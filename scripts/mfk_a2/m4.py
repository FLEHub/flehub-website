"""A2 Module 4 — Cultures en partage (univers Seuil des Sources)."""

from factory import L

IMG = "mfk-a2-m4"
IMG_DIR = IMG

MODULE = {
    "title": "A2 — Cultures en partage",
    "description": (
        "Grande étape A2-4 : préciser avec des adverbes, raconter un événement, "
        "mener une enquête, faire une appréciation, demander des explications "
        "et formuler des souhaits — pendant la fête des cultures partagées "
        "au Seuil des Sources (Rukiri-Nord), entre lanternes et Radio Figuier."
    ),
}


def _l(comp, title, obj, cons, st, sp, **kw):
    return L(IMG, comp, title, obj, cons, st, sp, **kw)


# ---------------------------------------------------------------------------
# Séquence 1 — Précisions et nuances (place de l'adverbe)
# ---------------------------------------------------------------------------

S1 = [
    _l(
        "CO",
        "CO — Lanternes déjà prêtes",
        "Repérer la place des adverbes : souvent, déjà, encore, bien, beaucoup.",
        "Lisez le dialogue (à écouter avec l'enseignant). Où se place chaque adverbe ?",
        "Banc du figuier, veille de fête",
        """Aline : J'écoute souvent Radio Figuier avant la veillée.
Patrick : Moi, j'ai déjà préparé les lanternes ocre.
Léa : Rose chante encore sous le figuier.
Marc : Le Marché des Lampions s'ouvre bien ce soir.
Hawa : Les enfants aiment beaucoup le cortège.
Joël : Lila Sow explique souvent le chant du figuier.
Karim : Nous avons déjà tendu les tissus à l'Atelier.
Kévin : On danse encore près de la Table des Sources.
Mado : J'ai bien compris l'horaire de la soirée.""",
        tf_item=(
            "Patrick a déjà préparé les lanternes.",
            True,
            "Patrick : « j'ai déjà préparé les lanternes ocre. »",
        ),
        qcm_item=(
            "Où se place « déjà » dans la phrase de Patrick ?",
            [
                "Avant avoir",
                "Entre l'auxiliaire et le participe",
                "Après le participe",
                "Avant le sujet",
            ],
            1,
            "J'ai déjà préparé : adverbe après l'auxiliaire.",
        ),
        pairs=[
            ("écoute souvent", "après le verbe conjugué"),
            ("ai déjà préparé", "après l'auxiliaire"),
            ("chante encore", "action qui continue"),
            ("aiment beaucoup", "intensité après le verbe"),
        ],
        fill_item=("J'ai ___ préparé les lanternes.", "déjà"),
        words=["J'écoute", "souvent", "Radio", "Figuier", "."],
        anagram=("souvent", "Adverbe : plusieurs fois, pas une seule."),
        error=(
            "Je souvent écoute Radio Figuier.",
            "J'écoute souvent Radio Figuier.",
            "L'adverbe se place après le verbe conjugué.",
        ),
        pic_start=0,
        pic_words=["un adverbe", "une phrase", "une fête", "une lanterne"],
        short_p="Notez cinq adverbes et le verbe qu'ils précisent.",
        audio="Enregistrez : J'écoute souvent. J'ai déjà préparé. Rose chante encore. Ils aiment beaucoup.",
    ),
    _l(
        "CE",
        "CE — Programme annoté",
        "Lire un programme où les adverbes précisent les actions.",
        "Lisez le programme épinglé, sans aller trop vite.",
        "Feuille ocre, Salle des Herbes",
        """Veillée des lanternes — Seuil des Sources
On allume souvent les lampions après dix-huit heures.
Lila Sow a déjà relu le conte du tissu partagé.
Le cortège avance encore vers le Marché des Lampions.
Radio Figuier explique bien les danses des trois rives.
Les visiteurs goûtent beaucoup le bol des sources.
Karim a bien tendu la banderole près du figuier.
Rose chante encore deux refrains.
Attention : beaucoup après le verbe. Très devant un adjectif.""",
        tf_item=(
            "Lila a déjà relu le conte.",
            True,
            "« Lila Sow a déjà relu le conte du tissu partagé. »",
        ),
        qcm_item=(
            "Que font les visiteurs avec le bol des sources ?",
            ["Ils le cachent", "Ils le goûtent beaucoup", "Ils le vendent", "Ils le cassent"],
            1,
            "« Les visiteurs goûtent beaucoup le bol des sources. »",
        ),
        pairs=[
            ("allume souvent", "lampions"),
            ("a déjà relu", "conte"),
            ("explique bien", "Radio Figuier"),
            ("goûtent beaucoup", "bol des sources"),
        ],
        fill_item=("Rose chante ___ deux refrains.", "encore"),
        words=["Karim", "a", "bien", "tendu", "la", "banderole", "."],
        anagram=("encore", "L'action n'est pas finie : elle continue."),
        error=(
            "Les visiteurs beaucoup goûtent le bol.",
            "Les visiteurs goûtent beaucoup le bol.",
            "Beaucoup se place après le verbe conjugué.",
        ),
        pic_start=4,
        pic_words=["ce qui", "ce que", "un récit", "un micro"],
        short_p="Recopiez quatre phrases et soulignez l'adverbe.",
        audio="Lisez le programme à voix haute, sans aller trop vite.",
    ),
    _l(
        "PO",
        "PO — Placer l'adverbe",
        "Dire une phrase avec l'adverbe à la bonne place.",
        "Répétez les modèles, puis précisez une action de la fête.",
        "Modèles d'Aline",
        """Je danse souvent.
Tu as déjà allumé.
Elle écoute encore.
Nous chantons bien.
Vous aimez beaucoup.
Ils ont bien compris.
On prépare encore les tissus.
J'ai déjà vu le cortège.""",
        tf_item=(
            "Avec un temps composé, l'adverbe se place souvent après l'auxiliaire.",
            True,
            "J'ai déjà vu. Ils ont bien compris.",
        ),
        qcm_item=(
            "Quelle phrase est correcte ?",
            [
                "Je déjà ai vu",
                "J'ai déjà vu",
                "J'ai vu déjà le cortège trop",
                "Déjà je ai vu",
            ],
            1,
            "Auxiliaire + adverbe + participe.",
        ),
        pairs=[
            ("souvent", "habitude"),
            ("déjà", "avant ce moment"),
            ("encore", "pas fini"),
            ("beaucoup", "intensité"),
        ],
        fill_item=("Vous aimez ___ la danse.", "beaucoup"),
        words=["Ils", "ont", "bien", "compris", "."],
        anagram=("beaucoup", "Adverbe d'intensité : un grand nombre ou très fort."),
        error=(
            "Nous bien chantons sous le figuier.",
            "Nous chantons bien sous le figuier.",
            "Bien se place après le verbe conjugué.",
        ),
        pic_start=8,
        pic_words=["une enquête", "des affiches", "une loupe", "un carnet"],
        short_p="Écrivez six phrases : souvent, déjà, encore, bien, beaucoup, trop.",
        audio="Enregistrez les huit modèles, puis deux phrases à vous.",
    ),
    _l(
        "PE",
        "PE — Mon carnet de veillée",
        "Écrire un carnet qui place correctement les adverbes.",
        "Imitez le carnet de Léa.",
        "Carnet de Léa Niyonzima",
        """Léa Niyonzima
J'écoute souvent le chant du figuier.
J'ai déjà cousu un tissu à l'Atelier.
Rose chante encore près de Radio Figuier.
Le cortège avance bien vers le marché.
Les enfants aiment beaucoup les lanternes.
Nous avons déjà préparé le bol des sources.
Léa
Seuil des Sources — Rukiri-Nord""",
        tf_item=(
            "Léa a déjà cousu un tissu.",
            True,
            "« J'ai déjà cousu un tissu à l'Atelier. »",
        ),
        qcm_item=(
            "Que font les enfants, d'après Léa ?",
            ["Ils dorment", "Ils aiment beaucoup les lanternes", "Ils ferment le marché", "Ils cachent le bol"],
            1,
            "« Les enfants aiment beaucoup les lanternes. »",
        ),
        pairs=[
            ("écoute souvent", "chant"),
            ("ai déjà cousu", "tissu"),
            ("chante encore", "Rose"),
            ("aiment beaucoup", "lanternes"),
        ],
        fill_item=("Le cortège avance ___ vers le marché.", "bien"),
        words=["J'écoute", "souvent", "le", "chant", "."],
        anagram=("lanternes", "On les allume le soir : des lumières en papier."),
        error=(
            "J'ai cousu déjà un tissu pour la veillée.",
            "J'ai déjà cousu un tissu pour la veillée.",
            "Déjà se place après l'auxiliaire.",
        ),
        pic_start=12,
        pic_words=["un podium", "une étoile", "un avis", "une tasse"],
        short_p="Imitez : six lignes avec cinq adverbes différents.",
        audio="Lisez votre carnet, une phrase, une pause, sans aller trop vite.",
    ),
    _l(
        "EL",
        "EL — Place de l'adverbe",
        "Retenir où placer souvent, déjà, encore, bien, beaucoup.",
        "Apprenez la fiche.",
        "Fiche du Cahier du chemin",
        """Après le verbe conjugué : je danse souvent / elle écoute encore.
Après l'auxiliaire, avant le participe : j'ai déjà vu / nous avons bien compris.
beaucoup : après le verbe (ils aiment beaucoup) ou beaucoup de + nom.
très : devant un adjectif (très beau), pas après le verbe seul.
trop : trop vite, trop tard — après le verbe ou devant l'adjectif.
On ne dit pas : je souvent danse.
On ne dit pas : j'ai vu déjà (place faible) — on préfère j'ai déjà vu.
bien ≠ bon : on chante bien / un bon chant.""",
        tf_item=(
            "On dit « je souvent danse ».",
            False,
            "L'adverbe se place après le verbe : je danse souvent.",
        ),
        qcm_item=(
            "Quelle phrase place bien l'adverbe ?",
            [
                "Ils beaucoup aiment",
                "Ils aiment beaucoup",
                "Beaucoup ils aiment le",
                "Ils aiment le beaucoup cortège",
            ],
            1,
            "Verbe + beaucoup.",
        ),
        pairs=[
            ("souvent", "habitude"),
            ("déjà", "fait avant"),
            ("encore", "continuité"),
            ("bien", "manière"),
        ],
        fill_item=("Nous avons ___ compris l'horaire.", "bien"),
        words=["Elle", "écoute", "encore", "Radio", "Figuier", "."],
        anagram=("maniere", "Bien précise la… de l'action (sans accent)."),
        error=(
            "Ce chant est beaucoup beau.",
            "Ce chant est très beau.",
            "Très + adjectif. Beaucoup + verbe.",
        ),
        pic_start=16,
        pic_words=["une inversion", "un pupitre", "un point", "une salle"],
        short_p="Placez cinq adverbes dans cinq phrases au présent et au passé composé.",
        audio="Enregistrez la fiche, puis quatre exemples à vous.",
    ),
]


