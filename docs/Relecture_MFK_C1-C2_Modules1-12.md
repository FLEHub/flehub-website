# Relecture MFK — C1-C2

Étape **séparée**, après rédaction des 360 supports et des 3 600 exercices.
Aucun texte A1, A2, B1 ni B2 n'a été modifié. Les modules restent en brouillon (`published = false`).

## Méthode

1. Analyse du tableau des contenus de Cosmopolite 5 (12 dossiers × 4 leçons) : **objectifs génériques seulement**.
2. Génération via `scripts/mfk_c1c2/generate.py` (même architecture que B2 : 6 séquences × 5 leçons × 10 types, PE *Imitez*, SVG, `published = false`).
3. Univers **Le Seuil des Sources**, Rukiri-Nord. Personnages établis + Nina Kayitesi, Oscar Niyitegeka, Inès Mukama, Basile Habiyaremye.
4. Contrôle anti-copyright : pas de textes, dialogues, lieux, personnages ni titres caractéristiques du manuel dans le seed SQL.

Les phrases volontairement fautives des `find_error` restent fautives ; seule la phrase correcte est normative.

## Correspondance avec Cosmopolite 5

| Module MFK | Niveau | Dossier de référence | Thème | Objectifs |
|------------|--------|----------------------|-------|-----------|
| C1-1 — La colline de demain | C1 | Dossier 1 — urbanisme, logement, mobilité, ville imaginaire | La colline future / habitat / circulation / hypotypose | 6 séquences, 30 leçons, 300 exercices |
| C1-2 — Faims du figuier | C1 | Dossier 2 — alimentation, données, agriculture, outils d'achat | Faim, chiffres, rive, marché, marketing, notices | 6 séquences, 30 leçons, 300 exercices |
| C1-3 — Soigner autrement | C1 | Dossier 3 — soin, enquête, formation, thérapies de cour | Parcours, Filtre, journal, herbe, conférence, podcast | 6 séquences, 30 leçons, 300 exercices |
| C1-4 — Corps visibles | C1 | Dossier 4 — image de soi, accès, gestes, œuvre | Regard, rampe, idiomes, lin, manifeste, audioguide | 6 séquences, 30 leçons, 300 exercices |
| C1-5 — Le monde de la cour | C1 | Dossier 5 — chant, biographie, accueil, âges | Refrain, Solange, clé, registres, diptyque, comparaison | 6 séquences, 30 leçons, 300 exercices |
| C1-6 — Travailler au Seuil | C1 | Dossier 6 — organisation du travail, recrutement, crise, ailleurs | Revue, accroche, atelier, ailleurs, témoignages, motion | 6 séquences, 30 leçons, 300 exercices |
| C2-1 — Bonheurs et utopies | C2 | Dossier 7 — scène, bonheur mesuré, médiation animale, utopie | Interprétation, joie obligatoire, Basile, rive rêvée | 6 séquences, 30 leçons, 300 exercices |
| C2-2 — Parler nos français | C2 | Dossier 8 — emprunts, politiques de voix, registres, oral | Mots voyageurs, micro, extraits, éloquence | 6 séquences, 30 leçons, 300 exercices |
| C2-3 — L'ère du fil | C2 | Dossier 9 — fil et livres, prévention, bruits, dystopie | Cahier, campagne, rumeur, paradoxe, extrait | 6 séquences, 30 leçons, 300 exercices |
| C2-4 — Ce que le figuier se souvient | C2 | Dossier 10 — pédagogie, pactes, mémoire, plaidoirie de cour | Support, éditorial, veillée, Bureau des Escales | 6 séquences, 30 leçons, 300 exercices |
| C2-5 — Cultures croisées | C2 | Dossier 11 — culture partagée, rire, signes, récit | Salle, sketch, lin, Pavillon, implicite, débat | 6 séquences, 30 leçons, 300 exercices |
| C2-6 — Révolutions de la rive | C2 | Dossier 12 — climat de rive, déni, mesures, personnage | Crue, visite, programme, roman, compte-rendu | 6 séquences, 30 leçons, 300 exercices |

Répartition naturelle retenue : **dossiers 1–6 → C1** (modules C1-1 à C1-6), **dossiers 7–12 → C2** (modules C2-1 à C2-6).
Les quatre leçons de chaque dossier deviennent les séquences 1–4 ; les séquences 5–6 sont des prolongements originaux (recommandation / synthèse / tâche finale).

# C1

## Module C1-1 — La colline de demain

Illustrations : `/elearning/mfk-c1-m1/` (30 SVG). Seed : voir liste des migrations.

### Séquence 1 — La colline future

- **Objectif communicatif** : Rendre compte de deux regards sur la colline future sans les fusionner.
- **Compétences** : CO (débat Radio Figuier) → CE (article / tribune) → PO (modèles) → PE (Imitez) → EL (fiche).
- **Objectif linguistique** : nominalisation ; encore que / pour autant que + subjonctif
- **Vocabulaire** : u, r, b, a, n, i, s, m, e, ,,  , d, e, n, s, i, f, i, c, a, t, i, o, n, ,,  , m, i, x, i, t, é, ,,  , f, r, i, c, h, e.
- **Résumé du support** : la colline de demain. Slogan discuté : « colline de demain ». Implicite : L'effacement possible du mot figuier. Documents : le calque de Nina Kayitesi / la tribune de Marc Nkurunziza.
- **Tâche** : garder deux voix dans le compte-rendu et une rampe avant les lanternes nouvelles
- **Difficulté** : C1 — implicite, concession, hypotaxe, collocation.
- **Illustration** : pictogrammes géométriques du dossier `mfk-c1-m1` (tous utilisés en `image_match`).
- **Points de vigilance** : nom_conc ; PE doit contenir *Imitez* ; anagrammes sans le mot-cible dans l'indice ; `word_order` sans virgule.
- **À vérifier en relecture** : l'implicite de « colline de demain » n'est pas évident ; les distracteurs QCM restent plausibles ; aucune formule reconnaissable du manuel ; personnages = Seuil seulement.

### Séquence 2 — Habiter autrement

- **Objectif communicatif** : Dégager l'essentiel de deux documents sur l'habitat partagé et en rédiger la synthèse.
- **Compétences** : CO (débat Radio Figuier) → CE (article / tribune) → PO (modèles) → PE (Imitez) → EL (fiche).
- **Objectif linguistique** : synthèse ; ce dont / ce à quoi ; relatives complexes
- **Vocabulaire** : s, y, n, t, h, è, s, e, ,,  , h, a, b, i, t, a, t, ,,  , s, i, l, e, n, c, e, ,,  , c, l, é.
- **Résumé du support** : l'habitat partagé du Pavillon du Saule. Slogan discuté : « toit commun ». Implicite : Plus de témoins, moins de portes. Documents : la chronique de Lila Sow / l'entretien écrit de Dieudonné Hakizimana.
- **Tâche** : écrire une synthèse qui retienne loyers, heures calmes et ce dont personne ne veut parler : la clé
- **Difficulté** : C1 — implicite, concession, hypotaxe, collocation.
- **Illustration** : pictogrammes géométriques du dossier `mfk-c1-m1` (tous utilisés en `image_match`).
- **Points de vigilance** : rel_synthese ; PE doit contenir *Imitez* ; anagrammes sans le mot-cible dans l'indice ; `word_order` sans virgule.
- **À vérifier en relecture** : l'implicite de « toit commun » n'est pas évident ; les distracteurs QCM restent plausibles ; aucune formule reconnaissable du manuel ; personnages = Seuil seulement.

### Séquence 3 — Circuler à Rukiri-Nord

- **Objectif communicatif** : Faire des recommandations pour une mobilité qui n'écrase pas la pente.
- **Compétences** : CO (débat Radio Figuier) → CE (article / tribune) → PO (modèles) → PE (Imitez) → EL (fiche).
- **Objectif linguistique** : il convient que / il s'agit de ; recommandations
- **Vocabulaire** : m, o, b, i, l, i, t, é, ,,  , t, r, o, t, t, o, i, r, ,,  , r, e, l, a, i, s, ,,  , r, e, c, o, m, m, a, n, d, a, t, i, o, n.
- **Résumé du support** : la mobilité sur la pente de Rukiri-Nord. Slogan discuté : « fluidifier la colline ». Implicite : Les camions avant les genoux. Documents : l'émission de Radio Figuier / la note de Nina Kayitesi sur la pente.
- **Tâche** : un relais humain, un trottoir nommé, un camion plus rare à l'heure de la soupe
- **Difficulté** : C1 — implicite, concession, hypotaxe, collocation.
- **Illustration** : pictogrammes géométriques du dossier `mfk-c1-m1` (tous utilisés en `image_match`).
- **Points de vigilance** : reco ; PE doit contenir *Imitez* ; anagrammes sans le mot-cible dans l'indice ; `word_order` sans virgule.
- **À vérifier en relecture** : l'implicite de « fluidifier la colline » n'est pas évident ; les distracteurs QCM restent plausibles ; aucune formule reconnaissable du manuel ; personnages = Seuil seulement.

### Séquence 4 — Midi sans ombre

- **Objectif communicatif** : Décrire une Rukiri-Nord imaginaire pour faire entendre une peur vraie.
- **Compétences** : CO (débat Radio Figuier) → CE (article / tribune) → PO (modèles) → PE (Imitez) → EL (fiche).
- **Objectif linguistique** : conditionnel d'hypotypose ; comme si ; on dirait que
- **Vocabulaire** : h, y, p, o, t, y, p, o, s, e, ,,  , o, m, b, r, e, ,,  , t, o, u, r, ,,  , r, a, c, i, n, e.
- **Résumé du support** : une Rukiri-Nord trop lisse. Slogan discuté : « ville parfaite ». Implicite : Plus le droit de s'asseoir. Documents : l'extrait inventé de Mado / la photo de la pente prise par Léa.
- **Tâche** : écrire la colline comme si les racines parlaient, puis revenir au banc réel
- **Difficulté** : C1 — implicite, concession, hypotaxe, collocation.
- **Illustration** : pictogrammes géométriques du dossier `mfk-c1-m1` (tous utilisés en `image_match`).
- **Points de vigilance** : hypotypose ; PE doit contenir *Imitez* ; anagrammes sans le mot-cible dans l'indice ; `word_order` sans virgule.
- **À vérifier en relecture** : l'implicite de « ville parfaite » n'est pas évident ; les distracteurs QCM restent plausibles ; aucune formule reconnaissable du manuel ; personnages = Seuil seulement.

### Séquence 5 — Recommandations pour la colline

- **Objectif communicatif** : Transformer l'analyse en motion claire pour l'assemblée sous le figuier.
- **Compétences** : CO (débat Radio Figuier) → CE (article / tribune) → PO (modèles) → PE (Imitez) → EL (fiche).
- **Objectif linguistique** : connecteurs de recommandation ; il convient que ; en vue de
- **Vocabulaire** : m, o, t, i, o, n, ,,  , d, e, s, t, i, n, a, t, a, i, r, e, ,,  , r, a, m, p, e, ,,  , a, s, s, e, m, b, l, é, e.
- **Résumé du support** : la motion de la colline. Slogan discuté : « passer à l'action ». Implicite : Ne plus entendre ceux qui marchent lentement. Documents : les notes d'assemblée d'Aline / le brouillon de Solange.
- **Tâche** : trois gestes datés : rampe, relais, heures de camions, signés par le Bureau des Escales
- **Difficulté** : C1 — implicite, concession, hypotaxe, collocation.
- **Illustration** : pictogrammes géométriques du dossier `mfk-c1-m1` (tous utilisés en `image_match`).
- **Points de vigilance** : reco ; PE doit contenir *Imitez* ; anagrammes sans le mot-cible dans l'indice ; `word_order` sans virgule.
- **À vérifier en relecture** : l'implicite de « passer à l'action » n'est pas évident ; les distracteurs QCM restent plausibles ; aucune formule reconnaissable du manuel ; personnages = Seuil seulement.

### Séquence 6 — Compte-rendu 2040

- **Objectif communicatif** : Rendre compte oralement de deux documents sur la colline, horizon inventé 2040.
- **Compétences** : CO (débat Radio Figuier) → CE (article / tribune) → PO (modèles) → PE (Imitez) → EL (fiche).
- **Objectif linguistique** : selon / d'après / il ressort que ; attribution des sources
- **Vocabulaire** : h, o, r, i, z, o, n, ,,  , a, t, t, r, i, b, u, t, i, o, n, ,,  , g, e, s, t, e, ,,  , s, o, u, r, c, e.
- **Résumé du support** : un horizon 2040 sous le figuier. Slogan discuté : « Rukiri-Nord 2040 ». Implicite : Ne plus répondre des camions d'aujourd'hui. Documents : le calque annoté « 2040 » / la chronique de Marc pour Radio Figuier.
- **Tâche** : un oral de quatre minutes : deux sources, un désaccord, un geste 2026 qui rend 2040 habitable
- **Difficulté** : C1 — implicite, concession, hypotaxe, collocation.
- **Illustration** : pictogrammes géométriques du dossier `mfk-c1-m1` (tous utilisés en `image_match`).
- **Points de vigilance** : compte_rendu ; PE doit contenir *Imitez* ; anagrammes sans le mot-cible dans l'indice ; `word_order` sans virgule.
- **À vérifier en relecture** : l'implicite de « Rukiri-Nord 2040 » n'est pas évident ; les distracteurs QCM restent plausibles ; aucune formule reconnaissable du manuel ; personnages = Seuil seulement.

---

## Module C1-2 — Faims du figuier

Illustrations : `/elearning/mfk-c1-m2/` (30 SVG). Seed : voir liste des migrations.

### Séquence 1 — Le creux a un nom

