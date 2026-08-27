"""MFK A1 Module 7 — Cap sur ailleurs (Seuil des Sources)."""

from __future__ import annotations

IMG = "/elearning/mfk-a1-m7/{name}.svg"


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
                {"image_path": IMG.format(name=name), "word": word}
                for name, word in pairs
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
    "title": "A1 — Cap sur ailleurs",
    "description": (
        "Grande étape 7 : dire un projet de départ au futur simple, voyager "
        "autrement, situer un ailleurs inventé, trouver un point de chute, "
        "choisir une saison et tenir un carnet — sous le figuier du Seuil "
        "des Sources (Rukiri-Nord)."
    ),
}

# ---------------------------------------------------------------------------
# Séquence 1 — Envie de partir
# futur simple : je partirai ; il faut + infinitif
# ---------------------------------------------------------------------------

S1_CO = lesson(
    "CO — Un billet sous le figuier",
    "CO",
    """Objectif
Comprendre un projet de départ : je partirai, j'aurai, il faut.

Consigne
Lisez le dialogue (à écouter avec l'enseignant). Qui partira ? Où ? Qu'est-ce qu'il faut ?

Support — Carnet de route, banc du Seuil
Léa : J'ai envie de partir. Je partirai au lac des Nénuphars.
Aline : Il faut un billet. Tu auras une place dans le minibus Figuier 7.
Marc : Oui. Je prendrai la route à six heures. Léa, tu seras à l'heure ?
Léa : Oui. J'aurai ma petite valise.
Joël : Moi, je ne partirai pas. Je resterai près de la moto.
Patrick : Il faut demander l'heure à l'accueil.""",
    [
        tf("Léa partira au lac des Nénuphars.", True, "Léa : « Je partirai au lac des Nénuphars. »"),
        qcm(
            "Qu'est-ce qu'il faut, d'après Aline ?",
            ["Un tambour", "Un billet", "Une danse", "Un cahier d'histoires"],
            1,
            "Aline : « Il faut un billet. »",
        ),
        match(
            [
                ("Léa", "partira au lac"),
                ("Marc", "prendra la route"),
                ("Joël", "restera"),
                ("Aline", "parle du billet"),
            ]
        ),
        fill("Complétez :\nJe ___ au lac des Nénuphars.", "partirai"),
        wo(["Il", "faut", "un", "billet", "."]),
        ana("partirai", "Le futur de partir, avec je."),
        err(
            "Je partiras au lac demain.",
            "Je partirai au lac demain.",
            "Je partirai (pas partiras).",
        ),
        img(
            [
                ("valise", "une valise"),
                ("ticket", "un billet"),
                ("partir", "partir"),
                ("minibus", "le minibus"),
            ]
        ),
        short("Notez qui partira, qui restera, et ce qu'il faut."),
        aud(
            "Enregistrez : J'ai envie de partir. Je partirai demain. Il faut un billet. J'aurai ma valise."
        ),
    ],
)

S1_CE = lesson(
    "CE — Cartes du carnet",
    "CE",
    """Objectif
Lire des projets au futur simple et la formule il faut.

Consigne
Lisez les cartes épinglées.

Support — Carnet de route
Léa — Je partirai au lac des Nénuphars. J'aurai une valise.
Marc — Je prendrai le minibus à 6 h. Tu seras à l'heure ?
Aline — Il faut un billet. Il faut demander à l'accueil.
Joël — Je ne partirai pas. Je resterai ici.
Noura Sarr — Je visiterai le Seuil. Après, je partirai aussi.
Règle : une phrase au futur, une phrase avec il faut.""",
    [
        tf("Joël partira avec Léa.", False, "Joël : « Je ne partirai pas. »"),
        qcm(
            "Qui visitera d'abord le Seuil ?",
            ["Marc", "Noura Sarr", "Aline", "Patrick"],
            1,
            "Carte Noura : « Je visiterai le Seuil. »",
        ),
        match(
            [
                ("je partirai", "Léa"),
                ("je prendrai", "Marc"),
                ("il faut", "Aline"),
                ("je resterai", "Joël"),
            ]
        ),
        fill("Complétez :\nIl ___ un billet.", "faut"),
        wo(["Tu", "seras", "à", "l'heure", "?"]),
        ana("aurai", "Le futur de avoir, avec je : j'…"),
        err(
            "Il fauts un billet.",
            "Il faut un billet.",
            "Il faut : toujours 3e personne, sans s.",
        ),
        img(
            [
                ("carnet", "un carnet"),
                ("ticket", "un billet"),
                ("valise", "une valise"),
                ("carte", "une carte"),
            ]
        ),
        short("Recopiez deux cartes. Ajoutez la vôtre : je partirai… / il faut…"),
        aud("Lisez les cinq cartes, sans aller trop vite."),
    ],
)

S1_PO = lesson(
    "PO — Dire je partirai, il faut",
    "PO",
    """Objectif
Dire un projet : je partirai, tu seras, j'aurai, il faut.

Consigne
Répétez, puis parlez de votre envie de partir (vraie ou inventée).

Support — Modèles de Léa
Je partirai demain.
Tu partiras aussi.
Il restera ici.
J'aurai une valise.
Tu seras à l'heure.
Il faut un billet.
Il faut demander.
Je ne partirai pas.""",
    [
        tf("« Il faut » ne change pas avec je ou tu.", True, "Toujours il faut + nom ou infinitif."),
        qcm(
            "Quelle phrase est au futur simple ?",
            ["Je pars", "Je vais partir", "Je partirai", "Je suis parti"],
            2,
            "Je partirai = futur simple.",
        ),
        match(
            [
                ("je partirai", "partir"),
                ("j'aurai", "avoir"),
                ("tu seras", "être"),
                ("il faut", "conseil"),
            ]
        ),
        fill("Complétez :\nTu ___ à l'heure.", "seras"),
        wo(["J'aurai", "une", "valise", "."]),
        ana("seras", "Le futur de être, avec tu."),
        err(
            "Je sera à l'heure.",
            "Je serai à l'heure.",
            "Je serai (être au futur).",
        ),
        img(
            [
                ("partir", "partir"),
                ("rester", "rester"),
                ("valise", "une valise"),
                ("ticket", "un billet"),
            ]
        ),
        short("Écrivez six phrases : deux je partirai, deux j'aurai/tu seras, deux il faut."),
        aud("Enregistrez les huit modèles, puis votre projet."),
    ],
)

