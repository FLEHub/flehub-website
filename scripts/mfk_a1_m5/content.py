"""MFK A1 Module 5 — Le fil des journées (Seuil des Sources)."""

from __future__ import annotations

IMG = "/elearning/mfk-a1-m5/{name}.svg"


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
    "title": "A1 — Le fil des journées",
    "description": (
        "Grande étape 5 : indiquer l'heure, parler des habitudes, raconter "
        "une journée de travail, s'informer sur les sorties et inviter — "
        "fil des heures sous le figuier du Seuil des Sources (Rukiri-Nord)."
    ),
}

# ---------------------------------------------------------------------------
# Séquence 1 — Une journée dans le monde
# Quelle heure est-il ? Il est… ; à + heure ; du matin / de l'après-midi / du soir
# ---------------------------------------------------------------------------

S1_CO = lesson(
    "CO — Le fil des heures",
    "CO",
    """Objectif
Comprendre l'heure : il est…, à + heure, du matin / de l'après-midi / du soir.

Consigne
Lisez le dialogue (à écouter avec l'enseignant). Quelle heure est-il ? Qui fait quoi, et à quelle heure ?

Support — Sous le figuier, cartes sur un fil
Aline : Le fil commence. Quelle heure est-il ?
Léa : Il est sept heures du matin.
Marc : À six heures, le minibus part. Moi, je suis déjà sur la route.
Hawa : À midi, on prend le thé ici.
Patrick : À trois heures de l'après-midi, je rentre du jardin.
Joël : À minuit, plus de moto. Je dors.""",
    [
        tf("Il est sept heures du matin, au début du dialogue.", True, "Léa : « Il est sept heures du matin. »"),
        qcm(
            "À quelle heure le minibus de Marc part-il ?",
            ["À midi", "À six heures", "À minuit", "À trois heures"],
            1,
            "Marc : « À six heures, le minibus part. »",
        ),
        match(
            [
                ("sept heures", "du matin"),
                ("midi", "le thé"),
                ("trois heures", "de l'après-midi"),
                ("minuit", "Joël dort"),
            ]
        ),
        fill("Complétez :\nIl ___ sept heures du matin.", "est"),
        wo(["Il", "est", "midi", "."]),
        ana("heures", "On les compte : une, deux, trois…"),
        err(
            "Il est sept heure du matin.",
            "Il est sept heures du matin.",
            "Après un nombre différent de un : heures, au pluriel.",
        ),
        img(
            [
                ("heure", "l'heure"),
                ("midi", "midi"),
                ("minuit", "minuit"),
                ("fil", "le fil"),
            ]
        ),
        short("Notez quatre heures entendues et l'activité (minibus, thé, jardin, sommeil)."),
        aud(
            "Enregistrez : Quelle heure est-il ? Il est sept heures du matin. À midi, on prend le thé. À minuit, je dors."
        ),
    ],
)

S1_CE = lesson(
    "CE — Les cartes du fil",
    "CE",
    """Objectif
Lire des heures et des moments de la journée.

Consigne
Lisez les cartes épinglées sur le fil, puis répondez.

Support — Cartes (encre ocre)
1. 6 h — Marc — minibus Figuier 7 — du matin
2. 7 h — Aline — accueil du Seuil — du matin
3. 12 h — Hawa — thé sous le figuier — midi
4. 15 h — Patrick — jardin des Sources — de l'après-midi
5. 19 h — Rose — Salle des Herbes — du soir
Radio Figuier : « Il est… à Rukiri-Nord. »""",
    [
        tf("Rose danse à sept heures du matin.", False, "Carte 5 : 19 h, du soir, Salle des Herbes."),
        qcm(
            "Qui est à l'accueil à sept heures ?",
            ["Marc", "Hawa", "Aline", "Patrick"],
            2,
            "Carte 2 : 7 h — Aline — accueil.",
        ),
        match(
            [
                ("6 h", "minibus"),
                ("12 h", "thé"),
                ("15 h", "jardin"),
                ("19 h", "salle"),
            ]
        ),
        fill("Complétez :\nIl est trois heures ___ l'après-midi.", "de"),
        wo(["Il", "est", "sept", "heures", "."]),
        ana("matin", "Le début de la journée, avant midi."),
        err(
            "Il est midi heures.",
            "Il est midi.",
            "Midi et minuit : sans le mot heures.",
        ),
        img(
            [
                ("matin", "le matin"),
                ("apresmidi", "l'après-midi"),
                ("soir", "le soir"),
                ("carte", "une carte"),
            ]
        ),
        short("Recopiez les cinq cartes. Ajoutez une carte pour vous : heure + lieu."),
        aud("Lisez les cinq cartes, sans aller trop vite."),
    ],
)

S1_PO = lesson(
    "PO — Dire l'heure",
    "PO",
    """Objectif
Dire l'heure et le moment : il est…, à… heures, du matin / du soir.

Consigne
Répétez les modèles, puis dites l'heure maintenant (vraie ou inventée).

Support — Modèles d'Aline
Quelle heure est-il ?
Il est sept heures.
Il est sept heures du matin.
Il est midi.
Il est trois heures de l'après-midi.
Il est sept heures du soir.
Il est minuit.
À six heures, je commence.""",
    [
        tf("« Quelle heure est-il ? » sert à demander l'heure.", True, "Question d'Aline sur le fil."),
        qcm(
            "Quelle phrase est correcte ?",
            [
                "Il est sept heure",
                "Il est sept heures",
                "Il sont sept heures",
                "Il es sept heures",
            ],
            1,
            "Il est + nombre + heures.",
        ),
        match(
            [
                ("du matin", "avant midi"),
                ("de l'après-midi", "après 12 h"),
                ("du soir", "après le travail"),
                ("minuit", "la nuit"),
            ]
        ),
        fill("Complétez :\nQuelle heure ___-il ?", "est"),
        wo(["Il", "est", "minuit", "."]),
        ana("midi", "Douze heures, on prend souvent le thé."),
        err(
            "Il est une heures.",
            "Il est une heure.",
            "Une heure : singulier.",
        ),
        img(
            [
                ("heure", "l'heure"),
                ("midi", "midi"),
                ("minuit", "minuit"),
                ("reveil", "le réveil"),
            ]
        ),
        short("Écrivez six phrases : trois « il est… », trois « à… heures, je… »."),
        aud("Enregistrez les huit modèles, puis l'heure de votre réveil."),
    ],
)

