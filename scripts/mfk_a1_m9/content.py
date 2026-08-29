"""MFK A1 Module 9 — Retour sur le chemin parcouru (Seuil des Sources)."""

from __future__ import annotations

IMG = "/elearning/mfk-a1-m9/{name}.svg"


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
    "title": "A1 — Retour sur le chemin parcouru",
    "description": (
        "Grande étape 9 : relire le chemin A1 au Seuil des Sources — se présenter "
        "à nouveau, dire ce qu'on a appris, ce qu'on sait faire, ce qui a changé, "
        "la suite au futur, et laisser une page dans le Cahier du chemin "
        "(Rukiri-Nord)."
    ),
}

# ---------------------------------------------------------------------------
# Séquence 1 — Premiers pas
# se présenter à nouveau : je m'appelle, je suis, j'habite
# ---------------------------------------------------------------------------

S1_CO = lesson(
    "CO — On se dit bonjour, encore",
    "CO",
    """Objectif
Reconnaître une présentation : je m'appelle, je suis, j'habite.

Consigne
Lisez le dialogue (à écouter avec l'enseignant). Qui est qui, au Seuil ?

Support — Cahier du chemin, banc du figuier
Patrick : On ouvre le cahier. Léa, tu te présentes ?
Léa : Je m'appelle Léa Niyonzima. J'habite à Rukiri-Nord. Je suis apprenante.
Noura : Moi, je m'appelle Noura Sarr. Je suis de passage. J'habite près du Port de la Brise.
Joël : Je m'appelle Joël. Je suis au Seuil tous les jours. C'est ma cour.
Aline : Bonjour. Je m'appelle Aline. Je suis formatrice. Bienvenue, encore.
Marc : Moi, c'est Marc. J'ai vingt-deux ans.""",
    [
        tf("Léa habite à Rukiri-Nord.", True, "Léa : « J'habite à Rukiri-Nord. »"),
        qcm(
            "Qui est formatrice ?",
            ["Léa", "Noura", "Aline", "Joël"],
            2,
            "Aline : « Je suis formatrice. »",
        ),
        match(
            [
                ("Léa", "apprenante"),
                ("Noura", "de passage"),
                ("Joël", "tous les jours"),
                ("Aline", "formatrice"),
            ]
        ),
        fill("Complétez :\nJe m'___ Léa.", "appelle"),
        wo(["J'habite", "à", "Rukiri-Nord", "."]),
        ana("bonjour", "Le premier mot, pour saluer."),
        err(
            "Je m'appelle Léa. Je habite à Rukiri-Nord.",
            "Je m'appelle Léa. J'habite à Rukiri-Nord.",
            "J'habite (élision).",
        ),
        img(
            [
                ("portrait", "un portrait"),
                ("groupe", "le groupe"),
                ("figuier", "le figuier"),
                ("cahier", "un cahier"),
            ]
        ),
        short("Notez trois présentations : nom, lieu, rôle."),
        aud(
            "Enregistrez : Bonjour. Je m'appelle… J'habite à… Je suis apprenant / apprenante. C'est le Seuil."
        ),
    ],
)

S1_CE = lesson(
    "CE — Page d'accueil du cahier",
    "CE",
    """Objectif
Lire des cartes d'identité inventées du Seuil.

Consigne
Lisez les cartes.

Support — Cahier du chemin
Léa Niyonzima — j'habite à Rukiri-Nord — je suis apprenante
Marc Nkurunziza — j'ai vingt-deux ans — je suis au Seuil
Noura Sarr — j'habite près du port — je suis de passage
Aline Uwase — je suis formatrice — bienvenue
Joël Mugisha — c'est ma cour — tous les jours
Règle : une phrase avec je m'appelle, une avec j'habite ou je suis.""",
    [
        tf("Marc a vingt-deux ans.", True, "Carte Marc : vingt-deux ans."),
        qcm(
            "Où habite Noura ?",
            ["À Mwezi-Haut", "Près du port", "Sous le minibus", "À l'infirmerie"],
            1,
            "« près du port ».",
        ),
        match(
            [
                ("Léa", "Rukiri-Nord"),
                ("Marc", "vingt-deux ans"),
                ("Noura", "port"),
                ("Joël", "sa cour"),
            ]
        ),
        fill("Complétez :\nJe ___ formatrice.", "suis"),
        wo(["C'est", "ma", "cour", "."]),
        ana("habite", "Le verbe pour dire où on vit, avec je : j'…"),
        err(
            "Je suis apprenante. J'ai vingt-deux an.",
            "Je suis apprenante. J'ai vingt-deux ans.",
            "Ans au pluriel.",
        ),
        img(
            [
                ("page", "une page"),
                ("portrait", "un portrait"),
                ("pierre", "une pierre"),
                ("chemin", "un chemin"),
            ]
        ),
        short("Recopiez deux cartes. Ajoutez la vôtre : je m'appelle, j'habite, je suis."),
        aud("Lisez les cinq cartes, sans aller trop vite."),
    ],
)

S1_PO = lesson(
    "PO — Se présenter encore",
    "PO",
    """Objectif
Se présenter clairement : je m'appelle, j'habite, je suis, j'ai … ans.

Consigne
Répétez, puis présentez-vous (vrai ou inventé).

Support — Modèles de Léa
Bonjour.
Je m'appelle Léa.
J'habite à Rukiri-Nord.
Je suis apprenante.
J'ai vingt et un ans.
C'est le Seuil des Sources.
Enchantée.
Au revoir.""",
    [
        tf("« Enchantée » s'accorde au féminin.", True, "Léa = elle : enchantée."),
        qcm(
            "Quelle phrase dit le lieu ?",
            ["Je m'appelle Léa", "J'habite à Rukiri-Nord", "J'ai vingt et un ans", "Enchantée"],
            1,
            "J'habite à…",
        ),
        match(
            [
                ("je m'appelle", "nom"),
                ("j'habite", "lieu"),
                ("je suis", "rôle"),
                ("j'ai", "âge"),
            ]
        ),
        fill("Complétez :\nJ'ai vingt et un ___.", "ans"),
        wo(["Je", "m'appelle", "Léa", "."]),
        ana("appelle", "Je m'… : pour dire son nom."),
        err(
            "Je suis enchanté.",
            "Je suis enchantée.",
            "Léa = elle : enchantée.",
        ),
        img(
            [
                ("groupe", "le groupe"),
                ("portrait", "un portrait"),
                ("merci", "merci"),
                ("adieu", "au revoir"),
            ]
        ),
        short("Écrivez six phrases de présentation."),
        aud("Enregistrez les huit modèles, puis votre présentation."),
    ],
)