S1_PE = lesson(
    "PE — Ma carte de départ",
    "PE",
    """Objectif
Écrire une courte carte au futur simple.

Consigne
Imitez la carte de Léa.

Support — Carte de Léa
Léa Niyonzima
Je partirai au lac des Nénuphars.
J'aurai une petite valise.
Il faut un billet. Il faut être à six heures.
Je serai à l'heure.
Léa
Carnet de route — Seuil des Sources""",
    [
        tf("Léa sera en retard, d'après sa carte.", False, "« Je serai à l'heure. »"),
        qcm(
            "À quelle heure faut-il être ?",
            ["À midi", "À six heures", "À minuit", "À seize heures"],
            1,
            "« Il faut être à six heures. »",
        ),
        match(
            [
                ("je partirai", "lac"),
                ("j'aurai", "valise"),
                ("il faut", "billet"),
                ("je serai", "à l'heure"),
            ]
        ),
        fill("Complétez :\nJe ___ à l'heure.", "serai"),
        wo(["Je", "partirai", "demain", "."]),
        ana("faut", "Il… un billet : toujours 3e personne."),
        err(
            "Je faut un billet.",
            "Il faut un billet.",
            "On ne dit pas je faut. Toujours il faut.",
        ),
        img(
            [
                ("valise", "une valise"),
                ("lac", "un lac"),
                ("ticket", "un billet"),
                ("carnet", "un carnet"),
            ]
        ),
        short("Écrivez cinq lignes : je partirai, j'aurai, deux il faut, je serai."),
        aud("Lisez votre carte, une phrase, une pause."),
    ],
)

S1_EL = lesson(
    "EL — Futur de partir, être, avoir",
    "EL",
    """Objectif
Retenir le futur simple (je/tu/il) et il faut.

Consigne
Apprenez la fiche.

Support — Fiche du carnet
je partirai / tu partiras / il partira / elle partira
être : je serai / tu seras / il sera / nous serons
avoir : j'aurai / tu auras / il aura / nous aurons
il faut + nom : il faut un billet
il faut + infinitif : il faut demander
Attention : je serai (pas je sera). Je partirai (pas je partiras).
Il faut : toujours il. Pas je faut, pas tu faut.""",
    [
        tf("On dit « je faut partir ».", False, "Il faut partir."),
        qcm(
            "Quelle forme est correcte ?",
            ["je sera", "je serai", "je êtreai", "je serais-tu"],
            1,
            "Je serai.",
        ),
        match(
            [
                ("partir", "je partirai"),
                ("être", "je serai"),
                ("avoir", "j'aurai"),
                ("il faut", "3e personne"),
            ]
        ),
        fill("Complétez :\nNous ___ à l'heure. (être)", "serons"),
        wo(["Elle", "partira", "demain", "."]),
        ana("auras", "Le futur de avoir, avec tu."),
        err(
            "Tu aura une valise.",
            "Tu auras une valise.",
            "Tu auras (avec s).",
        ),
        img(
            [
                ("partir", "partir"),
                ("valise", "une valise"),
                ("ticket", "un billet"),
                ("boussole", "une boussole"),
            ]
        ),
        short("Recopiez la fiche. Écrivez quatre phrases : je partirai, je serai, j'aurai, il faut."),
        aud("Dites : je partirai, tu seras, j'aurai, il sera, il faut un billet."),
    ],
)

# ---------------------------------------------------------------------------
# Séquence 2 — Voyager autrement
# je prendrai, je ferai, on pourra
# ---------------------------------------------------------------------------

S2_CO = lesson(
    "CO — Minibus, moto, bateau",
    "CO",
    """Objectif
Comprendre des moyens de voyage au futur : je prendrai, je ferai, on pourra.

Consigne
Qui prendra quoi ? Où ira le bateau ?

Support — Carte du Seuil vers ailleurs
Marc : Je prendrai le minibus. Je ferai la route du lac.
Joël : Moi, je prendrai la moto. On pourra aller jusqu'au Port de la Brise.
Ibrahim Tchami : Là, je prendrai le bateau. Vous serez sur l'eau vers l'Île de Sable-Rouge.
Léa : Je ne prendrai pas l'avion. Je voyagerai autrement.
Aline : Il faut choisir. Il faudra un billet pour le bateau.
Hawa : Nous ferons une pause, un thé, avant.""",
    [
        tf("Léa prendra l'avion.", False, "Léa : « Je ne prendrai pas l'avion. »"),
        qcm(
            "Que prendra Ibrahim au Port de la Brise ?",
            ["Le minibus", "La moto", "Le bateau", "Le fil des heures"],
            2,
            "Ibrahim : « Je prendrai le bateau. »",
        ),
        match(
            [
                ("minibus", "Marc"),
                ("moto", "Joël"),
                ("bateau", "Ibrahim"),
                ("thé", "Hawa"),
            ]
        ),
        fill("Complétez :\nJe ___ le minibus.", "prendrai"),
        wo(["On", "pourra", "aller", "loin", "."]),
        ana("ferai", "Le futur de faire, avec je."),
        err(
            "Je ferrai la route demain.",
            "Je ferai la route demain.",
            "Faire au futur : je ferai (un seul r).",
        ),
        img(
            [
                ("minibus", "le minibus"),
                ("moto", "la moto"),
                ("bateau", "un bateau"),
                ("mer", "la mer"),
            ]
        ),
        short("Notez trois moyens et une phrase avec on pourra."),
        aud(
            "Enregistrez : Je prendrai le minibus. Je ferai la route. On pourra prendre le bateau. Je ne prendrai pas l'avion."
        ),
    ],
)

S2_CE = lesson(
    "CE — Affiche « autrement »",
    "CE",
    """Objectif
Lire une affiche de voyages inventés.

Consigne
Lisez l'affiche sous le figuier.

Support — Affiche ocre
Voyager autrement — Rukiri-Nord
Minibus Figuier 7 — Marc — on prendra la route du lac
Moto Figuier — Joël — on pourra aller au Port de la Brise
Bateau d'Ibrahim — Île de Sable-Rouge — il faudra un billet
Pas d'avion ici. On fera la route, ensemble.
Il faut demander l'heure à l'accueil.
Carnet de route du Seuil""",
    [
        tf("L'affiche propose un avion.", False, "« Pas d'avion ici. »"),
        qcm(
            "Pour l'île, qu'est-ce qu'il faudra ?",
            ["Un tambour", "Un billet", "Une radio", "Un album"],
            1,
            "« Il faudra un billet. »",
        ),
        match(
            [
                ("minibus", "lac"),
                ("moto", "Port de la Brise"),
                ("bateau", "île"),
                ("accueil", "l'heure"),
            ]
        ),
        fill("Complétez :\nOn ___ la route ensemble.", "fera"),
        wo(["Il", "faudra", "un", "billet", "."]),
        ana("pourra", "On… aller loin : futur de pouvoir (deux r)."),
        err(
            "On poura aller au port.",
            "On pourra aller au port.",
            "Pouvoir au futur : pourra (deux r).",
        ),
        img(
            [
                ("bateau", "un bateau"),
                ("ile", "une île"),
                ("ticket", "un billet"),
                ("carte", "une carte"),
            ]
        ),
        short("Recopiez l'affiche. Entourez le moyen que vous choisirez."),
        aud("Lisez l'affiche, une ligne, une pause."),
    ],
)