S1_PE = lesson(
    "PE — Ma carte pour le fil",
    "PE",
    """Objectif
Écrire une petite carte d'heure, comme sur le fil.

Consigne
Imitez la carte de Léa. Changez l'heure et l'activité.

Support — Carte de Léa
Léa Niyonzima
Il est huit heures du matin.
À huit heures, je prends le thé.
À midi, je lis sous le figuier.
Léa
Fil des heures — Seuil des Sources""",
    [
        tf("Léa prend le thé à midi.", False, "Elle prend le thé à huit heures. À midi, elle lit."),
        qcm(
            "Quelle heure Léa écrit-elle en premier ?",
            ["Midi", "Huit heures du matin", "Minuit", "Trois heures"],
            1,
            "« Il est huit heures du matin. »",
        ),
        match(
            [
                ("huit heures", "thé"),
                ("midi", "lire"),
                ("Léa", "signature"),
                ("fil", "le Seuil"),
            ]
        ),
        fill("Complétez :\nÀ huit heures, je prends ___ thé.", "le"),
        wo(["Il", "est", "huit", "heures", "."]),
        ana("soir", "Le moment après l'après-midi, avant minuit."),
        err(
            "À huit heures je prends le thés.",
            "À huit heures je prends le thé.",
            "Thé reste au singulier : le thé.",
        ),
        img(
            [
                ("the", "le thé"),
                ("carte", "une carte"),
                ("fil", "le fil"),
                ("matin", "le matin"),
            ]
        ),
        short("Écrivez votre carte : prénom, il est…, à… je…, signature."),
        aud("Lisez votre carte, une phrase, une pause."),
    ],
)

S1_EL = lesson(
    "EL — Il est, à, du matin",
    "EL",
    """Objectif
Retenir l'heure : il est, à + heure, midi / minuit, du matin / du soir.

Consigne
Apprenez la fiche, puis dites l'heure.

Support — Fiche du fil
Quelle heure est-il ?
Il est + nombre + heures
Il est une heure (singulier)
Il est midi. Il est minuit.
à + heure : à six heures
du matin / de l'après-midi / du soir
Attention : heures au pluriel (sauf une heure).
On ne dit pas « midi heures ».""",
    [
        tf("On dit « il est midi heures ».", False, "Il est midi. Sans heures."),
        qcm(
            "Quelle forme est correcte ?",
            ["à le six heures", "à six heure", "à six heures", "à six-heures"],
            2,
            "À six heures.",
        ),
        match(
            [
                ("il est", "l'heure maintenant"),
                ("à", "l'heure d'une action"),
                ("midi", "12 h"),
                ("minuit", "0 h"),
            ]
        ),
        fill("Complétez :\nIl est une ___.", "heure"),
        wo(["Quelle", "heure", "est-il", "?"]),
        ana("minuit", "L'heure où Joël range la moto."),
        err(
            "Il est minuit heures.",
            "Il est minuit.",
            "Minuit : sans heures.",
        ),
        img(
            [
                ("heure", "l'heure"),
                ("midi", "midi"),
                ("soir", "le soir"),
                ("reveil", "le réveil"),
            ]
        ),
        short("Recopiez la fiche. Écrivez quatre heures : matin, midi, après-midi, soir."),
        aud("Dites : Quelle heure est-il ? Il est une heure. Il est midi. Il est minuit. À six heures."),
    ],
)

# ---------------------------------------------------------------------------
# Séquence 2 — Rythmes de vie
# je me lève / je me couche ; le matin, l'après-midi, le soir ; d'habitude
# ---------------------------------------------------------------------------

S2_CO = lesson(
    "CO — De l'aube au fil",
    "CO",
    """Objectif
Comprendre un rythme de journée : je me lève, je prends, je dîne, je me couche.

Consigne
Qui se lève tôt ? Qui se couche à quelle heure ?

Support — Banc près de la fontaine
Léa : D'habitude, je me lève à six heures.
Aline : Moi aussi. Je prends le thé, puis j'ouvre l'accueil.
Patrick : Je me lève à sept heures. Le matin, je marche au jardin.
Hawa : L'après-midi, je range les cartes. Le soir, je dîne ici.
Joël : Je me couche à minuit. Pas trop tôt.
Rose : Moi, je me couche à vingt-deux heures. Demain, je danse.""",
    [
        tf("Léa se lève à six heures.", True, "Léa : « D'habitude, je me lève à six heures. »"),
        qcm(
            "À quelle heure Joël se couche-t-il ?",
            ["À six heures", "À sept heures", "À minuit", "À vingt-deux heures"],
            2,
            "Joël : « Je me couche à minuit. »",
        ),
        match(
            [
                ("Léa", "se lève à 6 h"),
                ("Patrick", "marche le matin"),
                ("Hawa", "dîne le soir"),
                ("Rose", "se couche à 22 h"),
            ]
        ),
        fill("Complétez :\nJe me ___ à six heures.", "lève"),
        wo(["Je", "me", "couche", "tard", "."]),
        ana("lève", "Le premier verbe du matin, avec je me…"),
        err(
            "Je se lève à six heures.",
            "Je me lève à six heures.",
            "Je me lève (pas je se).",
        ),
        img(
            [
                ("lever", "se lever"),
                ("petitdej", "le petit déjeuner"),
                ("diner", "dîner"),
                ("coucher", "se coucher"),
            ]
        ),
        short("Notez pour quatre personnes : se lever / activité / se coucher."),
        aud(
            "Enregistrez : Je me lève à six heures. Je prends le thé. Le soir, je dîne. Je me couche à vingt-deux heures."
        ),
    ],
)

S2_CE = lesson(
    "CE — Cartes-rythmes",
    "CE",
    """Objectif
Lire des rythmes de vie : le matin, l'après-midi, le soir.

Consigne
Lisez les cartes, puis répondez.

Support — Cartes du fil
Léa — Je me lève à 6 h. Le matin, je prends le thé. Je me couche à 22 h.
Aline — Je me lève à 6 h. Puis j'ouvre l'accueil. Le soir, je range le fil.
Patrick — Je me lève à 7 h. Le matin, je marche. L'après-midi, je guide.
Joël — Je me lève à 8 h. Le soir, je roule. Je me couche à minuit.
Règle du Seuil : une heure pour se lever, une heure pour se coucher.""",
    [
        tf("Patrick se lève à six heures.", False, "Carte Patrick : 7 h."),
        qcm(
            "Qui se couche à minuit ?",
            ["Léa", "Aline", "Patrick", "Joël"],
            3,
            "Joël : « Je me couche à minuit. »",
        ),
        match(
            [
                ("le matin", "thé, marche, accueil"),
                ("l'après-midi", "Patrick guide"),
                ("le soir", "fil et moto"),
                ("d'habitude", "presque toujours"),
            ]
        ),
        fill("Complétez :\nJe me ___ à minuit.", "couche"),
        wo(["Je", "prends", "le", "thé", "."]),
        ana("couche", "Le dernier verbe de la journée, avec je me…"),
        err(
            "Tu me lèves à sept heures.",
            "Tu te lèves à sept heures.",
            "Tu te lèves (pas tu me).",
        ),
        img(
            [
                ("matin", "le matin"),
                ("apresmidi", "l'après-midi"),
                ("soir", "le soir"),
                ("the", "le thé"),
            ]
        ),
        short("Recopiez une carte. Ajoutez la vôtre : je me lève / je me couche."),
        aud("Lisez les quatre cartes, puis la règle du Seuil."),
    ],
)

