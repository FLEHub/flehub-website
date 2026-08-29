"""A2 Module 5 — Vivre ensemble autrement (univers Seuil des Sources)."""

from factory import L

IMG = "mfk-a2-m5"
IMG_DIR = IMG

MODULE = {
    "title": "A2 — Vivre ensemble autrement",
    "description": (
        "Grande étape A2-5 : croiser des portraits, rapporter des paroles, "
        "dire d'accord ou pas, donner un avis, convaincre en douceur "
        "et situer un état d'esprit — dans la cour du Seuil des Sources "
        "(Rukiri-Nord), autour du figuier et de la table commune."
    ),
}


def _l(comp, title, obj, cons, st, sp, **kw):
    return L(IMG, comp, title, obj, cons, st, sp, **kw)


# ---------------------------------------------------------------------------
# Séquence 1 — Portraits croisés (c'est / ce sont + relative)
# ---------------------------------------------------------------------------

S1 = [
    _l(
        "CO",
        "CO — C'est Aline qui ouvre",
        "Repérer c'est / ce sont + qui / que dans des portraits.",
        "Lisez le dialogue. Qui fait quoi ? Qui est mis en avant ?",
        "Cour du Seuil, banc des voisins",
        """Patrick : C'est Aline qui ouvre la cour le matin.
Léa : Ce sont les voisins qui rangent les tasses.
Marc : C'est le figuier qui donne l'ombre à midi.
Hawa : C'est Léa que j'écoute quand on parle des règles.
Joël : Ce sont Kévin et Mado qui ferment le portail.
Rose : C'est Sami que Benoît photographie près du banc.
Karim : C'est Yvette qui tient le Cahier du chemin.
Lila : Ce sont les enfants qui arrosent trop vite.""",
        tf_item=(
            "Patrick dit que c'est Aline qui ouvre la cour.",
            True,
            "« C'est Aline qui ouvre la cour le matin. »",
        ),
        qcm_item=(
            "Que reprend « que » dans « C'est Léa que j'écoute » ?",
            ["Le sujet", "Le complément d'objet", "Un lieu", "Un temps"],
            1,
            "J'écoute Léa → que = objet.",
        ),
        pairs=[
            ("c'est Aline qui", "sujet mis en avant"),
            ("ce sont les voisins qui", "pluriel"),
            ("c'est Léa que", "objet"),
            ("c'est le figuier qui", "la cour à midi"),
        ],
        fill_item=("___ sont les voisins qui rangent les tasses.", "Ce"),
        words=["C'est", "Aline", "qui", "ouvre", "la", "cour", "."],
        anagram=("ouvre", "C'est Aline qui… la cour : elle commence la journée."),
        error=(
            "C'est les voisins qui rangent les tasses.",
            "Ce sont les voisins qui rangent les tasses.",
            "Pluriel : ce sont, pas c'est.",
        ),
        pic_start=0,
        pic_words=["un portrait", "une relative", "deux visages", "un cadre"],
        short_p="Notez trois « c'est … qui » et un « c'est … que ».",
        audio="Enregistrez : C'est Aline qui ouvre. Ce sont les voisins qui rangent. C'est Léa que j'écoute.",
    ),
    _l(
        "CE",
        "CE — Fiches portraits",
        "Lire des portraits avec c'est / ce sont + relative.",
        "Lisez les fiches, sans aller trop vite.",
        "Mur de la Maison des Vents",
        """Fiche Aline : C'est Aline qui rappelle les heures calmes.
Fiche Patrick : C'est Patrick que la cour écoute pour le figuier.
Fiche Rose : Ce sont Rose et Hawa qui dressent la Table des Sources.
Fiche Solange : C'est Solange Mukamana qui signe le cahier des règles.
Fiche enfants : Ce sont les enfants que Joël surveille près du puits.
Fiche arbre : C'est le figuier qui unit les voix le soir.
Règle : c'est + singulier. ce sont + pluriel.
qui = sujet. que = objet.""",
        tf_item=(
            "Rose et Hawa dressent la table.",
            True,
            "« Ce sont Rose et Hawa qui dressent la Table des Sources. »",
        ),
        qcm_item=(
            "Qui signe le cahier des règles ?",
            ["Aline", "Patrick", "Solange", "Joël"],
            2,
            "Fiche Solange.",
        ),
        pairs=[
            ("c'est Aline qui", "heures calmes"),
            ("c'est Patrick que", "la cour écoute"),
            ("ce sont Rose et Hawa qui", "la table"),
            ("c'est le figuier qui", "les voix"),
        ],
        fill_item=("C'est le figuier ___ unit les voix.", "qui"),
        words=["Ce", "sont", "les", "enfants", "que", "Joël", "surveille", "."],
        anagram=("rappelle", "C'est Aline qui… les heures : elle dit de nouveau la règle."),
        error=(
            "C'est Rose et Hawa qui dressent la table.",
            "Ce sont Rose et Hawa qui dressent la table.",
            "Deux personnes → ce sont.",
        ),
        pic_start=4,
        pic_words=["une bulle", "une oreille", "un cahier", "une radio"],
        short_p="Recopiez quatre fiches et encadrez qui / que.",
        audio="Lisez les six fiches, sans aller trop vite.",
    ),
    _l(
        "PO",
        "PO — Mettre quelqu'un en avant",
        "Faire un portrait oral avec c'est / ce sont + qui / que.",
        "Répétez, puis présentez un voisin de la cour.",
        "Modèles d'Aline",
        """C'est moi qui range.
C'est toi qui parles.
C'est Léa que nous écoutons.
Ce sont eux qui ferment.
C'est le figuier qui protège.
Ce sont les tasses que je lave.
C'est Noura qui propose.
Ce sont les règles que l'on lit.""",
        tf_item=(
            "« Ce sont eux qui ferment » met le groupe au pluriel.",
            True,
            "Ce sont + pluriel + qui.",
        ),
        qcm_item=(
            "Quelle phrase utilise « que » pour un objet ?",
            [
                "C'est moi qui range",
                "C'est Léa que nous écoutons",
                "C'est le figuier qui protège",
                "Ce sont eux qui ferment",
            ],
            1,
            "Nous écoutons Léa → que.",
        ),
        pairs=[
            ("c'est + singulier", "une personne / une chose"),
            ("ce sont + pluriel", "plusieurs"),
            ("qui", "sujet"),
            ("que", "objet"),
        ],
        fill_item=("Ce ___ les tasses que je lave.", "sont"),
        words=["C'est", "toi", "qui", "parles", "."],
        anagram=("protege", "C'est le figuier qui… : il donne l'ombre (sans accent)."),
        error=(
            "C'est eux qui ferment le portail.",
            "Ce sont eux qui ferment le portail.",
            "Eux = pluriel → ce sont.",
        ),
        pic_start=8,
        pic_words=["un accord", "un désaccord", "deux avis", "une table"],
        short_p="Écrivez six portraits : quatre qui, deux que.",
        audio="Enregistrez les huit modèles, puis deux portraits à vous.",
    ),
    _l(
        "PE",
        "PE — Mes portraits de cour",
        "Écrire des portraits croisés avec c'est / ce sont.",
        "Imitez la page de Marc.",
        "Page de Marc Nkurunziza",
        """Marc Nkurunziza
C'est Aline qui ouvre les heures calmes.
Ce sont les voisins qui partagent la table.
C'est le figuier que nous protégeons.
C'est Hawa que j'écoute le soir.
Ce sont Kévin et Mado qui ferment.
C'est la cour qui nous rassemble.
Marc
Seuil des Sources — Rukiri-Nord""",
        tf_item=(
            "Marc écrit que le figuier est protégé par le groupe.",
            True,
            "« C'est le figuier que nous protégeons. »",
        ),
        qcm_item=(
            "Qui ferme, d'après Marc ?",
            ["Aline seule", "Kévin et Mado", "Solange", "Les tasses"],
            1,
            "« Ce sont Kévin et Mado qui ferment. »",
        ),
        pairs=[
            ("c'est Aline qui", "heures calmes"),
            ("ce sont les voisins qui", "la table"),
            ("c'est le figuier que", "nous protégeons"),
            ("c'est Hawa que", "j'écoute"),
        ],
        fill_item=("C'est la cour ___ nous rassemble.", "qui"),
        words=["C'est", "Hawa", "que", "j'écoute", "."],
        anagram=("rassemble", "C'est la cour qui nous… : elle met tout le monde ensemble."),
        error=(
            "C'est les voisins qui partagent la table.",
            "Ce sont les voisins qui partagent la table.",
            "Voisins = pluriel → ce sont.",
        ),
        pic_start=12,
        pic_words=["une main", "un carnet", "pour", "contre"],
        short_p="Imitez : six lignes avec c'est / ce sont et qui / que.",
        audio="Lisez vos portraits, sans aller trop vite.",
    ),
    _l(
        "EL",
        "EL — C'est, ce sont, qui, que",
        "Retenir c'est / ce sont + proposition relative.",
        "Apprenez la fiche.",
        "Fiche des portraits",
        """C'est + nom singulier + qui / que
Ce sont + nom pluriel + qui / que
qui = sujet : C'est Aline qui ouvre.
que = objet : C'est Léa que j'écoute. (qu' devant voyelle : qu'on)
On met en avant la personne ou la chose importante.
On ne dit pas : C'est les voisins qui…
On ne dit pas : C'est Aline que ouvre (ouvre a besoin d'un sujet : qui).
Accord : ce sont eux / ce sont elles.""",
        tf_item=(
            "On écrit « c'est les voisins qui ».",
            False,
            "Pluriel : ce sont les voisins qui.",
        ),
        qcm_item=(
            "« C'est Aline … ouvre » se complète par…",
            ["que", "qui", "dont", "où"],
            1,
            "Aline est sujet de ouvrir → qui.",
        ),
        pairs=[
            ("c'est", "singulier"),
            ("ce sont", "pluriel"),
            ("qui", "sujet"),
            ("que / qu'", "objet"),
        ],
        fill_item=("C'est Léa ___ j'écoute.", "que"),
        words=["Ce", "sont", "elles", "qui", "ferment", "."],
        anagram=("singulier", "C'est va avec un nom… : une seule personne."),
        error=(
            "C'est Aline que ouvre la cour.",
            "C'est Aline qui ouvre la cour.",
            "Aline fait l'action → qui.",
        ),
        pic_start=16,
        pic_words=["celui", "une flèche", "trois choix", "un panier"],
        short_p="Transformez six phrases en c'est / ce sont + relative.",
        audio="Enregistrez la fiche et six portraits.",
    ),
]


