"""MFK A1 Module 3 — pedagogical source (original micro-world)."""

from __future__ import annotations

IMG = "/elearning/mfk-a1-m3/{name}.svg"


def tf(statement: str, correct: bool, explanation: str) -> dict:
    return {
        "type": "true_false",
        "content": {
            "statement": statement,
            "correct": correct,
            "explanation": explanation,
        },
    }


def qcm(question: str, options: list[str], correct: int, explanation: str) -> dict:
    return {
        "type": "qcm",
        "content": {
            "question": question,
            "options": [
                {"text": text, "correct": i == correct} for i, text in enumerate(options)
            ],
            "explanation": explanation,
        },
    }


def match(pairs: list[tuple[str, str]]) -> dict:
    return {
        "type": "matching",
        "content": {"pairs": [{"left": a, "right": b} for a, b in pairs]},
    }


def fill(prompt: str, answer: str) -> dict:
    return {"type": "fill_blank", "content": {"prompt": prompt, "answer": answer}}


def wo(words: list[str]) -> dict:
    return {"type": "word_order", "content": {"words": words}}


def ana(word: str, hint: str) -> dict:
    return {"type": "anagram", "content": {"word": word, "hint": hint}}


def err(bad: str, good: str, explanation: str) -> dict:
    return {
        "type": "find_error",
        "content": {
            "sentence_with_error": bad,
            "correct_sentence": good,
            "explanation": explanation,
        },
    }


def img(pairs: list[tuple[str, str]]) -> dict:
    return {
        "type": "image_match",
        "content": {
            "pairs": [
                {"image_path": IMG.format(name=name), "word": word} for name, word in pairs
            ]
        },
    }


def short(prompt: str) -> dict:
    return {"type": "short_answer", "content": {"prompt": prompt}}


def aud(instructions: str) -> dict:
    return {"type": "audio_record", "content": {"instructions": instructions}}


def lesson(title: str, competency: str, content: str, exercises: list[dict]) -> dict:
    if len(exercises) != 10:
        raise ValueError(f"{title}: expected 10 exercises, got {len(exercises)}")
    types = [e["type"] for e in exercises]
    if len(set(types)) != 10:
        raise ValueError(f"{title}: duplicate or missing types {types}")
    return {
        "title": title,
        "competency": competency,
        "content": content.strip() + "\n",
        "exercises": exercises,
    }


MODULE = {
    "title": "A1 — S'orienter et s'installer",
    "description": (
        "Grande étape 3 : se repérer dans un quartier inventé (Rukiri-Nord), "
        "suivre un guide, prendre le minibus du week-end, demander son chemin, "
        "trouver une chambre et lire la route — cour d'accueil « Le Seuil des Sources »."
    ),
}

# ---------------------------------------------------------------------------
# Séquence 1 — Explorer une nouvelle ville
# Point de langue : c'est / il y a ; où est… ? ; près de, loin de, à côté de, en face de
# ---------------------------------------------------------------------------

S1_CO = lesson(
    "CO — La carte peinte sous le figuier",
    "CO",
    """Objectif
Comprendre un premier repérage : c'est, il y a, où est, près de, en face de.

Consigne
Lisez le dialogue (à écouter avec l'enseignant). Quels lieux Aline montre-t-elle ? Qu'est-ce qui est près du Seuil ?

Support — Sous le figuier, cour « Le Seuil des Sources » (Rukiri-Nord)
Aline : Bienvenue, Léa. C'est la cour du Seuil. Il y a une carte sur le mur.
Léa : Merci. Où est le marché ?
Aline : Le marché « Les Trois Paniers », c'est près d'ici. Tout droit, puis à gauche.
Léa : Et la pharmacie ?
Aline : La pharmacie « Feuille Verte » est en face du parc. Ce n'est pas loin.
Léa : Il y a une banque ?
Aline : Oui. La Caisse du Figuier est à côté de la fontaine.
Léa : Parfait. Je regarde la carte.""",
    [
        tf(
            "Aline montre une carte sur le mur de la cour.",
            True,
            "Aline dit : « Il y a une carte sur le mur. »",
        ),
        qcm(
            "Où est le marché « Les Trois Paniers » ?",
            [
                "Loin de l'aéroport",
                "Près du Seuil",
                "Derrière la banque",
                "Dans le bus",
            ],
            1,
            "Aline : « C'est près d'ici. »",
        ),
        match(
            [
                ("c'est", "présenter un lieu"),
                ("il y a", "signaler une chose"),
                ("près de", "pas loin"),
                ("en face de", "de l'autre côté"),
            ]
        ),
        fill("Complétez :\nLa pharmacie est ___ face du parc.", "en"),
        wo(["Où", "est", "le", "marché", "?"]),
        ana("carte", "Elle est peinte sur le mur de la cour."),
        err(
            "Il a une banque à côté de la fontaine.",
            "Il y a une banque à côté de la fontaine.",
            "On dit « il y a » pour signaler un lieu, pas « il a ».",
        ),
        img(
            [
                ("carte", "la carte"),
                ("marche", "le marché"),
                ("pharmacie", "la pharmacie"),
                ("fontaine", "la fontaine"),
            ]
        ),
        short(
            "Notez trois lieux entendus. Écrivez une phrase avec « près de » et une phrase avec « en face de »."
        ),
        aud(
            "Enregistrez : C'est la cour du Seuil. Où est le marché ? C'est près d'ici. La pharmacie est en face du parc."
        ),
    ],
)

S1_CE = lesson(
    "CE — Le plan glissé sous la porte",
    "CE",
    """Objectif
Lire un petit plan de quartier : c'est, il y a, près de, loin de, à côté de.

Consigne
Lisez le papier glissé sous la porte du Seuil, puis répondez.

Support — Plan du Seuil (encre brune, papier crème)
Rukiri-Nord — cour Le Seuil des Sources
C'est notre mur-carte.
Il y a :
1. le marché Les Trois Paniers — près de la cour
2. le parc Jardin des Sources — en face de la pharmacie
3. la pharmacie Feuille Verte — à côté de la rue des Mimosas
4. la Caisse du Figuier — loin du pont des Herbes
Bienvenue.
Aline Uwase""",
    [
        tf("Le pont des Herbes est près de la Caisse du Figuier.", False, "Le texte dit : la Caisse est loin du pont."),
        qcm(
            "Qu'est-ce qui est près de la cour ?",
            [
                "Le pont des Herbes",
                "Le marché Les Trois Paniers",
                "L'aéroport",
                "La plage",
            ],
            1,
            "Le plan : « le marché… — près de la cour ».",
        ),
        match(
            [
                ("marché", "près de la cour"),
                ("parc", "en face de la pharmacie"),
                ("pharmacie", "à côté de la rue des Mimosas"),
                ("banque", "loin du pont"),
            ]
        ),
        fill("Complétez :\nIl ___ un marché près de la cour.", "y a"),
        wo(["C'est", "notre", "mur-carte", "."]),
        ana("marché", "On y trouve des paniers, près de la cour."),
        err(
            "La pharmacie est a côté de la rue.",
            "La pharmacie est à côté de la rue.",
            "La préposition s'écrit « à » (accent).",
        ),
        img(
            [
                ("marche", "le marché"),
                ("parc", "le parc"),
                ("pharmacie", "la pharmacie"),
                ("banque", "la banque"),
            ]
        ),
        short("Recopiez la liste des quatre lieux. Ajoutez « près » ou « loin » pour chacun, d'après le plan."),
        aud("Lisez à voix haute le plan, de « Rukiri-Nord » jusqu'à la signature d'Aline."),
    ],
)

