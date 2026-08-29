"""MFK A1 Module 8 — Gestes du quotidien (Seuil des Sources)."""

from __future__ import annotations

IMG = "/elearning/mfk-a1-m8/{name}.svg"


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
    "title": "A1 — Gestes du quotidien",
    "description": (
        "Grande étape 8 : lire un menu, faire des courses, comparer, "
        "parler d'hier et d'aujourd'hui, s'habiller et donner son avis — "
        "à la Table des Sources, au Marché des Lampions et à l'Atelier du Tissu "
        "(Seuil des Sources, Rukiri-Nord)."
    ),
}

# ---------------------------------------------------------------------------
# Séquence 1 — La table du Seuil
# articles partitifs ; j'aime + article défini
# ---------------------------------------------------------------------------

S1_CO = lesson(
    "CO — Midi à la Table des Sources",
    "CO",
    """Objectif
Comprendre un menu et un avis : du / de la / des ; j'aime le / la / les.

Consigne
Lisez le dialogue (à écouter avec l'enseignant). Qu'est-ce qu'il y a à table ? Qui aime quoi ?

Support — Banc du figuier, midi
Félicie Ndayishimiye : Aujourd'hui, il y a de la soupe aux herbes. Et du pain du Seuil.
Léa : J'aime le pain. Je n'aime pas trop le poisson.
Marc : Moi, je prends du poulet. Il y a aussi des ignames.
Hawa : Il n'y a pas de fromage aujourd'hui. Tant pis. Je bois du thé.
Joël : Je déteste le café. J'adore le thé au gingembre.
Aline : Il faut goûter. La goyave est pour le dessert.""",
    [
        tf("Léa aime le pain.", True, "Léa : « J'aime le pain. »"),
        qcm(
            "Qu'est-ce qu'il n'y a pas, d'après Hawa ?",
            ["Du pain", "De la soupe", "Du fromage", "Du thé"],
            2,
            "Hawa : « Il n'y a pas de fromage. »",
        ),
        match(
            [
                ("Félicie", "soupe et pain"),
                ("Marc", "poulet"),
                ("Joël", "thé"),
                ("Aline", "goyave"),
            ]
        ),
        fill("Complétez :\nIl y a ___ soupe aux herbes.", "de la"),
        wo(["J'aime", "le", "pain", "."]),
        ana("soupe", "Le plat liquide de Félicie, aux herbes."),
        err(
            "Je n'aime pas du poisson.",
            "Je n'aime pas le poisson.",
            "Après aimer / n'aimer pas : le, la, les (pas du).",
        ),
        img(
            [
                ("menu", "un menu"),
                ("pain", "du pain"),
                ("poulet", "du poulet"),
                ("the", "du thé"),
            ]
        ),
        short("Notez trois plats et un avis (j'aime / je n'aime pas)."),
        aud(
            "Enregistrez : Il y a de la soupe. J'aime le pain. Je n'aime pas le poisson. Je bois du thé."
        ),
    ],
)

S1_CE = lesson(
    "CE — Menu du midi",
    "CE",
    """Objectif
Lire un menu inventé et repérer du / de la / des.

Consigne
Lisez le menu.

Support — Ardoise de la Table des Sources
Midi sous le figuier
Entrée : de la soupe aux herbes
Plat : du poulet au citron ou du poisson du lac
Accompagnement : des ignames ou des légumes du jardin
Pain du Seuil
Dessert : de la goyave
Boisson : du thé au gingembre. Pas de café aujourd'hui.
Félicie Ndayishimiye — Seuil des Sources""",
    [
        tf("Le menu propose du café.", False, "« Pas de café aujourd'hui. »"),
        qcm(
            "Quel dessert y a-t-il ?",
            ["Du chocolat", "De la goyave", "Des ignames frites", "Un gâteau du port"],
            1,
            "Dessert : de la goyave.",
        ),
        match(
            [
                ("entrée", "soupe"),
                ("plat", "poulet ou poisson"),
                ("accompagnement", "ignames ou légumes"),
                ("boisson", "thé"),
            ]
        ),
        fill("Complétez :\nIl y a ___ ignames.", "des"),
        wo(["Pas", "de", "café", "aujourd'hui", "."]),
        ana("menu", "La liste des plats, sur l'ardoise."),
        err(
            "Il n'y a pas du café.",
            "Il n'y a pas de café.",
            "Après pas : de (pas du).",
        ),
        img(
            [
                ("assiette", "une assiette"),
                ("poisson", "du poisson"),
                ("legume", "des légumes"),
                ("fruit", "un fruit"),
            ]
        ),
        short("Recopiez le menu. Ajoutez un plat avec du, de la ou des."),
        aud("Lisez le menu, une ligne, une pause."),
    ],
)

S1_PO = lesson(
    "PO — Dire j'aime, il y a du",
    "PO",
    """Objectif
Parler d'un plat : partitif et goût.

Consigne
Répétez, puis dites ce que vous aimez à table.

Support — Modèles de Félicie
Il y a du pain.
Il y a de la soupe.
Il y a de l'huile.
Il y a des légumes.
J'aime le thé.
Je n'aime pas le café.
Je bois du thé.
Il n'y a pas de fromage.""",
    [
        tf("On dit « j'aime du thé ».", False, "J'aime le thé (article défini)."),
        qcm(
            "Quelle phrase est correcte ?",
            ["Il y a de pain", "Il y a du pain", "Il y a le pain beaucoup", "Il y a pain"],
            1,
            "Du = de + le.",
        ),
        match(
            [
                ("du", "pain, poulet, thé"),
                ("de la", "soupe, goyave"),
                ("de l'", "huile"),
                ("des", "légumes, ignames"),
            ]
        ),
        fill("Complétez :\nJe bois ___ thé.", "du"),
        wo(["Je", "n'aime", "pas", "le", "café", "."]),
        ana("fromage", "Il n'y en a pas aujourd'hui, à table."),
        err(
            "J'aime de la soupe.",
            "J'aime la soupe.",
            "Goût : le / la / les, pas du / de la.",
        ),
        img(
            [
                ("fromage", "du fromage"),
                ("the", "du thé"),
                ("cafe", "du café"),
                ("table", "une table"),
            ]
        ),
        short("Écrivez six phrases : trois il y a du/de la/des, trois j'aime / je n'aime pas."),
        aud("Enregistrez les huit modèles, puis votre plat préféré."),
    ],
)