# ---------------------------------------------------------------------------
# Séquence 2 — Ce qu'on m'a dit (discours indirect au présent)
# ---------------------------------------------------------------------------

S2 = [
    _l(
        "CO",
        "CO — On m'a dit que",
        "Comprendre le discours indirect au présent : il dit que, elle demande si.",
        "Lisez le dialogue. Qui rapporte quelles paroles ?",
        "Banc sous le figuier",
        """Léa : Patrick dit que le figuier a trop soif.
Aline : Hawa demande si on peut déplacer la table.
Marc : On m'a dit que les heures calmes commencent à vingt-deux heures.
Rose : Joël dit qu'il ferme le portail.
Karim : Solange demande où se trouve le cahier.
Mado : On m'a dit que Kévin arrose déjà.
Sami : Yvette dit que la cour reste ouverte.
Benoît : Noura demande si Ibrahim vient ce soir.""",
        tf_item=(
            "Patrick dit que le figuier a trop soif.",
            True,
            "Léa rapporte : « Patrick dit que… »",
        ),
        qcm_item=(
            "Que demande Hawa, d'après Aline ?",
            [
                "Si on peut déplacer la table",
                "Si le portail est fermé",
                "Où est Radio Figuier",
                "Quand part le minibus",
            ],
            0,
            "« Hawa demande si on peut déplacer la table. »",
        ),
        pairs=[
            ("dit que", "affirmation rapportée"),
            ("demande si", "question oui / non"),
            ("demande où", "question de lieu"),
            ("on m'a dit que", "parole sans nom"),
        ],
        fill_item=("Hawa demande ___ on peut déplacer la table.", "si"),
        words=["Patrick", "dit", "que", "le", "figuier", "a", "soif", "."],
        anagram=("soif", "Le figuier a trop… : il manque d'eau."),
        error=(
            "Hawa demande que on peut déplacer la table.",
            "Hawa demande si on peut déplacer la table.",
            "Question oui / non → demander si.",
        ),
        pic_start=20,
        pic_words=["une horloge", "un futur", "un passé", "un nuage"],
        short_p="Notez deux « dit que », un « demande si », un « on m'a dit que ».",
        audio="Enregistrez : Il dit que. Elle demande si. On m'a dit que les heures calmes commencent.",
    ),
    _l(
        "CE",
        "CE — Cahier des on-dit",
        "Lire des paroles rapportées au présent.",
        "Lisez le cahier, sans aller trop vite.",
        "Cahier du chemin, page des échos",
        """Échos de la cour — ce qu'on m'a dit
Aline dit que le silence aide le figuier.
Patrick demande si la table peut rester au milieu.
On m'a dit que Félicie Ndayishimiye arrive jeudi.
Rose dit qu'elle prépare un thé à la Table des Sources.
Karim demande quand Dieudonné passe à la Maison des Vents.
Lila Sow dit que Radio Figuier répète les règles le soir.
Attention : après que / si, le verbe reste au présent ici.
On ne change pas encore les temps (pas de « il a dit qu'il fermait »).""",
        tf_item=(
            "Félicie arrive jeudi, d'après ce qu'on a dit.",
            True,
            "« On m'a dit que Félicie Ndayishimiye arrive jeudi. »",
        ),
        qcm_item=(
            "Que prépare Rose ?",
            ["Un micro", "Un thé", "Un tampon", "Un minibus"],
            1,
            "« Rose dit qu'elle prépare un thé. »",
        ),
        pairs=[
            ("Aline dit que", "le silence"),
            ("Patrick demande si", "la table"),
            ("Rose dit qu'elle", "un thé"),
            ("Karim demande quand", "Dieudonné"),
        ],
        fill_item=("Aline dit ___ le silence aide le figuier.", "que"),
        words=["On", "m'a", "dit", "que", "Félicie", "arrive", "."],
        anagram=("silence", "Aline dit que le… aide l'arbre : moins de bruit."),
        error=(
            "Patrick demande que la table peut rester au milieu.",
            "Patrick demande si la table peut rester au milieu.",
            "Question → si, pas que.",
        ),
        pic_start=24,
        pic_words=["une cour", "un banc", "une affiche", "une clé"],
        short_p="Recopiez et transformez deux phrases en discours direct.",
        audio="Lisez les six échos, sans aller trop vite.",
    ),
    _l(
        "PO",
        "PO — Rapporter une parole",
        "Rapporter au présent : il dit que, elle demande si.",
        "Répétez, puis rapportez une phrase d'un voisin.",
        "Modèles de Léa",
        """Il dit que c'est simple.
Elle demande si tu viens.
On m'a dit que c'est ouvert.
Il dit qu'il range.
Elle demande où tu vas.
On m'a dit que ça suffit.
Ils disent que la cour est calme.
Elle demande pourquoi on attend.""",
        tf_item=(
            "Après « demander », une question oui / non prend « si ».",
            True,
            "Elle demande si tu viens.",
        ),
        qcm_item=(
            "Quelle phrase rapporte une question de lieu ?",
            [
                "Il dit que c'est simple",
                "Elle demande où tu vas",
                "On m'a dit que ça suffit",
                "Ils disent que la cour est calme",
            ],
            1,
            "Demander où.",
        ),
        pairs=[
            ("dire que", "affirmation"),
            ("demander si", "oui / non"),
            ("demander où", "lieu"),
            ("demander pourquoi", "cause"),
        ],
        fill_item=("Elle demande ___ tu viens.", "si"),
        words=["Il", "dit", "qu'il", "range", "."],
        anagram=("ouvert", "On m'a dit que c'est… : on peut entrer."),
        error=(
            "Elle demande que tu viens ce soir ici maintenant.",
            "Elle demande si tu viens.",
            "Question oui / non → si.",
        ),
        pic_start=28,
        pic_words=["un figuier", "une porte", "un portrait", "une relative"],
        short_p="Écrivez six rapports : deux que, deux si, un où, un pourquoi.",
        audio="Enregistrez les huit modèles, puis deux phrases rapportées à vous.",
    ),
    _l(
        "PE",
        "PE — Mon cahier d'échos",
        "Écrire ce qu'on vous a dit, au présent.",
        "Imitez le cahier d'Hawa.",
        "Cahier de Hawa Diallo",
        """Hawa Diallo
Aline dit que les heures calmes commencent tôt.
Patrick demande si j'arrose le figuier.
On m'a dit que la table reste au milieu.
Rose dit qu'elle prépare les tasses.
Joël demande où se range le seau.
On m'a dit que Sami arrive après le thé.
Hawa
Cour du Seuil""",
        tf_item=(
            "Joël demande où se range le seau.",
            True,
            "Avant-dernière ligne du cahier.",
        ),
        qcm_item=(
            "Que dit-on de la table ?",
            ["Elle part", "Elle reste au milieu", "Elle se casse", "Elle est vendue"],
            1,
            "« On m'a dit que la table reste au milieu. »",
        ),
        pairs=[
            ("Aline dit que", "heures calmes"),
            ("Patrick demande si", "arroser"),
            ("Rose dit qu'elle", "tasses"),
            ("Joël demande où", "seau"),
        ],
        fill_item=("Patrick demande ___ j'arrose le figuier.", "si"),
        words=["Aline", "dit", "que", "ça", "commence", "tôt", "."],
        anagram=("arroser", "Patrick demande si je… l'arbre : lui donner de l'eau."),
        error=(
            "On m'a dit si la table reste au milieu.",
            "On m'a dit que la table reste au milieu.",
            "Dire + affirmation → que, pas si.",
        ),
        pic_start=1,
        pic_words=["une relative", "deux visages", "un cadre", "une bulle"],
        short_p="Imitez : six lignes de paroles rapportées au présent.",
        audio="Lisez votre cahier, sans aller trop vite.",
    ),
    _l(
        "EL",
        "EL — Discours indirect au présent",
        "Retenir il dit que, elle demande si, on m'a dit que.",
        "Apprenez la fiche.",
        "Fiche des paroles",
        """Direct : « Le figuier a soif. » → Il dit que le figuier a soif.
Direct : « Tu viens ? » → Elle demande si tu viens.
Direct : « Où est le cahier ? » → Il demande où est le cahier.
On m'a dit que + phrase au présent.
que / qu' (élision : dit qu'il).
demander si (pas demander que pour une question).
dire que (pas dire si pour une affirmation).
Ici, les verbes restent au présent : pas de changement de temps.""",
        tf_item=(
            "On transforme « Tu viens ? » par « elle demande que tu viens ».",
            False,
            "Question → elle demande si tu viens.",
        ),
        qcm_item=(
            "« Il dit … il range » s'écrit…",
            ["dit que il", "dit qu'il", "dit si il", "dit qui il"],
            1,
            "Élision : qu'il.",
        ),
        pairs=[
            ("dire que", "phrase déclarative"),
            ("demander si", "question fermée"),
            ("demander où / quand", "question ouverte"),
            ("on m'a dit que", "source vague"),
        ],
        fill_item=("Il dit ___ le portail ferme.", "que"),
        words=["Elle", "demande", "si", "tu", "viens", "."],
        anagram=("present", "Ici le verbe rapporté reste au… (sans accent)."),
        error=(
            "Il dit si le figuier a soif.",
            "Il dit que le figuier a soif.",
            "Affirmation → que.",
        ),
        pic_start=5,
        pic_words=["une oreille", "un cahier", "une radio", "un accord"],
        short_p="Passez six phrases du direct à l'indirect au présent.",
        audio="Enregistrez la fiche et six transformations.",
    ),
]


