"""MFK A1 Module 6 — Histoires vécues (Seuil des Sources)."""

from __future__ import annotations

IMG = "/elearning/mfk-a1-m6/{name}.svg"


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
    "title": "A1 — Histoires vécues",
    "description": (
        "Grande étape 6 : raconter au passé composé, parler d'un passé récent "
        "et d'un projet, lire une bio, décrire, comparer avant et maintenant, "
        "donner un conseil — cahier des histoires sous le figuier du Seuil "
        "des Sources (Rukiri-Nord)."
    ),
}

# ---------------------------------------------------------------------------
# Séquence 1 — Apprendre à sa manière
# passé composé (avoir) : j'ai écouté, j'ai lu, j'ai appris ; hier
# ---------------------------------------------------------------------------

S1_CO = lesson(
    "CO — Hier, sous le figuier",
    "CO",
    """Objectif
Comprendre un récit au passé composé : j'ai écouté, j'ai lu, j'ai appris.

Consigne
Lisez le dialogue (à écouter avec l'enseignant). Qui a appris quoi, hier ?

Support — Cahier des histoires, banc du Seuil
Léa : Hier, j'ai écouté Aline. J'ai répété les heures. J'ai appris « il est midi ».
Aline : Très bien. Moi, j'ai écrit trois cartes pour le fil.
Patrick : Hier, j'ai lu une page de Mado. J'ai appris un mot : figuier.
Hawa : J'ai écouté Radio Figuier. J'ai noté deux phrases.
Joël : Moi, j'ai travaillé. Je n'ai pas lu. Demain, peut-être.""",
    [
        tf("Léa a appris « il est midi ».", True, "Léa dit : j'ai appris « il est midi »."),
        qcm(
            "Qu'est-ce que Patrick a lu ?",
            ["Le journal du marché", "Une page de Mado", "Une carte d'Aline", "Un horaire de minibus"],
            1,
            "Patrick : « j'ai lu une page de Mado. »",
        ),
        match(
            [
                ("Léa", "a écouté et répété"),
                ("Aline", "a écrit des cartes"),
                ("Patrick", "a lu une page"),
                ("Joël", "n'a pas lu"),
            ]
        ),
        fill("Complétez :\nHier, j'___ écouté Aline.", "ai"),
        wo(["J'ai", "appris", "un", "mot", "."]),
        ana("appris", "Le participe de apprendre, après j'ai."),
        err(
            "Hier j'ai apprendre les heures.",
            "Hier j'ai appris les heures.",
            "Passé composé : j'ai + participe (appris).",
        ),
        img(
            [
                ("cahier", "un cahier"),
                ("hier", "hier"),
                ("ecouter", "écouter"),
                ("apprendre", "apprendre"),
            ]
        ),
        short("Notez pour quatre personnes : j'ai + verbe (écouté, écrit, lu, travaillé)."),
        aud(
            "Enregistrez : Hier, j'ai écouté. J'ai lu une page. J'ai appris un mot. J'ai écrit trois cartes."
        ),
    ],
)

S1_CE = lesson(
    "CE — Pages du cahier",
    "CE",
    """Objectif
Lire de courtes notes au passé composé.

Consigne
Lisez les pages épinglées, puis répondez.

Support — Cahier des histoires
Léa — Hier, j'ai écouté. J'ai répété. J'ai appris trois phrases.
Aline — Hier, j'ai écrit les cartes du fil. J'ai aidé Léa.
Patrick — Hier, j'ai lu les Notes du figuier. J'ai appris le mot « source ».
Hawa — Hier, j'ai écouté la radio. Je n'ai pas écrit.
Joël — Hier, j'ai travaillé avec la moto. Je n'ai pas lu.
Règle du Seuil : une phrase avec j'ai, une phrase vraie.""",
    [
        tf("Hawa a écrit hier.", False, "Hawa : « Je n'ai pas écrit. »"),
        qcm(
            "Qui a aidé Léa ?",
            ["Joël", "Patrick", "Aline", "Hawa"],
            2,
            "Aline : « J'ai aidé Léa. »",
        ),
        match(
            [
                ("j'ai écouté", "Léa, Hawa"),
                ("j'ai lu", "Patrick"),
                ("j'ai écrit", "Aline"),
                ("je n'ai pas lu", "Joël"),
            ]
        ),
        fill("Complétez :\nJe n'___ pas écrit.", "ai"),
        wo(["J'ai", "lu", "une", "page", "."]),
        ana("écrit", "Le participe de écrire, après j'ai."),
        err(
            "Je n'ai pas écouté pas la radio.",
            "Je n'ai pas écouté la radio.",
            "Une seule négation : ne… pas autour de l'auxiliaire.",
        ),
        img(
            [
                ("lire", "lire"),
                ("ecrire", "écrire"),
                ("cahier", "un cahier"),
                ("figuier", "le figuier"),
            ]
        ),
        short("Recopiez deux pages. Ajoutez la vôtre : hier, j'ai… / je n'ai pas…"),
        aud("Lisez les cinq pages, sans aller trop vite."),
    ],
)

S1_PO = lesson(
    "PO — Dire ce qu'on a fait",
    "PO",
    """Objectif
Raconter au passé composé avec avoir : j'ai, tu as, il/elle a.

Consigne
Répétez, puis racontez hier (vrai ou inventé).

Support — Modèles de Léa
J'ai écouté.
J'ai lu une page.
J'ai écrit une carte.
J'ai appris un mot.
Tu as écouté ?
Il a lu.
Elle a écrit.
Je n'ai pas travaillé.""",
    [
        tf("« J'ai » est l'auxiliaire avoir au passé composé.", True, "J'ai + participe."),
        qcm(
            "Quelle phrase est au passé composé ?",
            ["J'écoute", "Je vais écouter", "J'ai écouté", "J'écoute demain"],
            2,
            "J'ai écouté = passé composé.",
        ),
        match(
            [
                ("j'ai", "je"),
                ("tu as", "tu"),
                ("il a", "il"),
                ("elle a", "elle"),
            ]
        ),
        fill("Complétez :\nTu ___ lu une page ?", "as"),
        wo(["Elle", "a", "écrit", "."]),
        ana("écouté", "Le participe de écouter."),
        err(
            "Tu a écouté hier.",
            "Tu as écouté hier.",
            "Tu as (avec s).",
        ),
        img(
            [
                ("ecouter", "écouter"),
                ("lire", "lire"),
                ("ecrire", "écrire"),
                ("apprendre", "apprendre"),
            ]
        ),
        short("Écrivez six phrases : trois j'ai…, une tu as…, une il a…, une je n'ai pas…"),
        aud("Enregistrez les huit modèles, puis votre hier."),
    ],
)