S1_PE = lesson(
    "PE — Ma carte du cahier",
    "PE",
    """Objectif
Écrire une carte de présentation.

Consigne
Imitez la carte de Noura.

Support — Carte de Noura
Noura Sarr
Bonjour.
Je m'appelle Noura Sarr.
J'habite près du Port de la Brise.
Je suis de passage au Seuil.
Enchantée.
Noura
Cahier du chemin""",
    [
        tf("Noura habite sous le figuier.", False, "Près du Port de la Brise."),
        qcm(
            "Noura est…",
            ["Formatrice", "De passage", "Cuisinière", "À la moto seulement"],
            1,
            "« de passage au Seuil ».",
        ),
        match(
            [
                ("nom", "Noura Sarr"),
                ("lieu", "port"),
                ("rôle", "de passage"),
                ("formule", "enchantée"),
            ]
        ),
        fill("Complétez :\nJe ___ de passage au Seuil.", "suis"),
        wo(["Bonjour", "."]),
        ana("Noura", "Le prénom de Sarr, de passage."),
        err(
            "Je m'appelle Noura. J'habite près du port. Je suis enchanté.",
            "Je m'appelle Noura. J'habite près du port. Je suis enchantée.",
            "Noura = elle : enchantée.",
        ),
        img(
            [
                ("cahier", "un cahier"),
                ("page", "une page"),
                ("chemin", "un chemin"),
                ("portrait", "un portrait"),
            ]
        ),
        short("Écrivez cinq lignes : bonjour, je m'appelle, j'habite, je suis, enchanté(e)."),
        aud("Lisez votre carte, une phrase, une pause."),
    ],
)

S1_EL = lesson(
    "EL — Je m'appelle, j'habite, je suis",
    "EL",
    """Objectif
Retenir les formules de présentation A1.

Consigne
Apprenez la fiche.

Support — Fiche d'Aline
je m'appelle / tu t'appelles / il s'appelle
j'habite à / au / près de
je suis + rôle
j'ai … ans (pluriel)
enchanté / enchantée
bonjour / au revoir
Attention : j'habite (pas je habite). Ans au pluriel.
Enchantée au féminin.
Cahier du chemin : document inventé du Seuil.""",
    [
        tf("On écrit « j'ai vingt ans » (sans s).", False, "Ans, avec s."),
        qcm(
            "Quelle forme est correcte ?",
            ["je habite", "j'habite", "je habites", "j'habiter"],
            1,
            "J'habite.",
        ),
        match(
            [
                ("s'appeler", "je m'appelle"),
                ("habiter", "j'habite"),
                ("être", "je suis"),
                ("avoir", "j'ai … ans"),
            ]
        ),
        fill("Complétez :\nTu t'___ comment ?", "appelles"),
        wo(["Il", "s'appelle", "Marc", "."]),
        ana("ans", "Après le nombre, pour l'âge, au pluriel."),
        err(
            "Tu t'appelle Léa.",
            "Tu t'appelles Léa.",
            "Tu t'appelles (avec s).",
        ),
        img(
            [
                ("question", "une question"),
                ("reponse", "une réponse"),
                ("pas", "un pas"),
                ("figuier", "le figuier"),
            ]
        ),
        short("Recopiez la fiche. Écrivez quatre phrases : m'appelle, habite, suis, j'ai … ans."),
        aud("Dites : je m'appelle, j'habite, je suis, j'ai … ans, enchanté, enchantée, bonjour, au revoir."),
    ],
)

# ---------------------------------------------------------------------------
# Séquence 2 — Ce que j'ai appris
# passé composé (avoir / être)
# ---------------------------------------------------------------------------

S2_CO = lesson(
    "CO — On a ouvert le cahier",
    "CO",
    """Objectif
Comprendre un bilan au passé composé : j'ai appris, nous avons écouté.

Consigne
Qu'est-ce qu'ils ont fait ? Qui est arrivée ?

Support — Sous le figuier
Léa : J'ai appris beaucoup de mots. J'ai écouté Radio Figuier.
Marc : Nous avons lu le carnet de route. J'ai écrit une page.
Hawa : Je suis arrivée un lundi. J'ai choisi le Seuil.
Joël : Moi, j'ai travaillé à la moto. Je n'ai pas tout écrit.
Aline : Vous avez bien avancé. On a ouvert le Cahier du chemin.
Patrick : J'ai demandé l'heure. Ce n'est pas grave.""",
    [
        tf("Léa a écouté Radio Figuier.", True, "Léa : « J'ai écouté Radio Figuier. »"),
        qcm(
            "Quel jour Hawa est-elle arrivée ?",
            ["Un samedi", "Un lundi", "Un dimanche", "Un vendredi"],
            1,
            "Hawa : « un lundi ».",
        ),
        match(
            [
                ("Léa", "mots et radio"),
                ("Marc", "lu et écrit"),
                ("Hawa", "arrivée lundi"),
                ("Joël", "moto"),
            ]
        ),
        fill("Complétez :\nJ'___ beaucoup de mots.", "ai appris"),
        wo(["Nous", "avons", "lu", "le", "carnet", "."]),
        ana("appris", "Le participe de apprendre, après j'ai."),
        err(
            "J'ai apprendre beaucoup de mots.",
            "J'ai appris beaucoup de mots.",
            "Appris (participe), pas apprendre.",
        ),
        img(
            [
                ("apprendre", "apprendre"),
                ("cahier", "un cahier"),
                ("radio", "la radio"),
                ("page", "une page"),
            ]
        ),
        short("Notez quatre actions au passé composé."),
        aud(
            "Enregistrez : J'ai appris. J'ai écouté. Nous avons lu. Je suis arrivée. J'ai écrit une page."
        ),
    ],
)

S2_CE = lesson(
    "CE — Liste du chemin",
    "CE",
    """Objectif
Lire une liste de choses apprises.

Consigne
Lisez la liste.

Support — Liste du Cahier du chemin
Cette saison, au Seuil
Léa — j'ai appris l'heure et le futur
Marc — j'ai lu le carnet, j'ai écrit
Hawa — je suis arrivée, j'ai choisi
Joël — j'ai travaillé, je n'ai pas tout noté
Aline — vous avez écouté, vous avez parlé
Rien n'est copié d'un examen. C'est notre liste.""",
    [
        tf("Joël a tout noté.", False, "« je n'ai pas tout noté »."),
        qcm(
            "Qu'est-ce que Léa a appris, d'après la liste ?",
            ["La moto seulement", "L'heure et le futur", "Un avion", "La neige"],
            1,
            "L'heure et le futur.",
        ),
        match(
            [
                ("Léa", "heure, futur"),
                ("Marc", "lu, écrit"),
                ("Hawa", "arrivée"),
                ("Aline", "écouté, parlé"),
            ]
        ),
        fill("Complétez :\nJe ___ arrivée un lundi.", "suis"),
        wo(["J'ai", "écrit", "une", "page", "."]),
        ana("écrit", "Le participe de écrire, après j'ai."),
        err(
            "Hawa a arrivée un lundi.",
            "Hawa est arrivée un lundi.",
            "Arriver : être + arrivée.",
        ),
        img(
            [
                ("apprendre", "apprendre"),
                ("page", "une page"),
                ("radio", "la radio"),
                ("bilan", "un bilan"),
            ]
        ),
        short("Recopiez trois lignes. Ajoutez : j'ai… / je suis…"),
        aud("Lisez la liste, un nom, une pause."),
    ],
)