# ---------------------------------------------------------------------------
# Séquence 3 — D'accord, pas d'accord (où / dont)
# ---------------------------------------------------------------------------

S3 = [
    _l(
        "CO",
        "CO — Le lieu où l'on discute",
        "Repérer où et dont dans un débat de voisins.",
        "Lisez le dialogue. Où ? Dont quoi ?",
        "Table des Sources, débat du soir",
        """Aline : La cour où nous vivons doit rester calme.
Patrick : Le figuier dont les racines ont soif a besoin d'eau.
Léa : La raison dont on parle, c'est le bruit après vingt-deux heures.
Marc : Le banc où Sami s'assoit est trop près du portail.
Hawa : Le sujet dont Joël discute, c'est la table au milieu.
Rose : L'heure où tout s'arrête, c'est vingt-deux heures.
Karim : La règle dont Solange rappelle le texte est claire.
Noura : Le lieu où l'on se tait, c'est sous le figuier.""",
        tf_item=(
            "Aline parle de la cour où le groupe vit.",
            True,
            "« La cour où nous vivons… »",
        ),
        qcm_item=(
            "« Dont » dans « le figuier dont les racines » remplace…",
            ["un lieu", "de + nom (les racines de)", "un temps", "un objet direct"],
            1,
            "Les racines du figuier → dont.",
        ),
        pairs=[
            ("où nous vivons", "la cour"),
            ("dont les racines", "le figuier"),
            ("dont on parle", "la raison"),
            ("où tout s'arrête", "vingt-deux heures"),
        ],
        fill_item=("La cour ___ nous vivons doit rester calme.", "où"),
        words=["Le", "sujet", "dont", "Joël", "discute", "."],
        anagram=("racines", "Elles ont soif : la partie cachée de l'arbre."),
        error=(
            "La cour dont nous vivons doit rester calme.",
            "La cour où nous vivons doit rester calme.",
            "Vivre dans un lieu → où.",
        ),
        pic_start=9,
        pic_words=["un désaccord", "deux avis", "une table", "une main"],
        short_p="Notez trois « où » et trois « dont ».",
        audio="Enregistrez : La cour où nous vivons. Le sujet dont on parle. L'heure où tout s'arrête.",
    ),
    _l(
        "CE",
        "CE — Affiche du débat",
        "Lire un texte de débat avec où et dont.",
        "Lisez l'affiche, sans aller trop vite.",
        "Affiche ocre, Maison des Vents",
        """Débat — vivre sous le figuier
1. Le lieu où l'on dîne, c'est la Table des Sources.
2. La raison dont Aline parle, c'est le repos des enfants.
3. Le soir où Radio Figuier s'arrête, la cour écoute autrement.
4. Les règles dont nous avons besoin sont sur le cahier.
5. Le banc où Mado coud reste à l'ombre.
6. L'arbre dont l'ombre est douce n'est pas à nous seuls.
où = lieu ou moment. dont = de + nom / de + idée.
On parle de quelque chose → dont on parle.""",
        tf_item=(
            "Les règles dont le groupe a besoin sont sur le cahier.",
            True,
            "Point 4 de l'affiche.",
        ),
        qcm_item=(
            "Où Mado coud-elle ?",
            ["À la radio", "Au banc à l'ombre", "Au Bureau des Escales", "À Port de la Brise"],
            1,
            "« Le banc où Mado coud reste à l'ombre. »",
        ),
        pairs=[
            ("où l'on dîne", "table"),
            ("dont Aline parle", "repos"),
            ("où Radio s'arrête", "soir"),
            ("dont l'ombre est douce", "arbre"),
        ],
        fill_item=("Les règles ___ nous avons besoin sont sur le cahier.", "dont"),
        words=["Le", "lieu", "où", "l'on", "dîne", "."],
        anagram=("besoin", "Les règles dont nous avons… : elles nous manquent si on les oublie."),
        error=(
            "Les règles où nous avons besoin sont sur le cahier.",
            "Les règles dont nous avons besoin sont sur le cahier.",
            "Avoir besoin de → dont.",
        ),
        pic_start=13,
        pic_words=["un carnet", "pour", "contre", "celui"],
        short_p="Recopiez et classez : où lieu, où moment, dont.",
        audio="Lisez les six points, sans aller trop vite.",
    ),
    _l(
        "PO",
        "PO — Dire où et dont",
        "Relier avec où (lieu / moment) et dont (de + nom).",
        "Répétez, puis parlez d'un désaccord de la cour.",
        "Modèles de Patrick",
        """C'est le lieu où l'on parle.
C'est l'heure où l'on se tait.
C'est le sujet dont on discute.
C'est la raison dont je me souviens.
C'est l'arbre où l'ombre tombe.
C'est la règle dont Aline parle.
C'est la cour où je vis.
C'est l'ami dont j'écoute l'avis.""",
        tf_item=(
            "« Dont » remplace souvent « de + nom ».",
            True,
            "Parler de → dont on parle.",
        ),
        qcm_item=(
            "On dit « le sujet … on discute » comment ?",
            ["où", "que", "dont", "qui"],
            2,
            "Discuter de → dont.",
        ),
        pairs=[
            ("où", "lieu ou moment"),
            ("dont", "de + nom"),
            ("dont on parle", "parler de"),
            ("où je vis", "vivre dans"),
        ],
        fill_item=("C'est le sujet ___ on discute.", "dont"),
        words=["C'est", "la", "cour", "où", "je", "vis", "."],
        anagram=("discute", "Le sujet dont on… : on en parle, parfois sans être d'accord."),
        error=(
            "C'est le sujet où on discute trop longtemps ici.",
            "C'est le sujet dont on discute.",
            "Discuter de quelque chose → dont.",
        ),
        pic_start=17,
        pic_words=["une flèche", "trois choix", "un panier", "une horloge"],
        short_p="Écrivez huit relatives : quatre où, quatre dont.",
        audio="Enregistrez les huit modèles, puis deux phrases à vous.",
    ),
    _l(
        "PE",
        "PE — Ma note de débat",
        "Écrire une note avec où et dont.",
        "Imitez la note de Léa.",
        "Note de Léa Niyonzima",
        """Léa Niyonzima
La cour où nous dînons doit rester nette.
L'heure où le bruit s'arrête est vingt-deux heures.
Le figuier dont l'ombre nous unit a besoin d'eau.
La raison dont Patrick parle, c'est le repos.
Le banc où je couds reste à gauche.
La règle dont on a besoin est sur le mur.
Léa""",
        tf_item=(
            "Léa place le repos comme raison dont Patrick parle.",
            True,
            "« La raison dont Patrick parle, c'est le repos. »",
        ),
        qcm_item=(
            "Quelle heure Léa écrit-elle ?",
            ["Vingt heures", "Vingt-deux heures", "Midi", "Minuit"],
            1,
            "« L'heure où le bruit s'arrête est vingt-deux heures. »",
        ),
        pairs=[
            ("où nous dînons", "cour"),
            ("où le bruit s'arrête", "heure"),
            ("dont l'ombre nous unit", "figuier"),
            ("dont on a besoin", "règle"),
        ],
        fill_item=("Le banc ___ je couds reste à gauche.", "où"),
        words=["La", "règle", "dont", "on", "a", "besoin", "."],
        anagram=("ombre", "Le figuier dont l'… nous unit : le frais sous les feuilles."),
        error=(
            "La raison où Patrick parle c'est le repos.",
            "La raison dont Patrick parle c'est le repos.",
            "Parler de la raison → dont.",
        ),
        pic_start=21,
        pic_words=["un futur", "un passé", "un nuage", "une cour"],
        short_p="Imitez : six lignes avec où et dont.",
        audio="Lisez votre note, sans aller trop vite.",
    ),
    _l(
        "EL",
        "EL — Relatifs où et dont",
        "Retenir le lieu / le moment où et le nom dont.",
        "Apprenez la fiche.",
        "Fiche du débat",
        """où = dans ce lieu / à ce moment
la cour où nous vivons / l'heure où l'on se tait
dont = de + nom (possession, thème, besoin)
l'arbre dont les feuilles… / le sujet dont on parle
avoir besoin de → dont on a besoin
parler de / se souvenir de / discuter de → dont
On ne dit pas : le lieu dont nous vivons.
On ne dit pas : le sujet où on discute.
Élision : l'heure où (pas d'élision de où).""",
        tf_item=(
            "On écrit « le lieu dont nous vivons ».",
            False,
            "Vivre dans un lieu → où.",
        ),
        qcm_item=(
            "« Avoir besoin de cette règle » → la règle…",
            ["où on a besoin", "dont on a besoin", "que on a besoin", "qui on a besoin"],
            1,
            "De → dont.",
        ),
        pairs=[
            ("où", "lieu / moment"),
            ("dont", "de + nom"),
            ("parler de", "dont on parle"),
            ("vivre dans", "où l'on vit"),
        ],
        fill_item=("C'est l'ami ___ j'écoute l'avis.", "dont"),
        words=["C'est", "l'heure", "où", "l'on", "se", "tait", "."],
        anagram=("moment", "Où sert aussi pour un… : l'heure où l'on se tait."),
        error=(
            "C'est le sujet où je me souviens.",
            "C'est le sujet dont je me souviens.",
            "Se souvenir de → dont.",
        ),
        pic_start=25,
        pic_words=["un banc", "une affiche", "une clé", "un figuier"],
        short_p="Complétez huit phrases : où ou dont.",
        audio="Enregistrez la fiche et huit relatives.",
    ),
]