S1_PE = lesson(
    "PE — Mon avis à table",
    "PE",
    """Objectif
Écrire un court avis sur un menu.

Consigne
Imitez le mot de Léa.

Support — Mot de Léa
Léa Niyonzima
À la Table des Sources, il y a de la soupe et du pain.
J'aime le pain. Je n'aime pas le poisson.
Je bois du thé. Il n'y a pas de fromage.
C'est simple. Merci, Félicie.
Léa""",
    [
        tf("Léa aime le poisson.", False, "« Je n'aime pas le poisson. »"),
        qcm(
            "Que boit Léa ?",
            ["Du café", "Du thé", "De l'eau de mer", "Du sirop"],
            1,
            "« Je bois du thé. »",
        ),
        match(
            [
                ("il y a", "soupe et pain"),
                ("j'aime", "pain"),
                ("je n'aime pas", "poisson"),
                ("je bois", "thé"),
            ]
        ),
        fill("Complétez :\nIl n'y a pas ___ fromage.", "de"),
        wo(["J'aime", "le", "pain", "."]),
        ana("thé", "La boisson chaude de Léa, pas le café."),
        err(
            "Je bois de thé.",
            "Je bois du thé.",
            "Du thé (de + le).",
        ),
        img(
            [
                ("pain", "du pain"),
                ("the", "du thé"),
                ("assiette", "une assiette"),
                ("cuisine", "la cuisine"),
            ]
        ),
        short("Écrivez cinq lignes : il y a, j'aime, je n'aime pas, je bois, il n'y a pas."),
        aud("Lisez votre mot, une phrase, une pause."),
    ],
)

S1_EL = lesson(
    "EL — Du, de la, des ; j'aime le",
    "EL",
    """Objectif
Retenir les articles partitifs et l'article défini après aimer.

Consigne
Apprenez la fiche.

Support — Fiche de Félicie
du pain / de la soupe / de l'huile / des légumes
pas de fromage (après pas : de)
j'aime le pain / la soupe / les légumes
je n'aime pas le café
je bois du thé
Attention : j'aime le (pas j'aime du).
Il n'y a pas de (pas pas du).
Table des Sources : lieu inventé du Seuil.""",
    [
        tf("On écrit « pas du pain » après il n'y a.", False, "Il n'y a pas de pain."),
        qcm(
            "Quelle forme est correcte ?",
            ["j'aime du poulet", "j'aime le poulet", "j'aime de poulet", "j'aime poulet"],
            1,
            "J'aime le poulet.",
        ),
        match(
            [
                ("du", "masculin"),
                ("de la", "féminin"),
                ("de l'", "voyelle"),
                ("des", "pluriel"),
            ]
        ),
        fill("Complétez :\nIl y a ___ huile. (partitif)", "de l'"),
        wo(["Il", "y", "a", "des", "légumes", "."]),
        ana("pain", "On le coupe, on le mange avec la soupe."),
        err(
            "Il y a de pain sur la table.",
            "Il y a du pain sur la table.",
            "Du pain.",
        ),
        img(
            [
                ("pain", "du pain"),
                ("fromage", "du fromage"),
                ("legume", "des légumes"),
                ("menu", "un menu"),
            ]
        ),
        short("Recopiez la fiche. Écrivez quatre phrases : du, de la, des, j'aime le."),
        aud("Dites : du pain, de la soupe, de l'huile, des légumes, j'aime le thé, pas de café."),
    ],
)

# ---------------------------------------------------------------------------
# Séquence 2 — Courses au marché
# quantités + de ; je voudrais
# ---------------------------------------------------------------------------

S2_CO = lesson(
    "CO — À l'étal de Rose",
    "CO",
    """Objectif
Comprendre des courses : je voudrais, un kilo de, une bouteille de.

Consigne
Qui achète quoi ? Quelles quantités ?

Support — Marché des Lampions
Rose Iradukunda : Bonjour. Qu'est-ce que vous voulez ?
Léa : Je voudrais un kilo de tomates, s'il vous plaît.
Hawa : Moi, une bouteille d'huile de figuier.
Marc : Un pot de miel des Herbes. Et un morceau de fromage.
Joël : Deux pains du Seuil. C'est tout.
Rose : Voilà. Ça fait peu. Il faut un sac ?
Aline : Oui. Un sac, merci.""",
    [
        tf("Léa voudrait un kilo de tomates.", True, "Léa : « un kilo de tomates »."),
        qcm(
            "Que voudrait Hawa ?",
            ["Un pot de miel", "Une bouteille d'huile", "Deux pains", "Un kilo de café"],
            1,
            "Hawa : « une bouteille d'huile de figuier ».",
        ),
        match(
            [
                ("Léa", "un kilo de tomates"),
                ("Hawa", "une bouteille d'huile"),
                ("Marc", "miel et fromage"),
                ("Joël", "deux pains"),
            ]
        ),
        fill("Complétez :\nJe voudrais un kilo ___ tomates.", "de"),
        wo(["Je", "voudrais", "un", "pot", "de", "miel", "."]),
        ana("kilo", "Mille grammes, pour les tomates."),
        err(
            "Je voudrais un kilo du tomates.",
            "Je voudrais un kilo de tomates.",
            "Quantité + de (pas du).",
        ),
        img(
            [
                ("marche", "le marché"),
                ("panier", "un panier"),
                ("bouteille", "une bouteille"),
                ("kilo", "un kilo"),
            ]
        ),
        short("Notez quatre achats avec la quantité."),
        aud(
            "Enregistrez : Je voudrais un kilo de tomates. Une bouteille d'huile. Un pot de miel. Deux pains."
        ),
    ],
)

S2_CE = lesson(
    "CE — Liste de Rose",
    "CE",
    """Objectif
Lire une liste de courses avec des quantités.

Consigne
Lisez la liste.

Support — Liste épinglée à l'étal
Marché des Lampions — Rose
Pour la Table des Sources
un kilo de tomates
une bouteille d'huile de figuier
un pot de miel des Herbes
un morceau de fromage
deux pains du Seuil
un sac
Pas d'enseigne réelle. Étal inventé, Rukiri-Nord.""",
    [
        tf("La liste demande trois pains.", False, "Deux pains du Seuil."),
        qcm(
            "Combien de bouteilles d'huile ?",
            ["Zéro", "Une", "Deux", "Un kilo"],
            1,
            "Une bouteille d'huile.",
        ),
        match(
            [
                ("kilo", "tomates"),
                ("bouteille", "huile"),
                ("pot", "miel"),
                ("morceau", "fromage"),
            ]
        ),
        fill("Complétez :\nUn morceau ___ fromage.", "de"),
        wo(["Une", "bouteille", "d'huile", "."]),
        ana("miel", "Le pot sucré des Herbes, chez Rose."),
        err(
            "Je voudrais une bouteille de l'huile.",
            "Je voudrais une bouteille d'huile.",
            "Une bouteille d'huile (d' devant voyelle).",
        ),
        img(
            [
                ("pot", "un pot"),
                ("sac", "un sac"),
                ("fromage", "du fromage"),
                ("pain", "du pain"),
            ]
        ),
        short("Recopiez la liste. Ajoutez un article : je voudrais…"),
        aud("Lisez la liste, un article, une pause."),
    ],
)