- **Objectif communicatif** : Définir une faim qui n'est pas seulement le ventre et relier goûts et émotions.
- **Compétences** : CO (débat Radio Figuier) → CE (article / tribune) → PO (modèles) → PE (Imitez) → EL (fiche).
- **Objectif linguistique** : définir une notion ; cause émotionnelle ; nominalisation des sensations
- **Vocabulaire** : s, e, n, s, a, t, i, o, n, ,,  , a, p, p, é, t, i, t, ,,  , s, o, l, i, t, u, d, e, ,,  , r, e, c, u, e, i, l.
- **Résumé du support** : la faim qui n'est pas seulement le ventre. Slogan discuté : « juste un creux ». Implicite : Ne pas nommer la solitude de midi. Documents : l'article du Cahier du chemin / le livre lu à voix haute par Mado.
- **Tâche** : un recueil de plaisirs minuscules qui nomme l'émotion sans la moraliser
- **Difficulté** : C1 — implicite, concession, hypotaxe, collocation.
- **Illustration** : pictogrammes géométriques du dossier `mfk-c1-m2` (tous utilisés en `image_match`).
- **Points de vigilance** : nom_conc ; PE doit contenir *Imitez* ; anagrammes sans le mot-cible dans l'indice ; `word_order` sans virgule.
- **À vérifier en relecture** : l'implicite de « juste un creux » n'est pas évident ; les distracteurs QCM restent plausibles ; aucune formule reconnaissable du manuel ; personnages = Seuil seulement.

### Séquence 2 — Un tiers n'est pas une morale

- **Objectif communicatif** : Restituer des données inventées du Filtre des Herbes sans en faire une sentence.
- **Compétences** : CO (débat Radio Figuier) → CE (article / tribune) → PO (modèles) → PE (Imitez) → EL (fiche).
- **Objectif linguistique** : commenter des chiffres ; s'établir à ; alors que
- **Vocabulaire** : s, t, a, t, i, s, t, i, q, u, e, ,,  , r, a, t, i, o, n, ,,  , g, r, a, p, h, i, q, u, e, ,,  , r, a, p, p, o, r, t.
- **Résumé du support** : les rations inventées du Filtre des Herbes. Slogan discuté : « les chiffres parlent d'eux-mêmes ». Implicite : Ne plus poser de questions au rapport. Documents : le graphique du Filtre des Herbes / l'entretien d'Oscar au Marché des Herbes.
- **Tâche** : un article qui cite le Filtre, oppose alors que, et refuse la sentence
- **Difficulté** : C1 — implicite, concession, hypotaxe, collocation.
- **Illustration** : pictogrammes géométriques du dossier `mfk-c1-m2` (tous utilisés en `image_match`).
- **Points de vigilance** : stats ; PE doit contenir *Imitez* ; anagrammes sans le mot-cible dans l'indice ; `word_order` sans virgule.
- **À vérifier en relecture** : l'implicite de « les chiffres parlent d'eux-mêmes » n'est pas évident ; les distracteurs QCM restent plausibles ; aucune formule reconnaissable du manuel ; personnages = Seuil seulement.

### Séquence 3 — La terre n'est pas un caprice

- **Objectif communicatif** : Analyser et commenter un fait de société : la colère de ceux qui font pousser.
- **Compétences** : CO (débat Radio Figuier) → CE (article / tribune) → PO (modèles) → PE (Imitez) → EL (fiche).
- **Objectif linguistique** : cause et conséquence avancées ; du fait que ; si bien que
- **Vocabulaire** : c, o, l, è, r, e, ,,  , t, e, r, r, e, ,,  , f, i, l, e, ,,  , e, x, p, o, s, é.
- **Résumé du support** : la colère des jardiniers de la rive. Slogan discuté : « ils exagèrent ». Implicite : Refus d'entendre le prix réel. Documents : le récit d'Oscar au Cahier des racines / le reportage inventé de Lila au marché.
- **Tâche** : un exposé qui nomme Oscar, la file, le prix, et ce que la cour peut décider dès jeudi
- **Difficulté** : C1 — implicite, concession, hypotaxe, collocation.
- **Illustration** : pictogrammes géométriques du dossier `mfk-c1-m2` (tous utilisés en `image_match`).
- **Points de vigilance** : cause ; PE doit contenir *Imitez* ; anagrammes sans le mot-cible dans l'indice ; `word_order` sans virgule.
- **À vérifier en relecture** : l'implicite de « ils exagèrent » n'est pas évident ; les distracteurs QCM restent plausibles ; aucune formule reconnaissable du manuel ; personnages = Seuil seulement.

### Séquence 4 — Choisir au marché

- **Objectif communicatif** : Conseiller des achats sans ordonner, et peser une application inventée.
- **Compétences** : CO (débat Radio Figuier) → CE (article / tribune) → PO (modèles) → PE (Imitez) → EL (fiche).
- **Objectif linguistique** : conseil atténué ; on ferait mieux de ; il vaudrait mieux que
- **Vocabulaire** : é, t, i, q, u, e, t, t, e, ,,  , s, c, o, r, e, ,,  , a, p, p, l, i, c, a, t, i, o, n, ,,  , c, o, n, s, e, i, l.
- **Résumé du support** : l'application inventée Fil-des-Herbes. Slogan discuté : « mieux choisir ». Implicite : Obéir à un écran plutôt qu'à une file. Documents : la notice du Fil-des-Herbes / l'émission de Lila au Marché des Herbes.
- **Tâche** : échanger avantages et limites du Fil-des-Herbes, puis garder l'étiquette lue deux fois
- **Difficulté** : C1 — implicite, concession, hypotaxe, collocation.
- **Illustration** : pictogrammes géométriques du dossier `mfk-c1-m2` (tous utilisés en `image_match`).
- **Points de vigilance** : conseil ; PE doit contenir *Imitez* ; anagrammes sans le mot-cible dans l'indice ; `word_order` sans virgule.
- **À vérifier en relecture** : l'implicite de « mieux choisir » n'est pas évident ; les distracteurs QCM restent plausibles ; aucune formule reconnaissable du manuel ; personnages = Seuil seulement.

### Séquence 5 — Débat marketing

- **Objectif communicatif** : Débattre du marketing du Marché des Lampions sans slogan contre slogan.
- **Compétences** : CO (débat Radio Figuier) → CE (article / tribune) → PO (modèles) → PE (Imitez) → EL (fiche).
- **Objectif linguistique** : certes… mais ; encore que ; avantages et inconvénients
- **Vocabulaire** : a, f, f, i, c, h, e, ,,  , m, a, r, k, e, t, i, n, g, ,,  , p, r, o, m, e, s, s, e, ,,  , p, u, b, l, i, c, i, t, é.
- **Résumé du support** : le marketing du Marché des Lampions. Slogan discuté : « le brillant rend heureux ». Implicite : Ne plus demander qui a planté. Documents : l'affiche du Marché des Lampions / la chronique de Karim.
- **Tâche** : un débat : avantages d'une enseigne claire, inconvénients d'un bonheur collé au sel
- **Difficulté** : C1 — implicite, concession, hypotaxe, collocation.
- **Illustration** : pictogrammes géométriques du dossier `mfk-c1-m2` (tous utilisés en `image_match`).
- **Points de vigilance** : nom_conc ; PE doit contenir *Imitez* ; anagrammes sans le mot-cible dans l'indice ; `word_order` sans virgule.
- **À vérifier en relecture** : l'implicite de « le brillant rend heureux » n'est pas évident ; les distracteurs QCM restent plausibles ; aucune formule reconnaissable du manuel ; personnages = Seuil seulement.

### Séquence 6 — Huit notices sous le figuier

- **Objectif communicatif** : Composer un recueil de plaisirs minuscules ancré dans le Seuil, sans morale lourde.
- **Compétences** : CO (débat Radio Figuier) → CE (article / tribune) → PO (modèles) → PE (Imitez) → EL (fiche).
- **Objectif linguistique** : écriture créative encadrée ; nominalisation des sensations
- **Vocabulaire** : p, l, a, i, s, i, r, ,,  , n, o, t, i, c, e, ,,  , o, m, b, r, e, ,,  , f, e, u, i, l, l, e.
- **Résumé du support** : les plaisirs minuscules du figuier. Slogan discuté : « il faut jouir ». Implicite : Un ordre déguisé en joie. Documents : le recueil de Mado / les notes de Félicie au bas des pages.
- **Tâche** : huit notices de plaisir, au conditionnel parfois, sans injonction
- **Difficulté** : C1 — implicite, concession, hypotaxe, collocation.
- **Illustration** : pictogrammes géométriques du dossier `mfk-c1-m2` (tous utilisés en `image_match`).
- **Points de vigilance** : hypotypose ; PE doit contenir *Imitez* ; anagrammes sans le mot-cible dans l'indice ; `word_order` sans virgule.
- **À vérifier en relecture** : l'implicite de « il faut jouir » n'est pas évident ; les distracteurs QCM restent plausibles ; aucune formule reconnaissable du manuel ; personnages = Seuil seulement.

---

## Module C1-3 — Soigner autrement

Illustrations : `/elearning/mfk-c1-m3/` (30 SVG). Seed : voir liste des migrations.

### Séquence 1 — Dons et parcours

- **Objectif communicatif** : Reformuler les difficultés d'un parcours à l'Infirmerie des Herbes sans jargon abandonnant.
- **Compétences** : CO (débat Radio Figuier) → CE (article / tribune) → PO (modèles) → PE (Imitez) → EL (fiche).
- **Objectif linguistique** : passif ; reformulation d'un parcours ; vocabulaire du soin (inventé)
- **Vocabulaire** : p, a, r, c, o, u, r, s, ,,  , c, o, n, s, e, n, t, e, m, e, n, t, ,,  , j, a, r, g, o, n, ,,  , d, o, n.
- **Résumé du support** : le parcours à l'Infirmerie des Herbes. Slogan discuté : « il suffit d'attendre ». Implicite : La douleur n'a pas de place dans l'emploi du temps. Documents : les notes d'Hawa au Cahier des dons / la fiche trop technique d'un passage inventé.
- **Tâche** : un podcast qui reformule le parcours d'Hawa sans voler sa voix
- **Difficulté** : C1 — implicite, concession, hypotaxe, collocation.
- **Illustration** : pictogrammes géométriques du dossier `mfk-c1-m3` (tous utilisés en `image_match`).
- **Points de vigilance** : rel_synthese ; PE doit contenir *Imitez* ; anagrammes sans le mot-cible dans l'indice ; `word_order` sans virgule.
- **À vérifier en relecture** : l'implicite de « il suffit d'attendre » n'est pas évident ; les distracteurs QCM restent plausibles ; aucune formule reconnaissable du manuel ; personnages = Seuil seulement.

### Séquence 2 — Le graphique n'efface pas la peur

- **Objectif communicatif** : Rapporter une enquête du Filtre et expliciter une découverte sans triomphalisme.
- **Compétences** : CO (débat Radio Figuier) → CE (article / tribune) → PO (modèles) → PE (Imitez) → EL (fiche).
- **Objectif linguistique** : rapporter une enquête ; il apparaîtrait que ; modalisation
- **Vocabulaire** : e, n, q, u, ê, t, e, ,,  , d, é, c, o, u, v, e, r, t, e, ,,  , c, r, a, i, n, t, e, ,,  , é, c, h, a, n, t, i, l, l, o, n.
- **Résumé du support** : une découverte du Filtre des Herbes. Slogan discuté : « la science a parlé ». Implicite : Ne plus écouter une peur fondée. Documents : le rapport du Filtre / la conférence d'Inès sous le figuier.
- **Tâche** : une mini-conférence : résultat, limite, crainte légitime, geste de cour
- **Difficulté** : C1 — implicite, concession, hypotaxe, collocation.
- **Illustration** : pictogrammes géométriques du dossier `mfk-c1-m3` (tous utilisés en `image_match`).
- **Points de vigilance** : stats ; PE doit contenir *Imitez* ; anagrammes sans le mot-cible dans l'indice ; `word_order` sans virgule.
- **À vérifier en relecture** : l'implicite de « la science a parlé » n'est pas évident ; les distracteurs QCM restent plausibles ; aucune formule reconnaissable du manuel ; personnages = Seuil seulement.

### Séquence 3 — Une vie de formation

- **Objectif communicatif** : Raconter les difficultés d'une formation trop longue sans pathos de sacrifice.
- **Compétences** : CO (débat Radio Figuier) → CE (article / tribune) → PO (modèles) → PE (Imitez) → EL (fiche).
- **Objectif linguistique** : journal intime ; imparfait / plus-que-parfait ; modalisation du doute
- **Vocabulaire** : f, o, r, m, a, t, i, o, n, ,,  , j, o, u, r, n, a, l, ,,  , g, a, r, d, e, ,,  , v, o, c, a, t, i, o, n.
- **Résumé du support** : une formation trop longue au Seuil. Slogan discuté : « c'est le prix à payer ». Implicite : Interdiction de demander qui encaisse. Documents : le journal d'Aline / l'émission où l'on parle trop vite de vocation.
- **Tâche** : trois pages de journal : faits, doute, ce qui reste transmissible
- **Difficulté** : C1 — implicite, concession, hypotaxe, collocation.
- **Illustration** : pictogrammes géométriques du dossier `mfk-c1-m3` (tous utilisés en `image_match`).
- **Points de vigilance** : compte_rendu ; PE doit contenir *Imitez* ; anagrammes sans le mot-cible dans l'indice ; `word_order` sans virgule.
- **À vérifier en relecture** : l'implicite de « c'est le prix à payer » n'est pas évident ; les distracteurs QCM restent plausibles ; aucune formule reconnaissable du manuel ; personnages = Seuil seulement.

### Séquence 4 — L'herbe et la porte

- **Objectif communicatif** : Présenter une polémique sur les infusions de Solange sans caricature.
- **Compétences** : CO (débat Radio Figuier) → CE (article / tribune) → PO (modèles) → PE (Imitez) → EL (fiche).
- **Objectif linguistique** : présenter une polémique ; certains affirment / d'autres objectent
- **Vocabulaire** : p, o, l, é, m, i, q, u, e, ,,  , i, n, f, u, s, i, o, n, ,,  , s, u, i, v, i, ,,  , l, i, m, i, t, e.
- **Résumé du support** : les infusions de Solange Mukamana. Slogan discuté : « c'est naturel donc c'est sûr ». Implicite : Vendre une calme ignorance. Documents : la chronique de Solange / la mise au point d'Inès.
- **Tâche** : présenter deux positions, une limite, un geste : l'herbe n'efface pas la porte d'Inès
- **Difficulté** : C1 — implicite, concession, hypotaxe, collocation.
- **Illustration** : pictogrammes géométriques du dossier `mfk-c1-m3` (tous utilisés en `image_match`).
- **Points de vigilance** : cause ; PE doit contenir *Imitez* ; anagrammes sans le mot-cible dans l'indice ; `word_order` sans virgule.
- **À vérifier en relecture** : l'implicite de « c'est naturel donc c'est sûr » n'est pas évident ; les distracteurs QCM restent plausibles ; aucune formule reconnaissable du manuel ; personnages = Seuil seulement.