# ---------------------------------------------------------------------------
# Séquence 2 — Un événement à raconter (ce qui / ce que … c'est)
# ---------------------------------------------------------------------------

S2 = [
    _l(
        "CO",
        "CO — Ce qui a brillé",
        "Comprendre la mise en relief : ce qui / ce que … c'est.",
        "Lisez le dialogue. Qu'est-ce qu'on met en avant ?",
        "Micro de Radio Figuier, soir de fête",
        """Marc : Ce qui m'a plu, c'est le cortège des lampions.
Hawa : Ce que Patrick raconte, c'est la danse des trois rives.
Aline : Ce qui est beau, c'est le tissu partagé.
Léa : Ce que j'ai vu, c'est le figuier tout éclairé.
Joël : Ce qui étonne Kévin, c'est le silence après le chant.
Rose : Ce que Lila lit, c'est le conte du bol des sources.
Karim : Ce qui reste, c'est la lumière ocre.
Mado : Ce que nous gardons, c'est cette soirée.""",
        tf_item=(
            "Marc met en relief le cortège.",
            True,
            "« Ce qui m'a plu, c'est le cortège des lampions. »",
        ),
        qcm_item=(
            "Dans « Ce que j'ai vu », que remplace « ce que » ?",
            ["Le sujet", "Le complément d'objet", "Un lieu", "Un adverbe"],
            1,
            "Ce que + sujet + verbe : l'objet est mis en relief.",
        ),
        pairs=[
            ("ce qui m'a plu", "sujet de plaire"),
            ("ce que Patrick raconte", "objet de raconter"),
            ("ce qui est beau", "le tissu"),
            ("ce que j'ai vu", "le figuier"),
        ],
        fill_item=("___ qui m'a plu, c'est le cortège.", "Ce"),
        words=["Ce", "qui", "est", "beau", "c'est", "le", "tissu", "."],
        anagram=("cortège", "La file de lampions qui avance (avec accent)."),
        error=(
            "Ce que m'a plu, c'est le cortège.",
            "Ce qui m'a plu, c'est le cortège.",
            "Le sujet de plaire → ce qui.",
        ),
        pic_start=20,
        pic_words=["un souhait", "une lettre", "un nuage", "une main"],
        short_p="Notez trois « ce qui » et deux « ce que » entendus.",
        audio="Enregistrez : Ce qui m'a plu c'est le cortège. Ce que j'ai vu c'est le figuier.",
    ),
    _l(
        "CE",
        "CE — Carnet de témoins",
        "Lire des mises en relief dans un carnet de fête.",
        "Lisez le carnet, sans aller trop vite.",
        "Cahier du chemin, page ocre",
        """Témoins — Veillée des lanternes
Hawa : Ce qui éclaire la cour, c'est le figuier.
Patrick : Ce que Rose chante, c'est le refrain des trois rives.
Solange Mukamana : Ce qui manque encore, c'est un banc près du micro.
Karim : Ce que le marché propose, c'est l'échange des carnets.
Lila Sow : Ce qui unit les voix, c'est Radio Figuier.
Joël : Ce que Sami photographie, c'est la danse.
Règle : ce qui = sujet. ce que = objet (qu' devant voyelle).""",
        tf_item=(
            "Solange dit qu'il manque un banc.",
            True,
            "« Ce qui manque encore, c'est un banc près du micro. »",
        ),
        qcm_item=(
            "Que photographie Sami, d'après Joël ?",
            ["Le banc", "La danse", "Le bol", "Le tampon"],
            1,
            "« Ce que Sami photographie, c'est la danse. »",
        ),
        pairs=[
            ("ce qui éclaire", "le figuier"),
            ("ce que Rose chante", "le refrain"),
            ("ce qui unit", "Radio Figuier"),
            ("ce que Sami photographie", "la danse"),
        ],
        fill_item=("Ce ___ Rose chante, c'est le refrain.", "que"),
        words=["Ce", "qui", "éclaire", "la", "cour", "c'est", "le", "figuier", "."],
        anagram=("refrain", "Ce que Rose chante : la partie qui revient."),
        error=(
            "Ce qui Rose chante, c'est le refrain.",
            "Ce que Rose chante, c'est le refrain.",
            "Rose chante quelque chose → ce que (objet).",
        ),
        pic_start=24,
        pic_words=["une danse", "un tissu", "un livre", "une radio"],
        short_p="Recopiez le carnet et encadrez ce qui / ce que.",
        audio="Lisez les six témoignages, sans aller trop vite.",
    ),
    _l(
        "PO",
        "PO — Mettre en relief",
        "Raconter un événement avec ce qui / ce que … c'est.",
        "Répétez, puis racontez un moment de la fête.",
        "Modèles de Marc",
        """Ce qui m'étonne, c'est le silence.
Ce que j'aime, c'est la danse.
Ce qui reste, c'est la lumière.
Ce que tu racontes, c'est vrai.
Ce qui est simple, c'est d'écouter.
Ce que nous gardons, c'est le chant.
Ce qui brille, c'est la lanterne.
Ce que Hawa lit, c'est le conte.""",
        tf_item=(
            "« Ce qui » introduit le sujet de la relative.",
            True,
            "Ce qui brille : qui = sujet de briller.",
        ),
        qcm_item=(
            "On dit « … j'aime, c'est la danse » comment ?",
            ["Ce qui", "Ce que", "Ce dont", "Ce où"],
            1,
            "J'aime quelque chose → ce que.",
        ),
        pairs=[
            ("ce qui", "sujet"),
            ("ce que", "objet"),
            ("c'est", "mise en relief"),
            ("ce qu'", "devant voyelle"),
        ],
        fill_item=("Ce ___ j'aime, c'est la danse.", "que"),
        words=["Ce", "qui", "brille", "c'est", "la", "lanterne", "."],
        anagram=("silence", "Ce qui étonne : plus aucun bruit après le chant."),
        error=(
            "Ce que brille, c'est la lanterne.",
            "Ce qui brille, c'est la lanterne.",
            "La lanterne brille → sujet → ce qui.",
        ),
        pic_start=28,
        pic_words=["un marché", "une cour", "un adverbe", "une phrase"],
        short_p="Écrivez six mises en relief : trois ce qui, trois ce que.",
        audio="Enregistrez les huit modèles, puis deux phrases à vous.",
    ),
    _l(
        "PE",
        "PE — Mon récit de soirée",
        "Écrire un récit court avec ce qui / ce que … c'est.",
        "Imitez le récit de Hawa.",
        "Récit de Hawa Diallo",
        """Hawa Diallo
Ce qui a ouvert la soirée, c'est Radio Figuier.
Ce que Patrick a tendu, c'est la banderole ocre.
Ce qui m'a touchée, c'est le chant du figuier.
Ce que les enfants ont suivi, c'est le cortège.
Ce qui reste ce matin, c'est une lanterne.
Ce que je raconte, c'est cette veillée.
Hawa
Marché des Lampions — Seuil des Sources""",
        tf_item=(
            "Hawa dit que Radio Figuier a ouvert la soirée.",
            True,
            "« Ce qui a ouvert la soirée, c'est Radio Figuier. »",
        ),
        qcm_item=(
            "Qu'est-ce qui reste ce matin ?",
            ["Un banc", "Une lanterne", "Un tampon", "Un minibus"],
            1,
            "« Ce qui reste ce matin, c'est une lanterne. »",
        ),
        pairs=[
            ("ce qui a ouvert", "Radio Figuier"),
            ("ce que Patrick a tendu", "banderole"),
            ("ce qui m'a touchée", "chant"),
            ("ce que les enfants ont suivi", "cortège"),
        ],
        fill_item=("Ce ___ je raconte, c'est cette veillée.", "que"),
        words=["Ce", "qui", "reste", "c'est", "une", "lanterne", "."],
        anagram=("banderole", "Ce que Patrick a tendu : une longue bande de tissu."),
        error=(
            "Ce qui Patrick a tendu, c'est la banderole.",
            "Ce que Patrick a tendu, c'est la banderole.",
            "Patrick a tendu quelque chose → ce que.",
        ),
        pic_start=2,
        pic_words=["une fête", "une lanterne", "ce qui", "ce que"],
        short_p="Imitez : six lignes avec ce qui et ce que.",
        audio="Lisez votre récit, sans aller trop vite.",
    ),
    _l(
        "EL",
        "EL — Ce qui, ce que, c'est",
        "Retenir la mise en relief avec ce qui et ce que.",
        "Apprenez la fiche.",
        "Fiche de Lila Sow",
        """Ce qui + verbe : le sujet est mis en avant.
Ce qui m'étonne, c'est le silence.
Ce que + sujet + verbe : l'objet est mis en avant.
Ce que je vois, c'est la danse.
Élision : ce qu'elle raconte / ce qu'on garde.
On referme souvent avec c'est + nom (ou infinitif).
On ne dit pas : ce que m'étonne.
On ne dit pas : ce qui je vois.
Attention : ce qui / ce que (pas se qui).""",
        tf_item=(
            "On écrit « ce que m'étonne ».",
            False,
            "Étonner a un sujet : ce qui m'étonne.",
        ),
        qcm_item=(
            "« Ce que + elle » s'écrit…",
            ["ce que elle", "ce qu'elle", "ce qui elle", "ce quelle"],
            1,
            "Élision : ce qu'elle.",
        ),
        pairs=[
            ("ce qui", "sujet"),
            ("ce que", "objet"),
            ("ce qu'", "élision"),
            ("c'est", "fermeture"),
        ],
        fill_item=("Ce ___ elle raconte est vrai.", "qu'"),
        words=["Ce", "que", "je", "vois", "c'est", "la", "danse", "."],
        anagram=("objet", "Ce que reprend le… du verbe voir ou aimer."),
        error=(
            "Ce qui je vois, c'est la danse.",
            "Ce que je vois, c'est la danse.",
            "Je vois quelque chose → ce que.",
        ),
        pic_start=6,
        pic_words=["un récit", "un micro", "une enquête", "des affiches"],
        short_p="Transformez six phrases simples en ce qui / ce que … c'est.",
        audio="Enregistrez la fiche et six mises en relief.",
    ),
]


