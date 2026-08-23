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

## Modules 2 et 4 à 9 *(non seedés)*

| # | Module | Séquences |
| --- | --- | --- |
| 2 | A1 — Faire connaissance | 4 à 6 séquences |
| 4 | A1 — Portraits croisés | 4 à 6 séquences |
| 5 | A1 — Le fil des journées | 4 à 6 séquences |
| 6 | A1 — Histoires vécues | 4 à 6 séquences |
| 7 | A1 — Cap sur ailleurs | 4 à 6 séquences |
| 8 | A1 — Gestes du quotidien | 4 à 6 séquences |
| 9 | A1 — Retour sur le chemin parcouru | 4 à 6 séquences |

Même gabarit : 5 leçons × 10 exercices, personnages et documents inventés, pas de copie de méthode.