### Séquence 5 — Mini-conférence du Filtre

- **Objectif communicatif** : Tenir une mini-conférence claire : résultat, limite, geste.
- **Compétences** : CO (débat Radio Figuier) → CE (article / tribune) → PO (modèles) → PE (Imitez) → EL (fiche).
- **Objectif linguistique** : plan déductif ; il s'ensuit que ; en conséquence
- **Vocabulaire** : c, o, n, f, é, r, e, n, c, e, ,,  , d, é, d, u, c, t, i, o, n, ,,  , l, i, m, i, t, e, ,,  , r, e, c, o, m, m, a, n, d, a, t, i, o, n.
- **Résumé du support** : la mini-conférence sous le figuier. Slogan discuté : « faites confiance ». Implicite : Ne pas demander le plan. Documents : le plan d'Inès / les questions d'Hawa et de Karim.
- **Tâche** : un plan en trois temps : fait, limite, recommandation pour la cour
- **Difficulté** : C1 — implicite, concession, hypotaxe, collocation.
- **Illustration** : pictogrammes géométriques du dossier `mfk-c1-m3` (tous utilisés en `image_match`).
- **Points de vigilance** : reco ; PE doit contenir *Imitez* ; anagrammes sans le mot-cible dans l'indice ; `word_order` sans virgule.
- **À vérifier en relecture** : l'implicite de « faites confiance » n'est pas évident ; les distracteurs QCM restent plausibles ; aucune formule reconnaissable du manuel ; personnages = Seuil seulement.

### Séquence 6 — Podcast du parcours

- **Objectif communicatif** : Enregistrer un podcast qui rapporte un parcours médical inventé sans le voler.
- **Compétences** : CO (débat Radio Figuier) → CE (article / tribune) → PO (modèles) → PE (Imitez) → EL (fiche).
- **Objectif linguistique** : discours rapporté complexe ; elle a dit qu'elle / si
- **Vocabulaire** : p, o, d, c, a, s, t, ,,  , m, o, n, t, a, g, e, ,,  , s, i, l, e, n, c, e, ,,  , v, o, i, x.
- **Résumé du support** : le podcast de Radio Figuier sur le parcours. Slogan discuté : « donner la voix aux patients ». Implicite : Prendre la voix en prétendant la donner. Documents : le rush du podcast / les consignes d'Hawa sur ce qui ne se dit pas.
- **Tâche** : un épisode : Hawa, Inès, un silence gardé, une reformulation signalée
- **Difficulté** : C1 — implicite, concession, hypotaxe, collocation.
- **Illustration** : pictogrammes géométriques du dossier `mfk-c1-m3` (tous utilisés en `image_match`).
- **Points de vigilance** : disc_ind ; PE doit contenir *Imitez* ; anagrammes sans le mot-cible dans l'indice ; `word_order` sans virgule.
- **À vérifier en relecture** : l'implicite de « donner la voix aux patients » n'est pas évident ; les distracteurs QCM restent plausibles ; aucune formule reconnaissable du manuel ; personnages = Seuil seulement.

---

## Module C1-4 — Corps visibles

Illustrations : `/elearning/mfk-c1-m4/` (30 SVG). Seed : voir liste des migrations.

### Séquence 1 — Image de soi sous le figuier

- **Objectif communicatif** : Commenter une tendance du regard sans répéter les mots d'un fil.
- **Compétences** : CO (débat Radio Figuier) → CE (article / tribune) → PO (modèles) → PE (Imitez) → EL (fiche).
- **Objectif linguistique** : commenter une tendance ; on dirait que ; registre du regard
- **Vocabulaire** : r, e, g, a, r, d, ,,  , p, o, r, t, r, a, i, t, ,,  , t, e, n, d, a, n, c, e, ,,  , v, i, t, r, i, n, e.
- **Résumé du support** : le regard que la cour porte sur les corps. Slogan discuté : « sois toi-même ». Implicite : Une liste déguisée en liberté. Documents : les portraits trop nets du fil de la cour / le billet de Léa.
- **Tâche** : un billet pour le Cahier du chemin : tendance, implicite, geste de ne pas mesurer
- **Difficulté** : C1 — implicite, concession, hypotaxe, collocation.
- **Illustration** : pictogrammes géométriques du dossier `mfk-c1-m4` (tous utilisés en `image_match`).
- **Points de vigilance** : registre ; PE doit contenir *Imitez* ; anagrammes sans le mot-cible dans l'indice ; `word_order` sans virgule.
- **À vérifier en relecture** : l'implicite de « sois toi-même » n'est pas évident ; les distracteurs QCM restent plausibles ; aucune formule reconnaissable du manuel ; personnages = Seuil seulement.

### Séquence 2 — La planche n'est pas une rampe

- **Objectif communicatif** : Dénoncer ce que la cour rend invisible, notamment l'accès.
- **Compétences** : CO (débat Radio Figuier) → CE (article / tribune) → PO (modèles) → PE (Imitez) → EL (fiche).
- **Objectif linguistique** : dénoncer une inégalité ; relatives complexes ; il n'est que trop
- **Vocabulaire** : i, n, é, g, a, l, i, t, é, ,,  , r, a, m, p, e, ,,  , m, a, n, i, f, e, s, t, e, ,,  , a, c, c, è, s.
- **Résumé du support** : ce que la cour ne voit pas. Slogan discuté : « on s'adapte ». Implicite : Disparaître quand il pleut. Documents : le manifeste de Joël et de Léa / les minutes trop vagues de l'assemblée.
- **Tâche** : un manifeste : rampe, heures, bancs, signatures du Bureau des Escales
- **Difficulté** : C1 — implicite, concession, hypotaxe, collocation.
- **Illustration** : pictogrammes géométriques du dossier `mfk-c1-m4` (tous utilisés en `image_match`).
- **Points de vigilance** : cause ; PE doit contenir *Imitez* ; anagrammes sans le mot-cible dans l'indice ; `word_order` sans virgule.
- **À vérifier en relecture** : l'implicite de « on s'adapte » n'est pas évident ; les distracteurs QCM restent plausibles ; aucune formule reconnaissable du manuel ; personnages = Seuil seulement.

### Séquence 3 — Les épaules ne sont pas un verdict

- **Objectif communicatif** : Interpréter la gestuelle de la cour et des idiomes, sans les prendre pour des preuves.
- **Compétences** : CO (débat Radio Figuier) → CE (article / tribune) → PO (modèles) → PE (Imitez) → EL (fiche).
- **Objectif linguistique** : idiomes corporels ; ne pas les calquer ; interpréter un geste
- **Vocabulaire** : g, e, s, t, e, ,,  , i, d, i, o, m, e, ,,  , é, p, a, u, l, e, ,,  , s, l, a, m.
- **Résumé du support** : les gestes sous le figuier. Slogan discuté : « le corps ne ment pas ». Implicite : Cesser d'écouter les mots. Documents : les notes de Léa sur les gestes / le slam inventé de Sami.
- **Tâche** : interpréter trois gestes filmés par Léa, puis laisser à Rose le dernier mot
- **Difficulté** : C1 — implicite, concession, hypotaxe, collocation.
- **Illustration** : pictogrammes géométriques du dossier `mfk-c1-m4` (tous utilisés en `image_match`).
- **Points de vigilance** : registre ; PE doit contenir *Imitez* ; anagrammes sans le mot-cible dans l'indice ; `word_order` sans virgule.
- **À vérifier en relecture** : l'implicite de « le corps ne ment pas » n'est pas évident ; les distracteurs QCM restent plausibles ; aucune formule reconnaissable du manuel ; personnages = Seuil seulement.

### Séquence 4 — Le lin tient le geste

- **Objectif communicatif** : Analyser une œuvre inventée de Rose pour un audioguide.
- **Compétences** : CO (débat Radio Figuier) → CE (article / tribune) → PO (modèles) → PE (Imitez) → EL (fiche).
- **Objectif linguistique** : décrire une œuvre ; présent de reportage ; métaphore contrôlée
- **Vocabulaire** : œ, u, v, r, e, ,,  , a, u, d, i, o, g, u, i, d, e, ,,  , l, i, n, ,,  , h, y, p, o, t, h, è, s, e.
- **Résumé du support** : l'œuvre de Rose à la Salle des Herbes. Slogan discuté : « c'est beau point ». Implicite : Ne pas voir le corps trop réel. Documents : l'œuvre de Rose / le brouillon d'audioguide de Léa.
- **Tâche** : un audioguide de trois minutes : matériaux, geste, hypothèse, silence
- **Difficulté** : C1 — implicite, concession, hypotaxe, collocation.
- **Illustration** : pictogrammes géométriques du dossier `mfk-c1-m4` (tous utilisés en `image_match`).
- **Points de vigilance** : hypotypose ; PE doit contenir *Imitez* ; anagrammes sans le mot-cible dans l'indice ; `word_order` sans virgule.
- **À vérifier en relecture** : l'implicite de « c'est beau point » n'est pas évident ; les distracteurs QCM restent plausibles ; aucune formule reconnaissable du manuel ; personnages = Seuil seulement.

### Séquence 5 — Manifeste de la rampe

- **Objectif communicatif** : Écrire un manifeste qui exige sans insulter, et qui nomme des gestes.
- **Compétences** : CO (débat Radio Figuier) → CE (article / tribune) → PO (modèles) → PE (Imitez) → EL (fiche).
- **Objectif linguistique** : injonction vs subjonctif de volonté ; nous exigeons que
- **Vocabulaire** : m, a, n, i, f, e, s, t, e, ,,  , e, x, i, g, e, n, c, e, ,,  , s, i, g, n, a, t, u, r, e, ,,  , d, a, t, e.
- **Résumé du support** : le manifeste pour la rampe. Slogan discuté : « assez ». Implicite : N'avoir rien entendu. Documents : le manifeste / les ratures de Solange et d'Aline.
- **Tâche** : un manifeste signé : rampe, bancs, pluie, fer, jeudi
- **Difficulté** : C1 — implicite, concession, hypotaxe, collocation.
- **Illustration** : pictogrammes géométriques du dossier `mfk-c1-m4` (tous utilisés en `image_match`).
- **Points de vigilance** : reco ; PE doit contenir *Imitez* ; anagrammes sans le mot-cible dans l'indice ; `word_order` sans virgule.
- **À vérifier en relecture** : l'implicite de « assez » n'est pas évident ; les distracteurs QCM restent plausibles ; aucune formule reconnaissable du manuel ; personnages = Seuil seulement.

### Séquence 6 — Audioguide de Rose

- **Objectif communicatif** : Enregistrer un audioguide qui guide sans posséder l'œuvre.
- **Compétences** : CO (débat Radio Figuier) → CE (article / tribune) → PO (modèles) → PE (Imitez) → EL (fiche).
- **Objectif linguistique** : deuxième personne de guide ; hypotaxe ; hypothèse signalée
- **Vocabulaire** : g, u, i, d, e, ,,  , a, u, d, i, t, e, u, r, ,,  , s, i, l, e, n, c, e, ,,  , s, c, r, i, p, t.
- **Résumé du support** : l'audioguide de la Salle des Herbes. Slogan discuté : « vous allez aimer ». Implicite : Une violence polie. Documents : le script d'audioguide / les remarques de Rose.
- **Tâche** : trois minutes : matériaux, une hypothèse, un silence, une sortie
- **Difficulté** : C1 — implicite, concession, hypotaxe, collocation.
- **Illustration** : pictogrammes géométriques du dossier `mfk-c1-m4` (tous utilisés en `image_match`).
- **Points de vigilance** : hypotypose ; PE doit contenir *Imitez* ; anagrammes sans le mot-cible dans l'indice ; `word_order` sans virgule.
- **À vérifier en relecture** : l'implicite de « vous allez aimer » n'est pas évident ; les distracteurs QCM restent plausibles ; aucune formule reconnaissable du manuel ; personnages = Seuil seulement.

---

## Module C1-5 — Le monde de la cour

Illustrations : `/elearning/mfk-c1-m5/` (30 SVG). Seed : voir liste des migrations.

### Séquence 1 — Chant de la cour

- **Objectif communicatif** : Expliquer le message d'un chant de cour inventé, y compris ce qu'il ne dit pas.
- **Compétences** : CO (débat Radio Figuier) → CE (article / tribune) → PO (modèles) → PE (Imitez) → EL (fiche).
- **Objectif linguistique** : expliquer un implicite ; métaphore ; message d'un chant inventé
- **Vocabulaire** : r, e, f, r, a, i, n, ,,  , i, m, p, l, i, c, i, t, e, ,,  , m, é, t, a, p, h, o, r, e, ,,  , m, e, s, s, a, g, e.
- **Résumé du support** : le chant inventé de la cour. Slogan discuté : « c'est juste une chanson ». Implicite : Ne pas entendre qui reste derrière la colline. Documents : les paroles inventées de Sami / l'article de Mado sur le refrain.
- **Tâche** : expliquer le message : qui parle, qui n'est pas nommé, quel geste le refrain demande
- **Difficulté** : C1 — implicite, concession, hypotaxe, collocation.
- **Illustration** : pictogrammes géométriques du dossier `mfk-c1-m5` (tous utilisés en `image_match`).
- **Points de vigilance** : registre ; PE doit contenir *Imitez* ; anagrammes sans le mot-cible dans l'indice ; `word_order` sans virgule.
- **À vérifier en relecture** : l'implicite de « c'est juste une chanson » n'est pas évident ; les distracteurs QCM restent plausibles ; aucune formule reconnaissable du manuel ; personnages = Seuil seulement.

### Séquence 2 — Biographie engagée