# ---------------------------------------------------------------------------
# Séquence 3 — Une enquête à mener (lequel / laquelle / lesquels / lesquelles)
# ---------------------------------------------------------------------------

S3 = [
    _l(
        "CO",
        "CO — Quel stand reste ouvert",
        "Comprendre lequel, laquelle, lesquels, lesquelles dans une enquête.",
        "Lisez le dialogue. On choisit parmi quoi ?",
        "Marché des Lampions, quatre affiches",
        """Léa : Lequel de ces stands reste ouvert après vingt heures ?
Sami : Laquelle de ces danses commence près du figuier ?
Benoît : Lesquels de ces tissus viennent de l'Atelier ?
Yvette Mukeshimana : Lesquelles de ces lanternes sont déjà allumées ?
Noura Sarr : Lequel de ces micros appartient à Radio Figuier ?
Ibrahim Tchami : Laquelle de ces voix explique le conte ?
Aline : Parmi ces carnets, lesquels sont complets ?
Patrick : Parmi ces tasses, lesquelles sont pour le bol des sources ?""",
        tf_item=(
            "Léa demande quel stand reste ouvert.",
            True,
            "« Lequel de ces stands reste ouvert… »",
        ),
        qcm_item=(
            "Yvette parle de lanternes. Quel pronom utilise-t-elle ?",
            ["Lequel", "Laquelle", "Lesquels", "Lesquelles"],
            3,
            "Lanternes = féminin pluriel → lesquelles.",
        ),
        pairs=[
            ("lequel", "stand / micro — masc. sing."),
            ("laquelle", "danse / voix — fém. sing."),
            ("lesquels", "tissus / carnets — masc. pl."),
            ("lesquelles", "lanternes / tasses — fém. pl."),
        ],
        fill_item=("___ de ces stands reste ouvert ?", "Lequel"),
        words=["Laquelle", "de", "ces", "danses", "commence", "?"],
        anagram=("stand", "Un petit lieu du marché : on y vend ou on y montre."),
        error=(
            "Laquelle de ces stands reste ouvert ?",
            "Lequel de ces stands reste ouvert ?",
            "Stand est masculin : lequel.",
        ),
        pic_start=10,
        pic_words=["une loupe", "un carnet", "un podium", "une étoile"],
        short_p="Notez les quatre formes et le nom qu'elles reprennent.",
        audio="Enregistrez : Lequel de ces stands ? Laquelle de ces danses ? Lesquelles de ces lanternes ?",
    ),
    _l(
        "CE",
        "CE — Fiche d'enquête",
        "Lire une fiche d'enquête avec lequel / laquelle / lesquels / lesquelles.",
        "Lisez la fiche, sans aller trop vite.",
        "Carnet d'enquête, Bureau des Escales",
        """Enquête — fête des cultures partagées
1. Lequel de ces horaires est le bon pour Radio Figuier ?
2. Laquelle de ces salles accueille le conte : Salle des Herbes ou Maison des Vents ?
3. Lesquels de ces guides connaissent le Marché des Lampions : Karim ou Ibrahim ?
4. Lesquelles de ces règles restent affichées près du figuier ?
5. Parmi ces lanternes, lesquelles doivent encore brûler ?
6. Lequel de ces prénoms manque sur la liste : Félicie ou Dieudonné ?
Accord : on reprend le genre et le nombre du nom.""",
        tf_item=(
            "La fiche demande laquelle des salles accueille le conte.",
            True,
            "Point 2 : Salle des Herbes ou Maison des Vents.",
        ),
        qcm_item=(
            "Pour « règles », quelle forme est correcte ?",
            ["lequel", "laquelle", "lesquels", "lesquelles"],
            3,
            "Règles = féminin pluriel.",
        ),
        pairs=[
            ("lequel / horaires", "masculin singulier"),
            ("laquelle / salles", "féminin singulier"),
            ("lesquels / guides", "masculin pluriel"),
            ("lesquelles / règles", "féminin pluriel"),
        ],
        fill_item=("___ de ces salles accueille le conte ?", "Laquelle"),
        words=["Lesquelles", "de", "ces", "règles", "restent", "?"],
        anagram=("guides", "Karim ou Ibrahim : ceux qui montrent le chemin."),
        error=(
            "Lesquels de ces règles restent affichées ?",
            "Lesquelles de ces règles restent affichées ?",
            "Règle est féminin : lesquelles.",
        ),
        pic_start=14,
        pic_words=["un avis", "une tasse", "une inversion", "un pupitre"],
        short_p="Recopiez la fiche et accordez quatre pronoms à blanc.",
        audio="Lisez les six questions, sans aller trop vite.",
    ),
    _l(
        "PO",
        "PO — Choisir parmi plusieurs",
        "Poser une question avec lequel / laquelle / lesquels / lesquelles.",
        "Répétez, puis enquêtez sur un objet de la cour.",
        "Modèles d'Aline",
        """Lequel choisis-tu ?
Laquelle préfères-tu ?
Lesquels restent ouverts ?
Lesquelles sont allumées ?
Lequel de ces chants ?
Laquelle de ces voix ?
Lesquels de ces bancs ?
Lesquelles de ces tasses ?""",
        tf_item=(
            "« Lesquels » est masculin pluriel.",
            True,
            "Lesquels = ceux-là, parmi un groupe masculin.",
        ),
        qcm_item=(
            "Pour « voix » (féminin), on dit…",
            ["lequel", "laquelle", "lesquels", "lequelles"],
            1,
            "Une voix → laquelle.",
        ),
        pairs=[
            ("lequel", "celui"),
            ("laquelle", "celle"),
            ("lesquels", "ceux"),
            ("lesquelles", "celles"),
        ],
        fill_item=("___ de ces chants écoutes-tu ?", "Lequel"),
        words=["Lesquels", "restent", "ouverts", "?"],
        anagram=("choisis", "Lequel…-tu : tu prends l'un parmi d'autres."),
        error=(
            "Lesquelles de ces bancs restent ?",
            "Lesquels de ces bancs restent ?",
            "Banc est masculin : lesquels.",
        ),
        pic_start=18,
        pic_words=["un point", "une salle", "un souhait", "une lettre"],
        short_p="Écrivez huit questions : deux de chaque forme.",
        audio="Enregistrez les huit modèles, puis deux questions à vous.",
    ),
    _l(
        "PE",
        "PE — Ma feuille d'enquête",
        "Écrire une courte enquête avec les quatre formes.",
        "Imitez la feuille de Yvette.",
        "Feuille de Yvette Mukeshimana",
        """Yvette Mukeshimana
Lequel de ces micros marche encore ?
Laquelle de ces danses commence à vingt heures ?
Lesquels de ces tissus sont pour l'échange ?
Lesquelles de ces lanternes restent près du figuier ?
Parmi ces voix, laquelle explique le conte ?
Parmi ces stands, lesquels ferment les derniers ?
Yvette
Marché des Lampions""",
        tf_item=(
            "Yvette demande lesquels des tissus sont pour l'échange.",
            True,
            "Troisième question de la feuille.",
        ),
        qcm_item=(
            "Quelle question porte sur les lanternes ?",
            [
                "Lequel de ces micros",
                "Lesquelles de ces lanternes restent",
                "Lesquels de ces tissus",
                "Laquelle explique le conte",
            ],
            1,
            "« Lesquelles de ces lanternes restent près du figuier ? »",
        ),
        pairs=[
            ("lequel", "micros"),
            ("laquelle", "danses / voix"),
            ("lesquels", "tissus / stands"),
            ("lesquelles", "lanternes"),
        ],
        fill_item=("Parmi ces voix, ___ explique le conte ?", "laquelle"),
        words=["Lequel", "de", "ces", "micros", "marche", "?"],
        anagram=("lanternes", "Elles restent près du figuier : des lumières de papier."),
        error=(
            "Parmi ces voix, lequel explique le conte ?",
            "Parmi ces voix, laquelle explique le conte ?",
            "Voix est féminin : laquelle.",
        ),
        pic_start=22,
        pic_words=["un nuage", "une main", "une danse", "un tissu"],
        short_p="Imitez : six questions d'enquête avec les quatre formes.",
        audio="Lisez votre feuille, sans aller trop vite.",
    ),
    _l(
        "EL",
        "EL — Lequel et ses accords",
        "Retenir l'accord de lequel, laquelle, lesquels, lesquelles.",
        "Apprenez la fiche.",
        "Fiche d'enquête",
        """lequel → un nom masculin singulier (le stand, le micro)
laquelle → un nom féminin singulier (la danse, la voix)
lesquels → un nom masculin pluriel (les tissus, les bancs)
lesquelles → un nom féminin pluriel (les lanternes, les tasses)
Souvent : lequel de ces + nom pluriel.
On ne dit pas : lequel danse (sans nom ou idée de choix).
Après une préposition : de lequel / à laquelle (niveau plus tard).
Ici : forme simple + de ces.""",
        tf_item=(
            "« Lesquelles » reprend un nom féminin pluriel.",
            True,
            "Les lanternes → lesquelles.",
        ),
        qcm_item=(
            "« Tissu » au pluriel se reprend par…",
            ["laquelle", "lesquels", "lesquelles", "lequel"],
            1,
            "Tissus = masculin pluriel → lesquels.",
        ),
        pairs=[
            ("lequel", "masculin singulier"),
            ("laquelle", "féminin singulier"),
            ("lesquels", "masculin pluriel"),
            ("lesquelles", "féminin pluriel"),
        ],
        fill_item=("___ de ces tasses sont propres ?", "Lesquelles"),
        words=["Laquelle", "de", "ces", "voix", "parle", "?"],
        anagram=("pluriel", "Lesquels et lesquelles vont avec un nom en…"),
        error=(
            "Lesquelles de ces tissus sont pour l'échange ?",
            "Lesquels de ces tissus sont pour l'échange ?",
            "Tissu est masculin.",
        ),
        pic_start=26,
        pic_words=["un livre", "une radio", "un marché", "une cour"],
        short_p="Accordez lequel dans huit mini-questions.",
        audio="Enregistrez la fiche et huit questions accordées.",
    ),
]


