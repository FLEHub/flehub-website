/*
  Seed eLearning MFK — C1 — Faims du figuier

  Micro-monde : cour « Le Seuil des Sources », Rukiri-Nord.
  6 séquences × 5 leçons × 10 exercices (tous les types).
  Illustrations originales : /elearning/mfk-c1-m2/
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
  v_module_title text := 'C1 — Faims du figuier';
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
      'Grande étape C1-2 : nommer la faim qui n''est pas seulement le ventre, lire des chiffres inventés du Filtre des Herbes, entendre la colère des jardiniers de la rive, peser une application inventée (Fil-des-Herbes), débattre du marketing du Marché des Lampions, et composer un recueil de plaisirs minuscules — Félicie Ndayishimiye tient le bol, Oscar Niyitegeka garde la terre, Karim Bamba compte sans écraser, Lila Sow tend le micro.',
      'C1',
      false
    )
    RETURNING id INTO v_module_id;
  ELSE
    UPDATE elearning_modules
    SET
      description = 'Grande étape C1-2 : nommer la faim qui n''est pas seulement le ventre, lire des chiffres inventés du Filtre des Herbes, entendre la colère des jardiniers de la rive, peser une application inventée (Fil-des-Herbes), débattre du marketing du Marché des Lampions, et composer un recueil de plaisirs minuscules — Félicie Ndayishimiye tient le bol, Oscar Niyitegeka garde la terre, Karim Bamba compte sans écraser, Lila Sow tend le micro.',
      cefr_level = 'C1',
      published = false,
      updated_at = now()
    WHERE id = v_module_id;
  END IF;

  -- ===== Le creux a un nom =====
  SELECT s.id INTO v_seq_id
  FROM elearning_sequences s
  WHERE s.module_id = v_module_id AND s.title = 'Le creux a un nom'
  LIMIT 1;

  IF v_seq_id IS NULL THEN
    INSERT INTO elearning_sequences (module_id, title, order_index)
    VALUES (v_module_id, 'Le creux a un nom', 0)
    RETURNING id INTO v_seq_id;
  ELSE
    UPDATE elearning_sequences
    SET order_index = 0
    WHERE id = v_seq_id;
  END IF;

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CO — Le creux a un nom',
    'CO',
    $c$Objectif
Comprendre un échange long et en extraire l'implicite. Définir une faim qui n'est pas seulement le ventre et relier goûts et émotions. Viser la nuance, la collocation et l'implicite.

Consigne
Lisez le débat (à écouter avec l'enseignant). Qu'est-ce qui est dit, qu'est-ce qui reste implicite, qui concède quoi ?

Support — Débat Radio Figuier — Le creux a un nom
Lila Sow : Radio Figuier. On parle trop vite de la faim qui n'est pas seulement le ventre, comme si le mot dispensait d'en examiner le prix.
Marc Nkurunziza : Encore que l'on réduise la faim à un oubli de bol, une tristesse qui se déguise en appétit n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Léa Niyonzima : Félicie Ndayishimiye concède que un bol peut consoler un instant, pour autant que l'on n'appelle pas consolation ce qui empêche de parler.
Aline Uwase : Ce que l'on nomme sensation, ici, n'est pas un slogan : information du corps, plus large que la faim.
Patrick Habimana : Félicie pose le bol et attend : le creux n'est pas toujours le ventre.
Hawa Diallo : Patrick croit qu'un proverbe suffit ; Aline demande une définition.
Joël Mugisha : Hawa dit qu'elle mange plus vite quand Radio Figuier parle trop fort.
Rose Iradukunda : Karim refuse de chiffrer la tristesse, mais il note les midis silencieux.
Solange Mukamana : Rose coud en goûtant : les mains savent ce que la bouche nie.
Karim Bamba : Sami rit trop fort ; Yvette entend la faim derrière le rire.
Félicie Ndayishimiye : Un chiffre, une trace : Félicie a noté sept midis sans parole, trois bols trop vite, une infusion trop chaude pour cacher les yeux.
Dieudonné Hakizimana : L'enjeu n'est pas d'avoir raison plus fort : il s'agit de pouvoir dire j'ai faim de présence, non seulement de sel
Yvette : Oscar Niyitegeka apporte des feuilles : la terre aussi a des creux.
Mado : Aline Uwase entend, dans « juste un creux », ceci qui n'est pas dit : dire juste un creux permet souvent de ne pas nommer la solitude de midi
Sami : Autrement dit, la sensation n'est pas une faiblesse : c'est une information que le Seuil refuse trop vite
Lila Sow : Je reformule pour les auditeurs. La proposition qui reste debout est celle-ci : un recueil de plaisirs minuscules qui nomme l'émotion sans la moraliser
Nina Kayitesi : Lila : définir, ce n'est pas accuser, c'est donner un nom qui ne fasse pas honte.
Lila Sow : Nous clôturons sans clore. Nous clôturons sans fusionner les voix : l'article du Cahier du chemin d'un côté, le livre lu à voix haute par Mado de l'autre, et le point où elles refusent de se ressembler.
$c$,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "une tristesse qui se déguise en appétit est présenté comme un simple détail sans conséquence.",
  "correct": false,
  "explanation": "Le texte affirme au contraire que une tristesse qui se déguise en appétit n'est pas un détail."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Selon Aline Uwase, que reste-t-il implicite dans « juste un creux » ?",
  "options": [
    {
      "text": "Que Félicie interdit les bols",
      "correct": false
    },
    {
      "text": "Ne pas nommer la solitude de midi",
      "correct": true
    },
    {
      "text": "Que Mado refuse toute émotion à table",
      "correct": false
    },
    {
      "text": "Que le sel guérit la solitude",
      "correct": false
    }
  ],
  "explanation": "dire juste un creux permet souvent de ne pas nommer la solitude de midi"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "sensation",
      "right": "information du corps, plus large que la faim"
    },
    {
      "left": "appétit",
      "right": "élan vers le bol, parfois vers autre chose"
    },
    {
      "left": "solitude",
      "right": "midi sans parole sous le figuier"
    },
    {
      "left": "recueil",
      "right": "ensemble de plaisirs minuscules, non une leçon"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nEncore que l'on ___ , une tristesse qui se déguise en appétit n'est pas un détail. (nommer, subj.)",
  "answer": "nomme"
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
    "nomme",
    "la",
    "lumière",
    "sensation",
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
  "word": "sensation",
  "hint": "information du corps, plus large que la faim"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Encore que l'on nommer trop vite, une tristesse qui se déguise en appétit n'est pas un détail, et Félicie Ndayishimiye écoute.",
  "correct_sentence": "Encore que l'on nomme trop vite, une tristesse qui se déguise en appétit n'est pas un détail, et Félicie Ndayishimiye écoute.",
  "explanation": "Après encore que : nomme."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-c1-m2/faim-emotion.svg",
      "word": "faim emotion"
    },
    {
      "image_path": "/elearning/mfk-c1-m2/bol-felicie.svg",
      "word": "bol felicie"
    },
    {
      "image_path": "/elearning/mfk-c1-m2/carte-mentale.svg",
      "word": "carte mentale"
    },
    {
      "image_path": "/elearning/mfk-c1-m2/plaisir-minuscule.svg",
      "word": "plaisir minuscule"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Reformulez l'implicite de « juste un creux » et la concession de Félicie Ndayishimiye."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez une synthèse d'environ quatre-vingt-dix secondes : deux points de vue, un implicite, une proposition. Gardez l'article du Cahier du chemin et le livre lu à voix haute par Mado distincts."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CE — Le creux a un nom',
    'CE',
    $c$Objectif
Lire un texte argumenté long, synthétiser et reformuler. Définir une faim qui n'est pas seulement le ventre et relier goûts et émotions. Viser la nuance, la collocation et l'implicite.

Consigne
Lisez « Le creux a un nom », sans aller trop vite. Repérez la thèse, la concession, l'implicite et la proposition.

Support — Le creux a un nom
On parle trop vite de la faim qui n'est pas seulement le ventre, comme si le mot dispensait d'en examiner le prix.
Encore que l'on réduise la faim à un oubli de bol, une tristesse qui se déguise en appétit n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Félicie Ndayishimiye concède que un bol peut consoler un instant, pour autant que l'on n'appelle pas consolation ce qui empêche de parler.
Ce que l'on nomme sensation, ici, n'est pas un slogan : information du corps, plus large que la faim.
Félicie pose le bol et attend : le creux n'est pas toujours le ventre.
Patrick croit qu'un proverbe suffit ; Aline demande une définition.
Hawa dit qu'elle mange plus vite quand Radio Figuier parle trop fort.
Karim refuse de chiffrer la tristesse, mais il note les midis silencieux.
Rose coud en goûtant : les mains savent ce que la bouche nie.
Sami rit trop fort ; Yvette entend la faim derrière le rire.
Un chiffre, une trace : Félicie a noté sept midis sans parole, trois bols trop vite, une infusion trop chaude pour cacher les yeux.
L'enjeu n'est pas d'avoir raison plus fort : il s'agit de pouvoir dire j'ai faim de présence, non seulement de sel
Oscar Niyitegeka apporte des feuilles : la terre aussi a des creux.
Aline Uwase entend, dans « juste un creux », ceci qui n'est pas dit : dire juste un creux permet souvent de ne pas nommer la solitude de midi
Autrement dit, la sensation n'est pas une faiblesse : c'est une information que le Seuil refuse trop vite
La proposition qui reste debout est celle-ci : un recueil de plaisirs minuscules qui nomme l'émotion sans la moraliser
Lila : définir, ce n'est pas accuser, c'est donner un nom qui ne fasse pas honte.
Nous clôturons sans fusionner les voix : l'article du Cahier du chemin d'un côté, le livre lu à voix haute par Mado de l'autre, et le point où elles refusent de se ressembler.
Signé : Félicie Ndayishimiye, Rukiri-Nord — Cahier des racines, Rukiri-Nord.
$c$,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Le texte refuse de fusionner l'article du Cahier du chemin et le livre lu à voix haute par Mado en une seule affiche.",
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
      "text": "Sept midis sans parole, trois bols trop vite",
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
  "explanation": "Félicie a noté sept midis sans parole, trois bols trop vite, une infusion trop chaude pour cacher les yeux."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "sensation",
      "right": "information du corps, plus large que la faim"
    },
    {
      "left": "appétit",
      "right": "élan vers le bol, parfois vers autre chose"
    },
    {
      "left": "solitude",
      "right": "midi sans parole sous le figuier"
    },
    {
      "left": "recueil",
      "right": "ensemble de plaisirs minuscules, non une leçon"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nLa ___ n'est un abri que si l'on en parle vraiment. (sensation déjà nom ou verbe à nominaliser)",
  "answer": "sensation"
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
    "sensation",
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
  "word": "appétit",
  "hint": "élan vers le bol, parfois vers autre chose"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "La sensation de trop vite n'aide personne, et Aline Uwase reprend le fil.",
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
      "image_path": "/elearning/mfk-c1-m2/bol-felicie.svg",
      "word": "bol felicie"
    },
    {
      "image_path": "/elearning/mfk-c1-m2/carte-mentale.svg",
      "word": "carte mentale"
    },
    {
      "image_path": "/elearning/mfk-c1-m2/plaisir-minuscule.svg",
      "word": "plaisir minuscule"
    },
    {
      "image_path": "/elearning/mfk-c1-m2/ration-chiffre.svg",
      "word": "ration chiffre"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Synthétisez « Le creux a un nom » : thèse, concession, implicite, proposition (quinze lignes)."
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
    'PO — Le creux a un nom : dire sans slogan',
    'PO',
    $c$Objectif
Produire un oral structuré (thèse, concession, proposition). Point : définir une notion ; cause émotionnelle ; nominalisation des sensations.

Consigne
Répétez les modèles, puis prenez position en une minute : thèse, concession, reformulation, proposition.

Support — Modèles d'Aline Uwase, banc du figuier
Encore que l'on réduise la faim à un oubli de bol, une tristesse qui se déguise en appétit n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Félicie Ndayishimiye concède que un bol peut consoler un instant, pour autant que l'on n'appelle pas consolation ce qui empêche de parler.
Ce que l'on nomme sensation, ici, n'est pas un slogan : information du corps, plus large que la faim.
Encore que l'on nomme, une tristesse qui se déguise en appétit n'est pas un détail.
Félicie Ndayishimiye concède que un bol peut consoler un instant, pour autant que l'on n'appelle pas consolation ce qui empêche de parler.
Autrement dit, la sensation n'est pas une faiblesse : c'est une information que le Seuil refuse trop vite
Il ressort qu'un recueil de plaisirs minuscules qui nomme l'émotion sans la moraliser
Patrick croit qu'un proverbe suffit ; Aline demande une définition.
Rose coud en goûtant : les mains savent ce que la bouche nie.
La proposition qui reste debout est celle-ci : un recueil de plaisirs minuscules qui nomme l'émotion sans la moraliser
Je concède le point, je n'abandonne pas la proposition.
Ce n'est pas que je refuse : c'est que je refuse qu'on nomme cela un détail.
Autrement dit, l'implicite fait autant de travail que la thèse.
En une minute : fait, angle, concession, proposition.
Nous clôturons sans fusionner les voix : l'article du Cahier du chemin d'un côté, le livre lu à voix haute par Mado de l'autre, et le point où elles refusent de se ressembler.
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
  "statement": "Félicie Ndayishimiye transforme la concession en abandon de toute proposition.",
  "correct": false,
  "explanation": "Félicie Ndayishimiye concède que un bol peut consoler un instant, pour autant que l'on n'appelle pas consolation ce qui empêche de parler."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Que concède Félicie Ndayishimiye, et à quelle condition ?",
  "options": [
    {
      "text": "Félicie Ndayishimiye n'accorde rien et ferme le banc",
      "correct": false
    },
    {
      "text": "un bol peut consoler un instant — à condition que l'on n'appelle pas consolation ce qui empêche de parler",
      "correct": true
    },
    {
      "text": "Félicie Ndayishimiye abandonne il s'agit de pouvoir dire j'ai faim de présence, non seulement de sel",
      "correct": false
    },
    {
      "text": "La concession vaut acceptation du slogan",
      "correct": false
    }
  ],
  "explanation": "Concession réelle, pas un abandon : l'on n'appelle pas consolation ce qui empêche de parler"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "sensation",
      "right": "information du corps, plus large que la faim"
    },
    {
      "left": "appétit",
      "right": "élan vers le bol, parfois vers autre chose"
    },
    {
      "left": "solitude",
      "right": "midi sans parole sous le figuier"
    },
    {
      "left": "recueil",
      "right": "ensemble de plaisirs minuscules, non une leçon"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nPour autant que l'on ___ , Félicie concède un point. (nommer, subj.)",
  "answer": "nomme"
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
    "recueil",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "solitude",
  "hint": "midi sans parole sous le figuier"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Félicie Ndayishimiye écoute encore, et il fautons nommer avant de crier.",
  "correct_sentence": "Félicie Ndayishimiye écoute encore, et il faut nommer avant de crier.",
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
      "image_path": "/elearning/mfk-c1-m2/carte-mentale.svg",
      "word": "carte mentale"
    },
    {
      "image_path": "/elearning/mfk-c1-m2/plaisir-minuscule.svg",
      "word": "plaisir minuscule"
    },
    {
      "image_path": "/elearning/mfk-c1-m2/ration-chiffre.svg",
      "word": "ration chiffre"
    },
    {
      "image_path": "/elearning/mfk-c1-m2/graphique-sante.svg",
      "word": "graphique sante"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Écrivez six phrases orales justes : deux sur définir une notion ; cause émotionnelle ; nominalisation des sensations, deux concessions, deux propositions."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez quatre modèles, puis votre prise de position (thèse, concession, proposition). Gardez l'article du Cahier du chemin et le livre lu à voix haute par Mado distincts."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PE — le texte de Félicie Ndayishimiye',
    'PE',
    $c$Objectif
Écrire un texte long et structuré. Définir une faim qui n'est pas seulement le ventre et relier goûts et émotions. Point : définir une notion ; cause émotionnelle ; nominalisation des sensations.

Consigne
Imitez le texte de Félicie Ndayishimiye.

Support — Félicie Ndayishimiye — Le creux a un nom
Félicie Ndayishimiye — Le creux a un nom
On parle trop vite de la faim qui n'est pas seulement le ventre, comme si le mot dispensait d'en examiner le prix.
Encore que l'on réduise la faim à un oubli de bol, une tristesse qui se déguise en appétit n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Félicie Ndayishimiye concède que un bol peut consoler un instant, pour autant que l'on n'appelle pas consolation ce qui empêche de parler.
Ce que l'on nomme sensation, ici, n'est pas un slogan : information du corps, plus large que la faim.
Félicie pose le bol et attend : le creux n'est pas toujours le ventre.
Rose coud en goûtant : les mains savent ce que la bouche nie.
Sami rit trop fort ; Yvette entend la faim derrière le rire.
Oscar Niyitegeka apporte des feuilles : la terre aussi a des creux.
La proposition qui reste debout est celle-ci : un recueil de plaisirs minuscules qui nomme l'émotion sans la moraliser
Lila : définir, ce n'est pas accuser, c'est donner un nom qui ne fasse pas honte.
Nous clôturons sans fusionner les voix : l'article du Cahier du chemin d'un côté, le livre lu à voix haute par Mado de l'autre, et le point où elles refusent de se ressembler.
Encore que l'on nomme, une tristesse qui se déguise en appétit n'est pas un détail.
Félicie Ndayishimiye concède que un bol peut consoler un instant, pour autant que l'on n'appelle pas consolation ce qui empêche de parler.
Je n'écris pas pour vaincre : j'écris pour que la cour puisse relire.
la sensation n'est pas une faiblesse : c'est une information que le Seuil refuse trop vite
Félicie Ndayishimiye, Rukiri-Nord
$c$,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "La proposition retenue est : un recueil de plaisirs minuscules qui nomme l'émotion sans la moraliser",
  "correct": true,
  "explanation": "un recueil de plaisirs minuscules qui nomme l'émotion sans la moraliser"
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
      "text": "un recueil de plaisirs minuscules qui nomme l'émotion sans la moraliser",
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
  "explanation": "un recueil de plaisirs minuscules qui nomme l'émotion sans la moraliser"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "sensation",
      "right": "information du corps, plus large que la faim"
    },
    {
      "left": "appétit",
      "right": "élan vers le bol, parfois vers autre chose"
    },
    {
      "left": "solitude",
      "right": "midi sans parole sous le figuier"
    },
    {
      "left": "recueil",
      "right": "ensemble de plaisirs minuscules, non une leçon"
    }
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
  "word": "recueil",
  "hint": "ensemble de plaisirs minuscules, non une leçon"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Les arguments de Félicie Ndayishimiye est clairs, et Lila garde le micro ouvert.",
  "correct_sentence": "Les arguments de Félicie Ndayishimiye sont clairs, et Lila garde le micro ouvert.",
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
      "image_path": "/elearning/mfk-c1-m2/plaisir-minuscule.svg",
      "word": "plaisir minuscule"
    },
    {
      "image_path": "/elearning/mfk-c1-m2/ration-chiffre.svg",
      "word": "ration chiffre"
    },
    {
      "image_path": "/elearning/mfk-c1-m2/graphique-sante.svg",
      "word": "graphique sante"
    },
    {
      "image_path": "/elearning/mfk-c1-m2/rapport-etude.svg",
      "word": "rapport etude"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Imitez le texte de Félicie Ndayishimiye : vingt lignes, deux voix, une concession, une proposition."
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
    'EL — définir une notion ; cause émotionnelle ; nominalisation des sensations',
    'EL',
    $c$Objectif
Maîtriser définir une notion ; cause émotionnelle ; nominalisation des sensations au registre C1, avec collocations et pièges de construction.

Consigne
Apprenez la fiche, puis produisez des exemples justes au registre demandé.

Support — Fiche d'Aline Uwase, banc ocre
Fiche C1 — définir une notion ; cause émotionnelle ; nominalisation des sensations
On ne retient pas une liste : on retient des constructions et des collocations.
Encore que l'on nomme, une tristesse qui se déguise en appétit n'est pas un détail.
Félicie Ndayishimiye concède que un bol peut consoler un instant, pour autant que l'on n'appelle pas consolation ce qui empêche de parler.
Autrement dit, la sensation n'est pas une faiblesse : c'est une information que le Seuil refuse trop vite
Il ressort qu'un recueil de plaisirs minuscules qui nomme l'émotion sans la moraliser
Piège : indicatif après encore que
Registre : soutenu argumentatif, sans slogan
Collocation : encore que, pour autant que, il ressort que
Ce que l'on nomme sensation, ici, n'est pas un slogan : information du corps, plus large que la faim.
Patrick croit qu'un proverbe suffit ; Aline demande une définition.
Rose coud en goûtant : les mains savent ce que la bouche nie.
Nominaliser, ce n'est pas alourdir : c'est nommer le processus (la densification, l'accueil, le rappel).
Encore que / pour autant que / si tant est que : subjonctif, concession réelle, pas un ornement.
Reformuler une source : on change la syntaxe, on garde la charge, on signale le point de vue.
C1 : l'implicite se justifie. C2 : l'ironie se laisse entendre sans s'afficher.
Exemple fautif à ne plus produire : On va au solitude pour de vrai genre, et Aline Uwase demande un registre plus net.
Correction : On va au solitude vraiment, et Aline Uwase demande un registre plus net.
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
      "left": "sensation",
      "right": "information du corps, plus large que la faim"
    },
    {
      "left": "appétit",
      "right": "élan vers le bol, parfois vers autre chose"
    },
    {
      "left": "solitude",
      "right": "midi sans parole sous le figuier"
    },
    {
      "left": "recueil",
      "right": "ensemble de plaisirs minuscules, non une leçon"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nOn dira la ___ plutôt qu'un slogan. (nom de appétit)",
  "answer": "appétit"
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
    "nomme",
    "Félicie",
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
  "sentence_with_error": "On va au solitude pour de vrai genre, et Aline Uwase demande un registre plus net.",
  "correct_sentence": "On va au solitude vraiment, et Aline Uwase demande un registre plus net.",
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
      "image_path": "/elearning/mfk-c1-m2/ration-chiffre.svg",
      "word": "ration chiffre"
    },
    {
      "image_path": "/elearning/mfk-c1-m2/graphique-sante.svg",
      "word": "graphique sante"
    },
    {
      "image_path": "/elearning/mfk-c1-m2/rapport-etude.svg",
      "word": "rapport etude"
    },
    {
      "image_path": "/elearning/mfk-c1-m2/balance-sel.svg",
      "word": "balance sel"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Tableau de langue : six exemples justes de « définir une notion ; cause émotionnelle ; nominalisation des sensations » et deux pièges commentés."
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

  -- ===== Un tiers n'est pas une morale =====
  SELECT s.id INTO v_seq_id
  FROM elearning_sequences s
  WHERE s.module_id = v_module_id AND s.title = 'Un tiers n''est pas une morale'
  LIMIT 1;

  IF v_seq_id IS NULL THEN
    INSERT INTO elearning_sequences (module_id, title, order_index)
    VALUES (v_module_id, 'Un tiers n''est pas une morale', 1)
    RETURNING id INTO v_seq_id;
  ELSE
    UPDATE elearning_sequences
    SET order_index = 1
    WHERE id = v_seq_id;
  END IF;

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CO — Un tiers n''est pas une morale',
    'CO',
    $c$Objectif
Comprendre un échange long et en extraire l'implicite. Restituer des données inventées du Filtre des Herbes sans en faire une sentence. Viser la nuance, la collocation et l'implicite.

Consigne
Lisez le débat (à écouter avec l'enseignant). Qu'est-ce qui est dit, qu'est-ce qui reste implicite, qui concède quoi ?

Support — Débat Radio Figuier — Un tiers n'est pas une morale
Lila Sow : Radio Figuier. On parle trop vite de les rations inventées du Filtre des Herbes, comme si le mot dispensait d'en examiner le prix.
Marc Nkurunziza : Encore que l'on close le débat par un pourcentage, un rapport qui n'a pas goûté le bol n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Léa Niyonzima : Karim Bamba concède que un graphique peut alerter, pour autant que l'on dise qui a pesé, quand, et ce que le chiffre ne voit pas.
Aline Uwase : Ce que l'on nomme statistique, ici, n'est pas un slogan : donnée chiffrée, pas une sentence.
Patrick Habimana : Karim lit le graphique sans sourire : un tiers n'est pas une foule, c'est une alerte.
Hawa Diallo : Oscar dit que le jeudi, la terre a soif avant les étiquettes.
Joël Mugisha : Inès objecte : le sel excessif n'explique pas tous les maux, il en éclaire certains.
Rose Iradukunda : Aline : alors que le pourcentage monte, le bol de Félicie, lui, se vide trop vite.
Solange Mukamana : Léa demande qui a pesé, et à quelle heure d'ombre.
Karim Bamba : Marc refuse la formule les chiffres parlent : quelqu'un les a fait parler.
Félicie Ndayishimiye : Un chiffre, une trace : Le Filtre annonce : près d'un bol sur trois trop salé, deux jardins moins arrosés, une file plus longue le jeudi.
Dieudonné Hakizimana : L'enjeu n'est pas d'avoir raison plus fort : il s'agit que la santé du Seuil ne soit pas un slogan chiffré
Yvette : Lila cittera le Filtre et l'entretien, pas l'un contre l'autre comme une guerre.
Mado : Inès Mukama entend, dans « les chiffres parlent d'eux-mêmes », ceci qui n'est pas dit : les chiffres parlent d'eux-mêmes veut souvent dire ne me posez plus de questions
Sami : Autrement dit, s'établir à un tiers n'est pas prouver une morale : c'est ouvrir une lecture
Lila Sow : Je reformule pour les auditeurs. La proposition qui reste debout est celle-ci : un article qui cite le Filtre, oppose alors que, et refuse la sentence
Nina Kayitesi : Hawa : restituer, c'est garder le doute là où le rapport trop lisse le cache.
Lila Sow : Nous clôturons sans clore. Nous clôturons sans fusionner les voix : le graphique du Filtre des Herbes d'un côté, l'entretien d'Oscar au Marché des Herbes de l'autre, et le point où elles refusent de se ressembler.
$c$,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "un rapport qui n'a pas goûté le bol est présenté comme un simple détail sans conséquence.",
  "correct": false,
  "explanation": "Le texte affirme au contraire que un rapport qui n'a pas goûté le bol n'est pas un détail."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Selon Inès Mukama, que reste-t-il implicite dans « les chiffres parlent d'eux-mêmes » ?",
  "options": [
    {
      "text": "Que le Filtre a menti pour vendre du sel",
      "correct": false
    },
    {
      "text": "Ne plus poser de questions au rapport",
      "correct": true
    },
    {
      "text": "Que Oscar refuse tout chiffre",
      "correct": false
    },
    {
      "text": "Que Inès a fermé l'infirmerie",
      "correct": false
    }
  ],
  "explanation": "les chiffres parlent d'eux-mêmes veut souvent dire ne me posez plus de questions"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "statistique",
      "right": "donnée chiffrée, pas une sentence"
    },
    {
      "left": "ration",
      "right": "part pesée, parfois injuste"
    },
    {
      "left": "graphique",
      "right": "image de nombres, muette sur le goût"
    },
    {
      "left": "rapport",
      "right": "texte d'enquête, à relire, non à adorer"
    }
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
  "word": "statistique",
  "hint": "donnée chiffrée, pas une sentence"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "La part de bols trop salés s'établissent à un tiers, et Karim Bamba refuse d'en faire une morale.",
  "correct_sentence": "La part de bols trop salés s'établit à un tiers, et Karim Bamba refuse d'en faire une morale.",
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
      "image_path": "/elearning/mfk-c1-m2/graphique-sante.svg",
      "word": "graphique sante"
    },
    {
      "image_path": "/elearning/mfk-c1-m2/rapport-etude.svg",
      "word": "rapport etude"
    },
    {
      "image_path": "/elearning/mfk-c1-m2/balance-sel.svg",
      "word": "balance sel"
    },
    {
      "image_path": "/elearning/mfk-c1-m2/jardinier-rive.svg",
      "word": "jardinier rive"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Reformulez l'implicite de « les chiffres parlent d'eux-mêmes » et la concession de Karim Bamba."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez une synthèse d'environ quatre-vingt-dix secondes : deux points de vue, un implicite, une proposition. Gardez le graphique du Filtre des Herbes et l'entretien d'Oscar au Marché des Herbes distincts."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CE — Un tiers n''est pas une morale',
    'CE',
    $c$Objectif
Lire un texte argumenté long, synthétiser et reformuler. Restituer des données inventées du Filtre des Herbes sans en faire une sentence. Viser la nuance, la collocation et l'implicite.

Consigne
Lisez « Un tiers n'est pas une morale », sans aller trop vite. Repérez la thèse, la concession, l'implicite et la proposition.

Support — Un tiers n'est pas une morale
On parle trop vite de les rations inventées du Filtre des Herbes, comme si le mot dispensait d'en examiner le prix.
Encore que l'on close le débat par un pourcentage, un rapport qui n'a pas goûté le bol n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Karim Bamba concède que un graphique peut alerter, pour autant que l'on dise qui a pesé, quand, et ce que le chiffre ne voit pas.
Ce que l'on nomme statistique, ici, n'est pas un slogan : donnée chiffrée, pas une sentence.
Karim lit le graphique sans sourire : un tiers n'est pas une foule, c'est une alerte.
Oscar dit que le jeudi, la terre a soif avant les étiquettes.
Inès objecte : le sel excessif n'explique pas tous les maux, il en éclaire certains.
Aline : alors que le pourcentage monte, le bol de Félicie, lui, se vide trop vite.
Léa demande qui a pesé, et à quelle heure d'ombre.
Marc refuse la formule les chiffres parlent : quelqu'un les a fait parler.
Un chiffre, une trace : Le Filtre annonce : près d'un bol sur trois trop salé, deux jardins moins arrosés, une file plus longue le jeudi.
L'enjeu n'est pas d'avoir raison plus fort : il s'agit que la santé du Seuil ne soit pas un slogan chiffré
Lila cittera le Filtre et l'entretien, pas l'un contre l'autre comme une guerre.
Inès Mukama entend, dans « les chiffres parlent d'eux-mêmes », ceci qui n'est pas dit : les chiffres parlent d'eux-mêmes veut souvent dire ne me posez plus de questions
Autrement dit, s'établir à un tiers n'est pas prouver une morale : c'est ouvrir une lecture
La proposition qui reste debout est celle-ci : un article qui cite le Filtre, oppose alors que, et refuse la sentence
Hawa : restituer, c'est garder le doute là où le rapport trop lisse le cache.
Nous clôturons sans fusionner les voix : le graphique du Filtre des Herbes d'un côté, l'entretien d'Oscar au Marché des Herbes de l'autre, et le point où elles refusent de se ressembler.
Signé : Karim Bamba, Rukiri-Nord — Cahier des racines, Rukiri-Nord.
$c$,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Le texte refuse de fusionner le graphique du Filtre des Herbes et l'entretien d'Oscar au Marché des Herbes en une seule affiche.",
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
      "text": "Un bol sur trois trop salé, file plus longue le jeudi",
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
  "explanation": "Le Filtre annonce : près d'un bol sur trois trop salé, deux jardins moins arrosés, une file plus longue le jeudi."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "statistique",
      "right": "donnée chiffrée, pas une sentence"
    },
    {
      "left": "ration",
      "right": "part pesée, parfois injuste"
    },
    {
      "left": "graphique",
      "right": "image de nombres, muette sur le goût"
    },
    {
      "left": "rapport",
      "right": "texte d'enquête, à relire, non à adorer"
    }
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
  "word": "ration",
  "hint": "part pesée, parfois injuste"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "La statistique de trop vite n'aide personne, et Inès Mukama reprend le fil.",
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
      "image_path": "/elearning/mfk-c1-m2/rapport-etude.svg",
      "word": "rapport etude"
    },
    {
      "image_path": "/elearning/mfk-c1-m2/balance-sel.svg",
      "word": "balance sel"
    },
    {
      "image_path": "/elearning/mfk-c1-m2/jardinier-rive.svg",
      "word": "jardinier rive"
    },
    {
      "image_path": "/elearning/mfk-c1-m2/colere-marche.svg",
      "word": "colere marche"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Synthétisez « Un tiers n'est pas une morale » : thèse, concession, implicite, proposition (quinze lignes)."
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
    'PO — Un tiers n''est pas une morale : dire sans slogan',
    'PO',
    $c$Objectif
Produire un oral structuré (thèse, concession, proposition). Point : commenter des chiffres ; s'établir à ; alors que.

Consigne
Répétez les modèles, puis prenez position en une minute : thèse, concession, reformulation, proposition.

Support — Modèles d'Aline Uwase, banc du figuier
Encore que l'on close le débat par un pourcentage, un rapport qui n'a pas goûté le bol n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Karim Bamba concède que un graphique peut alerter, pour autant que l'on dise qui a pesé, quand, et ce que le chiffre ne voit pas.
Ce que l'on nomme statistique, ici, n'est pas un slogan : donnée chiffrée, pas une sentence.
Encore que l'on pèse, un rapport qui n'a pas goûté le bol n'est pas un détail.
Karim Bamba concède que un graphique peut alerter, pour autant que l'on dise qui a pesé, quand, et ce que le chiffre ne voit pas.
Autrement dit, s'établir à un tiers n'est pas prouver une morale : c'est ouvrir une lecture
Il ressort qu'un article qui cite le Filtre, oppose alors que, et refuse la sentence
Oscar dit que le jeudi, la terre a soif avant les étiquettes.
Léa demande qui a pesé, et à quelle heure d'ombre.
La proposition qui reste debout est celle-ci : un article qui cite le Filtre, oppose alors que, et refuse la sentence
Je concède le point, je n'abandonne pas la proposition.
Ce n'est pas que je refuse : c'est que je refuse qu'on nomme cela un détail.
Autrement dit, l'implicite fait autant de travail que la thèse.
En une minute : fait, angle, concession, proposition.
Nous clôturons sans fusionner les voix : le graphique du Filtre des Herbes d'un côté, l'entretien d'Oscar au Marché des Herbes de l'autre, et le point où elles refusent de se ressembler.
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
  "explanation": "Karim Bamba concède que un graphique peut alerter, pour autant que l'on dise qui a pesé, quand, et ce que le chiffre ne voit pas."
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
      "text": "un graphique peut alerter — à condition que l'on dise qui a pesé, quand, et ce que le chiffre ne voit pas",
      "correct": true
    },
    {
      "text": "Karim Bamba abandonne il s'agit que la santé du Seuil ne soit pas un slogan chiffré",
      "correct": false
    },
    {
      "text": "La concession vaut acceptation du slogan",
      "correct": false
    }
  ],
  "explanation": "Concession réelle, pas un abandon : l'on dise qui a pesé, quand, et ce que le chiffre ne voit pas"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "statistique",
      "right": "donnée chiffrée, pas une sentence"
    },
    {
      "left": "ration",
      "right": "part pesée, parfois injuste"
    },
    {
      "left": "graphique",
      "right": "image de nombres, muette sur le goût"
    },
    {
      "left": "rapport",
      "right": "texte d'enquête, à relire, non à adorer"
    }
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
  "word": "graphique",
  "hint": "image de nombres, muette sur le goût"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Karim Bamba écoute encore, et il fautons peser avant de crier.",
  "correct_sentence": "Karim Bamba écoute encore, et il faut peser avant de crier.",
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
      "image_path": "/elearning/mfk-c1-m2/balance-sel.svg",
      "word": "balance sel"
    },
    {
      "image_path": "/elearning/mfk-c1-m2/jardinier-rive.svg",
      "word": "jardinier rive"
    },
    {
      "image_path": "/elearning/mfk-c1-m2/colere-marche.svg",
      "word": "colere marche"
    },
    {
      "image_path": "/elearning/mfk-c1-m2/file-herbes.svg",
      "word": "file herbes"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Écrivez six phrases orales justes : deux sur commenter des chiffres ; s'établir à ; alors que, deux concessions, deux propositions."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez quatre modèles, puis votre prise de position (thèse, concession, proposition). Gardez le graphique du Filtre des Herbes et l'entretien d'Oscar au Marché des Herbes distincts."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PE — le texte de Karim Bamba',
    'PE',
    $c$Objectif
Écrire un texte long et structuré. Restituer des données inventées du Filtre des Herbes sans en faire une sentence. Point : commenter des chiffres ; s'établir à ; alors que.

Consigne
Imitez le texte de Karim Bamba.

Support — Karim Bamba — Un tiers n'est pas une morale
Karim Bamba — Un tiers n'est pas une morale
On parle trop vite de les rations inventées du Filtre des Herbes, comme si le mot dispensait d'en examiner le prix.
Encore que l'on close le débat par un pourcentage, un rapport qui n'a pas goûté le bol n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Karim Bamba concède que un graphique peut alerter, pour autant que l'on dise qui a pesé, quand, et ce que le chiffre ne voit pas.
Ce que l'on nomme statistique, ici, n'est pas un slogan : donnée chiffrée, pas une sentence.
Karim lit le graphique sans sourire : un tiers n'est pas une foule, c'est une alerte.
Léa demande qui a pesé, et à quelle heure d'ombre.
Marc refuse la formule les chiffres parlent : quelqu'un les a fait parler.
Lila cittera le Filtre et l'entretien, pas l'un contre l'autre comme une guerre.
La proposition qui reste debout est celle-ci : un article qui cite le Filtre, oppose alors que, et refuse la sentence
Hawa : restituer, c'est garder le doute là où le rapport trop lisse le cache.
Nous clôturons sans fusionner les voix : le graphique du Filtre des Herbes d'un côté, l'entretien d'Oscar au Marché des Herbes de l'autre, et le point où elles refusent de se ressembler.
Encore que l'on pèse, un rapport qui n'a pas goûté le bol n'est pas un détail.
Karim Bamba concède que un graphique peut alerter, pour autant que l'on dise qui a pesé, quand, et ce que le chiffre ne voit pas.
Je n'écris pas pour vaincre : j'écris pour que la cour puisse relire.
s'établir à un tiers n'est pas prouver une morale : c'est ouvrir une lecture
Karim Bamba, Rukiri-Nord
$c$,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "La proposition retenue est : un article qui cite le Filtre, oppose alors que, et refuse la sentence",
  "correct": true,
  "explanation": "un article qui cite le Filtre, oppose alors que, et refuse la sentence"
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
      "text": "un article qui cite le Filtre, oppose alors que, et refuse la sentence",
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
  "explanation": "un article qui cite le Filtre, oppose alors que, et refuse la sentence"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "statistique",
      "right": "donnée chiffrée, pas une sentence"
    },
    {
      "left": "ration",
      "right": "part pesée, parfois injuste"
    },
    {
      "left": "graphique",
      "right": "image de nombres, muette sur le goût"
    },
    {
      "left": "rapport",
      "right": "texte d'enquête, à relire, non à adorer"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nIl conviendrait que l'on ___ sans crier. (peser, subj.)",
  "answer": "pèse"
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
    "pèse",
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
  "word": "rapport",
  "hint": "texte d'enquête, à relire, non à adorer"
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
      "image_path": "/elearning/mfk-c1-m2/jardinier-rive.svg",
      "word": "jardinier rive"
    },
    {
      "image_path": "/elearning/mfk-c1-m2/colere-marche.svg",
      "word": "colere marche"
    },
    {
      "image_path": "/elearning/mfk-c1-m2/file-herbes.svg",
      "word": "file herbes"
    },
    {
      "image_path": "/elearning/mfk-c1-m2/prix-juste.svg",
      "word": "prix juste"
    }
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
    'EL — commenter des chiffres ; s''établir à ; alors que',
    'EL',
    $c$Objectif
Maîtriser commenter des chiffres ; s'établir à ; alors que au registre C1, avec collocations et pièges de construction.

Consigne
Apprenez la fiche, puis produisez des exemples justes au registre demandé.

Support — Fiche d'Aline Uwase, banc ocre
Fiche C1 — commenter des chiffres ; s'établir à ; alors que
On ne retient pas une liste : on retient des constructions et des collocations.
Encore que l'on pèse, un rapport qui n'a pas goûté le bol n'est pas un détail.
Karim Bamba concède que un graphique peut alerter, pour autant que l'on dise qui a pesé, quand, et ce que le chiffre ne voit pas.
Autrement dit, s'établir à un tiers n'est pas prouver une morale : c'est ouvrir une lecture
Il ressort qu'un article qui cite le Filtre, oppose alors que, et refuse la sentence
Piège : prendre un pourcentage pour une preuve morale
Registre : soutenu argumentatif, sans slogan
Collocation : encore que, pour autant que, il ressort que
Ce que l'on nomme statistique, ici, n'est pas un slogan : donnée chiffrée, pas une sentence.
Oscar dit que le jeudi, la terre a soif avant les étiquettes.
Léa demande qui a pesé, et à quelle heure d'ombre.
Nominaliser, ce n'est pas alourdir : c'est nommer le processus (la densification, l'accueil, le rappel).
Encore que / pour autant que / si tant est que : subjonctif, concession réelle, pas un ornement.
Reformuler une source : on change la syntaxe, on garde la charge, on signale le point de vue.
C1 : l'implicite se justifie. C2 : l'ironie se laisse entendre sans s'afficher.
Exemple fautif à ne plus produire : On va au graphique pour de vrai genre, et Inès Mukama demande un registre plus net.
Correction : On va au graphique vraiment, et Inès Mukama demande un registre plus net.
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
      "left": "statistique",
      "right": "donnée chiffrée, pas une sentence"
    },
    {
      "left": "ration",
      "right": "part pesée, parfois injuste"
    },
    {
      "left": "graphique",
      "right": "image de nombres, muette sur le goût"
    },
    {
      "left": "rapport",
      "right": "texte d'enquête, à relire, non à adorer"
    }
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
  "sentence_with_error": "On va au graphique pour de vrai genre, et Inès Mukama demande un registre plus net.",
  "correct_sentence": "On va au graphique vraiment, et Inès Mukama demande un registre plus net.",
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
      "image_path": "/elearning/mfk-c1-m2/colere-marche.svg",
      "word": "colere marche"
    },
    {
      "image_path": "/elearning/mfk-c1-m2/file-herbes.svg",
      "word": "file herbes"
    },
    {
      "image_path": "/elearning/mfk-c1-m2/prix-juste.svg",
      "word": "prix juste"
    },
    {
      "image_path": "/elearning/mfk-c1-m2/application-fil.svg",
      "word": "application fil"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Tableau de langue : six exemples justes de « commenter des chiffres ; s'établir à ; alors que » et deux pièges commentés."
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

  -- ===== La terre n'est pas un caprice =====
  SELECT s.id INTO v_seq_id
  FROM elearning_sequences s
  WHERE s.module_id = v_module_id AND s.title = 'La terre n''est pas un caprice'
  LIMIT 1;

  IF v_seq_id IS NULL THEN
    INSERT INTO elearning_sequences (module_id, title, order_index)
    VALUES (v_module_id, 'La terre n''est pas un caprice', 2)
    RETURNING id INTO v_seq_id;
  ELSE
    UPDATE elearning_sequences
    SET order_index = 2
    WHERE id = v_seq_id;
  END IF;

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CO — La terre n''est pas un caprice',
    'CO',
    $c$Objectif
Comprendre un échange long et en extraire l'implicite. Analyser et commenter un fait de société : la colère de ceux qui font pousser. Viser la nuance, la collocation et l'implicite.

Consigne
Lisez le débat (à écouter avec l'enseignant). Qu'est-ce qui est dit, qu'est-ce qui reste implicite, qui concède quoi ?

Support — Débat Radio Figuier — La terre n'est pas un caprice
Lila Sow : Radio Figuier. On parle trop vite de la colère des jardiniers de la rive, comme si le mot dispensait d'en examiner le prix.
Marc Nkurunziza : Encore que l'on réduise la colère à un caprice de saison, un prix de la terre qui flambe sans que les mains soient payées n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Léa Niyonzima : Oscar Niyitegeka concède que le Marché des Lampions attire des regards, pour autant que l'on n'y voie pas le droit d'oublier qui a planté.
Aline Uwase : Ce que l'on nomme colère, ici, n'est pas un slogan : signal politique, pas un caprice.
Patrick Habimana : Oscar parle bas : la colère trop criée sert ceux qui n'écoutent que le volume.
Hawa Diallo : Du fait que le prix flambe, les aides s'en vont, si bien que la rive maigrit.
Joël Mugisha : Félicie entend la terre avant d'entendre le slogan.
Rose Iradukunda : Patrick veut un exposé, pas une bagarre de bancs.
Solange Mukamana : Solange demande qui profite du brillant des Lampions.
Karim Bamba : Dieudonné réparerait les clôtures, pour autant qu'on cesse de les voler pour le décor.
Félicie Ndayishimiye : Un chiffre, une trace : Oscar a perdu deux aides cette lune ; la file des Herbes s'allonge d'une heure ; le Lampions vend plus brillant.
Dieudonné Hakizimana : L'enjeu n'est pas d'avoir raison plus fort : il s'agit que la rive reste une rive nourricière, non un décor
Yvette : Yvette : un fait de société a des visages, pas seulement des causes.
Mado : Karim Bamba entend, dans « ils exagèrent », ceci qui n'est pas dit : ils exagèrent signifie souvent nous ne voulons pas entendre le prix réel
Sami : Autrement dit, un fait de société se commente : causes, conséquences, visages, pas un cri contre un cri
Lila Sow : Je reformule pour les auditeurs. La proposition qui reste debout est celle-ci : un exposé qui nomme Oscar, la file, le prix, et ce que la cour peut décider dès jeudi
Nina Kayitesi : Marc : commenter, c'est refuser ils exagèrent comme seule analyse.
Lila Sow : Nous clôturons sans clore. Nous clôturons sans fusionner les voix : le récit d'Oscar au Cahier des racines d'un côté, le reportage inventé de Lila au marché de l'autre, et le point où elles refusent de se ressembler.
$c$,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "un prix de la terre qui flambe sans que les mains soient payées est présenté comme un simple détail sans conséquence.",
  "correct": false,
  "explanation": "Le texte affirme au contraire que un prix de la terre qui flambe sans que les mains soient payées n'est pas un détail."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Selon Karim Bamba, que reste-t-il implicite dans « ils exagèrent » ?",
  "options": [
    {
      "text": "Que Oscar veut fermer le figuier",
      "correct": false
    },
    {
      "text": "Refus d'entendre le prix réel",
      "correct": true
    },
    {
      "text": "Que Lila a inventé la file",
      "correct": false
    },
    {
      "text": "Que le sel est la seule cause",
      "correct": false
    }
  ],
  "explanation": "ils exagèrent signifie souvent nous ne voulons pas entendre le prix réel"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "colère",
      "right": "signal politique, pas un caprice"
    },
    {
      "left": "terre",
      "right": "sol travaillé, plus cher que l'étiquette"
    },
    {
      "left": "file",
      "right": "attente visible d'une injustice"
    },
    {
      "left": "exposé",
      "right": "parole structurée sur un fait de société"
    }
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
  "word": "colère",
  "hint": "signal politique, pas un caprice"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Du fait que le prix flambent, Oscar Niyitegeka refuse d'appeler cela un caprice, et Oscar écoute.",
  "correct_sentence": "Du fait que le prix flambe, Oscar Niyitegeka refuse d'appeler cela un caprice, et Oscar écoute.",
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
      "image_path": "/elearning/mfk-c1-m2/file-herbes.svg",
      "word": "file herbes"
    },
    {
      "image_path": "/elearning/mfk-c1-m2/prix-juste.svg",
      "word": "prix juste"
    },
    {
      "image_path": "/elearning/mfk-c1-m2/application-fil.svg",
      "word": "application fil"
    },
    {
      "image_path": "/elearning/mfk-c1-m2/conseil-achat.svg",
      "word": "conseil achat"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Reformulez l'implicite de « ils exagèrent » et la concession de Oscar Niyitegeka."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez une synthèse d'environ quatre-vingt-dix secondes : deux points de vue, un implicite, une proposition. Gardez le récit d'Oscar au Cahier des racines et le reportage inventé de Lila au marché distincts."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CE — La terre n''est pas un caprice',
    'CE',
    $c$Objectif
Lire un texte argumenté long, synthétiser et reformuler. Analyser et commenter un fait de société : la colère de ceux qui font pousser. Viser la nuance, la collocation et l'implicite.

Consigne
Lisez « La terre n'est pas un caprice », sans aller trop vite. Repérez la thèse, la concession, l'implicite et la proposition.

Support — La terre n'est pas un caprice
On parle trop vite de la colère des jardiniers de la rive, comme si le mot dispensait d'en examiner le prix.
Encore que l'on réduise la colère à un caprice de saison, un prix de la terre qui flambe sans que les mains soient payées n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Oscar Niyitegeka concède que le Marché des Lampions attire des regards, pour autant que l'on n'y voie pas le droit d'oublier qui a planté.
Ce que l'on nomme colère, ici, n'est pas un slogan : signal politique, pas un caprice.
Oscar parle bas : la colère trop criée sert ceux qui n'écoutent que le volume.
Du fait que le prix flambe, les aides s'en vont, si bien que la rive maigrit.
Félicie entend la terre avant d'entendre le slogan.
Patrick veut un exposé, pas une bagarre de bancs.
Solange demande qui profite du brillant des Lampions.
Dieudonné réparerait les clôtures, pour autant qu'on cesse de les voler pour le décor.
Un chiffre, une trace : Oscar a perdu deux aides cette lune ; la file des Herbes s'allonge d'une heure ; le Lampions vend plus brillant.
L'enjeu n'est pas d'avoir raison plus fort : il s'agit que la rive reste une rive nourricière, non un décor
Yvette : un fait de société a des visages, pas seulement des causes.
Karim Bamba entend, dans « ils exagèrent », ceci qui n'est pas dit : ils exagèrent signifie souvent nous ne voulons pas entendre le prix réel
Autrement dit, un fait de société se commente : causes, conséquences, visages, pas un cri contre un cri
La proposition qui reste debout est celle-ci : un exposé qui nomme Oscar, la file, le prix, et ce que la cour peut décider dès jeudi
Marc : commenter, c'est refuser ils exagèrent comme seule analyse.
Nous clôturons sans fusionner les voix : le récit d'Oscar au Cahier des racines d'un côté, le reportage inventé de Lila au marché de l'autre, et le point où elles refusent de se ressembler.
Signé : Oscar Niyitegeka, Rukiri-Nord — Cahier des racines, Rukiri-Nord.
$c$,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Le texte refuse de fusionner le récit d'Oscar au Cahier des racines et le reportage inventé de Lila au marché en une seule affiche.",
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
      "text": "Deux aides de moins, file plus longue, Lampions plus brillant",
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
  "explanation": "Oscar a perdu deux aides cette lune ; la file des Herbes s'allonge d'une heure ; le Lampions vend plus brillant."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "colère",
      "right": "signal politique, pas un caprice"
    },
    {
      "left": "terre",
      "right": "sol travaillé, plus cher que l'étiquette"
    },
    {
      "left": "file",
      "right": "attente visible d'une injustice"
    },
    {
      "left": "exposé",
      "right": "parole structurée sur un fait de société"
    }
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
  "word": "terre",
  "hint": "sol travaillé, plus cher que l'étiquette"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "La colère de trop vite n'aide personne, et Karim Bamba reprend le fil.",
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
      "image_path": "/elearning/mfk-c1-m2/prix-juste.svg",
      "word": "prix juste"
    },
    {
      "image_path": "/elearning/mfk-c1-m2/application-fil.svg",
      "word": "application fil"
    },
    {
      "image_path": "/elearning/mfk-c1-m2/conseil-achat.svg",
      "word": "conseil achat"
    },
    {
      "image_path": "/elearning/mfk-c1-m2/etiquette-lampe.svg",
      "word": "etiquette lampe"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Synthétisez « La terre n'est pas un caprice » : thèse, concession, implicite, proposition (quinze lignes)."
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
    'PO — La terre n''est pas un caprice : dire sans slogan',
    'PO',
    $c$Objectif
Produire un oral structuré (thèse, concession, proposition). Point : cause et conséquence avancées ; du fait que ; si bien que.

Consigne
Répétez les modèles, puis prenez position en une minute : thèse, concession, reformulation, proposition.

Support — Modèles d'Aline Uwase, banc du figuier
Encore que l'on réduise la colère à un caprice de saison, un prix de la terre qui flambe sans que les mains soient payées n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Oscar Niyitegeka concède que le Marché des Lampions attire des regards, pour autant que l'on n'y voie pas le droit d'oublier qui a planté.
Ce que l'on nomme colère, ici, n'est pas un slogan : signal politique, pas un caprice.
Encore que l'on écoute, un prix de la terre qui flambe sans que les mains soient payées n'est pas un détail.
Oscar Niyitegeka concède que le Marché des Lampions attire des regards, pour autant que l'on n'y voie pas le droit d'oublier qui a planté.
Autrement dit, un fait de société se commente : causes, conséquences, visages, pas un cri contre un cri
Il ressort qu'un exposé qui nomme Oscar, la file, le prix, et ce que la cour peut décider dès jeudi
Du fait que le prix flambe, les aides s'en vont, si bien que la rive maigrit.
Solange demande qui profite du brillant des Lampions.
La proposition qui reste debout est celle-ci : un exposé qui nomme Oscar, la file, le prix, et ce que la cour peut décider dès jeudi
Je concède le point, je n'abandonne pas la proposition.
Ce n'est pas que je refuse : c'est que je refuse qu'on nomme cela un détail.
Autrement dit, l'implicite fait autant de travail que la thèse.
En une minute : fait, angle, concession, proposition.
Nous clôturons sans fusionner les voix : le récit d'Oscar au Cahier des racines d'un côté, le reportage inventé de Lila au marché de l'autre, et le point où elles refusent de se ressembler.
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
  "statement": "Oscar Niyitegeka transforme la concession en abandon de toute proposition.",
  "correct": false,
  "explanation": "Oscar Niyitegeka concède que le Marché des Lampions attire des regards, pour autant que l'on n'y voie pas le droit d'oublier qui a planté."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Que concède Oscar Niyitegeka, et à quelle condition ?",
  "options": [
    {
      "text": "Oscar Niyitegeka n'accorde rien et ferme le banc",
      "correct": false
    },
    {
      "text": "le Marché des Lampions attire des regards — à condition que l'on n'y voie pas le droit d'oublier qui a planté",
      "correct": true
    },
    {
      "text": "Oscar Niyitegeka abandonne il s'agit que la rive reste une rive nourricière, non un décor",
      "correct": false
    },
    {
      "text": "La concession vaut acceptation du slogan",
      "correct": false
    }
  ],
  "explanation": "Concession réelle, pas un abandon : l'on n'y voie pas le droit d'oublier qui a planté"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "colère",
      "right": "signal politique, pas un caprice"
    },
    {
      "left": "terre",
      "right": "sol travaillé, plus cher que l'étiquette"
    },
    {
      "left": "file",
      "right": "attente visible d'une injustice"
    },
    {
      "left": "exposé",
      "right": "parole structurée sur un fait de société"
    }
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
  "word": "file",
  "hint": "attente visible d'une injustice"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Oscar Niyitegeka écoute encore, et il fautons écouter avant de crier.",
  "correct_sentence": "Oscar Niyitegeka écoute encore, et il faut écouter avant de crier.",
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
      "image_path": "/elearning/mfk-c1-m2/application-fil.svg",
      "word": "application fil"
    },
    {
      "image_path": "/elearning/mfk-c1-m2/conseil-achat.svg",
      "word": "conseil achat"
    },
    {
      "image_path": "/elearning/mfk-c1-m2/etiquette-lampe.svg",
      "word": "etiquette lampe"
    },
    {
      "image_path": "/elearning/mfk-c1-m2/panier-nuance.svg",
      "word": "panier nuance"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Écrivez six phrases orales justes : deux sur cause et conséquence avancées ; du fait que ; si bien que, deux concessions, deux propositions."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez quatre modèles, puis votre prise de position (thèse, concession, proposition). Gardez le récit d'Oscar au Cahier des racines et le reportage inventé de Lila au marché distincts."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PE — le texte de Oscar Niyitegeka',
    'PE',
    $c$Objectif
Écrire un texte long et structuré. Analyser et commenter un fait de société : la colère de ceux qui font pousser. Point : cause et conséquence avancées ; du fait que ; si bien que.

Consigne
Imitez le texte de Oscar Niyitegeka.

Support — Oscar Niyitegeka — La terre n'est pas un caprice
Oscar Niyitegeka — La terre n'est pas un caprice
On parle trop vite de la colère des jardiniers de la rive, comme si le mot dispensait d'en examiner le prix.
Encore que l'on réduise la colère à un caprice de saison, un prix de la terre qui flambe sans que les mains soient payées n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Oscar Niyitegeka concède que le Marché des Lampions attire des regards, pour autant que l'on n'y voie pas le droit d'oublier qui a planté.
Ce que l'on nomme colère, ici, n'est pas un slogan : signal politique, pas un caprice.
Oscar parle bas : la colère trop criée sert ceux qui n'écoutent que le volume.
Solange demande qui profite du brillant des Lampions.
Dieudonné réparerait les clôtures, pour autant qu'on cesse de les voler pour le décor.
Yvette : un fait de société a des visages, pas seulement des causes.
La proposition qui reste debout est celle-ci : un exposé qui nomme Oscar, la file, le prix, et ce que la cour peut décider dès jeudi
Marc : commenter, c'est refuser ils exagèrent comme seule analyse.
Nous clôturons sans fusionner les voix : le récit d'Oscar au Cahier des racines d'un côté, le reportage inventé de Lila au marché de l'autre, et le point où elles refusent de se ressembler.
Encore que l'on écoute, un prix de la terre qui flambe sans que les mains soient payées n'est pas un détail.
Oscar Niyitegeka concède que le Marché des Lampions attire des regards, pour autant que l'on n'y voie pas le droit d'oublier qui a planté.
Je n'écris pas pour vaincre : j'écris pour que la cour puisse relire.
un fait de société se commente : causes, conséquences, visages, pas un cri contre un cri
Oscar Niyitegeka, Rukiri-Nord
$c$,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "La proposition retenue est : un exposé qui nomme Oscar, la file, le prix, et ce que la cour peut décider dès jeudi",
  "correct": true,
  "explanation": "un exposé qui nomme Oscar, la file, le prix, et ce que la cour peut décider dès jeudi"
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
      "text": "un exposé qui nomme Oscar, la file, le prix, et ce que la cour peut décider dès jeudi",
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
  "explanation": "un exposé qui nomme Oscar, la file, le prix, et ce que la cour peut décider dès jeudi"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "colère",
      "right": "signal politique, pas un caprice"
    },
    {
      "left": "terre",
      "right": "sol travaillé, plus cher que l'étiquette"
    },
    {
      "left": "file",
      "right": "attente visible d'une injustice"
    },
    {
      "left": "exposé",
      "right": "parole structurée sur un fait de société"
    }
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
  "word": "exposé",
  "hint": "parole structurée sur un fait de société"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Les arguments de Oscar Niyitegeka est clairs, et Lila garde le micro ouvert.",
  "correct_sentence": "Les arguments de Oscar Niyitegeka sont clairs, et Lila garde le micro ouvert.",
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
      "image_path": "/elearning/mfk-c1-m2/conseil-achat.svg",
      "word": "conseil achat"
    },
    {
      "image_path": "/elearning/mfk-c1-m2/etiquette-lampe.svg",
      "word": "etiquette lampe"
    },
    {
      "image_path": "/elearning/mfk-c1-m2/panier-nuance.svg",
      "word": "panier nuance"
    },
    {
      "image_path": "/elearning/mfk-c1-m2/debat-pub.svg",
      "word": "debat pub"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Imitez le texte de Oscar Niyitegeka : vingt lignes, deux voix, une concession, une proposition."
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
    'EL — cause et conséquence avancées ; du fait que ; si bien que',
    'EL',
    $c$Objectif
Maîtriser cause et conséquence avancées ; du fait que ; si bien que au registre C1, avec collocations et pièges de construction.

Consigne
Apprenez la fiche, puis produisez des exemples justes au registre demandé.

Support — Fiche d'Aline Uwase, banc ocre
Fiche C1 — cause et conséquence avancées ; du fait que ; si bien que
On ne retient pas une liste : on retient des constructions et des collocations.
Encore que l'on écoute, un prix de la terre qui flambe sans que les mains soient payées n'est pas un détail.
Oscar Niyitegeka concède que le Marché des Lampions attire des regards, pour autant que l'on n'y voie pas le droit d'oublier qui a planté.
Autrement dit, un fait de société se commente : causes, conséquences, visages, pas un cri contre un cri
Il ressort qu'un exposé qui nomme Oscar, la file, le prix, et ce que la cour peut décider dès jeudi
Piège : confusion cause / concession
Registre : soutenu argumentatif, sans slogan
Collocation : encore que, pour autant que, il ressort que
Ce que l'on nomme colère, ici, n'est pas un slogan : signal politique, pas un caprice.
Du fait que le prix flambe, les aides s'en vont, si bien que la rive maigrit.
Solange demande qui profite du brillant des Lampions.
Nominaliser, ce n'est pas alourdir : c'est nommer le processus (la densification, l'accueil, le rappel).
Encore que / pour autant que / si tant est que : subjonctif, concession réelle, pas un ornement.
Reformuler une source : on change la syntaxe, on garde la charge, on signale le point de vue.
C1 : l'implicite se justifie. C2 : l'ironie se laisse entendre sans s'afficher.
Exemple fautif à ne plus produire : On va au file pour de vrai genre, et Karim Bamba demande un registre plus net.
Correction : On va au file vraiment, et Karim Bamba demande un registre plus net.
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
      "left": "colère",
      "right": "signal politique, pas un caprice"
    },
    {
      "left": "terre",
      "right": "sol travaillé, plus cher que l'étiquette"
    },
    {
      "left": "file",
      "right": "attente visible d'une injustice"
    },
    {
      "left": "exposé",
      "right": "parole structurée sur un fait de société"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nOn impute la hausse à terre, non au bol. (mot de la séquence)",
  "answer": "terre"
}$j$::jsonb,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Remettez les mots dans l''ordre',
    'word_order',
    $j${
  "words": [
    "Oscar",
    "impute",
    "la",
    "hausse",
    "à",
    "terre",
    "."
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
  "sentence_with_error": "On va au file pour de vrai genre, et Karim Bamba demande un registre plus net.",
  "correct_sentence": "On va au file vraiment, et Karim Bamba demande un registre plus net.",
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
      "image_path": "/elearning/mfk-c1-m2/etiquette-lampe.svg",
      "word": "etiquette lampe"
    },
    {
      "image_path": "/elearning/mfk-c1-m2/panier-nuance.svg",
      "word": "panier nuance"
    },
    {
      "image_path": "/elearning/mfk-c1-m2/debat-pub.svg",
      "word": "debat pub"
    },
    {
      "image_path": "/elearning/mfk-c1-m2/slogan-doux.svg",
      "word": "slogan doux"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Tableau de langue : six exemples justes de « cause et conséquence avancées ; du fait que ; si bien que » et deux pièges commentés."
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

  -- ===== Choisir au marché =====
  SELECT s.id INTO v_seq_id
  FROM elearning_sequences s
  WHERE s.module_id = v_module_id AND s.title = 'Choisir au marché'
  LIMIT 1;

  IF v_seq_id IS NULL THEN
    INSERT INTO elearning_sequences (module_id, title, order_index)
    VALUES (v_module_id, 'Choisir au marché', 3)
    RETURNING id INTO v_seq_id;
  ELSE
    UPDATE elearning_sequences
    SET order_index = 3
    WHERE id = v_seq_id;
  END IF;

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CO — Choisir au marché',
    'CO',
    $c$Objectif
Comprendre un échange long et en extraire l'implicite. Conseiller des achats sans ordonner, et peser une application inventée. Viser la nuance, la collocation et l'implicite.

Consigne
Lisez le débat (à écouter avec l'enseignant). Qu'est-ce qui est dit, qu'est-ce qui reste implicite, qui concède quoi ?

Support — Débat Radio Figuier — Choisir au marché
Lila Sow : Radio Figuier. On parle trop vite de l'application inventée Fil-des-Herbes, comme si le mot dispensait d'en examiner le prix.
Marc Nkurunziza : Encore que l'on remplace le goût par un score, une étiquette qui parle plus fort que Félicie n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Léa Niyonzima : Léa Niyonzima concède que un avis chiffré peut alerter sur le sel, pour autant que l'on n'achète pas un score comme on achète un bol.
Aline Uwase : Ce que l'on nomme étiquette, ici, n'est pas un slogan : texte sur le bol, à lire deux fois.
Patrick Habimana : Léa ouvre Fil-des-Herbes et rit : le bol d'Oscar n'a pas de page.
Hawa Diallo : On ferait mieux de lire l'étiquette deux fois, dit Inès, non l'écran une fois.
Joël Mugisha : Karim voit l'avantage : le sel apparaît. Il voit le piège : les mains disparaissent.
Rose Iradukunda : Rose : un conseil n'élève pas la voix.
Solange Mukamana : Joël achète trop vite quand le score est vert ; Aline le ralentit.
Karim Bamba : Sami aime l'outil ; Yvette demande qui l'a payé.
Félicie Ndayishimiye : Un chiffre, une trace : Léa a comparé : trois scores verts, un bol trop cher, zéro mention des mains d'Oscar.
Dieudonné Hakizimana : L'enjeu n'est pas d'avoir raison plus fort : il s'agit de choisir sans se laisser choisir par un slogan doux
Yvette : Lila : présenter avantages et limites, ce n'est pas condamner l'outil, c'est refuser l'obéissance.
Mado : Félicie Ndayishimiye entend, dans « mieux choisir », ceci qui n'est pas dit : mieux choisir veut souvent dire mieux obéir à un écran qu'à une file
Sami : Autrement dit, l'outil peut être un avis ; il ne doit pas devenir une loi de marché
Lila Sow : Je reformule pour les auditeurs. La proposition qui reste debout est celle-ci : échanger avantages et limites du Fil-des-Herbes, puis garder l'étiquette lue deux fois
Nina Kayitesi : Marc : il vaudrait mieux que tu lises le bol avant le slogan.
Lila Sow : Nous clôturons sans clore. Nous clôturons sans fusionner les voix : la notice du Fil-des-Herbes d'un côté, l'émission de Lila au Marché des Herbes de l'autre, et le point où elles refusent de se ressembler.
$c$,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "une étiquette qui parle plus fort que Félicie est présenté comme un simple détail sans conséquence.",
  "correct": false,
  "explanation": "Le texte affirme au contraire que une étiquette qui parle plus fort que Félicie n'est pas un détail."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Selon Félicie Ndayishimiye, que reste-t-il implicite dans « mieux choisir » ?",
  "options": [
    {
      "text": "Que Léa a écrit l'application",
      "correct": false
    },
    {
      "text": "Obéir à un écran plutôt qu'à une file",
      "correct": true
    },
    {
      "text": "Que Félicie refuse toute étiquette",
      "correct": false
    },
    {
      "text": "Que le score vert garantit Oscar",
      "correct": false
    }
  ],
  "explanation": "mieux choisir veut souvent dire mieux obéir à un écran qu'à une file"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "étiquette",
      "right": "texte sur le bol, à lire deux fois"
    },
    {
      "left": "score",
      "right": "avis chiffré, pas une loi"
    },
    {
      "left": "application",
      "right": "outil inventé Fil-des-Herbes"
    },
    {
      "left": "conseil",
      "right": "recommandation atténuée, distincte d'un ordre"
    }
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
  "word": "étiquette",
  "hint": "texte sur le bol, à lire deux fois"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Il vaudrait mieux que tu lire le bol trop vite, et Léa Niyonzima pose l'étiquette.",
  "correct_sentence": "Il vaudrait mieux que tu lises le bol trop vite, et Léa Niyonzima pose l'étiquette.",
  "explanation": "Il vaudrait mieux que + lises."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-c1-m2/panier-nuance.svg",
      "word": "panier nuance"
    },
    {
      "image_path": "/elearning/mfk-c1-m2/debat-pub.svg",
      "word": "debat pub"
    },
    {
      "image_path": "/elearning/mfk-c1-m2/slogan-doux.svg",
      "word": "slogan doux"
    },
    {
      "image_path": "/elearning/mfk-c1-m2/micro-gout.svg",
      "word": "micro gout"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Reformulez l'implicite de « mieux choisir » et la concession de Léa Niyonzima."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez une synthèse d'environ quatre-vingt-dix secondes : deux points de vue, un implicite, une proposition. Gardez la notice du Fil-des-Herbes et l'émission de Lila au Marché des Herbes distincts."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CE — Le score n''est pas le goût',
    'CE',
    $c$Objectif
Lire un texte argumenté long, synthétiser et reformuler. Conseiller des achats sans ordonner, et peser une application inventée. Viser la nuance, la collocation et l'implicite.

Consigne
Lisez « Le score n'est pas le goût », sans aller trop vite. Repérez la thèse, la concession, l'implicite et la proposition.

Support — Le score n'est pas le goût
On parle trop vite de l'application inventée Fil-des-Herbes, comme si le mot dispensait d'en examiner le prix.
Encore que l'on remplace le goût par un score, une étiquette qui parle plus fort que Félicie n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Léa Niyonzima concède que un avis chiffré peut alerter sur le sel, pour autant que l'on n'achète pas un score comme on achète un bol.
Ce que l'on nomme étiquette, ici, n'est pas un slogan : texte sur le bol, à lire deux fois.
Léa ouvre Fil-des-Herbes et rit : le bol d'Oscar n'a pas de page.
On ferait mieux de lire l'étiquette deux fois, dit Inès, non l'écran une fois.
Karim voit l'avantage : le sel apparaît. Il voit le piège : les mains disparaissent.
Rose : un conseil n'élève pas la voix.
Joël achète trop vite quand le score est vert ; Aline le ralentit.
Sami aime l'outil ; Yvette demande qui l'a payé.
Un chiffre, une trace : Léa a comparé : trois scores verts, un bol trop cher, zéro mention des mains d'Oscar.
L'enjeu n'est pas d'avoir raison plus fort : il s'agit de choisir sans se laisser choisir par un slogan doux
Lila : présenter avantages et limites, ce n'est pas condamner l'outil, c'est refuser l'obéissance.
Félicie Ndayishimiye entend, dans « mieux choisir », ceci qui n'est pas dit : mieux choisir veut souvent dire mieux obéir à un écran qu'à une file
Autrement dit, l'outil peut être un avis ; il ne doit pas devenir une loi de marché
La proposition qui reste debout est celle-ci : échanger avantages et limites du Fil-des-Herbes, puis garder l'étiquette lue deux fois
Marc : il vaudrait mieux que tu lises le bol avant le slogan.
Nous clôturons sans fusionner les voix : la notice du Fil-des-Herbes d'un côté, l'émission de Lila au Marché des Herbes de l'autre, et le point où elles refusent de se ressembler.
Signé : Léa Niyonzima, Rukiri-Nord — Cahier des racines, Rukiri-Nord.
$c$,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Le texte refuse de fusionner la notice du Fil-des-Herbes et l'émission de Lila au Marché des Herbes en une seule affiche.",
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
      "text": "Trois scores verts, zéro mention des mains",
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
  "explanation": "Léa a comparé : trois scores verts, un bol trop cher, zéro mention des mains d'Oscar."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "étiquette",
      "right": "texte sur le bol, à lire deux fois"
    },
    {
      "left": "score",
      "right": "avis chiffré, pas une loi"
    },
    {
      "left": "application",
      "right": "outil inventé Fil-des-Herbes"
    },
    {
      "left": "conseil",
      "right": "recommandation atténuée, distincte d'un ordre"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nIl vaudrait mieux que tu ___ le bol avant le slogan. (lire, subj.)",
  "answer": "lises"
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
    "lises",
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
  "word": "score",
  "hint": "avis chiffré, pas une loi"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "La étiquette de trop vite n'aide personne, et Félicie Ndayishimiye reprend le fil.",
  "correct_sentence": "La précipitation n'aide personne, et Félicie Ndayishimiye reprend le fil.",
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
      "image_path": "/elearning/mfk-c1-m2/debat-pub.svg",
      "word": "debat pub"
    },
    {
      "image_path": "/elearning/mfk-c1-m2/slogan-doux.svg",
      "word": "slogan doux"
    },
    {
      "image_path": "/elearning/mfk-c1-m2/micro-gout.svg",
      "word": "micro gout"
    },
    {
      "image_path": "/elearning/mfk-c1-m2/affiche-gout.svg",
      "word": "affiche gout"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Synthétisez « Le score n'est pas le goût » : thèse, concession, implicite, proposition (quinze lignes)."
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
    'PO — Choisir au marché : dire sans slogan',
    'PO',
    $c$Objectif
Produire un oral structuré (thèse, concession, proposition). Point : conseil atténué ; on ferait mieux de ; il vaudrait mieux que.

Consigne
Répétez les modèles, puis prenez position en une minute : thèse, concession, reformulation, proposition.

Support — Modèles d'Aline Uwase, banc du figuier
Encore que l'on remplace le goût par un score, une étiquette qui parle plus fort que Félicie n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Léa Niyonzima concède que un avis chiffré peut alerter sur le sel, pour autant que l'on n'achète pas un score comme on achète un bol.
Ce que l'on nomme étiquette, ici, n'est pas un slogan : texte sur le bol, à lire deux fois.
Encore que l'on lises, une étiquette qui parle plus fort que Félicie n'est pas un détail.
Léa Niyonzima concède que un avis chiffré peut alerter sur le sel, pour autant que l'on n'achète pas un score comme on achète un bol.
Autrement dit, l'outil peut être un avis ; il ne doit pas devenir une loi de marché
Il ressort qu'échanger avantages et limites du Fil-des-Herbes, puis garder l'étiquette lue deux fois
On ferait mieux de lire l'étiquette deux fois, dit Inès, non l'écran une fois.
Joël achète trop vite quand le score est vert ; Aline le ralentit.
La proposition qui reste debout est celle-ci : échanger avantages et limites du Fil-des-Herbes, puis garder l'étiquette lue deux fois
Je concède le point, je n'abandonne pas la proposition.
Ce n'est pas que je refuse : c'est que je refuse qu'on nomme cela un détail.
Autrement dit, l'implicite fait autant de travail que la thèse.
En une minute : fait, angle, concession, proposition.
Nous clôturons sans fusionner les voix : la notice du Fil-des-Herbes d'un côté, l'émission de Lila au Marché des Herbes de l'autre, et le point où elles refusent de se ressembler.
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
  "explanation": "Léa Niyonzima concède que un avis chiffré peut alerter sur le sel, pour autant que l'on n'achète pas un score comme on achète un bol."
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
      "text": "un avis chiffré peut alerter sur le sel — à condition que l'on n'achète pas un score comme on achète un bol",
      "correct": true
    },
    {
      "text": "Léa Niyonzima abandonne il s'agit de choisir sans se laisser choisir par un slogan doux",
      "correct": false
    },
    {
      "text": "La concession vaut acceptation du slogan",
      "correct": false
    }
  ],
  "explanation": "Concession réelle, pas un abandon : l'on n'achète pas un score comme on achète un bol"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "étiquette",
      "right": "texte sur le bol, à lire deux fois"
    },
    {
      "left": "score",
      "right": "avis chiffré, pas une loi"
    },
    {
      "left": "application",
      "right": "outil inventé Fil-des-Herbes"
    },
    {
      "left": "conseil",
      "right": "recommandation atténuée, distincte d'un ordre"
    }
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
  "word": "application",
  "hint": "outil inventé Fil-des-Herbes"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Léa Niyonzima écoute encore, et il fautons lire avant de crier.",
  "correct_sentence": "Léa Niyonzima écoute encore, et il faut lire avant de crier.",
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
      "image_path": "/elearning/mfk-c1-m2/slogan-doux.svg",
      "word": "slogan doux"
    },
    {
      "image_path": "/elearning/mfk-c1-m2/micro-gout.svg",
      "word": "micro gout"
    },
    {
      "image_path": "/elearning/mfk-c1-m2/affiche-gout.svg",
      "word": "affiche gout"
    },
    {
      "image_path": "/elearning/mfk-c1-m2/recueil-plaisirs.svg",
      "word": "recueil plaisirs"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Écrivez six phrases orales justes : deux sur conseil atténué ; on ferait mieux de ; il vaudrait mieux que, deux concessions, deux propositions."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez quatre modèles, puis votre prise de position (thèse, concession, proposition). Gardez la notice du Fil-des-Herbes et l'émission de Lila au Marché des Herbes distincts."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PE — le texte de Léa Niyonzima',
    'PE',
    $c$Objectif
Écrire un texte long et structuré. Conseiller des achats sans ordonner, et peser une application inventée. Point : conseil atténué ; on ferait mieux de ; il vaudrait mieux que.

Consigne
Imitez le texte de Léa Niyonzima.

Support — Léa Niyonzima — Le score n'est pas le goût
Léa Niyonzima — Le score n'est pas le goût
On parle trop vite de l'application inventée Fil-des-Herbes, comme si le mot dispensait d'en examiner le prix.
Encore que l'on remplace le goût par un score, une étiquette qui parle plus fort que Félicie n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Léa Niyonzima concède que un avis chiffré peut alerter sur le sel, pour autant que l'on n'achète pas un score comme on achète un bol.
Ce que l'on nomme étiquette, ici, n'est pas un slogan : texte sur le bol, à lire deux fois.
Léa ouvre Fil-des-Herbes et rit : le bol d'Oscar n'a pas de page.
Joël achète trop vite quand le score est vert ; Aline le ralentit.
Sami aime l'outil ; Yvette demande qui l'a payé.
Lila : présenter avantages et limites, ce n'est pas condamner l'outil, c'est refuser l'obéissance.
La proposition qui reste debout est celle-ci : échanger avantages et limites du Fil-des-Herbes, puis garder l'étiquette lue deux fois
Marc : il vaudrait mieux que tu lises le bol avant le slogan.
Nous clôturons sans fusionner les voix : la notice du Fil-des-Herbes d'un côté, l'émission de Lila au Marché des Herbes de l'autre, et le point où elles refusent de se ressembler.
Encore que l'on lises, une étiquette qui parle plus fort que Félicie n'est pas un détail.
Léa Niyonzima concède que un avis chiffré peut alerter sur le sel, pour autant que l'on n'achète pas un score comme on achète un bol.
Je n'écris pas pour vaincre : j'écris pour que la cour puisse relire.
l'outil peut être un avis ; il ne doit pas devenir une loi de marché
Léa Niyonzima, Rukiri-Nord
$c$,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "La proposition retenue est : échanger avantages et limites du Fil-des-Herbes, puis garder l'étiquette lue deux fois",
  "correct": true,
  "explanation": "échanger avantages et limites du Fil-des-Herbes, puis garder l'étiquette lue deux fois"
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
      "text": "échanger avantages et limites du Fil-des-Herbes, puis garder l'étiquette lue deux fois",
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
  "explanation": "échanger avantages et limites du Fil-des-Herbes, puis garder l'étiquette lue deux fois"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "étiquette",
      "right": "texte sur le bol, à lire deux fois"
    },
    {
      "left": "score",
      "right": "avis chiffré, pas une loi"
    },
    {
      "left": "application",
      "right": "outil inventé Fil-des-Herbes"
    },
    {
      "left": "conseil",
      "right": "recommandation atténuée, distincte d'un ordre"
    }
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
  "word": "conseil",
  "hint": "recommandation atténuée, distincte d'un ordre"
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
      "image_path": "/elearning/mfk-c1-m2/micro-gout.svg",
      "word": "micro gout"
    },
    {
      "image_path": "/elearning/mfk-c1-m2/affiche-gout.svg",
      "word": "affiche gout"
    },
    {
      "image_path": "/elearning/mfk-c1-m2/recueil-plaisirs.svg",
      "word": "recueil plaisirs"
    },
    {
      "image_path": "/elearning/mfk-c1-m2/feuille-goutee.svg",
      "word": "feuille goutee"
    }
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
    'EL — conseil atténué ; on ferait mieux de ; il vaudrait mieux que',
    'EL',
    $c$Objectif
Maîtriser conseil atténué ; on ferait mieux de ; il vaudrait mieux que au registre C1, avec collocations et pièges de construction.

Consigne
Apprenez la fiche, puis produisez des exemples justes au registre demandé.

Support — Fiche d'Aline Uwase, banc ocre
Fiche C1 — conseil atténué ; on ferait mieux de ; il vaudrait mieux que
On ne retient pas une liste : on retient des constructions et des collocations.
Encore que l'on lises, une étiquette qui parle plus fort que Félicie n'est pas un détail.
Léa Niyonzima concède que un avis chiffré peut alerter sur le sel, pour autant que l'on n'achète pas un score comme on achète un bol.
Autrement dit, l'outil peut être un avis ; il ne doit pas devenir une loi de marché
Il ressort qu'échanger avantages et limites du Fil-des-Herbes, puis garder l'étiquette lue deux fois
Piège : impératif brutal à la place du conditionnel de conseil
Registre : soutenu argumentatif, sans slogan
Collocation : encore que, pour autant que, il ressort que
Ce que l'on nomme étiquette, ici, n'est pas un slogan : texte sur le bol, à lire deux fois.
On ferait mieux de lire l'étiquette deux fois, dit Inès, non l'écran une fois.
Joël achète trop vite quand le score est vert ; Aline le ralentit.
Nominaliser, ce n'est pas alourdir : c'est nommer le processus (la densification, l'accueil, le rappel).
Encore que / pour autant que / si tant est que : subjonctif, concession réelle, pas un ornement.
Reformuler une source : on change la syntaxe, on garde la charge, on signale le point de vue.
C1 : l'implicite se justifie. C2 : l'ironie se laisse entendre sans s'afficher.
Exemple fautif à ne plus produire : On va au application pour de vrai genre, et Félicie Ndayishimiye demande un registre plus net.
Correction : On va au application vraiment, et Félicie Ndayishimiye demande un registre plus net.
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
      "left": "étiquette",
      "right": "texte sur le bol, à lire deux fois"
    },
    {
      "left": "score",
      "right": "avis chiffré, pas une loi"
    },
    {
      "left": "application",
      "right": "outil inventé Fil-des-Herbes"
    },
    {
      "left": "conseil",
      "right": "recommandation atténuée, distincte d'un ordre"
    }
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
  "sentence_with_error": "On va au application pour de vrai genre, et Félicie Ndayishimiye demande un registre plus net.",
  "correct_sentence": "On va au application vraiment, et Félicie Ndayishimiye demande un registre plus net.",
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
      "image_path": "/elearning/mfk-c1-m2/affiche-gout.svg",
      "word": "affiche gout"
    },
    {
      "image_path": "/elearning/mfk-c1-m2/recueil-plaisirs.svg",
      "word": "recueil plaisirs"
    },
    {
      "image_path": "/elearning/mfk-c1-m2/feuille-goutee.svg",
      "word": "feuille goutee"
    },
    {
      "image_path": "/elearning/mfk-c1-m2/banc-figuier.svg",
      "word": "banc figuier"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Tableau de langue : six exemples justes de « conseil atténué ; on ferait mieux de ; il vaudrait mieux que » et deux pièges commentés."
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

  -- ===== Débat marketing =====
  SELECT s.id INTO v_seq_id
  FROM elearning_sequences s
  WHERE s.module_id = v_module_id AND s.title = 'Débat marketing'
  LIMIT 1;

  IF v_seq_id IS NULL THEN
    INSERT INTO elearning_sequences (module_id, title, order_index)
    VALUES (v_module_id, 'Débat marketing', 4)
    RETURNING id INTO v_seq_id;
  ELSE
    UPDATE elearning_sequences
    SET order_index = 4
    WHERE id = v_seq_id;
  END IF;

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CO — Débat marketing',
    'CO',
    $c$Objectif
Comprendre un échange long et en extraire l'implicite. Débattre du marketing du Marché des Lampions sans slogan contre slogan. Viser la nuance, la collocation et l'implicite.

Consigne
Lisez le débat (à écouter avec l'enseignant). Qu'est-ce qui est dit, qu'est-ce qui reste implicite, qui concède quoi ?

Support — Débat Radio Figuier — Débat marketing
Lila Sow : Radio Figuier. On parle trop vite de le marketing du Marché des Lampions, comme si le mot dispensait d'en examiner le prix.
Marc Nkurunziza : Encore que l'on habille le sel d'un mot doux, une affiche qui cache le prix des mains n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Léa Niyonzima : Karim Bamba concède que une belle enseigne peut aider à trouver le stand, pour autant que l'on n'y lise pas une promesse de santé.
Aline Uwase : Ce que l'on nomme affiche, ici, n'est pas un slogan : enseigne argumentée ou menteuse selon les mots.
Patrick Habimana : Karim : certes l'enseigne guide, mais elle n'a pas à guérir.
Hawa Diallo : Inès refuse que le mot santé soit collé au sel brillant.
Joël Mugisha : Félicie n'a pas besoin d'un mot doux pour savoir si le bol nourrit.
Rose Iradukunda : Oscar n'apparaît pas sur l'affiche : c'est déjà un argument.
Solange Mukamana : Aline : encore que l'on discute le graphisme, le prix minuscule est une politique.
Karim Bamba : Léa propose un débat pour / contre, avec concession obligatoire.
Félicie Ndayishimiye : Un chiffre, une trace : Lila a relevé cinq mots doux sur l'affiche, zéro nom de jardinier, un prix en petits caractères.
Dieudonné Hakizimana : L'enjeu n'est pas d'avoir raison plus fort : il s'agit que la publicité inventée n'emprunte pas la voix de l'infirmerie
Yvette : Sami aime le brillant ; Yvette demande le coût.
Mado : Inès Mukama entend, dans « le brillant rend heureux », ceci qui n'est pas dit : le brillant rend heureux sert à ne plus demander qui a planté
Sami : Autrement dit, certes l'affiche attire, mais elle n'a pas le droit de se faire passer pour un soin
Lila Sow : Je reformule pour les auditeurs. La proposition qui reste debout est celle-ci : un débat : avantages d'une enseigne claire, inconvénients d'un bonheur collé au sel
Nina Kayitesi : Lila : Radio Figuier n'est pas une affiche, même quand elle parle des Lampions.
Lila Sow : Nous clôturons sans clore. Nous clôturons sans fusionner les voix : l'affiche du Marché des Lampions d'un côté, la chronique de Karim de l'autre, et le point où elles refusent de se ressembler.
$c$,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "une affiche qui cache le prix des mains est présenté comme un simple détail sans conséquence.",
  "correct": false,
  "explanation": "Le texte affirme au contraire que une affiche qui cache le prix des mains n'est pas un détail."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Selon Inès Mukama, que reste-t-il implicite dans « le brillant rend heureux » ?",
  "options": [
    {
      "text": "Que Karim a dessiné l'affiche",
      "correct": false
    },
    {
      "text": "Ne plus demander qui a planté",
      "correct": true
    },
    {
      "text": "Que Inès vend du brillant",
      "correct": false
    },
    {
      "text": "Que le figuier sera une enseigne",
      "correct": false
    }
  ],
  "explanation": "le brillant rend heureux sert à ne plus demander qui a planté"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "affiche",
      "right": "enseigne argumentée ou menteuse selon les mots"
    },
    {
      "left": "marketing",
      "right": "stratégie pour attirer, à discuter"
    },
    {
      "left": "promesse",
      "right": "engagement, trop souvent un éclat"
    },
    {
      "left": "publicité",
      "right": "discours d'attraction, distinct d'un soin"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nEncore que l'on ___ , une affiche qui cache le prix des mains n'est pas un détail. (discuter, subj.)",
  "answer": "discute"
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
    "discute",
    "la",
    "lumière",
    "affiche",
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
  "word": "affiche",
  "hint": "enseigne argumentée ou menteuse selon les mots"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Encore que l'on discuter trop vite, une affiche qui cache le prix des mains n'est pas un détail, et Karim Bamba écoute.",
  "correct_sentence": "Encore que l'on discute trop vite, une affiche qui cache le prix des mains n'est pas un détail, et Karim Bamba écoute.",
  "explanation": "Après encore que : discute."
}$j$::jsonb,
    6
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Image et mot',
    'image_match',
    $j${
  "pairs": [
    {
      "image_path": "/elearning/mfk-c1-m2/recueil-plaisirs.svg",
      "word": "recueil plaisirs"
    },
    {
      "image_path": "/elearning/mfk-c1-m2/feuille-goutee.svg",
      "word": "feuille goutee"
    },
    {
      "image_path": "/elearning/mfk-c1-m2/banc-figuier.svg",
      "word": "banc figuier"
    },
    {
      "image_path": "/elearning/mfk-c1-m2/the-saule.svg",
      "word": "the saule"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Reformulez l'implicite de « le brillant rend heureux » et la concession de Karim Bamba."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez une synthèse d'environ quatre-vingt-dix secondes : deux points de vue, un implicite, une proposition. Gardez l'affiche du Marché des Lampions et la chronique de Karim distincts."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CE — Le mot doux n''est pas un soin',
    'CE',
    $c$Objectif
Lire un texte argumenté long, synthétiser et reformuler. Débattre du marketing du Marché des Lampions sans slogan contre slogan. Viser la nuance, la collocation et l'implicite.

Consigne
Lisez « Le mot doux n'est pas un soin », sans aller trop vite. Repérez la thèse, la concession, l'implicite et la proposition.

Support — Le mot doux n'est pas un soin
On parle trop vite de le marketing du Marché des Lampions, comme si le mot dispensait d'en examiner le prix.
Encore que l'on habille le sel d'un mot doux, une affiche qui cache le prix des mains n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Karim Bamba concède que une belle enseigne peut aider à trouver le stand, pour autant que l'on n'y lise pas une promesse de santé.
Ce que l'on nomme affiche, ici, n'est pas un slogan : enseigne argumentée ou menteuse selon les mots.
Karim : certes l'enseigne guide, mais elle n'a pas à guérir.
Inès refuse que le mot santé soit collé au sel brillant.
Félicie n'a pas besoin d'un mot doux pour savoir si le bol nourrit.
Oscar n'apparaît pas sur l'affiche : c'est déjà un argument.
Aline : encore que l'on discute le graphisme, le prix minuscule est une politique.
Léa propose un débat pour / contre, avec concession obligatoire.
Un chiffre, une trace : Lila a relevé cinq mots doux sur l'affiche, zéro nom de jardinier, un prix en petits caractères.
L'enjeu n'est pas d'avoir raison plus fort : il s'agit que la publicité inventée n'emprunte pas la voix de l'infirmerie
Sami aime le brillant ; Yvette demande le coût.
Inès Mukama entend, dans « le brillant rend heureux », ceci qui n'est pas dit : le brillant rend heureux sert à ne plus demander qui a planté
Autrement dit, certes l'affiche attire, mais elle n'a pas le droit de se faire passer pour un soin
La proposition qui reste debout est celle-ci : un débat : avantages d'une enseigne claire, inconvénients d'un bonheur collé au sel
Lila : Radio Figuier n'est pas une affiche, même quand elle parle des Lampions.
Nous clôturons sans fusionner les voix : l'affiche du Marché des Lampions d'un côté, la chronique de Karim de l'autre, et le point où elles refusent de se ressembler.
Signé : Karim Bamba, Rukiri-Nord — Cahier des racines, Rukiri-Nord.
$c$,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Le texte refuse de fusionner l'affiche du Marché des Lampions et la chronique de Karim en une seule affiche.",
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
      "text": "Cinq mots doux, zéro jardinier, prix minuscule",
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
  "explanation": "Lila a relevé cinq mots doux sur l'affiche, zéro nom de jardinier, un prix en petits caractères."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "affiche",
      "right": "enseigne argumentée ou menteuse selon les mots"
    },
    {
      "left": "marketing",
      "right": "stratégie pour attirer, à discuter"
    },
    {
      "left": "promesse",
      "right": "engagement, trop souvent un éclat"
    },
    {
      "left": "publicité",
      "right": "discours d'attraction, distinct d'un soin"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nLa ___ n'est un abri que si l'on en parle vraiment. (affiche déjà nom ou verbe à nominaliser)",
  "answer": "affiche"
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
    "affiche",
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
  "word": "marketing",
  "hint": "stratégie pour attirer, à discuter"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "La affiche de trop vite n'aide personne, et Inès Mukama reprend le fil.",
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
      "image_path": "/elearning/mfk-c1-m2/feuille-goutee.svg",
      "word": "feuille goutee"
    },
    {
      "image_path": "/elearning/mfk-c1-m2/banc-figuier.svg",
      "word": "banc figuier"
    },
    {
      "image_path": "/elearning/mfk-c1-m2/the-saule.svg",
      "word": "the saule"
    },
    {
      "image_path": "/elearning/mfk-c1-m2/statistique-cour.svg",
      "word": "statistique cour"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Synthétisez « Le mot doux n'est pas un soin » : thèse, concession, implicite, proposition (quinze lignes)."
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
    'PO — Débat marketing : dire sans slogan',
    'PO',
    $c$Objectif
Produire un oral structuré (thèse, concession, proposition). Point : certes… mais ; encore que ; avantages et inconvénients.

Consigne
Répétez les modèles, puis prenez position en une minute : thèse, concession, reformulation, proposition.

Support — Modèles d'Aline Uwase, banc du figuier
Encore que l'on habille le sel d'un mot doux, une affiche qui cache le prix des mains n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Karim Bamba concède que une belle enseigne peut aider à trouver le stand, pour autant que l'on n'y lise pas une promesse de santé.
Ce que l'on nomme affiche, ici, n'est pas un slogan : enseigne argumentée ou menteuse selon les mots.
Encore que l'on discute, une affiche qui cache le prix des mains n'est pas un détail.
Karim Bamba concède que une belle enseigne peut aider à trouver le stand, pour autant que l'on n'y lise pas une promesse de santé.
Autrement dit, certes l'affiche attire, mais elle n'a pas le droit de se faire passer pour un soin
Il ressort qu'un débat : avantages d'une enseigne claire, inconvénients d'un bonheur collé au sel
Inès refuse que le mot santé soit collé au sel brillant.
Aline : encore que l'on discute le graphisme, le prix minuscule est une politique.
La proposition qui reste debout est celle-ci : un débat : avantages d'une enseigne claire, inconvénients d'un bonheur collé au sel
Je concède le point, je n'abandonne pas la proposition.
Ce n'est pas que je refuse : c'est que je refuse qu'on nomme cela un détail.
Autrement dit, l'implicite fait autant de travail que la thèse.
En une minute : fait, angle, concession, proposition.
Nous clôturons sans fusionner les voix : l'affiche du Marché des Lampions d'un côté, la chronique de Karim de l'autre, et le point où elles refusent de se ressembler.
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
  "explanation": "Karim Bamba concède que une belle enseigne peut aider à trouver le stand, pour autant que l'on n'y lise pas une promesse de santé."
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
      "text": "une belle enseigne peut aider à trouver le stand — à condition que l'on n'y lise pas une promesse de santé",
      "correct": true
    },
    {
      "text": "Karim Bamba abandonne il s'agit que la publicité inventée n'emprunte pas la voix de l'infirmerie",
      "correct": false
    },
    {
      "text": "La concession vaut acceptation du slogan",
      "correct": false
    }
  ],
  "explanation": "Concession réelle, pas un abandon : l'on n'y lise pas une promesse de santé"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "affiche",
      "right": "enseigne argumentée ou menteuse selon les mots"
    },
    {
      "left": "marketing",
      "right": "stratégie pour attirer, à discuter"
    },
    {
      "left": "promesse",
      "right": "engagement, trop souvent un éclat"
    },
    {
      "left": "publicité",
      "right": "discours d'attraction, distinct d'un soin"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nPour autant que l'on ___ , Karim concède un point. (discuter, subj.)",
  "answer": "discute"
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
    "publicité",
    "."
  ]
}$j$::jsonb,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre',
    'anagram',
    $j${
  "word": "promesse",
  "hint": "engagement, trop souvent un éclat"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Karim Bamba écoute encore, et il fautons discuter avant de crier.",
  "correct_sentence": "Karim Bamba écoute encore, et il faut discuter avant de crier.",
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
      "image_path": "/elearning/mfk-c1-m2/banc-figuier.svg",
      "word": "banc figuier"
    },
    {
      "image_path": "/elearning/mfk-c1-m2/the-saule.svg",
      "word": "the saule"
    },
    {
      "image_path": "/elearning/mfk-c1-m2/statistique-cour.svg",
      "word": "statistique cour"
    },
    {
      "image_path": "/elearning/mfk-c1-m2/nuage-faim.svg",
      "word": "nuage faim"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Écrivez six phrases orales justes : deux sur certes… mais ; encore que ; avantages et inconvénients, deux concessions, deux propositions."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez quatre modèles, puis votre prise de position (thèse, concession, proposition). Gardez l'affiche du Marché des Lampions et la chronique de Karim distincts."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PE — le texte de Karim Bamba',
    'PE',
    $c$Objectif
Écrire un texte long et structuré. Débattre du marketing du Marché des Lampions sans slogan contre slogan. Point : certes… mais ; encore que ; avantages et inconvénients.

Consigne
Imitez le texte de Karim Bamba.

Support — Karim Bamba — Le mot doux n'est pas un soin
Karim Bamba — Le mot doux n'est pas un soin
On parle trop vite de le marketing du Marché des Lampions, comme si le mot dispensait d'en examiner le prix.
Encore que l'on habille le sel d'un mot doux, une affiche qui cache le prix des mains n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Karim Bamba concède que une belle enseigne peut aider à trouver le stand, pour autant que l'on n'y lise pas une promesse de santé.
Ce que l'on nomme affiche, ici, n'est pas un slogan : enseigne argumentée ou menteuse selon les mots.
Karim : certes l'enseigne guide, mais elle n'a pas à guérir.
Aline : encore que l'on discute le graphisme, le prix minuscule est une politique.
Léa propose un débat pour / contre, avec concession obligatoire.
Sami aime le brillant ; Yvette demande le coût.
La proposition qui reste debout est celle-ci : un débat : avantages d'une enseigne claire, inconvénients d'un bonheur collé au sel
Lila : Radio Figuier n'est pas une affiche, même quand elle parle des Lampions.
Nous clôturons sans fusionner les voix : l'affiche du Marché des Lampions d'un côté, la chronique de Karim de l'autre, et le point où elles refusent de se ressembler.
Encore que l'on discute, une affiche qui cache le prix des mains n'est pas un détail.
Karim Bamba concède que une belle enseigne peut aider à trouver le stand, pour autant que l'on n'y lise pas une promesse de santé.
Je n'écris pas pour vaincre : j'écris pour que la cour puisse relire.
certes l'affiche attire, mais elle n'a pas le droit de se faire passer pour un soin
Karim Bamba, Rukiri-Nord
$c$,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "La proposition retenue est : un débat : avantages d'une enseigne claire, inconvénients d'un bonheur collé au sel",
  "correct": true,
  "explanation": "un débat : avantages d'une enseigne claire, inconvénients d'un bonheur collé au sel"
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
      "text": "un débat : avantages d'une enseigne claire, inconvénients d'un bonheur collé au sel",
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
  "explanation": "un débat : avantages d'une enseigne claire, inconvénients d'un bonheur collé au sel"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "affiche",
      "right": "enseigne argumentée ou menteuse selon les mots"
    },
    {
      "left": "marketing",
      "right": "stratégie pour attirer, à discuter"
    },
    {
      "left": "promesse",
      "right": "engagement, trop souvent un éclat"
    },
    {
      "left": "publicité",
      "right": "discours d'attraction, distinct d'un soin"
    }
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
  "word": "publicité",
  "hint": "discours d'attraction, distinct d'un soin"
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
      "image_path": "/elearning/mfk-c1-m2/the-saule.svg",
      "word": "the saule"
    },
    {
      "image_path": "/elearning/mfk-c1-m2/statistique-cour.svg",
      "word": "statistique cour"
    },
    {
      "image_path": "/elearning/mfk-c1-m2/nuage-faim.svg",
      "word": "nuage faim"
    },
    {
      "image_path": "/elearning/mfk-c1-m2/soleil-marche.svg",
      "word": "soleil marche"
    }
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
    'EL — certes… mais ; encore que ; avantages et inconvénients',
    'EL',
    $c$Objectif
Maîtriser certes… mais ; encore que ; avantages et inconvénients au registre C1, avec collocations et pièges de construction.

Consigne
Apprenez la fiche, puis produisez des exemples justes au registre demandé.

Support — Fiche d'Aline Uwase, banc ocre
Fiche C1 — certes… mais ; encore que ; avantages et inconvénients
On ne retient pas une liste : on retient des constructions et des collocations.
Encore que l'on discute, une affiche qui cache le prix des mains n'est pas un détail.
Karim Bamba concède que une belle enseigne peut aider à trouver le stand, pour autant que l'on n'y lise pas une promesse de santé.
Autrement dit, certes l'affiche attire, mais elle n'a pas le droit de se faire passer pour un soin
Il ressort qu'un débat : avantages d'une enseigne claire, inconvénients d'un bonheur collé au sel
Piège : indicatif après encore que
Registre : soutenu argumentatif, sans slogan
Collocation : encore que, pour autant que, il ressort que
Ce que l'on nomme affiche, ici, n'est pas un slogan : enseigne argumentée ou menteuse selon les mots.
Inès refuse que le mot santé soit collé au sel brillant.
Aline : encore que l'on discute le graphisme, le prix minuscule est une politique.
Nominaliser, ce n'est pas alourdir : c'est nommer le processus (la densification, l'accueil, le rappel).
Encore que / pour autant que / si tant est que : subjonctif, concession réelle, pas un ornement.
Reformuler une source : on change la syntaxe, on garde la charge, on signale le point de vue.
C1 : l'implicite se justifie. C2 : l'ironie se laisse entendre sans s'afficher.
Exemple fautif à ne plus produire : On va au promesse pour de vrai genre, et Inès Mukama demande un registre plus net.
Correction : On va au promesse vraiment, et Inès Mukama demande un registre plus net.
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
      "left": "affiche",
      "right": "enseigne argumentée ou menteuse selon les mots"
    },
    {
      "left": "marketing",
      "right": "stratégie pour attirer, à discuter"
    },
    {
      "left": "promesse",
      "right": "engagement, trop souvent un éclat"
    },
    {
      "left": "publicité",
      "right": "discours d'attraction, distinct d'un soin"
    }
  ]
}$j$::jsonb,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez',
    'fill_blank',
    $j${
  "prompt": "Complétez :\nOn dira la ___ plutôt qu'un slogan. (nom de marketing)",
  "answer": "promesse"
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
    "discute",
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
  "sentence_with_error": "On va au promesse pour de vrai genre, et Inès Mukama demande un registre plus net.",
  "correct_sentence": "On va au promesse vraiment, et Inès Mukama demande un registre plus net.",
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
      "image_path": "/elearning/mfk-c1-m2/statistique-cour.svg",
      "word": "statistique cour"
    },
    {
      "image_path": "/elearning/mfk-c1-m2/nuage-faim.svg",
      "word": "nuage faim"
    },
    {
      "image_path": "/elearning/mfk-c1-m2/soleil-marche.svg",
      "word": "soleil marche"
    },
    {
      "image_path": "/elearning/mfk-c1-m2/main-terre.svg",
      "word": "main terre"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Tableau de langue : six exemples justes de « certes… mais ; encore que ; avantages et inconvénients » et deux pièges commentés."
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

  -- ===== Huit notices sous le figuier =====
  SELECT s.id INTO v_seq_id
  FROM elearning_sequences s
  WHERE s.module_id = v_module_id AND s.title = 'Huit notices sous le figuier'
  LIMIT 1;

  IF v_seq_id IS NULL THEN
    INSERT INTO elearning_sequences (module_id, title, order_index)
    VALUES (v_module_id, 'Huit notices sous le figuier', 5)
    RETURNING id INTO v_seq_id;
  ELSE
    UPDATE elearning_sequences
    SET order_index = 5
    WHERE id = v_seq_id;
  END IF;

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CO — Huit notices sous le figuier',
    'CO',
    $c$Objectif
Comprendre un échange long et en extraire l'implicite. Composer un recueil de plaisirs minuscules ancré dans le Seuil, sans morale lourde. Viser la nuance, la collocation et l'implicite.

Consigne
Lisez le débat (à écouter avec l'enseignant). Qu'est-ce qui est dit, qu'est-ce qui reste implicite, qui concède quoi ?

Support — Débat Radio Figuier — Huit notices sous le figuier
Lila Sow : Radio Figuier. On parle trop vite de les plaisirs minuscules du figuier, comme si le mot dispensait d'en examiner le prix.
Marc Nkurunziza : Encore que l'on transforme le plaisir en consigne, une joie ordonnée comme un score n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Léa Niyonzima : Mado concède que écrire le plaisir peut le rendre partageable, pour autant que l'on n'en fasse pas une leçon de bien manger.
Aline Uwase : Ce que l'on nomme plaisir, ici, n'est pas un slogan : expérience minuscule, non une consigne.
Patrick Habimana : Mado : on dirait que l'ombre du figuier aurait un goût de thé trop infusé, et ce serait assez.
Hawa Diallo : Félicie ajoute une notice : le bol chaud quand personne n'interroge.
Joël Mugisha : Aline refuse l'impératif jouissez.
Rose Iradukunda : Patrick sourit d'une feuille croquée sans discours.
Solange Mukamana : Rose coud un signet trop simple, exprès.
Karim Bamba : Sami veut une notice drôle ; Yvette en veut une lente.
Félicie Ndayishimiye : Un chiffre, une trace : Mado a écrit huit notices ; Lila n'en lira que cinq, les trois trop morales restent dans le tiroir.
Dieudonné Hakizimana : L'enjeu n'est pas d'avoir raison plus fort : il s'agit de goûter sans se faire discipliner par un slogan de table
Yvette : Oscar glisse une terre sous l'ongle : cela aussi est un plaisir, dit-il, sans le vendre.
Mado : Félicie Ndayishimiye entend, dans « il faut jouir », ceci qui n'est pas dit : il faut jouir ressemble trop à une affiche pour n'être pas un ordre déguisé
Sami : Autrement dit, le minuscule ici, c'est ce qui n'a pas besoin d'affiche : l'ombre, le bol, la feuille
Lila Sow : Je reformule pour les auditeurs. La proposition qui reste debout est celle-ci : huit notices de plaisir, au conditionnel parfois, sans injonction
Nina Kayitesi : Lila lira sans musique : le minuscule n'a pas besoin d'orchestre.
Lila Sow : Nous clôturons sans clore. Nous clôturons sans fusionner les voix : le recueil de Mado d'un côté, les notes de Félicie au bas des pages de l'autre, et le point où elles refusent de se ressembler.
$c$,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "une joie ordonnée comme un score est présenté comme un simple détail sans conséquence.",
  "correct": false,
  "explanation": "Le texte affirme au contraire que une joie ordonnée comme un score n'est pas un détail."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne réponse',
    'qcm',
    $j${
  "question": "Selon Félicie Ndayishimiye, que reste-t-il implicite dans « il faut jouir » ?",
  "options": [
    {
      "text": "Que Mado a copié l'affiche des Lampions",
      "correct": false
    },
    {
      "text": "Un ordre déguisé en joie",
      "correct": true
    },
    {
      "text": "Que Félicie refuse tout plaisir",
      "correct": false
    },
    {
      "text": "Que Lila n'accepte que les leçons",
      "correct": false
    }
  ],
  "explanation": "il faut jouir ressemble trop à une affiche pour n'être pas un ordre déguisé"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "plaisir",
      "right": "expérience minuscule, non une consigne"
    },
    {
      "left": "notice",
      "right": "court texte de recueil"
    },
    {
      "left": "ombre",
      "right": "abri de midi, plaisir sans score"
    },
    {
      "left": "feuille",
      "right": "goût de la rive, plus discret que l'affiche"
    }
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
  "word": "plaisir",
  "hint": "expérience minuscule, non une consigne"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "On dirait que la rivière prend une voix demain soir, et Mado écrit encore.",
  "correct_sentence": "On dirait que la rivière prendrait une voix demain soir, et Mado écrit encore.",
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
      "image_path": "/elearning/mfk-c1-m2/nuage-faim.svg",
      "word": "nuage faim"
    },
    {
      "image_path": "/elearning/mfk-c1-m2/soleil-marche.svg",
      "word": "soleil marche"
    },
    {
      "image_path": "/elearning/mfk-c1-m2/main-terre.svg",
      "word": "main terre"
    },
    {
      "image_path": "/elearning/mfk-c1-m2/radio-ration.svg",
      "word": "radio ration"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Reformulez l'implicite de « il faut jouir » et la concession de Mado."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez une synthèse d'environ quatre-vingt-dix secondes : deux points de vue, un implicite, une proposition. Gardez le recueil de Mado et les notes de Félicie au bas des pages distincts."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CE — Huit notices, pas une leçon',
    'CE',
    $c$Objectif
Lire un texte argumenté long, synthétiser et reformuler. Composer un recueil de plaisirs minuscules ancré dans le Seuil, sans morale lourde. Viser la nuance, la collocation et l'implicite.

Consigne
Lisez « Huit notices, pas une leçon », sans aller trop vite. Repérez la thèse, la concession, l'implicite et la proposition.

Support — Huit notices, pas une leçon
On parle trop vite de les plaisirs minuscules du figuier, comme si le mot dispensait d'en examiner le prix.
Encore que l'on transforme le plaisir en consigne, une joie ordonnée comme un score n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Mado concède que écrire le plaisir peut le rendre partageable, pour autant que l'on n'en fasse pas une leçon de bien manger.
Ce que l'on nomme plaisir, ici, n'est pas un slogan : expérience minuscule, non une consigne.
Mado : on dirait que l'ombre du figuier aurait un goût de thé trop infusé, et ce serait assez.
Félicie ajoute une notice : le bol chaud quand personne n'interroge.
Aline refuse l'impératif jouissez.
Patrick sourit d'une feuille croquée sans discours.
Rose coud un signet trop simple, exprès.
Sami veut une notice drôle ; Yvette en veut une lente.
Un chiffre, une trace : Mado a écrit huit notices ; Lila n'en lira que cinq, les trois trop morales restent dans le tiroir.
L'enjeu n'est pas d'avoir raison plus fort : il s'agit de goûter sans se faire discipliner par un slogan de table
Oscar glisse une terre sous l'ongle : cela aussi est un plaisir, dit-il, sans le vendre.
Félicie Ndayishimiye entend, dans « il faut jouir », ceci qui n'est pas dit : il faut jouir ressemble trop à une affiche pour n'être pas un ordre déguisé
Autrement dit, le minuscule ici, c'est ce qui n'a pas besoin d'affiche : l'ombre, le bol, la feuille
La proposition qui reste debout est celle-ci : huit notices de plaisir, au conditionnel parfois, sans injonction
Lila lira sans musique : le minuscule n'a pas besoin d'orchestre.
Nous clôturons sans fusionner les voix : le recueil de Mado d'un côté, les notes de Félicie au bas des pages de l'autre, et le point où elles refusent de se ressembler.
Signé : Mado, Rukiri-Nord — Cahier des racines, Rukiri-Nord.
$c$,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "Le texte refuse de fusionner le recueil de Mado et les notes de Félicie au bas des pages en une seule affiche.",
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
      "text": "Huit notices, cinq lues, trois trop morales",
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
  "explanation": "Mado a écrit huit notices ; Lila n'en lira que cinq, les trois trop morales restent dans le tiroir."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "plaisir",
      "right": "expérience minuscule, non une consigne"
    },
    {
      "left": "notice",
      "right": "court texte de recueil"
    },
    {
      "left": "ombre",
      "right": "abri de midi, plaisir sans score"
    },
    {
      "left": "feuille",
      "right": "goût de la rive, plus discret que l'affiche"
    }
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
  "word": "notice",
  "hint": "court texte de recueil"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "La plaisir de trop vite n'aide personne, et Félicie Ndayishimiye reprend le fil.",
  "correct_sentence": "La précipitation n'aide personne, et Félicie Ndayishimiye reprend le fil.",
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
      "image_path": "/elearning/mfk-c1-m2/soleil-marche.svg",
      "word": "soleil marche"
    },
    {
      "image_path": "/elearning/mfk-c1-m2/main-terre.svg",
      "word": "main terre"
    },
    {
      "image_path": "/elearning/mfk-c1-m2/radio-ration.svg",
      "word": "radio ration"
    },
    {
      "image_path": "/elearning/mfk-c1-m2/coeur-table.svg",
      "word": "coeur table"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Synthétisez « Huit notices, pas une leçon » : thèse, concession, implicite, proposition (quinze lignes)."
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
    'PO — Huit notices sous le figuier : dire sans slogan',
    'PO',
    $c$Objectif
Produire un oral structuré (thèse, concession, proposition). Point : écriture créative encadrée ; nominalisation des sensations.

Consigne
Répétez les modèles, puis prenez position en une minute : thèse, concession, reformulation, proposition.

Support — Modèles d'Aline Uwase, banc du figuier
Encore que l'on transforme le plaisir en consigne, une joie ordonnée comme un score n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Mado concède que écrire le plaisir peut le rendre partageable, pour autant que l'on n'en fasse pas une leçon de bien manger.
Ce que l'on nomme plaisir, ici, n'est pas un slogan : expérience minuscule, non une consigne.
Encore que l'on écrive, une joie ordonnée comme un score n'est pas un détail.
Mado concède que écrire le plaisir peut le rendre partageable, pour autant que l'on n'en fasse pas une leçon de bien manger.
Autrement dit, le minuscule ici, c'est ce qui n'a pas besoin d'affiche : l'ombre, le bol, la feuille
Il ressort qu'huit notices de plaisir, au conditionnel parfois, sans injonction
Félicie ajoute une notice : le bol chaud quand personne n'interroge.
Rose coud un signet trop simple, exprès.
La proposition qui reste debout est celle-ci : huit notices de plaisir, au conditionnel parfois, sans injonction
Je concède le point, je n'abandonne pas la proposition.
Ce n'est pas que je refuse : c'est que je refuse qu'on nomme cela un détail.
Autrement dit, l'implicite fait autant de travail que la thèse.
En une minute : fait, angle, concession, proposition.
Nous clôturons sans fusionner les voix : le recueil de Mado d'un côté, les notes de Félicie au bas des pages de l'autre, et le point où elles refusent de se ressembler.
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
  "explanation": "Mado concède que écrire le plaisir peut le rendre partageable, pour autant que l'on n'en fasse pas une leçon de bien manger."
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
      "text": "écrire le plaisir peut le rendre partageable — à condition que l'on n'en fasse pas une leçon de bien manger",
      "correct": true
    },
    {
      "text": "Mado abandonne il s'agit de goûter sans se faire discipliner par un slogan de table",
      "correct": false
    },
    {
      "text": "La concession vaut acceptation du slogan",
      "correct": false
    }
  ],
  "explanation": "Concession réelle, pas un abandon : l'on n'en fasse pas une leçon de bien manger"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "plaisir",
      "right": "expérience minuscule, non une consigne"
    },
    {
      "left": "notice",
      "right": "court texte de recueil"
    },
    {
      "left": "ombre",
      "right": "abri de midi, plaisir sans score"
    },
    {
      "left": "feuille",
      "right": "goût de la rive, plus discret que l'affiche"
    }
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
  "hint": "abri de midi, plaisir sans score"
}$j$::jsonb,
    5
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Mado écoute encore, et il fautons écrire avant de crier.",
  "correct_sentence": "Mado écoute encore, et il faut écrire avant de crier.",
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
      "image_path": "/elearning/mfk-c1-m2/main-terre.svg",
      "word": "main terre"
    },
    {
      "image_path": "/elearning/mfk-c1-m2/radio-ration.svg",
      "word": "radio ration"
    },
    {
      "image_path": "/elearning/mfk-c1-m2/coeur-table.svg",
      "word": "coeur table"
    },
    {
      "image_path": "/elearning/mfk-c1-m2/faim-emotion.svg",
      "word": "faim emotion"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Écrivez six phrases orales justes : deux sur écriture créative encadrée ; nominalisation des sensations, deux concessions, deux propositions."
}$j$::jsonb,
    8
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez',
    'audio_record',
    $j${
  "instructions": "Enregistrez quatre modèles, puis votre prise de position (thèse, concession, proposition). Gardez le recueil de Mado et les notes de Félicie au bas des pages distincts."
}$j$::jsonb,
    9
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PE — le texte de Mado',
    'PE',
    $c$Objectif
Écrire un texte long et structuré. Composer un recueil de plaisirs minuscules ancré dans le Seuil, sans morale lourde. Point : écriture créative encadrée ; nominalisation des sensations.

Consigne
Imitez le texte de Mado.

Support — Mado — Huit notices, pas une leçon
Mado — Huit notices, pas une leçon
On parle trop vite de les plaisirs minuscules du figuier, comme si le mot dispensait d'en examiner le prix.
Encore que l'on transforme le plaisir en consigne, une joie ordonnée comme un score n'est pas un détail que l'on puisse ranger dans une note de bas de page.
Mado concède que écrire le plaisir peut le rendre partageable, pour autant que l'on n'en fasse pas une leçon de bien manger.
Ce que l'on nomme plaisir, ici, n'est pas un slogan : expérience minuscule, non une consigne.
Mado : on dirait que l'ombre du figuier aurait un goût de thé trop infusé, et ce serait assez.
Rose coud un signet trop simple, exprès.
Sami veut une notice drôle ; Yvette en veut une lente.
Oscar glisse une terre sous l'ongle : cela aussi est un plaisir, dit-il, sans le vendre.
La proposition qui reste debout est celle-ci : huit notices de plaisir, au conditionnel parfois, sans injonction
Lila lira sans musique : le minuscule n'a pas besoin d'orchestre.
Nous clôturons sans fusionner les voix : le recueil de Mado d'un côté, les notes de Félicie au bas des pages de l'autre, et le point où elles refusent de se ressembler.
Encore que l'on écrive, une joie ordonnée comme un score n'est pas un détail.
Mado concède que écrire le plaisir peut le rendre partageable, pour autant que l'on n'en fasse pas une leçon de bien manger.
Je n'écris pas pour vaincre : j'écris pour que la cour puisse relire.
le minuscule ici, c'est ce qui n'a pas besoin d'affiche : l'ombre, le bol, la feuille
Mado, Rukiri-Nord
$c$,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux',
    'true_false',
    $j${
  "statement": "La proposition retenue est : huit notices de plaisir, au conditionnel parfois, sans injonction",
  "correct": true,
  "explanation": "huit notices de plaisir, au conditionnel parfois, sans injonction"
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
      "text": "huit notices de plaisir, au conditionnel parfois, sans injonction",
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
  "explanation": "huit notices de plaisir, au conditionnel parfois, sans injonction"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez',
    'matching',
    $j${
  "pairs": [
    {
      "left": "plaisir",
      "right": "expérience minuscule, non une consigne"
    },
    {
      "left": "notice",
      "right": "court texte de recueil"
    },
    {
      "left": "ombre",
      "right": "abri de midi, plaisir sans score"
    },
    {
      "left": "feuille",
      "right": "goût de la rive, plus discret que l'affiche"
    }
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
  "word": "feuille",
  "hint": "goût de la rive, plus discret que l'affiche"
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
      "image_path": "/elearning/mfk-c1-m2/radio-ration.svg",
      "word": "radio ration"
    },
    {
      "image_path": "/elearning/mfk-c1-m2/coeur-table.svg",
      "word": "coeur table"
    },
    {
      "image_path": "/elearning/mfk-c1-m2/faim-emotion.svg",
      "word": "faim emotion"
    },
    {
      "image_path": "/elearning/mfk-c1-m2/bol-felicie.svg",
      "word": "bol felicie"
    }
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
    'EL — écriture créative encadrée ; nominalisation des sensations',
    'EL',
    $c$Objectif
Maîtriser écriture créative encadrée ; nominalisation des sensations au registre C1, avec collocations et pièges de construction.

Consigne
Apprenez la fiche, puis produisez des exemples justes au registre demandé.

Support — Fiche d'Aline Uwase, banc ocre
Fiche C1 — écriture créative encadrée ; nominalisation des sensations
On ne retient pas une liste : on retient des constructions et des collocations.
Encore que l'on écrive, une joie ordonnée comme un score n'est pas un détail.
Mado concède que écrire le plaisir peut le rendre partageable, pour autant que l'on n'en fasse pas une leçon de bien manger.
Autrement dit, le minuscule ici, c'est ce qui n'a pas besoin d'affiche : l'ombre, le bol, la feuille
Il ressort qu'huit notices de plaisir, au conditionnel parfois, sans injonction
Piège : indicatif plat là où le conditionnel peint
Registre : soutenu argumentatif, sans slogan
Collocation : encore que, pour autant que, il ressort que
Ce que l'on nomme plaisir, ici, n'est pas un slogan : expérience minuscule, non une consigne.
Félicie ajoute une notice : le bol chaud quand personne n'interroge.
Rose coud un signet trop simple, exprès.
Nominaliser, ce n'est pas alourdir : c'est nommer le processus (la densification, l'accueil, le rappel).
Encore que / pour autant que / si tant est que : subjonctif, concession réelle, pas un ornement.
Reformuler une source : on change la syntaxe, on garde la charge, on signale le point de vue.
C1 : l'implicite se justifie. C2 : l'ironie se laisse entendre sans s'afficher.
Exemple fautif à ne plus produire : On va au ombre pour de vrai genre, et Félicie Ndayishimiye demande un registre plus net.
Correction : On va au ombre vraiment, et Félicie Ndayishimiye demande un registre plus net.
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
      "left": "plaisir",
      "right": "expérience minuscule, non une consigne"
    },
    {
      "left": "notice",
      "right": "court texte de recueil"
    },
    {
      "left": "ombre",
      "right": "abri de midi, plaisir sans score"
    },
    {
      "left": "feuille",
      "right": "goût de la rive, plus discret que l'affiche"
    }
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
  "answer": "plaisir"
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
  "sentence_with_error": "On va au ombre pour de vrai genre, et Félicie Ndayishimiye demande un registre plus net.",
  "correct_sentence": "On va au ombre vraiment, et Félicie Ndayishimiye demande un registre plus net.",
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
      "image_path": "/elearning/mfk-c1-m2/coeur-table.svg",
      "word": "coeur table"
    },
    {
      "image_path": "/elearning/mfk-c1-m2/faim-emotion.svg",
      "word": "faim emotion"
    },
    {
      "image_path": "/elearning/mfk-c1-m2/bol-felicie.svg",
      "word": "bol felicie"
    },
    {
      "image_path": "/elearning/mfk-c1-m2/carte-mentale.svg",
      "word": "carte mentale"
    }
  ]
}$j$::jsonb,
    7
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Réponse libre',
    'short_answer',
    $j${
  "prompt": "Tableau de langue : six exemples justes de « écriture créative encadrée ; nominalisation des sensations » et deux pièges commentés."
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
