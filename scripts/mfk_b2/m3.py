"""B2 Module 3 — Une culture commune (univers Seuil des Sources)."""

from factory import L

IMG = "mfk-b2-m3"
IMG_DIR = IMG

MODULE = {
    "title": "B2 — Une culture commune",
    "description": (
        "Grande étape B2-3 : comparer et résumer des œuvres inventées, "
        "débattre et dresser des portraits (Mado, Sami, Aline), poser un "
        "problème culturel et des solutions, parler d'une tendance et d'une "
        "création, puis rédiger une critique et un manifeste — Saison des Voix, "
        "pièce « La cour n'oublie pas », livre « Le figuier n'oublie pas », "
        "Veillée des lampions et tambour de Sami, au Seuil des Sources "
        "(Rukiri-Nord)."
    ),
}

_PICS = [
    "une comparaison",
    "un avis",
    "un résumé",
    "une saison",
    "un portrait",
    "un débat",
    "un pupitre",
    "un cadre",
    "un relief",
    "un problème",
    "une solution",
    "une scène",
    "un pronom",
    "un registre",
    "une création",
    "un tissu",
    "un manifeste",
    "un bilan",
    "un livre",
    "un tambour",
    "un masque",
    "un micro",
    "une critique",
    "une danse",
    "une radio",
    "un théâtre",
    "un calendrier",
    "une œuvre",
    "un goût",
    "un cœur",
]


def _pw(start: int) -> list[str]:
    return [_PICS[(start + i) % 30] for i in range(4)]


def _l(comp, title, obj, cons, st, sp, **kw):
    return L(IMG, comp, title, obj, cons, st, sp, **kw)


# ---------------------------------------------------------------------------
# Séquence 1 — Préférences et résumés
# ---------------------------------------------------------------------------

S1 = [
    _l(
        "CO",
        "CO — Plus juste que spectaculaire",
        "Repérer comparatifs et superlatifs ; suivre un avis argumenté sur deux œuvres inventées.",
        "Lisez le dialogue. Quelle œuvre préfère-t-on, et selon quels critères ?",
        "Table des Sources, avant la Saison des Voix",
        """Aline : Cette année, la Saison des Voix ouvre sur deux œuvres : la pièce « La cour n'oublie pas » et le livre de Mado, « Le figuier n'oublie pas ».
Léa : La pièce m'a paru plus vive que le livre, mais le livre est plus dense que la pièce.
Patrick : Je trouve le tambour de Sami aussi présent que les répliques. Ce n'est pas un décor : c'est un personnage.
Marc : Attention aux formules paresseuses : on ne dit pas « plus bon ». On dit « meilleur ». Le meilleur acte, ce n'est pas le plus bruyant.
Hawa : Pour moi, le livre est moins spectaculaire que la pièce, et c'est précisément ce que je préfère.
Joël : Radio Figuier a lu le résumé le plus court. Trop court : on n'entendait plus le doute de la cour.
Rose : Le tissu ocre de la scène est aussi soigné que les phrases de Mado. L'œil compte autant que l'oreille.
Solange : Le public le plus attentif n'était pas le plus nombreux. Quelques bancs suffisent, si l'on écoute vraiment.
Karim : Je résumerais ainsi : une cour qui refuse d'oublier, un figuier qui garde les noms.
Lila : Le mieux, ce n'est pas d'applaudir plus fort. C'est de pouvoir raconter l'œuvre le lendemain, sans trahir.
Mado : Si l'on me demande mon avis, le livre n'est pas « plus bien » écrit : il est autrement écrit. Mieux, parfois ; moins clair, parfois.
Sami : Trois frappes valent mieux qu'un discours trop long. Le silence, lui, est le plus difficile à tenir.
Dieudonné : La mise en scène la moins chargée laisse voir le figuier. C'est mon critère.
Yvette : Donnez votre avis, mais justifiez-le. « J'aime » ne suffit plus à ce niveau.""",
        tf_item=(
            "Marc refuse la formule « plus bon » et rappelle « meilleur ».",
            True,
            "Marc : on ne dit pas « plus bon ». On dit « meilleur ».",
        ),
        qcm_item=(
            "Selon Hawa, le livre est…",
            [
                "plus spectaculaire que la pièce",
                "moins spectaculaire que la pièce",
                "aussi bruyant que le marché",
                "le plus vide de la saison",
            ],
            1,
            "Hawa : « moins spectaculaire que la pièce ».",
        ),
        pairs=[
            ("plus vive que", "la pièce / le livre"),
            ("aussi présent que", "le tambour / les répliques"),
            ("le plus attentif", "le public des bancs"),
            ("mieux", "trois frappes / un long discours"),
        ],
        fill_item=("On ne dit pas « plus bon » : on dit ___.", "meilleur"),
        words=["Le", "livre", "est", "plus", "dense", "que", "la", "pièce", "."],
        anagram=("meilleur", "Forme attendue à la place de « plus bon », pour un acte ou un livre."),
        error=(
            "C'est le livre plus bon de la saison, et la cour en discute encore sous le figuier.",
            "C'est le meilleur livre de la saison, et la cour en discute encore sous le figuier.",
            "Meilleur remplace plus bon.",
        ),
        pic_start=0,
        pic_words=_pw(0),
        short_p="Notez quatre comparaisons entendues et l'avis que vous défendriez, avec un critère.",
        audio="Enregistrez : La pièce est plus vive que le livre. Le livre est plus dense. Le mieux, c'est de pouvoir raconter.",
    ),
    _l(
        "CE",
        "CE — Deux résumés, un avis",
        "Lire des résumés d'œuvres inventées et un avis justifié (comparatifs, superlatifs).",
        "Lisez la fiche de la Saison des Voix, sans aller trop vite.",
        "Fiche d'Aline, Salle des Herbes",
        """Saison des Voix — deux œuvres à tenir ensemble
1. Pièce « La cour n'oublie pas » : sous le figuier, une assemblée refuse d'effacer un nom. Le tambour de Sami scande les silences. La mise en scène est plus nue que celle de l'an passé.
2. Livre « Le figuier n'oublie pas » (Mado) : les mêmes faits, autrement. Moins de gestes, plus de phrases. Le chapitre le plus dur n'est pas le plus long.
3. Résumer, ce n'est pas tout raconter. C'est garder le conflit, le lieu, le geste qui reste.
4. La pièce est plus collective que le livre ; le livre est plus intérieur que la pièce.
5. Le public le moins nombreux, jeudi, a été le plus précis dans les questions.
6. Avis d'Aline : le meilleur critère n'est pas le bruit des lampions. C'est la phrase que l'on peut encore dire le lendemain.
7. Avis de Lila : Radio Figuier lira le résumé le plus court le matin, le plus complet le soir.
8. Ne dites pas « plus bien » : dites « mieux ». Ne dites pas « plus bon » : dites « meilleur ».
9. Comparer n'est pas classer pour humilier. C'est éclairer une préférence.
10. Karim : aussi fidèle l'une que l'autre, si l'on accepte deux langages.
11. Rose : le tissu de scène est aussi éloquent qu'une réplique, parfois mieux.
12. Solange : le tampon du Bureau n'évalue pas une œuvre. Il date une saison.
13. Donnez votre avis en trois mouvements : ce que l'œuvre fait, ce qu'elle refuse, ce qu'elle vous laisse.
14. Rukiri-Nord — à relire avant le débat du banc.""",
        tf_item=(
            "Résumer, d'après la fiche, consiste à tout raconter.",
            False,
            "« Résumer, ce n'est pas tout raconter. »",
        ),
        qcm_item=(
            "Quel est le meilleur critère, selon Aline ?",
            [
                "Le bruit des lampions",
                "La phrase que l'on peut encore dire le lendemain",
                "Le nombre de spectateurs",
                "La longueur du chapitre",
            ],
            1,
            "Aline : pas le bruit des lampions, mais la phrase du lendemain.",
        ),
        pairs=[
            ("plus collective", "la pièce"),
            ("plus intérieur", "le livre"),
            ("mieux", "à la place de « plus bien »"),
            ("aussi fidèle", "les deux œuvres / Karim"),
        ],
        fill_item=("Ne dites pas « plus bien » : dites ___.", "mieux"),
        words=["La", "pièce", "est", "plus", "collective", "que", "le", "livre", "."],
        anagram=("resume", "Texte court qui garde le conflit et le geste, sans tout déplier. (sans accent)"),
        error=(
            "Cette mise en scène est plus bien pensée que l'an passé, et le public l'a dit sans hausser le ton.",
            "Cette mise en scène est mieux pensée que l'an passé, et le public l'a dit sans hausser le ton.",
            "Mieux remplace plus bien.",
        ),
        pic_start=1,
        pic_words=_pw(1),
        short_p="Recopiez les deux résumés en six lignes chacun, puis ajoutez votre avis en trois phrases.",
        audio="Lisez la fiche à voix haute, sans aller trop vite.",
    ),
    _l(
        "PO",
        "PO — Dire plus, moins, le mieux",
        "Employer à l'oral comparatifs et superlatifs pour un avis culturel.",
        "Répétez les modèles, puis donnez votre avis sur une œuvre de la Saison des Voix.",
        "Modèles d'Aline et de Lila, banc du figuier",
        """La pièce est plus vive que le livre.
Le livre est moins spectaculaire que la pièce.
Le tambour est aussi présent que les répliques.
C'est le meilleur acte, pas le plus long.
Le public le plus attentif n'était pas le plus nombreux.
Je préfère le livre, parce qu'il est plus intérieur.
Je résumerais en une phrase : la cour refuse d'oublier.
Le mieux, c'est de pouvoir raconter sans trahir.
Cette scène est mieux tenue que la précédente.
Lila : un avis sans critère n'est qu'un bruit.
Marc : « j'aime » ouvre ; « parce que » tient.
Mado : comparez les langages, pas les personnes.
Sami : trois frappes valent mieux qu'un commentaire trop sûr.
Yvette : le superlatif n'est pas une couronne. C'est une responsabilité.""",
        tf_item=(
            "« Le mieux » porte sur une manière, pas sur un nom de qualité.",
            True,
            "Le mieux = ce qui est préférable comme façon de faire.",
        ),
        qcm_item=(
            "Quelle phrase est correcte ?",
            [
                "C'est le plus bon acte",
                "C'est le meilleur acte, pas le plus long",
                "C'est le meilleur acte, pas le plus bon",
                "C'est le plus bien acte",
            ],
            1,
            "Meilleur + nom ; plus long reste régulier.",
        ),
        pairs=[
            ("plus vive que", "comparatif d'infériorité inverse"),
            ("aussi présent que", "égalité"),
            ("le plus attentif", "superlatif"),
            ("mieux tenue", "adverbe / manière"),
        ],
        fill_item=("C'est le ___ acte, pas le plus long.", "meilleur"),
        words=["Je", "préfère", "le", "livre", "parce", "qu'il", "est", "plus", "intérieur", "."],
        anagram=("mieux", "Adverbe attendu à la place de « plus bien », pour une scène tenue."),
        error=(
            "Le public le plus nombreux n'était pas le plus attentif, et c'est le plus bon critère pour moi.",
            "Le public le plus nombreux n'était pas le plus attentif, et c'est le meilleur critère pour moi.",
            "Meilleur devant critère, pas plus bon.",
        ),
        pic_start=2,
        pic_words=_pw(2),
        short_p="Écrivez huit phrases : deux plus, deux moins, deux aussi, un superlatif, un mieux.",
        audio="Enregistrez les six premiers modèles, puis un avis de quatre phrases à vous.",
    ),
    _l(
        "PE",
        "PE — Mon résumé argumenté",
        "Écrire le résumé d'une œuvre inventée et un avis justifié (comparatifs, superlatifs).",
        "Imitez la note de Léa Niyonzima, sans aller trop vite.",
        "Note de Léa, cahier de la Saison",
        """Léa Niyonzima — Seuil des Sources, Rukiri-Nord
Je résume d'abord « La cour n'oublie pas » : une assemblée refuse d'effacer un nom, et le tambour de Sami tient le silence comme on tient une corde.
Le livre de Mado, « Le figuier n'oublie pas », reprend le même nœud, mais il est plus intérieur que la pièce, moins spectaculaire, parfois mieux.
Je ne dirai pas que l'un est plus bon : le meilleur, pour moi, dépend du critère. Si je cherche le geste, je choisis la pièce ; si je cherche la phrase qui reste, je choisis le livre.
La mise en scène de cette saison est plus nue que celle de l'an passé, et c'est précisément ce qui la rend plus juste.
Le public le plus attentif n'était pas le plus nombreux. Quelques bancs ont suffi.
Mon avis : le mieux n'est pas de classer. C'est de pouvoir raconter les deux œuvres sans les confondre.
Aussi fidèle l'une que l'autre, si l'on accepte deux langages.
Je tiens à ce que Radio Figuier lise un résumé court le matin, un avis le soir, jamais l'inverse.
Si l'on me demande un superlatif, je dirai : le public le plus juste n'était pas le plus nombreux.
Comparer n'est pas humilier. Un avis sans critère n'est qu'un bruit, Aline l'a dit, et je le répète.
À relire avant le débat.
Léa""",
        tf_item=(
            "Léa classe les deux œuvres pour en humilier une.",
            False,
            "« le mieux n'est pas de classer. »",
        ),
        qcm_item=(
            "Si Léa cherche la phrase qui reste, que choisit-elle ?",
            [
                "Le marché seulement",
                "Le livre de Mado",
                "Le tampon de Solange",
                "Le plus long acte",
            ],
            1,
            "« si je cherche la phrase qui reste, je choisis le livre. »",
        ),
        pairs=[
            ("plus intérieur", "le livre / la pièce"),
            ("plus nue", "la mise en scène"),
            ("le plus attentif", "le public"),
            ("aussi fidèle", "deux langages"),
        ],
        fill_item=("Je ne dirai pas que l'un est plus bon : je dirai le ___.", "meilleur"),
        words=["Le", "mieux", "n'est", "pas", "de", "classer", "."],
        anagram=("densite", "Qualité d'un livre plus chargé de phrases que de gestes. (sans accent)"),
        error=(
            "Je trouve le livre plus bon que la pièce, et je peux pourtant raconter les deux sans les confondre.",
            "Je trouve le livre meilleur que la pièce, et je peux pourtant raconter les deux sans les confondre.",
            "Meilleur, pas plus bon.",
        ),
        pic_start=3,
        pic_words=_pw(3),
        short_p="Imitez : douze à quinze lignes, un résumé, un avis, trois comparatifs, un superlatif.",
        audio="Lisez votre note, une phrase, une pause, sans aller trop vite.",
    ),
    _l(
        "EL",
        "EL — Comparatifs et superlatifs de l'avis",
        "Retenir les formes régulières et les irréguliers meilleur / mieux pour un jugement culturel.",
        "Apprenez la fiche.",
        "Fiche du carnet d'Aline",
        """Comparatif : plus + adj. + que / moins + adj. + que / aussi + adj. + que
plus vive que, moins spectaculaire que, aussi présent que
Superlatif : le / la / les + plus / moins + adj. : le plus attentif, la moins chargée
Irréguliers (à ne pas rater) :
bon → meilleur / le meilleur (jamais plus bon / le plus bon)
bien → mieux / le mieux (jamais plus bien / le plus bien)
petit → plus petit ou moindre (moindre : registre plus soutenu)
Mieux porte sur une manière : cette scène est mieux tenue.
Meilleur porte sur un nom : le meilleur acte, le meilleur critère.
Résumer : garder le conflit, le lieu, le geste ; ne pas tout déplier.
Donner son avis : ce que l'œuvre fait + ce qu'elle refuse + ce qu'elle laisse.
Comparer n'est pas humilier. Le superlatif engage : on doit pouvoir le justifier.
Attention : de plus en plus / de moins en moins (évolution, pas un duel).
Bien que + subjonctif : bien que ce soit moins clair, je tiens au livre.
À + le = au résumé ; de + le = du public.""",
        tf_item=(
            "On peut dire « le plus bon acte » au Seuil.",
            False,
            "On dit le meilleur acte.",
        ),
        qcm_item=(
            "« Cette scène est mieux tenue » emploie…",
            [
                "un adjectif irrégulier",
                "un adverbe de manière",
                "un superlatif de petit",
                "un partitif",
            ],
            1,
            "Mieux = adverbe (manière).",
        ),
        pairs=[
            ("plus / moins / aussi … que", "comparatif"),
            ("le plus / le moins", "superlatif"),
            ("meilleur", "à la place de plus bon"),
            ("mieux", "à la place de plus bien"),
        ],
        fill_item=("Cette scène est ___ tenue que la précédente.", "mieux"),
        words=["Le", "meilleur", "critère", "n'est", "pas", "le", "bruit", "."],
        anagram=("egalite", "Rapport aussi… que : ni plus, ni moins. (sans accent)"),
        error=(
            "C'est la mise en scène le plus nue de la saison, et le figuier s'en trouve plus lisible.",
            "C'est la mise en scène la plus nue de la saison, et le figuier s'en trouve plus lisible.",
            "Accord : la plus nue, avec mise en scène.",
        ),
        pic_start=4,
        pic_words=_pw(4),
        short_p="Construisez dix phrases : quatre comparatifs, trois superlatifs, deux mieux, un meilleur.",
        audio="Enregistrez la fiche, puis six formes : plus que, moins que, aussi que, le plus, meilleur, mieux.",
    ),
]


