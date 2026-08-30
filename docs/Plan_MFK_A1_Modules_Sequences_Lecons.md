# Plan MFK — Modules, séquences et leçons (A1)

Document de génération pour l’espace enseignant MFK (Next.js + Supabase).
Hiérarchie réelle en base (`public`, tables `elearning_*`) :

- **9 modules** (`cefr_level = A1`) = les 9 grandes étapes
- **4 à 6 séquences** par module = les sous-thèmes (titre + thème + point de langue)
- **5 leçons** par séquence = CO, CE, PO, PE, EL
- **10 exercices** par leçon

Aucune table nouvelle. Plafond UI enseignant : **6 séquences** par module.

---

## Principe anti-copyright (obligatoire)

Tout le contenu seedé est **original MFK**. Il est interdit de :

- reprendre une mise en scène, un dialogue, une fiche ou un personnage d’une méthode existante (Alter Ego, Édito, Cosmopolite, Tempo, Ensemble, etc.) ;
- copier un texte, un enregistrement ou une consigne publiés ;
- calquer un « premier jour à l’école de langues » / accueil / fiche d’inscription type manuel.

À la place :

- inventer un **micro-monde** (lieux, personnages, documents) propre à MFK ;
- rédiger des dialogues, affiches, messages, listes et fiches **nouveaux** ;
- rester au niveau A1, ancré dans un quotidien est-africain francophone plausible.

Les personnages, lieux et papiers du Module 1 appartiennent au kiosque-bibliothèque de quartier **« La Colline »** (Kimisagara, Kigali) : Inès Kalisa, Yvan Bizimana, Sonia Mukeshimana, Didier Ndayisaba, Noël Iradukunda. Rien n’est emprunté à une méthode.

---

## Règle des 10 exercices par leçon

Chaque leçon a **exactement 10 exercices** (`order_index` 0 à 9), un de **chaque** type déjà supporté par `elearning_exercises` :

| `order_index` | `exercise_type` | Rôle pédagogique |
| --- | --- | --- |
| 0 | `true_false` | Repérage global |
| 1 | `qcm` | Compréhension ciblée |
| 2 | `matching` | Associer forme / sens |
| 3 | `fill_blank` | Forme attendue |
| 4 | `word_order` | Ordre des mots |
| 5 | `anagram` | Orthographe d’un mot-clé |
| 6 | `find_error` | Correction d’une forme |
| 7 | `image_match` | Associer image et mot (pictogrammes originaux MFK) |
| 8 | `short_answer` | Production courte (correction enseignant) |
| 9 | `audio_record` | Production orale (correction enseignant) |

Les 10 types sont toujours présents, y compris en CO / CE / EL : la compétence de la leçon oriente le **support** (`content`), pas la liste des types.

`image_match` pointe vers des SVG originaux servis par l’app (`/elearning/mfk-a1/…`), pas vers des images d’un éditeur.

---

## Gabarit d’une leçon

`elearning_lessons.content` (`content_type = text`) :

```
Objectif
<phrase A1 liée au point de langue de LA séquence>

Consigne
<ce que l’apprenant doit faire>

Support
<dialogue / document / modèle / fiche — originaux, personnages de La Colline>
```

Ordre des leçons dans la séquence :

| `order_index` | `competency` | Support |
| --- | --- | --- |
| 0 | `CO` | Script d’écoute inventé |
| 1 | `CE` | Document écrit inventé |
| 2 | `PO` | Phrases modèles |
| 3 | `PE` | Modèle écrit |
| 4 | `EL` | Fiche du point de langue de la séquence |

---

## Module 1 — A1 — Premiers repères *(à valider)*

| Champ | Valeur |
| --- | --- |
| Titre | A1 — Premiers repères |
| `cefr_level` | A1 |
| Micro-monde | Kiosque-bibliothèque « La Colline », Kimisagara |

| # | Séquence | Thème | Point de langue |
| --- | --- | --- | --- |
| 1.1 | Bienvenue en français | Saluer, se présenter, prendre congé | Formules de politesse ; tutoiement / vouvoiement ; `s’appeler` ; `je` / `tu` / `vous` ; `c’est` |
| 1.2 | Se compter et s’organiser | Nombres, âge, jours | Nombres 0–20 ; `j’ai … ans` ; jours de la semaine ; `c’est lundi` |
| 1.3 | Le monde en français | Pays, nationalités, langues | `être` + nationalité ; `d’où viens-tu ?` ; `je parle` ; `de` / `du` / `en` |
| 1.4 | Vivre en classe | Consignes et objets | Impératif (`écoutez`, `répétez`) ; `un` / `une` ; `je ne comprends pas` |

Seed : `supabase/migrations/20260814120000_elearning_mfk_a1_module1_premiers_reperes.sql`

---

## Module 3 — A1 — S'orienter et s'installer

| Champ | Valeur |
| --- | --- |
| Titre | A1 — S'orienter et s'installer |
| `cefr_level` | A1 |
| Micro-monde | Cour d'accueil « Le Seuil des Sources », Rukiri-Nord (quartier inventé) |
| Personnages | Aline Uwase, Patrick Habimana, Léa Niyonzima, Marc Nkurunziza, Hawa Diallo, Joël Mugisha |