S2_PO = lesson(
    "PO — Dire j'ai appris, je suis arrivé(e)",
    "PO",
    """Objectif
Raconter ce qu'on a fait : passé composé.

Consigne
Répétez, puis dites deux choses apprises.

Support — Modèles de Marc
J'ai appris un mot.
J'ai écouté.
Nous avons lu.
J'ai écrit.
Je suis arrivé.
Elle est arrivée.
Je n'ai pas tout noté.
Vous avez bien avancé.""",
    [
        tf("« Elle est arrivée » s'accorde au féminin.", True, "Être + arrivée."),
        qcm(
            "Quelle phrase est au passé composé ?",
            ["J'apprends", "Je vais apprendre", "J'ai appris", "J'apprendrai"],
            2,
            "J'ai appris.",
        ),
        match(
            [
                ("avoir", "j'ai écouté"),
                ("être", "je suis arrivé"),
                ("négation", "je n'ai pas"),
                ("nous", "avons lu"),
            ]
        ),
        fill("Complétez :\nElle est ___. (arriver, féminin)", "arrivée"),
        wo(["Vous", "avez", "bien", "avancé", "."]),
        ana("écouté", "Le participe de écouter, après j'ai."),
        err(
            "Je suis arrivé.",
            "Je suis arrivée.",
            "Hawa = elle : arrivée.",
        ),
        img(
            [
                ("arriver", "arriver"),
                ("apprendre", "apprendre"),
                ("cahier", "un cahier"),
                ("page", "une page"),
            ]
        ),
        short("Écrivez six phrases au passé composé (quatre avoir, deux être)."),
        aud("Enregistrez les huit modèles, puis deux choses que vous avez apprises."),
    ],
)

S2_PE = lesson(
    "PE — Ma liste d'appris",
    "PE",
    """Objectif
Écrire un mini-bilan au passé composé.

Consigne
Imitez la page de Léa.

Support — Page de Léa
Léa Niyonzima
J'ai appris l'heure. J'ai écouté la radio.
Je suis arrivée un lundi. J'ai choisi le Seuil.
Je n'ai pas tout écrit. J'ai avancé.
Léa
Cahier du chemin""",
    [
        tf("Léa a tout écrit.", False, "« Je n'ai pas tout écrit. »"),
        qcm(
            "Quel jour Léa est-elle arrivée ?",
            ["Un dimanche", "Un lundi", "Un mercredi", "Un samedi"],
            1,
            "Un lundi.",
        ),
        match(
            [
                ("j'ai appris", "l'heure"),
                ("j'ai écouté", "radio"),
                ("je suis arrivée", "lundi"),
                ("j'ai choisi", "Seuil"),
            ]
        ),
        fill("Complétez :\nJ'ai ___ le Seuil.", "choisi"),
        wo(["J'ai", "avancé", "."]),
        ana("choisi", "Le participe, après j'ai, quand on a pris une option."),
        err(
            "J'ai écouté. Je suis arrivé.",
            "J'ai écouté. Je suis arrivée.",
            "Léa = elle : arrivée.",
        ),
        img(
            [
                ("page", "une page"),
                ("radio", "la radio"),
                ("apprendre", "apprendre"),
                ("bilan", "un bilan"),
            ]
        ),
        short("Écrivez cinq lignes : appris, écouté, arrivé(e), choisi, n'ai pas."),
        aud("Lisez votre page, calmement."),
    ],
)

S2_EL = lesson(
    "EL — Passé composé : avoir et être",
    "EL",
    """Objectif
Retenir j'ai + participe et je suis arrivé(e).

Consigne
Apprenez la fiche.

Support — Fiche de Patrick
avoir : j'ai écouté / lu / écrit / appris / choisi
être : je suis arrivé / elle est arrivée
négation : je n'ai pas tout noté
nous avons lu
vous avez avancé
Attention : appris (pas apprendre). Arrivée au féminin.
Pas elle a arrivée.
Cahier du chemin : inventé.""",
    [
        tf("On dit « j'ai apprendre ».", False, "J'ai appris."),
        qcm(
            "Quelle forme est correcte ?",
            ["elle a arrivée", "elle est arrivée", "elle est arrivé", "elle a arrivé"],
            1,
            "Elle est arrivée.",
        ),
        match(
            [
                ("écouter", "écouté"),
                ("lire", "lu"),
                ("écrire", "écrit"),
                ("arriver", "arrivé / arrivée"),
            ]
        ),
        fill("Complétez :\nNous ___ lu le carnet.", "avons"),
        wo(["Je", "n'ai", "pas", "tout", "noté", "."]),
        ana("lu", "Le participe de lire, après j'ai / nous avons."),
        err(
            "Nous avons lu. Vous a avancé.",
            "Nous avons lu. Vous avez avancé.",
            "Vous avez.",
        ),
        img(
            [
                ("apprendre", "apprendre"),
                ("cahier", "un cahier"),
                ("arriver", "arriver"),
                ("bilan", "un bilan"),
            ]
        ),
        short("Recopiez la fiche. Écrivez quatre passés composés."),
        aud("Dites : j'ai appris, j'ai lu, j'ai écrit, je suis arrivé, elle est arrivée, nous avons lu."),
    ],
)

# ---------------------------------------------------------------------------
# Séquence 3 — Je sais le faire
# je peux / je sais / on peut + infinitif
# ---------------------------------------------------------------------------

S3_CO = lesson(
    "CO — Qu'est-ce qu'on sait faire ?",
    "CO",
    """Objectif
Comprendre je peux, je sais, on peut + infinitif.

Consigne
Qui peut faire quoi, maintenant ?

Support — Tour de parole
Aline : Maintenant, vous pouvez demander l'heure.
Léa : Je sais dire bonjour. Je peux lire un menu.
Hawa : On peut acheter au marché. Je sais compter.
Joël : Je peux réparer la moto. Je ne sais pas tout écrire.
Marc : On peut comparer deux thés. C'est simple.
Patrick : Il faut oser. On peut se tromper.""",
    [
        tf("Léa sait dire bonjour.", True, "Léa : « Je sais dire bonjour. »"),
        qcm(
            "Que peut faire Joël ?",
            ["Tout écrire", "Réparer la moto", "Fermer le Seuil", "Voler"],
            1,
            "Joël : « réparer la moto ».",
        ),
        match(
            [
                ("Léa", "lire un menu"),
                ("Hawa", "compter"),
                ("Joël", "moto"),
                ("Marc", "comparer"),
            ]
        ),
        fill("Complétez :\nJe ___ dire bonjour.", "sais"),
        wo(["On", "peut", "demander", "l'heure", "."]),
        ana("peux", "Je… + infinitif : c'est possible."),
        err(
            "Je peux de lire un menu.",
            "Je peux lire un menu.",
            "Pouvoir + infinitif, sans de.",
        ),
        img(
            [
                ("pouvoir", "pouvoir"),
                ("savoir", "savoir"),
                ("question", "une question"),
                ("table", "une table"),
            ]
        ),
        short("Notez quatre « je peux / je sais / on peut »."),
        aud(
            "Enregistrez : Je sais dire bonjour. Je peux lire un menu. On peut demander. Je ne sais pas tout écrire."
        ),
    ],
)