S1_PE = lesson(
    "PE — Ma page d'hier",
    "PE",
    """Objectif
Écrire une courte page au passé composé.

Consigne
Imitez la page de Léa.

Support — Page de Léa
Hier,
j'ai écouté Aline.
J'ai répété les heures.
J'ai appris trois phrases.
Je n'ai pas dansé.
Léa Niyonzima
Cahier des histoires""",
    [
        tf("Léa a dansé hier.", False, "« Je n'ai pas dansé. »"),
        qcm(
            "Combien de phrases Léa a-t-elle apprises ?",
            ["Une", "Deux", "Trois", "Zéro"],
            2,
            "« J'ai appris trois phrases. »",
        ),
        match(
            [
                ("j'ai écouté", "Aline"),
                ("j'ai répété", "les heures"),
                ("j'ai appris", "trois phrases"),
                ("je n'ai pas", "dansé"),
            ]
        ),
        fill("Complétez :\nJ'ai ___ trois phrases.", "appris"),
        wo(["Je", "n'ai", "pas", "dansé", "."]),
        ana("répété", "Léa a… les heures, après Aline."),
        err(
            "J'ai appris trois phrase.",
            "J'ai appris trois phrases.",
            "Phrases au pluriel après trois.",
        ),
        img(
            [
                ("cahier", "un cahier"),
                ("hier", "hier"),
                ("apprendre", "apprendre"),
                ("danse", "la danse"),
            ]
        ),
        short("Écrivez cinq lignes : hier, deux j'ai, un j'ai appris, un je n'ai pas, signature."),
        aud("Lisez votre page, une phrase, une pause."),
    ],
)

S1_EL = lesson(
    "EL — J'ai + participe",
    "EL",
    """Objectif
Retenir le passé composé avec avoir.

Consigne
Apprenez la fiche, puis racontez hier.

Support — Fiche du cahier
j'ai / tu as / il a / elle a / nous avons + participe
j'ai écouté, lu, écrit, appris, travaillé, dansé
je n'ai pas + participe
hier / samedi dernier
Participe : écouté, lu, écrit, appris (pas « apprendre »).
Attention : tu as (pas tu a). J'ai appris (invariable ici).
On ne dit pas « j'ai apprendre ».""",
    [
        tf("On dit « j'ai apprendre ».", False, "J'ai appris."),
        qcm(
            "Quelle forme est correcte ?",
            ["j'ai lu", "j'ai lire", "j'ai lis", "j'ai lise"],
            0,
            "J'ai lu.",
        ),
        match(
            [
                ("écouter", "écouté"),
                ("lire", "lu"),
                ("écrire", "écrit"),
                ("apprendre", "appris"),
            ]
        ),
        fill("Complétez :\nElle a ___ une carte.", "écrit"),
        wo(["Nous", "avons", "lu", "."]),
        ana("avons", "Nous… (auxiliaire avoir)."),
        err(
            "Il a apprendre un mot.",
            "Il a appris un mot.",
            "Passé composé : a + appris.",
        ),
        img(
            [
                ("apprendre", "apprendre"),
                ("lire", "lire"),
                ("ecrire", "écrire"),
                ("cahier", "un cahier"),
            ]
        ),
        short("Recopiez la fiche. Écrivez quatre phrases : écouté / lu / écrit / appris."),
        aud("Dites : j'ai, tu as, il a, elle a, puis j'ai écouté, j'ai lu, j'ai appris."),
    ],
)

# ---------------------------------------------------------------------------
# Séquence 2 — Jeunes talents
# passé récent : je viens de ; futur proche : je vais
# ---------------------------------------------------------------------------

S2_CO = lesson(
    "CO — Sami et Benoît sous le fil",
    "CO",
    """Objectif
Comprendre je viens de + infinitif et je vais + infinitif.

Consigne
Qui vient de faire quoi ? Qui va faire quoi ?

Support — Cour, après la Salle des Herbes
Sami : Je viens de jouer du tambour. J'ai dix-sept ans. Je suis de Rukiri-Nord.
Rose : Bravo. Moi, je vais danser ce soir.
Benoît : Je viens de courir au jardin. Demain, je vais courir encore.
Kévin : Je viens de jouer au football avec papa.
Léa : Moi, je vais écrire une page sur vous, dans le cahier.
Aline : Les jeunes talents du Seuil. On va écouter, ce soir.""",
    [
        tf("Sami vient de jouer du tambour.", True, "Sami : « Je viens de jouer du tambour. »"),
        qcm(
            "Que va faire Rose ce soir ?",
            ["Courir", "Jouer au football", "Danser", "Écrire un livre"],
            2,
            "Rose : « je vais danser ce soir. »",
        ),
        match(
            [
                ("Sami", "vient de jouer"),
                ("Benoît", "vient de courir"),
                ("Rose", "va danser"),
                ("Léa", "va écrire"),
            ]
        ),
        fill("Complétez :\nJe ___ de jouer du tambour.", "viens"),
        wo(["Je", "vais", "danser", "."]),
        ana("viens", "Je… de + infinitif : c'est tout proche."),
        err(
            "Je vien de jouer.",
            "Je viens de jouer.",
            "Je viens (avec s).",
        ),
        img(
            [
                ("tambour", "un tambour"),
                ("courir", "courir"),
                ("talent", "un talent"),
                ("jeune", "jeune"),
            ]
        ),
        short("Notez deux « je viens de » et deux « je vais » entendus."),
        aud(
            "Enregistrez : Je viens de jouer. Je viens de courir. Je vais danser. Je vais écrire."
        ),
    ],
)

S2_CE = lesson(
    "CE — Cartes « vient de » / « va »",
    "CE",
    """Objectif
Lire des projets et des actions toutes proches.

Consigne
Lisez les cartes du cahier.

Support — Cartes jeunes talents
Sami Niyonteze — 17 ans — vient de jouer du tambour — va répéter demain
Benoît Habumuremyi — vient de courir — va courir demain matin
Rose Iradukunda — va danser ce soir à la Salle des Herbes
Kévin Nkurunziza — vient de jouer au football
Léa — va écrire leurs histoires
Feuille du Seuil : un talent, une phrase au passé récent, une au futur proche.""",
    [
        tf("Benoît va courir ce soir.", False, "Benoît va courir demain matin."),
        qcm(
            "Quel âge a Sami ?",
            ["Huit ans", "Dix-sept ans", "Trente ans", "On ne sait pas"],
            1,
            "Carte : 17 ans.",
        ),
        match(
            [
                ("vient de", "tout près dans le passé"),
                ("va", "tout près dans le futur"),
                ("tambour", "Sami"),
                ("football", "Kévin"),
            ]
        ),
        fill("Complétez :\nSami va ___ demain.", "répéter"),
        wo(["Il", "vient", "de", "courir", "."]),
        ana("demain", "Le jour après aujourd'hui, pour un projet."),
        err(
            "Je vas danser ce soir.",
            "Je vais danser ce soir.",
            "Je vais (pas je vas).",
        ),
        img(
            [
                ("recent", "venir de"),
                ("projet", "un projet"),
                ("tambour", "un tambour"),
                ("danse", "la danse"),
            ]
        ),
        short("Recopiez deux cartes. Ajoutez la vôtre : je viens de… / je vais…"),
        aud("Lisez les cartes, puis la phrase de la Feuille du Seuil."),
    ],
)