| # | Séquence | Thème | Point de langue |
| --- | --- | --- | --- |
| 3.1 | Explorer une nouvelle ville | Lieux du quartier | `c'est` / `il y a` ; `où est… ?` ; `près de` / `loin de` / `à côté de` / `en face de` |
| 3.2 | Suivre un guide | Itinéraire à pied | Impératif (`allez`, `tournez`, `prenez`, `continuez`) ; `à gauche` / `à droite` / `tout droit` |
| 3.3 | Se déplacer en week-end | Transports et horaires | `je vais à` / `je viens de` ; `je prends` ; `à` + heure ; samedi / dimanche |
| 3.4 | Aller vers l'autre | Demander son chemin | `Excusez-moi` ; `Pour aller à… ?` ; `Pouvez-vous m'aider ?` ; `merci` / `de rien` |
| 3.5 | Trouver un toit | Chambre et loyer | `il y a` / `il n'y a pas` ; `libre` / `occupé` ; `Combien ça coûte ?` |
| 3.6 | Sur la route | Trajet et prudence | `avant` / `après` ; `attention` ; `lentement` ; `on prend la route de` |

Seed : `supabase/migrations/20260823190000_elearning_mfk_a1_module3_orienter_installer.sql`  
Illustrations : `/elearning/mfk-a1-m3/` (style carte-cour, terracotta / sarcelle).  
Relecture : `docs/Relecture_MFK_A1_Module3.md`

---

## Module 4 — A1 — Portraits croisés

| Champ | Valeur |
| --- | --- |
| Titre | A1 — Portraits croisés |
| `cefr_level` | A1 |
| Micro-monde | Cour « Le Seuil des Sources », Rukiri-Nord — album de portraits sous le figuier |
| Personnages | Aline Uwase, Patrick Habimana, Léa Niyonzima, Marc Nkurunziza, Hawa Diallo, Joël Mugisha, Rose Iradukunda ; familles : Claire Mukamana, Éric et Nina Uwase, Mireille Niyonzima, Fatou Diallo, Kévin Nkurunziza |

| # | Séquence | Thème | Point de langue |
| --- | --- | --- | --- |
| 4.1 | En famille | Présenter les siens | Possessifs `ma` / `mon` / `mes` ; mère, père, frère, sœur, tante, oncle ; `j'ai` / `c'est` |
| 4.2 | Se ressembler, se distinguer | Décrire et comparer | `il` / `elle est` + adjectif ; `il` / `elle a` ; `aussi` / `mais` |
| 4.3 | Ce qu'on aime, ce qu'on n'aime pas | Goûts | `j'aime` / `j'adore` / `je n'aime pas` |
| 4.4 | Se raconter en quelques mots | Mini-portrait | `je m'appelle`, `j'ai … ans`, `j'habite`, `je suis` |
| 4.5 | Temps libre | Week-end | Samedi / dimanche ; `jouer au` ; écouter, lire, danser, jardiner, se reposer |
| 4.6 | Quand le corps parle | Corps et sensations | Tête, main, pied, dos ; `j'ai mal à` / `au` ; fatigué(e), content(e) |

Seed : `supabase/migrations/20260823210000_elearning_mfk_a1_module4_portraits_croises.sql`  
Illustrations : `/elearning/mfk-a1-m4/` (style album, rose / terracotta / sarcelle).  
Relecture : `docs/Relecture_MFK_A1_Module4.md`

---

## Module 5 — A1 — Le fil des journées

| Champ | Valeur |
| --- | --- |
| Titre | A1 — Le fil des journées |
| `cefr_level` | A1 |
| Micro-monde | Cour « Le Seuil des Sources », Rukiri-Nord — fil des heures sous le figuier ; Salle des Herbes ; Marché des Lampions ; Radio Figuier |
| Personnages | Aline Uwase, Patrick Habimana, Léa Niyonzima, Marc Nkurunziza, Hawa Diallo, Joël Mugisha, Rose Iradukunda, Kévin Nkurunziza |

| # | Séquence | Thème | Point de langue |
| --- | --- | --- | --- |
| 5.1 | Une journée dans le monde | Indiquer l'heure et les horaires | `Quelle heure est-il ?` ; `il est` + heure ; `à` + heure ; `du matin` / `de l'après-midi` / `du soir` ; midi / minuit |
| 5.2 | Rythmes de vie | Activités et habitudes quotidiennes | `je me lève` / `je me couche` ; `le matin` / `l'après-midi` / `le soir` ; `d'habitude` / `parfois` |
| 5.3 | Nos habitudes partagées | Routines du groupe | `on` + verbe ; `tous les jours` ; `d'habitude` ; `parfois` ; le samedi / le dimanche |
| 5.4 | Une journée de travail | Horaires de travail | `je travaille` ; `je commence à` ; `je finis à` ; pause |
| 5.5 | Sortir à sa façon | S'informer sur les sorties | `je sors` ; `je vais à` / `au` / `à la` ; `ce soir` / `demain` |
| 5.6 | Organiser une rencontre | Inviter, accepter, refuser | `Tu veux… ?` ; `avec plaisir` ; `d'accord` ; `je ne peux pas` ; `désolé(e)` |

