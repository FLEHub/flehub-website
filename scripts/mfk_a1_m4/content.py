"""MFK A1 Module 4 — Portraits croisés (Seuil des Sources)."""

from __future__ import annotations

IMG = "/elearning/mfk-a1-m4/{name}.svg"


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
    "title": "A1 — Portraits croisés",
    "description": (
        "Grande étape 4 : parler de sa famille, se décrire, dire ce qu'on aime, "
        "se raconter, parler du temps libre et du corps — album de portraits "
        "sous le figuier du Seuil des Sources (Rukiri-Nord)."
    ),
}

# ---------------------------------------------------------------------------
# Séquence 1 — En famille
# mon / ma / mes ; mère, père, frère, sœur, enfant, tante, oncle
# ---------------------------------------------------------------------------

S1_CO = lesson(
    "CO — L'album sous le figuier",
    "CO",
    """Objectif
Comprendre un échange sur la famille : c'est ma / mon, j'ai un / une.

Consigne
Lisez le dialogue (à écouter avec l'enseignant). Qui est sur les photos ? Quels mots de famille entendez-vous ?

Support — Cour du Seuil, album de tissu crème
Aline : Voici mon album. C'est ma mère, Claire Mukamana.
Léa : Elle est belle. Et lui ?
Aline : C'est mon frère, Éric. J'ai aussi une nièce : Nina.
Léa : Moi, j'ai une sœur. Elle s'appelle Mireille.
Hawa : Et moi, c'est ma tante, Fatou Diallo. Elle habite près du pont.
Aline : On épingle tout sur le figuier. C'est notre famille du Seuil.""",
    [
        tf("Claire Mukamana est la mère d'Aline.", True, "Aline dit : « C'est ma mère, Claire Mukamana. »"),
        qcm(
            "Comment s'appelle la sœur de Léa ?",
            ["Nina", "Fatou", "Mireille", "Claire"],
            2,
            "Léa : « Elle s'appelle Mireille. »",
        ),
        match(
            [
                ("ma mère", "Claire"),
                ("mon frère", "Éric"),
                ("ma sœur", "Mireille"),
                ("ma tante", "Fatou"),
            ]
        ),
        fill("Complétez :\nC'est ___ mère.", "ma"),
        wo(["J'ai", "une", "sœur", "."]),
        ana("mère", "Aline la montre en premier dans l'album."),
        err(
            "C'est mon mère.",
            "C'est ma mère.",
            "Mère est féminin : ma mère.",
        ),
        img(
            [
                ("mere", "la mère"),
                ("frere", "le frère"),
                ("soeur", "la sœur"),
                ("tante", "la tante"),
            ]
        ),
        short("Notez quatre personnes de l'album et leur lien (mère, frère, sœur, tante)."),
        aud(
            "Enregistrez : Voici mon album. C'est ma mère. C'est mon frère. J'ai une sœur. C'est ma tante."
        ),
    ],
)

S1_CE = lesson(
    "CE — Les étiquettes de l'album",
    "CE",
    """Objectif
Lire des légendes de photos de famille : ma / mon / mes, c'est, j'ai.

Consigne
Lisez les étiquettes épinglées sur le tissu, puis répondez.

Support — Étiquettes (encre brune)
1. Aline — C'est ma mère, Claire. J'ai un frère, Éric. J'ai une nièce, Nina.
2. Léa — C'est ma sœur, Mireille. Mes parents habitent loin.
3. Hawa — C'est ma tante, Fatou. Je n'ai pas de frère.
4. Marc — C'est mon fils, Kévin. Il a huit ans.
Album du Seuil — Rukiri-Nord""",
    [
        tf("Hawa a un frère.", False, "L'étiquette : « Je n'ai pas de frère. »"),
        qcm(
            "Qui est Kévin ?",
            ["Le frère d'Aline", "Le fils de Marc", "L'oncle de Léa", "Le père d'Hawa"],
            1,
            "Marc : « C'est mon fils, Kévin. »",
        ),
        match(
            [
                ("Aline", "un frère et une nièce"),
                ("Léa", "une sœur"),
                ("Hawa", "une tante"),
                ("Marc", "un fils"),
            ]
        ),
        fill("Complétez :\nC'est ___ fils.", "mon"),
        wo(["J'ai", "un", "frère", "."]),
        ana("sœur", "Léa en a une, elle s'appelle Mireille."),
        err(
            "J'ai un sœur.",
            "J'ai une sœur.",
            "Sœur est féminin : une sœur.",
        ),
        img(
            [
                ("famille", "la famille"),
                ("enfant", "un enfant"),
                ("pere", "le père"),
                ("oncle", "l'oncle"),
            ]
        ),
        short("Recopiez les quatre étiquettes. Ajoutez une phrase : « C'est mon / ma… »"),
        aud("Lisez les quatre étiquettes à voix haute, lentement."),
    ],
)

S1_PO = lesson(
    "PO — Présenter les siens",
    "PO",
    """Objectif
Présenter sa famille avec c'est ma / mon et j'ai.

Consigne
Répétez les modèles, puis changez les prénoms.

Support — Modèles d'Aline
C'est ma mère.
C'est mon père.
C'est mon frère.
C'est ma sœur.
C'est ma tante.
C'est mon oncle.
J'ai un enfant.
Voici ma famille.""",
    [
        tf("« Voici ma famille » sert à montrer tout le groupe.", True, "Voici = présentation."),
        qcm(
            "Quelle phrase est correcte ?",
            ["C'est mon sœur", "C'est ma sœur", "C'est mes sœur", "C'est le sœur"],
            1,
            "Sœur → ma sœur.",
        ),
        match(
            [
                ("ma", "mère, sœur, tante"),
                ("mon", "père, frère, oncle"),
                ("mes", "parents, frères"),
                ("j'ai", "un / une + personne"),
            ]
        ),
        fill("Complétez :\nC'est ___ père.", "mon"),
        wo(["Voici", "ma", "famille", "."]),
        ana("famille", "Le mot pour tout le groupe, à la fin des modèles."),
        err(
            "C'est mes père.",
            "C'est mon père.",
            "Un seul père : mon père. Mes = plusieurs.",
        ),
        img(
            [
                ("mere", "la mère"),
                ("pere", "le père"),
                ("frere", "le frère"),
                ("soeur", "la sœur"),
            ]
        ),
        short("Écrivez six phrases : c'est ma / mon… et une phrase avec j'ai."),
        aud("Enregistrez les huit phrases modèles, puis votre famille (vraie ou inventée)."),
    ],
)

