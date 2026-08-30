# Relecture française — Niveau B1, modules 1 à 8

Étape **séparée**, après rédaction des 240 supports et des 2 400 exercices.  
Aucun texte A1 ou A2 n’a été modifié. Les modules restent en brouillon (`published = false`).

## Méthode

1. Génération via `scripts/mfk_b1/generate.py` (5 compétences, 10 types, anagrammes, QCM, SVG, PE *Imitez*).
2. Lecture séquence par séquence : subjonctif, conditionnel, relatifs composés, double pronominalisation, *il faut*, futurs / passifs.
3. Correction à la source (`scripts/mfk_b1/m1.py` … `m8.py`), puis régénération SQL.
4. Anti-copyright : Seuil des Sources uniquement (Rive-des-Saules, Pavillon du Saule, Lampe-Figue, Filtre des Herbes, Saison des Voix, pièce *La cour n’oublie pas*). Aucune ville, enseigne, média ou titre réel.

Les phrases volontairement fautives des `find_error` restent fautives ; seule la phrase correcte est normative. Pas de commentaire méta dans la phrase à corriger.

---

## Module 1 — Ailleurs, un nouveau chez-soi

Points : *s’installer à*, *s’habituer à*, *tenir à* ; *je voudrais* / *pourriez-vous* ; place de l’adjectif ; *si* + imparfait → conditionnel ; *où* / *dont*.

Contrôles gardés : *il faut* (pas *je faut*) ; *je serais* (conditionnel) ≠ *je serai* ; *au Pavillon* (à + le).

---

## Module 2 — S'installer autrement

Points : *je suis content(e) que* + subj. ; conséquence (*si bien que*, *c’est pourquoi*) ; impératif + pronoms ; discours indirect ; *ne… que* / *ne… ni… ni*.

Contrôles gardés : *il faut que tu partes* ; *elle m’a dit de* ; *je ne prends que*.

---

## Module 3 — Organiser la fête

Points : *si j’étais toi* ; *c’est… qui/que* ; *pour que* / *afin que* + subj. ; *bien que* + subj. ; *celui-ci*, *chacun*, *n’importe qui*.

| Lieu | Avant | Après |
| --- | --- | --- |
| S5 EL — erreur | *je serai d’accord si Joël aidait* | *je serais d’accord si Joël aidait* (déjà ciblé dans l’item) |

---

## Module 4 — Agir pour demain

Points : *la plupart*, *certains*, *aucun* ; participe présent ; *-ment* ; *trop* / *vraiment* ; *afin que* + subj. ; *il vaudrait mieux*.

Contrôles gardés : *aucun n’est* ; *pour que la rive soit* ; *de plus en plus de signatures*.

---

## Module 5 — Étudier et travailler autrement

Points : *tout d’abord*, *dans l’attente de* ; *il vaudrait mieux* ; *cela m’a permis de* ; *où* ; *en arrivant* (gérondif) ≠ participe présent épithète.

Contrôles gardés : *je vous prie* ; *en arrivant*, *une personne arrivant*.

---

## Module 6 — S'informer, s'exprimer

Points : *bien que* + subj. ; passif ; PC / imparfait / PQP ; *il paraît* vs *il a été confirmé* ; *c’est… que*.

| Lieu | Avant | Après |
| --- | --- | --- |
| S2 CO — erreur | correction coupait le décor | *a été gris* → *était gris* ; *pendant que l’eau montait…* conservé |
| S3 CO — erreur | correction changeait le témoin | *il a été confirmé* → *il paraît* ; *d’après Mado…* conservé |
| S3 PE — erreur | phrase correcte sans rapport | *personne a glissé* → *personne n’a glissé* |
| S3 EL — erreur | correction changeait la source | *il a été confirmé* → *il paraît* (source floue) |
| S4 — erreurs | *que je lis* trop court | *en premier à l’antenne* / *avant la rumeur* conservés |

---

## Module 7 — L'esprit d'innovation

Points : *auquel* / *duquel* / *avec lequel* ; *cela permet de* ; *d’abord… en conclusion* ; *il est probable que* + indicatif ; *je doute que* + subj.

| Lieu | Avant | Après |
| --- | --- | --- |
| S4 PO — erreur | clauses coupées | *explique demain à l’antenne* → *expliquera demain à l’antenne* |
| S6 PE — erreur | *comprenne* sans complément utile | *il est probable que la cour comprendra le schéma demain* |

---

## Module 8 — Un monde de culture

Points : *le plus émouvant* / *la meilleure* (pas *la plus meilleure*) ; *je le lui ai dit* ; *qu’est-ce qui* (sujet) / *qu’est-ce que* (COD).

| Lieu | Avant | Après |
| --- | --- | --- |
| S3 PO / EL — erreurs | pronoms corrigés mais complément coupé | *après la pièce sous le figuier* / *demain matin sous le figuier* conservés |
| S5 PO — erreur | *Coupez-moi* (sens différent) | *Ne le me coupe pas* → *Ne me le coupe pas* ; *Attends la fin* conservé |
| S5 PE — erreur | *simplement* ajouté | *Je vous le promets trop fort sous le figuier ce soir* |
| S6 EL — erreur | phrase correcte sans rapport | *politesse fait* → *politesse faite* |

---

## Contrôles communs aux 8 modules

- *Il faut* toujours 3e personne ; *je serai* / *je serais* distingués ; *je ferai* (un r) ; *je pourrai* (deux r).
- *Bien que* / *pour que* / *afin que* / *il faut que* + subjonctif.
- PE : **Imitez** ; CE / PE lus : *sans aller trop vite*.
- `audio_record` : enregistrement de l’apprenant.
- Anagrammes sans fuite du mot-cible ; aucun jeton virgule ; QCM 4 options / 1 correcte.
- 30 SVG originaux par module, tous utilisés.
- 8 × 30 leçons × 10 exercices = **240 leçons, 2 400 exercices** ; `cefr_level = 'B1'` ; `published = false`.

Aucun dump `*_textes.txt` n’est versionné.