S2_PO = lesson(
    "PO — Dire je prendrai, je ferai, on pourra",
    "PO",
    """Objectif
Parler d'un voyage : prendre, faire, pouvoir au futur.

Consigne
Répétez, puis choisissez un moyen.

Support — Modèles de Marc
Je prendrai le minibus.
Tu prendras la moto.
Il prendra le bateau.
Je ferai la route.
Nous ferons une pause.
On pourra partir tôt.
Vous serez sur l'eau.
Il faudra un billet.""",
    [
        tf("« Il faudra » est le futur de il faut.", True, "Falloir au futur : il faudra."),
        qcm(
            "Quelle forme de pouvoir est correcte ?",
            ["je poura", "je pourrai", "je peusrai", "je pouvrai"],
            1,
            "Je pourrai (deux r).",
        ),
        match(
            [
                ("prendre", "je prendrai"),
                ("faire", "je ferai"),
                ("pouvoir", "je pourrai"),
                ("falloir", "il faudra"),
            ]
        ),
        fill("Complétez :\nJe ___ la route. (faire)", "ferai"),
        wo(["Vous", "serez", "sur", "l'eau", "."]),
        ana("prendrai", "Le futur de prendre, avec je."),
        err(
            "Je prendreai le minibus.",
            "Je prendrai le minibus.",
            "Prendre : je prendrai.",
        ),
        img(
            [
                ("minibus", "le minibus"),
                ("moto", "la moto"),
                ("bateau", "un bateau"),
                ("pont", "un pont"),
            ]
        ),
        short("Écrivez six phrases : deux prendrai, deux ferai, un pourra, un faudra."),
        aud("Enregistrez les huit modèles, puis votre moyen de voyage."),
    ],
)

S2_PE = lesson(
    "PE — Mon voyage autrement",
    "PE",
    """Objectif
Écrire un petit projet de route.

Consigne
Imitez le mot de Joël.

Support — Mot de Joël
Bonjour,
Je prendrai la moto. Je ferai la route jusqu'au Port de la Brise.
On pourra voir la mer.
Je ne prendrai pas l'avion.
Il faudra de l'eau et un billet.
Joël Mugisha
Rukiri-Nord""",
    [
        tf("Joël prendra l'avion.", False, "« Je ne prendrai pas l'avion. »"),
        qcm(
            "Jusqu'où Joël fera-t-il la route ?",
            ["Le lac des Nénuphars", "Le Port de la Brise", "Mwezi-Haut", "L'accueil"],
            1,
            "« jusqu'au Port de la Brise ».",
        ),
        match(
            [
                ("je prendrai", "moto"),
                ("je ferai", "route"),
                ("on pourra", "mer"),
                ("il faudra", "eau et billet"),
            ]
        ),
        fill("Complétez :\nOn ___ voir la mer.", "pourra"),
        wo(["Je", "ferai", "la", "route", "."]),
        ana("moto", "Le moyen de Joël, pas le minibus."),
        err(
            "Il faudra de l'eau. Je faut un billet.",
            "Il faudra de l'eau. Il faut un billet.",
            "Toujours il faut / il faudra.",
        ),
        img(
            [
                ("moto", "la moto"),
                ("mer", "la mer"),
                ("ticket", "un billet"),
                ("partir", "partir"),
            ]
        ),
        short("Écrivez cinq lignes : je prendrai, je ferai, on pourra, je ne prendrai pas, il faudra."),
        aud("Lisez votre mot, simplement."),
    ],
)

S2_EL = lesson(
    "EL — Prendre, faire, pouvoir, falloir",
    "EL",
    """Objectif
Retenir les futurs irréguliers de la route.

Consigne
Étudiez la fiche.

Support — Fiche de Marc
prendre : je prendrai / tu prendras / il prendra
faire : je ferai / tu feras / il fera / nous ferons
pouvoir : je pourrai / tu pourras / il pourra (deux r)
falloir : il faut / il faudra (seulement il)
être : vous serez
Attention : je ferai (un r). Je pourrai (deux r).
Pas je faut. Pas on poura.""",
    [
        tf("On écrit « je ferrai » (deux r).", False, "Je ferai, un seul r."),
        qcm(
            "Quelle forme est correcte ?",
            ["il faudra", "ils faudra", "il fautent", "je faudra"],
            0,
            "Il faudra : seulement il.",
        ),
        match(
            [
                ("je ferai", "faire"),
                ("je pourrai", "pouvoir"),
                ("je prendrai", "prendre"),
                ("il faudra", "falloir"),
            ]
        ),
        fill("Complétez :\nTu ___ partir tôt. (pouvoir)", "pourras"),
        wo(["Nous", "ferons", "une", "pause", "."]),
        ana("ferons", "Le futur de faire, avec nous."),
        err(
            "Vous sera sur l'eau.",
            "Vous serez sur l'eau.",
            "Vous serez (être).",
        ),
        img(
            [
                ("minibus", "le minibus"),
                ("bateau", "un bateau"),
                ("boussole", "une boussole"),
                ("carte", "une carte"),
            ]
        ),
        short("Recopiez la fiche. Écrivez quatre phrases : prendrai, ferai, pourrai, faudra."),
        aud("Dites : je prendrai, je ferai, je pourrai, il faudra, vous serez."),
    ],
)

# ---------------------------------------------------------------------------
# Séquence 3 — Un tour d'horizon
# lieux inventés ; nous visiterons ; il y aura
# ---------------------------------------------------------------------------

S3_CO = lesson(
    "CO — La carte vers ailleurs",
    "CO",
    """Objectif
Comprendre un tour d'horizon : nord, sud, lac, île, montagne.

Consigne
Quels lieux entend-on ? Qui visitera quoi ?

Support — Carte inventée, épinglée au figuier
Patrick : Voici un tour d'horizon. Au nord, le lac des Nénuphars.
Noura : Au sud, Mwezi-Haut. Il y aura une montagne.
Ibrahim : À l'ouest, le Port de la Brise. Après, l'Île de Sable-Rouge.
Léa : Nous visiterons le lac d'abord. Puis nous irons au port.
Aline : Il faut regarder la carte. Vous serez moins perdus.
Joël : Moi, je resterai près du Seuil. Je verrai la carte ici.""",
    [
        tf("Le lac des Nénuphars est au nord.", True, "Patrick : « Au nord, le lac des Nénuphars. »"),
        qcm(
            "Où est Mwezi-Haut ?",
            ["Au nord", "Au sud", "Sur l'île", "À l'accueil"],
            1,
            "Noura : « Au sud, Mwezi-Haut. »",
        ),
        match(
            [
                ("nord", "lac"),
                ("sud", "Mwezi-Haut"),
                ("ouest", "port et île"),
                ("Seuil", "Joël"),
            ]
        ),
        fill("Complétez :\nNous ___ le lac d'abord.", "visiterons"),
        wo(["Il", "y", "aura", "une", "montagne", "."]),
        ana("irons", "Le futur de aller, avec nous."),
        err(
            "Nous allerons au port.",
            "Nous irons au port.",
            "Aller au futur : nous irons.",
        ),
        img(
            [
                ("carte", "une carte"),
                ("lac", "un lac"),
                ("ile", "une île"),
                ("montagne", "une montagne"),
            ]
        ),
        short("Notez quatre lieux et leur direction (nord, sud, ouest, ici)."),
        aud(
            "Enregistrez : Au nord, le lac. Au sud, la montagne. Nous visiterons le port. Il y aura une île."
        ),
    ],
)