S2_PO = lesson(
    "PO — Dire je viens de, je vais",
    "PO",
    """Objectif
Dire un passé récent et un projet proche.

Consigne
Répétez, puis parlez de vous.

Support — Modèles de Sami
Je viens de jouer.
Tu viens de courir.
Il vient de manger.
Je vais répéter.
Tu vas danser.
Elle va écrire.
Nous allons écouter.
On va au jardin.""",
    [
        tf("« Je viens de » parle d'un passé tout proche.", True, "Venir de + infinitif."),
        qcm(
            "Quelle phrase est un projet proche ?",
            ["Je viens de jouer", "J'ai joué hier", "Je vais répéter", "Je joue toujours"],
            2,
            "Je vais + infinitif = futur proche.",
        ),
        match(
            [
                ("je viens", "de + infinitif"),
                ("tu viens", "de + infinitif"),
                ("je vais", "infinitif"),
                ("tu vas", "infinitif"),
            ]
        ),
        fill("Complétez :\nTu ___ danser ce soir.", "vas"),
        wo(["Nous", "allons", "écouter", "."]),
        ana("allons", "Nous… + infinitif : futur proche."),
        err(
            "Il vient de joue.",
            "Il vient de jouer.",
            "Venir de + infinitif (jouer).",
        ),
        img(
            [
                ("recent", "venir de"),
                ("projet", "un projet"),
                ("courir", "courir"),
                ("talent", "un talent"),
            ]
        ),
        short("Écrivez six phrases : trois je viens de, trois je vais."),
        aud("Enregistrez les huit modèles, puis un talent (vrai ou inventé)."),
    ],
)

S2_PE = lesson(
    "PE — Ma carte de talent",
    "PE",
    """Objectif
Écrire une carte : je viens de / je vais.

Consigne
Imitez la carte de Benoît.

Support — Carte de Benoît
Je m'appelle Benoît Habumuremyi.
Je viens de courir au jardin des Sources.
Demain, je vais courir encore.
Je n'ai pas dix-sept ans. J'ai vingt ans.
Benoît
Jeunes talents — Rukiri-Nord""",
    [
        tf("Benoît a dix-sept ans.", False, "« Je n'ai pas dix-sept ans. J'ai vingt ans. »"),
        qcm(
            "Où Benoît vient-il de courir ?",
            ["À la salle", "Au jardin des Sources", "Au marché", "À l'accueil"],
            1,
            "« au jardin des Sources ».",
        ),
        match(
            [
                ("je viens de", "courir"),
                ("je vais", "courir encore"),
                ("vingt ans", "âge"),
                ("jardin", "lieu"),
            ]
        ),
        fill("Complétez :\nJe viens ___ courir.", "de"),
        wo(["Je", "vais", "courir", "encore", "."]),
        ana("courir", "Le verbe de Benoît, au jardin."),
        err(
            "Je viens de courir. Je vas courir demain.",
            "Je viens de courir. Je vais courir demain.",
            "Je vais (pas je vas).",
        ),
        img(
            [
                ("courir", "courir"),
                ("jeune", "jeune"),
                ("projet", "un projet"),
                ("figuier", "le figuier"),
            ]
        ),
        short("Écrivez votre carte : je m'appelle, je viens de, je vais, âge, signature."),
        aud("Lisez votre carte, simplement."),
    ],
)

S2_EL = lesson(
    "EL — Venir de, aller + infinitif",
    "EL",
    """Objectif
Retenir le passé récent et le futur proche.

Consigne
Étudiez la fiche.

Support — Fiche de Sami
Passé récent : je viens / tu viens / il vient / elle vient + de + infinitif
Futur proche : je vais / tu vas / il va / elle va + infinitif
nous venons de / nous allons
Attention : je viens (pas je vien). Je vais (pas je vas).
Après de / après vais : un infinitif (jouer, courir, danser).
Hier = passé composé. Tout à l'heure = souvent venir de / aller.""",
    [
        tf("On dit « je vas répéter ».", False, "Je vais répéter."),
        qcm(
            "Quelle forme est correcte ?",
            ["il vien de courir", "il vient de courir", "il viennent de courir", "il venir de courir"],
            1,
            "Il vient de courir.",
        ),
        match(
            [
                ("venir de", "passé tout proche"),
                ("aller + inf.", "futur tout proche"),
                ("j'ai joué", "passé composé"),
                ("infinitif", "jouer, courir"),
            ]
        ),
        fill("Complétez :\nElle ___ de danser.", "vient"),
        wo(["Tu", "vas", "écrire", "."]),
        ana("vient", "Il / elle… de + infinitif."),
        err(
            "Nous venons de dansons.",
            "Nous venons de danser.",
            "De + infinitif : danser.",
        ),
        img(
            [
                ("recent", "venir de"),
                ("projet", "un projet"),
                ("tambour", "un tambour"),
                ("danse", "la danse"),
            ]
        ),
        short("Recopiez la fiche. Écrivez deux je viens de et deux je vais."),
        aud("Dites je viens, tu viens, il vient, je vais, tu vas, elle va, puis deux phrases."),
    ],
)

# ---------------------------------------------------------------------------
# Séquence 3 — Plumes francophones
# bio : elle est née, elle a écrit, elle habite
# ---------------------------------------------------------------------------

S3_CO = lesson(
    "CO — Mado, la plume du figuier",
    "CO",
    """Objectif
Comprendre une bio simple : elle est née, elle a écrit, elle habite.

Consigne
Où Mado est-elle née ? Qu'a-t-elle écrit ?

Support — Lecture à voix haute, cahier ouvert
Patrick : Voici Mado Karekezi. Elle est née à Rukiri-Nord.
Léa : Elle a quel âge ?
Aline : Elle a soixante ans. Elle habite près du jardin.
Hawa : Elle a écrit les Notes du figuier. Ce sont de petites histoires.
Rose : Elle parle français. Elle a appris ici, à sa manière.
Mado : J'ai écrit pour la colline. Je vais lire une page, ce soir.""",
    [
        tf("Mado est née à Rukiri-Nord.", True, "Patrick : « Elle est née à Rukiri-Nord. »"),
        qcm(
            "Qu'a écrit Mado ?",
            ["Un horaire de minibus", "Les Notes du figuier", "Un album de photos", "Une carte de danse"],
            1,
            "Hawa : « Elle a écrit les Notes du figuier. »",
        ),
        match(
            [
                ("est née", "naissance"),
                ("a écrit", "livres / notes"),
                ("habite", "maintenant"),
                ("va lire", "ce soir"),
            ]
        ),
        fill("Complétez :\nElle ___ née à Rukiri-Nord.", "est"),
        wo(["Elle", "a", "écrit", "des", "notes", "."]),
        ana("née", "Le participe avec être, pour une femme."),
        err(
            "Elle a née à Rukiri-Nord.",
            "Elle est née à Rukiri-Nord.",
            "Naître se conjugue avec être : elle est née.",
        ),
        img(
            [
                ("plume", "une plume"),
                ("livre", "un livre"),
                ("naissance", "naître"),
                ("figuier", "le figuier"),
            ]
        ),
        short("Notez : lieu de naissance, âge, livre, projet de ce soir."),
        aud(
            "Enregistrez : Elle est née ici. Elle a soixante ans. Elle a écrit des notes. Elle va lire ce soir."
        ),
    ],
)