S2_PO = lesson(
    "PO — Dire je voudrais, un kilo de",
    "PO",
    """Objectif
Faire des courses : je voudrais + quantité + de.

Consigne
Répétez, puis achetez deux choses.

Support — Modèles de Rose
Je voudrais un kilo de tomates.
Je voudrais une bouteille d'huile.
Je voudrais un pot de miel.
Je voudrais un morceau de fromage.
Je voudrais deux pains.
S'il vous plaît.
C'est tout.
Il faut un sac.""",
    [
        tf("« Je voudrais » sert à demander poliment.", True, "Au marché, pour acheter."),
        qcm(
            "Quelle phrase est correcte ?",
            ["un kilo du pain", "un kilo de pain", "un kilo le pain", "un kilo pain"],
            1,
            "Un kilo de pain.",
        ),
        match(
            [
                ("un kilo de", "tomates"),
                ("une bouteille d'", "huile"),
                ("un pot de", "miel"),
                ("deux", "pains"),
            ]
        ),
        fill("Complétez :\nJe ___ un sac. (vouloir, poli)", "voudrais"),
        wo(["S'il", "vous", "plaît", "."]),
        ana("panier", "On y met les courses, au marché."),
        err(
            "Je voudrai un kilo de tomates. (demande polie)",
            "Je voudrais un kilo de tomates.",
            "Je voudrais (poli), pas je voudrai.",
        ),
        img(
            [
                ("panier", "un panier"),
                ("bouteille", "une bouteille"),
                ("pot", "un pot"),
                ("kilo", "un kilo"),
            ]
        ),
        short("Écrivez six phrases je voudrais + quantité."),
        aud("Enregistrez les huit modèles, puis vos deux courses."),
    ],
)

S2_PE = lesson(
    "PE — Ma liste",
    "PE",
    """Objectif
Écrire une petite liste de courses.

Consigne
Imitez la liste d'Hawa.

Support — Liste d'Hawa
Hawa Diallo
Je voudrais :
une bouteille d'huile
un pot de miel
un kilo de tomates
deux pains
s'il vous plaît.
Marché des Lampions""",
    [
        tf("Hawa veut du café.", False, "Huile, miel, tomates, pains."),
        qcm(
            "Combien de pains Hawa voudrait-elle ?",
            ["Un", "Deux", "Un kilo", "Zéro"],
            1,
            "Deux pains.",
        ),
        match(
            [
                ("bouteille", "huile"),
                ("pot", "miel"),
                ("kilo", "tomates"),
                ("deux", "pains"),
            ]
        ),
        fill("Complétez :\nJe voudrais une bouteille ___ huile.", "d'"),
        wo(["Je", "voudrais", "deux", "pains", "."]),
        ana("sac", "Rose le propose, pour porter."),
        err(
            "Je voudrais un pot du miel.",
            "Je voudrais un pot de miel.",
            "Un pot de miel.",
        ),
        img(
            [
                ("marche", "le marché"),
                ("sac", "un sac"),
                ("bouteille", "une bouteille"),
                ("pain", "du pain"),
            ]
        ),
        short("Écrivez cinq lignes : je voudrais + quatre quantités."),
        aud("Lisez votre liste, simplement."),
    ],
)

S2_EL = lesson(
    "EL — Quantités et je voudrais",
    "EL",
    """Objectif
Retenir quantité + de et je voudrais.

Consigne
Apprenez la fiche.

Support — Fiche de Rose
je voudrais (+ nom)
un kilo de tomates
une bouteille d'huile
un pot de miel
un morceau de fromage
deux pains
un sac
Attention : quantité + de (pas du).
Devant une voyelle : d'huile.
Je voudrais (poli). Pas je voudrai.
Marché des Lampions : lieu déjà connu du Seuil.""",
    [
        tf("On dit « un kilo du tomates ».", False, "Un kilo de tomates."),
        qcm(
            "Quelle forme est correcte ?",
            ["je voudrai du miel", "je voudrais un pot de miel", "je veux de un miel", "je voudrais du un miel"],
            1,
            "Je voudrais un pot de miel.",
        ),
        match(
            [
                ("kilo", "poids"),
                ("bouteille", "liquide"),
                ("pot", "miel"),
                ("morceau", "fromage"),
            ]
        ),
        fill("Complétez :\nUn ___ de fromage.", "morceau"),
        wo(["Un", "kilo", "de", "tomates", "."]),
        ana("voudrais", "La forme polie de vouloir, avec je."),
        err(
            "Je voudrais un morceau de le fromage.",
            "Je voudrais un morceau de fromage.",
            "De fromage, sans article.",
        ),
        img(
            [
                ("kilo", "un kilo"),
                ("pot", "un pot"),
                ("panier", "un panier"),
                ("marche", "le marché"),
            ]
        ),
        short("Recopiez la fiche. Écrivez quatre je voudrais avec de."),
        aud("Dites : je voudrais, un kilo de, une bouteille d'huile, un pot de miel, s'il vous plaît."),
    ],
)

# ---------------------------------------------------------------------------
# Séquence 3 — On compare
# plus / moins / aussi … que
# ---------------------------------------------------------------------------

S3_CO = lesson(
    "CO — Thé ou café, radio ou carnet",
    "CO",
    """Objectif
Comprendre une comparaison : plus, moins, aussi … que.

Consigne
Qui boit plus ? Qu'est-ce qui est moins cher ?

Support — Sous le figuier
Patrick : Le thé est moins cher que le café, ici.
Hawa : Moi, je bois plus de thé que Joël.
Joël : C'est vrai. Je bois moins de thé qu'Hawa. J'aime autant le café.
Léa : La Radio Figuier est aussi calme que le banc.
Marc : Le miel est plus sucré que la goyave.
Aline : Je vais prendre le thé. C'est plus simple.""",
    [
        tf("Le thé est moins cher que le café.", True, "Patrick : « moins cher que le café »."),
        qcm(
            "Qui boit plus de thé ?",
            ["Joël", "Hawa", "Marc", "Personne"],
            1,
            "Hawa boit plus de thé que Joël.",
        ),
        match(
            [
                ("thé", "moins cher"),
                ("Hawa", "plus de thé"),
                ("radio", "aussi calme"),
                ("miel", "plus sucré"),
            ]
        ),
        fill("Complétez :\nLe miel est plus sucré ___ la goyave.", "que"),
        wo(["Je", "vais", "prendre", "le", "thé", "."]),
        ana("moins", "Le contraire de plus, dans une comparaison."),
        err(
            "Le thé est moins cher que le café n'est.",
            "Le thé est moins cher que le café.",
            "Moins … que + nom.",
        ),
        img(
            [
                ("the", "du thé"),
                ("cafe", "du café"),
                ("comparer", "comparer"),
                ("avis", "un avis"),
            ]
        ),
        short("Notez trois comparaisons entendues."),
        aud(
            "Enregistrez : Le thé est moins cher que le café. Je bois plus de thé. La radio est aussi calme. Je vais prendre le thé."
        ),
    ],
)