# ---------------------------------------------------------------------------
# Séquence 2 — Débattre et portraits
# ---------------------------------------------------------------------------

S2 = [
    _l(
        "CO",
        "CO — Celles et ceux dont on parle",
        "Suivre un débat et des portraits ; pronoms relatifs pour éviter les répétitions.",
        "Lisez le dialogue. Qui est Mado, Sami, Aline, et quels relatifs relient les phrases ?",
        "Pupitre d'Aline, cercle des voix",
        """Aline : Évitons de répéter les noms. Disons : Mado, qui a écrit « Le figuier n'oublie pas », tient le banc du soir.
Léa : C'est le livre que j'ai relu deux fois, celui dont les phrases restent après le thé.
Patrick : La cour où l'on joue « La cour n'oublie pas » n'est pas un théâtre fermé. C'est le Seuil.
Marc : Sami, à qui l'on doit les trois frappes, n'explique jamais trop. Le tambour dont il se sert suffit.
Hawa : Aline, avec laquelle on prépare la saison, refuse les portraits trop lisses.
Joël : Le pupitre sur lequel elle pose le cahier est le même que jeudi dernier.
Rose : Les tissus auxquels je pense pour le portrait de Mado sont ocre, pas d'apparat.
Solange : Le dossier duquel le Bureau garde une copie, c'est la fiche des voix, pas une biographie officielle.
Karim : Débattre, ce n'est pas vaincre. C'est relier les faits dont on n'est pas sûr.
Lila : Radio Figuier présentera trois portraits : celle qui écrit, celui qui frappe, celle qui tient le pupitre.
Mado : Le figuier sous lequel j'écris n'est pas une métaphore. C'est un arbre, et il a des racines.
Sami : Les soirs pendant lesquels on se tait valent ceux pendant lesquels on parle.
Dieudonné : Le masque auquel on a renoncé cette saison laisse voir les visages.
Yvette : Un portrait qui n'admet aucune ombre n'est pas un portrait. C'est une affiche.""",
        tf_item=(
            "Aline accepte les portraits trop lisses, d'après Hawa.",
            False,
            "Hawa : Aline « refuse les portraits trop lisses ».",
        ),
        qcm_item=(
            "Que présentera Radio Figuier, selon Lila ?",
            [
                "Un concours de clameurs",
                "Trois portraits : celle qui écrit, celui qui frappe, celle qui tient le pupitre",
                "Un tampon sans noms",
                "La fermeture du figuier",
            ],
            1,
            "Lila : trois portraits, trois rôles.",
        ),
        pairs=[
            ("qui", "Mado / sujet"),
            ("dont", "les phrases / le tambour"),
            ("où", "la cour / le Seuil"),
            ("auquel / duquel", "tissus / dossier"),
        ],
        fill_item=("C'est le livre ___ les phrases restent après le thé.", "dont"),
        words=["Mado", "qui", "a", "écrit", "le", "livre", "tient", "le", "banc", "."],
        anagram=("dont", "Relatif pour parler de quelque chose, à la place d'un de répété."),
        error=(
            "Voici le livre que je parle encore ce soir, et le banc où nous l'avons ouvert reste ocre.",
            "Voici le livre dont je parle encore ce soir, et le banc où nous l'avons ouvert reste ocre.",
            "Parler de → dont.",
        ),
        pic_start=5,
        pic_words=_pw(5),
        short_p="Notez six relatifs entendus et le nom qu'ils reprennent.",
        audio="Enregistrez : Mado qui a écrit. Le livre que j'ai relu. Celui dont les phrases restent. La cour où l'on joue.",
    ),
    _l(
        "CE",
        "CE — Trois portraits du Seuil",
        "Lire des portraits liés par des relatifs (qui, que, dont, où, lequel, auquel, duquel).",
        "Lisez les portraits, sans aller trop vite.",
        "Cahier des voix, Table des Sources",
        """Portraits — Saison des Voix (inventés, Seuil des Sources)
Mado : celle qui écrit « Le figuier n'oublie pas ». Le livre qu'elle relit à voix basse n'est jamais tout à fait le même. Les ratures dont elle s'occupe valent les phrases qu'elle garde. La cour où elle s'assoit n'attend pas une héroïne : elle attend une voix juste.
Sami Niyonteze : celui à qui l'on doit les trois frappes. Le tambour dont il se sert n'accompagne pas : il discute. Les soirs pendant lesquels il se tait pèsent autant que ceux pendant lesquels il joue. Le rythme auquel la pièce se fie vient de lui, pas d'un orchestre d'ailleurs.
Aline Uwase : celle avec laquelle on tient la saison. Le pupitre sur lequel elle pose le cahier n'est pas un trône. Les débats auxquels elle invite restent ouverts. Le dossier duquel le Bureau garde une copie porte des dates, pas des couronnes.
Ce qui relie les trois, c'est le refus de l'affiche trop lisse.
Léa : un portrait qui n'admet aucune ombre n'éclaire personne.
Patrick : la personne de laquelle on parle trop vite devient un masque.
Rose : les tissus auxquels je pense pour Mado sont ocre, comme la terre du Seuil.
Karim : débattre des portraits, c'est déjà les corriger.
Lila : on lira ces lignes au fil de Radio Figuier, sans musique d'apparat.
Karim : débattre d'un portrait, c'est déjà refuser l'affiche.
Yvette : un relatif bien choisi évite la répétition ; il n'invente pas une légende.
Rukiri-Nord — à ne pas coller au marché comme une étiquette.""",
        tf_item=(
            "Le tambour de Sami, d'après le texte, se contente d'accompagner.",
            False,
            "« n'accompagne pas : il discute. »",
        ),
        qcm_item=(
            "Que porte le dossier duquel le Bureau garde une copie ?",
            [
                "Des couronnes",
                "Des dates, pas des couronnes",
                "Les ratures de Mado seulement",
                "Un orchestre d'ailleurs",
            ],
            1,
            "« porte des dates, pas des couronnes. »",
        ),
        pairs=[
            ("qui", "celle / celui — sujet"),
            ("dont", "ratures / tambour"),
            ("auquel", "rythme / débats"),
            ("duquel", "dossier / Bureau"),
        ],
        fill_item=("Le tambour ___ Sami se sert n'accompagne pas.", "dont"),
        words=["La", "cour", "où", "elle", "s'assoit", "attend", "une", "voix", "juste", "."],
        anagram=("portrait", "Texte qui dessine une personne du Seuil sans en faire une affiche."),
        error=(
            "Voici le dossier que le Bureau garde une copie, et les dates y restent plus utiles que les couronnes.",
            "Voici le dossier duquel le Bureau garde une copie, et les dates y restent plus utiles que les couronnes.",
            "Garder une copie de → duquel.",
        ),
        pic_start=6,
        pic_words=_pw(6),
        short_p="Recopiez un portrait et soulignez tous les relatifs. Ajoutez deux phrases à vous.",
        audio="Lisez les trois portraits, sans aller trop vite.",
    ),
    _l(
        "PO",
        "PO — Dire qui, que, dont, où, lequel",
        "Employer à l'oral les relatifs pour relier un débat et un portrait, sans répéter.",
        "Répétez, puis dressez le portrait d'une personne du Seuil.",
        "Modèles de Marc et d'Aline",
        """Mado, qui écrit, tient le banc du soir.
Le livre que j'ai relu reste ouvert.
Le tambour dont Sami se sert discute.
La cour où l'on joue n'est pas fermée.
Le pupitre sur lequel Aline pose le cahier est simple.
Les débats auxquels elle invite restent ouverts.
Le dossier duquel le Bureau garde une copie porte des dates.
Celle à qui l'on doit la saison refuse l'affiche.
Patrick : répéter le nom à chaque phrase fatigue l'oreille.
Léa : un relatif bien placé tient lieu de politesse.
Hawa : « dont » reprend un de ; « que » reprend un objet direct.
Joël : « où » peut être un lieu ou un moment.
Rose : « lequel » s'accorde et suit souvent une préposition.
Yvette : débattre, c'est choisir le relatif juste, pas le plus savant.""",
        tf_item=(
            "« Dont » reprend souvent une construction avec de.",
            True,
            "Hawa : dont reprend un de.",
        ),
        qcm_item=(
            "Quelle phrase est correcte ?",
            [
                "Le livre que je parle",
                "Le livre dont je parle",
                "Le livre où je parle de lui seulement",
                "Le livre lequel je parle",
            ],
            1,
            "Parler de → dont.",
        ),
        pairs=[
            ("qui", "sujet"),
            ("que", "objet direct"),
            ("dont", "reprise de de"),
            ("auquel / duquel", "à + lequel / de + lequel"),
        ],
        fill_item=("Les débats ___ elle invite restent ouverts.", "auxquels"),
        words=["Le", "tambour", "dont", "Sami", "se", "sert", "discute", "."],
        anagram=("relatif", "Mot qui reprend un nom déjà dit, pour éviter de le répéter."),
        error=(
            "Voici le débat que je pense depuis jeudi, et Aline en garde encore le fil sous le figuier.",
            "Voici le débat auquel je pense depuis jeudi, et Aline en garde encore le fil sous le figuier.",
            "Penser à → auquel.",
        ),
        pic_start=7,
        pic_words=_pw(7),
        short_p="Écrivez sept phrases : qui, que, dont, où, lequel, auquel, duquel — un portrait en fil.",
        audio="Enregistrez les huit premiers modèles, puis un portrait de six phrases à vous.",
    ),
    _l(
        "PE",
        "PE — Mon portrait du Seuil",
        "Écrire le portrait argumenté d'une personnalité inventée, avec des relatifs variés.",
        "Imitez le portrait de Sami par Patrick Habimana, sans aller trop vite.",
        "Portrait de Sami, cahier bleu",
        """Patrick Habimana — Seuil des Sources
Sami Niyonteze, qui ouvre la pièce par trois frappes, n'est pas un décor que l'on range après la saison.
Le tambour dont il se sert discute avec les répliques ; la cour où il s'installe n'a pas besoin d'estrade.
Les soirs pendant lesquels il se tait pèsent autant que ceux pendant lesquels il joue, et c'est précisément ce que j'admire.
Le rythme auquel « La cour n'oublie pas » se fie vient de lui. Le silence duquel on parle trop vite, lui, le tient vraiment.
Je ne ferai pas de lui une affiche. Un portrait qui n'admet aucune ombre n'éclaire personne.
Aline, avec laquelle il prépare les entrées, refuse aussi le lisse. Mado, dont les phrases restent, l'écoute plus qu'elle ne le commente.
Ce que je retiens : une personne à qui l'on doit un tempo, pas une légende.
Si Radio Figuier lit ce texte, qu'on le lise lentement. Le mieux n'est pas d'en faire plus.
La cour où il s'installe n'a pas besoin d'estrade, je l'ai dit, et je le redis : un portrait trop lisse n'éclaire personne.
Je tiens à l'ombre autant qu'aux trois frappes. Sans elle, Sami deviendrait un masque.
Patrick
Copie : Aline Uwase, Lila Sow""",
        tf_item=(
            "Patrick veut faire de Sami une affiche de saison.",
            False,
            "« Je ne ferai pas de lui une affiche. »",
        ),
        qcm_item=(
            "D'où vient le rythme auquel la pièce se fie, selon Patrick ?",
            [
                "D'un orchestre d'ailleurs",
                "De Sami",
                "Du tampon de Solange",
                "Du marché seulement",
            ],
            1,
            "« Le rythme auquel la pièce se fie vient de lui. »",
        ),
        pairs=[
            ("qui", "Sami / sujet"),
            ("dont", "tambour / phrases de Mado"),
            ("auquel", "rythme / se fier à"),
            ("duquel", "silence / parler de"),
        ],
        fill_item=("Le tambour ___ il se sert discute avec les répliques.", "dont"),
        words=["Je", "ne", "ferai", "pas", "de", "lui", "une", "affiche", "."],
        anagram=("silence", "Ce que Sami tient parfois mieux qu'une phrase trop sûre."),
        error=(
            "Voici le rythme que la pièce se fie trop vite, et Sami le reprend encore sous le figuier.",
            "Voici le rythme auquel la pièce se fie trop vite, et Sami le reprend encore sous le figuier.",
            "Se fier à → auquel.",
        ),
        pic_start=8,
        pic_words=_pw(8),
        short_p="Imitez : douze à quinze lignes, un portrait, au moins cinq relatifs différents.",
        audio="Lisez votre portrait, sans aller trop vite.",
    ),
    _l(
        "EL",
        "EL — Relatifs pour ne pas répéter",
        "Retenir qui, que, dont, où, lequel, auquel, duquel et leurs constructions.",
        "Apprenez la fiche.",
        "Fiche d'Aline, relatifs",
        """qui = sujet : Mado qui écrit ; Sami qui frappe
que = objet direct : le livre que j'ai relu ; le portrait que l'on refuse
dont = de + nom : le livre dont je parle ; le tambour dont il se sert ; les phrases dont elle s'occupe
où = lieu ou moment : la cour où l'on joue ; le soir où l'on se tait
lequel / laquelle / lesquels / lesquelles : après préposition, accord
sur lequel, pendant lesquels, avec laquelle
auquel = à + lequel ; auxquels / à laquelle / auxquelles
duquel = de + lequel (plus lourd que dont ; utile après nom déjà précisé)
à qui / de qui : souvent pour une personne (plus naturel que auquel / duquel)
Éviter : le livre que je parle (parler de → dont)
Éviter : le débat que je pense (penser à → auquel)
Un relatif bien choisi évite la répétition sans devenir un masque savant.
Portrait : faits + ombre + lien à la cour. Pas d'affiche.
Bien que + subj. : bien que ce soit incomplet, le portrait tient.""",
        tf_item=(
            "« Dont » et « que » sont interchangeables après parler.",
            False,
            "Parler de → dont. Que ne reprend pas de.",
        ),
        qcm_item=(
            "« Les débats auxquels elle invite » vient de…",
            [
                "inviter de",
                "inviter à",
                "inviter sur",
                "inviter dont",
            ],
            1,
            "Inviter à → auxquels.",
        ),
        pairs=[
            ("qui", "sujet"),
            ("que", "objet direct"),
            ("dont", "reprise de de"),
            ("auquel / duquel", "à + lequel / de + lequel"),
        ],
        fill_item=("Voici le livre ___ je parle encore ce soir.", "dont"),
        words=["La", "cour", "où", "l'on", "joue", "n'est", "pas", "fermée", "."],
        anagram=("lequel", "Relatif qui s'accorde et suit souvent une préposition."),
        error=(
            "Les tissus que je pense pour le portrait sont ocre, et Rose les a tendus avant le débat.",
            "Les tissus auxquels je pense pour le portrait sont ocre, et Rose les a tendus avant le débat.",
            "Penser à → auxquels.",
        ),
        pic_start=9,
        pic_words=_pw(9),
        short_p="Tableau : qui / que / dont / où / lequel / auquel / duquel — une phrase chacun, portrait compris.",
        audio="Enregistrez la fiche et sept relatives, une par forme.",
    ),
]


