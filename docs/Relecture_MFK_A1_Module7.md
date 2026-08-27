# Relecture française — Module 7 A1

Étape **séparée**, après rédaction des 30 supports et des 300 exercices.
Tous les textes apprenant (objectifs, consignes, dialogues, fiches, items, réponses) ont été relus une seconde fois, avec une attention particulière au **futur simple** (être, avoir, faire, pouvoir, aller, prendre, falloir) et à **`il faut` / `il faudra`** (toujours 3e personne du singulier).

## Méthode

1. Génération du dump `Relecture_MFK_A1_Module7_textes.txt` (tous les libellés).
2. Lecture séquence par séquence : terminaisons `-ai / -as / -a / -ons / -ez / -ont` ; irréguliers *serai*, *aurai*, *ferai* (un r), *pourrai* (deux r), *irai* / *irons* ; *il faut* jamais *je faut*.
3. Correction à la source (`scripts/mfk_a1_m7/content.py`), puis régénération du SQL.

## Corrections appliquées

| Lieu | Avant | Après |
| --- | --- | --- |
| S1 CO — Aline | *Tu auras le minibus Figuier 7* | *Tu auras une place dans le minibus Figuier 7* |
| S1 CO — Joël | *Je resterai à la moto* | *Je resterai près de la moto* |
| S1 CO — Patrick | *Il faut demander l'heure. Ce n'est pas grave.* | *Il faut demander l'heure à l'accueil.* |
| S1 EL — consigne libre | *quatre futurs : partir, être, avoir, il faut* | *quatre phrases : je partirai, je serai, j'aurai, il faut* |
| S2 CO — Hawa | *une pause au thé* | *une pause, un thé, avant* |
| S2 CO — QCM | *je prendrai* (citation) | *Je prendrai* |
| S2 CE / S3 PE / S6 CE — citations QCM | minuscule en tête de citation | majuscule (*Il faudra*, *Nous visiterons*, *Nous serons*) |
| S3 PO — distracteur QCM | *Au nord il y a un lac* | *Au nord, il y a un lac* |
| S4 CE — vrai/faux | télégraphique | *Léa a la chambre près de la mer. Noura a la petite chambre.* |
| S4 PE — erreur à trouver | la correction supprimait *Il faudra une clé* | une seule faute : *Je faut* → *Il faudra* |
| S5 CO — audio | *Je partirai au soleil* | *Je partirai. Je verrai le soleil.* |
| S5 CE — trou | *Il ___ regarder le ciel* (ambigu faut / faudra) | hint *(futur de falloir)* → *faudra* |
| S5 PO — erreur à trouver | la correction supprimait *Je partirai* | *chapeaux* → *chapeau*, le reste inchangé |
| S5 EL — erreur à trouver | *Il fauts* corrigé en *Il faudra* (deux changements) | *Il fauts* → *Il faut* ; *Il fera froid* conservé |
| S6 CO — QCM | *Que dessinerai Joël ?* | *Que dessinera Joël ?* |
| S6 CO — image | expression Python / `figuier` inexistant | pictogramme `pont` |
| S6 PO — erreur à trouver | consigne méta *(Léa parle)* | *Je serai content.* → *Je serai contente.* |
| S6 PE — erreur à trouver | la correction supprimait *J'écrirai le soir* | *Je sera* → *Je serai*, le reste inchangé |
| Toutes les PE | impératif | « Imitez… » (pas *Imitiez*) |

## Contrôles gardés

- *Être* : *je serai*, *tu seras*, *il/elle sera*, *nous serons*, *vous serez* (pas *je sera*, pas *vous sera*).
- *Avoir* : *j'aurai*, *tu auras* (pas *tu aura*) ; *il y aura* (pas *il y auras*).
- *Faire* : *je ferai* / *il fera* (un r, pas *ferrai* / *ferra*).
- *Pouvoir* : *je pourrai* / *on pourra* (deux r, pas *poura*).
- *Aller* : *j'irai* / *nous irons* (pas *j'allerai*, pas *nous allerons*).
- *Prendre* : *je prendrai* (pas *je prendreai*).
- *Falloir* : seulement *il faut* / *il faudra* (pas *je faut*, pas *ils faudra*) ; + nom ou infinitif.
- *On* = 3e personne : *on arrivera*, *on pourra*, *on sera* (pas *on arriverons*).
- Négation au futur : *je ne partirai pas* / *je ne visiterai pas* (*ne… pas*).
- Accord : Léa *fatiguée*, *contente* ; *une clé* (pas *une clés*) ; *des pauses* ; *un chapeau*.
- *Si* + présent : *s'il pleut* (pas *s'il pleuvra*).
- Figures et lieux **inventés** seulement (Noura Sarr, Ibrahim Tchami, Auberge des Figues, lac des Nénuphars, Port de la Brise, Île de Sable-Rouge, Mwezi-Haut, Rive d'Orage) : aucune célébrité ni enseigne réelle.
- Indices d'anagrammes : le mot-cible n'apparaît pas en clair.
- Ordre des mots : aucun jeton virgule.

Les phrases *volontairement fautives* des exercices `find_error` restent fautives ; seule la colonne « phrase correcte » est normative.

Le dump `Relecture_MFK_A1_Module7_textes.txt` n'est pas versionné : il sert à la passe de relecture, puis est régénéré au besoin.