S3_CE = lesson(
    "CE — Affiche « on peut »",
    "CE",
    """Objectif
Lire une affiche de savoir-faire du Seuil.

Consigne
Lisez l'affiche.

Support — Affiche ocre
Au Seuil, maintenant
on peut demander son chemin
on peut lire un menu
on peut acheter au marché
je sais dire l'heure
je peux parler un peu
il faut oser
Affiche inventée. Pas un diplôme réel.""",
    [
        tf("L'affiche dit qu'il faut oser.", True, "« il faut oser »."),
        qcm(
            "Que peut-on lire, d'après l'affiche ?",
            ["Un avion", "Un menu", "Un code secret", "Une carte bancaire"],
            1,
            "Lire un menu.",
        ),
        match(
            [
                ("demander", "chemin"),
                ("lire", "menu"),
                ("acheter", "marché"),
                ("dire", "l'heure"),
            ]
        ),
        fill("Complétez :\nOn ___ acheter au marché.", "peut"),
        wo(["Il", "faut", "oser", "."]),
        ana("savoir", "Je… + infinitif : c'est dans la tête."),
        err(
            "On peuts lire un menu.",
            "On peut lire un menu.",
            "On peut, sans s.",
        ),
        img(
            [
                ("savoir", "savoir"),
                ("marche", "le marché"),
                ("table", "une table"),
                ("question", "une question"),
            ]
        ),
        short("Recopiez l'affiche. Ajoutez : je peux… / je sais…"),
        aud("Lisez l'affiche, une ligne, une pause."),
    ],
)

S3_PO = lesson(
    "PO — Dire je peux, je sais, on peut",
    "PO",
    """Objectif
Parler de ses savoir-faire A1.

Consigne
Répétez, puis dites deux choses que vous savez faire.

Support — Modèles d'Hawa
Je peux parler.
Je sais compter.
On peut demander.
Je ne sais pas tout.
Je peux lire un peu.
On peut se tromper.
Il faut oser.
C'est possible.""",
    [
        tf("« Il faut oser » reste à la 3e personne.", True, "Toujours il faut."),
        qcm(
            "Quelle phrase est correcte ?",
            ["je peux de parler", "je peux parler", "je peux parle", "je peux parlé"],
            1,
            "Je peux + infinitif.",
        ),
        match(
            [
                ("je peux", "possibilité"),
                ("je sais", "connaissance"),
                ("on peut", "le groupe"),
                ("il faut", "conseil"),
            ]
        ),
        fill("Complétez :\nJe ne ___ pas tout.", "sais"),
        wo(["C'est", "possible", "."]),
        ana("oser", "Il faut… : ne pas avoir trop peur."),
        err(
            "Je faut oser.",
            "Il faut oser.",
            "Toujours il faut, pas je faut.",
        ),
        img(
            [
                ("pouvoir", "pouvoir"),
                ("savoir", "savoir"),
                ("reponse", "une réponse"),
                ("ensemble", "ensemble"),
            ]
        ),
        short("Écrivez six phrases : deux peux, deux sais, un on peut, un il faut."),
        aud("Enregistrez les huit modèles, puis deux savoir-faire."),
    ],
)

S3_PE = lesson(
    "PE — Ma liste « je peux »",
    "PE",
    """Objectif
Écrire ce qu'on sait faire.

Consigne
Imitez la liste de Marc.

Support — Liste de Marc
Marc Nkurunziza
Je sais lire un carnet.
Je peux comparer deux prix.
On peut demander à Rose.
Je ne sais pas tout.
Il faut oser.
Marc
Cahier du chemin""",
    [
        tf("Marc sait tout.", False, "« Je ne sais pas tout. »"),
        qcm(
            "Que peut comparer Marc ?",
            ["Deux avions", "Deux prix", "Deux infirmeries", "Deux mers"],
            1,
            "Deux prix.",
        ),
        match(
            [
                ("je sais", "lire"),
                ("je peux", "comparer"),
                ("on peut", "demander"),
                ("il faut", "oser"),
            ]
        ),
        fill("Complétez :\nOn peut demander ___ Rose.", "à"),
        wo(["Je", "peux", "comparer", "deux", "prix", "."]),
        ana("peut", "On… + infinitif : le groupe, comme il."),
        err(
            "On peut demander à Rose. Je sais de lire.",
            "On peut demander à Rose. Je sais lire.",
            "Savoir + infinitif, sans de.",
        ),
        img(
            [
                ("savoir", "savoir"),
                ("marche", "le marché"),
                ("page", "une page"),
                ("pouvoir", "pouvoir"),
            ]
        ),
        short("Écrivez cinq lignes : sais, peux, on peut, ne sais pas, il faut."),
        aud("Lisez votre liste, simplement."),
    ],
)

S3_EL = lesson(
    "EL — Pouvoir, savoir, il faut",
    "EL",
    """Objectif
Retenir je peux / je sais / on peut / il faut + infinitif.

Consigne
Apprenez la fiche.

Support — Fiche d'Aline
pouvoir : je peux / tu peux / on peut / nous pouvons
savoir : je sais / tu sais / il sait
il faut + infinitif (seulement il)
je ne sais pas tout
Attention : je peux (pas je peut). On peut (pas on peuts).
Pas je faut. Pas je peux de lire.
Infinitif après : parler, lire, demander.""",
    [
        tf("On dit « je peut parler ».", False, "Je peux."),
        qcm(
            "Quelle forme est correcte ?",
            ["il fauts oser", "je faut oser", "il faut oser", "ils faut oser"],
            2,
            "Il faut oser.",
        ),
        match(
            [
                ("je peux", "pouvoir"),
                ("je sais", "savoir"),
                ("on peut", "on = il"),
                ("il faut", "falloir"),
            ]
        ),
        fill("Complétez :\nTu ___ compter. (savoir)", "sais"),
        wo(["Nous", "pouvons", "demander", "."]),
        ana("pouvons", "Le verbe pouvoir, avec nous."),
        err(
            "Tu peux parler. Il sait de compter.",
            "Tu peux parler. Il sait compter.",
            "Sait + infinitif.",
        ),
        img(
            [
                ("pouvoir", "pouvoir"),
                ("savoir", "savoir"),
                ("question", "une question"),
                ("ensemble", "ensemble"),
            ]
        ),
        short("Recopiez la fiche. Écrivez quatre phrases : peux, sais, peut, faut."),
        aud("Dites : je peux, tu peux, on peut, je sais, tu sais, il faut oser, je ne sais pas tout."),
    ],
)