S1_PO = lesson(
    "PO — Dire où c'est",
    "PO",
    """Objectif
Dire où se trouve un lieu : c'est, il y a, près de, loin de, à côté de, en face de.

Consigne
Répétez les modèles, puis changez le lieu.

Support — Phrases d'Aline, sous le figuier
C'est le marché.
Il y a une pharmacie.
Où est la banque ?
C'est près de la cour.
C'est loin du pont.
C'est à côté de la fontaine.
C'est en face du parc.""",
    [
        tf("« C'est loin du pont » veut dire : le pont n'est pas près.", True, "Loin = pas près."),
        qcm(
            "Quelle question pose-t-on pour un lieu ?",
            ["Qui est-ce ?", "Où est la banque ?", "Combien ça coûte ?", "Quel âge as-tu ?"],
            1,
            "Pour un lieu, on demande « Où est… ? »",
        ),
        match(
            [
                ("près de", "proche"),
                ("loin de", "pas proche"),
                ("à côté de", "juste à côté"),
                ("en face de", "vis-à-vis"),
            ]
        ),
        fill("Complétez :\n___ est la fontaine ?", "Où"),
        wo(["C'est", "près", "de", "la", "cour", "."]),
        ana("fontaine", "Elle est dans la cour, à côté de la banque."),
        err(
            "C'est près de le pont.",
            "C'est près du pont.",
            "De + le → du.",
        ),
        img(
            [
                ("fontaine", "la fontaine"),
                ("parc", "le parc"),
                ("banque", "la banque"),
                ("pont", "le pont"),
            ]
        ),
        short("Écrivez quatre phrases : c'est / il y a / près de / en face de. Utilisez les lieux du Seuil."),
        aud("Enregistrez les sept phrases modèles, lentement, en regardant la carte."),
    ],
)

S1_PE = lesson(
    "PE — Quatre phrases pour Léa",
    "PE",
    """Objectif
Écrire un mini-repérage avec c'est, il y a et une préposition de lieu.

Consigne
Observez le modèle, puis écrivez quatre phrases pour aider Léa.

Support — Modèle d'Aline (carnet crème)
Léa,
C'est Rukiri-Nord.
Il y a un marché près de la cour.
La pharmacie est en face du parc.
La banque est à côté de la fontaine.
Aline""",
    [
        tf("Le modèle commence par « C'est Rukiri-Nord. »", True, "Première phrase du carnet."),
        qcm(
            "Combien de phrases Aline écrit-elle après le prénom ?",
            ["Deux", "Trois", "Quatre", "Six"],
            2,
            "Quatre phrases : c'est / il y a / pharmacie / banque.",
        ),
        match(
            [
                ("C'est Rukiri-Nord.", "présenter le quartier"),
                ("Il y a un marché", "signaler un lieu"),
                ("en face du parc", "vis-à-vis"),
                ("à côté de la fontaine", "juste à côté"),
            ]
        ),
        fill("Complétez :\nIl y a un marché près ___ la cour.", "de"),
        wo(["La", "banque", "est", "à", "côté", "de", "la", "fontaine", "."]),
        ana("quartier", "Rukiri-Nord est un… inventé autour du Seuil."),
        err(
            "Il y a une marché près de la cour.",
            "Il y a un marché près de la cour.",
            "Marché est masculin : un marché.",
        ),
        img(
            [
                ("rue", "la rue"),
                ("marche", "le marché"),
                ("pharmacie", "la pharmacie"),
                ("figuier", "le figuier"),
            ]
        ),
        short(
            "Écrivez quatre phrases pour Léa : 1) C'est… 2) Il y a… 3) … est en face de… 4) … est à côté de…"
        ),
        aud("Lisez votre texte à voix haute, comme un message pour Léa."),
    ],
)

S1_EL = lesson(
    "EL — C'est, il y a, près et loin",
    "EL",
    """Objectif
Retenir c'est / il y a et les prépositions de lieu A1.

Consigne
Lisez la fiche, puis faites les exercices.

Support — Fiche du Seuil (point de langue)
C'est + un lieu : C'est le marché.
Il y a + un lieu : Il y a une pharmacie.
Où est + le / la + lieu ?
près de / loin de
à côté de / en face de
de + le → du : près du pont
Attention : on ne dit pas « il a une banque » pour un lieu.""",
    [
        tf("On dit « il y a une pharmacie » pour signaler un lieu.", True, "Il y a = présence d'un lieu."),
        qcm(
            "Quelle forme est correcte ?",
            [
                "C'est près de le parc",
                "C'est près du parc",
                "C'est près de les parc",
                "C'est près le parc",
            ],
            1,
            "De + le → du.",
        ),
        match(
            [
                ("c'est", "identification"),
                ("il y a", "présence"),
                ("où est", "question de lieu"),
                ("du", "de + le"),
            ]
        ),
        fill("Complétez :\nC'est près ___ parc.", "du"),
        wo(["Il", "y", "a", "une", "pharmacie", "."]),
        ana("près", "Le contraire de loin."),
        err(
            "Où es le marché ?",
            "Où est le marché ?",
            "Le verbe être à la 3e personne : est.",
        ),
        img(
            [
                ("carte", "la carte"),
                ("marche", "le marché"),
                ("parc", "le parc"),
                ("pont", "le pont"),
            ]
        ),
        short("Recopiez la fiche. Ajoutez deux exemples personnels avec « à côté de » et « loin de »."),
        aud("Épelez et dites : c'est — il y a — où est — près de — loin de — à côté de — en face de."),
    ],
)

# ---------------------------------------------------------------------------
# Séquence 2 — Suivre un guide
# Point de langue : impératif (allez, tournez, prenez, continuez) ; à gauche / à droite / tout droit
# ---------------------------------------------------------------------------

S2_CO = lesson(
    "CO — Patrick mène jusqu'aux paniers",
    "CO",
    """Objectif
Comprendre un itinéraire à l'impératif : allez, tournez, prenez, continuez, à gauche, à droite, tout droit.

Consigne
Suivez la voix de Patrick. Dans quel ordre vient chaque direction ?

Support — Rue des Mimosas, vers le marché
Patrick : Vous êtes prête, Léa ? Allez tout droit jusqu'au figuier.
Léa : Oui. Ensuite ?
Patrick : Tournez à gauche. Prenez la petite rue.
Léa : Celle avec la peinture orange ?
Patrick : Oui. Continuez jusqu'au deuxième arbre. Puis tournez à droite.
Léa : Et le marché ?
Patrick : C'est là. Les Trois Paniers. Bravo.""",
    [
        tf("Patrick dit d'abord : « Allez tout droit. »", True, "Première consigne, jusqu'au figuier."),
        qcm(
            "Après le figuier, Léa doit…",
            [
                "Tourner à gauche",
                "Prendre le bus",
                "S'arrêter tout de suite",
                "Revenir au Seuil",
            ],
            0,
            "Patrick : « Tournez à gauche. »",
        ),
        match(
            [
                ("Allez", "marcher"),
                ("Tournez", "changer de direction"),
                ("Prenez", "choisir une rue"),
                ("Continuez", "ne pas s'arrêter"),
            ]
        ),
        fill("Complétez :\nAllez tout ___.", "droit"),
        wo(["Tournez", "à", "gauche", "."]),
        ana("gauche", "Patrick dit de tourner de ce côté après le figuier."),
        err(
            "Tournez à le gauche.",
            "Tournez à gauche.",
            "On dit « à gauche », sans article.",
        ),
        img(
            [
                ("guide", "le guide"),
                ("tout-droit", "tout droit"),
                ("gauche", "à gauche"),
                ("droite", "à droite"),
            ]
        ),
        short("Recopiez l'itinéraire en quatre verbes : allez / tournez / prenez / continuez."),
        aud(
            "Enregistrez l'itinéraire : Allez tout droit. Tournez à gauche. Prenez la petite rue. Continuez. Tournez à droite."
        ),
    ],
)

