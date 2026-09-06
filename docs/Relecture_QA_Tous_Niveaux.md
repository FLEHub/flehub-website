# Relecture QA — tous les niveaux MFK (A1 → C2)

Passe centralisée sur les **44 modules** existants du cour *Le Seuil des Sources* (Rukiri-Nord), plus le micro-monde du module A1-1 (*La Colline*, Kimisagara).

Les seeds d’origine **n’ont pas été réécrits**. Les correctifs sont des **UPDATE idempotents** :

| Migration | Niveau |
|-----------|--------|
| `20260906120000_elearning_mfk_qa_a1.sql` | A1 |
| `20260906120100_elearning_mfk_qa_a2.sql` | A2 |
| `20260906120200_elearning_mfk_qa_b1.sql` | B1 |
| `20260906120300_elearning_mfk_qa_b2.sql` | B2 |
| `20260906120400_elearning_mfk_qa_c1.sql` | C1 |
| `20260906120500_elearning_mfk_qa_c2.sql` | C2 |

Aucune table nouvelle. `published` n’est pas modifié. Structure (6×5×10, ou 4×5×10 pour A1-1) inchangée.

Les générateurs C1/C2 (`scripts/mfk_c1c2/`) ont aussi reçu les mêmes règles d’élision, pour qu’une régénération future ne réintroduise pas les fautes. Cela ne change pas le mécanisme de seed (fonctions `pg_temp`, upsert, ordre des exercices).

---

## Méthode

1. Lecture des 44 seeds (`$c$` leçons + `$j$` exercices), niveau par niveau, A1 → C2.
2. Croisement avec les relectures déjà faites à la génération (`docs/Relecture_MFK_A1_Module3.md` … `C1-C2`).
3. Scanner (`scripts/mfk_qa/scan.py`) puis filtrage des faux positifs (formes *volontairement* fautives des `find_error` / distracteurs QCM ; clés JSON en ASCII).
4. Correctifs ciblés A1–B2 ; correctifs systématiques C1/C2 (générateur à kernel).

**Hors périmètre volontaire**

- Phrases-pièges (`sentence_with_error`) et distracteurs qui enseignent *à le*, *de le*, *je vas*, etc.
- Objectifs de communication et points de grammaire : pas de nouveau contenu pédagogique.
- A1 module 1 reste le kiosque *La Colline* (Inès Kalisa, Yvan, Sonia, Didier, Noël) : ce n’est pas une fuite, c’est le premier micro-monde.
- *Cahier du chemin* et *Cahier des racines* sont **deux objets** de l’univers : pas de fusion.
- *Les Trois Paniers* (A1-3) et *Marché des Lampions* sont deux marchés inventés, pas une contradiction.
- Habitants de second plan déjà installés depuis A1 : Noura Sarr, Ibrahim Tchami, Benoît Habumuremyi, Kévin Nkurunziza, Claire Mukamana, Yvette Mukeshimana. Conservés.
- A2-6 *Après + infinitif* : point de langue du module, non remplacé par *après avoir + PP*.

---

## Décompte global (français / typographie)

| Zone | Nature | Nombre (approx.) |
|------|--------|------------------|
| A1 | élision, doubles espaces, indices d’anagramme | **13** |
| A2 | titre *Feuille de la une*, casse *Cahier du chemin* | **2** |
| B1 | — (le matching est un correctif de vraisemblance) | **0** |
| B2 | *hypothèsons*, *hypothétisé*, *Veillée des Lampions*, *puisqu’une* | **4** |
| C1/C2 | *que une/un* → *qu’une/un* | **~330** |
| C1/C2 | *de le / de les / de une / de un* → *du / des / d’une / d’un* | **~80** |
| C1/C2 | *de Aline/Oscar/Inès* → *d’…* (phrases correctes) | **~20** |
| C1/C2 | accord *présenté / présentée* (sujet féminin seulement) | **~35** |
| C1/C2 | double deux-points *celle-ci : X : Y* → *X — Y* | **dizaines** (leçons où la proposition contenait déjà `:`) |
| C1/C2 | nettoyage des préfixes de locuteurs doublés | **72 débats CO** + copies CE/PO/PE |

**Total des corrections de français / typographie : environ 500 surfaces** (une même faute de générateur apparaît souvent dans CO, CE, PO, PE et les explications d’exercices).