S3_CE = lesson(
    "CE — Tableau des goûts",
    "CE",
    """Objectif
Lire un tableau de comparaisons inventé.

Consigne
Lisez le tableau.

Support — Feuille du figuier
On compare — Seuil des Sources
thé — moins cher que le café
miel — plus sucré que la goyave
Radio Figuier — aussi calme que le banc
Hawa — plus de thé que Joël
ignames — aussi bonnes que le pain
Table des Sources — moins loin que le Port de la Brise
Rien n'est copié d'une enquête réelle.""",
    [
        tf("Les ignames sont moins bonnes que le pain, d'après le tableau.", False, "Aussi bonnes que le pain."),
        qcm(
            "La Table des Sources est…",
            ["Plus loin que le port", "Moins loin que le Port de la Brise", "Aussi loin que l'île", "Fermée"],
            1,
            "Moins loin que le Port de la Brise.",
        ),
        match(
            [
                ("thé", "moins cher"),
                ("miel", "plus sucré"),
                ("radio", "aussi calme"),
                ("Hawa", "plus de thé"),
            ]
        ),
        fill("Complétez :\nHawa boit plus de thé ___ Joël.", "que"),
        wo(["Le", "thé", "est", "moins", "cher", "."]),
        ana("sucré", "Le miel l'est plus que la goyave."),
        err(
            "La radio est aussi calme que le banc est.",
            "La radio est aussi calme que le banc.",
            "Aussi … que + nom.",
        ),
        img(
            [
                ("comparer", "comparer"),
                ("table", "une table"),
                ("the", "du thé"),
                ("fruit", "un fruit"),
            ]
        ),
        short("Recopiez trois lignes. Ajoutez une comparaison personnelle."),
        aud("Lisez le tableau, une ligne, une pause."),
    ],
)

S3_PO = lesson(
    "PO — Dire plus, moins, aussi",
    "PO",
    """Objectif
Comparer deux choses ou deux personnes.

Consigne
Répétez, puis comparez deux boissons.

Support — Modèles de Patrick
Le thé est moins cher que le café.
Le miel est plus sucré que la goyave.
La radio est aussi calme que le banc.
Je bois plus de thé que Joël.
Je bois moins de café qu'Hawa.
Je vais le prendre.
C'est plus simple.
Il est aussi bon.""",
    [
        tf("« Aussi … que » veut dire « la même chose ».", True, "Même degré."),
        qcm(
            "Quelle phrase est une comparaison ?",
            ["Je voudrais du thé", "Le thé est moins cher que le café", "Il y a du pain", "Bonjour Rose"],
            1,
            "Moins cher que.",
        ),
        match(
            [
                ("plus … que", "davantage"),
                ("moins … que", "pas autant"),
                ("aussi … que", "pareil"),
                ("je vais le prendre", "choix"),
            ]
        ),
        fill("Complétez :\nLa radio est aussi calme ___ le banc.", "que"),
        wo(["C'est", "plus", "simple", "."]),
        ana("aussi", "Pour dire « la même chose », avant l'adjectif."),
        err(
            "Je bois plus que thé que Joël.",
            "Je bois plus de thé que Joël.",
            "Plus de + nom + que.",
        ),
        img(
            [
                ("comparer", "comparer"),
                ("cafe", "du café"),
                ("the", "du thé"),
                ("avis", "un avis"),
            ]
        ),
        short("Écrivez six phrases : deux plus, deux moins, deux aussi."),
        aud("Enregistrez les huit modèles, puis une comparaison à vous."),
    ],
)

S3_PE = lesson(
    "PE — Ma comparaison",
    "PE",
    """Objectif
Écrire trois comparaisons.

Consigne
Imitez le mot de Marc.

Support — Mot de Marc
Marc Nkurunziza
Le miel est plus sucré que la goyave.
Le thé est moins cher que le café.
La Table des Sources est aussi calme que le figuier.
Je vais prendre le thé.
Marc""",
    [
        tf("Marc trouve le café moins cher que le thé.", False, "Le thé est moins cher que le café."),
        qcm(
            "Que va prendre Marc ?",
            ["Le café", "Le thé", "Le miel seul", "Rien"],
            1,
            "« Je vais prendre le thé. »",
        ),
        match(
            [
                ("miel", "plus sucré"),
                ("thé", "moins cher"),
                ("table", "aussi calme"),
                ("choix", "le thé"),
            ]
        ),
        fill("Complétez :\nJe vais ___ le thé.", "prendre"),
        wo(["Le", "miel", "est", "plus", "sucré", "."]),
        ana("goyave", "Le fruit du dessert, moins sucré que le miel."),
        err(
            "Le thé est plus moins cher que le café.",
            "Le thé est moins cher que le café.",
            "Un seul mot : plus ou moins.",
        ),
        img(
            [
                ("fruit", "un fruit"),
                ("the", "du thé"),
                ("table", "une table"),
                ("comparer", "comparer"),
            ]
        ),
        short("Écrivez cinq lignes : plus, moins, aussi, je vais prendre, un avis."),
        aud("Lisez votre mot de comparaison."),
    ],
)

S3_EL = lesson(
    "EL — Plus, moins, aussi … que",
    "EL",
    """Objectif
Retenir les comparatifs A1.

Consigne
Apprenez la fiche.

Support — Fiche de Patrick
plus + adj + que : plus sucré que
moins + adj + que : moins cher que
aussi + adj + que : aussi calme que
plus de / moins de + nom : plus de thé
je vais le prendre
Attention : que (pas qui) après la comparaison.
Aussi (deux s).
Pas plus moins ensemble.""",
    [
        tf("On écrit « ausi calme » (un s).", False, "Aussi, deux s."),
        qcm(
            "Quelle forme est correcte ?",
            ["plus sucré que", "plus sucré qui", "plus sucré de que", "le plus sucré que la"],
            0,
            "Plus sucré que.",
        ),
        match(
            [
                ("plus", "davantage"),
                ("moins", "pas autant"),
                ("aussi", "égal"),
                ("que", "après l'adjectif"),
            ]
        ),
        fill("Complétez :\nJoël boit moins ___ thé qu'Hawa.", "de"),
        wo(["Aussi", "calme", "que", "le", "banc", "."]),
        ana("simple", "C'est plus… : facile, sans souci."),
        err(
            "C'est plus simple que le café est.",
            "C'est plus simple.",
            "Pas besoin de répéter le verbe.",
        ),
        img(
            [
                ("avis", "un avis"),
                ("comparer", "comparer"),
                ("cafe", "du café"),
                ("menu", "un menu"),
            ]
        ),
        short("Recopiez la fiche. Écrivez quatre comparaisons."),
        aud("Dites : plus sucré que, moins cher que, aussi calme que, plus de thé, je vais le prendre."),
    ],
)

# ---------------------------------------------------------------------------
# Séquence 4 — Autrefois, maintenant
# imparfait (hier) / présent (aujourd'hui)
# ---------------------------------------------------------------------------

