/*
  # Seed eLearning MFK — Module 1 A1 « Premiers repères » (v2)

  Annule le seed v1 (module unique « A1 — Parcours MFK » + séquence
  « Séquence 1 — Premiers repères ») puis crée UN module par grande
  étape. Ce fichier = Module 1 seulement (4 séquences × 5 leçons).

  Aucune table nouvelle. Idempotent. Plafond UI : 6 séquences / module.

  JSON `content` (lib/elearning-exercises.ts) :
    qcm           { question, options: [{text, correct}], explanation }
    matching      { pairs: [{left, right}] }
    fill_blank    { prompt, answer }
    short_answer  { prompt }
    word_order    { words: string[] }
    anagram       { word, hint }
    true_false    { statement, correct, explanation }
    find_error    { sentence_with_error, correct_sentence, explanation }
    audio_record  { instructions }
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
  v_module_title text := 'A1 — Premiers repères';
BEGIN
  -- v1 cleanup (cascade lessons/exercises via sequences)
  DELETE FROM elearning_sequences
  WHERE title = 'Séquence 1 — Premiers repères';

  DELETE FROM elearning_modules m
  WHERE m.title = 'A1 — Parcours MFK'
    AND NOT EXISTS (
      SELECT 1 FROM elearning_sequences s WHERE s.module_id = m.id
    );

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
      'Seed A1 impossible : aucun enseignant (teachers) trouvé.';
  END IF;

  RAISE NOTICE 'Seed Module 1 : enseignant % (%)', v_teacher_email, v_teacher_id;

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
      'Grande étape 1 du parcours A1 : saluer et se présenter, se compter, situer le monde en français, vivre en classe.',
      'A1',
      false
    )
    RETURNING id INTO v_module_id;
  ELSE
    UPDATE elearning_modules
    SET
      description = 'Grande étape 1 du parcours A1 : saluer et se présenter, se compter, situer le monde en français, vivre en classe.',
      cefr_level = 'A1',
      updated_at = now()
    WHERE id = v_module_id;
  END IF;

  -- ===== Bienvenue en français =====
  SELECT s.id INTO v_seq_id
  FROM elearning_sequences s
  WHERE s.module_id = v_module_id AND s.title = 'Bienvenue en français'
  LIMIT 1;

  IF v_seq_id IS NULL THEN
    INSERT INTO elearning_sequences (module_id, title, order_index)
    VALUES (v_module_id, 'Bienvenue en français', 0)
    RETURNING id INTO v_seq_id;
  ELSE
    UPDATE elearning_sequences
    SET order_index = 0
    WHERE id = v_seq_id;
  END IF;

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CO — Comprendre un accueil',
    'CO',
    $c$Objectif
Comprendre un premier contact : saluer (tu / vous), se présenter avec s'appeler, prendre congé.

Consigne
Lisez le dialogue (à écouter en classe). Repérez les formules de politesse et les noms. Puis faites les exercices.

Support — Premier jour à l'école
Réceptionniste : Bonjour, monsieur.
Jean : Bonjour, madame. Je m'appelle Jean Mugisha.
Réceptionniste : Enchantée, monsieur Mugisha. Vous êtes nouveau ?
Jean : Oui. C'est mon premier cours.
Réceptionniste : Très bien. La professeure s'appelle madame Uwase. Au revoir, monsieur.
Jean : Au revoir. Merci. À bientôt.

Dans la classe
Claire : Salut ! Je m'appelle Claire. Et toi ?
Jean : Salut. Je m'appelle Jean.
Claire : Enchantée.

Point de langue
Bonjour / salut / au revoir / à bientôt / merci / enchanté(e) • je m'appelle • tu / vous • c'est.$c$,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux : Jean est nouveau',
    'true_false',
    $j${
  "statement": "Jean est nouveau à l'école.",
  "correct": true,
  "explanation": "Jean dit : « C'est mon premier cours. » La réceptionniste demande : « Vous êtes nouveau ? »"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Comment Claire salue-t-elle Jean ?',
    'qcm',
    $j${
  "question": "Comment Claire salue-t-elle Jean ?",
  "options": [
    {
      "text": "Bonjour, monsieur.",
      "correct": false
    },
    {
      "text": "Salut !",
      "correct": true
    },
    {
      "text": "Au revoir.",
      "correct": false
    },
    {
      "text": "S'il vous plaît.",
      "correct": false
    }
  ],
  "explanation": "Entre camarades, Claire dit « Salut ! » (tutoiement). À l'accueil, on dit « Bonjour, monsieur. » (vouvoiement)."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez la formule et la situation',
    'matching',
    $j${
  "pairs": [
    {
      "left": "Bonjour, madame.",
      "right": "Saluer (vous)"
    },
    {
      "left": "Salut !",
      "right": "Saluer (tu)"
    },
    {
      "left": "Enchantée.",
      "right": "Faire connaissance"
    },
    {
      "left": "Au revoir.",
      "right": "Partir"
    }
  ]
}$j$::jsonb,
    2
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CE — Lire un message de bienvenue',
    'CE',
    $c$Objectif
Lire un message simple de bienvenue : salutations, prénom, nom, vouvoiement.

Consigne
Lisez le message de madame Uwase. Qui écrit ? À qui ? Quelles formules voyez-vous ?

Support — Message
Bonjour Jean,
Bienvenue à l'école MFK.
Je m'appelle Claire Uwase. Je suis votre professeure.
Le premier cours : lundi, salle 2.
À bientôt,
Madame Uwase

Affiche à l'accueil
Bonjour !
Je m'appelle Paul. C'est l'accueil.
Merci. Au revoir.$c$,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Qui écrit le message ?',
    'qcm',
    $j${
  "question": "Qui écrit le message à Jean ?",
  "options": [
    {
      "text": "Paul, à l'accueil",
      "correct": false
    },
    {
      "text": "Claire Uwase, la professeure",
      "correct": true
    },
    {
      "text": "Jean Mugisha",
      "correct": false
    },
    {
      "text": "Un camarade de classe",
      "correct": false
    }
  ],
  "explanation": "Le message est signé Madame Uwase. Elle écrit : « Je m'appelle Claire Uwase. Je suis votre professeure. »"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux : le message tutoie Jean',
    'true_false',
    $j${
  "statement": "Madame Uwase tutoie Jean dans le message.",
  "correct": false,
  "explanation": "Elle écrit « votre professeure » : c'est le vouvoiement (vous)."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez : je m''appelle',
    'fill_blank',
    $j${
  "prompt": "Dans le message, la professeure écrit :\nJe ___ Claire Uwase.\nUn mot (forme de s'appeler).",
  "answer": "m'appelle"
}$j$::jsonb,
    2
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PO — Saluer et se présenter',
    'PO',
    $c$Objectif
Saluer (tu / vous), dire je m'appelle…, dire c'est…, prendre congé — à l'oral.

Consigne
Reliez les phrases, remettez la présentation dans l'ordre, puis enregistrez-vous (20 à 30 secondes).

Modèles
Vous : Bonjour, madame. Je m'appelle Jean Mugisha. Enchanté. Au revoir.
Tu : Salut ! Je m'appelle Jean. Et toi ?
C'est : C'est Claire. C'est monsieur Mugisha.$c$,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Tu ou vous ?',
    'matching',
    $j${
  "pairs": [
    {
      "left": "Bonjour, monsieur.",
      "right": "vous"
    },
    {
      "left": "Salut, ça va ?",
      "right": "tu"
    },
    {
      "left": "Comment vous appelez-vous ?",
      "right": "vous"
    },
    {
      "left": "Et toi ?",
      "right": "tu"
    }
  ]
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Remettez la phrase dans l''ordre',
    'word_order',
    $j${
  "words": [
    "Bonjour",
    "je",
    "m'appelle",
    "Jean"
  ]
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez votre présentation',
    'audio_record',
    $j${
  "instructions": "Enregistrez 20 à 30 secondes.\n1) Saluez (bonjour ou salut).\n2) Dites : Je m'appelle …\n3) Dites : Enchanté ou Enchantée.\n4) Prenez congé (au revoir ou à bientôt)."
}$j$::jsonb,
    2
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PE — Écrire « Bonjour, je m''appelle… »',
    'PE',
    $c$Objectif
Écrire une mini-présentation : saluer, je m'appelle, c'est, prendre congé.

Consigne
Complétez, remettez les mots dans l'ordre, puis écrivez 3 phrases comme dans le modèle.

Modèle
Bonjour,
Je m'appelle Amina Niyonzima.
C'est mon premier cours.
À bientôt.$c$,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez : c''est',
    'fill_blank',
    $j${
  "prompt": "Complétez (deux mots) :\n___ mon premier cours.",
  "answer": "C'est"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Remettez la phrase dans l''ordre',
    'word_order',
    $j${
  "words": [
    "Je",
    "m'appelle",
    "Amina",
    "Niyonzima"
  ]
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Écrivez votre présentation',
    'short_answer',
    $j${
  "prompt": "Écrivez 3 phrases.\n1) Saluez (Bonjour ou Salut).\n2) Je m'appelle …\n3) Au revoir ou À bientôt.\nCorrection par l'enseignant."
}$j$::jsonb,
    2
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'EL — s''appeler, tu / vous, formules de politesse',
    'EL',
    $c$Objectif
Fixer le point de langue de la séquence : formules de politesse, tu / vous, s'appeler, c'est.

Consigne
Lisez la fiche. Puis faites les trois exercices.

Fiche langue

1. Saluer et partir
vous : Bonjour, monsieur / madame. Au revoir. À bientôt.
tu : Salut. À plus.
Enchanté / Enchantée. Merci. S'il vous plaît.

2. s'appeler
je m'appelle
tu t'appelles
il / elle s'appelle
nous nous appelons
vous vous appelez
ils / elles s'appellent

3. c'est + nom
C'est Jean. C'est madame Uwase.

4. tu / vous
Camarade → tu. Accueil, professeur → vous.$c$,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne forme',
    'qcm',
    $j${
  "question": "Complétez : Je ___ Jean.",
  "options": [
    {
      "text": "m'appelle",
      "correct": true
    },
    {
      "text": "s'appelle",
      "correct": false
    },
    {
      "text": "t'appelles",
      "correct": false
    },
    {
      "text": "appelez",
      "correct": false
    }
  ],
  "explanation": "Avec je : je m'appelle. Avec il / elle : il / elle s'appelle."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre : BONJOUR',
    'anagram',
    $j${
  "word": "bonjour",
  "hint": "On dit ce mot pour saluer (vous), le matin."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Je s'appelle Claire.",
  "correct_sentence": "Je m'appelle Claire.",
  "explanation": "Je → je m'appelle. Il / elle → il / elle s'appelle."
}$j$::jsonb,
    2
  );

  -- ===== Se compter et s'organiser =====
  SELECT s.id INTO v_seq_id
  FROM elearning_sequences s
  WHERE s.module_id = v_module_id AND s.title = 'Se compter et s''organiser'
  LIMIT 1;

  IF v_seq_id IS NULL THEN
    INSERT INTO elearning_sequences (module_id, title, order_index)
    VALUES (v_module_id, 'Se compter et s''organiser', 1)
    RETURNING id INTO v_seq_id;
  ELSE
    UPDATE elearning_sequences
    SET order_index = 1
    WHERE id = v_seq_id;
  END IF;

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CO — Comprendre l''âge et le jour',
    'CO',
    $c$Objectif
Comprendre les nombres 0–20, l'âge (j'ai … ans) et le jour de la semaine (c'est lundi).

Consigne
Lisez le dialogue. Repérez l'âge de chacun et le jour du cours.

Support — Avant le cours
Claire : On est quel jour, Jean ?
Jean : C'est lundi.
Claire : Super. Tu as quel âge ?
Jean : J'ai vingt ans. Et toi ?
Claire : J'ai dix-neuf ans.
Professeure : Bonjour. Nous sommes dix dans la classe. C'est le premier cours.
Jean : Il y a combien d'élèves ?
Professeure : Dix. Un, deux, trois… dix.

Nombres entendus
0 zéro • 1 un • 2 deux • 10 dix • 19 dix-neuf • 20 vingt.$c$,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux : le cours est mardi',
    'true_false',
    $j${
  "statement": "Le cours a lieu mardi.",
  "correct": false,
  "explanation": "Jean dit : « C'est lundi. »"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Quel âge a Claire ?',
    'qcm',
    $j${
  "question": "Quel âge a Claire ?",
  "options": [
    {
      "text": "Dix ans",
      "correct": false
    },
    {
      "text": "Douze ans",
      "correct": false
    },
    {
      "text": "Dix-neuf ans",
      "correct": true
    },
    {
      "text": "Vingt ans",
      "correct": false
    }
  ],
  "explanation": "Claire dit : « J'ai dix-neuf ans. » Jean a vingt ans."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez le chiffre et le mot',
    'matching',
    $j${
  "pairs": [
    {
      "left": "1",
      "right": "un"
    },
    {
      "left": "10",
      "right": "dix"
    },
    {
      "left": "19",
      "right": "dix-neuf"
    },
    {
      "left": "20",
      "right": "vingt"
    }
  ]
}$j$::jsonb,
    2
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CE — Lire un petit emploi du temps',
    'CE',
    $c$Objectif
Lire un emploi du temps A1 : jours, nombres (salle, âge, horaire en chiffres).

Consigne
Lisez la fiche. Quel jour ? Quelle salle ? Combien d'élèves ?

Support — Fiche classe A1
École MFK — Niveau A1
Jour : lundi et mercredi
Salle : 2
Élèves : 10
Professeure : madame Uwase

Trombinoscope
Jean Mugisha — 20 ans
Claire Habimana — 19 ans
Amina Niyonzima — 18 ans
Paul Uwimana — 16 ans

Note
C'est lundi. Cours A1, salle 2. Nous sommes dix.$c$,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Quels jours a lieu le cours ?',
    'qcm',
    $j${
  "question": "Quels jours a lieu le cours A1 ?",
  "options": [
    {
      "text": "Mardi et jeudi",
      "correct": false
    },
    {
      "text": "Lundi et mercredi",
      "correct": true
    },
    {
      "text": "Samedi seulement",
      "correct": false
    },
    {
      "text": "Tous les jours",
      "correct": false
    }
  ],
  "explanation": "La fiche indique : lundi et mercredi."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux : il y a vingt élèves',
    'true_false',
    $j${
  "statement": "Il y a vingt élèves dans la classe A1.",
  "correct": false,
  "explanation": "La fiche indique 10 élèves. Vingt, c'est l'âge de Jean."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez le jour',
    'fill_blank',
    $j${
  "prompt": "La note dit : C'est ___.\nÉcrivez le jour (un mot, minuscules acceptées).",
  "answer": "lundi"
}$j$::jsonb,
    2
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PO — Dire son âge et le jour',
    'PO',
    $c$Objectif
Dire les nombres 0–20, son âge (j'ai … ans) et le jour (c'est + jour).

Consigne
Associez, remettez la phrase dans l'ordre, puis enregistrez-vous.

Modèles
J'ai vingt ans. Tu as quel âge ?
C'est lundi. On est quel jour ?
Nous sommes dix.

Jours
lundi mardi mercredi jeudi vendredi samedi dimanche$c$,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez la question et la réponse',
    'matching',
    $j${
  "pairs": [
    {
      "left": "Tu as quel âge ?",
      "right": "J'ai vingt ans."
    },
    {
      "left": "On est quel jour ?",
      "right": "C'est lundi."
    },
    {
      "left": "Vous êtes combien ?",
      "right": "Nous sommes dix."
    },
    {
      "left": "C'est quel numéro ?",
      "right": "Salle 2."
    }
  ]
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Remettez la phrase dans l''ordre',
    'word_order',
    $j${
  "words": [
    "J'ai",
    "vingt",
    "ans"
  ]
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez : âge et jour',
    'audio_record',
    $j${
  "instructions": "Enregistrez 20 à 30 secondes.\n1) Dites : Bonjour, je m'appelle …\n2) Dites : J'ai … ans.\n3) Dites le jour d'aujourd'hui : C'est …"
}$j$::jsonb,
    2
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PE — Remplir une fiche (âge, jour)',
    'PE',
    $c$Objectif
Écrire les nombres, l'âge et le jour sur une fiche simple.

Consigne
Complétez, remettez les mots dans l'ordre, puis écrivez votre fiche.

Modèle
Je m'appelle Amina.
J'ai dix-huit ans.
Le cours : c'est lundi.
Salle 2.$c$,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez : j''ai … ans',
    'fill_blank',
    $j${
  "prompt": "Complétez avec le verbe (un mot) :\nJ'___ dix-huit ans.",
  "answer": "ai"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Remettez la phrase dans l''ordre',
    'word_order',
    $j${
  "words": [
    "C'est",
    "lundi"
  ]
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Écrivez votre fiche',
    'short_answer',
    $j${
  "prompt": "Écrivez 3 phrases.\n1) Je m'appelle …\n2) J'ai … ans. (en lettres si possible : vingt, dix-huit…)\n3) C'est … (un jour de la semaine).\nCorrection par l'enseignant."
}$j$::jsonb,
    2
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'EL — Nombres 0–20, avoir + âge, jours',
    'EL',
    $c$Objectif
Fixer le point de langue : nombres 0–20, j'ai … ans, jours de la semaine, c'est + jour.

Consigne
Lisez la fiche. Puis faites les exercices.

Fiche langue

1. Nombres 0–20
0 zéro  1 un  2 deux  3 trois  4 quatre  5 cinq
6 six  7 sept  8 huit  9 neuf  10 dix
11 onze  12 douze  13 treize  14 quatorze  15 quinze
16 seize  17 dix-sept  18 dix-huit  19 dix-neuf  20 vingt

2. Avoir + âge
J'ai vingt ans. Tu as quel âge ?
Il / elle a dix-neuf ans.

3. Jours
lundi mardi mercredi jeudi vendredi samedi dimanche
C'est lundi. On est quel jour ?

4. Compter les personnes
Nous sommes dix. Vous êtes combien ?$c$,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Quel mot pour 18 ?',
    'qcm',
    $j${
  "question": "Comment écrit-on 18 en lettres ?",
  "options": [
    {
      "text": "huit",
      "correct": false
    },
    {
      "text": "dix-huit",
      "correct": true
    },
    {
      "text": "vingt",
      "correct": false
    },
    {
      "text": "douze",
      "correct": false
    }
  ],
  "explanation": "18 = dix-huit. 8 = huit. 20 = vingt. 12 = douze."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre : LUNDI',
    'anagram',
    $j${
  "word": "lundi",
  "hint": "Premier jour de la semaine (en France et au Rwanda, à l'école)."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Je suis vingt ans.",
  "correct_sentence": "J'ai vingt ans.",
  "explanation": "L'âge se dit avec avoir : j'ai vingt ans. Pas être."
}$j$::jsonb,
    2
  );

  -- ===== Le monde en français =====
  SELECT s.id INTO v_seq_id
  FROM elearning_sequences s
  WHERE s.module_id = v_module_id AND s.title = 'Le monde en français'
  LIMIT 1;

  IF v_seq_id IS NULL THEN
    INSERT INTO elearning_sequences (module_id, title, order_index)
    VALUES (v_module_id, 'Le monde en français', 2)
    RETURNING id INTO v_seq_id;
  ELSE
    UPDATE elearning_sequences
    SET order_index = 2
    WHERE id = v_seq_id;
  END IF;

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CO — Comprendre « D''où viens-tu ? »',
    'CO',
    $c$Objectif
Comprendre un échange sur le pays, la nationalité et la langue (être, d'où, je parle).

Consigne
Lisez le dialogue. D'où vient chaque personne ? Quelle langue parle-t-elle ?

Support — Dans la cour
Claire : Jean, d'où viens-tu ?
Jean : Je viens du Rwanda. Je suis rwandais. Je parle kinyarwanda et un peu français.
Claire : Moi, je viens du Burundi. Je suis burundaise.
Amina : Je viens de France. Je suis française. Je parle français.
Paul : Je viens de la RDC. Je suis congolais.
Professeure : Très bien. En classe, nous parlons français.

Pays et nationalités
Rwanda → rwandais / rwandaise
Burundi → burundais / burundaise
France → français / française
RDC → congolais / congolaise$c$,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux : Jean est français',
    'true_false',
    $j${
  "statement": "Jean est français.",
  "correct": false,
  "explanation": "Jean vient du Rwanda. Il est rwandais. Amina est française."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'D''où vient Claire ?',
    'qcm',
    $j${
  "question": "D'où vient Claire ?",
  "options": [
    {
      "text": "Du Rwanda",
      "correct": false
    },
    {
      "text": "Du Burundi",
      "correct": true
    },
    {
      "text": "De France",
      "correct": false
    },
    {
      "text": "De la RDC",
      "correct": false
    }
  ],
  "explanation": "Claire dit : « Je viens du Burundi. Je suis burundaise. »"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez le pays et la nationalité',
    'matching',
    $j${
  "pairs": [
    {
      "left": "Rwanda",
      "right": "rwandais / rwandaise"
    },
    {
      "left": "Burundi",
      "right": "burundais / burundaise"
    },
    {
      "left": "France",
      "right": "français / française"
    },
    {
      "left": "RDC",
      "right": "congolais / congolaise"
    }
  ]
}$j$::jsonb,
    2
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CE — Lire des cartes d''identité',
    'CE',
    $c$Objectif
Lire des fiches courtes : prénom, pays, nationalité, langue.

Consigne
Lisez les quatre cartes. Qui parle kinyarwanda ? Qui vient de France ?

Support — Cartes élèves
Carte 1
Prénom : Jean
Pays : Rwanda
Nationalité : rwandais
Langues : kinyarwanda, français

Carte 2
Prénom : Amina
Pays : France
Nationalité : française
Langues : français

Carte 3
Prénom : Paul
Pays : RDC
Nationalité : congolais
Langues : swahili, français

Message
Bonjour,
Je m'appelle Claire. Je viens du Burundi. Je suis burundaise.
Je parle kirundi et français.
À bientôt.$c$,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Qui vient de France ?',
    'qcm',
    $j${
  "question": "Qui vient de France ?",
  "options": [
    {
      "text": "Jean",
      "correct": false
    },
    {
      "text": "Amina",
      "correct": true
    },
    {
      "text": "Paul",
      "correct": false
    },
    {
      "text": "Claire",
      "correct": false
    }
  ],
  "explanation": "La carte 2 : Amina, pays France, nationale française."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux : Paul parle swahili',
    'true_false',
    $j${
  "statement": "Paul parle swahili.",
  "correct": true,
  "explanation": "Carte 3 : Langues : swahili, français."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez la nationalité',
    'fill_blank',
    $j${
  "prompt": "Claire écrit : Je suis ___.\nUn mot (féminin).",
  "answer": "burundaise"
}$j$::jsonb,
    2
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PO — Dire son pays, sa nationalité, sa langue',
    'PO',
    $c$Objectif
Dire d'où on vient, sa nationalité (être) et les langues (je parle…).

Consigne
Associez, remettez la phrase dans l'ordre, puis enregistrez-vous.

Modèles
Je viens du Rwanda. Je suis rwandais.
Je viens de France. Je suis française.
Je parle français et kinyarwanda.
D'où viens-tu ? Tu es de quel pays ?

Prépositions
de France • du Rwanda • du Burundi • de la RDC • en France • au Rwanda$c$,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez la phrase et le sens',
    'matching',
    $j${
  "pairs": [
    {
      "left": "Je viens du Rwanda.",
      "right": "le pays"
    },
    {
      "left": "Je suis rwandaise.",
      "right": "la nationalité"
    },
    {
      "left": "Je parle français.",
      "right": "la langue"
    },
    {
      "left": "D'où viens-tu ?",
      "right": "la question"
    }
  ]
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Remettez la phrase dans l''ordre',
    'word_order',
    $j${
  "words": [
    "Je",
    "viens",
    "du",
    "Rwanda"
  ]
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez : pays, nationalité, langue',
    'audio_record',
    $j${
  "instructions": "Enregistrez 20 à 30 secondes.\n1) Je m'appelle …\n2) Je viens de / du / de la …\n3) Je suis … (nationalité, accord : rwandais / rwandaise).\n4) Je parle …"
}$j$::jsonb,
    2
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PE — Écrire d''où on vient',
    'PE',
    $c$Objectif
Écrire 3 ou 4 phrases : pays, nationalité (accord), langues.

Consigne
Complétez, remettez les mots dans l'ordre, puis écrivez votre carte.

Modèle
Je m'appelle Amina.
Je viens de France.
Je suis française.
Je parle français.$c$,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez : je suis',
    'fill_blank',
    $j${
  "prompt": "Complétez le verbe (un mot) :\nJe ___ rwandaise.",
  "answer": "suis"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Remettez la phrase dans l''ordre',
    'word_order',
    $j${
  "words": [
    "Je",
    "parle",
    "français"
  ]
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Écrivez votre carte',
    'short_answer',
    $j${
  "prompt": "Écrivez 4 phrases.\n1) Je m'appelle …\n2) Je viens de / du / de la …\n3) Je suis … (nationalité, masculin ou féminin).\n4) Je parle …\nCorrection par l'enseignant."
}$j$::jsonb,
    2
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'EL — être, nationalités, je parle, de / du / en',
    'EL',
    $c$Objectif
Fixer le point de langue : être + nationalité, d'où viens-tu ?, je parle, de / du / de la / en / au.

Consigne
Lisez la fiche. Attention à l'accord (rwandais / rwandaise).

Fiche langue

1. être (présent)
je suis  tu es  il / elle est
nous sommes  vous êtes  ils / elles sont

2. Nationalités (accord)
rwandais / rwandaise
burundais / burundaise
français / française
congolais / congolaise

3. Pays : de / du / de la • en / au
Je viens de France. Je vis en France.
Je viens du Rwanda. Je vis au Rwanda.
Je viens de la RDC.

4. Langues
Je parle français. Je parle kinyarwanda.
Tu parles quelle langue ?$c$,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la bonne forme',
    'qcm',
    $j${
  "question": "Amina est une femme. On dit : Amina est ___.",
  "options": [
    {
      "text": "français",
      "correct": false
    },
    {
      "text": "française",
      "correct": true
    },
    {
      "text": "France",
      "correct": false
    },
    {
      "text": "françaises",
      "correct": false
    }
  ],
  "explanation": "Nationalité au féminin : française. Le pays : la France."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez : je viens … Rwanda',
    'fill_blank',
    $j${
  "prompt": "Complétez (un mot) :\nJe viens ___ Rwanda.",
  "answer": "du"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Je suis rwandaise. Je viens de Rwanda.",
  "correct_sentence": "Je suis rwandaise. Je viens du Rwanda.",
  "explanation": "On dit du Rwanda (de + le). De France, du Rwanda, de la RDC."
}$j$::jsonb,
    2
  );

  -- ===== Vivre en classe =====
  SELECT s.id INTO v_seq_id
  FROM elearning_sequences s
  WHERE s.module_id = v_module_id AND s.title = 'Vivre en classe'
  LIMIT 1;

  IF v_seq_id IS NULL THEN
    INSERT INTO elearning_sequences (module_id, title, order_index)
    VALUES (v_module_id, 'Vivre en classe', 3)
    RETURNING id INTO v_seq_id;
  ELSE
    UPDATE elearning_sequences
    SET order_index = 3
    WHERE id = v_seq_id;
  END IF;

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CO — Comprendre les consignes du professeur',
    'CO',
    $c$Objectif
Comprendre les consignes de classe (impératif) et les objets (un / une).

Consigne
Lisez le dialogue. Que dit la professeure ? Que répond l'élève ?

Support — En classe
Professeure : Bonjour. Asseyez-vous. Ouvrez le livre, page 2.
Jean : Pardon, madame. Je ne comprends pas. Répétez, s'il vous plaît.
Professeure : Écoutez. Répétez : « Bonjour ».
Classe : Bonjour.
Professeure : Très bien. Fermez le cahier. Prenez un stylo.
Claire : Madame, comment dit-on « book » en français ?
Professeure : Un livre. C'est un livre. C'est une chaise.
Jean : Merci.

Consignes
Écoutez. Répétez. Ouvrez. Fermez. Asseyez-vous. Prenez. Épelez.$c$,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux : Jean comprend tout',
    'true_false',
    $j${
  "statement": "Jean comprend tout dès le début.",
  "correct": false,
  "explanation": "Jean dit : « Je ne comprends pas. Répétez, s'il vous plaît. »"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Que prend-on à la fin ?',
    'qcm',
    $j${
  "question": "Que dit la professeure à la fin ?",
  "options": [
    {
      "text": "Fermez la porte.",
      "correct": false
    },
    {
      "text": "Prenez un stylo.",
      "correct": true
    },
    {
      "text": "Sortez.",
      "correct": false
    },
    {
      "text": "Épelez votre nom.",
      "correct": false
    }
  ],
  "explanation": "Elle dit : « Fermez le cahier. Prenez un stylo. »"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez la consigne et le sens',
    'matching',
    $j${
  "pairs": [
    {
      "left": "Écoutez.",
      "right": "On entend"
    },
    {
      "left": "Répétez.",
      "right": "On dit encore"
    },
    {
      "left": "Ouvrez le livre.",
      "right": "On ouvre"
    },
    {
      "left": "Je ne comprends pas.",
      "right": "On a besoin d'aide"
    }
  ]
}$j$::jsonb,
    2
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'CE — Lire l''affiche de la classe',
    'CE',
    $c$Objectif
Lire une affiche de consignes et une liste d'objets (un / une).

Consigne
Lisez l'affiche. Quelles consignes ? Quels objets ?

Support — Affiche « Vivre en classe »
En classe, on dit :
Bonjour. Merci. S'il vous plaît.
Écoutez. Répétez. Ouvrez le livre. Fermez le cahier.
Je ne comprends pas. Comment dit-on … ? Répétez, s'il vous plaît.

Objets
un livre • un cahier • un stylo • un sac
une chaise • une table • une porte • une fenêtre

Message du jour
Bonjour,
Aujourd'hui : ouvrez le livre, page 2. Prenez un stylo.
À bientôt,
Madame Uwase$c$,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Quelle page ouvre-t-on ?',
    'qcm',
    $j${
  "question": "Quelle page du livre ouvre-t-on aujourd'hui ?",
  "options": [
    {
      "text": "Page 1",
      "correct": false
    },
    {
      "text": "Page 2",
      "correct": true
    },
    {
      "text": "Page 10",
      "correct": false
    },
    {
      "text": "Page 20",
      "correct": false
    }
  ],
  "explanation": "Le message : « ouvrez le livre, page 2. »"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Vrai ou faux : « chaise » est masculin',
    'true_false',
    $j${
  "statement": "On dit un chaise.",
  "correct": false,
  "explanation": "On dit une chaise (féminin). Un livre, un stylo ; une chaise, une table."
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez l''article',
    'fill_blank',
    $j${
  "prompt": "Complétez (un mot) :\nPrenez ___ stylo.",
  "answer": "un"
}$j$::jsonb,
    2
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PO — Demander en classe',
    'PO',
    $c$Objectif
Dire et demander les consignes : impératif, je ne comprends pas, comment dit-on… ?

Consigne
Associez, remettez la phrase dans l'ordre, puis enregistrez une demande d'aide.

Modèles
Répétez, s'il vous plaît.
Je ne comprends pas.
Comment dit-on « book » en français ?
Ouvrez le livre. Écoutez. Répétez.$c$,
    2
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Associez la phrase et le moment',
    'matching',
    $j${
  "pairs": [
    {
      "left": "Écoutez.",
      "right": "Le professeur parle"
    },
    {
      "left": "Répétez, s'il vous plaît.",
      "right": "Je n'ai pas entendu"
    },
    {
      "left": "Je ne comprends pas.",
      "right": "C'est difficile"
    },
    {
      "left": "Comment dit-on … ?",
      "right": "Je cherche le mot"
    }
  ]
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Remettez la consigne dans l''ordre',
    'word_order',
    $j${
  "words": [
    "Ouvrez",
    "le",
    "livre"
  ]
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Enregistrez une demande en classe',
    'audio_record',
    $j${
  "instructions": "Enregistrez 20 secondes.\n1) Dites : Pardon, madame (ou monsieur).\n2) Dites : Je ne comprends pas.\n3) Dites : Répétez, s'il vous plaît.\n4) Demandez un mot : Comment dit-on … en français ?"
}$j$::jsonb,
    2
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'PE — Écrire consignes et objets',
    'PE',
    $c$Objectif
Écrire des consignes à l'impératif et une mini-liste d'objets (un / une).

Consigne
Complétez, remettez les mots dans l'ordre, puis écrivez 4 lignes.

Modèle
Écoutez. Répétez.
Ouvrez le livre.
C'est un stylo. C'est une chaise.
Je ne comprends pas.$c$,
    3
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Complétez : une chaise',
    'fill_blank',
    $j${
  "prompt": "Complétez l'article (un mot) :\nC'est ___ chaise.",
  "answer": "une"
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Remettez la phrase dans l''ordre',
    'word_order',
    $j${
  "words": [
    "Je",
    "ne",
    "comprends",
    "pas"
  ]
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Écrivez l''affiche de la classe',
    'short_answer',
    $j${
  "prompt": "Écrivez 4 lignes.\n1) Une consigne (Écoutez / Répétez / Ouvrez…).\n2) C'est un … (objet masculin).\n3) C'est une … (objet féminin).\n4) Je ne comprends pas. ou Comment dit-on … ?\nCorrection par l'enseignant."
}$j$::jsonb,
    2
  );

  v_lesson_id := pg_temp.mfk_upsert_lesson(
    v_seq_id,
    'EL — Impératif, un / une, je ne comprends pas',
    'EL',
    $c$Objectif
Fixer le point de langue : impératif de classe, articles un / une, phrases utiles.

Consigne
Lisez la fiche. Puis faites les exercices.

Fiche langue

1. Impératif (vous, en classe)
Écoutez. Répétez. Ouvrez. Fermez. Asseyez-vous. Prenez. Épelez.

2. un / une
un livre, un cahier, un stylo, un sac
une chaise, une table, une porte, une fenêtre
C'est un livre. C'est une chaise.

3. Phrases utiles
Je ne comprends pas.
Répétez, s'il vous plaît.
Comment dit-on … en français ?
Pardon, madame / monsieur.

4. Négation
Je comprends. → Je ne comprends pas.$c$,
    4
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Choisissez la consigne',
    'qcm',
    $j${
  "question": "Le professeur veut que la classe dise encore le mot. Il dit :",
  "options": [
    {
      "text": "Asseyez-vous.",
      "correct": false
    },
    {
      "text": "Répétez.",
      "correct": true
    },
    {
      "text": "Fermez le cahier.",
      "correct": false
    },
    {
      "text": "Au revoir.",
      "correct": false
    }
  ],
  "explanation": "Répétez = dire encore. Écoutez = entendre. Ouvrez / fermez = le livre ou le cahier."
}$j$::jsonb,
    0
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Lettres dans l''ordre : LIVRE',
    'anagram',
    $j${
  "word": "livre",
  "hint": "On dit : un livre. Comment dit-on « book » ?"
}$j$::jsonb,
    1
  );

  PERFORM pg_temp.mfk_seed_exercise(
    v_lesson_id,
    'Trouvez l''erreur',
    'find_error',
    $j${
  "sentence_with_error": "Je ne comprends.",
  "correct_sentence": "Je ne comprends pas.",
  "explanation": "La négation : ne … pas. Je ne comprends pas."
}$j$::jsonb,
    2
  );

  RAISE NOTICE 'Seed Module 1 terminé (module %)', v_module_id;
END;
$$;