S3_CE = lesson(
    "CE — Fiche bio de Mado",
    "CE",
    """Objectif
Lire une fiche biographique inventée.

Consigne
Lisez la fiche de la Feuille du Seuil.

Support — Feuille du Seuil
Mado Karekezi — plume de Rukiri-Nord
Elle est née à Rukiri-Nord.
Elle a soixante ans.
Elle habite près du jardin des Sources.
Elle a écrit les Notes du figuier (petites histoires).
Elle parle français et kinyarwanda.
Ce soir, elle va lire sous le figuier.
Personne réelle ? Non. Figure du cahier, inventée pour le Seuil.""",
    [
        tf("Mado habite loin de la colline.", False, "« Elle habite près du jardin des Sources. »"),
        qcm(
            "Que va faire Mado ce soir ?",
            ["Danser à la salle", "Courir au jardin", "Lire sous le figuier", "Prendre le minibus"],
            2,
            "« elle va lire sous le figuier ».",
        ),
        match(
            [
                ("née", "Rukiri-Nord"),
                ("60 ans", "âge"),
                ("Notes du figuier", "écrits"),
                ("ce soir", "lecture"),
            ]
        ),
        fill("Complétez :\nElle a ___ les Notes du figuier.", "écrit"),
        wo(["Elle", "habite", "ici", "."]),
        ana("écrit", "Le participe après elle a…, pour les notes."),
        err(
            "Elle est né à Rukiri-Nord.",
            "Elle est née à Rukiri-Nord.",
            "Féminin : née (avec e).",
        ),
        img(
            [
                ("plume", "une plume"),
                ("livre", "un livre"),
                ("journal", "un journal"),
                ("cahier", "un cahier"),
            ]
        ),
        short("Recopiez la fiche en quatre phrases : née, habite, a écrit, va lire."),
        aud("Lisez la fiche, une ligne, une pause."),
    ],
)

S3_PO = lesson(
    "PO — Dire une petite bio",
    "PO",
    """Objectif
Présenter une personne : il/elle est né(e), il/elle a écrit, il/elle habite.

Consigne
Répétez, puis présentez Mado ou une personne inventée.

Support — Modèles d'Aline
Elle est née ici.
Il est né à Rukiri-Nord.
Elle a soixante ans.
Elle habite près du jardin.
Elle a écrit des notes.
Elle parle français.
Il a écrit une page.
Elle va lire ce soir.""",
    [
        tf("« Elle est née » s'accorde au féminin.", True, "Être + née."),
        qcm(
            "Quelle phrase est correcte pour un homme ?",
            ["Il est née", "Il a né", "Il est né", "Il est nés"],
            2,
            "Il est né.",
        ),
        match(
            [
                ("elle est née", "femme"),
                ("il est né", "homme"),
                ("elle a écrit", "avoir + écrit"),
                ("elle habite", "présent"),
            ]
        ),
        fill("Complétez :\nIl est ___ à Rukiri-Nord.", "né"),
        wo(["Elle", "parle", "français", "."]),
        ana("habite", "Le verbe du lieu de vie, au présent."),
        err(
            "Il est née à Rukiri-Nord.",
            "Il est né à Rukiri-Nord.",
            "Masculin : né (sans e).",
        ),
        img(
            [
                ("naissance", "naître"),
                ("plume", "une plume"),
                ("livre", "un livre"),
                ("portrait", "un portrait"),
            ]
        ),
        short("Écrivez six phrases de bio : née/né, âge, habite, a écrit, parle, va."),
        aud("Enregistrez les huit modèles, puis la bio de Mado."),
    ],
)

S3_PE = lesson(
    "PE — Une bio en cinq lignes",
    "PE",
    """Objectif
Écrire une mini-biographie.

Consigne
Imitez la bio de Mado, ou inventez un voisin du Seuil.

Support — Bio modèle
Mado Karekezi est née à Rukiri-Nord.
Elle a soixante ans. Elle habite près du jardin.
Elle a écrit les Notes du figuier.
Elle parle français.
Ce soir, elle va lire sous le figuier.
Cahier des histoires""",
    [
        tf("La bio dit que Mado va lire ce soir.", True, "Dernière phrase avant le titre du cahier."),
        qcm(
            "Quel livre (inventé) Mado a-t-elle écrit ?",
            ["Les Heures du minibus", "Les Notes du figuier", "Le Cahier de Joël", "La Moto de Rukiri"],
            1,
            "Les Notes du figuier — titre inventé MFK.",
        ),
        match(
            [
                ("est née", "passé avec être"),
                ("a écrit", "passé avec avoir"),
                ("habite", "présent"),
                ("va lire", "futur proche"),
            ]
        ),
        fill("Complétez :\nMado Karekezi est ___ à Rukiri-Nord.", "née"),
        wo(["Elle", "a", "soixante", "ans", "."]),
        ana("notes", "Les petites histoires du figuier, au pluriel."),
        err(
            "Mado est née à Rukiri-Nord. Elle a écrite un livre.",
            "Mado est née à Rukiri-Nord. Elle a écrit un livre.",
            "Avec avoir, écrit reste invariable ici (pas de COD avant le verbe).",
        ),
        img(
            [
                ("livre", "un livre"),
                ("plume", "une plume"),
                ("cahier", "un cahier"),
                ("figuier", "le figuier"),
            ]
        ),
        short("Écrivez cinq lignes : est né(e), âge, habite, a écrit, va…"),
        aud("Lisez votre bio, calmement."),
    ],
)

S3_EL = lesson(
    "EL — Être né(e), avoir écrit",
    "EL",
    """Objectif
Retenir la bio : être né(e), avoir + participe, présent, futur proche.

Consigne
Apprenez la fiche.

Support — Fiche d'Aline
elle est née / il est né
j'ai écrit / elle a écrit
elle habite / elle parle
elle va lire
être (né, allé, arrivé) : on accorde
avoir (écrit, lu, appris) : pas d'accord ici
Attention : elle est née (pas elle a née). Il est né (pas il est née).
Personne inventée : Mado Karekezi, pas une célébrité réelle.""",
    [
        tf("On dit « elle a née ».", False, "Elle est née."),
        qcm(
            "Quelle phrase est correcte ?",
            ["Elle a née ici", "Elle est né ici", "Elle est née ici", "Elle née ici"],
            2,
            "Elle est née ici.",
        ),
        match(
            [
                ("être", "né / née"),
                ("avoir", "écrit / lu"),
                ("présent", "habite"),
                ("futur proche", "va lire"),
            ]
        ),
        fill("Complétez :\nIls sont ___ à Rukiri-Nord. (deux hommes)", "nés"),
        wo(["Elle", "est", "née", "ici", "."]),
        ana("nés", "Le pluriel masculin, avec ils sont…"),
        err(
            "Ils sont né à Rukiri-Nord.",
            "Ils sont nés à Rukiri-Nord.",
            "Pluriel : nés.",
        ),
        img(
            [
                ("naissance", "naître"),
                ("plume", "une plume"),
                ("ecrire", "écrire"),
                ("livre", "un livre"),
            ]
        ),
        short("Recopiez la fiche. Écrivez une bio inventée en quatre phrases."),
        aud("Dites : elle est née, il est né, elle a écrit, elle habite, elle va lire."),
    ],
)

# ---------------------------------------------------------------------------
# Séquence 4 — Portrait d'un jour
# description physique + un passé (il est arrivé)
# ---------------------------------------------------------------------------