# ---------------------------------------------------------------------------
# Séquence 4 — Faire une appréciation (superlatif)
# ---------------------------------------------------------------------------

S4 = [
    _l(
        "CO",
        "CO — Le plus beau cortège",
        "Comprendre le superlatif : le plus, le moins, le meilleur.",
        "Lisez le dialogue. Qui dit le plus / le moins / le meilleur ?",
        "Table des Sources, fin de veillée",
        """Rose : C'est le plus beau cortège de la saison.
Joël : La danse des trois rives est la plus vivante.
Hawa : Le bol des sources est le moins cher du marché.
Solange : Radio Figuier a le meilleur micro ce soir.
Félicie Ndayishimiye : C'est la moins longue des veillées.
Dieudonné Hakizimana : Les lanternes ocre sont les plus claires.
Lila : Le conte de Lila n'est pas le moins écouté.
Marc : C'est le meilleur moment sous le figuier.""",
        tf_item=(
            "Hawa dit que le bol est le moins cher.",
            True,
            "« le moins cher du marché. »",
        ),
        qcm_item=(
            "Selon Solange, qu'est-ce qui est le meilleur ?",
            ["Le bol", "Le micro de Radio Figuier", "Le banc", "Le tampon"],
            1,
            "« Radio Figuier a le meilleur micro ce soir. »",
        ),
        pairs=[
            ("le plus beau", "cortège"),
            ("la plus vivante", "danse"),
            ("le moins cher", "bol"),
            ("le meilleur", "micro / moment"),
        ],
        fill_item=("C'est ___ plus beau cortège de la saison.", "le"),
        words=["C'est", "le", "meilleur", "moment", "."],
        anagram=("vivante", "La danse la plus… : pleine d'énergie."),
        error=(
            "C'est le plus bon micro ce soir.",
            "C'est le meilleur micro ce soir.",
            "Bon → le meilleur, pas le plus bon.",
        ),
        pic_start=1,
        pic_words=["une phrase", "une fête", "une lanterne", "ce qui"],
        short_p="Notez trois superlatifs de supériorité et un de infériorité.",
        audio="Enregistrez : C'est le plus beau. C'est la moins chère. C'est le meilleur moment.",
    ),
    _l(
        "CE",
        "CE — Avis affichés",
        "Lire des avis au superlatif.",
        "Lisez les avis, sans aller trop vite.",
        "Mur ocre, Atelier du Tissu",
        """Avis de Rose : le chant du figuier est le plus doux de la cour.
Avis de Joël : la lanterne de Mado est la moins haute.
Avis d'Hawa : c'est le meilleur échange de carnets depuis l'an dernier.
Avis de Solange : les stands du fond sont les moins bruyants.
Avis de Félicie : c'est la plus claire des explications.
Avis de Dieudonné : les tissus jaunes sont les plus légers.
Règle : le / la / les + plus / moins + adjectif.
bon → le meilleur / la meilleure. Bien → le mieux.""",
        tf_item=(
            "Joël dit que la lanterne de Mado est la moins haute.",
            True,
            "Avis de Joël.",
        ),
        qcm_item=(
            "Qui parle du meilleur échange de carnets ?",
            ["Rose", "Hawa", "Solange", "Félicie"],
            1,
            "Avis d'Hawa.",
        ),
        pairs=[
            ("le plus doux", "chant"),
            ("la moins haute", "lanterne"),
            ("le meilleur", "échange"),
            ("les plus légers", "tissus"),
        ],
        fill_item=("Les stands du fond sont les ___ bruyants.", "moins"),
        words=["C'est", "la", "plus", "claire", "des", "explications", "."],
        anagram=("doux", "Le chant le plus… : sans dureté, agréable à l'oreille."),
        error=(
            "C'est le plus mieux des chants.",
            "C'est le mieux des chants.",
            "Bien → le mieux, pas le plus mieux.",
        ),
        pic_start=5,
        pic_words=["ce que", "un récit", "un micro", "une enquête"],
        short_p="Recopiez trois avis et changez plus en moins (ou l'inverse).",
        audio="Lisez les six avis, sans aller trop vite.",
    ),
    _l(
        "PO",
        "PO — Dire le plus et le moins",
        "Faire une appréciation au superlatif.",
        "Répétez, puis jugez un moment de la fête.",
        "Modèles de Rose",
        """C'est le plus intéressant.
C'est la moins chère.
C'est le meilleur conte.
C'est la meilleure danse.
Ce sont les plus clairs.
Ce sont les moins longs.
C'est le mieux expliqué.
C'est la plus simple des règles.""",
        tf_item=(
            "« Le meilleur » est le superlatif de bon.",
            True,
            "Bon → meilleur → le meilleur.",
        ),
        qcm_item=(
            "Quelle forme va avec « danse » (féminin) ?",
            ["le plus vivant", "la plus vivante", "les plus vivant", "le meilleure"],
            1,
            "La plus + adjectif au féminin.",
        ),
        pairs=[
            ("le plus", "supériorité masc."),
            ("la moins", "infériorité fém."),
            ("le meilleur", "de bon"),
            ("le mieux", "de bien"),
        ],
        fill_item=("C'est ___ moins chère.", "la"),
        words=["C'est", "le", "plus", "intéressant", "."],
        anagram=("meilleur", "Superlatif de bon : pas « le plus bon »."),
        error=(
            "C'est le plus intéressante des contes.",
            "C'est le plus intéressant des contes.",
            "Conte est masculin : intéressant.",
        ),
        pic_start=9,
        pic_words=["des affiches", "une loupe", "un carnet", "un podium"],
        short_p="Écrivez huit superlatifs : plus, moins, meilleur, mieux.",
        audio="Enregistrez les huit modèles, puis trois avis à vous.",
    ),
    _l(
        "PE",
        "PE — Mon avis de fête",
        "Écrire un avis avec des superlatifs.",
        "Imitez l'avis de Joël.",
        "Avis de Joël Mugisha",
        """Joël Mugisha
Le cortège est le plus beau de la saison.
La veillée est la moins chère du Seuil.
Radio Figuier a le meilleur micro.
La danse de Rose est la plus vivante.
Les lanternes ocre sont les moins lourdes.
C'est le meilleur soir sous le figuier.
Joël
Marché des Lampions""",
        tf_item=(
            "Joël trouve la veillée la moins chère.",
            True,
            "« La veillée est la moins chère du Seuil. »",
        ),
        qcm_item=(
            "Quelle danse Joël juge-t-il la plus vivante ?",
            ["Celle de Marc", "Celle de Rose", "Celle de Sami", "Celle de Karim"],
            1,
            "« La danse de Rose est la plus vivante. »",
        ),
        pairs=[
            ("le plus beau", "cortège"),
            ("la moins chère", "veillée"),
            ("le meilleur", "micro / soir"),
            ("la plus vivante", "danse"),
        ],
        fill_item=("Radio Figuier a ___ meilleur micro.", "le"),
        words=["C'est", "le", "meilleur", "soir", "."],
        anagram=("lourd", "Les lanternes sont les moins… : elles pèsent peu. (masc.)"),
        error=(
            "La veillée est le moins chère du Seuil.",
            "La veillée est la moins chère du Seuil.",
            "Veillée est féminin : la moins.",
        ),
        pic_start=13,
        pic_words=["une étoile", "un avis", "une tasse", "une inversion"],
        short_p="Imitez : six lignes avec le plus, le moins et le meilleur.",
        audio="Lisez votre avis, sans aller trop vite.",
    ),
    _l(
        "EL",
        "EL — Superlatif",
        "Retenir le plus, le moins, le meilleur, le mieux.",
        "Apprenez la fiche.",
        "Fiche d'appréciation",
        """le / la / les + plus + adjectif : le plus intéressant
le / la / les + moins + adjectif : la moins chère
Accord de l'adjectif : le plus beau / la plus belle / les plus clairs
bon → le meilleur / la meilleure / les meilleurs / les meilleures
bien → le mieux (invariable en genre)
De + groupe : le plus doux de la cour / du marché
On ne dit pas : le plus bon. On ne dit pas : le plus mieux.
Après c'est : C'est le plus simple.""",
        tf_item=(
            "On dit « le plus bon » pour un micro.",
            False,
            "On dit le meilleur.",
        ),
        qcm_item=(
            "Le superlatif de « bien » est…",
            ["le plus bien", "le mieux", "le meilleur bien", "la plus bien"],
            1,
            "Bien → le mieux.",
        ),
        pairs=[
            ("le plus", "supériorité"),
            ("le moins", "infériorité"),
            ("le meilleur", "de bon"),
            ("le mieux", "de bien"),
        ],
        fill_item=("C'est ___ meilleure danse.", "la"),
        words=["C'est", "la", "moins", "chère", "."],
        anagram=("accord", "L'adjectif change : le plus beau / la plus belle. C'est l'…"),
        error=(
            "C'est les plus beau cortège.",
            "C'est le plus beau cortège.",
            "Cortège singulier : le plus beau.",
        ),
        pic_start=17,
        pic_words=["un pupitre", "un point", "une salle", "un souhait"],
        short_p="Conjuguez cinq adjectifs au superlatif (plus / moins / meilleur).",
        audio="Enregistrez la fiche et cinq exemples.",
    ),
]