S2_PO = lesson(
    "PO — Raconter sa journée",
    "PO",
    """Objectif
Dire son rythme : je me lève, je prends, je dîne, je me couche.

Consigne
Répétez, puis parlez de votre journée.

Support — Modèles de Léa
Je me lève à six heures.
Je prends le thé.
Le matin, je marche.
L'après-midi, je lis.
Le soir, je dîne.
Je me couche à vingt-deux heures.
D'habitude, je me lève tôt.
Parfois, je me couche tard.""",
    [
        tf("« D'habitude » veut dire presque toujours.", True, "Habitude = souvent, presque chaque jour."),
        qcm(
            "Quel mot introduit une exception ?",
            ["d'habitude", "le matin", "parfois", "puis"],
            2,
            "Parfois = de temps en temps.",
        ),
        match(
            [
                ("je me lève", "matin"),
                ("je dîne", "soir"),
                ("je me couche", "nuit"),
                ("parfois", "pas toujours"),
            ]
        ),
        fill("Complétez :\nD'habitude, je me lève ___.", "tôt"),
        wo(["Le", "matin", "je", "marche", "."]),
        ana("parfois", "Le contraire de toujours, un peu."),
        err(
            "Je me couche à vingt-deux heure.",
            "Je me couche à vingt-deux heures.",
            "Heures au pluriel.",
        ),
        img(
            [
                ("lever", "se lever"),
                ("coucher", "se coucher"),
                ("diner", "dîner"),
                ("reveil", "le réveil"),
            ]
        ),
        short("Écrivez huit phrases comme Léa, avec vos heures (vraies ou inventées)."),
        aud("Enregistrez les huit modèles, puis votre rythme."),
    ],
)

S2_PE = lesson(
    "PE — Ma journée en six lignes",
    "PE",
    """Objectif
Écrire un petit rythme de vie.

Consigne
Imitez le mot de Patrick.

Support — Mot de Patrick
Bonjour,
D'habitude, je me lève à sept heures.
Le matin, je marche au jardin.
L'après-midi, je suis guide.
Le soir, je dîne au Seuil.
Je me couche à vingt-deux heures.
Patrick
Rukiri-Nord""",
    [
        tf("Patrick dîne au Seuil.", True, "« Le soir, je dîne au Seuil. »"),
        qcm(
            "Que fait Patrick le matin ?",
            ["Il dîne", "Il se couche", "Il marche au jardin", "Il ouvre l'accueil"],
            2,
            "« Le matin, je marche au jardin. »",
        ),
        match(
            [
                ("je me lève", "7 h"),
                ("le matin", "jardin"),
                ("l'après-midi", "guide"),
                ("le soir", "dîner"),
            ]
        ),
        fill("Complétez :\nJe me couche ___ vingt-deux heures.", "à"),
        wo(["Je", "dîne", "au", "Seuil", "."]),
        ana("jardin", "Patrick y marche, le matin, près des sources."),
        err(
            "Le matin je marche à le jardin.",
            "Le matin je marche au jardin.",
            "À + le → au jardin.",
        ),
        img(
            [
                ("jardin", "le jardin"),
                ("marche", "marcher"),
                ("diner", "dîner"),
                ("coucher", "se coucher"),
            ]
        ),
        short("Écrivez six lignes : bonjour, je me lève, matin, après-midi, soir, je me couche."),
        aud("Lisez votre mot, simplement, comme Patrick."),
    ],
)

S2_EL = lesson(
    "EL — Se lever, se coucher",
    "EL",
    """Objectif
Retenir les verbes du rythme et je me / tu te / il se.

Consigne
Étudiez la fiche.

Support — Fiche de Léa
je me lève / tu te lèves / il se lève / elle se lève
je me couche / tu te couches / il se couche
je prends le thé
je dîne
le matin / l'après-midi / le soir
d'habitude / parfois
Attention : je me lève (pas je se lève).
tôt / tard.""",
    [
        tf("On dit « je se lève ».", False, "Je me lève."),
        qcm(
            "Quelle forme est correcte ?",
            ["tu me lèves", "tu te lèves", "tu se lèves", "tu lèves-toi"],
            1,
            "Tu te lèves.",
        ),
        match(
            [
                ("je me", "lève / couche"),
                ("tu te", "lèves / couches"),
                ("il se", "lève / couche"),
                ("elle se", "lève / couche"),
            ]
        ),
        fill("Complétez :\nTu ___ lèves à sept heures.", "te"),
        wo(["Elle", "se", "couche", "tôt", "."]),
        ana("lèves", "La forme avec tu te…"),
        err(
            "Elle me couche à vingt-deux heures.",
            "Elle se couche à vingt-deux heures.",
            "Elle se couche.",
        ),
        img(
            [
                ("lever", "se lever"),
                ("coucher", "se coucher"),
                ("matin", "le matin"),
                ("soir", "le soir"),
            ]
        ),
        short("Recopiez la fiche. Écrivez quatre phrases : je / tu / il / elle."),
        aud("Dites je me lève, tu te lèves, il se lève, elle se lève, puis je me couche."),
    ],
)

# ---------------------------------------------------------------------------
# Séquence 3 — Nos habitudes partagées
# on + verbe ; tous les jours ; d'habitude ; le samedi
# ---------------------------------------------------------------------------

S3_CO = lesson(
    "CO — On se retrouve sous le figuier",
    "CO",
    """Objectif
Comprendre des habitudes communes : on + verbe, tous les jours, d'habitude.

Consigne
Qu'est-ce qu'on fait ensemble ? Quel jour ?

Support — Pause du Seuil, 16 h
Hawa : Tous les jours, on prend le thé à quatre heures.
Aline : Oui. D'habitude, on se retrouve ici.
Marc : Le samedi, on n'est pas tous là. Kévin joue au football.
Rose : Le samedi soir, on danse à la Salle des Herbes.
Léa : Moi, j'aime ça. On écoute aussi la radio.
Patrick : Le dimanche, on marche au jardin. Pas de course.""",
    [
        tf("On prend le thé tous les jours à quatre heures.", True, "Hawa : « Tous les jours, on prend le thé à quatre heures. »"),
        qcm(
            "Que fait-on le dimanche ?",
            ["On danse", "On prend le minibus", "On marche au jardin", "On ouvre l'accueil"],
            2,
            "Patrick : « Le dimanche, on marche au jardin. »",
        ),
        match(
            [
                ("tous les jours", "thé à 16 h"),
                ("samedi soir", "danse"),
                ("dimanche", "jardin"),
                ("samedi", "football de Kévin"),
            ]
        ),
        fill("Complétez :\nTous les jours, ___ prend le thé.", "on"),
        wo(["On", "se", "retrouve", "ici", "."]),
        ana("habitude", "D'… : presque toujours, au Seuil."),
        err(
            "On prends le thé à quatre heures.",
            "On prend le thé à quatre heures.",
            "On prend (comme il/elle), sans s.",
        ),
        img(
            [
                ("the", "le thé"),
                ("danse", "la danse"),
                ("jardin", "le jardin"),
                ("radio", "la radio"),
            ]
        ),
        short("Listez quatre habitudes du Seuil : tous les jours / samedi / dimanche."),
        aud(
            "Enregistrez : Tous les jours, on prend le thé. Le samedi soir, on danse. Le dimanche, on marche."
        ),
    ],
)