S4_CO = lesson(
    "CO — Félicie raconte",
    "CO",
    """Objectif
Comprendre hier et aujourd'hui : imparfait / présent.

Consigne
Que faisait Félicie avant ? Que fait-elle maintenant ?

Support — Table des Sources
Félicie : Avant, j'étais à Mwezi-Haut. Je cuisinais pour ma famille.
Léa : Et maintenant ?
Félicie : Maintenant, je suis au Seuil. Je cuisine ici, midi.
Patrick : Tu voulais partir ?
Félicie : Oui. Je voulais un travail près du figuier. J'avais peu de temps, avant.
Aline : On mangeait trop vite, là-bas. Ici, on mange plus lentement.
Joël : Moi, je n'étais pas cuisinier. Je restais à la moto.""",
    [
        tf("Félicie était à Mwezi-Haut, avant.", True, "« j'étais à Mwezi-Haut »."),
        qcm(
            "Que fait Félicie maintenant ?",
            ["Elle cuisinait à Mwezi-Haut", "Elle est au Seuil et elle cuisine ici", "Elle reste à la moto", "Elle vend des vestes"],
            1,
            "Maintenant, je suis au Seuil.",
        ),
        match(
            [
                ("avant", "Mwezi-Haut"),
                ("maintenant", "le Seuil"),
                ("on mangeait", "trop vite"),
                ("Joël", "pas cuisinier"),
            ]
        ),
        fill("Complétez :\nAvant, j'___ à Mwezi-Haut. (être)", "étais"),
        wo(["Je", "cuisinais", "pour", "ma", "famille", "."]),
        ana("étais", "Le verbe être, à l'imparfait, avec je."),
        err(
            "Avant je suis à Mwezi-Haut.",
            "Avant, j'étais à Mwezi-Haut.",
            "Hier / avant : imparfait (j'étais).",
        ),
        img(
            [
                ("hier", "hier"),
                ("cuisine", "la cuisine"),
                ("table", "une table"),
                ("assiette", "une assiette"),
            ]
        ),
        short("Notez deux phrases avant (imparfait) et deux maintenant (présent)."),
        aud(
            "Enregistrez : Avant, j'étais à Mwezi-Haut. Je cuisinais. Maintenant, je suis au Seuil. On mange plus lentement."
        ),
    ],
)

S4_CE = lesson(
    "CE — Carte d'autrefois",
    "CE",
    """Objectif
Lire un petit portrait hier / aujourd'hui.

Consigne
Lisez la carte.

Support — Carte de Félicie
Félicie Ndayishimiye
Avant : j'étais à Mwezi-Haut. Je cuisinais le soir. J'avais peu de temps. Je voulais partir.
Maintenant : je suis au Seuil. Je cuisine à midi. J'ai le figuier. On mange lentement.
Table des Sources — Rukiri-Nord
Portrait inventé.""",
    [
        tf("Félicie cuisine encore le soir, maintenant.", False, "Maintenant : à midi."),
        qcm(
            "Que voulait Félicie, avant ?",
            ["Rester à la moto", "Partir", "Acheter une veste", "Fermer la table"],
            1,
            "« Je voulais partir. »",
        ),
        match(
            [
                ("j'étais", "Mwezi-Haut"),
                ("je cuisinais", "le soir"),
                ("je suis", "Seuil"),
                ("je cuisine", "midi"),
            ]
        ),
        fill("Complétez :\nJe ___ partir. (vouloir, avant)", "voulais"),
        wo(["J'avais", "peu", "de", "temps", "."]),
        ana("voulais", "Le verbe vouloir, à l'imparfait, avec je."),
        err(
            "Maintenant j'étais au Seuil.",
            "Maintenant je suis au Seuil.",
            "Maintenant : présent (je suis).",
        ),
        img(
            [
                ("hier", "hier"),
                ("cuisine", "la cuisine"),
                ("table", "une table"),
                ("menu", "un menu"),
            ]
        ),
        short("Recopiez la carte en deux colonnes : avant / maintenant."),
        aud("Lisez la carte, sans aller trop vite."),
    ],
)

S4_PO = lesson(
    "PO — Dire j'étais, je suis",
    "PO",
    """Objectif
Parler d'une évolution : imparfait et présent.

Consigne
Répétez, puis dites un avant / maintenant (vrai ou inventé).

Support — Modèles de Félicie
J'étais à Mwezi-Haut.
Je cuisinais le soir.
J'avais peu de temps.
Je voulais partir.
Maintenant, je suis ici.
Je cuisine à midi.
On mangeait trop vite.
On mange lentement.""",
    [
        tf("« J'étais » est l'imparfait de être.", True, "Je suis → j'étais."),
        qcm(
            "Quelle forme d'imparfait est correcte ?",
            ["je étais", "j'étais", "j'étaisais", "je suisais"],
            1,
            "J'étais.",
        ),
        match(
            [
                ("être", "j'étais"),
                ("avoir", "j'avais"),
                ("vouloir", "je voulais"),
                ("cuisiner", "je cuisinais"),
            ]
        ),
        fill("Complétez :\nOn ___ trop vite. (manger, avant)", "mangeait"),
        wo(["Maintenant", "je", "suis", "ici", "."]),
        ana("avait", "Le verbe avoir, à l'imparfait, avec il/elle."),
        err(
            "On mangions trop vite.",
            "On mangeait trop vite.",
            "On = il/elle : mangeait.",
        ),
        img(
            [
                ("hier", "hier"),
                ("cuisine", "la cuisine"),
                ("assiette", "une assiette"),
                ("poulet", "du poulet"),
            ]
        ),
        short("Écrivez six phrases : trois imparfaits, trois présents."),
        aud("Enregistrez les huit modèles, puis votre avant / maintenant."),
    ],
)

S4_PE = lesson(
    "PE — Ma carte hier / aujourd'hui",
    "PE",
    """Objectif
Écrire un mini-portrait d'évolution.

Consigne
Imitez la carte de Joël.

Support — Carte de Joël
Joël Mugisha
Avant, j'étais toujours à la moto. Je n'avais pas le midi à table.
Je voulais un moment calme.
Maintenant, je mange à la Table des Sources. Je suis content.
Joël""",
    [
        tf("Joël mangeait déjà à la Table des Sources, avant.", False, "Avant : à la moto, pas le midi à table."),
        qcm(
            "Que voulait Joël ?",
            ["Un avion", "Un moment calme", "Du café seulement", "Partir au port"],
            1,
            "« un moment calme ».",
        ),
        match(
            [
                ("avant", "moto"),
                ("je n'avais pas", "le midi"),
                ("je voulais", "calme"),
                ("maintenant", "table"),
            ]
        ),
        fill("Complétez :\nMaintenant, je ___ content.", "suis"),
        wo(["Je", "voulais", "un", "moment", "calme", "."]),
        ana("content", "Joël l'est, maintenant, à table."),
        err(
            "Avant je suis toujours à la moto.",
            "Avant, j'étais toujours à la moto.",
            "Avant : j'étais.",
        ),
        img(
            [
                ("hier", "hier"),
                ("table", "une table"),
                ("cuisine", "la cuisine"),
                ("avis", "un avis"),
            ]
        ),
        short("Écrivez cinq lignes : deux avant, deux maintenant, un je voulais."),
        aud("Lisez votre carte, calmement."),
    ],
)

