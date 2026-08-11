/*
  # Seed : 120 questions Révision — Unité 1 Conjugaison

  12 points × 10 questions (format TCF texte à trous).
  point_id résolu via revision_unites.numero = 1 + revision_points.numero.
  Idempotent : n'insère pas si (point_id, ordre) existe déjà.

  Niveaux par point : ~3 A1–A2, ~4 B1–B2, ~3 C1–C2.
*/

INSERT INTO public.revision_questions (
  point_id,
  ordre,
  niveau,
  question_texte,
  choix_a,
  choix_b,
  choix_c,
  choix_d,
  bonne_reponse
)
SELECT
  p.id,
  v.ordre,
  v.niveau,
  v.question_texte,
  v.choix_a,
  v.choix_b,
  v.choix_c,
  v.choix_d,
  v.bonne_reponse
FROM public.revision_unites u
JOIN public.revision_points p ON p.unite_id = u.id
JOIN (
  VALUES
  -- ========================================================================
  -- Point 1 — Les 3 groupes de verbes et leurs terminaisons
  -- ========================================================================
  (
    1, 1, 'A1',
    'Nous ___ (parler) français en classe. (1er groupe)',
    'parlons',
    'parlez',
    'parlent',
    'parle',
    'a'
  ),
  (
    1, 2, 'A1',
    'Tu ___ (finir) toujours tes exercices. (2e groupe)',
    'finit',
    'finis',
    'finisses',
    'finissons',
    'b'
  ),
  (
    1, 3, 'A2',
    'Ils ___ (vendre) leur voiture. (3e groupe)',
    'vendons',
    'vendez',
    'vendent',
    'vend',
    'c'
  ),
  (
    1, 4, 'B1',
    'Vous ___ (choisir) le menu du jour ? (2e groupe)',
    'choisis',
    'choisissent',
    'choisiez',
    'choisissez',
    'd'
  ),
  (
    1, 5, 'B1',
    'Je ___ (prendre) le petit-déjeuner à 8 heures. (3e groupe)',
    'prends',
    'prend',
    'prenez',
    'prennent',
    'a'
  ),
  (
    1, 6, 'B2',
    'Nous ___ (réussir) grâce à un travail régulier. (2e groupe, radical en -iss-)',
    'réussions',
    'réussissons',
    'réussons',
    'réussissent',
    'b'
  ),
  (
    1, 7, 'B2',
    'J''___ (offrir) un cadeau à mon ami. (verbe en -ir conjugé comme le 1er groupe)',
    'offris',
    'offres',
    'offre',
    'offrirais',
    'c'
  ),
  (
    1, 8, 'C1',
    'Nous ___ (haïr) l''injustice sous toutes ses formes.',
    'haissons',
    'haïons',
    'hairons',
    'haïssons',
    'd'
  ),
  (
    1, 9, 'C1',
    'Ils ___ (mentir) rarement, mais cette fois c''est évident. (3e groupe en -ir)',
    'mentent',
    'mentissent',
    'mentons',
    'ment',
    'a'
  ),
  (
    1, 10, 'C2',
    'Je ___ (cueillir) des herbes aromatiques dans le jardin.',
    'cueillis',
    'cueille',
    'cueillez',
    'cueiller',
    'b'
  ),

  -- ========================================================================
  -- Point 2 — Présent de l'indicatif
  -- ========================================================================
  (
    2, 1, 'A1',
    'Chaque matin, je ___ (manger) des fruits.',
    'mange',
    'manges',
    'mangeons',
    'mangé',
    'a'
  ),
  (
    2, 2, 'A1',
    'Tu ___ (être) très gentil avec tes amis.',
    'est',
    'es',
    'suis',
    'êtes',
    'b'
  ),
  (
    2, 3, 'A2',
    'Nous ___ (avoir) un examen demain.',
    'avez',
    'ont',
    'avons',
    'avons eu',
    'c'
  ),
  (
    2, 4, 'B1',
    'Ils ___ (venir) souvent le week-end.',
    'viennent pas',
    'venons',
    'vient',
    'viennent',
    'd'
  ),
  (
    2, 5, 'B1',
    'Vous ___ (prendre) le bus ou le métro ?',
    'prenez',
    'prend',
    'prennent',
    'prenons',
    'a'
  ),
  (
    2, 6, 'B2',
    'Elle ___ (aller) à la bibliothèque après les cours.',
    'vais',
    'va',
    'allez',
    'vont',
    'b'
  ),
  (
    2, 7, 'B2',
    'Je ___ (faire) mes devoirs tous les soirs.',
    'fait',
    'faisons',
    'fais',
    'font',
    'c'
  ),
  (
    2, 8, 'C1',
    'Ces chercheurs ___ (acquérir) une expérience précieuse sur le terrain.',
    'acquèrent',
    'acquiert',
    'acquérent',
    'acquièrent',
    'd'
  ),
  (
    2, 9, 'C1',
    'Tu ___ (savoir) vraiment ce que tu veux ?',
    'sais',
    'sait',
    'savons',
    'savez',
    'a'
  ),
  (
    2, 10, 'C2',
    'Nous ___ (résoudre) ce problème étape par étape.',
    'résolons',
    'résolvons',
    'résoudons',
    'résolvions',
    'b'
  ),

  -- ========================================================================
  -- Point 3 — Passé composé vs imparfait
  -- ========================================================================
  (
    3, 1, 'A1',
    'Hier, j''___ (manger) une pizza.',
    'ai mangé',
    'mangeais',
    'mange',
    'avais mangé',
    'a'
  ),
  (
    3, 2, 'A2',
    'Quand j''étais petit, je ___ (jouer) dans le jardin.',
    'ai joué',
    'jouais',
    'joue',
    'avais joué',
    'b'
  ),
  (
    3, 3, 'A2',
    'Elle ___ (aller) au cinéma samedi dernier.',
    'allait',
    'va',
    'est allée',
    'était allée',
    'c'
  ),
  (
    3, 4, 'B1',
    'Il ___ (pleuvoir) quand nous sommes sortis.',
    'a plu',
    'pleut',
    'avait plu',
    'pleuvait',
    'd'
  ),
  (
    3, 5, 'B1',
    'Nous ___ (finir) le rapport avant midi.',
    'avons fini',
    'finissions',
    'finissons',
    'avions fini',
    'a'
  ),
  (
    3, 6, 'B2',
    'Pendant que tu ___ (dormir), le téléphone a sonné.',
    'as dormi',
    'dormais',
    'dors',
    'avais dormi',
    'b'
  ),
  (
    3, 7, 'B2',
    'Ils ___ (découvrir) la vérité ce jour-là.',
    'découvraient',
    'découvrent',
    'ont découvert',
    'avaient découvert',
    'c'
  ),
  (
    3, 8, 'C1',
    'Chaque fois qu''il ___ (venir), il apportait des fleurs.',
    'est venu',
    'vient',
    'était venu',
    'venait',
    'd'
  ),
  (
    3, 9, 'C1',
    'Soudain, quelqu''un ___ (crier) dans la rue.',
    'a crié',
    'criait',
    'crie',
    'avait crié',
    'a'
  ),
  (
    3, 10, 'C2',
    'Alors que la conférence ___ (se dérouler), une panne d''électricité a interrompu tout.',
    's''est déroulée',
    'se déroulait',
    'se déroule',
    's''était déroulée',
    'b'
  ),

  -- ========================================================================
  -- Point 4 — Futur simple et futur proche
  -- ========================================================================
  (
    4, 1, 'A1',
    'Demain, je ___ (aller) au marché. (futur proche)',
    'vais aller',
    'irai',
    'allais',
    'suis allé',
    'a'
  ),
  (
    4, 2, 'A2',
    'Attention ! Tu ___ (tomber) ! (futur proche)',
    'tomberas',
    'vas tomber',
    'tombes',
    'es tombé',
    'b'
  ),
  (
    4, 3, 'A2',
    'L''année prochaine, nous ___ (habiter) à Lyon. (futur simple)',
    'allons habiter',
    'habitions',
    'habiterons',
    'avons habité',
    'c'
  ),
  (
    4, 4, 'B1',
    'Dans dix minutes, le train ___ (partir). (futur simple)',
    'va partir',
    'part',
    'est parti',
    'partira',
    'd'
  ),
  (
    4, 5, 'B1',
    'Ils ___ (venir) nous voir ce soir. (futur proche)',
    'vont venir',
    'viendront',
    'viennent',
    'sont venus',
    'a'
  ),
  (
    4, 6, 'B2',
    'Vous ___ (recevoir) votre réponse sous 48 heures. (futur simple)',
    'allez recevoir',
    'recevrez',
    'recevez',
    'avez reçu',
    'b'
  ),
  (
    4, 7, 'B2',
    'Je ___ (être) disponible après 18 h. (futur simple)',
    'vais être',
    'suis',
    'serai',
    'étais',
    'c'
  ),
  (
    4, 8, 'C1',
    'Dès que tu ___ (arriver), appelle-moi. (futur simple après « dès que »)',
    'arrives',
    'vas arriver',
    'es arrivé',
    'arriveras',
    'd'
  ),
  (
    4, 9, 'C1',
    'Nous ___ (acquérir) de nouvelles compétences grâce à cette formation. (futur simple)',
    'acquerrons',
    'acquérirons',
    'allons acquérir',
    'acquérons',
    'a'
  ),
  (
    4, 10, 'C2',
    'Quand il ___ (savoir) la vérité, il comprendra mieux la situation. (futur simple)',
    'sait',
    'saura',
    'va savoir',
    'a su',
    'b'
  ),

  -- ========================================================================
  -- Point 5 — Plus-que-parfait et passé simple
  -- ========================================================================
  (
    5, 1, 'A2',
    'Quand je suis arrivé, elle ___ déjà (partir).',
    'était partie',
    'a parti',
    'est partie',
    'avait partir',
    'a'
  ),
  (
    5, 2, 'A2',
    'Il ___ (finir) ses études avant de trouver un emploi.',
    'a fini',
    'avait fini',
    'finit',
    'finissait',
    'b'
  ),
  (
    5, 3, 'B1',
    'Nous ___ (manger) quand le facteur a sonné.',
    'avons mangé',
    'mangeâmes',
    'avions mangé',
    'mangions',
    'c'
  ),
  (
    5, 4, 'B1',
    'Dans ce roman, le héros ___ (entrer) dans la salle et salua tout le monde. (passé simple)',
    'est entré',
    'entrait',
    'était entré',
    'entra',
    'd'
  ),
  (
    5, 5, 'B1',
    'Ils ___ (voir) ce film deux fois avant cette séance.',
    'avaient vu',
    'ont vu',
    'virent',
    'voyaient',
    'a'
  ),
  (
    5, 6, 'B2',
    'Elle ___ (prendre) sa décision bien avant la réunion.',
    'a pris',
    'avait pris',
    'prit',
    'prenait',
    'b'
  ),
  (
    5, 7, 'B2',
    'Le roi ___ (ordonner) que l''on ferme les portes. (passé simple)',
    'a ordonné',
    'ordonnait',
    'ordonna',
    'avait ordonné',
    'c'
  ),
  (
    5, 8, 'C1',
    'Il ___ (ouvrir) la lettre, lut les premières lignes, puis sourit. (passé simple)',
    'a ouvert',
    'ouvrait',
    'avait ouvert',
    'ouvrit',
    'd'
  ),
  (
    5, 9, 'C1',
    'Vous ___ (écrire) trois messages avant d''obtenir une réponse.',
    'aviez écrit',
    'avez écrit',
    'écrivîtes',
    'écriviez',
    'a'
  ),
  (
    5, 10, 'C2',
    'Ils ___ (naître) dans un petit village, puis partirent pour la capitale. (passé simple)',
    'sont nés',
    'naquirent',
    'naissaient',
    'étaient nés',
    'b'
  ),

  -- ========================================================================
  -- Point 6 — Impératif
  -- ========================================================================
  (
    6, 1, 'A1',
    '___ (écouter) bien la consigne ! (tutoiement)',
    'Écoute',
    'Écoutes',
    'Écoutez',
    'Écoutons',
    'a'
  ),
  (
    6, 2, 'A1',
    'S''il te plaît, ___ (venir) avec moi.',
    'vient',
    'viens',
    'venez',
    'venir',
    'b'
  ),
  (
    6, 3, 'A2',
    '___ (ne pas oublier) vos papiers ! (vouvoiement)',
    'N''oublie pas',
    'Ne pas oubliez',
    'N''oubliez pas',
    'N''oublies pas',
    'c'
  ),
  (
    6, 4, 'B1',
    '___ (aller) à la page 12, s''il vous plaît.',
    'Va',
    'Allons',
    'Aller',
    'Allez',
    'd'
  ),
  (
    6, 5, 'B1',
    '___ (finir) cet exercice avant de sortir. (tutoiement)',
    'Finis',
    'Fini',
    'Finissez',
    'Finisons',
    'a'
  ),
  (
    6, 6, 'B2',
    '___ (avoir) un peu de patience ! (vouvoiement)',
    'Avez',
    'Ayez',
    'Aie',
    'Ayons',
    'b'
  ),
  (
    6, 7, 'B2',
    '___ (être) prêts pour 8 heures ! (vouvoiement)',
    'Êtes',
    'Sois',
    'Soyez',
    'Soyons',
    'c'
  ),
  (
    6, 8, 'C1',
    '___-en un autre exemplaire, s''il te plaît. (verbe prendre)',
    'Prend',
    'Prenez',
    'Prendre',
    'Prends',
    'd'
  ),
  (
    6, 9, 'C1',
    'Ne ___ (se lever) pas avant la fin du discours. (vouvoiement)',
    'vous levez',
    'te lève',
    'se levez',
    'vous lever',
    'a'
  ),
  (
    6, 10, 'C2',
    '___ (savoir) que cette décision n''est pas définitive. (vouvoiement)',
    'Savez',
    'Sachez',
    'Saches',
    'Sachons',
    'b'
  ),

  -- ========================================================================
  -- Point 7 — Subjonctif présent
  -- ========================================================================
  (
    7, 1, 'A2',
    'Il faut que tu ___ (venir) demain.',
    'viennes',
    'viens',
    'viendras',
    'venais',
    'a'
  ),
  (
    7, 2, 'A2',
    'Je veux que vous ___ (être) à l''heure.',
    'êtes',
    'soyez',
    'serez',
    'étiez',
    'b'
  ),
  (
    7, 3, 'B1',
    'Il est important que nous ___ (finir) ce projet.',
    'finissons',
    'finirons',
    'finissions',
    'avons fini',
    'c'
  ),
  (
    7, 4, 'B1',
    'Bien que je ___ (avoir) peu de temps, je t''aiderai.',
    'ai',
    'aurai',
    'avais',
    'aie',
    'd'
  ),
  (
    7, 5, 'B1',
    'Elle souhaite que son frère ___ (partir) plus tôt.',
    'parte',
    'part',
    'partira',
    'partait',
    'a'
  ),
  (
    7, 6, 'B2',
    'Pourvu qu''il ___ (faire) beau ce week-end !',
    'fait',
    'fasse',
    'fera',
    'faisait',
    'b'
  ),
  (
    7, 7, 'B2',
    'Je doute qu''ils ___ (pouvoir) réussir sans aide.',
    'peuvent',
    'pourront',
    'puissent',
    'pouvaient',
    'c'
  ),
  (
    7, 8, 'C1',
    'Il est nécessaire que l''on ___ (prendre) des mesures immédiates.',
    'prend',
    'prendra',
    'prenait',
    'prenne',
    'd'
  ),
  (
    7, 9, 'C1',
    'Quoique vous ___ (dire), la décision est déjà prise.',
    'disiez',
    'dites',
    'direz',
    'disiez pas',
    'a'
  ),
  (
    7, 10, 'C2',
    'Il convient que chacun ___ (savoir) exactement son rôle.',
    'sait',
    'sache',
    'saura',
    'savait',
    'b'
  ),

  -- ========================================================================
  -- Point 8 — Conditionnel présent et passé
  -- ========================================================================
  (
    8, 1, 'A2',
    'Si j''avais le temps, je ___ (voyager) plus.',
    'voyagerais',
    'voyage',
    'voyagerai',
    'ai voyagé',
    'a'
  ),
  (
    8, 2, 'A2',
    'Tu ___ (pouvoir) m''aider, s''il te plaît ? (demande polie)',
    'peux',
    'pourrais',
    'pourras',
    'as pu',
    'b'
  ),
  (
    8, 3, 'B1',
    'Nous ___ (aimer) visiter ce musée un jour.',
    'aimons',
    'aimerons',
    'aimerions',
    'avons aimé',
    'c'
  ),
  (
    8, 4, 'B1',
    'S''il avait su, il ___ (venir) plus tôt. (conditionnel passé)',
    'viendrait',
    'est venu',
    'venait',
    'serait venu',
    'd'
  ),
  (
    8, 5, 'B1',
    'Vous ___ (devoir) vérifier vos sources avant de publier.',
    'devriez',
    'devez',
    'devrez',
    'avez dû',
    'a'
  ),
  (
    8, 6, 'B2',
    'Sans ton aide, je n''___ jamais ___ (réussir). (conditionnel passé)',
    'ai / réussi',
    'aurais / réussi',
    'réussirais /',
    'avais / réussi',
    'b'
  ),
  (
    8, 7, 'B2',
    'Ils ___ (être) ravis de participer à l''atelier.',
    'sont',
    'seront',
    'seraient',
    'étaient',
    'c'
  ),
  (
    8, 8, 'C1',
    'Si elle avait écouté les conseils, elle ___ (éviter) cette erreur. (conditionnel passé)',
    'éviterait',
    'a évité',
    'évitait',
    'aurait évité',
    'd'
  ),
  (
    8, 9, 'C1',
    'On ___ (croire) qu''il connaissait déjà la réponse.',
    'croirait',
    'croit',
    'croira',
    'a cru',
    'a'
  ),
  (
    8, 10, 'C2',
    'À ta place, j''___ (faire) autrement dès le début. (conditionnel passé)',
    'ferais',
    'aurais fait',
    'ai fait',
    'faisais',
    'b'
  ),

  -- ========================================================================
  -- Point 9 — Participe présent et gérondif
  -- ========================================================================
  (
    9, 1, 'A2',
    'Il est sorti en ___ (chanter).',
    'chantant',
    'chanté',
    'chanter',
    'chante',
    'a'
  ),
  (
    9, 2, 'A2',
    '___ (lire) ce livre, j''ai beaucoup appris. (participe présent)',
    'Lu',
    'Lisant',
    'Lire',
    'Lis',
    'b'
  ),
  (
    9, 3, 'B1',
    'Elle prépare le dîner en ___ (écouter) la radio.',
    'écouté',
    'écouter',
    'écoutant',
    'écoute',
    'c'
  ),
  (
    9, 4, 'B1',
    'Les personnes ___ (vivre) ici connaissent bien le quartier. (participe présent)',
    'vécu',
    'vivre',
    'vivent',
    'vivant',
    'd'
  ),
  (
    9, 5, 'B1',
    'Il a réussi en ___ (travailler) régulièrement.',
    'travaillant',
    'travaillé',
    'travailler',
    'travaille',
    'a'
  ),
  (
    9, 6, 'B2',
    '___ (savoir) la vérité, elle a changé d''avis. (participe présent)',
    'Su',
    'Sachant',
    'Savoir',
    'Sait',
    'b'
  ),
  (
    9, 7, 'B2',
    'Nous progressons en ___ (pratiquer) chaque jour.',
    'pratiqué',
    'pratiquer',
    'pratiquant',
    'pratiquons',
    'c'
  ),
  (
    9, 8, 'C1',
    '___ (avoir) peu de moyens, ils ont tout de même organisé l''événement. (participe présent)',
    'Eu',
    'Avoir',
    'Ont',
    'Ayant',
    'd'
  ),
  (
    9, 9, 'C1',
    'Il s''est blessé en ___ (courir) trop vite.',
    'courant',
    'couru',
    'courir',
    'court',
    'a'
  ),
  (
    9, 10, 'C2',
    'Les arguments ___ (convaincre) le jury étaient particulièrement solides. (participe présent)',
    'convaincu',
    'convainquant',
    'convaincre',
    'convainquent',
    'b'
  ),

  -- ========================================================================
  -- Point 10 — Accord du participe passé
  -- ========================================================================
  (
    10, 1, 'A2',
    'Elle est ___ (allé) au marché.',
    'allée',
    'allé',
    'allés',
    'allées',
    'a'
  ),
  (
    10, 2, 'A2',
    'Ils sont ___ (parti) très tôt.',
    'parti',
    'partis',
    'partie',
    'parties',
    'b'
  ),
  (
    10, 3, 'B1',
    'La lettre que j''ai ___ (écrire) est sur le bureau.',
    'écrit',
    'écrits',
    'écrite',
    'écrites',
    'c'
  ),
  (
    10, 4, 'B1',
    'Les pommes que nous avons ___ (acheter) sont délicieuses.',
    'acheté',
    'achetés',
    'achetée',
    'achetées',
    'd'
  ),
  (
    10, 5, 'B1',
    'Elle s''est ___ (laver) les mains. (COD = les mains)',
    'lavé',
    'lavée',
    'lavés',
    'lavées',
    'a'
  ),
  (
    10, 6, 'B2',
    'Les décisions qu''ils ont ___ (prendre) sont contestées.',
    'pris',
    'prises',
    'prise',
    'prisses',
    'b'
  ),
  (
    10, 7, 'B2',
    'Elle s''est ___ (souvenir) de mon anniversaire.',
    'souvenu',
    'souvenus',
    'souvenue',
    'souvenues',
    'c'
  ),
  (
    10, 8, 'C1',
    'La chanson que tu as ___ (entendre) hier passait à la radio.',
    'entendu',
    'entendus',
    'entendues',
    'entendue',
    'd'
  ),
  (
    10, 9, 'C1',
    'Ils se sont ___ (écrire) de longues lettres. (COD = de longues lettres)',
    'écrit',
    'écrits',
    'écrite',
    'écrites',
    'a'
  ),
  (
    10, 10, 'C2',
    'Les efforts qu''elle s''est ___ (imposer) ont fini par payer.',
    'imposé',
    'imposés',
    'imposée',
    'imposées',
    'b'
  ),

  -- ========================================================================
  -- Point 11 — Voix passive
  -- ========================================================================
  (
    11, 1, 'A2',
    'Ce livre ___ (écrire) par une auteure canadienne. (présent passif)',
    'est écrit',
    'écrit',
    'a écrit',
    'est écrire',
    'a'
  ),
  (
    11, 2, 'A2',
    'La porte ___ (fermer) chaque soir à 21 h. (présent passif)',
    'ferme',
    'est fermée',
    'a fermé',
    'est fermer',
    'b'
  ),
  (
    11, 3, 'B1',
    'Les résultats ___ (publier) hier. (passé composé passif)',
    'sont publiés',
    'ont publié',
    'ont été publiés',
    'étaient publiés',
    'c'
  ),
  (
    11, 4, 'B1',
    'Cette décision ___ (prendre) par le comité. (passé composé passif)',
    'est prise',
    'a pris',
    'était prise',
    'a été prise',
    'd'
  ),
  (
    11, 5, 'B1',
    'Les documents ___ (envoyer) demain. (futur passif)',
    'seront envoyés',
    'sont envoyés',
    'enverront',
    'ont été envoyés',
    'a'
  ),
  (
    11, 6, 'B2',
    'Le bâtiment ___ (construire) en 1920. (passé composé passif)',
    'est construit',
    'a été construit',
    'a construit',
    'était construit',
    'b'
  ),
  (
    11, 7, 'B2',
    'Ces règles ___ (respecter) par tous les participants. (présent passif)',
    'respectent',
    'ont respecté',
    'sont respectées',
    'sont respecter',
    'c'
  ),
  (
    11, 8, 'C1',
    'La proposition ___ (rejeter) à l''unanimité. (passé composé passif)',
    'est rejetée',
    'a rejeté',
    'était rejetée',
    'a été rejetée',
    'd'
  ),
  (
    11, 9, 'C1',
    'On dit que le tableau ___ (voler) pendant la nuit. (passé composé passif)',
    'a été volé',
    'est volé',
    'a volé',
    'était volé',
    'a'
  ),
  (
    11, 10, 'C2',
    'Si les mesures ___ (appliquer) plus tôt, la crise aurait été limitée. (plus-que-parfait passif)',
    'étaient appliquées',
    'avaient été appliquées',
    'ont été appliquées',
    'seraient appliquées',
    'b'
  ),

  -- ========================================================================
  -- Point 12 — Concordance des temps au discours indirect
  -- ========================================================================
  (
    12, 1, 'A2',
    'Il a dit : « Je suis fatigué. » → Il a dit qu''il ___ fatigué.',
    'était',
    'est',
    'sera',
    'soit',
    'a'
  ),
  (
    12, 2, 'A2',
    'Elle a dit : « Je viendrai demain. » → Elle a dit qu''elle ___ le lendemain.',
    'viendra',
    'viendrait',
    'vient',
    'venait',
    'b'
  ),
  (
    12, 3, 'B1',
    'Ils ont affirmé : « Nous avons fini. » → Ils ont affirmé qu''ils ___ .',
    'ont fini',
    'finissaient',
    'avaient fini',
    'finiraient',
    'c'
  ),
  (
    12, 4, 'B1',
    'Tu m''as demandé : « Où habites-tu ? » → Tu m''as demandé où j''___ .',
    'habite',
    'habiterai',
    'habiteais',
    'habitais',
    'd'
  ),
  (
    12, 5, 'B1',
    'Il a promis : « Je t''appellerai. » → Il a promis qu''il m''___ .',
    'appellerait',
    'appellera',
    'appelle',
    'appelait',
    'a'
  ),
  (
    12, 6, 'B2',
    'Elle a dit : « Je faisais mes devoirs. » → Elle a dit qu''elle ___ ses devoirs.',
    'a fait',
    'faisait',
    'ferait',
    'fasse',
    'b'
  ),
  (
    12, 7, 'B2',
    'Le guide a expliqué : « Visitez la salle suivante. » → Le guide a expliqué qu''il ___ visiter la salle suivante.',
    'faut',
    'faudra',
    'fallait',
    'fallût',
    'c'
  ),
  (
    12, 8, 'C1',
    'Il a déclaré : « Je partirai dès que j''aurai terminé. » → Il a déclaré qu''il ___ dès qu''il ___ terminé.',
    'partira / aura',
    'partait / avait',
    'parte / ait',
    'partirait / aurait',
    'd'
  ),
  (
    12, 9, 'C1',
    'Elle a dit : « Si j''avais su, je serais venue. » → Elle a dit que si elle ___ , elle ___ .',
    'avait su / serait venue',
    'aurait su / serait venue',
    'savait / venait',
    'a su / est venue',
    'a'
  ),
  (
    12, 10, 'C2',
    'Ils ont soutenu : « Nous ne pouvons pas accepter cette condition. » → Ils ont soutenu qu''ils ___ pas accepter cette condition.',
    'ne peuvent',
    'ne pouvaient',
    'ne pourraient',
    'n''avaient pu',
    'b'
  )
) AS v(
  point_numero,
  ordre,
  niveau,
  question_texte,
  choix_a,
  choix_b,
  choix_c,
  choix_d,
  bonne_reponse
) ON v.point_numero = p.numero
WHERE u.numero = 1
  AND NOT EXISTS (
    SELECT 1
    FROM public.revision_questions q
    WHERE q.point_id = p.id
      AND q.ordre = v.ordre
  );

NOTIFY pgrst, 'reload schema';