S1_PE = lesson(
    "PE — Une page pour l'album",
    "PE",
    """Objectif
Écrire une courte page de famille avec ma / mon et j'ai.

Consigne
Imitez la page de Léa. Changez les prénoms.

Support — Page de Léa (papier crème)
Je m'appelle Léa Niyonzima.
Voici ma famille.
C'est ma sœur, Mireille.
J'ai une sœur. Je n'ai pas de frère.
Mes parents habitent loin.
Léa""",
    [
        tf("Léa a un frère.", False, "Elle écrit : « Je n'ai pas de frère. »"),
        qcm(
            "Quel possessif utilise Léa devant « parents » ?",
            ["mon", "ma", "mes", "leur"],
            2,
            "« Mes parents » : plusieurs.",
        ),
        match(
            [
                ("ma sœur", "une personne"),
                ("mes parents", "plusieurs personnes"),
                ("j'ai", "possession"),
                ("je n'ai pas", "absence"),
            ]
        ),
        fill("Complétez :\n___ parents habitent loin.", "Mes"),
        wo(["Voici", "ma", "famille", "."]),
        ana("parents", "Le père et la mère, ensemble."),
        err(
            "C'est mon sœur, Mireille.",
            "C'est ma sœur, Mireille.",
            "Sœur est féminin : ma sœur.",
        ),
        img(
            [
                ("soeur", "la sœur"),
                ("famille", "la famille"),
                ("photo", "une photo"),
                ("maison", "la maison"),
            ]
        ),
        short(
            "Écrivez une page de six lignes pour l'album : je m'appelle, voici, c'est ma/mon, j'ai, je n'ai pas."
        ),
        aud("Lisez votre page comme Léa, une phrase, une pause."),
    ],
)

S1_EL = lesson(
    "EL — Ma, mon, mes",
    "EL",
    """Objectif
Retenir les possessifs et les mots de la famille.

Consigne
Apprenez la fiche, puis entraînez-vous.

Support — Fiche de l'album
ma + féminin : ma mère, ma sœur, ma tante
mon + masculin : mon père, mon frère, mon oncle
mes + pluriel : mes parents, mes frères
j'ai un frère / une sœur
je n'ai pas de frère
C'est + ma / mon + personne
Voici ma famille.
Attention : on dit ma mère, pas mon mère.""",
    [
        tf("On dit « mon sœur ».", False, "Sœur est féminin : ma sœur."),
        qcm(
            "Quel mot va avec « oncle » ?",
            ["ma", "mes", "mon", "une"],
            2,
            "Oncle est masculin : mon oncle.",
        ),
        match(
            [
                ("mère", "ma"),
                ("père", "mon"),
                ("parents", "mes"),
                ("sœur", "ma"),
            ]
        ),
        fill("Complétez :\nC'est ___ tante.", "ma"),
        wo(["Je", "n'ai", "pas", "de", "frère", "."]),
        ana("tante", "La sœur du père ou de la mère."),
        err(
            "C'est ma oncle.",
            "C'est mon oncle.",
            "Oncle est masculin : mon oncle.",
        ),
        img(
            [
                ("tante", "la tante"),
                ("oncle", "l'oncle"),
                ("enfant", "un enfant"),
                ("famille", "la famille"),
            ]
        ),
        short("Recopiez la fiche. Ajoutez quatre phrases vraies ou inventées sur votre famille."),
        aud("Dites : ma mère, mon père, ma sœur, mon frère, ma tante, mon oncle, mes parents."),
    ],
)

# ---------------------------------------------------------------------------
# Séquence 2 — Se ressembler, se distinguer
# il/elle est grand(e) ; il/elle a ; aussi / mais
# ---------------------------------------------------------------------------

S2_CO = lesson(
    "CO — Deux photos, une ressemblance",
    "CO",
    """Objectif
Comprendre une description simple : il / elle est, il / elle a, aussi, mais.

Consigne
Qui est grand ? Qui a des lunettes ? Qu'est-ce qui est pareil, qu'est-ce qui change ?

Support — Sous le figuier, deux photos
Patrick : Éric est grand. Nina est petite.
Aline : Oui. Mais Nina a les mêmes yeux. Elle ressemble à Éric.
Léa : Éric a des lunettes. Nina n'a pas de lunettes.
Patrick : Éric est jeune. Claire n'est pas jeune, mais elle sourit aussi.
Aline : Ils sont différents, et c'est une famille.""",
    [
        tf("Nina est grande.", False, "Patrick : « Nina est petite. »"),
        qcm(
            "Qui a des lunettes ?",
            ["Nina", "Éric", "Léa", "Patrick"],
            1,
            "Léa : « Éric a des lunettes. »",
        ),
        match(
            [
                ("grand", "Éric"),
                ("petite", "Nina"),
                ("lunettes", "Éric"),
                ("aussi", "le sourire de Claire"),
            ]
        ),
        fill("Complétez :\nNina est ___.", "petite"),
        wo(["Éric", "est", "grand", "."]),
        ana("lunettes", "Éric en porte, Nina non."),
        err(
            "Nina est petit.",
            "Nina est petite.",
            "Nina = elle : petite (féminin).",
        ),
        img(
            [
                ("grand", "grand"),
                ("petit", "petit"),
                ("lunettes", "les lunettes"),
                ("cheveux", "les cheveux"),
            ]
        ),
        short("Notez deux ressemblances et deux différences entendues dans le dialogue."),
        aud(
            "Enregistrez : Éric est grand. Nina est petite. Éric a des lunettes. Elle sourit aussi."
        ),
    ],
)

S2_CE = lesson(
    "CE — Cartes « même » et « mais »",
    "CE",
    """Objectif
Lire des portraits croisés : est / a, aussi, mais.

Consigne
Lisez les cartes épinglées, puis répondez.

Support — Cartes de l'album
Carte A — Éric Uwase
Il est grand. Il a des lunettes. Il a les cheveux courts.

Carte B — Nina Uwase
Elle est petite. Elle n'a pas de lunettes. Mais elle a les mêmes yeux.

Carte C — Claire et Aline
Claire a les cheveux longs. Aline aussi. Mais Aline est plus jeune.""",
    [
        tf("Aline a les cheveux courts, comme Claire.", False, "Claire a les cheveux longs. Aline aussi."),
        qcm(
            "Quelle phrase est vraie pour Nina ?",
            [
                "Elle est grande",
                "Elle a des lunettes",
                "Elle est petite",
                "Elle habite loin",
            ],
            2,
            "Carte B : « Elle est petite. »",
        ),
        match(
            [
                ("il est", "description avec être"),
                ("il a", "description avec avoir"),
                ("aussi", "pareil"),
                ("mais", "différence"),
            ]
        ),
        fill("Complétez :\nAline aussi. ___ Aline est plus jeune.", "Mais"),
        wo(["Il", "a", "des", "lunettes", "."]),
        ana("cheveux", "Longs chez Claire, et chez Aline aussi."),
        err(
            "Il est grande.",
            "Il est grand.",
            "Il = masculin : grand, sans e.",
        ),
        img(
            [
                ("grand", "grand"),
                ("petit", "petit"),
                ("cheveux", "les cheveux"),
                ("portrait", "un portrait"),
            ]
        ),
        short("Recopiez une carte, puis écrivez deux phrases avec aussi et mais."),
        aud("Lisez les trois cartes à voix haute."),
    ],
)