- **Objectif communicatif** : Résumer un discours et écrire la biographie d'une voix engagée de la cour.
- **Compétences** : CO (débat Radio Figuier) → CE (article / tribune) → PO (modèles) → PE (Imitez) → EL (fiche).
- **Objectif linguistique** : plus-que-parfait ; il fut un temps ; résumé d'un discours
- **Vocabulaire** : b, i, o, g, r, a, p, h, i, e, ,,  , d, i, s, c, o, u, r, s, ,,  , l, u, t, t, e, ,,  , h, a, g, i, o, g, r, a, p, h, i, e.
- **Résumé du support** : la biographie de Solange Mukamana. Slogan discuté : « une femme exceptionnelle ». Implicite : Ne pas rendre ordinaires les droits exigés. Documents : le discours de Solange sous le figuier / la biographie raturée de Mado.
- **Tâche** : deux pages : dates, discours, ce qu'elle a refusé qu'on dise d'elle
- **Difficulté** : C1 — implicite, concession, hypotaxe, collocation.
- **Illustration** : pictogrammes géométriques du dossier `mfk-c1-m5` (tous utilisés en `image_match`).
- **Points de vigilance** : compte_rendu ; PE doit contenir *Imitez* ; anagrammes sans le mot-cible dans l'indice ; `word_order` sans virgule.
- **À vérifier en relecture** : l'implicite de « une femme exceptionnelle » n'est pas évident ; les distracteurs QCM restent plausibles ; aucune formule reconnaissable du manuel ; personnages = Seuil seulement.

### Séquence 3 — Le sourire n'est pas un lit

- **Objectif communicatif** : Comprendre une chronique d'accueil et écrire un poème sans slogan.
- **Compétences** : CO (débat Radio Figuier) → CE (article / tribune) → PO (modèles) → PE (Imitez) → EL (fiche).
- **Objectif linguistique** : humour et sous-entendu ; écrire un poème ; chronique
- **Vocabulaire** : a, c, c, u, e, i, l, ,,  , c, h, r, o, n, i, q, u, e, ,,  , p, o, è, m, e, ,,  , h, o, s, p, i, t, a, l, i, t, é.
- **Résumé du support** : l'accueil à Rukiri-Nord. Slogan discuté : « nous sommes hospitaliers ». Implicite : Rien donné, mot doux offert. Documents : la chronique de Mado / le poème d'Hawa.
- **Tâche** : une chronique d'humour sans mépris, puis un poème qui tient dans la poche
- **Difficulté** : C1 — implicite, concession, hypotaxe, collocation.
- **Illustration** : pictogrammes géométriques du dossier `mfk-c1-m5` (tous utilisés en `image_match`).
- **Points de vigilance** : ironie ; PE doit contenir *Imitez* ; anagrammes sans le mot-cible dans l'indice ; `word_order` sans virgule.
- **À vérifier en relecture** : l'implicite de « nous sommes hospitaliers » n'est pas évident ; les distracteurs QCM restent plausibles ; aucune formule reconnaissable du manuel ; personnages = Seuil seulement.

### Séquence 4 — Deux vitesses une cour

- **Objectif communicatif** : Comparer deux générations et adapter le registre sans mépris.
- **Compétences** : CO (débat Radio Figuier) → CE (article / tribune) → PO (modèles) → PE (Imitez) → EL (fiche).
- **Objectif linguistique** : registres selon l'interlocuteur ; tutoiement / vouvoiement ; alors que
- **Vocabulaire** : g, é, n, é, r, a, t, i, o, n, ,,  , r, e, g, i, s, t, r, e, ,,  , t, u, t, o, i, e, m, e, n, t, ,,  , v, o, u, v, o, i, e, m, e, n, t.
- **Résumé du support** : deux âges sous le figuier. Slogan discuté : « de mon temps ». Implicite : Votre temps ne compte pas. Documents : le portrait d'Yvette par Mado / le sketch trop dur de Sami, raturé.
- **Tâche** : un dialogue : Yvette et Sami, deux registres, une cour commune
- **Difficulté** : C1 — implicite, concession, hypotaxe, collocation.
- **Illustration** : pictogrammes géométriques du dossier `mfk-c1-m5` (tous utilisés en `image_match`).
- **Points de vigilance** : registre ; PE doit contenir *Imitez* ; anagrammes sans le mot-cible dans l'indice ; `word_order` sans virgule.
- **À vérifier en relecture** : l'implicite de « de mon temps » n'est pas évident ; les distracteurs QCM restent plausibles ; aucune formule reconnaissable du manuel ; personnages = Seuil seulement.

### Séquence 5 — Poème et chronique

- **Objectif communicatif** : Croiser un poème et une chronique pour dire le monde de la cour.
- **Compétences** : CO (débat Radio Figuier) → CE (article / tribune) → PO (modèles) → PE (Imitez) → EL (fiche).
- **Objectif linguistique** : croiser deux genres ; implicite ; humour sans mépris
- **Vocabulaire** : d, i, p, t, y, q, u, e, ,,  , v, e, r, s, ,,  , t, o, n, ,,  , n, o, n, -, d, i, t.
- **Résumé du support** : le cahier des combats. Slogan discuté : « il faut choisir un genre ». Implicite : Ne sois pas trop vivant. Documents : le poème de Mado / sa chronique du même jeudi.
- **Tâche** : un diptyque : huit vers, une chronique, un même non-dit
- **Difficulté** : C1 — implicite, concession, hypotaxe, collocation.
- **Illustration** : pictogrammes géométriques du dossier `mfk-c1-m5` (tous utilisés en `image_match`).
- **Points de vigilance** : ironie ; PE doit contenir *Imitez* ; anagrammes sans le mot-cible dans l'indice ; `word_order` sans virgule.
- **À vérifier en relecture** : l'implicite de « il faut choisir un genre » n'est pas évident ; les distracteurs QCM restent plausibles ; aucune formule reconnaissable du manuel ; personnages = Seuil seulement.

### Séquence 6 — Comparaison de générations

- **Objectif communicatif** : Comparer deux modes de vie d'âges différents sans couronner l'un des deux.
- **Compétences** : CO (débat Radio Figuier) → CE (article / tribune) → PO (modèles) → PE (Imitez) → EL (fiche).
- **Objectif linguistique** : alors que / tandis que / à mesure que ; synthèse
- **Vocabulaire** : c, o, m, p, a, r, a, i, s, o, n, ,,  , n, o, s, t, a, l, g, i, e, ,,  , s, y, n, t, h, è, s, e, ,,  , e, m, p, l, o, i.
- **Résumé du support** : la comparaison Yvette / Sami. Slogan discuté : « c'était mieux avant ». Implicite : Qui n'avait pas la parole. Documents : les deux emplois du temps / la synthèse de Patrick.
- **Tâche** : une synthèse : deux emplois du temps, deux peurs, un banc commun
- **Difficulté** : C1 — implicite, concession, hypotaxe, collocation.
- **Illustration** : pictogrammes géométriques du dossier `mfk-c1-m5` (tous utilisés en `image_match`).
- **Points de vigilance** : compte_rendu ; PE doit contenir *Imitez* ; anagrammes sans le mot-cible dans l'indice ; `word_order` sans virgule.
- **À vérifier en relecture** : l'implicite de « c'était mieux avant » n'est pas évident ; les distracteurs QCM restent plausibles ; aucune formule reconnaissable du manuel ; personnages = Seuil seulement.

---

## Module C1-6 — Travailler au Seuil

Illustrations : `/elearning/mfk-c1-m6/` (30 SVG). Seed : voir liste des migrations.

### Séquence 1 — Pas de tout le monde dit

- **Objectif communicatif** : Réaliser une revue de presse de l'atelier et de la radio, sans fusionner les sources.
- **Compétences** : CO (débat Radio Figuier) → CE (article / tribune) → PO (modèles) → PE (Imitez) → EL (fiche).
- **Objectif linguistique** : selon tel cahier / tel micro ; organisation du travail
- **Vocabulaire** : r, e, v, u, e, ,,  , s, o, u, r, c, e, ,,  , a, t, t, r, i, b, u, t, i, o, n, ,,  , f, r, i, c, t, i, o, n.
- **Résumé du support** : la revue de presse du Seuil. Slogan discuté : « tout le monde dit ». Implicite : Une prise de pouvoir sur les sources. Documents : le Cahier des racines du mardi / l'antenne de Radio Figuier du mercredi.
- **Tâche** : trois extraits, trois attributions, un point de friction nommé
- **Difficulté** : C1 — implicite, concession, hypotaxe, collocation.
- **Illustration** : pictogrammes géométriques du dossier `mfk-c1-m6` (tous utilisés en `image_match`).
- **Points de vigilance** : compte_rendu ; PE doit contenir *Imitez* ; anagrammes sans le mot-cible dans l'indice ; `word_order` sans virgule.
- **À vérifier en relecture** : l'implicite de « tout le monde dit » n'est pas évident ; les distracteurs QCM restent plausibles ; aucune formule reconnaissable du manuel ; personnages = Seuil seulement.

### Séquence 2 — Accroche et entretien

- **Objectif communicatif** : Témoigner d'un entretien et rédiger une accroche d'offre sans mensonge.
- **Compétences** : CO (débat Radio Figuier) → CE (article / tribune) → PO (modèles) → PE (Imitez) → EL (fiche).
- **Objectif linguistique** : discours indirect ; accroche d'offre ; témoignage
- **Vocabulaire** : a, c, c, r, o, c, h, e, ,,  , e, n, t, r, e, t, i, e, n, ,,  , p, o, s, t, e, ,,  , t, é, m, o, i, g, n, a, g, e.
- **Résumé du support** : l'entretien de Joël à l'atelier. Slogan discuté : « super profil ». Implicite : Ne pas dire ce que le poste exige. Documents : l'accroche raturée / le témoignage de Joël.
- **Tâche** : une accroche juste, puis un témoignage d'entretien au discours indirect
- **Difficulté** : C1 — implicite, concession, hypotaxe, collocation.
- **Illustration** : pictogrammes géométriques du dossier `mfk-c1-m6` (tous utilisés en `image_match`).
- **Points de vigilance** : disc_ind ; PE doit contenir *Imitez* ; anagrammes sans le mot-cible dans l'indice ; `word_order` sans virgule.
- **À vérifier en relecture** : l'implicite de « super profil » n'est pas évident ; les distracteurs QCM restent plausibles ; aucune formule reconnaissable du manuel ; personnages = Seuil seulement.

### Séquence 3 — Conflit à l'atelier

- **Objectif communicatif** : Comprendre un conflit de travail et le rapporter sans le romancer.
- **Compétences** : CO (débat Radio Figuier) → CE (article / tribune) → PO (modèles) → PE (Imitez) → EL (fiche).
- **Objectif linguistique** : rapporter une crise ; style indirect libre ; on aurait dit
- **Vocabulaire** : c, o, n, f, l, i, t, ,,  , c, r, i, s, e, ,,  , r, e, l, a, i, s, ,,  , c, o, m, p, t, e, -, r, e, n, d, u.
- **Résumé du support** : la crise de l'atelier. Slogan discuté : « c'est la faute des autres ». Implicite : Éviter de compter les heures mal partagées. Documents : le compte-rendu de Rose / les notes de Karim.
- **Tâche** : un compte-rendu : ce qui a été dit, ce qui a été tu, ce que l'atelier peut décider
- **Difficulté** : C1 — implicite, concession, hypotaxe, collocation.
- **Illustration** : pictogrammes géométriques du dossier `mfk-c1-m6` (tous utilisés en `image_match`).
- **Points de vigilance** : disc_ind ; PE doit contenir *Imitez* ; anagrammes sans le mot-cible dans l'indice ; `word_order` sans virgule.
- **À vérifier en relecture** : l'implicite de « c'est la faute des autres » n'est pas évident ; les distracteurs QCM restent plausibles ; aucune formule reconnaissable du manuel ; personnages = Seuil seulement.

### Séquence 4 — Là-bas n'est pas une morale

- **Objectif communicatif** : Présenter des départs et des ailleurs inventés, sans mirage.
- **Compétences** : CO (débat Radio Figuier) → CE (article / tribune) → PO (modèles) → PE (Imitez) → EL (fiche).
- **Objectif linguistique** : concession ; hypothèse ; habitudes professionnelles ailleurs
- **Vocabulaire** : a, i, l, l, e, u, r, s, ,,  , c, o, n, t, r, a, t, ,,  , t, é, m, o, i, g, n, a, g, e, ,,  , h, a, b, i, t, u, d, e.
- **Résumé du support** : les ailleurs trop brillants. Slogan discuté : « là-bas c'est mieux ». Implicite : Ne plus améliorer ici. Documents : les lettres d'ailleurs inventées / les voix du banc.
- **Tâche** : recueillir trois témoignages : parti, resté, revenu, sans podium
- **Difficulté** : C1 — implicite, concession, hypotaxe, collocation.
- **Illustration** : pictogrammes géométriques du dossier `mfk-c1-m6` (tous utilisés en `image_match`).
- **Points de vigilance** : nom_conc ; PE doit contenir *Imitez* ; anagrammes sans le mot-cible dans l'indice ; `word_order` sans virgule.
- **À vérifier en relecture** : l'implicite de « là-bas c'est mieux » n'est pas évident ; les distracteurs QCM restent plausibles ; aucune formule reconnaissable du manuel ; personnages = Seuil seulement.

### Séquence 5 — Témoignages croisés

- **Objectif communicatif** : Intégrer des témoignages dans une analyse du travail au Seuil.
- **Compétences** : CO (débat Radio Figuier) → CE (article / tribune) → PO (modèles) → PE (Imitez) → EL (fiche).
- **Objectif linguistique** : intégrer des citations ; il a déclaré que ; nuance
- **Vocabulaire** : c, i, t, a, t, i, o, n, ,,  , a, n, a, l, y, s, e, ,,  , f, r, i, c, t, i, o, n, ,,  , e, n, q, u, ê, t, e.
- **Résumé du support** : les voix croisées de l'atelier et de la radio. Slogan discuté : « on a tous le même avis ». Implicite : Le contraire d'une enquête. Documents : les témoignages bruts / l'analyse de Marc.
- **Tâche** : une analyse : trois citations, deux frictions, une proposition de relais
- **Difficulté** : C1 — implicite, concession, hypotaxe, collocation.
- **Illustration** : pictogrammes géométriques du dossier `mfk-c1-m6` (tous utilisés en `image_match`).
- **Points de vigilance** : disc_ind ; PE doit contenir *Imitez* ; anagrammes sans le mot-cible dans l'indice ; `word_order` sans virgule.
- **À vérifier en relecture** : l'implicite de « on a tous le même avis » n'est pas évident ; les distracteurs QCM restent plausibles ; aucune formule reconnaissable du manuel ; personnages = Seuil seulement.

