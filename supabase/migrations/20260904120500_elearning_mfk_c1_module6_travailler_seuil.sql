/*
  Seed eLearning MFK — C1 — Travailler au Seuil

  Micro-monde : cour « Le Seuil des Sources », Rukiri-Nord.
  6 séquences × 5 leçons × 10 exercices (tous les types).
  Illustrations originales : /elearning/mfk-c1-m6/
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
  v_module_title text := 'C1 — Travailler au Seuil';
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
      'Grande étape C1-6 : faire la revue de presse de l''atelier et de la radio, témoigner d''un entretien, rapporter une crise sans la romancer, recueillir des voix parties trop loin, intégrer les témoignages dans une analyse du travail au Seuil — Joël Mugisha refuse l''accroche menteuse, Rose Iradukunda parle des mains, Karim Bamba des heures, Lila Sow coupe les insultes et garde les doutes.',
      'C1',
      false
    )
    RETURNING id INTO v_module_id;
  ELSE
    UPDATE elearning_modules
    SET
      description = 'Grande étape C1-6 : faire la revue de presse de l''atelier et de la radio, témoigner d''un entretien, rapporter une crise sans la romancer, recueillir des voix parties trop loin, intégrer les témoignages dans une analyse du travail au Seuil — Joël Mugisha refuse l''accroche menteuse, Rose Iradukunda parle des mains, Karim Bamba des heures, Lila Sow coupe les insultes et garde les doutes.',
      cefr_level = 'C1',
      published = false,
      updated_at = now()
    WHERE id = v_module_id;
  END IF;

  -- ===== Pas de tout le monde dit =====
  SELECT s.id INTO v_seq_id
  FROM elearning_sequences s
  WHERE s.module_id = v_module_id AND s.title = 'Pas de tout le monde dit'
  LIMIT 1;

  IF v_seq_id IS NULL THEN
    INSERT INTO elearning_sequences (module_id, title, order_index)
    VALUES (v_module_id, 'Pas de tout le monde dit', 0)
    RETURNING id INTO v_seq_id;
  ELSE
    UPDATE elearning_sequences
    SET order_index = 0
    WHERE id = v_seq_id;
  END IF;

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CO — Pas de tout le monde dit',
    'CO',
    $c$Objectif
Comprendre un échange long et en extraire l'implicite. Réaliser une revue de presse de l'atelier et de la radio, sans fusionner les sources. Viser la nuance, la collocation et l'implicite.

Consigne
Lisez le débat (à écouter avec l'enseignant). Qu'est-ce qui est dit, qu'est-ce qui reste implicite, qui concède quoi ?

Support — Débat Radio Figuier — Pas de tout le monde dit
Lila Sow : Radio Figuier. On parle trop vite de la revue de presse du Seuil, comme si le mot dispensait d'en examiner le prix.
Marc Nkurunziza : Encore que l'on efface les signatures, une revue trop lisse pour être honnête n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Léa Niyonzima : Lila Sow concède que raccourcir aide l'oreille, pour autant que l'on garde selon et d'après.
Aline Uwase : Ce que l'on nomme revue, ici, n'est pas un slogan : tour de sources attribuées.
Patrick Habimana : Selon le Cahier, l'atelier manque de relais ; d'après l'antenne, la radio manque d'heures.
Hawa Diallo : Il ressort que les deux manques se parlent.
Joël Mugisha : Rose a dit que les mains n'apparaissent pas dans les unes.
Rose Iradukunda : Karim a chiffré les heures.
Solange Mukamana : Aline : tout le monde dit est interdit en revue.
Karim Bamba : Joël écoute sa propre absence et la nomme.
Félicie Ndayishimiye : Un chiffre, une trace : Lila a cité Marc, Rose, Karim ; coupé un anonymat trop commode ; gardé un désaccord.
Dieudonné Hakizimana : L'enjeu n'est pas d'avoir raison plus fort : il s'agit que le travail de la cour ait des voix, pas une rumeur
Yvette : Patrick veut la friction, pas la paix fausse.
Mado : Marc Nkurunziza entend, dans « tout le monde dit », ceci qui n'est pas dit : tout le monde dit est déjà une prise de pouvoir sur les sources
Sami : Autrement dit, la revue attribue : Cahier des racines, Radio Figuier, affiche de l'atelier
Lila Sow : Je reformule pour les auditeurs. La proposition qui reste debout est celle-ci : trois extraits, trois attributions, un point de friction nommé
Nina Kayitesi : Marc : une revue de presse est un art d'attribution.
Lila Sow : Nous clôturons sans clore. Nous clôturons sans fusionner les voix : le Cahier des racines du mardi d'un côté, l'antenne de Radio Figuier du mercredi de l'autre, et le point où elles refusent de se ressembler.
$c$,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "une revue trop lisse pour être honnête est présenté comme un simple détail sans conséquence.",
  "correct": false,
  "explanation": "Le texte affirme au contraire que une revue trop lisse pour être honnête n'est pas un détail."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Selon Marc Nkurunziza, que reste-t-il implicite dans « tout le monde dit » ?",
  "options": [
    {
      "text": "Que Lila a fusionné Marc et Rose",
      "correct": false
    },
    {
      "text": "Une prise de pouvoir sur les sources",
      "correct": true
    },
    {
      "text": "Que Marc a interdit l'antenne",
      "correct": false
    },
    {
      "text": "Que l'atelier n'a pas d'affiche",
      "correct": false
    }
  ],
  "explanation": "tout le monde dit est déjà une prise de pouvoir sur les sources"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "revue",
      "right": "tour de sources attribuées"
    },
    {
      "left": "source",
      "right": "texte ou micro nommé"
    },
    {
      "left": "attribution",
      "right": "selon / d'après"
    },
    {
      "left": "friction",
      "right": "désaccord conservé, pas gommée"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nSelon Lila, il ___ que deux documents s'opposent. (ressortir)",
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
    "Selon",
    "Lila",
    "il",
    "ressort",
    "que",
    "deux",
    "documents",
    "s'opposent",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "revue",
  "hint": "tour de sources attribuées"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Selon Lila Sow, il ressort que les deux textes est d'accord, et Lila coupe le micro.",
  "correct_sentence": "Selon Lila Sow, il ressort que les deux textes sont d'accord, et Lila coupe le micro.",
  "explanation": "Accord : les deux textes sont."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-c1-m6/revue-presse.svg",
      "word": "revue presse"
    },
    {
      "image_path": "/elearning/mfk-c1-m6/organisation-atelier.svg",
      "word": "organisation atelier"
    },
    {
      "image_path": "/elearning/mfk-c1-m6/bienveillance-poste.svg",
      "word": "bienveillance poste"
    },
    {
      "image_path": "/elearning/mfk-c1-m6/horloge-poste.svg",
      "word": "horloge poste"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Reformulez l'implicite de « tout le monde dit » et la concession de Lila Sow."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez une synthèse d'environ quatre-vingt-dix secondes : deux points de vue, un implicite, une proposition. Gardez le Cahier des racines du mardi et l'antenne de Radio Figuier du mercredi distincts."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CE — Pas de tout le monde dit',
    'CE',
    $c$Objectif
Lire un texte argumenté long, synthétiser et reformuler. Réaliser une revue de presse de l'atelier et de la radio, sans fusionner les sources. Viser la nuance, la collocation et l'implicite.

Consigne
Lisez « Pas de tout le monde dit », sans aller trop vite. Repérez la thèse, la concession, l'implicite et la proposition.

Support — Pas de tout le monde dit
On parle trop vite de la revue de presse du Seuil, comme si le mot dispensait d'en examiner le prix.
Encore que l'on efface les signatures, une revue trop lisse pour être honnête n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Lila Sow concède que raccourcir aide l'oreille, pour autant que l'on garde selon et d'après.
Ce que l'on nomme revue, ici, n'est pas un slogan : tour de sources attribuées.
Selon le Cahier, l'atelier manque de relais ; d'après l'antenne, la radio manque d'heures.
Il ressort que les deux manques se parlent.
Rose a dit que les mains n'apparaissent pas dans les unes.
Karim a chiffré les heures.
Aline : tout le monde dit est interdit en revue.
Joël écoute sa propre absence et la nomme.
Un chiffre, une trace : Lila a cité Marc, Rose, Karim ; coupé un anonymat trop commode ; gardé un désaccord.
L'enjeu n'est pas d'avoir raison plus fort : il s'agit que le travail de la cour ait des voix, pas une rumeur
Patrick veut la friction, pas la paix fausse.
Marc Nkurunziza entend, dans « tout le monde dit », ceci qui n'est pas dit : tout le monde dit est déjà une prise de pouvoir sur les sources
Autrement dit, la revue attribue : Cahier des racines, Radio Figuier, affiche de l'atelier
La proposition qui reste debout est celle-ci : trois extraits, trois attributions, un point de friction nommé
Marc : une revue de presse est un art d'attribution.
Nous clôturons sans fusionner les voix : le Cahier des racines du mardi d'un côté, l'antenne de Radio Figuier du mercredi de l'autre, et le point où elles refusent de se ressembler.
Signé : Lila Sow, Rukiri-Nord — Cahier des racines, Rukiri-Nord.
$c$,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Le texte refuse de fusionner le Cahier des racines du mardi et l'antenne de Radio Figuier du mercredi en une seule affiche.",
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
      "text": "Trois noms, un anonymat refusé, un désaccord gardé",
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
  "explanation": "Lila a cité Marc, Rose, Karim ; coupé un anonymat trop commode ; gardé un désaccord."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "revue",
      "right": "tour de sources attribuées"
    },
    {
      "left": "source",
      "right": "texte ou micro nommé"
    },
    {
      "left": "attribution",
      "right": "selon / d'après"
    },
    {
      "left": "friction",
      "right": "désaccord conservé, pas gommée"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nD'après le second texte, on ___ une rampe avant les lanternes. (exiger, cond. atténué)",
  "answer": "exigerait"
}$j$::jsonb,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Remettez les mots dans l''ordre',
    'word_order',
    $j${
  "words": [
    "D'après",
    "le",
    "second",
    "texte",
    "on",
    "exigerait",
    "une",
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
  "word": "source",
  "hint": "texte ou micro nommé"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "La revue de trop vite n'aide personne, et Marc Nkurunziza reprend le fil.",
  "correct_sentence": "La précipitation n'aide personne, et Marc Nkurunziza reprend le fil.",
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
      "image_path": "/elearning/mfk-c1-m6/organisation-atelier.svg",
      "word": "organisation atelier"
    },
    {
      "image_path": "/elearning/mfk-c1-m6/bienveillance-poste.svg",
      "word": "bienveillance poste"
    },
    {
      "image_path": "/elearning/mfk-c1-m6/horloge-poste.svg",
      "word": "horloge poste"
    },
    {
      "image_path": "/elearning/mfk-c1-m6/accroche-offre.svg",
      "word": "accroche offre"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Synthétisez « Pas de tout le monde dit » : thèse, concession, implicite, proposition (quinze lignes)."
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
    'PO — Pas de tout le monde dit : dire sans slogan',
    'PO',
    $c$Objectif
Produire un oral structuré (thèse, concession, proposition). Point : selon tel cahier / tel micro ; organisation du travail.

Consigne
Répétez les modèles, puis prenez position en une minute : thèse, concession, reformulation, proposition.

Support — Modèles d'Aline Uwase, banc du figuier
Encore que l'on efface les signatures, une revue trop lisse pour être honnête n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Lila Sow concède que raccourcir aide l'oreille, pour autant que l'on garde selon et d'après.
Ce que l'on nomme revue, ici, n'est pas un slogan : tour de sources attribuées.
Encore que l'on cite, une revue trop lisse pour être honnête n'est pas un détail.
Lila Sow concède que raccourcir aide l'oreille, pour autant que l'on garde selon et d'après.
Autrement dit, la revue attribue : Cahier des racines, Radio Figuier, affiche de l'atelier
Il ressort que trois extraits, trois attributions, un point de friction nommé
Il ressort que les deux manques se parlent.
Aline : tout le monde dit est interdit en revue.
La proposition qui reste debout est celle-ci : trois extraits, trois attributions, un point de friction nommé
Je concède le point, je n'abandonne pas la proposition.
Ce n'est pas que je refuse : c'est que je refuse qu'on nomme cela un détail.
Autrement dit, l'implicite fait autant de travail que la thèse.
En une minute : fait, angle, concession, proposition.
Nous clôturons sans fusionner les voix : le Cahier des racines du mardi d'un côté, l'antenne de Radio Figuier du mercredi de l'autre, et le point où elles refusent de se ressembler.
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
  "explanation": "Lila Sow concède que raccourcir aide l'oreille, pour autant que l'on garde selon et d'après."
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
      "text": "raccourcir aide l'oreille — à condition que l'on garde selon et d'après",
      "correct": true
    },
    {
      "text": "Lila Sow abandonne il s'agit que le travail de la cour ait des voix, pas une rumeur",
      "correct": false
    },
    {
      "text": "La concession vaut acceptation du slogan",
      "correct": false
    }
  ],
  "explanation": "Concession réelle, pas un abandon : l'on garde selon et d'après"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "revue",
      "right": "tour de sources attribuées"
    },
    {
      "left": "source",
      "right": "texte ou micro nommé"
    },
    {
      "left": "attribution",
      "right": "selon / d'après"
    },
    {
      "left": "friction",
      "right": "désaccord conservé, pas gommée"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nIl appert que revue n'est pas un slogan.",
  "answer": "appert"
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
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "attribution",
  "hint": "selon / d'après"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Lila Sow écoute encore, et il fautons citer avant de crier.",
  "correct_sentence": "Lila Sow écoute encore, et il faut citer avant de crier.",
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
      "image_path": "/elearning/mfk-c1-m6/bienveillance-poste.svg",
      "word": "bienveillance poste"
    },
    {
      "image_path": "/elearning/mfk-c1-m6/horloge-poste.svg",
      "word": "horloge poste"
    },
    {
      "image_path": "/elearning/mfk-c1-m6/accroche-offre.svg",
      "word": "accroche offre"
    },
    {
      "image_path": "/elearning/mfk-c1-m6/entretien-joel.svg",
      "word": "entretien joel"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Écrivez six phrases orales justes : deux sur selon tel cahier / tel micro ; organisation du travail, deux concessions, deux propositions."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez quatre modèles, puis votre prise de position (thèse, concession, proposition). Gardez le Cahier des racines du mardi et l'antenne de Radio Figuier du mercredi distincts."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PE — le texte de Lila Sow',
    'PE',
    $c$Objectif
Écrire un texte long et structuré. Réaliser une revue de presse de l'atelier et de la radio, sans fusionner les sources. Point : selon tel cahier / tel micro ; organisation du travail.

Consigne
Imitez le texte de Lila Sow.

Support — Lila Sow — Pas de tout le monde dit
Lila Sow — Pas de tout le monde dit
On parle trop vite de la revue de presse du Seuil, comme si le mot dispensait d'en examiner le prix.
Encore que l'on efface les signatures, une revue trop lisse pour être honnête n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Lila Sow concède que raccourcir aide l'oreille, pour autant que l'on garde selon et d'après.
Ce que l'on nomme revue, ici, n'est pas un slogan : tour de sources attribuées.
Selon le Cahier, l'atelier manque de relais ; d'après l'antenne, la radio manque d'heures.
Aline : tout le monde dit est interdit en revue.
Joël écoute sa propre absence et la nomme.
Patrick veut la friction, pas la paix fausse.
La proposition qui reste debout est celle-ci : trois extraits, trois attributions, un point de friction nommé
Marc : une revue de presse est un art d'attribution.
Nous clôturons sans fusionner les voix : le Cahier des racines du mardi d'un côté, l'antenne de Radio Figuier du mercredi de l'autre, et le point où elles refusent de se ressembler.
Encore que l'on cite, une revue trop lisse pour être honnête n'est pas un détail.
Lila Sow concède que raccourcir aide l'oreille, pour autant que l'on garde selon et d'après.
Je n'écris pas pour vaincre : j'écris pour que la cour puisse relire.
la revue attribue : Cahier des racines, Radio Figuier, affiche de l'atelier
Lila Sow, Rukiri-Nord
$c$,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "La proposition retenue est : trois extraits, trois attributions, un point de friction nommé",
  "correct": true,
  "explanation": "trois extraits, trois attributions, un point de friction nommé"
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
      "text": "trois extraits, trois attributions, un point de friction nommé",
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
  "explanation": "trois extraits, trois attributions, un point de friction nommé"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "revue",
      "right": "tour de sources attribuées"
    },
    {
      "left": "source",
      "right": "texte ou micro nommé"
    },
    {
      "left": "attribution",
      "right": "selon / d'après"
    },
    {
      "left": "friction",
      "right": "désaccord conservé, pas gommée"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nEncore que l'on ___ les deux sources, on ne les fusionne pas. (citer, subj.)",
  "answer": "cite"
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
    "cite",
    "les",
    "sources",
    "on",
    "ne",
    "les",
    "fusionne",
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
  "word": "friction",
  "hint": "désaccord conservé, pas gommée"
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
      "image_path": "/elearning/mfk-c1-m6/horloge-poste.svg",
      "word": "horloge poste"
    },
    {
      "image_path": "/elearning/mfk-c1-m6/accroche-offre.svg",
      "word": "accroche offre"
    },
    {
      "image_path": "/elearning/mfk-c1-m6/entretien-joel.svg",
      "word": "entretien joel"
    },
    {
      "image_path": "/elearning/mfk-c1-m6/cv-croise.svg",
      "word": "cv croise"
    }
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
    'EL — selon tel cahier / tel micro ; organisation du travail',
    'EL',
    $c$Objectif
Maîtriser selon tel cahier / tel micro ; organisation du travail au registre C1, avec collocations et pièges de construction.

Consigne
Apprenez la fiche, puis produisez des exemples justes au registre demandé.

Support — Fiche d'Aline Uwase, banc ocre
Fiche C1 — selon tel cahier / tel micro ; organisation du travail
On ne retient pas une liste : on retient des constructions et des collocations.
Encore que l'on cite, une revue trop lisse pour être honnête n'est pas un détail.
Lila Sow concède que raccourcir aide l'oreille, pour autant que l'on garde selon et d'après.
Autrement dit, la revue attribue : Cahier des racines, Radio Figuier, affiche de l'atelier
Il ressort que trois extraits, trois attributions, un point de friction nommé
Piège : fusionner les sources au lieu de les attribuer (selon / d'après)
Registre : soutenu argumentatif, sans slogan
Collocation : encore que, pour autant que, il ressort que
Ce que l'on nomme revue, ici, n'est pas un slogan : tour de sources attribuées.
Il ressort que les deux manques se parlent.
Aline : tout le monde dit est interdit en revue.
Nominaliser, ce n'est pas alourdir : c'est nommer le processus (la densification, l'accueil, le rappel).
Encore que / pour autant que / si tant est que : subjonctif, concession réelle, pas un ornement.
Reformuler une source : on change la syntaxe, on garde la charge, on signale le point de vue.
C1 : l'implicite se justifie. C2 : l'ironie se laisse entendre sans s'afficher.
Exemple fautif à ne plus produire : On va au attribution pour de vrai genre, et Marc Nkurunziza demande un registre plus net.
Correction : On va au attribution vraiment, et Marc Nkurunziza demande un registre plus net.
Aline Uwase, banc ocre — Le Seuil des Sources.
$c$,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "« Selon X » permet d'attribuer sans fusionner.",
  "correct": true,
  "explanation": "Compte-rendu."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Pour attribuer une idée à une source, on privilégie…",
  "options": [
    {
      "text": "je pense que sans source",
      "correct": false
    },
    {
      "text": "selon / d'après / il ressort que",
      "correct": true
    },
    {
      "text": "il fautons",
      "correct": false
    },
    {
      "text": "un slogan",
      "correct": false
    }
  ],
  "explanation": "Marqueurs de compte-rendu."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "revue",
      "right": "tour de sources attribuées"
    },
    {
      "left": "source",
      "right": "texte ou micro nommé"
    },
    {
      "left": "attribution",
      "right": "selon / d'après"
    },
    {
      "left": "friction",
      "right": "désaccord conservé, pas gommée"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nLe compte-rendu ___ les désaccords, il ne les gomme pas. (accueillir)",
  "answer": "accueille"
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
    "appert",
    "que",
    "le",
    "slogan",
    "ne",
    "tient",
    "pas",
    "lieu",
    "de",
    "plan",
    "."
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
  "sentence_with_error": "On va au attribution pour de vrai genre, et Marc Nkurunziza demande un registre plus net.",
  "correct_sentence": "On va au attribution vraiment, et Marc Nkurunziza demande un registre plus net.",
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
      "image_path": "/elearning/mfk-c1-m6/accroche-offre.svg",
      "word": "accroche offre"
    },
    {
      "image_path": "/elearning/mfk-c1-m6/entretien-joel.svg",
      "word": "entretien joel"
    },
    {
      "image_path": "/elearning/mfk-c1-m6/cv-croise.svg",
      "word": "cv croise"
    },
    {
      "image_path": "/elearning/mfk-c1-m6/porte-essai.svg",
      "word": "porte essai"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Tableau de langue : six exemples justes de « selon tel cahier / tel micro ; organisation du travail » et deux pièges commentés."
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

  -- ===== Accroche et entretien =====
  SELECT s.id INTO v_seq_id
  FROM elearning_sequences s
  WHERE s.module_id = v_module_id AND s.title = 'Accroche et entretien'
  LIMIT 1;

  IF v_seq_id IS NULL THEN
    INSERT INTO elearning_sequences (module_id, title, order_index)
    VALUES (v_module_id, 'Accroche et entretien', 1)
    RETURNING id INTO v_seq_id;
  ELSE
    UPDATE elearning_sequences
    SET order_index = 1
    WHERE id = v_seq_id;
  END IF;

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CO — Accroche et entretien',
    'CO',
    $c$Objectif
Comprendre un échange long et en extraire l'implicite. Témoigner d'un entretien et rédiger une accroche d'offre sans mensonge. Viser la nuance, la collocation et l'implicite.

Consigne
Lisez le débat (à écouter avec l'enseignant). Qu'est-ce qui est dit, qu'est-ce qui reste implicite, qui concède quoi ?

Support — Débat Radio Figuier — Accroche et entretien
Lila Sow : Radio Figuier. On parle trop vite de l'entretien de Joël à l'atelier, comme si le mot dispensait d'en examiner le prix.
Marc Nkurunziza : Encore que l'on habille le poste d'un mot trop grand, une accroche qui n'a pas de mains n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Léa Niyonzima : Joël Mugisha concède que une phrase courte attire l'œil, pour autant que l'on y lise encore le fer, les heures, le relais.
Aline Uwase : Ce que l'on nomme accroche, ici, n'est pas un slogan : première phrase d'une offre, à tenir juste.
Patrick Habimana : Joël a dit qu'il poserait le casque dès l'aube si le relais existait.
Hawa Diallo : Rose a demandé si l'on nommait les mains dans l'accroche.
Joël Mugisha : Karim a prétendu que les heures étaient déjà trop longues, puis a corrigé.
Rose Iradukunda : Lila a exigé que l'on coupe super profil.
Solange Mukamana : Aline : le DI au passé décale les temps, il n'embellit pas.
Karim Bamba : Dieudonné a écouté derrière la porte, puis s'est montré.
Félicie Ndayishimiye : Un chiffre, une trace : Joël a parlé de relais ; Karim a parlé de chiffres ; l'accroche trop grande a été raturée deux fois.
Dieudonné Hakizimana : L'enjeu n'est pas d'avoir raison plus fort : il s'agit de recruter sans mentir sur la peine ni sur la joie
Yvette : Yvette : un entretien n'est pas une chasse.
Mado : Karim Bamba entend, dans « super profil », ceci qui n'est pas dit : super profil flatte pour ne pas dire ce que le poste exige vraiment
Sami : Autrement dit, Joël a dit qu'il poserait le casque ; l'accroche n'a pas à le transformer en héros
Lila Sow : Je reformule pour les auditeurs. La proposition qui reste debout est celle-ci : une accroche juste, puis un témoignage d'entretien au discours indirect
Nina Kayitesi : Marc : témoigner, c'est garder le fer dans la phrase.
Lila Sow : Nous clôturons sans clore. Nous clôturons sans fusionner les voix : l'accroche raturée d'un côté, le témoignage de Joël de l'autre, et le point où elles refusent de se ressembler.
$c$,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "une accroche qui n'a pas de mains est présenté comme un simple détail sans conséquence.",
  "correct": false,
  "explanation": "Le texte affirme au contraire que une accroche qui n'a pas de mains n'est pas un détail."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Selon Karim Bamba, que reste-t-il implicite dans « super profil » ?",
  "options": [
    {
      "text": "Que Joël a menti sur le casque",
      "correct": false
    },
    {
      "text": "Ne pas dire ce que le poste exige",
      "correct": true
    },
    {
      "text": "Que Karim a écrit super profil",
      "correct": false
    },
    {
      "text": "Que Rose a interdit l'atelier",
      "correct": false
    }
  ],
  "explanation": "super profil flatte pour ne pas dire ce que le poste exige vraiment"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "accroche",
      "right": "première phrase d'une offre, à tenir juste"
    },
    {
      "left": "entretien",
      "right": "échange, pas un interrogatoire"
    },
    {
      "left": "poste",
      "right": "travail nommé, avec heures"
    },
    {
      "left": "témoignage",
      "right": "récit d'expérience, au DI souvent"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nJoël a dit qu'il ___ le casque dès l'aube. (poser, cond. du DI passé)",
  "answer": "poserait"
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
    "a",
    "dit",
    "qu'il",
    "poserait",
    "le",
    "casque",
    "dès",
    "l'aube",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "accroche",
  "hint": "première phrase d'une offre, à tenir juste"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Joël a dit qu'il posera le casque dès l'aube, et Joël Mugisha prend des notes.",
  "correct_sentence": "Joël a dit qu'il poserait le casque dès l'aube, et Joël Mugisha prend des notes.",
  "explanation": "DI au passé : poserait."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-c1-m6/entretien-joel.svg",
      "word": "entretien joel"
    },
    {
      "image_path": "/elearning/mfk-c1-m6/cv-croise.svg",
      "word": "cv croise"
    },
    {
      "image_path": "/elearning/mfk-c1-m6/porte-essai.svg",
      "word": "porte essai"
    },
    {
      "image_path": "/elearning/mfk-c1-m6/conflit-atelier.svg",
      "word": "conflit atelier"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Reformulez l'implicite de « super profil » et la concession de Joël Mugisha."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez une synthèse d'environ quatre-vingt-dix secondes : deux points de vue, un implicite, une proposition. Gardez l'accroche raturée et le témoignage de Joël distincts."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CE — Pas de super profil',
    'CE',
    $c$Objectif
Lire un texte argumenté long, synthétiser et reformuler. Témoigner d'un entretien et rédiger une accroche d'offre sans mensonge. Viser la nuance, la collocation et l'implicite.

Consigne
Lisez « Pas de super profil », sans aller trop vite. Repérez la thèse, la concession, l'implicite et la proposition.

Support — Pas de super profil
On parle trop vite de l'entretien de Joël à l'atelier, comme si le mot dispensait d'en examiner le prix.
Encore que l'on habille le poste d'un mot trop grand, une accroche qui n'a pas de mains n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Joël Mugisha concède que une phrase courte attire l'œil, pour autant que l'on y lise encore le fer, les heures, le relais.
Ce que l'on nomme accroche, ici, n'est pas un slogan : première phrase d'une offre, à tenir juste.
Joël a dit qu'il poserait le casque dès l'aube si le relais existait.
Rose a demandé si l'on nommait les mains dans l'accroche.
Karim a prétendu que les heures étaient déjà trop longues, puis a corrigé.
Lila a exigé que l'on coupe super profil.
Aline : le DI au passé décale les temps, il n'embellit pas.
Dieudonné a écouté derrière la porte, puis s'est montré.
Un chiffre, une trace : Joël a parlé de relais ; Karim a parlé de chiffres ; l'accroche trop grande a été raturée deux fois.
L'enjeu n'est pas d'avoir raison plus fort : il s'agit de recruter sans mentir sur la peine ni sur la joie
Yvette : un entretien n'est pas une chasse.
Karim Bamba entend, dans « super profil », ceci qui n'est pas dit : super profil flatte pour ne pas dire ce que le poste exige vraiment
Autrement dit, Joël a dit qu'il poserait le casque ; l'accroche n'a pas à le transformer en héros
La proposition qui reste debout est celle-ci : une accroche juste, puis un témoignage d'entretien au discours indirect
Marc : témoigner, c'est garder le fer dans la phrase.
Nous clôturons sans fusionner les voix : l'accroche raturée d'un côté, le témoignage de Joël de l'autre, et le point où elles refusent de se ressembler.
Signé : Joël Mugisha, Rukiri-Nord — Cahier des racines, Rukiri-Nord.
$c$,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Le texte refuse de fusionner l'accroche raturée et le témoignage de Joël en une seule affiche.",
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
      "text": "Relais, chiffres, accroche raturée deux fois",
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
  "explanation": "Joël a parlé de relais ; Karim a parlé de chiffres ; l'accroche trop grande a été raturée deux fois."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "accroche",
      "right": "première phrase d'une offre, à tenir juste"
    },
    {
      "left": "entretien",
      "right": "échange, pas un interrogatoire"
    },
    {
      "left": "poste",
      "right": "travail nommé, avec heures"
    },
    {
      "left": "témoignage",
      "right": "récit d'expérience, au DI souvent"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nRose a demandé si l'on ___ les mains dans l'accroche. (nommer, imp.)",
  "answer": "nommait"
}$j$::jsonb,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Remettez les mots dans l''ordre',
    'word_order',
    $j${
  "words": [
    "Rose",
    "a",
    "demandé",
    "si",
    "l'on",
    "nommait",
    "les",
    "mains",
    "dans",
    "l'accroche",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "entretien",
  "hint": "échange, pas un interrogatoire"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "La accroche de trop vite n'aide personne, et Karim Bamba reprend le fil.",
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
      "image_path": "/elearning/mfk-c1-m6/cv-croise.svg",
      "word": "cv croise"
    },
    {
      "image_path": "/elearning/mfk-c1-m6/porte-essai.svg",
      "word": "porte essai"
    },
    {
      "image_path": "/elearning/mfk-c1-m6/conflit-atelier.svg",
      "word": "conflit atelier"
    },
    {
      "image_path": "/elearning/mfk-c1-m6/discours-rapporte.svg",
      "word": "discours rapporte"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Synthétisez « Pas de super profil » : thèse, concession, implicite, proposition (quinze lignes)."
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
    'PO — Accroche et entretien : dire sans slogan',
    'PO',
    $c$Objectif
Produire un oral structuré (thèse, concession, proposition). Point : discours indirect ; accroche d'offre ; témoignage.

Consigne
Répétez les modèles, puis prenez position en une minute : thèse, concession, reformulation, proposition.

Support — Modèles d'Aline Uwase, banc du figuier
Encore que l'on habille le poste d'un mot trop grand, une accroche qui n'a pas de mains n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Joël Mugisha concède que une phrase courte attire l'œil, pour autant que l'on y lise encore le fer, les heures, le relais.
Ce que l'on nomme accroche, ici, n'est pas un slogan : première phrase d'une offre, à tenir juste.
Encore que l'on rature, une accroche qui n'a pas de mains n'est pas un détail.
Joël Mugisha concède que une phrase courte attire l'œil, pour autant que l'on y lise encore le fer, les heures, le relais.
Autrement dit, Joël a dit qu'il poserait le casque ; l'accroche n'a pas à le transformer en héros
Il ressort qu'une accroche juste, puis un témoignage d'entretien au discours indirect
Rose a demandé si l'on nommait les mains dans l'accroche.
Aline : le DI au passé décale les temps, il n'embellit pas.
La proposition qui reste debout est celle-ci : une accroche juste, puis un témoignage d'entretien au discours indirect
Je concède le point, je n'abandonne pas la proposition.
Ce n'est pas que je refuse : c'est que je refuse qu'on nomme cela un détail.
Autrement dit, l'implicite fait autant de travail que la thèse.
En une minute : fait, angle, concession, proposition.
Nous clôturons sans fusionner les voix : l'accroche raturée d'un côté, le témoignage de Joël de l'autre, et le point où elles refusent de se ressembler.
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
  "explanation": "Joël Mugisha concède que une phrase courte attire l'œil, pour autant que l'on y lise encore le fer, les heures, le relais."
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
      "text": "une phrase courte attire l'œil — à condition que l'on y lise encore le fer, les heures, le relais",
      "correct": true
    },
    {
      "text": "Joël Mugisha abandonne il s'agit de recruter sans mentir sur la peine ni sur la joie",
      "correct": false
    },
    {
      "text": "La concession vaut acceptation du slogan",
      "correct": false
    }
  ],
  "explanation": "Concession réelle, pas un abandon : l'on y lise encore le fer, les heures, le relais"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "accroche",
      "right": "première phrase d'une offre, à tenir juste"
    },
    {
      "left": "entretien",
      "right": "échange, pas un interrogatoire"
    },
    {
      "left": "poste",
      "right": "travail nommé, avec heures"
    },
    {
      "left": "témoignage",
      "right": "récit d'expérience, au DI souvent"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nKarim a prétendu que les heures ___ déjà trop longues. (être, imp.)",
  "answer": "étaient"
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
    "prétendu",
    "que",
    "les",
    "heures",
    "étaient",
    "déjà",
    "trop",
    "longues",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "poste",
  "hint": "travail nommé, avec heures"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Joël Mugisha écoute encore, et il fautons raturer avant de crier.",
  "correct_sentence": "Joël Mugisha écoute encore, et il faut raturer avant de crier.",
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
      "image_path": "/elearning/mfk-c1-m6/porte-essai.svg",
      "word": "porte essai"
    },
    {
      "image_path": "/elearning/mfk-c1-m6/conflit-atelier.svg",
      "word": "conflit atelier"
    },
    {
      "image_path": "/elearning/mfk-c1-m6/discours-rapporte.svg",
      "word": "discours rapporte"
    },
    {
      "image_path": "/elearning/mfk-c1-m6/crise-travail.svg",
      "word": "crise travail"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Écrivez six phrases orales justes : deux sur discours indirect ; accroche d'offre ; témoignage, deux concessions, deux propositions."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez quatre modèles, puis votre prise de position (thèse, concession, proposition). Gardez l'accroche raturée et le témoignage de Joël distincts."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PE — le texte de Joël Mugisha',
    'PE',
    $c$Objectif
Écrire un texte long et structuré. Témoigner d'un entretien et rédiger une accroche d'offre sans mensonge. Point : discours indirect ; accroche d'offre ; témoignage.

Consigne
Imitez le texte de Joël Mugisha.

Support — Joël Mugisha — Pas de super profil
Joël Mugisha — Pas de super profil
On parle trop vite de l'entretien de Joël à l'atelier, comme si le mot dispensait d'en examiner le prix.
Encore que l'on habille le poste d'un mot trop grand, une accroche qui n'a pas de mains n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Joël Mugisha concède que une phrase courte attire l'œil, pour autant que l'on y lise encore le fer, les heures, le relais.
Ce que l'on nomme accroche, ici, n'est pas un slogan : première phrase d'une offre, à tenir juste.
Joël a dit qu'il poserait le casque dès l'aube si le relais existait.
Aline : le DI au passé décale les temps, il n'embellit pas.
Dieudonné a écouté derrière la porte, puis s'est montré.
Yvette : un entretien n'est pas une chasse.
La proposition qui reste debout est celle-ci : une accroche juste, puis un témoignage d'entretien au discours indirect
Marc : témoigner, c'est garder le fer dans la phrase.
Nous clôturons sans fusionner les voix : l'accroche raturée d'un côté, le témoignage de Joël de l'autre, et le point où elles refusent de se ressembler.
Encore que l'on rature, une accroche qui n'a pas de mains n'est pas un détail.
Joël Mugisha concède que une phrase courte attire l'œil, pour autant que l'on y lise encore le fer, les heures, le relais.
Je n'écris pas pour vaincre : j'écris pour que la cour puisse relire.
Joël a dit qu'il poserait le casque ; l'accroche n'a pas à le transformer en héros
Joël Mugisha, Rukiri-Nord
$c$,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "La proposition retenue est : une accroche juste, puis un témoignage d'entretien au discours indirect",
  "correct": true,
  "explanation": "une accroche juste, puis un témoignage d'entretien au discours indirect"
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
      "text": "une accroche juste, puis un témoignage d'entretien au discours indirect",
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
  "explanation": "une accroche juste, puis un témoignage d'entretien au discours indirect"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "accroche",
      "right": "première phrase d'une offre, à tenir juste"
    },
    {
      "left": "entretien",
      "right": "échange, pas un interrogatoire"
    },
    {
      "left": "poste",
      "right": "travail nommé, avec heures"
    },
    {
      "left": "témoignage",
      "right": "récit d'expérience, au DI souvent"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nLila a exigé que l'on ___ les insultes. (raturer, subj.)",
  "answer": "rature"
}$j$::jsonb,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Remettez les mots dans l''ordre',
    'word_order',
    $j${
  "words": [
    "Lila",
    "a",
    "exigé",
    "que",
    "l'on",
    "rature",
    "les",
    "insultes",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "témoignage",
  "hint": "récit d'expérience, au DI souvent"
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
      "image_path": "/elearning/mfk-c1-m6/conflit-atelier.svg",
      "word": "conflit atelier"
    },
    {
      "image_path": "/elearning/mfk-c1-m6/discours-rapporte.svg",
      "word": "discours rapporte"
    },
    {
      "image_path": "/elearning/mfk-c1-m6/crise-travail.svg",
      "word": "crise travail"
    },
    {
      "image_path": "/elearning/mfk-c1-m6/table-froide.svg",
      "word": "table froide"
    }
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
    'EL — discours indirect ; accroche d''offre ; témoignage',
    'EL',
    $c$Objectif
Maîtriser discours indirect ; accroche d'offre ; témoignage au registre C1, avec collocations et pièges de construction.

Consigne
Apprenez la fiche, puis produisez des exemples justes au registre demandé.

Support — Fiche d'Aline Uwase, banc ocre
Fiche C1 — discours indirect ; accroche d'offre ; témoignage
On ne retient pas une liste : on retient des constructions et des collocations.
Encore que l'on rature, une accroche qui n'a pas de mains n'est pas un détail.
Joël Mugisha concède que une phrase courte attire l'œil, pour autant que l'on y lise encore le fer, les heures, le relais.
Autrement dit, Joël a dit qu'il poserait le casque ; l'accroche n'a pas à le transformer en héros
Il ressort qu'une accroche juste, puis un témoignage d'entretien au discours indirect
Piège : garder le présent du DD dans un DI au passé
Registre : soutenu argumentatif, sans slogan
Collocation : encore que, pour autant que, il ressort que
Ce que l'on nomme accroche, ici, n'est pas un slogan : première phrase d'une offre, à tenir juste.
Rose a demandé si l'on nommait les mains dans l'accroche.
Aline : le DI au passé décale les temps, il n'embellit pas.
Nominaliser, ce n'est pas alourdir : c'est nommer le processus (la densification, l'accueil, le rappel).
Encore que / pour autant que / si tant est que : subjonctif, concession réelle, pas un ornement.
Reformuler une source : on change la syntaxe, on garde la charge, on signale le point de vue.
C1 : l'implicite se justifie. C2 : l'ironie se laisse entendre sans s'afficher.
Exemple fautif à ne plus produire : On va au poste pour de vrai genre, et Karim Bamba demande un registre plus net.
Correction : On va au poste vraiment, et Karim Bamba demande un registre plus net.
Aline Uwase, banc ocre — Le Seuil des Sources.
$c$,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Le discours indirect au passé décale souvent les temps.",
  "correct": true,
  "explanation": "Concordance."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Dans un discours indirect au passé, « je poserai » devient souvent…",
  "options": [
    {
      "text": "je poserai encore",
      "correct": false
    },
    {
      "text": "il poserait",
      "correct": true
    },
    {
      "text": "il a posé uniquement",
      "correct": false
    },
    {
      "text": "pose !",
      "correct": false
    }
  ],
  "explanation": "Futur → conditionnel dans le DI au passé."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "accroche",
      "right": "première phrase d'une offre, à tenir juste"
    },
    {
      "left": "entretien",
      "right": "échange, pas un interrogatoire"
    },
    {
      "left": "poste",
      "right": "travail nommé, avec heures"
    },
    {
      "left": "témoignage",
      "right": "récit d'expérience, au DI souvent"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nLe discours ___ n'est pas une sténographie : on change les temps. (rapporté)",
  "answer": "rapporté"
}$j$::jsonb,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Remettez les mots dans l''ordre',
    'word_order',
    $j${
  "words": [
    "Rapporter",
    "n'est",
    "pas",
    "sténographier",
    "."
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
  "sentence_with_error": "On va au poste pour de vrai genre, et Karim Bamba demande un registre plus net.",
  "correct_sentence": "On va au poste vraiment, et Karim Bamba demande un registre plus net.",
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
      "image_path": "/elearning/mfk-c1-m6/discours-rapporte.svg",
      "word": "discours rapporte"
    },
    {
      "image_path": "/elearning/mfk-c1-m6/crise-travail.svg",
      "word": "crise travail"
    },
    {
      "image_path": "/elearning/mfk-c1-m6/table-froide.svg",
      "word": "table froide"
    },
    {
      "image_path": "/elearning/mfk-c1-m6/eldorado-invente.svg",
      "word": "eldorado invente"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Tableau de langue : six exemples justes de « discours indirect ; accroche d'offre ; témoignage » et deux pièges commentés."
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

  -- ===== Conflit à l'atelier =====
  SELECT s.id INTO v_seq_id
  FROM elearning_sequences s
  WHERE s.module_id = v_module_id AND s.title = 'Conflit à l''atelier'
  LIMIT 1;

  IF v_seq_id IS NULL THEN
    INSERT INTO elearning_sequences (module_id, title, order_index)
    VALUES (v_module_id, 'Conflit à l''atelier', 2)
    RETURNING id INTO v_seq_id;
  ELSE
    UPDATE elearning_sequences
    SET order_index = 2
    WHERE id = v_seq_id;
  END IF;

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CO — Conflit à l''atelier',
    'CO',
    $c$Objectif
Comprendre un échange long et en extraire l'implicite. Comprendre un conflit de travail et le rapporter sans le romancer. Viser la nuance, la collocation et l'implicite.

Consigne
Lisez le débat (à écouter avec l'enseignant). Qu'est-ce qui est dit, qu'est-ce qui reste implicite, qui concède quoi ?

Support — Débat Radio Figuier — Conflit à l'atelier
Lila Sow : Radio Figuier. On parle trop vite de la crise de l'atelier, comme si le mot dispensait d'en examiner le prix.
Marc Nkurunziza : Encore que l'on désigne un coupable trop vite, une table trop froide après la voix trop haute n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Léa Niyonzima : Rose Iradukunda concède que élever la voix arrive, pour autant que l'on revienne aux heures, au relais, au fer, pas à l'humiliation.
Aline Uwase : Ce que l'on nomme conflit, ici, n'est pas un slogan : désaccord de travail, à rapporter.
Patrick Habimana : On aurait dit que la table allait se fendre ; elle n'a fait que refroidir.
Hawa Diallo : Rose a dit qu'elle garderait les propos, pas les insultes.
Joël Mugisha : Joël a demandé si l'on parlait encore du relais.
Rose Iradukunda : Karim a chiffré, trop tôt.
Solange Mukamana : Aline : le style indirect libre peut montrer la fièvre, il ne doit pas l'inventer.
Karim Bamba : Lila n'enregistrera pas la crise comme un spectacle.
Félicie Ndayishimiye : Un chiffre, une trace : Deux voix trop hautes ; une heure de silence ; un relais promis, puis oublié, puis réécrit.
Dieudonné Hakizimana : L'enjeu n'est pas d'avoir raison plus fort : il s'agit que la crise serve à réparer le travail, pas à créer un héros et un traître
Yvette : Patrick propose une heure calme avant de décider.
Mado : Dieudonné Hakizimana entend, dans « c'est la faute des autres », ceci qui n'est pas dit : c'est la faute des autres évite de compter les heures mal partagées
Sami : Autrement dit, rapporter un discours de crise, c'est garder les propos, signaler le ton, refuser le roman
Lila Sow : Je reformule pour les auditeurs. La proposition qui reste debout est celle-ci : un compte-rendu : ce qui a été dit, ce qui a été tu, ce que l'atelier peut décider
Nina Kayitesi : Marc : une crise du travail se répare au relais, pas au roman.
Lila Sow : Nous clôturons sans clore. Nous clôturons sans fusionner les voix : le compte-rendu de Rose d'un côté, les notes de Karim de l'autre, et le point où elles refusent de se ressembler.
$c$,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "une table trop froide après la voix trop haute est présenté comme un simple détail sans conséquence.",
  "correct": false,
  "explanation": "Le texte affirme au contraire que une table trop froide après la voix trop haute n'est pas un détail."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Selon Dieudonné Hakizimana, que reste-t-il implicite dans « c'est la faute des autres » ?",
  "options": [
    {
      "text": "Que Rose a renvoyé Joël",
      "correct": false
    },
    {
      "text": "Éviter de compter les heures mal partagées",
      "correct": true
    },
    {
      "text": "Que Dieudonné a crié",
      "correct": false
    },
    {
      "text": "Que le relais n'a jamais existé comme enjeu",
      "correct": false
    }
  ],
  "explanation": "c'est la faute des autres évite de compter les heures mal partagées"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "conflit",
      "right": "désaccord de travail, à rapporter"
    },
    {
      "left": "crise",
      "right": "moment trop tendu, pas une légende"
    },
    {
      "left": "relais",
      "right": "partage des heures, souvent l'enjeu"
    },
    {
      "left": "compte-rendu",
      "right": "texte factuel, sans héros"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nJoël a dit qu'il ___ le casque dès l'aube. (poser, cond. du DI passé)",
  "answer": "poserait"
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
    "a",
    "dit",
    "qu'il",
    "poserait",
    "le",
    "casque",
    "dès",
    "l'aube",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "conflit",
  "hint": "désaccord de travail, à rapporter"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Joël a dit qu'il posera le casque dès l'aube, et Rose Iradukunda prend des notes.",
  "correct_sentence": "Joël a dit qu'il poserait le casque dès l'aube, et Rose Iradukunda prend des notes.",
  "explanation": "DI au passé : poserait."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-c1-m6/crise-travail.svg",
      "word": "crise travail"
    },
    {
      "image_path": "/elearning/mfk-c1-m6/table-froide.svg",
      "word": "table froide"
    },
    {
      "image_path": "/elearning/mfk-c1-m6/eldorado-invente.svg",
      "word": "eldorado invente"
    },
    {
      "image_path": "/elearning/mfk-c1-m6/temoignage-expat.svg",
      "word": "temoignage expat"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Reformulez l'implicite de « c'est la faute des autres » et la concession de Rose Iradukunda."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez une synthèse d'environ quatre-vingt-dix secondes : deux points de vue, un implicite, une proposition. Gardez le compte-rendu de Rose et les notes de Karim distincts."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CE — Pas de roman de crise',
    'CE',
    $c$Objectif
Lire un texte argumenté long, synthétiser et reformuler. Comprendre un conflit de travail et le rapporter sans le romancer. Viser la nuance, la collocation et l'implicite.

Consigne
Lisez « Pas de roman de crise », sans aller trop vite. Repérez la thèse, la concession, l'implicite et la proposition.

Support — Pas de roman de crise
On parle trop vite de la crise de l'atelier, comme si le mot dispensait d'en examiner le prix.
Encore que l'on désigne un coupable trop vite, une table trop froide après la voix trop haute n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Rose Iradukunda concède que élever la voix arrive, pour autant que l'on revienne aux heures, au relais, au fer, pas à l'humiliation.
Ce que l'on nomme conflit, ici, n'est pas un slogan : désaccord de travail, à rapporter.
On aurait dit que la table allait se fendre ; elle n'a fait que refroidir.
Rose a dit qu'elle garderait les propos, pas les insultes.
Joël a demandé si l'on parlait encore du relais.
Karim a chiffré, trop tôt.
Aline : le style indirect libre peut montrer la fièvre, il ne doit pas l'inventer.
Lila n'enregistrera pas la crise comme un spectacle.
Un chiffre, une trace : Deux voix trop hautes ; une heure de silence ; un relais promis, puis oublié, puis réécrit.
L'enjeu n'est pas d'avoir raison plus fort : il s'agit que la crise serve à réparer le travail, pas à créer un héros et un traître
Patrick propose une heure calme avant de décider.
Dieudonné Hakizimana entend, dans « c'est la faute des autres », ceci qui n'est pas dit : c'est la faute des autres évite de compter les heures mal partagées
Autrement dit, rapporter un discours de crise, c'est garder les propos, signaler le ton, refuser le roman
La proposition qui reste debout est celle-ci : un compte-rendu : ce qui a été dit, ce qui a été tu, ce que l'atelier peut décider
Marc : une crise du travail se répare au relais, pas au roman.
Nous clôturons sans fusionner les voix : le compte-rendu de Rose d'un côté, les notes de Karim de l'autre, et le point où elles refusent de se ressembler.
Signé : Rose Iradukunda, Rukiri-Nord — Cahier des racines, Rukiri-Nord.
$c$,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Le texte refuse de fusionner le compte-rendu de Rose et les notes de Karim en une seule affiche.",
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
      "text": "Deux voix trop hautes, une heure de silence, un relais réécrit",
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
  "explanation": "Deux voix trop hautes ; une heure de silence ; un relais promis, puis oublié, puis réécrit."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "conflit",
      "right": "désaccord de travail, à rapporter"
    },
    {
      "left": "crise",
      "right": "moment trop tendu, pas une légende"
    },
    {
      "left": "relais",
      "right": "partage des heures, souvent l'enjeu"
    },
    {
      "left": "compte-rendu",
      "right": "texte factuel, sans héros"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nRose a demandé si l'on ___ les mains dans l'accroche. (nommer, imp.)",
  "answer": "nommait"
}$j$::jsonb,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Remettez les mots dans l''ordre',
    'word_order',
    $j${
  "words": [
    "Rose",
    "a",
    "demandé",
    "si",
    "l'on",
    "nommait",
    "les",
    "mains",
    "dans",
    "l'accroche",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "crise",
  "hint": "moment trop tendu, pas une légende"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "La conflit de trop vite n'aide personne, et Dieudonné Hakizimana reprend le fil.",
  "correct_sentence": "La précipitation n'aide personne, et Dieudonné Hakizimana reprend le fil.",
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
      "image_path": "/elearning/mfk-c1-m6/table-froide.svg",
      "word": "table froide"
    },
    {
      "image_path": "/elearning/mfk-c1-m6/eldorado-invente.svg",
      "word": "eldorado invente"
    },
    {
      "image_path": "/elearning/mfk-c1-m6/temoignage-expat.svg",
      "word": "temoignage expat"
    },
    {
      "image_path": "/elearning/mfk-c1-m6/habitude-pro.svg",
      "word": "habitude pro"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Synthétisez « Pas de roman de crise » : thèse, concession, implicite, proposition (quinze lignes)."
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
    'PO — Conflit à l''atelier : dire sans slogan',
    'PO',
    $c$Objectif
Produire un oral structuré (thèse, concession, proposition). Point : rapporter une crise ; style indirect libre ; on aurait dit.

Consigne
Répétez les modèles, puis prenez position en une minute : thèse, concession, reformulation, proposition.

Support — Modèles d'Aline Uwase, banc du figuier
Encore que l'on désigne un coupable trop vite, une table trop froide après la voix trop haute n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Rose Iradukunda concède que élever la voix arrive, pour autant que l'on revienne aux heures, au relais, au fer, pas à l'humiliation.
Ce que l'on nomme conflit, ici, n'est pas un slogan : désaccord de travail, à rapporter.
Encore que l'on rapporte, une table trop froide après la voix trop haute n'est pas un détail.
Rose Iradukunda concède que élever la voix arrive, pour autant que l'on revienne aux heures, au relais, au fer, pas à l'humiliation.
Autrement dit, rapporter un discours de crise, c'est garder les propos, signaler le ton, refuser le roman
Il ressort qu'un compte-rendu : ce qui a été dit, ce qui a été tu, ce que l'atelier peut décider
Rose a dit qu'elle garderait les propos, pas les insultes.
Aline : le style indirect libre peut montrer la fièvre, il ne doit pas l'inventer.
La proposition qui reste debout est celle-ci : un compte-rendu : ce qui a été dit, ce qui a été tu, ce que l'atelier peut décider
Je concède le point, je n'abandonne pas la proposition.
Ce n'est pas que je refuse : c'est que je refuse qu'on nomme cela un détail.
Autrement dit, l'implicite fait autant de travail que la thèse.
En une minute : fait, angle, concession, proposition.
Nous clôturons sans fusionner les voix : le compte-rendu de Rose d'un côté, les notes de Karim de l'autre, et le point où elles refusent de se ressembler.
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
  "explanation": "Rose Iradukunda concède que élever la voix arrive, pour autant que l'on revienne aux heures, au relais, au fer, pas à l'humiliation."
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
      "text": "élever la voix arrive — à condition que l'on revienne aux heures, au relais, au fer, pas à l'humiliation",
      "correct": true
    },
    {
      "text": "Rose Iradukunda abandonne il s'agit que la crise serve à réparer le travail, pas à créer un héros et un traître",
      "correct": false
    },
    {
      "text": "La concession vaut acceptation du slogan",
      "correct": false
    }
  ],
  "explanation": "Concession réelle, pas un abandon : l'on revienne aux heures, au relais, au fer, pas à l'humiliation"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "conflit",
      "right": "désaccord de travail, à rapporter"
    },
    {
      "left": "crise",
      "right": "moment trop tendu, pas une légende"
    },
    {
      "left": "relais",
      "right": "partage des heures, souvent l'enjeu"
    },
    {
      "left": "compte-rendu",
      "right": "texte factuel, sans héros"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nKarim a prétendu que les heures ___ déjà trop longues. (être, imp.)",
  "answer": "étaient"
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
    "prétendu",
    "que",
    "les",
    "heures",
    "étaient",
    "déjà",
    "trop",
    "longues",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "relais",
  "hint": "partage des heures, souvent l'enjeu"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Rose Iradukunda écoute encore, et il fautons rapporter avant de crier.",
  "correct_sentence": "Rose Iradukunda écoute encore, et il faut rapporter avant de crier.",
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
      "image_path": "/elearning/mfk-c1-m6/eldorado-invente.svg",
      "word": "eldorado invente"
    },
    {
      "image_path": "/elearning/mfk-c1-m6/temoignage-expat.svg",
      "word": "temoignage expat"
    },
    {
      "image_path": "/elearning/mfk-c1-m6/habitude-pro.svg",
      "word": "habitude pro"
    },
    {
      "image_path": "/elearning/mfk-c1-m6/valise-contrat.svg",
      "word": "valise contrat"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Écrivez six phrases orales justes : deux sur rapporter une crise ; style indirect libre ; on aurait dit, deux concessions, deux propositions."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez quatre modèles, puis votre prise de position (thèse, concession, proposition). Gardez le compte-rendu de Rose et les notes de Karim distincts."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PE — le texte de Rose Iradukunda',
    'PE',
    $c$Objectif
Écrire un texte long et structuré. Comprendre un conflit de travail et le rapporter sans le romancer. Point : rapporter une crise ; style indirect libre ; on aurait dit.

Consigne
Imitez le texte de Rose Iradukunda.

Support — Rose Iradukunda — Pas de roman de crise
Rose Iradukunda — Pas de roman de crise
On parle trop vite de la crise de l'atelier, comme si le mot dispensait d'en examiner le prix.
Encore que l'on désigne un coupable trop vite, une table trop froide après la voix trop haute n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Rose Iradukunda concède que élever la voix arrive, pour autant que l'on revienne aux heures, au relais, au fer, pas à l'humiliation.
Ce que l'on nomme conflit, ici, n'est pas un slogan : désaccord de travail, à rapporter.
On aurait dit que la table allait se fendre ; elle n'a fait que refroidir.
Aline : le style indirect libre peut montrer la fièvre, il ne doit pas l'inventer.
Lila n'enregistrera pas la crise comme un spectacle.
Patrick propose une heure calme avant de décider.
La proposition qui reste debout est celle-ci : un compte-rendu : ce qui a été dit, ce qui a été tu, ce que l'atelier peut décider
Marc : une crise du travail se répare au relais, pas au roman.
Nous clôturons sans fusionner les voix : le compte-rendu de Rose d'un côté, les notes de Karim de l'autre, et le point où elles refusent de se ressembler.
Encore que l'on rapporte, une table trop froide après la voix trop haute n'est pas un détail.
Rose Iradukunda concède que élever la voix arrive, pour autant que l'on revienne aux heures, au relais, au fer, pas à l'humiliation.
Je n'écris pas pour vaincre : j'écris pour que la cour puisse relire.
rapporter un discours de crise, c'est garder les propos, signaler le ton, refuser le roman
Rose Iradukunda, Rukiri-Nord
$c$,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "La proposition retenue est : un compte-rendu : ce qui a été dit, ce qui a été tu, ce que l'atelier peut décider",
  "correct": true,
  "explanation": "un compte-rendu : ce qui a été dit, ce qui a été tu, ce que l'atelier peut décider"
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
      "text": "un compte-rendu : ce qui a été dit, ce qui a été tu, ce que l'atelier peut décider",
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
  "explanation": "un compte-rendu : ce qui a été dit, ce qui a été tu, ce que l'atelier peut décider"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "conflit",
      "right": "désaccord de travail, à rapporter"
    },
    {
      "left": "crise",
      "right": "moment trop tendu, pas une légende"
    },
    {
      "left": "relais",
      "right": "partage des heures, souvent l'enjeu"
    },
    {
      "left": "compte-rendu",
      "right": "texte factuel, sans héros"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nLila a exigé que l'on ___ les insultes. (rapporter, subj.)",
  "answer": "rapporte"
}$j$::jsonb,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Remettez les mots dans l''ordre',
    'word_order',
    $j${
  "words": [
    "Lila",
    "a",
    "exigé",
    "que",
    "l'on",
    "rapporte",
    "les",
    "insultes",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "compte-rendu",
  "hint": "texte factuel, sans héros"
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
      "image_path": "/elearning/mfk-c1-m6/temoignage-expat.svg",
      "word": "temoignage expat"
    },
    {
      "image_path": "/elearning/mfk-c1-m6/habitude-pro.svg",
      "word": "habitude pro"
    },
    {
      "image_path": "/elearning/mfk-c1-m6/valise-contrat.svg",
      "word": "valise contrat"
    },
    {
      "image_path": "/elearning/mfk-c1-m6/analyse-travail.svg",
      "word": "analyse travail"
    }
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
    'EL — rapporter une crise ; style indirect libre ; on aurait dit',
    'EL',
    $c$Objectif
Maîtriser rapporter une crise ; style indirect libre ; on aurait dit au registre C1, avec collocations et pièges de construction.

Consigne
Apprenez la fiche, puis produisez des exemples justes au registre demandé.

Support — Fiche d'Aline Uwase, banc ocre
Fiche C1 — rapporter une crise ; style indirect libre ; on aurait dit
On ne retient pas une liste : on retient des constructions et des collocations.
Encore que l'on rapporte, une table trop froide après la voix trop haute n'est pas un détail.
Rose Iradukunda concède que élever la voix arrive, pour autant que l'on revienne aux heures, au relais, au fer, pas à l'humiliation.
Autrement dit, rapporter un discours de crise, c'est garder les propos, signaler le ton, refuser le roman
Il ressort qu'un compte-rendu : ce qui a été dit, ce qui a été tu, ce que l'atelier peut décider
Piège : garder le présent du DD dans un DI au passé
Registre : soutenu argumentatif, sans slogan
Collocation : encore que, pour autant que, il ressort que
Ce que l'on nomme conflit, ici, n'est pas un slogan : désaccord de travail, à rapporter.
Rose a dit qu'elle garderait les propos, pas les insultes.
Aline : le style indirect libre peut montrer la fièvre, il ne doit pas l'inventer.
Nominaliser, ce n'est pas alourdir : c'est nommer le processus (la densification, l'accueil, le rappel).
Encore que / pour autant que / si tant est que : subjonctif, concession réelle, pas un ornement.
Reformuler une source : on change la syntaxe, on garde la charge, on signale le point de vue.
C1 : l'implicite se justifie. C2 : l'ironie se laisse entendre sans s'afficher.
Exemple fautif à ne plus produire : On va au relais pour de vrai genre, et Dieudonné Hakizimana demande un registre plus net.
Correction : On va au relais vraiment, et Dieudonné Hakizimana demande un registre plus net.
Aline Uwase, banc ocre — Le Seuil des Sources.
$c$,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Le discours indirect au passé décale souvent les temps.",
  "correct": true,
  "explanation": "Concordance."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Dans un discours indirect au passé, « je poserai » devient souvent…",
  "options": [
    {
      "text": "je poserai encore",
      "correct": false
    },
    {
      "text": "il poserait",
      "correct": true
    },
    {
      "text": "il a posé uniquement",
      "correct": false
    },
    {
      "text": "pose !",
      "correct": false
    }
  ],
  "explanation": "Futur → conditionnel dans le DI au passé."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "conflit",
      "right": "désaccord de travail, à rapporter"
    },
    {
      "left": "crise",
      "right": "moment trop tendu, pas une légende"
    },
    {
      "left": "relais",
      "right": "partage des heures, souvent l'enjeu"
    },
    {
      "left": "compte-rendu",
      "right": "texte factuel, sans héros"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nLe discours ___ n'est pas une sténographie : on change les temps. (rapporté)",
  "answer": "rapporté"
}$j$::jsonb,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Remettez les mots dans l''ordre',
    'word_order',
    $j${
  "words": [
    "Rapporter",
    "n'est",
    "pas",
    "sténographier",
    "."
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
  "sentence_with_error": "On va au relais pour de vrai genre, et Dieudonné Hakizimana demande un registre plus net.",
  "correct_sentence": "On va au relais vraiment, et Dieudonné Hakizimana demande un registre plus net.",
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
      "image_path": "/elearning/mfk-c1-m6/habitude-pro.svg",
      "word": "habitude pro"
    },
    {
      "image_path": "/elearning/mfk-c1-m6/valise-contrat.svg",
      "word": "valise contrat"
    },
    {
      "image_path": "/elearning/mfk-c1-m6/analyse-travail.svg",
      "word": "analyse travail"
    },
    {
      "image_path": "/elearning/mfk-c1-m6/cahier-temoins.svg",
      "word": "cahier temoins"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Tableau de langue : six exemples justes de « rapporter une crise ; style indirect libre ; on aurait dit » et deux pièges commentés."
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

  -- ===== Là-bas n'est pas une morale =====
  SELECT s.id INTO v_seq_id
  FROM elearning_sequences s
  WHERE s.module_id = v_module_id AND s.title = 'Là-bas n''est pas une morale'
  LIMIT 1;

  IF v_seq_id IS NULL THEN
    INSERT INTO elearning_sequences (module_id, title, order_index)
    VALUES (v_module_id, 'Là-bas n''est pas une morale', 3)
    RETURNING id INTO v_seq_id;
  ELSE
    UPDATE elearning_sequences
    SET order_index = 3
    WHERE id = v_seq_id;
  END IF;

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CO — Là-bas n''est pas une morale',
    'CO',
    $c$Objectif
Comprendre un échange long et en extraire l'implicite. Présenter des départs et des ailleurs inventés, sans mirage. Viser la nuance, la collocation et l'implicite.

Consigne
Lisez le débat (à écouter avec l'enseignant). Qu'est-ce qui est dit, qu'est-ce qui reste implicite, qui concède quoi ?

Support — Débat Radio Figuier — Là-bas n'est pas une morale
Lila Sow : Radio Figuier. On parle trop vite de les ailleurs trop brillants, comme si le mot dispensait d'en examiner le prix.
Marc Nkurunziza : Encore que l'on efface le Seuil d'un revers de valise, une promesse d'heures plus douces jamais datée n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Léa Niyonzima : Karim Bamba concède que partir peut être juste, pour autant que l'on n'humilie pas ceux qui restent, ni ceux qui reviennent.
Aline Uwase : Ce que l'on nomme ailleurs, ici, n'est pas un slogan : lieu projeté, parfois un mirage.
Patrick Habimana : Karim : encore que l'on promette des heures plus douces, le contrat n'était pas dans la lettre.
Hawa Diallo : Hawa est partie, revenue, sans devoir choisir un camp.
Joël Mugisha : Joël reste, et ce n'est pas un échec.
Rose Iradukunda : Aline refuse le mot eldorado collé comme une insulte.
Solange Mukamana : Rose a cousu pour un départ, puis pour un retour.
Karim Bamba : Lila recueillera les trois voix.
Félicie Ndayishimiye : Un chiffre, une trace : Trois lettres ; une valise trop légère ; zéro contrat lu jusqu'au bout dans le récit trop brillant.
Dieudonné Hakizimana : L'enjeu n'est pas d'avoir raison plus fort : il s'agit de parler d'ailleurs sans faire du Seuil une honte
Yvette : Yvette : là-bas c'est mieux n'est pas une analyse.
Mado : Hawa Diallo entend, dans « là-bas c'est mieux », ceci qui n'est pas dit : là-bas c'est mieux sert trop souvent à ne plus améliorer ici
Sami : Autrement dit, encore que l'ailleurs attire, le Seuil a des heures à réparer
Lila Sow : Je reformule pour les auditeurs. La proposition qui reste debout est celle-ci : recueillir trois témoignages : parti, resté, revenu, sans podium
Nina Kayitesi : Marc : intégrer des témoignages, c'est refuser le podium.
Lila Sow : Nous clôturons sans clore. Nous clôturons sans fusionner les voix : les lettres d'ailleurs inventées d'un côté, les voix du banc de l'autre, et le point où elles refusent de se ressembler.
$c$,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "une promesse d'heures plus douces jamais datée est présenté comme un simple détail sans conséquence.",
  "correct": false,
  "explanation": "Le texte affirme au contraire que une promesse d'heures plus douces jamais datée n'est pas un détail."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Selon Hawa Diallo, que reste-t-il implicite dans « là-bas c'est mieux » ?",
  "options": [
    {
      "text": "Que Karim a vendu des valises",
      "correct": false
    },
    {
      "text": "Ne plus améliorer ici",
      "correct": true
    },
    {
      "text": "Que Hawa méprise ceux qui partent",
      "correct": false
    },
    {
      "text": "Que le Seuil interdit tout départ",
      "correct": false
    }
  ],
  "explanation": "là-bas c'est mieux sert trop souvent à ne plus améliorer ici"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "ailleurs",
      "right": "lieu projeté, parfois un mirage"
    },
    {
      "left": "contrat",
      "right": "texte à lire, plus que la valise"
    },
    {
      "left": "témoignage",
      "right": "voix d'un parcours, sans podium"
    },
    {
      "left": "habitude",
      "right": "pratique professionnelle, variable selon les rives"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nEncore que l'on ___ , une promesse d'heures plus douces jamais datée n'est pas un détail. (partir, subj.)",
  "answer": "parte"
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
    "parte",
    "la",
    "lumière",
    "ailleurs",
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
  "word": "ailleurs",
  "hint": "lieu projeté, parfois un mirage"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Encore que l'on partir trop vite, une promesse d'heures plus douces jamais datée n'est pas un détail, et Karim Bamba écoute.",
  "correct_sentence": "Encore que l'on parte trop vite, une promesse d'heures plus douces jamais datée n'est pas un détail, et Karim Bamba écoute.",
  "explanation": "Après encore que : parte."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-c1-m6/valise-contrat.svg",
      "word": "valise contrat"
    },
    {
      "image_path": "/elearning/mfk-c1-m6/analyse-travail.svg",
      "word": "analyse travail"
    },
    {
      "image_path": "/elearning/mfk-c1-m6/cahier-temoins.svg",
      "word": "cahier temoins"
    },
    {
      "image_path": "/elearning/mfk-c1-m6/micro-emploi.svg",
      "word": "micro emploi"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Reformulez l'implicite de « là-bas c'est mieux » et la concession de Karim Bamba."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez une synthèse d'environ quatre-vingt-dix secondes : deux points de vue, un implicite, une proposition. Gardez les lettres d'ailleurs inventées et les voix du banc distincts."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CE — Là-bas n''est pas une morale',
    'CE',
    $c$Objectif
Lire un texte argumenté long, synthétiser et reformuler. Présenter des départs et des ailleurs inventés, sans mirage. Viser la nuance, la collocation et l'implicite.

Consigne
Lisez « Là-bas n'est pas une morale », sans aller trop vite. Repérez la thèse, la concession, l'implicite et la proposition.

Support — Là-bas n'est pas une morale
On parle trop vite de les ailleurs trop brillants, comme si le mot dispensait d'en examiner le prix.
Encore que l'on efface le Seuil d'un revers de valise, une promesse d'heures plus douces jamais datée n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Karim Bamba concède que partir peut être juste, pour autant que l'on n'humilie pas ceux qui restent, ni ceux qui reviennent.
Ce que l'on nomme ailleurs, ici, n'est pas un slogan : lieu projeté, parfois un mirage.
Karim : encore que l'on promette des heures plus douces, le contrat n'était pas dans la lettre.
Hawa est partie, revenue, sans devoir choisir un camp.
Joël reste, et ce n'est pas un échec.
Aline refuse le mot eldorado collé comme une insulte.
Rose a cousu pour un départ, puis pour un retour.
Lila recueillera les trois voix.
Un chiffre, une trace : Trois lettres ; une valise trop légère ; zéro contrat lu jusqu'au bout dans le récit trop brillant.
L'enjeu n'est pas d'avoir raison plus fort : il s'agit de parler d'ailleurs sans faire du Seuil une honte
Yvette : là-bas c'est mieux n'est pas une analyse.
Hawa Diallo entend, dans « là-bas c'est mieux », ceci qui n'est pas dit : là-bas c'est mieux sert trop souvent à ne plus améliorer ici
Autrement dit, encore que l'ailleurs attire, le Seuil a des heures à réparer
La proposition qui reste debout est celle-ci : recueillir trois témoignages : parti, resté, revenu, sans podium
Marc : intégrer des témoignages, c'est refuser le podium.
Nous clôturons sans fusionner les voix : les lettres d'ailleurs inventées d'un côté, les voix du banc de l'autre, et le point où elles refusent de se ressembler.
Signé : Karim Bamba, Rukiri-Nord — Cahier des racines, Rukiri-Nord.
$c$,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Le texte refuse de fusionner les lettres d'ailleurs inventées et les voix du banc en une seule affiche.",
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
      "text": "Trois lettres, une valise légère, zéro contrat lu au bout",
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
  "explanation": "Trois lettres ; une valise trop légère ; zéro contrat lu jusqu'au bout dans le récit trop brillant."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "ailleurs",
      "right": "lieu projeté, parfois un mirage"
    },
    {
      "left": "contrat",
      "right": "texte à lire, plus que la valise"
    },
    {
      "left": "témoignage",
      "right": "voix d'un parcours, sans podium"
    },
    {
      "left": "habitude",
      "right": "pratique professionnelle, variable selon les rives"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nLa ___ n'est un abri que si l'on en parle vraiment. (ailleurs déjà nom ou verbe à nominaliser)",
  "answer": "ailleurs"
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
    "ailleurs",
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
  "word": "contrat",
  "hint": "texte à lire, plus que la valise"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "La ailleurs de trop vite n'aide personne, et Hawa Diallo reprend le fil.",
  "correct_sentence": "La précipitation n'aide personne, et Hawa Diallo reprend le fil.",
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
      "image_path": "/elearning/mfk-c1-m6/analyse-travail.svg",
      "word": "analyse travail"
    },
    {
      "image_path": "/elearning/mfk-c1-m6/cahier-temoins.svg",
      "word": "cahier temoins"
    },
    {
      "image_path": "/elearning/mfk-c1-m6/micro-emploi.svg",
      "word": "micro emploi"
    },
    {
      "image_path": "/elearning/mfk-c1-m6/balance-salaire.svg",
      "word": "balance salaire"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Synthétisez « Là-bas n'est pas une morale » : thèse, concession, implicite, proposition (quinze lignes)."
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
    'PO — Là-bas n''est pas une morale : dire sans slogan',
    'PO',
    $c$Objectif
Produire un oral structuré (thèse, concession, proposition). Point : concession ; hypothèse ; habitudes professionnelles ailleurs.

Consigne
Répétez les modèles, puis prenez position en une minute : thèse, concession, reformulation, proposition.

Support — Modèles d'Aline Uwase, banc du figuier
Encore que l'on efface le Seuil d'un revers de valise, une promesse d'heures plus douces jamais datée n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Karim Bamba concède que partir peut être juste, pour autant que l'on n'humilie pas ceux qui restent, ni ceux qui reviennent.
Ce que l'on nomme ailleurs, ici, n'est pas un slogan : lieu projeté, parfois un mirage.
Encore que l'on parte, une promesse d'heures plus douces jamais datée n'est pas un détail.
Karim Bamba concède que partir peut être juste, pour autant que l'on n'humilie pas ceux qui restent, ni ceux qui reviennent.
Autrement dit, encore que l'ailleurs attire, le Seuil a des heures à réparer
Il ressort que recueillir trois témoignages : parti, resté, revenu, sans podium
Hawa est partie, revenue, sans devoir choisir un camp.
Rose a cousu pour un départ, puis pour un retour.
La proposition qui reste debout est celle-ci : recueillir trois témoignages : parti, resté, revenu, sans podium
Je concède le point, je n'abandonne pas la proposition.
Ce n'est pas que je refuse : c'est que je refuse qu'on nomme cela un détail.
Autrement dit, l'implicite fait autant de travail que la thèse.
En une minute : fait, angle, concession, proposition.
Nous clôturons sans fusionner les voix : les lettres d'ailleurs inventées d'un côté, les voix du banc de l'autre, et le point où elles refusent de se ressembler.
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
  "explanation": "Karim Bamba concède que partir peut être juste, pour autant que l'on n'humilie pas ceux qui restent, ni ceux qui reviennent."
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
      "text": "partir peut être juste — à condition que l'on n'humilie pas ceux qui restent, ni ceux qui reviennent",
      "correct": true
    },
    {
      "text": "Karim Bamba abandonne il s'agit de parler d'ailleurs sans faire du Seuil une honte",
      "correct": false
    },
    {
      "text": "La concession vaut acceptation du slogan",
      "correct": false
    }
  ],
  "explanation": "Concession réelle, pas un abandon : l'on n'humilie pas ceux qui restent, ni ceux qui reviennent"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "ailleurs",
      "right": "lieu projeté, parfois un mirage"
    },
    {
      "left": "contrat",
      "right": "texte à lire, plus que la valise"
    },
    {
      "left": "témoignage",
      "right": "voix d'un parcours, sans podium"
    },
    {
      "left": "habitude",
      "right": "pratique professionnelle, variable selon les rives"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nPour autant que l'on ___ , Karim concède un point. (partir, subj.)",
  "answer": "parte"
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
    "habitude",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "témoignage",
  "hint": "voix d'un parcours, sans podium"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Karim Bamba écoute encore, et il fautons partir avant de crier.",
  "correct_sentence": "Karim Bamba écoute encore, et il faut partir avant de crier.",
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
      "image_path": "/elearning/mfk-c1-m6/cahier-temoins.svg",
      "word": "cahier temoins"
    },
    {
      "image_path": "/elearning/mfk-c1-m6/micro-emploi.svg",
      "word": "micro emploi"
    },
    {
      "image_path": "/elearning/mfk-c1-m6/balance-salaire.svg",
      "word": "balance salaire"
    },
    {
      "image_path": "/elearning/mfk-c1-m6/motion-bureau.svg",
      "word": "motion bureau"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Écrivez six phrases orales justes : deux sur concession ; hypothèse ; habitudes professionnelles ailleurs, deux concessions, deux propositions."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez quatre modèles, puis votre prise de position (thèse, concession, proposition). Gardez les lettres d'ailleurs inventées et les voix du banc distincts."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PE — le texte de Karim Bamba',
    'PE',
    $c$Objectif
Écrire un texte long et structuré. Présenter des départs et des ailleurs inventés, sans mirage. Point : concession ; hypothèse ; habitudes professionnelles ailleurs.

Consigne
Imitez le texte de Karim Bamba.

Support — Karim Bamba — Là-bas n'est pas une morale
Karim Bamba — Là-bas n'est pas une morale
On parle trop vite de les ailleurs trop brillants, comme si le mot dispensait d'en examiner le prix.
Encore que l'on efface le Seuil d'un revers de valise, une promesse d'heures plus douces jamais datée n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Karim Bamba concède que partir peut être juste, pour autant que l'on n'humilie pas ceux qui restent, ni ceux qui reviennent.
Ce que l'on nomme ailleurs, ici, n'est pas un slogan : lieu projeté, parfois un mirage.
Karim : encore que l'on promette des heures plus douces, le contrat n'était pas dans la lettre.
Rose a cousu pour un départ, puis pour un retour.
Lila recueillera les trois voix.
Yvette : là-bas c'est mieux n'est pas une analyse.
La proposition qui reste debout est celle-ci : recueillir trois témoignages : parti, resté, revenu, sans podium
Marc : intégrer des témoignages, c'est refuser le podium.
Nous clôturons sans fusionner les voix : les lettres d'ailleurs inventées d'un côté, les voix du banc de l'autre, et le point où elles refusent de se ressembler.
Encore que l'on parte, une promesse d'heures plus douces jamais datée n'est pas un détail.
Karim Bamba concède que partir peut être juste, pour autant que l'on n'humilie pas ceux qui restent, ni ceux qui reviennent.
Je n'écris pas pour vaincre : j'écris pour que la cour puisse relire.
encore que l'ailleurs attire, le Seuil a des heures à réparer
Karim Bamba, Rukiri-Nord
$c$,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "La proposition retenue est : recueillir trois témoignages : parti, resté, revenu, sans podium",
  "correct": true,
  "explanation": "recueillir trois témoignages : parti, resté, revenu, sans podium"
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
      "text": "recueillir trois témoignages : parti, resté, revenu, sans podium",
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
  "explanation": "recueillir trois témoignages : parti, resté, revenu, sans podium"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "ailleurs",
      "right": "lieu projeté, parfois un mirage"
    },
    {
      "left": "contrat",
      "right": "texte à lire, plus que la valise"
    },
    {
      "left": "témoignage",
      "right": "voix d'un parcours, sans podium"
    },
    {
      "left": "habitude",
      "right": "pratique professionnelle, variable selon les rives"
    }
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
  "word": "habitude",
  "hint": "pratique professionnelle, variable selon les rives"
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
      "image_path": "/elearning/mfk-c1-m6/micro-emploi.svg",
      "word": "micro emploi"
    },
    {
      "image_path": "/elearning/mfk-c1-m6/balance-salaire.svg",
      "word": "balance salaire"
    },
    {
      "image_path": "/elearning/mfk-c1-m6/motion-bureau.svg",
      "word": "motion bureau"
    },
    {
      "image_path": "/elearning/mfk-c1-m6/tampon-offre.svg",
      "word": "tampon offre"
    }
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
    'EL — concession ; hypothèse ; habitudes professionnelles ailleurs',
    'EL',
    $c$Objectif
Maîtriser concession ; hypothèse ; habitudes professionnelles ailleurs au registre C1, avec collocations et pièges de construction.

Consigne
Apprenez la fiche, puis produisez des exemples justes au registre demandé.

Support — Fiche d'Aline Uwase, banc ocre
Fiche C1 — concession ; hypothèse ; habitudes professionnelles ailleurs
On ne retient pas une liste : on retient des constructions et des collocations.
Encore que l'on parte, une promesse d'heures plus douces jamais datée n'est pas un détail.
Karim Bamba concède que partir peut être juste, pour autant que l'on n'humilie pas ceux qui restent, ni ceux qui reviennent.
Autrement dit, encore que l'ailleurs attire, le Seuil a des heures à réparer
Il ressort que recueillir trois témoignages : parti, resté, revenu, sans podium
Piège : indicatif après encore que
Registre : soutenu argumentatif, sans slogan
Collocation : encore que, pour autant que, il ressort que
Ce que l'on nomme ailleurs, ici, n'est pas un slogan : lieu projeté, parfois un mirage.
Hawa est partie, revenue, sans devoir choisir un camp.
Rose a cousu pour un départ, puis pour un retour.
Nominaliser, ce n'est pas alourdir : c'est nommer le processus (la densification, l'accueil, le rappel).
Encore que / pour autant que / si tant est que : subjonctif, concession réelle, pas un ornement.
Reformuler une source : on change la syntaxe, on garde la charge, on signale le point de vue.
C1 : l'implicite se justifie. C2 : l'ironie se laisse entendre sans s'afficher.
Exemple fautif à ne plus produire : On va au témoignage pour de vrai genre, et Hawa Diallo demande un registre plus net.
Correction : On va au témoignage vraiment, et Hawa Diallo demande un registre plus net.
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
      "left": "ailleurs",
      "right": "lieu projeté, parfois un mirage"
    },
    {
      "left": "contrat",
      "right": "texte à lire, plus que la valise"
    },
    {
      "left": "témoignage",
      "right": "voix d'un parcours, sans podium"
    },
    {
      "left": "habitude",
      "right": "pratique professionnelle, variable selon les rives"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nOn dira la ___ plutôt qu'un slogan. (nom de contrat)",
  "answer": "contrat"
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
    "parte",
    "Karim",
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
  "sentence_with_error": "On va au témoignage pour de vrai genre, et Hawa Diallo demande un registre plus net.",
  "correct_sentence": "On va au témoignage vraiment, et Hawa Diallo demande un registre plus net.",
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
      "image_path": "/elearning/mfk-c1-m6/balance-salaire.svg",
      "word": "balance salaire"
    },
    {
      "image_path": "/elearning/mfk-c1-m6/motion-bureau.svg",
      "word": "motion bureau"
    },
    {
      "image_path": "/elearning/mfk-c1-m6/tampon-offre.svg",
      "word": "tampon offre"
    },
    {
      "image_path": "/elearning/mfk-c1-m6/equipe-rive.svg",
      "word": "equipe rive"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Tableau de langue : six exemples justes de « concession ; hypothèse ; habitudes professionnelles ailleurs » et deux pièges commentés."
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

  -- ===== Témoignages croisés =====
  SELECT s.id INTO v_seq_id
  FROM elearning_sequences s
  WHERE s.module_id = v_module_id AND s.title = 'Témoignages croisés'
  LIMIT 1;

  IF v_seq_id IS NULL THEN
    INSERT INTO elearning_sequences (module_id, title, order_index)
    VALUES (v_module_id, 'Témoignages croisés', 4)
    RETURNING id INTO v_seq_id;
  ELSE
    UPDATE elearning_sequences
    SET order_index = 4
    WHERE id = v_seq_id;
  END IF;

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CO — Témoignages croisés',
    'CO',
    $c$Objectif
Comprendre un échange long et en extraire l'implicite. Intégrer des témoignages dans une analyse du travail au Seuil. Viser la nuance, la collocation et l'implicite.

Consigne
Lisez le débat (à écouter avec l'enseignant). Qu'est-ce qui est dit, qu'est-ce qui reste implicite, qui concède quoi ?

Support — Débat Radio Figuier — Témoignages croisés
Lila Sow : Radio Figuier. On parle trop vite de les voix croisées de l'atelier et de la radio, comme si le mot dispensait d'en examiner le prix.
Marc Nkurunziza : Encore que l'on lisse les citations jusqu'au consensus faux, une analyse sans aspérités n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Léa Niyonzima : Marc Nkurunziza concède que trouver un point commun aide, pour autant que l'on garde les phrases qui gênent.
Aline Uwase : Ce que l'on nomme citation, ici, n'est pas un slogan : parole attribuée, non fondue.
Patrick Habimana : Rose a déclaré que les mains manquaient dans les unes.
Hawa Diallo : Joël a dit qu'il reviendrait si le relais tenait.
Joël Mugisha : Lila a demandé si l'on pouvait garder le doute à l'antenne.
Rose Iradukunda : Aline : intégrer n'est pas fondre.
Solange Mukamana : Karim ajoute un chiffre, pas un verdict.
Karim Bamba : Patrick relit les aspérités.
Félicie Ndayishimiye : Un chiffre, une trace : Marc a cité Rose, Joël, Lila ; gardé deux frictions ; refusé un tous d'accord final.
Dieudonné Hakizimana : L'enjeu n'est pas d'avoir raison plus fort : il s'agit que l'analyse ressemble au travail réel, pas à une brochure
Yvette : Dieudonné signe le relais proposé.
Mado : Rose Iradukunda entend, dans « on a tous le même avis », ceci qui n'est pas dit : on a tous le même avis est le contraire d'une enquête
Sami : Autrement dit, intégrer, c'est citer, attribuer, commenter, pas fondre
Lila Sow : Je reformule pour les auditeurs. La proposition qui reste debout est celle-ci : une analyse : trois citations, deux frictions, une proposition de relais
Nina Kayitesi : Marc : une analyse du travail au Seuil se juge à ce qu'elle n'a pas gommé.
Lila Sow : Nous clôturons sans clore. Nous clôturons sans fusionner les voix : les témoignages bruts d'un côté, l'analyse de Marc de l'autre, et le point où elles refusent de se ressembler.
$c$,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "une analyse sans aspérités est présenté comme un simple détail sans conséquence.",
  "correct": false,
  "explanation": "Le texte affirme au contraire que une analyse sans aspérités n'est pas un détail."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Selon Rose Iradukunda, que reste-t-il implicite dans « on a tous le même avis » ?",
  "options": [
    {
      "text": "Que Marc a lissé Rose",
      "correct": false
    },
    {
      "text": "Le contraire d'une enquête",
      "correct": true
    },
    {
      "text": "Que Joël a refusé d'être cité",
      "correct": false
    },
    {
      "text": "Que Lila a exigé un consensus",
      "correct": false
    }
  ],
  "explanation": "on a tous le même avis est le contraire d'une enquête"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "citation",
      "right": "parole attribuée, non fondue"
    },
    {
      "left": "analyse",
      "right": "texte qui commente les voix"
    },
    {
      "left": "friction",
      "right": "désaccord conservé"
    },
    {
      "left": "enquête",
      "right": "écoute structurée, pas un avis unique"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nJoël a dit qu'il ___ le casque dès l'aube. (poser, cond. du DI passé)",
  "answer": "poserait"
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
    "a",
    "dit",
    "qu'il",
    "poserait",
    "le",
    "casque",
    "dès",
    "l'aube",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "citation",
  "hint": "parole attribuée, non fondue"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Joël a dit qu'il posera le casque dès l'aube, et Marc Nkurunziza prend des notes.",
  "correct_sentence": "Joël a dit qu'il poserait le casque dès l'aube, et Marc Nkurunziza prend des notes.",
  "explanation": "DI au passé : poserait."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-c1-m6/motion-bureau.svg",
      "word": "motion bureau"
    },
    {
      "image_path": "/elearning/mfk-c1-m6/tampon-offre.svg",
      "word": "tampon offre"
    },
    {
      "image_path": "/elearning/mfk-c1-m6/equipe-rive.svg",
      "word": "equipe rive"
    },
    {
      "image_path": "/elearning/mfk-c1-m6/casque-joel.svg",
      "word": "casque joel"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Reformulez l'implicite de « on a tous le même avis » et la concession de Marc Nkurunziza."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez une synthèse d'environ quatre-vingt-dix secondes : deux points de vue, un implicite, une proposition. Gardez les témoignages bruts et l'analyse de Marc distincts."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CE — Garder ce qui gêne',
    'CE',
    $c$Objectif
Lire un texte argumenté long, synthétiser et reformuler. Intégrer des témoignages dans une analyse du travail au Seuil. Viser la nuance, la collocation et l'implicite.

Consigne
Lisez « Garder ce qui gêne », sans aller trop vite. Repérez la thèse, la concession, l'implicite et la proposition.

Support — Garder ce qui gêne
On parle trop vite de les voix croisées de l'atelier et de la radio, comme si le mot dispensait d'en examiner le prix.
Encore que l'on lisse les citations jusqu'au consensus faux, une analyse sans aspérités n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Marc Nkurunziza concède que trouver un point commun aide, pour autant que l'on garde les phrases qui gênent.
Ce que l'on nomme citation, ici, n'est pas un slogan : parole attribuée, non fondue.
Rose a déclaré que les mains manquaient dans les unes.
Joël a dit qu'il reviendrait si le relais tenait.
Lila a demandé si l'on pouvait garder le doute à l'antenne.
Aline : intégrer n'est pas fondre.
Karim ajoute un chiffre, pas un verdict.
Patrick relit les aspérités.
Un chiffre, une trace : Marc a cité Rose, Joël, Lila ; gardé deux frictions ; refusé un tous d'accord final.
L'enjeu n'est pas d'avoir raison plus fort : il s'agit que l'analyse ressemble au travail réel, pas à une brochure
Dieudonné signe le relais proposé.
Rose Iradukunda entend, dans « on a tous le même avis », ceci qui n'est pas dit : on a tous le même avis est le contraire d'une enquête
Autrement dit, intégrer, c'est citer, attribuer, commenter, pas fondre
La proposition qui reste debout est celle-ci : une analyse : trois citations, deux frictions, une proposition de relais
Marc : une analyse du travail au Seuil se juge à ce qu'elle n'a pas gommé.
Nous clôturons sans fusionner les voix : les témoignages bruts d'un côté, l'analyse de Marc de l'autre, et le point où elles refusent de se ressembler.
Signé : Marc Nkurunziza, Rukiri-Nord — Cahier des racines, Rukiri-Nord.
$c$,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Le texte refuse de fusionner les témoignages bruts et l'analyse de Marc en une seule affiche.",
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
      "text": "Trois citations, deux frictions, zéro tous d'accord",
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
  "explanation": "Marc a cité Rose, Joël, Lila ; gardé deux frictions ; refusé un tous d'accord final."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "citation",
      "right": "parole attribuée, non fondue"
    },
    {
      "left": "analyse",
      "right": "texte qui commente les voix"
    },
    {
      "left": "friction",
      "right": "désaccord conservé"
    },
    {
      "left": "enquête",
      "right": "écoute structurée, pas un avis unique"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nRose a demandé si l'on ___ les mains dans l'accroche. (nommer, imp.)",
  "answer": "nommait"
}$j$::jsonb,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Remettez les mots dans l''ordre',
    'word_order',
    $j${
  "words": [
    "Rose",
    "a",
    "demandé",
    "si",
    "l'on",
    "nommait",
    "les",
    "mains",
    "dans",
    "l'accroche",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "analyse",
  "hint": "texte qui commente les voix"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "La citation de trop vite n'aide personne, et Rose Iradukunda reprend le fil.",
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
      "image_path": "/elearning/mfk-c1-m6/tampon-offre.svg",
      "word": "tampon offre"
    },
    {
      "image_path": "/elearning/mfk-c1-m6/equipe-rive.svg",
      "word": "equipe rive"
    },
    {
      "image_path": "/elearning/mfk-c1-m6/casque-joel.svg",
      "word": "casque joel"
    },
    {
      "image_path": "/elearning/mfk-c1-m6/radio-travail.svg",
      "word": "radio travail"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Synthétisez « Garder ce qui gêne » : thèse, concession, implicite, proposition (quinze lignes)."
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
    'PO — Témoignages croisés : dire sans slogan',
    'PO',
    $c$Objectif
Produire un oral structuré (thèse, concession, proposition). Point : intégrer des citations ; il a déclaré que ; nuance.

Consigne
Répétez les modèles, puis prenez position en une minute : thèse, concession, reformulation, proposition.

Support — Modèles d'Aline Uwase, banc du figuier
Encore que l'on lisse les citations jusqu'au consensus faux, une analyse sans aspérités n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Marc Nkurunziza concède que trouver un point commun aide, pour autant que l'on garde les phrases qui gênent.
Ce que l'on nomme citation, ici, n'est pas un slogan : parole attribuée, non fondue.
Encore que l'on cite, une analyse sans aspérités n'est pas un détail.
Marc Nkurunziza concède que trouver un point commun aide, pour autant que l'on garde les phrases qui gênent.
Autrement dit, intégrer, c'est citer, attribuer, commenter, pas fondre
Il ressort qu'une analyse : trois citations, deux frictions, une proposition de relais
Joël a dit qu'il reviendrait si le relais tenait.
Karim ajoute un chiffre, pas un verdict.
La proposition qui reste debout est celle-ci : une analyse : trois citations, deux frictions, une proposition de relais
Je concède le point, je n'abandonne pas la proposition.
Ce n'est pas que je refuse : c'est que je refuse qu'on nomme cela un détail.
Autrement dit, l'implicite fait autant de travail que la thèse.
En une minute : fait, angle, concession, proposition.
Nous clôturons sans fusionner les voix : les témoignages bruts d'un côté, l'analyse de Marc de l'autre, et le point où elles refusent de se ressembler.
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
  "explanation": "Marc Nkurunziza concède que trouver un point commun aide, pour autant que l'on garde les phrases qui gênent."
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
      "text": "trouver un point commun aide — à condition que l'on garde les phrases qui gênent",
      "correct": true
    },
    {
      "text": "Marc Nkurunziza abandonne il s'agit que l'analyse ressemble au travail réel, pas à une brochure",
      "correct": false
    },
    {
      "text": "La concession vaut acceptation du slogan",
      "correct": false
    }
  ],
  "explanation": "Concession réelle, pas un abandon : l'on garde les phrases qui gênent"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "citation",
      "right": "parole attribuée, non fondue"
    },
    {
      "left": "analyse",
      "right": "texte qui commente les voix"
    },
    {
      "left": "friction",
      "right": "désaccord conservé"
    },
    {
      "left": "enquête",
      "right": "écoute structurée, pas un avis unique"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nKarim a prétendu que les heures ___ déjà trop longues. (être, imp.)",
  "answer": "étaient"
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
    "prétendu",
    "que",
    "les",
    "heures",
    "étaient",
    "déjà",
    "trop",
    "longues",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "friction",
  "hint": "désaccord conservé"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Marc Nkurunziza écoute encore, et il fautons citer avant de crier.",
  "correct_sentence": "Marc Nkurunziza écoute encore, et il faut citer avant de crier.",
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
      "image_path": "/elearning/mfk-c1-m6/equipe-rive.svg",
      "word": "equipe rive"
    },
    {
      "image_path": "/elearning/mfk-c1-m6/casque-joel.svg",
      "word": "casque joel"
    },
    {
      "image_path": "/elearning/mfk-c1-m6/radio-travail.svg",
      "word": "radio travail"
    },
    {
      "image_path": "/elearning/mfk-c1-m6/soleil-poste.svg",
      "word": "soleil poste"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Écrivez six phrases orales justes : deux sur intégrer des citations ; il a déclaré que ; nuance, deux concessions, deux propositions."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez quatre modèles, puis votre prise de position (thèse, concession, proposition). Gardez les témoignages bruts et l'analyse de Marc distincts."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PE — le texte de Marc Nkurunziza',
    'PE',
    $c$Objectif
Écrire un texte long et structuré. Intégrer des témoignages dans une analyse du travail au Seuil. Point : intégrer des citations ; il a déclaré que ; nuance.

Consigne
Imitez le texte de Marc Nkurunziza.

Support — Marc Nkurunziza — Garder ce qui gêne
Marc Nkurunziza — Garder ce qui gêne
On parle trop vite de les voix croisées de l'atelier et de la radio, comme si le mot dispensait d'en examiner le prix.
Encore que l'on lisse les citations jusqu'au consensus faux, une analyse sans aspérités n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Marc Nkurunziza concède que trouver un point commun aide, pour autant que l'on garde les phrases qui gênent.
Ce que l'on nomme citation, ici, n'est pas un slogan : parole attribuée, non fondue.
Rose a déclaré que les mains manquaient dans les unes.
Karim ajoute un chiffre, pas un verdict.
Patrick relit les aspérités.
Dieudonné signe le relais proposé.
La proposition qui reste debout est celle-ci : une analyse : trois citations, deux frictions, une proposition de relais
Marc : une analyse du travail au Seuil se juge à ce qu'elle n'a pas gommé.
Nous clôturons sans fusionner les voix : les témoignages bruts d'un côté, l'analyse de Marc de l'autre, et le point où elles refusent de se ressembler.
Encore que l'on cite, une analyse sans aspérités n'est pas un détail.
Marc Nkurunziza concède que trouver un point commun aide, pour autant que l'on garde les phrases qui gênent.
Je n'écris pas pour vaincre : j'écris pour que la cour puisse relire.
intégrer, c'est citer, attribuer, commenter, pas fondre
Marc Nkurunziza, Rukiri-Nord
$c$,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "La proposition retenue est : une analyse : trois citations, deux frictions, une proposition de relais",
  "correct": true,
  "explanation": "une analyse : trois citations, deux frictions, une proposition de relais"
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
      "text": "une analyse : trois citations, deux frictions, une proposition de relais",
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
  "explanation": "une analyse : trois citations, deux frictions, une proposition de relais"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "citation",
      "right": "parole attribuée, non fondue"
    },
    {
      "left": "analyse",
      "right": "texte qui commente les voix"
    },
    {
      "left": "friction",
      "right": "désaccord conservé"
    },
    {
      "left": "enquête",
      "right": "écoute structurée, pas un avis unique"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nLila a exigé que l'on ___ les insultes. (citer, subj.)",
  "answer": "cite"
}$j$::jsonb,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Remettez les mots dans l''ordre',
    'word_order',
    $j${
  "words": [
    "Lila",
    "a",
    "exigé",
    "que",
    "l'on",
    "cite",
    "les",
    "insultes",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "enquête",
  "hint": "écoute structurée, pas un avis unique"
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
      "image_path": "/elearning/mfk-c1-m6/casque-joel.svg",
      "word": "casque joel"
    },
    {
      "image_path": "/elearning/mfk-c1-m6/radio-travail.svg",
      "word": "radio travail"
    },
    {
      "image_path": "/elearning/mfk-c1-m6/soleil-poste.svg",
      "word": "soleil poste"
    },
    {
      "image_path": "/elearning/mfk-c1-m6/nuage-crise.svg",
      "word": "nuage crise"
    }
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
    'EL — intégrer des citations ; il a déclaré que ; nuance',
    'EL',
    $c$Objectif
Maîtriser intégrer des citations ; il a déclaré que ; nuance au registre C1, avec collocations et pièges de construction.

Consigne
Apprenez la fiche, puis produisez des exemples justes au registre demandé.

Support — Fiche d'Aline Uwase, banc ocre
Fiche C1 — intégrer des citations ; il a déclaré que ; nuance
On ne retient pas une liste : on retient des constructions et des collocations.
Encore que l'on cite, une analyse sans aspérités n'est pas un détail.
Marc Nkurunziza concède que trouver un point commun aide, pour autant que l'on garde les phrases qui gênent.
Autrement dit, intégrer, c'est citer, attribuer, commenter, pas fondre
Il ressort qu'une analyse : trois citations, deux frictions, une proposition de relais
Piège : garder le présent du DD dans un DI au passé
Registre : soutenu argumentatif, sans slogan
Collocation : encore que, pour autant que, il ressort que
Ce que l'on nomme citation, ici, n'est pas un slogan : parole attribuée, non fondue.
Joël a dit qu'il reviendrait si le relais tenait.
Karim ajoute un chiffre, pas un verdict.
Nominaliser, ce n'est pas alourdir : c'est nommer le processus (la densification, l'accueil, le rappel).
Encore que / pour autant que / si tant est que : subjonctif, concession réelle, pas un ornement.
Reformuler une source : on change la syntaxe, on garde la charge, on signale le point de vue.
C1 : l'implicite se justifie. C2 : l'ironie se laisse entendre sans s'afficher.
Exemple fautif à ne plus produire : On va au friction pour de vrai genre, et Rose Iradukunda demande un registre plus net.
Correction : On va au friction vraiment, et Rose Iradukunda demande un registre plus net.
Aline Uwase, banc ocre — Le Seuil des Sources.
$c$,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Le discours indirect au passé décale souvent les temps.",
  "correct": true,
  "explanation": "Concordance."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Dans un discours indirect au passé, « je poserai » devient souvent…",
  "options": [
    {
      "text": "je poserai encore",
      "correct": false
    },
    {
      "text": "il poserait",
      "correct": true
    },
    {
      "text": "il a posé uniquement",
      "correct": false
    },
    {
      "text": "pose !",
      "correct": false
    }
  ],
  "explanation": "Futur → conditionnel dans le DI au passé."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "citation",
      "right": "parole attribuée, non fondue"
    },
    {
      "left": "analyse",
      "right": "texte qui commente les voix"
    },
    {
      "left": "friction",
      "right": "désaccord conservé"
    },
    {
      "left": "enquête",
      "right": "écoute structurée, pas un avis unique"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nLe discours ___ n'est pas une sténographie : on change les temps. (rapporté)",
  "answer": "rapporté"
}$j$::jsonb,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Remettez les mots dans l''ordre',
    'word_order',
    $j${
  "words": [
    "Rapporter",
    "n'est",
    "pas",
    "sténographier",
    "."
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
  "sentence_with_error": "On va au friction pour de vrai genre, et Rose Iradukunda demande un registre plus net.",
  "correct_sentence": "On va au friction vraiment, et Rose Iradukunda demande un registre plus net.",
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
      "image_path": "/elearning/mfk-c1-m6/radio-travail.svg",
      "word": "radio travail"
    },
    {
      "image_path": "/elearning/mfk-c1-m6/soleil-poste.svg",
      "word": "soleil poste"
    },
    {
      "image_path": "/elearning/mfk-c1-m6/nuage-crise.svg",
      "word": "nuage crise"
    },
    {
      "image_path": "/elearning/mfk-c1-m6/feuille-revue.svg",
      "word": "feuille revue"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Tableau de langue : six exemples justes de « intégrer des citations ; il a déclaré que ; nuance » et deux pièges commentés."
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

  -- ===== Analyse du travail au Seuil =====
  SELECT s.id INTO v_seq_id
  FROM elearning_sequences s
  WHERE s.module_id = v_module_id AND s.title = 'Analyse du travail au Seuil'
  LIMIT 1;

  IF v_seq_id IS NULL THEN
    INSERT INTO elearning_sequences (module_id, title, order_index)
    VALUES (v_module_id, 'Analyse du travail au Seuil', 5)
    RETURNING id INTO v_seq_id;
  ELSE
    UPDATE elearning_sequences
    SET order_index = 5
    WHERE id = v_seq_id;
  END IF;

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CO — Analyse du travail au Seuil',
    'CO',
    $c$Objectif
Comprendre un échange long et en extraire l'implicite. Conclure le module par une analyse : organisation, recrutement, crise, ailleurs. Viser la nuance, la collocation et l'implicite.

Consigne
Lisez le débat (à écouter avec l'enseignant). Qu'est-ce qui est dit, qu'est-ce qui reste implicite, qui concède quoi ?

Support — Débat Radio Figuier — Analyse du travail au Seuil
Lila Sow : Radio Figuier. On parle trop vite de le travail au Seuil comme horizon commun, comme si le mot dispensait d'en examiner le prix.
Marc Nkurunziza : Encore que l'on reporte le relais à une saison trop vague, une analyse sans calendrier n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Léa Niyonzima : Aline Uwase concède que tout ne se répare pas en un jeudi, pour autant que l'on date ce qui peut l'être : relais, accroche, rampe de l'atelier.
Aline Uwase : Ce que l'on nomme constat, ici, n'est pas un slogan : fait établi, distinct d'un slogan.
Patrick Habimana : Aline : il convient que l'on date le relais, encore que tout ne se répare pas jeudi.
Hawa Diallo : Joël entend enfin son nom dans une motion.
Joël Mugisha : Rose exige que l'accroche reste juste.
Rose Iradukunda : Karim veut la revue dans un mois, pas un nuage.
Solange Mukamana : Lila ouvrira l'antenne pour la revue.
Karim Bamba : Patrick relie C1-6 aux heures de la colline.
Félicie Ndayishimiye : Un chiffre, une trace : Quatre constats écrits ; deux dates ; une revue promise sous le figuier dans un mois.
Dieudonné Hakizimana : L'enjeu n'est pas d'avoir raison plus fort : il s'agit que C1-6 ne reste pas une suite de récits, mais une cour qui décide
Yvette : Dieudonné peut commencer le fer.
Mado : Joël Mugisha entend, dans « on verra plus tard », ceci qui n'est pas dit : on verra plus tard est la phrase préférée de ce qui n'a pas à porter les lanternes
Sami : Autrement dit, il s'agit de tenir ensemble les voix, les heures et la date
Lila Sow : Je reformule pour les auditeurs. La proposition qui reste debout est celle-ci : un texte final : quatre constats, deux gestes datés, une revue dans un mois
Nina Kayitesi : Marc : une analyse qui n'agit pas n'était qu'un exercice.
Lila Sow : Nous clôturons sans clore. Nous clôturons sans fusionner les voix : les quatre séquences précédentes d'un côté, la motion d'Aline de l'autre, et le point où elles refusent de se ressembler.
$c$,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "une analyse sans calendrier est présenté comme un simple détail sans conséquence.",
  "correct": false,
  "explanation": "Le texte affirme au contraire que une analyse sans calendrier n'est pas un détail."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Selon Joël Mugisha, que reste-t-il implicite dans « on verra plus tard » ?",
  "options": [
    {
      "text": "Que Aline a tout remis à l'année suivante",
      "correct": false
    },
    {
      "text": "Phrase de ceux qui ne portent pas les lanternes",
      "correct": true
    },
    {
      "text": "Que Joël a refusé les dates",
      "correct": false
    },
    {
      "text": "Que le relais est un luxe",
      "correct": false
    }
  ],
  "explanation": "on verra plus tard est la phrase préférée de ce qui n'a pas à porter les lanternes"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "constat",
      "right": "fait établi, distinct d'un slogan"
    },
    {
      "left": "calendrier",
      "right": "dates, plus précis que plus tard"
    },
    {
      "left": "relais",
      "right": "partage des heures, geste central"
    },
    {
      "left": "motion",
      "right": "décision de cour, relisible"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nIl convient que l'on ___ avant d'accélérer. (dater, subj.)",
  "answer": "date"
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
    "date",
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
  "word": "constat",
  "hint": "fait établi, distinct d'un slogan"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Il convient que l'on dater trop tard, et Aline Uwase refuse d'accélérer la pente.",
  "correct_sentence": "Il convient que l'on date trop tard, et Aline Uwase refuse d'accélérer la pente.",
  "explanation": "Il convient que + date."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-c1-m6/soleil-poste.svg",
      "word": "soleil poste"
    },
    {
      "image_path": "/elearning/mfk-c1-m6/nuage-crise.svg",
      "word": "nuage crise"
    },
    {
      "image_path": "/elearning/mfk-c1-m6/feuille-revue.svg",
      "word": "feuille revue"
    },
    {
      "image_path": "/elearning/mfk-c1-m6/main-poignee.svg",
      "word": "main poignee"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Reformulez l'implicite de « on verra plus tard » et la concession de Aline Uwase."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez une synthèse d'environ quatre-vingt-dix secondes : deux points de vue, un implicite, une proposition. Gardez les quatre séquences précédentes et la motion d'Aline distincts."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CE — Deux dates, pas plus tard',
    'CE',
    $c$Objectif
Lire un texte argumenté long, synthétiser et reformuler. Conclure le module par une analyse : organisation, recrutement, crise, ailleurs. Viser la nuance, la collocation et l'implicite.

Consigne
Lisez « Deux dates, pas plus tard », sans aller trop vite. Repérez la thèse, la concession, l'implicite et la proposition.

Support — Deux dates, pas plus tard
On parle trop vite de le travail au Seuil comme horizon commun, comme si le mot dispensait d'en examiner le prix.
Encore que l'on reporte le relais à une saison trop vague, une analyse sans calendrier n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Aline Uwase concède que tout ne se répare pas en un jeudi, pour autant que l'on date ce qui peut l'être : relais, accroche, rampe de l'atelier.
Ce que l'on nomme constat, ici, n'est pas un slogan : fait établi, distinct d'un slogan.
Aline : il convient que l'on date le relais, encore que tout ne se répare pas jeudi.
Joël entend enfin son nom dans une motion.
Rose exige que l'accroche reste juste.
Karim veut la revue dans un mois, pas un nuage.
Lila ouvrira l'antenne pour la revue.
Patrick relie C1-6 aux heures de la colline.
Un chiffre, une trace : Quatre constats écrits ; deux dates ; une revue promise sous le figuier dans un mois.
L'enjeu n'est pas d'avoir raison plus fort : il s'agit que C1-6 ne reste pas une suite de récits, mais une cour qui décide
Dieudonné peut commencer le fer.
Joël Mugisha entend, dans « on verra plus tard », ceci qui n'est pas dit : on verra plus tard est la phrase préférée de ce qui n'a pas à porter les lanternes
Autrement dit, il s'agit de tenir ensemble les voix, les heures et la date
La proposition qui reste debout est celle-ci : un texte final : quatre constats, deux gestes datés, une revue dans un mois
Marc : une analyse qui n'agit pas n'était qu'un exercice.
Nous clôturons sans fusionner les voix : les quatre séquences précédentes d'un côté, la motion d'Aline de l'autre, et le point où elles refusent de se ressembler.
Signé : Aline Uwase, Rukiri-Nord — Cahier des racines, Rukiri-Nord.
$c$,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Le texte refuse de fusionner les quatre séquences précédentes et la motion d'Aline en une seule affiche.",
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
      "text": "Quatre constats, deux dates, une revue dans un mois",
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
  "explanation": "Quatre constats écrits ; deux dates ; une revue promise sous le figuier dans un mois."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "constat",
      "right": "fait établi, distinct d'un slogan"
    },
    {
      "left": "calendrier",
      "right": "dates, plus précis que plus tard"
    },
    {
      "left": "relais",
      "right": "partage des heures, geste central"
    },
    {
      "left": "motion",
      "right": "décision de cour, relisible"
    }
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
  "word": "calendrier",
  "hint": "dates, plus précis que plus tard"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "La constat de trop vite n'aide personne, et Joël Mugisha reprend le fil.",
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
      "image_path": "/elearning/mfk-c1-m6/nuage-crise.svg",
      "word": "nuage crise"
    },
    {
      "image_path": "/elearning/mfk-c1-m6/feuille-revue.svg",
      "word": "feuille revue"
    },
    {
      "image_path": "/elearning/mfk-c1-m6/main-poignee.svg",
      "word": "main poignee"
    },
    {
      "image_path": "/elearning/mfk-c1-m6/coeur-atelier.svg",
      "word": "coeur atelier"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Synthétisez « Deux dates, pas plus tard » : thèse, concession, implicite, proposition (quinze lignes)."
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
    'PO — Analyse du travail au Seuil : dire sans slogan',
    'PO',
    $c$Objectif
Produire un oral structuré (thèse, concession, proposition). Point : synthèse argumentée ; encore que ; il s'agit de.

Consigne
Répétez les modèles, puis prenez position en une minute : thèse, concession, reformulation, proposition.

Support — Modèles d'Aline Uwase, banc du figuier
Encore que l'on reporte le relais à une saison trop vague, une analyse sans calendrier n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Aline Uwase concède que tout ne se répare pas en un jeudi, pour autant que l'on date ce qui peut l'être : relais, accroche, rampe de l'atelier.
Ce que l'on nomme constat, ici, n'est pas un slogan : fait établi, distinct d'un slogan.
Encore que l'on date, une analyse sans calendrier n'est pas un détail.
Aline Uwase concède que tout ne se répare pas en un jeudi, pour autant que l'on date ce qui peut l'être : relais, accroche, rampe de l'atelier.
Autrement dit, il s'agit de tenir ensemble les voix, les heures et la date
Il ressort qu'un texte final : quatre constats, deux gestes datés, une revue dans un mois
Joël entend enfin son nom dans une motion.
Lila ouvrira l'antenne pour la revue.
La proposition qui reste debout est celle-ci : un texte final : quatre constats, deux gestes datés, une revue dans un mois
Je concède le point, je n'abandonne pas la proposition.
Ce n'est pas que je refuse : c'est que je refuse qu'on nomme cela un détail.
Autrement dit, l'implicite fait autant de travail que la thèse.
En une minute : fait, angle, concession, proposition.
Nous clôturons sans fusionner les voix : les quatre séquences précédentes d'un côté, la motion d'Aline de l'autre, et le point où elles refusent de se ressembler.
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
  "explanation": "Aline Uwase concède que tout ne se répare pas en un jeudi, pour autant que l'on date ce qui peut l'être : relais, accroche, rampe de l'atelier."
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
      "text": "tout ne se répare pas en un jeudi — à condition que l'on date ce qui peut l'être : relais, accroche, rampe de l'atelier",
      "correct": true
    },
    {
      "text": "Aline Uwase abandonne il s'agit que C1-6 ne reste pas une suite de récits, mais une cour qui décide",
      "correct": false
    },
    {
      "text": "La concession vaut acceptation du slogan",
      "correct": false
    }
  ],
  "explanation": "Concession réelle, pas un abandon : l'on date ce qui peut l'être : relais, accroche, rampe de l'atelier"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "constat",
      "right": "fait établi, distinct d'un slogan"
    },
    {
      "left": "calendrier",
      "right": "dates, plus précis que plus tard"
    },
    {
      "left": "relais",
      "right": "partage des heures, geste central"
    },
    {
      "left": "motion",
      "right": "décision de cour, relisible"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nNous recommandons que la cour ___ un relais. (dater, subj.)",
  "answer": "date"
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
    "date",
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
  "word": "relais",
  "hint": "partage des heures, geste central"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Aline Uwase écoute encore, et il fautons dater avant de crier.",
  "correct_sentence": "Aline Uwase écoute encore, et il faut dater avant de crier.",
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
      "image_path": "/elearning/mfk-c1-m6/feuille-revue.svg",
      "word": "feuille revue"
    },
    {
      "image_path": "/elearning/mfk-c1-m6/main-poignee.svg",
      "word": "main poignee"
    },
    {
      "image_path": "/elearning/mfk-c1-m6/coeur-atelier.svg",
      "word": "coeur atelier"
    },
    {
      "image_path": "/elearning/mfk-c1-m6/revue-presse.svg",
      "word": "revue presse"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Écrivez six phrases orales justes : deux sur synthèse argumentée ; encore que ; il s'agit de, deux concessions, deux propositions."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez quatre modèles, puis votre prise de position (thèse, concession, proposition). Gardez les quatre séquences précédentes et la motion d'Aline distincts."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PE — le texte de Aline Uwase',
    'PE',
    $c$Objectif
Écrire un texte long et structuré. Conclure le module par une analyse : organisation, recrutement, crise, ailleurs. Point : synthèse argumentée ; encore que ; il s'agit de.

Consigne
Imitez le texte de Aline Uwase.

Support — Aline Uwase — Deux dates, pas plus tard
Aline Uwase — Deux dates, pas plus tard
On parle trop vite de le travail au Seuil comme horizon commun, comme si le mot dispensait d'en examiner le prix.
Encore que l'on reporte le relais à une saison trop vague, une analyse sans calendrier n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Aline Uwase concède que tout ne se répare pas en un jeudi, pour autant que l'on date ce qui peut l'être : relais, accroche, rampe de l'atelier.
Ce que l'on nomme constat, ici, n'est pas un slogan : fait établi, distinct d'un slogan.
Aline : il convient que l'on date le relais, encore que tout ne se répare pas jeudi.
Lila ouvrira l'antenne pour la revue.
Patrick relie C1-6 aux heures de la colline.
Dieudonné peut commencer le fer.
La proposition qui reste debout est celle-ci : un texte final : quatre constats, deux gestes datés, une revue dans un mois
Marc : une analyse qui n'agit pas n'était qu'un exercice.
Nous clôturons sans fusionner les voix : les quatre séquences précédentes d'un côté, la motion d'Aline de l'autre, et le point où elles refusent de se ressembler.
Encore que l'on date, une analyse sans calendrier n'est pas un détail.
Aline Uwase concède que tout ne se répare pas en un jeudi, pour autant que l'on date ce qui peut l'être : relais, accroche, rampe de l'atelier.
Je n'écris pas pour vaincre : j'écris pour que la cour puisse relire.
il s'agit de tenir ensemble les voix, les heures et la date
Aline Uwase, Rukiri-Nord
$c$,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "La proposition retenue est : un texte final : quatre constats, deux gestes datés, une revue dans un mois",
  "correct": true,
  "explanation": "un texte final : quatre constats, deux gestes datés, une revue dans un mois"
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
      "text": "un texte final : quatre constats, deux gestes datés, une revue dans un mois",
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
  "explanation": "un texte final : quatre constats, deux gestes datés, une revue dans un mois"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "constat",
      "right": "fait établi, distinct d'un slogan"
    },
    {
      "left": "calendrier",
      "right": "dates, plus précis que plus tard"
    },
    {
      "left": "relais",
      "right": "partage des heures, geste central"
    },
    {
      "left": "motion",
      "right": "décision de cour, relisible"
    }
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
  "word": "motion",
  "hint": "décision de cour, relisible"
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
      "image_path": "/elearning/mfk-c1-m6/main-poignee.svg",
      "word": "main poignee"
    },
    {
      "image_path": "/elearning/mfk-c1-m6/coeur-atelier.svg",
      "word": "coeur atelier"
    },
    {
      "image_path": "/elearning/mfk-c1-m6/revue-presse.svg",
      "word": "revue presse"
    },
    {
      "image_path": "/elearning/mfk-c1-m6/organisation-atelier.svg",
      "word": "organisation atelier"
    }
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
    'EL — synthèse argumentée ; encore que ; il s''agit de',
    'EL',
    $c$Objectif
Maîtriser synthèse argumentée ; encore que ; il s'agit de au registre C1, avec collocations et pièges de construction.

Consigne
Apprenez la fiche, puis produisez des exemples justes au registre demandé.

Support — Fiche d'Aline Uwase, banc ocre
Fiche C1 — synthèse argumentée ; encore que ; il s'agit de
On ne retient pas une liste : on retient des constructions et des collocations.
Encore que l'on date, une analyse sans calendrier n'est pas un détail.
Aline Uwase concède que tout ne se répare pas en un jeudi, pour autant que l'on date ce qui peut l'être : relais, accroche, rampe de l'atelier.
Autrement dit, il s'agit de tenir ensemble les voix, les heures et la date
Il ressort qu'un texte final : quatre constats, deux gestes datés, une revue dans un mois
Piège : indicatif après il convient que
Registre : soutenu argumentatif, sans slogan
Collocation : encore que, pour autant que, il ressort que
Ce que l'on nomme constat, ici, n'est pas un slogan : fait établi, distinct d'un slogan.
Joël entend enfin son nom dans une motion.
Lila ouvrira l'antenne pour la revue.
Nominaliser, ce n'est pas alourdir : c'est nommer le processus (la densification, l'accueil, le rappel).
Encore que / pour autant que / si tant est que : subjonctif, concession réelle, pas un ornement.
Reformuler une source : on change la syntaxe, on garde la charge, on signale le point de vue.
C1 : l'implicite se justifie. C2 : l'ironie se laisse entendre sans s'afficher.
Exemple fautif à ne plus produire : On va au relais pour de vrai genre, et Joël Mugisha demande un registre plus net.
Correction : On va au relais vraiment, et Joël Mugisha demande un registre plus net.
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
      "left": "constat",
      "right": "fait établi, distinct d'un slogan"
    },
    {
      "left": "calendrier",
      "right": "dates, plus précis que plus tard"
    },
    {
      "left": "relais",
      "right": "partage des heures, geste central"
    },
    {
      "left": "motion",
      "right": "décision de cour, relisible"
    }
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
  "sentence_with_error": "On va au relais pour de vrai genre, et Joël Mugisha demande un registre plus net.",
  "correct_sentence": "On va au relais vraiment, et Joël Mugisha demande un registre plus net.",
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
      "image_path": "/elearning/mfk-c1-m6/coeur-atelier.svg",
      "word": "coeur atelier"
    },
    {
      "image_path": "/elearning/mfk-c1-m6/revue-presse.svg",
      "word": "revue presse"
    },
    {
      "image_path": "/elearning/mfk-c1-m6/organisation-atelier.svg",
      "word": "organisation atelier"
    },
    {
      "image_path": "/elearning/mfk-c1-m6/bienveillance-poste.svg",
      "word": "bienveillance poste"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Tableau de langue : six exemples justes de « synthèse argumentée ; encore que ; il s'agit de » et deux pièges commentés."
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