# ---------------------------------------------------------------------------
# Séquence 4 — Vivre ensemble (demander / donner un avis)
# ---------------------------------------------------------------------------

S4 = [
    _l(
        "CO",
        "CO — À mon avis le figuier",
        "Comprendre des avis : à mon avis, je trouve que, je ne suis pas d'accord.",
        "Lisez le dialogue. Qui est d'accord ? Qui ne l'est pas ?",
        "Cour, autour de la table",
        """Aline : À mon avis, le figuier doit rester au centre.
Patrick : Je trouve que tu as raison.
Léa : Et toi, tu en penses quoi, Marc ?
Marc : Je ne suis pas d'accord. La table prend trop de place.
Hawa : Selon moi, on peut garder les deux.
Joël : Pour moi, les heures calmes sont trop tôt.
Rose : Je suis d'accord avec Aline.
Kévin : Moi, je pense que le portail doit rester ouvert.""",
        tf_item=(
            "Marc n'est pas d'accord avec Aline sur la place.",
            True,
            "« Je ne suis pas d'accord. La table prend trop de place. »",
        ),
        qcm_item=(
            "Qui demande l'avis de Marc ?",
            ["Aline", "Léa", "Hawa", "Rose"],
            1,
            "« Et toi, tu en penses quoi, Marc ? »",
        ),
        pairs=[
            ("à mon avis", "Aline"),
            ("je trouve que", "Patrick"),
            ("tu en penses quoi", "Léa à Marc"),
            ("je ne suis pas d'accord", "Marc"),
        ],
        fill_item=("___ mon avis, le figuier doit rester au centre.", "À"),
        words=["Je", "trouve", "que", "tu", "as", "raison", "."],
        anagram=("raison", "Patrick trouve qu'Aline a… : il la suit."),
        error=(
            "Je ne suis pas d'accord que le figuier trop.",
            "Je ne suis pas d'accord.",
            "D'accord se construit souvent seul, ou avec avec + nom.",
        ),
        pic_start=2,
        pic_words=["deux visages", "un cadre", "une bulle", "une oreille"],
        short_p="Notez deux accords et deux désaccords.",
        audio="Enregistrez : À mon avis. Je trouve que. Et toi tu en penses quoi. Je ne suis pas d'accord.",
    ),
    _l(
        "CE",
        "CE — Cartes d'avis",
        "Lire des cartes pour demander et donner un avis.",
        "Lisez les cartes, sans aller trop vite.",
        "Cartes épinglées au figuier",
        """Carte Aline : À mon avis, il faut moins de bruit après vingt-deux heures.
Carte Patrick : Je trouve que le seau doit rester près de l'arbre.
Carte Léa : Et vous, vous en pensez quoi du banc trop près du portail ?
Carte Marc : Je ne suis pas d'accord avec le déplacement de la table.
Carte Hawa : Selon moi, on peut essayer une semaine.
Carte Solange : Pour moi, les règles du cahier suffisent.
Il faut (toujours 3e personne) + infinitif.
Je trouve que + phrase. Être d'accord avec + quelqu'un.""",
        tf_item=(
            "Solange trouve que les règles du cahier suffisent.",
            True,
            "Carte Solange : « Pour moi, les règles du cahier suffisent. »",
        ),
        qcm_item=(
            "Qui propose d'essayer une semaine ?",
            ["Marc", "Hawa", "Léa", "Aline"],
            1,
            "Carte Hawa.",
        ),
        pairs=[
            ("à mon avis", "moins de bruit"),
            ("je trouve que", "le seau"),
            ("vous en pensez quoi", "le banc"),
            ("selon moi", "une semaine"),
        ],
        fill_item=("Je ne suis pas d'accord ___ le déplacement.", "avec"),
        words=["Selon", "moi", "on", "peut", "essayer", "."],
        anagram=("essayer", "Hawa propose d'… une semaine : faire le test."),
        error=(
            "Je faut moins de bruit après vingt-deux heures.",
            "Il faut moins de bruit après vingt-deux heures.",
            "Toujours il faut, jamais je faut.",
        ),
        pic_start=6,
        pic_words=["un cahier", "une radio", "un accord", "un désaccord"],
        short_p="Recopiez et ajoutez votre avis en une phrase.",
        audio="Lisez les six cartes, sans aller trop vite.",
    ),
    _l(
        "PO",
        "PO — Dire son avis",
        "Demander et donner un avis à voix haute.",
        "Répétez, puis donnez votre avis sur la cour.",
        "Modèles d'Hawa",
        """À mon avis, c'est juste.
Je trouve que c'est trop tôt.
Et toi, tu en penses quoi ?
Je suis d'accord.
Je ne suis pas d'accord.
Selon moi, on peut attendre.
Pour moi, la table reste.
Je pense que le figuier suffit.""",
        tf_item=(
            "« Et toi, tu en penses quoi ? » sert à demander un avis.",
            True,
            "Question d'opinion.",
        ),
        qcm_item=(
            "Quelle phrase exprime un désaccord ?",
            [
                "Je suis d'accord",
                "Je ne suis pas d'accord",
                "À mon avis c'est juste",
                "Selon moi on peut attendre",
            ],
            1,
            "Négation de être d'accord.",
        ),
        pairs=[
            ("à mon avis", "opinion"),
            ("je trouve que", "jugement"),
            ("tu en penses quoi", "demande"),
            ("d'accord / pas d'accord", "position"),
        ],
        fill_item=("Et toi, tu ___ penses quoi ?", "en"),
        words=["Je", "ne", "suis", "pas", "d'accord", "."],
        anagram=("attente", "Selon moi on peut… : ne pas décider tout de suite. (nom)"),
        error=(
            "Je trouve ça que c'est trop tôt.",
            "Je trouve que c'est trop tôt.",
            "Je trouve que + phrase, sans ça.",
        ),
        pic_start=10,
        pic_words=["deux avis", "une table", "une main", "un carnet"],
        short_p="Écrivez huit phrases d'avis (demander / donner / accord / désaccord).",
        audio="Enregistrez les huit modèles, puis votre avis sur le figuier.",
    ),
    _l(
        "PE",
        "PE — Mon mot d'avis",
        "Écrire un mot pour donner et demander un avis.",
        "Imitez le mot de Rose.",
        "Mot de Rose Iradukunda",
        """Rose Iradukunda
À mon avis, le figuier doit garder l'eau le matin.
Je trouve que la table peut rester au milieu.
Et toi, tu en penses quoi, Patrick ?
Je ne suis pas d'accord avec un portail fermé trop tôt.
Selon moi, il faut écouter les enfants aussi.
Je suis d'accord avec les heures calmes.
Rose""",
        tf_item=(
            "Rose n'est pas d'accord avec un portail fermé trop tôt.",
            True,
            "Quatrième ligne du corps.",
        ),
        qcm_item=(
            "À qui Rose demande-t-elle son avis ?",
            ["Aline", "Patrick", "Joël", "Solange"],
            1,
            "« Et toi, tu en penses quoi, Patrick ? »",
        ),
        pairs=[
            ("à mon avis", "l'eau"),
            ("je trouve que", "la table"),
            ("tu en penses quoi", "Patrick"),
            ("selon moi", "les enfants"),
        ],
        fill_item=("Je suis d'accord ___ les heures calmes.", "avec"),
        words=["À", "mon", "avis", "c'est", "juste", "."],
        anagram=("calmes", "Les heures… : moins de bruit le soir."),
        error=(
            "Je suis d'accord que les heures calmes trop.",
            "Je suis d'accord avec les heures calmes.",
            "Être d'accord avec + nom.",
        ),
        pic_start=14,
        pic_words=["pour", "contre", "celui", "une flèche"],
        short_p="Imitez : six lignes d'avis (avis, trouve que, demande, accord).",
        audio="Lisez votre mot, sans aller trop vite.",
    ),
    _l(
        "EL",
        "EL — Structures d'avis",
        "Retenir les formules pour demander et donner un avis.",
        "Apprenez la fiche.",
        "Fiche de la table",
        """Donner : à mon avis / selon moi / pour moi / je pense que / je trouve que
Demander : et toi, tu en penses quoi ? / vous en pensez quoi ?
Position : je suis d'accord (avec + nom) / je ne suis pas d'accord
il faut + infinitif (il, toujours)
Je trouve que + phrase complète.
On ne dit pas : je faut. On ne dit pas : à mon avis que (sans verbe après, oui ; pas « que » obligatoire).
Politesse : je ne suis pas tout à fait d'accord.
en = de cela : tu en penses quoi (de cela).""",
        tf_item=(
            "« Tu en penses quoi » : en reprend le sujet du débat.",
            True,
            "En = de cela.",
        ),
        qcm_item=(
            "Quelle forme est correcte ?",
            ["je faut écouter", "il faut écouter", "tu faut écouter", "nous faut écouter"],
            1,
            "Toujours il faut.",
        ),
        pairs=[
            ("à mon avis", "opinion personnelle"),
            ("je trouve que", "jugement + phrase"),
            ("d'accord avec", "soutien"),
            ("tu en penses quoi", "demande"),
        ],
        fill_item=("Je trouve ___ c'est trop tôt.", "que"),
        words=["Pour", "moi", "la", "table", "reste", "."],
        anagram=("opinion", "À mon avis, selon moi : c'est une… personnelle."),
        error=(
            "Je trouve de que c'est trop tôt.",
            "Je trouve que c'est trop tôt.",
            "Trouver que, sans de.",
        ),
        pic_start=18,
        pic_words=["trois choix", "un panier", "une horloge", "un futur"],
        short_p="Rédigez un mini-dialogue de huit répliques d'avis.",
        audio="Enregistrez la fiche et six formules.",
    ),
]


