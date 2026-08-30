"""B2 Module 7 — Agir au travail (univers Seuil des Sources)."""

from factory import L

IMG = "mfk-b2-m7"
IMG_DIR = IMG

MODULE = {
    "title": "B2 — Agir au travail",
    "description": (
        "Grande étape B2-7 : rapporter des pratiques, nommer des compétences, "
        "transmettre une consigne, nuancer un métier, croiser un entretien "
        "et signer une charte — Patrick compare l'Atelier du Tissu de "
        "Dieudonné et Radio Figuier (Lila, Léa, Marc, Joël), Aline forme, "
        "au Seuil des Sources (Rukiri-Nord)."
    ),
}


def _l(comp, title, obj, cons, st, sp, **kw):
    return L(IMG, comp, title, obj, cons, st, sp, **kw)


# ---------------------------------------------------------------------------
# Séquence 1 — Pratiques et parcours (discours indirect présent et passé)
# ---------------------------------------------------------------------------

S1 = [
    _l(
        "CO",
        "CO — Ce qu'on a dit du poste",
        "Repérer le discours indirect au présent et au passé (il a dit qu'il partirait, elle a demandé si, on m'a assuré que).",
        "Lisez le dialogue. Qui rapporte quoi, au présent ou au passé ?",
        "Table des Sources, feuilles de parcours",
        """Aline : Patrick, rappelez ce que Dieudonné a dit de l'atelier, et ce que Lila dit encore de l'antenne.
Patrick : Dieudonné a dit qu'il partirait à l'aube, et qu'il tendrait le premier coupon avant le thé.
Léa : Lila dit qu'elle ouvre le relais à sept heures, et elle demande si le casque de Joël est déjà posé.
Marc : On m'a assuré que le banc resterait libre, encore que la cour soit déjà bruyante.
Joël : Dieudonné m'a demandé si je savais mesurer un coupon ; j'ai répondu que j'apprendrais sans trop vite.
Rose : Il a dit qu'il ne coudrait pas un sac trop large, car un fond trop faible fatigue toute l'équipe.
Hawa : Lila dit qu'un relais trop long fatigue l'oreille, et elle a demandé si l'on pouvait couper à trois minutes.
Karim : On m'a assuré que Solange tamponnerait la feuille, pourvu que l'heure tenue soit écrite clairement.
Solange : Aline a dit qu'il faudrait relire le parcours avant de choisir, et non pas signer trop tôt.
Félicie : Patrick a demandé s'il pouvait essayer les deux lieux ; Aline a dit que ce serait plus juste.
Mado : On m'a assuré que le Cahier du chemin garderait ces paroles, afin que personne ne les déforme demain.
Yvette : Dieudonné dit encore qu'il ouvre à qui sait attendre ; Lila dit qu'elle ouvre à qui sait écouter.
Aline : Notez : au présent, il dit qu'il partira ; au passé, il a dit qu'il partirait. Elle a demandé si. On m'a assuré que.""",
        tf_item=(
            "Au passé, le futur de la parole devient un conditionnel : il a dit qu'il partirait.",
            True,
            "Aline clôt sur ce glissement de temps.",
        ),
        qcm_item=(
            "Que Dieudonné a-t-il dit de son départ, d'après Patrick ?",
            [
                "Qu'il resterait sous le figuier toute la journée",
                "Qu'il partirait à l'aube et tendrait le coupon avant le thé",
                "Qu'il fermerait l'atelier sans prévenir",
                "Qu'il vendrait les casques de Joël",
            ],
            1,
            "Patrick : « il partirait à l'aube… tendrait le premier coupon. »",
        ),
        pairs=[
            ("il a dit que", "il partirait"),
            ("elle a demandé si", "le casque est posé"),
            ("on m'a assuré que", "le banc resterait libre"),
            ("Lila dit que", "elle ouvre à sept heures"),
        ],
        fill_item=("Dieudonné a dit qu'il ___ à l'aube. (partir, cond.)", "partirait"),
        words=["On", "m'a", "assuré", "que", "le", "banc", "resterait", "libre", "."],
        anagram=("partirait", "Conditionnel de partir, après un verbe de parole au passé."),
        error=(
            "Il a dit qu'il partira à l'aube, et on m'a assuré que le banc resterait libre.",
            "Il a dit qu'il partirait à l'aube, et on m'a assuré que le banc resterait libre.",
            "Discours indirect au passé : le futur devient conditionnel.",
        ),
        pic_start=0,
        pic_words=["un discours", "un parcours", "un choix", "un curriculum"],
        short_p="Notez quatre paroles au présent et quatre au passé, avec le temps du verbe rapporté.",
        audio="Enregistrez : Il a dit qu'il partirait. Elle a demandé si le casque était prêt. On m'a assuré que le banc resterait libre.",
    ),
    _l(
        "CE",
        "CE — Compte rendu de parcours",
        "Lire un compte rendu qui enchaîne discours indirect présent et passé.",
        "Lisez le compte rendu, sans aller trop vite.",
        "Feuille de Patrick Habimana",
        """Compte rendu — paroles rapportées (Patrick Habimana)
Dieudonné a dit qu'il partirait à l'aube, et qu'un coupon mal mesuré ferait perdre une heure à tout l'atelier.
Lila dit encore qu'elle ouvre le relais à sept heures, et elle demande si Joël a posé le casque sans le jeter.
On m'a assuré que le banc resterait libre ; toutefois Félicie a demandé si la Table des Sources n'était pas déjà prise.
Aline a dit qu'il faudrait relire mon parcours avant de choisir, car un métier n'est pas un caprice.
Joël m'a demandé si je savais tenir trois minutes sans trop parler ; j'ai répondu que j'apprendrais.
Rose a dit qu'elle tendrait le tissu, encore que le fil soit court, pour que le sac tienne.
Karim a assuré que Solange tamponnerait la feuille, pourvu que l'heure soit écrite clairement.
Marc a dit que Radio Figuier n'était pas une scène : c'est une oreille, et l'on y entre en écoutant.
Hawa a demandé si l'on pouvait essayer l'atelier un matin et l'antenne un jeudi, afin de comparer sans idéaliser.
Mado a noté ces paroles au Cahier du chemin, afin que personne ne les déforme demain.
Yvette a dit qu'un choix trop vite signé fatigue plus qu'un essai honnête.
Je retiens : au présent, on dit que / on demande si ; au passé, on a dit que / on a demandé si, et le futur devient conditionnel.
Copie : Aline Uwase — Atelier d'Aline
Seuil des Sources — Rukiri-Nord""",
        tf_item=(
            "Marc dit que Radio Figuier est une scène où l'on parle d'abord.",
            False,
            "Marc : ce n'est pas une scène, c'est une oreille.",
        ),
        qcm_item=(
            "Que faudrait-il faire, selon Aline, avant de choisir ?",
            [
                "Signer trop tôt",
                "Relire le parcours",
                "Fermer l'atelier",
                "Jeter le casque",
            ],
            1,
            "« Aline a dit qu'il faudrait relire mon parcours. »",
        ),
        pairs=[
            ("Dieudonné a dit que", "il partirait à l'aube"),
            ("Lila dit que", "elle ouvre à sept heures"),
            ("Joël a demandé si", "tenir trois minutes"),
            ("on m'a assuré que", "le banc resterait libre"),
        ],
        fill_item=("Joël m'a demandé ___ je savais tenir trois minutes.", "si"),
        words=["Aline", "a", "dit", "qu'il", "faudrait", "relire", "le", "parcours", "."],
        anagram=("assure", "On m'a… que : verbe pour garantir une parole. (sans accent)"),
        error=(
            "Elle a demandé que le casque était prêt, et Lila dit qu'elle ouvre à sept heures.",
            "Elle a demandé si le casque était prêt, et Lila dit qu'elle ouvre à sept heures.",
            "Une question rapportée se construit avec si, pas avec que.",
        ),
        pic_start=1,
        pic_words=["un parcours", "un choix", "un curriculum", "une compétence"],
        short_p="Recopiez le compte rendu et soulignez tous les verbes rapportés ; indiquez présent ou passé.",
        audio="Lisez le compte rendu, sans aller trop vite.",
    ),
    _l(
        "PO",
        "PO — Dire il a dit que, elle a demandé si",
        "Rapporter à l'oral une pratique de travail au présent et au passé.",
        "Répétez les modèles, puis rapportez deux paroles d'atelier et deux d'antenne.",
        "Modèles d'Aline et de Patrick",
        """Il dit qu'il partira à l'aube.
Il a dit qu'il partirait à l'aube.
Elle demande si le casque est posé.
Elle a demandé si le casque était posé.
On m'assure que le banc restera libre.
On m'a assuré que le banc resterait libre.
Dieudonné m'a dit de mesurer avant de couper.
Lila m'a demandé de couper à trois minutes.
Aline a dit qu'il faudrait relire le parcours.
Joël a répondu qu'il apprendrait.
Marc dit que l'antenne n'est pas une scène.
Rose a dit qu'elle tendrait le tissu.
Hawa a demandé si l'on pouvait essayer les deux lieux.
Je rapporte sans crier, et je change le temps quand le verbe introducteur est au passé.""",
        tf_item=(
            "Quand le verbe introducteur est au passé, le futur de la parole devient un conditionnel.",
            True,
            "Il a dit qu'il partirait.",
        ),
        qcm_item=(
            "Quelle phrase est un discours indirect au passé correct ?",
            [
                "Il a dit qu'il partira à l'aube",
                "Il a dit qu'il partirait à l'aube",
                "Il a dit si il partirait à l'aube",
                "Il a dit de il partirait à l'aube",
            ],
            1,
            "Passé + que + conditionnel.",
        ),
        pairs=[
            ("il dit que", "présent / futur"),
            ("il a dit que", "imparfait / conditionnel"),
            ("demander si", "question rapportée"),
            ("dire de", "ordre / conseil rapporté"),
        ],
        fill_item=("Lila m'a demandé ___ couper à trois minutes.", "de"),
        words=["Elle", "a", "demandé", "si", "le", "casque", "était", "posé", "."],
        anagram=("demander", "Verbe pour rapporter une question : elle a… si."),
        error=(
            "Dieudonné m'a dit que mesurer avant de couper, et Lila a demandé si l'heure tenait.",
            "Dieudonné m'a dit de mesurer avant de couper, et Lila a demandé si l'heure tenait.",
            "Un ordre rapporté : dire de + infinitif.",
        ),
        pic_start=2,
        pic_words=["un choix", "un curriculum", "une compétence", "un badge"],
        short_p="Écrivez huit phrases : quatre au présent (dit que / demande si), quatre au passé.",
        audio="Enregistrez les six premiers modèles, puis deux paroles rapportées à vous.",
    ),
    _l(
        "PE",
        "PE — Mon compte rendu de pratiques",
        "Écrire un compte rendu de parcours en discours indirect présent et passé.",
        "Imitez le compte rendu de Léa Niyonzima, sans aller trop vite.",
        "Compte rendu de Léa Niyonzima",
        """Léa Niyonzima — pratiques entendues sous le figuier
Dieudonné a dit qu'il ouvrirait l'Atelier du Tissu dès l'aube, et qu'il faudrait mesurer avant de couper.
Lila dit qu'elle tient le relais à sept heures, et elle demande si Marc a déjà réglé le casque de Joël.
On m'a assuré que Patrick pourrait essayer les deux lieux, encore que le temps soit court.
Aline a dit qu'un parcours se raconte sans se vanter, et elle m'a demandé de noter les heures tenues.
Joël a répondu qu'il apprendrait à couper à trois minutes, car un relais trop long fatigue l'oreille.
Rose a dit qu'elle tendrait le coupon, pourvu que le fil tienne jusqu'au soir.
Karim a assuré que Solange tamponnerait la feuille si l'heure était lisible.
Marc dit que Radio Figuier n'est pas une scène ; c'est une oreille, et l'on y entre en écoutant.
Hawa a demandé si l'on pouvait comparer sans idéaliser : un matin à l'atelier, un jeudi à l'antenne.
Mado a noté ces paroles au Cahier du chemin, afin que le choix de Patrick reste clair.
Je retiens : on dit que, on a dit que, on demande si, on a demandé si, on m'a assuré que.
Léa
Copie : Aline Uwase — Seuil des Sources""",
        tf_item=(
            "Léa écrit que Marc présente Radio Figuier comme une scène.",
            False,
            "« n'est pas une scène ; c'est une oreille. »",
        ),
        qcm_item=(
            "Que Dieudonné a-t-il dit qu'il faudrait faire avant de couper ?",
            [
                "Signer trop tôt",
                "Mesurer",
                "Jeter le fil",
                "Fermer l'antenne",
            ],
            1,
            "« il faudrait mesurer avant de couper. »",
        ),
        pairs=[
            ("Dieudonné a dit que", "il ouvrirait à l'aube"),
            ("Lila dit que", "elle tient le relais"),
            ("on m'a assuré que", "Patrick pourrait essayer"),
            ("Aline a demandé de", "noter les heures"),
        ],
        fill_item=("On m'a assuré que Patrick ___ essayer les deux lieux. (pouvoir, cond.)", "pourrait"),
        words=["Lila", "dit", "qu'elle", "tient", "le", "relais", "."],
        anagram=("parcours", "Ce que Patrick relit avant de choisir un métier, pas un caprice."),
        error=(
            "On m'a assuré si le banc resterait libre, et Dieudonné a dit qu'il ouvrirait à l'aube.",
            "On m'a assuré que le banc resterait libre, et Dieudonné a dit qu'il ouvrirait à l'aube.",
            "Assurer se construit avec que, pas avec si.",
        ),
        pic_start=3,
        pic_words=["un curriculum", "une compétence", "un badge", "un tissu"],
        short_p="Imitez : douze à quinze lignes, trois « a dit que », deux « a demandé si », un « on m'a assuré que ».",
        audio="Lisez votre compte rendu, une phrase, une pause, sans aller trop vite.",
    ),
    _l(
        "EL",
        "EL — Discours indirect présent et passé",
        "Retenir les glissements de temps et les introducteurs que / si / de.",
        "Apprenez la fiche.",
        "Fiche d'Aline, discours rapporté",
        """Présent : il dit qu'il part / qu'il partira ; elle demande si le banc est libre ; on assure que l'heure tiendra.
Passé : il a dit qu'il partait / qu'il partirait ; elle a demandé si le banc était libre ; on m'a assuré que l'heure tiendrait.
Glissements : présent → imparfait ; futur → conditionnel ; passé composé → plus-que-parfait.
Question : demander si + indicatif (pas demander que pour une question fermée).
Ordre / conseil : dire de + infinitif ; demander de + infinitif.
On m'a assuré que + indicatif (pas assurer si).
Il a dit qu'il faudrait + infinitif : nécessité rapportée.
Encore que + subjonctif : encore que la cour soit bruyante.
Bien que + subjonctif : bien que l'heure soit courte.
Attention : il faut (pas je faut). À + le = au : au Seuil, au parcours.
Un métier se raconte ; on ne le crie pas. Le Cahier du chemin garde les paroles.
On rapporte pour clarifier une pratique, non pour enfler une rumeur.""",
        tf_item=(
            "On dit « elle a demandé que le casque était prêt » pour une question fermée.",
            False,
            "Demander si + indicatif.",
        ),
        qcm_item=(
            "« Il a dit qu'il partira » doit devenir, au passé…",
            [
                "il a dit qu'il part",
                "il a dit qu'il partirait",
                "il a dit si il partira",
                "il a dit de il partira",
            ],
            1,
            "Futur → conditionnel.",
        ),
        pairs=[
            ("futur →", "conditionnel"),
            ("présent →", "imparfait"),
            ("demander si", "question"),
            ("dire de", "ordre"),
        ],
        fill_item=("Elle a demandé ___ le casque était posé.", "si"),
        words=["Il", "a", "dit", "qu'il", "partirait", "à", "l'aube", "."],
        anagram=("indirect", "Discours… : on rapporte sans citer les paroles telles quelles."),
        error=(
            "Il a dit qu'il faudra relire le parcours, et Aline a demandé si l'heure tenait.",
            "Il a dit qu'il faudrait relire le parcours, et Aline a demandé si l'heure tenait.",
            "Nécessité rapportée au passé : il faudrait.",
        ),
        pic_start=4,
        pic_words=["une compétence", "un badge", "un tissu", "une antenne"],
        short_p="Transformez six phrases directes en indirect : trois au présent, trois au passé.",
        audio="Enregistrez la fiche et six phrases : dit que, a dit que, demande si, a demandé si, assure que, on m'a assuré que.",
    ),
]