Seed : `supabase/migrations/20260827120000_elearning_mfk_a1_module5_fil_journees.sql`  
Illustrations : `/elearning/mfk-a1-m5/` (style fil des heures, ocre / terracotta / sarcelle).  
Relecture : `docs/Relecture_MFK_A1_Module5.md`

---

## Module 6 — A1 — Histoires vécues

| Champ | Valeur |
| --- | --- |
| Titre | A1 — Histoires vécues |
| `cefr_level` | A1 |
| Micro-monde | Cour « Le Seuil des Sources », Rukiri-Nord — cahier des histoires sous le figuier ; Feuille du Seuil ; Infirmerie des Herbes ; Salle des Herbes |
| Personnages | Aline, Patrick, Léa, Marc, Hawa, Joël, Rose, Kévin ; figures inventées : Mado Karekezi (plume), Sami Niyonteze (tambour), Benoît Habumuremyi (course), Yvette Mukeshimana (infirmerie) |

| # | Séquence | Thème | Point de langue |
| --- | --- | --- | --- |
| 6.1 | Apprendre à sa manière | Raconter des événements passés | Passé composé avec *avoir* (`j'ai écouté`, `lu`, `écrit`, `appris`) ; `hier` |
| 6.2 | Jeunes talents | Expériences récentes et projets | Passé récent `venir de` + infinitif ; futur proche `aller` + infinitif |
| 6.3 | Plumes francophones | Informations biographiques | `être né(e)` ; `avoir écrit` ; `habiter` / `parler` ; futur proche |
| 6.4 | Portrait d'un jour | Description physique + un événement | `il/elle est` ; `il/elle a` ; `être arrivé(e)` (accord) |
| 6.5 | Un choix de vie | Passé et présent | `avant` + passé composé ; `maintenant` + présent ; `j'ai choisi` |
| 6.6 | S'informer pour avancer | Conseils | Impératif (`écoutez`, `lisez`) ; `il faut` + inf. ; `on peut` + inf. |

Seed : `supabase/migrations/20260827140000_elearning_mfk_a1_module6_histoires_vecues.sql`  
Illustrations : `/elearning/mfk-a1-m6/` (style cahier, prune / terracotta / sarcelle).  
Relecture : `docs/Relecture_MFK_A1_Module6.md`

---

## Module 7 — A1 — Cap sur ailleurs

| Champ | Valeur |
| --- | --- |
| Titre | A1 — Cap sur ailleurs |
| `cefr_level` | A1 |
| Micro-monde | Cour « Le Seuil des Sources », Rukiri-Nord — carnet de route sous le figuier ; destinations inventées : lac des Nénuphars, Port de la Brise, Île de Sable-Rouge, Mwezi-Haut, Rive d'Orage, Auberge des Figues |
| Personnages | Aline, Patrick, Léa, Marc, Hawa, Joël ; figures inventées : Noura Sarr, Ibrahim Tchami (bateau), Mado Karekezi (carnet) |

| # | Séquence | Thème | Point de langue |
| --- | --- | --- | --- |
| 7.1 | Envie de partir | Dire un projet de départ | Futur simple `je partirai` / `tu seras` / `j'aurai` ; `il faut` + nom ou infinitif (toujours 3e pers. du singulier) |
| 7.2 | Voyager autrement | Moyens de voyage | `je prendrai` ; `je ferai` (un r) ; `on pourra` (deux r) ; `il faudra` |
| 7.3 | Un tour d'horizon | Lieux et directions | `nous visiterons` ; `j'irai` / `nous irons` ; `il y aura` ; nord / sud / est / ouest |
| 7.4 | Un point de chute | Hébergement | `je resterai` ; `nous arriverons` / `on arrivera` ; `je rentrerai` ; `il faudra` + nom ou infinitif |
| 7.5 | Choisir sa saison | Temps et saisons | `il fera` (chaud / frais / froid) ; `il pleuvra` ; saison sèche / des pluies / fraîche ; printemps, été, automne, hiver |
| 7.6 | Carnets de route | Noter le voyage | `j'écrirai` ; `je serai` / `nous serons` ; `nous lirons` ; `nous raconterons` ; `il faudra` une ligne |

Seed : `supabase/migrations/20260827160000_elearning_mfk_a1_module7_cap_ailleurs.sql`  
Illustrations : `/elearning/mfk-a1-m7/` (style carte-boussole, bleu mer / terracotta / sarcelle).  
Relecture : `docs/Relecture_MFK_A1_Module7.md`

---

## Module 8 — A1 — Gestes du quotidien

| Champ | Valeur |
| --- | --- |
| Titre | A1 — Gestes du quotidien |
| `cefr_level` | A1 |
| Micro-monde | Cour « Le Seuil des Sources », Rukiri-Nord — Table des Sources ; Marché des Lampions ; Atelier du Tissu |
| Personnages | Aline, Patrick, Léa, Marc, Hawa, Joël, Rose ; figures inventées : Félicie Ndayishimiye (table), Dieudonné Hakizimana (tissu) |