Les guillemets ASCII des clés JSON sont **normatifs** (JSON) ; les citations apprenant des seeds A1–B2 étaient déjà en « ». Pas de passe massive d’espaces insécables avant `: ; ! ?` : les dialogues du Seuil utilisent déjà `Nom : réplique`, convention conservée.

---

# A1

## A1-1 — Premiers repères

**Univers :** kiosque-bibliothèque *La Colline* (Kimisagara). Aucune fuite Seuil.

**Vraisemblance corrigée**

- Six indices d’anagramme révélaient le mot-cible (`parle`, `livre`, `stylo`, `cahier`, `table`, `stylo`). Indices réécrits sans le mot.

**Français / typo**

- Titre CO : *sous le auvent* → *sous l’auvent*.
- Fiches nombres 0–20 et *être* : doubles espaces retirés.

**Ortho/typo : 13.**

## A1-3 — S’orienter et s’installer

Aucun correctif. Relecture seed déjà propre. *Les Trois Paniers* conservé (marché distinct du *Marché des Lampions*).

**Ortho/typo : 0.**

## A1-4 — Portraits croisés

Aucun correctif. Famille Claire / Mireille / Éric / Nina = Seuil.

**Ortho/typo : 0.**

## A1-5 — Le fil des journées

Aucun correctif. Introduction du *Marché des Lampions* cohérente.

**Ortho/typo : 0.**

## A1-6 — Histoires vécues

**Vraisemblance corrigée**

- CO *Yvette a choisi la colline* : le dialogue ne disait que l’infirmerie. Réplique ajoutée : *J’ai choisi la colline. Maintenant, je suis ici. Je travaille à l’Infirmerie des Herbes.* (la colline = Rukiri-Nord, pas le kiosque A1-1). Titre et modèles PO *J’ai choisi la colline* conservés : ils correspondent maintenant au support.

**Ortho/typo : 0.**

## A1-7 — Cap sur ailleurs

Aucun correctif. Lieux inventés (Auberge des Figues, lac des Nénuphars) stables.

**Ortho/typo : 0.**

## A1-8 — Gestes du quotidien

Aucun correctif.

**Ortho/typo : 0.**

## A1-9 — Retour sur le chemin parcouru

Aucun correctif. Rappel Noura (A1-7) voulu comme bilan.

**Ortho/typo : 0.**

---

# A2

## A2-1 — Escale en France

Aucun correctif. Lieux A2 (*Mwezi-Haut*, *Bureau des Escales*, *Port de la Brise*) cohérents en interne.

**Ortho/typo : 0.**

## A2-2 — Aventures partagées

Aucun correctif. Kévin Nkurunziza = second plan A1.

**Ortho/typo : 0.**

## A2-3 — Un métier en français

Aucun correctif.

**Ortho/typo : 0.**

## A2-4 — Cultures en partage

**Vraisemblance corrigée**

- S5 CO : Noura demandait s’il fallait *allumer* toutes les lanternes ; PE, V/F et matching de la même séquence portent sur *éteindre à minuit*. Réplique alignée : *Faut-il éteindre les lanternes à minuit ?*

**Ortho/typo : 0.**

## A2-5 — Vivre ensemble autrement

Aucun correctif.

**Ortho/typo : 0.**

## A2-6 — Petits gestes, grand quotidien

Aucun correctif. *Après + infinitif* laissé comme point du module.

**Ortho/typo : 0.**

## A2-7 — Mémoire et engagement

Aucun correctif. *Cahier des racines* conservé (carnet de mémoire, distinct du *Cahier du chemin*).

**Ortho/typo : 0.**

## A2-8 — Le monde en direct

**Vraisemblance / français**

- Titre et support *Feuille de une* → *Feuille de la une* (calque journalistique corrigé).
- *le cahier du Chemin* → *le Cahier du chemin*.
- *Cahier des racines* dans le bulletin passif : conservé (même objet qu’en A2-7).

**Ortho/typo : 2.**

---

# B1

## B1-1 — Ailleurs, un nouveau chez-soi

**Vraisemblance corrigée**

- Matching PE : *ne pas s’éloigner des restants* (calque artificiel) → *ne pas s’éloigner de ceux qui restent*, aligné sur le support de Rose.

*À le Seuil* n’apparaît que dans `sentence_with_error` ; la phrase correcte a *Au Seuil*.

**Ortho/typo : 0.**

## B1-2 — S’installer autrement

Aucun correctif.

**Ortho/typo : 0.**

## B1-3 — Organiser la fête