S3_CE = lesson(
    "CE — Tableau des habitudes",
    "CE",
    """Objectif
Lire un tableau d'habitudes partagées.

Consigne
Lisez le tableau à la craie.

Support — Tableau Figuier
Habitudes du Seuil
Tous les jours — 16 h — on prend le thé
D'habitude — on se retrouve sous le figuier
Samedi — Kévin joue au football
Samedi soir — on danse à la Salle des Herbes
Dimanche — on marche au jardin
Parfois — on écoute Radio Figuier
Rien d'obligatoire. C'est notre fil.""",
    [
        tf("On danse tous les jours.", False, "On danse le samedi soir."),
        qcm(
            "À quelle heure prend-on le thé tous les jours ?",
            ["À 6 h", "À midi", "À 16 h", "À minuit"],
            2,
            "Tous les jours — 16 h — on prend le thé.",
        ),
        match(
            [
                ("on prend", "le thé"),
                ("on danse", "Salle des Herbes"),
                ("on marche", "jardin"),
                ("parfois", "radio"),
            ]
        ),
        fill("Complétez :\nLe samedi soir, on ___.", "danse"),
        wo(["On", "écoute", "la", "radio", "."]),
        ana("samedi", "Jour où Kévin joue, et où l'on danse le soir."),
        err(
            "On vas au jardin le dimanche.",
            "On va au jardin le dimanche.",
            "On va (pas on vas).",
        ),
        img(
            [
                ("samedi", "samedi"),
                ("weekend", "le week-end"),
                ("fil", "le fil"),
                ("pause", "la pause"),
            ]
        ),
        short("Recopiez le tableau. Ajoutez une ligne : jour + on + verbe."),
        aud("Lisez le tableau, du haut vers le bas."),
    ],
)

S3_PO = lesson(
    "PO — Dire ce qu'on fait ensemble",
    "PO",
    """Objectif
Parler d'habitudes avec on, tous les jours, d'habitude, parfois.

Consigne
Répétez, puis dites une habitude de votre groupe.

Support — Modèles d'Hawa
On prend le thé.
On se retrouve ici.
Tous les jours, on parle un peu.
D'habitude, on est à l'heure.
Parfois, on écoute la radio.
Le samedi, on danse.
Le dimanche, on se repose.
On aime ce fil.""",
    [
        tf("« On » peut parler du groupe, ici le Seuil.", True, "On = nous, de façon simple."),
        qcm(
            "Quelle phrase dit la fréquence « presque toujours » ?",
            ["Parfois on écoute la radio", "D'habitude on est à l'heure", "Le samedi on danse", "On prend le thé"],
            1,
            "D'habitude = presque toujours.",
        ),
        match(
            [
                ("tous les jours", "chaque jour"),
                ("d'habitude", "presque toujours"),
                ("parfois", "de temps en temps"),
                ("le samedi", "un jour précis"),
            ]
        ),
        fill("Complétez :\nParfois, on ___ la radio.", "écoute"),
        wo(["On", "aime", "ce", "fil", "."]),
        ana("parfois", "Pas tous les jours : de temps en temps."),
        err(
            "Tous les jours on prends le thé.",
            "Tous les jours on prend le thé.",
            "On prend, sans s.",
        ),
        img(
            [
                ("the", "le thé"),
                ("radio", "la radio"),
                ("danse", "la danse"),
                ("weekend", "le week-end"),
            ]
        ),
        short("Écrivez six phrases avec on : deux tous les jours, deux parfois, deux week-end."),
        aud("Enregistrez les huit modèles, puis une habitude de votre classe."),
    ],
)

S3_PE = lesson(
    "PE — Notre petite habitude",
    "PE",
    """Objectif
Écrire une habitude partagée.

Consigne
Imitez le mot d'Hawa.

Support — Mot d'Hawa
Amies, amis du Seuil,
Tous les jours, on prend le thé à quatre heures.
D'habitude, on se retrouve sous le figuier.
Parfois, on écoute Radio Figuier.
Le dimanche, on marche au jardin.
Venez.
Hawa Diallo""",
    [
        tf("Hawa invite à venir.", True, "Dernier mot avant la signature : « Venez. »"),
        qcm(
            "Où se retrouve-t-on, d'habitude ?",
            ["À la Salle des Herbes", "Sous le figuier", "Au minibus", "Chez Kévin"],
            1,
            "« sous le figuier ».",
        ),
        match(
            [
                ("tous les jours", "thé à 16 h"),
                ("d'habitude", "figuier"),
                ("parfois", "radio"),
                ("dimanche", "jardin"),
            ]
        ),
        fill("Complétez :\nD'habitude, on se retrouve ___ le figuier.", "sous"),
        wo(["Venez", "sous", "le", "figuier", "."]),
        ana("figuier", "L'arbre de la cour, où l'on prend le thé."),
        err(
            "On se retrouve sous le figuier tous les jour.",
            "On se retrouve sous le figuier tous les jours.",
            "Jours au pluriel : tous les jours.",
        ),
        img(
            [
                ("the", "le thé"),
                ("jardin", "le jardin"),
                ("radio", "la radio"),
                ("fil", "le fil"),
            ]
        ),
        short("Écrivez un mot de cinq lignes : tous les jours, d'habitude, parfois, un jour, venez."),
        aud("Lisez votre mot, puis dites « Venez. »"),
    ],
)

S3_EL = lesson(
    "EL — On, tous les jours, parfois",
    "EL",
    """Objectif
Retenir on + verbe et les mots de fréquence.

Consigne
Apprenez la fiche du Seuil.

Support — Fiche d'Hawa
on + verbe (comme il / elle) : on prend, on va, on danse
tous les jours
d'habitude
parfois
le samedi / le dimanche
on se retrouve
Attention : on prend (pas on prends). On va (pas on vas).
On aime ce fil.""",
    [
        tf("On conjugue « on » comme « nous » (prenons).", False, "On prend, comme il/elle."),
        qcm(
            "Quelle forme est correcte ?",
            ["on vas", "on va", "on allers", "on aller"],
            1,
            "On va.",
        ),
        match(
            [
                ("on prend", "il/elle prend"),
                ("on va", "il/elle va"),
                ("tous les jours", "fréquence forte"),
                ("parfois", "fréquence faible"),
            ]
        ),
        fill("Complétez :\nOn ___ au jardin le dimanche.", "va"),
        wo(["On", "danse", "le", "samedi", "."]),
        ana("prend", "On… le thé, tous les jours."),
        err(
            "On aimes ce fil.",
            "On aime ce fil.",
            "On aime (pas aimes).",
        ),
        img(
            [
                ("pause", "la pause"),
                ("samedi", "samedi"),
                ("weekend", "le week-end"),
                ("danse", "la danse"),
            ]
        ),
        short("Recopiez la fiche. Écrivez quatre phrases avec on."),
        aud("Dites : on prend, on va, on danse, on se retrouve, tous les jours, parfois."),
    ],
)