S4_CO = lesson(
    "CO — Sami, hier soir",
    "CO",
    """Objectif
Comprendre un portrait : il est, il a, et un événement (il est arrivé).

Consigne
Comment est Sami ? Qu'est-ce qu'il a ? Que s'est-il passé hier ?

Support — Photo épinglée au cahier
Léa : Hier, Sami est arrivé à la salle. Il est grand.
Rose : Il a les cheveux courts. Il a un sourire.
Patrick : Il a un tambour. Il n'a pas de lunettes.
Aline : Il est jeune. Il est de Rukiri-Nord.
Hawa : Après, il a joué. Tout le monde a écouté.
Sami : Voilà mon portrait d'un jour.""",
    [
        tf("Sami a des lunettes.", False, "Patrick : « Il n'a pas de lunettes. »"),
        qcm(
            "Comment Sami est-il arrivé, d'après Léa ?",
            ["Il est petit", "Il est arrivé à la salle", "Il est né à midi", "Il a les cheveux longs"],
            1,
            "Léa : « Sami est arrivé à la salle. »",
        ),
        match(
            [
                ("grand", "taille"),
                ("cheveux courts", "tête"),
                ("tambour", "objet"),
                ("arrivé", "hier"),
            ]
        ),
        fill("Complétez :\nIl ___ les cheveux courts.", "a"),
        wo(["Il", "est", "grand", "."]),
        ana("arrivé", "Le participe avec être, hier à la salle."),
        err(
            "Sami est arrivée à la salle.",
            "Sami est arrivé à la salle.",
            "Sami = il : arrivé (sans e).",
        ),
        img(
            [
                ("portrait", "un portrait"),
                ("grand", "grand"),
                ("cheveux", "les cheveux"),
                ("tambour", "un tambour"),
            ]
        ),
        short("Notez : un verbe d'arrivée, deux « il est », deux « il a »."),
        aud(
            "Enregistrez : Hier, il est arrivé. Il est grand. Il a les cheveux courts. Il a un tambour."
        ),
    ],
)

S4_CE = lesson(
    "CE — Carte portrait",
    "CE",
    """Objectif
Lire un portrait écrit pour un jour précis.

Consigne
Lisez la carte de Léa.

Support — Carte « Un jour »
Hier soir — Salle des Herbes
Sami Niyonteze
Il est arrivé à dix-neuf heures.
Il est grand. Il est jeune.
Il a les cheveux courts. Il a un sourire.
Il a un tambour. Il n'a pas de lunettes.
Il a joué. Nous avons écouté.
Portrait d'un jour — Léa""",
    [
        tf("Sami est arrivé le matin.", False, "Carte : hier soir, 19 h."),
        qcm(
            "Qui a écrit la carte ?",
            ["Sami", "Rose", "Léa", "Mado"],
            2,
            "Signature : Léa.",
        ),
        match(
            [
                ("est arrivé", "être + participe"),
                ("est grand", "description"),
                ("a les cheveux", "avoir"),
                ("a joué", "avoir + participe"),
            ]
        ),
        fill("Complétez :\nIl n'a pas ___ lunettes.", "de"),
        wo(["Il", "a", "un", "sourire", "."]),
        ana("sourire", "Sami l'a, sur la photo du cahier."),
        err(
            "Il a les cheveu courts.",
            "Il a les cheveux courts.",
            "Cheveux au pluriel.",
        ),
        img(
            [
                ("photo", "une photo"),
                ("lunettes", "les lunettes"),
                ("cheveux", "les cheveux"),
                ("jeune", "jeune"),
            ]
        ),
        short("Recopiez la carte. Changez le prénom et deux détails."),
        aud("Lisez la carte, sans aller trop vite."),
    ],
)

S4_PO = lesson(
    "PO — Décrire une personne",
    "PO",
    """Objectif
Décrire : il/elle est, il/elle a, et un passé simple à l'oral (est arrivé(e)).

Consigne
Répétez, puis décrivez Sami ou un camarade.

Support — Modèles de Rose
Il est grand.
Elle est petite.
Il est jeune.
Il a les cheveux courts.
Elle a les cheveux longs.
Il a des lunettes.
Elle n'a pas de lunettes.
Il est arrivé hier.""",
    [
        tf("« Elle est petite » s'accorde au féminin.", True, "Petite, avec e."),
        qcm(
            "Quelle phrase décrit un objet sur la personne ?",
            ["Il est grand", "Il est jeune", "Il a des lunettes", "Il est arrivé"],
            2,
            "Avoir + lunettes.",
        ),
        match(
            [
                ("il est", "adjectif"),
                ("il a", "cheveux / lunettes / tambour"),
                ("est arrivé", "un moment"),
                ("n'a pas de", "absence"),
            ]
        ),
        fill("Complétez :\nElle ___ petite.", "est"),
        wo(["Elle", "est", "arrivée", "hier", "."]),
        ana("petite", "Féminin de petit."),
        err(
            "Elle est arrivé hier.",
            "Elle est arrivée hier.",
            "Féminin avec être : arrivée.",
        ),
        img(
            [
                ("grand", "grand"),
                ("cheveux", "les cheveux"),
                ("lunettes", "les lunettes"),
                ("portrait", "un portrait"),
            ]
        ),
        short("Écrivez six phrases : deux est, deux a, une n'a pas, une est arrivé(e)."),
        aud("Enregistrez les huit modèles, puis un portrait d'un jour."),
    ],
)

S4_PE = lesson(
    "PE — Un portrait d'un jour",
    "PE",
    """Objectif
Écrire un portrait daté.

Consigne
Imitez le portrait de Léa. Changez la personne.

Support — Portrait
Hier soir, Rose est arrivée à la salle.
Elle est jeune. Elle a les cheveux longs.
Elle n'a pas de tambour. Elle a un sourire.
Elle a dansé. Nous avons regardé.
Léa
Portrait d'un jour""",
    [
        tf("Rose a un tambour.", False, "« Elle n'a pas de tambour. »"),
        qcm(
            "Que s'est-il passé après l'arrivée de Rose ?",
            ["Elle a couru", "Elle a dansé", "Elle a écrit un livre", "Elle est née"],
            1,
            "« Elle a dansé. »",
        ),
        match(
            [
                ("est arrivée", "Rose"),
                ("cheveux longs", "description"),
                ("a dansé", "action"),
                ("nous avons regardé", "le groupe"),
            ]
        ),
        fill("Complétez :\nRose est ___ à la salle.", "arrivée"),
        wo(["Elle", "a", "dansé", "."]),
        ana("longs", "Les cheveux de Rose, pas courts."),
        err(
            "Rose est arrivé à la salle.",
            "Rose est arrivée à la salle.",
            "Rose = elle : arrivée.",
        ),
        img(
            [
                ("danse", "la danse"),
                ("photo", "une photo"),
                ("portrait", "un portrait"),
                ("cheveux", "les cheveux"),
            ]
        ),
        short("Écrivez un portrait daté : est arrivé(e), est, a, n'a pas, a + verbe."),
        aud("Lisez votre portrait, une phrase, une pause."),
    ],
)