S3_CE = lesson(
    "CE — Légende de la carte",
    "CE",
    """Objectif
Lire une légende de carte inventée.

Consigne
Lisez la légende.

Support — Légende
Carte du Seuil vers ailleurs
N — lac des Nénuphars — 2 h en minibus
S — Mwezi-Haut — montagne, air frais
O — Port de la Brise — bateau d'Ibrahim
Île de Sable-Rouge — après le port
Rive d'Orage — vent, plus loin
Il y aura des pauses. Nous irons lentement.
Rien n'est copié d'une ville réelle. C'est le carnet du Seuil.""",
    [
        tf("Mwezi-Haut est une grande ville réelle.", False, "Lieu inventé du carnet."),
        qcm(
            "Combien d'heures jusqu'au lac, en minibus ?",
            ["Une", "Deux", "Six", "Douze"],
            1,
            "N — 2 h en minibus.",
        ),
        match(
            [
                ("N", "lac"),
                ("S", "montagne"),
                ("O", "port"),
                ("île", "Sable-Rouge"),
            ]
        ),
        fill("Complétez :\nIl y ___ des pauses.", "aura"),
        wo(["Nous", "irons", "lentement", "."]),
        ana("montagne", "Au sud, l'air frais de Mwezi-Haut."),
        err(
            "Il y aura des pause.",
            "Il y aura des pauses.",
            "Pauses au pluriel après des.",
        ),
        img(
            [
                ("nord", "le nord"),
                ("sud", "le sud"),
                ("boussole", "une boussole"),
                ("montagne", "une montagne"),
            ]
        ),
        short("Recopiez quatre lignes de la légende. Ajoutez un lieu inventé."),
        aud("Lisez la légende, du nord vers l'île."),
    ],
)

S3_PO = lesson(
    "PO — Situer et projeter",
    "PO",
    """Objectif
Situer un lieu et dire nous visiterons / il y aura.

Consigne
Répétez, puis décrivez la carte.

Support — Modèles de Patrick
Au nord, il y a un lac.
Au sud, il y aura une montagne.
Nous visiterons le port.
Nous irons à l'île.
Vous serez au Seuil.
Ils partiront tôt.
La carte sera claire.
Il faut regarder le nord.""",
    [
        tf("« Il y aura » est le futur de il y a.", True, "Avoir au futur : aura."),
        qcm(
            "Quelle phrase est au futur ?",
            ["Au nord, il y a un lac", "Il faut regarder le nord", "Nous visiterons le port", "La carte est claire"],
            2,
            "Nous visiterons.",
        ),
        match(
            [
                ("au nord", "lac"),
                ("au sud", "montagne"),
                ("nous irons", "île"),
                ("il faut", "regarder"),
            ]
        ),
        fill("Complétez :\nVous ___ au Seuil. (être)", "serez"),
        wo(["Ils", "partiront", "tôt", "."]),
        ana("visiterons", "Le futur de visiter, avec nous."),
        err(
            "La carte sera claire. Il y auras un lac.",
            "La carte sera claire. Il y aura un lac.",
            "Il y aura (pas auras).",
        ),
        img(
            [
                ("lac", "un lac"),
                ("ile", "une île"),
                ("carte", "une carte"),
                ("visiter", "visiter"),
            ]
        ),
        short("Écrivez six phrases : deux lieux, deux nous visiterons/irons, un il y aura, un il faut."),
        aud("Enregistrez les huit modèles, puis un mini-tour d'horizon."),
    ],
)

S3_PE = lesson(
    "PE — Mon tour d'horizon",
    "PE",
    """Objectif
Écrire un court tour de carte.

Consigne
Imitez le mot de Noura.

Support — Mot de Noura
Noura Sarr
Au nord, nous visiterons le lac.
Au sud, il y aura Mwezi-Haut.
Puis nous irons au Port de la Brise.
Je ne visiterai pas la Rive d'Orage cette fois.
Il faut la carte.
Noura
Carnet de route""",
    [
        tf("Noura visitera la Rive d'Orage cette fois.", False, "« Je ne visiterai pas la Rive d'Orage cette fois. »"),
        qcm(
            "Que visiteront-ils au nord ?",
            ["La montagne", "Le lac", "L'auberge", "L'accueil"],
            1,
            "« Nous visiterons le lac. »",
        ),
        match(
            [
                ("nord", "lac"),
                ("sud", "Mwezi-Haut"),
                ("port", "ensuite"),
                ("carte", "il faut"),
            ]
        ),
        fill("Complétez :\nNous ___ au Port de la Brise.", "irons"),
        wo(["Il", "faut", "la", "carte", "."]),
        ana("horizon", "Un tour d'… : regarder loin, sur la carte."),
        err(
            "Nous visiterons le lac. Je visiterai pas la rive.",
            "Nous visiterons le lac. Je ne visiterai pas la rive.",
            "Négation : ne… pas.",
        ),
        img(
            [
                ("carte", "une carte"),
                ("lac", "un lac"),
                ("nord", "le nord"),
                ("sud", "le sud"),
            ]
        ),
        short("Écrivez cinq lignes : nord, sud, puis, je ne… pas, il faut."),
        aud("Lisez votre tour d'horizon."),
    ],
)

S3_EL = lesson(
    "EL — Visiter, aller, il y aura",
    "EL",
    """Objectif
Retenir nous visiterons, nous irons, il y aura, les points cardinaux.

Consigne
Apprenez la fiche.

Support — Fiche de Patrick
visiter : je visiterai / nous visiterons
aller : j'irai / tu iras / nous irons
il y a → il y aura
nord / sud / est / ouest
il faut + nom (la carte)
Attention : nous irons (pas nous allerons).
Il y aura (pas il y auras).
Lieux du carnet : inventés, pas des villes copiées.""",
    [
        tf("On dit « nous allerons ».", False, "Nous irons."),
        qcm(
            "Quelle forme est correcte ?",
            ["j'allerai", "j'irai", "je irai", "j'allerais"],
            1,
            "J'irai.",
        ),
        match(
            [
                ("aller", "j'irai"),
                ("visiter", "nous visiterons"),
                ("il y a", "il y aura"),
                ("ouest", "port"),
            ]
        ),
        fill("Complétez :\nJ'___ au lac demain. (aller)", "irai"),
        wo(["Au", "nord", "il", "y", "aura", "un", "lac", "."]),
        ana("irai", "Le futur de aller, avec je : j'…"),
        err(
            "Tu iras au sud. J'allerai au nord.",
            "Tu iras au sud. J'irai au nord.",
            "Aller : j'irai.",
        ),
        img(
            [
                ("boussole", "une boussole"),
                ("nord", "le nord"),
                ("sud", "le sud"),
                ("visiter", "visiter"),
            ]
        ),
        short("Recopiez la fiche. Écrivez quatre phrases : irai, visiterons, il y aura, au nord."),
        aud("Dites : j'irai, nous irons, nous visiterons, il y aura, au nord, au sud."),
    ],
)

# ---------------------------------------------------------------------------
# Séquence 4 — Un point de chute
# je resterai ; il faudra une chambre ; auberge
# ---------------------------------------------------------------------------

