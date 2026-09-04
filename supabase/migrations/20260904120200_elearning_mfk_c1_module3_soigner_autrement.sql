/*
  Seed eLearning MFK — C1 — Soigner autrement

  Micro-monde : cour « Le Seuil des Sources », Rukiri-Nord.
  6 séquences × 5 leçons × 10 exercices (tous les types).
  Illustrations originales : /elearning/mfk-c1-m3/
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
  v_module_title text := 'C1 — Soigner autrement';
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
      'Grande étape C1-3 : reformuler un parcours à l''Infirmerie des Herbes, rapporter une enquête du Filtre, raconter une formation trop longue, présenter une polémique sur les infusions de Solange, tenir une mini-conférence puis un podcast — Hawa Diallo traduit la peur sans la nier, Inès Mukama refuse le jargon qui abandonne le malade, Aline Uwase tient la fiche de langue, Dieudonné répare la porte d''attente.',
      'C1',
      false
    )
    RETURNING id INTO v_module_id;
  ELSE
    UPDATE elearning_modules
    SET
      description = 'Grande étape C1-3 : reformuler un parcours à l''Infirmerie des Herbes, rapporter une enquête du Filtre, raconter une formation trop longue, présenter une polémique sur les infusions de Solange, tenir une mini-conférence puis un podcast — Hawa Diallo traduit la peur sans la nier, Inès Mukama refuse le jargon qui abandonne le malade, Aline Uwase tient la fiche de langue, Dieudonné répare la porte d''attente.',
      cefr_level = 'C1',
      published = false,
      updated_at = now()
    WHERE id = v_module_id;
  END IF;

  -- ===== Dons et parcours =====
  SELECT s.id INTO v_seq_id
  FROM elearning_sequences s
  WHERE s.module_id = v_module_id AND s.title = 'Dons et parcours'
  LIMIT 1;

  IF v_seq_id IS NULL THEN
    INSERT INTO elearning_sequences (module_id, title, order_index)
    VALUES (v_module_id, 'Dons et parcours', 0)
    RETURNING id INTO v_seq_id;
  ELSE
    UPDATE elearning_sequences
    SET order_index = 0
    WHERE id = v_seq_id;
  END IF;

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CO — Dons et parcours',
    'CO',
    $c$Objectif
Comprendre un échange long et en extraire l'implicite. Reformuler les difficultés d'un parcours à l'Infirmerie des Herbes sans jargon abandonnant. Viser la nuance, la collocation et l'implicite.

Consigne
Lisez le débat (à écouter avec l'enseignant). Qu'est-ce qui est dit, qu'est-ce qui reste implicite, qui concède quoi ?

Support — Débat Radio Figuier — Dons et parcours
Lila Sow : Radio Figuier. On parle trop vite de le parcours à l'Infirmerie des Herbes, comme si le mot dispensait d'en examiner le prix.
Marc Nkurunziza : Encore que l'on réduise l'attente à une vertu, une porte trop longue à s'ouvrir pour Hawa n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Léa Niyonzima : Hawa Diallo concède que un don de temps peut aider l'infirmerie, pour autant que l'on n'appelle pas don le silence imposé au malade.
Aline Uwase : Ce que l'on nomme parcours, ici, n'est pas un slogan : suite de portes et de mots, plus qu'une attente.
Patrick Habimana : Hawa : on m'a dit d'attendre comme on dit merci.
Hawa Diallo : Inès refuse le jargon qui abandonne : elle traduit, elle n'humilie pas.
Joël Mugisha : Dieudonné répare la porte d'attente pour qu'elle grince moins.
Rose Iradukunda : Aline : le passif a été reçue trop tard n'est pas une excuse, c'est une phrase à relire.
Solange Mukamana : Patrick demande ce dont on a besoin : une explication, pas un mot savant.
Karim Bamba : Solange apporte une infusion et sort : elle n'est pas le protocole.
Félicie Ndayishimiye : Un chiffre, une trace : Hawa a compté onze passages de porte, trois jargon incompréhensibles, une main de Dieudonné sur le banc.
Dieudonné Hakizimana : L'enjeu n'est pas d'avoir raison plus fort : il s'agit que le consentement soit clair, pas seulement signé trop vite
Yvette : Lila enregistrera le podcast si Hawa le veut, pas pour le spectacle.
Mado : Inès Mukama entend, dans « il suffit d'attendre », ceci qui n'est pas dit : il suffit d'attendre veut souvent dire votre douleur n'a pas de place dans l'emploi du temps
Sami : Autrement dit, le parcours n'est pas une ligne : c'est une série de portes, de mots, de peurs nommées
Lila Sow : Je reformule pour les auditeurs. La proposition qui reste debout est celle-ci : un podcast qui reformule le parcours d'Hawa sans voler sa voix
Nina Kayitesi : Marc : reformuler un parcours, c'est rendre les portes visibles.
Lila Sow : Nous clôturons sans clore. Nous clôturons sans fusionner les voix : les notes d'Hawa au Cahier des dons d'un côté, la fiche trop technique d'un passage inventé de l'autre, et le point où elles refusent de se ressembler.
$c$,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "une porte trop longue à s'ouvrir pour Hawa est présenté comme un simple détail sans conséquence.",
  "correct": false,
  "explanation": "Le texte affirme au contraire que une porte trop longue à s'ouvrir pour Hawa n'est pas un détail."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Selon Inès Mukama, que reste-t-il implicite dans « il suffit d'attendre » ?",
  "options": [
    {
      "text": "Que Hawa refuse tout soin",
      "correct": false
    },
    {
      "text": "La douleur n'a pas de place dans l'emploi du temps",
      "correct": true
    },
    {
      "text": "Que Inès a fermé l'infirmerie",
      "correct": false
    },
    {
      "text": "Que Dieudonné prescrit les infusions",
      "correct": false
    }
  ],
  "explanation": "il suffit d'attendre veut souvent dire votre douleur n'a pas de place dans l'emploi du temps"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "parcours",
      "right": "suite de portes et de mots, plus qu'une attente"
    },
    {
      "left": "consentement",
      "right": "accord clair, pas une signature trop vite"
    },
    {
      "left": "jargon",
      "right": "langue qui abandonne le malade"
    },
    {
      "left": "don",
      "right": "geste, distinct du silence imposé"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nVoici ce ___ nous avons besoin pour tenir. (dont)",
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
    "Voici",
    "ce",
    "dont",
    "nous",
    "avons",
    "besoin",
    "sous",
    "don",
    "."
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
  "hint": "suite de portes et de mots, plus qu'une attente"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Voici ce que nous avons besoin pour le parcours à l'Infirmerie des Herbes, et Hawa Diallo écrit encore.",
  "correct_sentence": "Voici ce dont nous avons besoin pour le parcours à l'Infirmerie des Herbes, et Hawa Diallo écrit encore.",
  "explanation": "Besoin se construit avec de : ce dont."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-c1-m3/cahier-dons.svg",
      "word": "cahier dons"
    },
    {
      "image_path": "/elearning/mfk-c1-m3/parcours-infirmerie.svg",
      "word": "parcours infirmerie"
    },
    {
      "image_path": "/elearning/mfk-c1-m3/attente-longue.svg",
      "word": "attente longue"
    },
    {
      "image_path": "/elearning/mfk-c1-m3/consentement-clair.svg",
      "word": "consentement clair"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Reformulez l'implicite de « il suffit d'attendre » et la concession de Hawa Diallo."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez une synthèse d'environ quatre-vingt-dix secondes : deux points de vue, un implicite, une proposition. Gardez les notes d'Hawa au Cahier des dons et la fiche trop technique d'un passage inventé distincts."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CE — La porte trop longue',
    'CE',
    $c$Objectif
Lire un texte argumenté long, synthétiser et reformuler. Reformuler les difficultés d'un parcours à l'Infirmerie des Herbes sans jargon abandonnant. Viser la nuance, la collocation et l'implicite.

Consigne
Lisez « La porte trop longue », sans aller trop vite. Repérez la thèse, la concession, l'implicite et la proposition.

Support — La porte trop longue
On parle trop vite de le parcours à l'Infirmerie des Herbes, comme si le mot dispensait d'en examiner le prix.
Encore que l'on réduise l'attente à une vertu, une porte trop longue à s'ouvrir pour Hawa n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Hawa Diallo concède que un don de temps peut aider l'infirmerie, pour autant que l'on n'appelle pas don le silence imposé au malade.
Ce que l'on nomme parcours, ici, n'est pas un slogan : suite de portes et de mots, plus qu'une attente.
Hawa : on m'a dit d'attendre comme on dit merci.
Inès refuse le jargon qui abandonne : elle traduit, elle n'humilie pas.
Dieudonné répare la porte d'attente pour qu'elle grince moins.
Aline : le passif a été reçue trop tard n'est pas une excuse, c'est une phrase à relire.
Patrick demande ce dont on a besoin : une explication, pas un mot savant.
Solange apporte une infusion et sort : elle n'est pas le protocole.
Un chiffre, une trace : Hawa a compté onze passages de porte, trois jargon incompréhensibles, une main de Dieudonné sur le banc.
L'enjeu n'est pas d'avoir raison plus fort : il s'agit que le consentement soit clair, pas seulement signé trop vite
Lila enregistrera le podcast si Hawa le veut, pas pour le spectacle.
Inès Mukama entend, dans « il suffit d'attendre », ceci qui n'est pas dit : il suffit d'attendre veut souvent dire votre douleur n'a pas de place dans l'emploi du temps
Autrement dit, le parcours n'est pas une ligne : c'est une série de portes, de mots, de peurs nommées
La proposition qui reste debout est celle-ci : un podcast qui reformule le parcours d'Hawa sans voler sa voix
Marc : reformuler un parcours, c'est rendre les portes visibles.
Nous clôturons sans fusionner les voix : les notes d'Hawa au Cahier des dons d'un côté, la fiche trop technique d'un passage inventé de l'autre, et le point où elles refusent de se ressembler.
Signé : Hawa Diallo, Rukiri-Nord — Cahier des racines, Rukiri-Nord.
$c$,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Le texte refuse de fusionner les notes d'Hawa au Cahier des dons et la fiche trop technique d'un passage inventé en une seule affiche.",
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
      "text": "Onze portes, trois jargon, une main sur le banc",
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
  "explanation": "Hawa a compté onze passages de porte, trois jargon incompréhensibles, une main de Dieudonné sur le banc."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "parcours",
      "right": "suite de portes et de mots, plus qu'une attente"
    },
    {
      "left": "consentement",
      "right": "accord clair, pas une signature trop vite"
    },
    {
      "left": "jargon",
      "right": "langue qui abandonne le malade"
    },
    {
      "left": "don",
      "right": "geste, distinct du silence imposé"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nVoilà ce ___ l'on s'engage en signant. (à quoi)",
  "answer": "à quoi"
}$j$::jsonb,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Remettez les mots dans l''ordre',
    'word_order',
    $j${
  "words": [
    "Voilà",
    "ce",
    "à",
    "quoi",
    "l'on",
    "s'engage",
    "en",
    "signant",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "consentement",
  "hint": "accord clair, pas une signature trop vite"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "La parcours de trop vite n'aide personne, et Inès Mukama reprend le fil.",
  "correct_sentence": "La précipitation n'aide personne, et Inès Mukama reprend le fil.",
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
      "image_path": "/elearning/mfk-c1-m3/parcours-infirmerie.svg",
      "word": "parcours infirmerie"
    },
    {
      "image_path": "/elearning/mfk-c1-m3/attente-longue.svg",
      "word": "attente longue"
    },
    {
      "image_path": "/elearning/mfk-c1-m3/consentement-clair.svg",
      "word": "consentement clair"
    },
    {
      "image_path": "/elearning/mfk-c1-m3/enquete-herbes.svg",
      "word": "enquete herbes"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Synthétisez « La porte trop longue » : thèse, concession, implicite, proposition (quinze lignes)."
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
    'PO — Dons et parcours : dire sans slogan',
    'PO',
    $c$Objectif
Produire un oral structuré (thèse, concession, proposition). Point : passif ; reformulation d'un parcours ; vocabulaire du soin (inventé).

Consigne
Répétez les modèles, puis prenez position en une minute : thèse, concession, reformulation, proposition.

Support — Modèles d'Aline Uwase, banc du figuier
Encore que l'on réduise l'attente à une vertu, une porte trop longue à s'ouvrir pour Hawa n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Hawa Diallo concède que un don de temps peut aider l'infirmerie, pour autant que l'on n'appelle pas don le silence imposé au malade.
Ce que l'on nomme parcours, ici, n'est pas un slogan : suite de portes et de mots, plus qu'une attente.
Encore que l'on reformule, une porte trop longue à s'ouvrir pour Hawa n'est pas un détail.
Hawa Diallo concède que un don de temps peut aider l'infirmerie, pour autant que l'on n'appelle pas don le silence imposé au malade.
Autrement dit, le parcours n'est pas une ligne : c'est une série de portes, de mots, de peurs nommées
Il ressort qu'un podcast qui reformule le parcours d'Hawa sans voler sa voix
Inès refuse le jargon qui abandonne : elle traduit, elle n'humilie pas.
Patrick demande ce dont on a besoin : une explication, pas un mot savant.
La proposition qui reste debout est celle-ci : un podcast qui reformule le parcours d'Hawa sans voler sa voix
Je concède le point, je n'abandonne pas la proposition.
Ce n'est pas que je refuse : c'est que je refuse qu'on nomme cela un détail.
Autrement dit, l'implicite fait autant de travail que la thèse.
En une minute : fait, angle, concession, proposition.
Nous clôturons sans fusionner les voix : les notes d'Hawa au Cahier des dons d'un côté, la fiche trop technique d'un passage inventé de l'autre, et le point où elles refusent de se ressembler.
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
  "explanation": "Hawa Diallo concède que un don de temps peut aider l'infirmerie, pour autant que l'on n'appelle pas don le silence imposé au malade."
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
      "text": "un don de temps peut aider l'infirmerie — à condition que l'on n'appelle pas don le silence imposé au malade",
      "correct": true
    },
    {
      "text": "Hawa Diallo abandonne il s'agit que le consentement soit clair, pas seulement signé trop vite",
      "correct": false
    },
    {
      "text": "La concession vaut acceptation du slogan",
      "correct": false
    }
  ],
  "explanation": "Concession réelle, pas un abandon : l'on n'appelle pas don le silence imposé au malade"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "parcours",
      "right": "suite de portes et de mots, plus qu'une attente"
    },
    {
      "left": "consentement",
      "right": "accord clair, pas une signature trop vite"
    },
    {
      "left": "jargon",
      "right": "langue qui abandonne le malade"
    },
    {
      "left": "don",
      "right": "geste, distinct du silence imposé"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nLa ___ retient deux sources sans les fusionner. (synthétiser → nom)",
  "answer": "synthèse"
}$j$::jsonb,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Remettez les mots dans l''ordre',
    'word_order',
    $j${
  "words": [
    "Synthétiser",
    "n'est",
    "pas",
    "couper",
    "les",
    "aspérités",
    "des",
    "sources",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "jargon",
  "hint": "langue qui abandonne le malade"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Hawa Diallo écoute encore, et il fautons reformuler avant de crier.",
  "correct_sentence": "Hawa Diallo écoute encore, et il faut reformuler avant de crier.",
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
      "image_path": "/elearning/mfk-c1-m3/attente-longue.svg",
      "word": "attente longue"
    },
    {
      "image_path": "/elearning/mfk-c1-m3/consentement-clair.svg",
      "word": "consentement clair"
    },
    {
      "image_path": "/elearning/mfk-c1-m3/enquete-herbes.svg",
      "word": "enquete herbes"
    },
    {
      "image_path": "/elearning/mfk-c1-m3/decouverte-filtre.svg",
      "word": "decouverte filtre"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Écrivez six phrases orales justes : deux sur passif ; reformulation d'un parcours ; vocabulaire du soin (inventé), deux concessions, deux propositions."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez quatre modèles, puis votre prise de position (thèse, concession, proposition). Gardez les notes d'Hawa au Cahier des dons et la fiche trop technique d'un passage inventé distincts."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PE — le texte de Hawa Diallo',
    'PE',
    $c$Objectif
Écrire un texte long et structuré. Reformuler les difficultés d'un parcours à l'Infirmerie des Herbes sans jargon abandonnant. Point : passif ; reformulation d'un parcours ; vocabulaire du soin (inventé).

Consigne
Imitez le texte de Hawa Diallo.

Support — Hawa Diallo — La porte trop longue
Hawa Diallo — La porte trop longue
On parle trop vite de le parcours à l'Infirmerie des Herbes, comme si le mot dispensait d'en examiner le prix.
Encore que l'on réduise l'attente à une vertu, une porte trop longue à s'ouvrir pour Hawa n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Hawa Diallo concède que un don de temps peut aider l'infirmerie, pour autant que l'on n'appelle pas don le silence imposé au malade.
Ce que l'on nomme parcours, ici, n'est pas un slogan : suite de portes et de mots, plus qu'une attente.
Hawa : on m'a dit d'attendre comme on dit merci.
Patrick demande ce dont on a besoin : une explication, pas un mot savant.
Solange apporte une infusion et sort : elle n'est pas le protocole.
Lila enregistrera le podcast si Hawa le veut, pas pour le spectacle.
La proposition qui reste debout est celle-ci : un podcast qui reformule le parcours d'Hawa sans voler sa voix
Marc : reformuler un parcours, c'est rendre les portes visibles.
Nous clôturons sans fusionner les voix : les notes d'Hawa au Cahier des dons d'un côté, la fiche trop technique d'un passage inventé de l'autre, et le point où elles refusent de se ressembler.
Encore que l'on reformule, une porte trop longue à s'ouvrir pour Hawa n'est pas un détail.
Hawa Diallo concède que un don de temps peut aider l'infirmerie, pour autant que l'on n'appelle pas don le silence imposé au malade.
Je n'écris pas pour vaincre : j'écris pour que la cour puisse relire.
le parcours n'est pas une ligne : c'est une série de portes, de mots, de peurs nommées
Hawa Diallo, Rukiri-Nord
$c$,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "La proposition retenue est : un podcast qui reformule le parcours d'Hawa sans voler sa voix",
  "correct": true,
  "explanation": "un podcast qui reformule le parcours d'Hawa sans voler sa voix"
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
      "text": "un podcast qui reformule le parcours d'Hawa sans voler sa voix",
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
  "explanation": "un podcast qui reformule le parcours d'Hawa sans voler sa voix"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "parcours",
      "right": "suite de portes et de mots, plus qu'une attente"
    },
    {
      "left": "consentement",
      "right": "accord clair, pas une signature trop vite"
    },
    {
      "left": "jargon",
      "right": "langue qui abandonne le malade"
    },
    {
      "left": "don",
      "right": "geste, distinct du silence imposé"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nIl n'est pas vrai que cela ___ un slogan. (être, subj.)",
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
    "Hawa",
    "concède",
    "le",
    "partage",
    "pour",
    "autant",
    "que",
    "l'on",
    "nomme",
    "les",
    "règles",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "don",
  "hint": "geste, distinct du silence imposé"
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
      "image_path": "/elearning/mfk-c1-m3/consentement-clair.svg",
      "word": "consentement clair"
    },
    {
      "image_path": "/elearning/mfk-c1-m3/enquete-herbes.svg",
      "word": "enquete herbes"
    },
    {
      "image_path": "/elearning/mfk-c1-m3/decouverte-filtre.svg",
      "word": "decouverte filtre"
    },
    {
      "image_path": "/elearning/mfk-c1-m3/miniconference.svg",
      "word": "miniconference"
    }
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
    'EL — passif ; reformulation d''un parcours ; vocabulaire du soin (inventé)',
    'EL',
    $c$Objectif
Maîtriser passif ; reformulation d'un parcours ; vocabulaire du soin (inventé) au registre C1, avec collocations et pièges de construction.

Consigne
Apprenez la fiche, puis produisez des exemples justes au registre demandé.

Support — Fiche d'Aline Uwase, banc ocre
Fiche C1 — passif ; reformulation d'un parcours ; vocabulaire du soin (inventé)
On ne retient pas une liste : on retient des constructions et des collocations.
Encore que l'on reformule, une porte trop longue à s'ouvrir pour Hawa n'est pas un détail.
Hawa Diallo concède que un don de temps peut aider l'infirmerie, pour autant que l'on n'appelle pas don le silence imposé au malade.
Autrement dit, le parcours n'est pas une ligne : c'est une série de portes, de mots, de peurs nommées
Il ressort qu'un podcast qui reformule le parcours d'Hawa sans voler sa voix
Piège : ce que + besoin au lieu de ce dont
Registre : soutenu argumentatif, sans slogan
Collocation : encore que, pour autant que, il ressort que
Ce que l'on nomme parcours, ici, n'est pas un slogan : suite de portes et de mots, plus qu'une attente.
Inès refuse le jargon qui abandonne : elle traduit, elle n'humilie pas.
Patrick demande ce dont on a besoin : une explication, pas un mot savant.
Nominaliser, ce n'est pas alourdir : c'est nommer le processus (la densification, l'accueil, le rappel).
Encore que / pour autant que / si tant est que : subjonctif, concession réelle, pas un ornement.
Reformuler une source : on change la syntaxe, on garde la charge, on signale le point de vue.
C1 : l'implicite se justifie. C2 : l'ironie se laisse entendre sans s'afficher.
Exemple fautif à ne plus produire : On va au jargon pour de vrai genre, et Inès Mukama demande un registre plus net.
Correction : On va au jargon vraiment, et Inès Mukama demande un registre plus net.
Aline Uwase, banc ocre — Le Seuil des Sources.
$c$,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "« Ce dont nous avons besoin » évite le calque « ce que besoin ».",
  "correct": true,
  "explanation": "Construction de besoin."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Quelle relative est juste pour le besoin ?",
  "options": [
    {
      "text": "ce que nous avons besoin",
      "correct": false
    },
    {
      "text": "ce dont nous avons besoin",
      "correct": true
    },
    {
      "text": "ce qui nous avons besoin",
      "correct": false
    },
    {
      "text": "dont que nous avons besoin",
      "correct": false
    }
  ],
  "explanation": "Besoin + de → ce dont."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "parcours",
      "right": "suite de portes et de mots, plus qu'une attente"
    },
    {
      "left": "consentement",
      "right": "accord clair, pas une signature trop vite"
    },
    {
      "left": "jargon",
      "right": "langue qui abandonne le malade"
    },
    {
      "left": "don",
      "right": "geste, distinct du silence imposé"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nPour autant que l'on ___ les règles, le partage tient. (reformuler, subj.)",
  "answer": "reformule"
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
    "clé",
    "n'est",
    "pas",
    "un",
    "luxe",
    "c'est",
    "un",
    "droit",
    "de",
    "fermer",
    "."
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
  "sentence_with_error": "On va au jargon pour de vrai genre, et Inès Mukama demande un registre plus net.",
  "correct_sentence": "On va au jargon vraiment, et Inès Mukama demande un registre plus net.",
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
      "image_path": "/elearning/mfk-c1-m3/enquete-herbes.svg",
      "word": "enquete herbes"
    },
    {
      "image_path": "/elearning/mfk-c1-m3/decouverte-filtre.svg",
      "word": "decouverte filtre"
    },
    {
      "image_path": "/elearning/mfk-c1-m3/miniconference.svg",
      "word": "miniconference"
    },
    {
      "image_path": "/elearning/mfk-c1-m3/graphique-peur.svg",
      "word": "graphique peur"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Tableau de langue : six exemples justes de « passif ; reformulation d'un parcours ; vocabulaire du soin (inventé) » et deux pièges commentés."
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

  -- ===== Le graphique n'efface pas la peur =====
  SELECT s.id INTO v_seq_id
  FROM elearning_sequences s
  WHERE s.module_id = v_module_id AND s.title = 'Le graphique n''efface pas la peur'
  LIMIT 1;

  IF v_seq_id IS NULL THEN
    INSERT INTO elearning_sequences (module_id, title, order_index)
    VALUES (v_module_id, 'Le graphique n''efface pas la peur', 1)
    RETURNING id INTO v_seq_id;
  ELSE
    UPDATE elearning_sequences
    SET order_index = 1
    WHERE id = v_seq_id;
  END IF;

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CO — Le graphique n''efface pas la peur',
    'CO',
    $c$Objectif
Comprendre un échange long et en extraire l'implicite. Rapporter une enquête du Filtre et expliciter une découverte sans triomphalisme. Viser la nuance, la collocation et l'implicite.

Consigne
Lisez le débat (à écouter avec l'enseignant). Qu'est-ce qui est dit, qu'est-ce qui reste implicite, qui concède quoi ?

Support — Débat Radio Figuier — Le graphique n'efface pas la peur
Lila Sow : Radio Figuier. On parle trop vite de une découverte du Filtre des Herbes, comme si le mot dispensait d'en examiner le prix.
Marc Nkurunziza : Encore que l'on close la peur par un graphique, une crainte qui n'est pas une ignorance n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Léa Niyonzima : Inès Mukama concède que un résultat peut rassurer, pour autant que l'on dise aussi ce que l'enquête n'a pas vu.
Aline Uwase : Ce que l'on nomme enquête, ici, n'est pas un slogan : recherche datée, avec limites.
Patrick Habimana : Inès : il apparaîtrait que le risque baisse, et j'entends déjà ceux qui veulent que je cesse le conditionnel.
Hawa Diallo : Hawa : ma crainte n'est pas une erreur de calcul.
Joël Mugisha : Karim exige la taille de l'échantillon, pas le mot miracle.
Rose Iradukunda : Aline : modaliser, c'est rester honnête.
Solange Mukamana : Patrick veut une mini-conférence, pas une messe.
Karim Bamba : Solange demande ce que l'on fera des deux craintes hors graphique.
Félicie Ndayishimiye : Un chiffre, une trace : Le Filtre avance : risque moindre dans un échantillon inventé de quarante bols ; deux craintes non mesurées restent sur le banc.
Dieudonné Hakizimana : L'enjeu n'est pas d'avoir raison plus fort : il s'agit de nommer le progrès sans chasser la crainte comme une honte
Yvette : Lila notera le conditionnel à l'antenne, exprès.
Mado : Hawa Diallo entend, dans « la science a parlé », ceci qui n'est pas dit : la science a parlé sert parfois à ne plus écouter ceux qui ont peur pour de vraies raisons
Sami : Autrement dit, il apparaîtrait que le filtre réduit un risque : ce conditionnel de prudence n'est pas une faiblesse
Lila Sow : Je reformule pour les auditeurs. La proposition qui reste debout est celle-ci : une mini-conférence : résultat, limite, crainte légitime, geste de cour
Nina Kayitesi : Marc : expliciter une découverte, c'est aussi dire où elle s'arrête.
Lila Sow : Nous clôturons sans clore. Nous clôturons sans fusionner les voix : le rapport du Filtre d'un côté, la conférence d'Inès sous le figuier de l'autre, et le point où elles refusent de se ressembler.
$c$,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "une crainte qui n'est pas une ignorance est présenté comme un simple détail sans conséquence.",
  "correct": false,
  "explanation": "Le texte affirme au contraire que une crainte qui n'est pas une ignorance n'est pas un détail."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Selon Hawa Diallo, que reste-t-il implicite dans « la science a parlé » ?",
  "options": [
    {
      "text": "Que le Filtre a tout mesuré",
      "correct": false
    },
    {
      "text": "Ne plus écouter une peur fondée",
      "correct": true
    },
    {
      "text": "Que Hawa refuse les graphiques",
      "correct": false
    },
    {
      "text": "Que Inès promet l'immortalité",
      "correct": false
    }
  ],
  "explanation": "la science a parlé sert parfois à ne plus écouter ceux qui ont peur pour de vraies raisons"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "enquête",
      "right": "recherche datée, avec limites"
    },
    {
      "left": "découverte",
      "right": "résultat, pas un triomphe"
    },
    {
      "left": "crainte",
      "right": "peur fondée, distincte de l'ignorance"
    },
    {
      "left": "échantillon",
      "right": "portion observée, pas tout le Seuil"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nLa part de bols trop salés s'___ à près d'un tiers. (établir)",
  "answer": "établit"
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
    "part",
    "de",
    "bols",
    "trop",
    "salés",
    "s'établit",
    "à",
    "près",
    "d'un",
    "tiers",
    "."
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
  "hint": "recherche datée, avec limites"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "La part de bols trop salés s'établissent à un tiers, et Inès Mukama refuse d'en faire une morale.",
  "correct_sentence": "La part de bols trop salés s'établit à un tiers, et Inès Mukama refuse d'en faire une morale.",
  "explanation": "La part … s'établit (singulier)."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-c1-m3/decouverte-filtre.svg",
      "word": "decouverte filtre"
    },
    {
      "image_path": "/elearning/mfk-c1-m3/miniconference.svg",
      "word": "miniconference"
    },
    {
      "image_path": "/elearning/mfk-c1-m3/graphique-peur.svg",
      "word": "graphique peur"
    },
    {
      "image_path": "/elearning/mfk-c1-m3/formation-longue.svg",
      "word": "formation longue"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Reformulez l'implicite de « la science a parlé » et la concession de Inès Mukama."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez une synthèse d'environ quatre-vingt-dix secondes : deux points de vue, un implicite, une proposition. Gardez le rapport du Filtre et la conférence d'Inès sous le figuier distincts."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CE — Le graphique n''efface pas la peur',
    'CE',
    $c$Objectif
Lire un texte argumenté long, synthétiser et reformuler. Rapporter une enquête du Filtre et expliciter une découverte sans triomphalisme. Viser la nuance, la collocation et l'implicite.

Consigne
Lisez « Le graphique n'efface pas la peur », sans aller trop vite. Repérez la thèse, la concession, l'implicite et la proposition.

Support — Le graphique n'efface pas la peur
On parle trop vite de une découverte du Filtre des Herbes, comme si le mot dispensait d'en examiner le prix.
Encore que l'on close la peur par un graphique, une crainte qui n'est pas une ignorance n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Inès Mukama concède que un résultat peut rassurer, pour autant que l'on dise aussi ce que l'enquête n'a pas vu.
Ce que l'on nomme enquête, ici, n'est pas un slogan : recherche datée, avec limites.
Inès : il apparaîtrait que le risque baisse, et j'entends déjà ceux qui veulent que je cesse le conditionnel.
Hawa : ma crainte n'est pas une erreur de calcul.
Karim exige la taille de l'échantillon, pas le mot miracle.
Aline : modaliser, c'est rester honnête.
Patrick veut une mini-conférence, pas une messe.
Solange demande ce que l'on fera des deux craintes hors graphique.
Un chiffre, une trace : Le Filtre avance : risque moindre dans un échantillon inventé de quarante bols ; deux craintes non mesurées restent sur le banc.
L'enjeu n'est pas d'avoir raison plus fort : il s'agit de nommer le progrès sans chasser la crainte comme une honte
Lila notera le conditionnel à l'antenne, exprès.
Hawa Diallo entend, dans « la science a parlé », ceci qui n'est pas dit : la science a parlé sert parfois à ne plus écouter ceux qui ont peur pour de vraies raisons
Autrement dit, il apparaîtrait que le filtre réduit un risque : ce conditionnel de prudence n'est pas une faiblesse
La proposition qui reste debout est celle-ci : une mini-conférence : résultat, limite, crainte légitime, geste de cour
Marc : expliciter une découverte, c'est aussi dire où elle s'arrête.
Nous clôturons sans fusionner les voix : le rapport du Filtre d'un côté, la conférence d'Inès sous le figuier de l'autre, et le point où elles refusent de se ressembler.
Signé : Inès Mukama, Rukiri-Nord — Cahier des racines, Rukiri-Nord.
$c$,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Le texte refuse de fusionner le rapport du Filtre et la conférence d'Inès sous le figuier en une seule affiche.",
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
      "text": "Quarante bols, risque moindre, deux craintes hors graphique",
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
  "explanation": "Le Filtre avance : risque moindre dans un échantillon inventé de quarante bols ; deux craintes non mesurées restent sur le banc."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "enquête",
      "right": "recherche datée, avec limites"
    },
    {
      "left": "découverte",
      "right": "résultat, pas un triomphe"
    },
    {
      "left": "crainte",
      "right": "peur fondée, distincte de l'ignorance"
    },
    {
      "left": "échantillon",
      "right": "portion observée, pas tout le Seuil"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nCes chiffres ___ une peur, ils ne la prouvent pas à eux seuls. (illustrer)",
  "answer": "illustrent"
}$j$::jsonb,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Remettez les mots dans l''ordre',
    'word_order',
    $j${
  "words": [
    "Ces",
    "chiffres",
    "illustrent",
    "une",
    "peur",
    "ils",
    "ne",
    "la",
    "prouvent",
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
  "word": "découverte",
  "hint": "résultat, pas un triomphe"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "La enquête de trop vite n'aide personne, et Hawa Diallo reprend le fil.",
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
      "image_path": "/elearning/mfk-c1-m3/miniconference.svg",
      "word": "miniconference"
    },
    {
      "image_path": "/elearning/mfk-c1-m3/graphique-peur.svg",
      "word": "graphique peur"
    },
    {
      "image_path": "/elearning/mfk-c1-m3/formation-longue.svg",
      "word": "formation longue"
    },
    {
      "image_path": "/elearning/mfk-c1-m3/journal-intime.svg",
      "word": "journal intime"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Synthétisez « Le graphique n'efface pas la peur » : thèse, concession, implicite, proposition (quinze lignes)."
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
    'PO — Le graphique n''efface pas la peur : dire sans slogan',
    'PO',
    $c$Objectif
Produire un oral structuré (thèse, concession, proposition). Point : rapporter une enquête ; il apparaîtrait que ; modalisation.

Consigne
Répétez les modèles, puis prenez position en une minute : thèse, concession, reformulation, proposition.

Support — Modèles d'Aline Uwase, banc du figuier
Encore que l'on close la peur par un graphique, une crainte qui n'est pas une ignorance n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Inès Mukama concède que un résultat peut rassurer, pour autant que l'on dise aussi ce que l'enquête n'a pas vu.
Ce que l'on nomme enquête, ici, n'est pas un slogan : recherche datée, avec limites.
Encore que l'on rapporte, une crainte qui n'est pas une ignorance n'est pas un détail.
Inès Mukama concède que un résultat peut rassurer, pour autant que l'on dise aussi ce que l'enquête n'a pas vu.
Autrement dit, il apparaîtrait que le filtre réduit un risque : ce conditionnel de prudence n'est pas une faiblesse
Il ressort qu'une mini-conférence : résultat, limite, crainte légitime, geste de cour
Hawa : ma crainte n'est pas une erreur de calcul.
Patrick veut une mini-conférence, pas une messe.
La proposition qui reste debout est celle-ci : une mini-conférence : résultat, limite, crainte légitime, geste de cour
Je concède le point, je n'abandonne pas la proposition.
Ce n'est pas que je refuse : c'est que je refuse qu'on nomme cela un détail.
Autrement dit, l'implicite fait autant de travail que la thèse.
En une minute : fait, angle, concession, proposition.
Nous clôturons sans fusionner les voix : le rapport du Filtre d'un côté, la conférence d'Inès sous le figuier de l'autre, et le point où elles refusent de se ressembler.
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
  "statement": "Inès Mukama transforme la concession en abandon de toute proposition.",
  "correct": false,
  "explanation": "Inès Mukama concède que un résultat peut rassurer, pour autant que l'on dise aussi ce que l'enquête n'a pas vu."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Que concède Inès Mukama, et à quelle condition ?",
  "options": [
    {
      "text": "Inès Mukama n'accorde rien et ferme le banc",
      "correct": false
    },
    {
      "text": "un résultat peut rassurer — à condition que l'on dise aussi ce que l'enquête n'a pas vu",
      "correct": true
    },
    {
      "text": "Inès Mukama abandonne il s'agit de nommer le progrès sans chasser la crainte comme une honte",
      "correct": false
    },
    {
      "text": "La concession vaut acceptation du slogan",
      "correct": false
    }
  ],
  "explanation": "Concession réelle, pas un abandon : l'on dise aussi ce que l'enquête n'a pas vu"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "enquête",
      "right": "recherche datée, avec limites"
    },
    {
      "left": "découverte",
      "right": "résultat, pas un triomphe"
    },
    {
      "left": "crainte",
      "right": "peur fondée, distincte de l'ignorance"
    },
    {
      "left": "échantillon",
      "right": "portion observée, pas tout le Seuil"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nAlors que le sel ___, le jardin tient encore. (monter)",
  "answer": "monte"
}$j$::jsonb,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Remettez les mots dans l''ordre',
    'word_order',
    $j${
  "words": [
    "Alors",
    "que",
    "le",
    "sel",
    "monte",
    "le",
    "jardin",
    "tient",
    "encore",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "crainte",
  "hint": "peur fondée, distincte de l'ignorance"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Inès Mukama écoute encore, et il fautons rapporter avant de crier.",
  "correct_sentence": "Inès Mukama écoute encore, et il faut rapporter avant de crier.",
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
      "image_path": "/elearning/mfk-c1-m3/graphique-peur.svg",
      "word": "graphique peur"
    },
    {
      "image_path": "/elearning/mfk-c1-m3/formation-longue.svg",
      "word": "formation longue"
    },
    {
      "image_path": "/elearning/mfk-c1-m3/journal-intime.svg",
      "word": "journal intime"
    },
    {
      "image_path": "/elearning/mfk-c1-m3/garde-nuit.svg",
      "word": "garde nuit"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Écrivez six phrases orales justes : deux sur rapporter une enquête ; il apparaîtrait que ; modalisation, deux concessions, deux propositions."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez quatre modèles, puis votre prise de position (thèse, concession, proposition). Gardez le rapport du Filtre et la conférence d'Inès sous le figuier distincts."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PE — le texte de Inès Mukama',
    'PE',
    $c$Objectif
Écrire un texte long et structuré. Rapporter une enquête du Filtre et expliciter une découverte sans triomphalisme. Point : rapporter une enquête ; il apparaîtrait que ; modalisation.

Consigne
Imitez le texte de Inès Mukama.

Support — Inès Mukama — Le graphique n'efface pas la peur
Inès Mukama — Le graphique n'efface pas la peur
On parle trop vite de une découverte du Filtre des Herbes, comme si le mot dispensait d'en examiner le prix.
Encore que l'on close la peur par un graphique, une crainte qui n'est pas une ignorance n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Inès Mukama concède que un résultat peut rassurer, pour autant que l'on dise aussi ce que l'enquête n'a pas vu.
Ce que l'on nomme enquête, ici, n'est pas un slogan : recherche datée, avec limites.
Inès : il apparaîtrait que le risque baisse, et j'entends déjà ceux qui veulent que je cesse le conditionnel.
Patrick veut une mini-conférence, pas une messe.
Solange demande ce que l'on fera des deux craintes hors graphique.
Lila notera le conditionnel à l'antenne, exprès.
La proposition qui reste debout est celle-ci : une mini-conférence : résultat, limite, crainte légitime, geste de cour
Marc : expliciter une découverte, c'est aussi dire où elle s'arrête.
Nous clôturons sans fusionner les voix : le rapport du Filtre d'un côté, la conférence d'Inès sous le figuier de l'autre, et le point où elles refusent de se ressembler.
Encore que l'on rapporte, une crainte qui n'est pas une ignorance n'est pas un détail.
Inès Mukama concède que un résultat peut rassurer, pour autant que l'on dise aussi ce que l'enquête n'a pas vu.
Je n'écris pas pour vaincre : j'écris pour que la cour puisse relire.
il apparaîtrait que le filtre réduit un risque : ce conditionnel de prudence n'est pas une faiblesse
Inès Mukama, Rukiri-Nord
$c$,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "La proposition retenue est : une mini-conférence : résultat, limite, crainte légitime, geste de cour",
  "correct": true,
  "explanation": "une mini-conférence : résultat, limite, crainte légitime, geste de cour"
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
      "text": "une mini-conférence : résultat, limite, crainte légitime, geste de cour",
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
  "explanation": "une mini-conférence : résultat, limite, crainte légitime, geste de cour"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "enquête",
      "right": "recherche datée, avec limites"
    },
    {
      "left": "découverte",
      "right": "résultat, pas un triomphe"
    },
    {
      "left": "crainte",
      "right": "peur fondée, distincte de l'ignorance"
    },
    {
      "left": "échantillon",
      "right": "portion observée, pas tout le Seuil"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nIl conviendrait que l'on ___ sans crier. (rapporter, subj.)",
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
    "Il",
    "conviendrait",
    "que",
    "l'on",
    "rapporte",
    "sans",
    "crier",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "échantillon",
  "hint": "portion observée, pas tout le Seuil"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Les arguments de Inès Mukama est clairs, et Lila garde le micro ouvert.",
  "correct_sentence": "Les arguments de Inès Mukama sont clairs, et Lila garde le micro ouvert.",
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
      "image_path": "/elearning/mfk-c1-m3/formation-longue.svg",
      "word": "formation longue"
    },
    {
      "image_path": "/elearning/mfk-c1-m3/journal-intime.svg",
      "word": "journal intime"
    },
    {
      "image_path": "/elearning/mfk-c1-m3/garde-nuit.svg",
      "word": "garde nuit"
    },
    {
      "image_path": "/elearning/mfk-c1-m3/blouse-inventee.svg",
      "word": "blouse inventee"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Imitez le texte de Inès Mukama : vingt lignes, deux voix, une concession, une proposition."
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
    'EL — rapporter une enquête ; il apparaîtrait que ; modalisation',
    'EL',
    $c$Objectif
Maîtriser rapporter une enquête ; il apparaîtrait que ; modalisation au registre C1, avec collocations et pièges de construction.

Consigne
Apprenez la fiche, puis produisez des exemples justes au registre demandé.

Support — Fiche d'Aline Uwase, banc ocre
Fiche C1 — rapporter une enquête ; il apparaîtrait que ; modalisation
On ne retient pas une liste : on retient des constructions et des collocations.
Encore que l'on rapporte, une crainte qui n'est pas une ignorance n'est pas un détail.
Inès Mukama concède que un résultat peut rassurer, pour autant que l'on dise aussi ce que l'enquête n'a pas vu.
Autrement dit, il apparaîtrait que le filtre réduit un risque : ce conditionnel de prudence n'est pas une faiblesse
Il ressort qu'une mini-conférence : résultat, limite, crainte légitime, geste de cour
Piège : prendre un pourcentage pour une preuve morale
Registre : soutenu argumentatif, sans slogan
Collocation : encore que, pour autant que, il ressort que
Ce que l'on nomme enquête, ici, n'est pas un slogan : recherche datée, avec limites.
Hawa : ma crainte n'est pas une erreur de calcul.
Patrick veut une mini-conférence, pas une messe.
Nominaliser, ce n'est pas alourdir : c'est nommer le processus (la densification, l'accueil, le rappel).
Encore que / pour autant que / si tant est que : subjonctif, concession réelle, pas un ornement.
Reformuler une source : on change la syntaxe, on garde la charge, on signale le point de vue.
C1 : l'implicite se justifie. C2 : l'ironie se laisse entendre sans s'afficher.
Exemple fautif à ne plus produire : On va au crainte pour de vrai genre, et Hawa Diallo demande un registre plus net.
Correction : On va au crainte vraiment, et Hawa Diallo demande un registre plus net.
Aline Uwase, banc ocre — Le Seuil des Sources.
$c$,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Un chiffre peut illustrer sans conclure à lui seul.",
  "correct": true,
  "explanation": "Prudence énonciative."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Comment introduire un chiffre sans en faire une sentence ?",
  "options": [
    {
      "text": "s'établir à / illustrer / alors que",
      "correct": true
    },
    {
      "text": "c'est vrai parce que chiffre",
      "correct": false
    },
    {
      "text": "le micro interdit les nombres",
      "correct": false
    },
    {
      "text": "on crie le pourcentage",
      "correct": false
    }
  ],
  "explanation": "Langue des données : s'établir à, illustrer, opposer."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "enquête",
      "right": "recherche datée, avec limites"
    },
    {
      "left": "découverte",
      "right": "résultat, pas un triomphe"
    },
    {
      "left": "crainte",
      "right": "peur fondée, distincte de l'ignorance"
    },
    {
      "left": "échantillon",
      "right": "portion observée, pas tout le Seuil"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nUne ___ n'est pas une sentence. (statistique)",
  "answer": "statistique"
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
    "statistique",
    "n'est",
    "pas",
    "une",
    "sentence",
    "."
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
  "sentence_with_error": "On va au crainte pour de vrai genre, et Hawa Diallo demande un registre plus net.",
  "correct_sentence": "On va au crainte vraiment, et Hawa Diallo demande un registre plus net.",
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
      "image_path": "/elearning/mfk-c1-m3/journal-intime.svg",
      "word": "journal intime"
    },
    {
      "image_path": "/elearning/mfk-c1-m3/garde-nuit.svg",
      "word": "garde nuit"
    },
    {
      "image_path": "/elearning/mfk-c1-m3/blouse-inventee.svg",
      "word": "blouse inventee"
    },
    {
      "image_path": "/elearning/mfk-c1-m3/therapie-rive.svg",
      "word": "therapie rive"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Tableau de langue : six exemples justes de « rapporter une enquête ; il apparaîtrait que ; modalisation » et deux pièges commentés."
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

  -- ===== Une vie de formation =====
  SELECT s.id INTO v_seq_id
  FROM elearning_sequences s
  WHERE s.module_id = v_module_id AND s.title = 'Une vie de formation'
  LIMIT 1;

  IF v_seq_id IS NULL THEN
    INSERT INTO elearning_sequences (module_id, title, order_index)
    VALUES (v_module_id, 'Une vie de formation', 2)
    RETURNING id INTO v_seq_id;
  ELSE
    UPDATE elearning_sequences
    SET order_index = 2
    WHERE id = v_seq_id;
  END IF;

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CO — Une vie de formation',
    'CO',
    $c$Objectif
Comprendre un échange long et en extraire l'implicite. Raconter les difficultés d'une formation trop longue sans pathos de sacrifice. Viser la nuance, la collocation et l'implicite.

Consigne
Lisez le débat (à écouter avec l'enseignant). Qu'est-ce qui est dit, qu'est-ce qui reste implicite, qui concède quoi ?

Support — Débat Radio Figuier — Une vie de formation
Lila Sow : Radio Figuier. On parle trop vite de une formation trop longue au Seuil, comme si le mot dispensait d'en examiner le prix.
Marc Nkurunziza : Encore que l'on transforme l'épuisement en vertu, des gardes qui volent les heures d'écriture d'Aline n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Léa Niyonzima : Aline Uwase concède que apprendre longtemps peut être juste, pour autant que l'on n'appelle pas vocation ce qui use sans transmettre.
Aline Uwase : Ce que l'on nomme formation, ici, n'est pas un slogan : temps d'apprendre, pas une épreuve sacrée.
Patrick Habimana : Aline : j'avais cru que former, c'était parler ; j'ai appris que c'était d'abord ne pas disparaître.
Hawa Diallo : Patrick lit le journal sans corriger l'émotion, seulement la syntaxe.
Joël Mugisha : Inès reconnaît les gardes : elle les a faites, elle refuse d'en faire une légende.
Rose Iradukunda : Hawa dit qu'une élève n'a pas à payer le sommeil de la formatrice.
Solange Mukamana : Lila n'enregistrera le journal que si Aline le veut.
Karim Bamba : Dieudonné apporte du thé à l'aube, sans discours.
Félicie Ndayishimiye : Un chiffre, une trace : Aline a noté vingt gardes, quatre cours manqués, une élève qui attend encore la fiche.
Dieudonné Hakizimana : L'enjeu n'est pas d'avoir raison plus fort : il s'agit que la transmission ne meure pas sous le mot sacrifice
Yvette : Yvette : un métier difficile n'est pas une religion.
Mado : Patrick Habimana entend, dans « c'est le prix à payer », ceci qui n'est pas dit : c'est le prix à payer interdit souvent de demander qui encaisse
Sami : Autrement dit, le journal n'est pas une plainte : c'est une archive de ce que la blouse cache
Lila Sow : Je reformule pour les auditeurs. La proposition qui reste debout est celle-ci : trois pages de journal : faits, doute, ce qui reste transmissible
Nina Kayitesi : Marc : selon le journal, il ressort que la transmission exige des heures, pas un martyre.
Lila Sow : Nous clôturons sans clore. Nous clôturons sans fusionner les voix : le journal d'Aline d'un côté, l'émission où l'on parle trop vite de vocation de l'autre, et le point où elles refusent de se ressembler.
$c$,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "des gardes qui volent les heures d'écriture d'Aline est présenté comme un simple détail sans conséquence.",
  "correct": false,
  "explanation": "Le texte affirme au contraire que des gardes qui volent les heures d'écriture d'Aline n'est pas un détail."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Selon Patrick Habimana, que reste-t-il implicite dans « c'est le prix à payer » ?",
  "options": [
    {
      "text": "Que Aline quitte le Seuil demain",
      "correct": false
    },
    {
      "text": "Interdiction de demander qui encaisse",
      "correct": true
    },
    {
      "text": "Que Patrick interdit les journaux",
      "correct": false
    },
    {
      "text": "Que les gardes sont une fête",
      "correct": false
    }
  ],
  "explanation": "c'est le prix à payer interdit souvent de demander qui encaisse"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "formation",
      "right": "temps d'apprendre, pas une épreuve sacrée"
    },
    {
      "left": "journal",
      "right": "écriture datée, archive du doute"
    },
    {
      "left": "garde",
      "right": "heure prise sur le sommeil et la transmission"
    },
    {
      "left": "vocation",
      "right": "mot trop large, parfois une excuse"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nSelon Aline, il ___ que deux documents s'opposent. (ressortir)",
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
    "Aline",
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
  "word": "formation",
  "hint": "temps d'apprendre, pas une épreuve sacrée"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Selon Aline Uwase, il ressort que les deux textes est d'accord, et Lila coupe le micro.",
  "correct_sentence": "Selon Aline Uwase, il ressort que les deux textes sont d'accord, et Lila coupe le micro.",
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
      "image_path": "/elearning/mfk-c1-m3/garde-nuit.svg",
      "word": "garde nuit"
    },
    {
      "image_path": "/elearning/mfk-c1-m3/blouse-inventee.svg",
      "word": "blouse inventee"
    },
    {
      "image_path": "/elearning/mfk-c1-m3/therapie-rive.svg",
      "word": "therapie rive"
    },
    {
      "image_path": "/elearning/mfk-c1-m3/debat-naturel.svg",
      "word": "debat naturel"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Reformulez l'implicite de « c'est le prix à payer » et la concession de Aline Uwase."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez une synthèse d'environ quatre-vingt-dix secondes : deux points de vue, un implicite, une proposition. Gardez le journal d'Aline et l'émission où l'on parle trop vite de vocation distincts."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CE — Ce que la blouse cache',
    'CE',
    $c$Objectif
Lire un texte argumenté long, synthétiser et reformuler. Raconter les difficultés d'une formation trop longue sans pathos de sacrifice. Viser la nuance, la collocation et l'implicite.

Consigne
Lisez « Ce que la blouse cache », sans aller trop vite. Repérez la thèse, la concession, l'implicite et la proposition.

Support — Ce que la blouse cache
On parle trop vite de une formation trop longue au Seuil, comme si le mot dispensait d'en examiner le prix.
Encore que l'on transforme l'épuisement en vertu, des gardes qui volent les heures d'écriture d'Aline n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Aline Uwase concède que apprendre longtemps peut être juste, pour autant que l'on n'appelle pas vocation ce qui use sans transmettre.
Ce que l'on nomme formation, ici, n'est pas un slogan : temps d'apprendre, pas une épreuve sacrée.
Aline : j'avais cru que former, c'était parler ; j'ai appris que c'était d'abord ne pas disparaître.
Patrick lit le journal sans corriger l'émotion, seulement la syntaxe.
Inès reconnaît les gardes : elle les a faites, elle refuse d'en faire une légende.
Hawa dit qu'une élève n'a pas à payer le sommeil de la formatrice.
Lila n'enregistrera le journal que si Aline le veut.
Dieudonné apporte du thé à l'aube, sans discours.
Un chiffre, une trace : Aline a noté vingt gardes, quatre cours manqués, une élève qui attend encore la fiche.
L'enjeu n'est pas d'avoir raison plus fort : il s'agit que la transmission ne meure pas sous le mot sacrifice
Yvette : un métier difficile n'est pas une religion.
Patrick Habimana entend, dans « c'est le prix à payer », ceci qui n'est pas dit : c'est le prix à payer interdit souvent de demander qui encaisse
Autrement dit, le journal n'est pas une plainte : c'est une archive de ce que la blouse cache
La proposition qui reste debout est celle-ci : trois pages de journal : faits, doute, ce qui reste transmissible
Marc : selon le journal, il ressort que la transmission exige des heures, pas un martyre.
Nous clôturons sans fusionner les voix : le journal d'Aline d'un côté, l'émission où l'on parle trop vite de vocation de l'autre, et le point où elles refusent de se ressembler.
Signé : Aline Uwase, Rukiri-Nord — Cahier des racines, Rukiri-Nord.
$c$,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Le texte refuse de fusionner le journal d'Aline et l'émission où l'on parle trop vite de vocation en une seule affiche.",
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
      "text": "Vingt gardes, quatre cours manqués, une élève en attente",
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
  "explanation": "Aline a noté vingt gardes, quatre cours manqués, une élève qui attend encore la fiche."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "formation",
      "right": "temps d'apprendre, pas une épreuve sacrée"
    },
    {
      "left": "journal",
      "right": "écriture datée, archive du doute"
    },
    {
      "left": "garde",
      "right": "heure prise sur le sommeil et la transmission"
    },
    {
      "left": "vocation",
      "right": "mot trop large, parfois une excuse"
    }
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
  "word": "journal",
  "hint": "écriture datée, archive du doute"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "La formation de trop vite n'aide personne, et Patrick Habimana reprend le fil.",
  "correct_sentence": "La précipitation n'aide personne, et Patrick Habimana reprend le fil.",
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
      "image_path": "/elearning/mfk-c1-m3/blouse-inventee.svg",
      "word": "blouse inventee"
    },
    {
      "image_path": "/elearning/mfk-c1-m3/therapie-rive.svg",
      "word": "therapie rive"
    },
    {
      "image_path": "/elearning/mfk-c1-m3/debat-naturel.svg",
      "word": "debat naturel"
    },
    {
      "image_path": "/elearning/mfk-c1-m3/infusion-solange.svg",
      "word": "infusion solange"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Synthétisez « Ce que la blouse cache » : thèse, concession, implicite, proposition (quinze lignes)."
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
    'PO — Une vie de formation : dire sans slogan',
    'PO',
    $c$Objectif
Produire un oral structuré (thèse, concession, proposition). Point : journal intime ; imparfait / plus-que-parfait ; modalisation du doute.

Consigne
Répétez les modèles, puis prenez position en une minute : thèse, concession, reformulation, proposition.

Support — Modèles d'Aline Uwase, banc du figuier
Encore que l'on transforme l'épuisement en vertu, des gardes qui volent les heures d'écriture d'Aline n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Aline Uwase concède que apprendre longtemps peut être juste, pour autant que l'on n'appelle pas vocation ce qui use sans transmettre.
Ce que l'on nomme formation, ici, n'est pas un slogan : temps d'apprendre, pas une épreuve sacrée.
Encore que l'on écrive, des gardes qui volent les heures d'écriture d'Aline n'est pas un détail.
Aline Uwase concède que apprendre longtemps peut être juste, pour autant que l'on n'appelle pas vocation ce qui use sans transmettre.
Autrement dit, le journal n'est pas une plainte : c'est une archive de ce que la blouse cache
Il ressort que trois pages de journal : faits, doute, ce qui reste transmissible
Patrick lit le journal sans corriger l'émotion, seulement la syntaxe.
Lila n'enregistrera le journal que si Aline le veut.
La proposition qui reste debout est celle-ci : trois pages de journal : faits, doute, ce qui reste transmissible
Je concède le point, je n'abandonne pas la proposition.
Ce n'est pas que je refuse : c'est que je refuse qu'on nomme cela un détail.
Autrement dit, l'implicite fait autant de travail que la thèse.
En une minute : fait, angle, concession, proposition.
Nous clôturons sans fusionner les voix : le journal d'Aline d'un côté, l'émission où l'on parle trop vite de vocation de l'autre, et le point où elles refusent de se ressembler.
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
  "explanation": "Aline Uwase concède que apprendre longtemps peut être juste, pour autant que l'on n'appelle pas vocation ce qui use sans transmettre."
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
      "text": "apprendre longtemps peut être juste — à condition que l'on n'appelle pas vocation ce qui use sans transmettre",
      "correct": true
    },
    {
      "text": "Aline Uwase abandonne il s'agit que la transmission ne meure pas sous le mot sacrifice",
      "correct": false
    },
    {
      "text": "La concession vaut acceptation du slogan",
      "correct": false
    }
  ],
  "explanation": "Concession réelle, pas un abandon : l'on n'appelle pas vocation ce qui use sans transmettre"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "formation",
      "right": "temps d'apprendre, pas une épreuve sacrée"
    },
    {
      "left": "journal",
      "right": "écriture datée, archive du doute"
    },
    {
      "left": "garde",
      "right": "heure prise sur le sommeil et la transmission"
    },
    {
      "left": "vocation",
      "right": "mot trop large, parfois une excuse"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nIl appert que formation n'est pas un slogan.",
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
  "word": "garde",
  "hint": "heure prise sur le sommeil et la transmission"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Aline Uwase écoute encore, et il fautons écrire avant de crier.",
  "correct_sentence": "Aline Uwase écoute encore, et il faut écrire avant de crier.",
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
      "image_path": "/elearning/mfk-c1-m3/therapie-rive.svg",
      "word": "therapie rive"
    },
    {
      "image_path": "/elearning/mfk-c1-m3/debat-naturel.svg",
      "word": "debat naturel"
    },
    {
      "image_path": "/elearning/mfk-c1-m3/infusion-solange.svg",
      "word": "infusion solange"
    },
    {
      "image_path": "/elearning/mfk-c1-m3/cabinet-ombre.svg",
      "word": "cabinet ombre"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Écrivez six phrases orales justes : deux sur journal intime ; imparfait / plus-que-parfait ; modalisation du doute, deux concessions, deux propositions."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez quatre modèles, puis votre prise de position (thèse, concession, proposition). Gardez le journal d'Aline et l'émission où l'on parle trop vite de vocation distincts."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PE — le texte de Aline Uwase',
    'PE',
    $c$Objectif
Écrire un texte long et structuré. Raconter les difficultés d'une formation trop longue sans pathos de sacrifice. Point : journal intime ; imparfait / plus-que-parfait ; modalisation du doute.

Consigne
Imitez le texte de Aline Uwase.

Support — Aline Uwase — Ce que la blouse cache
Aline Uwase — Ce que la blouse cache
On parle trop vite de une formation trop longue au Seuil, comme si le mot dispensait d'en examiner le prix.
Encore que l'on transforme l'épuisement en vertu, des gardes qui volent les heures d'écriture d'Aline n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Aline Uwase concède que apprendre longtemps peut être juste, pour autant que l'on n'appelle pas vocation ce qui use sans transmettre.
Ce que l'on nomme formation, ici, n'est pas un slogan : temps d'apprendre, pas une épreuve sacrée.
Aline : j'avais cru que former, c'était parler ; j'ai appris que c'était d'abord ne pas disparaître.
Lila n'enregistrera le journal que si Aline le veut.
Dieudonné apporte du thé à l'aube, sans discours.
Yvette : un métier difficile n'est pas une religion.
La proposition qui reste debout est celle-ci : trois pages de journal : faits, doute, ce qui reste transmissible
Marc : selon le journal, il ressort que la transmission exige des heures, pas un martyre.
Nous clôturons sans fusionner les voix : le journal d'Aline d'un côté, l'émission où l'on parle trop vite de vocation de l'autre, et le point où elles refusent de se ressembler.
Encore que l'on écrive, des gardes qui volent les heures d'écriture d'Aline n'est pas un détail.
Aline Uwase concède que apprendre longtemps peut être juste, pour autant que l'on n'appelle pas vocation ce qui use sans transmettre.
Je n'écris pas pour vaincre : j'écris pour que la cour puisse relire.
le journal n'est pas une plainte : c'est une archive de ce que la blouse cache
Aline Uwase, Rukiri-Nord
$c$,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "La proposition retenue est : trois pages de journal : faits, doute, ce qui reste transmissible",
  "correct": true,
  "explanation": "trois pages de journal : faits, doute, ce qui reste transmissible"
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
      "text": "trois pages de journal : faits, doute, ce qui reste transmissible",
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
  "explanation": "trois pages de journal : faits, doute, ce qui reste transmissible"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "formation",
      "right": "temps d'apprendre, pas une épreuve sacrée"
    },
    {
      "left": "journal",
      "right": "écriture datée, archive du doute"
    },
    {
      "left": "garde",
      "right": "heure prise sur le sommeil et la transmission"
    },
    {
      "left": "vocation",
      "right": "mot trop large, parfois une excuse"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nEncore que l'on ___ les deux sources, on ne les fusionne pas. (écrire, subj.)",
  "answer": "écrive"
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
    "écrive",
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
  "word": "vocation",
  "hint": "mot trop large, parfois une excuse"
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
      "image_path": "/elearning/mfk-c1-m3/debat-naturel.svg",
      "word": "debat naturel"
    },
    {
      "image_path": "/elearning/mfk-c1-m3/infusion-solange.svg",
      "word": "infusion solange"
    },
    {
      "image_path": "/elearning/mfk-c1-m3/cabinet-ombre.svg",
      "word": "cabinet ombre"
    },
    {
      "image_path": "/elearning/mfk-c1-m3/podcast-parcours.svg",
      "word": "podcast parcours"
    }
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
    'EL — journal intime ; imparfait / plus-que-parfait ; modalisation du doute',
    'EL',
    $c$Objectif
Maîtriser journal intime ; imparfait / plus-que-parfait ; modalisation du doute au registre C1, avec collocations et pièges de construction.

Consigne
Apprenez la fiche, puis produisez des exemples justes au registre demandé.

Support — Fiche d'Aline Uwase, banc ocre
Fiche C1 — journal intime ; imparfait / plus-que-parfait ; modalisation du doute
On ne retient pas une liste : on retient des constructions et des collocations.
Encore que l'on écrive, des gardes qui volent les heures d'écriture d'Aline n'est pas un détail.
Aline Uwase concède que apprendre longtemps peut être juste, pour autant que l'on n'appelle pas vocation ce qui use sans transmettre.
Autrement dit, le journal n'est pas une plainte : c'est une archive de ce que la blouse cache
Il ressort que trois pages de journal : faits, doute, ce qui reste transmissible
Piège : fusionner les sources au lieu de les attribuer (selon / d'après)
Registre : soutenu argumentatif, sans slogan
Collocation : encore que, pour autant que, il ressort que
Ce que l'on nomme formation, ici, n'est pas un slogan : temps d'apprendre, pas une épreuve sacrée.
Patrick lit le journal sans corriger l'émotion, seulement la syntaxe.
Lila n'enregistrera le journal que si Aline le veut.
Nominaliser, ce n'est pas alourdir : c'est nommer le processus (la densification, l'accueil, le rappel).
Encore que / pour autant que / si tant est que : subjonctif, concession réelle, pas un ornement.
Reformuler une source : on change la syntaxe, on garde la charge, on signale le point de vue.
C1 : l'implicite se justifie. C2 : l'ironie se laisse entendre sans s'afficher.
Exemple fautif à ne plus produire : On va au garde pour de vrai genre, et Patrick Habimana demande un registre plus net.
Correction : On va au garde vraiment, et Patrick Habimana demande un registre plus net.
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
      "left": "formation",
      "right": "temps d'apprendre, pas une épreuve sacrée"
    },
    {
      "left": "journal",
      "right": "écriture datée, archive du doute"
    },
    {
      "left": "garde",
      "right": "heure prise sur le sommeil et la transmission"
    },
    {
      "left": "vocation",
      "right": "mot trop large, parfois une excuse"
    }
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
  "sentence_with_error": "On va au garde pour de vrai genre, et Patrick Habimana demande un registre plus net.",
  "correct_sentence": "On va au garde vraiment, et Patrick Habimana demande un registre plus net.",
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
      "image_path": "/elearning/mfk-c1-m3/infusion-solange.svg",
      "word": "infusion solange"
    },
    {
      "image_path": "/elearning/mfk-c1-m3/cabinet-ombre.svg",
      "word": "cabinet ombre"
    },
    {
      "image_path": "/elearning/mfk-c1-m3/podcast-parcours.svg",
      "word": "podcast parcours"
    },
    {
      "image_path": "/elearning/mfk-c1-m3/studio-sante.svg",
      "word": "studio sante"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Tableau de langue : six exemples justes de « journal intime ; imparfait / plus-que-parfait ; modalisation du doute » et deux pièges commentés."
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

  -- ===== L'herbe et la porte =====
  SELECT s.id INTO v_seq_id
  FROM elearning_sequences s
  WHERE s.module_id = v_module_id AND s.title = 'L''herbe et la porte'
  LIMIT 1;

  IF v_seq_id IS NULL THEN
    INSERT INTO elearning_sequences (module_id, title, order_index)
    VALUES (v_module_id, 'L''herbe et la porte', 3)
    RETURNING id INTO v_seq_id;
  ELSE
    UPDATE elearning_sequences
    SET order_index = 3
    WHERE id = v_seq_id;
  END IF;

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CO — L''herbe et la porte',
    'CO',
    $c$Objectif
Comprendre un échange long et en extraire l'implicite. Présenter une polémique sur les infusions de Solange sans caricature. Viser la nuance, la collocation et l'implicite.

Consigne
Lisez le débat (à écouter avec l'enseignant). Qu'est-ce qui est dit, qu'est-ce qui reste implicite, qui concède quoi ?

Support — Débat Radio Figuier — L'herbe et la porte
Lila Sow : Radio Figuier. On parle trop vite de les infusions de Solange Mukamana, comme si le mot dispensait d'en examiner le prix.
Marc Nkurunziza : Encore que l'on remplace l'infirmerie par une casserole, une confiance trop simple dans l'herbe n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Léa Niyonzima : Solange Mukamana concède que une infusion peut apaiser, pour autant que l'on n'y voie pas un remplacement du consentement et du suivi.
Aline Uwase : Ce que l'on nomme polémique, ici, n'est pas un slogan : désaccord public à présenter, non à envenimer.
Patrick Habimana : Solange : certains affirment que l'herbe suffit ; je n'ai jamais dit cela, j'ai dit qu'elle console.
Hawa Diallo : Inès : d'autres objectent que console veut dire guérir, et c'est là que les portes s'ouvrent trop tard.
Joël Mugisha : Aline exige les deux voix dans le même exposé.
Rose Iradukunda : Hawa a goûté l'infusion et gardé son rendez-vous.
Solange Mukamana : Karim refuse le donc trop rapide : naturel donc sûr.
Karim Bamba : Lila présentera la polémique sans chercher une gagnante.
Félicie Ndayishimiye : Un chiffre, une trace : Solange a servi douze infusions ; Inès a reçu trois personnes trop tard, persuadées que l'herbe suffisait.
Dieudonné Hakizimana : L'enjeu n'est pas d'avoir raison plus fort : il s'agit de soigner sans magie, ni mépris de l'herbe, ni abandon du suivi
Yvette : Dieudonné : une casserole n'est pas une infamie, c'est un outil.
Mado : Inès Mukama entend, dans « c'est naturel donc c'est sûr », ceci qui n'est pas dit : naturel donc sûr permet de vendre une calme ignorance
Sami : Autrement dit, la polémique n'est pas Solange contre Inès : c'est le mot sûr collé trop vite à l'herbe
Lila Sow : Je reformule pour les auditeurs. La proposition qui reste debout est celle-ci : présenter deux positions, une limite, un geste : l'herbe n'efface pas la porte d'Inès
Nina Kayitesi : Marc : expliquer le fonctionnement d'une thérapie, c'est aussi dire où elle s'arrête.
Lila Sow : Nous clôturons sans clore. Nous clôturons sans fusionner les voix : la chronique de Solange d'un côté, la mise au point d'Inès de l'autre, et le point où elles refusent de se ressembler.
$c$,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "une confiance trop simple dans l'herbe est présenté comme un simple détail sans conséquence.",
  "correct": false,
  "explanation": "Le texte affirme au contraire que une confiance trop simple dans l'herbe n'est pas un détail."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Selon Inès Mukama, que reste-t-il implicite dans « c'est naturel donc c'est sûr » ?",
  "options": [
    {
      "text": "Que Solange interdit l'infirmerie",
      "correct": false
    },
    {
      "text": "Vendre une calme ignorance",
      "correct": true
    },
    {
      "text": "Que Inès brûle les herbes",
      "correct": false
    },
    {
      "text": "Que le figuier guérit tout",
      "correct": false
    }
  ],
  "explanation": "naturel donc sûr permet de vendre une calme ignorance"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "polémique",
      "right": "désaccord public à présenter, non à envenimer"
    },
    {
      "left": "infusion",
      "right": "préparation d'herbe, parfois un apaisement"
    },
    {
      "left": "suivi",
      "right": "continuité du soin, plus qu'un bol chaud"
    },
    {
      "left": "limite",
      "right": "ligne où l'herbe ne remplace pas la porte"
    }
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
  "word": "polémique",
  "hint": "désaccord public à présenter, non à envenimer"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Du fait que le prix flambent, Solange Mukamana refuse d'appeler cela un caprice, et Oscar écoute.",
  "correct_sentence": "Du fait que le prix flambe, Solange Mukamana refuse d'appeler cela un caprice, et Oscar écoute.",
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
      "image_path": "/elearning/mfk-c1-m3/cabinet-ombre.svg",
      "word": "cabinet ombre"
    },
    {
      "image_path": "/elearning/mfk-c1-m3/podcast-parcours.svg",
      "word": "podcast parcours"
    },
    {
      "image_path": "/elearning/mfk-c1-m3/studio-sante.svg",
      "word": "studio sante"
    },
    {
      "image_path": "/elearning/mfk-c1-m3/oreille-doute.svg",
      "word": "oreille doute"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Reformulez l'implicite de « c'est naturel donc c'est sûr » et la concession de Solange Mukamana."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez une synthèse d'environ quatre-vingt-dix secondes : deux points de vue, un implicite, une proposition. Gardez la chronique de Solange et la mise au point d'Inès distincts."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CE — L''herbe n''est pas un sort',
    'CE',
    $c$Objectif
Lire un texte argumenté long, synthétiser et reformuler. Présenter une polémique sur les infusions de Solange sans caricature. Viser la nuance, la collocation et l'implicite.

Consigne
Lisez « L'herbe n'est pas un sort », sans aller trop vite. Repérez la thèse, la concession, l'implicite et la proposition.

Support — L'herbe n'est pas un sort
On parle trop vite de les infusions de Solange Mukamana, comme si le mot dispensait d'en examiner le prix.
Encore que l'on remplace l'infirmerie par une casserole, une confiance trop simple dans l'herbe n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Solange Mukamana concède que une infusion peut apaiser, pour autant que l'on n'y voie pas un remplacement du consentement et du suivi.
Ce que l'on nomme polémique, ici, n'est pas un slogan : désaccord public à présenter, non à envenimer.
Solange : certains affirment que l'herbe suffit ; je n'ai jamais dit cela, j'ai dit qu'elle console.
Inès : d'autres objectent que console veut dire guérir, et c'est là que les portes s'ouvrent trop tard.
Aline exige les deux voix dans le même exposé.
Hawa a goûté l'infusion et gardé son rendez-vous.
Karim refuse le donc trop rapide : naturel donc sûr.
Lila présentera la polémique sans chercher une gagnante.
Un chiffre, une trace : Solange a servi douze infusions ; Inès a reçu trois personnes trop tard, persuadées que l'herbe suffisait.
L'enjeu n'est pas d'avoir raison plus fort : il s'agit de soigner sans magie, ni mépris de l'herbe, ni abandon du suivi
Dieudonné : une casserole n'est pas une infamie, c'est un outil.
Inès Mukama entend, dans « c'est naturel donc c'est sûr », ceci qui n'est pas dit : naturel donc sûr permet de vendre une calme ignorance
Autrement dit, la polémique n'est pas Solange contre Inès : c'est le mot sûr collé trop vite à l'herbe
La proposition qui reste debout est celle-ci : présenter deux positions, une limite, un geste : l'herbe n'efface pas la porte d'Inès
Marc : expliquer le fonctionnement d'une thérapie, c'est aussi dire où elle s'arrête.
Nous clôturons sans fusionner les voix : la chronique de Solange d'un côté, la mise au point d'Inès de l'autre, et le point où elles refusent de se ressembler.
Signé : Solange Mukamana, Rukiri-Nord — Cahier des racines, Rukiri-Nord.
$c$,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Le texte refuse de fusionner la chronique de Solange et la mise au point d'Inès en une seule affiche.",
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
      "text": "Douze infusions, trois arrivées trop tard",
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
  "explanation": "Solange a servi douze infusions ; Inès a reçu trois personnes trop tard, persuadées que l'herbe suffisait."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "polémique",
      "right": "désaccord public à présenter, non à envenimer"
    },
    {
      "left": "infusion",
      "right": "préparation d'herbe, parfois un apaisement"
    },
    {
      "left": "suivi",
      "right": "continuité du soin, plus qu'un bol chaud"
    },
    {
      "left": "limite",
      "right": "ligne où l'herbe ne remplace pas la porte"
    }
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
  "word": "infusion",
  "hint": "préparation d'herbe, parfois un apaisement"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "La polémique de trop vite n'aide personne, et Inès Mukama reprend le fil.",
  "correct_sentence": "La précipitation n'aide personne, et Inès Mukama reprend le fil.",
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
      "image_path": "/elearning/mfk-c1-m3/podcast-parcours.svg",
      "word": "podcast parcours"
    },
    {
      "image_path": "/elearning/mfk-c1-m3/studio-sante.svg",
      "word": "studio sante"
    },
    {
      "image_path": "/elearning/mfk-c1-m3/oreille-doute.svg",
      "word": "oreille doute"
    },
    {
      "image_path": "/elearning/mfk-c1-m3/voix-hawa.svg",
      "word": "voix hawa"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Synthétisez « L'herbe n'est pas un sort » : thèse, concession, implicite, proposition (quinze lignes)."
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
    'PO — L''herbe et la porte : dire sans slogan',
    'PO',
    $c$Objectif
Produire un oral structuré (thèse, concession, proposition). Point : présenter une polémique ; certains affirment / d'autres objectent.

Consigne
Répétez les modèles, puis prenez position en une minute : thèse, concession, reformulation, proposition.

Support — Modèles d'Aline Uwase, banc du figuier
Encore que l'on remplace l'infirmerie par une casserole, une confiance trop simple dans l'herbe n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Solange Mukamana concède que une infusion peut apaiser, pour autant que l'on n'y voie pas un remplacement du consentement et du suivi.
Ce que l'on nomme polémique, ici, n'est pas un slogan : désaccord public à présenter, non à envenimer.
Encore que l'on présente, une confiance trop simple dans l'herbe n'est pas un détail.
Solange Mukamana concède que une infusion peut apaiser, pour autant que l'on n'y voie pas un remplacement du consentement et du suivi.
Autrement dit, la polémique n'est pas Solange contre Inès : c'est le mot sûr collé trop vite à l'herbe
Il ressort que présenter deux positions, une limite, un geste : l'herbe n'efface pas la porte d'Inès
Inès : d'autres objectent que console veut dire guérir, et c'est là que les portes s'ouvrent trop tard.
Karim refuse le donc trop rapide : naturel donc sûr.
La proposition qui reste debout est celle-ci : présenter deux positions, une limite, un geste : l'herbe n'efface pas la porte d'Inès
Je concède le point, je n'abandonne pas la proposition.
Ce n'est pas que je refuse : c'est que je refuse qu'on nomme cela un détail.
Autrement dit, l'implicite fait autant de travail que la thèse.
En une minute : fait, angle, concession, proposition.
Nous clôturons sans fusionner les voix : la chronique de Solange d'un côté, la mise au point d'Inès de l'autre, et le point où elles refusent de se ressembler.
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
  "statement": "Solange Mukamana transforme la concession en abandon de toute proposition.",
  "correct": false,
  "explanation": "Solange Mukamana concède que une infusion peut apaiser, pour autant que l'on n'y voie pas un remplacement du consentement et du suivi."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Que concède Solange Mukamana, et à quelle condition ?",
  "options": [
    {
      "text": "Solange Mukamana n'accorde rien et ferme le banc",
      "correct": false
    },
    {
      "text": "une infusion peut apaiser — à condition que l'on n'y voie pas un remplacement du consentement et du suivi",
      "correct": true
    },
    {
      "text": "Solange Mukamana abandonne il s'agit de soigner sans magie, ni mépris de l'herbe, ni abandon du suivi",
      "correct": false
    },
    {
      "text": "La concession vaut acceptation du slogan",
      "correct": false
    }
  ],
  "explanation": "Concession réelle, pas un abandon : l'on n'y voie pas un remplacement du consentement et du suivi"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "polémique",
      "right": "désaccord public à présenter, non à envenimer"
    },
    {
      "left": "infusion",
      "right": "préparation d'herbe, parfois un apaisement"
    },
    {
      "left": "suivi",
      "right": "continuité du soin, plus qu'un bol chaud"
    },
    {
      "left": "limite",
      "right": "ligne où l'herbe ne remplace pas la porte"
    }
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
  "word": "suivi",
  "hint": "continuité du soin, plus qu'un bol chaud"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Solange Mukamana écoute encore, et il fautons présenter avant de crier.",
  "correct_sentence": "Solange Mukamana écoute encore, et il faut présenter avant de crier.",
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
      "image_path": "/elearning/mfk-c1-m3/studio-sante.svg",
      "word": "studio sante"
    },
    {
      "image_path": "/elearning/mfk-c1-m3/oreille-doute.svg",
      "word": "oreille doute"
    },
    {
      "image_path": "/elearning/mfk-c1-m3/voix-hawa.svg",
      "word": "voix hawa"
    },
    {
      "image_path": "/elearning/mfk-c1-m3/progres-crainte.svg",
      "word": "progres crainte"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Écrivez six phrases orales justes : deux sur présenter une polémique ; certains affirment / d'autres objectent, deux concessions, deux propositions."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez quatre modèles, puis votre prise de position (thèse, concession, proposition). Gardez la chronique de Solange et la mise au point d'Inès distincts."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PE — le texte de Solange Mukamana',
    'PE',
    $c$Objectif
Écrire un texte long et structuré. Présenter une polémique sur les infusions de Solange sans caricature. Point : présenter une polémique ; certains affirment / d'autres objectent.

Consigne
Imitez le texte de Solange Mukamana.

Support — Solange Mukamana — L'herbe n'est pas un sort
Solange Mukamana — L'herbe n'est pas un sort
On parle trop vite de les infusions de Solange Mukamana, comme si le mot dispensait d'en examiner le prix.
Encore que l'on remplace l'infirmerie par une casserole, une confiance trop simple dans l'herbe n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Solange Mukamana concède que une infusion peut apaiser, pour autant que l'on n'y voie pas un remplacement du consentement et du suivi.
Ce que l'on nomme polémique, ici, n'est pas un slogan : désaccord public à présenter, non à envenimer.
Solange : certains affirment que l'herbe suffit ; je n'ai jamais dit cela, j'ai dit qu'elle console.
Karim refuse le donc trop rapide : naturel donc sûr.
Lila présentera la polémique sans chercher une gagnante.
Dieudonné : une casserole n'est pas une infamie, c'est un outil.
La proposition qui reste debout est celle-ci : présenter deux positions, une limite, un geste : l'herbe n'efface pas la porte d'Inès
Marc : expliquer le fonctionnement d'une thérapie, c'est aussi dire où elle s'arrête.
Nous clôturons sans fusionner les voix : la chronique de Solange d'un côté, la mise au point d'Inès de l'autre, et le point où elles refusent de se ressembler.
Encore que l'on présente, une confiance trop simple dans l'herbe n'est pas un détail.
Solange Mukamana concède que une infusion peut apaiser, pour autant que l'on n'y voie pas un remplacement du consentement et du suivi.
Je n'écris pas pour vaincre : j'écris pour que la cour puisse relire.
la polémique n'est pas Solange contre Inès : c'est le mot sûr collé trop vite à l'herbe
Solange Mukamana, Rukiri-Nord
$c$,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "La proposition retenue est : présenter deux positions, une limite, un geste : l'herbe n'efface pas la porte d'Inès",
  "correct": true,
  "explanation": "présenter deux positions, une limite, un geste : l'herbe n'efface pas la porte d'Inès"
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
      "text": "présenter deux positions, une limite, un geste : l'herbe n'efface pas la porte d'Inès",
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
  "explanation": "présenter deux positions, une limite, un geste : l'herbe n'efface pas la porte d'Inès"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "polémique",
      "right": "désaccord public à présenter, non à envenimer"
    },
    {
      "left": "infusion",
      "right": "préparation d'herbe, parfois un apaisement"
    },
    {
      "left": "suivi",
      "right": "continuité du soin, plus qu'un bol chaud"
    },
    {
      "left": "limite",
      "right": "ligne où l'herbe ne remplace pas la porte"
    }
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
  "word": "limite",
  "hint": "ligne où l'herbe ne remplace pas la porte"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Les arguments de Solange Mukamana est clairs, et Lila garde le micro ouvert.",
  "correct_sentence": "Les arguments de Solange Mukamana sont clairs, et Lila garde le micro ouvert.",
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
      "image_path": "/elearning/mfk-c1-m3/oreille-doute.svg",
      "word": "oreille doute"
    },
    {
      "image_path": "/elearning/mfk-c1-m3/voix-hawa.svg",
      "word": "voix hawa"
    },
    {
      "image_path": "/elearning/mfk-c1-m3/progres-crainte.svg",
      "word": "progres crainte"
    },
    {
      "image_path": "/elearning/mfk-c1-m3/loupe-science.svg",
      "word": "loupe science"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Imitez le texte de Solange Mukamana : vingt lignes, deux voix, une concession, une proposition."
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
    'EL — présenter une polémique ; certains affirment / d''autres objectent',
    'EL',
    $c$Objectif
Maîtriser présenter une polémique ; certains affirment / d'autres objectent au registre C1, avec collocations et pièges de construction.

Consigne
Apprenez la fiche, puis produisez des exemples justes au registre demandé.

Support — Fiche d'Aline Uwase, banc ocre
Fiche C1 — présenter une polémique ; certains affirment / d'autres objectent
On ne retient pas une liste : on retient des constructions et des collocations.
Encore que l'on présente, une confiance trop simple dans l'herbe n'est pas un détail.
Solange Mukamana concède que une infusion peut apaiser, pour autant que l'on n'y voie pas un remplacement du consentement et du suivi.
Autrement dit, la polémique n'est pas Solange contre Inès : c'est le mot sûr collé trop vite à l'herbe
Il ressort que présenter deux positions, une limite, un geste : l'herbe n'efface pas la porte d'Inès
Piège : confusion cause / concession
Registre : soutenu argumentatif, sans slogan
Collocation : encore que, pour autant que, il ressort que
Ce que l'on nomme polémique, ici, n'est pas un slogan : désaccord public à présenter, non à envenimer.
Inès : d'autres objectent que console veut dire guérir, et c'est là que les portes s'ouvrent trop tard.
Karim refuse le donc trop rapide : naturel donc sûr.
Nominaliser, ce n'est pas alourdir : c'est nommer le processus (la densification, l'accueil, le rappel).
Encore que / pour autant que / si tant est que : subjonctif, concession réelle, pas un ornement.
Reformuler une source : on change la syntaxe, on garde la charge, on signale le point de vue.
C1 : l'implicite se justifie. C2 : l'ironie se laisse entendre sans s'afficher.
Exemple fautif à ne plus produire : On va au suivi pour de vrai genre, et Inès Mukama demande un registre plus net.
Correction : On va au suivi vraiment, et Inès Mukama demande un registre plus net.
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
      "left": "polémique",
      "right": "désaccord public à présenter, non à envenimer"
    },
    {
      "left": "infusion",
      "right": "préparation d'herbe, parfois un apaisement"
    },
    {
      "left": "suivi",
      "right": "continuité du soin, plus qu'un bol chaud"
    },
    {
      "left": "limite",
      "right": "ligne où l'herbe ne remplace pas la porte"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nOn impute la hausse à infusion, non au bol. (mot de la séquence)",
  "answer": "infusion"
}$j$::jsonb,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Remettez les mots dans l''ordre',
    'word_order',
    $j${
  "words": [
    "Solange",
    "impute",
    "la",
    "hausse",
    "à",
    "infusion",
    "."
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
  "sentence_with_error": "On va au suivi pour de vrai genre, et Inès Mukama demande un registre plus net.",
  "correct_sentence": "On va au suivi vraiment, et Inès Mukama demande un registre plus net.",
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
      "image_path": "/elearning/mfk-c1-m3/voix-hawa.svg",
      "word": "voix hawa"
    },
    {
      "image_path": "/elearning/mfk-c1-m3/progres-crainte.svg",
      "word": "progres crainte"
    },
    {
      "image_path": "/elearning/mfk-c1-m3/loupe-science.svg",
      "word": "loupe science"
    },
    {
      "image_path": "/elearning/mfk-c1-m3/main-soin.svg",
      "word": "main soin"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Tableau de langue : six exemples justes de « présenter une polémique ; certains affirment / d'autres objectent » et deux pièges commentés."
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

  -- ===== Mini-conférence du Filtre =====
  SELECT s.id INTO v_seq_id
  FROM elearning_sequences s
  WHERE s.module_id = v_module_id AND s.title = 'Mini-conférence du Filtre'
  LIMIT 1;

  IF v_seq_id IS NULL THEN
    INSERT INTO elearning_sequences (module_id, title, order_index)
    VALUES (v_module_id, 'Mini-conférence du Filtre', 4)
    RETURNING id INTO v_seq_id;
  ELSE
    UPDATE elearning_sequences
    SET order_index = 4
    WHERE id = v_seq_id;
  END IF;

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CO — Mini-conférence du Filtre',
    'CO',
    $c$Objectif
Comprendre un échange long et en extraire l'implicite. Tenir une mini-conférence claire : résultat, limite, geste. Viser la nuance, la collocation et l'implicite.

Consigne
Lisez le débat (à écouter avec l'enseignant). Qu'est-ce qui est dit, qu'est-ce qui reste implicite, qui concède quoi ?

Support — Débat Radio Figuier — Mini-conférence du Filtre
Lila Sow : Radio Figuier. On parle trop vite de la mini-conférence sous le figuier, comme si le mot dispensait d'en examiner le prix.
Marc Nkurunziza : Encore que l'on remplace le plan par le charisme, une salle qui applaudit trop tôt n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Léa Niyonzima : Inès Mukama concède que un oral peut emporter l'adhésion, pour autant que l'on ait d'abord posé les limites de l'échantillon.
Aline Uwase : Ce que l'on nomme conférence, ici, n'est pas un slogan : oral structuré, distinct d'un spectacle.
Patrick Habimana : Inès pose le fait, puis la limite, puis le geste : la salle voudrait inverser.
Hawa Diallo : Aline : il convient que l'on entende le donc avant l'applaudissement.
Joël Mugisha : Karim demande ce qui ne s'ensuit pas.
Rose Iradukunda : Hawa pose la question que le graphique évite.
Solange Mukamana : Patrick chronomètre sans brutalité.
Karim Bamba : Lila gardera les trois questions, pas seulement la formule claire.
Félicie Ndayishimiye : Un chiffre, une trace : Inès a parlé onze minutes ; trois questions ; zéro mot miracle.
Dieudonné Hakizimana : L'enjeu n'est pas d'avoir raison plus fort : il s'agit que la cour puisse relire la conférence demain sans se sentir trompée
Yvette : Solange apporte de l'eau, pas une conclusion.
Mado : Aline Uwase entend, dans « faites confiance », ceci qui n'est pas dit : faites confiance veut souvent dire ne demandez pas le plan
Sami : Autrement dit, déduire, ce n'est pas enchaîner des mots savants : c'est montrer ce qui s'ensuit, et ce qui ne s'ensuit pas
Lila Sow : Je reformule pour les auditeurs. La proposition qui reste debout est celle-ci : un plan en trois temps : fait, limite, recommandation pour la cour
Nina Kayitesi : Marc : une mini-conférence est une hospitalité faite au doute.
Lila Sow : Nous clôturons sans clore. Nous clôturons sans fusionner les voix : le plan d'Inès d'un côté, les questions d'Hawa et de Karim de l'autre, et le point où elles refusent de se ressembler.
$c$,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "une salle qui applaudit trop tôt est présenté comme un simple détail sans conséquence.",
  "correct": false,
  "explanation": "Le texte affirme au contraire que une salle qui applaudit trop tôt n'est pas un détail."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Selon Aline Uwase, que reste-t-il implicite dans « faites confiance » ?",
  "options": [
    {
      "text": "Que Inès a parlé une heure sans questions",
      "correct": false
    },
    {
      "text": "Ne pas demander le plan",
      "correct": true
    },
    {
      "text": "Que Aline a interdit les limites",
      "correct": false
    },
    {
      "text": "Que le Filtre est une magie",
      "correct": false
    }
  ],
  "explanation": "faites confiance veut souvent dire ne demandez pas le plan"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "conférence",
      "right": "oral structuré, distinct d'un spectacle"
    },
    {
      "left": "déduction",
      "right": "enchaînement justifié, pas un saut"
    },
    {
      "left": "limite",
      "right": "bord de ce que l'on peut dire"
    },
    {
      "left": "recommandation",
      "right": "geste proposé après le fait"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nIl convient que l'on ___ avant d'accélérer. (conclure, subj.)",
  "answer": "conclue"
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
    "conclue",
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
  "word": "conférence",
  "hint": "oral structuré, distinct d'un spectacle"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Il convient que l'on conclure trop tard, et Inès Mukama refuse d'accélérer la pente.",
  "correct_sentence": "Il convient que l'on conclue trop tard, et Inès Mukama refuse d'accélérer la pente.",
  "explanation": "Il convient que + conclue."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-c1-m3/progres-crainte.svg",
      "word": "progres crainte"
    },
    {
      "image_path": "/elearning/mfk-c1-m3/loupe-science.svg",
      "word": "loupe science"
    },
    {
      "image_path": "/elearning/mfk-c1-m3/main-soin.svg",
      "word": "main soin"
    },
    {
      "image_path": "/elearning/mfk-c1-m3/banc-attente.svg",
      "word": "banc attente"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Reformulez l'implicite de « faites confiance » et la concession de Inès Mukama."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez une synthèse d'environ quatre-vingt-dix secondes : deux points de vue, un implicite, une proposition. Gardez le plan d'Inès et les questions d'Hawa et de Karim distincts."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CE — Ce qui s''ensuit, ce qui ne s''ensuit pas',
    'CE',
    $c$Objectif
Lire un texte argumenté long, synthétiser et reformuler. Tenir une mini-conférence claire : résultat, limite, geste. Viser la nuance, la collocation et l'implicite.

Consigne
Lisez « Ce qui s'ensuit, ce qui ne s'ensuit pas », sans aller trop vite. Repérez la thèse, la concession, l'implicite et la proposition.

Support — Ce qui s'ensuit, ce qui ne s'ensuit pas
On parle trop vite de la mini-conférence sous le figuier, comme si le mot dispensait d'en examiner le prix.
Encore que l'on remplace le plan par le charisme, une salle qui applaudit trop tôt n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Inès Mukama concède que un oral peut emporter l'adhésion, pour autant que l'on ait d'abord posé les limites de l'échantillon.
Ce que l'on nomme conférence, ici, n'est pas un slogan : oral structuré, distinct d'un spectacle.
Inès pose le fait, puis la limite, puis le geste : la salle voudrait inverser.
Aline : il convient que l'on entende le donc avant l'applaudissement.
Karim demande ce qui ne s'ensuit pas.
Hawa pose la question que le graphique évite.
Patrick chronomètre sans brutalité.
Lila gardera les trois questions, pas seulement la formule claire.
Un chiffre, une trace : Inès a parlé onze minutes ; trois questions ; zéro mot miracle.
L'enjeu n'est pas d'avoir raison plus fort : il s'agit que la cour puisse relire la conférence demain sans se sentir trompée
Solange apporte de l'eau, pas une conclusion.
Aline Uwase entend, dans « faites confiance », ceci qui n'est pas dit : faites confiance veut souvent dire ne demandez pas le plan
Autrement dit, déduire, ce n'est pas enchaîner des mots savants : c'est montrer ce qui s'ensuit, et ce qui ne s'ensuit pas
La proposition qui reste debout est celle-ci : un plan en trois temps : fait, limite, recommandation pour la cour
Marc : une mini-conférence est une hospitalité faite au doute.
Nous clôturons sans fusionner les voix : le plan d'Inès d'un côté, les questions d'Hawa et de Karim de l'autre, et le point où elles refusent de se ressembler.
Signé : Inès Mukama, Rukiri-Nord — Cahier des racines, Rukiri-Nord.
$c$,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Le texte refuse de fusionner le plan d'Inès et les questions d'Hawa et de Karim en une seule affiche.",
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
      "text": "Onze minutes, trois questions, zéro miracle",
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
  "explanation": "Inès a parlé onze minutes ; trois questions ; zéro mot miracle."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "conférence",
      "right": "oral structuré, distinct d'un spectacle"
    },
    {
      "left": "déduction",
      "right": "enchaînement justifié, pas un saut"
    },
    {
      "left": "limite",
      "right": "bord de ce que l'on peut dire"
    },
    {
      "left": "recommandation",
      "right": "geste proposé après le fait"
    }
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
  "word": "déduction",
  "hint": "enchaînement justifié, pas un saut"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "La conférence de trop vite n'aide personne, et Aline Uwase reprend le fil.",
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
      "image_path": "/elearning/mfk-c1-m3/loupe-science.svg",
      "word": "loupe science"
    },
    {
      "image_path": "/elearning/mfk-c1-m3/main-soin.svg",
      "word": "main soin"
    },
    {
      "image_path": "/elearning/mfk-c1-m3/banc-attente.svg",
      "word": "banc attente"
    },
    {
      "image_path": "/elearning/mfk-c1-m3/radio-don.svg",
      "word": "radio don"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Synthétisez « Ce qui s'ensuit, ce qui ne s'ensuit pas » : thèse, concession, implicite, proposition (quinze lignes)."
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
    'PO — Mini-conférence du Filtre : dire sans slogan',
    'PO',
    $c$Objectif
Produire un oral structuré (thèse, concession, proposition). Point : plan déductif ; il s'ensuit que ; en conséquence.

Consigne
Répétez les modèles, puis prenez position en une minute : thèse, concession, reformulation, proposition.

Support — Modèles d'Aline Uwase, banc du figuier
Encore que l'on remplace le plan par le charisme, une salle qui applaudit trop tôt n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Inès Mukama concède que un oral peut emporter l'adhésion, pour autant que l'on ait d'abord posé les limites de l'échantillon.
Ce que l'on nomme conférence, ici, n'est pas un slogan : oral structuré, distinct d'un spectacle.
Encore que l'on conclue, une salle qui applaudit trop tôt n'est pas un détail.
Inès Mukama concède que un oral peut emporter l'adhésion, pour autant que l'on ait d'abord posé les limites de l'échantillon.
Autrement dit, déduire, ce n'est pas enchaîner des mots savants : c'est montrer ce qui s'ensuit, et ce qui ne s'ensuit pas
Il ressort qu'un plan en trois temps : fait, limite, recommandation pour la cour
Aline : il convient que l'on entende le donc avant l'applaudissement.
Patrick chronomètre sans brutalité.
La proposition qui reste debout est celle-ci : un plan en trois temps : fait, limite, recommandation pour la cour
Je concède le point, je n'abandonne pas la proposition.
Ce n'est pas que je refuse : c'est que je refuse qu'on nomme cela un détail.
Autrement dit, l'implicite fait autant de travail que la thèse.
En une minute : fait, angle, concession, proposition.
Nous clôturons sans fusionner les voix : le plan d'Inès d'un côté, les questions d'Hawa et de Karim de l'autre, et le point où elles refusent de se ressembler.
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
  "statement": "Inès Mukama transforme la concession en abandon de toute proposition.",
  "correct": false,
  "explanation": "Inès Mukama concède que un oral peut emporter l'adhésion, pour autant que l'on ait d'abord posé les limites de l'échantillon."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Que concède Inès Mukama, et à quelle condition ?",
  "options": [
    {
      "text": "Inès Mukama n'accorde rien et ferme le banc",
      "correct": false
    },
    {
      "text": "un oral peut emporter l'adhésion — à condition que l'on ait d'abord posé les limites de l'échantillon",
      "correct": true
    },
    {
      "text": "Inès Mukama abandonne il s'agit que la cour puisse relire la conférence demain sans se sentir trompée",
      "correct": false
    },
    {
      "text": "La concession vaut acceptation du slogan",
      "correct": false
    }
  ],
  "explanation": "Concession réelle, pas un abandon : l'on ait d'abord posé les limites de l'échantillon"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "conférence",
      "right": "oral structuré, distinct d'un spectacle"
    },
    {
      "left": "déduction",
      "right": "enchaînement justifié, pas un saut"
    },
    {
      "left": "limite",
      "right": "bord de ce que l'on peut dire"
    },
    {
      "left": "recommandation",
      "right": "geste proposé après le fait"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nNous recommandons que la cour ___ un relais. (conclure, subj.)",
  "answer": "conclue"
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
    "conclue",
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
  "word": "limite",
  "hint": "bord de ce que l'on peut dire"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Inès Mukama écoute encore, et il fautons conclure avant de crier.",
  "correct_sentence": "Inès Mukama écoute encore, et il faut conclure avant de crier.",
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
      "image_path": "/elearning/mfk-c1-m3/main-soin.svg",
      "word": "main soin"
    },
    {
      "image_path": "/elearning/mfk-c1-m3/banc-attente.svg",
      "word": "banc attente"
    },
    {
      "image_path": "/elearning/mfk-c1-m3/radio-don.svg",
      "word": "radio don"
    },
    {
      "image_path": "/elearning/mfk-c1-m3/feuille-loi-inventee.svg",
      "word": "feuille loi inventee"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Écrivez six phrases orales justes : deux sur plan déductif ; il s'ensuit que ; en conséquence, deux concessions, deux propositions."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez quatre modèles, puis votre prise de position (thèse, concession, proposition). Gardez le plan d'Inès et les questions d'Hawa et de Karim distincts."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PE — le texte de Inès Mukama',
    'PE',
    $c$Objectif
Écrire un texte long et structuré. Tenir une mini-conférence claire : résultat, limite, geste. Point : plan déductif ; il s'ensuit que ; en conséquence.

Consigne
Imitez le texte de Inès Mukama.

Support — Inès Mukama — Ce qui s'ensuit, ce qui ne s'ensuit pas
Inès Mukama — Ce qui s'ensuit, ce qui ne s'ensuit pas
On parle trop vite de la mini-conférence sous le figuier, comme si le mot dispensait d'en examiner le prix.
Encore que l'on remplace le plan par le charisme, une salle qui applaudit trop tôt n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Inès Mukama concède que un oral peut emporter l'adhésion, pour autant que l'on ait d'abord posé les limites de l'échantillon.
Ce que l'on nomme conférence, ici, n'est pas un slogan : oral structuré, distinct d'un spectacle.
Inès pose le fait, puis la limite, puis le geste : la salle voudrait inverser.
Patrick chronomètre sans brutalité.
Lila gardera les trois questions, pas seulement la formule claire.
Solange apporte de l'eau, pas une conclusion.
La proposition qui reste debout est celle-ci : un plan en trois temps : fait, limite, recommandation pour la cour
Marc : une mini-conférence est une hospitalité faite au doute.
Nous clôturons sans fusionner les voix : le plan d'Inès d'un côté, les questions d'Hawa et de Karim de l'autre, et le point où elles refusent de se ressembler.
Encore que l'on conclue, une salle qui applaudit trop tôt n'est pas un détail.
Inès Mukama concède que un oral peut emporter l'adhésion, pour autant que l'on ait d'abord posé les limites de l'échantillon.
Je n'écris pas pour vaincre : j'écris pour que la cour puisse relire.
déduire, ce n'est pas enchaîner des mots savants : c'est montrer ce qui s'ensuit, et ce qui ne s'ensuit pas
Inès Mukama, Rukiri-Nord
$c$,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "La proposition retenue est : un plan en trois temps : fait, limite, recommandation pour la cour",
  "correct": true,
  "explanation": "un plan en trois temps : fait, limite, recommandation pour la cour"
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
      "text": "un plan en trois temps : fait, limite, recommandation pour la cour",
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
  "explanation": "un plan en trois temps : fait, limite, recommandation pour la cour"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "conférence",
      "right": "oral structuré, distinct d'un spectacle"
    },
    {
      "left": "déduction",
      "right": "enchaînement justifié, pas un saut"
    },
    {
      "left": "limite",
      "right": "bord de ce que l'on peut dire"
    },
    {
      "left": "recommandation",
      "right": "geste proposé après le fait"
    }
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
  "word": "recommandation",
  "hint": "geste proposé après le fait"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Les arguments de Inès Mukama est clairs, et Lila garde le micro ouvert.",
  "correct_sentence": "Les arguments de Inès Mukama sont clairs, et Lila garde le micro ouvert.",
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
      "image_path": "/elearning/mfk-c1-m3/banc-attente.svg",
      "word": "banc attente"
    },
    {
      "image_path": "/elearning/mfk-c1-m3/radio-don.svg",
      "word": "radio don"
    },
    {
      "image_path": "/elearning/mfk-c1-m3/feuille-loi-inventee.svg",
      "word": "feuille loi inventee"
    },
    {
      "image_path": "/elearning/mfk-c1-m3/soleil-guerir.svg",
      "word": "soleil guerir"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Imitez le texte de Inès Mukama : vingt lignes, deux voix, une concession, une proposition."
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
    'EL — plan déductif ; il s''ensuit que ; en conséquence',
    'EL',
    $c$Objectif
Maîtriser plan déductif ; il s'ensuit que ; en conséquence au registre C1, avec collocations et pièges de construction.

Consigne
Apprenez la fiche, puis produisez des exemples justes au registre demandé.

Support — Fiche d'Aline Uwase, banc ocre
Fiche C1 — plan déductif ; il s'ensuit que ; en conséquence
On ne retient pas une liste : on retient des constructions et des collocations.
Encore que l'on conclue, une salle qui applaudit trop tôt n'est pas un détail.
Inès Mukama concède que un oral peut emporter l'adhésion, pour autant que l'on ait d'abord posé les limites de l'échantillon.
Autrement dit, déduire, ce n'est pas enchaîner des mots savants : c'est montrer ce qui s'ensuit, et ce qui ne s'ensuit pas
Il ressort qu'un plan en trois temps : fait, limite, recommandation pour la cour
Piège : indicatif après il convient que
Registre : soutenu argumentatif, sans slogan
Collocation : encore que, pour autant que, il ressort que
Ce que l'on nomme conférence, ici, n'est pas un slogan : oral structuré, distinct d'un spectacle.
Aline : il convient que l'on entende le donc avant l'applaudissement.
Patrick chronomètre sans brutalité.
Nominaliser, ce n'est pas alourdir : c'est nommer le processus (la densification, l'accueil, le rappel).
Encore que / pour autant que / si tant est que : subjonctif, concession réelle, pas un ornement.
Reformuler une source : on change la syntaxe, on garde la charge, on signale le point de vue.
C1 : l'implicite se justifie. C2 : l'ironie se laisse entendre sans s'afficher.
Exemple fautif à ne plus produire : On va au limite pour de vrai genre, et Aline Uwase demande un registre plus net.
Correction : On va au limite vraiment, et Aline Uwase demande un registre plus net.
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
      "left": "conférence",
      "right": "oral structuré, distinct d'un spectacle"
    },
    {
      "left": "déduction",
      "right": "enchaînement justifié, pas un saut"
    },
    {
      "left": "limite",
      "right": "bord de ce que l'on peut dire"
    },
    {
      "left": "recommandation",
      "right": "geste proposé après le fait"
    }
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
  "sentence_with_error": "On va au limite pour de vrai genre, et Aline Uwase demande un registre plus net.",
  "correct_sentence": "On va au limite vraiment, et Aline Uwase demande un registre plus net.",
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
      "image_path": "/elearning/mfk-c1-m3/radio-don.svg",
      "word": "radio don"
    },
    {
      "image_path": "/elearning/mfk-c1-m3/feuille-loi-inventee.svg",
      "word": "feuille loi inventee"
    },
    {
      "image_path": "/elearning/mfk-c1-m3/soleil-guerir.svg",
      "word": "soleil guerir"
    },
    {
      "image_path": "/elearning/mfk-c1-m3/nuage-fatigue.svg",
      "word": "nuage fatigue"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Tableau de langue : six exemples justes de « plan déductif ; il s'ensuit que ; en conséquence » et deux pièges commentés."
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

  -- ===== Podcast du parcours =====
  SELECT s.id INTO v_seq_id
  FROM elearning_sequences s
  WHERE s.module_id = v_module_id AND s.title = 'Podcast du parcours'
  LIMIT 1;

  IF v_seq_id IS NULL THEN
    INSERT INTO elearning_sequences (module_id, title, order_index)
    VALUES (v_module_id, 'Podcast du parcours', 5)
    RETURNING id INTO v_seq_id;
  ELSE
    UPDATE elearning_sequences
    SET order_index = 5
    WHERE id = v_seq_id;
  END IF;

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CO — Podcast du parcours',
    'CO',
    $c$Objectif
Comprendre un échange long et en extraire l'implicite. Enregistrer un podcast qui rapporte un parcours médical inventé sans le voler. Viser la nuance, la collocation et l'implicite.

Consigne
Lisez le débat (à écouter avec l'enseignant). Qu'est-ce qui est dit, qu'est-ce qui reste implicite, qui concède quoi ?

Support — Débat Radio Figuier — Podcast du parcours
Lila Sow : Radio Figuier. On parle trop vite de le podcast de Radio Figuier sur le parcours, comme si le mot dispensait d'en examiner le prix.
Marc Nkurunziza : Encore que l'on coupe la parole d'Hawa pour faire plus vrai, un montage trop lisse n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Léa Niyonzima : Lila Sow concède que monter peut clarifier, pour autant que l'on n'efface pas les silences qu'Hawa a choisis.
Aline Uwase : Ce que l'on nomme podcast, ici, n'est pas un slogan : épisode parlé, monté avec éthique.
Patrick Habimana : Hawa a dit qu'elle voulait le silence après le mot porte.
Hawa Diallo : Lila a demandé si l'on pouvait reformuler jargon ; Hawa a dit que oui, à condition de le signaler.
Joël Mugisha : Inès a prétendu que le protocole était clair ; Hawa a ri, puis s'est tue.
Rose Iradukunda : Aline : le discours indirect ici protège, il n'habille pas.
Solange Mukamana : Dieudonné n'apparaît que s'il accepte.
Karim Bamba : Patrick écoute le rush et refuse le fond musical.
Félicie Ndayishimiye : Un chiffre, une trace : Lila a gardé quatre silences ; coupé deux répétitions ; refusé un fond musical trop doux.
Dieudonné Hakizimana : L'enjeu n'est pas d'avoir raison plus fort : il s'agit que le podcast reste un soin de parole, pas un spectacle de douleur
Yvette : Yvette : donner la voix n'est pas une décoration.
Mado : Hawa Diallo entend, dans « donner la voix aux patients », ceci qui n'est pas dit : donner la voix peut cacher le fait qu'on la prend
Sami : Autrement dit, rapporter, ce n'est pas sténographier, et ce n'est pas non plus embellir la peur
Lila Sow : Je reformule pour les auditeurs. La proposition qui reste debout est celle-ci : un épisode : Hawa, Inès, un silence gardé, une reformulation signalée
Nina Kayitesi : Marc : Radio Figuier rapportera, elle n'éditera pas la peur.
Lila Sow : Nous clôturons sans clore. Nous clôturons sans fusionner les voix : le rush du podcast d'un côté, les consignes d'Hawa sur ce qui ne se dit pas de l'autre, et le point où elles refusent de se ressembler.
$c$,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "un montage trop lisse est présenté comme un simple détail sans conséquence.",
  "correct": false,
  "explanation": "Le texte affirme au contraire que un montage trop lisse n'est pas un détail."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Selon Hawa Diallo, que reste-t-il implicite dans « donner la voix aux patients » ?",
  "options": [
    {
      "text": "Que Lila a vendu l'épisode aux Lampions",
      "correct": false
    },
    {
      "text": "Prendre la voix en prétendant la donner",
      "correct": true
    },
    {
      "text": "Que Hawa a tout interdit",
      "correct": false
    },
    {
      "text": "Que Inès a parlé à la place d'Hawa",
      "correct": false
    }
  ],
  "explanation": "donner la voix peut cacher le fait qu'on la prend"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "podcast",
      "right": "épisode parlé, monté avec éthique"
    },
    {
      "left": "montage",
      "right": "choix de garder ou couper, jamais anodin"
    },
    {
      "left": "silence",
      "right": "partie du récit, pas un trou à remplir"
    },
    {
      "left": "voix",
      "right": "parole d'Hawa, non un objet de radio"
    }
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
  "word": "podcast",
  "hint": "épisode parlé, monté avec éthique"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Joël a dit qu'il posera le casque dès l'aube, et Lila Sow prend des notes.",
  "correct_sentence": "Joël a dit qu'il poserait le casque dès l'aube, et Lila Sow prend des notes.",
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
      "image_path": "/elearning/mfk-c1-m3/feuille-loi-inventee.svg",
      "word": "feuille loi inventee"
    },
    {
      "image_path": "/elearning/mfk-c1-m3/soleil-guerir.svg",
      "word": "soleil guerir"
    },
    {
      "image_path": "/elearning/mfk-c1-m3/nuage-fatigue.svg",
      "word": "nuage fatigue"
    },
    {
      "image_path": "/elearning/mfk-c1-m3/porte-infirmerie.svg",
      "word": "porte infirmerie"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Reformulez l'implicite de « donner la voix aux patients » et la concession de Lila Sow."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez une synthèse d'environ quatre-vingt-dix secondes : deux points de vue, un implicite, une proposition. Gardez le rush du podcast et les consignes d'Hawa sur ce qui ne se dit pas distincts."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CE — Ce qui ne se monte pas',
    'CE',
    $c$Objectif
Lire un texte argumenté long, synthétiser et reformuler. Enregistrer un podcast qui rapporte un parcours médical inventé sans le voler. Viser la nuance, la collocation et l'implicite.

Consigne
Lisez « Ce qui ne se monte pas », sans aller trop vite. Repérez la thèse, la concession, l'implicite et la proposition.

Support — Ce qui ne se monte pas
On parle trop vite de le podcast de Radio Figuier sur le parcours, comme si le mot dispensait d'en examiner le prix.
Encore que l'on coupe la parole d'Hawa pour faire plus vrai, un montage trop lisse n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Lila Sow concède que monter peut clarifier, pour autant que l'on n'efface pas les silences qu'Hawa a choisis.
Ce que l'on nomme podcast, ici, n'est pas un slogan : épisode parlé, monté avec éthique.
Hawa a dit qu'elle voulait le silence après le mot porte.
Lila a demandé si l'on pouvait reformuler jargon ; Hawa a dit que oui, à condition de le signaler.
Inès a prétendu que le protocole était clair ; Hawa a ri, puis s'est tue.
Aline : le discours indirect ici protège, il n'habille pas.
Dieudonné n'apparaît que s'il accepte.
Patrick écoute le rush et refuse le fond musical.
Un chiffre, une trace : Lila a gardé quatre silences ; coupé deux répétitions ; refusé un fond musical trop doux.
L'enjeu n'est pas d'avoir raison plus fort : il s'agit que le podcast reste un soin de parole, pas un spectacle de douleur
Yvette : donner la voix n'est pas une décoration.
Hawa Diallo entend, dans « donner la voix aux patients », ceci qui n'est pas dit : donner la voix peut cacher le fait qu'on la prend
Autrement dit, rapporter, ce n'est pas sténographier, et ce n'est pas non plus embellir la peur
La proposition qui reste debout est celle-ci : un épisode : Hawa, Inès, un silence gardé, une reformulation signalée
Marc : Radio Figuier rapportera, elle n'éditera pas la peur.
Nous clôturons sans fusionner les voix : le rush du podcast d'un côté, les consignes d'Hawa sur ce qui ne se dit pas de l'autre, et le point où elles refusent de se ressembler.
Signé : Lila Sow, Rukiri-Nord — Cahier des racines, Rukiri-Nord.
$c$,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Le texte refuse de fusionner le rush du podcast et les consignes d'Hawa sur ce qui ne se dit pas en une seule affiche.",
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
      "text": "Quatre silences gardés, deux coupures, zéro musique trop douce",
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
  "explanation": "Lila a gardé quatre silences ; coupé deux répétitions ; refusé un fond musical trop doux."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "podcast",
      "right": "épisode parlé, monté avec éthique"
    },
    {
      "left": "montage",
      "right": "choix de garder ou couper, jamais anodin"
    },
    {
      "left": "silence",
      "right": "partie du récit, pas un trou à remplir"
    },
    {
      "left": "voix",
      "right": "parole d'Hawa, non un objet de radio"
    }
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
  "word": "montage",
  "hint": "choix de garder ou couper, jamais anodin"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "La podcast de trop vite n'aide personne, et Hawa Diallo reprend le fil.",
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
      "image_path": "/elearning/mfk-c1-m3/soleil-guerir.svg",
      "word": "soleil guerir"
    },
    {
      "image_path": "/elearning/mfk-c1-m3/nuage-fatigue.svg",
      "word": "nuage fatigue"
    },
    {
      "image_path": "/elearning/mfk-c1-m3/porte-infirmerie.svg",
      "word": "porte infirmerie"
    },
    {
      "image_path": "/elearning/mfk-c1-m3/coeur-soin.svg",
      "word": "coeur soin"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Synthétisez « Ce qui ne se monte pas » : thèse, concession, implicite, proposition (quinze lignes)."
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
    'PO — Podcast du parcours : dire sans slogan',
    'PO',
    $c$Objectif
Produire un oral structuré (thèse, concession, proposition). Point : discours rapporté complexe ; elle a dit qu'elle / si.

Consigne
Répétez les modèles, puis prenez position en une minute : thèse, concession, reformulation, proposition.

Support — Modèles d'Aline Uwase, banc du figuier
Encore que l'on coupe la parole d'Hawa pour faire plus vrai, un montage trop lisse n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Lila Sow concède que monter peut clarifier, pour autant que l'on n'efface pas les silences qu'Hawa a choisis.
Ce que l'on nomme podcast, ici, n'est pas un slogan : épisode parlé, monté avec éthique.
Encore que l'on coupe, un montage trop lisse n'est pas un détail.
Lila Sow concède que monter peut clarifier, pour autant que l'on n'efface pas les silences qu'Hawa a choisis.
Autrement dit, rapporter, ce n'est pas sténographier, et ce n'est pas non plus embellir la peur
Il ressort qu'un épisode : Hawa, Inès, un silence gardé, une reformulation signalée
Lila a demandé si l'on pouvait reformuler jargon ; Hawa a dit que oui, à condition de le signaler.
Dieudonné n'apparaît que s'il accepte.
La proposition qui reste debout est celle-ci : un épisode : Hawa, Inès, un silence gardé, une reformulation signalée
Je concède le point, je n'abandonne pas la proposition.
Ce n'est pas que je refuse : c'est que je refuse qu'on nomme cela un détail.
Autrement dit, l'implicite fait autant de travail que la thèse.
En une minute : fait, angle, concession, proposition.
Nous clôturons sans fusionner les voix : le rush du podcast d'un côté, les consignes d'Hawa sur ce qui ne se dit pas de l'autre, et le point où elles refusent de se ressembler.
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
  "explanation": "Lila Sow concède que monter peut clarifier, pour autant que l'on n'efface pas les silences qu'Hawa a choisis."
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
      "text": "monter peut clarifier — à condition que l'on n'efface pas les silences qu'Hawa a choisis",
      "correct": true
    },
    {
      "text": "Lila Sow abandonne il s'agit que le podcast reste un soin de parole, pas un spectacle de douleur",
      "correct": false
    },
    {
      "text": "La concession vaut acceptation du slogan",
      "correct": false
    }
  ],
  "explanation": "Concession réelle, pas un abandon : l'on n'efface pas les silences qu'Hawa a choisis"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "podcast",
      "right": "épisode parlé, monté avec éthique"
    },
    {
      "left": "montage",
      "right": "choix de garder ou couper, jamais anodin"
    },
    {
      "left": "silence",
      "right": "partie du récit, pas un trou à remplir"
    },
    {
      "left": "voix",
      "right": "parole d'Hawa, non un objet de radio"
    }
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
  "word": "silence",
  "hint": "partie du récit, pas un trou à remplir"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Lila Sow écoute encore, et il fautons couper avant de crier.",
  "correct_sentence": "Lila Sow écoute encore, et il faut couper avant de crier.",
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
      "image_path": "/elearning/mfk-c1-m3/nuage-fatigue.svg",
      "word": "nuage fatigue"
    },
    {
      "image_path": "/elearning/mfk-c1-m3/porte-infirmerie.svg",
      "word": "porte infirmerie"
    },
    {
      "image_path": "/elearning/mfk-c1-m3/coeur-soin.svg",
      "word": "coeur soin"
    },
    {
      "image_path": "/elearning/mfk-c1-m3/cahier-dons.svg",
      "word": "cahier dons"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Écrivez six phrases orales justes : deux sur discours rapporté complexe ; elle a dit qu'elle / si, deux concessions, deux propositions."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez quatre modèles, puis votre prise de position (thèse, concession, proposition). Gardez le rush du podcast et les consignes d'Hawa sur ce qui ne se dit pas distincts."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PE — le texte de Lila Sow',
    'PE',
    $c$Objectif
Écrire un texte long et structuré. Enregistrer un podcast qui rapporte un parcours médical inventé sans le voler. Point : discours rapporté complexe ; elle a dit qu'elle / si.

Consigne
Imitez le texte de Lila Sow.

Support — Lila Sow — Ce qui ne se monte pas
Lila Sow — Ce qui ne se monte pas
On parle trop vite de le podcast de Radio Figuier sur le parcours, comme si le mot dispensait d'en examiner le prix.
Encore que l'on coupe la parole d'Hawa pour faire plus vrai, un montage trop lisse n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Lila Sow concède que monter peut clarifier, pour autant que l'on n'efface pas les silences qu'Hawa a choisis.
Ce que l'on nomme podcast, ici, n'est pas un slogan : épisode parlé, monté avec éthique.
Hawa a dit qu'elle voulait le silence après le mot porte.
Dieudonné n'apparaît que s'il accepte.
Patrick écoute le rush et refuse le fond musical.
Yvette : donner la voix n'est pas une décoration.
La proposition qui reste debout est celle-ci : un épisode : Hawa, Inès, un silence gardé, une reformulation signalée
Marc : Radio Figuier rapportera, elle n'éditera pas la peur.
Nous clôturons sans fusionner les voix : le rush du podcast d'un côté, les consignes d'Hawa sur ce qui ne se dit pas de l'autre, et le point où elles refusent de se ressembler.
Encore que l'on coupe, un montage trop lisse n'est pas un détail.
Lila Sow concède que monter peut clarifier, pour autant que l'on n'efface pas les silences qu'Hawa a choisis.
Je n'écris pas pour vaincre : j'écris pour que la cour puisse relire.
rapporter, ce n'est pas sténographier, et ce n'est pas non plus embellir la peur
Lila Sow, Rukiri-Nord
$c$,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "La proposition retenue est : un épisode : Hawa, Inès, un silence gardé, une reformulation signalée",
  "correct": true,
  "explanation": "un épisode : Hawa, Inès, un silence gardé, une reformulation signalée"
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
      "text": "un épisode : Hawa, Inès, un silence gardé, une reformulation signalée",
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
  "explanation": "un épisode : Hawa, Inès, un silence gardé, une reformulation signalée"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "podcast",
      "right": "épisode parlé, monté avec éthique"
    },
    {
      "left": "montage",
      "right": "choix de garder ou couper, jamais anodin"
    },
    {
      "left": "silence",
      "right": "partie du récit, pas un trou à remplir"
    },
    {
      "left": "voix",
      "right": "parole d'Hawa, non un objet de radio"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nLila a exigé que l'on ___ les insultes. (couper, subj.)",
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
    "Lila",
    "a",
    "exigé",
    "que",
    "l'on",
    "coupe",
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
  "word": "voix",
  "hint": "parole d'Hawa, non un objet de radio"
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
      "image_path": "/elearning/mfk-c1-m3/porte-infirmerie.svg",
      "word": "porte infirmerie"
    },
    {
      "image_path": "/elearning/mfk-c1-m3/coeur-soin.svg",
      "word": "coeur soin"
    },
    {
      "image_path": "/elearning/mfk-c1-m3/cahier-dons.svg",
      "word": "cahier dons"
    },
    {
      "image_path": "/elearning/mfk-c1-m3/parcours-infirmerie.svg",
      "word": "parcours infirmerie"
    }
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
    'EL — discours rapporté complexe ; elle a dit qu''elle / si',
    'EL',
    $c$Objectif
Maîtriser discours rapporté complexe ; elle a dit qu'elle / si au registre C1, avec collocations et pièges de construction.

Consigne
Apprenez la fiche, puis produisez des exemples justes au registre demandé.

Support — Fiche d'Aline Uwase, banc ocre
Fiche C1 — discours rapporté complexe ; elle a dit qu'elle / si
On ne retient pas une liste : on retient des constructions et des collocations.
Encore que l'on coupe, un montage trop lisse n'est pas un détail.
Lila Sow concède que monter peut clarifier, pour autant que l'on n'efface pas les silences qu'Hawa a choisis.
Autrement dit, rapporter, ce n'est pas sténographier, et ce n'est pas non plus embellir la peur
Il ressort qu'un épisode : Hawa, Inès, un silence gardé, une reformulation signalée
Piège : garder le présent du DD dans un DI au passé
Registre : soutenu argumentatif, sans slogan
Collocation : encore que, pour autant que, il ressort que
Ce que l'on nomme podcast, ici, n'est pas un slogan : épisode parlé, monté avec éthique.
Lila a demandé si l'on pouvait reformuler jargon ; Hawa a dit que oui, à condition de le signaler.
Dieudonné n'apparaît que s'il accepte.
Nominaliser, ce n'est pas alourdir : c'est nommer le processus (la densification, l'accueil, le rappel).
Encore que / pour autant que / si tant est que : subjonctif, concession réelle, pas un ornement.
Reformuler une source : on change la syntaxe, on garde la charge, on signale le point de vue.
C1 : l'implicite se justifie. C2 : l'ironie se laisse entendre sans s'afficher.
Exemple fautif à ne plus produire : On va au silence pour de vrai genre, et Hawa Diallo demande un registre plus net.
Correction : On va au silence vraiment, et Hawa Diallo demande un registre plus net.
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
      "left": "podcast",
      "right": "épisode parlé, monté avec éthique"
    },
    {
      "left": "montage",
      "right": "choix de garder ou couper, jamais anodin"
    },
    {
      "left": "silence",
      "right": "partie du récit, pas un trou à remplir"
    },
    {
      "left": "voix",
      "right": "parole d'Hawa, non un objet de radio"
    }
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
  "sentence_with_error": "On va au silence pour de vrai genre, et Hawa Diallo demande un registre plus net.",
  "correct_sentence": "On va au silence vraiment, et Hawa Diallo demande un registre plus net.",
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
      "image_path": "/elearning/mfk-c1-m3/coeur-soin.svg",
      "word": "coeur soin"
    },
    {
      "image_path": "/elearning/mfk-c1-m3/cahier-dons.svg",
      "word": "cahier dons"
    },
    {
      "image_path": "/elearning/mfk-c1-m3/parcours-infirmerie.svg",
      "word": "parcours infirmerie"
    },
    {
      "image_path": "/elearning/mfk-c1-m3/attente-longue.svg",
      "word": "attente longue"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Tableau de langue : six exemples justes de « discours rapporté complexe ; elle a dit qu'elle / si » et deux pièges commentés."
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
