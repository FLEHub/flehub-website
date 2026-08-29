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

## Modules 2 et 9 *(non seedés)*

| # | Module | Séquences |
| --- | --- | --- |
| 2 | A1 — Faire connaissance | 4 à 6 séquences |
| 9 | A1 — Retour sur le chemin parcouru | 4 à 6 séquences |

Même gabarit : 5 leçons × 10 exercices, personnages et documents inventés, pas de copie de méthode.