S2_PO = lesson(
    "PO — Dire qui on est, qui on n'est pas",
    "PO",
    """Objectif
Décrire une personne : il / elle est, il / elle a, aussi, mais.

Consigne
Répétez, puis décrivez un camarade ou une photo.

Support — Modèles de Patrick
Il est grand.
Elle est petite.
Il est jeune.
Elle a les cheveux longs.
Il a des lunettes.
Moi aussi.
Mais je suis petit.
Nous sommes différents.""",
    [
        tf("« Moi aussi » marque une ressemblance.", True, "Aussi = pareil."),
        qcm(
            "Quel mot introduit une différence ?",
            ["aussi", "et", "mais", "voici"],
            2,
            "Mais = contraste.",
        ),
        match(
            [
                ("grand", "pas petit"),
                ("jeune", "pas âgé"),
                ("aussi", "pareil"),
                ("mais", "contraire"),
            ]
        ),
        fill("Complétez :\nElle ___ les cheveux longs.", "a"),
        wo(["Elle", "est", "petite", "."]),
        ana("aussi", "Le petit mot pour dire « pareil »."),
        err(
            "Elle a le cheveux longs.",
            "Elle a les cheveux longs.",
            "Cheveux est pluriel : les cheveux.",
        ),
        img(
            [
                ("cheveux", "les cheveux"),
                ("lunettes", "les lunettes"),
                ("sourire", "un sourire"),
                ("portrait", "un portrait"),
            ]
        ),
        short("Écrivez six phrases : deux avec est, deux avec a, une avec aussi, une avec mais."),
        aud("Enregistrez les huit phrases, puis un mini-portrait d'Éric ou de Nina."),
    ],
)

S2_PE = lesson(
    "PE — Deux colonnes sur une carte",
    "PE",
    """Objectif
Écrire un portrait croisé : ressemblances et différences.

Consigne
Imitez la carte de Patrick. Une colonne « aussi », une colonne « mais ».

Support — Carte de Patrick
Éric et Nina
Aussi : les yeux.
Mais : la taille. Éric est grand. Nina est petite.
Aussi : le sourire.
Mais : les lunettes. Éric a des lunettes. Nina n'a pas de lunettes.
Patrick""",
    [
        tf("Patrick écrit que Nina a des lunettes.", False, "« Nina n'a pas de lunettes. »"),
        qcm(
            "Qu'est-ce qui est pareil, d'après Patrick ?",
            ["La taille", "Les lunettes", "Les yeux", "L'âge"],
            2,
            "Colonne Aussi : les yeux.",
        ),
        match(
            [
                ("Aussi", "yeux, sourire"),
                ("Mais", "taille, lunettes"),
                ("grand", "Éric"),
                ("petite", "Nina"),
            ]
        ),
        fill("Complétez :\nNina n'a pas ___ lunettes.", "de"),
        wo(["Éric", "est", "grand", "."]),
        ana("taille", "Éric et Nina : ce n'est pas la même…"),
        err(
            "Nina n'a pas des lunettes.",
            "Nina n'a pas de lunettes.",
            "Négation : pas de + nom.",
        ),
        img(
            [
                ("photo", "une photo"),
                ("lunettes", "les lunettes"),
                ("sourire", "un sourire"),
                ("petit", "petit"),
            ]
        ),
        short(
            "Écrivez une carte : deux personnes, deux « aussi », deux « mais ». Signez."
        ),
        aud("Lisez votre carte, lentement, comme Patrick."),
    ],
)

S2_EL = lesson(
    "EL — Être, avoir, aussi, mais",
    "EL",
    """Objectif
Retenir il / elle est, il / elle a, et les petits mots aussi / mais.

Consigne
Étudiez la fiche, puis décrivez deux personnes.

Support — Fiche de Patrick
Il est / elle est + adjectif : grand, grande, petit, petite, jeune
Il a / elle a + les cheveux / des lunettes
aussi = pareil
mais = différence
Je suis / tu es / il est / elle est
J'ai / tu as / il a / elle a
Attention : elle est petite (avec e). Il est petit.""",
    [
        tf("On dit « elle est petit ».", False, "Féminin : petite."),
        qcm(
            "Quelle phrase est correcte ?",
            [
                "Elle est grand",
                "Elle est grande",
                "Elle sont grande",
                "Elle es grande",
            ],
            1,
            "Elle est grande.",
        ),
        match(
            [
                ("être", "il est grand"),
                ("avoir", "il a des lunettes"),
                ("aussi", "ressemblance"),
                ("mais", "différence"),
            ]
        ),
        fill("Complétez :\nElle est ___. (Nina, la taille)", "petite"),
        wo(["Je", "suis", "jeune", "."]),
        ana("grande", "Féminin de grand."),
        err(
            "Il a les lunettes.",
            "Il a des lunettes.",
            "On dit souvent des lunettes (une paire).",
        ),
        img(
            [
                ("grand", "grand"),
                ("petit", "petit"),
                ("lunettes", "les lunettes"),
                ("cheveux", "les cheveux"),
            ]
        ),
        short("Recopiez la fiche. Écrivez quatre phrases : est / a / aussi / mais."),
        aud("Dites la conjugaison de être et d'avoir au présent (je, tu, il, elle)."),
    ],
)

# ---------------------------------------------------------------------------
# Séquence 3 — Ce qu'on aime, ce qu'on n'aime pas
# aimer / adorer / ne pas aimer
# ---------------------------------------------------------------------------

S3_CO = lesson(
    "CO — Le tour des goûts, autour du thé",
    "CO",
    """Objectif
Comprendre j'aime, j'adore, je n'aime pas.

Consigne
Qui aime quoi ? Qui n'aime pas le football ?

Support — Banc près de la fontaine, tasses de thé
Hawa : J'adore le thé. Je n'aime pas le football.
Marc : Moi, j'aime le football. Mon fils Kévin aussi.
Léa : J'aime les livres. Je n'aime pas la radio trop forte.
Rose : J'adore la danse. Et le thé, moi aussi.
Aline : J'aime le jardin, le samedi. Je n'aime pas partir loin.
Joël : Moi, j'aime la moto. Mais j'aime aussi le thé, lentement.""",
    [
        tf("Hawa adore le football.", False, "Hawa : « Je n'aime pas le football. »"),
        qcm(
            "Qu'est-ce que Léa aime ?",
            ["La moto", "Les livres", "Le football", "La radio trop forte"],
            1,
            "Léa : « J'aime les livres. »",
        ),
        match(
            [
                ("Hawa", "le thé"),
                ("Marc", "le football"),
                ("Rose", "la danse"),
                ("Aline", "le jardin"),
            ]
        ),
        fill("Complétez :\nJ'___ le thé.", "adore"),
        wo(["Je", "n'aime", "pas", "le", "football", "."]),
        ana("thé", "Hawa en adore une tasse, près de la fontaine."),
        err(
            "Je n'aime pas le danse.",
            "Je n'aime pas la danse.",
            "Danse est féminin : la danse.",
        ),
        img(
            [
                ("the", "le thé"),
                ("football", "le football"),
                ("livre", "un livre"),
                ("danse", "la danse"),
            ]
        ),
        short("Listez quatre goûts entendus : j'aime / j'adore / je n'aime pas."),
        aud(
            "Enregistrez : J'adore le thé. J'aime les livres. Je n'aime pas le football. J'adore la danse."
        ),
    ],
)