# ---------------------------------------------------------------------------
# Séquence 4 — Une journée de travail
# je travaille ; je commence à ; je finis à
# ---------------------------------------------------------------------------

S4_CO = lesson(
    "CO — Les heures de la cour",
    "CO",
    """Objectif
Comprendre une journée de travail : je travaille, je commence, je finis.

Consigne
Qui commence à quelle heure ? Qui finit quand ?

Support — Accueil du Seuil, craie à la main
Aline : Je travaille à l'accueil. Je commence à sept heures. Je finis à quinze heures.
Marc : Je suis chauffeur. Je commence à six heures. Je finis à quatorze heures.
Patrick : Je suis guide. Je commence à huit heures. Je finis à seize heures.
Joël : Moi, je travaille avec la moto. Je commence à neuf heures. Je finis tard.
Hawa : Je range les cartes l'après-midi. Ce n'est pas un bureau, mais c'est du travail.""",
    [
        tf("Aline finit à quinze heures.", True, "Aline : « Je finis à quinze heures. »"),
        qcm(
            "Qui commence le plus tôt ?",
            ["Aline", "Marc", "Patrick", "Joël"],
            1,
            "Marc commence à six heures.",
        ),
        match(
            [
                ("Aline", "accueil 7 h–15 h"),
                ("Marc", "minibus 6 h–14 h"),
                ("Patrick", "guide 8 h–16 h"),
                ("Joël", "moto dès 9 h"),
            ]
        ),
        fill("Complétez :\nJe ___ à sept heures.", "commence"),
        wo(["Je", "finis", "à", "quinze", "heures", "."]),
        ana("travaille", "Le verbe du métier, à l'accueil ou sur la route."),
        err(
            "Je fini à quinze heures.",
            "Je finis à quinze heures.",
            "Je finis (avec s).",
        ),
        img(
            [
                ("travailler", "travailler"),
                ("accueil", "l'accueil"),
                ("moto", "la moto"),
                ("minibus", "le minibus"),
            ]
        ),
        short("Notez pour quatre personnes : métier, heure de début, heure de fin."),
        aud(
            "Enregistrez : Je travaille à l'accueil. Je commence à sept heures. Je finis à quinze heures."
        ),
    ],
)

S4_CE = lesson(
    "CE — Fiches de poste",
    "CE",
    """Objectif
Lire des fiches de journée de travail.

Consigne
Lisez les fiches accrochées près de l'accueil.

Support — Fiches crème
Aline Uwase — accueil — commence 7 h — finit 15 h — pause à midi
Marc Nkurunziza — chauffeur — commence 6 h — finit 14 h — pause courte
Patrick Habimana — guide — commence 8 h — finit 16 h — jardin le matin
Joël Mugisha — moto — commence 9 h — finit tard — pause au thé
Consigne du Seuil : écrire je commence / je finis, pas seulement les chiffres.""",
    [
        tf("Patrick finit à quatorze heures.", False, "Patrick finit à 16 h. Marc finit à 14 h."),
        qcm(
            "Qui a une pause à midi ?",
            ["Marc", "Aline", "Joël", "Patrick"],
            1,
            "Fiche Aline : pause à midi.",
        ),
        match(
            [
                ("commence 6 h", "Marc"),
                ("commence 7 h", "Aline"),
                ("commence 8 h", "Patrick"),
                ("commence 9 h", "Joël"),
            ]
        ),
        fill("Complétez :\nJe finis ___ quinze heures.", "à"),
        wo(["Je", "travaille", "à", "l'accueil", "."]),
        ana("commence", "Le verbe du début, avant je finis."),
        err(
            "Je commence à le accueil.",
            "Je commence à l'accueil.",
            "À l'accueil (élision).",
        ),
        img(
            [
                ("accueil", "l'accueil"),
                ("minibus", "le minibus"),
                ("pause", "la pause"),
                ("travailler", "travailler"),
            ]
        ),
        short("Recopiez une fiche en phrases : je suis, je commence, je finis, pause."),
        aud("Lisez les quatre fiches, sans aller trop vite."),
    ],
)

S4_PO = lesson(
    "PO — Dire son travail",
    "PO",
    """Objectif
Parler de sa journée de travail : je suis, je commence, je finis.

Consigne
Répétez, puis inventez un métier au Seuil.

Support — Modèles d'Aline
Je suis à l'accueil.
Je travaille ici.
Je commence à sept heures.
Je finis à quinze heures.
À midi, je prends une pause.
Je suis chauffeur.
Je suis guide.
Je travaille avec la moto.""",
    [
        tf("« Je commence » dit le début du travail.", True, "Commencer = le début."),
        qcm(
            "Quel verbe dit la fin du travail ?",
            ["je commence", "je prends", "je finis", "je suis"],
            2,
            "Je finis à…",
        ),
        match(
            [
                ("je suis", "rôle"),
                ("je commence", "début"),
                ("je finis", "fin"),
                ("pause", "midi"),
            ]
        ),
        fill("Complétez :\nÀ midi, je prends une ___.", "pause"),
        wo(["Je", "suis", "guide", "."]),
        ana("finis", "Je… à quinze heures, après le travail."),
        err(
            "Je travaille à le accueil.",
            "Je travaille à l'accueil.",
            "À l'accueil.",
        ),
        img(
            [
                ("travailler", "travailler"),
                ("accueil", "l'accueil"),
                ("moto", "la moto"),
                ("pause", "la pause"),
            ]
        ),
        short("Écrivez six phrases : je suis, je travaille, je commence, je finis, pause, lieu."),
        aud("Enregistrez les huit modèles, puis votre journée (vraie ou inventée)."),
    ],
)

S4_PE = lesson(
    "PE — Ma fiche de journée",
    "PE",
    """Objectif
Écrire une fiche de travail claire.

Consigne
Imitez la fiche de Marc.

Support — Fiche de Marc
Je m'appelle Marc Nkurunziza.
Je suis chauffeur.
Je commence à six heures du matin.
Je finis à quatorze heures.
À midi, pause courte.
Puis le minibus Figuier 7 rentre.
Marc
Seuil des Sources""",
    [
        tf("Marc finit le matin.", False, "Il finit à quatorze heures, l'après-midi."),
        qcm(
            "Quel est le métier de Marc ?",
            ["Guide", "Accueil", "Chauffeur", "Danseur"],
            2,
            "« Je suis chauffeur. »",
        ),
        match(
            [
                ("six heures", "début"),
                ("quatorze heures", "fin"),
                ("midi", "pause"),
                ("Figuier 7", "minibus"),
            ]
        ),
        fill("Complétez :\nJe suis ___.", "chauffeur"),
        wo(["Je", "commence", "tôt", "."]),
        ana("chauffeur", "Le métier de Marc, avec le minibus."),
        err(
            "Je commence à six heure du matin.",
            "Je commence à six heures du matin.",
            "Heures au pluriel.",
        ),
        img(
            [
                ("minibus", "le minibus"),
                ("travailler", "travailler"),
                ("pause", "la pause"),
                ("reveil", "le réveil"),
            ]
        ),
        short("Écrivez votre fiche : je m'appelle, je suis, je commence, je finis, pause."),
        aud("Lisez votre fiche comme pour l'accueil."),
    ],
)