# ---------------------------------------------------------------------------
# Séquence 2 — Identifier des compétences (savoir-faire du Seuil)
# ---------------------------------------------------------------------------

S2 = [
    _l(
        "CO",
        "CO — Savoir-faire sous le figuier",
        "Repérer et nommer des compétences professionnelles inventées du Seuil.",
        "Lisez le dialogue. Qui sait faire quoi, et comment le dit-on ?",
        "Atelier du Tissu / seuil de Radio Figuier",
        """Dieudonné : Un teneur de coupon sait mesurer avant de couper ; il est capable de tendre sans déchirer.
Lila : Un relais du matin maîtrise le silence : il a l'habitude de poser le casque avant de parler.
Patrick : Je sais porter un seau, mais je ne maîtrise pas encore le fil ocre.
Léa : Joël est capable de tenir trois minutes ; il n'a pas encore l'habitude de couper pile.
Marc : Savoir écouter n'est pas connaître le nom de tous les outils : ce sont deux compétences.
Aline : On décrit un savoir-faire avec savoir + infinitif, être capable de, maîtriser, avoir l'habitude de.
Rose : Je sais recoudre un fond trop faible ; je ne me vante pas, je le montre.
Hawa : Solange a l'habitude de tamponner une feuille lisible, pas une page trop vite signée.
Karim : Un apprenti-tissu apprend à plier ; un preneur de son apprend à ne pas jeter le casque.
Félicie : Être capable de dresser la table à l'heure, cela compte autant qu'un long discours.
Mado : Le Cahier du chemin note les gestes tenus, pas les titres d'ailleurs.
Yvette : Patrick pourra dire : je sais, je suis capable de, je commence à maîtriser.
Joël : Je ne maîtrise pas encore l'antenne ; j'ai toutefois l'habitude d'écouter jusqu'au bout.
Aline : Une compétence du Seuil se montre ; elle ne s'emprunte pas à une ville lointaine.""",
        tf_item=(
            "Marc distingue savoir écouter et connaître le nom des outils.",
            True,
            "Marc : ce sont deux compétences.",
        ),
        qcm_item=(
            "Que sait faire un teneur de coupon, selon Dieudonné ?",
            [
                "Crier plus fort que Lila",
                "Mesurer avant de couper et tendre sans déchirer",
                "Tamponner le Bureau des Escales",
                "Vendre un casque",
            ],
            1,
            "Dieudonné : mesurer avant de couper ; tendre sans déchirer.",
        ),
        pairs=[
            ("savoir + infinitif", "mesurer / porter"),
            ("être capable de", "tenir trois minutes"),
            ("maîtriser", "le silence / le fil"),
            ("avoir l'habitude de", "poser le casque"),
        ],
        fill_item=("Un teneur de coupon ___ mesurer avant de couper.", "sait"),
        words=["Joël", "est", "capable", "de", "tenir", "trois", "minutes", "."],
        anagram=("maitriser", "Tenir un geste jusqu'au bout, sans trop d'erreurs. (sans accent)"),
        error=(
            "Je suis capable à tenir trois minutes, et j'ai l'habitude de poser le casque.",
            "Je suis capable de tenir trois minutes, et j'ai l'habitude de poser le casque.",
            "Être capable de, pas capable à.",
        ),
        pic_start=5,
        pic_words=["un badge", "un tissu", "une antenne", "un pronom"],
        short_p="Notez huit compétences entendues, avec le verbe qui les introduit (savoir / capable / maîtriser / habitude).",
        audio="Enregistrez : Je sais mesurer. Je suis capable de tendre. Je maîtrise le silence. J'ai l'habitude de poser le casque.",
    ),
    _l(
        "CE",
        "CE — Fiche des savoir-faire du Seuil",
        "Lire une fiche qui décrit des compétences locales, sans titres d'ailleurs.",
        "Lisez la fiche, sans aller trop vite.",
        "Fiche d'Aline Uwase, savoir-faire",
        """Fiche — compétences du Seuil (Atelier du Tissu / Radio Figuier)
1. Teneur de coupon : savoir mesurer, être capable de tendre sans déchirer, maîtriser le fil ocre.
2. Apprenti-tissu : avoir l'habitude de plier trois sacs avant de parler d'un quatrième.
3. Relais du matin : maîtriser le silence, savoir couper à trois minutes, poser le casque avant la voix.
4. Preneur de son : être capable de régler le casque de Joël sans le jeter, avoir l'habitude d'écouter.
5. Chroniqueur de cour : savoir relater un geste tenu, pas une rumeur ; Aline relit la page.
6. Tamponneur au Bureau des Escales : Solange a l'habitude d'exiger une heure lisible.
7. Dresseuse de table : Félicie est capable de tenir l'heure du thé sans crier.
8. Teneur du Cahier du chemin : Mado sait noter un savoir-faire sans l'enfler.
Patrick : je sais porter un seau ; je commence à maîtriser le coupon ; je n'ai pas encore l'habitude du micro.
Léa : Joël est capable de tenir trois minutes ; il ne maîtrise pas encore la coupe pile.
Marc : connaître le nom d'un outil n'est pas savoir s'en servir.
Aline : une compétence se décrit au Seuil, jamais avec un titre emprunté à une école d'ailleurs.
Dieudonné : montrer un sac fini vaut mieux que dire « je connais tout ».""",
        tf_item=(
            "Patrick dit qu'il maîtrise déjà complètement le micro.",
            False,
            "Il n'a pas encore l'habitude du micro.",
        ),
        qcm_item=(
            "Que exige Solange, d'après la fiche ?",
            [
                "Un titre d'ailleurs",
                "Une heure lisible",
                "Un casque jeté",
                "Un sac trop large",
            ],
            1,
            "« exiger une heure lisible. »",
        ),
        pairs=[
            ("teneur de coupon", "mesurer / tendre"),
            ("relais du matin", "silence / trois minutes"),
            ("preneur de son", "régler le casque"),
            ("Patrick", "seau / coupon / pas encore le micro"),
        ],
        fill_item=("Joël est capable ___ tenir trois minutes.", "de"),
        words=["Je", "sais", "porter", "un", "seau", "."],
        anagram=("competence", "Savoir-faire montré, pas un titre emprunté. (sans accent)"),
        error=(
            "Je connais mesurer un coupon, et j'ai l'habitude de plier trois sacs.",
            "Je sais mesurer un coupon, et j'ai l'habitude de plier trois sacs.",
            "Savoir + infinitif pour un geste ; connaître s'emploie avec un nom.",
        ),
        pic_start=6,
        pic_words=["un tissu", "une antenne", "un pronom", "une figure"],
        short_p="Recopiez six métiers inventés et, pour chacun, un savoir-faire avec le bon verbe.",
        audio="Lisez la fiche des savoir-faire, sans aller trop vite.",
    ),
    _l(
        "PO",
        "PO — Dire je sais, je maîtrise, je suis capable de",
        "Décrire à l'oral ses savoir-faire avec les verbes du Seuil.",
        "Répétez, puis dites trois compétences tenues et une que vous commencez.",
        "Modèles de Dieudonné et de Lila",
        """Je sais mesurer un coupon.
Je suis capable de tendre sans déchirer.
Je maîtrise le fil ocre, pas encore le micro.
J'ai l'habitude de poser le casque avant de parler.
Je commence à maîtriser trois minutes.
Je ne connais pas tous les outils, mais je sais m'en servir.
Un teneur de coupon montre un geste, il ne le crie pas.
Un relais du matin sait se taire.
Je suis capable d'écouter jusqu'au bout.
J'ai l'habitude de relire la page avec Aline.
Patrick : je sais porter un seau.
Léa : Joël est capable de tenir l'heure.
Marc : connaître un nom n'est pas savoir faire.
Aline : décrivez, ne vous vantez pas.""",
        tf_item=(
            "« Connaître le nom d'un outil » n'équivaut pas à « savoir s'en servir ».",
            True,
            "Marc et la fiche le rappellent.",
        ),
        qcm_item=(
            "Quelle phrase décrit correctement un savoir-faire ?",
            [
                "Je suis capable à couper",
                "Je connais mesurer",
                "Je sais mesurer un coupon",
                "J'ai l'habitude à poser le casque",
            ],
            2,
            "Savoir + infinitif.",
        ),
        pairs=[
            ("je sais", "geste + infinitif"),
            ("je suis capable de", "possibilité réelle"),
            ("je maîtrise", "geste tenu"),
            ("j'ai l'habitude de", "geste répété"),
        ],
        fill_item=("J'ai l'habitude ___ poser le casque avant de parler.", "de"),
        words=["Je", "maîtrise", "le", "fil", "ocre", "."],
        anagram=("habitude", "Geste répété : j'ai l'… de poser le casque."),
        error=(
            "J'ai l'habitude à poser le casque, et je commence à maîtriser trois minutes.",
            "J'ai l'habitude de poser le casque, et je commence à maîtriser trois minutes.",
            "Avoir l'habitude de, pas habitude à.",
        ),
        pic_start=7,
        pic_words=["une antenne", "un pronom", "une figure", "une réunion"],
        short_p="Écrivez dix phrases : trois je sais, trois capable de, deux je maîtrise, deux habitude de.",
        audio="Enregistrez les six premiers modèles, puis trois compétences à vous.",
    ),
    _l(
        "PE",
        "PE — Ma fiche de compétences",
        "Écrire une fiche de savoir-faire professionnels du Seuil.",
        "Imitez la fiche de Joël Mugisha, sans aller trop vite.",
        "Fiche de Joël Mugisha",
        """Joël Mugisha — savoir-faire tenus, savoir-faire commencés
Je sais porter un seau jusqu'à la rive, et je suis capable de le poser sans le verser.
Je n'ai pas encore l'habitude du micro : je commence à maîtriser trois minutes, pas davantage.
Dieudonné dit qu'un apprenti-tissu sait plier avant de couper ; je plie, je ne me vante pas.
Lila dit qu'un relais du matin maîtrise le silence ; je suis capable de me taire jusqu'au signal.
Patrick sait mesurer un coupon plus vite que moi ; je sais toutefois recoudre un fond trop faible.
Rose a l'habitude de tendre le fil ocre ; je l'observe, puis je répète le geste.
Aline m'a demandé de nommer quatre compétences sans emprunter un titre d'ailleurs.
Je connais le nom du casque, mais je ne maîtrise pas encore le réglage : Léa m'aide.
Solange a l'habitude d'exiger une heure lisible ; je suis capable d'écrire l'heure sans rature.
Le Cahier du chemin notera ces gestes, afin que mon parcours reste clair.
Joël
Copie : Aline Uwase, Dieudonné Hakizimana, Lila Sow""",
        tf_item=(
            "Joël dit qu'il maîtrise déjà complètement le réglage du casque.",
            False,
            "Il ne maîtrise pas encore le réglage ; Léa l'aide.",
        ),
        qcm_item=(
            "Quelle compétence Joël commence-t-il seulement ?",
            [
                "Porter un seau",
                "Tenir trois minutes au micro",
                "Recoudre un fond",
                "Écrire l'heure",
            ],
            1,
            "« je commence à maîtriser trois minutes, pas davantage. »",
        ),
        pairs=[
            ("je sais", "porter / recoudre"),
            ("je suis capable de", "poser / me taire"),
            ("je commence à maîtriser", "trois minutes"),
            ("j'ai l'habitude de", "pas encore le micro"),
        ],
        fill_item=("Je n'ai pas encore l'habitude ___ micro.", "du"),
        words=["Je", "sais", "plier", "avant", "de", "couper", "."],
        anagram=("savoir", "Verbe suivi de l'infinitif pour un geste qu'on tient."),
        error=(
            "Je suis capable de mesurer un coupon, et je connais tendre le fil sans déchirer.",
            "Je suis capable de mesurer un coupon, et je sais tendre le fil sans déchirer.",
            "Savoir + infinitif, pas connaître + infinitif.",
        ),
        pic_start=8,
        pic_words=["un pronom", "une figure", "une réunion", "un carnet"],
        short_p="Imitez : une fiche de douze lignes, quatre verbes de compétence, deux métiers inventés du Seuil.",
        audio="Lisez votre fiche, sans aller trop vite.",
    ),
    _l(
        "EL",
        "EL — Verbes pour décrire un savoir-faire",
        "Retenir savoir, être capable de, maîtriser, avoir l'habitude de, et l'écart avec connaître.",
        "Apprenez la fiche.",
        "Fiche d'Aline, compétences",
        """savoir + infinitif : je sais mesurer, tu sais écouter, il sait couper (un geste).
connaître + nom : je connais l'outil, je connais Lila (une personne, un objet). On ne dit pas je connais mesurer.
être capable de + infinitif : je suis capable de tenir trois minutes (possibilité réelle).
maîtriser + nom : je maîtrise le fil, le silence, l'heure (un geste tenu, pas commencé).
avoir l'habitude de + infinitif : j'ai l'habitude de poser le casque (répétition).
commencer à + infinitif : je commence à maîtriser (geste encore fragile).
Métiers inventés du Seuil : teneur de coupon, apprenti-tissu, relais du matin, preneur de son, chroniqueur de cour, tamponneur, dresseuse de table, teneur du Cahier.
On ne nomme pas une école d'ailleurs. On montre un geste.
Attention : capable de (pas capable à) ; habitude de (pas habitude à).
À + le = au : au Seuil, au micro. De + le = du : du casque, du fil.
Une compétence se décrit ; elle ne s'emprunte pas.
On montre un geste tenu ; on n'emprunte pas un titre lointain.""",
        tf_item=(
            "On dit « je connais mesurer un coupon ».",
            False,
            "Je sais mesurer. Connaître + nom.",
        ),
        qcm_item=(
            "Quelle construction est correcte ?",
            [
                "Je suis capable à tendre",
                "J'ai l'habitude à écouter",
                "Je sais mesurer un coupon",
                "Je connais couper le fil",
            ],
            2,
            "Savoir + infinitif.",
        ),
        pairs=[
            ("savoir", "infinitif / geste"),
            ("connaître", "nom / personne"),
            ("capable de", "possibilité"),
            ("habitude de", "répétition"),
        ],
        fill_item=("Je ___ le silence à l'antenne, pas encore le fil. (maîtriser, présent)", "maîtrise"),
        words=["Je", "suis", "capable", "de", "tenir", "l'heure", "."],
        anagram=("capable", "Être… de : on peut vraiment faire le geste, aujourd'hui."),
        error=(
            "Je suis capable à écouter jusqu'au bout, et je sais poser le casque.",
            "Je suis capable d'écouter jusqu'au bout, et je sais poser le casque.",
            "Capable de / d' + infinitif.",
        ),
        pic_start=9,
        pic_words=["une figure", "une réunion", "un carnet", "une nuance"],
        short_p="Construisez deux colonnes : savoir / connaître, puis six phrases de compétences du Seuil.",
        audio="Enregistrez la fiche et six phrases, une par verbe de la fiche.",
    ),
]


