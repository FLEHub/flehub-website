# Relecture française — Module 5 A1

Étape **séparée**, après rédaction des 30 supports et des 300 exercices.
Tous les textes apprenant (objectifs, consignes, dialogues, fiches, items, réponses) ont été relus une seconde fois.

## Méthode

1. Génération du dump `Relecture_MFK_A1_Module5_textes.txt` (tous les libellés).
2. Lecture séquence par séquence : accords, conjugaison, élisions, prépositions, typographie A1.
3. Correction à la source (`scripts/mfk_a1_m5/content.py`), puis régénération du SQL.

## Corrections appliquées

| Lieu | Avant | Après |
| --- | --- | --- |
| S1 CO — explication | « Après un nombre autre que un » | « Après un nombre différent de un » |
| S1 PO — association | « après midi » (ambigu) | « après 12 h » |
| S1 PE, S2 PE, S3 PE, S4 PE, S5 PE, S6 PE — consigne | impératif « Imitez » | conservé (pas *Imitiez*) |
| S2 CE — association « le soir » | « dîner » absent des cartes | « fil et moto » (textes des cartes) |
| S2 CE — trou | « Le soir, je dîne » hors support | « Je me couche à minuit » (carte Joël) |
| S4 CE — consigne du Seuil | « commence / finis » (personne mêlée) | « je commence / je finis » |
| S4 PO — explication | « Commencer = démarrer » | « Commencer = le début » |
| S4 PE — erreur à trouver | phrase trop longue, plusieurs fautes | « Je commence à six heure du matin. » → *heures* |
| S5 CO — Hawa | « Je sors au Marché » (calque flou) | « Ce soir, je vais au Marché des Lampions. » |
| S5 CE / S5 PE — erreur à trouver | deux fautes dans une phrase | une seule : *à le* → *à la* / *au* |
| S6 CO — distracteur QCM | « Il n'a pas l'heure » | « Il n'a pas le temps » |
| S6 CO — association | « ok » (anglais) | « oui simple » |
| S6 PE — ordre des mots | « D'accord . » trop court | « Oui avec plaisir . » |
| Ordre des mots (toutes séq.) | virgule comme jeton | phrases sans virgule |

## Contrôles gardés

- Heure : *il est sept heures* ; *il est une heure* ; *il est midi* / *minuit* (sans *heures*).
- Contractions : *au jardin*, *au marché*, *à la salle*, *à l'accueil*.
- Pronoms réfléchis : *je me lève*, *tu te lèves*, *elle se couche*.
- *On* comme *il/elle* : *on prend*, *on va* (pas *prends* / *vas*).
- Travail : *je finis*, *il finit* (pas *je fini*).
- Invitation : *je peux* / *tu veux* (avec x) ; *il peut* (avec t).
- Négation : *je ne sors pas*, *je ne peux pas*.
- Indices d'anagrammes : le mot-cible n'apparaît pas en clair.
- Consigne audio : *sans aller trop vite*.

Les phrases *volontairement fautives* des exercices `find_error` restent fautives ; seule la colonne « phrase correcte » est normative.
