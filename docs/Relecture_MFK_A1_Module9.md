# Relecture française — Module 9 A1

Étape **séparée**, après rédaction des 30 supports et des 300 exercices.
Tous les textes apprenant ont été relus une seconde fois. Ce module est un **bilan** : présent de présentation, passé composé, `pouvoir` / `savoir`, imparfait, futur simple et `il faut`.

## Méthode

1. Génération du dump `Relecture_MFK_A1_Module9_textes.txt`.
2. Lecture séquence par séquence.
3. Correction à la source (`scripts/mfk_a1_m9/content.py`), puis régénération du SQL.

## Corrections appliquées

| Lieu | Avant | Après |
| --- | --- | --- |
| S1 PE — erreur à trouver | la correction supprimait *J'habite près du port* | une seule faute : *enchanté* → *enchantée* |
| S1 / S2 / S6 PO-PE — erreur à trouver | consigne méta *(Léa parle)* | phrase fautive seule, accord dans l'explication |
| S2 PE / S4 EL — anagrammes | indices contenant *choisi* / *connaît* (sous-chaîne) | indices sans le mot-cible |
| S4 EL — erreur à trouver | deux changements (*connaissait* + ajout de *le*) | *Maintenant on connaissait* → *connaît* |
| S6 EL — fiche | *pas raconterons-nous ici* (peu clair) | *pas nous raconteront* |
| Toutes les PE | impératif | « Imitez… » (pas *Imitiez*) |

## Contrôles gardés

- Présentation : *j'habite*, *j'ai … ans*, *enchantée*.
- Passé composé : *j'ai appris* (pas *apprendre*) ; *elle est arrivée* (pas *elle a arrivée*).
- *Je peux* / *je sais* / *on peut* + infinitif (pas *de*) ; *il faut* seulement 3e personne.
- Avant + imparfait (*j'étais*, *je savais*) ; maintenant + présent.
- Futur : *je serai*, *je ferai* (un r), *on pourra* (deux r), *il faudra* ; pas *je faut*.
- *On se verra* (deux r). *Contente* au féminin.
- Figures et lieux **inventés** (Cahier du chemin, Seuil des Sources) : aucune méthode, enseigne ou célébrité.
- Indices d'anagrammes : le mot-cible n'apparaît pas en clair (ni comme sous-chaîne).
- Ordre des mots : aucun jeton virgule.

Les phrases *volontairement fautives* des exercices `find_error` restent fautives ; seule la colonne « phrase correcte » est normative.

Le dump `Relecture_MFK_A1_Module9_textes.txt` n'est pas versionné.