# ---------------------------------------------------------------------------
# Séquence 3 — Communiquer au travail (double pronom + figures)
# ---------------------------------------------------------------------------

S3 = [
    _l(
        "CO",
        "CO — Je le lui ai transmis",
        "Repérer la double pronominalisation et quelques figures inventées (figuier, tissu, radio).",
        "Lisez le dialogue. Où sont les deux pronoms, et quelles figures entend-on ?",
        "Réunion de cour, carnet professionnel",
        """Aline : Patrick, le coupon, à Dieudonné : tu le lui as transmis ?
Patrick : Je le lui ai transmis à l'aube, et on me l'a confirmé avant le thé.
Léa : Lila m'a dit la durée : elle me l'a répétée, claire comme un coupon bien coupé.
Marc : Le figuier est une antenne : il tient les voix sans les crier. Ce n'est pas rien.
Joël : Dieudonné m'a montré les ciseaux ; il me les a prêtés, et je les lui ai rendus.
Rose : On nous l'a dit sans brusquer : le fil trop tendu casse, comme une phrase trop vite dite.
Hawa : Je te le confirmerai jeudi, encore que l'heure soit courte.
Karim : Solange leur a tamponné la feuille : elle la leur a remise, lisible.
Félicie : Ce n'est pas le plus faible des relais, que de poser le casque avant de parler. Litote d'Aline.
Mado : La métaphore douce tient : l'atelier est une phrase qu'on tend, la radio une oreille qu'on ouvre.
Yvette : Tu me l'as expliqué ; je le leur dirai sans enfler.
Dieudonné : Ne me le jetez pas, ce coupon : tendez-le-moi, simplement.
Lila : On me l'a confirmé : trois minutes, pas davantage.
Aline : Ordre : me / te / nous / vous, puis le / la / les, puis lui / leur. Ensuite l'auxiliaire.""",
        tf_item=(
            "Marc emploie une métaphore : le figuier est une antenne.",
            True,
            "Marc le dit clairement.",
        ),
        qcm_item=(
            "Quel est l'ordre des pronoms rappelé par Aline ?",
            [
                "lui / le / me",
                "me-te-nous-vous, puis le-la-les, puis lui-leur",
                "les / leur / me seulement",
                "l'auxiliaire d'abord, puis rien",
            ],
            1,
            "Aline clôt sur cet ordre.",
        ),
        pairs=[
            ("je le lui ai transmis", "coupon à Dieudonné"),
            ("on me l'a confirmé", "durée / trois minutes"),
            ("métaphore", "le figuier est une antenne"),
            ("comparaison", "clair comme un coupon"),
        ],
        fill_item=("Je ___ lui ai transmis à l'aube. (le coupon)", "le"),
        words=["On", "me", "l'a", "confirmé", "avant", "le", "thé", "."],
        anagram=("transmis", "Passé de transmettre : ce qu'on a fait du coupon à Dieudonné."),
        error=(
            "Je lui le ai transmis à l'aube, et on me l'a confirmé avant le thé.",
            "Je le lui ai transmis à l'aube, et on me l'a confirmé avant le thé.",
            "Le (COD) se place avant lui (COI).",
        ),
        pic_start=10,
        pic_words=["une réunion", "un carnet", "une nuance", "un métier"],
        short_p="Notez quatre doubles pronoms et trois figures (métaphore, comparaison, litote).",
        audio="Enregistrez : Je le lui ai transmis. On me l'a confirmé. Je te les ai rendus. Clair comme un coupon bien coupé.",
    ),
    _l(
        "CE",
        "CE — Consignes et figures du carnet",
        "Lire un carnet de consignes avec doubles pronoms et figures de la cour.",
        "Lisez le carnet, sans aller trop vite.",
        "Carnet professionnel de Marc Nkurunziza",
        """Carnet — transmettre sans brusquer
Patrick a tendu le coupon : il le lui a transmis à Dieudonné, et on me l'a confirmé avant le thé.
Léa a réglé le casque : elle me l'a passé, puis Joël le lui a rendu sans le jeter.
Solange a tamponné la feuille : elle la leur a remise, lisible comme un fil bien tendu.
Aline nous l'a dit : le figuier est une antenne, pas un tambour ; ce n'est pas rien que de s'y taire.
Dieudonné m'a prêté les ciseaux : il me les a confiés, et je les lui ai rendus avant midi.
Lila te le confirmera : trois minutes, encore que le sujet soit vaste.
Rose compare sans enfler : une consigne trop vite dite casse, comme un fil trop tiré.
Hawa emploie la litote d'Aline : ce n'est pas le plus faible des relais, que de poser le casque d'abord.
Mado note au Cahier : l'atelier est une phrase qu'on tend ; la radio est une oreille qu'on ouvre.
Yvette me l'a expliqué ; je le leur dirai jeudi, sans crier.
Ordre retenu : me / te / nous / vous + le / la / les + lui / leur, puis l'auxiliaire.
On ne dit pas je lui le. On ne dit pas on l'a me confirmé.
Une figure douce éclaire ; elle ne remplace pas la consigne.""",
        tf_item=(
            "Le carnet interdit « je lui le » et « on l'a me confirmé ».",
            True,
            "Les deux interdits sont écrits en clair.",
        ),
        qcm_item=(
            "Quelle métaphore Aline a-t-elle dite, d'après le carnet ?",
            [
                "Le figuier est un tambour",
                "Le figuier est une antenne",
                "L'atelier est un minibus",
                "La radio est un palais",
            ],
            1,
            "« le figuier est une antenne, pas un tambour. »",
        ),
        pairs=[
            ("il le lui a transmis", "coupon / Dieudonné"),
            ("elle la leur a remise", "feuille / Solange"),
            ("clair comme un fil", "comparaison"),
            ("ce n'est pas rien", "litote"),
        ],
        fill_item=("Elle ___ leur a remise, lisible. (la feuille)", "la"),
        words=["Je", "les", "lui", "ai", "rendus", "avant", "midi", "."],
        anagram=("metaphore", "Le figuier est une antenne : une… douce. (sans accent)"),
        error=(
            "On l'a me confirmé avant le thé, et Patrick le lui a transmis à l'aube.",
            "On me l'a confirmé avant le thé, et Patrick le lui a transmis à l'aube.",
            "Me se place avant le, tous deux avant l'auxiliaire.",
        ),
        pic_start=11,
        pic_words=["un carnet", "une nuance", "un métier", "une charte"],
        short_p="Recopiez le carnet et encadrez tous les groupes de deux pronoms ; nommez trois figures.",
        audio="Lisez le carnet, sans aller trop vite.",
    ),
    _l(
        "PO",
        "PO — Dire je le lui / on me l'a",
        "Placer deux pronoms et oser une figure douce autour du figuier, du tissu ou de la radio.",
        "Répétez, puis transmettez une consigne avec deux pronoms et une comparaison.",
        "Modèles de Lila et de Dieudonné",
        """Je le lui ai transmis.
On me l'a confirmé.
Je te les ai montrés.
Elle nous l'a expliqué.
Tu le leur as dit.
Je les lui ai rendus.
Tendez-le-moi, simplement.
Ne me le jetez pas.
Le figuier est une antenne.
Clair comme un coupon bien coupé.
Ce n'est pas rien que de se taire.
L'atelier est une phrase qu'on tend.
La radio est une oreille qu'on ouvre.
Aline : deux pronoms, puis l'auxiliaire ; une figure, pas un cri.""",
        tf_item=(
            "À l'impératif affirmatif, les pronoms se placent après le verbe : tendez-le-moi.",
            True,
            "Dieudonné : tendez-le-moi.",
        ),
        qcm_item=(
            "Quelle phrase place correctement les deux pronoms ?",
            [
                "Je lui le ai transmis",
                "Je le lui ai transmis",
                "Je ai le lui transmis",
                "Le je lui ai transmis",
            ],
            1,
            "Je + le + lui + ai transmis.",
        ),
        pairs=[
            ("je le lui", "COD + COI 3e"),
            ("on me l'", "me + le"),
            ("tendez-le-moi", "impératif affirmatif"),
            ("ce n'est pas rien", "litote"),
        ],
        fill_item=("Tu ___ leur as dit sans crier. (le message)", "le"),
        words=["Elle", "nous", "l'a", "expliqué", "calmement", "."],
        anagram=("litote", "Ce n'est pas rien : une figure qui diminue pour mieux dire."),
        error=(
            "Je lui les ai rendus avant midi, et on me l'a confirmé au thé.",
            "Je les lui ai rendus avant midi, et on me l'a confirmé au thé.",
            "Les (COD) avant lui (COI).",
        ),
        pic_start=12,
        pic_words=["une nuance", "un métier", "une charte", "une table"],
        short_p="Écrivez huit phrases à deux pronoms et trois figures (une métaphore, une comparaison, une litote).",
        audio="Enregistrez les six premiers modèles, puis une consigne et une figure à vous.",
    ),
    _l(
        "PE",
        "PE — Ma consigne transmise",
        "Écrire une consigne de travail avec doubles pronoms et figures de la cour.",
        "Imitez la consigne de Rose Iradukunda, sans aller trop vite.",
        "Consigne de Rose Iradukunda",
        """Rose Iradukunda — transmettre le coupon et l'heure
Patrick m'a tendu le coupon : je le lui ai remis à Dieudonné, et on me l'a confirmé avant le thé.
Lila m'avait dit la durée : je te la répète, claire comme un fil bien coupé.
Le figuier est une antenne : il tient nos voix sans les jeter. Ce n'est pas rien.
Joël m'a prêté les ciseaux ; je les lui ai rendus, encore que l'heure fût déjà courte.
Solange a tamponné la feuille : elle la leur a donnée, lisible, sans rature.
Aline nous l'a expliqué : une consigne trop vite criée casse, comme un tissu trop tiré.
Je le leur dirai jeudi : trois minutes à l'antenne, un sac fini à l'atelier, pas davantage.
Ne me le jetez pas, ce carnet : tendez-le-moi, simplement, sous le figuier.
L'atelier est une phrase qu'on tend ; la radio est une oreille qu'on ouvre.
Je retiens l'ordre : me / te / nous / vous, le / la / les, lui / leur.
Rose
Copie : Aline, Dieudonné, Lila — Seuil des Sources""",
        tf_item=(
            "Rose emploie la comparaison « claire comme un fil bien coupé ».",
            True,
            "Deuxième phrase de la consigne.",
        ),
        qcm_item=(
            "Que Rose a-t-elle fait des ciseaux de Joël ?",
            [
                "Elle les a jetés",
                "Elle les lui a rendus",
                "Elle les a vendus",
                "Elle les a cachés au Bureau",
            ],
            1,
            "« je les lui ai rendus. »",
        ),
        pairs=[
            ("je le lui ai remis", "coupon / Dieudonné"),
            ("on me l'a confirmé", "avant le thé"),
            ("le figuier est une antenne", "métaphore"),
            ("comme un tissu trop tiré", "comparaison"),
        ],
        fill_item=("Ne me ___ jetez pas, ce carnet. (le)", "le"),
        words=["Tendez-le-moi", "simplement", "sous", "le", "figuier", "."],
        anagram=("confirme", "On me l'a… : on a garanti la durée avant le thé. (sans accent final)"),
        error=(
            "Aline nous l'a expliqué calmement, et une consigne trop vite criée casse comme un tissus trop tiré.",
            "Aline nous l'a expliqué calmement, et une consigne trop vite criée casse comme un tissu trop tiré.",
            "Tissu s'écrit sans s final au singulier.",
        ),
        pic_start=13,
        pic_words=["un métier", "une charte", "une table", "un entretien"],
        short_p="Imitez : douze lignes, quatre doubles pronoms, une métaphore, une comparaison, une litote.",
        audio="Lisez votre consigne, sans aller trop vite.",
    ),
    _l(
        "EL",
        "EL — Doubles pronoms et figures douces",
        "Retenir l'ordre des pronoms et trois figures inventées de la cour.",
        "Apprenez la fiche.",
        "Fiche de Lila, pronoms et figures",
        """Ordre à l'indicatif : me / te / se / nous / vous + le / la / les + lui / leur + verbe.
Je le lui ai transmis. On me l'a confirmé. Elle nous les a montrés.
Pas : je lui le. Pas : on l'a me confirmé.
Impératif affirmatif : verbe-le-moi (tendez-le-moi). Impératif négatif : ne me le jetez pas.
Accord du participe : COD avant → je les lui ai rendus ; je me l'a répétée (durée, fém.).
Métaphore douce : le figuier est une antenne ; l'atelier est une phrase qu'on tend ; la radio est une oreille.
Comparaison : clair comme un coupon bien coupé ; cassé comme un fil trop tiré.
Litote : ce n'est pas rien ; ce n'est pas le plus faible des relais.
Ces figures s'inventent autour du figuier, du tissu, de la radio : pas ailleurs.
Attention : à + le = au. Il faut (pas je faut).
Une figure éclaire une consigne ; elle ne la remplace pas.
On transmet sous le figuier : deux pronoms, une image douce, pas un cri.""",
        tf_item=(
            "À l'impératif négatif, les pronoms restent avant le verbe : ne me le jetez pas.",
            True,
            "Fiche : impératif négatif.",
        ),
        qcm_item=(
            "« Le figuier est une antenne » est…",
            [
                "une litote",
                "une métaphore",
                "une question rapportée",
                "un superlatif",
            ],
            1,
            "On dit que c'est, sans comme.",
        ),
        pairs=[
            ("je le lui", "COD + lui"),
            ("tendez-le-moi", "impératif +"),
            ("ne me le jetez pas", "impératif −"),
            ("ce n'est pas rien", "litote"),
        ],
        fill_item=("Tendez-___-moi, simplement. (le coupon)", "le"),
        words=["Ce", "n'est", "pas", "rien", "que", "de", "se", "taire", "."],
        anagram=("pronoms", "Le, lui, me, te : on en place souvent deux, dans un ordre fixe."),
        error=(
            "Je lui le confirmerai jeudi, et le figuier restera notre antenne.",
            "Je le lui confirmerai jeudi, et le figuier restera notre antenne.",
            "Le avant lui.",
        ),
        pic_start=14,
        pic_words=["une charte", "une table", "un entretien", "une porte"],
        short_p="Conjuguez transmettre et confirmer au PC avec deux pronoms (je / on / elle) et inventez trois figures.",
        audio="Enregistrez la fiche, six doubles pronoms et trois figures.",
    ),
]