S4_EL = lesson(
    "EL — Imparfait : être, avoir, vouloir",
    "EL",
    """Objectif
Retenir l'imparfait (je/tu/il) pour décrire avant.

Consigne
Apprenez la fiche.

Support — Fiche d'Aline
être : j'étais / tu étais / il était / nous étions
avoir : j'avais / tu avais / elle avait
vouloir : je voulais / il voulait
cuisiner : je cuisinais / on cuisinait
manger : je mangeais / on mangeait / nous mangions
Attention : j'étais (pas je suis au passé). Être : ét- (pas êt-).
Maintenant + présent. Avant + imparfait.
On mangeait (pas on mangions).""",
    [
        tf("On dit « je suisais » à l'imparfait.", False, "J'étais."),
        qcm(
            "Quelle forme est correcte ?",
            ["nous mangeions", "nous mangions", "nous mangerons hier", "nous mangeait"],
            1,
            "Nous mangions (g + i, sans e).",
        ),
        match(
            [
                ("j'étais", "être"),
                ("j'avais", "avoir"),
                ("je voulais", "vouloir"),
                ("je mangeais", "manger"),
            ]
        ),
        fill("Complétez :\nNous ___ au Seuil. (être, avant)", "étions"),
        wo(["Elle", "avait", "peu", "de", "temps", "."]),
        ana("étions", "Le verbe être, à l'imparfait, avec nous."),
        err(
            "On mangions trop vite.",
            "On mangeait trop vite.",
            "On = il : mangeait.",
        ),
        img(
            [
                ("hier", "hier"),
                ("cuisine", "la cuisine"),
                ("poisson", "du poisson"),
                ("table", "une table"),
            ]
        ),
        short("Recopiez la fiche. Écrivez quatre imparfaits : étais, avais, voulais, mangeais."),
        aud("Dites : j'étais, tu étais, j'avais, je voulais, je cuisinais, on mangeait, maintenant je suis."),
    ],
)

# ---------------------------------------------------------------------------
# Séquence 5 — S'habiller à la cour
# vêtements, couleurs, ce / cette / ces
# ---------------------------------------------------------------------------

S5_CO = lesson(
    "CO — À l'Atelier du Tissu",
    "CO",
    """Objectif
Comprendre un achat de vêtements : cette robe, ces sandales, une veste.

Consigne
Qui veut quoi ? Quelle couleur ?

Support — Atelier du Tissu
Dieudonné Hakizimana : Bonjour. Cette chemise ? Elle est bleue.
Léa : Non. Je voudrais cette robe. La robe rouge.
Hawa : Moi, ces sandales. Elles sont simples.
Joël : Une veste, s'il vous plaît. Pas trop chaude.
Rose : J'aime le pagne vert. Il est assez long.
Patrick : Ce pantalon est trop large. L'autre, s'il vous plaît.
Dieudonné : Je vais le prendre de côté. Il faut essayer.""",
    [
        tf("Léa voudrait la robe rouge.", True, "Léa : « cette robe. La robe rouge. »"),
        qcm(
            "Que veut Hawa ?",
            ["Une veste", "Ces sandales", "Le pagne vert", "Ce pantalon"],
            1,
            "Hawa : « ces sandales ».",
        ),
        match(
            [
                ("Léa", "robe rouge"),
                ("Hawa", "sandales"),
                ("Joël", "veste"),
                ("Rose", "pagne vert"),
            ]
        ),
        fill("Complétez :\nJe voudrais ___ robe. (démonstratif, féminin)", "cette"),
        wo(["Cette", "chemise", "est", "bleue", "."]),
        ana("robe", "Léa la veut, rouge, à l'atelier."),
        err(
            "Ce robe est rouge.",
            "Cette robe est rouge.",
            "Robe = féminin : cette.",
        ),
        img(
            [
                ("robe", "une robe"),
                ("chemise", "une chemise"),
                ("sandale", "des sandales"),
                ("veste", "une veste"),
            ]
        ),
        short("Notez quatre vêtements et une couleur."),
        aud(
            "Enregistrez : Cette robe est rouge. Ces sandales sont simples. Ce pantalon est trop large. Je voudrais une veste."
        ),
    ],
)

S5_CE = lesson(
    "CE — Ardoise de l'atelier",
    "CE",
    """Objectif
Lire une liste de vêtements inventée.

Consigne
Lisez l'ardoise.

Support — Ardoise
Atelier du Tissu — Dieudonné
cette chemise bleue
cette robe rouge
ces sandales
une veste
un pantalon (trop large / l'autre)
un pagne vert
une jupe
Inventé pour la cour. Pas un magasin réel.""",
    [
        tf("L'atelier vend un avion.", False, "Vêtements seulement."),
        qcm(
            "Quelle couleur a le pagne ?",
            ["Rouge", "Bleu", "Vert", "Noir"],
            2,
            "Un pagne vert.",
        ),
        match(
            [
                ("chemise", "bleue"),
                ("robe", "rouge"),
                ("pagne", "vert"),
                ("pantalon", "trop large"),
            ]
        ),
        fill("Complétez :\n___ sandales. (démonstratif, pluriel)", "Ces"),
        wo(["Une", "jupe", "s'il", "vous", "plaît", "."]),
        ana("jupe", "Un vêtement, plus court qu'une robe."),
        err(
            "Ces chemise est bleue.",
            "Cette chemise est bleue.",
            "Une chemise : cette.",
        ),
        img(
            [
                ("pagne", "un pagne"),
                ("pantalon", "un pantalon"),
                ("jupe", "une jupe"),
                ("tissu", "du tissu"),
            ]
        ),
        short("Recopiez l'ardoise. Entourez le vêtement que vous choisiriez."),
        aud("Lisez l'ardoise, un vêtement, une pause."),
    ],
)

S5_PO = lesson(
    "PO — Dire cette robe, ces sandales",
    "PO",
    """Objectif
Nommer un vêtement et une couleur.

Consigne
Répétez, puis choisissez un habit.

Support — Modèles de Dieudonné
Cette chemise est bleue.
Cette robe est rouge.
Ces sandales sont simples.
Ce pantalon est trop large.
Cette jupe est courte.
Ce pagne est vert.
Je voudrais une veste.
Il faut essayer.""",
    [
        tf("« Ces » va avec un nom pluriel.", True, "Ces sandales."),
        qcm(
            "Quelle phrase est correcte ?",
            ["ce jupe", "cette jupe", "ces jupe", "cet jupe"],
            1,
            "Cette jupe.",
        ),
        match(
            [
                ("ce", "pantalon, pagne"),
                ("cette", "chemise, robe, jupe"),
                ("ces", "sandales"),
                ("une", "veste"),
            ]
        ),
        fill("Complétez :\nCette chemise est ___. (couleur, féminin)", "bleue"),
        wo(["Je", "voudrais", "une", "veste", "."]),
        ana("veste", "Joël en veut une, pas trop chaude."),
        err(
            "La chemise est bleu.",
            "La chemise est bleue.",
            "Chemise = elle : bleue.",
        ),
        img(
            [
                ("chemise", "une chemise"),
                ("jupe", "une jupe"),
                ("veste", "une veste"),
                ("pagne", "un pagne"),
            ]
        ),
        short("Écrivez six phrases : trois ce/cette/ces, trois couleurs."),
        aud("Enregistrez les huit modèles, puis votre vêtement."),
    ],
)