S4_CO = lesson(
    "CO — L'Auberge des Figues",
    "CO",
    """Objectif
Comprendre un hébergement au futur : je resterai, il faudra une chambre.

Consigne
Où Léa restera-t-elle ? Qu'est-ce qu'il faudra ?

Support — Port de la Brise, clé à la main
Léa : Je resterai à l'Auberge des Figues. Ce n'est pas loin du bateau.
Aline : Il faudra une chambre. Il faudra une clé.
Noura : Moi, je prendrai la petite chambre. Elle sera calme.
Ibrahim : Vous serez près de la mer. Il faudra arriver avant dix-neuf heures.
Joël : Je ne resterai pas. Je rentrerai au Seuil.
Patrick : Il faut demander à l'accueil de l'auberge.""",
    [
        tf("Joël restera à l'auberge.", False, "Joël : « Je ne resterai pas. »"),
        qcm(
            "Où Léa restera-t-elle ?",
            ["Au Seuil", "À l'Auberge des Figues", "À Mwezi-Haut", "Chez Kévin"],
            1,
            "Léa : « Je resterai à l'Auberge des Figues. »",
        ),
        match(
            [
                ("Léa", "auberge"),
                ("Noura", "petite chambre"),
                ("Joël", "rentrera"),
                ("Ibrahim", "avant 19 h"),
            ]
        ),
        fill("Complétez :\nJe ___ à l'auberge.", "resterai"),
        wo(["Il", "faudra", "une", "chambre", "."]),
        ana("chambre", "Le lieu pour dormir, à l'auberge."),
        err(
            "Je resterai à l'auberge. Il faudra une clés.",
            "Je resterai à l'auberge. Il faudra une clé.",
            "Une clé, au singulier.",
        ),
        img(
            [
                ("auberge", "une auberge"),
                ("chambre", "une chambre"),
                ("cle", "une clé"),
                ("rester", "rester"),
            ]
        ),
        short("Notez qui restera, qui rentrera, et deux « il faudra »."),
        aud(
            "Enregistrez : Je resterai à l'auberge. Il faudra une chambre. La chambre sera calme. Je rentrerai demain."
        ),
    ],
)

S4_CE = lesson(
    "CE — Fiche de l'auberge",
    "CE",
    """Objectif
Lire une fiche d'hébergement inventée.

Consigne
Lisez la fiche.

Support — Fiche
Auberge des Figues — Port de la Brise
Chambre petite — Noura — elle sera calme
Chambre près de la mer — Léa — elle regardera l'eau
Arrivée : avant 19 h
Il faudra une clé. Il faudra un nom.
Pas d'avion. On arrivera en bateau ou en moto.
Inventée pour le carnet. Pas un hôtel réel.""",
    [
        tf("Léa aura la chambre petite.", False, "Léa a la chambre près de la mer. Noura a la petite chambre."),
        qcm(
            "Avant quelle heure faut-il arriver ?",
            ["6 h", "12 h", "19 h", "Minuit"],
            2,
            "Arrivée : avant 19 h.",
        ),
        match(
            [
                ("petite chambre", "Noura"),
                ("près de la mer", "Léa"),
                ("clé", "il faudra"),
                ("19 h", "arrivée"),
            ]
        ),
        fill("Complétez :\nOn ___ en bateau. (arriver)", "arrivera"),
        wo(["La", "chambre", "sera", "calme", "."]),
        ana("auberge", "La maison du Port de la Brise, pour une nuit."),
        err(
            "On arriverons en bateau.",
            "On arrivera en bateau.",
            "On = il/elle : arrivera.",
        ),
        img(
            [
                ("chambre", "une chambre"),
                ("auberge", "une auberge"),
                ("cle", "une clé"),
                ("mer", "la mer"),
            ]
        ),
        short("Recopiez la fiche en phrases : je resterai, il faudra, on arrivera."),
        aud("Lisez la fiche, sans aller trop vite."),
    ],
)

S4_PO = lesson(
    "PO — Dire je resterai, il faudra",
    "PO",
    """Objectif
Parler d'un point de chute : rester, arriver, falloir.

Consigne
Répétez, puis inventez une chambre.

Support — Modèles de Noura
Je resterai ici.
Tu resteras près de la mer.
Elle sera calme.
Nous arriverons tôt.
Il faudra une clé.
Il faudra demander.
Vous serez à l'auberge.
Je rentrerai demain.""",
    [
        tf("« Vous serez » est le futur de être.", True, "Vous serez."),
        qcm(
            "Quelle phrase dit un besoin ?",
            ["Je resterai ici", "Elle sera calme", "Il faudra une clé", "Je rentrerai demain"],
            2,
            "Il faudra = besoin au futur.",
        ),
        match(
            [
                ("je resterai", "nuit"),
                ("nous arriverons", "entrée"),
                ("il faudra", "clé"),
                ("je rentrerai", "retour"),
            ]
        ),
        fill("Complétez :\nNous ___ tôt. (arriver)", "arriverons"),
        wo(["Tu", "resteras", "ici", "."]),
        ana("clé", "Il la faudra, pour la chambre."),
        err(
            "Nous arriverons tôt. Il faudra demandé à l'accueil.",
            "Nous arriverons tôt. Il faudra demander à l'accueil.",
            "Il faudra + infinitif : demander.",
        ),
        img(
            [
                ("rester", "rester"),
                ("arriver", "arriver"),
                ("chambre", "une chambre"),
                ("auberge", "une auberge"),
            ]
        ),
        short("Écrivez six phrases : resterai, arriverons, deux il faudra, serez, rentrerai."),
        aud("Enregistrez les huit modèles, puis votre point de chute."),
    ],
)

S4_PE = lesson(
    "PE — Ma fiche de chambre",
    "PE",
    """Objectif
Écrire une fiche de point de chute.

Consigne
Imitez la fiche de Léa.

Support — Fiche de Léa
Léa Niyonzima
Je resterai à l'Auberge des Figues.
La chambre sera près de la mer.
Il faudra une clé. Il faudra arriver avant dix-neuf heures.
Je ne resterai pas longtemps. Je rentrerai au Seuil.
Léa""",
    [
        tf("Léa restera longtemps.", False, "« Je ne resterai pas longtemps. »"),
        qcm(
            "Où sera la chambre de Léa ?",
            ["Sous le figuier", "Près de la mer", "À Mwezi-Haut", "Dans le minibus"],
            1,
            "« près de la mer ».",
        ),
        match(
            [
                ("je resterai", "auberge"),
                ("sera", "près de la mer"),
                ("il faudra", "clé et heure"),
                ("je rentrerai", "Seuil"),
            ]
        ),
        fill("Complétez :\nJe ne resterai ___ longtemps.", "pas"),
        wo(["Je", "rentrerai", "au", "Seuil", "."]),
        ana("rentrerai", "Le futur de rentrer, vers le Seuil."),
        err(
            "La chambre sera près de la mer. Il faudra une clé. Je faut arriver tôt.",
            "La chambre sera près de la mer. Il faudra une clé. Il faudra arriver tôt.",
            "Il faudra (pas je faut).",
        ),
        img(
            [
                ("chambre", "une chambre"),
                ("cle", "une clé"),
                ("mer", "la mer"),
                ("carnet", "un carnet"),
            ]
        ),
        short("Écrivez cinq lignes : je resterai, la chambre sera, deux il faudra, je rentrerai."),
        aud("Lisez votre fiche, calmement."),
    ],
)