# ---------------------------------------------------------------------------
# Séquence 5 — Convaincre en douceur (celui / celle / ceux / celles)
# ---------------------------------------------------------------------------

S5 = [
    _l(
        "CO",
        "CO — Celui du figuier",
        "Comprendre celui, celle, ceux, celles pour désigner sans répéter.",
        "Lisez le dialogue. Celui de qui ? Celle qui… ?",
        "Ombre du figuier, choix de règles",
        """Aline : Prenez celui de Patrick, le seau bleu.
Léa : Je préfère celle qui est près du banc, la règle courte.
Marc : Ceux que Joël a écrits sont plus clairs.
Hawa : Celles de Rose restent sur la table.
Patrick : Celui qui fuit, c'est le vieux seau.
Karim : Celle de Solange, la clé, ouvre encore.
Mado : Ceux du milieu, les bancs, gênent le passage.
Sami : Celles que nous lisons le soir suffisent.""",
        tf_item=(
            "Aline désigne le seau de Patrick par « celui de Patrick ».",
            True,
            "Celui de + nom = le seau de Patrick.",
        ),
        qcm_item=(
            "« Celles de Rose » reprend…",
            ["Les seaux", "Les règles / affaires au féminin pluriel", "Les bancs", "Les portails"],
            1,
            "Celles = féminin pluriel.",
        ),
        pairs=[
            ("celui de Patrick", "le seau"),
            ("celle qui est près", "la règle"),
            ("ceux que Joël a écrits", "les textes"),
            ("celles de Rose", "sur la table"),
        ],
        fill_item=("Prenez ___ de Patrick, le seau bleu.", "celui"),
        words=["Je", "préfère", "celle", "qui", "est", "près", "."],
        anagram=("fuit", "Celui qui… : le vieux seau laisse partir l'eau."),
        error=(
            "Prenez celle de Patrick, le seau bleu.",
            "Prenez celui de Patrick, le seau bleu.",
            "Seau est masculin : celui.",
        ),
        pic_start=22,
        pic_words=["un passé", "un nuage", "une cour", "un banc"],
        short_p="Notez les quatre formes et le nom qu'elles évitent.",
        audio="Enregistrez : Celui de Patrick. Celle qui est près. Ceux que Joël a écrits. Celles de Rose.",
    ),
    _l(
        "CE",
        "CE — Liste de choix",
        "Lire une liste qui utilise les pronoms démonstratifs.",
        "Lisez la liste, sans aller trop vite.",
        "Liste de Karim Bamba",
        """Choix pour convaincre sans hausser la voix
1. Prenez celui du figuier, pas celui du portail.
2. Gardez celle qui est courte, pas celle qui est trop longue.
3. Lisez ceux que Solange a signés.
4. Rangez celles que les enfants ont laissées.
5. Celui-ci (près de moi) est plus léger que celui-là.
6. Celles-ci restent ; celles-là partent à la Maison des Vents.
celui / celle / ceux / celles + de + nom
+ qui (sujet) / + que (objet).""",
        tf_item=(
            "On oppose celui du figuier et celui du portail.",
            True,
            "Point 1 de la liste.",
        ),
        qcm_item=(
            "Que faut-il lire, d'après le point 3 ?",
            [
                "Ceux que Solange a signés",
                "Celles du portail",
                "Celui-là seulement",
                "Le seau de Marc",
            ],
            0,
            "« Lisez ceux que Solange a signés. »",
        ),
        pairs=[
            ("celui du figuier", "pas du portail"),
            ("celle qui est courte", "règle"),
            ("ceux que Solange a signés", "textes"),
            ("celles que les enfants ont laissées", "affaires"),
        ],
        fill_item=("Gardez ___ qui est courte.", "celle"),
        words=["Lisez", "ceux", "que", "Solange", "a", "signés", "."],
        anagram=("signes", "Ceux que Solange a… : elle a mis son nom (sans accent)."),
        error=(
            "Lisez celles que Solange a signés.",
            "Lisez ceux que Solange a signés.",
            "Textes / papiers masculins → ceux, participe signés.",
        ),
        pic_start=26,
        pic_words=["une affiche", "une clé", "un figuier", "une porte"],
        short_p="Recopiez et reliez chaque pronom à un nom.",
        audio="Lisez les six points, sans aller trop vite.",
    ),
    _l(
        "PO",
        "PO — Désigner sans répéter",
        "Utiliser celui / celle / ceux / celles à l'oral.",
        "Répétez, puis désignez un objet de la cour.",
        "Modèles d'Aline",
        """Celui de Marc.
Celle de Léa.
Ceux du milieu.
Celles de la table.
Celui qui reste.
Celle que je lis.
Ceux que vous voulez.
Celles qui sont propres.""",
        tf_item=(
            "« Celui qui » introduit un sujet.",
            True,
            "Celui qui reste : qui = sujet.",
        ),
        qcm_item=(
            "Pour « les tasses de la table », on dit…",
            ["celui de la table", "celle de la table", "ceux de la table", "celles de la table"],
            3,
            "Tasses = féminin pluriel → celles.",
        ),
        pairs=[
            ("celui", "masculin singulier"),
            ("celle", "féminin singulier"),
            ("ceux", "masculin pluriel"),
            ("celles", "féminin pluriel"),
        ],
        fill_item=("___ que je lis est courte.", "Celle"),
        words=["Celui", "qui", "reste", "est", "bleu", "."],
        anagram=("milieu", "Ceux du… : ni à gauche ni à droite, au centre."),
        error=(
            "Celle de Marc est trop lourd, le seau.",
            "Celui de Marc est trop lourd.",
            "Seau masculin → celui, lourd.",
        ),
        pic_start=29,
        pic_words=["une porte", "un portrait", "une relative", "deux visages"],
        short_p="Écrivez huit désignations : deux de chaque forme.",
        audio="Enregistrez les huit modèles, puis trois désignations à vous.",
    ),
    _l(
        "PE",
        "PE — Ma proposition douce",
        "Écrire une proposition qui désigne avec celui / celle / ceux / celles.",
        "Imitez la proposition de Patrick.",
        "Proposition de Patrick Habimana",
        """Patrick Habimana
Gardons celui du figuier, le seau plein.
Laissons celle qui est courte, la règle du soir.
Lisons ceux qu'Aline a recopiés.
Rangeons celles de la Table des Sources.
Celui qui fuit peut partir à l'Atelier.
Celles que nous gardons suffisent pour demain.
Patrick""",
        tf_item=(
            "Patrick veut garder le seau du figuier.",
            True,
            "« Gardons celui du figuier, le seau plein. »",
        ),
        qcm_item=(
            "Que faire de la règle courte ?",
            ["La jeter", "La laisser", "La vendre", "La cacher"],
            1,
            "« Laissons celle qui est courte. »",
        ),
        pairs=[
            ("celui du figuier", "seau"),
            ("celle qui est courte", "règle"),
            ("ceux qu'Aline a recopiés", "textes"),
            ("celles de la table", "tasses / affaires"),
        ],
        fill_item=("Rangeons ___ de la Table des Sources.", "celles"),
        words=["Gardons", "celui", "du", "figuier", "."],
        anagram=("recopies", "Ceux qu'Aline a… : elle a écrit une deuxième fois (sans accent)."),
        error=(
            "Gardons celle du figuier, le seau plein.",
            "Gardons celui du figuier, le seau plein.",
            "Seau → celui.",
        ),
        pic_start=3,
        pic_words=["un cadre", "une bulle", "une oreille", "un cahier"],
        short_p="Imitez : six lignes avec les quatre pronoms.",
        audio="Lisez votre proposition, sans aller trop vite.",
    ),
    _l(
        "EL",
        "EL — Celui, celle, ceux, celles",
        "Retenir les pronoms démonstratifs et leurs suites.",
        "Apprenez la fiche.",
        "Fiche pour convaincre",
        """celui / celle / ceux / celles remplacent un nom déjà connu.
+ de + nom : celui de Patrick / celles de la table
+ qui : celui qui fuit (sujet)
+ que : ceux que j'ai lus (objet) — qu' devant voyelle
celui-ci / celui-là : proche / plus loin
Accord avec le nom remplacé, pas avec « de + nom » seul.
On ne dit pas : le celui de Patrick.
On ne dit pas : ceux de Rose pour des tasses (tasses → celles).""",
        tf_item=(
            "On dit « le celui de Patrick ».",
            False,
            "Pas d'article devant celui.",
        ),
        qcm_item=(
            "« Que + elle a signés » après ceux s'écrit…",
            ["ceux que elle", "ceux qu'elle", "ceux qui elle", "ceux quelle"],
            1,
            "Élision : qu'elle.",
        ),
        pairs=[
            ("celui de", "possession / origine"),
            ("celle qui", "sujet fém."),
            ("ceux que", "objet masc. pl."),
            ("celles-ci / celles-là", "proche / loin"),
        ],
        fill_item=("Rangez ___ qu'elle a laissées.", "celles"),
        words=["Prenez", "celui-ci", "pas", "celui-là", "."],
        anagram=("article", "On ne met pas le ou la devant celui : pas d'…"),
        error=(
            "Prenez le celui de Patrick.",
            "Prenez celui de Patrick.",
            "Celui sans article.",
        ),
        pic_start=7,
        pic_words=["une radio", "un accord", "un désaccord", "deux avis"],
        short_p="Remplacez huit noms répétés par celui / celle / ceux / celles.",
        audio="Enregistrez la fiche et huit exemples.",
    ),
]


