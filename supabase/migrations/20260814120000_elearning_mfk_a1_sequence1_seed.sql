/*
  # Seed eLearning MFK — Module A1, séquence 1 « Premiers repères »

  Schéma réel (public, pas de schéma SQL « elearning ») :

  elearning_modules
    id            uuid PK default gen_random_uuid()
    teacher_id    uuid NOT NULL → teachers(id)
    title         text NOT NULL
    description   text
    cefr_level    text CHECK (A1|A2|B1|B2|C1|C2)
    published     boolean NOT NULL default false
    created_at    timestamptz
    updated_at    timestamptz

  elearning_sequences
    id            uuid PK
    module_id     uuid NOT NULL → elearning_modules(id)
    title         text NOT NULL default ''
    order_index   integer NOT NULL default 0
    created_at    timestamptz

  elearning_lessons
    id            uuid PK
    sequence_id   uuid NOT NULL → elearning_sequences(id)
    title         text NOT NULL default ''
    competency    text CHECK (PE|PO|CE|CO|EE|EO|EL)
    content_type  text NOT NULL default 'text'
                  CHECK (youtube|image|text|audio|pdf)
    content       text   -- texte, URL YouTube, ou chemin storage
    order_index   integer NOT NULL default 0
    created_at    timestamptz

  elearning_exercises
    id             uuid PK
    lesson_id      uuid NOT NULL → elearning_lessons(id)
    title          text NOT NULL default ''
    exercise_type  text NOT NULL CHECK (
                     qcm | matching | fill_blank | short_answer |
                     word_order | anagram | true_false |
                     image_match | find_error | audio_record
                   )
    content        jsonb NOT NULL default '{}'
    order_index    integer NOT NULL default 0
    created_at     timestamptz

  JSON `content` par type (aligné sur lib/elearning-exercises.ts) :
    qcm           { question, options: [{text, correct}], explanation }
    matching      { pairs: [{left, right}] }
    fill_blank    { prompt, answer }
    short_answer  { prompt }
    word_order    { words: string[] }
    anagram       { word, hint }
    true_false    { statement, correct, explanation }
    image_match   { pairs: [{image_path, word}] }  -- non utilisé ici (pas d'images)
    find_error    { sentence_with_error, correct_sentence, explanation }
    audio_record  { instructions }

  Ce fichier ne crée aucune table. Idempotent.
  Séquence 1 seulement — les séquences 2 à 9 attendent validation.
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
    AND order_index IN (0, 1, 2);

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
  v_module_title text := 'A1 — Parcours MFK';
  v_seq_title text := 'Séquence 1 — Premiers repères';
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
      'Seed A1 impossible : aucun enseignant (teachers) trouvé. Créez un compte teacher puis relancez la migration.';
  END IF;

  RAISE NOTICE 'Seed A1 : enseignant % (%)', v_teacher_email, v_teacher_id;

  SELECT m.id INTO v_module_id
  FROM elearning_modules m
  WHERE m.teacher_id = v_teacher_id
    AND (
      m.title = v_module_title
      OR m.title = 'A1'
      OR (m.cefr_level = 'A1' AND m.title ILIKE 'A1%Parcours%')
    )
  ORDER BY
    CASE
      WHEN m.title = v_module_title THEN 0
      WHEN m.title = 'A1' THEN 1
      ELSE 2
    END,
    m.created_at ASC NULLS LAST
  LIMIT 1;

  IF v_module_id IS NULL THEN
    INSERT INTO elearning_modules (
      teacher_id,
      title,
      description,
      cefr_level,
      published
    )
    VALUES (
      v_teacher_id,
      v_module_title,
      'Parcours eLearning A1 (MFK) : neuf séquences thématiques, chacune avec cinq leçons (CO, CE, PO, PE, EL).',
      'A1',
      false
    )
    RETURNING id INTO v_module_id;
  ELSE
    UPDATE elearning_modules
    SET
      title = v_module_title,
      description = 'Parcours eLearning A1 (MFK) : neuf séquences thématiques, chacune avec cinq leçons (CO, CE, PO, PE, EL).',
      cefr_level = 'A1',
      updated_at = now()
    WHERE id = v_module_id;
  END IF;

  SELECT s.id INTO v_seq_id
  FROM elearning_sequences s
  WHERE s.module_id = v_module_id
    AND s.title = v_seq_title
  LIMIT 1;

  IF v_seq_id IS NULL THEN
    INSERT INTO elearning_sequences (module_id, title, order_index)
    VALUES (v_module_id, v_seq_title, 0)
    RETURNING id INTO v_seq_id;
  ELSE
    UPDATE elearning_sequences
    SET title = v_seq_title, order_index = 0
    WHERE id = v_seq_id;
  END IF;

  -- ------------------------------------------------------------------
  -- CO
  -- ------------------------------------------------------------------
  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CO — Comprendre un premier contact',
    'CO',
    $c$Objectif
Comprendre un échange simple à l'accueil : saluer, se présenter, épeler son prénom, dire son âge, prendre congé.

Consigne
Lisez le dialogue (à écouter en classe ou avec un enregistrement). Repérez le prénom, le nom, l'âge et les formules de politesse. Puis faites les exercices.

Support — Dialogue à l'accueil
Réceptionniste : Bonjour, madame.
Amina : Bonjour. Je m'appelle Amina Niyonzima.
Réceptionniste : Enchantée, madame Niyonzima. Vous êtes nouvelle ?
Amina : Oui. Je suis rwandaise. J'apprends le français.
Réceptionniste : Très bien. Votre prénom s'écrit comment ?
Amina : A-M-I-N-A.
Réceptionniste : Merci. Et vous avez quel âge ?
Amina : J'ai vingt ans.
Réceptionniste : Parfait. La classe est au premier étage. Au revoir, madame.
Amina : Au revoir. Merci. À bientôt.

Points de langue
Bonjour / au revoir / à bientôt / enchanté(e) • je m'appelle • j'ai … ans • épeler.$c$,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux : Amina est nouvelle',
    'true_false',
    $j${
      "statement": "Amina est nouvelle dans l'école.",
      "correct": true,
      "explanation": "La réceptionniste demande : « Vous êtes nouvelle ? » Amina répond : « Oui. »"
    }$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Quel âge a Amina ?',
    'qcm',
    $j${
      "question": "Quel âge a Amina ?",
      "options": [
        {"text": "Douze ans", "correct": false},
        {"text": "Vingt ans", "correct": true},
        {"text": "Trente ans", "correct": false},
        {"text": "Elle ne dit pas son âge", "correct": false}
      ],
      "explanation": "Amina dit : « J'ai vingt ans. »"
    }$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez la formule et le moment',
    'matching',
    $j${
      "pairs": [
        {"left": "Bonjour", "right": "On arrive, le matin"},
        {"left": "Enchantée", "right": "On fait connaissance"},
        {"left": "Au revoir", "right": "On part"},
        {"left": "À bientôt", "right": "On se revoit plus tard"}
      ]
    }$j$::jsonb,
    2
  );

  -- ------------------------------------------------------------------
  -- CE
  -- ------------------------------------------------------------------
  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CE — Lire une fiche d''inscription',
    'CE',
    $c$Objectif
Lire une fiche d'inscription simple : prénom, nom, âge, classe, horaire.

Consigne
Lisez la fiche. Répondez ensuite aux questions : qui ? où ? à quelle heure ?

Support — Fiche d'inscription
École de français MFK
Fiche élève — niveau A1

Prénom : Amina
Nom : Niyonzima
Âge : 20 ans
Nationalité : rwandaise
Classe : A1 — Salle 2 (premier étage)
Horaire : lundi et mercredi, 9 h – 11 h
Professeur : monsieur Habimana

Consignes en classe
Écoutez. Répétez. Ouvrez le livre. Épelez votre nom.

Message de l'école
Bonjour Amina,
Bienvenue à l'école MFK. Le premier cours est lundi à 9 h, salle 2.
À bientôt,
L'accueil$c$,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Où est la classe d''Amina ?',
    'qcm',
    $j${
      "question": "Où est la classe d'Amina ?",
      "options": [
        {"text": "Salle 1, rez-de-chaussée", "correct": false},
        {"text": "Salle 2, premier étage", "correct": true},
        {"text": "Salle 20, deuxième étage", "correct": false},
        {"text": "À l'accueil", "correct": false}
      ],
      "explanation": "La fiche indique : Classe A1 — Salle 2 (premier étage)."
    }$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux : le cours commence à 11 h',
    'true_false',
    $j${
      "statement": "Le premier cours d'Amina commence à 11 h.",
      "correct": false,
      "explanation": "L'horaire est 9 h – 11 h. Le cours commence à 9 h."
    }$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez le prénom',
    'fill_blank',
    $j${
      "prompt": "Sur la fiche, on lit : Prénom : ___.\nÉcrivez le prénom de l'élève.",
      "answer": "Amina"
    }$j$::jsonb,
    2
  );

  -- ------------------------------------------------------------------
  -- PO
  -- ------------------------------------------------------------------
  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PO — Se présenter à l''oral',
    'PO',
    $c$Objectif
Saluer, dire son prénom, épeler, dire son âge, prendre congé — à l'oral, avec tu ou vous.

Consigne
1) Reliez les phrases utiles.
2) Remettez la présentation dans l'ordre.
3) Enregistrez votre présentation (20 à 30 secondes).

Modèles
Formel
Bonjour, madame. Je m'appelle Amina Niyonzima. J'ai vingt ans. Au revoir.

Informel
Salut ! Je m'appelle Amina. Et toi ?

Épelez
Mon prénom s'écrit A-M-I-N-A.

Nombres utiles
0 zéro • 1 un • 2 deux • 3 trois • 4 quatre • 5 cinq
6 six • 7 sept • 8 huit • 9 neuf • 10 dix
11 onze • 12 douze • 13 treize • 14 quatorze • 15 quinze
16 seize • 17 dix-sept • 18 dix-huit • 19 dix-neuf • 20 vingt$c$,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Quelle phrase pour quelle situation ?',
    'matching',
    $j${
      "pairs": [
        {"left": "Bonjour, monsieur.", "right": "Saluer (vous)"},
        {"left": "Salut !", "right": "Saluer (tu)"},
        {"left": "Je m'appelle Amina.", "right": "Dire son prénom"},
        {"left": "J'ai vingt ans.", "right": "Dire son âge"}
      ]
    }$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Remettez la présentation dans l''ordre',
    'word_order',
    $j${
      "words": ["Bonjour", "je", "m'appelle", "Amina"]
    }$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez votre présentation',
    'audio_record',
    $j${
      "instructions": "Enregistrez 20 à 30 secondes.\n1) Saluez (bonjour ou salut).\n2) Dites : Je m'appelle …\n3) Épelez votre prénom.\n4) Dites : J'ai … ans.\n5) Prenez congé (au revoir ou à bientôt)."
    }$j$::jsonb,
    2
  );

  -- ------------------------------------------------------------------
  -- PE
  -- ------------------------------------------------------------------
  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PE — Écrire une mini-présentation',
    'PE',
    $c$Objectif
Remplir une fiche et écrire 3 ou 4 phrases pour se présenter.

Consigne
Complétez les exercices. Pour la réponse libre, écrivez comme dans le modèle. Attention à je m'appelle et j'ai … ans.

Modèle
Bonjour,
Je m'appelle Amina Niyonzima.
J'ai vingt ans.
J'apprends le français.
À bientôt.

Fiche à imiter
Prénom : ________
Nom : ________
Âge : ________ ans
Classe : A1$c$,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez : j''ai … ans',
    'fill_blank',
    $j${
      "prompt": "Complétez avec le verbe juste (un mot) :\nJ'___ vingt ans.",
      "answer": "ai"
    }$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Remettez la phrase dans l''ordre',
    'word_order',
    $j${
      "words": ["Je", "m'appelle", "Amina", "Niyonzima"]
    }$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Écrivez votre présentation',
    'short_answer',
    $j${
      "prompt": "Écrivez 3 ou 4 phrases.\n1) Saluez.\n2) Je m'appelle …\n3) J'ai … ans.\n4) Prenez congé (au revoir / à bientôt).\nCorrection par l'enseignant."
    }$j$::jsonb,
    2
  );

  -- ------------------------------------------------------------------
  -- EL
  -- ------------------------------------------------------------------
  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'EL — Saluer, s''appeler, compter jusqu''à 20',
    'EL',
    $c$Objectif
Fixer les formes de la séquence : formules de politesse, s'appeler, je / tu / vous, nombres 0–20, consignes de classe.

Consigne
Lisez la fiche. Puis faites les trois exercices.

Fiche langue

1. Saluer et partir
Bonjour (vous, le matin / la journée) • Salut (tu)
Au revoir • À bientôt • Enchanté / Enchantée

2. s'appeler (présent)
je m'appelle
tu t'appelles
il / elle s'appelle
nous nous appelons
vous vous appelez
ils / elles s'appellent

3. C'est + nom
C'est Amina. C'est monsieur Habimana.

4. Avoir + âge
J'ai vingt ans. Tu as quel âge ?

5. Nombres 0–20
0 zéro  1 un  2 deux  3 trois  4 quatre  5 cinq
6 six  7 sept  8 huit  9 neuf  10 dix
11 onze  12 douze  13 treize  14 quatorze  15 quinze
16 seize  17 dix-sept  18 dix-huit  19 dix-neuf  20 vingt

6. En classe
Écoutez. Répétez. Ouvrez le livre. Épelez.
un livre • une salle • un stylo • une chaise$c$,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne forme',
    'qcm',
    $j${
      "question": "Complétez : Je ___ Amina.",
      "options": [
        {"text": "m'appelle", "correct": true},
        {"text": "s'appelle", "correct": false},
        {"text": "t'appelles", "correct": false},
        {"text": "appelons", "correct": false}
      ],
      "explanation": "Avec je, on dit je m'appelle."
    }$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre : BONJOUR',
    'anagram',
    $j${
      "word": "bonjour",
      "hint": "On dit ce mot le matin, pour saluer."
    }$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
      "sentence_with_error": "Je s'appelle Paul.",
      "correct_sentence": "Je m'appelle Paul.",
      "explanation": "Je → je m'appelle. Il / elle → il / elle s'appelle."
    }$j$::jsonb,
    2
  );

  RAISE NOTICE 'Seed A1 séquence 1 terminé (module %, séquence %)', v_module_id, v_seq_id;
END;
$$;