# ---------------------------------------------------------------------------
# Séquence 4 — Ce qui a changé
# imparfait (avant) / présent (maintenant)
# ---------------------------------------------------------------------------

S4_CO = lesson(
    "CO — Avant, je ne savais pas",
    "CO",
    """Objectif
Comprendre un changement : avant + imparfait, maintenant + présent.

Consigne
Qu'est-ce qui a changé pour Léa ? Pour Joël ?

Support — Cahier ouvert
Léa : Avant, je ne savais pas demander. Maintenant, je demande.
Joël : Avant, j'étais toujours à la moto. Maintenant, je mange à table.
Hawa : Avant, j'avais peur. Maintenant, je parle un peu.
Patrick : On ne connaissait pas le figuier. Maintenant, on le connaît.
Aline : Vous étiez nouveaux. Maintenant, vous êtes du Seuil.
Marc : Avant, je voulais partir. Maintenant, je reste aujourd'hui.""",
    [
        tf("Avant, Léa ne savait pas demander.", True, "Léa : « je ne savais pas demander »."),
        qcm(
            "Où Joël mange-t-il maintenant ?",
            ["Toujours à la moto", "À table", "Au port seulement", "Nulle part"],
            1,
            "Maintenant, à table.",
        ),
        match(
            [
                ("Léa", "demande"),
                ("Joël", "table"),
                ("Hawa", "parle"),
                ("Marc", "reste"),
            ]
        ),
        fill("Complétez :\nAvant, j'___ peur. (avoir)", "avais"),
        wo(["Maintenant", "je", "parle", "un", "peu", "."]),
        ana("savais", "Le verbe savoir, à l'imparfait, avec je."),
        err(
            "Avant je ne sais pas demander.",
            "Avant, je ne savais pas demander.",
            "Avant : imparfait (savais).",
        ),
        img(
            [
                ("avant", "avant"),
                ("maintenant", "maintenant"),
                ("figuier", "le figuier"),
                ("table", "une table"),
            ]
        ),
        short("Notez deux avant (imparfait) et deux maintenant (présent)."),
        aud(
            "Enregistrez : Avant, je ne savais pas. Maintenant, je demande. J'étais à la moto. Maintenant, je mange à table."
        ),
    ],
)

S4_CE = lesson(
    "CE — Deux colonnes",
    "CE",
    """Objectif
Lire un tableau avant / maintenant.

Consigne
Lisez le tableau.

Support — Tableau du cahier
Avant → maintenant
je ne savais pas → je demande
j'étais à la moto → je mange à table
j'avais peur → je parle
on ne connaissait pas → on connaît
vous étiez nouveaux → vous êtes du Seuil
je voulais partir → je reste aujourd'hui
Inventé pour le bilan. Pas une enquête réelle.""",
    [
        tf("Maintenant, ils sont encore tous nouveaux, d'après le tableau.", False, "Vous êtes du Seuil."),
        qcm(
            "Que voulait Marc, avant ?",
            ["Rester", "Partir", "Chanter", "Fermer"],
            1,
            "Je voulais partir.",
        ),
        match(
            [
                ("savais pas", "je demande"),
                ("moto", "table"),
                ("peur", "je parle"),
                ("nouveaux", "du Seuil"),
            ]
        ),
        fill("Complétez :\nVous ___ nouveaux. (être, avant)", "étiez"),
        wo(["On", "connaît", "le", "figuier", "."]),
        ana("peur", "Hawa l'avait, avant. Maintenant, elle parle."),
        err(
            "Maintenant j'étais du Seuil.",
            "Maintenant je suis du Seuil.",
            "Maintenant : présent.",
        ),
        img(
            [
                ("avant", "avant"),
                ("maintenant", "maintenant"),
                ("chemin", "un chemin"),
                ("groupe", "le groupe"),
            ]
        ),
        short("Recopiez trois lignes du tableau. Ajoutez la vôtre."),
        aud("Lisez le tableau, avant d'abord, puis maintenant."),
    ],
)

S4_PO = lesson(
    "PO — Dire avant / maintenant",
    "PO",
    """Objectif
Parler d'un changement personnel.

Consigne
Répétez, puis dites un avant et un maintenant.

Support — Modèles d'Hawa
Avant, j'avais peur.
Maintenant, je parle.
Avant, je ne savais pas.
Maintenant, je sais un peu.
On ne connaissait pas le Seuil.
On le connaît.
Vous étiez nouveaux.
Vous êtes ici.""",
    [
        tf("« Vous étiez » est l'imparfait de être.", True, "Vous étiez / vous êtes."),
        qcm(
            "Quelle phrase est au présent ?",
            ["J'avais peur", "Je ne savais pas", "Je parle", "Vous étiez nouveaux"],
            2,
            "Je parle.",
        ),
        match(
            [
                ("avant", "imparfait"),
                ("maintenant", "présent"),
                ("j'avais", "peur"),
                ("je sais", "un peu"),
            ]
        ),
        fill("Complétez :\nOn ___ le Seuil. (connaître, maintenant)", "connaît"),
        wo(["Avant", "j'avais", "peur", "."]),
        ana("étiez", "Le verbe être, à l'imparfait, avec vous."),
        err(
            "On connaissait pas le Seuil. (négation)",
            "On ne connaissait pas le Seuil.",
            "Ne… pas.",
        ),
        img(
            [
                ("avant", "avant"),
                ("maintenant", "maintenant"),
                ("portrait", "un portrait"),
                ("content", "content"),
            ]
        ),
        short("Écrivez six phrases : trois avant, trois maintenant."),
        aud("Enregistrez les huit modèles, puis votre changement."),
    ],
)

S4_PE = lesson(
    "PE — Ma colonne du changement",
    "PE",
    """Objectif
Écrire un avant / maintenant.

Consigne
Imitez la page de Joël.

Support — Page de Joël
Joël Mugisha
Avant, j'étais toujours à la moto. Je n'avais pas le midi à table.
Maintenant, je mange avec le groupe. Je suis content.
Avant, je ne savais pas dire « il faut ».
Maintenant, je le dis.
Joël""",
    [
        tf("Joël mangeait déjà à table, avant.", False, "Avant : pas le midi à table."),
        qcm(
            "Que sait Joël dire, maintenant ?",
            ["Au revoir seulement", "« Il faut »", "Rien", "Un poème long"],
            1,
            "« il faut ».",
        ),
        match(
            [
                ("avant, moto", "j'étais"),
                ("midi", "je n'avais pas"),
                ("maintenant", "je mange"),
                ("il faut", "je le dis"),
            ]
        ),
        fill("Complétez :\nJe suis ___.", "content"),
        wo(["Je", "mange", "avec", "le", "groupe", "."]),
        ana("groupe", "Les autres, autour de la table."),
        err(
            "Avant je suis toujours à la moto.",
            "Avant, j'étais toujours à la moto.",
            "Avant : j'étais.",
        ),
        img(
            [
                ("avant", "avant"),
                ("maintenant", "maintenant"),
                ("table", "une table"),
                ("ensemble", "ensemble"),
            ]
        ),
        short("Écrivez cinq lignes : deux avant, deux maintenant, un je suis."),
        aud("Lisez votre page de changement."),
    ],
)