S4_EL = lesson(
    "EL — Rester, arriver, il faudra",
    "EL",
    """Objectif
Retenir rester / arriver au futur et il faudra.

Consigne
Apprenez la fiche.

Support — Fiche d'Aline
rester : je resterai / tu resteras / elle restera
arriver : j'arriverai / nous arriverons / on arrivera
rentrer : je rentrerai
être : elle sera / vous serez
il faut / il faudra + nom ou infinitif
Attention : on arrivera (comme il). Pas on arriverons.
Il faudra demander (infinitif).
Auberge des Figues : lieu inventé.""",
    [
        tf("On conjugue « on » comme « nous » au futur (arriverons).", False, "On arrivera, comme il/elle."),
        qcm(
            "Quelle forme est correcte ?",
            ["on arriverons", "on arrivera", "on arriver", "on arriveront"],
            1,
            "On arrivera.",
        ),
        match(
            [
                ("je resterai", "nuit"),
                ("nous arriverons", "nous"),
                ("on arrivera", "on = il"),
                ("il faudra", "besoin"),
            ]
        ),
        fill("Complétez :\nElle ___ près de la mer. (rester)", "restera"),
        wo(["Vous", "serez", "à", "l'auberge", "."]),
        ana("restera", "Le futur de rester, avec elle."),
        err(
            "On arriverons avant dix-neuf heures.",
            "On arrivera avant dix-neuf heures.",
            "On arrivera.",
        ),
        img(
            [
                ("auberge", "une auberge"),
                ("chambre", "une chambre"),
                ("arriver", "arriver"),
                ("rester", "rester"),
            ]
        ),
        short("Recopiez la fiche. Écrivez quatre phrases : resterai, arriverons, sera, faudra."),
        aud("Dites : je resterai, nous arriverons, on arrivera, il faudra une clé, elle sera calme."),
    ],
)

# ---------------------------------------------------------------------------
# Séquence 5 — Choisir sa saison
# il fera chaud ; il pleuvra ; en saison sèche
# ---------------------------------------------------------------------------

S5_CO = lesson(
    "CO — Saison sèche ou pluie",
    "CO",
    """Objectif
Comprendre un choix de saison : il fera, il pleuvra, je partirai.

Consigne
Quelle saison pour le lac ? Pour l'île ?

Support — Carnet ouvert, thé
Patrick : En saison sèche, il fera chaud. Le lac sera clair.
Hawa : En saison des pluies, il pleuvra. La route sera longue.
Léa : Je partirai en saison sèche. Je verrai le soleil.
Noura : Moi, je visiterai Mwezi-Haut en saison fraîche. Il fera moins chaud.
Ibrahim : Pour le bateau, il faudra peu de vent. Pas la Rive d'Orage.
Aline : Il faut choisir sa saison. On ne partira pas tous le même jour.""",
    [
        tf("Léa partira en saison des pluies.", False, "Léa : « Je partirai en saison sèche. »"),
        qcm(
            "Que fera-t-il en saison sèche, d'après Patrick ?",
            ["Il pleuvra", "Il fera chaud", "Il neigera", "Il fera nuit à midi"],
            1,
            "Patrick : « Il fera chaud. »",
        ),
        match(
            [
                ("saison sèche", "chaud, lac clair"),
                ("pluies", "route longue"),
                ("saison fraîche", "Mwezi-Haut"),
                ("peu de vent", "bateau"),
            ]
        ),
        fill("Complétez :\nIl ___ chaud. (faire)", "fera"),
        wo(["Il", "pleuvra", "demain", "."]),
        ana("pleuvra", "Le futur de pleuvoir."),
        err(
            "Il ferra chaud en saison sèche.",
            "Il fera chaud en saison sèche.",
            "Faire : il fera (un r).",
        ),
        img(
            [
                ("saison", "une saison"),
                ("soleil", "le soleil"),
                ("pluie", "la pluie"),
                ("vent", "le vent"),
            ]
        ),
        short("Notez trois saisons et une phrase il fera / il pleuvra."),
        aud(
            "Enregistrez : En saison sèche, il fera chaud. Il pleuvra en saison des pluies. Je partirai. Je verrai le soleil."
        ),
    ],
)

S5_CE = lesson(
    "CE — Tableau des saisons",
    "CE",
    """Objectif
Lire un tableau de saisons inventé pour le carnet.

Consigne
Lisez le tableau.

Support — Tableau Figuier
Choisir sa saison
Saison sèche — il fera chaud — lac des Nénuphars — soleil
Saison des pluies — il pleuvra — route longue — rester au Seuil
Saison fraîche — il fera moins chaud — Mwezi-Haut
Vent fort — Rive d'Orage — on ne prendra pas le bateau
Il faudra regarder le ciel. Il faut demander à Patrick.
Carnet de route""",
    [
        tf("On prendra le bateau par vent fort.", False, "Vent fort : on ne prendra pas le bateau."),
        qcm(
            "Où aller en saison fraîche ?",
            ["Au lac seulement", "À Mwezi-Haut", "À la Rive d'Orage", "Nulle part"],
            1,
            "Saison fraîche — Mwezi-Haut.",
        ),
        match(
            [
                ("sèche", "soleil"),
                ("pluies", "Seuil"),
                ("fraîche", "montagne"),
                ("vent fort", "pas de bateau"),
            ]
        ),
        fill("Complétez :\nIl ___ regarder le ciel. (futur de falloir)", "faudra"),
        wo(["Il", "fera", "moins", "chaud", "."]),
        ana("saison", "Un moment de l'année, sèche ou des pluies."),
        err(
            "Il pleuvra. Il faut tu restes au Seuil.",
            "Il pleuvra. Il faut rester au Seuil.",
            "Il faut + infinitif.",
        ),
        img(
            [
                ("soleil", "le soleil"),
                ("pluie", "la pluie"),
                ("ete", "l'été"),
                ("hiver", "l'hiver"),
            ]
        ),
        short("Recopiez le tableau. Ajoutez votre saison et un il fera / il pleuvra."),
        aud("Lisez le tableau, une saison, une pause."),
    ],
)

S5_PO = lesson(
    "PO — Dire il fera, il pleuvra",
    "PO",
    """Objectif
Parler du temps au futur et d'un choix de saison.

Consigne
Répétez, puis choisissez une saison.

Support — Modèles d'Hawa
Il fera chaud.
Il fera frais.
Il pleuvra.
Il y aura du vent.
Je partirai en saison sèche.
Nous resterons s'il pleut.
Il faudra un chapeau.
En hiver, ailleurs, il fera froid.""",
    [
        tf("« Il fera froid » décrit le temps au futur.", True, "Faire au futur, pour le temps."),
        qcm(
            "Quelle phrase est un projet de départ ?",
            ["Il pleuvra", "Il y aura du vent", "Je partirai en saison sèche", "Il fera frais"],
            2,
            "Je partirai.",
        ),
        match(
            [
                ("il fera", "chaud / frais / froid"),
                ("il pleuvra", "pluie"),
                ("il y aura", "vent"),
                ("il faudra", "chapeau"),
            ]
        ),
        fill("Complétez :\nEn hiver, il fera ___.", "froid"),
        wo(["Je", "partirai", "en", "saison", "sèche", "."]),
        ana("chaud", "Le contraire de froid, en saison sèche."),
        err(
            "Il fera chaud. Je partirai. Il faudra un chapeaux.",
            "Il fera chaud. Je partirai. Il faudra un chapeau.",
            "Un chapeau, au singulier.",
        ),
        img(
            [
                ("soleil", "le soleil"),
                ("pluie", "la pluie"),
                ("printemps", "le printemps"),
                ("automne", "l'automne"),
            ]
        ),
        short("Écrivez six phrases : deux il fera, un il pleuvra, un je partirai, un nous resterons, un il faudra."),
        aud("Enregistrez les huit modèles, puis votre saison."),
    ],
)