S4_EL = lesson(
    "EL — Commencer, finir, travailler",
    "EL",
    """Objectif
Retenir je travaille, je commence à, je finis à.

Consigne
Apprenez, puis dites une journée de travail.

Support — Fiche d'Aline
je travaille / tu travailles / il travaille
je commence / tu commences / elle commence
je finis / tu finis / il finit
à + heure
à l'accueil / au jardin / avec la moto
pause à midi
Attention : je finis (avec s). Je commence à (pas « je commence à le »).
Je suis + métier.""",
    [
        tf("On écrit « je fini ».", False, "Je finis, avec s."),
        qcm(
            "Quelle conjugaison est correcte ?",
            ["tu travaille", "tu travailles", "tu travailler", "tu travaill"],
            1,
            "Tu travailles.",
        ),
        match(
            [
                ("travailler", "le métier"),
                ("commencer", "le début"),
                ("finir", "la fin"),
                ("pause", "un moment"),
            ]
        ),
        fill("Complétez :\nTu ___ à seize heures. (fin du travail)", "finis"),
        wo(["Elle", "travaille", "ici", "."]),
        ana("commences", "La forme avec tu…"),
        err(
            "Il fini à seize heures.",
            "Il finit à seize heures.",
            "Il/elle finit (avec t).",
        ),
        img(
            [
                ("travailler", "travailler"),
                ("accueil", "l'accueil"),
                ("moto", "la moto"),
                ("minibus", "le minibus"),
            ]
        ),
        short("Recopiez la fiche. Écrivez trois phrases : je travaille / je commence / je finis."),
        aud("Dites la conjugaison de commencer et de finir (je, tu, il, elle)."),
    ],
)

# ---------------------------------------------------------------------------
# Séquence 5 — Sortir à sa façon
# je sors ; on va à / au / à la ; ce soir
# ---------------------------------------------------------------------------

S5_CO = lesson(
    "CO — Ce soir au Seuil",
    "CO",
    """Objectif
Comprendre des sorties : je sors, on va à, ce soir, demain.

Consigne
Qui sort où ? Quel lieu ?

Support — Fil du soir, lampions
Rose : Ce soir, je sors. Je vais à la Salle des Herbes. On danse.
Léa : Moi, je vais au jardin. C'est calme.
Hawa : Ce soir, je vais au Marché des Lampions. Il y a du thé et des lumières.
Marc : Demain, je ne sors pas. Je me repose avec Kévin.
Joël : Moi, je sors un peu, en moto. Puis je rentre.
Aline : On peut rester ici, aussi. Sortir à sa façon.""",
    [
        tf("Marc sort ce soir.", False, "Marc : « Demain, je ne sors pas. »"),
        qcm(
            "Où va Rose ce soir ?",
            ["Au jardin", "À la Salle des Herbes", "Au marché", "À l'accueil"],
            1,
            "Rose : « Je vais à la Salle des Herbes. »",
        ),
        match(
            [
                ("Rose", "danse"),
                ("Léa", "jardin"),
                ("Hawa", "marché"),
                ("Marc", "repos"),
            ]
        ),
        fill("Complétez :\nCe soir, je ___.", "sors"),
        wo(["Je", "vais", "au", "jardin", "."]),
        ana("sors", "Je… ce soir : quitter la maison un moment."),
        err(
            "Je vais à le jardin.",
            "Je vais au jardin.",
            "À + le → au jardin.",
        ),
        img(
            [
                ("danse", "la danse"),
                ("salle", "la salle"),
                ("lampion", "un lampion"),
                ("jardin", "le jardin"),
            ]
        ),
        short("Notez quatre sorties : personne, lieu, ce soir ou demain."),
        aud(
            "Enregistrez : Ce soir, je sors. Je vais à la salle. Je vais au jardin. Je vais au marché."
        ),
    ],
)

S5_CE = lesson(
    "CE — Affiche des sorties",
    "CE",
    """Objectif
Lire une affiche de sorties du quartier.

Consigne
Lisez l'affiche épinglée sur le fil.

Support — Affiche ocre
Sortir à Rukiri-Nord
Ce soir — Salle des Herbes — danse avec Rose — 19 h
Ce soir — Marché des Lampions — thé et lumières — 18 h
Demain — Jardin des Sources — marche avec Patrick — 9 h
Dimanche — Radio Figuier sous le figuier — 16 h
Entrée libre. On va à sa façon.
Seuil des Sources""",
    [
        tf("La danse commence à dix-huit heures.", False, "Danse à 19 h. Marché à 18 h."),
        qcm(
            "À quelle heure est la marche au jardin ?",
            ["19 h", "18 h", "9 h", "16 h"],
            2,
            "Demain — jardin — 9 h.",
        ),
        match(
            [
                ("Salle des Herbes", "danse"),
                ("Marché des Lampions", "thé"),
                ("Jardin des Sources", "marche"),
                ("Radio Figuier", "figuier"),
            ]
        ),
        fill("Complétez :\nOn va ___ la Salle des Herbes.", "à"),
        wo(["Ce", "soir", "je", "sors", "."]),
        ana("marché", "Le soir, des lampions et du thé, pas le matin."),
        err(
            "Je vais à le Salle des Herbes.",
            "Je vais à la Salle des Herbes.",
            "Salle est féminin : à la salle.",
        ),
        img(
            [
                ("lampion", "un lampion"),
                ("salle", "la salle"),
                ("radio", "la radio"),
                ("marche", "marcher"),
            ]
        ),
        short("Recopiez l'affiche. Entourez la sortie que vous choisissez et dites pourquoi."),
        aud("Lisez l'affiche, une ligne, une pause."),
    ],
)

S5_PO = lesson(
    "PO — Dire où l'on va",
    "PO",
    """Objectif
Dire une sortie : je sors, je vais à / au / à la, ce soir.

Consigne
Répétez, puis choisissez une sortie.

Support — Modèles de Rose
Je sors ce soir.
Je vais à la salle.
Je vais au jardin.
Je vais au marché.
On danse.
On marche.
Je ne sors pas demain.
J'aime sortir à ma façon.""",
    [
        tf("« Je ne sors pas » est une négation.", True, "Ne… pas = pas de sortie."),
        qcm(
            "Quelle phrase va vers un lieu masculin avec à + le ?",
            ["Je vais à la salle", "Je vais au jardin", "Je sors ce soir", "On danse"],
            1,
            "Au jardin = à + le jardin.",
        ),
        match(
            [
                ("à la", "salle"),
                ("au", "jardin, marché"),
                ("ce soir", "aujourd'hui, plus tard"),
                ("demain", "le jour d'après"),
            ]
        ),
        fill("Complétez :\nJe vais ___ marché.", "au"),
        wo(["J'aime", "sortir", "ce", "soir", "."]),
        ana("sortir", "Quitter la cour un moment, pour la salle ou le marché."),
        err(
            "Je vais à le marché.",
            "Je vais au marché.",
            "À + le → au.",
        ),
        img(
            [
                ("soir", "le soir"),
                ("salle", "la salle"),
                ("jardin", "le jardin"),
                ("lampion", "un lampion"),
            ]
        ),
        short("Écrivez six phrases : deux je sors, deux je vais à/au, une négation, une préférence."),
        aud("Enregistrez les huit modèles, puis votre sortie."),
    ],
)