S4_EL = lesson(
    "EL — Imparfait et présent",
    "EL",
    """Objectif
Retenir avant + imparfait, maintenant + présent.

Consigne
Apprenez la fiche.

Support — Fiche de Patrick
imparfait : j'étais / j'avais / je savais / je voulais / on connaissait / vous étiez
présent : je suis / j'ai / je sais / je veux / on connaît / vous êtes
avant / maintenant
Attention : je savais (pas je sais au passé).
On connaît (présent, t final).
Pas maintenant j'étais.
Négation : ne… pas.""",
    [
        tf("On dit « maintenant j'étais ici ».", False, "Maintenant je suis ici."),
        qcm(
            "Quelle forme d'imparfait est correcte ?",
            ["je savais", "je saisais", "je savoir", "j'ai savais"],
            0,
            "Je savais.",
        ),
        match(
            [
                ("j'étais", "je suis"),
                ("j'avais", "j'ai"),
                ("je savais", "je sais"),
                ("vous étiez", "vous êtes"),
            ]
        ),
        fill("Complétez :\nOn ___ le figuier. (connaître, avant)", "connaissait"),
        wo(["Vous", "êtes", "du", "Seuil", "."]),
        ana("connaît", "Le verbe pour un lieu déjà vu, au présent, avec on."),
        err(
            "Maintenant on connaissait le figuier.",
            "Maintenant on connaît le figuier.",
            "Maintenant : connaît.",
        ),
        img(
            [
                ("avant", "avant"),
                ("maintenant", "maintenant"),
                ("figuier", "le figuier"),
                ("chemin", "un chemin"),
            ]
        ),
        short("Recopiez la fiche. Écrivez quatre paires avant / maintenant."),
        aud("Dites : j'étais, je suis, j'avais, j'ai, je savais, je sais, vous étiez, vous êtes."),
    ],
)

# ---------------------------------------------------------------------------
# Séquence 5 — La suite du chemin
# futur simple + il faut (réemploi)
# ---------------------------------------------------------------------------

S5_CO = lesson(
    "CO — Demain, sous le figuier",
    "CO",
    """Objectif
Comprendre un projet : je serai, nous ferons, il faudra, je pourrai.

Consigne
Qui fera quoi demain ? Qu'est-ce qu'il faudra ?

Support — Dernière page ouverte
Aline : Demain, vous serez encore ici. Il faudra une page.
Léa : Je serai à l'heure. J'écrirai mon bilan.
Marc : Nous ferons un tour du Seuil. On pourra relire le cahier.
Joël : Je ne partirai pas. Je resterai à la moto, un peu.
Hawa : J'aurai mon carnet. Il faut un crayon.
Patrick : On pourra se tromper. Ce n'est pas grave.""",
    [
        tf("Léa sera à l'heure.", True, "Léa : « Je serai à l'heure. »"),
        qcm(
            "Que feront-ils, d'après Marc ?",
            ["Un avion", "Un tour du Seuil", "La neige", "Rien"],
            1,
            "« Nous ferons un tour du Seuil. »",
        ),
        match(
            [
                ("Léa", "écrira"),
                ("Marc", "tour du Seuil"),
                ("Joël", "restera"),
                ("Hawa", "carnet"),
            ]
        ),
        fill("Complétez :\nJe ___ à l'heure. (être)", "serai"),
        wo(["Il", "faudra", "une", "page", "."]),
        ana("serai", "Le futur de être, avec je."),
        err(
            "Je sera à l'heure.",
            "Je serai à l'heure.",
            "Je serai (pas je sera).",
        ),
        img(
            [
                ("demain", "demain"),
                ("fleche", "une flèche"),
                ("cahier", "un cahier"),
                ("lac", "un lac"),
            ]
        ),
        short("Notez trois futurs et un il faudra."),
        aud(
            "Enregistrez : Je serai à l'heure. Nous ferons un tour. On pourra relire. Il faudra une page. J'aurai mon carnet."
        ),
    ],
)

S5_CE = lesson(
    "CE — Promesses du cahier",
    "CE",
    """Objectif
Lire des projets au futur simple.

Consigne
Lisez les promesses.

Support — Promesses
Cahier du chemin — la suite
Léa — je serai précise. J'écrirai demain.
Marc — nous ferons le tour. On pourra relire.
Hawa — j'aurai un crayon. Il faut une ligne.
Joël — je ne partirai pas. Je resterai.
Aline — vous serez prêts. Il faudra oser.
Pas un contrat réel. Page inventée.""",
    [
        tf("Joël partira demain, d'après sa promesse.", False, "« je ne partirai pas »."),
        qcm(
            "Que faudra-t-il, d'après Aline ?",
            ["Un avion", "Oser", "De la neige", "Fermer"],
            1,
            "Il faudra oser.",
        ),
        match(
            [
                ("je serai", "précise"),
                ("nous ferons", "le tour"),
                ("j'aurai", "crayon"),
                ("vous serez", "prêts"),
            ]
        ),
        fill("Complétez :\nOn ___ relire. (pouvoir)", "pourra"),
        wo(["J'aurai", "un", "crayon", "."]),
        ana("ferons", "Le futur de faire, avec nous."),
        err(
            "Nous ferons le tour. On poura relire.",
            "Nous ferons le tour. On pourra relire.",
            "Pourra : deux r.",
        ),
        img(
            [
                ("demain", "demain"),
                ("boussole", "une boussole"),
                ("valise", "une valise"),
                ("partir", "partir"),
            ]
        ),
        short("Recopiez trois promesses. Ajoutez : je serai… / il faudra…"),
        aud("Lisez les promesses, une ligne, une pause."),
    ],
)