S5_PE = lesson(
    "PE — Ma saison",
    "PE",
    """Objectif
Écrire un choix de saison.

Consigne
Imitez le mot de Léa.

Support — Mot de Léa
Léa
Je partirai en saison sèche.
Il fera chaud. Il y aura du soleil.
Je ne partirai pas s'il pleut.
Il faudra de l'eau. Il faudra un chapeau.
À bientôt, lac des Nénuphars.
Léa""",
    [
        tf("Léa partira s'il pleut.", False, "« Je ne partirai pas s'il pleut. »"),
        qcm(
            "Que faudra-t-il, d'après Léa ?",
            ["Un tambour et une radio", "De l'eau et un chapeau", "Un avion", "De la neige"],
            1,
            "Eau et chapeau.",
        ),
        match(
            [
                ("saison sèche", "départ"),
                ("il fera", "chaud"),
                ("s'il pleut", "pas de départ"),
                ("il faudra", "eau, chapeau"),
            ]
        ),
        fill("Complétez :\nIl y aura du ___.", "soleil"),
        wo(["Il", "fera", "chaud", "."]),
        ana("soleil", "Il y en aura, en saison sèche."),
        err(
            "Je partirai en saison sèche. Il ferra chaud.",
            "Je partirai en saison sèche. Il fera chaud.",
            "Il fera (un r).",
        ),
        img(
            [
                ("saison", "une saison"),
                ("soleil", "le soleil"),
                ("pluie", "la pluie"),
                ("valise", "une valise"),
            ]
        ),
        short("Écrivez cinq lignes : je partirai en…, il fera, je ne… pas, deux il faudra."),
        aud("Lisez votre mot de saison."),
    ],
)

S5_EL = lesson(
    "EL — Il fera, il pleuvra, saisons",
    "EL",
    """Objectif
Retenir le temps au futur et les saisons du carnet.

Consigne
Apprenez la fiche.

Support — Fiche d'Hawa
il fera chaud / frais / froid
il pleuvra
il y aura du vent / du soleil
saison sèche / saison des pluies / saison fraîche
ailleurs : printemps, été, automne, hiver
faire (temps) : il fera
Attention : il fera (pas il ferra). Il pleuvra.
Il faut / il faudra choisir sa saison.
On ne partira pas tous le même jour.""",
    [
        tf("On écrit « il ferra froid ».", False, "Il fera froid."),
        qcm(
            "Quelle forme est correcte ?",
            ["il pleuvra", "il pleuvera", "il pleusera", "il pleuvoir"],
            0,
            "Il pleuvra.",
        ),
        match(
            [
                ("saison sèche", "chaud"),
                ("pluies", "il pleuvra"),
                ("hiver", "froid"),
                ("été", "soleil"),
            ]
        ),
        fill("Complétez :\nEn saison des pluies, il ___.", "pleuvra"),
        wo(["Il", "y", "aura", "du", "vent", "."]),
        ana("frais", "Moins chaud, à Mwezi-Haut."),
        err(
            "Il pleuvra. Il fera froid. Il fauts un chapeau.",
            "Il pleuvra. Il fera froid. Il faut un chapeau.",
            "Il faut, sans s.",
        ),
        img(
            [
                ("ete", "l'été"),
                ("hiver", "l'hiver"),
                ("printemps", "le printemps"),
                ("automne", "l'automne"),
            ]
        ),
        short("Recopiez la fiche. Écrivez quatre phrases : fera, pleuvra, saison sèche, il faudra."),
        aud("Dites : il fera chaud, il pleuvra, il y aura du vent, printemps, été, automne, hiver."),
    ],
)

# ---------------------------------------------------------------------------
# Séquence 6 — Carnets de route
# j'écrirai ; je serai ; nous raconterons
# ---------------------------------------------------------------------------

S6_CO = lesson(
    "CO — On écrira le chemin",
    "CO",
    """Objectif
Comprendre un projet de carnet : j'écrirai, nous raconterons, je serai.

Consigne
Qui écrira quoi ? Que racontera-t-on au retour ?

Support — Sous le figuier, carnets ouverts
Léa : J'écrirai chaque soir. Je serai fatiguée, mais contente.
Noura : Nous raconterons le lac, le bateau, l'auberge.
Mado : Il faut une ligne par jour. On pourra relire plus tard.
Patrick : Je noterai les heures. Vous serez précis.
Joël : Moi, j'écrirai peu. Je dessinerai la moto.
Aline : Au retour, on sera au Seuil. Il faudra lire une page, ensemble.""",
    [
        tf("Léa écrira chaque soir.", True, "Léa : « J'écrirai chaque soir. »"),
        qcm(
            "Que dessinera Joël ?",
            ["Le lac", "La moto", "L'auberge", "La radio"],
            1,
            "Joël : « Je dessinerai la moto. »",
        ),
        match(
            [
                ("Léa", "écrira"),
                ("Noura", "racontera le voyage"),
                ("Patrick", "notera les heures"),
                ("Joël", "dessinera"),
            ]
        ),
        fill("Complétez :\nJ'___ chaque soir. (écrire)", "écrirai"),
        wo(["Nous", "raconterons", "le", "lac", "."]),
        ana("écrirai", "Le futur de écrire, avec je."),
        err(
            "Je serai fatiguée. J'écrireai chaque soir.",
            "Je serai fatiguée. J'écrirai chaque soir.",
            "Écrire : j'écrirai.",
        ),
        img(
            [
                ("carnet", "un carnet"),
                ("visiter", "visiter"),
                ("partir", "partir"),
                ("pont", "un pont"),
            ]
        ),
        short("Notez quatre verbes au futur entendus (écrire, raconter, noter, dessiner)."),
        aud(
            "Enregistrez : J'écrirai chaque soir. Nous raconterons le lac. Je serai contente. Il faudra lire une page."
        ),
    ],
)