# ---------------------------------------------------------------------------
# Séquence 3 — Problème culturel, solutions
# ---------------------------------------------------------------------------

S3 = [
    _l(
        "CO",
        "CO — C'est la veillée qui se presse",
        "Repérer la mise en relief et un problème culturel inventé, avec des solutions de cour.",
        "Lisez le dialogue. Quel est le problème, et qui propose quoi ?",
        "Avant la Veillée des lampions, Salle des Herbes",
        """Aline : Ce qui nous inquiète, c'est la vitesse. Ce n'est pas le tambour. C'est la veillée qui se presse.
Léa : C'est le cortège que l'on a trop chargé. Les lampions avancent plus vite que les phrases.
Patrick : Ce que je refuse, c'est de transformer une spécificité du Seuil en spectacle pour passer.
Marc : C'est Sami qui devrait poser le tempo, pas le marché. C'est le silence que l'on a oublié.
Hawa : Le problème, ce n'est pas la fête. C'est la fête qui n'ose plus s'arrêter.
Joël : C'est une solution simple que je propose : moins de lampions, plus de bancs.
Rose : C'est le tissu que l'on montre trop tôt. Qu'on le déplie après la troisième frappe.
Solange : Ce qui manque, c'est une règle écrite. Le Bureau peut dater un créneau, pas inventer une âme.
Karim : C'est nous qui tenons la cour. Si l'on cède au trop-vite, ce n'est plus une veillée, c'est une file.
Lila : Radio Figuier ne relayera pas un défilé. C'est la voix que l'on gardera, pas le compte des lampions.
Mado : Ce que le livre a déjà dit, c'est ceci : une cour qui oublie son rythme s'oublie.
Sami : Trois frappes. C'est moi qui les dois. Si l'on parle par-dessus, je m'arrête.
Dieudonné : C'est l'entrée par les Herbes qui calme. L'autre porte pousse déjà trop.
Yvette : Un problème culturel n'est pas une honte. C'est une question à tenir ensemble.""",
        tf_item=(
            "Aline dit que le tambour est la cause principale de l'inquiétude.",
            False,
            "« Ce n'est pas le tambour. C'est la veillée qui se presse. »",
        ),
        qcm_item=(
            "Quelle solution Joël propose-t-il ?",
            [
                "Plus de lampions, moins de bancs",
                "Moins de lampions, plus de bancs",
                "Fermer Radio Figuier",
                "Interdire le tambour",
            ],
            1,
            "Joël : moins de lampions, plus de bancs.",
        ),
        pairs=[
            ("c'est… qui", "Sami / nous / la veillée"),
            ("c'est… que", "le cortège / le silence / le tissu"),
            ("ce qui… c'est", "la vitesse / une règle"),
            ("ce que… c'est", "le refus / la phrase du livre"),
        ],
        fill_item=("C'est Sami ___ devrait poser le tempo.", "qui"),
        words=["C'est", "la", "veillée", "qui", "se", "presse", "."],
        anagram=("relief", "Tour c'est… qui / que : on met en avant un élément de la phrase."),
        error=(
            "C'est le silence qui on a oublié trop vite, et Sami refuse de frapper par-dessus le cortège.",
            "C'est le silence que l'on a oublié trop vite, et Sami refuse de frapper par-dessus le cortège.",
            "Objet : c'est… que, pas qui.",
        ),
        pic_start=10,
        pic_words=_pw(10),
        short_p="Notez le problème, trois mises en relief et deux solutions entendues.",
        audio="Enregistrez : C'est la veillée qui se presse. Ce qui nous inquiète, c'est la vitesse. C'est Sami qui pose le tempo.",
    ),
    _l(
        "CE",
        "CE — Spécificité et solutions",
        "Lire un texte argumenté sur une spécificité culturelle inventée et des solutions.",
        "Lisez le texte de la cour, sans aller trop vite.",
        "Note de la cour, Veillée des lampions",
        """Note — Une spécificité à ne pas vider
Ce qui fait la Veillée des lampions, ce n'est pas le nombre de lumières. C'est le moment où le cortège s'arrête pour le tambour de Sami.
Le problème, cette saison, c'est que l'on avance trop vite. On dirait une file, plus une veille.
C'est le marché qui pousse, parfois sans le vouloir. C'est nous qui cédons, parfois sans le voir.
Solutions proposées (à débattre, pas à imposer) :
1. C'est Sami qui ouvre et qui ferme. Trois frappes. Pas de phrase par-dessus.
2. C'est le tissu de Rose que l'on déplie après la troisième frappe, pas avant.
3. Ce qui manque, c'est un banc de silence : moins de lampions sur ce côté, plus d'écoute.
4. C'est l'entrée par la Salle des Herbes qui calme ; l'autre porte, on la garde pour la fin.
5. Radio Figuier relayera la voix, pas le compte. Ce que l'on garde, c'est une phrase, pas un total.
Mado rappelle : une cour qui oublie son rythme s'oublie.
Aline : un problème culturel n'est pas une honte. C'est une question.
Karim : si l'on refuse toute règle, ce n'est plus une spécificité, c'est un caprice.
Solange datera le créneau. Elle n'inventera pas l'âme.
Rukiri-Nord — à lire avant d'allumer le premier lampion.""",
        tf_item=(
            "On doit déplier le tissu de Rose avant la troisième frappe.",
            False,
            "Après la troisième frappe, pas avant.",
        ),
        qcm_item=(
            "Que relayera Radio Figuier, d'après la note ?",
            [
                "Le compte des lampions",
                "La voix, pas le compte",
                "Un orchestre d'ailleurs",
                "La fermeture du Bureau",
            ],
            1,
            "« relayera la voix, pas le compte. »",
        ),
        pairs=[
            ("ce qui fait la veillée", "l'arrêt pour le tambour"),
            ("c'est Sami qui", "ouvre et ferme"),
            ("ce qui manque", "un banc de silence"),
            ("ce que l'on garde", "une phrase"),
        ],
        fill_item=("C'est l'entrée par les Herbes ___ calme.", "qui"),
        words=["Ce", "qui", "nous", "inquiète", "c'est", "la", "vitesse", "."],
        anagram=("veillée", "Soir de lampions et de tambour, à ne pas vider en file. (sans accent sur le premier e)"),
        error=(
            "C'est nous que tenons encore la cour, et le cortège devra s'arrêter pour les trois frappes.",
            "C'est nous qui tenons encore la cour, et le cortège devra s'arrêter pour les trois frappes.",
            "Sujet : c'est… qui.",
        ),
        pic_start=11,
        pic_words=_pw(11),
        short_p="Recopiez le problème en deux phrases et les cinq solutions. Ajoutez la vôtre en mise en relief.",
        audio="Lisez la note, sans aller trop vite.",
    ),
    _l(
        "PO",
        "PO — Dire c'est… qui, ce qui… c'est",
        "Mettre en relief à l'oral un problème culturel et une solution.",
        "Répétez, puis posez un problème du Seuil et une solution, avec c'est… / ce qui…",
        "Modèles d'Aline et de Karim",
        """C'est la veillée qui se presse.
C'est le silence que l'on a oublié.
C'est Sami qui pose le tempo.
C'est nous qui tenons la cour.
Ce qui nous inquiète, c'est la vitesse.
Ce que je refuse, c'est le spectacle pour passer.
Ce qui manque, c'est un banc de silence.
Ce que l'on garde, c'est une phrase.
Aline : on met en avant ce qui compte, pas ce qui brille.
Marc : qui pour le sujet, que pour l'objet.
Léa : ce qui = sujet ; ce que = objet.
Joël : une solution se dit aussi en relief, sinon elle se perd.
Rose : c'est le tissu que l'on déplie trop tôt.
Yvette : le relief n'est pas un cri. C'est une précision.""",
        tf_item=(
            "« Ce qui » reprend un sujet, « ce que » un objet.",
            True,
            "Léa : ce qui = sujet ; ce que = objet.",
        ),
        qcm_item=(
            "Quelle phrase met en relief un sujet ?",
            [
                "C'est le silence que l'on a oublié",
                "C'est Sami qui pose le tempo",
                "Ce que je refuse c'est le spectacle",
                "On a oublié le silence",
            ],
            1,
            "C'est Sami qui : Sami est sujet de poser.",
        ),
        pairs=[
            ("c'est… qui", "sujet mis en avant"),
            ("c'est… que", "objet mis en avant"),
            ("ce qui… c'est", "sujet neutre"),
            ("ce que… c'est", "objet neutre"),
        ],
        fill_item=("Ce ___ je refuse, c'est le spectacle pour passer.", "que"),
        words=["C'est", "nous", "qui", "tenons", "la", "cour", "."],
        anagram=("solution", "Réponse concrète à un problème de rythme, de tissu ou de porte."),
        error=(
            "Ce que nous inquiète encore, c'est la vitesse, et Sami refuse de frapper dans le bruit.",
            "Ce qui nous inquiète encore, c'est la vitesse, et Sami refuse de frapper dans le bruit.",
            "Sujet de inquiéter : ce qui.",
        ),
        pic_start=12,
        pic_words=_pw(12),
        short_p="Écrivez huit mises en relief : quatre c'est… qui/que, quatre ce qui/ce que… c'est.",
        audio="Enregistrez les huit premiers modèles, puis un problème et une solution à vous.",
    ),
    _l(
        "PE",
        "PE — Mon problème, mes solutions",
        "Écrire un texte argumenté : spécificité culturelle, problème, solutions, mise en relief.",
        "Imitez la note de Hawa, sans aller trop vite.",
        "Note de Hawa, Salle des Herbes",
        """Hawa — Seuil des Sources, avant la veillée
Ce qui me tient éveillée, ce n'est pas le nombre de lampions. C'est la peur de vider une spécificité : l'arrêt pour le tambour de Sami.
Le problème, cette saison, c'est que le cortège avance comme une file. C'est le marché qui pousse ; c'est nous qui cédons.
Je n'accuse personne. J'accuse un rythme. Une cour qui oublie de s'arrêter s'oublie, Mado l'a déjà écrit.
Solutions que je défends, sans les imposer :
C'est Sami qui ouvre et qui ferme. Trois frappes. Pas de phrase par-dessus.
C'est le tissu de Rose que l'on déplie après, pas avant.
Ce qui manque, c'est un banc de silence du côté des Herbes.
C'est l'entrée calme que Dieudonné a dite : par la Salle, pas par l'autre porte.
Ce que Radio Figuier doit garder, c'est une voix, pas un total.
Si l'on refuse toute règle, ce n'est plus une spécificité, c'est un caprice. Si l'on règle tout, ce n'est plus une veillée, c'est un tampon.
Je tiens le milieu. C'est ce milieu que je propose à la cour.
Hawa""",
        tf_item=(
            "Hawa accuse nommément le marché et refuse toute règle.",
            False,
            "Elle n'accuse pas une personne ; elle refuse l'excès des deux côtés.",
        ),
        qcm_item=(
            "Que propose Hawa du côté des Herbes ?",
            [
                "Plus de lampions",
                "Un banc de silence",
                "Fermer Sami",
                "Un total à la radio",
            ],
            1,
            "« un banc de silence du côté des Herbes. »",
        ),
        pairs=[
            ("ce qui me tient", "la peur de vider"),
            ("c'est Sami qui", "ouvre et ferme"),
            ("c'est le tissu que", "l'on déplie après"),
            ("ce que la radio doit", "une voix"),
        ],
        fill_item=("C'est le tissu de Rose ___ l'on déplie après.", "que"),
        words=["C'est", "Sami", "qui", "ouvre", "et", "qui", "ferme", "."],
        anagram=("specifique", "Ce qui n'appartient qu'à cette cour, à ne pas vider. (sans accent)"),
        error=(
            "C'est le cortège qui l'on a trop chargé cette saison, et les lampions avancent plus vite que les phrases.",
            "C'est le cortège que l'on a trop chargé cette saison, et les lampions avancent plus vite que les phrases.",
            "Objet : c'est… que.",
        ),
        pic_start=13,
        pic_words=_pw(13),
        short_p="Imitez : treize à seize lignes, un problème, trois solutions, au moins six mises en relief.",
        audio="Lisez votre note, sans aller trop vite.",
    ),
    _l(
        "EL",
        "EL — Mise en relief du problème",
        "Retenir c'est… qui / que et ce qui / ce que… c'est pour argumenter.",
        "Apprenez la fiche.",
        "Fiche d'Aline, mise en relief",
        """C'est + X + qui + verbe : X est sujet
C'est Sami qui pose le tempo. C'est nous qui tenons la cour. C'est la veillée qui se presse.
C'est + X + que + sujet + verbe : X est objet
C'est le silence que l'on a oublié. C'est le tissu que l'on déplie trop tôt.
Ce qui + verbe, c'est… : le sujet n'est pas encore nommé
Ce qui nous inquiète, c'est la vitesse. Ce qui manque, c'est un banc.
Ce que + sujet + verbe, c'est… : l'objet n'est pas encore nommé
Ce que je refuse, c'est le spectacle. Ce que l'on garde, c'est une phrase.
Qui / que : même logique que le relatif. Sujet / objet.
On peut renforcer : c'est bien… qui/que ; ce n'est pas X, c'est Y.
Problème culturel : nommer une spécificité, un dérèglement, des solutions discutables.
Éviter : c'est le silence qui on a oublié (objet → que).
Éviter : ce que nous inquiète (sujet → ce qui).
Bien que + subj. : bien que ce soit une fête, elle peut se vider.
À + le = au tambour ; de + le = du cortège.""",
        tf_item=(
            "« C'est le silence que l'on a oublié » met en relief un objet.",
            True,
            "Que + on a oublié : silence = objet.",
        ),
        qcm_item=(
            "Quelle phrase est fautive ?",
            [
                "C'est Sami qui ouvre",
                "Ce qui manque c'est un banc",
                "C'est le silence qui on a oublié",
                "Ce que je refuse c'est le spectacle",
            ],
            2,
            "Objet : que, pas qui.",
        ),
        pairs=[
            ("c'est… qui", "sujet"),
            ("c'est… que", "objet"),
            ("ce qui… c'est", "sujet neutre"),
            ("ce que… c'est", "objet neutre"),
        ],
        fill_item=("Ce ___ manque, c'est un banc de silence.", "qui"),
        words=["Ce", "que", "je", "refuse", "c'est", "le", "spectacle", "."],
        anagram=("probleme", "Question culturelle à tenir ensemble, sans en faire une honte. (sans accent)"),
        error=(
            "C'est nous que ouvrons encore la veillée, et Sami attend trois secondes de silence avant de frapper.",
            "C'est nous qui ouvrons encore la veillée, et Sami attend trois secondes de silence avant de frapper.",
            "Sujet : c'est… qui.",
        ),
        pic_start=14,
        pic_words=_pw(14),
        short_p="Rédigez un mini-tableau : huit phrases, deux par tour de relief, sur la veillée.",
        audio="Enregistrez la fiche et six mises en relief, voix posée.",
    ),
]