S5_PE = lesson(
    "PE — Mon choix de tissu",
    "PE",
    """Objectif
Écrire un petit choix de vêtement.

Consigne
Imitez le mot d'Hawa.

Support — Mot d'Hawa
Hawa Diallo
Je voudrais ces sandales. Elles sont simples.
Cette robe est trop rouge pour moi.
Le pagne vert est assez long.
Merci, Dieudonné.
Hawa
Atelier du Tissu""",
    [
        tf("Hawa veut la robe trop rouge.", False, "Trop rouge pour elle. Elle veut les sandales."),
        qcm(
            "Comment est le pagne, d'après Hawa ?",
            ["Trop court", "Assez long", "Bleu", "Large comme un pantalon"],
            1,
            "« assez long ».",
        ),
        match(
            [
                ("sandales", "simples"),
                ("robe", "trop rouge"),
                ("pagne", "assez long"),
                ("merci", "Dieudonné"),
            ]
        ),
        fill("Complétez :\nLe pagne vert est assez ___.", "long"),
        wo(["Ces", "sandales", "sont", "simples", "."]),
        ana("sandales", "Hawa les voudrait, à l'atelier."),
        err(
            "Ces sandales est simples.",
            "Ces sandales sont simples.",
            "Sandales = elles : sont.",
        ),
        img(
            [
                ("sandale", "des sandales"),
                ("robe", "une robe"),
                ("pagne", "un pagne"),
                ("tissu", "du tissu"),
            ]
        ),
        short("Écrivez cinq lignes : je voudrais, cette/ces, une couleur, trop, assez."),
        aud("Lisez votre mot, une phrase, une pause."),
    ],
)

S5_EL = lesson(
    "EL — Vêtements, ce / cette / ces",
    "EL",
    """Objectif
Retenir les vêtements et les démonstratifs.

Consigne
Apprenez la fiche.

Support — Fiche de Dieudonné
ce pantalon / ce pagne
cet (devant voyelle : cet atelier)
cette chemise / cette robe / cette jupe / cette veste
ces sandales
couleurs : bleu / bleue ; vert / verte ; rouge (invariable)
trop large / assez long
Attention : cette (féminin). Ces (pluriel).
Bleue avec e au féminin.
Atelier du Tissu : lieu inventé.""",
    [
        tf("On dit « ce robe ».", False, "Cette robe."),
        qcm(
            "Quelle forme est correcte ?",
            ["un jupe", "une jupe", "une jupon", "un jupe rouge"],
            1,
            "Une jupe.",
        ),
        match(
            [
                ("un", "pantalon, pagne"),
                ("une", "chemise, robe, jupe, veste"),
                ("des", "sandales"),
                ("cette", "féminin singulier"),
            ]
        ),
        fill("Complétez :\n___ pantalon est trop large.", "Ce"),
        wo(["Cette", "veste", "est", "simple", "."]),
        ana("pagne", "Le tissu long, souvent vert, chez Dieudonné."),
        err(
            "La jupe est vert.",
            "La jupe est verte.",
            "Jupe = elle : verte.",
        ),
        img(
            [
                ("pantalon", "un pantalon"),
                ("veste", "une veste"),
                ("jupe", "une jupe"),
                ("chemise", "une chemise"),
            ]
        ),
        short("Recopiez la fiche. Écrivez quatre phrases : ce, cette, ces, une couleur."),
        aud("Dites : ce pantalon, cette robe, ces sandales, une veste, un pagne vert, trop large, assez long."),
    ],
)

# ---------------------------------------------------------------------------
# Séquence 6 — Dire son avis
# trop / assez / vraiment ; appréciation + / −
# ---------------------------------------------------------------------------

S6_CO = lesson(
    "CO — Autour du thé, on dit",
    "CO",
    """Objectif
Comprendre un avis : vraiment, trop, assez, un peu.

Consigne
Qui trouve ça bon ? Qui n'aime pas trop ?

Support — Banc du figuier
Léa : La soupe est vraiment bonne.
Marc : Le poulet est assez chaud. Parfait.
Joël : Le thé est un peu trop sucré pour moi.
Hawa : Moi, je trouve ça franchement original. J'adore.
Patrick : La veste est trop chaude, non ?
Dieudonné : Un peu, oui. L'autre est mieux.
Aline : Ce n'est pas mal. C'est calme. J'aime bien.""",
    [
        tf("Léa trouve la soupe vraiment bonne.", True, "Léa : « vraiment bonne »."),
        qcm(
            "Que pense Joël du thé ?",
            ["Vraiment bon", "Un peu trop sucré", "Pas assez chaud", "Ridicule"],
            1,
            "Joël : « un peu trop sucré ».",
        ),
        match(
            [
                ("Léa", "vraiment bonne"),
                ("Marc", "assez chaud"),
                ("Joël", "trop sucré"),
                ("Hawa", "franchement original"),
            ]
        ),
        fill("Complétez :\nLa veste est trop ___.", "chaude"),
        wo(["C'est", "vraiment", "bon", "."]),
        ana("avis", "Ce qu'on pense : bon, trop, assez…"),
        err(
            "Le thé est trop de sucré.",
            "Le thé est trop sucré.",
            "Trop + adjectif (pas trop de + adj.).",
        ),
        img(
            [
                ("avis", "un avis"),
                ("trop", "trop"),
                ("the", "du thé"),
                ("veste", "une veste"),
            ]
        ),
        short("Notez quatre avis (positif ou négatif)."),
        aud(
            "Enregistrez : C'est vraiment bon. C'est assez chaud. C'est un peu trop sucré. Ce n'est pas mal. J'aime bien."
        ),
    ],
)

