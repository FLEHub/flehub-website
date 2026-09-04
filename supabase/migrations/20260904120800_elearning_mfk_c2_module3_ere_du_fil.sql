/*
  Seed eLearning MFK — C2 — L'ère du fil

  Micro-monde : cour « Le Seuil des Sources », Rukiri-Nord.
  6 séquences × 5 leçons × 10 exercices (tous les types).
  Illustrations originales : /elearning/mfk-c2-m3/
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
  v_module_title text := 'C2 — L''ère du fil';
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
      'Grande étape C2-3 : débattre du fil et des livres, adapter une campagne de prévention, lire le torrent des bruits sans source, écrire un paradoxe, puis un extrait de dystopie — Léa Niyonzima refuse le résumé trop court, Marc Nkurunziza nomme le bruit, Lampe-Figue reste un objet inventé, jamais une marque.',
      'C2',
      false
    )
    RETURNING id INTO v_module_id;
  ELSE
    UPDATE elearning_modules
    SET
      description = 'Grande étape C2-3 : débattre du fil et des livres, adapter une campagne de prévention, lire le torrent des bruits sans source, écrire un paradoxe, puis un extrait de dystopie — Léa Niyonzima refuse le résumé trop court, Marc Nkurunziza nomme le bruit, Lampe-Figue reste un objet inventé, jamais une marque.',
      cefr_level = 'C2',
      published = false,
      updated_at = now()
    WHERE id = v_module_id;
  END IF;

  -- ===== Le fil et le Cahier =====
  SELECT s.id INTO v_seq_id
  FROM elearning_sequences s
  WHERE s.module_id = v_module_id AND s.title = 'Le fil et le Cahier'
  LIMIT 1;

  IF v_seq_id IS NULL THEN
    INSERT INTO elearning_sequences (module_id, title, order_index)
    VALUES (v_module_id, 'Le fil et le Cahier', 0)
    RETURNING id INTO v_seq_id;
  ELSE
    UPDATE elearning_sequences
    SET order_index = 0
    WHERE id = v_seq_id;
  END IF;

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CO — Le fil et le Cahier',
    'CO',
    $c$Objectif
Comprendre un échange long et en extraire l'implicite. Débattre de l'impact du fil sur la lecture, sans nostalgie de boutique. Viser l'ironie, le sous-entendu, le registre et la synthèse de points de vue.

Consigne
Lisez le débat (à écouter avec l'enseignant). Qu'est-ce qui est dit, qu'est-ce qui reste implicite, qui concède quoi ?

Support — Débat Radio Figuier — Le fil et le Cahier
Lila Sow : Radio Figuier. On parle trop vite de le fil et le Cahier du chemin, comme si le mot dispensait d'en examiner le prix.
Marc Nkurunziza : Encore que l'on enterre le Cahier d'un tweet inventé trop court, un résumé qui se prend pour le livre n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Léa Niyonzima : Mado concède que un fil peut porter un vers jusqu'à une oreille nouvelle, pour autant que l'on n'y voie pas le droit de ne plus ouvrir la page.
Aline Uwase : Ce que l'on nomme fil, ici, n'est pas un slogan : flux inventé de la cour, trop rapide parfois.
Patrick Habimana : Mado : encore que le fil porte un vers, il n'a pas à se prendre pour la page.
Hawa Diallo : Léa refuse l'enterrement.
Joël Mugisha : Sami résume trop court ; Aline allonge.
Rose Iradukunda : Karim cite un lecteur nouveau, sans triomphe.
Solange Mukamana : Lila ouvrira un débat, pas un procès.
Karim Bamba : Patrick aime le papier et le fil, à deux vitesses.
Félicie Ndayishimiye : Un chiffre, une trace : Mado a vu vingt résumés trop courts ; trois lecteurs nouveaux ; zéro enterrement du Cahier.
Dieudonné Hakizimana : L'enjeu n'est pas d'avoir raison plus fort : il s'agit de lire plus loin, pas de gagner contre un écran
Yvette : Rose coud un signet.
Mado : Léa Niyonzima entend, dans « plus personne ne lit », ceci qui n'est pas dit : plus personne ne lit est souvent le cri de ceux qui n'aiment qu'une façon de lire
Sami : Autrement dit, certes le fil accélère, mais il n'a pas à remplacer la librairie immense du Cahier
Lila Sow : Je reformule pour les auditeurs. La proposition qui reste debout est celle-ci : un débat : trois positions, une concession obligatoire, un geste pour le Cahier
Nina Kayitesi : Marc : débattre, c'est concéder, pas gagner contre un écran.
Lila Sow : Nous clôturons sans clore. Nous clôturons sans fusionner les voix : les résumés trop courts du fil d'un côté, la tribune de Mado de l'autre, et le point où elles refusent de se ressembler.
Mado, plus bas, sans hausser le ton : Plus personne ne lit : constat commode, surtout à l'heure où l'on n'a pas ouvert le Cahier soi-même.
$c$,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "un résumé qui se prend pour le livre est présenté comme un simple détail sans conséquence.",
  "correct": false,
  "explanation": "Le texte affirme au contraire que un résumé qui se prend pour le livre n'est pas un détail."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Selon Léa Niyonzima, que reste-t-il implicite dans « plus personne ne lit » ?",
  "options": [
    {
      "text": "Que Mado a interdit le fil",
      "correct": false
    },
    {
      "text": "N'aimer qu'une façon de lire",
      "correct": true
    },
    {
      "text": "Que Léa n'ouvre plus le Cahier",
      "correct": false
    },
    {
      "text": "Que les trois lecteurs n'existent pas",
      "correct": false
    }
  ],
  "explanation": "plus personne ne lit est souvent le cri de ceux qui n'aiment qu'une façon de lire"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "fil",
      "right": "flux inventé de la cour, trop rapide parfois"
    },
    {
      "left": "résumé",
      "right": "raccourci, distinct de l'œuvre"
    },
    {
      "left": "lecture",
      "right": "pratique longue, pas un score"
    },
    {
      "left": "débat",
      "right": "échange avec concession"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nEncore que l'on ___ , un résumé qui se prend pour le livre n'est pas un détail. (lire, subj.)",
  "answer": "lise"
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
    "lise",
    "la",
    "lumière",
    "fil",
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
  "word": "fil",
  "hint": "flux inventé de la cour, trop rapide parfois"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Encore que l'on lire trop vite, un résumé qui se prend pour le livre n'est pas un détail, et Mado écoute.",
  "correct_sentence": "Encore que l'on lise trop vite, un résumé qui se prend pour le livre n'est pas un détail, et Mado écoute.",
  "explanation": "Après encore que : lise."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-c2-m3/librairie-immense.svg",
      "word": "librairie immense"
    },
    {
      "image_path": "/elearning/mfk-c2-m3/fil-litteraire.svg",
      "word": "fil litteraire"
    },
    {
      "image_path": "/elearning/mfk-c2-m3/debat-reseau.svg",
      "word": "debat reseau"
    },
    {
      "image_path": "/elearning/mfk-c2-m3/resume-court.svg",
      "word": "resume court"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Reformulez l'implicite de « plus personne ne lit » et la concession de Mado."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez une synthèse d'environ quatre-vingt-dix secondes : deux points de vue, un implicite, une proposition. Gardez les résumés trop courts du fil et la tribune de Mado distincts."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CE — Le résumé n''est pas le livre',
    'CE',
    $c$Objectif
Lire un texte argumenté long, synthétiser et reformuler. Débattre de l'impact du fil sur la lecture, sans nostalgie de boutique. Viser l'ironie, le sous-entendu, le registre et la synthèse de points de vue.

Consigne
Lisez « Le résumé n'est pas le livre », sans aller trop vite. Repérez la thèse, la concession, l'implicite et la proposition.

Support — Le résumé n'est pas le livre
On parle trop vite de le fil et le Cahier du chemin, comme si le mot dispensait d'en examiner le prix.
Encore que l'on enterre le Cahier d'un tweet inventé trop court, un résumé qui se prend pour le livre n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Mado concède que un fil peut porter un vers jusqu'à une oreille nouvelle, pour autant que l'on n'y voie pas le droit de ne plus ouvrir la page.
Ce que l'on nomme fil, ici, n'est pas un slogan : flux inventé de la cour, trop rapide parfois.
Mado : encore que le fil porte un vers, il n'a pas à se prendre pour la page.
Léa refuse l'enterrement.
Sami résume trop court ; Aline allonge.
Karim cite un lecteur nouveau, sans triomphe.
Lila ouvrira un débat, pas un procès.
Patrick aime le papier et le fil, à deux vitesses.
Un chiffre, une trace : Mado a vu vingt résumés trop courts ; trois lecteurs nouveaux ; zéro enterrement du Cahier.
L'enjeu n'est pas d'avoir raison plus fort : il s'agit de lire plus loin, pas de gagner contre un écran
Rose coud un signet.
Léa Niyonzima entend, dans « plus personne ne lit », ceci qui n'est pas dit : plus personne ne lit est souvent le cri de ceux qui n'aiment qu'une façon de lire
Autrement dit, certes le fil accélère, mais il n'a pas à remplacer la librairie immense du Cahier
La proposition qui reste debout est celle-ci : un débat : trois positions, une concession obligatoire, un geste pour le Cahier
Marc : débattre, c'est concéder, pas gagner contre un écran.
Nous clôturons sans fusionner les voix : les résumés trop courts du fil d'un côté, la tribune de Mado de l'autre, et le point où elles refusent de se ressembler.
Signé : Mado, Rukiri-Nord — Cahier des racines, Rukiri-Nord.
$c$,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Le texte refuse de fusionner les résumés trop courts du fil et la tribune de Mado en une seule affiche.",
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
      "text": "Vingt résumés trop courts, trois lecteurs nouveaux",
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
  "explanation": "Mado a vu vingt résumés trop courts ; trois lecteurs nouveaux ; zéro enterrement du Cahier."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "fil",
      "right": "flux inventé de la cour, trop rapide parfois"
    },
    {
      "left": "résumé",
      "right": "raccourci, distinct de l'œuvre"
    },
    {
      "left": "lecture",
      "right": "pratique longue, pas un score"
    },
    {
      "left": "débat",
      "right": "échange avec concession"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nLa ___ n'est un abri que si l'on en parle vraiment. (fil déjà nom ou verbe à nominaliser)",
  "answer": "fil"
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
    "fil",
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
  "word": "résumé",
  "hint": "raccourci, distinct de l'œuvre"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "La fil de trop vite n'aide personne, et Léa Niyonzima reprend le fil.",
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
      "image_path": "/elearning/mfk-c2-m3/fil-litteraire.svg",
      "word": "fil litteraire"
    },
    {
      "image_path": "/elearning/mfk-c2-m3/debat-reseau.svg",
      "word": "debat reseau"
    },
    {
      "image_path": "/elearning/mfk-c2-m3/resume-court.svg",
      "word": "resume court"
    },
    {
      "image_path": "/elearning/mfk-c2-m3/campagne-prevention.svg",
      "word": "campagne prevention"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Synthétisez « Le résumé n'est pas le livre » : thèse, concession, implicite, proposition (quinze lignes)."
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
    'PO — Le fil et le Cahier : dire sans slogan',
    'PO',
    $c$Objectif
Produire un oral structuré (thèse, concession, proposition). Point : accord, concession, désaccord ; fil et livres.

Consigne
Répétez les modèles, puis prenez position en une minute : thèse, concession, reformulation, proposition.

Support — Modèles d'Aline Uwase, banc du figuier
Encore que l'on enterre le Cahier d'un tweet inventé trop court, un résumé qui se prend pour le livre n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Mado concède que un fil peut porter un vers jusqu'à une oreille nouvelle, pour autant que l'on n'y voie pas le droit de ne plus ouvrir la page.
Ce que l'on nomme fil, ici, n'est pas un slogan : flux inventé de la cour, trop rapide parfois.
Encore que l'on lise, un résumé qui se prend pour le livre n'est pas un détail.
Mado concède que un fil peut porter un vers jusqu'à une oreille nouvelle, pour autant que l'on n'y voie pas le droit de ne plus ouvrir la page.
Autrement dit, certes le fil accélère, mais il n'a pas à remplacer la librairie immense du Cahier
Il ressort qu'un débat : trois positions, une concession obligatoire, un geste pour le Cahier
Léa refuse l'enterrement.
Lila ouvrira un débat, pas un procès.
La proposition qui reste debout est celle-ci : un débat : trois positions, une concession obligatoire, un geste pour le Cahier
Je concède le point, je n'abandonne pas la proposition.
Ce n'est pas que je refuse : c'est que je refuse qu'on nomme cela un détail.
Autrement dit, l'implicite fait autant de travail que la thèse.
En une minute : fait, angle, concession, proposition.
Nous clôturons sans fusionner les voix : les résumés trop courts du fil d'un côté, la tribune de Mado de l'autre, et le point où elles refusent de se ressembler.
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
  "explanation": "Mado concède que un fil peut porter un vers jusqu'à une oreille nouvelle, pour autant que l'on n'y voie pas le droit de ne plus ouvrir la page."
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
      "text": "un fil peut porter un vers jusqu'à une oreille nouvelle — à condition que l'on n'y voie pas le droit de ne plus ouvrir la page",
      "correct": true
    },
    {
      "text": "Mado abandonne il s'agit de lire plus loin, pas de gagner contre un écran",
      "correct": false
    },
    {
      "text": "La concession vaut acceptation du slogan",
      "correct": false
    }
  ],
  "explanation": "Concession réelle, pas un abandon : l'on n'y voie pas le droit de ne plus ouvrir la page"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "fil",
      "right": "flux inventé de la cour, trop rapide parfois"
    },
    {
      "left": "résumé",
      "right": "raccourci, distinct de l'œuvre"
    },
    {
      "left": "lecture",
      "right": "pratique longue, pas un score"
    },
    {
      "left": "débat",
      "right": "échange avec concession"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nPour autant que l'on ___ , Mado concède un point. (lire, subj.)",
  "answer": "lise"
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
    "débat",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "lecture",
  "hint": "pratique longue, pas un score"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Mado écoute encore, et il fautons lire avant de crier.",
  "correct_sentence": "Mado écoute encore, et il faut lire avant de crier.",
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
      "image_path": "/elearning/mfk-c2-m3/debat-reseau.svg",
      "word": "debat reseau"
    },
    {
      "image_path": "/elearning/mfk-c2-m3/resume-court.svg",
      "word": "resume court"
    },
    {
      "image_path": "/elearning/mfk-c2-m3/campagne-prevention.svg",
      "word": "campagne prevention"
    },
    {
      "image_path": "/elearning/mfk-c2-m3/public-cible.svg",
      "word": "public cible"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Écrivez six phrases orales justes : deux sur accord, concession, désaccord ; fil et livres, deux concessions, deux propositions."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez quatre modèles, puis votre prise de position (thèse, concession, proposition). Gardez les résumés trop courts du fil et la tribune de Mado distincts."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PE — le texte de Mado',
    'PE',
    $c$Objectif
Écrire un texte long et structuré. Débattre de l'impact du fil sur la lecture, sans nostalgie de boutique. Point : accord, concession, désaccord ; fil et livres.

Consigne
Imitez le texte de Mado.

Support — Mado — Le résumé n'est pas le livre
Mado — Le résumé n'est pas le livre
On parle trop vite de le fil et le Cahier du chemin, comme si le mot dispensait d'en examiner le prix.
Encore que l'on enterre le Cahier d'un tweet inventé trop court, un résumé qui se prend pour le livre n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Mado concède que un fil peut porter un vers jusqu'à une oreille nouvelle, pour autant que l'on n'y voie pas le droit de ne plus ouvrir la page.
Ce que l'on nomme fil, ici, n'est pas un slogan : flux inventé de la cour, trop rapide parfois.
Mado : encore que le fil porte un vers, il n'a pas à se prendre pour la page.
Lila ouvrira un débat, pas un procès.
Patrick aime le papier et le fil, à deux vitesses.
Rose coud un signet.
La proposition qui reste debout est celle-ci : un débat : trois positions, une concession obligatoire, un geste pour le Cahier
Marc : débattre, c'est concéder, pas gagner contre un écran.
Nous clôturons sans fusionner les voix : les résumés trop courts du fil d'un côté, la tribune de Mado de l'autre, et le point où elles refusent de se ressembler.
Encore que l'on lise, un résumé qui se prend pour le livre n'est pas un détail.
Mado concède que un fil peut porter un vers jusqu'à une oreille nouvelle, pour autant que l'on n'y voie pas le droit de ne plus ouvrir la page.
Je n'écris pas pour vaincre : j'écris pour que la cour puisse relire.
certes le fil accélère, mais il n'a pas à remplacer la librairie immense du Cahier
Mado, Rukiri-Nord
$c$,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "La proposition retenue est : un débat : trois positions, une concession obligatoire, un geste pour le Cahier",
  "correct": true,
  "explanation": "un débat : trois positions, une concession obligatoire, un geste pour le Cahier"
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
      "text": "un débat : trois positions, une concession obligatoire, un geste pour le Cahier",
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
  "explanation": "un débat : trois positions, une concession obligatoire, un geste pour le Cahier"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "fil",
      "right": "flux inventé de la cour, trop rapide parfois"
    },
    {
      "left": "résumé",
      "right": "raccourci, distinct de l'œuvre"
    },
    {
      "left": "lecture",
      "right": "pratique longue, pas un score"
    },
    {
      "left": "débat",
      "right": "échange avec concession"
    }
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
  "word": "débat",
  "hint": "échange avec concession"
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
      "image_path": "/elearning/mfk-c2-m3/resume-court.svg",
      "word": "resume court"
    },
    {
      "image_path": "/elearning/mfk-c2-m3/campagne-prevention.svg",
      "word": "campagne prevention"
    },
    {
      "image_path": "/elearning/mfk-c2-m3/public-cible.svg",
      "word": "public cible"
    },
    {
      "image_path": "/elearning/mfk-c2-m3/conseil-adapte.svg",
      "word": "conseil adapte"
    }
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
    'EL — accord, concession, désaccord ; fil et livres',
    'EL',
    $c$Objectif
Maîtriser accord, concession, désaccord ; fil et livres au registre C2, avec collocations et pièges de construction.

Consigne
Apprenez la fiche, puis produisez des exemples justes au registre demandé.

Support — Fiche d'Aline Uwase, banc ocre
Fiche C2 — accord, concession, désaccord ; fil et livres
On ne retient pas une liste : on retient des constructions et des collocations.
Encore que l'on lise, un résumé qui se prend pour le livre n'est pas un détail.
Mado concède que un fil peut porter un vers jusqu'à une oreille nouvelle, pour autant que l'on n'y voie pas le droit de ne plus ouvrir la page.
Autrement dit, certes le fil accélère, mais il n'a pas à remplacer la librairie immense du Cahier
Il ressort qu'un débat : trois positions, une concession obligatoire, un geste pour le Cahier
Piège : indicatif après encore que
Registre : soutenu argumentatif, sans slogan
Collocation : encore que, pour autant que, il ressort que
Ce que l'on nomme fil, ici, n'est pas un slogan : flux inventé de la cour, trop rapide parfois.
Léa refuse l'enterrement.
Lila ouvrira un débat, pas un procès.
Nominaliser, ce n'est pas alourdir : c'est nommer le processus (la densification, l'accueil, le rappel).
Encore que / pour autant que / si tant est que : subjonctif, concession réelle, pas un ornement.
Reformuler une source : on change la syntaxe, on garde la charge, on signale le point de vue.
C1 : l'implicite se justifie. C2 : l'ironie se laisse entendre sans s'afficher.
Exemple fautif à ne plus produire : On va au lecture pour de vrai genre, et Léa Niyonzima demande un registre plus net.
Correction : On va au lecture vraiment, et Léa Niyonzima demande un registre plus net.
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
      "left": "fil",
      "right": "flux inventé de la cour, trop rapide parfois"
    },
    {
      "left": "résumé",
      "right": "raccourci, distinct de l'œuvre"
    },
    {
      "left": "lecture",
      "right": "pratique longue, pas un score"
    },
    {
      "left": "débat",
      "right": "échange avec concession"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nOn dira la ___ plutôt qu'un slogan. (nom de résumé)",
  "answer": "résumé"
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
    "lise",
    "Mado",
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
  "sentence_with_error": "On va au lecture pour de vrai genre, et Léa Niyonzima demande un registre plus net.",
  "correct_sentence": "On va au lecture vraiment, et Léa Niyonzima demande un registre plus net.",
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
      "image_path": "/elearning/mfk-c2-m3/campagne-prevention.svg",
      "word": "campagne prevention"
    },
    {
      "image_path": "/elearning/mfk-c2-m3/public-cible.svg",
      "word": "public cible"
    },
    {
      "image_path": "/elearning/mfk-c2-m3/conseil-adapte.svg",
      "word": "conseil adapte"
    },
    {
      "image_path": "/elearning/mfk-c2-m3/affiche-gaffe.svg",
      "word": "affiche gaffe"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Tableau de langue : six exemples justes de « accord, concession, désaccord ; fil et livres » et deux pièges commentés."
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

  -- ===== Deux tons un même soin =====
  SELECT s.id INTO v_seq_id
  FROM elearning_sequences s
  WHERE s.module_id = v_module_id AND s.title = 'Deux tons un même soin'
  LIMIT 1;

  IF v_seq_id IS NULL THEN
    INSERT INTO elearning_sequences (module_id, title, order_index)
    VALUES (v_module_id, 'Deux tons un même soin', 1)
    RETURNING id INTO v_seq_id;
  ELSE
    UPDATE elearning_sequences
    SET order_index = 1
    WHERE id = v_seq_id;
  END IF;

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CO — Deux tons un même soin',
    'CO',
    $c$Objectif
Comprendre un échange long et en extraire l'implicite. Adapter une campagne de prévention à un public de cour, sans panique. Viser l'ironie, le sous-entendu, le registre et la synthèse de points de vue.

Consigne
Lisez le débat (à écouter avec l'enseignant). Qu'est-ce qui est dit, qu'est-ce qui reste implicite, qui concède quoi ?

Support — Débat Radio Figuier — Deux tons un même soin
Lila Sow : Radio Figuier. On parle trop vite de une campagne trop criée contre le fil, comme si le mot dispensait d'en examiner le prix.
Marc Nkurunziza : Encore que l'on remplace l'argument par la peur, une affiche qui parle à tout le monde, donc à personne n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Léa Niyonzima : Léa Niyonzima concède que alerter peut être juste, pour autant que l'on nomme un public, un risque, un geste, pas une panique.
Aline Uwase : Ce que l'on nomme campagne, ici, n'est pas un slogan : discours préventif adapté.
Patrick Habimana : Léa : on ferait mieux d'écrire pour une oreille, non pour une foule.
Hawa Diallo : Il vaudrait mieux que tu lises la version d'Yvette avant de crier.
Joël Mugisha : Sami corrige le trop jeune trop faux.
Rose Iradukunda : Aline refuse le slogan orphelin.
Solange Mukamana : Lila lira les deux tons.
Karim Bamba : Patrick veut le fait, pas la peur.
Félicie Ndayishimiye : Un chiffre, une trace : Léa a écrit deux versions ; Sami a corrigé la sienne ; Yvette la sienne ; zéro panique retenue.
Dieudonné Hakizimana : L'enjeu n'est pas d'avoir raison plus fort : il s'agit de prévenir, pas d'humilier l'usage
Yvette : Rose affiche sans rouge trop violent.
Mado : Sami entend, dans « ouvrez l'œil », ceci qui n'est pas dit : une affiche pour tous évite souvent de parler aux plus exposés
Sami : Autrement dit, on ferait mieux d'écrire deux versions : banc des jeunes, banc des anciens, même soin
Lila Sow : Je reformule pour les auditeurs. La proposition qui reste debout est celle-ci : une campagne : deux tons, un même fait, zéro slogan orphelin
Nina Kayitesi : Marc : adapter un discours, c'est respecter l'interlocuteur.
Lila Sow : Nous clôturons sans clore. Nous clôturons sans fusionner les voix : l'affiche trop criée d'un côté, les deux versions de Léa de l'autre, et le point où elles refusent de se ressembler.
Mado, plus bas, sans hausser le ton : Ouvrez l'œil : on reconnaît la pédagogie de ceux qui n'ont pas le temps de nommer le risque.
$c$,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "une affiche qui parle à tout le monde, donc à personne est présenté comme un simple détail sans conséquence.",
  "correct": false,
  "explanation": "Le texte affirme au contraire que une affiche qui parle à tout le monde, donc à personne n'est pas un détail."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Selon Sami, que reste-t-il implicite dans « ouvrez l'œil » ?",
  "options": [
    {
      "text": "Que Léa a humilié Sami",
      "correct": false
    },
    {
      "text": "Éviter les plus exposés",
      "correct": true
    },
    {
      "text": "Que Yvette a refusé toute alerte",
      "correct": false
    },
    {
      "text": "Que la panique a été retenue",
      "correct": false
    }
  ],
  "explanation": "une affiche pour tous évite souvent de parler aux plus exposés"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "campagne",
      "right": "discours préventif adapté"
    },
    {
      "left": "public",
      "right": "oreille visée, nommée"
    },
    {
      "left": "risque",
      "right": "danger précis, pas une panique"
    },
    {
      "left": "version",
      "right": "adaptation de ton, même fait"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nOn ___ lire l'étiquette deux fois, non l'application une fois. (faire mieux de, cond.)",
  "answer": "ferait mieux de"
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
    "ferait",
    "mieux",
    "de",
    "lire",
    "l'étiquette",
    "deux",
    "fois",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "campagne",
  "hint": "discours préventif adapté"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Il vaudrait mieux que tu adapter le bol trop vite, et Léa Niyonzima pose l'étiquette.",
  "correct_sentence": "Il vaudrait mieux que tu adapte le bol trop vite, et Léa Niyonzima pose l'étiquette.",
  "explanation": "Il vaudrait mieux que + adapte."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-c2-m3/public-cible.svg",
      "word": "public cible"
    },
    {
      "image_path": "/elearning/mfk-c2-m3/conseil-adapte.svg",
      "word": "conseil adapte"
    },
    {
      "image_path": "/elearning/mfk-c2-m3/affiche-gaffe.svg",
      "word": "affiche gaffe"
    },
    {
      "image_path": "/elearning/mfk-c2-m3/torrent-infos.svg",
      "word": "torrent infos"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Reformulez l'implicite de « ouvrez l'œil » et la concession de Léa Niyonzima."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez une synthèse d'environ quatre-vingt-dix secondes : deux points de vue, un implicite, une proposition. Gardez l'affiche trop criée et les deux versions de Léa distincts."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CE — Deux tons, un même soin',
    'CE',
    $c$Objectif
Lire un texte argumenté long, synthétiser et reformuler. Adapter une campagne de prévention à un public de cour, sans panique. Viser l'ironie, le sous-entendu, le registre et la synthèse de points de vue.

Consigne
Lisez « Deux tons, un même soin », sans aller trop vite. Repérez la thèse, la concession, l'implicite et la proposition.

Support — Deux tons, un même soin
On parle trop vite de une campagne trop criée contre le fil, comme si le mot dispensait d'en examiner le prix.
Encore que l'on remplace l'argument par la peur, une affiche qui parle à tout le monde, donc à personne n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Léa Niyonzima concède que alerter peut être juste, pour autant que l'on nomme un public, un risque, un geste, pas une panique.
Ce que l'on nomme campagne, ici, n'est pas un slogan : discours préventif adapté.
Léa : on ferait mieux d'écrire pour une oreille, non pour une foule.
Il vaudrait mieux que tu lises la version d'Yvette avant de crier.
Sami corrige le trop jeune trop faux.
Aline refuse le slogan orphelin.
Lila lira les deux tons.
Patrick veut le fait, pas la peur.
Un chiffre, une trace : Léa a écrit deux versions ; Sami a corrigé la sienne ; Yvette la sienne ; zéro panique retenue.
L'enjeu n'est pas d'avoir raison plus fort : il s'agit de prévenir, pas d'humilier l'usage
Rose affiche sans rouge trop violent.
Sami entend, dans « ouvrez l'œil », ceci qui n'est pas dit : une affiche pour tous évite souvent de parler aux plus exposés
Autrement dit, on ferait mieux d'écrire deux versions : banc des jeunes, banc des anciens, même soin
La proposition qui reste debout est celle-ci : une campagne : deux tons, un même fait, zéro slogan orphelin
Marc : adapter un discours, c'est respecter l'interlocuteur.
Nous clôturons sans fusionner les voix : l'affiche trop criée d'un côté, les deux versions de Léa de l'autre, et le point où elles refusent de se ressembler.
Signé : Léa Niyonzima, Rukiri-Nord — Cahier des racines, Rukiri-Nord.
$c$,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Le texte refuse de fusionner l'affiche trop criée et les deux versions de Léa en une seule affiche.",
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
      "text": "Deux versions, deux corrections, zéro panique",
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
  "explanation": "Léa a écrit deux versions ; Sami a corrigé la sienne ; Yvette la sienne ; zéro panique retenue."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "campagne",
      "right": "discours préventif adapté"
    },
    {
      "left": "public",
      "right": "oreille visée, nommée"
    },
    {
      "left": "risque",
      "right": "danger précis, pas une panique"
    },
    {
      "left": "version",
      "right": "adaptation de ton, même fait"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nIl vaudrait mieux que tu ___ le bol avant le slogan. (adapter, subj.)",
  "answer": "adapte"
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
    "vaudrait",
    "mieux",
    "que",
    "tu",
    "adapte",
    "le",
    "bol",
    "avant",
    "le",
    "slogan",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "public",
  "hint": "oreille visée, nommée"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "La campagne de trop vite n'aide personne, et Sami reprend le fil.",
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
      "image_path": "/elearning/mfk-c2-m3/conseil-adapte.svg",
      "word": "conseil adapte"
    },
    {
      "image_path": "/elearning/mfk-c2-m3/affiche-gaffe.svg",
      "word": "affiche gaffe"
    },
    {
      "image_path": "/elearning/mfk-c2-m3/torrent-infos.svg",
      "word": "torrent infos"
    },
    {
      "image_path": "/elearning/mfk-c2-m3/paradoxe-article.svg",
      "word": "paradoxe article"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Synthétisez « Deux tons, un même soin » : thèse, concession, implicite, proposition (quinze lignes)."
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
    'PO — Deux tons un même soin : dire sans slogan',
    'PO',
    $c$Objectif
Produire un oral structuré (thèse, concession, proposition). Point : adapter un discours ; conseils ; public visé.

Consigne
Répétez les modèles, puis prenez position en une minute : thèse, concession, reformulation, proposition.

Support — Modèles d'Aline Uwase, banc du figuier
Encore que l'on remplace l'argument par la peur, une affiche qui parle à tout le monde, donc à personne n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Léa Niyonzima concède que alerter peut être juste, pour autant que l'on nomme un public, un risque, un geste, pas une panique.
Ce que l'on nomme campagne, ici, n'est pas un slogan : discours préventif adapté.
Encore que l'on adapte, une affiche qui parle à tout le monde, donc à personne n'est pas un détail.
Léa Niyonzima concède que alerter peut être juste, pour autant que l'on nomme un public, un risque, un geste, pas une panique.
Autrement dit, on ferait mieux d'écrire deux versions : banc des jeunes, banc des anciens, même soin
Il ressort qu'une campagne : deux tons, un même fait, zéro slogan orphelin
Il vaudrait mieux que tu lises la version d'Yvette avant de crier.
Lila lira les deux tons.
La proposition qui reste debout est celle-ci : une campagne : deux tons, un même fait, zéro slogan orphelin
Je concède le point, je n'abandonne pas la proposition.
Ce n'est pas que je refuse : c'est que je refuse qu'on nomme cela un détail.
Autrement dit, l'implicite fait autant de travail que la thèse.
En une minute : fait, angle, concession, proposition.
Nous clôturons sans fusionner les voix : l'affiche trop criée d'un côté, les deux versions de Léa de l'autre, et le point où elles refusent de se ressembler.
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
  "explanation": "Léa Niyonzima concède que alerter peut être juste, pour autant que l'on nomme un public, un risque, un geste, pas une panique."
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
      "text": "alerter peut être juste — à condition que l'on nomme un public, un risque, un geste, pas une panique",
      "correct": true
    },
    {
      "text": "Léa Niyonzima abandonne il s'agit de prévenir, pas d'humilier l'usage",
      "correct": false
    },
    {
      "text": "La concession vaut acceptation du slogan",
      "correct": false
    }
  ],
  "explanation": "Concession réelle, pas un abandon : l'on nomme un public, un risque, un geste, pas une panique"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "campagne",
      "right": "discours préventif adapté"
    },
    {
      "left": "public",
      "right": "oreille visée, nommée"
    },
    {
      "left": "risque",
      "right": "danger précis, pas une panique"
    },
    {
      "left": "version",
      "right": "adaptation de ton, même fait"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nPourquoi ne pas ___ le Fil-des-Herbes comme un avis, non une loi ? (traiter)",
  "answer": "traiter"
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
    "ne",
    "pas",
    "traiter",
    "l'outil",
    "comme",
    "un",
    "avis",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "risque",
  "hint": "danger précis, pas une panique"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Léa Niyonzima écoute encore, et il fautons adapter avant de crier.",
  "correct_sentence": "Léa Niyonzima écoute encore, et il faut adapter avant de crier.",
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
      "image_path": "/elearning/mfk-c2-m3/affiche-gaffe.svg",
      "word": "affiche gaffe"
    },
    {
      "image_path": "/elearning/mfk-c2-m3/torrent-infos.svg",
      "word": "torrent infos"
    },
    {
      "image_path": "/elearning/mfk-c2-m3/paradoxe-article.svg",
      "word": "paradoxe article"
    },
    {
      "image_path": "/elearning/mfk-c2-m3/bruit-vrai.svg",
      "word": "bruit vrai"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Écrivez six phrases orales justes : deux sur adapter un discours ; conseils ; public visé, deux concessions, deux propositions."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez quatre modèles, puis votre prise de position (thèse, concession, proposition). Gardez l'affiche trop criée et les deux versions de Léa distincts."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PE — le texte de Léa Niyonzima',
    'PE',
    $c$Objectif
Écrire un texte long et structuré. Adapter une campagne de prévention à un public de cour, sans panique. Point : adapter un discours ; conseils ; public visé.

Consigne
Imitez le texte de Léa Niyonzima.

Support — Léa Niyonzima — Deux tons, un même soin
Léa Niyonzima — Deux tons, un même soin
On parle trop vite de une campagne trop criée contre le fil, comme si le mot dispensait d'en examiner le prix.
Encore que l'on remplace l'argument par la peur, une affiche qui parle à tout le monde, donc à personne n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Léa Niyonzima concède que alerter peut être juste, pour autant que l'on nomme un public, un risque, un geste, pas une panique.
Ce que l'on nomme campagne, ici, n'est pas un slogan : discours préventif adapté.
Léa : on ferait mieux d'écrire pour une oreille, non pour une foule.
Lila lira les deux tons.
Patrick veut le fait, pas la peur.
Rose affiche sans rouge trop violent.
La proposition qui reste debout est celle-ci : une campagne : deux tons, un même fait, zéro slogan orphelin
Marc : adapter un discours, c'est respecter l'interlocuteur.
Nous clôturons sans fusionner les voix : l'affiche trop criée d'un côté, les deux versions de Léa de l'autre, et le point où elles refusent de se ressembler.
Encore que l'on adapte, une affiche qui parle à tout le monde, donc à personne n'est pas un détail.
Léa Niyonzima concède que alerter peut être juste, pour autant que l'on nomme un public, un risque, un geste, pas une panique.
Je n'écris pas pour vaincre : j'écris pour que la cour puisse relire.
on ferait mieux d'écrire deux versions : banc des jeunes, banc des anciens, même soin
Léa Niyonzima, Rukiri-Nord
$c$,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "La proposition retenue est : une campagne : deux tons, un même fait, zéro slogan orphelin",
  "correct": true,
  "explanation": "une campagne : deux tons, un même fait, zéro slogan orphelin"
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
      "text": "une campagne : deux tons, un même fait, zéro slogan orphelin",
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
  "explanation": "une campagne : deux tons, un même fait, zéro slogan orphelin"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "campagne",
      "right": "discours préventif adapté"
    },
    {
      "left": "public",
      "right": "oreille visée, nommée"
    },
    {
      "left": "risque",
      "right": "danger précis, pas une panique"
    },
    {
      "left": "version",
      "right": "adaptation de ton, même fait"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nEncore que l'outil ___ pratique, il n'achète pas à notre place. (être, subj.)",
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
    "l'outil",
    "soit",
    "pratique",
    "il",
    "n'achète",
    "pas",
    "à",
    "notre",
    "place",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "version",
  "hint": "adaptation de ton, même fait"
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
      "image_path": "/elearning/mfk-c2-m3/torrent-infos.svg",
      "word": "torrent infos"
    },
    {
      "image_path": "/elearning/mfk-c2-m3/paradoxe-article.svg",
      "word": "paradoxe article"
    },
    {
      "image_path": "/elearning/mfk-c2-m3/bruit-vrai.svg",
      "word": "bruit vrai"
    },
    {
      "image_path": "/elearning/mfk-c2-m3/loupe-source.svg",
      "word": "loupe source"
    }
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
    'EL — adapter un discours ; conseils ; public visé',
    'EL',
    $c$Objectif
Maîtriser adapter un discours ; conseils ; public visé au registre C2, avec collocations et pièges de construction.

Consigne
Apprenez la fiche, puis produisez des exemples justes au registre demandé.

Support — Fiche d'Aline Uwase, banc ocre
Fiche C2 — adapter un discours ; conseils ; public visé
On ne retient pas une liste : on retient des constructions et des collocations.
Encore que l'on adapte, une affiche qui parle à tout le monde, donc à personne n'est pas un détail.
Léa Niyonzima concède que alerter peut être juste, pour autant que l'on nomme un public, un risque, un geste, pas une panique.
Autrement dit, on ferait mieux d'écrire deux versions : banc des jeunes, banc des anciens, même soin
Il ressort qu'une campagne : deux tons, un même fait, zéro slogan orphelin
Piège : impératif brutal à la place du conditionnel de conseil
Registre : soutenu argumentatif, sans slogan
Collocation : encore que, pour autant que, il ressort que
Ce que l'on nomme campagne, ici, n'est pas un slogan : discours préventif adapté.
Il vaudrait mieux que tu lises la version d'Yvette avant de crier.
Lila lira les deux tons.
Nominaliser, ce n'est pas alourdir : c'est nommer le processus (la densification, l'accueil, le rappel).
Encore que / pour autant que / si tant est que : subjonctif, concession réelle, pas un ornement.
Reformuler une source : on change la syntaxe, on garde la charge, on signale le point de vue.
C1 : l'implicite se justifie. C2 : l'ironie se laisse entendre sans s'afficher.
Exemple fautif à ne plus produire : On va au risque pour de vrai genre, et Sami demande un registre plus net.
Correction : On va au risque vraiment, et Sami demande un registre plus net.
Aline Uwase, banc ocre — Le Seuil des Sources.
$c$,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "« On ferait mieux de » atténue un conseil.",
  "correct": true,
  "explanation": "Conditionnel de conseil."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Pour conseiller sans ordonner, on privilégie…",
  "options": [
    {
      "text": "fais ! seulement",
      "correct": false
    },
    {
      "text": "on ferait mieux de / il vaudrait mieux que",
      "correct": true
    },
    {
      "text": "il fautons",
      "correct": false
    },
    {
      "text": "le slogan",
      "correct": false
    }
  ],
  "explanation": "Conditionnel et subjonctif de conseil."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "campagne",
      "right": "discours préventif adapté"
    },
    {
      "left": "public",
      "right": "oreille visée, nommée"
    },
    {
      "left": "risque",
      "right": "danger précis, pas une panique"
    },
    {
      "left": "version",
      "right": "adaptation de ton, même fait"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nUn ___ n'est pas un ordre. (conseil)",
  "answer": "conseil"
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
    "conseil",
    "n'est",
    "pas",
    "un",
    "ordre",
    "."
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
  "sentence_with_error": "On va au risque pour de vrai genre, et Sami demande un registre plus net.",
  "correct_sentence": "On va au risque vraiment, et Sami demande un registre plus net.",
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
      "image_path": "/elearning/mfk-c2-m3/paradoxe-article.svg",
      "word": "paradoxe article"
    },
    {
      "image_path": "/elearning/mfk-c2-m3/bruit-vrai.svg",
      "word": "bruit vrai"
    },
    {
      "image_path": "/elearning/mfk-c2-m3/loupe-source.svg",
      "word": "loupe source"
    },
    {
      "image_path": "/elearning/mfk-c2-m3/dystopie-demain.svg",
      "word": "dystopie demain"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Tableau de langue : six exemples justes de « adapter un discours ; conseils ; public visé » et deux pièges commentés."
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

  -- ===== Le bruit sans source =====
  SELECT s.id INTO v_seq_id
  FROM elearning_sequences s
  WHERE s.module_id = v_module_id AND s.title = 'Le bruit sans source'
  LIMIT 1;

  IF v_seq_id IS NULL THEN
    INSERT INTO elearning_sequences (module_id, title, order_index)
    VALUES (v_module_id, 'Le bruit sans source', 2)
    RETURNING id INTO v_seq_id;
  ELSE
    UPDATE elearning_sequences
    SET order_index = 2
    WHERE id = v_seq_id;
  END IF;

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CO — Le bruit sans source',
    'CO',
    $c$Objectif
Comprendre un échange long et en extraire l'implicite. Comprendre le processus d'un bruit sans source et écrire un paradoxe. Viser l'ironie, le sous-entendu, le registre et la synthèse de points de vue.

Consigne
Lisez le débat (à écouter avec l'enseignant). Qu'est-ce qui est dit, qu'est-ce qui reste implicite, qui concède quoi ?

Support — Débat Radio Figuier — Le bruit sans source
Lila Sow : Radio Figuier. On parle trop vite de un bruit trop vite vrai sous le figuier, comme si le mot dispensait d'en examiner le prix.
Marc Nkurunziza : Encore que l'on prend le torrent pour une preuve, une rumeur qui n'a plus d'auteur n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Léa Niyonzima : Marc Nkurunziza concède que la répétition peut alerter, pour autant que l'on cherche encore qui a parlé d'abord.
Aline Uwase : Ce que l'on nomme rumeur, ici, n'est pas un slogan : bruit sans auteur, trop vite vrai.
Patrick Habimana : Marc : loin de s'informer, la cour s'inondait, et bel et bien personne n'avait de source.
Hawa Diallo : Lila dément trop tard, ce qui est déjà une leçon.
Joël Mugisha : Aline : le paradoxe n'est pas un jeu, c'est une alarme.
Rose Iradukunda : Léa retrace, échoue, le dit.
Solange Mukamana : Karim refuse le partout.
Karim Bamba : Sami avait partagé trop vite ; il le dit aussi.
Félicie Ndayishimiye : Un chiffre, une trace : Marc a retracé zéro source ; sept répétitions ; une démenti tardif de Lila.
Dieudonné Hakizimana : L'enjeu n'est pas d'avoir raison plus fort : il s'agit de ralentir le bruit, pas d'interdire le fil
Yvette : Patrick veut un article, pas une chasse.
Mado : Lila Sow entend, dans « c'est partout donc c'est vrai », ceci qui n'est pas dit : partout donc vrai est la grammaire du torrent, pas celle d'une enquête
Sami : Autrement dit, loin de s'informer, on s'inonde ; bel et bien une source manquait
Lila Sow : Je reformule pour les auditeurs. La proposition qui reste debout est celle-ci : un article-paradoxe : plus l'on répète, moins l'on sait, sauf si l'on nomme
Nina Kayitesi : Mado glisse une ironie, puis une méthode.
Lila Sow : Nous clôturons sans clore. Nous clôturons sans fusionner les voix : le torrent du fil d'un côté, l'article de Marc de l'autre, et le point où elles refusent de se ressembler.
Mado, plus bas, sans hausser le ton : C'est partout donc c'est vrai : on admirera la rigueur du donc.
$c$,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "une rumeur qui n'a plus d'auteur est présenté comme un simple détail sans conséquence.",
  "correct": false,
  "explanation": "Le texte affirme au contraire que une rumeur qui n'a plus d'auteur n'est pas un détail."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Selon Lila Sow, que reste-t-il implicite dans « c'est partout donc c'est vrai » ?",
  "options": [
    {
      "text": "Que Marc a inventé la rumeur",
      "correct": false
    },
    {
      "text": "La grammaire du torrent, pas de l'enquête",
      "correct": true
    },
    {
      "text": "Que Lila a refusé le démenti",
      "correct": false
    },
    {
      "text": "Que sept répétitions valent une enquête",
      "correct": false
    }
  ],
  "explanation": "partout donc vrai est la grammaire du torrent, pas celle d'une enquête"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "rumeur",
      "right": "bruit sans auteur, trop vite vrai"
    },
    {
      "left": "source",
      "right": "origine nommée d'une info"
    },
    {
      "left": "paradoxe",
      "right": "formule qui tient deux vérités contraires"
    },
    {
      "left": "torrent",
      "right": "flux trop fort pour une enquête"
    }
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
  "word": "rumeur",
  "hint": "bruit sans auteur, trop vite vrai"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Si tant est que le bonheur s'industrialise, il se vend déjà, et Marc Nkurunziza sourit trop large.",
  "correct_sentence": "Si tant est que le bonheur s'industrialise, il se vendrait déjà, et Marc Nkurunziza sourit trop large.",
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
      "image_path": "/elearning/mfk-c2-m3/bruit-vrai.svg",
      "word": "bruit vrai"
    },
    {
      "image_path": "/elearning/mfk-c2-m3/loupe-source.svg",
      "word": "loupe source"
    },
    {
      "image_path": "/elearning/mfk-c2-m3/dystopie-demain.svg",
      "word": "dystopie demain"
    },
    {
      "image_path": "/elearning/mfk-c2-m3/machine-voix.svg",
      "word": "machine voix"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Reformulez l'implicite de « c'est partout donc c'est vrai » et la concession de Marc Nkurunziza."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez une synthèse d'environ quatre-vingt-dix secondes : deux points de vue, un implicite, une proposition. Gardez le torrent du fil et l'article de Marc distincts."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CE — Partout n''est pas une source',
    'CE',
    $c$Objectif
Lire un texte argumenté long, synthétiser et reformuler. Comprendre le processus d'un bruit sans source et écrire un paradoxe. Viser l'ironie, le sous-entendu, le registre et la synthèse de points de vue.

Consigne
Lisez « Partout n'est pas une source », sans aller trop vite. Repérez la thèse, la concession, l'implicite et la proposition.

Support — Partout n'est pas une source
On parle trop vite de un bruit trop vite vrai sous le figuier, comme si le mot dispensait d'en examiner le prix.
Encore que l'on prend le torrent pour une preuve, une rumeur qui n'a plus d'auteur n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Marc Nkurunziza concède que la répétition peut alerter, pour autant que l'on cherche encore qui a parlé d'abord.
Ce que l'on nomme rumeur, ici, n'est pas un slogan : bruit sans auteur, trop vite vrai.
Marc : loin de s'informer, la cour s'inondait, et bel et bien personne n'avait de source.
Lila dément trop tard, ce qui est déjà une leçon.
Aline : le paradoxe n'est pas un jeu, c'est une alarme.
Léa retrace, échoue, le dit.
Karim refuse le partout.
Sami avait partagé trop vite ; il le dit aussi.
Un chiffre, une trace : Marc a retracé zéro source ; sept répétitions ; une démenti tardif de Lila.
L'enjeu n'est pas d'avoir raison plus fort : il s'agit de ralentir le bruit, pas d'interdire le fil
Patrick veut un article, pas une chasse.
Lila Sow entend, dans « c'est partout donc c'est vrai », ceci qui n'est pas dit : partout donc vrai est la grammaire du torrent, pas celle d'une enquête
Autrement dit, loin de s'informer, on s'inonde ; bel et bien une source manquait
La proposition qui reste debout est celle-ci : un article-paradoxe : plus l'on répète, moins l'on sait, sauf si l'on nomme
Mado glisse une ironie, puis une méthode.
Nous clôturons sans fusionner les voix : le torrent du fil d'un côté, l'article de Marc de l'autre, et le point où elles refusent de se ressembler.
Signé : Marc Nkurunziza, Rukiri-Nord — Cahier des racines, Rukiri-Nord.
$c$,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Le texte refuse de fusionner le torrent du fil et l'article de Marc en une seule affiche.",
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
      "text": "Zéro source, sept répétitions, un démenti tardif",
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
  "explanation": "Marc a retracé zéro source ; sept répétitions ; une démenti tardif de Lila."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "rumeur",
      "right": "bruit sans auteur, trop vite vrai"
    },
    {
      "left": "source",
      "right": "origine nommée d'une info"
    },
    {
      "left": "paradoxe",
      "right": "formule qui tient deux vérités contraires"
    },
    {
      "left": "torrent",
      "right": "flux trop fort pour une enquête"
    }
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
  "word": "source",
  "hint": "origine nommée d'une info"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "La rumeur de trop vite n'aide personne, et Lila Sow reprend le fil.",
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
      "image_path": "/elearning/mfk-c2-m3/loupe-source.svg",
      "word": "loupe source"
    },
    {
      "image_path": "/elearning/mfk-c2-m3/dystopie-demain.svg",
      "word": "dystopie demain"
    },
    {
      "image_path": "/elearning/mfk-c2-m3/machine-voix.svg",
      "word": "machine voix"
    },
    {
      "image_path": "/elearning/mfk-c2-m3/extrait-noir.svg",
      "word": "extrait noir"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Synthétisez « Partout n'est pas une source » : thèse, concession, implicite, proposition (quinze lignes)."
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
    'PO — Le bruit sans source : dire sans slogan',
    'PO',
    $c$Objectif
Produire un oral structuré (thèse, concession, proposition). Point : paradoxe ; bruit sans source ; loin de / bel et bien.

Consigne
Répétez les modèles, puis prenez position en une minute : thèse, concession, reformulation, proposition.

Support — Modèles d'Aline Uwase, banc du figuier
Encore que l'on prend le torrent pour une preuve, une rumeur qui n'a plus d'auteur n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Marc Nkurunziza concède que la répétition peut alerter, pour autant que l'on cherche encore qui a parlé d'abord.
Ce que l'on nomme rumeur, ici, n'est pas un slogan : bruit sans auteur, trop vite vrai.
Encore que l'on nomme, une rumeur qui n'a plus d'auteur n'est pas un détail.
Marc Nkurunziza concède que la répétition peut alerter, pour autant que l'on cherche encore qui a parlé d'abord.
Autrement dit, loin de s'informer, on s'inonde ; bel et bien une source manquait
Il ressort qu'un article-paradoxe : plus l'on répète, moins l'on sait, sauf si l'on nomme
Lila dément trop tard, ce qui est déjà une leçon.
Karim refuse le partout.
La proposition qui reste debout est celle-ci : un article-paradoxe : plus l'on répète, moins l'on sait, sauf si l'on nomme
Je concède le point, je n'abandonne pas la proposition.
Ce n'est pas que je refuse : c'est que je refuse qu'on nomme cela un détail.
Autrement dit, l'implicite fait autant de travail que la thèse.
En une minute : fait, angle, concession, proposition.
Nous clôturons sans fusionner les voix : le torrent du fil d'un côté, l'article de Marc de l'autre, et le point où elles refusent de se ressembler.
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
  "explanation": "Marc Nkurunziza concède que la répétition peut alerter, pour autant que l'on cherche encore qui a parlé d'abord."
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
      "text": "la répétition peut alerter — à condition que l'on cherche encore qui a parlé d'abord",
      "correct": true
    },
    {
      "text": "Marc Nkurunziza abandonne il s'agit de ralentir le bruit, pas d'interdire le fil",
      "correct": false
    },
    {
      "text": "La concession vaut acceptation du slogan",
      "correct": false
    }
  ],
  "explanation": "Concession réelle, pas un abandon : l'on cherche encore qui a parlé d'abord"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "rumeur",
      "right": "bruit sans auteur, trop vite vrai"
    },
    {
      "left": "source",
      "right": "origine nommée d'une info"
    },
    {
      "left": "paradoxe",
      "right": "formule qui tient deux vérités contraires"
    },
    {
      "left": "torrent",
      "right": "flux trop fort pour une enquête"
    }
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
  "word": "paradoxe",
  "hint": "formule qui tient deux vérités contraires"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Marc Nkurunziza écoute encore, et il fautons nommer avant de crier.",
  "correct_sentence": "Marc Nkurunziza écoute encore, et il faut nommer avant de crier.",
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
      "image_path": "/elearning/mfk-c2-m3/dystopie-demain.svg",
      "word": "dystopie demain"
    },
    {
      "image_path": "/elearning/mfk-c2-m3/machine-voix.svg",
      "word": "machine voix"
    },
    {
      "image_path": "/elearning/mfk-c2-m3/extrait-noir.svg",
      "word": "extrait noir"
    },
    {
      "image_path": "/elearning/mfk-c2-m3/antenne-muette.svg",
      "word": "antenne muette"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Écrivez six phrases orales justes : deux sur paradoxe ; bruit sans source ; loin de / bel et bien, deux concessions, deux propositions."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez quatre modèles, puis votre prise de position (thèse, concession, proposition). Gardez le torrent du fil et l'article de Marc distincts."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PE — le texte de Marc Nkurunziza',
    'PE',
    $c$Objectif
Écrire un texte long et structuré. Comprendre le processus d'un bruit sans source et écrire un paradoxe. Point : paradoxe ; bruit sans source ; loin de / bel et bien.

Consigne
Imitez le texte de Marc Nkurunziza.

Support — Marc Nkurunziza — Partout n'est pas une source
Marc Nkurunziza — Partout n'est pas une source
On parle trop vite de un bruit trop vite vrai sous le figuier, comme si le mot dispensait d'en examiner le prix.
Encore que l'on prend le torrent pour une preuve, une rumeur qui n'a plus d'auteur n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Marc Nkurunziza concède que la répétition peut alerter, pour autant que l'on cherche encore qui a parlé d'abord.
Ce que l'on nomme rumeur, ici, n'est pas un slogan : bruit sans auteur, trop vite vrai.
Marc : loin de s'informer, la cour s'inondait, et bel et bien personne n'avait de source.
Karim refuse le partout.
Sami avait partagé trop vite ; il le dit aussi.
Patrick veut un article, pas une chasse.
La proposition qui reste debout est celle-ci : un article-paradoxe : plus l'on répète, moins l'on sait, sauf si l'on nomme
Mado glisse une ironie, puis une méthode.
Nous clôturons sans fusionner les voix : le torrent du fil d'un côté, l'article de Marc de l'autre, et le point où elles refusent de se ressembler.
Encore que l'on nomme, une rumeur qui n'a plus d'auteur n'est pas un détail.
Marc Nkurunziza concède que la répétition peut alerter, pour autant que l'on cherche encore qui a parlé d'abord.
Je n'écris pas pour vaincre : j'écris pour que la cour puisse relire.
loin de s'informer, on s'inonde ; bel et bien une source manquait
Marc Nkurunziza, Rukiri-Nord
$c$,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "La proposition retenue est : un article-paradoxe : plus l'on répète, moins l'on sait, sauf si l'on nomme",
  "correct": true,
  "explanation": "un article-paradoxe : plus l'on répète, moins l'on sait, sauf si l'on nomme"
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
      "text": "un article-paradoxe : plus l'on répète, moins l'on sait, sauf si l'on nomme",
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
  "explanation": "un article-paradoxe : plus l'on répète, moins l'on sait, sauf si l'on nomme"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "rumeur",
      "right": "bruit sans auteur, trop vite vrai"
    },
    {
      "left": "source",
      "right": "origine nommée d'une info"
    },
    {
      "left": "paradoxe",
      "right": "formule qui tient deux vérités contraires"
    },
    {
      "left": "torrent",
      "right": "flux trop fort pour une enquête"
    }
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
  "word": "torrent",
  "hint": "flux trop fort pour une enquête"
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
      "image_path": "/elearning/mfk-c2-m3/machine-voix.svg",
      "word": "machine voix"
    },
    {
      "image_path": "/elearning/mfk-c2-m3/extrait-noir.svg",
      "word": "extrait noir"
    },
    {
      "image_path": "/elearning/mfk-c2-m3/antenne-muette.svg",
      "word": "antenne muette"
    },
    {
      "image_path": "/elearning/mfk-c2-m3/accord-concession.svg",
      "word": "accord concession"
    }
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
    'EL — paradoxe ; bruit sans source ; loin de / bel et bien',
    'EL',
    $c$Objectif
Maîtriser paradoxe ; bruit sans source ; loin de / bel et bien au registre C2, avec collocations et pièges de construction.

Consigne
Apprenez la fiche, puis produisez des exemples justes au registre demandé.

Support — Fiche d'Aline Uwase, banc ocre
Fiche C2 — paradoxe ; bruit sans source ; loin de / bel et bien
On ne retient pas une liste : on retient des constructions et des collocations.
Encore que l'on nomme, une rumeur qui n'a plus d'auteur n'est pas un détail.
Marc Nkurunziza concède que la répétition peut alerter, pour autant que l'on cherche encore qui a parlé d'abord.
Autrement dit, loin de s'informer, on s'inonde ; bel et bien une source manquait
Il ressort qu'un article-paradoxe : plus l'on répète, moins l'on sait, sauf si l'on nomme
Piège : prendre l'antiphrase au premier degré
Registre : soutenu argumentatif, sans slogan
Collocation : encore que, pour autant que, il ressort que
Ce que l'on nomme rumeur, ici, n'est pas un slogan : bruit sans auteur, trop vite vrai.
Lila dément trop tard, ce qui est déjà une leçon.
Karim refuse le partout.
Nominaliser, ce n'est pas alourdir : c'est nommer le processus (la densification, l'accueil, le rappel).
Encore que / pour autant que / si tant est que : subjonctif, concession réelle, pas un ornement.
Reformuler une source : on change la syntaxe, on garde la charge, on signale le point de vue.
C1 : l'implicite se justifie. C2 : l'ironie se laisse entendre sans s'afficher.
Exemple fautif à ne plus produire : On va au paradoxe pour de vrai genre, et Lila Sow demande un registre plus net.
Correction : On va au paradoxe vraiment, et Lila Sow demande un registre plus net.
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
      "left": "rumeur",
      "right": "bruit sans auteur, trop vite vrai"
    },
    {
      "left": "source",
      "right": "origine nommée d'une info"
    },
    {
      "left": "paradoxe",
      "right": "formule qui tient deux vérités contraires"
    },
    {
      "left": "torrent",
      "right": "flux trop fort pour une enquête"
    }
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
  "sentence_with_error": "On va au paradoxe pour de vrai genre, et Lila Sow demande un registre plus net.",
  "correct_sentence": "On va au paradoxe vraiment, et Lila Sow demande un registre plus net.",
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
      "image_path": "/elearning/mfk-c2-m3/extrait-noir.svg",
      "word": "extrait noir"
    },
    {
      "image_path": "/elearning/mfk-c2-m3/antenne-muette.svg",
      "word": "antenne muette"
    },
    {
      "image_path": "/elearning/mfk-c2-m3/accord-concession.svg",
      "word": "accord concession"
    },
    {
      "image_path": "/elearning/mfk-c2-m3/desaccord-fin.svg",
      "word": "desaccord fin"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Tableau de langue : six exemples justes de « paradoxe ; bruit sans source ; loin de / bel et bien » et deux pièges commentés."
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

  -- ===== Demain trop net =====
  SELECT s.id INTO v_seq_id
  FROM elearning_sequences s
  WHERE s.module_id = v_module_id AND s.title = 'Demain trop net'
  LIMIT 1;

  IF v_seq_id IS NULL THEN
    INSERT INTO elearning_sequences (module_id, title, order_index)
    VALUES (v_module_id, 'Demain trop net', 3)
    RETURNING id INTO v_seq_id;
  ELSE
    UPDATE elearning_sequences
    SET order_index = 3
    WHERE id = v_seq_id;
  END IF;

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CO — Demain trop net',
    'CO',
    $c$Objectif
Comprendre un échange long et en extraire l'implicite. Envisager des dérives technologiques inventées et écrire un extrait dystopique. Viser l'ironie, le sous-entendu, le registre et la synthèse de points de vue.

Consigne
Lisez le débat (à écouter avec l'enseignant). Qu'est-ce qui est dit, qu'est-ce qui reste implicite, qui concède quoi ?

Support — Débat Radio Figuier — Demain trop net
Lila Sow : Radio Figuier. On parle trop vite de une Rukiri-Nord trop écoutée, comme si le mot dispensait d'en examiner le prix.
Marc Nkurunziza : Encore que l'on remplace les relais humains par une voix trop sûre, un demain où Joël n'aurait plus à porter, ni à décider n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Léa Niyonzima : Léa Niyonzima concède que un outil peut alléger, pour autant que l'on n'y lise pas la fin du relais.
Aline Uwase : Ce que l'on nomme dystopie, ici, n'est pas un slogan : ailleurs sombre pour juger l'ici.
Patrick Habimana : Léa : on dirait que midi n'aurait plus d'ombre, seulement un score.
Hawa Diallo : Joël demande qui dirait non.
Joël Mugisha : Aline : le conditionnel ici est une éthique.
Rose Iradukunda : Marc entend une antenne trop sûre.
Solange Mukamana : Mado rature miracle.
Karim Bamba : Lila n'adoucira pas l'extrait.
Félicie Ndayishimiye : Un chiffre, une trace : Léa a écrit trois pages ; coupé le mot miracle ; gardé le refus de Joël.
Dieudonné Hakizimana : L'enjeu n'est pas d'avoir raison plus fort : il s'agit d'imaginer pour juger l'ici, pas pour se faire peur en vain
Yvette : Nina voit une tour.
Mado : Joël Mugisha entend, dans « la machine nous aide », ceci qui n'est pas dit : la machine nous aide cache trop souvent qui n'a plus le droit de dire non
Sami : Autrement dit, on dirait que les lanternes marcheraient toutes seules, et l'on n'entendrait plus Joël
Lila Sow : Je reformule pour les auditeurs. La proposition qui reste debout est celle-ci : un extrait : demain trop net, une voix, un refus, une ombre
Nina Kayitesi : Patrick : déduire un point de vue, c'est lire qui parle trop bien de l'aide.
Lila Sow : Nous clôturons sans clore. Nous clôturons sans fusionner les voix : le podcast trop enthousiaste d'un côté, l'extrait de Léa de l'autre, et le point où elles refusent de se ressembler.
Mado, plus bas, sans hausser le ton : La machine nous aide : on notera le nous, d'une générosité qui n'a pas à porter.
$c$,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "un demain où Joël n'aurait plus à porter, ni à décider est présenté comme un simple détail sans conséquence.",
  "correct": false,
  "explanation": "Le texte affirme au contraire que un demain où Joël n'aurait plus à porter, ni à décider n'est pas un détail."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Selon Joël Mugisha, que reste-t-il implicite dans « la machine nous aide » ?",
  "options": [
    {
      "text": "Que Léa promet la machine",
      "correct": false
    },
    {
      "text": "Plus le droit de dire non",
      "correct": true
    },
    {
      "text": "Que Joël a disparu de l'extrait",
      "correct": false
    },
    {
      "text": "Que le podcast était déjà une dystopie assumée",
      "correct": false
    }
  ],
  "explanation": "la machine nous aide cache trop souvent qui n'a plus le droit de dire non"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "dystopie",
      "right": "ailleurs sombre pour juger l'ici"
    },
    {
      "left": "machine",
      "right": "voix trop sûre, inventée"
    },
    {
      "left": "refus",
      "right": "droit qui doit rester humain"
    },
    {
      "left": "extrait",
      "right": "morceau d'écriture d'anticipation"
    }
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
  "word": "dystopie",
  "hint": "ailleurs sombre pour juger l'ici"
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
      "image_path": "/elearning/mfk-c2-m3/antenne-muette.svg",
      "word": "antenne muette"
    },
    {
      "image_path": "/elearning/mfk-c2-m3/accord-concession.svg",
      "word": "accord concession"
    },
    {
      "image_path": "/elearning/mfk-c2-m3/desaccord-fin.svg",
      "word": "desaccord fin"
    },
    {
      "image_path": "/elearning/mfk-c2-m3/micro-fil.svg",
      "word": "micro fil"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Reformulez l'implicite de « la machine nous aide » et la concession de Léa Niyonzima."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez une synthèse d'environ quatre-vingt-dix secondes : deux points de vue, un implicite, une proposition. Gardez le podcast trop enthousiaste et l'extrait de Léa distincts."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CE — Les lanternes trop seules',
    'CE',
    $c$Objectif
Lire un texte argumenté long, synthétiser et reformuler. Envisager des dérives technologiques inventées et écrire un extrait dystopique. Viser l'ironie, le sous-entendu, le registre et la synthèse de points de vue.

Consigne
Lisez « Les lanternes trop seules », sans aller trop vite. Repérez la thèse, la concession, l'implicite et la proposition.

Support — Les lanternes trop seules
On parle trop vite de une Rukiri-Nord trop écoutée, comme si le mot dispensait d'en examiner le prix.
Encore que l'on remplace les relais humains par une voix trop sûre, un demain où Joël n'aurait plus à porter, ni à décider n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Léa Niyonzima concède que un outil peut alléger, pour autant que l'on n'y lise pas la fin du relais.
Ce que l'on nomme dystopie, ici, n'est pas un slogan : ailleurs sombre pour juger l'ici.
Léa : on dirait que midi n'aurait plus d'ombre, seulement un score.
Joël demande qui dirait non.
Aline : le conditionnel ici est une éthique.
Marc entend une antenne trop sûre.
Mado rature miracle.
Lila n'adoucira pas l'extrait.
Un chiffre, une trace : Léa a écrit trois pages ; coupé le mot miracle ; gardé le refus de Joël.
L'enjeu n'est pas d'avoir raison plus fort : il s'agit d'imaginer pour juger l'ici, pas pour se faire peur en vain
Nina voit une tour.
Joël Mugisha entend, dans « la machine nous aide », ceci qui n'est pas dit : la machine nous aide cache trop souvent qui n'a plus le droit de dire non
Autrement dit, on dirait que les lanternes marcheraient toutes seules, et l'on n'entendrait plus Joël
La proposition qui reste debout est celle-ci : un extrait : demain trop net, une voix, un refus, une ombre
Patrick : déduire un point de vue, c'est lire qui parle trop bien de l'aide.
Nous clôturons sans fusionner les voix : le podcast trop enthousiaste d'un côté, l'extrait de Léa de l'autre, et le point où elles refusent de se ressembler.
Signé : Léa Niyonzima, Rukiri-Nord — Cahier des racines, Rukiri-Nord.
$c$,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Le texte refuse de fusionner le podcast trop enthousiaste et l'extrait de Léa en une seule affiche.",
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
      "text": "Trois pages, zéro miracle, un refus gardé",
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
  "explanation": "Léa a écrit trois pages ; coupé le mot miracle ; gardé le refus de Joël."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "dystopie",
      "right": "ailleurs sombre pour juger l'ici"
    },
    {
      "left": "machine",
      "right": "voix trop sûre, inventée"
    },
    {
      "left": "refus",
      "right": "droit qui doit rester humain"
    },
    {
      "left": "extrait",
      "right": "morceau d'écriture d'anticipation"
    }
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
  "word": "machine",
  "hint": "voix trop sûre, inventée"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "La dystopie de trop vite n'aide personne, et Joël Mugisha reprend le fil.",
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
      "image_path": "/elearning/mfk-c2-m3/accord-concession.svg",
      "word": "accord concession"
    },
    {
      "image_path": "/elearning/mfk-c2-m3/desaccord-fin.svg",
      "word": "desaccord fin"
    },
    {
      "image_path": "/elearning/mfk-c2-m3/micro-fil.svg",
      "word": "micro fil"
    },
    {
      "image_path": "/elearning/mfk-c2-m3/cahier-alerte.svg",
      "word": "cahier alerte"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Synthétisez « Les lanternes trop seules » : thèse, concession, implicite, proposition (quinze lignes)."
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
    'PO — Demain trop net : dire sans slogan',
    'PO',
    $c$Objectif
Produire un oral structuré (thèse, concession, proposition). Point : dystopie ; dérives ; point de vue d'un intervenant.

Consigne
Répétez les modèles, puis prenez position en une minute : thèse, concession, reformulation, proposition.

Support — Modèles d'Aline Uwase, banc du figuier
Encore que l'on remplace les relais humains par une voix trop sûre, un demain où Joël n'aurait plus à porter, ni à décider n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Léa Niyonzima concède que un outil peut alléger, pour autant que l'on n'y lise pas la fin du relais.
Ce que l'on nomme dystopie, ici, n'est pas un slogan : ailleurs sombre pour juger l'ici.
Encore que l'on imagine, un demain où Joël n'aurait plus à porter, ni à décider n'est pas un détail.
Léa Niyonzima concède que un outil peut alléger, pour autant que l'on n'y lise pas la fin du relais.
Autrement dit, on dirait que les lanternes marcheraient toutes seules, et l'on n'entendrait plus Joël
Il ressort qu'un extrait : demain trop net, une voix, un refus, une ombre
Joël demande qui dirait non.
Mado rature miracle.
La proposition qui reste debout est celle-ci : un extrait : demain trop net, une voix, un refus, une ombre
Je concède le point, je n'abandonne pas la proposition.
Ce n'est pas que je refuse : c'est que je refuse qu'on nomme cela un détail.
Autrement dit, l'implicite fait autant de travail que la thèse.
En une minute : fait, angle, concession, proposition.
Nous clôturons sans fusionner les voix : le podcast trop enthousiaste d'un côté, l'extrait de Léa de l'autre, et le point où elles refusent de se ressembler.
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
  "explanation": "Léa Niyonzima concède que un outil peut alléger, pour autant que l'on n'y lise pas la fin du relais."
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
      "text": "un outil peut alléger — à condition que l'on n'y lise pas la fin du relais",
      "correct": true
    },
    {
      "text": "Léa Niyonzima abandonne il s'agit d'imaginer pour juger l'ici, pas pour se faire peur en vain",
      "correct": false
    },
    {
      "text": "La concession vaut acceptation du slogan",
      "correct": false
    }
  ],
  "explanation": "Concession réelle, pas un abandon : l'on n'y lise pas la fin du relais"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "dystopie",
      "right": "ailleurs sombre pour juger l'ici"
    },
    {
      "left": "machine",
      "right": "voix trop sûre, inventée"
    },
    {
      "left": "refus",
      "right": "droit qui doit rester humain"
    },
    {
      "left": "extrait",
      "right": "morceau d'écriture d'anticipation"
    }
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
  "word": "refus",
  "hint": "droit qui doit rester humain"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Léa Niyonzima écoute encore, et il fautons imaginer avant de crier.",
  "correct_sentence": "Léa Niyonzima écoute encore, et il faut imaginer avant de crier.",
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
      "image_path": "/elearning/mfk-c2-m3/desaccord-fin.svg",
      "word": "desaccord fin"
    },
    {
      "image_path": "/elearning/mfk-c2-m3/micro-fil.svg",
      "word": "micro fil"
    },
    {
      "image_path": "/elearning/mfk-c2-m3/cahier-alerte.svg",
      "word": "cahier alerte"
    },
    {
      "image_path": "/elearning/mfk-c2-m3/lampe-figue-fil.svg",
      "word": "lampe figue fil"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Écrivez six phrases orales justes : deux sur dystopie ; dérives ; point de vue d'un intervenant, deux concessions, deux propositions."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez quatre modèles, puis votre prise de position (thèse, concession, proposition). Gardez le podcast trop enthousiaste et l'extrait de Léa distincts."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PE — le texte de Léa Niyonzima',
    'PE',
    $c$Objectif
Écrire un texte long et structuré. Envisager des dérives technologiques inventées et écrire un extrait dystopique. Point : dystopie ; dérives ; point de vue d'un intervenant.

Consigne
Imitez le texte de Léa Niyonzima.

Support — Léa Niyonzima — Les lanternes trop seules
Léa Niyonzima — Les lanternes trop seules
On parle trop vite de une Rukiri-Nord trop écoutée, comme si le mot dispensait d'en examiner le prix.
Encore que l'on remplace les relais humains par une voix trop sûre, un demain où Joël n'aurait plus à porter, ni à décider n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Léa Niyonzima concède que un outil peut alléger, pour autant que l'on n'y lise pas la fin du relais.
Ce que l'on nomme dystopie, ici, n'est pas un slogan : ailleurs sombre pour juger l'ici.
Léa : on dirait que midi n'aurait plus d'ombre, seulement un score.
Mado rature miracle.
Lila n'adoucira pas l'extrait.
Nina voit une tour.
La proposition qui reste debout est celle-ci : un extrait : demain trop net, une voix, un refus, une ombre
Patrick : déduire un point de vue, c'est lire qui parle trop bien de l'aide.
Nous clôturons sans fusionner les voix : le podcast trop enthousiaste d'un côté, l'extrait de Léa de l'autre, et le point où elles refusent de se ressembler.
Encore que l'on imagine, un demain où Joël n'aurait plus à porter, ni à décider n'est pas un détail.
Léa Niyonzima concède que un outil peut alléger, pour autant que l'on n'y lise pas la fin du relais.
Je n'écris pas pour vaincre : j'écris pour que la cour puisse relire.
on dirait que les lanternes marcheraient toutes seules, et l'on n'entendrait plus Joël
Léa Niyonzima, Rukiri-Nord
$c$,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "La proposition retenue est : un extrait : demain trop net, une voix, un refus, une ombre",
  "correct": true,
  "explanation": "un extrait : demain trop net, une voix, un refus, une ombre"
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
      "text": "un extrait : demain trop net, une voix, un refus, une ombre",
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
  "explanation": "un extrait : demain trop net, une voix, un refus, une ombre"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "dystopie",
      "right": "ailleurs sombre pour juger l'ici"
    },
    {
      "left": "machine",
      "right": "voix trop sûre, inventée"
    },
    {
      "left": "refus",
      "right": "droit qui doit rester humain"
    },
    {
      "left": "extrait",
      "right": "morceau d'écriture d'anticipation"
    }
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
  "word": "extrait",
  "hint": "morceau d'écriture d'anticipation"
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
      "image_path": "/elearning/mfk-c2-m3/micro-fil.svg",
      "word": "micro fil"
    },
    {
      "image_path": "/elearning/mfk-c2-m3/cahier-alerte.svg",
      "word": "cahier alerte"
    },
    {
      "image_path": "/elearning/mfk-c2-m3/lampe-figue-fil.svg",
      "word": "lampe figue fil"
    },
    {
      "image_path": "/elearning/mfk-c2-m3/interrupteur-doux.svg",
      "word": "interrupteur doux"
    }
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
    'EL — dystopie ; dérives ; point de vue d''un intervenant',
    'EL',
    $c$Objectif
Maîtriser dystopie ; dérives ; point de vue d'un intervenant au registre C2, avec collocations et pièges de construction.

Consigne
Apprenez la fiche, puis produisez des exemples justes au registre demandé.

Support — Fiche d'Aline Uwase, banc ocre
Fiche C2 — dystopie ; dérives ; point de vue d'un intervenant
On ne retient pas une liste : on retient des constructions et des collocations.
Encore que l'on imagine, un demain où Joël n'aurait plus à porter, ni à décider n'est pas un détail.
Léa Niyonzima concède que un outil peut alléger, pour autant que l'on n'y lise pas la fin du relais.
Autrement dit, on dirait que les lanternes marcheraient toutes seules, et l'on n'entendrait plus Joël
Il ressort qu'un extrait : demain trop net, une voix, un refus, une ombre
Piège : indicatif plat là où le conditionnel peint
Registre : soutenu argumentatif, sans slogan
Collocation : encore que, pour autant que, il ressort que
Ce que l'on nomme dystopie, ici, n'est pas un slogan : ailleurs sombre pour juger l'ici.
Joël demande qui dirait non.
Mado rature miracle.
Nominaliser, ce n'est pas alourdir : c'est nommer le processus (la densification, l'accueil, le rappel).
Encore que / pour autant que / si tant est que : subjonctif, concession réelle, pas un ornement.
Reformuler une source : on change la syntaxe, on garde la charge, on signale le point de vue.
C1 : l'implicite se justifie. C2 : l'ironie se laisse entendre sans s'afficher.
Exemple fautif à ne plus produire : On va au refus pour de vrai genre, et Joël Mugisha demande un registre plus net.
Correction : On va au refus vraiment, et Joël Mugisha demande un registre plus net.
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
      "left": "dystopie",
      "right": "ailleurs sombre pour juger l'ici"
    },
    {
      "left": "machine",
      "right": "voix trop sûre, inventée"
    },
    {
      "left": "refus",
      "right": "droit qui doit rester humain"
    },
    {
      "left": "extrait",
      "right": "morceau d'écriture d'anticipation"
    }
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
  "answer": "dystopie"
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
  "sentence_with_error": "On va au refus pour de vrai genre, et Joël Mugisha demande un registre plus net.",
  "correct_sentence": "On va au refus vraiment, et Joël Mugisha demande un registre plus net.",
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
      "image_path": "/elearning/mfk-c2-m3/cahier-alerte.svg",
      "word": "cahier alerte"
    },
    {
      "image_path": "/elearning/mfk-c2-m3/lampe-figue-fil.svg",
      "word": "lampe figue fil"
    },
    {
      "image_path": "/elearning/mfk-c2-m3/interrupteur-doux.svg",
      "word": "interrupteur doux"
    },
    {
      "image_path": "/elearning/mfk-c2-m3/soleil-ecran.svg",
      "word": "soleil ecran"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Tableau de langue : six exemples justes de « dystopie ; dérives ; point de vue d'un intervenant » et deux pièges commentés."
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

  -- ===== Article-paradoxe =====
  SELECT s.id INTO v_seq_id
  FROM elearning_sequences s
  WHERE s.module_id = v_module_id AND s.title = 'Article-paradoxe'
  LIMIT 1;

  IF v_seq_id IS NULL THEN
    INSERT INTO elearning_sequences (module_id, title, order_index)
    VALUES (v_module_id, 'Article-paradoxe', 4)
    RETURNING id INTO v_seq_id;
  ELSE
    UPDATE elearning_sequences
    SET order_index = 4
    WHERE id = v_seq_id;
  END IF;

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CO — Article-paradoxe',
    'CO',
    $c$Objectif
Comprendre un échange long et en extraire l'implicite. Rédiger un article qui tienne un paradoxe sans se perdre en effets. Viser l'ironie, le sous-entendu, le registre et la synthèse de points de vue.

Consigne
Lisez le débat (à écouter avec l'enseignant). Qu'est-ce qui est dit, qu'est-ce qui reste implicite, qui concède quoi ?

Support — Débat Radio Figuier — Article-paradoxe
Lila Sow : Radio Figuier. On parle trop vite de plus l'on sait, moins l'on vérifie, comme si le mot dispensait d'en examiner le prix.
Marc Nkurunziza : Encore que l'on prend le volume pour la connaissance, une fierté d'être au courant qui n'a plus de source n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Léa Niyonzima : Marc Nkurunziza concède que l'accès aux voix s'est élargi, pour autant que l'on n'en conclue pas que l'on sait.
Aline Uwase : Ce que l'on nomme paradoxe, ici, n'est pas un slogan : tension tenue entre deux vérités.
Patrick Habimana : Marc : loin de savoir davantage, l'on vérifie moins, et c'est bel et bien un paradoxe de cour.
Hawa Diallo : Lila accepte d'être le geste : attendre.
Joël Mugisha : Aline refuse l'effet gratuit.
Rose Iradukunda : Léa fournit l'exemple.
Solange Mukamana : Sami avait partagé ; il relit.
Karim Bamba : Patrick veut un titre sans cri.
Félicie Ndayishimiye : Un chiffre, une trace : Marc a cité le torrent de la veille ; zéro source ; un geste : attendre Lila.
Dieudonné Hakizimana : L'enjeu n'est pas d'avoir raison plus fort : il s'agit d'écrire juste, pas d'épater par le paradoxe
Yvette : Mado glisse une ironie, puis la rature trop facile.
Mado : Lila Sow entend, dans « on est informés comme jamais », ceci qui n'est pas dit : informés comme jamais flatte pour ne plus avoir à vérifier
Sami : Autrement dit, plus le torrent grossit, plus la source se dérobe — sauf à la nommer
Lila Sow : Je reformule pour les auditeurs. La proposition qui reste debout est celle-ci : un article : paradoxe, exemple du Seuil, geste (nommer, ralentir)
Nina Kayitesi : Karim : un article C2 se juge à l'exemple, pas à la pirouette.
Lila Sow : Nous clôturons sans clore. Nous clôturons sans fusionner les voix : les bruits de la veille d'un côté, l'article de Marc de l'autre, et le point où elles refusent de se ressembler.
Mado, plus bas, sans hausser le ton : On est informés comme jamais : la formule a cet avantage qu'elle n'exige aucune source.
$c$,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "une fierté d'être au courant qui n'a plus de source est présenté comme un simple détail sans conséquence.",
  "correct": false,
  "explanation": "Le texte affirme au contraire que une fierté d'être au courant qui n'a plus de source n'est pas un détail."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Selon Lila Sow, que reste-t-il implicite dans « on est informés comme jamais » ?",
  "options": [
    {
      "text": "Que Marc se vante d'être au courant",
      "correct": false
    },
    {
      "text": "Ne plus avoir à vérifier",
      "correct": true
    },
    {
      "text": "Que Lila a refusé d'être attendue",
      "correct": false
    },
    {
      "text": "Que le paradoxe est un jeu gratuit",
      "correct": false
    }
  ],
  "explanation": "informés comme jamais flatte pour ne plus avoir à vérifier"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "paradoxe",
      "right": "tension tenue entre deux vérités"
    },
    {
      "left": "volume",
      "right": "quantité d'infos, pas une preuve"
    },
    {
      "left": "vérification",
      "right": "geste, trop souvent sauté"
    },
    {
      "left": "article",
      "right": "texte argumenté, avec exemple de cour"
    }
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
  "word": "paradoxe",
  "hint": "tension tenue entre deux vérités"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Si tant est que le bonheur s'industrialise, il se vend déjà, et Marc Nkurunziza sourit trop large.",
  "correct_sentence": "Si tant est que le bonheur s'industrialise, il se vendrait déjà, et Marc Nkurunziza sourit trop large.",
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
      "image_path": "/elearning/mfk-c2-m3/lampe-figue-fil.svg",
      "word": "lampe figue fil"
    },
    {
      "image_path": "/elearning/mfk-c2-m3/interrupteur-doux.svg",
      "word": "interrupteur doux"
    },
    {
      "image_path": "/elearning/mfk-c2-m3/soleil-ecran.svg",
      "word": "soleil ecran"
    },
    {
      "image_path": "/elearning/mfk-c2-m3/nuage-fausse.svg",
      "word": "nuage fausse"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Reformulez l'implicite de « on est informés comme jamais » et la concession de Marc Nkurunziza."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez une synthèse d'environ quatre-vingt-dix secondes : deux points de vue, un implicite, une proposition. Gardez les bruits de la veille et l'article de Marc distincts."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CE — Le volume n''est pas le savoir',
    'CE',
    $c$Objectif
Lire un texte argumenté long, synthétiser et reformuler. Rédiger un article qui tienne un paradoxe sans se perdre en effets. Viser l'ironie, le sous-entendu, le registre et la synthèse de points de vue.

Consigne
Lisez « Le volume n'est pas le savoir », sans aller trop vite. Repérez la thèse, la concession, l'implicite et la proposition.

Support — Le volume n'est pas le savoir
On parle trop vite de plus l'on sait, moins l'on vérifie, comme si le mot dispensait d'en examiner le prix.
Encore que l'on prend le volume pour la connaissance, une fierté d'être au courant qui n'a plus de source n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Marc Nkurunziza concède que l'accès aux voix s'est élargi, pour autant que l'on n'en conclue pas que l'on sait.
Ce que l'on nomme paradoxe, ici, n'est pas un slogan : tension tenue entre deux vérités.
Marc : loin de savoir davantage, l'on vérifie moins, et c'est bel et bien un paradoxe de cour.
Lila accepte d'être le geste : attendre.
Aline refuse l'effet gratuit.
Léa fournit l'exemple.
Sami avait partagé ; il relit.
Patrick veut un titre sans cri.
Un chiffre, une trace : Marc a cité le torrent de la veille ; zéro source ; un geste : attendre Lila.
L'enjeu n'est pas d'avoir raison plus fort : il s'agit d'écrire juste, pas d'épater par le paradoxe
Mado glisse une ironie, puis la rature trop facile.
Lila Sow entend, dans « on est informés comme jamais », ceci qui n'est pas dit : informés comme jamais flatte pour ne plus avoir à vérifier
Autrement dit, plus le torrent grossit, plus la source se dérobe — sauf à la nommer
La proposition qui reste debout est celle-ci : un article : paradoxe, exemple du Seuil, geste (nommer, ralentir)
Karim : un article C2 se juge à l'exemple, pas à la pirouette.
Nous clôturons sans fusionner les voix : les bruits de la veille d'un côté, l'article de Marc de l'autre, et le point où elles refusent de se ressembler.
Signé : Marc Nkurunziza, Rukiri-Nord — Cahier des racines, Rukiri-Nord.
$c$,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Le texte refuse de fusionner les bruits de la veille et l'article de Marc en une seule affiche.",
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
      "text": "Torrent de la veille, zéro source, attendre Lila",
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
  "explanation": "Marc a cité le torrent de la veille ; zéro source ; un geste : attendre Lila."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "paradoxe",
      "right": "tension tenue entre deux vérités"
    },
    {
      "left": "volume",
      "right": "quantité d'infos, pas une preuve"
    },
    {
      "left": "vérification",
      "right": "geste, trop souvent sauté"
    },
    {
      "left": "article",
      "right": "texte argumenté, avec exemple de cour"
    }
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
  "word": "volume",
  "hint": "quantité d'infos, pas une preuve"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "La paradoxe de trop vite n'aide personne, et Lila Sow reprend le fil.",
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
      "image_path": "/elearning/mfk-c2-m3/interrupteur-doux.svg",
      "word": "interrupteur doux"
    },
    {
      "image_path": "/elearning/mfk-c2-m3/soleil-ecran.svg",
      "word": "soleil ecran"
    },
    {
      "image_path": "/elearning/mfk-c2-m3/nuage-fausse.svg",
      "word": "nuage fausse"
    },
    {
      "image_path": "/elearning/mfk-c2-m3/radio-fil.svg",
      "word": "radio fil"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Synthétisez « Le volume n'est pas le savoir » : thèse, concession, implicite, proposition (quinze lignes)."
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
    'PO — Article-paradoxe : dire sans slogan',
    'PO',
    $c$Objectif
Produire un oral structuré (thèse, concession, proposition). Point : exprimer un paradoxe ; concession ; reformulation.

Consigne
Répétez les modèles, puis prenez position en une minute : thèse, concession, reformulation, proposition.

Support — Modèles d'Aline Uwase, banc du figuier
Encore que l'on prend le volume pour la connaissance, une fierté d'être au courant qui n'a plus de source n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Marc Nkurunziza concède que l'accès aux voix s'est élargi, pour autant que l'on n'en conclue pas que l'on sait.
Ce que l'on nomme paradoxe, ici, n'est pas un slogan : tension tenue entre deux vérités.
Encore que l'on vérifie, une fierté d'être au courant qui n'a plus de source n'est pas un détail.
Marc Nkurunziza concède que l'accès aux voix s'est élargi, pour autant que l'on n'en conclue pas que l'on sait.
Autrement dit, plus le torrent grossit, plus la source se dérobe — sauf à la nommer
Il ressort qu'un article : paradoxe, exemple du Seuil, geste (nommer, ralentir)
Lila accepte d'être le geste : attendre.
Sami avait partagé ; il relit.
La proposition qui reste debout est celle-ci : un article : paradoxe, exemple du Seuil, geste (nommer, ralentir)
Je concède le point, je n'abandonne pas la proposition.
Ce n'est pas que je refuse : c'est que je refuse qu'on nomme cela un détail.
Autrement dit, l'implicite fait autant de travail que la thèse.
En une minute : fait, angle, concession, proposition.
Nous clôturons sans fusionner les voix : les bruits de la veille d'un côté, l'article de Marc de l'autre, et le point où elles refusent de se ressembler.
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
  "explanation": "Marc Nkurunziza concède que l'accès aux voix s'est élargi, pour autant que l'on n'en conclue pas que l'on sait."
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
      "text": "l'accès aux voix s'est élargi — à condition que l'on n'en conclue pas que l'on sait",
      "correct": true
    },
    {
      "text": "Marc Nkurunziza abandonne il s'agit d'écrire juste, pas d'épater par le paradoxe",
      "correct": false
    },
    {
      "text": "La concession vaut acceptation du slogan",
      "correct": false
    }
  ],
  "explanation": "Concession réelle, pas un abandon : l'on n'en conclue pas que l'on sait"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "paradoxe",
      "right": "tension tenue entre deux vérités"
    },
    {
      "left": "volume",
      "right": "quantité d'infos, pas une preuve"
    },
    {
      "left": "vérification",
      "right": "geste, trop souvent sauté"
    },
    {
      "left": "article",
      "right": "texte argumenté, avec exemple de cour"
    }
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
  "word": "vérification",
  "hint": "geste, trop souvent sauté"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Marc Nkurunziza écoute encore, et il fautons vérifier avant de crier.",
  "correct_sentence": "Marc Nkurunziza écoute encore, et il faut vérifier avant de crier.",
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
      "image_path": "/elearning/mfk-c2-m3/soleil-ecran.svg",
      "word": "soleil ecran"
    },
    {
      "image_path": "/elearning/mfk-c2-m3/nuage-fausse.svg",
      "word": "nuage fausse"
    },
    {
      "image_path": "/elearning/mfk-c2-m3/radio-fil.svg",
      "word": "radio fil"
    },
    {
      "image_path": "/elearning/mfk-c2-m3/feuille-paradoxe.svg",
      "word": "feuille paradoxe"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Écrivez six phrases orales justes : deux sur exprimer un paradoxe ; concession ; reformulation, deux concessions, deux propositions."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez quatre modèles, puis votre prise de position (thèse, concession, proposition). Gardez les bruits de la veille et l'article de Marc distincts."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PE — le texte de Marc Nkurunziza',
    'PE',
    $c$Objectif
Écrire un texte long et structuré. Rédiger un article qui tienne un paradoxe sans se perdre en effets. Point : exprimer un paradoxe ; concession ; reformulation.

Consigne
Imitez le texte de Marc Nkurunziza.

Support — Marc Nkurunziza — Le volume n'est pas le savoir
Marc Nkurunziza — Le volume n'est pas le savoir
On parle trop vite de plus l'on sait, moins l'on vérifie, comme si le mot dispensait d'en examiner le prix.
Encore que l'on prend le volume pour la connaissance, une fierté d'être au courant qui n'a plus de source n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Marc Nkurunziza concède que l'accès aux voix s'est élargi, pour autant que l'on n'en conclue pas que l'on sait.
Ce que l'on nomme paradoxe, ici, n'est pas un slogan : tension tenue entre deux vérités.
Marc : loin de savoir davantage, l'on vérifie moins, et c'est bel et bien un paradoxe de cour.
Sami avait partagé ; il relit.
Patrick veut un titre sans cri.
Mado glisse une ironie, puis la rature trop facile.
La proposition qui reste debout est celle-ci : un article : paradoxe, exemple du Seuil, geste (nommer, ralentir)
Karim : un article C2 se juge à l'exemple, pas à la pirouette.
Nous clôturons sans fusionner les voix : les bruits de la veille d'un côté, l'article de Marc de l'autre, et le point où elles refusent de se ressembler.
Encore que l'on vérifie, une fierté d'être au courant qui n'a plus de source n'est pas un détail.
Marc Nkurunziza concède que l'accès aux voix s'est élargi, pour autant que l'on n'en conclue pas que l'on sait.
Je n'écris pas pour vaincre : j'écris pour que la cour puisse relire.
plus le torrent grossit, plus la source se dérobe — sauf à la nommer
Marc Nkurunziza, Rukiri-Nord
$c$,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "La proposition retenue est : un article : paradoxe, exemple du Seuil, geste (nommer, ralentir)",
  "correct": true,
  "explanation": "un article : paradoxe, exemple du Seuil, geste (nommer, ralentir)"
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
      "text": "un article : paradoxe, exemple du Seuil, geste (nommer, ralentir)",
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
  "explanation": "un article : paradoxe, exemple du Seuil, geste (nommer, ralentir)"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "paradoxe",
      "right": "tension tenue entre deux vérités"
    },
    {
      "left": "volume",
      "right": "quantité d'infos, pas une preuve"
    },
    {
      "left": "vérification",
      "right": "geste, trop souvent sauté"
    },
    {
      "left": "article",
      "right": "texte argumenté, avec exemple de cour"
    }
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
  "word": "article",
  "hint": "texte argumenté, avec exemple de cour"
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
      "image_path": "/elearning/mfk-c2-m3/nuage-fausse.svg",
      "word": "nuage fausse"
    },
    {
      "image_path": "/elearning/mfk-c2-m3/radio-fil.svg",
      "word": "radio fil"
    },
    {
      "image_path": "/elearning/mfk-c2-m3/feuille-paradoxe.svg",
      "word": "feuille paradoxe"
    },
    {
      "image_path": "/elearning/mfk-c2-m3/groupe-debat.svg",
      "word": "groupe debat"
    }
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
    'EL — exprimer un paradoxe ; concession ; reformulation',
    'EL',
    $c$Objectif
Maîtriser exprimer un paradoxe ; concession ; reformulation au registre C2, avec collocations et pièges de construction.

Consigne
Apprenez la fiche, puis produisez des exemples justes au registre demandé.

Support — Fiche d'Aline Uwase, banc ocre
Fiche C2 — exprimer un paradoxe ; concession ; reformulation
On ne retient pas une liste : on retient des constructions et des collocations.
Encore que l'on vérifie, une fierté d'être au courant qui n'a plus de source n'est pas un détail.
Marc Nkurunziza concède que l'accès aux voix s'est élargi, pour autant que l'on n'en conclue pas que l'on sait.
Autrement dit, plus le torrent grossit, plus la source se dérobe — sauf à la nommer
Il ressort qu'un article : paradoxe, exemple du Seuil, geste (nommer, ralentir)
Piège : prendre l'antiphrase au premier degré
Registre : soutenu argumentatif, sans slogan
Collocation : encore que, pour autant que, il ressort que
Ce que l'on nomme paradoxe, ici, n'est pas un slogan : tension tenue entre deux vérités.
Lila accepte d'être le geste : attendre.
Sami avait partagé ; il relit.
Nominaliser, ce n'est pas alourdir : c'est nommer le processus (la densification, l'accueil, le rappel).
Encore que / pour autant que / si tant est que : subjonctif, concession réelle, pas un ornement.
Reformuler une source : on change la syntaxe, on garde la charge, on signale le point de vue.
C1 : l'implicite se justifie. C2 : l'ironie se laisse entendre sans s'afficher.
Exemple fautif à ne plus produire : On va au vérification pour de vrai genre, et Lila Sow demande un registre plus net.
Correction : On va au vérification vraiment, et Lila Sow demande un registre plus net.
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
      "left": "paradoxe",
      "right": "tension tenue entre deux vérités"
    },
    {
      "left": "volume",
      "right": "quantité d'infos, pas une preuve"
    },
    {
      "left": "vérification",
      "right": "geste, trop souvent sauté"
    },
    {
      "left": "article",
      "right": "texte argumenté, avec exemple de cour"
    }
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
  "sentence_with_error": "On va au vérification pour de vrai genre, et Lila Sow demande un registre plus net.",
  "correct_sentence": "On va au vérification vraiment, et Lila Sow demande un registre plus net.",
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
      "image_path": "/elearning/mfk-c2-m3/radio-fil.svg",
      "word": "radio fil"
    },
    {
      "image_path": "/elearning/mfk-c2-m3/feuille-paradoxe.svg",
      "word": "feuille paradoxe"
    },
    {
      "image_path": "/elearning/mfk-c2-m3/groupe-debat.svg",
      "word": "groupe debat"
    },
    {
      "image_path": "/elearning/mfk-c2-m3/balance-preuve.svg",
      "word": "balance preuve"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Tableau de langue : six exemples justes de « exprimer un paradoxe ; concession ; reformulation » et deux pièges commentés."
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

  -- ===== Extrait dystopique =====
  SELECT s.id INTO v_seq_id
  FROM elearning_sequences s
  WHERE s.module_id = v_module_id AND s.title = 'Extrait dystopique'
  LIMIT 1;

  IF v_seq_id IS NULL THEN
    INSERT INTO elearning_sequences (module_id, title, order_index)
    VALUES (v_module_id, 'Extrait dystopique', 5)
    RETURNING id INTO v_seq_id;
  ELSE
    UPDATE elearning_sequences
    SET order_index = 5
    WHERE id = v_seq_id;
  END IF;

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CO — Extrait dystopique',
    'CO',
    $c$Objectif
Comprendre un échange long et en extraire l'implicite. Écrire un extrait de dystopie ancré à Rukiri-Nord, original, sans catalogue de gadgets. Viser l'ironie, le sous-entendu, le registre et la synthèse de points de vue.

Consigne
Lisez le débat (à écouter avec l'enseignant). Qu'est-ce qui est dit, qu'est-ce qui reste implicite, qui concède quoi ?

Support — Débat Radio Figuier — Extrait dystopique
Lila Sow : Radio Figuier. On parle trop vite de la cour trop écoutée de demain, comme si le mot dispensait d'en examiner le prix.
Marc Nkurunziza : Encore que l'on efface les relais, les ratures, les non, une simplicité où l'on n'aurait plus à se parler n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Léa Niyonzima : Léa Niyonzima concède que simplifier une corvée peut être juste, pour autant que l'on n'y perde la possibilité du refus.
Aline Uwase : Ce que l'on nomme anticipation, ici, n'est pas un slogan : écriture du demain pour juger l'aujourd'hui.
Patrick Habimana : Léa : on dirait que les lanternes avanceraient sans Joël, et que cela s'appellerait simple.
Hawa Diallo : Mado exige le non.
Joël Mugisha : Aline : pas de catalogue.
Rose Iradukunda : Marc entend trop de tout sera.
Solange Mukamana : Lila n'adoucit pas.
Karim Bamba : Nina voit midi trop blanc.
Félicie Ndayishimiye : Un chiffre, une trace : Léa a gardé le non de Joël ; coupé trois gadgets ; laissé l'ombre.
Dieudonné Hakizimana : L'enjeu n'est pas d'avoir raison plus fort : il s'agit d'une écriture, pas d'un inventaire d'objets
Yvette : Sami veut un objet ; on le refuse.
Mado : Mado entend, dans « tout sera plus simple », ceci qui n'est pas dit : plus simple veut souvent dire plus seul, plus écouté, moins consulté
Sami : Autrement dit, midi n'aurait plus d'ombre ; Joël n'aurait plus de relais ; Lila n'aurait plus de rature
Lila Sow : Je reformule pour les auditeurs. La proposition qui reste debout est celle-ci : un extrait de quarante lignes : un midi, une voix trop sûre, un non
Nina Kayitesi : Patrick : un extrait se juge à l'ombre qu'il a gardée.
Lila Sow : Nous clôturons sans clore. Nous clôturons sans fusionner les voix : les ratures de Léa d'un côté, la lecture de Mado de l'autre, et le point où elles refusent de se ressembler.
Mado, plus bas, sans hausser le ton : Tout sera plus simple : promesse d'une voix qui n'a pas à demander la permission de couper l'ombre.
$c$,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "une simplicité où l'on n'aurait plus à se parler est présenté comme un simple détail sans conséquence.",
  "correct": false,
  "explanation": "Le texte affirme au contraire que une simplicité où l'on n'aurait plus à se parler n'est pas un détail."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Selon Mado, que reste-t-il implicite dans « tout sera plus simple » ?",
  "options": [
    {
      "text": "Que Léa a fait un catalogue d'objets",
      "correct": false
    },
    {
      "text": "Plus seul, plus écouté, moins consulté",
      "correct": true
    },
    {
      "text": "Que Joël n'a pas de non dans l'extrait",
      "correct": false
    },
    {
      "text": "Que Mado a exigé plus simple comme consigne",
      "correct": false
    }
  ],
  "explanation": "plus simple veut souvent dire plus seul, plus écouté, moins consulté"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "anticipation",
      "right": "écriture du demain pour juger l'aujourd'hui"
    },
    {
      "left": "gadget",
      "right": "objet trop nommé, à éviter ici"
    },
    {
      "left": "ombre",
      "right": "abri, trop simple à effacer"
    },
    {
      "left": "non",
      "right": "refus humain, à garder dans l'extrait"
    }
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
  "word": "anticipation",
  "hint": "écriture du demain pour juger l'aujourd'hui"
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
      "image_path": "/elearning/mfk-c2-m3/feuille-paradoxe.svg",
      "word": "feuille paradoxe"
    },
    {
      "image_path": "/elearning/mfk-c2-m3/groupe-debat.svg",
      "word": "groupe debat"
    },
    {
      "image_path": "/elearning/mfk-c2-m3/balance-preuve.svg",
      "word": "balance preuve"
    },
    {
      "image_path": "/elearning/mfk-c2-m3/porte-silence.svg",
      "word": "porte silence"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Reformulez l'implicite de « tout sera plus simple » et la concession de Léa Niyonzima."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez une synthèse d'environ quatre-vingt-dix secondes : deux points de vue, un implicite, une proposition. Gardez les ratures de Léa et la lecture de Mado distincts."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CE — Garder le non',
    'CE',
    $c$Objectif
Lire un texte argumenté long, synthétiser et reformuler. Écrire un extrait de dystopie ancré à Rukiri-Nord, original, sans catalogue de gadgets. Viser l'ironie, le sous-entendu, le registre et la synthèse de points de vue.

Consigne
Lisez « Garder le non », sans aller trop vite. Repérez la thèse, la concession, l'implicite et la proposition.

Support — Garder le non
On parle trop vite de la cour trop écoutée de demain, comme si le mot dispensait d'en examiner le prix.
Encore que l'on efface les relais, les ratures, les non, une simplicité où l'on n'aurait plus à se parler n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Léa Niyonzima concède que simplifier une corvée peut être juste, pour autant que l'on n'y perde la possibilité du refus.
Ce que l'on nomme anticipation, ici, n'est pas un slogan : écriture du demain pour juger l'aujourd'hui.
Léa : on dirait que les lanternes avanceraient sans Joël, et que cela s'appellerait simple.
Mado exige le non.
Aline : pas de catalogue.
Marc entend trop de tout sera.
Lila n'adoucit pas.
Nina voit midi trop blanc.
Un chiffre, une trace : Léa a gardé le non de Joël ; coupé trois gadgets ; laissé l'ombre.
L'enjeu n'est pas d'avoir raison plus fort : il s'agit d'une écriture, pas d'un inventaire d'objets
Sami veut un objet ; on le refuse.
Mado entend, dans « tout sera plus simple », ceci qui n'est pas dit : plus simple veut souvent dire plus seul, plus écouté, moins consulté
Autrement dit, midi n'aurait plus d'ombre ; Joël n'aurait plus de relais ; Lila n'aurait plus de rature
La proposition qui reste debout est celle-ci : un extrait de quarante lignes : un midi, une voix trop sûre, un non
Patrick : un extrait se juge à l'ombre qu'il a gardée.
Nous clôturons sans fusionner les voix : les ratures de Léa d'un côté, la lecture de Mado de l'autre, et le point où elles refusent de se ressembler.
Signé : Léa Niyonzima, Rukiri-Nord — Cahier des racines, Rukiri-Nord.
$c$,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Le texte refuse de fusionner les ratures de Léa et la lecture de Mado en une seule affiche.",
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
      "text": "Un non, zéro gadget, une ombre",
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
  "explanation": "Léa a gardé le non de Joël ; coupé trois gadgets ; laissé l'ombre."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "anticipation",
      "right": "écriture du demain pour juger l'aujourd'hui"
    },
    {
      "left": "gadget",
      "right": "objet trop nommé, à éviter ici"
    },
    {
      "left": "ombre",
      "right": "abri, trop simple à effacer"
    },
    {
      "left": "non",
      "right": "refus humain, à garder dans l'extrait"
    }
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
  "word": "gadget",
  "hint": "objet trop nommé, à éviter ici"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "La anticipation de trop vite n'aide personne, et Mado reprend le fil.",
  "correct_sentence": "La précipitation n'aide personne, et Mado reprend le fil.",
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
      "image_path": "/elearning/mfk-c2-m3/groupe-debat.svg",
      "word": "groupe debat"
    },
    {
      "image_path": "/elearning/mfk-c2-m3/balance-preuve.svg",
      "word": "balance preuve"
    },
    {
      "image_path": "/elearning/mfk-c2-m3/porte-silence.svg",
      "word": "porte silence"
    },
    {
      "image_path": "/elearning/mfk-c2-m3/coeur-vigilance.svg",
      "word": "coeur vigilance"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Synthétisez « Garder le non » : thèse, concession, implicite, proposition (quinze lignes)."
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
    'PO — Extrait dystopique : dire sans slogan',
    'PO',
    $c$Objectif
Produire un oral structuré (thèse, concession, proposition). Point : écriture d'anticipation ; voix ; ombre.

Consigne
Répétez les modèles, puis prenez position en une minute : thèse, concession, reformulation, proposition.

Support — Modèles d'Aline Uwase, banc du figuier
Encore que l'on efface les relais, les ratures, les non, une simplicité où l'on n'aurait plus à se parler n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Léa Niyonzima concède que simplifier une corvée peut être juste, pour autant que l'on n'y perde la possibilité du refus.
Ce que l'on nomme anticipation, ici, n'est pas un slogan : écriture du demain pour juger l'aujourd'hui.
Encore que l'on écrive, une simplicité où l'on n'aurait plus à se parler n'est pas un détail.
Léa Niyonzima concède que simplifier une corvée peut être juste, pour autant que l'on n'y perde la possibilité du refus.
Autrement dit, midi n'aurait plus d'ombre ; Joël n'aurait plus de relais ; Lila n'aurait plus de rature
Il ressort qu'un extrait de quarante lignes : un midi, une voix trop sûre, un non
Mado exige le non.
Lila n'adoucit pas.
La proposition qui reste debout est celle-ci : un extrait de quarante lignes : un midi, une voix trop sûre, un non
Je concède le point, je n'abandonne pas la proposition.
Ce n'est pas que je refuse : c'est que je refuse qu'on nomme cela un détail.
Autrement dit, l'implicite fait autant de travail que la thèse.
En une minute : fait, angle, concession, proposition.
Nous clôturons sans fusionner les voix : les ratures de Léa d'un côté, la lecture de Mado de l'autre, et le point où elles refusent de se ressembler.
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
  "explanation": "Léa Niyonzima concède que simplifier une corvée peut être juste, pour autant que l'on n'y perde la possibilité du refus."
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
      "text": "simplifier une corvée peut être juste — à condition que l'on n'y perde la possibilité du refus",
      "correct": true
    },
    {
      "text": "Léa Niyonzima abandonne il s'agit d'une écriture, pas d'un inventaire d'objets",
      "correct": false
    },
    {
      "text": "La concession vaut acceptation du slogan",
      "correct": false
    }
  ],
  "explanation": "Concession réelle, pas un abandon : l'on n'y perde la possibilité du refus"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "anticipation",
      "right": "écriture du demain pour juger l'aujourd'hui"
    },
    {
      "left": "gadget",
      "right": "objet trop nommé, à éviter ici"
    },
    {
      "left": "ombre",
      "right": "abri, trop simple à effacer"
    },
    {
      "left": "non",
      "right": "refus humain, à garder dans l'extrait"
    }
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
  "word": "ombre",
  "hint": "abri, trop simple à effacer"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Léa Niyonzima écoute encore, et il fautons écrire avant de crier.",
  "correct_sentence": "Léa Niyonzima écoute encore, et il faut écrire avant de crier.",
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
      "image_path": "/elearning/mfk-c2-m3/balance-preuve.svg",
      "word": "balance preuve"
    },
    {
      "image_path": "/elearning/mfk-c2-m3/porte-silence.svg",
      "word": "porte silence"
    },
    {
      "image_path": "/elearning/mfk-c2-m3/coeur-vigilance.svg",
      "word": "coeur vigilance"
    },
    {
      "image_path": "/elearning/mfk-c2-m3/librairie-immense.svg",
      "word": "librairie immense"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Écrivez six phrases orales justes : deux sur écriture d'anticipation ; voix ; ombre, deux concessions, deux propositions."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez quatre modèles, puis votre prise de position (thèse, concession, proposition). Gardez les ratures de Léa et la lecture de Mado distincts."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PE — le texte de Léa Niyonzima',
    'PE',
    $c$Objectif
Écrire un texte long et structuré. Écrire un extrait de dystopie ancré à Rukiri-Nord, original, sans catalogue de gadgets. Point : écriture d'anticipation ; voix ; ombre.

Consigne
Imitez le texte de Léa Niyonzima.

Support — Léa Niyonzima — Garder le non
Léa Niyonzima — Garder le non
On parle trop vite de la cour trop écoutée de demain, comme si le mot dispensait d'en examiner le prix.
Encore que l'on efface les relais, les ratures, les non, une simplicité où l'on n'aurait plus à se parler n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Léa Niyonzima concède que simplifier une corvée peut être juste, pour autant que l'on n'y perde la possibilité du refus.
Ce que l'on nomme anticipation, ici, n'est pas un slogan : écriture du demain pour juger l'aujourd'hui.
Léa : on dirait que les lanternes avanceraient sans Joël, et que cela s'appellerait simple.
Lila n'adoucit pas.
Nina voit midi trop blanc.
Sami veut un objet ; on le refuse.
La proposition qui reste debout est celle-ci : un extrait de quarante lignes : un midi, une voix trop sûre, un non
Patrick : un extrait se juge à l'ombre qu'il a gardée.
Nous clôturons sans fusionner les voix : les ratures de Léa d'un côté, la lecture de Mado de l'autre, et le point où elles refusent de se ressembler.
Encore que l'on écrive, une simplicité où l'on n'aurait plus à se parler n'est pas un détail.
Léa Niyonzima concède que simplifier une corvée peut être juste, pour autant que l'on n'y perde la possibilité du refus.
Je n'écris pas pour vaincre : j'écris pour que la cour puisse relire.
midi n'aurait plus d'ombre ; Joël n'aurait plus de relais ; Lila n'aurait plus de rature
Léa Niyonzima, Rukiri-Nord
$c$,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "La proposition retenue est : un extrait de quarante lignes : un midi, une voix trop sûre, un non",
  "correct": true,
  "explanation": "un extrait de quarante lignes : un midi, une voix trop sûre, un non"
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
      "text": "un extrait de quarante lignes : un midi, une voix trop sûre, un non",
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
  "explanation": "un extrait de quarante lignes : un midi, une voix trop sûre, un non"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "anticipation",
      "right": "écriture du demain pour juger l'aujourd'hui"
    },
    {
      "left": "gadget",
      "right": "objet trop nommé, à éviter ici"
    },
    {
      "left": "ombre",
      "right": "abri, trop simple à effacer"
    },
    {
      "left": "non",
      "right": "refus humain, à garder dans l'extrait"
    }
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
  "word": "non",
  "hint": "refus humain, à garder dans l'extrait"
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
      "image_path": "/elearning/mfk-c2-m3/porte-silence.svg",
      "word": "porte silence"
    },
    {
      "image_path": "/elearning/mfk-c2-m3/coeur-vigilance.svg",
      "word": "coeur vigilance"
    },
    {
      "image_path": "/elearning/mfk-c2-m3/librairie-immense.svg",
      "word": "librairie immense"
    },
    {
      "image_path": "/elearning/mfk-c2-m3/fil-litteraire.svg",
      "word": "fil litteraire"
    }
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
    'EL — écriture d''anticipation ; voix ; ombre',
    'EL',
    $c$Objectif
Maîtriser écriture d'anticipation ; voix ; ombre au registre C2, avec collocations et pièges de construction.

Consigne
Apprenez la fiche, puis produisez des exemples justes au registre demandé.

Support — Fiche d'Aline Uwase, banc ocre
Fiche C2 — écriture d'anticipation ; voix ; ombre
On ne retient pas une liste : on retient des constructions et des collocations.
Encore que l'on écrive, une simplicité où l'on n'aurait plus à se parler n'est pas un détail.
Léa Niyonzima concède que simplifier une corvée peut être juste, pour autant que l'on n'y perde la possibilité du refus.
Autrement dit, midi n'aurait plus d'ombre ; Joël n'aurait plus de relais ; Lila n'aurait plus de rature
Il ressort qu'un extrait de quarante lignes : un midi, une voix trop sûre, un non
Piège : indicatif plat là où le conditionnel peint
Registre : soutenu argumentatif, sans slogan
Collocation : encore que, pour autant que, il ressort que
Ce que l'on nomme anticipation, ici, n'est pas un slogan : écriture du demain pour juger l'aujourd'hui.
Mado exige le non.
Lila n'adoucit pas.
Nominaliser, ce n'est pas alourdir : c'est nommer le processus (la densification, l'accueil, le rappel).
Encore que / pour autant que / si tant est que : subjonctif, concession réelle, pas un ornement.
Reformuler une source : on change la syntaxe, on garde la charge, on signale le point de vue.
C1 : l'implicite se justifie. C2 : l'ironie se laisse entendre sans s'afficher.
Exemple fautif à ne plus produire : On va au ombre pour de vrai genre, et Mado demande un registre plus net.
Correction : On va au ombre vraiment, et Mado demande un registre plus net.
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
      "left": "anticipation",
      "right": "écriture du demain pour juger l'aujourd'hui"
    },
    {
      "left": "gadget",
      "right": "objet trop nommé, à éviter ici"
    },
    {
      "left": "ombre",
      "right": "abri, trop simple à effacer"
    },
    {
      "left": "non",
      "right": "refus humain, à garder dans l'extrait"
    }
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
  "answer": "anticipation"
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
  "sentence_with_error": "On va au ombre pour de vrai genre, et Mado demande un registre plus net.",
  "correct_sentence": "On va au ombre vraiment, et Mado demande un registre plus net.",
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
      "image_path": "/elearning/mfk-c2-m3/coeur-vigilance.svg",
      "word": "coeur vigilance"
    },
    {
      "image_path": "/elearning/mfk-c2-m3/librairie-immense.svg",
      "word": "librairie immense"
    },
    {
      "image_path": "/elearning/mfk-c2-m3/fil-litteraire.svg",
      "word": "fil litteraire"
    },
    {
      "image_path": "/elearning/mfk-c2-m3/debat-reseau.svg",
      "word": "debat reseau"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Tableau de langue : six exemples justes de « écriture d'anticipation ; voix ; ombre » et deux pièges commentés."
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