S5_PO = lesson(
    "PO — Dire je serai, il faudra",
    "PO",
    """Objectif
Parler de la suite : futur simple et il faut / il faudra.

Consigne
Répétez, puis promettez une chose.

Support — Modèles d'Aline
Je serai à l'heure.
Tu seras prêt.
Nous ferons le tour.
On pourra relire.
J'aurai une page.
Il faudra oser.
Il faut un crayon.
Je ne partirai pas.""",
    [
        tf("« Il faudra » est le futur de il faut.", True, "Toujours 3e personne."),
        qcm(
            "Quelle forme est correcte ?",
            ["je sera", "je serai", "je serais-tu", "je suisrai"],
            1,
            "Je serai.",
        ),
        match(
            [
                ("être", "je serai"),
                ("faire", "nous ferons"),
                ("pouvoir", "on pourra"),
                ("avoir", "j'aurai"),
            ]
        ),
        fill("Complétez :\nTu ___ prêt. (être)", "seras"),
        wo(["Il", "faut", "un", "crayon", "."]),
        ana("pourra", "On… relire : futur de pouvoir, deux r."),
        err(
            "Je ferrai le tour demain.",
            "Je ferai le tour demain.",
            "Faire : je ferai (un r).",
        ),
        img(
            [
                ("demain", "demain"),
                ("fleche", "une flèche"),
                ("partir", "partir"),
                ("chemin", "un chemin"),
            ]
        ),
        short("Écrivez six phrases : serai, ferons, pourra, aurai, faudra, faut."),
        aud("Enregistrez les huit modèles, puis votre promesse."),
    ],
)

S5_PE = lesson(
    "PE — Ma promesse",
    "PE",
    """Objectif
Écrire une courte promesse au futur.

Consigne
Imitez la promesse d'Hawa.

Support — Promesse d'Hawa
Hawa Diallo
Demain, je serai au Seuil. J'écrirai une ligne.
Nous ferons le tour ensemble. On pourra rire.
Il faudra un crayon. Il faut oser.
Je ne partirai pas trop vite.
Hawa""",
    [
        tf("Hawa partira trop vite.", False, "« Je ne partirai pas trop vite. »"),
        qcm(
            "Avec qui Hawa fera-t-elle le tour ?",
            ["Toute seule", "Ensemble", "Avec un avion", "Personne"],
            1,
            "« ensemble ».",
        ),
        match(
            [
                ("je serai", "Seuil"),
                ("j'écrirai", "une ligne"),
                ("nous ferons", "le tour"),
                ("il faudra", "crayon"),
            ]
        ),
        fill("Complétez :\nIl ___ oser.", "faut"),
        wo(["Nous", "ferons", "le", "tour", "ensemble", "."]),
        ana("ensemble", "Tous, pas tout seul."),
        err(
            "Demain je serai au Seuil. Je faut un crayon.",
            "Demain je serai au Seuil. Il faut un crayon.",
            "Il faut, pas je faut.",
        ),
        img(
            [
                ("demain", "demain"),
                ("page", "une page"),
                ("ensemble", "ensemble"),
                ("boussole", "une boussole"),
            ]
        ),
        short("Écrivez cinq lignes : serai, écrirai, ferons, faudra, ne partirai pas."),
        aud("Lisez votre promesse, une phrase, une pause."),
    ],
)

S5_EL = lesson(
    "EL — Futur : être, avoir, faire, pouvoir",
    "EL",
    """Objectif
Retenir je serai, j'aurai, je ferai, on pourra, il faudra.

Consigne
Apprenez la fiche.

Support — Fiche d'Aline
être : je serai / tu seras / vous serez
avoir : j'aurai / tu auras
faire : je ferai / nous ferons (un r)
pouvoir : je pourrai / on pourra (deux r)
falloir : il faut / il faudra (seulement il)
Attention : je serai (pas je sera). Je ferai (un r). Je pourrai (deux r).
Pas je faut. Pas on poura. Pas nous allerons (nous irons).
La suite du chemin : page inventée.""",
    [
        tf("On écrit « je ferrai » (deux r).", False, "Je ferai, un r."),
        qcm(
            "Quelle forme est correcte ?",
            ["je poura", "je pourrai", "je pouvrai", "je peusrai"],
            1,
            "Je pourrai (deux r).",
        ),
        match(
            [
                ("je serai", "être"),
                ("j'aurai", "avoir"),
                ("je ferai", "faire"),
                ("il faudra", "falloir"),
            ]
        ),
        fill("Complétez :\nVous ___ prêts. (être)", "serez"),
        wo(["On", "pourra", "relire", "."]),
        ana("aurai", "Le futur de avoir, avec je : j'…"),
        err(
            "Vous sera prêts demain.",
            "Vous serez prêts demain.",
            "Vous serez.",
        ),
        img(
            [
                ("demain", "demain"),
                ("fleche", "une flèche"),
                ("boussole", "une boussole"),
                ("chemin", "un chemin"),
            ]
        ),
        short("Recopiez la fiche. Écrivez quatre futurs : serai, aurai, ferai, faudra."),
        aud("Dites : je serai, tu seras, j'aurai, je ferai, nous ferons, on pourra, il faudra, il faut oser."),
    ],
)

# ---------------------------------------------------------------------------
# Séquence 6 — Une page pour la route
# synthèse : merci, je suis content(e), nous raconterons
# ---------------------------------------------------------------------------

S6_CO = lesson(
    "CO — Merci, le chemin",
    "CO",
    """Objectif
Comprendre un au revoir de bilan : merci, je suis content(e), nous raconterons.

Consigne
Qui dit merci ? Que racontera-t-on ?

Support — Dernier tour sous le figuier
Léa : Merci. Je suis contente. J'ai appris.
Noura : Merci à Aline, à Patrick. Nous raconterons le Seuil.
Joël : Moi, je suis content. Je resterai un peu.
Aline : Merci à vous. Vous avez bien marché.
Marc : À bientôt. On se verra ici.
Hawa : J'écrirai une dernière ligne. Au revoir.
Patrick : Le cahier restera sous le figuier.""",
    [
        tf("Léa est contente.", True, "Léa : « Je suis contente. »"),
        qcm(
            "Où restera le cahier ?",
            ["Dans le minibus", "Sous le figuier", "À Mwezi-Haut", "À la mer"],
            1,
            "Patrick : « sous le figuier ».",
        ),
        match(
            [
                ("Léa", "contente"),
                ("Noura", "raconterons"),
                ("Joël", "resterai"),
                ("Marc", "à bientôt"),
            ]
        ),
        fill("Complétez :\nNous ___ le Seuil.", "raconterons"),
        wo(["Merci", "."]),
        ana("merci", "Le mot pour dire qu'on est reconnaissant."),
        err(
            "Je suis content.",
            "Je suis contente.",
            "Léa = elle : contente.",
        ),
        img(
            [
                ("merci", "merci"),
                ("content", "content"),
                ("adieu", "au revoir"),
                ("figuier", "le figuier"),
            ]
        ),
        short("Notez qui est content(e), un merci, un à bientôt."),
        aud(
            "Enregistrez : Merci. Je suis content / contente. Nous raconterons le Seuil. À bientôt. Au revoir."
        ),
    ],
)