### Séquence 6 — Analyse du travail au Seuil

- **Objectif communicatif** : Conclure le module par une analyse : organisation, recrutement, crise, ailleurs.
- **Compétences** : CO (débat Radio Figuier) → CE (article / tribune) → PO (modèles) → PE (Imitez) → EL (fiche).
- **Objectif linguistique** : synthèse argumentée ; encore que ; il s'agit de
- **Vocabulaire** : c, o, n, s, t, a, t, ,,  , c, a, l, e, n, d, r, i, e, r, ,,  , r, e, l, a, i, s, ,,  , m, o, t, i, o, n.
- **Résumé du support** : le travail au Seuil comme horizon commun. Slogan discuté : « on verra plus tard ». Implicite : Phrase de ceux qui ne portent pas les lanternes. Documents : les quatre séquences précédentes / la motion d'Aline.
- **Tâche** : un texte final : quatre constats, deux gestes datés, une revue dans un mois
- **Difficulté** : C1 — implicite, concession, hypotaxe, collocation.
- **Illustration** : pictogrammes géométriques du dossier `mfk-c1-m6` (tous utilisés en `image_match`).
- **Points de vigilance** : reco ; PE doit contenir *Imitez* ; anagrammes sans le mot-cible dans l'indice ; `word_order` sans virgule.
- **À vérifier en relecture** : l'implicite de « on verra plus tard » n'est pas évident ; les distracteurs QCM restent plausibles ; aucune formule reconnaissable du manuel ; personnages = Seuil seulement.

---

# C2

## Module C2-1 — Bonheurs et utopies

Illustrations : `/elearning/mfk-c2-m1/` (30 SVG). Seed : voir liste des migrations.

### Séquence 1 — Scène sous le figuier

- **Objectif communicatif** : Analyser un extrait inventé et formuler un point de vue critique sans résumé plat.
- **Compétences** : CO (débat Radio Figuier) → CE (article / tribune) → PO (modèles) → PE (Imitez) → EL (fiche).
- **Objectif linguistique** : interprétation théâtrale ; sous-entendu ; point de vue critique
- **Vocabulaire** : s, o, u, s, -, e, n, t, e, n, d, u, ,,  , r, é, p, l, i, q, u, e, ,,  , c, r, i, t, i, q, u, e, ,,  , s, i, l, e, n, c, e.
- **Résumé du support** : une scène trop calme à la Salle des Herbes. Slogan discuté : « quelle émotion ». Implicite : Personne n'a osé bouger. Documents : l'extrait joué par Léa et Marc / l'émission trop rapide de Lila.
- **Tâche** : un échange d'impressions : deux lectures, une ironie, zéro adjectif orphelin
- **Difficulté** : C2 — ironie, sous-entendu, registre, synthèse de points de vue.
- **Illustration** : pictogrammes géométriques du dossier `mfk-c2-m1` (tous utilisés en `image_match`).
- **Points de vigilance** : ironie ; PE doit contenir *Imitez* ; anagrammes sans le mot-cible dans l'indice ; `word_order` sans virgule.
- **À vérifier en relecture** : l'implicite de « quelle émotion » n'est pas évident ; les distracteurs QCM restent plausibles ; aucune formule reconnaissable du manuel ; personnages = Seuil seulement.

### Séquence 2 — Bonheur en série

- **Objectif communicatif** : Prendre position sur un bonheur trop mesuré, trop vendu.
- **Compétences** : CO (débat Radio Figuier) → CE (article / tribune) → PO (modèles) → PE (Imitez) → EL (fiche).
- **Objectif linguistique** : antiphrase ; industrialisation d'un sentiment ; prise de position
- **Vocabulaire** : b, o, n, h, e, u, r, ,,  , r, i, t, u, e, l, ,,  , f, a, t, i, g, u, e, ,,  , t, r, i, b, u, n, e.
- **Résumé du support** : le bonheur à l'heure dite sous le figuier. Slogan discuté : « soyez heureux ». Implicite : Plus le droit d'être las. Documents : l'interview trop lisse d'un animateur inventé / l'extrait de roman de Mado.
- **Tâche** : une tribune : contre la joie obligatoire, pour les soirs sans score
- **Difficulté** : C2 — ironie, sous-entendu, registre, synthèse de points de vue.
- **Illustration** : pictogrammes géométriques du dossier `mfk-c2-m1` (tous utilisés en `image_match`).
- **Points de vigilance** : ironie ; PE doit contenir *Imitez* ; anagrammes sans le mot-cible dans l'indice ; `word_order` sans virgule.
- **À vérifier en relecture** : l'implicite de « soyez heureux » n'est pas évident ; les distracteurs QCM restent plausibles ; aucune formule reconnaissable du manuel ; personnages = Seuil seulement.

### Séquence 3 — La bête et le banc

- **Objectif communicatif** : Argumenter en faveur d'une médiation animale au Seuil, sans mièvrerie.
- **Compétences** : CO (débat Radio Figuier) → CE (article / tribune) → PO (modèles) → PE (Imitez) → EL (fiche).
- **Objectif linguistique** : argumentation juridique inventée ; encore que ; fût-ce
- **Vocabulaire** : m, é, d, i, a, t, i, o, n, ,,  , r, e, s, p, o, n, s, a, b, i, l, i, t, é, ,,  , r, e, f, u, s, ,,  , l, e, t, t, r, e.
- **Résumé du support** : le chien de Basile Habiyaremye. Slogan discuté : « les bêtes n'ont pas leur place ». Implicite : Notre malaise d'abord. Documents : la lettre de Basile / la réserve d'Inès.
- **Tâche** : une lettre au Bureau des Escales : horaires, responsabilité, droit de dire non
- **Difficulté** : C2 — ironie, sous-entendu, registre, synthèse de points de vue.
- **Illustration** : pictogrammes géométriques du dossier `mfk-c2-m1` (tous utilisés en `image_match`).
- **Points de vigilance** : reco ; PE doit contenir *Imitez* ; anagrammes sans le mot-cible dans l'indice ; `word_order` sans virgule.
- **À vérifier en relecture** : l'implicite de « les bêtes n'ont pas leur place » n'est pas évident ; les distracteurs QCM restent plausibles ; aucune formule reconnaissable du manuel ; personnages = Seuil seulement.

### Séquence 4 — Ailleurs possibles

- **Objectif communicatif** : Comprendre les enjeux d'une utopie de rive et en décrire une, sans naïveté.
- **Compétences** : CO (débat Radio Figuier) → CE (article / tribune) → PO (modèles) → PE (Imitez) → EL (fiche).
- **Objectif linguistique** : utopie / contrainte ; conditionnel ; rêve et réalité
- **Vocabulaire** : u, t, o, p, i, e, ,,  , c, o, n, t, r, a, i, n, t, e, ,,  , l, i, b, e, r, t, é, ,,  , c, h, a, r, g, e.
- **Résumé du support** : une utopie trop propre de Rukiri-Nord. Slogan discuté : « demain on sera libres ». Implicite : Qui restera chargé. Documents : le calque utopique de Nina / le conte philosophique de Mado.
- **Tâche** : décrire une rive possible : libertés, charges, refus du trop propre
- **Difficulté** : C2 — ironie, sous-entendu, registre, synthèse de points de vue.
- **Illustration** : pictogrammes géométriques du dossier `mfk-c2-m1` (tous utilisés en `image_match`).
- **Points de vigilance** : hypotypose ; PE doit contenir *Imitez* ; anagrammes sans le mot-cible dans l'indice ; `word_order` sans virgule.
- **À vérifier en relecture** : l'implicite de « demain on sera libres » n'est pas évident ; les distracteurs QCM restent plausibles ; aucune formule reconnaissable du manuel ; personnages = Seuil seulement.

### Séquence 5 — Lettre pour Basile

- **Objectif communicatif** : Rédiger une lettre de médiation claire, relisible, sans mièvrerie.
- **Compétences** : CO (débat Radio Figuier) → CE (article / tribune) → PO (modèles) → PE (Imitez) → EL (fiche).
- **Objectif linguistique** : lettre formelle ; concession ; hypotaxe longue
- **Vocabulaire** : c, a, d, r, e, ,,  , h, o, r, a, i, r, e, ,,  , o, p, p, o, s, a, b, l, e, ,,  , p, a, r, a, g, r, a, p, h, e.
- **Résumé du support** : la lettre au Bureau des Escales. Slogan discuté : « suivez votre cœur ». Implicite : Qui répond du chien s'il gronde. Documents : le brouillon trop tendre / la lettre retenue.
- **Tâche** : trois paragraphes : constat, cadre, demande datée
- **Difficulté** : C2 — ironie, sous-entendu, registre, synthèse de points de vue.
- **Illustration** : pictogrammes géométriques du dossier `mfk-c2-m1` (tous utilisés en `image_match`).
- **Points de vigilance** : reco ; PE doit contenir *Imitez* ; anagrammes sans le mot-cible dans l'indice ; `word_order` sans virgule.
- **À vérifier en relecture** : l'implicite de « suivez votre cœur » n'est pas évident ; les distracteurs QCM restent plausibles ; aucune formule reconnaissable du manuel ; personnages = Seuil seulement.

### Séquence 6 — Une utopie de rive

- **Objectif communicatif** : Décrire une utopie personnelle ancrée à Rukiri-Nord, C2, sans carte postale.
- **Compétences** : CO (débat Radio Figuier) → CE (article / tribune) → PO (modèles) → PE (Imitez) → EL (fiche).
- **Objectif linguistique** : écriture d'utopie ; charges avouées ; ironie douce
- **Vocabulaire** : r, i, v, e, ,,  , p, e, r, f, e, c, t, i, o, n, ,,  , t, e, r, r, e, ,,  , v, i, t, r, i, n, e.
- **Résumé du support** : la rive que l'on ose encore rêver. Slogan discuté : « un monde parfait ». Implicite : Sans visages trop réels. Documents : l'utopie de Mado / les ratures de Nina.
- **Tâche** : deux pages : ailleurs, charges, une ironie contre le trop propre
- **Difficulté** : C2 — ironie, sous-entendu, registre, synthèse de points de vue.
- **Illustration** : pictogrammes géométriques du dossier `mfk-c2-m1` (tous utilisés en `image_match`).
- **Points de vigilance** : hypotypose ; PE doit contenir *Imitez* ; anagrammes sans le mot-cible dans l'indice ; `word_order` sans virgule.
- **À vérifier en relecture** : l'implicite de « un monde parfait » n'est pas évident ; les distracteurs QCM restent plausibles ; aucune formule reconnaissable du manuel ; personnages = Seuil seulement.

---

## Module C2-2 — Parler nos français

Illustrations : `/elearning/mfk-c2-m2/` (30 SVG). Seed : voir liste des migrations.

### Séquence 1 — Mots voyageurs

- **Objectif communicatif** : Réagir aux emprunts et définir notre représentation du français au Seuil.
- **Compétences** : CO (débat Radio Figuier) → CE (article / tribune) → PO (modèles) → PE (Imitez) → EL (fiche).
- **Objectif linguistique** : emprunts ; représentation d'une langue ; sans purisme de boutique
- **Vocabulaire** : e, m, p, r, u, n, t, ,,  , p, u, r, i, s, m, e, ,,  , r, e, p, r, é, s, e, n, t, a, t, i, o, n, ,,  , o, r, e, i, l, l, e.
- **Résumé du support** : les mots voyageurs sous le figuier. Slogan discuté : « il faut parler pur ». Implicite : Parler comme ceux qui n'ont pas eu à emprunter. Documents : l'émission trop sévère / l'article de Karim.
- **Tâche** : un article : ce que nous empruntons, ce que nous refusons, sans tribunal
- **Difficulté** : C2 — ironie, sous-entendu, registre, synthèse de points de vue.
- **Illustration** : pictogrammes géométriques du dossier `mfk-c2-m2` (tous utilisés en `image_match`).
- **Points de vigilance** : registre ; PE doit contenir *Imitez* ; anagrammes sans le mot-cible dans l'indice ; `word_order` sans virgule.
- **À vérifier en relecture** : l'implicite de « il faut parler pur » n'est pas évident ; les distracteurs QCM restent plausibles ; aucune formule reconnaissable du manuel ; personnages = Seuil seulement.

### Séquence 2 — Politiques des voix

- **Objectif communicatif** : Analyser et écrire une lettre ouverte sur les voix de la cour.
- **Compétences** : CO (débat Radio Figuier) → CE (article / tribune) → PO (modèles) → PE (Imitez) → EL (fiche).
- **Objectif linguistique** : lettre ouverte ; politiques linguistiques inventées ; francophonies
- **Vocabulaire** : p, o, l, i, t, i, q, u, e, ,,  , m, i, c, r, o, ,,  , u, s, a, g, e, ,,  , l, e, t, t, r, e.
- **Résumé du support** : qui a droit au micro de Radio Figuier. Slogan discuté : « une seule langue officielle de cour ». Implicite : Une seule oreille légitime. Documents : le projet trop étroit / la lettre ouverte.
- **Tâche** : une lettre ouverte : heures, langues, droit d'être compris sans être effacé
- **Difficulté** : C2 — ironie, sous-entendu, registre, synthèse de points de vue.
- **Illustration** : pictogrammes géométriques du dossier `mfk-c2-m2` (tous utilisés en `image_match`).
- **Points de vigilance** : reco ; PE doit contenir *Imitez* ; anagrammes sans le mot-cible dans l'indice ; `word_order` sans virgule.
- **À vérifier en relecture** : l'implicite de « une seule langue officielle de cour » n'est pas évident ; les distracteurs QCM restent plausibles ; aucune formule reconnaissable du manuel ; personnages = Seuil seulement.