# ---------------------------------------------------------------------------
# Séquence 6 — Un état d'esprit (en train de / aller / venir de)
# ---------------------------------------------------------------------------

S6 = [
    _l(
        "CO",
        "CO — On est en train de",
        "Comprendre être en train de, aller + infinitif, venir de + infinitif.",
        "Lisez le dialogue. Qu'est-ce qui se passe maintenant, bientôt, juste avant ?",
        "Cour au réveil, Table des Sources",
        """Aline : Je suis en train d'ouvrir le cahier.
Patrick : Léa va arroser le figuier.
Hawa : Marc vient de ranger les tasses.
Joël : Nous sommes en train de discuter des heures calmes.
Rose : Ils vont fermer le portail tout à l'heure.
Kévin : Je viens de parler à Yvette.
Mado : Sami est en train de coudre près du banc.
Lila : On va se retrouver à la table ce soir.""",
        tf_item=(
            "Marc vient de ranger : l'action est toute récente.",
            True,
            "Venir de + infinitif = passé récent.",
        ),
        qcm_item=(
            "Que va faire Léa ?",
            ["Ouvrir le cahier", "Arroser le figuier", "Fermer le portail", "Coudre"],
            1,
            "« Léa va arroser le figuier. » — futur proche.",
        ),
        pairs=[
            ("être en train de", "action en cours"),
            ("aller + infinitif", "futur proche"),
            ("venir de + infinitif", "passé récent"),
            ("je viens de parler", "à Yvette"),
        ],
        fill_item=("Je suis en train ___ ouvrir le cahier.", "d'"),
        words=["Léa", "va", "arroser", "le", "figuier", "."],
        anagram=("recent", "Venir de : l'action vient de se terminer, c'est… (sans accent)."),
        error=(
            "Je suis en train que j'ouvre le cahier.",
            "Je suis en train d'ouvrir le cahier.",
            "Être en train de + infinitif.",
        ),
        pic_start=11,
        pic_words=["une table", "une main", "un carnet", "pour"],
        short_p="Classez six actions : en cours / tout à l'heure / à l'instant.",
        audio="Enregistrez : Je suis en train d'ouvrir. Léa va arroser. Marc vient de ranger.",
    ),
    _l(
        "CE",
        "CE — Tableau des moments",
        "Lire un tableau d'états d'esprit et de temps proches.",
        "Lisez le tableau, sans aller trop vite.",
        "Tableau ocre, Salle des Herbes",
        """Maintenant — être en train de
Aline est en train de lire le cahier.
Les voisins sont en train de déplacer un banc.
Tout à l'heure — aller + infinitif
Patrick va parler à Radio Figuier.
Nous allons essayer les heures calmes.
À l'instant — venir de + infinitif
Hawa vient d'éteindre la lanterne.
Joël et Rose viennent de signer.
Attention : je vais (futur proche) ≠ je serai (futur simple).
venir de ≠ venir à (lieu).""",
        tf_item=(
            "Hawa vient d'éteindre : c'est tout juste fait.",
            True,
            "Venir de + infinitif.",
        ),
        qcm_item=(
            "Quelle phrase est au futur proche ?",
            [
                "Aline est en train de lire",
                "Patrick va parler à Radio Figuier",
                "Hawa vient d'éteindre",
                "Joël et Rose viennent de signer",
            ],
            1,
            "Aller + infinitif.",
        ),
        pairs=[
            ("en train de lire", "maintenant"),
            ("va parler", "tout à l'heure"),
            ("vient d'éteindre", "à l'instant"),
            ("allons essayer", "nous"),
        ],
        fill_item=("Nous ___ essayer les heures calmes.", "allons"),
        words=["Hawa", "vient", "d'éteindre", "la", "lanterne", "."],
        anagram=("lanterne", "Hawa vient de l'éteindre : la lumière de papier."),
        error=(
            "Patrick va de parler à Radio Figuier.",
            "Patrick va parler à Radio Figuier.",
            "Aller + infinitif, sans de.",
        ),
        pic_start=15,
        pic_words=["contre", "celui", "une flèche", "trois choix"],
        short_p="Recopiez le tableau et ajoutez une phrase à vous dans chaque case.",
        audio="Lisez le tableau, sans aller trop vite.",
    ),
    _l(
        "PO",
        "PO — Dire en cours, bientôt, à l'instant",
        "Situer une action : en train de, aller, venir de.",
        "Répétez, puis parlez de votre matinée à la cour.",
        "Modèles de Marc",
        """Je suis en train d'écouter.
Tu vas ranger.
Elle vient de partir.
Nous sommes en train de décider.
Vous allez signer.
Ils viennent d'arriver.
On va se taire.
Je viens de comprendre.""",
        tf_item=(
            "« Je viens de comprendre » place l'action juste avant maintenant.",
            True,
            "Passé récent.",
        ),
        qcm_item=(
            "Quelle forme marque une action en cours ?",
            [
                "tu vas ranger",
                "je suis en train d'écouter",
                "elle vient de partir",
                "vous allez signer",
            ],
            1,
            "Être en train de.",
        ),
        pairs=[
            ("en train de", "en cours"),
            ("aller + inf.", "proche avenir"),
            ("venir de + inf.", "proche passé"),
            ("on va se taire", "projet"),
        ],
        fill_item=("Elle vient ___ partir.", "de"),
        words=["Je", "suis", "en", "train", "d'écouter", "."],
        anagram=("decider", "Nous sommes en train de… : faire un choix (sans accent)."),
        error=(
            "Je suis en train je écoute la cour trop.",
            "Je suis en train d'écouter.",
            "De + infinitif (d' devant voyelle).",
        ),
        pic_start=19,
        pic_words=["un panier", "une horloge", "un futur", "un passé"],
        short_p="Écrivez neuf phrases : trois de chaque structure.",
        audio="Enregistrez les huit modèles, puis trois phrases à vous.",
    ),
    _l(
        "PE",
        "PE — Mon état du matin",
        "Écrire un état d'esprit avec les trois structures.",
        "Imitez la page de Joël.",
        "Page de Joël Mugisha",
        """Joël Mugisha
Je suis en train d'ouvrir le portail.
Léa va arroser le figuier dans un instant.
Hawa vient de poser les tasses.
Nous sommes en train de lire les règles.
Vous allez entendre Radio Figuier.
Ils viennent de quitter le banc.
Joël
Seuil des Sources — Rukiri-Nord""",
        tf_item=(
            "Hawa vient de poser les tasses.",
            True,
            "Troisième ligne du corps.",
        ),
        qcm_item=(
            "Que va faire Léa ?",
            ["Ouvrir le portail", "Arroser le figuier", "Quitter le banc", "Poser les tasses"],
            1,
            "« Léa va arroser le figuier dans un instant. »",
        ),
        pairs=[
            ("je suis en train d'ouvrir", "portail"),
            ("Léa va arroser", "figuier"),
            ("Hawa vient de poser", "tasses"),
            ("ils viennent de quitter", "banc"),
        ],
        fill_item=("Nous sommes en train ___ lire les règles.", "de"),
        words=["Vous", "allez", "entendre", "Radio", "Figuier", "."],
        anagram=("portail", "Joël est en train de l'ouvrir : la porte de la cour."),
        error=(
            "Je viens à poser les tasses à l'instant trop vite.",
            "Je viens de poser les tasses.",
            "Passé récent : venir de + infinitif.",
        ),
        pic_start=23,
        pic_words=["un nuage", "une cour", "un banc", "une affiche"],
        short_p="Imitez : six lignes, deux de chaque structure.",
        audio="Lisez votre page, sans aller trop vite.",
    ),
    _l(
        "EL",
        "EL — En train, aller, venir de",
        "Retenir présent continu, futur proche et passé récent.",
        "Apprenez la fiche.",
        "Fiche des états",
        """être en train de + infinitif : action en cours
je suis / tu es / il est / nous sommes en train de…
aller + infinitif : futur proche (bientôt)
je vais / tu vas / il va / nous allons / vous allez / ils vont
venir de + infinitif : passé récent (à l'instant)
je viens / tu viens / il vient / nous venons de…
Élision : en train d'ouvrir / vient d'arriver
je serai (futur simple) ≠ je vais être (futur proche)
On ne dit pas : je suis en train que je…""",
        tf_item=(
            "« Je serai » et « je vais être » disent exactement la même chose.",
            False,
            "Serai = futur simple. Je vais être = futur proche, plus immédiat.",
        ),
        qcm_item=(
            "« Venir de ranger » situe l'action…",
            ["dans longtemps", "en ce moment exact et long", "juste avant maintenant", "jamais"],
            2,
            "Passé récent.",
        ),
        pairs=[
            ("en train de", "maintenant"),
            ("aller + inf.", "bientôt"),
            ("venir de + inf.", "à l'instant"),
            ("d'", "élision devant voyelle"),
        ],
        fill_item=("Je ___ de comprendre. (venir)", "viens"),
        words=["Nous", "allons", "essayer", "demain", "."],
        anagram=("bientot", "Aller + infinitif : l'action aura lieu… (sans accent)."),
        error=(
            "Nous venons à signer le cahier à l'instant.",
            "Nous venons de signer le cahier.",
            "Venir de + infinitif, pas venir à.",
        ),
        pic_start=27,
        pic_words=["une clé", "un figuier", "une porte", "un portrait"],
        short_p="Conjuguez les trois structures à je / nous / ils.",
        audio="Enregistrez la fiche et neuf formes.",
    ),
]


SEQUENCES = [
    {"title": "Portraits croisés", "lessons": S1},
    {"title": "Ce qu'on m'a dit", "lessons": S2},
    {"title": "D'accord, pas d'accord", "lessons": S3},
    {"title": "Vivre ensemble", "lessons": S4},
    {"title": "Convaincre en douceur", "lessons": S5},
    {"title": "Un état d'esprit", "lessons": S6},
]
