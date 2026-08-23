# Relecture française — Module 3 A1

Étape **séparée**, après rédaction des 30 supports et des 300 exercices.
Tous les textes apprenant (objectifs, consignes, dialogues, fiches, items, réponses) ont été relus une seconde fois.

## Méthode

1. Génération du dump `Relecture_MFK_A1_Module3_textes.txt` (tous les libellés).
2. Lecture séquence par séquence : accords, conjugaison, élisions, prépositions, typographie A1.
3. Correction à la source (`scripts/mfk_a1_m3/content.py`), puis régénération du SQL.

## Corrections appliquées

| Lieu | Avant | Après |
| --- | --- | --- |
| S2 PE, S3 PE, S5 PE — consigne | « Imitiez le modèle / le mot » | « Imitez… » (impératif) |
| S1 CE — trou | « Il ___ trois paniers au nom du marché » | « Il ___ un marché près de la cour » (`y a`) |
| S2 CE — audio | « sans trop vite » | « sans aller trop vite » |
| S2 PE — audio | « lent, une phrase, une pause » | « lentement, une phrase, une pause » |
| S4 CO — erreur à trouver | phrase doublement fautive + tronquée | « Excuse-moi, madame. » → « Excusez-moi, madame. » |
| S4 EL / S6 PO — ordre des mots | virgule comme « mot » | phrases sans jeton virgule |
| S5 CE — annonce | « Contact : Hawa peut venir voir… » | « On peut venir voir aujourd'hui. » |
| S5 EL — trou | « Il n'y a pas ___ cuisine ? » | même phrase, point final |

## Contrôles gardés

- Accords : *un marché*, *un lit*, *la porte*, *la deuxième rue*.
- Contractions : *du*, *au*, *jusqu'au*, *de + le*.
- Aller : *je vais* (pas *je vas*) ; *on prend* (pas *on prends*).
- Adverbe : *tout droit* ; *lentement* (pas *lent* / *toute droite*).
- Politesse : *excusez-moi*, *pouvez-vous* (trait d'union).
- Négation de lieu : *il n'y a pas* (pas *il n'a pas*).
- Indices d'anagrammes : le mot-cible n'apparaît pas en clair.

Les phrases *volontairement fautives* des exercices `find_error` restent fautives ; seule la colonne « phrase correcte » est normative.