# ---------------------------------------------------------------------------
# Séquence 5 — Demander des explications (interrogation inversée)
# ---------------------------------------------------------------------------

S5 = [
    _l(
        "CO",
        "CO — Pouvez-vous expliquer",
        "Comprendre des questions formelles à l'inversion.",
        "Lisez le dialogue. Quelles questions sont inversées ?",
        "Pupitre de la Salle des Herbes",
        """Aline : Avez-vous entendu le chant du figuier ?
Patrick : Pouvez-vous expliquer la danse des trois rives ?
Karim : Quel est le thème de Radio Figuier ce soir ?
Solange : Savez-vous où se tient l'échange des carnets ?
Noura : Faut-il allumer toutes les lanternes ?
Lila : Qu'est-ce qui a changé depuis hier ?
Marc : Est-ce que le marché ferme à vingt-deux heures ?
Hawa : Où se trouve le micro, s'il vous plaît ?""",
        tf_item=(
            "Aline pose une question inversée : Avez-vous…",
            True,
            "Inversion sujet-verbe : avez-vous.",
        ),
        qcm_item=(
            "Quelle question n'est pas une inversion ?",
            [
                "Avez-vous entendu",
                "Pouvez-vous expliquer",
                "Est-ce que le marché ferme",
                "Quel est le thème",
            ],
            2,
            "Est-ce que + ordre normal. Quel est = inversion de est-il.",
        ),
        pairs=[
            ("avez-vous", "inversion de avoir"),
            ("pouvez-vous", "demande polie"),
            ("quel est", "identification"),
            ("est-ce que", "forme non inversée"),
        ],
        fill_item=("___-vous expliquer la danse ?", "Pouvez"),
        words=["Avez-vous", "entendu", "le", "chant", "?"],
        anagram=("expliquer", "Pouvez-vous… : rendre clair pour l'autre."),
        error=(
            "Pouvez vous expliquer la danse ?",
            "Pouvez-vous expliquer la danse ?",
            "Inversion : trait d'union entre verbe et sujet.",
        ),
        pic_start=21,
        pic_words=["une lettre", "un nuage", "une main", "une danse"],
        short_p="Classez les questions : inversion / est-ce que / qu'est-ce qui.",
        audio="Enregistrez : Avez-vous entendu ? Pouvez-vous expliquer ? Quel est le thème ?",
    ),
    _l(
        "CE",
        "CE — Questions du soir",
        "Lire des questions formelles et leurs variantes.",
        "Lisez la feuille, sans aller trop vite.",
        "Feuille de Solange Mukamana",
        """Questions pour les guides — Veillée
1. Avez-vous préparé le micro de Radio Figuier ?
2. Pouvez-vous indiquer la Salle des Herbes ?
3. Quel est l'horaire du cortège ?
4. Savez-vous pourquoi le figuier reste ouvert ?
5. Faut-il signer le Cahier du chemin ?
6. Qu'est-ce qui manque encore sur la table ?
Variante simple : Est-ce que vous avez préparé le micro ?
Inversion = plus formelle. Qu'est-ce qui = sujet inconnu.""",
        tf_item=(
            "La feuille oppose inversion et « est-ce que ».",
            True,
            "Variante du point 1.",
        ),
        qcm_item=(
            "Quelle forme sert à un sujet inconnu ?",
            ["Avez-vous", "Pouvez-vous", "Qu'est-ce qui", "Quel est"],
            2,
            "Qu'est-ce qui a changé / manque.",
        ),
        pairs=[
            ("avez-vous préparé", "inversion"),
            ("est-ce que vous avez", "forme longue"),
            ("quel est", "lequel parmi"),
            ("qu'est-ce qui", "sujet"),
        ],
        fill_item=("___ est l'horaire du cortège ?", "Quel"),
        words=["Pouvez-vous", "indiquer", "la", "salle", "?"],
        anagram=("horaire", "Quel est l'… : l'heure du cortège."),
        error=(
            "Avez vous préparé le micro ?",
            "Avez-vous préparé le micro ?",
            "Trait d'union obligatoire à l'inversion.",
        ),
        pic_start=25,
        pic_words=["un tissu", "un livre", "une radio", "un marché"],
        short_p="Transformez trois « est-ce que » en inversions.",
        audio="Lisez les six questions, sans aller trop vite.",
    ),
    _l(
        "PO",
        "PO — Inverser pour demander",
        "Poser une question formelle à l'inversion.",
        "Répétez, puis demandez une explication sur la fête.",
        "Modèles de Karim",
        """Avez-vous le temps ?
Pouvez-vous répéter ?
Quel est votre rôle ?
Savez-vous l'heure ?
Faut-il rester ?
Où va le cortège ?
Que dit Radio Figuier ?
Pourquoi le silence ?""",
        tf_item=(
            "« Faut-il » est l'inversion de « il faut ».",
            True,
            "Il faut → faut-il.",
        ),
        qcm_item=(
            "Quelle inversion est correcte ?",
            [
                "Vous avez le temps",
                "Avez-vous le temps",
                "Avez vous le temps",
                "Le temps avez-vous trop",
            ],
            1,
            "Verbe-sujet avec trait d'union.",
        ),
        pairs=[
            ("avez-vous", "avoir"),
            ("pouvez-vous", "pouvoir"),
            ("faut-il", "il faut"),
            ("quel est", "être"),
        ],
        fill_item=("___-il rester près du figuier ?", "Faut"),
        words=["Quel", "est", "votre", "rôle", "?"],
        anagram=("repete", "Pouvez-vous… : dire une deuxième fois (sans accent)."),
        error=(
            "Il faut-il rester près du figuier ?",
            "Faut-il rester près du figuier ?",
            "On n'empile pas il et l'inversion.",
        ),
        pic_start=29,
        pic_words=["une cour", "un adverbe", "une phrase", "une fête"],
        short_p="Écrivez six questions inversées (avoir, pouvoir, être, falloir).",
        audio="Enregistrez les huit modèles, puis trois questions à vous.",
    ),
    _l(
        "PE",
        "PE — Mes questions aux guides",
        "Écrire des questions formelles pour une explication.",
        "Imitez la liste de Noura.",
        "Liste de Noura Sarr",
        """Noura Sarr
Avez-vous ouvert l'Atelier du Tissu ?
Pouvez-vous expliquer le chant du figuier ?
Quel est le sens du bol des sources ?
Savez-vous où se range le micro ?
Faut-il éteindre les lanternes à minuit ?
Qu'est-ce qui reste à préparer ?
Noura
Salle des Herbes""",
        tf_item=(
            "Noura demande s'il faut éteindre les lanternes à minuit.",
            True,
            "« Faut-il éteindre les lanternes à minuit ? »",
        ),
        qcm_item=(
            "Quelle question utilise « quel est » ?",
            [
                "Avez-vous ouvert l'Atelier",
                "Quel est le sens du bol des sources",
                "Faut-il éteindre",
                "Qu'est-ce qui reste",
            ],
            1,
            "Identification : quel est le sens.",
        ),
        pairs=[
            ("avez-vous", "ouvrir"),
            ("pouvez-vous", "expliquer"),
            ("quel est", "le sens"),
            ("faut-il", "éteindre"),
        ],
        fill_item=("___-vous expliquer le chant ?", "Pouvez"),
        words=["Faut-il", "éteindre", "les", "lanternes", "?"],
        anagram=("minuit", "L'heure où les lanternes s'éteignent : douze heures."),
        error=(
            "Pouvez expliquer-vous le chant du figuier ?",
            "Pouvez-vous expliquer le chant du figuier ?",
            "Le sujet inversé se colle au premier verbe.",
        ),
        pic_start=3,
        pic_words=["une lanterne", "ce qui", "ce que", "un récit"],
        short_p="Imitez : six questions formelles dont deux inversions et un qu'est-ce qui.",
        audio="Lisez votre liste, sans aller trop vite.",
    ),
    _l(
        "EL",
        "EL — Inversion et autres questions",
        "Retenir l'interrogation inversée et ses voisines.",
        "Apprenez la fiche.",
        "Fiche du pupitre",
        """Inversion : verbe + trait d'union + sujet.
Avez-vous… ? Pouvez-vous… ? Savez-vous… ? Faut-il… ?
Quel est… ? Quelle est… ? Où va… ? Que dit… ?
Est-ce que + phrase normale : plus simple, moins formel.
Qu'est-ce qui + verbe : le sujet est inconnu.
Qu'est-ce que + sujet + verbe : l'objet est inconnu.
Trait d'union obligatoire. Pas : Avez vous.
Devant voyelle, t euphonique parfois : Y a-t-il… ?""",
        tf_item=(
            "« Est-ce que » est plus formel que l'inversion.",
            False,
            "L'inversion est plus formelle.",
        ),
        qcm_item=(
            "« Il faut » à la forme inversée donne…",
            ["Il faut-il", "Faut-il", "Faut il", "Est-ce faut"],
            1,
            "Faut-il.",
        ),
        pairs=[
            ("inversion", "forme polie / formelle"),
            ("est-ce que", "forme simple"),
            ("qu'est-ce qui", "sujet inconnu"),
            ("qu'est-ce que", "objet inconnu"),
        ],
        fill_item=("___-ce qui a changé ?", "Qu'est"),
        words=["Savez-vous", "où", "se", "tient", "l'échange", "?"],
        anagram=("formel", "L'inversion convient à un ton… : poli, officiel."),
        error=(
            "Qu'est-ce que a changé depuis hier ?",
            "Qu'est-ce qui a changé depuis hier ?",
            "Le sujet de changer → qu'est-ce qui.",
        ),
        pic_start=7,
        pic_words=["un micro", "une enquête", "des affiches", "une loupe"],
        short_p="Passez six questions de est-ce que à l'inversion.",
        audio="Enregistrez la fiche et six questions inversées.",
    ),
]