S2_CE = lesson(
    "CE — Les flèches sur le papier plié",
    "CE",
    """Objectif
Lire un itinéraire écrit avec l'impératif et les directions.

Consigne
Lisez le papier que Patrick glisse dans la poche de Léa.

Support — Papier plié (flèches au crayon)
Pour Léa — marché Les Trois Paniers
1. Allez tout droit jusqu'au figuier.
2. Tournez à gauche.
3. Prenez la rue orange.
4. Continuez jusqu'au deuxième arbre.
5. Tournez à droite.
C'est le marché.
Patrick Habimana""",
    [
        tf("La rue orange vient après « tournez à gauche ».", True, "Étape 3, après l'étape 2."),
        qcm(
            "Jusqu'où Léa continue-t-elle ?",
            [
                "Jusqu'au pont",
                "Jusqu'au deuxième arbre",
                "Jusqu'à la banque",
                "Jusqu'au Seuil",
            ],
            1,
            "Le papier : « Continuez jusqu'au deuxième arbre. »",
        ),
        match(
            [
                ("1", "tout droit"),
                ("2", "à gauche"),
                ("5", "à droite"),
                ("marché", "arrivée"),
            ]
        ),
        fill("Complétez :\nPrenez la rue ___.", "orange"),
        wo(["Allez", "tout", "droit", "jusqu'au", "figuier", "."]),
        ana("droite", "Dernière flèche avant le marché."),
        err(
            "Continuez jusqu'a le deuxième arbre.",
            "Continuez jusqu'au deuxième arbre.",
            "Jusqu'à + le → jusqu'au.",
        ),
        img(
            [
                ("figuier", "le figuier"),
                ("rue", "la rue"),
                ("marche", "le marché"),
                ("affiche", "l'affiche"),
            ]
        ),
        short("Recopiez les cinq étapes. Soulignez les verbes à l'impératif."),
        aud("Lisez le papier de Patrick, numéro par numéro, sans aller trop vite."),
    ],
)

S2_PO = lesson(
    "PO — Donner le chemin",
    "PO",
    """Objectif
Donner un chemin court à l'impératif (vous).

Consigne
Répétez, puis guidez un camarade jusqu'à la fontaine.

Support — Modèles de Patrick
Allez tout droit.
Tournez à gauche.
Tournez à droite.
Prenez la deuxième rue.
Continuez jusqu'à la fontaine.
Arrêtez-vous ici.""",
    [
        tf("« Arrêtez-vous ici » est un impératif avec vous.", True, "Arrêtez-vous = vous, avec un trait d'union."),
        qcm(
            "Quel verbe manque : « ___ la deuxième rue. » ?",
            ["Mangez", "Prenez", "Dormez", "Chantez"],
            1,
            "Pour une rue, on dit « Prenez… »",
        ),
        match(
            [
                ("tout droit", "devant soi"),
                ("à gauche", "côté gauche"),
                ("à droite", "côté droit"),
                ("jusqu'à", "limite"),
            ]
        ),
        fill("Complétez :\nTournez à ___.", "gauche"),
        wo(["Prenez", "la", "deuxième", "rue", "."]),
        ana("tournez", "Verbe pour changer de direction."),
        err(
            "Allez toute droite.",
            "Allez tout droit.",
            "L'adverbe s'écrit « tout droit » (sans e à tout, sans e à droit).",
        ),
        img(
            [
                ("tout-droit", "tout droit"),
                ("gauche", "à gauche"),
                ("droite", "à droite"),
                ("fontaine", "la fontaine"),
            ]
        ),
        short("Écrivez un chemin de cinq phrases pour aller du Seuil à la fontaine."),
        aud("Enregistrez les six phrases modèles, puis votre chemin personnel."),
    ],
)

S2_PE = lesson(
    "PE — Un itinéraire pour Hawa",
    "PE",
    """Objectif
Écrire un itinéraire clair avec l'impératif et les directions.

Consigne
Aidez Hawa à rejoindre le Jardin des Sources. Imitez le modèle.

Support — Modèle (verso du papier plié)
Hawa,
Allez tout droit jusqu'à la porte du Seuil.
Tournez à droite.
Prenez la rue des Mimosas.
Continuez jusqu'au parc.
C'est le Jardin des Sources.
Patrick""",
    [
        tf("Le modèle s'adresse à Hawa.", True, "Première ligne : « Hawa, »"),
        qcm(
            "Quelle est la dernière phrase avant la signature ?",
            [
                "C'est le Jardin des Sources.",
                "C'est le marché.",
                "C'est la banque.",
                "C'est loin.",
            ],
            0,
            "Le texte se termine par le nom du parc.",
        ),
        match(
            [
                ("Allez", "partir en avant"),
                ("Tournez", "changer de côté"),
                ("Prenez", "choisir la rue"),
                ("Continuez", "garder la direction"),
            ]
        ),
        fill("Complétez :\nPrenez la rue ___ Mimosas.", "des"),
        wo(["Tournez", "à", "droite", "."]),
        ana("mimosas", "Nom de la rue près du Seuil."),
        err(
            "Allez tout droit jusqu'à le porte.",
            "Allez tout droit jusqu'à la porte.",
            "Porte est féminin : la porte.",
        ),
        img(
            [
                ("porte", "la porte"),
                ("rue", "la rue"),
                ("parc", "le parc"),
                ("guide", "le guide"),
            ]
        ),
        short(
            "Écrivez un itinéraire de cinq lignes pour Hawa : allez / tournez / prenez / continuez / c'est…"
        ),
        aud(
            "Lisez votre itinéraire comme Patrick : lentement, une phrase, une pause."
        ),
    ],
)

S2_EL = lesson(
    "EL — Impératif et flèches",
    "EL",
    """Objectif
Retenir l'impératif de politesse et les mots de direction.

Consigne
Apprenez la fiche, puis entraînez-vous.

Support — Fiche de Patrick
Pour guider (vous) :
allez — tournez — prenez — continuez — arrêtez-vous
à gauche / à droite / tout droit
le premier / le deuxième
jusqu'à + le → jusqu'au
jusqu'à + la → jusqu'à la
On ne dit pas « tournez à le gauche ».""",
    [
        tf("« Arrêtez-vous » prend un trait d'union.", True, "Impératif + vous : arrêtez-vous."),
        qcm(
            "Quelle forme est correcte ?",
            [
                "Tournez à le droite",
                "Tournez à droite",
                "Tournez de droite",
                "Tournez le droite",
            ],
            1,
            "À gauche / à droite, sans article.",
        ),
        match(
            [
                ("allez", "marcher en avant"),
                ("tournez", "changer de côté"),
                ("prenez", "choisir une voie"),
                ("continuez", "poursuivre"),
            ]
        ),
        fill("Complétez :\nContinuez jusqu'___ figuier.", "au"),
        wo(["Arrêtez-vous", "ici", "."]),
        ana("prenez", "Verbe pour choisir une rue."),
        err(
            "Prenez le deuxième rues.",
            "Prenez la deuxième rue.",
            "Rue est féminin : la deuxième rue.",
        ),
        img(
            [
                ("gauche", "à gauche"),
                ("droite", "à droite"),
                ("tout-droit", "tout droit"),
                ("figuier", "le figuier"),
            ]
        ),
        short("Recopiez la fiche. Inventez deux phrases avec « le premier » et « le deuxième »."),
        aud("Dites la liste des verbes, puis : à gauche, à droite, tout droit, jusqu'au, jusqu'à la."),
    ],
)

# ---------------------------------------------------------------------------
# Séquence 3 — Se déplacer en week-end
# Point de langue : bus / minibus / à pied / vélo ; à + heure ; aller à / venir de ; samedi / dimanche
# ---------------------------------------------------------------------------