S5_PE = lesson(
    "PE — Mon programme du soir",
    "PE",
    """Objectif
Écrire un petit programme de sortie.

Consigne
Imitez le mot de Léa.

Support — Mot de Léa
Bonsoir,
Ce soir, je sors.
Je vais au jardin des Sources.
C'est calme. Je marche un peu.
Je ne vais pas à la salle.
À demain.
Léa
Rukiri-Nord""",
    [
        tf("Léa va à la salle ce soir.", False, "« Je ne vais pas à la salle. »"),
        qcm(
            "Où Léa va-t-elle ?",
            ["Au marché", "Au jardin", "À l'accueil", "À la moto"],
            1,
            "« Je vais au jardin des Sources. »",
        ),
        match(
            [
                ("ce soir", "je sors"),
                ("jardin", "calme"),
                ("salle", "non"),
                ("à demain", "salutation"),
            ]
        ),
        fill("Complétez :\nJe ne vais ___ à la salle.", "pas"),
        wo(["Je", "marche", "un", "peu", "."]),
        ana("calme", "Léa aime le jardin, pas trop de bruit."),
        err(
            "Je vais à le jardin.",
            "Je vais au jardin.",
            "À + le → au jardin.",
        ),
        img(
            [
                ("jardin", "le jardin"),
                ("marche", "marcher"),
                ("soir", "le soir"),
                ("invitation", "une invitation"),
            ]
        ),
        short("Écrivez cinq lignes : bonsoir, je sors, je vais, je ne vais pas, à demain."),
        aud("Lisez votre mot, calmement."),
    ],
)

S5_EL = lesson(
    "EL — Aller à, au, à la",
    "EL",
    """Objectif
Retenir je sors et je vais à / au / à la.

Consigne
Apprenez la fiche.

Support — Fiche de Rose
je sors / tu sors / il sort / elle sort
je vais / tu vas / il va
à la salle
au jardin (à + le)
au marché
ce soir / demain
je ne sors pas
Attention : au = à + le. On ne dit pas « à le jardin ».
Sortir à sa façon : chacun choisit.""",
    [
        tf("On dit « je vais à le jardin ».", False, "Je vais au jardin."),
        qcm(
            "Quelle forme est correcte ?",
            ["tu vas", "tu va", "tu aller", "tu vais"],
            0,
            "Tu vas.",
        ),
        match(
            [
                ("à la", "salle"),
                ("au", "jardin / marché"),
                ("je sors", "je quitte un moment"),
                ("je ne sors pas", "je reste"),
            ]
        ),
        fill("Complétez :\nElle ___ ce soir.", "sort"),
        wo(["Tu", "vas", "au", "marché", "."]),
        ana("marché", "Le soir, des lampions : on y va…"),
        err(
            "Elle sors ce soir.",
            "Elle sort ce soir.",
            "Il / elle sort (sans s).",
        ),
        img(
            [
                ("salle", "la salle"),
                ("jardin", "le jardin"),
                ("lampion", "un lampion"),
                ("soir", "le soir"),
            ]
        ),
        short("Recopiez la fiche. Écrivez quatre phrases : sors / vais à la / vais au / ne sors pas."),
        aud("Dites : je sors, tu sors, elle sort, je vais à la salle, je vais au jardin."),
    ],
)

# ---------------------------------------------------------------------------
# Séquence 6 — Organiser une rencontre
# tu veux… ? ; d'accord ; avec plaisir ; je ne peux pas
# ---------------------------------------------------------------------------

S6_CO = lesson(
    "CO — Une invitation sous le fil",
    "CO",
    """Objectif
Comprendre une invitation : tu veux… ?, oui, d'accord, je ne peux pas.

Consigne
Qui invite ? Qui accepte ? Qui refuse ?

Support — Fin d'après-midi
Rose : Léa, tu veux venir à la salle ce soir ?
Léa : Oui, avec plaisir. À quelle heure ?
Rose : À dix-neuf heures. D'accord ?
Léa : D'accord.
Rose : Joël, tu viens aussi ?
Joël : Non, je ne peux pas. Désolé. La route est longue.
Aline : Une autre fois, alors. Merci, Rose.""",
    [
        tf("Léa accepte l'invitation.", True, "Léa : « Oui, avec plaisir. »"),
        qcm(
            "Pourquoi Joël refuse-t-il ?",
            ["Il n'aime pas danser", "La route est longue", "Il est à l'accueil", "Il n'a pas le temps"],
            1,
            "Joël : « La route est longue. »",
        ),
        match(
            [
                ("tu veux venir", "invitation"),
                ("avec plaisir", "oui"),
                ("d'accord", "oui simple"),
                ("je ne peux pas", "non poli"),
            ]
        ),
        fill("Complétez :\nOui, avec ___.", "plaisir"),
        wo(["Tu", "veux", "venir", "?"]),
        ana("plaisir", "Oui, avec… : un oui chaleureux."),
        err(
            "Je ne peut pas.",
            "Je ne peux pas.",
            "Je peux (avec x).",
        ),
        img(
            [
                ("invitation", "une invitation"),
                ("daccord", "d'accord"),
                ("refuse", "refuser"),
                ("salle", "la salle"),
            ]
        ),
        short("Notez : la question de Rose, la réponse de Léa, la réponse de Joël."),
        aud(
            "Enregistrez : Tu veux venir ce soir ? Oui, avec plaisir. Non, je ne peux pas. Désolé."
        ),
    ],
)

S6_CE = lesson(
    "CE — Billets d'invitation",
    "CE",
    """Objectif
Lire des billets pour inviter, accepter ou refuser.

Consigne
Lisez les billets près du thé.

Support — Billets
1. Rose → Léa — Tu veux venir à la Salle des Herbes ce soir, à 19 h ?
2. Léa → Rose — Oui, avec plaisir. À tout à l'heure.
3. Rose → Joël — Tu viens aussi ?
4. Joël → Rose — Non, je ne peux pas. Désolé. Une autre fois.
5. Aline — Merci. On se retrouve sous le fil, demain.
Règle du Seuil : un oui clair, ou un non poli.""",
    [
        tf("Joël écrit « avec plaisir ».", False, "Joël refuse : « je ne peux pas »."),
        qcm(
            "Quelle formule Léa utilise-t-elle pour accepter ?",
            ["D'accord seulement", "Oui, avec plaisir", "Je ne peux pas", "Une autre fois"],
            1,
            "Billet 2 : « Oui, avec plaisir. »",
        ),
        match(
            [
                ("tu veux", "inviter"),
                ("avec plaisir", "accepter"),
                ("je ne peux pas", "refuser"),
                ("une autre fois", "plus tard"),
            ]
        ),
        fill("Complétez :\nNon, je ne ___ pas.", "peux"),
        wo(["À", "tout", "à", "l'heure", "."]),
        ana("désolé", "Le mot de Joël, pour refuser poliment (masculin)."),
        err(
            "Non je ne peux pas. Désoler.",
            "Non je ne peux pas. Désolé.",
            "Désolé est un adjectif (pas un verbe).",
        ),
        img(
            [
                ("invitation", "une invitation"),
                ("daccord", "d'accord"),
                ("refuse", "refuser"),
                ("the", "le thé"),
            ]
        ),
        short("Recopiez un oui et un non. Ajoutez votre billet : tu veux… ? + réponse."),
        aud("Lisez les cinq billets, puis la règle du Seuil."),
    ],
)