# ---------------------------------------------------------------------------
# Séquence 4 — Métier et point de vue (nuancer)
# ---------------------------------------------------------------------------

S4 = [
    _l(
        "CO",
        "CO — Nuancer sans trahir",
        "Repérer les expressions qui nuancent un avis sur un métier (il me semble que, on peut toutefois, sans nier que, encore que + subj.).",
        "Lisez le dialogue. Qui nuance quoi, et avec quelle formule ?",
        "Banc du Seuil, avis croisés",
        """Aline : Un métier se discute ; on ne le cloue pas. Nuancez.
Patrick : Il me semble que l'atelier me convient davantage, encore que l'antenne m'attire.
Léa : On peut toutefois reconnaître que Joël tient déjà trois minutes, sans nier que le silence lui coûte.
Marc : Sans nier que Radio Figuier ouvre une oreille, il me semble que l'atelier forme plus les mains.
Dieudonné : Encore que le fil soit court, on peut toutefois finir un sac honnête.
Lila : Il me semble que Patrick gagnerait à essayer les deux, encore qu'il doive choisir un matin.
Joël : On peut toutefois dire que je commence, sans nier que je tremble encore au signal.
Rose : Encore que le coupon soit simple, ce n'est pas un métier moindre.
Hawa : Il me semble que comparer n'est pas trahir, encore que chacun tienne à son lieu.
Karim : Sans nier que le tampon compte, on peut toutefois préférer un geste tenu.
Solange : Encore que la feuille soit lisible, il me semble qu'il manque une heure.
Félicie : On peut toutefois boire le thé avant de décider, sans nier que le temps presse.
Mado : J'écrirai ces nuances au Cahier, afin que l'avis reste un avis, pas un verdict.
Aline : Il me semble que / on peut toutefois / sans nier que / encore que + subjonctif : quatre portes, pas un mur.""",
        tf_item=(
            "Encore que se construit avec le subjonctif : encore que le fil soit court.",
            True,
            "Dieudonné et Aline le montrent.",
        ),
        qcm_item=(
            "Que semble-t-il à Patrick, d'après le dialogue ?",
            [
                "Que l'antenne lui convient davantage",
                "Que l'atelier lui convient davantage, encore que l'antenne l'attire",
                "Qu'il faut fermer l'atelier",
                "Que Solange refuse toute feuille",
            ],
            1,
            "Patrick : atelier davantage, antenne qui attire encore.",
        ),
        pairs=[
            ("il me semble que", "avis prudent"),
            ("on peut toutefois", "concession souple"),
            ("sans nier que", "on admet un fait"),
            ("encore que", "subjonctif"),
        ],
        fill_item=("Encore que le fil ___ court, on peut finir un sac. (être, subj.)", "soit"),
        words=["Il", "me", "semble", "que", "l'atelier", "me", "convient", "."],
        anagram=("toutefois", "On peut… : on admet, puis on ajoute un autre avis."),
        error=(
            "Encore que le fil est court, on peut toutefois finir un sac honnête.",
            "Encore que le fil soit court, on peut toutefois finir un sac honnête.",
            "Encore que + subjonctif : soit, pas est.",
        ),
        pic_start=15,
        pic_words=["une table", "un entretien", "une porte", "un outil"],
        short_p="Notez quatre formules de nuance et, pour chacune, l'avis qu'elle porte.",
        audio="Enregistrez : Il me semble que l'atelier me convient. On peut toutefois essayer l'antenne. Sans nier que le silence coûte. Encore que le fil soit court.",
    ),
    _l(
        "CE",
        "CE — Avis nuancé sur deux métiers",
        "Lire un avis argumenté qui refuse le verdict trop net.",
        "Lisez l'avis, sans aller trop vite.",
        "Avis de Marc Nkurunziza",
        """Avis — Atelier du Tissu et Radio Figuier, sans verdict
Il me semble que l'atelier forme davantage les mains, encore que l'antenne forme l'oreille.
On peut toutefois reconnaître que Lila tient un relais juste, sans nier que Dieudonné tient un sac fini.
Sans nier que Patrick rêve du micro, il me semble qu'il gagne à mesurer un coupon avant de parler trop vite.
Encore que Joël tremble au signal, on peut toutefois dire qu'il tient déjà trois minutes.
Léa écrit que Radio Figuier n'est pas une scène ; je le crois, encore que certains y parlent trop fort.
Hawa ajoute : comparer n'est pas trahir, encore que chacun tienne à son banc.
Karim, sans nier que le tampon de Solange compte, préfère toutefois un geste tenu à une feuille trop vite signée.
Félicie rappelle qu'on peut toutefois boire le thé avant de décider, encore que le temps presse.
Mado notera cet avis au Cahier du chemin : un point de vue n'est pas une sentence.
Aline nous a dit qu'il faudrait nuancer, afin que personne n'idéalise un métier.
Yvette : encore que le fil soit simple, ce n'est pas un métier moindre.
Je conclus, sans crier : il me semble juste d'essayer les deux lieux, encore que le choix doive un jour se poser.
Marc
Seuil des Sources — Rukiri-Nord""",
        tf_item=(
            "Marc conclut qu'il faut choisir ce soir, sans essayer.",
            False,
            "Il semble juste d'essayer les deux lieux.",
        ),
        qcm_item=(
            "Que gagne Patrick à faire, selon Marc, avant de parler trop vite ?",
            [
                "Fermer Radio Figuier",
                "Mesurer un coupon",
                "Jeter le casque",
                "Refuser le thé",
            ],
            1,
            "« mesurer un coupon avant de parler trop vite. »",
        ),
        pairs=[
            ("il me semble que", "l'atelier forme les mains"),
            ("on peut toutefois", "reconnaître le relais de Lila"),
            ("sans nier que", "Patrick rêve du micro"),
            ("encore que", "Joël tremble / le fil soit simple"),
        ],
        fill_item=("Sans ___ que Patrick rêve du micro, il gagne à mesurer.", "nier"),
        words=["Comparer", "n'est", "pas", "trahir", "."],
        anagram=("semble", "Il me… que : on avance un avis sans le clouer."),
        error=(
            "Encore que chacun tient à son banc, on peut toutefois comparer sans trahir.",
            "Encore que chacun tienne à son banc, on peut toutefois comparer sans trahir.",
            "Encore que + subjonctif : tienne.",
        ),
        pic_start=16,
        pic_words=["un entretien", "une porte", "un outil", "un casque"],
        short_p="Recopiez l'avis et encadrez les quatre formules ; ajoutez deux nuances à vous.",
        audio="Lisez l'avis de Marc, sans aller trop vite.",
    ),
    _l(
        "PO",
        "PO — Dire il me semble, encore que",
        "Nuancer à l'oral un point de vue sur un métier du Seuil.",
        "Répétez, puis donnez un avis nuancé sur l'atelier ou l'antenne.",
        "Modèles d'Aline et de Patrick",
        """Il me semble que l'atelier me convient.
On peut toutefois essayer l'antenne.
Sans nier que le silence coûte, Joël tient trois minutes.
Encore que le fil soit court, le sac peut tenir.
Il me semble juste de comparer.
On peut toutefois boire le thé avant de décider.
Sans nier que le tampon compte, je préfère un geste tenu.
Encore que je tremble, je commence.
Un avis n'est pas un verdict.
Comparer n'est pas trahir.
Aline : quatre portes, pas un mur.
Léa : Radio Figuier n'est pas une scène.
Dieudonné : encore que le coupon soit simple, le geste compte.
Lila : on peut toutefois couper à trois minutes.""",
        tf_item=(
            "Les quatre formules servent à nuancer, non à imposer un verdict.",
            True,
            "Aline : quatre portes, pas un mur.",
        ),
        qcm_item=(
            "Quelle phrase emploie correctement encore que ?",
            [
                "Encore que le fil est court",
                "Encore que le fil soit court le sac peut tenir",
                "Encore que le fil sera court",
                "Encore que le fil a été court seulement",
            ],
            1,
            "Encore que + subjonctif.",
        ),
        pairs=[
            ("il me semble que", "indicatif"),
            ("on peut toutefois", "infinitif / phrase"),
            ("sans nier que", "on admet"),
            ("encore que", "subjonctif"),
        ],
        fill_item=("Il me ___ que l'atelier me convient.", "semble"),
        words=["Sans", "nier", "que", "le", "silence", "coûte", "Joël", "tient", "."],
        anagram=("nuance", "Avis prudent : on admet, on oppose, on ne cloue pas."),
        error=(
            "Il me semble que l'atelier me convient, et encore que je dois choisir un matin j'essaierai l'antenne.",
            "Il me semble que l'atelier me convient, et encore que je doive choisir un matin j'essaierai l'antenne.",
            "Encore que + subjonctif : doive, pas dois.",
        ),
        pic_start=17,
        pic_words=["une porte", "un outil", "un casque", "une poignée"],
        short_p="Écrivez huit avis : deux par formule (semble, toutefois, sans nier, encore que).",
        audio="Enregistrez les huit premiers modèles, puis votre avis nuancé.",
    ),
    _l(
        "PE",
        "PE — Mon point de vue nuancé",
        "Écrire un avis argumenté sur un métier du Seuil, avec les quatre formules.",
        "Imitez l'avis de Patrick Habimana, sans aller trop vite.",
        "Avis de Patrick Habimana",
        """Patrick Habimana — point de vue, sans verdict
Il me semble que l'Atelier du Tissu me convient davantage, encore que Radio Figuier m'attire le jeudi.
On peut toutefois reconnaître que Lila tient un relais juste, sans nier que Dieudonné tient un sac que je voudrais savoir finir.
Sans nier que je rêve du micro, il me semble que je gagne à mesurer un coupon avant de parler trop vite.
Encore que Joël tremble au signal, on peut toutefois dire qu'il m'apprend le silence.
Aline a dit qu'un avis n'était pas une sentence ; je la crois, encore que le choix doive un jour se poser.
Hawa rappelle que comparer n'est pas trahir ; je le note au Cahier du chemin.
Karim, sans nier que le tampon de Solange compte, préfère toutefois un geste tenu.
Félicie dit qu'on peut toutefois boire le thé avant de décider, encore que le temps presse.
Léa : la radio n'est pas une scène. Dieudonné : le coupon n'est pas un métier moindre.
Je conclus : il me semble juste d'essayer les deux lieux, encore que je doive choisir un matin.
Patrick
Copie : Aline Uwase — Seuil des Sources""",
        tf_item=(
            "Patrick refuse d'essayer Radio Figuier.",
            False,
            "Il semble juste d'essayer les deux lieux.",
        ),
        qcm_item=(
            "Que gagne Patrick à faire, selon lui, avant de parler trop vite ?",
            [
                "Fermer l'atelier",
                "Mesurer un coupon",
                "Jeter le Cahier",
                "Crier plus fort",
            ],
            1,
            "« mesurer un coupon avant de parler trop vite. »",
        ),
        pairs=[
            ("il me semble que", "l'atelier davantage"),
            ("on peut toutefois", "reconnaître le relais"),
            ("sans nier que", "rêve du micro"),
            ("encore que", "Joël tremble / je doive choisir"),
        ],
        fill_item=("Encore que je ___ choisir un matin. (devoir, subj.)", "doive"),
        words=["Comparer", "n'est", "pas", "trahir", "."],
        anagram=("metier", "Atelier ou antenne : un… du Seuil, pas un titre d'ailleurs. (sans accent)"),
        error=(
            "Il me semble que l'atelier me convient, et encore que je dois choisir un matin j'essaierai les deux.",
            "Il me semble que l'atelier me convient, et encore que je doive choisir un matin j'essaierai les deux.",
            "Encore que + subjonctif : doive.",
        ),
        pic_start=18,
        pic_words=["un outil", "un casque", "une poignée", "une horloge"],
        short_p="Imitez : douze à quinze lignes, les quatre formules, un métier inventé, pas de verdict sec.",
        audio="Lisez votre avis, sans aller trop vite.",
    ),
    _l(
        "EL",
        "EL — Formules pour nuancer un avis",
        "Retenir il me semble que, on peut toutefois, sans nier que, encore que + subjonctif.",
        "Apprenez la fiche.",
        "Fiche d'Aline, nuances",
        """il me semble que + indicatif : avis prudent (il me semble que l'atelier convient).
on peut toutefois + infinitif / phrase : on ajoute un autre côté (on peut toutefois essayer).
sans nier que + indicatif : on admet un fait avant d'opposer (sans nier que le silence coûte).
encore que + subjonctif : concession (encore que le fil soit court, encore que je doive choisir).
Ne pas écrire : encore que le fil est. Ne pas écrire : encore que je dois.
Un avis n'est pas un verdict. Comparer n'est pas trahir.
Réemploi possible : il a dit qu'il faudrait nuancer ; on m'a assuré que l'essai resterait possible.
Je le lui dirai sans crier. On me l'a confirmé : quatre portes, pas un mur.
Attention : il faut nuancer (pas je faut). Bien que / encore que + subj.
À + le = au métier, au Seuil. De + le = du micro, du coupon.
Les métiers du Seuil se discutent sous le figuier, pas avec un titre emprunté.
Un point de vue se nuance ; il ne se cloue pas en verdict.""",
        tf_item=(
            "« Encore que je dois choisir » est la forme correcte.",
            False,
            "Encore que je doive choisir.",
        ),
        qcm_item=(
            "Quelle formule appelle le subjonctif ?",
            [
                "il me semble que",
                "sans nier que",
                "encore que",
                "on peut toutefois",
            ],
            2,
            "Encore que + subjonctif.",
        ),
        pairs=[
            ("il me semble que", "indicatif"),
            ("on peut toutefois", "autre côté"),
            ("sans nier que", "on admet"),
            ("encore que", "subjonctif"),
        ],
        fill_item=("Encore que le temps ___ , on peut boire le thé. (presser, subj.)", "presse"),
        words=["Un", "avis", "n'est", "pas", "un", "verdict", "."],
        anagram=("encore", "… que + subjonctif : on concède, puis on tient l'avis."),
        error=(
            "Sans nier que le tampon compte, encore que la feuille est lisible il manque une heure.",
            "Sans nier que le tampon compte, encore que la feuille soit lisible il manque une heure.",
            "Encore que + subjonctif : soit.",
        ),
        pic_start=19,
        pic_words=["un casque", "une poignée", "une horloge", "une feuille"],
        short_p="Rédigez un mini-tableau : formule, mode, exemple d'atelier, exemple d'antenne.",
        audio="Enregistrez la fiche et quatre phrases, une par formule.",
    ),
]