# ---------------------------------------------------------------------------
# Séquence 6 — Souhaits et conseils (conditionnel présent)
# ---------------------------------------------------------------------------

S6 = [
    _l(
        "CO",
        "CO — On pourrait allumer",
        "Comprendre des souhaits et conseils au conditionnel présent.",
        "Lisez le dialogue. Qui souhaite ? Qui conseille ?",
        "Fin de veillée, cour du figuier",
        """Léa : Je voudrais encore une lanterne.
Marc : Tu devrais te reposer un peu.
Hawa : On pourrait ranger les tissus demain.
Joël : Nous pourrions aider Rose à plier les banderoles.
Rose : Je partirais plus tôt si le cortège se termine.
Kévin : Elle aimerait relire le conte à Radio Figuier.
Aline : Vous devriez remercier Lila Sow.
Patrick : Ils pourraient laisser une lumière pour la nuit.""",
        tf_item=(
            "Marc conseille à Léa de se reposer.",
            True,
            "« Tu devrais te reposer un peu. »",
        ),
        qcm_item=(
            "Quelle phrase est un souhait de Léa ?",
            [
                "Tu devrais te reposer",
                "Je voudrais encore une lanterne",
                "Vous devriez remercier",
                "Ils pourraient laisser",
            ],
            1,
            "Je voudrais = souhait.",
        ),
        pairs=[
            ("je voudrais", "souhait"),
            ("tu devrais", "conseil"),
            ("on pourrait", "proposition"),
            ("je partirais", "condition / projection"),
        ],
        fill_item=("On ___ ranger les tissus demain.", "pourrait"),
        words=["Je", "voudrais", "encore", "une", "lanterne", "."],
        anagram=("reposer", "Tu devrais te… : arrêter un moment, souffler."),
        error=(
            "Je voudrais d'une lanterne encore s'il te plaît beaucoup.",
            "Je voudrais encore une lanterne.",
            "Vouloir au conditionnel + nom, sans de ici.",
        ),
        pic_start=11,
        pic_words=["un carnet", "un podium", "une étoile", "un avis"],
        short_p="Classez : deux souhaits, deux conseils, deux propositions.",
        audio="Enregistrez : Je voudrais. Tu devrais. On pourrait. Nous pourrions. Je partirais.",
    ),
    _l(
        "CE",
        "CE — Lettres de conseil",
        "Lire des souhaits et conseils au conditionnel.",
        "Lisez les lettres, sans aller trop vite.",
        "Lettres accrochées au figuier",
        """Lettre de Léa : Je voudrais garder une lanterne pour Mwezi-Haut.
Lettre de Marc : Tu devrais écrire à Radio Figuier demain.
Lettre d'Hawa : On pourrait ouvrir l'Atelier plus tôt.
Lettre de Joël : Nous pourrions inviter Ibrahim Tchami au prochain chant.
Lettre de Rose : Je serais prête à raconter encore.
Lettre de Kévin : Vous devriez laisser le marché propre.
Forme : radical du futur + ais / ais / ait / ions / iez / aient.
je serai (futur) ≠ je serais (conditionnel).""",
        tf_item=(
            "Rose écrit « je serais prête » au conditionnel.",
            True,
            "Serais = conditionnel. Serai = futur.",
        ),
        qcm_item=(
            "Quelle forme est le futur, pas le conditionnel ?",
            ["je voudrais", "tu devrais", "je serai", "on pourrait"],
            2,
            "Je serai = futur. Je serais = conditionnel.",
        ),
        pairs=[
            ("je voudrais", "Léa"),
            ("tu devrais", "Marc"),
            ("on pourrait", "Hawa"),
            ("je serais", "Rose"),
        ],
        fill_item=("Nous ___ inviter Ibrahim. (pouvoir)", "pourrions"),
        words=["Tu", "devrais", "écrire", "demain", "."],
        anagram=("serais", "Conditionnel de être, 1re personne : pas le futur serai."),
        error=(
            "Je serai prête à raconter encore si on me le demandait hier.",
            "Je serais prête à raconter encore.",
            "Souhait / hypothèse → conditionnel serais.",
        ),
        pic_start=15,
        pic_words=["une tasse", "une inversion", "un pupitre", "un point"],
        short_p="Recopiez et soulignez toutes les formes en -ais / -ions.",
        audio="Lisez les six lettres, sans aller trop vite.",
    ),
    _l(
        "PO",
        "PO — Souhaiter et conseiller",
        "Dire un souhait ou un conseil au conditionnel présent.",
        "Répétez, puis conseillez un voisin de la fête.",
        "Modèles d'Aline",
        """Je voudrais danser.
Tu devrais écouter.
On pourrait aider.
Nous pourrions rester.
Je partirais plus tôt.
Elle aimerait raconter.
Vous devriez remercier.
Ils pourraient allumer.""",
        tf_item=(
            "« Nous pourrions » est le conditionnel de pouvoir.",
            True,
            "Pouvoir → je pourrais / nous pourrions.",
        ),
        qcm_item=(
            "Quelle forme est correcte pour « je / partir » au conditionnel ?",
            ["je partirai", "je partirais", "je partis", "je partirais-tu"],
            1,
            "Infinitif + ais : je partirais.",
        ),
        pairs=[
            ("voudrais", "vouloir"),
            ("devrais", "devoir"),
            ("pourrait", "pouvoir"),
            ("partirais", "partir"),
        ],
        fill_item=("Je ___ plus tôt. (partir)", "partirais"),
        words=["Nous", "pourrions", "rester", "."],
        anagram=("aimerait", "Elle… raconter : conditionnel de aimer."),
        error=(
            "Je partirai plus tôt si le cortège se termine maintenant peut-être.",
            "Je partirais plus tôt.",
            "Conseil / hypothèse → partirais, pas le futur partirai.",
        ),
        pic_start=19,
        pic_words=["une salle", "un souhait", "une lettre", "un nuage"],
        short_p="Écrivez huit conditionnels : deux de chaque verbe (vouloir devoir pouvoir aimer).",
        audio="Enregistrez les huit modèles, puis trois conseils à vous.",
    ),
    _l(
        "PE",
        "PE — Ma lettre de souhaits",
        "Écrire une lettre de souhaits et de conseils.",
        "Imitez la lettre de Rose.",
        "Lettre de Rose Iradukunda",
        """Rose Iradukunda
Je voudrais remercier Radio Figuier.
Tu devrais garder une lanterne pour Lila.
On pourrait replier les tissus demain matin.
Nous pourrions écrire un mot à Solange.
Je partirais après le dernier chant.
Vous devriez laisser la cour nette.
Rose
Seuil des Sources — Rukiri-Nord""",
        tf_item=(
            "Rose voudrait remercier Radio Figuier.",
            True,
            "Première ligne du corps de la lettre.",
        ),
        qcm_item=(
            "À qui pourrait-on écrire un mot ?",
            ["Karim", "Solange", "Sami", "Benoît"],
            1,
            "« Nous pourrions écrire un mot à Solange. »",
        ),
        pairs=[
            ("je voudrais", "remercier"),
            ("tu devrais", "garder"),
            ("on pourrait", "replier"),
            ("je partirais", "après le chant"),
        ],
        fill_item=("Vous ___ laisser la cour nette.", "devriez"),
        words=["On", "pourrait", "replier", "les", "tissus", "."],
        anagram=("remercier", "Je voudrais… : dire merci à Radio Figuier."),
        error=(
            "Nous pourrions d'écrire un mot à Solange.",
            "Nous pourrions écrire un mot à Solange.",
            "Pouvoir + infinitif, sans de.",
        ),
        pic_start=23,
        pic_words=["une main", "une danse", "un tissu", "un livre"],
        short_p="Imitez : six lignes au conditionnel (souhait, conseil, proposition).",
        audio="Lisez votre lettre, sans aller trop vite.",
    ),
    _l(
        "EL",
        "EL — Conditionnel présent",
        "Retenir la formation et les emplois du conditionnel présent.",
        "Apprenez la fiche.",
        "Fiche des souhaits",
        """Formation : radical du futur + ais ais ait ions iez aient
je voudrais / tu devrais / il pourrait / nous pourrions
je partirais / elle aimerait / vous devriez / ils pourraient
Futur : je serai / je partirai / nous pourrons
Conditionnel : je serais / je partirais / nous pourrions
Emplois : souhait (je voudrais), conseil (tu devrais), proposition (on pourrait)
Politesse : je voudrais un thé (plus doux que je veux).
On ne dit pas : je voudrais de danser — je voudrais danser.""",
        tf_item=(
            "« Je serai » est un conditionnel.",
            False,
            "Serai = futur. Serais = conditionnel.",
        ),
        qcm_item=(
            "Quelle série est au conditionnel ?",
            [
                "je serai nous pourrons",
                "je serais nous pourrions",
                "je suis nous pouvons",
                "je serai nous pourrions",
            ],
            1,
            "ais / ions = conditionnel.",
        ),
        pairs=[
            ("je voudrais", "souhait"),
            ("tu devrais", "conseil"),
            ("on pourrait", "proposition"),
            ("je serais", "être au conditionnel"),
        ],
        fill_item=("Nous ___ rester. (pouvoir)", "pourrions"),
        words=["Je", "partirais", "plus", "tôt", "."],
        anagram=("politesse", "Je voudrais est plus doux : c'est de la…"),
        error=(
            "Je voudrais de danser encore une fois ce soir.",
            "Je voudrais danser encore une fois ce soir.",
            "Vouloir + infinitif, sans de.",
        ),
        pic_start=27,
        pic_words=["une radio", "un marché", "une cour", "un adverbe"],
        short_p="Conjuguez vouloir, devoir, pouvoir et partir au conditionnel (je / nous).",
        audio="Enregistrez la fiche et huit formes (je / nous).",
    ),
]


SEQUENCES = [
    {"title": "Précisions et nuances", "lessons": S1},
    {"title": "Un événement à raconter", "lessons": S2},
    {"title": "Une enquête à mener", "lessons": S3},
    {"title": "Faire une appréciation", "lessons": S4},
    {"title": "Demander des explications", "lessons": S5},
    {"title": "Souhaits et conseils", "lessons": S6},
]