S6_CE = lesson(
    "CE — Feuille des avis",
    "CE",
    """Objectif
Lire des avis courts sur la cour.

Consigne
Lisez la feuille.

Support — Feuille du Seuil
Dire son avis
Table des Sources — vraiment bonne, assez calme
Thé — un peu trop sucré (Joël)
Pagne vert — franchement original (Hawa)
Veste — trop chaude (Patrick)
Radio Figuier — ce n'est pas mal
Atelier — j'aime bien
Inventé sous le figuier. Pas un magazine réel.""",
    [
        tf("Patrick trouve la veste trop chaude.", True, "Veste — trop chaude (Patrick)."),
        qcm(
            "Qui trouve le pagne franchement original ?",
            ["Joël", "Patrick", "Hawa", "Félicie"],
            2,
            "Hawa.",
        ),
        match(
            [
                ("table", "vraiment bonne"),
                ("thé", "trop sucré"),
                ("pagne", "original"),
                ("radio", "pas mal"),
            ]
        ),
        fill("Complétez :\nJ'aime ___.", "bien"),
        wo(["Ce", "n'est", "pas", "mal", "."]),
        ana("original", "Hawa trouve le pagne ainsi : pas comme les autres."),
        err(
            "C'est trop de chaud.",
            "C'est trop chaud.",
            "Trop + adjectif.",
        ),
        img(
            [
                ("avis", "un avis"),
                ("trop", "trop"),
                ("pagne", "un pagne"),
                ("table", "une table"),
            ]
        ),
        short("Recopiez quatre avis. Ajoutez le vôtre avec vraiment ou trop."),
        aud("Lisez la feuille, un avis, une pause."),
    ],
)

S6_PO = lesson(
    "PO — Dire vraiment, trop, assez",
    "PO",
    """Objectif
Donner un avis positif ou négatif.

Consigne
Répétez, puis donnez votre avis sur un plat ou un vêtement.

Support — Modèles d'Aline
C'est vraiment bon.
C'est assez calme.
C'est un peu trop sucré.
C'est trop chaud.
Ce n'est pas mal.
J'aime bien.
Je n'aime pas trop.
C'est franchement original.""",
    [
        tf("« Je n'aime pas trop » est un avis plutôt négatif.", True, "Moins fort que je déteste."),
        qcm(
            "Quelle phrase est positive ?",
            ["C'est trop chaud", "Je n'aime pas trop", "C'est vraiment bon", "C'est un peu trop sucré"],
            2,
            "Vraiment bon.",
        ),
        match(
            [
                ("vraiment", "positif fort"),
                ("assez", "suffisant"),
                ("trop", "excessif"),
                ("pas mal", "plutôt bien"),
            ]
        ),
        fill("Complétez :\nJe n'aime pas ___.", "trop"),
        wo(["C'est", "assez", "calme", "."]),
        ana("vraiment", "Pour renforcer : c'est … bon."),
        err(
            "C'est assez de calme. (avis sur le lieu)",
            "C'est assez calme.",
            "Assez + adjectif.",
        ),
        img(
            [
                ("avis", "un avis"),
                ("trop", "trop"),
                ("assiette", "une assiette"),
                ("robe", "une robe"),
            ]
        ),
        short("Écrivez six avis : deux vraiment, deux trop, un assez, un j'aime bien."),
        aud("Enregistrez les huit modèles, puis deux avis personnels."),
    ],
)

S6_PE = lesson(
    "PE — Mon avis du jour",
    "PE",
    """Objectif
Écrire quatre avis.

Consigne
Imitez le mot d'Aline.

Support — Mot d'Aline
Aline Uwase
La soupe est vraiment bonne.
Le thé est un peu trop sucré.
L'atelier est assez calme.
La veste ? Je n'aime pas trop : trop chaude.
Sinon, j'aime bien le Seuil.
Aline""",
    [
        tf("Aline aime trop la veste.", False, "Elle n'aime pas trop : trop chaude."),
        qcm(
            "Comment Aline trouve-t-elle l'atelier ?",
            ["Trop chaud", "Assez calme", "Ridicule", "Fermé"],
            1,
            "« assez calme ».",
        ),
        match(
            [
                ("soupe", "vraiment bonne"),
                ("thé", "trop sucré"),
                ("atelier", "assez calme"),
                ("veste", "je n'aime pas trop"),
            ]
        ),
        fill("Complétez :\nLa soupe est vraiment ___.", "bonne"),
        wo(["J'aime", "bien", "le", "Seuil", "."]),
        ana("calme", "Pas trop de bruit, à l'atelier."),
        err(
            "La soupe est vraiment bon.",
            "La soupe est vraiment bonne.",
            "Soupe = elle : bonne.",
        ),
        img(
            [
                ("avis", "un avis"),
                ("assiette", "une assiette"),
                ("veste", "une veste"),
                ("trop", "trop"),
            ]
        ),
        short("Écrivez cinq lignes : vraiment, trop, assez, je n'aime pas trop, j'aime bien."),
        aud("Lisez votre mot d'avis."),
    ],
)

S6_EL = lesson(
    "EL — Trop, assez, vraiment",
    "EL",
    """Objectif
Retenir les mots pour un avis A1.

Consigne
Apprenez la fiche.

Support — Fiche d'Aline
positif : vraiment bon / j'aime bien / ce n'est pas mal / franchement original
degré : assez calme / trop chaud / un peu trop sucré
négatif : je n'aime pas trop
trop + adjectif : trop sucré, trop chaude
assez + adjectif : assez long, assez calme
trop de + nom : trop de sucre
Attention : trop chaude (accord). Vraiment bonne (accord).
Pas trop de + adjectif.""",
    [
        tf("On dit « trop de chaud » pour la veste.", False, "Trop chaude (adjectif)."),
        qcm(
            "Quelle phrase est correcte ?",
            ["c'est trop de sucré", "c'est trop sucré", "c'est trop sucres", "c'est de trop sucré"],
            1,
            "Trop sucré.",
        ),
        match(
            [
                ("vraiment", "renforce le positif"),
                ("assez", "suffit"),
                ("trop", "trop fort"),
                ("j'aime bien", "positif simple"),
            ]
        ),
        fill("Complétez :\nC'est un peu trop ___. (sucre, adjectif)", "sucré"),
        wo(["Je", "n'aime", "pas", "trop", "."]),
        ana("assez", "Ni trop ni trop peu : ça suffit."),
        err(
            "La veste est trop chaud.",
            "La veste est trop chaude.",
            "Veste = elle : chaude.",
        ),
        img(
            [
                ("trop", "trop"),
                ("avis", "un avis"),
                ("veste", "une veste"),
                ("the", "du thé"),
            ]
        ),
        short("Recopiez la fiche. Écrivez quatre avis : vraiment, assez, trop, j'aime bien."),
        aud("Dites : vraiment bon, assez calme, trop chaud, un peu trop sucré, ce n'est pas mal, j'aime bien, je n'aime pas trop."),
    ],
)

SEQUENCES = [
    {"title": "La table du Seuil", "lessons": [S1_CO, S1_CE, S1_PO, S1_PE, S1_EL]},
    {"title": "Courses au marché", "lessons": [S2_CO, S2_CE, S2_PO, S2_PE, S2_EL]},
    {"title": "On compare", "lessons": [S3_CO, S3_CE, S3_PO, S3_PE, S3_EL]},
    {"title": "Autrefois, maintenant", "lessons": [S4_CO, S4_CE, S4_PO, S4_PE, S4_EL]},
    {"title": "S'habiller à la cour", "lessons": [S5_CO, S5_CE, S5_PO, S5_PE, S5_EL]},
    {"title": "Dire son avis", "lessons": [S6_CO, S6_CE, S6_PO, S6_PE, S6_EL]},
]