# ---------------------------------------------------------------------------
# Séquence 4 — Tendance et création
# ---------------------------------------------------------------------------

S4 = [
    _l(
        "CO",
        "CO — On en parle, on y pense",
        "Repérer en / y et le passage d'un registre standard à un registre familier.",
        "Lisez le dialogue. De quoi parle-t-on, à quoi pense-t-on, et quel ton choisit-on ?",
        "Atelier de Rose, tissu ocre",
        """Rose : On en parle depuis trois jeudis, de cette tendance : moins d'apparat, plus de couture visible.
Aline : J'y pense aussi. Créer, ce n'est pas empiler. C'est oser enlever.
Léa : Moi, j'en ai assez des masques trop chargés. J'y reviendrai, à la pièce, si le tissu reste simple.
Patrick : Standard : cela n'est pas négligeable. Familier : c'est pas mal. Les deux disent une valeur, pas le même salon.
Marc : On y va trop vite, parfois, quand on dit « on » à la place d'un « nous » assumé. Ici, on peut. Devant le Bureau, nous préférons « nous ».
Hawa : Sami en a assez, des commentaires par-dessus les frappes. Il y est pour quelque chose, dans le calme de la scène.
Joël : J'y suis favorable, à cette création-là. J'en doute encore, du masque.
Karim : Le processus : on coupe, on essaie, on en retire une couche, on y revient le lendemain.
Lila : À l'antenne, je dirai « nous en discuterons ». Sous le figuier, je peux dire « on en parle ».
Mado : J'y vois une éthique : ne pas vendre une tendance comme une obligation.
Dieudonné : On s'y habitue, à la simplicité. On n'en revient pas, une fois qu'on l'a goûtée.
Yvette : Un chouïa plus sombre, si vous voulez un mot inventé et doux. Moi je reste à « un peu ». C'est plus clair.
Félicie : C'est pas mal, ce tissu. Cela n'est pas négligeable, pour une saison entière.
Sami : J'en ai fini, des discours. J'y vais, aux trois frappes.""",
        tf_item=(
            "Patrick distingue « cela n'est pas négligeable » et « c'est pas mal ».",
            True,
            "L'un est plus standard, l'autre plus familier.",
        ),
        qcm_item=(
            "Devant le Bureau, que préfère Marc ?",
            [
                "Uniquement « on »",
                "« Nous » plutôt que « on »",
                "Le mot chouïa seulement",
                "Le silence total",
            ],
            1,
            "Marc : devant le Bureau, nous préférons « nous ».",
        ),
        pairs=[
            ("en parler", "de la tendance"),
            ("y penser", "à la création"),
            ("c'est pas mal", "registre familier"),
            ("cela n'est pas négligeable", "registre standard"),
        ],
        fill_item=("On ___ parle depuis trois jeudis.", "en"),
        words=["J'y", "pense", "aussi", "depuis", "trois", "jeudis", "."],
        anagram=("registre", "Ton d'une phrase : standard sous le Bureau, plus familier sous l'arbre."),
        error=(
            "On y parle depuis trop longtemps de cette tendance, et Rose refuse encore l'apparat.",
            "On en parle depuis trop longtemps de cette tendance, et Rose refuse encore l'apparat.",
            "Parler de → en.",
        ),
        pic_start=15,
        pic_words=_pw(15),
        short_p="Notez six en / y et deux paires de registre (familier / standard).",
        audio="Enregistrez : On en parle. J'y pense. C'est pas mal. Cela n'est pas négligeable.",
    ),
    _l(
        "CE",
        "CE — Processus d'une création",
        "Lire un texte sur une tendance et un processus de création (en / y, registres).",
        "Lisez la chronique de Lila, sans aller trop vite.",
        "Chronique de Radio Figuier, atelier ocre",
        """Chronique — Une tendance n'est pas un ordre
On en parle au Seuil : une création plus nue, un tissu qui assume ses coutures.
Rose Iradukunda y travaille depuis la saison sèche. Elle en retire une couche, puis y revient le lendemain.
Le processus n'a rien d'un secret d'ailleurs. On coupe, on essaie, on en doute, on y croit un peu plus.
Registre : sous le figuier, « c'est pas mal » suffit. Devant le Bureau, « cela n'est pas négligeable » protège le sérieux du geste.
On et nous : on crée ensemble, le soir ; nous signerons, le matin, si Solange le demande.
Yvette a proposé « un chouïa plus sombre ». Rose a répondu « un peu plus sombre ». Les deux se comprennent ; le second se relit mieux.
Mado y voit une éthique : ne pas vendre une tendance comme une obligation.
Sami en a assez des commentaires qui recouvrent les frappes. Il y est pour beaucoup, dans le calme obtenu.
Léa : j'y suis favorable. Patrick : j'en doute encore, du masque, pas du tissu.
Ce que la chronique refuse, c'est le snobisme. On peut aimer une création sans en faire une loi.
Aline : une tendance se discute. On n'y obéit pas comme à un tampon.
Rukiri-Nord — à relire avant d'ouvrir l'atelier aux voisins.""",
        tf_item=(
            "Mado veut que la tendance devienne une obligation pour toute la cour.",
            False,
            "Elle refuse de vendre une tendance comme une obligation.",
        ),
        qcm_item=(
            "Que répond Rose à « un chouïa plus sombre » ?",
            [
                "Un orchestre",
                "Un peu plus sombre",
                "Un tampon",
                "Un silence interdit",
            ],
            1,
            "Rose choisit « un peu », plus lisible.",
        ),
        pairs=[
            ("en parler / en retirer", "de la tendance / une couche"),
            ("y travailler / y revenir", "à l'atelier / le lendemain"),
            ("c'est pas mal", "sous le figuier"),
            ("cela n'est pas négligeable", "devant le Bureau"),
        ],
        fill_item=("Rose ___ travaille depuis la saison sèche.", "y"),
        words=["On", "en", "parle", "au", "Seuil", "depuis", "trois", "jeudis", "."],
        anagram=("tendance", "Goût d'une saison, à discuter, sans en faire une loi pour la cour."),
        error=(
            "Nous y doutons encore du masque, et Rose continue d'en retirer une couche chaque soir.",
            "Nous en doutons encore du masque, et Rose continue d'en retirer une couche chaque soir.",
            "Douter de → en.",
        ),
        pic_start=16,
        pic_words=_pw(16),
        short_p="Recopiez le processus en cinq étapes et deux phrases de registre différent.",
        audio="Lisez la chronique, sans aller trop vite.",
    ),
    _l(
        "PO",
        "PO — Dire en, y, et le ton juste",
        "Employer en / y à l'oral et glisser d'un registre à l'autre sans se tromper de lieu.",
        "Répétez, puis parlez d'une création : vous en dites, vous y pensez, vous choisissez le ton.",
        "Modèles de Rose et de Marc",
        """On en parle depuis jeudi.
J'y pense chaque soir.
J'en retire une couche.
On y revient le lendemain.
J'y suis favorable.
J'en doute encore.
C'est pas mal. (familier, banc)
Cela n'est pas négligeable. (standard, Bureau)
Nous en discuterons demain. (plus posé)
On s'y habitue.
Aline : en = de cela ; y = à cela / là.
Léa : j'y vais, à l'atelier ; j'en viens, de l'idée.
Patrick : le ton suit le lieu. Le figuier n'est pas le Bureau.
Yvette : « un peu » se relit mieux qu'un mot trop privé.""",
        tf_item=(
            "« En » reprend souvent un complément introduit par de.",
            True,
            "Aline : en = de cela.",
        ),
        qcm_item=(
            "Quelle phrase est correcte ?",
            [
                "On y parle de cette tendance",
                "On en parle de cette tendance",
                "On y doute du masque",
                "J'en pense à la création",
            ],
            1,
            "Parler de → en. (On en parle.)",
        ),
        pairs=[
            ("en parler", "de cela"),
            ("y penser", "à cela"),
            ("c'est pas mal", "familier"),
            ("nous en discuterons", "plus standard"),
        ],
        fill_item=("J'___ suis favorable à cette création.", "y"),
        words=["On", "s'y", "habitue", "à", "la", "simplicité", "."],
        anagram=("creation", "Geste de couper d'essayer et d'enlever, sans copie d'ailleurs. (sans accent)"),
        error=(
            "J'en pense encore à cette création, et Rose y revient chaque matin avec un tissu plus nu.",
            "J'y pense encore à cette création, et Rose y revient chaque matin avec un tissu plus nu.",
            "Penser à → y.",
        ),
        pic_start=17,
        pic_words=_pw(17),
        short_p="Écrivez dix phrases : cinq en, cinq y, dont deux familières et deux standard.",
        audio="Enregistrez les dix premiers modèles, puis trois phrases à vous, deux tons.",
    ),
    _l(
        "PE",
        "PE — Ma note de création",
        "Écrire un texte sur une tendance et un processus, avec en / y et deux registres.",
        "Imitez la note de Rose Iradukunda, sans aller trop vite.",
        "Note de Rose, atelier ocre",
        """Rose Iradukunda — Seuil des Sources
On en parle trop comme d'une mode. J'y vois plutôt un processus : enlever, essayer, y revenir.
J'en retire une couche chaque soir. Le tissu dont la saison a besoin n'a pas à cacher ses coutures.
Sous le figuier, je peux dire : c'est pas mal. Devant Solange, je dirai : cela n'est pas négligeable. Le geste est le même ; le salon change.
Nous signerons le matin, si le Bureau le demande. Le soir, on crée, on se trompe, on en rit un peu.
Yvette a soufflé « un chouïa plus sombre ». J'ai répondu « un peu ». J'y tiens : une création se relit.
Mado y voit une éthique, et j'en suis d'accord : une tendance n'est pas un ordre.
Sami en a assez des phrases par-dessus les frappes. J'y fais attention, au moment où le tissu entre.
Ce que je refuse, c'est le snobisme. On peut aimer sans en faire une loi, et l'on peut douter sans tout casser.
Si Léa y est favorable et que Patrick en doute encore, tant mieux : la création respire.
On s'y habitue, à la simplicité. On n'en revient pas, une fois qu'on l'a goûtée.
Devant le Bureau je dirai « nous ». Sous le figuier je peux encore dire « on ». Le ton suit le lieu.
Rose""",
        tf_item=(
            "Rose veut que toute la cour obéisse à la tendance comme à un tampon.",
            False,
            "« une tendance n'est pas un ordre. »",
        ),
        qcm_item=(
            "Que répond Rose au « chouïa » d'Yvette ?",
            [
                "Un orchestre",
                "Un peu",
                "Un masque obligatoire",
                "Un refus du Bureau",
            ],
            1,
            "« J'ai répondu « un peu ». »",
        ),
        pairs=[
            ("en parler / en retirer", "mode / couche"),
            ("y voir / y revenir", "processus / lendemain"),
            ("c'est pas mal", "figuier"),
            ("cela n'est pas négligeable", "Solange / Bureau"),
        ],
        fill_item=("J'___ suis d'accord : une tendance n'est pas un ordre.", "en"),
        words=["On", "peut", "aimer", "sans", "en", "faire", "une", "loi", "."],
        anagram=("couture", "Ligne visible sur le tissu ocre, que Rose refuse désormais de cacher."),
        error=(
            "On y rit encore de nos essais trop chargés, et le tissu plus nu tient mieux sous la lampe.",
            "On en rit encore de nos essais trop chargés, et le tissu plus nu tient mieux sous la lampe.",
            "Rire de → en.",
        ),
        pic_start=18,
        pic_words=_pw(18),
        short_p="Imitez : douze à quinze lignes, en / y, une phrase familière, une phrase standard.",
        audio="Lisez votre note, sans aller trop vite.",
    ),
    _l(
        "EL",
        "EL — En, y et les registres",
        "Retenir en / y et le choix d'un ton (on / nous, familier / standard).",
        "Apprenez la fiche.",
        "Fiche d'Aline, pronoms et tons",
        """en reprend de + nom / de cela : en parler, en douter, en retirer, en rire, en avoir assez
y reprend à + nom / là : y penser, y revenir, y être favorable, s'y habituer, y voir, y aller
Élision : j'y pense, j'en doute, on s'y habitue
Pièges : parler de → en (pas y) ; penser à → y (pas en) ; douter de → en
Registre familier (banc, figuier) : c'est pas mal ; on en parle ; un peu
Registre standard (Bureau, antenne posée) : cela n'est pas négligeable ; nous en discuterons
On : fréquent à l'oral, collectif souple. Nous : plus assumé, plus officiel.
Un mot trop privé (chouïa) peut se comprendre ; « un peu » se relit mieux.
Le ton suit le lieu. Le figuier n'est pas le Bureau. L'antenne n'est pas le marché.
Création : processus (couper, essayer, enlever, y revenir), pas copie d'ailleurs.
Tendance : se discute. On n'y obéit pas comme à un tampon.
Attention : y / en se placent avant le verbe, sauf à l'impératif affirmatif (parles-en, vas-y).""",
        tf_item=(
            "« Penser à » se reprend par en.",
            False,
            "Penser à → y.",
        ),
        qcm_item=(
            "Quelle reprise est juste pour « douter du masque » ?",
            [
                "y douter",
                "en douter",
                "le douter à",
                "dont douter y",
            ],
            1,
            "Douter de → en.",
        ),
        pairs=[
            ("en", "de cela"),
            ("y", "à cela / là"),
            ("c'est pas mal", "familier"),
            ("nous en discuterons", "standard"),
        ],
        fill_item=("Parler de la tendance → on ___ parle.", "en"),
        words=["J'y", "suis", "favorable", "sans", "en", "faire", "une", "loi", "."],
        anagram=("processus", "Suite d'essais : couper, enlever, revenir, sans secret d'apparat."),
        error=(
            "Vas-y : parles-y demain au Bureau, et Rose apportera le tissu plus nu.",
            "Vas-y : parles-en demain au Bureau, et Rose apportera le tissu plus nu.",
            "Parler de → en (parles-en).",
        ),
        pic_start=19,
        pic_words=_pw(19),
        short_p="Tableau en / y : huit verbes, une phrase chacun, plus deux paires de registre.",
        audio="Enregistrez la fiche, puis : j'en parle, j'y pense, parles-en, vas-y, c'est pas mal, cela n'est pas négligeable.",
    ),
]