S6_CE = lesson(
    "CE — Consignes du carnet",
    "CE",
    """Objectif
Lire des consignes pour tenir un carnet de route.

Consigne
Lisez la page.

Support — Page de Mado
Carnets de route — Seuil des Sources
1. J'écrirai une ligne le soir.
2. Nous raconterons un lieu : lac, port, île, auberge.
3. Il faudra la date et l'heure.
4. On pourra coller un petit dessin.
5. Au retour, nous serons sous le figuier. Nous lirons.
Inventé pour le Seuil. Pas un guide de voyage réel.""",
    [
        tf("Il faudra la date et l'heure.", True, "Point 3 de la page."),
        qcm(
            "Où sera-t-on au retour, pour lire ?",
            ["À l'île", "Sous le figuier", "À Mwezi-Haut", "Dans le minibus"],
            1,
            "« Nous serons sous le figuier. »",
        ),
        match(
            [
                ("j'écrirai", "une ligne"),
                ("nous raconterons", "un lieu"),
                ("il faudra", "date et heure"),
                ("nous lirons", "retour"),
            ]
        ),
        fill("Complétez :\nNous ___ sous le figuier. (être)", "serons"),
        wo(["On", "pourra", "coller", "un", "dessin", "."]),
        ana("raconterons", "Le futur de raconter, avec nous."),
        err(
            "Nous serons sous le figuier. Nous liserons une page.",
            "Nous serons sous le figuier. Nous lirons une page.",
            "Lire au futur : nous lirons.",
        ),
        img(
            [
                ("carnet", "un carnet"),
                ("carte", "une carte"),
                ("ticket", "un billet"),
                ("boussole", "une boussole"),
            ]
        ),
        short("Recopiez trois consignes. Ajoutez la vôtre au futur."),
        aud("Lisez la page de Mado, un numéro, une pause."),
    ],
)

S6_PO = lesson(
    "PO — Dire j'écrirai, nous serons",
    "PO",
    """Objectif
Projeter l'écriture du voyage : écrire, raconter, être, lire.

Consigne
Répétez, puis dites ce que vous écrirez.

Support — Modèles de Mado
J'écrirai une ligne.
Tu écriras la date.
Nous raconterons le bateau.
Je serai contente.
Vous serez précis.
Nous lirons au retour.
Il faudra un crayon.
On pourra dessiner.""",
    [
        tf("« Nous lirons » est le futur de lire.", True, "Nous lirons."),
        qcm(
            "Quelle forme d'être est correcte au futur, avec je ?",
            ["je sera", "je serai", "je suisrai", "j'éterai"],
            1,
            "Je serai.",
        ),
        match(
            [
                ("écrire", "j'écrirai"),
                ("être", "je serai"),
                ("lire", "nous lirons"),
                ("raconter", "nous raconterons"),
            ]
        ),
        fill("Complétez :\nTu ___ la date. (écrire)", "écriras"),
        wo(["Je", "serai", "contente", "."]),
        ana("lirons", "Le futur de lire, avec nous."),
        err(
            "Je serai content.",
            "Je serai contente.",
            "Léa = elle : contente.",
        ),
        img(
            [
                ("carnet", "un carnet"),
                ("partir", "partir"),
                ("arriver", "arriver"),
                ("visiter", "visiter"),
            ]
        ),
        short("Écrivez six phrases : écrirai, raconterons, serai, serez, lirons, faudra."),
        aud("Enregistrez les huit modèles, puis une ligne pour votre carnet."),
    ],
)

S6_PE = lesson(
    "PE — Ma première ligne",
    "PE",
    """Objectif
Écrire la première page d'un carnet de route.

Consigne
Imitez la page de Noura.

Support — Page de Noura
Carnet de Noura Sarr
Demain, je partirai. J'écrirai le soir.
Nous visiterons le lac. Je serai à l'Auberge des Figues.
Il faudra une ligne, seulement une.
Au retour, nous raconterons tout sous le figuier.
Noura""",
    [
        tf("Noura écrira le matin, d'après sa page.", False, "« J'écrirai le soir. »"),
        qcm(
            "Combien de lignes faudra-t-il, d'après Noura ?",
            ["Dix", "Une", "Zéro", "Cent"],
            1,
            "« une ligne, seulement une ».",
        ),
        match(
            [
                ("je partirai", "demain"),
                ("j'écrirai", "le soir"),
                ("je serai", "auberge"),
                ("nous raconterons", "retour"),
            ]
        ),
        fill("Complétez :\nNous ___ tout sous le figuier.", "raconterons"),
        wo(["J'écrirai", "le", "soir", "."]),
        ana("ligne", "Une seule, chaque soir, dans le carnet."),
        err(
            "Demain je partirai. J'écrirai le soir. Je sera à l'auberge.",
            "Demain je partirai. J'écrirai le soir. Je serai à l'auberge.",
            "Je serai (pas je sera).",
        ),
        img(
            [
                ("carnet", "un carnet"),
                ("lac", "un lac"),
                ("auberge", "une auberge"),
                ("partir", "partir"),
            ]
        ),
        short("Écrivez cinq lignes de carnet : partirai, écrirai, visiterons, serai, raconterons."),
        aud("Lisez votre première page, une phrase, une pause.")
    ],
)

S6_EL = lesson(
    "EL — Écrire, être, lire au futur",
    "EL",
    """Objectif
Retenir j'écrirai, je serai, nous lirons, nous raconterons.

Consigne
Apprenez la fiche, puis promettez une ligne.

Support — Fiche de Mado
écrire : j'écrirai / tu écriras / nous écrirons
être : je serai / tu seras / nous serons / vous serez
lire : je lirai / nous lirons
raconter : nous raconterons
il faudra une ligne
on pourra dessiner
Attention : j'écrirai (pas j'écrireai). Je serai (pas je sera).
Nous lirons (pas nous liserons).
Le carnet est inventé, sous le figuier.""",
    [
        tf("On dit « j'écrireai ».", False, "J'écrirai."),
        qcm(
            "Quelle forme est correcte ?",
            ["nous liserons", "nous lirons", "nous lireons", "nous lesirons"],
            1,
            "Nous lirons.",
        ),
        match(
            [
                ("écrire", "j'écrirai"),
                ("être", "nous serons"),
                ("lire", "nous lirons"),
                ("raconter", "nous raconterons"),
            ]
        ),
        fill("Complétez :\nVous ___ précis. (être)", "serez"),
        wo(["Nous", "écrirons", "une", "ligne", "."]),
        ana("serons", "Le futur de être, avec nous."),
        err(
            "Nous raconterons le lac. Vous sera sous le figuier.",
            "Nous raconterons le lac. Vous serez sous le figuier.",
            "Vous serez.",
        ),
        img(
            [
                ("carnet", "un carnet"),
                ("boussole", "une boussole"),
                ("carte", "une carte"),
                ("visiter", "visiter"),
            ]
        ),
        short("Recopiez la fiche. Écrivez quatre futurs : écrirai, serai, lirons, raconterons."),
        aud("Dites : j'écrirai, je serai, nous serons, nous lirons, nous raconterons, il faudra une ligne."),
    ],
)

SEQUENCES = [
    {"title": "Envie de partir", "lessons": [S1_CO, S1_CE, S1_PO, S1_PE, S1_EL]},
    {"title": "Voyager autrement", "lessons": [S2_CO, S2_CE, S2_PO, S2_PE, S2_EL]},
    {"title": "Un tour d'horizon", "lessons": [S3_CO, S3_CE, S3_PO, S3_PE, S3_EL]},
    {"title": "Un point de chute", "lessons": [S4_CO, S4_CE, S4_PO, S4_PE, S4_EL]},
    {"title": "Choisir sa saison", "lessons": [S5_CO, S5_CE, S5_PO, S5_PE, S5_EL]},
    {"title": "Carnets de route", "lessons": [S6_CO, S6_CE, S6_PO, S6_PE, S6_EL]},
]