S3_CE = lesson(
    "CE — Les cartes-goûts du figuier",
    "CE",
    """Objectif
Lire des cartes de goûts : aimer, adorer, ne pas aimer.

Consigne
Lisez les cartes, puis répondez.

Support — Cartes colorées
Hawa — J'adore le thé. Je n'aime pas le football.
Marc — J'aime le football et la radio.
Léa — J'aime les livres. Je n'aime pas le bruit.
Rose — J'adore la danse. J'aime le thé aussi.
Joël — J'aime la moto. Je n'aime pas rester assis.
Règle du Seuil : un « j'aime », un « je n'aime pas » par carte.""",
    [
        tf("Joël aime rester assis.", False, "« Je n'aime pas rester assis. »"),
        qcm(
            "Qui écrit deux choses aimées, sans « je n'aime pas » ?",
            ["Hawa", "Marc", "Léa", "Joël"],
            1,
            "Marc : football et radio. Pas de « je n'aime pas » sur sa carte.",
        ),
        match(
            [
                ("j'adore", "très fort"),
                ("j'aime", "c'est bien"),
                ("je n'aime pas", "non merci"),
                ("aussi", "moi de même"),
            ]
        ),
        fill("Complétez :\nJe n'aime ___ le bruit.", "pas"),
        wo(["J'aime", "les", "livres", "."]),
        ana("danse", "Rose l'adore, après le thé."),
        err(
            "J'aime pas le football.",
            "Je n'aime pas le football.",
            "Négation complète : ne… pas → je n'aime pas.",
        ),
        img(
            [
                ("the", "le thé"),
                ("musique", "la musique"),
                ("livre", "un livre"),
                ("adorer", "adorer"),
            ]
        ),
        short("Recopiez deux cartes. Ajoutez la vôtre : un j'aime et un je n'aime pas."),
        aud("Lisez les cinq cartes, puis la règle du Seuil."),
    ],
)

S3_PO = lesson(
    "PO — Dire j'aime et je n'aime pas",
    "PO",
    """Objectif
Dire ses goûts avec aimer, adorer et ne pas aimer.

Consigne
Répétez, puis parlez de vous.

Support — Modèles de Rose
J'aime le thé.
J'adore la danse.
Je n'aime pas le football.
J'aime les livres.
J'aime la musique.
Je n'aime pas le bruit.
Moi aussi.
Mais moi, j'aime la moto.""",
    [
        tf("« J'adore » est plus fort que « j'aime ».", True, "Adorer = aimer beaucoup."),
        qcm(
            "Quelle phrase est une négation ?",
            [
                "J'aime le thé",
                "J'adore la danse",
                "Je n'aime pas le bruit",
                "Moi aussi",
            ],
            2,
            "Ne… pas = négation.",
        ),
        match(
            [
                ("j'aime", "positif"),
                ("j'adore", "très positif"),
                ("je n'aime pas", "négatif"),
                ("mais moi", "contraste"),
            ]
        ),
        fill("Complétez :\nJ'___ la danse.", "adore"),
        wo(["J'aime", "la", "musique", "."]),
        ana("adore", "Plus fort que j'aime."),
        err(
            "J'aime le musique.",
            "J'aime la musique.",
            "Musique est féminin : la musique.",
        ),
        img(
            [
                ("danse", "la danse"),
                ("musique", "la musique"),
                ("football", "le football"),
                ("the", "le thé"),
            ]
        ),
        short("Écrivez six phrases de goûts : deux j'aime, deux j'adore, deux je n'aime pas."),
        aud("Enregistrez les huit modèles, puis vos goûts."),
    ],
)

S3_PE = lesson(
    "PE — Ma carte-goût",
    "PE",
    """Objectif
Écrire une carte de goûts claire, comme à l'album.

Consigne
Imitez la carte de Rose. Respectez la règle : un j'aime, un j'adore, un je n'aime pas.

Support — Carte de Rose
Je m'appelle Rose Iradukunda.
J'adore la danse.
J'aime le thé.
Je n'aime pas rester assise.
Et vous ?
Rose
Seuil des Sources""",
    [
        tf("Rose pose une question à la fin.", True, "« Et vous ? »"),
        qcm(
            "Que n'aime pas Rose ?",
            ["La danse", "Le thé", "Rester assise", "Le Seuil"],
            2,
            "« Je n'aime pas rester assise. »",
        ),
        match(
            [
                ("J'adore", "la danse"),
                ("J'aime", "le thé"),
                ("Je n'aime pas", "rester assise"),
                ("Et vous ?", "question"),
            ]
        ),
        fill("Complétez :\nJe n'aime pas rester ___.", "assise"),
        wo(["J'adore", "la", "danse", "."]),
        ana("assise", "Rose n'aime pas rester… (féminin)."),
        err(
            "Je n'aime pas rester assis.",
            "Je n'aime pas rester assise.",
            "Rose = elle : assise.",
        ),
        img(
            [
                ("danse", "la danse"),
                ("the", "le thé"),
                ("adorer", "adorer"),
                ("photo", "une photo"),
            ]
        ),
        short(
            "Écrivez votre carte : je m'appelle, j'adore, j'aime, je n'aime pas, et vous ?"
        ),
        aud("Lisez votre carte, puis posez la question « Et vous ? »"),
    ],
)

S3_EL = lesson(
    "EL — Aimer et ne pas aimer",
    "EL",
    """Objectif
Retenir aimer / adorer / ne pas aimer + un nom.

Consigne
Apprenez la fiche du Seuil.

Support — Fiche de Rose
j'aime + le / la / les + nom
j'adore + le / la + nom
je n'aime pas + le / la + nom
j'aime le thé / la danse / les livres
j'aime / tu aimes / il aime / elle aime
nous aimons / vous aimez / ils aiment
Attention : je n'aime pas (avec n').
On ne dit pas « j'aime pas » à l'écrit, ici.""",
    [
        tf("« J'aime pas » est la forme de la fiche.", False, "La fiche demande : je n'aime pas."),
        qcm(
            "Quelle conjugaison est correcte ?",
            ["tu aime", "tu aimes", "tu aimer", "tu aimes-tu"],
            1,
            "Tu aimes.",
        ),
        match(
            [
                ("j'aime", "je"),
                ("tu aimes", "tu"),
                ("nous aimons", "nous"),
                ("ils aiment", "ils"),
            ]
        ),
        fill("Complétez :\nTu ___ le thé ?", "aimes"),
        wo(["Nous", "aimons", "la", "danse", "."]),
        ana("aimons", "Nous… (verbe aimer)."),
        err(
            "Elle aimes la musique.",
            "Elle aime la musique.",
            "Il / elle aime (sans s).",
        ),
        img(
            [
                ("the", "le thé"),
                ("livre", "un livre"),
                ("musique", "la musique"),
                ("football", "le football"),
            ]
        ),
        short("Conjuguez aimer. Écrivez trois phrases : j'aime / j'adore / je n'aime pas."),
        aud("Dites la conjugaison d'aimer, puis trois goûts personnels."),
    ],
)