S3_CO = lesson(
    "CO — Le tableau de Marc, samedi matin",
    "CO",
    """Objectif
Comprendre un départ de week-end : le minibus, à + heure, aller à, samedi.

Consigne
Écoutez Marc devant le tableau. Qui part, à quelle heure, vers où ?

Support — Arrêt « Figuier 7 », samedi
Marc : Bonjour. C'est le minibus Figuier 7. On va au Jardin des Sources.
Léa : Bonjour. Vous partez à quelle heure ?
Marc : À huit heures, samedi. Pas le dimanche.
Hawa : Je viens du Seuil, à pied. Il y a de la place ?
Marc : Oui. Après le jardin, on va au pont des Herbes.
Léa : Je n'ai pas de vélo. Je prends le minibus.
Marc : Très bien. À samedi, à huit heures.""",
    [
        tf("Le minibus circule le dimanche.", False, "Marc : « Pas le dimanche. »"),
        qcm(
            "À quelle heure part le Figuier 7 ?",
            ["À six heures", "À huit heures", "À midi", "À vingt heures"],
            1,
            "Marc répète : à huit heures, samedi.",
        ),
        match(
            [
                ("minibus", "Figuier 7"),
                ("à pied", "depuis le Seuil"),
                ("samedi", "jour de départ"),
                ("huit heures", "heure"),
            ]
        ),
        fill("Complétez :\nOn part ___ huit heures.", "à"),
        wo(["Je", "prends", "le", "minibus", "."]),
        ana("samedi", "Jour du départ, pas dimanche."),
        err(
            "Je vas au Jardin des Sources.",
            "Je vais au Jardin des Sources.",
            "Je vais (aller). Pas « je vas ».",
        ),
        img(
            [
                ("minibus", "le minibus"),
                ("arret", "l'arrêt"),
                ("horloge", "l'heure"),
                ("a-pied", "à pied"),
            ]
        ),
        short("Notez : le véhicule, le jour, l'heure, deux destinations."),
        aud(
            "Enregistrez : C'est le minibus Figuier 7. On part à huit heures, samedi. Je viens du Seuil à pied."
        ),
    ],
)

S3_CE = lesson(
    "CE — La craie du week-end",
    "CE",
    """Objectif
Lire un tableau d'horaires simple : jours, heures, destinations.

Consigne
Lisez le tableau à la craie, puis répondez.

Support — Tableau de l'arrêt Figuier 7
Minibus Figuier 7 — week-end
Samedi
8 h 00 — Seuil → Jardin des Sources
8 h 20 — Jardin → Pont des Herbes
Retour 16 h 00 — Pont → Seuil
Dimanche : pas de minibus
À pied : 15 minutes jusqu'au jardin
Vélo : 8 minutes
Marc Nkurunziza""",
    [
        tf("Le retour est à seize heures.", True, "« Retour 16 h 00 — Pont → Seuil »."),
        qcm(
            "Combien de minutes à pied jusqu'au jardin ?",
            ["5", "8", "15", "60"],
            2,
            "Le tableau : « À pied : 15 minutes ».",
        ),
        match(
            [
                ("8 h 00", "vers le jardin"),
                ("8 h 20", "vers le pont"),
                ("16 h 00", "retour au Seuil"),
                ("dimanche", "pas de minibus"),
            ]
        ),
        fill("Complétez :\nDimanche : pas de ___.", "minibus"),
        wo(["Je", "vais", "au", "jardin", "."]),
        ana("vélo", "Huit minutes, d'après le tableau."),
        err(
            "Je viens à le Seuil.",
            "Je viens du Seuil.",
            "Venir de + le → du. On vient du Seuil.",
        ),
        img(
            [
                ("minibus", "le minibus"),
                ("velo", "le vélo"),
                ("a-pied", "à pied"),
                ("horloge", "l'heure"),
            ]
        ),
        short("Recopiez le tableau. Ajoutez une phrase : « Je vais à… à … heures. »"),
        aud("Lisez le tableau à voix haute, ligne par ligne."),
    ],
)

S3_PO = lesson(
    "PO — Dire comment on y va",
    "PO",
    """Objectif
Dire le moyen, le jour et l'heure : je vais à, je viens de, je prends, à pied.

Consigne
Répétez, puis parlez de votre samedi.

Support — Modèles de Marc
Je prends le minibus.
Je vais au jardin.
Je viens du Seuil.
Je vais à pied.
Je prends le vélo.
On part à huit heures.
Le dimanche, je reste ici.""",
    [
        tf("« Je viens du Seuil » indique l'origine.", True, "Venir de = d'où on arrive."),
        qcm(
            "Quelle phrase dit le moyen de transport ?",
            [
                "Je m'appelle Marc.",
                "Je prends le minibus.",
                "C'est samedi.",
                "Il y a une carte.",
            ],
            1,
            "Prendre + le minibus / le vélo / le bus.",
        ),
        match(
            [
                ("je vais à", "destination"),
                ("je viens de", "origine"),
                ("je prends", "moyen"),
                ("à huit heures", "moment"),
            ]
        ),
        fill("Complétez :\nJe vais ___ pied.", "à"),
        wo(["On", "part", "à", "huit", "heures", "."]),
        ana("minibus", "Le véhicule de Marc, le samedi."),
        err(
            "Je prends le vélo à pied.",
            "Je vais à pied.",
            "À pied = sans véhicule. On ne « prend » pas le vélo à pied.",
        ),
        img(
            [
                ("bus", "le bus"),
                ("minibus", "le minibus"),
                ("velo", "le vélo"),
                ("a-pied", "à pied"),
            ]
        ),
        short("Écrivez trois phrases : je prends / je vais à / je viens de. Indiquez un jour et une heure."),
        aud("Enregistrez les sept phrases modèles, puis votre samedi à Rukiri-Nord."),
    ],
)

S3_PE = lesson(
    "PE — Mot à une amie, vendredi soir",
    "PE",
    """Objectif
Écrire un court message de déplacement : jour, heure, moyen, lieu.

Consigne
Imitez le mot de Léa. Changez l'heure ou le moyen.

Support — Mot de Léa (papier du Seuil)
Hawa,
Samedi, je prends le minibus.
Je vais au Jardin des Sources à huit heures.
Je viens du Seuil.
Tu viens à vélo ?
À demain.
Léa""",
    [
        tf("Léa propose le samedi.", True, "Première information : samedi."),
        qcm(
            "Léa demande à Hawa si elle vient…",
            ["en avion", "à vélo", "en bateau", "à cheval"],
            1,
            "« Tu viens à vélo ? »",
        ),
        match(
            [
                ("Samedi", "jour"),
                ("huit heures", "heure"),
                ("minibus", "moyen"),
                ("Jardin des Sources", "lieu"),
            ]
        ),
        fill("Complétez :\nJe vais ___ Jardin des Sources.", "au"),
        wo(["Tu", "viens", "à", "vélo", "?"]),
        ana("demain", "Léa écrit : à… (le jour d'après)."),
        err(
            "Je vas au jardin à huit heures.",
            "Je vais au jardin à huit heures.",
            "Aller : je vais.",
        ),
        img(
            [
                ("minibus", "le minibus"),
                ("velo", "le vélo"),
                ("parc", "le parc"),
                ("horloge", "l'heure"),
            ]
        ),
        short(
            "Écrivez un mot de cinq lignes à un camarade : jour, moyen, lieu, heure, une question."
        ),
        aud("Lisez votre mot comme un message oral, clairement."),
    ],
)