Aucun correctif. *Sami Niyonteze* : nom de famille inventé, conservé (précise le personnage, ne contredit pas *Sami*).

**Ortho/typo : 0.**

## B1-4 — Agir pour demain

Aucun correctif.

**Ortho/typo : 0.**

## B1-5 — Étudier et travailler autrement

Aucun correctif.

**Ortho/typo : 0.**

## B1-6 — S’informer, s’exprimer

Aucun correctif. *c’est que une* uniquement en phrase-piège + ligne d’alerte EL (*On n’écrit pas…*). Phrase correcte : *c’est une source nommée*.

**Ortho/typo : 0.**

## B1-7 — L’esprit d’innovation

Aucun correctif.

**Ortho/typo : 0.**

## B1-8 — Un monde de culture

Aucun correctif. Superlatifs et œuvre *La cour n’oublie pas* stables.

**Ortho/typo : 0.**

---

# B2

## B2-1 — Tendances du Seuil

Aucun correctif.

**Ortho/typo : 0.**

## B2-2 — Mémoire du Seuil

**Français**

- *nous hypothesons* → *nous hypothèsons*.
- Objectif CE : *hypothesé* → *hypothétisé*.

**Ortho/typo : 2.**

## B2-3 — Une culture commune

**Typographie**

- Description de module : *Veillée des lampions* → *Veillée des Lampions* (alignement B1-3).

**Ortho/typo : 1.**

## B2-4 — Vivre avec la technologie

**Français**

- Matching : *puisque une marque reste* → *puisqu’une marque reste* (le support PE était déjà juste).

**Ortho/typo : 1.**

## B2-5 — Questions de société

Aucun correctif. Noura = voix du minibus, déjà en B1.

**Ortho/typo : 0.**

## B2-6 — Faire évoluer la société

Aucun correctif.

**Ortho/typo : 0.**

## B2-7 — Agir au travail

Aucun correctif. *À le Seuil* seulement en phrase-piège.

**Ortho/typo : 0.**

## B2-8 — Modèles éducatifs

Aucun correctif. *il se peut que une* seulement en `sentence_with_error` ; correct = *qu’une*.

**Ortho/typo : 0.**

---

# C1

Les six modules C1 (et les six C2) viennent d’un kernel unique. Les mêmes défauts se répétaient à chaque séquence.

**Correctifs communs (tous les modules C1)**

1. *que une / que un* → *qu’une / qu’un* dans le texte normatif (leçons, explications, phrases correctes).
2. *On parle trop vite de le / de les / de une* → *du / des / d’une*.
3. Accord *est présenté* → *est présentée* seulement si l’item commence par *une / la*.
4. *La proposition qui reste debout est celle-ci : une tribune : …* → tiret cadratin à la place du second `:`.
5. Préfixes radio doublés (*Léa Niyonzima : Léa Niyonzima concède…* ; *Nina Kayitesi : Marc Nkurunziza : …*) nettoyés.
6. `find_error` PE : le même squelette *Les arguments de X est clairs, et Lila garde le micro ouvert* (72 fois) est réécrit en *Les propos de/d’X sur « [séquence] » est/sont nets…* — **une** faute (accord), élision *d’Aline / d’Oscar / d’Inès* déjà dans la phrase fautive pour ne pas en ajouter une seconde.

## C1-1 — La colline de demain

Vraisemblance : débats CO lisibles (plus de locuteur doublé). Français : élisions + *présentée* (*une tour*, *une action*). *le parking… est présenté* laissé au masculin.

**Ortho/typo : ~40 surfaces.**

## C1-2 — Faims du figuier

*de le marketing* → *du marketing* ; *de les rations / plaisirs* → *des…* ; *concède qu’une belle enseigne*. *d’Oscar* dans le `find_error` PE.

**Ortho/typo : ~55 surfaces.**

## C1-3 — Soigner autrement

*de le parcours / podcast* → *du…* ; *des infusions* ; *qu’une infusion*. *d’Inès / d’Aline* aux PE concernés.

**Ortho/typo : ~60 surfaces.**

## C1-4 — Corps visibles

*du regard*, *des gestes*, *du manifeste* ; *qu’une assemblée / lecture / toile*.

**Ortho/typo : ~50 surfaces.**

## C1-5 — Le monde de la cour

**Anti-copyright / univers**