### Séquence 3 — Deux extraits deux oreilles

- **Objectif communicatif** : Comparer deux extraits de Mado et commenter les choix d'écriture.
- **Compétences** : CO (débat Radio Figuier) → CE (article / tribune) → PO (modèles) → PE (Imitez) → EL (fiche).
- **Objectif linguistique** : registres sociaux ; comparer deux extraits ; choix d'écriture
- **Vocabulaire** : e, x, t, r, a, i, t, ,,  , h, y, p, o, t, a, x, e, ,,  , c, l, a, r, t, é, ,,  , d, e, s, t, i, n, a, t, a, i, r, e.
- **Résumé du support** : deux extraits trop éloignés pour n'être pas une politique. Slogan discuté : « il faut écrire simple ». Implicite : N'embêtez pas ceux qui pourraient aller plus loin. Documents : l'extrait court / l'extrait noué.
- **Tâche** : un commentaire : destinataires, rythme, ce que chaque choix exclut
- **Difficulté** : C2 — ironie, sous-entendu, registre, synthèse de points de vue.
- **Illustration** : pictogrammes géométriques du dossier `mfk-c2-m2` (tous utilisés en `image_match`).
- **Points de vigilance** : registre ; PE doit contenir *Imitez* ; anagrammes sans le mot-cible dans l'indice ; `word_order` sans virgule.
- **À vérifier en relecture** : l'implicite de « il faut écrire simple » n'est pas évident ; les distracteurs QCM restent plausibles ; aucune formule reconnaissable du manuel ; personnages = Seuil seulement.

### Séquence 4 — Le souffle sous le figuier

- **Objectif communicatif** : Parler de notre rapport à l'oral et préparer un discours d'éloquence de cour.
- **Compétences** : CO (débat Radio Figuier) → CE (article / tribune) → PO (modèles) → PE (Imitez) → EL (fiche).
- **Objectif linguistique** : art oratoire ; rapport à l'oral ; souffle et hypotaxe
- **Vocabulaire** : é, l, o, q, u, e, n, c, e, ,,  , s, o, u, f, f, l, e, ,,  , d, i, s, c, o, u, r, s, ,,  , d, e, s, t, i, n, a, t, a, i, r, e.
- **Résumé du support** : le concours d'éloquence sous le figuier. Slogan discuté : « parlez avec le ventre ». Implicite : Dispenser d'un plan. Documents : l'essai d'Aline sur l'oral / le discours de Léa.
- **Tâche** : un discours de quatre minutes : thèse, concession, implicite, geste
- **Difficulté** : C2 — ironie, sous-entendu, registre, synthèse de points de vue.
- **Illustration** : pictogrammes géométriques du dossier `mfk-c2-m2` (tous utilisés en `image_match`).
- **Points de vigilance** : registre ; PE doit contenir *Imitez* ; anagrammes sans le mot-cible dans l'indice ; `word_order` sans virgule.
- **À vérifier en relecture** : l'implicite de « parlez avec le ventre » n'est pas évident ; les distracteurs QCM restent plausibles ; aucune formule reconnaissable du manuel ; personnages = Seuil seulement.

### Séquence 5 — Lettre ouverte aux voix

- **Objectif communicatif** : Écrire une lettre ouverte qui dénonce un étroit linguistique de cour.
- **Compétences** : CO (débat Radio Figuier) → CE (article / tribune) → PO (modèles) → PE (Imitez) → EL (fiche).
- **Objectif linguistique** : dénoncer sans insulter ; hypotaxe ; nous demandons que
- **Vocabulaire** : o, u, v, e, r, t, u, r, e, ,,  , t, r, a, d, u, c, t, i, o, n, ,,  , s, i, g, n, a, t, u, r, e, ,,  , é, m, i, s, s, i, o, n.
- **Résumé du support** : la lettre sur le micro trop étroit. Slogan discuté : « ce n'est pas le moment ». Implicite : Votre bouche peut attendre. Documents : les deux émissions / la lettre d'Hawa.
- **Tâche** : une lettre : constat, exemples, heures datées, signatures
- **Difficulté** : C2 — ironie, sous-entendu, registre, synthèse de points de vue.
- **Illustration** : pictogrammes géométriques du dossier `mfk-c2-m2` (tous utilisés en `image_match`).
- **Points de vigilance** : reco ; PE doit contenir *Imitez* ; anagrammes sans le mot-cible dans l'indice ; `word_order` sans virgule.
- **À vérifier en relecture** : l'implicite de « ce n'est pas le moment » n'est pas évident ; les distracteurs QCM restent plausibles ; aucune formule reconnaissable du manuel ; personnages = Seuil seulement.

### Séquence 6 — Concours d'éloquence

- **Objectif communicatif** : Organiser et tenir un concours d'éloquence de cour, C2.
- **Compétences** : CO (débat Radio Figuier) → CE (article / tribune) → PO (modèles) → PE (Imitez) → EL (fiche).
- **Objectif linguistique** : prononcer un discours ; concession oratoire ; implicite assumé
- **Vocabulaire** : c, o, n, c, o, u, r, s, ,,  , c, o, n, c, e, s, s, i, o, n, ,,  , p, a, l, m, a, r, è, s, ,,  , o, r, e, i, l, l, e.
- **Résumé du support** : le concours sous le figuier. Slogan discuté : « le meilleur gagne ». Implicite : Qui n'a pas eu le micro assez tôt. Documents : les trois discours / le palmarès d'Aline.
- **Tâche** : trois discours, un prix de la concession, zéro trophée trop lourd
- **Difficulté** : C2 — ironie, sous-entendu, registre, synthèse de points de vue.
- **Illustration** : pictogrammes géométriques du dossier `mfk-c2-m2` (tous utilisés en `image_match`).
- **Points de vigilance** : ironie ; PE doit contenir *Imitez* ; anagrammes sans le mot-cible dans l'indice ; `word_order` sans virgule.
- **À vérifier en relecture** : l'implicite de « le meilleur gagne » n'est pas évident ; les distracteurs QCM restent plausibles ; aucune formule reconnaissable du manuel ; personnages = Seuil seulement.

---

## Module C2-3 — L'ère du fil

Illustrations : `/elearning/mfk-c2-m3/` (30 SVG). Seed : voir liste des migrations.

### Séquence 1 — Le fil et le Cahier

- **Objectif communicatif** : Débattre de l'impact du fil sur la lecture, sans nostalgie de boutique.
- **Compétences** : CO (débat Radio Figuier) → CE (article / tribune) → PO (modèles) → PE (Imitez) → EL (fiche).
- **Objectif linguistique** : accord, concession, désaccord ; fil et livres
- **Vocabulaire** : f, i, l, ,,  , r, é, s, u, m, é, ,,  , l, e, c, t, u, r, e, ,,  , d, é, b, a, t.
- **Résumé du support** : le fil et le Cahier du chemin. Slogan discuté : « plus personne ne lit ». Implicite : N'aimer qu'une façon de lire. Documents : les résumés trop courts du fil / la tribune de Mado.
- **Tâche** : un débat : trois positions, une concession obligatoire, un geste pour le Cahier
- **Difficulté** : C2 — ironie, sous-entendu, registre, synthèse de points de vue.
- **Illustration** : pictogrammes géométriques du dossier `mfk-c2-m3` (tous utilisés en `image_match`).
- **Points de vigilance** : nom_conc ; PE doit contenir *Imitez* ; anagrammes sans le mot-cible dans l'indice ; `word_order` sans virgule.
- **À vérifier en relecture** : l'implicite de « plus personne ne lit » n'est pas évident ; les distracteurs QCM restent plausibles ; aucune formule reconnaissable du manuel ; personnages = Seuil seulement.

### Séquence 2 — Deux tons un même soin

- **Objectif communicatif** : Adapter une campagne de prévention à un public de cour, sans panique.
- **Compétences** : CO (débat Radio Figuier) → CE (article / tribune) → PO (modèles) → PE (Imitez) → EL (fiche).
- **Objectif linguistique** : adapter un discours ; conseils ; public visé
- **Vocabulaire** : c, a, m, p, a, g, n, e, ,,  , p, u, b, l, i, c, ,,  , r, i, s, q, u, e, ,,  , v, e, r, s, i, o, n.
- **Résumé du support** : une campagne trop criée contre le fil. Slogan discuté : « ouvrez l'œil ». Implicite : Éviter les plus exposés. Documents : l'affiche trop criée / les deux versions de Léa.
- **Tâche** : une campagne : deux tons, un même fait, zéro slogan orphelin
- **Difficulté** : C2 — ironie, sous-entendu, registre, synthèse de points de vue.
- **Illustration** : pictogrammes géométriques du dossier `mfk-c2-m3` (tous utilisés en `image_match`).
- **Points de vigilance** : conseil ; PE doit contenir *Imitez* ; anagrammes sans le mot-cible dans l'indice ; `word_order` sans virgule.
- **À vérifier en relecture** : l'implicite de « ouvrez l'œil » n'est pas évident ; les distracteurs QCM restent plausibles ; aucune formule reconnaissable du manuel ; personnages = Seuil seulement.

### Séquence 3 — Le bruit sans source

- **Objectif communicatif** : Comprendre le processus d'un bruit sans source et écrire un paradoxe.
- **Compétences** : CO (débat Radio Figuier) → CE (article / tribune) → PO (modèles) → PE (Imitez) → EL (fiche).
- **Objectif linguistique** : paradoxe ; bruit sans source ; loin de / bel et bien
- **Vocabulaire** : r, u, m, e, u, r, ,,  , s, o, u, r, c, e, ,,  , p, a, r, a, d, o, x, e, ,,  , t, o, r, r, e, n, t.
- **Résumé du support** : un bruit trop vite vrai sous le figuier. Slogan discuté : « c'est partout donc c'est vrai ». Implicite : La grammaire du torrent, pas de l'enquête. Documents : le torrent du fil / l'article de Marc.
- **Tâche** : un article-paradoxe : plus l'on répète, moins l'on sait, sauf si l'on nomme
- **Difficulté** : C2 — ironie, sous-entendu, registre, synthèse de points de vue.
- **Illustration** : pictogrammes géométriques du dossier `mfk-c2-m3` (tous utilisés en `image_match`).
- **Points de vigilance** : ironie ; PE doit contenir *Imitez* ; anagrammes sans le mot-cible dans l'indice ; `word_order` sans virgule.
- **À vérifier en relecture** : l'implicite de « c'est partout donc c'est vrai » n'est pas évident ; les distracteurs QCM restent plausibles ; aucune formule reconnaissable du manuel ; personnages = Seuil seulement.

### Séquence 4 — Demain trop net

- **Objectif communicatif** : Envisager des dérives technologiques inventées et écrire un extrait dystopique.
- **Compétences** : CO (débat Radio Figuier) → CE (article / tribune) → PO (modèles) → PE (Imitez) → EL (fiche).
- **Objectif linguistique** : dystopie ; dérives ; point de vue d'un intervenant
- **Vocabulaire** : d, y, s, t, o, p, i, e, ,,  , m, a, c, h, i, n, e, ,,  , r, e, f, u, s, ,,  , e, x, t, r, a, i, t.
- **Résumé du support** : une Rukiri-Nord trop écoutée. Slogan discuté : « la machine nous aide ». Implicite : Plus le droit de dire non. Documents : le podcast trop enthousiaste / l'extrait de Léa.
- **Tâche** : un extrait : demain trop net, une voix, un refus, une ombre
- **Difficulté** : C2 — ironie, sous-entendu, registre, synthèse de points de vue.
- **Illustration** : pictogrammes géométriques du dossier `mfk-c2-m3` (tous utilisés en `image_match`).
- **Points de vigilance** : hypotypose ; PE doit contenir *Imitez* ; anagrammes sans le mot-cible dans l'indice ; `word_order` sans virgule.
- **À vérifier en relecture** : l'implicite de « la machine nous aide » n'est pas évident ; les distracteurs QCM restent plausibles ; aucune formule reconnaissable du manuel ; personnages = Seuil seulement.

### Séquence 5 — Article-paradoxe

- **Objectif communicatif** : Rédiger un article qui tienne un paradoxe sans se perdre en effets.
- **Compétences** : CO (débat Radio Figuier) → CE (article / tribune) → PO (modèles) → PE (Imitez) → EL (fiche).
- **Objectif linguistique** : exprimer un paradoxe ; concession ; reformulation
- **Vocabulaire** : p, a, r, a, d, o, x, e, ,,  , v, o, l, u, m, e, ,,  , v, é, r, i, f, i, c, a, t, i, o, n, ,,  , a, r, t, i, c, l, e.
- **Résumé du support** : plus l'on sait, moins l'on vérifie. Slogan discuté : « on est informés comme jamais ». Implicite : Ne plus avoir à vérifier. Documents : les bruits de la veille / l'article de Marc.
- **Tâche** : un article : paradoxe, exemple du Seuil, geste (nommer, ralentir)
- **Difficulté** : C2 — ironie, sous-entendu, registre, synthèse de points de vue.
- **Illustration** : pictogrammes géométriques du dossier `mfk-c2-m3` (tous utilisés en `image_match`).
- **Points de vigilance** : ironie ; PE doit contenir *Imitez* ; anagrammes sans le mot-cible dans l'indice ; `word_order` sans virgule.
- **À vérifier en relecture** : l'implicite de « on est informés comme jamais » n'est pas évident ; les distracteurs QCM restent plausibles ; aucune formule reconnaissable du manuel ; personnages = Seuil seulement.

### Séquence 6 — Extrait dystopique

