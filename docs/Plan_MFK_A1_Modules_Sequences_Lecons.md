# Plan MFK — 9 modules A1

Hiérarchie réelle (schéma `public`, tables `elearning_*`) :

- **9 modules** (`cefr_level = A1`) = les 9 grandes étapes
- **4 à 6 séquences** par module = les sous-thèmes
- **5 leçons** par séquence = CO, CE, PO, PE, EL

Seed : `supabase/migrations/20260814120000_elearning_mfk_a1_module1_premiers_reperes.sql` (aucune table nouvelle). Plafond UI enseignant : **6 séquences** par module.

> Le fichier d’origine n’était pas dans le workspace au moment du seed v1. Cette version suit la correction structurelle v2. Seul le **Module 1** est détaillé et seedé ; les modules 2 à 9 attendent la validation du Module 1.

## Module 1 — Premiers repères *(seedé — à valider)*

| Champ | Valeur |
| --- | --- |
| Titre | A1 — Premiers repères |
| `cefr_level` | A1 |
| Description | Grande étape 1 : saluer et se présenter, se compter, situer le monde en français, vivre en classe. |

| # | Séquence | Thème | Point de langue |
| --- | --- | --- | --- |
| 1.1 | Bienvenue en français | Saluer, se présenter, prendre congé | Formules de politesse ; tutoiement / vouvoiement ; `s’appeler` ; `je` / `tu` / `vous` ; `c’est` |
| 1.2 | Se compter et s’organiser | Nombres, âge, jours de la semaine | Nombres 0–20 ; `avoir` + âge ; jours de la semaine ; `c’est` + jour |
| 1.3 | Le monde en français | Pays, nationalités, langues | `être` + nationalité ; `d’où viens-tu ?` ; `je parle…` ; `de` / `à` / `en` |
| 1.4 | Vivre en classe | Consignes et objets de la classe | Impératif (`écoutez`, `répétez`, `ouvrez`) ; `un` / `une` ; `je ne comprends pas` |

## Modules 2 à 9 *(non seedés)*

| # | Module (`cefr_level = A1`) | Séquences |
| --- | --- | --- |
| 2 | A1 — Faire connaissance | 4 à 6 séquences (après validation du module 1) |
| 3 | A1 — S’orienter et s’installer | 4 à 6 séquences |
| 4 | A1 — Portraits croisés | 4 à 6 séquences |
| 5 | A1 — Le fil des journées | 4 à 6 séquences |
| 6 | A1 — Histoires vécues | 4 à 6 séquences |
| 7 | A1 — Cap sur ailleurs | 4 à 6 séquences |
| 8 | A1 — Gestes du quotidien | 4 à 6 séquences |
| 9 | A1 — Retour sur le chemin parcouru | 4 à 6 séquences |

---

## Gabarit de leçon (chaque séquence)

Ordre `order_index` dans `elearning_lessons` :

| `order_index` | `competency` | Support dans `content` (`content_type = text`) | Exercices (2 ou 3) |
| --- | --- | --- | --- |
| 0 | `CO` | Objectif + consigne + script d’écoute | `true_false`, `qcm`, `matching` |
| 1 | `CE` | Objectif + consigne + texte court | `qcm`, `true_false`, `fill_blank` |
| 2 | `PO` | Objectif + consigne + phrases modèles | `matching` ou `word_order`, puis `audio_record` |
| 3 | `PE` | Objectif + consigne + modèle écrit | `fill_blank` ou `word_order`, puis `short_answer` |
| 4 | `EL` | Objectif + fiche du **point de langue de la séquence** | `qcm` / `fill_blank` / `find_error` / `anagram` / `word_order` |

Format de `elearning_lessons.content` :

```
Objectif
<une phrase CECR A1, liée au point de langue de la séquence>

Consigne
<ce que l’apprenant doit faire>

Support
<dialogue, texte, modèle ou fiche>
```

Il n’existe pas de colonne `objectif` / `consigne` / `thème` / `point_de_langue` : tout va dans `title` + `content`.