S6_PO = lesson(
    "PO — Inviter, dire oui, dire non",
    "PO",
    """Objectif
Inviter et répondre : tu veux… ?, d'accord, avec plaisir, je ne peux pas.

Consigne
Répétez, puis invitez un camarade.

Support — Modèles de Rose
Tu veux venir ce soir ?
Tu viens à la salle ?
Oui, avec plaisir.
D'accord.
À quelle heure ?
Non, je ne peux pas.
Désolé. / Désolée.
Une autre fois.
Merci.""",
    [
        tf("« Désolée » s'accorde au féminin.", True, "Désolé / désolée."),
        qcm(
            "Quelle phrase refuse poliment ?",
            [
                "Oui, avec plaisir",
                "D'accord",
                "Non, je ne peux pas",
                "Tu veux venir",
            ],
            2,
            "Je ne peux pas = refus.",
        ),
        match(
            [
                ("tu veux", "question"),
                ("avec plaisir", "oui chaleureux"),
                ("d'accord", "oui simple"),
                ("une autre fois", "pas maintenant"),
            ]
        ),
        fill("Complétez :\nTu ___ venir ce soir ?", "veux"),
        wo(["Une", "autre", "fois", "."]),
        ana("peux", "Je ne… pas : refuser."),
        err(
            "Tu veut venir ce soir ?",
            "Tu veux venir ce soir ?",
            "Tu veux (avec x).",
        ),
        img(
            [
                ("invitation", "une invitation"),
                ("daccord", "d'accord"),
                ("refuse", "refuser"),
                ("soir", "le soir"),
            ]
        ),
        short("Écrivez un mini-dialogue de six répliques : inviter, heure, oui, non, merci."),
        aud("Enregistrez les modèles, puis une invitation et deux réponses (oui et non)."),
    ],
)

S6_PE = lesson(
    "PE — Un billet aller-retour",
    "PE",
    """Objectif
Écrire une invitation et une réponse.

Consigne
Imitez le billet de Rose, puis la réponse de Léa.

Support — Deux billets
Rose
Léa, tu veux venir à la salle ce soir, à dix-neuf heures ?
Rose

Léa
Oui, avec plaisir. D'accord. À tout à l'heure.
Léa
Seuil des Sources""",
    [
        tf("Léa refuse.", False, "Elle écrit : « Oui, avec plaisir. »"),
        qcm(
            "À quelle heure Rose propose-t-elle de se voir ?",
            ["À midi", "À seize heures", "À dix-neuf heures", "À minuit"],
            2,
            "« à dix-neuf heures ».",
        ),
        match(
            [
                ("tu veux venir", "Rose"),
                ("avec plaisir", "Léa"),
                ("dix-neuf heures", "horaire"),
                ("à tout à l'heure", "bientôt"),
            ]
        ),
        fill("Complétez :\n___ , avec plaisir.", "Oui"),
        wo(["Oui", "avec", "plaisir", "."]),
        ana("venir", "Tu veux… à la salle : le verbe de l'invitation."),
        err(
            "Tu veux de venir à la salle ?",
            "Tu veux venir à la salle ?",
            "Tu veux + verbe à l'infinitif, sans de.",
        ),
        img(
            [
                ("invitation", "une invitation"),
                ("daccord", "d'accord"),
                ("salle", "la salle"),
                ("carte", "une carte"),
            ]
        ),
        short("Écrivez deux billets : une invitation (heure + lieu) et un oui ou un non poli."),
        aud("Lisez les deux billets, comme un aller-retour."),
    ],
)

S6_EL = lesson(
    "EL — Tu veux, d'accord, je ne peux pas",
    "EL",
    """Objectif
Retenir les formules pour inviter, accepter et refuser.

Consigne
Apprenez la fiche, puis jouez une rencontre.

Support — Fiche de Rose
Inviter : Tu veux… ? Tu viens… ? On va… ?
Accepter : Oui. D'accord. Avec plaisir.
Demander l'heure : À quelle heure ?
Refuser : Non, je ne peux pas. Désolé / Désolée.
Reporter : Une autre fois.
Remercier : Merci.
Attention : je peux / tu peux / il peut.
On ne dit pas « je ne peut pas ».""",
    [
        tf("On dit « je ne peut pas ».", False, "Je ne peux pas."),
        qcm(
            "Quelle forme est correcte ?",
            ["il peux", "il peut", "il peuts", "il pouvois"],
            1,
            "Il / elle peut.",
        ),
        match(
            [
                ("tu veux", "inviter"),
                ("d'accord", "accepter"),
                ("je ne peux pas", "refuser"),
                ("merci", "remercier"),
            ]
        ),
        fill("Complétez :\nIl ne ___ pas venir.", "peut"),
        wo(["Merci", "Rose", "."]),
        ana("merci", "Le petit mot à la fin, pour Rose ou pour Léa."),
        err(
            "Il ne peux pas venir.",
            "Il ne peut pas venir.",
            "Il / elle peut (avec t).",
        ),
        img(
            [
                ("invitation", "une invitation"),
                ("daccord", "d'accord"),
                ("refuse", "refuser"),
                ("fil", "le fil"),
            ]
        ),
        short("Recopiez la fiche. Écrivez un oui et un non, avec une invitation."),
        aud("Dites : tu veux venir ? oui, avec plaisir ; non, je ne peux pas ; une autre fois ; merci."),
    ],
)

SEQUENCES = [
    {"title": "Une journée dans le monde", "lessons": [S1_CO, S1_CE, S1_PO, S1_PE, S1_EL]},
    {"title": "Rythmes de vie", "lessons": [S2_CO, S2_CE, S2_PO, S2_PE, S2_EL]},
    {
        "title": "Nos habitudes partagées",
        "lessons": [S3_CO, S3_CE, S3_PO, S3_PE, S3_EL],
    },
    {"title": "Une journée de travail", "lessons": [S4_CO, S4_CE, S4_PO, S4_PE, S4_EL]},
    {"title": "Sortir à sa façon", "lessons": [S5_CO, S5_CE, S5_PO, S5_PE, S5_EL]},
    {
        "title": "Organiser une rencontre",
        "lessons": [S6_CO, S6_CE, S6_PO, S6_PE, S6_EL],
    },
]