# ---------------------------------------------------------------------------
# Séquence 4 — Se raconter en quelques mots
# je m'appelle, j'ai … ans, j'habite, je suis
# ---------------------------------------------------------------------------

S4_CO = lesson(
    "CO — Quatre voix, quatre portraits",
    "CO",
    """Objectif
Comprendre un mini-portrait : je m'appelle, j'ai … ans, j'habite, je suis.

Consigne
Qui habite au Seuil ? Qui est chauffeur ? Qui a quel âge ?

Support — Tour de parole sous le figuier
Léa : Je m'appelle Léa Niyonzima. J'ai vingt-six ans. J'habite au Seuil. Je suis nouvelle.
Marc : Je m'appelle Marc. J'ai quarante ans. Je suis chauffeur. J'habite Rukiri-Nord.
Patrick : Je m'appelle Patrick Habimana. J'ai trente ans. Je suis guide. J'habite près du marché.
Aline : Je m'appelle Aline Uwase. J'ai trente-deux ans. J'habite près de la cour. Je suis à l'accueil du Seuil.""",
    [
        tf("Léa habite au Seuil.", True, "Léa : « J'habite au Seuil. »"),
        qcm(
            "Quel âge a Patrick ?",
            ["Vingt-six ans", "Trente ans", "Trente-deux ans", "Quarante ans"],
            1,
            "Patrick : « J'ai trente ans. »",
        ),
        match(
            [
                ("Léa", "nouvelle"),
                ("Marc", "chauffeur"),
                ("Patrick", "guide"),
                ("Aline", "accueil"),
            ]
        ),
        fill("Complétez :\nJ'___ trente ans.", "ai"),
        wo(["Je", "suis", "guide", "."]),
        ana("habite", "Le verbe pour dire où on vit."),
        err(
            "J'ai trente an.",
            "J'ai trente ans.",
            "Ans, au pluriel, après un nombre.",
        ),
        img(
            [
                ("portrait", "un portrait"),
                ("maison", "la maison"),
                ("photo", "une photo"),
                ("famille", "la famille"),
            ]
        ),
        short("Notez pour chaque voix : prénom, âge, lieu, rôle."),
        aud(
            "Enregistrez : Je m'appelle… J'ai … ans. J'habite… Je suis…"
        ),
    ],
)

S4_CE = lesson(
    "CE — Fiches portrait du tissu",
    "CE",
    """Objectif
Lire des mini-portraits écrits.

Consigne
Lisez les quatre fiches, puis répondez.

Support — Fiches crème
Léa Niyonzima — 26 ans — habite au Seuil — est nouvelle
Marc Nkurunziza — 40 ans — habite Rukiri-Nord — est chauffeur
Patrick Habimana — 30 ans — habite près du marché — est guide
Aline Uwase — 32 ans — habite près de la cour — est à l'accueil
Consigne de l'album : quatre lignes, pas plus.""",
    [
        tf("Aline habite loin de la cour.", False, "Fiche : « habite près de la cour »."),
        qcm(
            "Qui a quarante ans ?",
            ["Léa", "Marc", "Patrick", "Aline"],
            1,
            "Marc Nkurunziza — 40 ans.",
        ),
        match(
            [
                ("26 ans", "Léa"),
                ("30 ans", "Patrick"),
                ("32 ans", "Aline"),
                ("40 ans", "Marc"),
            ]
        ),
        fill("Complétez :\nPatrick est ___.", "guide"),
        wo(["J'habite", "au", "Seuil", "."]),
        ana("nouvelle", "Léa l'est encore, au Seuil."),
        err(
            "Je suis nouveau.",
            "Je suis nouvelle.",
            "Léa = féminin : nouvelle.",
        ),
        img(
            [
                ("portrait", "un portrait"),
                ("maison", "la maison"),
                ("photo", "une photo"),
                ("famille", "la famille"),
            ]
        ),
        short("Recopiez une fiche en phrases complètes : je m'appelle / j'ai / j'habite / je suis."),
        aud("Lisez les quatre fiches, sans aller trop vite."),
    ],
)

S4_PO = lesson(
    "PO — Se dire en quatre phrases",
    "PO",
    """Objectif
Se présenter en quatre phrases stables.

Consigne
Répétez le cadre, puis remplissez avec votre vie (ou une vie inventée).

Support — Cadre d'Aline
Je m'appelle …
J'ai … ans.
J'habite …
Je suis …
Enchanté / Enchantée.
Voilà, c'est moi.""",
    [
        tf("On peut dire « Enchantée » au féminin.", True, "Accord : enchanté / enchantée."),
        qcm(
            "Quelle phrase dit l'âge ?",
            ["Je m'appelle Aline", "J'ai trente-deux ans", "J'habite près de la cour", "Je suis à l'accueil"],
            1,
            "J'ai + nombre + ans.",
        ),
        match(
            [
                ("je m'appelle", "nom"),
                ("j'ai … ans", "âge"),
                ("j'habite", "lieu"),
                ("je suis", "rôle"),
            ]
        ),
        fill("Complétez :\nJe m'___.", "appelle"),
        wo(["Voici", "mon", "portrait", "."]),
        ana("appelle", "Je m'… + prénom."),
        err(
            "J'habite à le Seuil.",
            "J'habite au Seuil.",
            "À + le → au.",
        ),
        img(
            [
                ("portrait", "un portrait"),
                ("maison", "la maison"),
                ("photo", "une photo"),
                ("sourire", "un sourire"),
            ]
        ),
        short("Écrivez votre cadre en six lignes, y compris Enchanté(e) et Voilà, c'est moi."),
        aud("Enregistrez votre portrait en quatre phrases, puis « Voilà, c'est moi. »"),
    ],
)

S4_PE = lesson(
    "PE — Ma fiche de l'album",
    "PE",
    """Objectif
Écrire un mini-portrait de quatre phrases.

Consigne
Imitez la fiche de Joël. Restez à quatre phrases + signature.

Support — Fiche de Joël
Je m'appelle Joël Mugisha.
J'ai vingt-neuf ans.
J'habite Rukiri-Nord.
Je suis sur la route, avec la moto.
Joël
Album du Seuil""",
    [
        tf("Joël a vingt-neuf ans.", True, "Deuxième phrase de la fiche."),
        qcm(
            "Que fait Joël ?",
            ["Il est à l'accueil", "Il est sur la route, avec la moto", "Il est guide du marché", "Il est nouveau au Seuil"],
            1,
            "« Je suis sur la route, avec la moto. »",
        ),
        match(
            [
                ("Je m'appelle", "Joël Mugisha"),
                ("J'ai", "vingt-neuf ans"),
                ("J'habite", "Rukiri-Nord"),
                ("Je suis", "sur la route"),
            ]
        ),
        fill("Complétez :\nJ'ai vingt-neuf ___.", "ans"),
        wo(["J'habite", "Rukiri-Nord", "."]),
        ana("vingt", "Le début du nombre 29."),
        err(
            "J'ai vingt-neuf an.",
            "J'ai vingt-neuf ans.",
            "Ans au pluriel.",
        ),
        img(
            [
                ("portrait", "un portrait"),
                ("photo", "une photo"),
                ("maison", "la maison"),
                ("sourire", "un sourire"),
            ]
        ),
        short("Écrivez votre fiche : quatre phrases, une signature, le mot Album du Seuil."),
        aud("Lisez votre fiche comme pour l'album."),
    ],
)