S4_EL = lesson(
    "EL — Est, a, est arrivé(e)",
    "EL",
    """Objectif
Retenir description et accord avec être.

Consigne
Apprenez la fiche.

Support — Fiche de Léa
il est / elle est + adjectif (grand, grande, jeune)
il a / elle a + les cheveux / des lunettes / un tambour
il n'a pas de + nom
il est arrivé / elle est arrivée
ils sont arrivés / elles sont arrivées
avoir : il a joué, elle a dansé (pas d'accord ici)
Attention : arrivé / arrivée / arrivés / arrivées.
On ne dit pas « elle est arrivé ».""",
    [
        tf("On dit « elle est arrivé ».", False, "Elle est arrivée."),
        qcm(
            "Quelle phrase est correcte ?",
            ["Elles sont arrivé", "Elles sont arrivée", "Elles sont arrivées", "Elles ont arrivées"],
            2,
            "Elles sont arrivées.",
        ),
        match(
            [
                ("il est arrivé", "un homme"),
                ("elle est arrivée", "une femme"),
                ("ils sont arrivés", "plusieurs, dont un homme"),
                ("elles sont arrivées", "plusieurs femmes"),
            ]
        ),
        fill("Complétez :\nElles sont ___.", "arrivées"),
        wo(["Il", "n'a", "pas", "de", "lunettes", "."]),
        ana("arrivée", "Une femme, hier, à la salle : elle est…"),
        err(
            "Ils sont arrivé à dix-neuf heures.",
            "Ils sont arrivés à dix-neuf heures.",
            "Pluriel : arrivés.",
        ),
        img(
            [
                ("arriver", "arriver"),
                ("grand", "grand"),
                ("lunettes", "les lunettes"),
                ("portrait", "un portrait"),
            ]
        ),
        short("Recopiez la fiche. Écrivez quatre accords : il / elle / ils / elles."),
        aud("Dites : il est arrivé, elle est arrivée, ils sont arrivés, elles sont arrivées."),
    ],
)

# ---------------------------------------------------------------------------
# Séquence 5 — Un choix de vie
# avant (passé) / maintenant (présent)
# ---------------------------------------------------------------------------

S5_CO = lesson(
    "CO — Yvette a choisi la colline",
    "CO",
    """Objectif
Comprendre un choix : avant + passé composé, maintenant + présent.

Consigne
Qu'a fait Yvette avant ? Que fait-elle maintenant ?

Support — Infirmerie des Herbes, thé à la main
Yvette : Avant, j'ai travaillé loin. J'ai habité en ville.
Léa : Et maintenant ?
Yvette : Maintenant, je suis ici. Je travaille à l'Infirmerie des Herbes.
Joël : Moi, avant, j'ai conduit un grand bus. Maintenant, je suis à la moto.
Aline : J'ai choisi l'accueil. Maintenant, j'ouvre le Seuil.
Patrick : On a tous choisi un chemin.""",
    [
        tf("Yvette travaille encore en ville.", False, "Maintenant, elle est ici, à l'infirmerie."),
        qcm(
            "Que faisait Joël avant ?",
            ["Il dansait", "Il a conduit un grand bus", "Il écrivait des notes", "Il était guide"],
            1,
            "Joël : « j'ai conduit un grand bus. »",
        ),
        match(
            [
                ("Yvette avant", "ville, loin"),
                ("Yvette maintenant", "infirmerie"),
                ("Joël avant", "grand bus"),
                ("Aline maintenant", "accueil"),
            ]
        ),
        fill("Complétez :\nAvant, j'___ travaillé loin.", "ai"),
        wo(["Maintenant", "je", "suis", "ici", "."]),
        ana("choix", "Un chemin de vie : on a… un."),
        err(
            "Avant j'ai travaillé loin. Maintenant j'ai suis ici.",
            "Avant j'ai travaillé loin. Maintenant je suis ici.",
            "Maintenant : présent (je suis), pas j'ai suis.",
        ),
        img(
            [
                ("choix", "un choix"),
                ("avant", "avant"),
                ("maintenant", "maintenant"),
                ("aller", "aller"),
            ]
        ),
        short("Notez deux « avant, j'ai… » et deux « maintenant, je… »."),
        aud(
            "Enregistrez : Avant, j'ai travaillé loin. Maintenant, je suis ici. J'ai choisi ce chemin."
        ),
    ],
)

S5_CE = lesson(
    "CE — Deux colonnes : avant / maintenant",
    "CE",
    """Objectif
Lire un tableau de choix de vie.

Consigne
Lisez le tableau du cahier.

Support — Tableau
Un choix de vie — Rukiri-Nord
Yvette Mukeshimana — Avant : elle a travaillé loin. Maintenant : infirmerie des Herbes.
Joël Mugisha — Avant : il a conduit un bus. Maintenant : moto Figuier.
Aline Uwase — Avant : elle a étudié en ville. Maintenant : accueil du Seuil.
Léa Niyonzima — Avant : elle a habité loin. Maintenant : elle apprend ici.
Rien n'est obligatoire. C'est un choix.""",
    [
        tf("Léa habite encore loin.", False, "Maintenant, elle apprend ici."),
        qcm(
            "Qu'a fait Aline avant ?",
            ["Elle a dansé", "Elle a étudié en ville", "Elle a conduit un bus", "Elle a écrit les Notes"],
            1,
            "Aline : elle a étudié en ville.",
        ),
        match(
            [
                ("avant", "passé composé"),
                ("maintenant", "présent"),
                ("infirmerie", "Yvette"),
                ("accueil", "Aline"),
            ]
        ),
        fill("Complétez :\nMaintenant, elle ___ ici.", "apprend"),
        wo(["J'ai", "choisi", "ce", "chemin", "."]),
        ana("choisi", "Le participe après j'ai, pour un chemin de vie."),
        err(
            "Avant elle a étudié. Maintenant elle a étudie à l'accueil.",
            "Avant elle a étudié. Maintenant elle étudie à l'accueil.",
            "Maintenant : présent (étudie), pas a étudie.",
        ),
        img(
            [
                ("avant", "avant"),
                ("maintenant", "maintenant"),
                ("choix", "un choix"),
                ("cahier", "un cahier"),
            ]
        ),
        short("Recopiez une ligne. Ajoutez la vôtre : avant / maintenant."),
        aud("Lisez le tableau, avant d'abord, puis maintenant."),
    ],
)

S5_PO = lesson(
    "PO — Dire avant et maintenant",
    "PO",
    """Objectif
Opposer un passé et un présent : avant j'ai…, maintenant je…

Consigne
Répétez, puis parlez d'un choix (vrai ou inventé).

Support — Modèles d'Yvette
Avant, j'ai travaillé loin.
Avant, j'ai habité en ville.
Maintenant, je suis ici.
Maintenant, je travaille à l'infirmerie.
J'ai choisi la colline.
Il a choisi la moto.
Elle a choisi l'accueil.
On a choisi ce Seuil.""",
    [
        tf("« J'ai choisi » est au passé composé.", True, "Avoir + choisi."),
        qcm(
            "Quelle phrase est au présent ?",
            ["J'ai travaillé loin", "J'ai choisi la colline", "Maintenant je suis ici", "Avant j'ai habité en ville"],
            2,
            "Je suis = présent.",
        ),
        match(
            [
                ("avant", "j'ai…"),
                ("maintenant", "je suis / je travaille"),
                ("j'ai choisi", "décision"),
                ("ici", "Rukiri-Nord"),
            ]
        ),
        fill("Complétez :\nJ'ai ___ la colline.", "choisi"),
        wo(["Elle", "a", "choisi", "l'accueil", "."]),
        ana("avant", "Le mot du passé, face à maintenant."),
        err(
            "J'ai choisi la colline. Maintenant j'ai travailler ici.",
            "J'ai choisi la colline. Maintenant je travaille ici.",
            "Maintenant : je travaille (présent).",
        ),
        img(
            [
                ("choix", "un choix"),
                ("avant", "avant"),
                ("maintenant", "maintenant"),
                ("arriver", "arriver"),
            ]
        ),
        short("Écrivez six phrases : deux avant, deux maintenant, deux j'ai choisi."),
        aud("Enregistrez les huit modèles, puis votre choix."),
    ],
)