S3_EL = lesson(
    "EL — Aller, venir, à + heure",
    "EL",
    """Objectif
Retenir aller à / venir de, les transports et à + heure.

Consigne
Étudiez la fiche du week-end.

Support — Fiche de Marc
Je vais à + lieu : je vais au jardin / à Rukiri-Nord
Je viens de + lieu : je viens du Seuil
Je prends le bus / le minibus / le vélo
Je vais à pied
à + heure : à huit heures
samedi / dimanche
aller : je vais, tu vas, il va, nous allons, vous allez, ils vont""",
    [
        tf("« À pied » s'écrit avec un accent sur le à.", True, "à pied = préposition à."),
        qcm(
            "Quelle conjugaison est correcte ?",
            ["je vas", "je vais", "je aller", "je va"],
            1,
            "Aller est irrégulier : je vais.",
        ),
        match(
            [
                ("je vais", "destination"),
                ("je viens", "origine"),
                ("je prends", "transport"),
                ("à huit heures", "horaire"),
            ]
        ),
        fill("Complétez :\nJe viens ___ Seuil.", "du"),
        wo(["Vous", "allez", "au", "pont", "."]),
        ana("allons", "Nous… (verbe aller)."),
        err(
            "On part a huit heures.",
            "On part à huit heures.",
            "La préposition de l'heure s'écrit « à ».",
        ),
        img(
            [
                ("bus", "le bus"),
                ("minibus", "le minibus"),
                ("velo", "le vélo"),
                ("horloge", "l'heure"),
            ]
        ),
        short("Conjuguez « aller » au présent. Écrivez deux phrases : je vais à / je viens de."),
        aud("Dites la conjugaison d'aller, puis : je prends le minibus à huit heures, samedi."),
    ],
)

# ---------------------------------------------------------------------------
# Séquence 4 — Aller vers l'autre
# Point de langue : Excusez-moi, pour aller à… ? Pouvez-vous m'aider ? près / loin ; merci / de rien
# ---------------------------------------------------------------------------

S4_CO = lesson(
    "CO — Léa interroge Hawa près de la fontaine",
    "CO",
    """Objectif
Comprendre une demande de chemin polie : excusez-moi, pour aller à, pouvez-vous, merci.

Consigne
Qui aide ? Quel lieu Léa cherche-t-elle ? C'est près ou loin ?

Support — Près de la fontaine du Seuil
Léa : Excusez-moi, madame. Pour aller à la pharmacie Feuille Verte ?
Hawa : Oui. Je peux vous aider. C'est près. Cinq minutes à pied.
Léa : Pouvez-vous répéter, s'il vous plaît ?
Hawa : Tout droit, puis en face du parc. Ce n'est pas loin.
Léa : Merci beaucoup.
Hawa : De rien. Bonne route.""",
    [
        tf("Hawa dit que la pharmacie est loin.", False, "Hawa : « C'est près. Cinq minutes. »"),
        qcm(
            "Comment Léa commence-t-elle ?",
            [
                "Hé, toi !",
                "Excusez-moi, madame.",
                "Donnez la carte.",
                "C'est où ?",
            ],
            1,
            "Formule de politesse : Excusez-moi, madame.",
        ),
        match(
            [
                ("Excusez-moi", "attirer l'attention"),
                ("Pour aller à… ?", "demander le chemin"),
                ("Pouvez-vous", "demander de l'aide"),
                ("De rien", "répondre à merci"),
            ]
        ),
        fill("Complétez :\nMerci beaucoup. — ___ rien.", "De"),
        wo(["Pouvez-vous", "m'aider", "?"]),
        ana("merci", "Léa le dit à la fin."),
        err(
            "Excuse-moi, madame.",
            "Excusez-moi, madame.",
            "Avec madame, on vouvoie : excusez-moi.",
        ),
        img(
            [
                ("fontaine", "la fontaine"),
                ("pharmacie", "la pharmacie"),
                ("a-pied", "à pied"),
                ("parc", "le parc"),
            ]
        ),
        short("Notez les formules de politesse du dialogue (au moins quatre)."),
        aud(
            "Enregistrez : Excusez-moi, madame. Pour aller à la pharmacie ? Pouvez-vous m'aider ? Merci beaucoup. De rien."
        ),
    ],
)

S4_CE = lesson(
    "CE — Deux messages sur le papier du figuier",
    "CE",
    """Objectif
Lire un échange écrit pour demander et indiquer un chemin.

Consigne
Lisez les deux messages épinglés sur le figuier.

Support — Billets épinglés
Léa → Hawa
Excusez-moi. Pour aller à la Caisse du Figuier ?
Pouvez-vous m'aider ? Merci.

Hawa → Léa
Oui. C'est près de la fontaine.
Ce n'est pas loin. Cinq minutes.
De rien. À tout à l'heure.""",
    [
        tf("Hawa refuse d'aider Léa.", False, "Hawa répond « Oui » et donne le chemin."),
        qcm(
            "Où est la Caisse du Figuier, d'après Hawa ?",
            [
                "Loin du pont seulement",
                "Près de la fontaine",
                "Dans le minibus",
                "À l'aéroport",
            ],
            1,
            "Hawa : « C'est près de la fontaine. »",
        ),
        match(
            [
                ("Pour aller à", "question"),
                ("près de", "réponse de lieu"),
                ("cinq minutes", "durée"),
                ("À tout à l'heure", "plus tard"),
            ]
        ),
        fill("Complétez :\nCe n'est pas ___.", "loin"),
        wo(["C'est", "près", "de", "la", "fontaine", "."]),
        ana("aider", "Léa demande : pouvez-vous m'… ?"),
        err(
            "Pouvez vous m'aider ?",
            "Pouvez-vous m'aider ?",
            "Question avec vous : trait d'union.",
        ),
        img(
            [
                ("affiche", "l'affiche"),
                ("banque", "la banque"),
                ("fontaine", "la fontaine"),
                ("figuier", "le figuier"),
            ]
        ),
        short("Recopiez l'échange. Ajoutez une question « Pour aller à… ? » vers un autre lieu."),
        aud("Lisez les deux billets : d'abord Léa, puis Hawa."),
    ],
)

S4_PO = lesson(
    "PO — Demander et remercier",
    "PO",
    """Objectif
Demander son chemin et remercier, au vouvoiement.

Consigne
Répétez les modèles. Changez le lieu.

Support — Modèles près de la fontaine
Excusez-moi, monsieur.
Excusez-moi, madame.
Pour aller au marché, s'il vous plaît ?
Pouvez-vous m'aider ?
C'est près ou loin ?
Merci beaucoup.
De rien.
Bonne route.""",
    [
        tf("« Bonne route » se dit après l'aide.", True, "Formule de clôture, comme Hawa."),
        qcm(
            "Quelle question demande la distance ?",
            [
                "Comment vous appelez-vous ?",
                "C'est près ou loin ?",
                "Quel jour sommes-nous ?",
                "Vous prenez le vélo ?",
            ],
            1,
            "Près ou loin = distance simple.",
        ),
        match(
            [
                ("Excusez-moi", "politesse"),
                ("s'il vous plaît", "demande"),
                ("Merci beaucoup", "remerciement"),
                ("De rien", "réponse"),
            ]
        ),
        fill("Complétez :\nPour aller ___ marché ?", "au"),
        wo(["C'est", "près", "ou", "loin", "?"]),
        ana("excusez", "Premier mot pour arrêter quelqu'un poliment (vous)."),
        err(
            "Merci beaucoup. — De rien pas.",
            "Merci beaucoup. — De rien.",
            "La réponse courte est « De rien. »",
        ),
        img(
            [
                ("guide", "le guide"),
                ("marche", "le marché"),
                ("a-pied", "à pied"),
                ("carte", "la carte"),
            ]
        ),
        short("Écrivez un mini-dialogue de six répliques : demander le pont des Herbes."),
        aud("Enregistrez les huit phrases modèles, puis votre dialogue."),
    ],
)