- *une terre d’accueil se mesure aux clés* (formule trop proche d’un dossier manuel) → *un accueil de cour se mesure aux clés*.
- Pictogramme `terre-accueil.svg` → `accueil-cles.svg` (libellé *accueil clés*).

**Ortho/typo : ~50 surfaces + 1 réécriture d’univers.**

## C1-6 — Travailler au Seuil

*des ailleurs*, *des voix croisées*, *du travail au Seuil* ; *qu’une phrase courte* (accroche). *d’Aline* en PE analyse.

**Ortho/typo : ~45 surfaces.**

---

# C2

Mêmes correctifs de générateur qu’en C1.

## C2-1 — Bonheurs et utopies

**Anti-copyright**

- Mot et fichier *routinite* (reprise reconnaissable) → *joie-horloge* / `joie-horloge.svg` (bonheur à l’heure dite, thème déjà du module).

*du bonheur*, *du chien de Basile* ; *qu’une joie / lettre / liberté / perfection*. *d’Inès* en PE.

**Ortho/typo : ~55 surfaces + 1 réécriture d’univers.**

## C2-2 — Parler nos français

*des mots voyageurs*, *du concours* ; *qu’une pureté / éloquence*. *d’Aline* en PE.

**Ortho/typo : ~50 surfaces.**

## C2-3 — L’ère du fil

**Anti-copyright**

- `affiche-gaffe.svg` (écho *fais gaffe*) → `campagne-deux-tons.svg` / *campagne-deux-tons*.

*du fil et du Cahier* ; *d’une campagne* ; *qu’une rumeur / fierté / simplicité*.

**Ortho/typo : ~50 surfaces + 1 réécriture d’univers.**

## C2-4 — Ce que le figuier se souvient

**Anti-copyright**

- `souvenons-nous.svg` → `pacte-rive.svg` / *pacte-rive*.

*des pactes* ; *qu’une formule / forme soignée* (Yvette, Lila).

**Ortho/typo : ~60 surfaces + 1 réécriture d’univers.**

## C2-5 — Cultures croisées

**Vraisemblance**

- Beat cryptique *Hawa garde le tarif.* → *Hawa garde le tarif bas dans sa version, sans le crier.*
- *Hawa concède le mot généreux, pas le tarif* précisé de la même façon.

*des premiers mois d’Hawa*, *du débat* ; *qu’une tendance / synthèse*. *d’Aline* en PE.

**Ortho/typo : ~50 surfaces + 1 réécriture de beat.**

## C2-6 — Révolutions de la rive

**Anti-copyright**

- Mot / fichier *rapport alarmant* → *hypothèse de crue* / `hypothese-crue.svg`.

*du déni poli* ; *qu’une fierté*. *d’Oscar / d’Aline* en PE.

**Ortho/typo : ~55 surfaces + 1 réécriture d’univers.**

---

## Fichiers graphiques renommés

| Ancien | Nouveau | Raison |
|--------|---------|--------|
| `mfk-c2-m1/routinite.svg` | `joie-horloge.svg` | mot de manuel |
| `mfk-c2-m3/affiche-gaffe.svg` | `campagne-deux-tons.svg` | écho *fais gaffe* |
| `mfk-c2-m4/souvenons-nous.svg` | `pacte-rive.svg` | titre de dossier |
| `mfk-c2-m6/rapport-alarmant.svg` | `hypothese-crue.svg` | titre de dossier |
| `mfk-c1-m5/terre-accueil.svg` | `accueil-cles.svg` | formule trop typée |

Les chemins `image_match` et `scripts/mfk_c1c2/draw.py` suivent les nouveaux slugs.

---

## Ce qui n’a pas été changé (décisions)

| Élément | Décision |
|---------|----------|
| Structure, types, `order_index`, `published` | inchangés |
| Seeds `202608*` / `2026090412*` | non édités |
| A1-1 *La Colline* | micro-monde distinct, documenté |
| Deux cahiers, deux marchés | objets distincts de l’univers |
| Cast de second plan | conservé |
| *Après + infinitif* (A2-6) | point de grammaire du module |
| Phrases-pièges | restent fautives |

---

## Outils

- `scripts/mfk_qa/scan.py` — extraction et drapeaux (à relire : beaucoup de faux positifs pédagogiques).
- `scripts/mfk_qa/fr_fix.py` + `emit_updates.py` — régénèrent les six migrations UPDATE si besoin.

Pour réémettre les UPDATE après un ajustement de règle :

```bash
cd scripts/mfk_qa && python3 emit_updates.py
```