S4_EL = lesson(
    "EL — Le cadre du portrait",
    "EL",
    """Objectif
Retenir le cadre : s'appeler, avoir + âge, habiter, être.

Consigne
Apprenez, puis racontez-vous.

Support — Fiche d'Aline
Je m'appelle + prénom
J'ai + nombre + ans
J'habite + lieu (à / au / près de)
Je suis + rôle
Enchanté (homme) / Enchantée (femme)
avoir : j'ai, tu as, il a, elle a
être : je suis, tu es, il est, elle est
Attention : j'ai trente ans (pas « j'ai trente an »).""",
    [
        tf("On écrit « j'ai trente an ».", False, "Ans, au pluriel."),
        qcm(
            "Quelle forme est correcte ?",
            ["Je habite", "J'habite", "J'habit", "Je habites"],
            1,
            "J'habite (élision).",
        ),
        match(
            [
                ("s'appeler", "le nom"),
                ("avoir", "l'âge"),
                ("habiter", "le lieu"),
                ("être", "le rôle"),
            ]
        ),
        fill("Complétez :\nJe ___ nouvelle.", "suis"),
        wo(["Je", "suis", "chauffeur", "."]),
        ana("habite", "Le verbe du lieu de vie."),
        err(
            "Je m'appelle est Léa.",
            "Je m'appelle Léa.",
            "Pas de « est » après je m'appelle.",
        ),
        img(
            [
                ("portrait", "un portrait"),
                ("photo", "une photo"),
                ("maison", "la maison"),
                ("famille", "la famille"),
            ]
        ),
        short("Recopiez la fiche. Écrivez votre portrait en quatre phrases."),
        aud("Dites le cadre, puis votre portrait."),
    ],
)

# ---------------------------------------------------------------------------
# Séquence 5 — Temps libre
# le week-end ; jouer à ; écouter ; lire ; danser
# ---------------------------------------------------------------------------

S5_CO = lesson(
    "CO — Le samedi au Seuil",
    "CO",
    """Objectif
Comprendre des activités de temps libre : le samedi, jouer à, écouter, lire, danser.

Consigne
Qui fait quoi le week-end ?

Support — Fin d'après-midi, craie à la main
Marc : Le samedi, je joue au football avec Kévin.
Léa : Le dimanche, je lis un livre sous le figuier.
Rose : Le samedi soir, je danse. Pas trop tard.
Hawa : J'écoute la radio, et je bois du thé.
Patrick : Le dimanche, je marche au jardin. Pas de guide, juste moi.
Aline : Moi, je jardine près de la cour. C'est calme.""",
    [
        tf("Patrick est guide le dimanche, au jardin.", False, "« Pas de guide, juste moi. »"),
        qcm(
            "Que fait Léa le dimanche ?",
            ["Elle joue au football", "Elle lit un livre", "Elle danse", "Elle jardine"],
            1,
            "Léa : « je lis un livre sous le figuier. »",
        ),
        match(
            [
                ("Marc", "football"),
                ("Rose", "danse"),
                ("Hawa", "radio et thé"),
                ("Aline", "jardin"),
            ]
        ),
        fill("Complétez :\nJe joue ___ football.", "au"),
        wo(["Je", "lis", "un", "livre", "."]),
        ana("samedi", "Jour où Marc joue avec Kévin."),
        err(
            "Je joue à le football.",
            "Je joue au football.",
            "Jouer à + le → au football.",
        ),
        img(
            [
                ("football", "le football"),
                ("livre", "un livre"),
                ("danse", "la danse"),
                ("jardin", "le jardin"),
            ]
        ),
        short("Notez six activités et le jour (samedi ou dimanche)."),
        aud(
            "Enregistrez : Le samedi, je joue au football. Le dimanche, je lis un livre. J'écoute la radio."
        ),
    ],
)

S5_CE = lesson(
    "CE — Le tableau des samedis",
    "CE",
    """Objectif
Lire un tableau d'activités de week-end.

Consigne
Lisez le tableau à la craie.

Support — Tableau Figuier
Temps libre — Seuil des Sources
Samedi
Marc + Kévin — jouer au football
Rose — danser
Aline — jardiner
Hawa — écouter la radio
Dimanche
Léa — lire
Patrick — marcher au jardin
Joël — se reposer (parfois la moto)
Rien d'obligatoire. C'est le temps libre.""",
    [
        tf("Joël joue au football le dimanche.", False, "Joël : se reposer (parfois la moto)."),
        qcm(
            "Qui jardine le samedi ?",
            ["Léa", "Aline", "Patrick", "Rose"],
            1,
            "Samedi — Aline — jardiner.",
        ),
        match(
            [
                ("jouer", "football"),
                ("danser", "Rose"),
                ("lire", "Léa"),
                ("marcher", "Patrick"),
            ]
        ),
        fill("Complétez :\nLe dimanche, Léa ___.", "lit"),
        wo(["C'est", "le", "temps", "libre", "."]),
        ana("jardiner", "L'activité d'Aline, près de la cour."),
        err(
            "Je joue au danse.",
            "Je danse.",
            "On danse (verbe). On ne dit pas « jouer au danse ».",
        ),
        img(
            [
                ("ballon", "un ballon"),
                ("radio", "la radio"),
                ("jardin", "le jardin"),
                ("livre", "un livre"),
            ]
        ),
        short("Recopiez le tableau. Ajoutez votre ligne : jour + verbe."),
        aud("Lisez le tableau, samedi d'abord, puis dimanche."),
    ],
)