S4_PE = lesson(
    "PE — Un mot collé pour un inconnu",
    "PE",
    """Objectif
Écrire une demande de chemin courte et polie.

Consigne
Rédigez un mot à épingler près de la porte. Suivez le modèle de Léa.

Support — Modèle
Bonjour,
Excusez-moi.
Pour aller au pont des Herbes, s'il vous plaît ?
C'est près ou loin ?
Merci beaucoup.
Léa Niyonzima
Le Seuil des Sources""",
    [
        tf("Léa oublie de dire merci dans le modèle.", False, "Le modèle contient « Merci beaucoup. »"),
        qcm(
            "Quel lieu Léa cherche-t-elle dans le modèle ?",
            [
                "La pharmacie",
                "Le pont des Herbes",
                "La Caisse",
                "Le minibus",
            ],
            1,
            "« Pour aller au pont des Herbes »",
        ),
        match(
            [
                ("Bonjour", "ouverture"),
                ("Excusez-moi", "politesse"),
                ("Pour aller à", "objet"),
                ("Merci beaucoup", "clôture"),
            ]
        ),
        fill("Complétez :\nPour aller ___ pont des Herbes ?", "au"),
        wo(["C'est", "près", "ou", "loin", "?"]),
        ana("beaucoup", "Merci…"),
        err(
            "Pour aller à le pont, s'il vous plaît ?",
            "Pour aller au pont, s'il vous plaît ?",
            "À + le → au.",
        ),
        img(
            [
                ("porte", "la porte"),
                ("pont", "le pont"),
                ("affiche", "l'affiche"),
                ("valise", "la valise"),
            ]
        ),
        short(
            "Écrivez votre mot (six lignes) pour aller à la pharmacie ou au marché. Signez."
        ),
        aud("Lisez votre mot à voix haute, comme si vous parliez à un inconnu."),
    ],
)

S4_EL = lesson(
    "EL — Formules pour le chemin",
    "EL",
    """Objectif
Mémoriser les formules pour demander son chemin (A1, vouvoiement).

Consigne
Apprenez, puis variez le lieu.

Support — Fiche d'Hawa
Excusez-moi, monsieur / madame.
Pour aller à + lieu ?
Pour aller au + lieu masculin (au pont, au marché)
Pouvez-vous m'aider ?
s'il vous plaît
C'est près. / C'est loin. / Cinq minutes.
Merci beaucoup. — De rien.
Bonne route.
Attention : excusez-moi (vous), pas « excuse-moi » avec un inconnu.""",
    [
        tf("Avec un inconnu, on dit « excusez-moi ».", True, "Vouvoiement de politesse."),
        qcm(
            "Quelle question est complète ?",
            [
                "Aller pharmacie ?",
                "Pour aller à la pharmacie, s'il vous plaît ?",
                "Pharmacie maintenant.",
                "Tu sais pharmacie ?",
            ],
            1,
            "Pour aller à + lieu + s'il vous plaît.",
        ),
        match(
            [
                ("au marché", "à + le"),
                ("à la pharmacie", "à + la"),
                ("près", "courte distance"),
                ("loin", "longue distance"),
            ]
        ),
        fill("Complétez :\nPouvez-___ m'aider ?", "vous"),
        wo(["Excusez-moi", "madame", "."]),
        ana("pouvez", "Verbe pouvoir, pour demander poliment."),
        err(
            "Pour aller à la marché ?",
            "Pour aller au marché ?",
            "Marché est masculin : au marché.",
        ),
        img(
            [
                ("pharmacie", "la pharmacie"),
                ("marche", "le marché"),
                ("pont", "le pont"),
                ("guide", "le guide"),
            ]
        ),
        short("Recopiez la fiche. Transformez « Pour aller à… » vers trois lieux du quartier."),
        aud("Dites toutes les formules de la fiche, lentement."),
    ],
)

# ---------------------------------------------------------------------------
# Séquence 5 — Trouver un toit
# Point de langue : chambre, lit, cuisine, douche ; il y a / il n'y a pas ; libre / occupé ; loyer
# ---------------------------------------------------------------------------

S5_CO = lesson(
    "CO — Devant le tableau de liège",
    "CO",
    """Objectif
Comprendre une offre de chambre : il y a, c'est libre, le loyer, cuisine, douche.

Consigne
Écoutez Aline et Hawa. Qu'est-ce qu'il y a dans la chambre ? Quel est le loyer ?

Support — Tableau de liège, cour du Seuil
Hawa : Aline, je cherche un toit. Il y a une chambre ?
Aline : Oui. Maison Karekezi. C'est libre. Il y a un lit, une cuisine et une douche.
Hawa : Il n'y a pas de salon ?
Aline : Non, pas de salon. Mais c'est calme.
Hawa : Combien ça coûte ?
Aline : Le loyer est petit. La clé est ici, près de l'affiche.
Hawa : Merci. Je regarde.""",
    [
        tf("La chambre de la maison Karekezi est occupée.", False, "Aline : « C'est libre. »"),
        qcm(
            "Que n'y a-t-il pas ?",
            ["Un lit", "Une cuisine", "Une douche", "Un salon"],
            3,
            "Aline : « Pas de salon. »",
        ),
        match(
            [
                ("c'est libre", "on peut prendre"),
                ("c'est occupé", "déjà pris"),
                ("le loyer", "le prix"),
                ("la clé", "pour ouvrir"),
            ]
        ),
        fill("Complétez :\nCombien ça ___ ?", "coûte"),
        wo(["Il", "y", "a", "un", "lit", "."]),
        ana("loyer", "Hawa demande le prix : le…"),
        err(
            "Il n'a pas de salon.",
            "Il n'y a pas de salon.",
            "Négation d'un lieu : il n'y a pas.",
        ),
        img(
            [
                ("chambre", "une chambre"),
                ("lit", "un lit"),
                ("cuisine", "une cuisine"),
                ("cle", "la clé"),
            ]
        ),
        short("Listez ce qu'il y a et ce qu'il n'y a pas. Notez la question sur le prix."),
        aud(
            "Enregistrez : Je cherche un toit. C'est libre ? Il y a une douche ? Combien ça coûte ?"
        ),
    ],
)

S5_CE = lesson(
    "CE — L'annonce Maison Karekezi",
    "CE",
    """Objectif
Lire une annonce de chambre simple.

Consigne
Lisez l'annonce épinglée, puis répondez.

Support — Annonce (carton crème)
Chambre — Maison Karekezi
Rukiri-Nord, près du Seuil
C'est libre.
Il y a : un lit, une cuisine, une douche.
Il n'y a pas de salon.
Loyer : petit, à payer le samedi.
Clé au Seuil des Sources, chez Aline.
On peut venir voir aujourd'hui.""",
    [
        tf("On paie le loyer le samedi.", True, "L'annonce : « à payer le samedi »."),
        qcm(
            "Où prend-on la clé ?",
            [
                "Au pont des Herbes",
                "Au Seuil des Sources, chez Aline",
                "Dans le minibus",
                "À la banque",
            ],
            1,
            "« Clé au Seuil des Sources, chez Aline. »",
        ),
        match(
            [
                ("libre", "disponible"),
                ("lit", "pour dormir"),
                ("douche", "pour se laver"),
                ("loyer", "à payer"),
            ]
        ),
        fill("Complétez :\nIl n'y a pas ___ salon.", "de"),
        wo(["C'est", "libre", "."]),
        ana("chambre", "Ce que Hawa cherche."),
        err(
            "Il y a une lit et une cuisine.",
            "Il y a un lit et une cuisine.",
            "Lit est masculin : un lit.",
        ),
        img(
            [
                ("toit", "un toit"),
                ("chambre", "une chambre"),
                ("douche", "une douche"),
                ("loyer", "le loyer"),
            ]
        ),
        short("Recopiez l'annonce en trois phrases : lieu / il y a / loyer."),
        aud("Lisez l'annonce complète, lentement, comme Aline au tableau."),
    ],
)