S5_PE = lesson(
    "PE — Mon choix en six lignes",
    "PE",
    """Objectif
Écrire un petit texte avant / maintenant.

Consigne
Imitez le mot d'Yvette.

Support — Mot d'Yvette
Bonjour,
Avant, j'ai travaillé loin. J'ai habité en ville.
Maintenant, je suis à Rukiri-Nord.
Je travaille à l'Infirmerie des Herbes.
J'ai choisi ce chemin.
Yvette Mukeshimana""",
    [
        tf("Yvette habite encore en ville.", False, "Maintenant, elle est à Rukiri-Nord."),
        qcm(
            "Où Yvette travaille-t-elle maintenant ?",
            ["À l'accueil", "À l'Infirmerie des Herbes", "Au minibus", "À la salle"],
            1,
            "« Je travaille à l'Infirmerie des Herbes. »",
        ),
        match(
            [
                ("avant", "loin, ville"),
                ("maintenant", "Rukiri-Nord"),
                ("infirmerie", "travail"),
                ("chemin", "choix"),
            ]
        ),
        fill("Complétez :\nMaintenant, je ___ à Rukiri-Nord.", "suis"),
        wo(["J'ai", "habité", "en", "ville", "."]),
        ana("ville", "Le lieu d'avant, opposé à la colline."),
        err(
            "J'ai habité en ville. Maintenant je suis allé à Rukiri-Nord.",
            "J'ai habité en ville. Maintenant je suis à Rukiri-Nord.",
            "Yvette = elle, et c'est un état présent : je suis (pas je suis allé).",
        ),
        img(
            [
                ("choix", "un choix"),
                ("maintenant", "maintenant"),
                ("avant", "avant"),
                ("journal", "un journal"),
            ]
        ),
        short("Écrivez six lignes : bonjour, deux avant, deux maintenant, j'ai choisi."),
        aud("Lisez votre mot, simplement."),
    ],
)

S5_EL = lesson(
    "EL — Avant j'ai, maintenant je",
    "EL",
    """Objectif
Retenir le contraste passé composé / présent.

Consigne
Apprenez la fiche.

Support — Fiche d'Yvette
Avant + passé composé : j'ai travaillé, j'ai habité, j'ai choisi
Maintenant + présent : je suis, je travaille, j'habite
j'ai choisi / tu as choisi / elle a choisi
Attention : choisi (pas « choisé »).
On ne mélange pas : « maintenant j'ai suis ».
Un choix de vie = un chemin, pas une célébrité.""",
    [
        tf("On écrit « j'ai choisé ».", False, "J'ai choisi."),
        qcm(
            "Quelle phrase est correcte ?",
            ["Maintenant j'ai suis ici", "Maintenant je suis ici", "Maintenant je suis allé ici", "Maintenant j'être ici"],
            1,
            "Maintenant je suis ici.",
        ),
        match(
            [
                ("avant", "passé composé"),
                ("maintenant", "présent"),
                ("choisi", "participe"),
                ("chemin", "vie"),
            ]
        ),
        fill("Complétez :\nTu as ___ l'accueil ?", "choisi"),
        wo(["Maintenant", "je", "travaille", "ici", "."]),
        ana("choisi", "Le participe après j'ai, pour un chemin."),
        err(
            "Elle a choisi la colline. Avant elle habite loin.",
            "Elle a choisi la colline. Avant elle a habité loin.",
            "Avant : passé composé (a habité).",
        ),
        img(
            [
                ("choix", "un choix"),
                ("avant", "avant"),
                ("maintenant", "maintenant"),
                ("aller", "aller"),
            ]
        ),
        short("Recopiez la fiche. Écrivez quatre phrases : deux avant, deux maintenant."),
        aud("Dites : avant j'ai travaillé, maintenant je travaille, j'ai choisi ce chemin."),
    ],
)

# ---------------------------------------------------------------------------
# Séquence 6 — S'informer pour avancer
# impératif ; il faut ; on peut
# ---------------------------------------------------------------------------

S6_CO = lesson(
    "CO — Conseils autour du cahier",
    "CO",
    """Objectif
Comprendre des conseils : écoutez, lisez, il faut, on peut.

Consigne
Quels conseils entend-on ? Pour avancer comment ?

Support — Feuille du Seuil, lue à voix haute
Aline : Écoutez Radio Figuier. Lisez la Feuille du Seuil.
Patrick : Demandez le chemin, si vous ne savez pas.
Mado : Il faut lire un peu, tous les jours. On peut écrire une ligne.
Léa : Posez une question. Ce n'est pas grave.
Yvette : Allez à l'infirmerie si vous êtes fatigué.
Rose : Venez à la salle. Mais d'abord, informez-vous.""",
    [
        tf("Aline conseille d'écouter la radio.", True, "Aline : « Écoutez Radio Figuier. »"),
        qcm(
            "Que dit Mado ?",
            ["Il faut danser", "Il faut lire un peu", "Il faut prendre la moto", "Il faut partir"],
            1,
            "Mado : « Il faut lire un peu, tous les jours. »",
        ),
        match(
            [
                ("écoutez", "radio"),
                ("lisez", "Feuille du Seuil"),
                ("il faut", "lire"),
                ("on peut", "écrire"),
            ]
        ),
        fill("Complétez :\nIl ___ lire un peu.", "faut"),
        wo(["Posez", "une", "question", "."]),
        ana("faut", "Il… + infinitif : un conseil fort."),
        err(
            "Il faut tu lis tous les jours.",
            "Il faut lire tous les jours.",
            "Il faut + infinitif (lire).",
        ),
        img(
            [
                ("conseil", "un conseil"),
                ("journal", "un journal"),
                ("question", "une question"),
                ("ecouter", "écouter"),
            ]
        ),
        short("Listez quatre conseils entendus (impératif ou il faut / on peut)."),
        aud(
            "Enregistrez : Écoutez la radio. Lisez la feuille. Il faut lire un peu. On peut écrire une ligne."
        ),
    ],
)