| # | Séquence | Thème | Point de langue |
| --- | --- | --- | --- |
| 8.1 | La table du Seuil | Menu et goûts | Partitifs `du` / `de la` / `de l'` / `des` ; `pas de` ; `j'aime` + article défini |
| 8.2 | Courses au marché | Quantités | `je voudrais` ; `un kilo de` / `une bouteille d'` / `un pot de` / `un morceau de` |
| 8.3 | On compare | Comparer | `plus` / `moins` / `aussi` … `que` ; `plus de` / `moins de` ; `je vais le prendre` |
| 8.4 | Autrefois, maintenant | Évolution | Imparfait (`j'étais`, `j'avais`, `je voulais`, `on mangeait`) ; présent pour *maintenant* |
| 8.5 | S'habiller à la cour | Vêtements | `ce` / `cette` / `ces` ; couleurs (`bleue`, `verte`) ; trop / assez |
| 8.6 | Dire son avis | Appréciation | `vraiment` / `assez` / `trop` + adj. ; `j'aime bien` ; `je n'aime pas trop` ; `ce n'est pas mal` |

Seed : `supabase/migrations/20260829120000_elearning_mfk_a1_module8_gestes_quotidien.sql`  
Illustrations : `/elearning/mfk-a1-m8/` (style table-marché, sage / terracotta / sarcelle).  
Relecture : `docs/Relecture_MFK_A1_Module8.md`

---

## Module 9 — A1 — Retour sur le chemin parcouru

| Champ | Valeur |
| --- | --- |
| Titre | A1 — Retour sur le chemin parcouru |
| `cefr_level` | A1 |
| Micro-monde | Cour « Le Seuil des Sources », Rukiri-Nord — Cahier du chemin sous le figuier |
| Personnages | Aline, Patrick, Léa, Marc, Hawa, Joël, Noura ; la cour au complet pour le bilan |

| # | Séquence | Thème | Point de langue |
| --- | --- | --- | --- |
| 9.1 | Premiers pas | Se présenter à nouveau | `je m'appelle` ; `j'habite` ; `je suis` ; `j'ai … ans` ; `enchanté(e)` |
| 9.2 | Ce que j'ai appris | Bilan au passé | Passé composé *avoir* (`j'ai appris`, `lu`, `écrit`) ; *être* (`je suis arrivé(e)`) |
| 9.3 | Je sais le faire | Savoir-faire | `je peux` / `je sais` / `on peut` + infinitif ; `il faut` + infinitif |
| 9.4 | Ce qui a changé | Évolution | Avant + imparfait ; maintenant + présent |
| 9.5 | La suite du chemin | Projet | Futur simple `je serai` / `j'aurai` / `je ferai` / `on pourra` ; `il faut` / `il faudra` |
| 9.6 | Une page pour la route | Clôture | `merci` ; `content(e)` ; `nous raconterons` ; `on se verra` ; `à bientôt` |

Seed : `supabase/migrations/20260829140000_elearning_mfk_a1_module9_chemin_parcouru.sql`  
Illustrations : `/elearning/mfk-a1-m9/` (style chemin-borne, ocre / terracotta / sarcelle).  
Relecture : `docs/Relecture_MFK_A1_Module9.md`

---

## Module 2 *(non seedé)*

| # | Module | Séquences |
| --- | --- | --- |
| 2 | A1 — Faire connaissance | 4 à 6 séquences |

Même gabarit : 5 leçons × 10 exercices, personnages et documents inventés, pas de copie de méthode.

---

# Plan MFK — Niveau A2 (8 modules)