- **Objectif communicatif** : Écrire un extrait de dystopie ancré à Rukiri-Nord, original, sans catalogue de gadgets.
- **Compétences** : CO (débat Radio Figuier) → CE (article / tribune) → PO (modèles) → PE (Imitez) → EL (fiche).
- **Objectif linguistique** : écriture d'anticipation ; voix ; ombre
- **Vocabulaire** : a, n, t, i, c, i, p, a, t, i, o, n, ,,  , g, a, d, g, e, t, ,,  , o, m, b, r, e, ,,  , n, o, n.
- **Résumé du support** : la cour trop écoutée de demain. Slogan discuté : « tout sera plus simple ». Implicite : Plus seul, plus écouté, moins consulté. Documents : les ratures de Léa / la lecture de Mado.
- **Tâche** : un extrait de quarante lignes : un midi, une voix trop sûre, un non
- **Difficulté** : C2 — ironie, sous-entendu, registre, synthèse de points de vue.
- **Illustration** : pictogrammes géométriques du dossier `mfk-c2-m3` (tous utilisés en `image_match`).
- **Points de vigilance** : hypotypose ; PE doit contenir *Imitez* ; anagrammes sans le mot-cible dans l'indice ; `word_order` sans virgule.
- **À vérifier en relecture** : l'implicite de « tout sera plus simple » n'est pas évident ; les distracteurs QCM restent plausibles ; aucune formule reconnaissable du manuel ; personnages = Seuil seulement.

---

## Module C2-4 — Ce que le figuier se souvient

Illustrations : `/elearning/mfk-c2-m4/` (30 SVG). Seed : voir liste des migrations.

### Séquence 1 — Le tableau de la cour

- **Objectif communicatif** : Démontrer l'intérêt d'un support inventé pour enseigner une mémoire de cour.
- **Compétences** : CO (débat Radio Figuier) → CE (article / tribune) → PO (modèles) → PE (Imitez) → EL (fiche).
- **Objectif linguistique** : raisonnement déductif ; intérêt d'un support pédagogique
- **Vocabulaire** : s, u, p, p, o, r, t, ,,  , d, é, d, u, c, t, i, o, n, ,,  , a, n, g, l, e, ,,  , e, s, s, a, i.
- **Résumé du support** : un support trop controversé d'Aline. Slogan discuté : « au tableau on ne discute pas ». Implicite : La craie a déjà choisi. Documents : le support d'Aline / la critique de Patrick.
- **Tâche** : un essai : intérêt, angle mort, usage sous le figuier
- **Difficulté** : C2 — ironie, sous-entendu, registre, synthèse de points de vue.
- **Illustration** : pictogrammes géométriques du dossier `mfk-c2-m4` (tous utilisés en `image_match`).
- **Points de vigilance** : compte_rendu ; PE doit contenir *Imitez* ; anagrammes sans le mot-cible dans l'indice ; `word_order` sans virgule.
- **À vérifier en relecture** : l'implicite de « au tableau on ne discute pas » n'est pas évident ; les distracteurs QCM restent plausibles ; aucune formule reconnaissable du manuel ; personnages = Seuil seulement.

### Séquence 2 — Éditorial des pactes

- **Objectif communicatif** : Rédiger un éditorial sur des pactes de cour, sans copier un traité réel.
- **Compétences** : CO (débat Radio Figuier) → CE (article / tribune) → PO (modèles) → PE (Imitez) → EL (fiche).
- **Objectif linguistique** : plan chronologique ; éditorial ; accords de rive inventés
- **Vocabulaire** : p, a, c, t, e, ,,  , é, d, i, t, o, r, i, a, l, ,,  , c, h, r, o, n, o, l, o, g, i, e, ,,  , c, e, s, s, i, o, n.
- **Résumé du support** : les pactes de la rive. Slogan discuté : « l'union fait la force ». Implicite : Qui a porté. Documents : les minutes trop lyriques / l'éditorial de Marc.
- **Tâche** : un éditorial : trois dates inventées de cour, un pacte, une rampe
- **Difficulté** : C2 — ironie, sous-entendu, registre, synthèse de points de vue.
- **Illustration** : pictogrammes géométriques du dossier `mfk-c2-m4` (tous utilisés en `image_match`).
- **Points de vigilance** : compte_rendu ; PE doit contenir *Imitez* ; anagrammes sans le mot-cible dans l'indice ; `word_order` sans virgule.
- **À vérifier en relecture** : l'implicite de « l'union fait la force » n'est pas évident ; les distracteurs QCM restent plausibles ; aucune formule reconnaissable du manuel ; personnages = Seuil seulement.

### Séquence 3 — Les noms avant la formule

- **Objectif communicatif** : Analyser un discours de veillée et enregistrer une chronique.
- **Compétences** : CO (débat Radio Figuier) → CE (article / tribune) → PO (modèles) → PE (Imitez) → EL (fiche).
- **Objectif linguistique** : analyse d'un discours ; chronique de veillée ; mémoire
- **Vocabulaire** : v, e, i, l, l, é, e, ,,  , d, i, s, c, o, u, r, s, ,,  , c, h, r, o, n, i, q, u, e, ,,  , o, u, b, l, i.
- **Résumé du support** : la veillée sous le figuier. Slogan discuté : « plus jamais ça ». Implicite : Ne plus nommer. Documents : le discours trop lisse / la chronique d'Yvette.
- **Tâche** : un discours lu, une chronique : noms, silence, ce que le slogan évitait
- **Difficulté** : C2 — ironie, sous-entendu, registre, synthèse de points de vue.
- **Illustration** : pictogrammes géométriques du dossier `mfk-c2-m4` (tous utilisés en `image_match`).
- **Points de vigilance** : ironie ; PE doit contenir *Imitez* ; anagrammes sans le mot-cible dans l'indice ; `word_order` sans virgule.
- **À vérifier en relecture** : l'implicite de « plus jamais ça » n'est pas évident ; les distracteurs QCM restent plausibles ; aucune formule reconnaissable du manuel ; personnages = Seuil seulement.

### Séquence 4 — Plaidoirie sous le figuier

- **Objectif communicatif** : Analyser et rédiger le plan d'une plaidoirie inventée, sans procès d'État.
- **Compétences** : CO (débat Radio Figuier) → CE (article / tribune) → PO (modèles) → PE (Imitez) → EL (fiche).
- **Objectif linguistique** : plan d'une plaidoirie ; contexte et opinion ; justice de cour
- **Vocabulaire** : p, l, a, i, d, o, i, r, i, e, ,,  , c, o, n, t, e, x, t, e, ,,  , i, n, t, r, o, d, u, c, t, i, o, n, ,,  , d, e, m, a, n, d, e.
- **Résumé du support** : une plaidoirie au Bureau des Escales. Slogan discuté : « l'opinion a déjà jugé ». Implicite : N'avoir plus de plan. Documents : le bruit du fil / le plan de Solange.
- **Tâche** : un plan : faits, textes, contexte, demande ; puis l'introduction lue
- **Difficulté** : C2 — ironie, sous-entendu, registre, synthèse de points de vue.
- **Illustration** : pictogrammes géométriques du dossier `mfk-c2-m4` (tous utilisés en `image_match`).
- **Points de vigilance** : reco ; PE doit contenir *Imitez* ; anagrammes sans le mot-cible dans l'indice ; `word_order` sans virgule.
- **À vérifier en relecture** : l'implicite de « l'opinion a déjà jugé » n'est pas évident ; les distracteurs QCM restent plausibles ; aucune formule reconnaissable du manuel ; personnages = Seuil seulement.

### Séquence 5 — Essai du support

- **Objectif communicatif** : Rédiger l'essai promis : intérêt d'un support pour une mémoire de cour.
- **Compétences** : CO (débat Radio Figuier) → CE (article / tribune) → PO (modèles) → PE (Imitez) → EL (fiche).
- **Objectif linguistique** : essai argumenté ; déduction ; pédagogie de mémoire
- **Vocabulaire** : i, n, t, é, r, ê, t, ,,  , l, i, m, i, t, e, ,,  , u, s, a, g, e, ,,  , t, a, m, p, o, n.
- **Résumé du support** : l'essai d'Aline relu par la cour. Slogan discuté : « c'est pédagogique donc c'est bien ». Implicite : Éviter l'essai véritable. Documents : le brouillon trop sûr / l'essai de Patrick.
- **Tâche** : un essai de vingt lignes : intérêt, angle, usage, limite
- **Difficulté** : C2 — ironie, sous-entendu, registre, synthèse de points de vue.
- **Illustration** : pictogrammes géométriques du dossier `mfk-c2-m4` (tous utilisés en `image_match`).
- **Points de vigilance** : compte_rendu ; PE doit contenir *Imitez* ; anagrammes sans le mot-cible dans l'indice ; `word_order` sans virgule.
- **À vérifier en relecture** : l'implicite de « c'est pédagogique donc c'est bien » n'est pas évident ; les distracteurs QCM restent plausibles ; aucune formule reconnaissable du manuel ; personnages = Seuil seulement.

### Séquence 6 — Chronique de veillée

- **Objectif communicatif** : Enregistrer la chronique finale de mémoire, C2.
- **Compétences** : CO (débat Radio Figuier) → CE (article / tribune) → PO (modèles) → PE (Imitez) → EL (fiche).
- **Objectif linguistique** : voix de chronique ; noms ; silence
- **Vocabulaire** : c, é, r, é, m, o, n, i, e, ,,  , p, r, é, n, o, m, ,,  , r, u, s, h, ,,  , j, u, s, t, e, s, s, e.
- **Résumé du support** : la chronique que Lila n'adoucira pas. Slogan discuté : « une belle cérémonie ». Implicite : Un oubli poli. Documents : le rush trop soigné / la chronique retenue.
- **Tâche** : une chronique de quatre minutes : noms, un silence, un refus du bel
- **Difficulté** : C2 — ironie, sous-entendu, registre, synthèse de points de vue.
- **Illustration** : pictogrammes géométriques du dossier `mfk-c2-m4` (tous utilisés en `image_match`).
- **Points de vigilance** : ironie ; PE doit contenir *Imitez* ; anagrammes sans le mot-cible dans l'indice ; `word_order` sans virgule.
- **À vérifier en relecture** : l'implicite de « une belle cérémonie » n'est pas évident ; les distracteurs QCM restent plausibles ; aucune formule reconnaissable du manuel ; personnages = Seuil seulement.

---

## Module C2-5 — Cultures croisées

Illustrations : `/elearning/mfk-c2-m5/` (30 SVG). Seed : voir liste des migrations.

### Séquence 1 — Culture partagée

- **Objectif communicatif** : Rédiger un article qui exprime implicitement une position sur l'accès à la Salle.
- **Compétences** : CO (débat Radio Figuier) → CE (article / tribune) → PO (modèles) → PE (Imitez) → EL (fiche).
- **Objectif linguistique** : implicite ; accessibilité ; position non criée
- **Vocabulaire** : a, c, c, e, s, s, i, b, i, l, i, t, é, ,,  , t, a, r, i, f, ,,  , i, m, p, l, i, c, i, t, e, ,,  , é, c, a, r, t.
- **Résumé du support** : l'accès trop cher à la Salle des Herbes. Slogan discuté : « la culture est à tout le monde ». Implicite : Une invitation à se taire. Documents : l'affiche trop généreuse / l'article d'Hawa.
- **Tâche** : un article implicite : faits, écart, zéro slogan retourné
- **Difficulté** : C2 — ironie, sous-entendu, registre, synthèse de points de vue.
- **Illustration** : pictogrammes géométriques du dossier `mfk-c2-m5` (tous utilisés en `image_match`).
- **Points de vigilance** : ironie ; PE doit contenir *Imitez* ; anagrammes sans le mot-cible dans l'indice ; `word_order` sans virgule.
- **À vérifier en relecture** : l'implicite de « la culture est à tout le monde » n'est pas évident ; les distracteurs QCM restent plausibles ; aucune formule reconnaissable du manuel ; personnages = Seuil seulement.

### Séquence 2 — Qui paie le rire

- **Objectif communicatif** : Expliquer une scène comique de cour sans en faire une recette, ni un procès.
- **Compétences** : CO (débat Radio Figuier) → CE (article / tribune) → PO (modèles) → PE (Imitez) → EL (fiche).
- **Objectif linguistique** : ressorts comiques ; humour ; succès trop facile
- **Vocabulaire** : r, e, s, s, o, r, t, ,,  , c, i, b, l, e, ,,  , q, u, i, p, r, o, q, u, o, ,,  , s, u, c, c, è, s.
- **Résumé du support** : un sketch trop sûr de ses cibles. Slogan discuté : « c'est de l'humour ». Implicite : Après le geste qui a déjà fait mal. Documents : le sketch trop dur / la version raturée.
- **Tâche** : une explication : quiproquo, cible, limite, version raturée
- **Difficulté** : C2 — ironie, sous-entendu, registre, synthèse de points de vue.
- **Illustration** : pictogrammes géométriques du dossier `mfk-c2-m5` (tous utilisés en `image_match`).
- **Points de vigilance** : ironie ; PE doit contenir *Imitez* ; anagrammes sans le mot-cible dans l'indice ; `word_order` sans virgule.
- **À vérifier en relecture** : l'implicite de « c'est de l'humour » n'est pas évident ; les distracteurs QCM restent plausibles ; aucune formule reconnaissable du manuel ; personnages = Seuil seulement.

### Séquence 3 — Le lin trop vite porté

- **Objectif communicatif** : Débattre d'un lin trop vite porté comme décor, sans procès d'intention plat.
- **Compétences** : CO (débat Radio Figuier) → CE (article / tribune) → PO (modèles) → PE (Imitez) → EL (fiche).
- **Objectif linguistique** : débat ; appropriation ; tendance trop vite portée
- **Vocabulaire** : s, i, g, n, e, ,,  , i, n, s, p, i, r, a, t, i, o, n, ,,  , p, e, r, m, i, s, s, i, o, n, ,,  , t, e, n, d, a, n, c, e.
- **Résumé du support** : un lin de Rose trop vite copié. Slogan discuté : « c'est un hommage ». Implicite : Éviter le prix, la source, la permission. Documents : les copies trop nettes / la prise de parole de Rose.
- **Tâche** : un débat : inspiration, vide, demande, geste (créditer, payer, parfois ne pas porter)
- **Difficulté** : C2 — ironie, sous-entendu, registre, synthèse de points de vue.
- **Illustration** : pictogrammes géométriques du dossier `mfk-c2-m5` (tous utilisés en `image_match`).
- **Points de vigilance** : cause ; PE doit contenir *Imitez* ; anagrammes sans le mot-cible dans l'indice ; `word_order` sans virgule.
- **À vérifier en relecture** : l'implicite de « c'est un hommage » n'est pas évident ; les distracteurs QCM restent plausibles ; aucune formule reconnaissable du manuel ; personnages = Seuil seulement.