# ---------------------------------------------------------------------------
# Séquence 5 — Bilan de la Saison des Voix (EXTRA critique)
# ---------------------------------------------------------------------------

S5 = [
    _l(
        "CO",
        "CO — Une saison à juger",
        "Suivre un bilan critique : qualités, limites, critères, sans slogan.",
        "Lisez le dialogue. Qu'est-ce qui a tenu, qu'est-ce qui a manqué ?",
        "Après la dernière frappe, banc du figuier",
        """Aline : Une critique n'est pas une insulte. C'est un bilan qui ose le « mais ».
Léa : La saison a été plus juste que bruyante. Le meilleur soir, ce n'est pas le plus plein.
Patrick : Ce que je retiens, c'est le livre de Mado. Ce qui m'a manqué, c'est du temps entre les œuvres.
Marc : La pièce dont on parle encore a tenu. Le cortège, lui, a trop glissé vers la file.
Hawa : J'y vois une réussite inégale, et c'est déjà beaucoup. On n'en fera pas une légende lisse.
Joël : C'est le tambour qui a sauvé deux soirs trop pressés. C'est nous qui avons trop parlé par-dessus.
Rose : Le tissu a mieux tenu que les commentaires. J'en suis plutôt fière, sans en faire une loi.
Solange : Le Bureau date. Il ne note pas. Une critique n'a pas besoin d'un tampon pour exister.
Karim : Or, sans public, pas de saison. Toutefois, un public n'excuse pas la vitesse.
Lila : À l'antenne, je dirai : cela n'est pas négligeable. Sous l'arbre, je peux dire : c'est pas mal, et c'est déjà rare.
Mado : Une critique qui n'admet que l'éloge n'est pas une critique. C'est une affiche de plus.
Sami : Trois soirs ont tenu. Un soir a glissé. Je n'en dirai pas plus long que ça.
Dieudonné : L'entrée des Herbes a calmé. L'autre porte a poussé. On y reviendra.
Yvette : Le mieux, pour un bilan, c'est une phrase juste, pas un classement.""",
        tf_item=(
            "Mado considère qu'un éloge sans réserve suffit à faire une critique.",
            False,
            "« Une critique qui n'admet que l'éloge n'est pas une critique. »",
        ),
        qcm_item=(
            "Selon Patrick, qu'est-ce qui a manqué ?",
            [
                "Le tampon de Solange",
                "Du temps entre les œuvres",
                "Le tambour de Sami",
                "Le tissu de Rose",
            ],
            1,
            "« du temps entre les œuvres. »",
        ),
        pairs=[
            ("plus juste que bruyante", "la saison"),
            ("ce que je retiens", "le livre"),
            ("c'est le tambour qui", "a sauvé deux soirs"),
            ("toutefois", "le public n'excuse pas la vitesse"),
        ],
        fill_item=("Une critique n'est pas une insulte. C'est un bilan qui ose le « ___ ».", "mais"),
        words=["La", "saison", "a", "été", "plus", "juste", "que", "bruyante", "."],
        anagram=("critique", "Bilan qui ose un mais, sans devenir une affiche ni une insulte."),
        error=(
            "C'est le meilleur soir de la saison et c'est aussi le plus bon public que j'aie vu sous le figuier.",
            "C'est le meilleur soir de la saison et c'est aussi le meilleur public que j'aie vu sous le figuier.",
            "Meilleur, pas plus bon.",
        ),
        pic_start=20,
        pic_words=_pw(20),
        short_p="Notez trois qualités, deux limites et le critère que vous garderiez pour une critique.",
        audio="Enregistrez : Une critique ose le mais. Ce que je retiens, c'est le livre. Ce qui a manqué, c'est du temps.",
    ),
    _l(
        "CE",
        "CE — Critique de saison",
        "Lire une critique argumentée de la Saison des Voix (inventée).",
        "Lisez la critique de Lila, sans aller trop vite.",
        "Feuille du soir, Radio Figuier",
        """Critique — Saison des Voix, Seuil des Sources
On en attendait une fête. On y a trouvé, plus souvent, une écoute. Cela n'est pas négligeable.
La pièce « La cour n'oublie pas », que la cour a jouée sous le figuier, a été plus nue que l'an passé. C'est Sami qui en a tenu le tempo. Le meilleur acte n'était pas le plus long.
Le livre de Mado, dont les phrases restent, a moins besoin de lampions. Ce qui lui va le mieux, c'est le banc, pas le cortège.
Toutefois, le cortège a trop glissé vers la file. C'est la veillée que l'on a pressée, pas le tambour. On y reviendra.
Rose : le tissu a mieux tenu que certains commentaires. On peut en parler sans en faire une loi.
Aline a refusé l'affiche lisse. Karim a rappelé qu'un public n'excuse pas la vitesse. Solange a daté, sans noter.
Ce que cette critique refuse, c'est le classement humiliant. Ce qu'elle propose, c'est un critère : la phrase que l'on peut encore dire le lendemain.
Réussite inégale, donc. Le mieux n'est pas de crier au chef-d'œuvre. C'est de pouvoir raconter sans trahir.
Sami : trois soirs ont tenu, un soir a glissé. On peut le dire sans insulter personne.
Dieudonné : l'entrée des Herbes a calmé ; l'autre porte a poussé. On y reviendra.
Yvette : une critique qui n'admet que l'éloge n'est pas une critique. C'est une affiche de plus.
Rukiri-Nord — à lire une fois, puis à discuter, jamais à coller comme un tampon.""",
        tf_item=(
            "La critique affirme que le cortège a trop glissé vers la file.",
            True,
            "« le cortège a trop glissé vers la file. »",
        ),
        qcm_item=(
            "Quel critère la critique propose-t-elle ?",
            [
                "Le nombre de lampions",
                "La phrase que l'on peut encore dire le lendemain",
                "Le tampon du Bureau",
                "La longueur du meilleur acte",
            ],
            1,
            "Le critère du lendemain, déjà posé par Aline.",
        ),
        pairs=[
            ("plus nue", "la pièce / l'an passé"),
            ("dont les phrases restent", "le livre de Mado"),
            ("toutefois", "la file du cortège"),
            ("réussite inégale", "bilan sans légende"),
        ],
        fill_item=("C'est Sami ___ en a tenu le tempo.", "qui"),
        words=["On", "peut", "en", "parler", "sans", "en", "faire", "une", "loi", "."],
        anagram=("bilan", "Regard d'après-saison : ce qui a tenu, ce qui a glissé, un critère."),
        error=(
            "Voici la saison dont je pense encore ce soir, et Lila en relira la critique à l'antenne.",
            "Voici la saison à laquelle je pense encore ce soir, et Lila en relira la critique à l'antenne.",
            "Penser à → à laquelle.",
        ),
        pic_start=21,
        pic_words=_pw(21),
        short_p="Recopiez la critique et marquez éloge, limite, critère. Ajoutez deux phrases à vous.",
        audio="Lisez la critique, sans aller trop vite.",
    ),
    _l(
        "PO",
        "PO — Dire une critique juste",
        "Formuler à l'oral un bilan : qualité, limite, critère, ton mesuré.",
        "Répétez, puis critiquez une œuvre de la saison sans slogan.",
        "Modèles d'Aline et de Mado",
        """La saison a été plus juste que bruyante.
Ce que je retiens, c'est le livre.
Ce qui m'a manqué, c'est du temps.
C'est le tambour qui a tenu deux soirs.
Toutefois, le cortège a trop glissé.
Cela n'est pas négligeable.
C'est pas mal, et c'est déjà rare.
Une critique ose le « mais ».
Le mieux n'est pas de crier au chef-d'œuvre.
Aline : un éloge sans réserve n'éclaire rien.
Marc : un critère se dit en une phrase.
Léa : on en parle, on n'y met pas de couronne.
Patrick : je préfère inégale et vraie à lisse et fausse.
Yvette : finissez par ce que vous garderez.""",
        tf_item=(
            "Aline soutient qu'un éloge sans réserve n'éclaire rien.",
            True,
            "Un éloge plat n'est pas une critique.",
        ),
        qcm_item=(
            "Quelle phrase ouvre une limite ?",
            [
                "Cela n'est pas négligeable",
                "Toutefois le cortège a trop glissé",
                "C'est le tambour qui a tenu",
                "Le livre que j'ai relu",
            ],
            1,
            "Toutefois introduit la réserve.",
        ),
        pairs=[
            ("ce que je retiens", "qualité"),
            ("ce qui m'a manqué", "limite"),
            ("toutefois", "réserve"),
            ("le mieux", "refus du slogan"),
        ],
        fill_item=("Une critique ose le « ___ ».", "mais"),
        words=["Cela", "n'est", "pas", "négligeable", "."],
        anagram=("reserve", "Le mais d'une critique, sans lequel l'éloge devient une affiche. (sans accent)"),
        error=(
            "La saison a été plus juste que bruyante, et c'est le plus bon soir que nous ayons tenu sous l'arbre.",
            "La saison a été plus juste que bruyante, et c'est le meilleur soir que nous ayons tenu sous l'arbre.",
            "Meilleur soir, pas plus bon.",
        ),
        pic_start=22,
        pic_words=_pw(22),
        short_p="Écrivez une critique orale en huit phrases : deux qualités, deux limites, un critère, une conclusion.",
        audio="Enregistrez les neuf premiers modèles, puis votre bilan en une minute.",
    ),
    _l(
        "PE",
        "PE — Ma critique de saison",
        "Écrire une critique argumentée de la Saison des Voix (inventée).",
        "Imitez la critique de Marc, sans aller trop vite.",
        "Critique de Marc, cahier ocre",
        """Marc — Seuil des Sources, après la dernière frappe
Une critique n'est pas une insulte. J'en écris une, donc, avec un « mais ».
La Saison des Voix a été plus juste que bruyante. La pièce que la cour a tenue sous le figuier, plus nue que l'an passé, a trouvé son tempo : c'est Sami qui l'a posé, et c'est nous qui l'avons parfois recouvert.
Le livre dont les phrases restent — « Le figuier n'oublie pas » — m'a paru moins spectaculaire et mieux. Ce que je retiens, c'est une cour qui refuse d'oublier.
Ce qui m'a manqué, c'est du temps entre les œuvres. Toutefois, le cortège a trop glissé vers la file : c'est la veillée que l'on a pressée, pas le tambour.
Rose : le tissu a mieux tenu que certains commentaires. On peut en parler sans en faire une loi.
Cela n'est pas négligeable. Sous l'arbre, je peux même dire : c'est pas mal, et c'est déjà rare.
Je refuse le classement humiliant. Le critère que je garde, c'est la phrase que l'on peut encore dire le lendemain.
Réussite inégale, donc. Le mieux n'est pas de crier au chef-d'œuvre. C'est de pouvoir raconter sans trahir.
Aline a refusé l'affiche. Solange a daté, sans noter. J'y vois assez de dignité pour une cour.
On en parlera encore au fil. On n'y mettra pas de couronne. Une saison se relit, elle ne se décerne pas.
Si Lila lit ceci à l'antenne, qu'elle garde le « mais ». Sans lui, je n'ai rien écrit.
Marc""",
        tf_item=(
            "Marc refuse le classement humiliant.",
            True,
            "« Je refuse le classement humiliant. »",
        ),
        qcm_item=(
            "Quel critère Marc garde-t-il ?",
            [
                "Le nombre de lampions",
                "La phrase que l'on peut encore dire le lendemain",
                "Le tampon du Bureau",
                "Le plus long acte",
            ],
            1,
            "Le critère du lendemain.",
        ),
        pairs=[
            ("plus juste que bruyante", "la saison"),
            ("ce que je retiens", "une cour qui refuse d'oublier"),
            ("toutefois", "la file du cortège"),
            ("réussite inégale", "bilan sans chef-d'œuvre"),
        ],
        fill_item=("Le mieux n'est pas de crier au ___.", "chef-d'œuvre"),
        words=["Une", "critique", "n'est", "pas", "une", "insulte", "."],
        anagram=("inegale", "Réussite vraie, sans légende lisse. (sans accent)"),
        error=(
            "C'est la veillée qui l'on a pressée trop vite, et le tambour n'y est pour rien.",
            "C'est la veillée que l'on a pressée trop vite, et le tambour n'y est pour rien.",
            "Objet : c'est… que.",
        ),
        pic_start=23,
        pic_words=_pw(23),
        short_p="Imitez : treize à seize lignes, éloge, limite, critère, un toutefois, un mieux.",
        audio="Lisez votre critique, sans aller trop vite.",
    ),
    _l(
        "EL",
        "EL — Tenir une critique",
        "Retenir la structure d'une critique : qualité, limite, critère, ton mesuré.",
        "Apprenez la fiche.",
        "Fiche d'Aline, critique de saison",
        """Critique = bilan qui ose le « mais ». Ni insulte, ni affiche.
Mouvements : ce que l'œuvre / la saison a fait ; ce qu'elle a manqué ; le critère ; la conclusion.
Outils déjà vus :
comparatif / superlatif : plus juste que bruyante ; le meilleur soir
relatifs : la pièce que… ; le livre dont… ; la cour où…
mise en relief : c'est Sami qui ; ce que je retiens, c'est ; ce qui m'a manqué, c'est
en / y : on en parle ; on y reviendra
Connecteur de réserve : toutefois. Conclusion mesurée : donc ; le mieux n'est pas…
Registre : cela n'est pas négligeable (antenne) ; c'est pas mal (banc)
Éviter le classement humiliant. Préférer « réussite inégale » à « chef-d'œuvre ».
Critère utile au Seuil : la phrase que l'on peut encore dire le lendemain.
Le Bureau date. Il ne note pas. Une critique n'a pas besoin d'un tampon.
Bien que + subj. : bien que ce soit inégal, la saison tient.
Attention : meilleur / mieux ; dont après parler de ; c'est… qui / que.""",
        tf_item=(
            "Une critique, d'après la fiche, peut se limiter à un éloge sans réserve.",
            False,
            "Elle ose le « mais ». Un éloge plat n'éclaire rien.",
        ),
        qcm_item=(
            "Quel connecteur ouvre surtout une réserve ?",
            [
                "donc seulement",
                "toutefois",
                "en avant",
                "tampon",
            ],
            1,
            "Toutefois = réserve.",
        ),
        pairs=[
            ("ce que je retiens", "qualité"),
            ("ce qui m'a manqué", "limite"),
            ("toutefois", "réserve"),
            ("le mieux n'est pas", "refus du slogan"),
        ],
        fill_item=("Une critique ose le « ___ ».", "mais"),
        words=["Réussite", "inégale", "donc", "."],
        anagram=("critere", "Phrase qui justifie un avis, par exemple celle du lendemain. (sans accent)"),
        error=(
            "Voici la saison que je parle encore ce soir, et Lila en relira le bilan à l'antenne demain.",
            "Voici la saison dont je parle encore ce soir, et Lila en relira le bilan à l'antenne demain.",
            "Parler de → dont.",
        ),
        pic_start=24,
        pic_words=_pw(24),
        short_p="Rédigez un plan de critique en cinq mouvements, avec un exemple de phrase pour chacun.",
        audio="Enregistrez la fiche, puis une mini-critique de six phrases.",
    ),
]