S5_PO = lesson(
    "PO — Parler d'une chambre",
    "PO",
    """Objectif
Poser des questions sur un logement et décrire une chambre.

Consigne
Répétez, puis jouez Aline / Hawa.

Support — Modèles au tableau de liège
Je cherche une chambre.
C'est libre ou occupé ?
Il y a une cuisine ?
Il y a une douche ?
Il n'y a pas de salon.
Combien ça coûte ?
Le loyer est petit.
Voici la clé.""",
    [
        tf("« Voici la clé » sert à donner la clé.", True, "Voici = présentation de l'objet."),
        qcm(
            "Quelle question porte sur le prix ?",
            [
                "C'est loin ?",
                "Combien ça coûte ?",
                "Où est le parc ?",
                "Vous allez à pied ?",
            ],
            1,
            "Combien ça coûte ? = prix / loyer.",
        ),
        match(
            [
                ("libre", "oui, disponible"),
                ("occupé", "non, pris"),
                ("cuisine", "pour cuisiner"),
                ("douche", "pour l'eau"),
            ]
        ),
        fill("Complétez :\nC'est libre ou ___ ?", "occupé"),
        wo(["Je", "cherche", "une", "chambre", "."]),
        ana("occupé", "Le contraire de libre."),
        err(
            "Combien ça coûtent ?",
            "Combien ça coûte ?",
            "Ça = singulier → coûte.",
        ),
        img(
            [
                ("chambre", "une chambre"),
                ("cuisine", "une cuisine"),
                ("douche", "une douche"),
                ("cle", "la clé"),
            ]
        ),
        short("Écrivez six questions / phrases pour visiter Maison Karekezi."),
        aud("Enregistrez les huit phrases modèles, puis une visite inventée."),
    ],
)

S5_PE = lesson(
    "PE — Mot d'intérêt pour la chambre",
    "PE",
    """Objectif
Écrire un court mot pour réserver ou visiter une chambre.

Consigne
Imitez le mot d'Hawa. Changez un détail (jour ou question).

Support — Mot d'Hawa
Aline,
Je cherche un toit.
La chambre de la maison Karekezi m'intéresse.
C'est libre ? Il y a une douche ?
Je peux venir samedi ?
Merci.
Hawa Diallo""",
    [
        tf("Hawa veut venir le samedi.", True, "« Je peux venir samedi ? »"),
        qcm(
            "Quel logement Hawa nomme-t-elle ?",
            [
                "Maison Karekezi",
                "Hôtel du Pont",
                "Chambre Figuier 7",
                "Parc des Sources",
            ],
            0,
            "Le mot : maison Karekezi.",
        ),
        match(
            [
                ("Je cherche", "besoin"),
                ("m'intéresse", "envie"),
                ("C'est libre ?", "disponibilité"),
                ("Je peux venir", "visite"),
            ]
        ),
        fill("Complétez :\nLa chambre m'___.", "intéresse"),
        wo(["Je", "peux", "venir", "samedi", "?"]),
        ana("intéresse", "Hawa dit : la chambre m'…"),
        err(
            "Je cherches un toit.",
            "Je cherche un toit.",
            "Je cherche (sans s).",
        ),
        img(
            [
                ("toit", "un toit"),
                ("chambre", "une chambre"),
                ("cle", "la clé"),
                ("affiche", "l'affiche"),
            ]
        ),
        short(
            "Écrivez un mot de six lignes pour Aline : chercher, nommer la maison, deux questions, un jour, merci."
        ),
        aud("Lisez votre mot, comme si Aline était devant le tableau."),
    ],
)

S5_EL = lesson(
    "EL — Il y a, libre, loyer",
    "EL",
    """Objectif
Retenir le vocabulaire du logement et il y a / il n'y a pas.

Consigne
Apprenez la fiche, puis décrivez une chambre.

Support — Fiche d'Aline
une chambre / un lit / une cuisine / une douche / un toit
il y a + un / une
il n'y a pas de + nom
c'est libre / c'est occupé
Combien ça coûte ?
le loyer / la clé
Attention : un lit (masculin), une chambre (féminin).""",
    [
        tf("On dit « il n'y a pas de salon ».", True, "Négation : il n'y a pas de + nom."),
        qcm(
            "Quel article va avec « lit » ?",
            ["une", "un", "des le", "la"],
            1,
            "Un lit (masculin).",
        ),
        match(
            [
                ("il y a", "présence"),
                ("il n'y a pas", "absence"),
                ("libre", "disponible"),
                ("occupé", "pris"),
            ]
        ),
        fill("Complétez :\nIl n'y a pas ___ cuisine.", "de"),
        wo(["C'est", "occupé", "."]),
        ana("douche", "Pour se laver, dans l'annonce."),
        err(
            "C'est une occupé.",
            "C'est occupé.",
            "Occupé est un adjectif : c'est occupé.",
        ),
        img(
            [
                ("lit", "un lit"),
                ("cuisine", "une cuisine"),
                ("douche", "une douche"),
                ("loyer", "le loyer"),
            ]
        ),
        short("Recopiez la fiche. Décrivez une chambre inventée en cinq phrases."),
        aud("Dites : il y a / il n'y a pas / c'est libre / c'est occupé / combien ça coûte ?"),
    ],
)

# ---------------------------------------------------------------------------
# Séquence 6 — Sur la route
# Point de langue : moto, voiture, à pied ; avant / après ; attention, lentement ; on prend la route de
# ---------------------------------------------------------------------------

S6_CO = lesson(
    "CO — Joël explique le Pont des Herbes",
    "CO",
    """Objectif
Comprendre un trajet : avant, après, attention, lentement, moto, à pied.

Consigne
Écoutez Joël. Que faut-il faire avant le pont ? Après le pont ?

Support — Sous le figuier, casque à la main
Joël : Je prends la moto. C'est le service Moto-Figuier.
Léa : On prend la route de Rukiri-Nord ?
Joël : Oui. Attention avant le pont des Herbes : allez lentement.
Léa : Et après le pont ?
Joël : Après le pont, c'est calme. On va au jardin. À pied, c'est long.
Léa : Pas de voiture aujourd'hui ?
Joël : Non. Juste la moto. Vous êtes prête ?""",
    [
        tf("Joël dit d'aller vite avant le pont.", False, "Il dit : « allez lentement. »"),
        qcm(
            "Quel service Joël nomme-t-il ?",
            ["Bus 12", "Moto-Figuier", "Taxi-Lac", "Minibus 3"],
            1,
            "« C'est le service Moto-Figuier. »",
        ),
        match(
            [
                ("avant le pont", "juste avant"),
                ("après le pont", "une fois passé"),
                ("lentement", "pas vite"),
                ("attention", "prudence"),
            ]
        ),
        fill("Complétez :\nAttention ___ le pont.", "avant"),
        wo(["On", "prend", "la", "route", "."]),
        ana("pont", "Joël parle du… des Herbes."),
        err(
            "Allez lente.",
            "Allez lentement.",
            "L'adverbe est « lentement ».",
        ),
        img(
            [
                ("moto", "la moto"),
                ("pont", "le pont"),
                ("a-pied", "à pied"),
                ("figuier", "le figuier"),
            ]
        ),
        short("Notez : le moyen, un conseil avant le pont, une info après le pont."),
        aud(
            "Enregistrez : On prend la route de Rukiri-Nord. Attention avant le pont. Allez lentement. Après le pont, c'est calme."
        ),
    ],
)