### Séquence 4 — Récit interculturel

- **Objectif communicatif** : Raconter une expérience interculturelle au Seuil, détaillée, sans figer l'autre.
- **Compétences** : CO (débat Radio Figuier) → CE (article / tribune) → PO (modèles) → PE (Imitez) → EL (fiche).
- **Objectif linguistique** : récit détaillé au passé ; différences ; sans ethnologiser
- **Vocabulaire** : m, a, l, e, n, t, e, n, d, u, ,,  , e, s, s, e, n, c, e, ,,  , r, é, c, i, t, ,,  , c, o, r, r, e, c, t, i, o, n.
- **Résumé du support** : les premiers mois d'Hawa au Pavillon. Slogan discuté : « chez eux c'est comme ça ». Implicite : Éviter le moi, figer le eux. Documents : les notes trop typiques d'un voisin / le récit d'Hawa.
- **Tâche** : un récit : dates, gestes, malentendus, corrections, zéro chez eux trop large
- **Difficulté** : C2 — ironie, sous-entendu, registre, synthèse de points de vue.
- **Illustration** : pictogrammes géométriques du dossier `mfk-c2-m5` (tous utilisés en `image_match`).
- **Points de vigilance** : compte_rendu ; PE doit contenir *Imitez* ; anagrammes sans le mot-cible dans l'indice ; `word_order` sans virgule.
- **À vérifier en relecture** : l'implicite de « chez eux c'est comme ça » n'est pas évident ; les distracteurs QCM restent plausibles ; aucune formule reconnaissable du manuel ; personnages = Seuil seulement.

### Séquence 5 — Article implicite

- **Objectif communicatif** : Tenir l'article implicite jusqu'au bout, sans retomber dans le cri.
- **Compétences** : CO (débat Radio Figuier) → CE (article / tribune) → PO (modèles) → PE (Imitez) → EL (fiche).
- **Objectif linguistique** : écrire en sous-entendu ; faits ; écart
- **Vocabulaire** : c, o, m, p, o, s, i, t, i, o, n, ,,  , c, o, n, c, l, u, s, i, o, n, ,,  , c, l, a, r, t, é, ,,  , c, o, u, r, a, g, e.
- **Résumé du support** : la seconde version de l'article d'Hawa. Slogan discuté : « il faut le dire clairement ». Implicite : Criez comme nous. Documents : la demande de crier / l'article gardé.
- **Tâche** : garder l'article d'Hawa, justifier l'implicite, refuser le slogan contraire
- **Difficulté** : C2 — ironie, sous-entendu, registre, synthèse de points de vue.
- **Illustration** : pictogrammes géométriques du dossier `mfk-c2-m5` (tous utilisés en `image_match`).
- **Points de vigilance** : ironie ; PE doit contenir *Imitez* ; anagrammes sans le mot-cible dans l'indice ; `word_order` sans virgule.
- **À vérifier en relecture** : l'implicite de « il faut le dire clairement » n'est pas évident ; les distracteurs QCM restent plausibles ; aucune formule reconnaissable du manuel ; personnages = Seuil seulement.

### Séquence 6 — Débat de la cour

- **Objectif communicatif** : Tenir un débat sur un sujet polémique de cour, avec règles C2.
- **Compétences** : CO (débat Radio Figuier) → CE (article / tribune) → PO (modèles) → PE (Imitez) → EL (fiche).
- **Objectif linguistique** : débat contradictoire ; polémique ; synthèse
- **Vocabulaire** : d, é, b, a, t, ,,  , p, o, l, é, m, i, q, u, e, ,,  , r, è, g, l, e, ,,  , a, r, è, n, e.
- **Résumé du support** : le débat sous le figuier, après les copies et le rire. Slogan discuté : « que le meilleur gagne ». Implicite : Une politique du micro. Documents : les prises de parole / la synthèse de Patrick.
- **Tâche** : un débat : Rose, Sami, Hawa ; une synthèse de Patrick ; zéro roi
- **Difficulté** : C2 — ironie, sous-entendu, registre, synthèse de points de vue.
- **Illustration** : pictogrammes géométriques du dossier `mfk-c2-m5` (tous utilisés en `image_match`).
- **Points de vigilance** : reco ; PE doit contenir *Imitez* ; anagrammes sans le mot-cible dans l'indice ; `word_order` sans virgule.
- **À vérifier en relecture** : l'implicite de « que le meilleur gagne » n'est pas évident ; les distracteurs QCM restent plausibles ; aucune formule reconnaissable du manuel ; personnages = Seuil seulement.

---

## Module C2-6 — Révolutions de la rive

Illustrations : `/elearning/mfk-c2-m6/` (30 SVG). Seed : voir liste des migrations.

### Séquence 1 — La crue trop tôt

- **Objectif communicatif** : Faire des hypothèses sur une crue inventée et exposer des conséquences.
- **Compétences** : CO (débat Radio Figuier) → CE (article / tribune) → PO (modèles) → PE (Imitez) → EL (fiche).
- **Objectif linguistique** : hypothèses ; conséquences ; biodiversité de rive
- **Vocabulaire** : c, r, u, e, ,,  , h, y, p, o, t, h, è, s, e, ,,  , b, i, o, d, i, v, e, r, s, i, t, é, ,,  , c, o, n, s, é, q, u, e, n, c, e.
- **Résumé du support** : la crue trop tôt de la rive. Slogan discuté : « on verra bien ». Implicite : Le jardin n'est pas le premier mouillé. Documents : les mesures d'Oscar / l'émission trop calme.
- **Tâche** : un compte-rendu oral : hypothèses, conséquences, un geste de rive
- **Difficulté** : C2 — ironie, sous-entendu, registre, synthèse de points de vue.
- **Illustration** : pictogrammes géométriques du dossier `mfk-c2-m6` (tous utilisés en `image_match`).
- **Points de vigilance** : stats ; PE doit contenir *Imitez* ; anagrammes sans le mot-cible dans l'indice ; `word_order` sans virgule.
- **À vérifier en relecture** : l'implicite de « on verra bien » n'est pas évident ; les distracteurs QCM restent plausibles ; aucune formule reconnaissable du manuel ; personnages = Seuil seulement.

### Séquence 2 — Consensus trop commode

- **Objectif communicatif** : Rédiger un article qui répond aux doutes trop commodes, sans mépris.
- **Compétences** : CO (débat Radio Figuier) → CE (article / tribune) → PO (modèles) → PE (Imitez) → EL (fiche).
- **Objectif linguistique** : stratégie argumentative ; répondre au déni poli
- **Vocabulaire** : d, é, n, i, ,,  , p, r, e, u, v, e, ,,  , s, c, e, p, t, i, q, u, e, ,,  , v, i, s, i, t, e.
- **Résumé du support** : le déni poli sous le figuier. Slogan discuté : « ce n'est pas si grave ». Implicite : Pas chez moi d'abord. Documents : les phrases trop calmes du banc / l'article de Nina.
- **Tâche** : un article : doute légitime vs déni poli, preuves de cour, geste
- **Difficulté** : C2 — ironie, sous-entendu, registre, synthèse de points de vue.
- **Illustration** : pictogrammes géométriques du dossier `mfk-c2-m6` (tous utilisés en `image_match`).
- **Points de vigilance** : ironie ; PE doit contenir *Imitez* ; anagrammes sans le mot-cible dans l'indice ; `word_order` sans virgule.
- **À vérifier en relecture** : l'implicite de « ce n'est pas si grave » n'est pas évident ; les distracteurs QCM restent plausibles ; aucune formule reconnaissable du manuel ; personnages = Seuil seulement.

### Séquence 3 — Mesures pour la rive

- **Objectif communicatif** : Proposer des mesures écologiques de cour, datées, finançables.
- **Compétences** : CO (débat Radio Figuier) → CE (article / tribune) → PO (modèles) → PE (Imitez) → EL (fiche).
- **Objectif linguistique** : programme ; mesures politiques de cour ; il convient que
- **Vocabulaire** : m, e, s, u, r, e, ,,  , p, r, o, g, r, a, m, m, e, ,,  , f, i, n, a, n, c, e, m, e, n, t, ,,  , c, o, m, p, o, s, t.
- **Résumé du support** : un programme trop lyrique de la rive. Slogan discuté : « sauvons la planète ». Implicite : Ne pas nommer le jeudi et le fer. Documents : le brouillon trop lyrique / le programme retenu.
- **Tâche** : un programme de cour : trois mesures, deux dates, un financement inventé du Bureau
- **Difficulté** : C2 — ironie, sous-entendu, registre, synthèse de points de vue.
- **Illustration** : pictogrammes géométriques du dossier `mfk-c2-m6` (tous utilisés en `image_match`).
- **Points de vigilance** : reco ; PE doit contenir *Imitez* ; anagrammes sans le mot-cible dans l'indice ; `word_order` sans virgule.
- **À vérifier en relecture** : l'implicite de « sauvons la planète » n'est pas évident ; les distracteurs QCM restent plausibles ; aucune formule reconnaissable du manuel ; personnages = Seuil seulement.

### Séquence 4 — Un personnage de rive

- **Objectif communicatif** : Encourager des gestes et étudier un personnage de roman qui défend une rive.
- **Compétences** : CO (débat Radio Figuier) → CE (article / tribune) → PO (modèles) → PE (Imitez) → EL (fiche).
- **Objectif linguistique** : gestes quotidiens ; personnage de roman ; mode et éthique inventées
- **Vocabulaire** : p, e, r, s, o, n, n, a, g, e, ,,  , g, e, s, t, e, ,,  , c, o, n, t, r, a, d, i, c, t, i, o, n, ,,  , é, t, h, i, q, u, e.
- **Résumé du support** : un personnage trop exemplaire de Mado. Slogan discuté : « soyez écolos ». Implicite : Une affiche, pas une fonction romanesque. Documents : le brouillon trop saint / le personnage retenu.
- **Tâche** : un personnage : un geste, une contradiction, une rive, zéro sainteté
- **Difficulté** : C2 — ironie, sous-entendu, registre, synthèse de points de vue.
- **Illustration** : pictogrammes géométriques du dossier `mfk-c2-m6` (tous utilisés en `image_match`).
- **Points de vigilance** : hypotypose ; PE doit contenir *Imitez* ; anagrammes sans le mot-cible dans l'indice ; `word_order` sans virgule.
- **À vérifier en relecture** : l'implicite de « soyez écolos » n'est pas évident ; les distracteurs QCM restent plausibles ; aucune formule reconnaissable du manuel ; personnages = Seuil seulement.

### Séquence 5 — Compte-rendu climat

- **Objectif communicatif** : Faire le compte-rendu oral des conséquences, à partir des séquences précédentes.
- **Compétences** : CO (débat Radio Figuier) → CE (article / tribune) → PO (modèles) → PE (Imitez) → EL (fiche).
- **Objectif linguistique** : oral de synthèse ; conséquences ; sans spectacle
- **Vocabulaire** : a, m, p, l, e, u, r, ,,  , s, i, d, é, r, a, t, i, o, n, ,,  , s, o, u, r, c, e, ,,  , g, e, s, t, e.
- **Résumé du support** : ce que la cour peut déjà dire de la rive. Slogan discuté : « il faut tout dire ». Implicite : Le contraire d'un compte-rendu. Documents : les rapports de la rive / l'oral de Nina.
- **Tâche** : un oral : quatre minutes, deux sources, une conséquence, un geste
- **Difficulté** : C2 — ironie, sous-entendu, registre, synthèse de points de vue.
- **Illustration** : pictogrammes géométriques du dossier `mfk-c2-m6` (tous utilisés en `image_match`).
- **Points de vigilance** : compte_rendu ; PE doit contenir *Imitez* ; anagrammes sans le mot-cible dans l'indice ; `word_order` sans virgule.
- **À vérifier en relecture** : l'implicite de « il faut tout dire » n'est pas évident ; les distracteurs QCM restent plausibles ; aucune formule reconnaissable du manuel ; personnages = Seuil seulement.

### Séquence 6 — Programme et personnage

- **Objectif communicatif** : Tenir ensemble un programme de rive et un personnage de roman, tâche finale C2-6.
- **Compétences** : CO (débat Radio Figuier) → CE (article / tribune) → PO (modèles) → PE (Imitez) → EL (fiche).
- **Objectif linguistique** : synthèse finale ; programme ; roman
- **Vocabulaire** : c, l, ô, t, u, r, e, ,,  , r, e, v, u, e, ,,  , i, m, p, a, r, f, a, i, t, ,,  , s, t, y, l, e.
- **Résumé du support** : ce que le module laisse à la cour. Slogan discuté : « on a fait le job ». Implicite : Pas à essuyer la prochaine crue. Documents : le programme et le roman / la clôture d'Aline.
- **Tâche** : un texte final : quatre mesures, un personnage contradictoire, une revue sous le figuier
- **Difficulté** : C2 — ironie, sous-entendu, registre, synthèse de points de vue.
- **Illustration** : pictogrammes géométriques du dossier `mfk-c2-m6` (tous utilisés en `image_match`).
- **Points de vigilance** : reco ; PE doit contenir *Imitez* ; anagrammes sans le mot-cible dans l'indice ; `word_order` sans virgule.
- **À vérifier en relecture** : l'implicite de « on a fait le job » n'est pas évident ; les distracteurs QCM restent plausibles ; aucune formule reconnaissable du manuel ; personnages = Seuil seulement.

---

## Contrôles communs aux 12 modules

- 12 modules, 72 séquences, 360 leçons, 3 600 exercices.
- Types par leçon : true_false, qcm, matching, fill_blank, word_order, anagram, find_error, image_match, short_answer, audio_record.
- `published = false` (INSERT et UPDATE).
- Aucun TTS, aucun fichier audio généré ; `audio_record` = voix de l'apprenant.
- A1 / A2 / B1 / B2 inchangés.
