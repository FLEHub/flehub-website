# Relecture française — Module 8 A1

Étape **séparée**, après rédaction des 30 supports et des 300 exercices.
Tous les textes apprenant ont été relus une seconde fois, avec une attention particulière aux **articles partitifs**, à **`je voudrais`**, aux comparatifs, à **l'imparfait**, aux démonstratifs **ce / cette / ces**, à l'accord des couleurs et à **trop / assez + adjectif**.

## Méthode

1. Génération du dump `Relecture_MFK_A1_Module8_textes.txt` (tous les libellés).
2. Lecture séquence par séquence.
3. Correction à la source (`scripts/mfk_a1_m8/content.py`), puis régénération du SQL.

## Corrections appliquées

| Lieu | Avant | Après |
| --- | --- | --- |
| S1 CO — QCM | option télégraphique *De fromage* | *Du fromage* (ce qui manque) |
| S1 CE — distracteurs | *rillettes* / *gâteau de Paris* (trop proches d'un manuel) | *ignames frites* / *gâteau du port* |
| S2 PO — erreur à trouver | — | *je voudrai* (futur) → *je voudrais* (demande polie) |
| S3 CE / S4 PE — distracteurs | *Paris* | *l'île* / *le port* (lieux du Seuil) |
| S4 PO — erreur à trouver | *Nous mangions* (forme correcte) marquée fausse | *On mangions* → *On mangeait* |
| S6 PE — image | expression Python résiduelle | pictogramme `assiette` |
| S6 EL — anagramme | indice contenant *assez* | indice sans le mot-cible |
| Toutes les PE | impératif | « Imitez… » (pas *Imitiez*) |

## Contrôles gardés

- Partitif : *du pain*, *de la soupe*, *de l'huile*, *des légumes* ; après *pas* : *pas de*.
- Goût : *j'aime le / la / les* (pas *j'aime du*).
- Quantité : *un kilo de*, *une bouteille d'huile*, *un pot de miel* (pas *du* après la mesure).
- Politesse : *je voudrais* (pas *je voudrai*).
- Comparatif : *plus / moins / aussi … que* ; *plus de / moins de* + nom.
- Imparfait : *j'étais*, *j'avais*, *je voulais*, *on mangeait*, *nous mangions*, *nous étions* (pas *je suisais*, pas *on mangions*).
- *Maintenant* + présent ; *avant* + imparfait.
- Démonstratifs : *ce pantalon*, *cette robe*, *ces sandales*.
- Accord : *chemise bleue*, *jupe verte*, *veste trop chaude*, *soupe vraiment bonne*.
- *Trop / assez* + adjectif (pas *trop de chaud*).
- Figures et lieux **inventés** seulement (Félicie, Dieudonné, Table des Sources, Atelier du Tissu) : aucune enseigne ni personne réelle, aucun texte de méthode.
- Indices d'anagrammes : le mot-cible n'apparaît pas en clair.
- Ordre des mots : aucun jeton virgule.

Les phrases *volontairement fautives* des exercices `find_error` restent fautives ; seule la colonne « phrase correcte » est normative.

Le dump `Relecture_MFK_A1_Module8_textes.txt` n'est pas versionné.