S6_CE = lesson(
    "CE — La Feuille du Seuil",
    "CE",
    """Objectif
Lire une petite feuille de conseils.

Consigne
Lisez l'affiche.

Support — Affiche
S'informer pour avancer — Rukiri-Nord
1. Écoutez Radio Figuier (16 h).
2. Lisez la Feuille du Seuil (sous le figuier).
3. Demandez à Aline, à l'accueil.
4. Il faut noter une phrase dans le cahier.
5. On peut poser une question. Ce n'est pas grave.
6. Allez au jardin pour marcher, ou à la salle pour danser.
Inventée pour le Seuil. Pas un journal réel.""",
    [
        tf("On doit écouter la radio à minuit.", False, "Radio Figuier à 16 h."),
        qcm(
            "À qui demander, d'après l'affiche ?",
            ["À Mado seulement", "À Aline, à l'accueil", "Au minibus", "À Kévin"],
            1,
            "« Demandez à Aline, à l'accueil. »",
        ),
        match(
            [
                ("écoutez", "radio"),
                ("lisez", "feuille"),
                ("demandez", "Aline"),
                ("allez", "jardin ou salle"),
            ]
        ),
        fill("Complétez :\nOn ___ poser une question.", "peut"),
        wo(["Demandez", "à", "Aline", "."]),
        ana("conseil", "Un mot pour aider à avancer."),
        err(
            "Écoute la radio.",
            "Écoutez la radio.",
            "Au groupe : écoutez (pas écoute).",
        ),
        img(
            [
                ("journal", "un journal"),
                ("conseil", "un conseil"),
                ("question", "une question"),
                ("figuier", "le figuier"),
            ]
        ),
        short("Recopiez trois conseils. Ajoutez le vôtre avec il faut ou on peut."),
        aud("Lisez l'affiche, un numéro, une pause."),
    ],
)

S6_PO = lesson(
    "PO — Donner un conseil",
    "PO",
    """Objectif
Donner un conseil : impératif, il faut, on peut.

Consigne
Répétez, puis conseillez un camarade.

Support — Modèles d'Aline
Écoutez.
Lisez.
Demandez.
Posez une question.
Allez à l'accueil.
Il faut lire.
On peut écrire.
N'oubliez pas le cahier.""",
    [
        tf("« Écoutez » est un impératif de politesse au groupe.", True, "Vous : écoutez."),
        qcm(
            "Quelle phrase utilise « il faut » ?",
            ["Écoutez", "On peut écrire", "Il faut lire", "Allez à l'accueil"],
            2,
            "Il faut + infinitif.",
        ),
        match(
            [
                ("écoutez", "impératif"),
                ("il faut", "obligation douce"),
                ("on peut", "possibilité"),
                ("n'oubliez pas", "négation"),
            ]
        ),
        fill("Complétez :\n___ une question.", "Posez"),
        wo(["Il", "faut", "lire", "."]),
        ana("lisez", "L'impératif de lire, pour vous / le groupe."),
        err(
            "Il faut lisez le cahier.",
            "Il faut lire le cahier.",
            "Il faut + infinitif, pas l'impératif.",
        ),
        img(
            [
                ("conseil", "un conseil"),
                ("lire", "lire"),
                ("ecouter", "écouter"),
                ("question", "une question"),
            ]
        ),
        short("Écrivez six conseils : deux impératifs, deux il faut, deux on peut."),
        aud("Enregistrez les huit modèles, puis deux conseils personnels."),
    ],
)

S6_PE = lesson(
    "PE — Un petit mot de conseil",
    "PE",
    """Objectif
Écrire une courte liste de conseils.

Consigne
Imitez le mot de Mado.

Support — Mot de Mado
Amies, amis,
Écoutez un peu chaque jour.
Lisez une ligne des Notes du figuier.
Il faut poser une question.
On peut écrire dans le cahier.
Avancez, à votre manière.
Mado Karekezi""",
    [
        tf("Mado interdit d'écrire dans le cahier.", False, "« On peut écrire dans le cahier. »"),
        qcm(
            "Quelle formule de clôture Mado utilise-t-elle ?",
            ["Au revoir la ville", "Avancez, à votre manière", "Prenez le bus", "Silence"],
            1,
            "« Avancez, à votre manière. »",
        ),
        match(
            [
                ("écoutez", "chaque jour"),
                ("lisez", "une ligne"),
                ("il faut", "poser une question"),
                ("on peut", "écrire"),
            ]
        ),
        fill("Complétez :\nAvancez, à votre ___.", "manière"),
        wo(["On", "peut", "écrire", "."]),
        ana("avancez", "L'impératif de la dernière ligne, pour le groupe."),
        err(
            "Il faut posez une question.",
            "Il faut poser une question.",
            "Il faut + infinitif : poser.",
        ),
        img(
            [
                ("conseil", "un conseil"),
                ("cahier", "un cahier"),
                ("plume", "une plume"),
                ("journal", "un journal"),
            ]
        ),
        short("Écrivez un mot : deux impératifs, il faut, on peut, une phrase de clôture."),
        aud("Lisez votre mot, comme Mado."),
    ],
)

S6_EL = lesson(
    "EL — Impératif, il faut, on peut",
    "EL",
    """Objectif
Retenir les formes du conseil.

Consigne
Apprenez la fiche, puis donnez trois conseils.

Support — Fiche d'Aline
Impératif (vous / groupe) : écoutez, lisez, demandez, allez, posez, venez
il faut + infinitif
on peut + infinitif
n'oubliez pas
Attention : il faut lire (pas il faut lisez).
écoute (tu) / écoutez (vous).
S'informer = écouter, lire, demander.
Pour avancer : un peu, tous les jours.""",
    [
        tf("On dit « il faut lisez ».", False, "Il faut lire."),
        qcm(
            "Quelle forme s'adresse au groupe ?",
            ["écoute", "lis", "écoutez", "je écoute"],
            2,
            "Écoutez.",
        ),
        match(
            [
                ("impératif", "écoutez"),
                ("il faut", "lire"),
                ("on peut", "écrire"),
                ("s'informer", "radio, feuille, questions"),
            ]
        ),
        fill("Complétez :\nVous, ___ à l'accueil.", "allez"),
        wo(["N'oubliez", "pas", "le", "cahier", "."]),
        ana("demandez", "L'impératif pour poser une question à Aline."),
        err(
            "On peut écrivez une ligne.",
            "On peut écrire une ligne.",
            "On peut + infinitif : écrire.",
        ),
        img(
            [
                ("conseil", "un conseil"),
                ("question", "une question"),
                ("ecouter", "écouter"),
                ("lire", "lire"),
            ]
        ),
        short("Recopiez la fiche. Écrivez trois conseils : impératif, il faut, on peut."),
        aud("Dites : écoutez, lisez, demandez, il faut lire, on peut écrire, n'oubliez pas."),
    ],
)

SEQUENCES = [
    {"title": "Apprendre à sa manière", "lessons": [S1_CO, S1_CE, S1_PO, S1_PE, S1_EL]},
    {"title": "Jeunes talents", "lessons": [S2_CO, S2_CE, S2_PO, S2_PE, S2_EL]},
    {
        "title": "Plumes francophones",
        "lessons": [S3_CO, S3_CE, S3_PO, S3_PE, S3_EL],
    },
    {"title": "Portrait d'un jour", "lessons": [S4_CO, S4_CE, S4_PO, S4_PE, S4_EL]},
    {"title": "Un choix de vie", "lessons": [S5_CO, S5_CE, S5_PO, S5_PE, S5_EL]},
    {
        "title": "S'informer pour avancer",
        "lessons": [S6_CO, S6_CE, S6_PO, S6_PE, S6_EL],
    },
]