S6_CE = lesson(
    "CE — Dernière page",
    "CE",
    """Objectif
Lire la dernière page du Cahier du chemin.

Consigne
Lisez la page.

Support — Dernière page
Cahier du chemin — Seuil des Sources
Merci à la cour.
Léa — je suis contente. J'ai appris.
Joël — je suis content. Je resterai.
Nous raconterons. On se verra.
À bientôt. Au revoir.
Le cahier restera sous le figuier.
Page inventée. Pas un diplôme.""",
    [
        tf("Le cahier partira avec Noura.", False, "Il restera sous le figuier."),
        qcm(
            "Quelle formule de fin trouve-t-on ?",
            ["Bonne année seulement", "À bientôt. Au revoir.", "Silence", "Fermé lundi"],
            1,
            "À bientôt. Au revoir.",
        ),
        match(
            [
                ("Léa", "contente"),
                ("Joël", "content"),
                ("nous", "raconterons"),
                ("cahier", "figuier"),
            ]
        ),
        fill("Complétez :\nÀ ___.", "bientôt"),
        wo(["Au", "revoir", "."]),
        ana("bientôt", "À… : on se verra dans peu de temps."),
        err(
            "Nous raconterons. On se vera.",
            "Nous raconterons. On se verra.",
            "Verra (deux r), futur de voir.",
        ),
        img(
            [
                ("page", "une page"),
                ("bilan", "un bilan"),
                ("merci", "merci"),
                ("cahier", "un cahier"),
            ]
        ),
        short("Recopiez la page. Ajoutez votre merci et un je suis content(e)."),
        aud("Lisez la dernière page, une ligne, une pause."),
    ],
)

S6_PO = lesson(
    "PO — Dire merci, à bientôt",
    "PO",
    """Objectif
Clore le chemin : merci, je suis content(e), à bientôt.

Consigne
Répétez, puis dites votre fin de cahier.

Support — Modèles de Patrick
Merci.
Je suis content.
Je suis contente.
Nous raconterons.
On se verra.
À bientôt.
Au revoir.
Le cahier restera ici.""",
    [
        tf("« On se verra » est au futur.", True, "Voir : on se verra."),
        qcm(
            "Quelle forme est correcte, pour Léa ?",
            ["je suis content", "je suis contente", "je suis contents", "j'ai content"],
            1,
            "Contente.",
        ),
        match(
            [
                ("merci", "reconnaissance"),
                ("content", "masculin"),
                ("contente", "féminin"),
                ("à bientôt", "on se verra"),
            ]
        ),
        fill("Complétez :\nOn se ___.", "verra"),
        wo(["Le", "cahier", "restera", "ici", "."]),
        ana("revoir", "Au… : pour partir, poliment."),
        err(
            "À bientôt. On se vera sous le figuier.",
            "À bientôt. On se verra sous le figuier.",
            "Verra, deux r.",
        ),
        img(
            [
                ("merci", "merci"),
                ("adieu", "au revoir"),
                ("ensemble", "ensemble"),
                ("content", "content"),
            ]
        ),
        short("Écrivez six phrases de clôture."),
        aud("Enregistrez les huit modèles, puis votre merci."),
    ],
)

S6_PE = lesson(
    "PE — Ma dernière ligne",
    "PE",
    """Objectif
Écrire la dernière ligne du cahier.

Consigne
Imitez la page de Noura.

Support — Page de Noura
Noura Sarr
Merci au Seuil. Je suis contente.
J'ai appris. Nous raconterons le chemin.
À bientôt, sous le figuier.
Au revoir.
Noura""",
    [
        tf("Noura est fâchée.", False, "« Je suis contente. »"),
        qcm(
            "Que raconteront-ils ?",
            ["Un avion", "Le chemin", "Rien", "Un examen secret"],
            1,
            "Le chemin.",
        ),
        match(
            [
                ("merci", "Seuil"),
                ("contente", "Noura"),
                ("j'ai appris", "bilan"),
                ("à bientôt", "figuier"),
            ]
        ),
        fill("Complétez :\nJe suis ___. (Noura)", "contente"),
        wo(["Merci", "au", "Seuil", "."]),
        ana("ligne", "Une seule, la dernière, dans le cahier."),
        err(
            "Merci au Seuil. Je suis content.",
            "Merci au Seuil. Je suis contente.",
            "Noura = elle : contente.",
        ),
        img(
            [
                ("page", "une page"),
                ("merci", "merci"),
                ("figuier", "le figuier"),
                ("adieu", "au revoir"),
            ]
        ),
        short("Écrivez cinq lignes : merci, contente/content, j'ai appris, raconterons, à bientôt."),
        aud("Lisez votre dernière ligne, sans aller trop vite."),
    ],
)

S6_EL = lesson(
    "EL — Merci, content(e), on se verra",
    "EL",
    """Objectif
Retenir les formules de fin et l'accord de content(e).

Consigne
Apprenez la fiche, puis fermez le cahier.

Support — Fiche d'Aline
merci
je suis content / je suis contente
nous raconterons
on se verra (futur de voir, deux r)
à bientôt / au revoir
le cahier restera
Attention : contente au féminin.
On se verra (pas vera).
Nous raconterons (pas nous raconteront).
Cahier du chemin : inventé, sous le figuier.""",
    [
        tf("On écrit « on se vera » (un r).", False, "On se verra, deux r."),
        qcm(
            "Quelle forme est correcte ?",
            ["nous raconterons", "nous raconteront", "nous raconteons", "nous raconter"],
            0,
            "Nous raconterons.",
        ),
        match(
            [
                ("merci", "reconnaissance"),
                ("content", "il"),
                ("contente", "elle"),
                ("à bientôt", "futur proche du cœur"),
            ]
        ),
        fill("Complétez :\nNous ___ le Seuil.", "raconterons"),
        wo(["Je", "suis", "contente", "."]),
        ana("restera", "Le futur de rester, pour le cahier."),
        err(
            "Nous raconterons le Seuil. Vous sera sous le figuier.",
            "Nous raconterons le Seuil. Vous serez sous le figuier.",
            "Vous serez.",
        ),
        img(
            [
                ("bilan", "un bilan"),
                ("cahier", "un cahier"),
                ("content", "content"),
                ("chemin", "un chemin"),
            ]
        ),
        short("Recopiez la fiche. Écrivez quatre phrases : merci, contente/content, raconterons, à bientôt."),
        aud("Dites : merci, je suis content, je suis contente, nous raconterons, on se verra, à bientôt, au revoir."),
    ],
)

SEQUENCES = [
    {"title": "Premiers pas", "lessons": [S1_CO, S1_CE, S1_PO, S1_PE, S1_EL]},
    {"title": "Ce que j'ai appris", "lessons": [S2_CO, S2_CE, S2_PO, S2_PE, S2_EL]},
    {"title": "Je sais le faire", "lessons": [S3_CO, S3_CE, S3_PO, S3_PE, S3_EL]},
    {"title": "Ce qui a changé", "lessons": [S4_CO, S4_CE, S4_PO, S4_PE, S4_EL]},
    {"title": "La suite du chemin", "lessons": [S5_CO, S5_CE, S5_PO, S5_PE, S5_EL]},
    {"title": "Une page pour la route", "lessons": [S6_CO, S6_CE, S6_PO, S6_PE, S6_EL]},
]