# ---------------------------------------------------------------------------
# Séquence 6 — Manifeste culturel du Seuil (EXTRA texte argumenté)
# ---------------------------------------------------------------------------

S6 = [
    _l(
        "CO",
        "CO — Nous ne vendons pas une cour",
        "Suivre l'élaboration d'un manifeste : thèses, concessions, engagements.",
        "Lisez le dialogue. Quelles phrases deviendraient des articles ?",
        "Assemblée sous le figuier, après la saison",
        """Aline : Un manifeste n'est pas une affiche. C'est un texte qui engage, et qui admet un « toutefois ».
Mado : Nous affirmons que la cour n'oublie pas. C'est le titre que l'on se doit, pas un slogan de marché.
Sami : Nous affirmons que trois frappes valent mieux qu'un défilé. C'est le tempo que nous défendons.
Léa : Ce que nous refusons, c'est de vendre une spécificité. Ce que nous proposons, c'est de la tenir.
Patrick : Article possible : la saison la plus juste n'est pas la plus pleine.
Marc : Or, sans public, pas de saison. Toutefois, un public n'excuse pas la vitesse. Les deux phrases doivent rester.
Hawa : Nous en parlerons au fil de Radio Figuier. Nous n'y obéirons pas comme à une mode.
Joël : C'est nous qui tenons le Seuil. C'est le figuier sous lequel on s'assemble, pas une estrade d'ailleurs.
Rose : Le tissu dont on se sert n'a pas à cacher ses coutures. J'en fais un article, si l'on veut.
Solange : Le Bureau date un manifeste. Il ne le note pas. Il n'en est pas le maître.
Karim : Ainsi, chaque article dira un fait, une limite, un geste. Pas une couronne.
Lila : À l'antenne, registre posé. Sous l'arbre, on peut dire : c'est pas mal, et cela suffit à nous lier.
Dieudonné : Nous y reviendrons chaque saison. Un manifeste qui ne se relit pas n'est qu'un papier.
Yvette : Le mieux, c'est une phrase que l'enfant du Seuil pourra encore comprendre.""",
        tf_item=(
            "Aline dit qu'un manifeste est une affiche de plus.",
            False,
            "« Un manifeste n'est pas une affiche. »",
        ),
        qcm_item=(
            "Que refuse Léa, dans le dialogue ?",
            [
                "Les trois frappes",
                "De vendre une spécificité",
                "Le tissu de Rose",
                "Le tampon de Solange",
            ],
            1,
            "Léa : refuser de vendre une spécificité.",
        ),
        pairs=[
            ("nous affirmons", "la cour n'oublie pas"),
            ("ce que nous refusons", "vendre une spécificité"),
            ("or / toutefois", "public / vitesse"),
            ("ainsi", "fait + limite + geste"),
        ],
        fill_item=("Un manifeste n'est pas une ___.", "affiche"),
        words=["C'est", "nous", "qui", "tenons", "le", "Seuil", "."],
        anagram=("manifeste", "Texte qui engage une cour, avec des articles et un toutefois."),
        error=(
            "Voici le manifeste que je pense depuis la dernière frappe, et Aline en relira les articles demain.",
            "Voici le manifeste auquel je pense depuis la dernière frappe, et Aline en relira les articles demain.",
            "Penser à → auquel.",
        ),
        pic_start=25,
        pic_words=_pw(25),
        short_p="Notez quatre articles possibles et la concession (or / toutefois) entendue.",
        audio="Enregistrez : Nous affirmons que la cour n'oublie pas. Ce que nous refusons, c'est de vendre. Toutefois, un public n'excuse pas la vitesse.",
    ),
    _l(
        "CE",
        "CE — Premier jet du manifeste",
        "Lire un manifeste culturel argumenté (articles, concessions, engagements).",
        "Lisez le manifeste, sans aller trop vite.",
        "Feuille du Seuil, Table des Sources",
        """Manifeste culturel du Seuil des Sources — premier jet
Nous, assemblés sous le figuier, affirmons que la cour n'oublie pas.
Nous affirmons que la Saison des Voix n'est pas un défilé. C'est une écoute que l'on tient ensemble.
Article 1. La saison la plus juste n'est pas la plus pleine. Le meilleur soir n'est pas le plus bruyant.
Article 2. C'est Sami qui pose le tempo de la veillée. Trois frappes. Pas de phrase par-dessus.
Article 3. Le livre dont les phrases restent, la pièce que l'on joue, le tissu auquel Rose travaille : deux langages, une cour.
Article 4. Or, sans public, pas de saison. Toutefois, un public n'excuse pas la vitesse.
Article 5. Une tendance se discute. On n'y obéit pas comme à un tampon. On en parle, on n'en fait pas une loi.
Article 6. Une critique ose le « mais ». Un manifeste aussi. Nous refusons l'affiche lisse.
Article 7. Radio Figuier relayera la voix, pas le compte. Le Bureau daté, sans noter.
Ce que nous proposons, c'est de relire ce texte chaque saison. Ce qui nous lie, c'est une phrase juste, pas une couronne.
Ainsi, nous nous engageons à tenir le milieu : assez de règle pour ne pas vider, assez de souffle pour ne pas geler.
Rukiri-Nord — à discuter, à corriger, à signer sans faste.""",
        tf_item=(
            "L'article 4 concède le besoin d'un public tout en refusant la vitesse.",
            True,
            "Or… Toutefois… : les deux phrases restent.",
        ),
        qcm_item=(
            "Que relayera Radio Figuier, selon l'article 7 ?",
            [
                "Le compte des lampions",
                "La voix, pas le compte",
                "Un classement des œuvres",
                "Une couronne",
            ],
            1,
            "La voix, pas le compte.",
        ),
        pairs=[
            ("article 1", "juste ≠ pleine"),
            ("article 2", "tempo de Sami"),
            ("article 4", "or / toutefois"),
            ("article 6", "le mais de la critique"),
        ],
        fill_item=("Une tendance se discute. On n'___ obéit pas comme à un tampon.", "y"),
        words=["Nous", "refusons", "l'affiche", "lisse", "."],
        anagram=("article", "Phrase numérotée d'un manifeste : un fait, une limite, un geste."),
        error=(
            "C'est nous que tenons encore le Seuil, et le manifeste le dira sans faste demain matin.",
            "C'est nous qui tenons encore le Seuil, et le manifeste le dira sans faste demain matin.",
            "Sujet : c'est… qui.",
        ),
        pic_start=26,
        pic_words=_pw(26),
        short_p="Recopiez trois articles et ajoutez le vôtre, avec une concession.",
        audio="Lisez le manifeste, sans aller trop vite.",
    ),
    _l(
        "PO",
        "PO — Dire un article, tenir un toutefois",
        "Argumenter à l'oral : thèse, concession, engagement, ton de manifeste.",
        "Répétez, puis proposez deux articles et une concession.",
        "Modèles d'Aline et de Karim",
        """Nous affirmons que la cour n'oublie pas.
Nous refusons de vendre une spécificité.
C'est nous qui tenons le Seuil.
Ce que nous proposons, c'est de tenir une écoute.
Or, sans public, pas de saison.
Toutefois, un public n'excuse pas la vitesse.
Ainsi, nous relirons ce texte chaque saison.
Le mieux, c'est une phrase juste.
Cela n'est pas négligeable.
Aline : un article dit un fait, une limite, un geste.
Marc : la concession n'affaiblit pas. Elle rend honnête.
Léa : on en parlera au fil. On n'y obéira pas comme à une mode.
Mado : signez sans faste. Un manifeste trop brillant se vide.
Yvette : finissez par ce que l'enfant du Seuil comprendra.""",
        tf_item=(
            "Marc dit que la concession rend le texte plus honnête.",
            True,
            "Elle n'affaiblit pas : elle rend honnête.",
        ),
        qcm_item=(
            "Quel couple pose la concession du public et de la vitesse ?",
            [
                "donc / ainsi seulement",
                "or / toutefois",
                "en / y seulement",
                "qui / que seulement",
            ],
            1,
            "Or… Toutefois…",
        ),
        pairs=[
            ("nous affirmons", "thèse"),
            ("nous refusons", "refus"),
            ("or / toutefois", "concession"),
            ("ainsi", "engagement"),
        ],
        fill_item=("___, un public n'excuse pas la vitesse.", "Toutefois"),
        words=["Nous", "affirmons", "que", "la", "cour", "n'oublie", "pas", "."],
        anagram=("concession", "Mouvement or / toutefois : on admet un fait sans céder sur l'essentiel."),
        error=(
            "Nous en obéirons pas comme à une mode, et le manifeste le dira dès demain sous le figuier.",
            "Nous n'y obéirons pas comme à une mode, et le manifeste le dira dès demain sous le figuier.",
            "Obéir à → y.",
        ),
        pic_start=27,
        pic_words=_pw(27),
        short_p="Écrivez six articles oraux : thèse, refus, relief, or, toutefois, ainsi.",
        audio="Enregistrez les neuf premiers modèles, puis deux articles à vous.",
    ),
    _l(
        "PE",
        "PE — Mon manifeste du Seuil",
        "Écrire un texte argumenté : manifeste culturel, articles, concessions, engagements.",
        "Imitez le manifeste de Mado, sans aller trop vite.",
        "Manifeste de Mado, encre du figuier",
        """Mado — Seuil des Sources, Rukiri-Nord
Nous, qui écrivons et qui frappons et qui tenons le pupitre, affirmons que la cour n'oublie pas.
Un manifeste n'est pas une affiche. C'est un texte dont on se sert, et auquel on revient.
Nous affirmons que la Saison des Voix est une écoute, non un défilé. La saison la plus juste n'est pas la plus pleine.
C'est Sami qui pose le tempo. C'est Rose dont le tissu assume ses coutures. C'est Aline avec laquelle on refuse le lisse.
Ce que nous refusons, c'est de vendre une spécificité. Ce que nous proposons, c'est de la tenir : veillée, tambour, livre, pièce.
Or, sans public, pas de saison. Toutefois, un public n'excuse pas la vitesse. Les deux phrases restent, ou le texte ment.
Nous en parlerons au fil de Radio Figuier. Nous n'y obéirons pas comme à une mode. Une tendance se discute ; on n'en fait pas une loi.
Ainsi, nous nous engageons à relire ces lignes chaque saison, à oser le « mais » d'une critique, à préférer une phrase juste à une couronne.
Le Bureau date. Il ne note pas. Le mieux, c'est ce qu'un enfant du Seuil pourra encore comprendre.
Je signe sans faste. Que la cour corrige.
Mado""",
        tf_item=(
            "Mado accepte qu'on vende la spécificité du Seuil si le public le demande.",
            False,
            "Elle refuse de vendre une spécificité.",
        ),
        qcm_item=(
            "Que restera-t-il si l'on retire l'une des deux phrases « or / toutefois » ?",
            [
                "Un texte plus vrai",
                "Un texte qui ment",
                "Un tampon plus clair",
                "Un défilé plus beau",
            ],
            1,
            "« Les deux phrases restent, ou le texte ment. »",
        ),
        pairs=[
            ("nous affirmons", "écoute, non défilé"),
            ("ce que nous refusons", "vendre"),
            ("or / toutefois", "public / vitesse"),
            ("ainsi", "relire chaque saison"),
        ],
        fill_item=("Nous n'___ obéirons pas comme à une mode.", "y"),
        words=["Un", "manifeste", "n'est", "pas", "une", "affiche", "."],
        anagram=("engagement", "Promesse écrite : relire, oser le mais, préférer une phrase juste."),
        error=(
            "Nous affirmons que la cour n'oublie pas, et c'est le plus bon article que nous ayons osé signer.",
            "Nous affirmons que la cour n'oublie pas, et c'est le meilleur article que nous ayons osé signer.",
            "Meilleur article, pas plus bon.",
        ),
        pic_start=28,
        pic_words=_pw(28),
        short_p="Imitez : quatorze à dix-huit lignes, au moins cinq articles, une concession, un ainsi.",
        audio="Lisez votre manifeste, sans aller trop vite.",
    ),
    _l(
        "EL",
        "EL — Texte argumenté du manifeste",
        "Retenir la charpente d'un texte argumenté : thèse, concession, engagement.",
        "Apprenez la fiche.",
        "Fiche d'Aline, manifeste",
        """Manifeste = texte qui engage une communauté. Pas une affiche. Pas un tampon.
Charpente : nous affirmons / nous refusons / nous proposons / nous nous engageons
Concession honnête : or… ; toutefois… (les deux restent, ou le texte ment)
Conséquence : ainsi ; par conséquent (plus tard). Conclusion mesurée : le mieux, c'est…
Reprendre les outils du module :
comparatifs : la plus juste n'est pas la plus pleine
relatifs : le livre dont… ; la pièce que… ; le figuier sous lequel…
relief : c'est nous qui ; ce que nous refusons, c'est
en / y : en parler, n'y obéir pas
Registre : antenne posée pour signer ; familier permis pour lier, pas pour vider.
Articles courts : un fait, une limite, un geste.
Relire chaque saison. Un manifeste qui ne se relit pas n'est qu'un papier.
Éviter : plus bon, le livre que je parle, c'est… qui + objet, penser à → dont.
Bien que + subj. : bien que ce soit incomplet, nous signons.
À + le = au Seuil ; de + le = du figuier.""",
        tf_item=(
            "Un manifeste, d'après la fiche, peut se passer de concession.",
            False,
            "Sans or / toutefois, le texte risque de mentir.",
        ),
        qcm_item=(
            "Quelle série ouvre surtout la charpente ?",
            [
                "plus / moins / aussi seulement",
                "nous affirmons / refusons / proposons / engageons",
                "chouïa / c'est pas mal seulement",
                "tampon / date / note",
            ],
            1,
            "Les quatre verbes d'engagement.",
        ),
        pairs=[
            ("nous affirmons", "thèse"),
            ("or / toutefois", "concession"),
            ("ainsi", "conséquence"),
            ("nous nous engageons", "promesse"),
        ],
        fill_item=("Un manifeste qui ne se ___ pas n'est qu'un papier.", "relit"),
        words=["Nous", "nous", "engageons", "à", "tenir", "une", "écoute", "."],
        anagram=("these", "Phrase que l'on affirme d'abord, avant la concession. (sans accent)"),
        error=(
            "Nous affirmons que la cour n'oublie pas, et c'est le plus bon article que nous ayons écrit.",
            "Nous affirmons que la cour n'oublie pas, et c'est le meilleur article que nous ayons écrit.",
            "Meilleur article, pas plus bon.",
        ),
        pic_start=29,
        pic_words=_pw(29),
        short_p="Rédigez un plan de manifeste : quatre verbes d'engagement, deux concessions, trois articles.",
        audio="Enregistrez la fiche et cinq phrases : nous affirmons, nous refusons, or, toutefois, ainsi.",
    ),
]


SEQUENCES = [
    {"title": "Préférences et résumés", "lessons": S1},
    {"title": "Débattre et portraits", "lessons": S2},
    {"title": "Problème culturel, solutions", "lessons": S3},
    {"title": "Tendance et création", "lessons": S4},
    {"title": "Bilan de la Saison des Voix", "lessons": S5},
    {"title": "Manifeste culturel du Seuil", "lessons": S6},
]