# ---------------------------------------------------------------------------
# Séquence 5 — Entretien croisé Atelier / Radio (EXTRA)
# ---------------------------------------------------------------------------

S5 = [
    _l(
        "CO",
        "CO — Deux portes, un matin",
        "Suivre un entretien croisé et réemployer discours indirect, compétences, pronoms et nuances.",
        "Lisez l'entretien. Que demande-t-on à Patrick, et que rapporte-t-il ?",
        "Atelier du Tissu puis Radio Figuier",
        """Aline : Patrick, Dieudonné vous recevra d'abord ; Lila ensuite. Je le leur ai dit.
Dieudonné : On m'a assuré que vous saviez mesurer. Montrez-le-moi, sans trop parler.
Patrick : Il me semble que je sais plier ; je commence à maîtriser le coupon, encore que le fil me résiste.
Lila : Léa m'a demandé si vous teniez trois minutes. Joël me l'a confirmé, toutefois sans nier que vous tremblez.
Marc : Encore que l'antenne soit une oreille, on peut toutefois demander un geste d'atelier : cela rassure.
Joël : Dieudonné a dit qu'il ouvrirait à qui sait attendre ; vous avez attendu, c'est déjà une compétence.
Rose : Je le lui ai transmis, le carnet : les heures tenues, pas un titre d'ailleurs.
Hawa : Sans nier que le micro attire, il me semble plus juste d'essayer les deux portes le même matin.
Karim : Solange a demandé si la feuille serait lisible ; on me l'a confirmé pour midi.
Félicie : On peut toutefois boire le thé entre les deux portes, encore que le temps presse.
Mado : J'écrirai : il a dit qu'il essaierait ; elle a demandé s'il savait se taire ; on m'a assuré que le banc resterait libre.
Yvette : Ce n'est pas rien, que de croiser les deux lieux sans idéaliser.
Aline : Je vous le redis : un entretien croisé n'est pas un verdict. Nuancez, transmettez, rappelez.
Patrick : Je le vous redis ? — Aline : Je vous le redis. L'ordre tient aussi ici.""",
        tf_item=(
            "Aline corrige « je le vous redis » en « je vous le redis ».",
            True,
            "Dernier échange.",
        ),
        qcm_item=(
            "Que Dieudonné demande-t-il à Patrick de montrer ?",
            [
                "Un titre d'ailleurs",
                "Qu'il sait mesurer, sans trop parler",
                "Qu'il sait crier",
                "Qu'il refuse le thé",
            ],
            1,
            "« vous saviez mesurer. Montrez-le-moi. »",
        ),
        pairs=[
            ("je le leur ai dit", "Aline aux deux portes"),
            ("on me l'a confirmé", "trois minutes / feuille"),
            ("il me semble que", "je sais plier"),
            ("encore que", "le fil me résiste"),
        ],
        fill_item=("Je ___ le redis : un entretien n'est pas un verdict. (vous)", "vous"),
        words=["Montrez-le-moi", "sans", "trop", "parler", "."],
        anagram=("entretien", "Croisé : une porte à l'atelier, une porte à l'antenne, le même matin."),
        error=(
            "Je le vous redis calmement, et Dieudonné a dit qu'il ouvrirait à qui sait attendre.",
            "Je vous le redis calmement, et Dieudonné a dit qu'il ouvrirait à qui sait attendre.",
            "Vous (COI) avant le (COD).",
        ),
        pic_start=20,
        pic_words=["une feuille", "une étoile", "une radio", "un nuage"],
        short_p="Notez trois questions rapportées, deux doubles pronoms et deux nuances de l'entretien.",
        audio="Enregistrez : On m'a assuré que vous saviez mesurer. Je vous le redis. Encore que le fil me résiste, je commence.",
    ),
    _l(
        "CE",
        "CE — Feuille d'entretien croisé",
        "Lire la feuille qui croise les deux portes et les paroles rapportées.",
        "Lisez la feuille, sans aller trop vite.",
        "Feuille d'Aline Uwase, entretien croisé",
        """Feuille — Patrick Habimana, deux portes le même matin
Dieudonné a dit qu'il ouvrirait à qui saurait attendre ; Patrick a attendu, puis il lui a montré un coupon mesuré.
Lila a demandé si Patrick tenait trois minutes ; Joël me l'a confirmé, encore que le silence lui coûte.
On m'a assuré que le banc resterait libre entre les deux portes ; Félicie a toutefois demandé si le thé n'était pas déjà versé.
Patrick : il me semble que je sais plier ; je commence à maîtriser le fil, sans nier que le micro m'attire.
Aline lui a dit de ne pas idéaliser : un entretien croisé n'est pas un verdict.
Rose le lui a transmis, le carnet : heures tenues, pas un titre emprunté.
Marc : encore que l'antenne soit une oreille, on peut toutefois demander un geste d'atelier.
Hawa : comparer n'est pas trahir ; Léa : la radio n'est pas une scène.
Karim a assuré que Solange tamponnerait la feuille à midi, pourvu qu'elle soit lisible.
Mado notera au Cahier du chemin : il a dit qu'il essaierait les deux ; on me l'a confirmé.
Yvette : ce n'est pas rien, que de croiser sans crier.
Je vous le redis : nuancez, transmettez, rappelez les compétences sans les enfler.
Aline Uwase — Atelier d'Aline
Seuil des Sources — Rukiri-Nord""",
        tf_item=(
            "La feuille présente l'entretien croisé comme un verdict définitif.",
            False,
            "« n'est pas un verdict. »",
        ),
        qcm_item=(
            "Qui a confirmé que Patrick tenait trois minutes ?",
            ["Solange", "Joël", "Karim", "Félicie"],
            1,
            "« Joël me l'a confirmé. »",
        ),
        pairs=[
            ("Dieudonné a dit que", "il ouvrirait à qui attend"),
            ("Lila a demandé si", "trois minutes"),
            ("il me semble que", "je sais plier"),
            ("je vous le redis", "nuancez"),
        ],
        fill_item=("Rose ___ lui a transmis, le carnet.", "le"),
        words=["Un", "entretien", "croisé", "n'est", "pas", "un", "verdict", "."],
        anagram=("croise", "Entretien… : les deux portes le même matin. (sans accent)"),
        error=(
            "Lila a demandé que Patrick tenait trois minutes, et Joël me l'a confirmé.",
            "Lila a demandé si Patrick tenait trois minutes, et Joël me l'a confirmé.",
            "Question rapportée : demander si.",
        ),
        pic_start=21,
        pic_words=["une étoile", "une radio", "un nuage", "un soleil"],
        short_p="Recopiez la feuille et classez : discours indirect, compétence, pronom, nuance.",
        audio="Lisez la feuille d'entretien, sans aller trop vite.",
    ),
    _l(
        "PO",
        "PO — Dire l'entretien croisé",
        "Réemployer à l'oral les outils des quatre premières séquences, à deux portes.",
        "Répétez, puis jouez deux minutes d'entretien : une question, une compétence, une nuance.",
        "Modèles d'Aline, de Dieudonné et de Lila",
        """On m'a assuré que vous saviez mesurer.
Montrez-le-moi, sans trop parler.
Il me semble que je sais plier.
Encore que le fil me résiste, je commence.
Elle a demandé si vous teniez trois minutes.
Joël me l'a confirmé.
Sans nier que le micro attire, j'essaie l'atelier.
On peut toutefois boire le thé entre les deux portes.
Je vous le redis : ce n'est pas un verdict.
Dieudonné a dit qu'il ouvrirait à qui attend.
Comparer n'est pas trahir.
Je le lui ai transmis, le carnet.
Ce n'est pas rien, que de croiser les deux lieux.
Aline : transmettez, nuancez, rappelez.""",
        tf_item=(
            "L'entretien croisé réemploie les quatre outils : rapporter, nommer, transmettre, nuancer.",
            True,
            "C'est le but de la séquence extra.",
        ),
        qcm_item=(
            "Quelle réplique transmet une consigne avec deux pronoms ?",
            [
                "Il me semble que je sais plier",
                "Montrez-le-moi sans trop parler",
                "Comparer n'est pas trahir",
                "Encore que le fil me résiste",
            ],
            1,
            "Montrez-le-moi : impératif + le + moi.",
        ),
        pairs=[
            ("on m'a assuré que", "vous saviez mesurer"),
            ("montrez-le-moi", "deux pronoms"),
            ("encore que", "le fil me résiste"),
            ("je vous le redis", "pas un verdict"),
        ],
        fill_item=("Sans nier que le micro attire, j'___ l'atelier. (essayer, présent)", "essaie"),
        words=["Comparer", "n'est", "pas", "trahir", "."],
        anagram=("atelier", "Première porte : le lieu où Dieudonné tend le coupon."),
        error=(
            "Je le vous redis sans crier, et on m'a assuré que le banc resterait libre.",
            "Je vous le redis sans crier, et on m'a assuré que le banc resterait libre.",
            "Vous avant le.",
        ),
        pic_start=22,
        pic_words=["une radio", "un nuage", "un soleil", "des collègues"],
        short_p="Écrivez un mini-dialogue de dix répliques : deux portes, discours indirect, un double pronom, une nuance.",
        audio="Enregistrez les six premiers modèles, puis deux minutes d'entretien à vous.",
    ),
    _l(
        "PE",
        "PE — Mon compte d'entretien croisé",
        "Écrire le compte rendu argumenté d'un entretien à deux portes.",
        "Imitez le compte de Hawa Diallo, sans aller trop vite.",
        "Compte de Hawa Diallo",
        """Hawa Diallo — Patrick entre deux portes, le même matin
Dieudonné a dit qu'il ouvrirait à qui saurait attendre ; Patrick a attendu, puis il le lui a montré, le coupon mesuré.
Lila a demandé si Patrick tenait trois minutes ; Joël me l'a confirmé, encore que le silence lui coûte.
On m'a assuré que le banc resterait libre entre les deux portes ; Félicie a toutefois versé le thé.
Il me semble que Patrick sait plier, sans nier que le micro l'attire encore.
Aline lui a dit de ne pas idéaliser : un entretien croisé n'est pas un verdict, ce n'est pas rien que de l'écrire.
Rose le lui a transmis, le carnet : heures tenues, pas un titre d'ailleurs.
Marc : encore que l'antenne soit une oreille, on peut toutefois demander un geste d'atelier.
Léa : la radio n'est pas une scène. Dieudonné : le coupon n'est pas un métier moindre.
Karim a assuré que Solange tamponnerait la feuille à midi, pourvu qu'elle soit lisible.
Je vous le redis : comparer n'est pas trahir ; Patrick essaiera les deux, encore qu'il doive choisir un jour.
Hawa
Cahier du chemin — Seuil des Sources""",
        tf_item=(
            "Hawa dit que comparer, c'est trahir l'un des deux lieux.",
            False,
            "« comparer n'est pas trahir. »",
        ),
        qcm_item=(
            "Que Rose a-t-elle transmis ?",
            [
                "Un titre d'ailleurs",
                "Le carnet des heures tenues",
                "Un casque jeté",
                "Une sentence",
            ],
            1,
            "« le carnet : heures tenues. »",
        ),
        pairs=[
            ("il a dit que", "il ouvrirait"),
            ("elle a demandé si", "trois minutes"),
            ("il me semble que", "Patrick sait plier"),
            ("je vous le redis", "comparer n'est pas trahir"),
        ],
        fill_item=("Encore qu'il ___ choisir un jour. (devoir, subj.)", "doive"),
        words=["Un", "entretien", "croisé", "n'est", "pas", "un", "verdict", "."],
        anagram=("essai", "Les deux portes le même matin : un… , pas une sentence."),
        error=(
            "On m'a assuré si le banc resterait libre, et Félicie a toutefois versé le thé.",
            "On m'a assuré que le banc resterait libre, et Félicie a toutefois versé le thé.",
            "Assurer que, pas assurer si.",
        ),
        pic_start=23,
        pic_words=["un nuage", "un soleil", "des collègues", "un tampon"],
        short_p="Imitez : quinze lignes, deux portes, discours indirect, compétences, un double pronom, deux nuances.",
        audio="Lisez votre compte, sans aller trop vite.",
    ),
    _l(
        "EL",
        "EL — Synthèse de l'entretien croisé",
        "Relier discours indirect, compétences, doubles pronoms et nuances dans un même oral.",
        "Apprenez la fiche.",
        "Fiche de synthèse, deux portes",
        """Réemploi 1 — rapporter : il a dit qu'il ouvrirait ; elle a demandé si ; on m'a assuré que.
Réemploi 2 — compétences : je sais plier ; je suis capable d'attendre ; je commence à maîtriser le fil.
Réemploi 3 — pronoms : je le lui ai transmis ; on me l'a confirmé ; montrez-le-moi ; je vous le redis.
Réemploi 4 — nuances : il me semble que ; on peut toutefois ; sans nier que ; encore que + subj.
Deux portes : Atelier du Tissu (Dieudonné) le matin, Radio Figuier (Lila, Léa, Marc, Joël) ensuite.
Un entretien croisé n'est pas un verdict. Comparer n'est pas trahir.
Ordre : me / te / nous / vous + le / la / les + lui / leur. Pas : je le vous.
Futur rapporté au passé → conditionnel : il a dit qu'il essaierait.
Encore que le silence lui coûte, Joël me l'a confirmé.
Attention : assurer que (pas si) ; demander si (question) ; dire de (ordre).
Il faut nuancer (pas je faut). À + le = au Seuil, aux deux portes.
Le Cahier du chemin garde les heures tenues, pas un titre d'ailleurs.""",
        tf_item=(
            "On dit « je le vous redis » dans l'ordre correct.",
            False,
            "Je vous le redis.",
        ),
        qcm_item=(
            "Quelle série relie correctement les quatre réemplois ?",
            [
                "je faut / je lui le / encore que est / assurer si",
                "il a dit qu'il essaierait / je sais plier / je vous le redis / encore que + subj.",
                "il a dit qu'il essayera seulement / je connais plier / je le vous / encore que + indicatif",
                "demander que (question) / capable à / tendez moi le / verdict obligatoire",
            ],
            1,
            "Les quatre outils de la séquence, correctement formés.",
        ),
        pairs=[
            ("il a dit que", "conditionnel"),
            ("je sais / capable de", "compétence"),
            ("je vous le redis", "deux pronoms"),
            ("encore que", "subjonctif"),
        ],
        fill_item=("Je ___ le redis : ce n'est pas un verdict.", "vous"),
        words=["Comparer", "n'est", "pas", "trahir", "."],
        anagram=("synthese", "Fiche qui relie les quatre outils des deux portes. (sans accent)"),
        error=(
            "Il a dit qu'il essayera les deux portes, et Aline a demandé si le banc était libre.",
            "Il a dit qu'il essaierait les deux portes, et Aline a demandé si le banc était libre.",
            "Discours indirect au passé : futur → conditionnel.",
        ),
        pic_start=24,
        pic_words=["un soleil", "des collègues", "un tampon", "une balance"],
        short_p="Rédigez un tableau : quatre réemplois, un exemple atelier, un exemple antenne.",
        audio="Enregistrez la fiche et quatre phrases, une par réemploi.",
    ),
]