S5_PO = lesson(
    "PO — Dire son week-end",
    "PO",
    """Objectif
Parler de son temps libre avec le samedi / le dimanche + un verbe.

Consigne
Répétez, puis dites votre week-end.

Support — Modèles de Marc
Le samedi, je joue au football.
Le dimanche, je me repose.
J'écoute la radio.
Je lis un livre.
Je danse.
Je jardine.
Je marche.
J'aime ce temps libre.""",
    [
        tf("« Je me repose » est une activité de temps libre.", True, "Repos = temps libre aussi."),
        qcm(
            "Quelle phrase dit le jour ?",
            ["J'écoute la radio", "Le samedi, je joue au football", "J'aime ce temps libre", "Je marche"],
            1,
            "Le samedi = jour.",
        ),
        match(
            [
                ("jouer au", "football"),
                ("écouter", "la radio"),
                ("lire", "un livre"),
                ("danser", "le samedi soir"),
            ]
        ),
        fill("Complétez :\nLe dimanche, je me ___.", "repose"),
        wo(["J'écoute", "la", "radio", "."]),
        ana("repose", "Je me… le dimanche, parfois."),
        err(
            "Le samedi je joue à football.",
            "Le samedi je joue au football.",
            "Jouer au football.",
        ),
        img(
            [
                ("football", "le football"),
                ("radio", "la radio"),
                ("danse", "la danse"),
                ("jardin", "le jardin"),
            ]
        ),
        short("Écrivez six phrases : trois pour samedi, trois pour dimanche."),
        aud("Enregistrez les huit modèles, puis votre week-end."),
    ],
)

S5_PE = lesson(
    "PE — Mon samedi en cinq lignes",
    "PE",
    """Objectif
Écrire un petit texte de temps libre.

Consigne
Imitez le mot de Kévin (écrit avec Marc).

Support — Mot de Kévin
Bonjour,
Le samedi, je joue au football avec mon père.
Après, j'écoute la radio.
Le dimanche, je me repose.
J'aime ce temps libre.
Kévin
8 ans""",
    [
        tf("Kévin joue le dimanche.", False, "Il joue le samedi. Le dimanche, il se repose."),
        qcm(
            "Avec qui Kévin joue-t-il ?",
            ["Aline", "Son père", "Rose", "Léa"],
            1,
            "« avec mon père ».",
        ),
        match(
            [
                ("samedi", "football puis radio"),
                ("dimanche", "repos"),
                ("j'aime", "ce temps libre"),
                ("8 ans", "Kévin"),
            ]
        ),
        fill("Complétez :\nJe joue au football avec ___ père.", "mon"),
        wo(["J'aime", "ce", "temps", "libre", "."]),
        ana("libre", "Le temps… du week-end, pas l'école."),
        err(
            "Le samedi je joue au football avec ma père.",
            "Le samedi je joue au football avec mon père.",
            "Père est masculin : mon père.",
        ),
        img(
            [
                ("ballon", "un ballon"),
                ("radio", "la radio"),
                ("enfant", "un enfant"),
                ("football", "le football"),
            ]
        ),
        short("Écrivez cinq lignes : bonjour, samedi, après, dimanche, j'aime…"),
        aud("Lisez votre mot, simplement, comme Kévin."),
    ],
)

S5_EL = lesson(
    "EL — Verbes du temps libre",
    "EL",
    """Objectif
Retenir les verbes de week-end et jouer à / au.

Consigne
Étudiez la fiche.

Support — Fiche de Marc
le samedi / le dimanche
je joue au football
j'écoute la radio
je lis un livre
je danse
je jardine
je marche
je me repose
jouer à + le → au
Attention : je lis (pas « je lise » au présent).
J'aime ce temps libre.""",
    [
        tf("On dit « je lise un livre » au présent.", False, "Présent : je lis."),
        qcm(
            "Quelle forme est correcte ?",
            ["je joue à le football", "je joue au football", "je joue de football", "je joue football"],
            1,
            "Jouer au football.",
        ),
        match(
            [
                ("jouer", "ballon"),
                ("écouter", "radio"),
                ("lire", "livre"),
                ("se reposer", "calme"),
            ]
        ),
        fill("Complétez :\nJe ___ un livre.", "lis"),
        wo(["Je", "me", "repose", "."]),
        ana("écoute", "J'… la radio."),
        err(
            "Je lise un livre le dimanche.",
            "Je lis un livre le dimanche.",
            "Présent de lire : je lis.",
        ),
        img(
            [
                ("livre", "un livre"),
                ("radio", "la radio"),
                ("ballon", "un ballon"),
                ("jardin", "le jardin"),
            ]
        ),
        short("Recopiez la fiche. Écrivez votre week-end en quatre phrases."),
        aud("Dites tous les verbes de la fiche, puis deux phrases au samedi."),
    ],
)

# ---------------------------------------------------------------------------
# Séquence 6 — Quand le corps parle
# tête, main, pied, dos ; j'ai mal à ; fatigué / content
# ---------------------------------------------------------------------------

S6_CO = lesson(
    "CO — Après la route, Joël s'assoit",
    "CO",
    """Objectif
Comprendre le corps et les sensations : j'ai mal à, je suis fatigué, je suis content.

Consigne
Où Joël a-t-il mal ? Comment se sent Rose ?

Support — Banc sous le figuier, casque posé
Joël : Ah… j'ai mal au dos. La route est longue.
Léa : Tu es fatigué ?
Joël : Oui. J'ai aussi mal à la tête. Mais je suis content : tout le monde est arrivé.
Rose : Moi, j'ai mal au pied. J'ai trop dansé.
Aline : Prenez le thé. Après, la main est calme, la tête aussi.
Hawa : Je suis fatiguée, mais je souris.""",
    [
        tf("Joël a mal au pied.", False, "Joël a mal au dos et à la tête. Rose a mal au pied."),
        qcm(
            "Pourquoi Rose a-t-elle mal au pied ?",
            ["Elle a marché au pont", "Elle a trop dansé", "Elle a joué au football", "Elle a jardiné"],
            1,
            "Rose : « J'ai trop dansé. »",
        ),
        match(
            [
                ("dos", "Joël"),
                ("tête", "Joël aussi"),
                ("pied", "Rose"),
                ("sourire", "Hawa"),
            ]
        ),
        fill("Complétez :\nJ'ai mal ___ dos.", "au"),
        wo(["Je", "suis", "fatigué", "."]),
        ana("dos", "Joël y a mal, après la moto."),
        err(
            "J'ai mal à le dos.",
            "J'ai mal au dos.",
            "À + le → au.",
        ),
        img(
            [
                ("dos", "le dos"),
                ("tete", "la tête"),
                ("pied", "le pied"),
                ("fatigue", "fatigué"),
            ]
        ),
        short("Notez qui a mal où, et qui est fatigué / content."),
        aud(
            "Enregistrez : J'ai mal au dos. J'ai mal à la tête. Je suis fatigué. Mais je suis content."
        ),
    ],
)