Même architecture que les modules A1 seedés (tables `elearning_*`, 6 séquences × 5 leçons × 10 exercices, `published = false`).  
Micro-monde : cour « Le Seuil des Sources », Rukiri-Nord. Les personnages A1 évoluent (escale à Val-des-Peupliers, offres à l'atelier / à la radio, engagement pour le figuier).  
Cosmopolite 2 n'est utilisé qu'à titre d'objectifs génériques (communication, grammaire, lexique) : aucun texte, lieu réel, personnage ou mise en situation du manuel.

Personnages : Aline Uwase, Patrick Habimana, Léa Niyonzima, Marc Nkurunziza, Hawa Diallo, Joël Mugisha, Rose Iradukunda ; figures A2 : Solange Mukamana, Karim Bamba, Lila Sow.  
Lieux inventés ajoutés : Bureau des Escales, Maison des Vents, Val-des-Peupliers.

Relecture consolidée : `docs/Relecture_MFK_A2_Modules1-8.md`

## Module A2-1 — Escale en France

| Champ | Valeur |
| --- | --- |
| Titre | A2 — Escale en France |
| `cefr_level` | A2 |

| # | Séquence | Point de langue |
| --- | --- | --- |
| 1.1 | Comparer des séjours | Comparatifs (`plus` / `moins` / `aussi` … `que`, `meilleur`) |
| 1.2 | Premières démarches | Pronoms `y` et `en` |
| 1.3 | Organiser un déplacement | Pronoms COD / COI, synthèse |
| 1.4 | Trouver un logement | Impératif ; `devoir` / `il faut` + infinitif ; négation renforcée |
| 1.5 | Un lieu pas comme les autres | Adverbes et locutions de lieu |
| 1.6 | Suivre un itinéraire | Relatifs `qui` / `que` / `à qui` / `avec qui` |

Seed : `supabase/migrations/20260829180000_elearning_mfk_a2_module1_escale_france.sql`  
Illustrations : `/elearning/mfk-a2-m1/`

## Module A2-2 — Aventures partagées

| Titre | A2 — Aventures partagées |

| # | Séquence | Point de langue |
| --- | --- | --- |
| 2.1 | Une expérience à raconter | Accord du participe passé avec *être* |
| 2.2 | Règles et conseils | Obligation / interdiction ; subjonctif présent (intro) |
| 2.3 | Émotions et souvenirs | Passé composé / imparfait pour raconter |
| 2.4 | Un week-end à thème | Mise en relief `c'est… qui` / `c'est… que` |
| 2.5 | Partir à l'aventure | Genre des noms |
| 2.6 | Le fil de mon parcours | `il y a`, `pendant`, `depuis`, `dans` |

Seed : `supabase/migrations/20260829180100_elearning_mfk_a2_module2_aventures_partagees.sql`  
Illustrations : `/elearning/mfk-a2-m2/`

## Module A2-3 — Un métier en français

| Titre | A2 — Un métier en français |

| # | Séquence | Point de langue |
| --- | --- | --- |
| 3.1 | Une offre à saisir | Compétences et qualités professionnelles |
| 3.2 | Se présenter professionnellement | Articulateurs du discours |
| 3.3 | Proposer un service | Adverbes en `-ment` (réguliers / irréguliers) |
| 3.4 | Oser un choix | Hypothèse avec `si` + présent |
| 3.5 | Un parcours à raconter | Plus-que-parfait |
| 3.6 | Répondre avec assurance | Interrogation formelle ; adjectifs indéfinis |

Seed : `supabase/migrations/20260829180200_elearning_mfk_a2_module3_metier_francais.sql`  
Illustrations : `/elearning/mfk-a2-m3/`

## Module A2-4 — Cultures en partage

| Titre | A2 — Cultures en partage |

| # | Séquence | Point de langue |
| --- | --- | --- |
| 4.1 | Précisions et nuances | Place de l'adverbe |
| 4.2 | Un événement à raconter | `ce qui` / `ce que` … `c'est` |
| 4.3 | Une enquête à mener | `lequel` / `laquelle` / `lesquels` / `lesquelles` |
| 4.4 | Faire une appréciation | Superlatif |
| 4.5 | Demander des explications | Interrogation formelle inversée |
| 4.6 | Souhaits et conseils | Conditionnel présent |

Seed : `supabase/migrations/20260829180300_elearning_mfk_a2_module4_cultures_partage.sql`  
Illustrations : `/elearning/mfk-a2-m4/`

## Module A2-5 — Vivre ensemble autrement

| Titre | A2 — Vivre ensemble autrement |

| # | Séquence | Point de langue |
| --- | --- | --- |
| 5.1 | Portraits croisés | `c'est` / `ce sont` + relative |
| 5.2 | Ce qu'on m'a dit | Discours indirect au présent |
| 5.3 | D'accord, pas d'accord | Relatifs `où` / `dont` |
| 5.4 | Vivre ensemble | Demander / donner un avis |
| 5.5 | Convaincre en douceur | Démonstratifs `celui` / `celle` / `ceux` / `celles` |
| 5.6 | Un état d'esprit | Présent continu, futur proche, passé récent |

Seed : `supabase/migrations/20260829180400_elearning_mfk_a2_module5_vivre_ensemble.sql`  
Illustrations : `/elearning/mfk-a2-m5/`

## Module A2-6 — Petits gestes, grand quotidien

| Titre | A2 — Petits gestes, grand quotidien |

| # | Séquence | Point de langue |
| --- | --- | --- |
| 6.1 | Instructions du jour | Verbes en `-cer` / `-ger` / `-yer` / `-ayer` |
| 6.2 | Une recette à rédiger | Verbes prépositionnels (`essayer de`, `réussir à`…) |
| 6.3 | Un mode d'emploi | `si` + imparfait ; pronoms indéfinis |
| 6.4 | Une réussite à raconter | Accord du participe passé avec *avoir* |
| 6.5 | Prendre soin de soi | Pronoms possessifs |
| 6.6 | Une suite d'actions | `avant de` / `après` + infinitif ; marqueurs temporels |

Seed : `supabase/migrations/20260829180500_elearning_mfk_a2_module6_petits_gestes.sql`  
Illustrations : `/elearning/mfk-a2-m6/`

## Module A2-7 — Mémoire et engagement

| Titre | A2 — Mémoire et engagement |

| # | Séquence | Point de langue |
| --- | --- | --- |
| 7.1 | Un récit à comprendre | PC / imparfait / plus-que-parfait (synthèse) |
| 7.2 | Un souvenir à raconter | Moment précis et durée |
| 7.3 | Une suite de faits | Prépositions et marqueurs temporels (synthèse) |
| 7.4 | Une cause à défendre | Cause et conséquence |
| 7.5 | Agir pour la nature | Adjectif + `à` / `de` |
| 7.6 | Donner son avis | `de plus en plus` / `de moins en moins` |

Seed : `supabase/migrations/20260829180600_elearning_mfk_a2_module7_memoire_engagement.sql`  
Illustrations : `/elearning/mfk-a2-m7/`

## Module A2-8 — Le monde en direct

| Titre | A2 — Le monde en direct |

| # | Séquence | Point de langue |
| --- | --- | --- |
| 8.1 | Un fait à raconter | Forme passive |
| 8.2 | Info du jour | Nominalisation |
| 8.3 | Réagir avec justesse | Gérondif |
| 8.4 | Des suggestions à faire | Conditionnel ; `suggérer` / `proposer de` |
| 8.5 | Espérer un monde meilleur | Subjonctif |
| 8.6 | Parler d'un livre | Pronom `on` |

Seed : `supabase/migrations/20260829180700_elearning_mfk_a2_module8_monde_direct.sql`  
Illustrations : `/elearning/mfk-a2-m8/`

---

# Plan MFK — Niveau B1 (8 modules)

Même architecture (tables `elearning_*`, 6 séquences × 5 leçons × 10 exercices, `published = false`).  
Les 4 axes communicatifs de la référence sont développés, puis **deux séquences supplémentaires** par module (synthèse ou prolongement).  
Cosmopolite 3 : objectifs génériques seulement. Univers Seuil des Sources. Lieux B1 inventés : Rive-des-Saules, Pavillon du Saule, Lampe-Figue, Filtre des Herbes, Saison des Voix.

Relecture consolidée : `docs/Relecture_MFK_B1_Modules1-8.md`

## Module B1-1 — Ailleurs, un nouveau chez-soi

| Titre | B1 — Ailleurs, un nouveau chez-soi |

| # | Séquence | Point de langue |
| --- | --- | --- |
| 1.1 | Choisir un lieu de vie | Verbes prépositionnels d'expatriation ; mise en garde |
| 1.2 | Formuler un souhait | Conditionnel présent ; demande polie |
| 1.3 | Un quartier à caractériser | Place de l'adjectif ; hypothèse `si` + imparfait |
| 1.4 | Souvenirs d'arrivée | Relatifs `où` / `dont` |
| 1.5 | Deux rives, un choix | Synthèse : prépositionnels + conditionnel |
| 1.6 | Écrire à ceux qui restent | Lettre ; politesse ; lien des deux rives |

Seed : `supabase/migrations/20260830120000_elearning_mfk_b1_module1_ailleurs_nouveau_chez_soi.sql`  
Illustrations : `/elearning/mfk-b1-m1/`

## Module B1-2 — S'installer autrement

| Titre | B1 — S'installer autrement |

| # | Séquence | Point de langue |
| --- | --- | --- |
| 2.1 | Un souci du quotidien | Subjonctif des sentiments |
| 2.2 | Anticiper un problème de santé | Conséquence (`donc`, `si bien que`, `c'est pourquoi`) |
| 2.3 | Des papiers à remplir | Impératif + pronoms ; discours indirect |
| 2.4 | Goûts et façons de vivre | Négation nuancée |
| 2.5 | Trouver un rythme | Synthèse habitudes / changement |
| 2.6 | Un voisinage à tisser | Médiation, compromis |

Seed : `supabase/migrations/20260830120100_elearning_mfk_b1_module2_sinstaller_autrement.sql`  
Illustrations : `/elearning/mfk-b1-m2/`

## Module B1-3 — Organiser la fête

| Titre | B1 — Organiser la fête |

| # | Séquence | Point de langue |
| --- | --- | --- |
| 3.1 | Proposer une sortie | Conseils ; mise en relief |
| 3.2 | Convaincre le groupe | Expression du but (`pour que`, `afin de`) |
| 3.3 | Fêtes et coutumes | `en` / `y` ; concession (`bien que`) |
| 3.4 | Autour de la soirée | Démonstratifs et indéfinis |
| 3.5 | Préparer la veillée | Synthèse d'organisation |
| 3.6 | Après la fête | Raconter, remercier |

Seed : `supabase/migrations/20260830120200_elearning_mfk_b1_module3_organiser_la_fete.sql`  
Illustrations : `/elearning/mfk-b1-m3/`

## Module B1-4 — Agir pour demain

| Titre | B1 — Agir pour demain |

| # | Séquence | Point de langue |
| --- | --- | --- |
| 4.1 | Rendre compte, adhérer, nuancer | Indéfinis de quantité |
| 4.2 | Débattre de solutions | Participe présent ; adverbes `-ment` ; intensité |
| 4.3 | Un projet pour la rive | Infinitif et subjonctif de but |
| 4.4 | Persuader d'agir | Éco-gestes ; persuasion |
| 4.5 | Mesurer l'impact | `de plus en plus` / `de moins en moins` |
| 4.6 | Convaincre le Bureau | Lettre, pétition, Cahier des racines |

Seed : `supabase/migrations/20260830120300_elearning_mfk_b1_module4_agir_pour_demain.sql`  
Illustrations : `/elearning/mfk-b1-m4/`

## Module B1-5 — Étudier et travailler autrement

| Titre | B1 — Étudier et travailler autrement |

| # | Séquence | Point de langue |
| --- | --- | --- |
| 5.1 | Dire son parcours | Articulateurs de lettre de motivation |
| 5.2 | Se préparer à l'entretien | Conseils d'embauche |
| 5.3 | Oser une expérience | Valoriser une prise de risque |
| 5.4 | Une journée de métier | `où` ; gérondif vs participe présent |
| 5.5 | Un stage à la radio | Plateau de Radio Figuier |
| 5.6 | Bilan de la première semaine | Synthèse parcours + gérondif |

Seed : `supabase/migrations/20260830120400_elearning_mfk_b1_module5_etudier_travailler.sql`  
Illustrations : `/elearning/mfk-b1-m5/`

## Module B1-6 — S'informer, s'exprimer

| Titre | B1 — S'informer, s'exprimer |

| # | Séquence | Point de langue |
| --- | --- | --- |
| 6.1 | Lire une source | Concession ; voix passive |
| 6.2 | Écrire un fait divers | Récit journalistique ; temps du passé |
| 6.3 | Démasquer une rumeur | `d'après` / `il paraît` / `il a été confirmé` |
| 6.4 | Tenir le micro | Mise en évidence (`ce qui` / `c'est… que`) |
| 6.5 | Préparer le journal parlé | Structure d'une émission |
| 6.6 | L'éthique du micro | Droit de réponse ; charte inventée |

Seed : `supabase/migrations/20260830120500_elearning_mfk_b1_module6_sinformer_sexprimer.sql`  
Illustrations : `/elearning/mfk-b1-m6/`

## Module B1-7 — L'esprit d'innovation

| Titre | B1 — L'esprit d'innovation |

| # | Séquence | Point de langue |
| --- | --- | --- |
| 7.1 | Des talents à découvrir | Relatifs composés (`auquel`, `duquel`…) |
| 7.2 | Expliquer une découverte | Présenter une innovation |
| 7.3 | Argumenter pas à pas | Progression chronologique |
| 7.4 | Imaginer demain | Doute et certitude (indicatif / subjonctif) |
| 7.5 | Le prototype sous le figuier | Test de la Lampe-Figue |
| 7.6 | Pitcher devant la cour | Oral de synthèse |

Seed : `supabase/migrations/20260830120600_elearning_mfk_b1_module7_esprit_innovation.sql`  
Illustrations : `/elearning/mfk-b1-m7/`

## Module B1-8 — Un monde de culture

| Titre | B1 — Un monde de culture |

| # | Séquence | Point de langue |
| --- | --- | --- |
| 8.1 | Une critique enthousiaste | Superlatif |
| 8.2 | Spectacles et parcours | Spectacles vivants ; parcours artistique |
| 8.3 | Réagir à une œuvre | Double pronominalisation |
| 8.4 | Pourquoi lire | Interrogation (`qu'est-ce qui` / inversion) |
| 8.5 | Soirée lecture | Cercle du Cahier du chemin |
| 8.6 | Inventer une saison | Programmer la Saison des Voix |

Seed : `supabase/migrations/20260830120700_elearning_mfk_b1_module8_monde_de_culture.sql`  
Illustrations : `/elearning/mfk-b1-m8/`

---

# Plan MFK — Niveau B2 (8 modules)

Même architecture (tables `elearning_*`, 6 séquences × 5 leçons × 10 exercices, `published = false`).  
Les 4 axes de la référence sont développés, plus **deux séquences** de débat ou de prolongement. Supports plus longs et argumentatifs (articles, interviews, débats).  
Cosmopolite 4 : objectifs génériques seulement. Univers Seuil des Sources.

Relecture consolidée : `docs/Relecture_MFK_B2_Modules1-8.md`

## Module B2-1 — Tendances du Seuil

| Titre | B2 — Tendances du Seuil |

| # | Séquence | Point de langue |
| --- | --- | --- |
| 1.1 | Mode et apparence | Participe présent / adjectif verbal ; participe composé |
| 1.2 | Tendance alimentaire | Futur antérieur |
| 1.3 | Vacances et pratiques sociales | Opposition et concession |
| 1.4 | Introduire un texte explicatif | Conjonctions de temps |
| 1.5 | Débattre des tendances | Synthèse sous le figuier |
| 1.6 | Une chronique pour Radio Figuier | Article / oral argumenté |

Seed : `supabase/migrations/20260830140000_elearning_mfk_b2_module1_tendances_seuil.sql`  
Illustrations : `/elearning/mfk-b2-m1/`

## Module B2-2 — Mémoire du Seuil

| Titre | B2 — Mémoire du Seuil |

| # | Séquence | Point de langue |
| --- | --- | --- |
| 2.1 | Hypothèses sur le passé | `si` + PQP → conditionnel passé |
| 2.2 | Un métier, une société | Évolution sociale ; décrire un métier |
| 2.3 | Lieux d'enfance | Passé simple (compréhension) ; prépositions de lieu |
| 2.4 | Raconter l'histoire autrement | Voix, archives, radio |
| 2.5 | Archives du Cahier du chemin | Documents inventés |
| 2.6 | Table ronde « ce que le figuier a vu » | Débat / synthèse |

Seed : `supabase/migrations/20260830140100_elearning_mfk_b2_module2_memoire_seuil.sql`  
Illustrations : `/elearning/mfk-b2-m2/`

## Module B2-3 — Une culture commune

| Titre | B2 — Une culture commune |

| # | Séquence | Point de langue |
| --- | --- | --- |
| 3.1 | Préférences et résumés | Comparatifs et superlatifs |
| 3.2 | Débattre et portraits | Relatifs (dont composés) |
| 3.3 | Problème culturel, solutions | Mise en relief |
| 3.4 | Tendance et création | `en` / `y` ; registres |
| 3.5 | Bilan de la Saison des Voix | Critique |
| 3.6 | Manifeste culturel du Seuil | Texte argumenté |

Seed : `supabase/migrations/20260830140200_elearning_mfk_b2_module3_culture_commune.sql`  
Illustrations : `/elearning/mfk-b2-m3/`

## Module B2-4 — Vivre avec la technologie

| Titre | B2 — Vivre avec la technologie |

| # | Séquence | Point de langue |
| --- | --- | --- |
| 4.1 | Actualité technologique | Inversion ; préfixes négatifs |
| 4.2 | Évolution sociétale | Exprimer la durée |
| 4.3 | Mémoire et réseaux | Préfixe `re-` ; cause / conséquence |
| 4.4 | Raisonnement sur la déconnexion | Connecteurs de raisonnement |
| 4.5 | Charte numérique de Radio Figuier | Texte de charte |
| 4.6 | Débat « Lampe-Figue et le fil » | Pour / contre |

Seed : `supabase/migrations/20260830140300_elearning_mfk_b2_module4_vivre_technologie.sql`  
Illustrations : `/elearning/mfk-b2-m4/`

## Module B2-5 — Questions de société

| Titre | B2 — Questions de société |

| # | Séquence | Point de langue |
| --- | --- | --- |
| 5.1 | Un enjeu à analyser | Voix passive |
| 5.2 | Prendre position | Emplois du subjonctif |
| 5.3 | Fait culturel et politique | Assemblée, motion, veillée |
| 5.4 | Nuancer une comparaison | Subjonctif d'alternative |
| 5.5 | Enquête à Rukiri-Nord | Rapport d'enquête |
| 5.6 | Éditorial pour le Cahier des racines | Éditorial |

Seed : `supabase/migrations/20260830140400_elearning_mfk_b2_module5_questions_societe.sql`  
Illustrations : `/elearning/mfk-b2-m5/`

## Module B2-6 — Faire évoluer la société

| Titre | B2 — Faire évoluer la société |

| # | Séquence | Point de langue |
| --- | --- | --- |
| 6.1 | Dresser un bilan | Condition (`pourvu que`, `à moins que`) |
| 6.2 | Prise de conscience et recommandations | Conditionnel ; conditionnel passé |
| 6.3 | Action citoyenne | Indéfinis |
| 6.4 | Dénoncer et proposer | Locutions prépositionnelles ; accord PP / COD |
| 6.5 | Assemblée sous le figuier | Synthèse orale |
| 6.6 | Motion au Bureau des Escales | Texte formel |

Seed : `supabase/migrations/20260830140500_elearning_mfk_b2_module6_evoluer_societe.sql`  
Illustrations : `/elearning/mfk-b2-m6/`

## Module B2-7 — Agir au travail

| Titre | B2 — Agir au travail |

| # | Séquence | Point de langue |
| --- | --- | --- |
| 7.1 | Pratiques et parcours | Discours indirect présent / passé |
| 7.2 | Identifier des compétences | Lexique professionnel |
| 7.3 | Communiquer au travail | Double pronominalisation ; figures de style |
| 7.4 | Métier et point de vue | Expressions pour nuancer |
| 7.5 | Entretien croisé Atelier / Radio | Dialogue professionnel |
| 7.6 | Charte du travail au Seuil | Texte de charte |

Seed : `supabase/migrations/20260830140600_elearning_mfk_b2_module7_agir_travail.sql`  
Illustrations : `/elearning/mfk-b2-m7/`

## Module B2-8 — Modèles éducatifs

| Titre | B2 — Modèles éducatifs |

| # | Séquence | Point de langue |
| --- | --- | --- |
| 8.1 | Objectifs et expériences novatrices | Relatives de but / souhait ; subjonctif d'opinion |
| 8.2 | Expliquer et commenter des résultats | Commentaire de chiffres inventés |
| 8.3 | L'utilité des diplômes | Subjonctif de probabilité |
| 8.4 | Une initiative, des différences | `ne… ni… ni…` |
| 8.5 | Bilan pédagogique d'Aline | Synthèse |
| 8.6 | Projet d'école de la cour | Manifeste éducatif |

Seed : `supabase/migrations/20260830140700_elearning_mfk_b2_module8_modeles_educatifs.sql`  
Illustrations : `/elearning/mfk-b2-m8/`
