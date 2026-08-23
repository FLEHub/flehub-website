# Relecture française — Module 4 A1

Étape **séparée**, après rédaction des 30 supports et des 300 exercices.
Tous les textes apprenant (objectifs, consignes, dialogues, fiches, items, réponses) ont été relus une seconde fois.

## Méthode

1. Génération du dump `Relecture_MFK_A1_Module4_textes.txt` (tous les libellés).
2. Lecture séquence par séquence : accords, conjugaison, élisions, prépositions, typographie A1.
3. Correction à la source (`scripts/mfk_a1_m4/content.py`), puis régénération du SQL.

## Corrections appliquées

| Lieu | Avant | Après |
| --- | --- | --- |
| S1 PE, S2 PE, S3 PE, S4 PE, S5 PE — consigne | impératif fautif possible « Imitiez » | « Imitez… » (déjà à la source) |
| S1 PE — erreur à trouver | « C'est mon sœur, Mireille. » comme cible normative | phrase fautive conservée ; correctif « C'est ma sœur, Mireille. » |
| S2 CO — dernière réplique | « ils sont une famille » | « Ils sont différents, et c'est une famille. » |
| S2 CO — âge de Claire | « Claire est… pas jeune » | « Claire n'est pas jeune » |
| S3 CO — erreur à trouver | « Je n'aime pas le danses. » (deux fautes) | « Je n'aime pas le danse. » → « la danse » |
| S3 EL — fiche | « je / tu aimes » (verbe manquant) | « j'aime / tu aimes / il aime / elle aime » |
| S4 CO — Aline | portrait sans lieu | « J'habite près de la cour. » (aligné sur la fiche CE) |
| S4 CE — audio | risque « sans trop vite » | « sans aller trop vite » |
| S4 PO — ordre des mots | « Voilà c'est moi » (virgule obligatoire absente) | « Voici mon portrait » (pas de jeton virgule) |
| S4 PE — anagramme *vingt* | indice « Le début de vingt-neuf » (mot-cible en clair) | « Le début du nombre 29. » |
| S5 CE — explication | « On ne « joue au danse » pas. » | « On ne dit pas « jouer au danse ». » |
| S5 EL — fiche | « aimer ce temps libre. » | « J'aime ce temps libre. » |
| S6 CE — erreur à trouver | accord ambigu sur *fatigué* | « Je suis fatigué. » → « Je suis fatiguée. » (Hawa) |

## Contrôles gardés

- Possessifs : *ma mère*, *mon père*, *mes parents* ; *une sœur*, *un frère*.
- Accords : *petite*, *grande*, *nouvelle*, *assise*, *fatiguée*, *contente*.
- Contractions : *au* = à + le (*au Seuil*, *au dos*, *au football*).
- Négation : *je n'aime pas*, *je n'ai pas*, *pas de* + nom.
- Âge : *ans* au pluriel (*j'ai trente ans*).
- Présent de *lire* : *je lis* (pas *je lise*).
- *jouer au football* (pas *à le* / *à football*).
- Indices d'anagrammes : le mot-cible n'apparaît pas en clair.
- Ordre des mots : aucun jeton virgule.

Les phrases *volontairement fautives* des exercices `find_error` restent fautives ; seule la colonne « phrase correcte » est normative.