S6_CE = lesson(
    "CE — L'ardoise de la route",
    "CE",
    """Objectif
Lire un avis de route : avant / après, attention, moyens.

Consigne
Lisez l'ardoise accrochée près de la porte.

Support — Ardoise Moto-Figuier
Route de Rukiri-Nord
On prend la moto. Pas de voiture aujourd'hui.
Avant le pont des Herbes : attention, lentement.
Après le pont : le jardin est à droite.
À pied : c'est long.
Vélo : possible, mais lentement aussi.
Joël Mugisha""",
    [
        tf("Après le pont, le jardin est à gauche.", False, "L'ardoise : « le jardin est à droite. »"),
        qcm(
            "Quel moyen n'est pas disponible aujourd'hui ?",
            ["La moto", "À pied", "Le vélo", "La voiture"],
            3,
            "« Pas de voiture aujourd'hui. »",
        ),
        match(
            [
                ("avant le pont", "attention"),
                ("après le pont", "jardin à droite"),
                ("à pied", "c'est long"),
                ("vélo", "lentement aussi"),
            ]
        ),
        fill("Complétez :\nAprès le pont : le jardin est à ___.", "droite"),
        wo(["Pas", "de", "voiture", "aujourd'hui", "."]),
        ana("attention", "Mot écrit avant le pont, pour la prudence."),
        err(
            "On prends la route de Rukiri-Nord.",
            "On prend la route de Rukiri-Nord.",
            "On prend (comme il/elle).",
        ),
        img(
            [
                ("moto", "la moto"),
                ("velo", "le vélo"),
                ("pont", "le pont"),
                ("porte", "la porte"),
            ]
        ),
        short("Recopiez l'ardoise en quatre phrases courtes (moyen, avant, après, à pied)."),
        aud("Lisez l'ardoise à voix haute, comme un avis aux voyageurs."),
    ],
)

S6_PO = lesson(
    "PO — Dire la route",
    "PO",
    """Objectif
Donner un conseil de route simple : avant / après, attention, lentement.

Consigne
Répétez, puis guidez jusqu'au pont.

Support — Modèles de Joël
On prend la route de Rukiri-Nord.
Je prends la moto.
Attention.
Allez lentement.
Avant le pont, c'est étroit.
Après le pont, tournez à droite.
À pied, c'est long.
Bonne route.""",
    [
        tf("« C'est étroit » décrit la route avant le pont.", True, "Modèle : avant le pont, c'est étroit."),
        qcm(
            "Quel adverbe dit « pas vite » ?",
            ["beaucoup", "lentement", "demain", "ici"],
            1,
            "Lentement = pas vite.",
        ),
        match(
            [
                ("avant", "plus tôt sur la route"),
                ("après", "plus tard sur la route"),
                ("attention", "soyez prudent"),
                ("Bonne route", "souhait"),
            ]
        ),
        fill("Complétez :\nAllez ___.", "lentement"),
        wo(["Tournez", "à", "droite", "après", "le", "pont", "."]),
        ana("route", "On prend la… de Rukiri-Nord."),
        err(
            "Avant le pont, allez lent.",
            "Avant le pont, allez lentement.",
            "Après un verbe, on utilise l'adverbe « lentement ».",
        ),
        img(
            [
                ("moto", "la moto"),
                ("pont", "le pont"),
                ("droite", "à droite"),
                ("a-pied", "à pied"),
            ]
        ),
        short("Écrivez six phrases pour un camarade qui va au pont (moyen, avant, après, conseil)."),
        aud("Enregistrez les huit phrases, puis votre propre conseil de route."),
    ],
)

S6_PE = lesson(
    "PE — Trois conseils sur un carton",
    "PE",
    """Objectif
Écrire trois conseils de route clairs, au présent.

Consigne
Rédigez un carton pour les nouveaux, d'après le modèle de Joël.

Support — Modèle
Voyageurs,
On prend la route de Rukiri-Nord.
1. Attention avant le pont.
2. Allez lentement.
3. Après le pont, le jardin est à droite.
Bonne route.
Joël""",
    [
        tf("Le modèle contient trois conseils numérotés.", True, "1, 2 et 3 dans le carton."),
        qcm(
            "Où est le jardin, d'après le modèle ?",
            [
                "À gauche avant le pont",
                "À droite après le pont",
                "Dans le minibus",
                "Sous le figuier seulement",
            ],
            1,
            "« Après le pont, le jardin est à droite. »",
        ),
        match(
            [
                ("Attention", "conseil 1"),
                ("lentement", "conseil 2"),
                ("à droite", "conseil 3"),
                ("Bonne route", "souhait final"),
            ]
        ),
        fill("Complétez :\nAprès le pont, le jardin est à ___.", "droite"),
        wo(["Attention", "avant", "le", "pont", "."]),
        ana("voyageurs", "Premier mot du carton, au pluriel."),
        err(
            "On prend la route à Rukiri-Nord.",
            "On prend la route de Rukiri-Nord.",
            "On dit « la route de » + lieu.",
        ),
        img(
            [
                ("affiche", "l'affiche"),
                ("pont", "le pont"),
                ("parc", "le parc"),
                ("moto", "la moto"),
            ]
        ),
        short(
            "Écrivez un carton : une ouverture, trois conseils (avant / lentement / après), une clôture."
        ),
        aud("Lisez votre carton comme un avis affiché près de la porte."),
    ],
)

S6_EL = lesson(
    "EL — Avant, après, attention",
    "EL",
    """Objectif
Retenir avant / après, les moyens et les conseils de route.

Consigne
Étudiez la fiche de Joël.

Support — Fiche route
On prend la route de + lieu
Je prends la moto / le vélo
Je vais à pied
avant + le / la + lieu
après + le / la + lieu
attention
lentement (adverbe)
Bonne route
Attention : on prend (pas « on prends »).
Allez lentement (pas « allez lent »).""",
    [
        tf("« Lentement » est un adverbe.", True, "Il précise le verbe : allez lentement."),
        qcm(
            "Quelle phrase est correcte ?",
            [
                "On prends la moto",
                "On prend la moto",
                "On prendre la moto",
                "On prenez la moto",
            ],
            1,
            "On = il/elle → prend.",
        ),
        match(
            [
                ("avant", "plus tôt"),
                ("après", "plus tard"),
                ("à pied", "sans véhicule"),
                ("la moto", "Moto-Figuier"),
            ]
        ),
        fill("Complétez :\nOn prend la route ___ Rukiri-Nord.", "de"),
        wo(["Je", "vais", "à", "pied", "."]),
        ana("lentement", "Adverbe : pas vite."),
        err(
            "Après le pont, c'est à le droite.",
            "Après le pont, c'est à droite.",
            "À droite, sans article.",
        ),
        img(
            [
                ("moto", "la moto"),
                ("velo", "le vélo"),
                ("a-pied", "à pied"),
                ("pont", "le pont"),
            ]
        ),
        short("Recopiez la fiche. Écrivez quatre phrases : moto / à pied / avant / après."),
        aud("Dites la fiche : on prend, avant, après, attention, lentement, bonne route."),
    ],
)

SEQUENCES = [
    {
        "title": "Explorer une nouvelle ville",
        "lessons": [S1_CO, S1_CE, S1_PO, S1_PE, S1_EL],
    },
    {
        "title": "Suivre un guide",
        "lessons": [S2_CO, S2_CE, S2_PO, S2_PE, S2_EL],
    },
    {
        "title": "Se déplacer en week-end",
        "lessons": [S3_CO, S3_CE, S3_PO, S3_PE, S3_EL],
    },
    {
        "title": "Aller vers l'autre",
        "lessons": [S4_CO, S4_CE, S4_PO, S4_PE, S4_EL],
    },
    {
        "title": "Trouver un toit",
        "lessons": [S5_CO, S5_CE, S5_PO, S5_PE, S5_EL],
    },
    {
        "title": "Sur la route",
        "lessons": [S6_CO, S6_CE, S6_PO, S6_PE, S6_EL],
    },
]
