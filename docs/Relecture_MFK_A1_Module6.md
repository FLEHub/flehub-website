# Relecture française — Module 6 A1

Étape **séparée**, après rédaction des 30 supports et des 300 exercices.
Tous les textes apprenant (objectifs, consignes, dialogues, fiches, items, réponses) ont été relus une seconde fois, avec une attention particulière au **passé composé**, au **passé récent** et au **futur proche**.

## Méthode

1. Génération du dump `Relecture_MFK_A1_Module6_textes.txt` (tous les libellés).
2. Lecture séquence par séquence : auxiliaires *être* / *avoir*, accords du participe, `venir de` / `aller` + infinitif, impératif.
3. Correction à la source (`scripts/mfk_a1_m6/content.py`), puis régénération du SQL.

## Corrections appliquées

| Lieu | Avant | Après |
| --- | --- | --- |
| S1 CO — explication | guillemets imbriqués peu lisibles | « Léa dit : j'ai appris « il est midi ». » |
| S1 EL — erreur à trouver | deux fautes dans une phrase longue | « Il a apprendre un mot. » → *appris* |
| S2 PE — image | expression Python résiduelle | pictogramme `figuier` |
| S2 CE / EL — anagrammes | indices contenant *choisi* / *avant* | indices sans le mot-cible |
| S3 PE — distracteurs QCM | titres de méthodes / livres réels | titres inventés du Seuil |
| S4 CE — erreur à trouver | trois phrases d'un coup | « Il a les cheveu courts. » → *cheveux* |
| S4 PE / EL — accords | *arrivé* / *arrivée* | conservé : Rose *arrivée*, Sami *arrivé*, elles *arrivées* |
| S5 — maintenant | risque *j'ai suis* / *a étudie* | présent : *je suis*, *elle étudie* |
| S6 CE — erreur à trouver | consigne méta entre parenthèses | « Écoute la radio. » → *Écoutez* |
| Toutes les PE | impératif | « Imitez… » (pas *Imitiez*) |

## Contrôles gardés

- *Avoir* : *j'ai écouté*, *lu*, *écrit*, *appris*, *choisi* (invariable dans ces items, pas de COD antéposé).
- *Être* : *elle est née*, *il est né*, *ils sont nés* ; *arrivé* / *arrivée* / *arrivés* / *arrivées*.
- Pas *elle a née*, pas *j'ai apprendre*, pas *je vas*, pas *je vien*.
- Passé récent : *je viens de* + infinitif ; futur proche : *je vais* + infinitif.
- *Il faut* / *on peut* + infinitif (pas d'impératif après).
- Groupe : *écoutez*, *lisez*, *demandez*.
- Figures **inventées** seulement (Mado, Sami, Benoît, Yvette) : aucune célébrité réelle.
- Indices d'anagrammes : le mot-cible n'apparaît pas en clair (ni comme sous-chaîne, ex. *choisi* dans *choisir*).
- Ordre des mots : aucun jeton virgule.

Les phrases *volontairement fautives* des exercices `find_error` restent fautives ; seule la colonne « phrase correcte » est normative.