# ---------------------------------------------------------------------------
# Séquence 6 — Charte du travail au Seuil (EXTRA)
# ---------------------------------------------------------------------------

S6 = [
    _l(
        "CO",
        "CO — Articles sous le figuier",
        "Comprendre une charte inventée du travail au Seuil, et les formules qui la portent.",
        "Lisez le dialogue. Quels articles entend-on, et qui les défend ?",
        "Table des Sources, feuille de charte",
        """Aline : Nous écrirons une charte, pas un règlement d'ailleurs. Elle tiendra atelier et antenne.
Dieudonné : Article premier : on a dit qu'il faudrait mesurer avant de couper, et on me l'a confirmé.
Lila : Article deux : encore que le sujet soit vaste, on coupe à trois minutes ; ce n'est pas rien.
Patrick : Il me semble que l'article trois devrait dire : un entretien n'est pas un verdict.
Léa : On peut toutefois ajouter qu'un relais du matin maîtrise le silence, sans nier que l'atelier forme les mains.
Marc : Je vous le redis : le figuier est une antenne, pas un tambour. Article quatre, métaphore douce.
Joël : On m'a assuré que Solange tamponnerait seulement une feuille lisible. Article cinq.
Rose : Sans nier que le fil casse, on peut toutefois recoudre : article six, compétence de réparation.
Hawa : Article sept : comparer n'est pas trahir ; encore que chacun tienne à sa porte, on croise.
Karim : Dieudonné a dit qu'il ouvrirait à qui saurait attendre ; cela devient un article, pas une rumeur.
Solange : Je la leur remettrai, la charte, quand les heures seront tenues. Je vous le promets.
Félicie : On peut toutefois boire le thé avant de signer, encore que le temps presse.
Mado : Le Cahier du chemin gardera la charte, afin que personne ne l'enfle demain.
Yvette : Ce n'est pas le plus faible des textes, qu'une charte écrite sous le figuier.""",
        tf_item=(
            "Aline refuse d'emprunter un règlement d'ailleurs.",
            True,
            "« pas un règlement d'ailleurs. »",
        ),
        qcm_item=(
            "Que dit l'article deux, d'après Lila ?",
            [
                "On parle sans limite",
                "On coupe à trois minutes, encore que le sujet soit vaste",
                "On jette le casque",
                "On ferme l'atelier",
            ],
            1,
            "Lila : coupe à trois minutes.",
        ),
        pairs=[
            ("article premier", "mesurer avant de couper"),
            ("article deux", "trois minutes"),
            ("article trois", "pas un verdict"),
            ("article quatre", "figuier / antenne"),
        ],
        fill_item=("Je ___ leur remettrai, la charte, quand les heures seront tenues.", "la"),
        words=["Comparer", "n'est", "pas", "trahir", "."],
        anagram=("charte", "Texte commun du Seuil : articles d'atelier et d'antenne, pas un règlement d'ailleurs."),
        error=(
            "Encore que le sujet est vaste on coupe à trois minutes, et on me l'a confirmé.",
            "Encore que le sujet soit vaste on coupe à trois minutes, et on me l'a confirmé.",
            "Encore que + subjonctif : soit.",
        ),
        pic_start=25,
        pic_words=["des collègues", "un tampon", "une balance", "un discours"],
        short_p="Notez six articles entendus et la formule (indirect, pronom, nuance ou figure) qui les porte.",
        audio="Enregistrez : On a dit qu'il faudrait mesurer. Encore que le sujet soit vaste on coupe. Je vous le redis : ce n'est pas un verdict.",
    ),
    _l(
        "CE",
        "CE — Charte du travail au Seuil",
        "Lire la charte argumentée qui lie l'atelier et l'antenne.",
        "Lisez la charte, sans aller trop vite.",
        "Charte du travail au Seuil des Sources",
        """Charte du travail au Seuil — feuille commune
Article 1. Dieudonné a dit qu'il faudrait mesurer avant de couper ; on me l'a confirmé : un geste tenu vaut mieux qu'un titre.
Article 2. Encore que le sujet soit vaste, Lila coupe à trois minutes ; un relais du matin maîtrise le silence.
Article 3. Il me semble juste d'écrire qu'un entretien n'est pas un verdict, encore que le choix doive un jour se poser.
Article 4. Le figuier est une antenne, pas un tambour : on y transmet, on n'y crie pas. Ce n'est pas rien.
Article 5. Solange tamponne seulement une feuille lisible ; Karim a assuré qu'elle la leur remettrait à midi.
Article 6. Sans nier que le fil casse, on peut toutefois recoudre : Rose tient cette compétence.
Article 7. Comparer n'est pas trahir : on croise atelier et radio, encore que chacun tienne à sa porte.
Article 8. On a demandé si les heures étaient tenues ; Mado les note au Cahier du chemin, afin que personne ne les déforme.
Article 9. Je vous le redis : savoir + infinitif, être capable de, commencer à maîtriser — on décrit, on ne se vante pas.
Article 10. On peut toutefois boire le thé avant de signer, encore que le temps presse ; Félicie dresse la table.
Aline Uwase, formatrice — Atelier d'Aline
Dieudonné Hakizimana, Lila Sow, Patrick Habimana
Seuil des Sources — Rukiri-Nord
Cette charte n'emprunte aucun règlement d'ailleurs.""",
        tf_item=(
            "L'article 5 dit que Solange tamponne n'importe quelle feuille, même illisible.",
            False,
            "Elle tamponne seulement une feuille lisible.",
        ),
        qcm_item=(
            "Que note Mado à l'article 8 ?",
            [
                "Des titres d'ailleurs",
                "Les heures tenues au Cahier du chemin",
                "Les rumeurs de la rive",
                "Un verdict définitif",
            ],
            1,
            "« Mado les note au Cahier du chemin. »",
        ),
        pairs=[
            ("article 1", "mesurer avant de couper"),
            ("article 3", "pas un verdict"),
            ("article 4", "figuier / antenne"),
            ("article 7", "comparer n'est pas trahir"),
        ],
        fill_item=("Encore que le choix ___ un jour se poser. (devoir, subj.)", "doive"),
        words=["Un", "entretien", "n'est", "pas", "un", "verdict", "."],
        anagram=("devoir", "Article 1 : on a dit qu'il faudrait… mesurer. Un… du geste."),
        error=(
            "On a demandé que les heures étaient tenues, et Mado les note au Cahier du chemin.",
            "On a demandé si les heures étaient tenues, et Mado les note au Cahier du chemin.",
            "Question rapportée : demander si.",
        ),
        pic_start=26,
        pic_words=["un tampon", "une balance", "un discours", "un parcours"],
        short_p="Recopiez cinq articles et, pour chacun, le point de langue qu'il réemploie.",
        audio="Lisez la charte, sans aller trop vite.",
    ),
    _l(
        "PO",
        "PO — Dire un article de charte",
        "Prononcer un article en réemployant les formules du module.",
        "Répétez, puis proposez un article à vous, nuancé, sans titre d'ailleurs.",
        "Modèles d'Aline et de Solange",
        """On a dit qu'il faudrait mesurer avant de couper.
Encore que le sujet soit vaste, on coupe à trois minutes.
Il me semble qu'un entretien n'est pas un verdict.
Je vous le redis : le figuier est une antenne.
On me l'a confirmé : feuille lisible seulement.
Sans nier que le fil casse, on peut toutefois recoudre.
Comparer n'est pas trahir.
Je la leur remettrai, la charte, à midi.
On peut toutefois boire le thé avant de signer.
Ce n'est pas rien, qu'une charte sous le figuier.
Dieudonné : un geste tenu vaut mieux qu'un titre.
Lila : un relais maîtrise le silence.
Patrick : j'essaierai les deux portes.
Aline : on décrit, on ne se vante pas.""",
        tf_item=(
            "Un article de charte peut réemployer le discours indirect et la nuance.",
            True,
            "Les modèles le font.",
        ),
        qcm_item=(
            "Quelle phrase est une métaphore douce de la charte ?",
            [
                "On coupe à trois minutes",
                "Le figuier est une antenne",
                "Feuille lisible seulement",
                "Boire le thé avant de signer",
            ],
            1,
            "Le figuier est une antenne.",
        ),
        pairs=[
            ("il faudrait mesurer", "article 1"),
            ("trois minutes", "article 2"),
            ("pas un verdict", "article 3"),
            ("figuier / antenne", "article 4"),
        ],
        fill_item=("Je ___ leur remettrai, la charte, à midi.", "la"),
        words=["On", "décrit", "on", "ne", "se", "vante", "pas", "."],
        anagram=("equipe", "Atelier et antenne ensemble, sous le figuier. (sans accent)"),
        error=(
            "Je le leur remettrai la charte à midi, et on me l'a confirmé pour la feuille lisible.",
            "Je la leur remettrai la charte à midi, et on me l'a confirmé pour la feuille lisible.",
            "La charte est féminin : la leur.",
        ),
        pic_start=27,
        pic_words=["une balance", "un discours", "un parcours", "un choix"],
        short_p="Écrivez six articles oraux : un par formule (dit que, encore que, semble, le lui, toutefois, litote).",
        audio="Enregistrez les huit premiers modèles, puis un article à vous.",
    ),
    _l(
        "PE",
        "PE — Mon article de charte",
        "Écrire un article argumenté pour la charte du travail au Seuil.",
        "Imitez l'article de Léa Niyonzima, sans aller trop vite.",
        "Article de Léa Niyonzima",
        """Léa Niyonzima — pour la charte du Seuil
Il me semble juste d'écrire qu'un relais du matin n'est pas une scène, encore que la voix porte jusqu'au banc.
On m'a assuré que Lila couperait à trois minutes ; je le lui ai confirmé, claire comme un coupon bien tendu.
Sans nier que l'atelier forme les mains, on peut toutefois reconnaître que l'antenne forme l'oreille : comparer n'est pas trahir.
Dieudonné a dit qu'il ouvrirait à qui saurait attendre ; Aline a demandé si nous savions décrire une compétence sans nous vanter.
Je vous le redis : le figuier est une antenne, pas un tambour. Ce n'est pas rien que de s'y taire avant de parler.
Solange tamponnera seulement une feuille lisible ; Karim a assuré qu'elle la leur remettrait à midi.
Encore que Patrick doive choisir un jour, un entretien croisé n'est pas un verdict.
Rose tient la réparation : sans nier que le fil casse, on peut toutefois recoudre.
Mado notera cet article au Cahier du chemin, afin que personne ne l'enfle.
On peut toutefois boire le thé avant de signer, encore que le temps presse.
Léa
Copie : Aline Uwase, Lila Sow, Dieudonné Hakizimana""",
        tf_item=(
            "Léa écrit que Radio Figuier est une scène.",
            False,
            "« un relais du matin n'est pas une scène. »",
        ),
        qcm_item=(
            "Que Solange tamponnera-t-elle, d'après Léa ?",
            [
                "N'importe quelle rumeur",
                "Seulement une feuille lisible",
                "Un titre d'ailleurs",
                "Un casque cassé",
            ],
            1,
            "« seulement une feuille lisible. »",
        ),
        pairs=[
            ("il me semble que", "pas une scène"),
            ("je le lui ai confirmé", "trois minutes / Lila"),
            ("comparer n'est pas trahir", "mains / oreille"),
            ("pas un verdict", "entretien croisé"),
        ],
        fill_item=("Encore que Patrick ___ choisir un jour. (devoir, subj.)", "doive"),
        words=["Comparer", "n'est", "pas", "trahir", "."],
        anagram=("tampon", "Solange le pose sur une feuille lisible, jamais sur une rumeur."),
        error=(
            "Je le lui ai confirmé la durée, et encore que Patrick doit choisir un jour l'entretien n'est pas un verdict.",
            "Je le lui ai confirmé la durée, et encore que Patrick doive choisir un jour l'entretien n'est pas un verdict.",
            "Encore que + subjonctif : doive.",
        ),
        pic_start=28,
        pic_words=["un discours", "un parcours", "un choix", "un curriculum"],
        short_p="Imitez : un article de douze à quinze lignes, charte locale, quatre outils du module.",
        audio="Lisez votre article, sans aller trop vite.",
    ),
    _l(
        "EL",
        "EL — Langue de la charte du Seuil",
        "Retenir les formules qui portent une charte de travail argumentée.",
        "Apprenez la fiche.",
        "Fiche de clôture, charte",
        """Une charte du Seuil réemploie : discours indirect, compétences, doubles pronoms, nuances, figures douces.
Il a dit qu'il faudrait + infinitif. Elle a demandé si + indicatif. On m'a assuré que + indicatif.
Je le lui ai transmis. On me l'a confirmé. Je vous le redis. Je la leur remettrai.
Il me semble que + indicatif. On peut toutefois. Sans nier que. Encore que + subjonctif.
Métaphore : le figuier est une antenne. Comparaison : clair comme un coupon. Litote : ce n'est pas rien.
Savoir + infinitif ; être capable de ; maîtriser ; avoir l'habitude de. Pas : je connais mesurer.
Métiers inventés seulement : teneur de coupon, relais du matin, preneur de son, tamponneur, teneur du Cahier.
Pas de règlement d'ailleurs, pas de titre emprunté, pas de ville lointaine.
Un entretien n'est pas un verdict. Comparer n'est pas trahir.
Attention : il faut (pas je faut). À + le = au Seuil. Encore que soit / doive / tienne.
Le Cahier du chemin garde la charte. On signe après le thé, pas trop vite.
Une charte locale relie l'atelier et l'antenne, sans règlement d'ailleurs.""",
        tf_item=(
            "La charte accepte un titre emprunté à une école d'ailleurs.",
            False,
            "Pas de titre emprunté, pas de ville lointaine.",
        ),
        qcm_item=(
            "Quelle série est correcte pour la charte ?",
            [
                "je faut / je lui le / encore que est",
                "il faudrait / je vous le redis / encore que soit",
                "assurer si / je connais mesurer / je le vous",
                "demander que (question) / capable à / verdict obligatoire",
            ],
            1,
            "Il faudrait, je vous le redis, encore que soit.",
        ),
        pairs=[
            ("il a dit qu'il faudrait", "nécessité rapportée"),
            ("je vous le redis", "deux pronoms"),
            ("encore que + subj.", "concession"),
            ("Cahier du chemin", "garde la charte"),
        ],
        fill_item=("On m'a assuré ___ Solange tamponnerait une feuille lisible.", "que"),
        words=["Le", "figuier", "est", "une", "antenne", "."],
        anagram=("pratique", "Geste tenu à l'atelier ou à l'antenne, plus sûr qu'un titre."),
        error=(
            "À le Seuil on signe la charte après le thé, et on me l'a confirmé.",
            "Au Seuil on signe la charte après le thé, et on me l'a confirmé.",
            "À + le = au.",
        ),
        pic_start=29,
        pic_words=["un parcours", "un choix", "un curriculum", "une compétence"],
        short_p="Rédigez un tableau final : dix articles possibles, chacun avec un point de langue du module.",
        audio="Enregistrez la fiche et cinq articles, chacun avec une formule différente.",
    ),
]


SEQUENCES = [
    {"title": "Pratiques et parcours", "lessons": S1},
    {"title": "Identifier des compétences", "lessons": S2},
    {"title": "Communiquer au travail", "lessons": S3},
    {"title": "Métier et point de vue", "lessons": S4},
    {"title": "Entretien croisé Atelier / Radio", "lessons": S5},
    {"title": "Charte du travail au Seuil", "lessons": S6},
]