S6_CE = lesson(
    "CE — Billets « mal » et « mieux »",
    "CE",
    """Objectif
Lire de courtes notes sur le corps.

Consigne
Lisez les billets épinglés près du thé.

Support — Billets
Joël — J'ai mal au dos et à la tête. Je suis fatigué. Mais je suis content.
Rose — J'ai mal au pied. La danse, c'est trop ! Demain, ça va.
Hawa — Je suis fatiguée. J'ai mal à la main (beaucoup de cartes). Je souris.
Aline — Thé sucré pour la tête. La main tient la tasse. Tout va bien.
Conseil du Seuil : dire où ça fait mal, simplement.""",
    [
        tf("Hawa a mal à la main.", True, "Billet d'Hawa : « J'ai mal à la main. »"),
        qcm(
            "Que propose Aline pour la tête ?",
            ["Un ballon", "Un thé sucré", "La moto", "Le football"],
            1,
            "« Thé sucré pour la tête. »",
        ),
        match(
            [
                ("mal au dos", "Joël"),
                ("mal au pied", "Rose"),
                ("mal à la main", "Hawa"),
                ("thé sucré", "Aline"),
            ]
        ),
        fill("Complétez :\nJ'ai mal ___ la tête.", "à"),
        wo(["Je", "suis", "content", "."]),
        ana("main", "Hawa y a mal, à force de cartes."),
        err(
            "Je suis fatigué.",
            "Je suis fatiguée.",
            "Hawa parle : féminin, fatiguée.",
        ),
        img(
            [
                ("main", "la main"),
                ("tete", "la tête"),
                ("pied", "le pied"),
                ("sourire", "un sourire"),
            ]
        ),
        short("Recopiez deux billets. Ajoutez le vôtre : j'ai mal à… / je suis…"),
        aud("Lisez les quatre billets, puis le conseil du Seuil."),
    ],
)

S6_PO = lesson(
    "PO — Dire j'ai mal, je suis…",
    "PO",
    """Objectif
Dire une douleur et un sentiment simples.

Consigne
Répétez, puis parlez de vous (vrai ou inventé).

Support — Modèles d'Aline
J'ai mal à la tête.
J'ai mal au dos.
J'ai mal au pied.
J'ai mal à la main.
Je suis fatigué.
Je suis fatiguée.
Je suis content.
Je suis contente.
Je souris.""",
    [
        tf("« Je suis contente » est au féminin.", True, "Contente = elle."),
        qcm(
            "Quelle phrase parle d'un sentiment, pas d'un lieu du corps ?",
            [
                "J'ai mal à la tête",
                "J'ai mal au dos",
                "Je suis content",
                "J'ai mal à la main",
            ],
            2,
            "Content = sentiment.",
        ),
        match(
            [
                ("la tête", "à la tête"),
                ("le dos", "au dos"),
                ("le pied", "au pied"),
                ("la main", "à la main"),
            ]
        ),
        fill("Complétez :\nJ'ai mal ___ pied.", "au"),
        wo(["Je", "souris", "."]),
        ana("mal", "J'ai … à la tête."),
        err(
            "J'ai mal à le pied.",
            "J'ai mal au pied.",
            "À + le → au.",
        ),
        img(
            [
                ("tete", "la tête"),
                ("dos", "le dos"),
                ("main", "la main"),
                ("sourire", "un sourire"),
            ]
        ),
        short("Écrivez six phrases : quatre « j'ai mal à/au », deux « je suis… »."),
        aud("Enregistrez les modèles, puis deux phrases sur vous."),
    ],
)

S6_PE = lesson(
    "PE — Un billet pour Aline",
    "PE",
    """Objectif
Écrire un court billet sur le corps et l'état.

Consigne
Imitez le billet de Joël.

Support — Billet de Joël
Aline,
Aujourd'hui, j'ai mal au dos.
J'ai aussi mal à la tête.
Je suis fatigué, mais je suis content.
Merci pour le thé.
Joël""",
    [
        tf("Joël remercie pour le thé.", True, "Dernière phrase avant la signature."),
        qcm(
            "Combien de « j'ai mal » Joël écrit-il ?",
            ["Un", "Deux", "Trois", "Zéro"],
            1,
            "Dos et tête : deux.",
        ),
        match(
            [
                ("dos", "première douleur"),
                ("tête", "deuxième douleur"),
                ("fatigué", "état"),
                ("content", "mais…"),
            ]
        ),
        fill("Complétez :\nJe suis fatigué, ___ je suis content.", "mais"),
        wo(["Merci", "pour", "le", "thé", "."]),
        ana("content", "Joël l'est, malgré le dos."),
        err(
            "Je suis fatigué mais je suis contente.",
            "Je suis fatigué mais je suis content.",
            "Joël = il : content.",
        ),
        img(
            [
                ("dos", "le dos"),
                ("tete", "la tête"),
                ("the", "le thé"),
                ("fatigue", "fatigué"),
            ]
        ),
        short(
            "Écrivez un billet de six lignes : prénom, deux douleurs, un état, mais, merci."
        ),
        aud("Lisez votre billet, calmement."),
    ],
)

S6_EL = lesson(
    "EL — Mal à, mal au, je suis",
    "EL",
    """Objectif
Retenir le corps et j'ai mal à / au, je suis + adjectif.

Consigne
Apprenez la fiche, puis dites comment vous allez.

Support — Fiche d'Aline
la tête → j'ai mal à la tête
la main → j'ai mal à la main
le dos → j'ai mal au dos
le pied → j'ai mal au pied
je suis fatigué / fatiguée
je suis content / contente
je souris
à + la → à la
à + le → au
Attention : j'ai mal (pas « je suis mal » pour une partie du corps).""",
    [
        tf("On dit « je suis mal à la tête ».", False, "On dit j'ai mal à la tête."),
        qcm(
            "Quelle phrase est correcte ?",
            [
                "J'ai mal à le dos",
                "J'ai mal au dos",
                "J'ai mal de dos",
                "Je suis mal au dos",
            ],
            1,
            "J'ai mal au dos.",
        ),
        match(
            [
                ("tête", "à la"),
                ("main", "à la"),
                ("dos", "au"),
                ("pied", "au"),
            ]
        ),
        fill("Complétez :\nJ'ai mal ___ la main.", "à"),
        wo(["Je", "suis", "contente", "."]),
        ana("tête", "On y a souvent mal, après la route."),
        err(
            "J'ai mal à dos.",
            "J'ai mal au dos.",
            "Au dos (à + le).",
        ),
        img(
            [
                ("tete", "la tête"),
                ("main", "la main"),
                ("dos", "le dos"),
                ("pied", "le pied"),
            ]
        ),
        short("Recopiez la fiche. Écrivez quatre phrases : deux douleurs, fatigué(e), content(e)."),
        aud("Dites : à la tête, à la main, au dos, au pied, je suis fatigué, je suis content."),
    ],
)

SEQUENCES = [
    {"title": "En famille", "lessons": [S1_CO, S1_CE, S1_PO, S1_PE, S1_EL]},
    {
        "title": "Se ressembler, se distinguer",
        "lessons": [S2_CO, S2_CE, S2_PO, S2_PE, S2_EL],
    },
    {
        "title": "Ce qu'on aime, ce qu'on n'aime pas",
        "lessons": [S3_CO, S3_CE, S3_PO, S3_PE, S3_EL],
    },
    {
        "title": "Se raconter en quelques mots",
        "lessons": [S4_CO, S4_CE, S4_PO, S4_PE, S4_EL],
    },
    {"title": "Temps libre", "lessons": [S5_CO, S5_CE, S5_PO, S5_PE, S5_EL]},
    {"title": "Quand le corps parle", "lessons": [S6_CO, S6_CE, S6_PO, S6_PE, S6_EL]},
]
