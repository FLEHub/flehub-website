"""A2 Module 3 — Un métier en français (univers Seuil des Sources)."""

from factory import L

IMG = "mfk-a2-m3"
IMG_DIR = IMG

MODULE = {
    "title": "A2 — Un métier en français",
    "description": (
        "Grande étape A2-3 : lire une offre, se présenter, proposer un "
        "service, oser un choix, raconter un parcours et répondre avec "
        "assurance — à l'Atelier du Tissu et à Radio Figuier, avec Aline, "
        "Patrick, Joël, Dieudonné et Lila Sow."
    ),
}


def _l(comp, title, obj, cons, st, sp, **kw):
    return L(IMG, comp, title, obj, cons, st, sp, **kw)


# ---------------------------------------------------------------------------
# Séquence 1 — Une offre à saisir (compétences et qualités)
# ---------------------------------------------------------------------------

S1 = [
    _l(
        "CO",
        "CO — Deux offres à la Table",
        "Repérer le vocabulaire des compétences et des qualités.",
        "Lisez le dialogue. Quelles qualités chaque offre demande-t-elle ?",
        "Table des Sources, feuilles ocre",
        """Dieudonné : À l'Atelier du Tissu, il me faut quelqu'un de soigneux et patient.
Lila : À Radio Figuier, je cherche une voix claire, ponctuelle, à l'écoute.
Patrick : Moi, je suis organisé. Je peux tenir l'accueil de la cour.
Joël : Je suis souriant, mais je ne suis pas encore autonome.
Aline : Une qualité, c'est ce que vous êtes. Une compétence, c'est ce que vous savez faire.
Hawa : L'accueil demande d'être fiable et poli.
Rose : L'atelier demande de mesurer le tissu, de plier, de noter les commandes.
Marc : La radio demande de lire un texte, de régler le micro, de respecter l'heure.""",
        tf_item=(
            "Dieudonné cherche quelqu'un de soigneux et patient.",
            True,
            "Première réplique de Dieudonné.",
        ),
        qcm_item=(
            "Selon Aline, une compétence, c'est…",
            [
                "ce que vous êtes",
                "ce que vous savez faire",
                "un défaut",
                "un horaire",
            ],
            1,
            "Qualité = être. Compétence = savoir faire.",
        ),
        pairs=[
            ("soigneux / patient", "atelier"),
            ("ponctuelle / à l'écoute", "radio"),
            ("organisé", "Patrick"),
            ("souriant", "Joël"),
        ],
        fill_item=("Une ___ , c'est ce que vous êtes.", "qualité"),
        words=["Je", "suis", "organisé", "."],
        anagram=("patient", "Dieudonné le demande : on attend sans s'énerver."),
        error=(
            "Une compétence, c'est ce que vous êtes seulement.",
            "Une compétence, c'est ce que vous savez faire.",
            "Être = qualité. Savoir faire = compétence.",
        ),
        pic_start=0,
        pic_words=["une offre", "un CV", "une qualité", "une compétence"],
        short_p="Notez quatre qualités et quatre compétences entendues.",
        audio="Enregistrez : Je suis organisé. Je suis ponctuel. Je sais tenir l'accueil. Je sais régler le micro.",
    ),
    _l(
        "CE",
        "CE — Annonces épinglées",
        "Lire deux offres et extraire qualités et compétences.",
        "Lisez les annonces, sans aller trop vite.",
        "Mur de la cour, tampons ocre",
        """Offre 1 — Atelier du Tissu (Dieudonné Hakizimana)
Qualités : soigneux, calme, fiable.
Compétences : couper droit, plier un coupon, noter une commande.
Horaires : chaque matin, accueil des commandes.
Offre 2 — Radio Figuier (Lila Sow)
Qualités : ponctuel, clair, à l'écoute de l'équipe.
Compétences : lire un texte, régler le micro, annoncer l'heure.
Offre 3 — Accueil de la cour (Aline Uwase)
Qualités : souriant, poli, autonome.
Compétences : indiquer un lieu, tenir le cahier, appeler l'infirmerie.""",
        tf_item=(
            "L'accueil de la cour demande d'être souriant et poli.",
            True,
            "Offre 3 — qualités : souriant, poli, autonome.",
        ),
        qcm_item=(
            "Qui signe l'offre de la radio ?",
            ["Dieudonné", "Aline", "Lila Sow", "Patrick"],
            2,
            "Offre 2 — Lila Sow.",
        ),
        pairs=[
            ("couper / plier / noter", "atelier"),
            ("lire / régler / annoncer", "radio"),
            ("indiquer / tenir / appeler", "accueil"),
            ("fiable / ponctuel / autonome", "qualités"),
        ],
        fill_item=("L'atelier demande quelqu'un de ___. (calme aussi)", "soigneux"),
        words=["Lire", "un", "texte", "régler", "le", "micro", "."],
        anagram=("fiable", "On peut compter sur cette personne : elle est…"),
        error=(
            "Radio Figuier cherche quelqu'un de ponctuelle et clair.",
            "Radio Figuier cherche quelqu'un de ponctuel et clair.",
            "Quelqu'un est masculin : ponctuel, clair.",
        ),
        pic_start=1,
        pic_words=["un CV", "une qualité", "une compétence", "un badge"],
        short_p="Recopiez une offre et ajoutez une qualité à vous.",
        audio="Lisez les trois offres, sans aller trop vite.",
    ),
    _l(
        "PO",
        "PO — Dire une qualité, une compétence",
        "Présenter ce que l'on est et ce que l'on sait faire.",
        "Répétez, puis parlez d'un poste inventé de la cour.",
        "Modèles d'Aline",
        """Je suis ponctuel.
Je suis à l'écoute.
Je suis autonome.
Je sais tenir l'accueil.
Je sais plier un coupon.
Je sais lire un texte à voix haute.
Je ne suis pas encore très patient, mais j'apprends.""",
        tf_item=(
            "« Je sais + infinitif » introduit une compétence.",
            True,
            "Je sais tenir, plier, lire.",
        ),
        qcm_item=(
            "Quelle phrase dit une qualité ?",
            [
                "Je sais régler le micro",
                "Je suis fiable",
                "Je note une commande",
                "J'appelle l'infirmerie",
            ],
            1,
            "Être + adjectif = qualité.",
        ),
        pairs=[
            ("je suis", "qualité"),
            ("je sais + inf.", "compétence"),
            ("ponctuel", "à l'heure"),
            ("autonome", "sans aide constante"),
        ],
        fill_item=("Je ___ tenir l'accueil. (compétence)", "sais"),
        words=["Je", "suis", "à", "l'écoute", "."],
        anagram=("autonome", "On travaille sans demander de l'aide à chaque pas."),
        error=(
            "Je suis savoir tenir l'accueil.",
            "Je sais tenir l'accueil.",
            "Compétence : je sais + infinitif.",
        ),
        pic_start=2,
        pic_words=["une qualité", "une compétence", "un badge", "un mot de liaison"],
        short_p="Écrivez six phrases : trois je suis, trois je sais.",
        audio="Enregistrez les modèles, puis votre mini-portrait.",
    ),
    _l(
        "PE",
        "PE — Mes notes d'offre",
        "Écrire des notes sur une offre : qualités et compétences.",
        "Imitez les notes de Patrick.",
        "Notes de Patrick Habimana",
        """Patrick Habimana
Offre : accueil de la cour, sous le figuier.
Qualités demandées : souriant, poli, fiable.
Compétences : indiquer un lieu, tenir le cahier, appeler Yvette à l'infirmerie.
Je suis organisé. Je sais lire un horaire.
Je ne suis pas encore autonome le soir, mais je suis ponctuel le matin.
Patrick
Table des Sources""",
        tf_item=(
            "Patrick dit qu'il est déjà autonome le soir.",
            False,
            "« Je ne suis pas encore autonome le soir. »",
        ),
        qcm_item=(
            "Qui faut-il appeler à l'infirmerie ?",
            ["Lila", "Dieudonné", "Yvette", "Karim"],
            2,
            "« appeler Yvette à l'infirmerie ».",
        ),
        pairs=[
            ("souriant / poli / fiable", "qualités"),
            ("indiquer / tenir / appeler", "compétences"),
            ("organisé", "Patrick"),
            ("ponctuel le matin", "force"),
        ],
        fill_item=("Je suis ___. Je sais lire un horaire.", "organisé"),
        words=["Je", "sais", "lire", "un", "horaire", "."],
        anagram=("souriant", "Visage ouvert à l'accueil : une qualité de la cour."),
        error=(
            "Je suis organisé et je suis savoir l'horaire.",
            "Je suis organisé. Je sais lire un horaire.",
            "Qualité : je suis. Compétence : je sais.",
        ),
        pic_start=3,
        pic_words=["une compétence", "un badge", "un mot de liaison", "un micro"],
        short_p="Imitez : six lignes, trois qualités, trois compétences.",
        audio="Lisez vos notes, sans aller trop vite.",
    ),
    _l(
        "EL",
        "EL — Qualités et compétences",
        "Retenir le lexique pour lire une offre et se décrire.",
        "Apprenez la fiche.",
        "Fiche d'Aline",
        """Qualité (être) : ponctuel, fiable, souriant, patient, organisé,
autonome, poli, soigneux, calme, à l'écoute, clair.
Accord : une personne ponctuelle / un collègue ponctuel.
Compétence (savoir faire) : je sais + infinitif.
tenir l'accueil, plier un coupon, régler le micro, lire un texte,
indiquer un lieu, noter une commande, respecter l'heure.
On ne dit pas : je suis savoir. On dit : je sais.
Postes inventés ici : accueil de la cour, atelier du tissu, radio locale.""",
        tf_item=(
            "On dit « je suis savoir plier ».",
            False,
            "Je sais plier.",
        ),
        qcm_item=(
            "« Ponctuel » veut dire…",
            ["toujours en retard", "à l'heure", "très fort", "sans sourire"],
            1,
            "À l'heure.",
        ),
        pairs=[
            ("qualité", "je suis"),
            ("compétence", "je sais"),
            ("fiable", "on peut compter"),
            ("autonome", "sans aide constante"),
        ],
        fill_item=("Une collègue ___ arrive à l'heure. (ponctuel, fém.)", "ponctuelle"),
        words=["Je", "sais", "plier", "un", "coupon", "."],
        anagram=("ponctuel", "Jamais en retard : un collègue… le matin."),
        error=(
            "Elle est ponctuel à Radio Figuier.",
            "Elle est ponctuelle à Radio Figuier.",
            "Féminin : ponctuelle.",
        ),
        pic_start=4,
        pic_words=["un badge", "un mot de liaison", "un micro", "une carte"],
        short_p="Faites deux colonnes de dix mots : qualités / compétences.",
        audio="Enregistrez la fiche et six phrases je suis / je sais.",
    ),
]


# ---------------------------------------------------------------------------
# Séquence 2 — Se présenter professionnellement (articulateurs)
# ---------------------------------------------------------------------------

S2 = [
    _l(
        "CO",
        "CO — Coach d'Aline",
        "Repérer les articulateurs dans une présentation orale.",
        "Lisez le dialogue. Quel mot relie quelle idée ?",
        "Salle des Herbes, chaises en cercle",
        """Aline : D'abord, dites votre nom et le poste visé.
Patrick : D'abord, je m'appelle Patrick. Ensuite, je vise l'accueil.
Joël : Puis je parlerai de l'atelier. Enfin, je poserai une question.
Léa : Cependant, Joël parle trop vite. Donc il doit respirer.
Hawa : En effet, Lila l'a dit à la radio. Par exemple, une pause après chaque idée.
Marc : D'abord le cadre, ensuite les preuves, puis une qualité, enfin un merci.
Aline : Donc vous reliez : d'abord, ensuite, puis, enfin, cependant, donc, en effet, par exemple.
Rose : Cependant n'est pas un « et ». C'est un « mais » plus posé.""",
        tf_item=(
            "« Cependant » sert à ajouter la même idée, comme « et ».",
            False,
            "Rose : c'est un « mais » plus posé.",
        ),
        qcm_item=(
            "Quel mot ouvre souvent la présentation ?",
            ["enfin", "cependant", "d'abord", "en effet"],
            2,
            "D'abord = première étape.",
        ),
        pairs=[
            ("d'abord", "première idée"),
            ("ensuite / puis", "suite"),
            ("enfin", "dernière étape"),
            ("cependant", "opposition"),
        ],
        fill_item=("___ , je m'appelle Patrick.", "D'abord"),
        words=["Ensuite", "je", "vise", "l'accueil", "."],
        anagram=("ensuite", "Après d'abord : la deuxième étape, le mot…"),
        error=(
            "D'abord je m'appelle. Cependant je vise l'accueil sans contraste.",
            "D'abord je m'appelle. Ensuite je vise l'accueil.",
            "Ensuite = suite. Cependant = opposition.",
        ),
        pic_start=5,
        pic_words=["un mot de liaison", "un micro", "une carte", "un service"],
        short_p="Notez les huit articulateurs et un exemple pour chacun.",
        audio="Enregistrez : D'abord je me présente. Ensuite je vise l'accueil. Enfin je remercie.",
    ),
    _l(
        "CE",
        "CE — Cartes de présentation",
        "Lire des présentations structurées par des articulateurs.",
        "Lisez les cartes, sans aller trop vite.",
        "Cartes ocre, Bureau des Escales",
        """Carte Joël — D'abord, je m'appelle Joël Mugisha. Ensuite, je vise l'atelier.
Puis j'explique que je sais plier. Enfin, je remercie Dieudonné.
Carte Patrick — D'abord l'accueil. Cependant, je peux aider à la radio le jeudi.
Donc je reste souple. En effet, Aline l'a conseillé.
Carte Léa — Par exemple, je peux indiquer la Salle des Herbes.
Puis je tiens le cahier. Enfin, je cède la place.
Rappel : donc = conclusion. En effet = on confirme. Par exemple = on illustre.""",
        tf_item=(
            "Patrick refuse d'aider à la radio.",
            False,
            "« Cependant, je peux aider à la radio le jeudi. »",
        ),
        qcm_item=(
            "Quel mot illustre une idée ?",
            ["donc", "en effet", "par exemple", "cependant"],
            2,
            "Par exemple = illustration.",
        ),
        pairs=[
            ("d'abord / ensuite / puis / enfin", "ordre"),
            ("cependant", "contraste"),
            ("donc", "conclusion"),
            ("en effet", "confirmation"),
        ],
        fill_item=("___ je reste souple. (conclusion)", "Donc"),
        words=["Par", "exemple", "je", "peux", "indiquer", "la", "salle", "."],
        anagram=("cependant", "Opposition posée : un « mais » de présentation."),
        error=(
            "Enfin je m'appelle Joël, d'abord je remercie.",
            "D'abord je m'appelle Joël. Enfin je remercie.",
            "D'abord ouvre. Enfin ferme.",
        ),
        pic_start=6,
        pic_words=["un micro", "une carte", "un service", "une horloge"],
        short_p="Recopiez une carte et changez deux articulateurs.",
        audio="Lisez les trois cartes, sans aller trop vite.",
    ),
    _l(
        "PO",
        "PO — Relier les idées",
        "Enchaîner une présentation avec des mots de liaison.",
        "Répétez, puis présentez-vous en une minute.",
        "Modèles de Patrick",
        """D'abord, je me présente.
Ensuite, je parle du poste.
Puis je donne un exemple.
Enfin, je remercie.
Cependant, je manque d'expérience le soir.
Donc j'apprends encore.
En effet, Aline m'aide.
Par exemple, je tiens déjà le cahier du matin.""",
        tf_item=(
            "« Donc » tire une conclusion.",
            True,
            "Donc j'apprends encore.",
        ),
        qcm_item=(
            "Quel mot confirme ce qui précède ?",
            ["cependant", "en effet", "puis", "d'abord"],
            1,
            "En effet = confirmation.",
        ),
        pairs=[
            ("d'abord", "ouvrir"),
            ("puis", "continuer"),
            ("enfin", "fermer"),
            ("par exemple", "illustrer"),
        ],
        fill_item=("___ , je remercie. (dernier mot d'ordre)", "Enfin"),
        words=["Donc", "j'apprends", "encore", "."],
        anagram=("enfin", "Dernier mot de la série d'abord-ensuite-puis-…"),
        error=(
            "D'abord je remercie et enfin je me présente.",
            "D'abord je me présente. Enfin je remercie.",
            "L'ordre des articulateurs suit l'ordre des idées.",
        ),
        pic_start=7,
        pic_words=["une carte", "un service", "une horloge", "un panier"],
        short_p="Écrivez une présentation de huit lignes, un articulateur par ligne.",
        audio="Enregistrez les modèles, puis votre minute.",
    ),
    _l(
        "PE",
        "PE — Ma présentation écrite",
        "Écrire une présentation professionnelle reliée.",
        "Imitez la présentation de Joël.",
        "Présentation de Joël Mugisha",
        """Joël Mugisha
D'abord, je m'appelle Joël et je vise l'Atelier du Tissu.
Ensuite, je dis mes qualités : souriant, soigneux.
Puis je parle d'une compétence : je sais plier un coupon.
Cependant, je ne suis pas encore très rapide.
Donc je demande un essai le matin.
En effet, Dieudonné accepte les essais courts.
Par exemple, je peux ranger les coupons une heure.
Enfin, je vous remercie.
Joël""",
        tf_item=(
            "Joël dit qu'il est déjà très rapide.",
            False,
            "« Cependant, je ne suis pas encore très rapide. »",
        ),
        qcm_item=(
            "Quel mot introduit l'opposition chez Joël ?",
            ["donc", "ensuite", "cependant", "enfin"],
            2,
            "Cependant + manque de vitesse.",
        ),
        pairs=[
            ("d'abord", "nom et poste"),
            ("ensuite", "qualités"),
            ("cependant", "limite"),
            ("par exemple", "ranger"),
        ],
        fill_item=("___ , je vous remercie.", "Enfin"),
        words=["Cependant", "je", "ne", "suis", "pas", "encore", "rapide", "."],
        anagram=("rapide", "Joël ne l'est pas encore : trop lent sur les coupons."),
        error=(
            "D'abord je remercie. Enfin je m'appelle Joël.",
            "D'abord je m'appelle Joël. Enfin je vous remercie.",
            "Ouverture puis clôture.",
        ),
        pic_start=8,
        pic_words=["un service", "une horloge", "un panier", "une clé"],
        short_p="Imitez : huit lignes, au moins six articulateurs différents.",
        audio="Lisez votre présentation, sans aller trop vite.",
    ),
    _l(
        "EL",
        "EL — Articulateurs",
        "Retenir d'abord, ensuite, puis, enfin, cependant, donc, en effet, par exemple.",
        "Apprenez la fiche.",
        "Fiche du carnet",
        """Ordre : d'abord → ensuite → puis → enfin
Opposition : cependant (plus posé que mais)
Conclusion : donc
Confirmation : en effet
Illustration : par exemple
D'abord s'écrit avec une apostrophe. Pas : dabord.
On ne commence pas tout par et. On varie.
Place : souvent en tête de phrase, suivis d'une virgule à l'écrit soigné.""",
        tf_item=(
            "« En effet » sert surtout à s'opposer.",
            False,
            "En effet confirme. Cependant oppose.",
        ),
        qcm_item=(
            "Quelle série est dans le bon ordre ?",
            [
                "enfin, d'abord, puis",
                "d'abord, ensuite, puis, enfin",
                "donc, d'abord, cependant",
                "par exemple, enfin, d'abord",
            ],
            1,
            "D'abord… enfin.",
        ),
        pairs=[
            ("d'abord", "1"),
            ("ensuite / puis", "2-3"),
            ("enfin", "4"),
            ("donc", "alors"),
        ],
        fill_item=("___ , Aline l'a conseillé. (confirmation)", "En effet"),
        words=["D'abord", "je", "me", "présente", "."],
        anagram=("exemple", "Par… : on illustre une idée par un cas."),
        error=(
            "Dabord je parle ensuite je finis sans apostrophe.",
            "D'abord je parle. Ensuite je finis.",
            "D'abord, avec apostrophe.",
        ),
        pic_start=9,
        pic_words=["une horloge", "un panier", "une clé", "un carrefour"],
        short_p="Écrivez huit mini-phrases, une par articulateur.",
        audio="Enregistrez la fiche et une présentation reliée de trente secondes.",
    ),
]


# ---------------------------------------------------------------------------
# Séquence 3 — Proposer un service (adverbes en -ment)
# ---------------------------------------------------------------------------

S3 = [
    _l(
        "CO",
        "CO — Comment on s'y prend",
        "Repérer les adverbes en -ment et les formes irrégulières.",
        "Lisez le dialogue. Comment chaque personne travaille-t-elle ?",
        "Atelier du Tissu, table longue",
        """Dieudonné : Pliez lentement. Ne tirez pas trop vite sur le coupon.
Lila : À la radio, parlez vraiment clairement. Les auditeurs écoutent bien.
Patrick : Je peux mieux indiquer la cour si j'ai le plan.
Joël : Je range gentiment les chutes. Ibrahim m'a aidé énormément.
Aline : Notez précisément l'heure. Noura arrive soigneusement à l'heure.
Hawa : Félicie coupe facilement le pain, mais le tissu, c'est autre chose.
Rose : Poliment, on dit « je peux vous aider » plutôt que « donne-moi ça ».
Marc : Bien et mieux ne prennent pas -ment.""",
        tf_item=(
            "Dieudonné demande de plier lentement.",
            True,
            "Première réplique.",
        ),
        qcm_item=(
            "Quel adverbe n'est pas formé avec -ment ?",
            ["lentement", "vraiment", "mieux", "précisément"],
            2,
            "Bien / mieux : formes courtes.",
        ),
        pairs=[
            ("lentement", "sans précipitation"),
            ("gentiment", "avec gentillesse"),
            ("énormément", "beaucoup"),
            ("précisément", "avec exactitude"),
        ],
        fill_item=("Pliez ___. Ne tirez pas trop vite.", "lentement"),
        words=["Parlez", "vraiment", "clairement", "."],
        anagram=("lentement", "Dieudonné : pliez sans précipiter, adverbe de lent."),
        error=(
            "Je range gentillement les chutes.",
            "Je range gentiment les chutes.",
            "Gentil → gentiment (pas gentillement).",
        ),
        pic_start=10,
        pic_words=["un panier", "une clé", "un carrefour", "un chemin"],
        short_p="Listez huit adverbes entendus et l'adjectif (s'il existe).",
        audio="Enregistrez : Pliez lentement. Parlez vraiment clairement. Je range gentiment. Notez précisément.",
    ),
    _l(
        "CE",
        "CE — Cartes de service",
        "Lire des propositions de service riches en adverbes.",
        "Lisez les cartes, sans aller trop vite.",
        "Panier ocre, Atelier du Tissu",
        """Carte Dieudonné — Nous coupons soigneusement. Nous livrons lentement si le tissu est fragile.
Carte Lila — Nous lisons vraiment le texte avant l'antenne. Nous parlons clairement.
Carte Patrick — J'indique bien la cour. Je peux mieux le faire avec un plan.
Carte Joël — Je plie gentiment. J'ai appris énormément cette semaine.
Carte Aline — Marquez précisément le nom. Merci de frapper poliment à la porte.
Irréguliers utiles : gentiment, énormément, précisément. Aussi : bien, mieux.""",
        tf_item=(
            "Patrick dit qu'il indique mal la cour.",
            False,
            "« J'indique bien la cour. »",
        ),
        qcm_item=(
            "Qui a appris énormément cette semaine ?",
            ["Lila", "Patrick", "Joël", "Aline"],
            2,
            "Carte Joël.",
        ),
        pairs=[
            ("soigneusement / lentement", "tissu"),
            ("vraiment / clairement", "radio"),
            ("bien / mieux", "accueil"),
            ("gentiment / énormément", "Joël"),
        ],
        fill_item=("Marquez ___ le nom. (exactitude)", "précisément"),
        words=["Nous", "parlons", "clairement", "."],
        anagram=("clairement", "Lila : une voix nette, sans brouillard."),
        error=(
            "Nous livrons lent si le tissu est fragile.",
            "Nous livrons lentement si le tissu est fragile.",
            "Adverbe : lentement.",
        ),
        pic_start=11,
        pic_words=["une clé", "un carrefour", "un chemin", "un choix"],
        short_p="Recopiez deux cartes et soulignez chaque adverbe.",
        audio="Lisez les cinq cartes, sans aller trop vite.",
    ),
    _l(
        "PO",
        "PO — Dire comment on fait",
        "Modifier un verbe avec un adverbe en -ment (ou bien / mieux).",
        "Répétez, puis proposez un service de la cour.",
        "Modèles de Lila",
        """Je parle lentement.
Je lis vraiment le texte.
Je m'exprime bien.
Je peux mieux expliquer.
Je réponds gentiment.
J'écoute énormément.
Je note précisément.""",
        tf_item=(
            "L'adverbe se place souvent après le verbe conjugué au présent.",
            True,
            "Je parle lentement. Je note précisément.",
        ),
        qcm_item=(
            "Quelle forme est correcte ?",
            ["gentillement", "gentiment", "gentilement", "gentilment"],
            1,
            "Gentil → gentiment.",
        ),
        pairs=[
            ("lent → lentement", "e + ment"),
            ("clair → clairement", "-ement"),
            ("gentil → gentiment", "irrégulier"),
            ("bien / mieux", "sans -ment"),
        ],
        fill_item=("Je réponds ___. (avec gentillesse)", "gentiment"),
        words=["Je", "note", "précisément", "."],
        anagram=("vraiment", "Pas un peu : je lis… le texte, pour de bon."),
        error=(
            "Je m'exprime bienment à l'antenne.",
            "Je m'exprime bien à l'antenne.",
            "Bien, pas bienment.",
        ),
        pic_start=12,
        pic_words=["un carrefour", "un chemin", "un choix", "un nuage"],
        short_p="Écrivez sept phrases, un adverbe différent à chaque ligne.",
        audio="Enregistrez les sept modèles, puis un service à vous.",
    ),
    _l(
        "PE",
        "PE — Ma carte de service",
        "Écrire une proposition de service avec des adverbes.",
        "Imitez la carte de Lila.",
        "Carte de Lila Sow",
        """Lila Sow — Radio Figuier
Nous préparons vraiment le texte.
Nous parlons lentement, puis plus clairement.
Nous accueillons gentiment les voix du Seuil.
Joël nous a aidés énormément sur les horaires.
Notez précisément votre prénom avant l'antenne.
Vous pouvez mieux vous entendre si le micro est près.
Lila""",
        tf_item=(
            "Lila demande d'écrire le prénom n'importe comment.",
            False,
            "« Notez précisément votre prénom. »",
        ),
        qcm_item=(
            "Qui a aidé énormément sur les horaires ?",
            ["Patrick", "Dieudonné", "Joël", "Marc"],
            2,
            "« Joël nous a aidés énormément. »",
        ),
        pairs=[
            ("vraiment", "préparer"),
            ("lentement / clairement", "parler"),
            ("gentiment", "accueillir"),
            ("précisément", "prénom"),
        ],
        fill_item=("Vous pouvez ___ vous entendre si le micro est près.", "mieux"),
        words=["Nous", "parlons", "lentement", "."],
        anagram=("énormément", "Joël a beaucoup aidé : adverbe d'énorme."),
        error=(
            "Nous parlons lent et claire à l'antenne.",
            "Nous parlons lentement, puis plus clairement.",
            "Adverbes : lentement, clairement.",
        ),
        pic_start=13,
        pic_words=["un chemin", "un choix", "un nuage", "une ligne"],
        short_p="Imitez : six lignes, cinq adverbes différents.",
        audio="Lisez votre carte, sans aller trop vite.",
    ),
    _l(
        "EL",
        "EL — Adverbes en -ment",
        "Retenir la formation des adverbes et les irréguliers utiles.",
        "Apprenez la fiche.",
        "Fiche d'Aline",
        """Souvent : adjectif féminin + ment.
lent → lente → lentement. clair → claire → clairement.
vrai → vraie → vraiment. poli → polie → poliment.
facile → facilement (déjà en -e).
Irréguliers : gentil → gentiment (pas gentillement)
énorme → énormément. précis → précisément.
bien et mieux : pas de -ment. On ne dit pas plus bien : on dit mieux.
Place fréquente : après le verbe. Aux temps composés : souvent avant le participe
(nous avons vraiment lu) ou après, selon le rythme.""",
        tf_item=(
            "On forme « gentillement » à partir de gentil.",
            False,
            "Gentiment.",
        ),
        qcm_item=(
            "Le comparatif de « bien », c'est…",
            ["plus bien", "bienment", "mieux", "meilleurment"],
            2,
            "Mieux.",
        ),
        pairs=[
            ("lentement", "lent"),
            ("gentiment", "gentil"),
            ("énormément", "énorme"),
            ("mieux", "bien"),
        ],
        fill_item=("Gentil → ___.", "gentiment"),
        words=["Notez", "précisément", "l'heure", "."],
        anagram=("précisément", "Sans à-peu-près : adverbe de précis, avec deux accents."),
        error=(
            "Il travaille plus bien que moi à l'atelier.",
            "Il travaille mieux que moi à l'atelier.",
            "Mieux remplace plus bien.",
        ),
        pic_start=14,
        pic_words=["un choix", "un nuage", "une ligne", "un souvenir"],
        short_p="Formez dix adverbes et signalez les irréguliers.",
        audio="Enregistrez la fiche et six adverbes en phrase.",
    ),
]


# ---------------------------------------------------------------------------
# Séquence 4 — Oser un choix (si + présent → présent / futur / impératif)
# ---------------------------------------------------------------------------

S4 = [
    _l(
        "CO",
        "CO — Deux chemins, une décision",
        "Comprendre l'hypothèse : si + présent, et la suite au présent, au futur ou à l'impératif.",
        "Lisez le dialogue. Que se passe-t-il si… ?",
        "Carrefour derrière l'atelier",
        """Aline : Si tu postules à l'atelier, tu apprends le tissu.
Dieudonné : Si tu viens le matin, tu auras un essai.
Lila : Si Joël choisit la radio, il sera à l'antenne jeudi.
Patrick : Si j'ai une question, je demande. Si tu hésites, appelle Aline.
Joël : Si elle accepte, je ferai le tour de l'atelier.
Hawa : Si vous choisissez l'accueil, vous serez sous le figuier.
Marc : Si on part trop tard, on rate Lila.
Rose : Si tu peux, reste jusqu'à midi.""",
        tf_item=(
            "Si Joël choisit la radio, il sera à l'antenne jeudi.",
            True,
            "Lila : futur après si + présent.",
        ),
        qcm_item=(
            "Quelle suite est à l'impératif ?",
            [
                "tu apprends le tissu",
                "tu auras un essai",
                "appelle Aline",
                "il sera à l'antenne",
            ],
            2,
            "Si tu hésites, appelle Aline.",
        ),
        pairs=[
            ("si + présent → présent", "habitude / règle"),
            ("si + présent → futur", "conséquence plus tard"),
            ("si + présent → impératif", "conseil"),
            ("si tu peux, reste", "ordre doux"),
        ],
        fill_item=("Si tu viens le matin, tu ___ un essai. (avoir, futur)", "auras"),
        words=["Si", "tu", "hésites", "appelle", "Aline", "."],
        anagram=("postules", "Si tu… à l'atelier : tu déposes ta candidature."),
        error=(
            "Si tu postulera, tu apprends le tissu.",
            "Si tu postules, tu apprends le tissu.",
            "Après si : présent (pas futur).",
        ),
        pic_start=15,
        pic_words=["un nuage", "une ligne", "un souvenir", "un poste"],
        short_p="Notez trois si… présent, deux si… futur, un si… impératif.",
        audio="Enregistrez : Si tu postules, tu apprends. Si tu viens, tu auras un essai. Si tu hésites, appelle.",
    ),
    _l(
        "CE",
        "CE — Billets de carrefour",
        "Lire des conseils hypothétiques avec si.",
        "Lisez les billets, sans aller trop vite.",
        "Billets d'Aline, pince ocre",
        """Billet 1 — Si vous arrivez à l'heure, Dieudonné ouvre l'atelier.
Billet 2 — Si Patrick choisit l'accueil, il sera près du figuier.
Billet 3 — Si Joël a le trac, qu'il respire. S'il peut, qu'il répète.
Billet 4 — Si Lila dit oui, vous ferez une voix d'essai.
Billet 5 — Si on manque de coupon, on attend. Si on peut, on prévient.
Attention : après si, pas de futur. On dit si tu viens, pas si tu viendras.
Je ferai (un r). Je pourrai (deux r). Je serai (pas je sera).""",
        tf_item=(
            "On écrit « si tu viendras » dans ces billets.",
            False,
            "« après si, pas de futur ».",
        ),
        qcm_item=(
            "Si Lila dit oui, que se passera-t-il ?",
            ["L'atelier ferme", "Une voix d'essai", "On manque de coupon", "Patrick part"],
            1,
            "« vous ferez une voix d'essai ».",
        ),
        pairs=[
            ("si vous arrivez", "présent → présent"),
            ("si Patrick choisit", "présent → futur"),
            ("s'il peut", "impératif / conseil"),
            ("si Lila dit oui", "vous ferez"),
        ],
        fill_item=("Si Lila dit oui, vous ___ une voix d'essai. (faire, futur)", "ferez"),
        words=["Si", "vous", "arrivez", "à", "l'heure", "il", "ouvre", "."],
        anagram=("ferez", "Vous… une voix : futur de faire, vous, un seul r."),
        error=(
            "Si tu viendras le matin, tu auras un essai.",
            "Si tu viens le matin, tu auras un essai.",
            "Si + présent, pas si + futur.",
        ),
        pic_start=16,
        pic_words=["une ligne", "un souvenir", "un poste", "un badge"],
        short_p="Réécrivez trois billets en changeant la conséquence (présent / futur / impératif).",
        audio="Lisez les cinq billets, sans aller trop vite.",
    ),
    _l(
        "PO",
        "PO — Dire si… alors",
        "Construire une hypothèse réaliste à l'oral.",
        "Répétez, puis choisissez un poste à voix haute.",
        "Modèles de Joël",
        """Si je postule, j'apprends.
Si je viens tôt, j'aurai un essai.
Si tu hésites, demande.
Si elle accepte, je ferai le tour.
Si nous choisissons la radio, nous serons à l'antenne.
Si vous pouvez, restez.
Si on part tard, on rate Lila.""",
        tf_item=(
            "« Je ferai » s'écrit avec un seul r.",
            True,
            "Faire au futur : je ferai.",
        ),
        qcm_item=(
            "Quelle phrase est correcte ?",
            [
                "Si je posterai, j'apprends",
                "Si je postule, j'apprendrai",
                "Si je postulais demain sûr",
                "Si je sera pris",
            ],
            1,
            "Si + présent, conséquence au futur possible.",
        ),
        pairs=[
            ("si + présent", "condition"),
            ("présent", "règle"),
            ("futur", "plus tard"),
            ("impératif", "conseil"),
        ],
        fill_item=("Si elle accepte, je ___ le tour. (faire, futur)", "ferai"),
        words=["Si", "tu", "hésites", "demande", "."],
        anagram=("ferai", "Je… le tour : futur de faire, je, un seul r."),
        error=(
            "Si elle accepte, je fera le tour.",
            "Si elle accepte, je ferai le tour.",
            "Je ferai (un r, terminaison -ai).",
        ),
        pic_start=17,
        pic_words=["un souvenir", "un poste", "un badge", "une question"],
        short_p="Écrivez six hypothèses : deux présent, deux futur, deux impératif.",
        audio="Enregistrez les modèles, puis votre choix oral.",
    ),
    _l(
        "PE",
        "PE — Mon billet de choix",
        "Écrire un choix avec des phrases en si.",
        "Imitez le billet d'Aline.",
        "Billet d'Aline Uwase",
        """Aline Uwase
Si tu postules à l'atelier, tu apprends le tissu.
Si tu viens le matin, tu auras un essai chez Dieudonné.
Si tu choisis la radio, tu seras avec Lila.
Si tu as une question, demande.
Si Joël vient, je pourrai l'aider.
Si vous pouvez, restez jusqu'à midi.
Aline
Carrefour de la cour""",
        tf_item=(
            "Aline écrit « je pourra » avec un seul r.",
            False,
            "« je pourrai l'aider » : deux r.",
        ),
        qcm_item=(
            "Que faire si on a une question ?",
            ["Partir", "Demander", "Se taire", "Couper le tissu"],
            1,
            "« Si tu as une question, demande. »",
        ),
        pairs=[
            ("si tu postules", "tu apprends"),
            ("si tu viens", "tu auras"),
            ("si tu as une question", "demande"),
            ("si Joël vient", "je pourrai"),
        ],
        fill_item=("Si Joël vient, je ___ l'aider. (pouvoir, futur)", "pourrai"),
        words=["Si", "tu", "as", "une", "question", "demande", "."],
        anagram=("pourrai", "Je… aider : futur de pouvoir, deux r, je."),
        error=(
            "Si tu choisis la radio, tu sera avec Lila.",
            "Si tu choisis la radio, tu seras avec Lila.",
            "Tu seras (pas tu sera).",
        ),
        pic_start=18,
        pic_words=["un poste", "un badge", "une question", "une réponse"],
        short_p="Imitez : six lignes en si, les trois suites (présent, futur, impératif).",
        audio="Lisez votre billet, sans aller trop vite.",
    ),
    _l(
        "EL",
        "EL — Si + présent",
        "Retenir les trois suites possibles après si + présent.",
        "Apprenez la fiche.",
        "Fiche du carnet",
        """Si + présent, + présent : règle, habitude.
Si tu postules, tu apprends.
Si + présent, + futur : conséquence plus tard.
Si tu viens, tu auras un essai. Si elle accepte, je ferai le tour.
Si + présent, + impératif : conseil.
Si tu hésites, appelle. Si vous pouvez, restez.
Jamais : si tu viendras. Le futur est dans l'autre partie.
Futurs utiles : je serai, tu seras ; je ferai (1 r) ; je pourrai (2 r).""",
        tf_item=(
            "On met le futur juste après si : si tu viendras.",
            False,
            "Si + présent seulement, dans ce système.",
        ),
        qcm_item=(
            "« Pouvoir » au futur, je…",
            ["je pourai", "je pourrai", "je pourra", "je peuxrai"],
            1,
            "Je pourrai, deux r.",
        ),
        pairs=[
            ("si + présent + présent", "règle"),
            ("si + présent + futur", "plus tard"),
            ("si + présent + impératif", "conseil"),
            ("je ferai", "un r"),
        ],
        fill_item=("Si tu viens, tu ___ un essai. (avoir, futur)", "auras"),
        words=["Si", "vous", "pouvez", "restez", "."],
        anagram=("auras", "Tu… un essai : futur d'avoir, tu."),
        error=(
            "Si je pourrai venir, j'apprends le tissu.",
            "Si je peux venir, j'apprendrai le tissu.",
            "Pas de futur dans la partie si.",
        ),
        pic_start=19,
        pic_words=["un badge", "une question", "une réponse", "une liste"],
        short_p="Complétez un tableau : six si, trois colonnes de suites.",
        audio="Enregistrez la fiche et six hypothèses.",
    ),
]


# ---------------------------------------------------------------------------
# Séquence 5 — Un parcours à raconter (plus-que-parfait)
# ---------------------------------------------------------------------------

S5 = [
    _l(
        "CO",
        "CO — Avant l'entretien",
        "Comprendre le plus-que-parfait : un passé déjà fini avant un autre passé.",
        "Lisez le dialogue. Qu'est-ce qui s'était passé avant ?",
        "Banc près de l'atelier",
        """Patrick : Avant l'essai, j'avais déjà tenu l'accueil trois matins.
Joël : Moi, j'avais plié des coupons chez Dieudonné, l'an dernier.
Aline : Léa est arrivée, mais elle avait préparé ses phrases la veille.
Lila : Nous avions écouté l'émission avant de postuler.
Hawa : Tu avais fini le cahier quand Marc l'a demandé.
Rose : Ils avaient postulé trop tard : la place était prise.
Dieudonné : J'avais ouvert l'atelier avant que le groupe n'arrive.
Marc : Elle s'était présentée clairement : Aline l'avait aidée.""",
        tf_item=(
            "Patrick avait déjà tenu l'accueil avant l'essai.",
            True,
            "Plus-que-parfait : j'avais déjà tenu.",
        ),
        qcm_item=(
            "Quand Léa a-t-elle préparé ses phrases ?",
            ["Après l'arrivée", "La veille", "Pendant l'essai", "Jamais"],
            1,
            "Elle avait préparé ses phrases la veille.",
        ),
        pairs=[
            ("j'avais tenu", "avant l'essai"),
            ("j'avais plié", "l'an dernier"),
            ("elle avait préparé", "la veille"),
            ("nous avions écouté", "avant de postuler"),
        ],
        fill_item=("J'___ déjà tenu l'accueil trois matins.", "avais"),
        words=["Nous", "avions", "écouté", "l'émission", "."],
        anagram=("avions", "Nous… écouté : auxiliaire avoir à l'imparfait, nous."),
        error=(
            "J'ai déjà tenu l'accueil avant que l'essai commence.",
            "J'avais déjà tenu l'accueil avant l'essai.",
            "Passé avant un autre passé → plus-que-parfait.",
        ),
        pic_start=20,
        pic_words=["une question", "une réponse", "une liste", "une porte"],
        short_p="Notez cinq actions déjà finies avant une autre.",
        audio="Enregistrez : J'avais déjà tenu l'accueil. Elle avait préparé ses phrases. Nous avions écouté.",
    ),
    _l(
        "CE",
        "CE — Extraits de parcours",
        "Lire des extraits de CV racontés au plus-que-parfait.",
        "Lisez les extraits, sans aller trop vite.",
        "Cahier de notes, Table des Sources",
        """Extrait Patrick — Quand Aline m'a appelé, j'avais rangé le cahier de la cour.
Extrait Joël — Dieudonné m'a repris parce que j'avais oublié un pli.
Extrait Léa — Avant Radio Figuier, j'avais lu trois textes à voix haute.
Extrait Hawa — Nous étions prêts : nous avions répété avec Noura.
Extrait Ibrahim — Certains étaient partis ; ils avaient fini trop tôt.
Forme : avoir (ou être) à l'imparfait + participe passé.
j'avais travaillé / elle était déjà partie / nous nous étions présentés.""",
        tf_item=(
            "Joël avait oublié un pli avant que Dieudonné le reprenne.",
            True,
            "« j'avais oublié un pli ».",
        ),
        qcm_item=(
            "Qui avait répété avec Noura ?",
            ["Patrick seul", "Léa seule", "Hawa et son groupe", "Ibrahim seul"],
            2,
            "Extrait Hawa : nous avions répété.",
        ),
        pairs=[
            ("j'avais rangé", "Patrick"),
            ("j'avais oublié", "Joël"),
            ("j'avais lu", "Léa"),
            ("nous avions répété", "Hawa"),
        ],
        fill_item=("Elle ___ déjà partie. (être, imparfait)", "était"),
        words=["J'avais", "rangé", "le", "cahier", "."],
        anagram=("oublié", "Joël l'avait… : un pli manquait, avant la reprise."),
        error=(
            "Quand Aline m'a appelé, j'ai rangé le cahier juste avant dans ma tête.",
            "Quand Aline m'a appelé, j'avais rangé le cahier.",
            "L'action est déjà finie : plus-que-parfait.",
        ),
        pic_start=21,
        pic_words=["une réponse", "une liste", "une porte", "un atelier"],
        short_p="Recopiez deux extraits et encadrez l'auxiliaire à l'imparfait.",
        audio="Lisez les cinq extraits, sans aller trop vite.",
    ),
    _l(
        "PO",
        "PO — Dire j'avais + participe",
        "Raconter un avant-passé à l'oral.",
        "Répétez, puis parlez d'un geste déjà fait avant aujourd'hui.",
        "Modèles de Patrick",
        """J'avais travaillé.
Tu avais fini.
Elle avait postulé.
Nous avions appris.
Vous aviez écouté.
Ils avaient attendu.
Je m'étais présenté.""",
        tf_item=(
            "Le plus-que-parfait = imparfait de l'auxiliaire + participe.",
            True,
            "J'avais travaillé. Elle était partie.",
        ),
        qcm_item=(
            "Quelle forme est un plus-que-parfait ?",
            ["j'ai travaillé", "je travaillais", "j'avais travaillé", "je travaillerai"],
            2,
            "J'avais + PP.",
        ),
        pairs=[
            ("j'avais", "je"),
            ("nous avions", "nous"),
            ("elle était partie", "être"),
            ("je m'étais présenté", "pronominal"),
        ],
        fill_item=("Tu ___ fini avant midi.", "avais"),
        words=["Elle", "avait", "postulé", "."],
        anagram=("travaillé", "Patrick l'avait déjà… : un travail avant l'essai."),
        error=(
            "Nous avons appris avant de postuler, c'était plus tôt que postuler.",
            "Nous avions appris avant de postuler.",
            "Avant un autre passé : avions + PP.",
        ),
        pic_start=22,
        pic_words=["une liste", "une porte", "un atelier", "une table"],
        short_p="Écrivez six plus-que-parfaits, personnes différentes.",
        audio="Enregistrez les sept modèles, puis deux phrases à vous.",
    ),
    _l(
        "PE",
        "PE — Mon parcours d'avant",
        "Écrire un parcours avec le plus-que-parfait.",
        "Imitez le parcours de Patrick.",
        "Parcours de Patrick Habimana",
        """Patrick Habimana
Avant l'essai, j'avais déjà tenu l'accueil trois matins.
J'avais rangé le cahier quand Aline m'a appelé.
Nous avions écouté Radio Figuier la veille.
Joël m'avait prêté un plan de la cour.
Je m'étais présenté poliment.
Je n'avais pas encore vu l'atelier de l'intérieur.
Patrick""",
        tf_item=(
            "Patrick avait déjà vu tout l'atelier.",
            False,
            "« Je n'avais pas encore vu l'atelier de l'intérieur. »",
        ),
        qcm_item=(
            "Qui avait prêté un plan ?",
            ["Aline", "Lila", "Joël", "Dieudonné"],
            2,
            "« Joël m'avait prêté un plan. »",
        ),
        pairs=[
            ("j'avais tenu", "accueil"),
            ("j'avais rangé", "cahier"),
            ("nous avions écouté", "radio"),
            ("je m'étais présenté", "poliment"),
        ],
        fill_item=("Joël m'___ prêté un plan.", "avait"),
        words=["Je", "m'étais", "présenté", "poliment", "."],
        anagram=("prêté", "Joël l'avait… : le plan de la cour, avant l'essai."),
        error=(
            "Avant l'essai, j'ai déjà tenu l'accueil depuis trois matins passés.",
            "Avant l'essai, j'avais déjà tenu l'accueil trois matins.",
            "Plus-que-parfait pour l'avant-passé.",
        ),
        pic_start=23,
        pic_words=["une porte", "un atelier", "une table", "un cahier"],
        short_p="Imitez : six lignes, au moins cinq plus-que-parfaits.",
        audio="Lisez votre parcours, sans aller trop vite.",
    ),
    _l(
        "EL",
        "EL — Plus-que-parfait",
        "Retenir la forme et l'emploi du plus-que-parfait.",
        "Apprenez la fiche.",
        "Fiche du carnet",
        """Plus-que-parfait = un passé déjà fini avant un autre passé.
Forme : avoir à l'imparfait + PP. j'avais, tu avais, il/elle avait,
nous avions, vous aviez, ils/elles avaient + participe.
Avec être : j'étais allé(e), elle était déjà partie.
Pronominal : je m'étais présenté(e).
Emploi : avant l'essai, la veille, quand + PC (l'autre action).
On ne remplace pas toujours le PC par le PQP : il faut un « avant ».""",
        tf_item=(
            "« J'avais » + participe forme le plus-que-parfait.",
            True,
            "J'avais travaillé.",
        ),
        qcm_item=(
            "« Aller » au plus-que-parfait, Léa :",
            ["elle a allé", "elle allait", "elle était allée", "elle sera allée"],
            2,
            "Être à l'imparfait + allée.",
        ),
        pairs=[
            ("j'avais + PP", "avoir"),
            ("j'étais allé(e)", "être"),
            ("la veille", "indice"),
            ("avant l'essai", "emploi"),
        ],
        fill_item=("Nous ___ appris le texte avant l'antenne.", "avions"),
        words=["Elle", "était", "déjà", "partie", "."],
        anagram=("partie", "Elle était déjà… : être + PP, féminin, avant les autres."),
        error=(
            "Léa a été allée avant l'entretien trop tôt.",
            "Léa était déjà allée à l'atelier avant l'entretien.",
            "Plus-que-parfait avec être : était allée.",
        ),
        pic_start=24,
        pic_words=["un atelier", "une table", "un cahier", "un tampon"],
        short_p="Conjuguez cinq verbes au PQP (je / elle / nous) avec un indice de temps.",
        audio="Enregistrez la fiche et cinq phrases d'avant-passé.",
    ),
]


# ---------------------------------------------------------------------------
# Séquence 6 — Répondre avec assurance (interrogation formelle, indéfinis)
# ---------------------------------------------------------------------------

S6 = [
    _l(
        "CO",
        "CO — Questions d'entretien",
        "Repérer est-ce que, l'inversion, et les adjectifs indéfinis.",
        "Lisez le dialogue. Comment pose-t-on les questions ?",
        "Porte de l'atelier, essai du matin",
        """Dieudonné : Est-ce que vous avez déjà plié un coupon ?
Lila : Avez-vous un exemple précis ?
Aline : Travaillez-vous chaque matin ?
Patrick : Puis-je poser une question ? Tout le monde écoute-t-il ?
Joël : Plusieurs ateliers ouvrent-ils le jeudi ?
Hawa : Certains jours, aucun bus ne passe. Est-ce que c'est vrai ?
Rose : Qu'avez-vous appris à l'accueil ?
Marc : Aucune expérience n'est trop petite, dit Aline.""",
        tf_item=(
            "« Avez-vous un exemple » est une inversion.",
            True,
            "Verbe + sujet : avez-vous.",
        ),
        qcm_item=(
            "Quel mot veut dire « pas une seule » au féminin ?",
            ["chaque", "plusieurs", "certains", "aucune"],
            3,
            "Aucune expérience.",
        ),
        pairs=[
            ("est-ce que", "question posée"),
            ("avez-vous", "inversion"),
            ("chaque matin", "tous les matins"),
            ("aucun / aucune", "zéro"),
        ],
        fill_item=("___ -vous un exemple précis ?", "Avez"),
        words=["Est-ce", "que", "vous", "avez", "déjà", "plié", "?"],
        anagram=("chaque", "Aline : … matin, sans exception, à la même heure."),
        error=(
            "Avez vous un exemple précis ?",
            "Avez-vous un exemple précis ?",
            "Inversion : trait d'union.",
        ),
        pic_start=25,
        pic_words=["une table", "un cahier", "un tampon", "une poignée"],
        short_p="Notez trois questions formelles et quatre indéfinis.",
        audio="Enregistrez : Est-ce que vous avez déjà plié ? Avez-vous un exemple ? Travaillez-vous chaque matin ?",
    ),
    _l(
        "CE",
        "CE — Fiche d'entretien",
        "Lire une fiche de questions et d'indéfinis.",
        "Lisez la fiche, sans aller trop vite.",
        "Fiche de Dieudonné Hakizimana",
        """Entretien — Atelier du Tissu / relais Radio Figuier
1. Est-ce que vous connaissez le Seuil ?
2. Pouvez-vous rester toute la matinée ?
3. Qu'avez-vous déjà fait à l'accueil ?
4. Chaque commande a un nom. Avez-vous noté le vôtre ?
5. Plusieurs coupons attendent. Certains sont fragiles.
6. Aucun retard n'est acceptable après la troisième fois.
7. Tout le monde signe le cahier.
Lila ajoute : Écoutez-vous vraiment les consignes ?""",
        tf_item=(
            "On tolère tous les retards sans limite.",
            False,
            "« Aucun retard n'est acceptable après la troisième fois. »",
        ),
        qcm_item=(
            "Qui doit signer le cahier ?",
            ["Patrick seulement", "Tout le monde", "Certains invités", "Aucun stagiaire"],
            1,
            "« Tout le monde signe le cahier. »",
        ),
        pairs=[
            ("est-ce que vous connaissez", "forme longue"),
            ("pouvez-vous", "inversion"),
            ("plusieurs / certains", "une partie"),
            ("aucun retard", "zéro"),
        ],
        fill_item=("___ le monde signe le cahier.", "Tout"),
        words=["Pouvez-vous", "rester", "toute", "la", "matinée", "?"],
        anagram=("plusieurs", "Pas un seul coupon : … coupons attendent sur la table."),
        error=(
            "Aucun retard sont acceptables le lundi.",
            "Aucun retard n'est acceptable.",
            "Aucun + nom singulier + ne… (accord au singulier).",
        ),
        pic_start=26,
        pic_words=["un cahier", "un tampon", "une poignée", "une étoile"],
        short_p="Recopiez la fiche et transformez deux est-ce que en inversion.",
        audio="Lisez les sept points, sans aller trop vite.",
    ),
    _l(
        "PO",
        "PO — Questionner et préciser",
        "Poser une question formelle et utiliser un indéfini.",
        "Répétez, puis jouez deux minutes d'entretien.",
        "Modèles d'Aline",
        """Est-ce que vous êtes prêt ?
Avez-vous un exemple ?
Travaillez-vous chaque matin ?
Puis-je entrer ?
Plusieurs personnes attendent.
Certains jours, c'est calme.
Aucun bus ne passe.
Tout le monde écoute.""",
        tf_item=(
            "« Puis-je » est une inversion polie de je peux.",
            True,
            "Puis-je entrer ?",
        ),
        qcm_item=(
            "Quelle question utilise est-ce que ?",
            [
                "Avez-vous un exemple",
                "Est-ce que vous êtes prêt",
                "Puis-je entrer",
                "Travaillez-vous chaque matin",
            ],
            1,
            "Est-ce que + sujet + verbe.",
        ),
        pairs=[
            ("est-ce que", "forme claire"),
            ("inversion", "verbe-sujet"),
            ("chaque / tout", "totalité"),
            ("plusieurs / certains / aucun", "quantité"),
        ],
        fill_item=("___ -je entrer ?", "Puis"),
        words=["Aucun", "bus", "ne", "passe", "."],
        anagram=("certains", "Pas tous les jours : … jours seulement, c'est calme."),
        error=(
            "Est-ce que travaillez-vous chaque matin ?",
            "Est-ce que vous travaillez chaque matin ?",
            "On choisit est-ce que OU l'inversion, pas les deux.",
        ),
        pic_start=27,
        pic_words=["un tampon", "une poignée", "une étoile", "une offre"],
        short_p="Écrivez quatre questions (2 est-ce que, 2 inversions) et quatre indéfinis.",
        audio="Enregistrez les modèles, puis trois questions à vous.",
    ),
    _l(
        "PE",
        "PE — Ma feuille d'entretien",
        "Écrire des questions formelles et des réponses avec des indéfinis.",
        "Imitez la feuille de Dieudonné.",
        "Feuille de Dieudonné Hakizimana",
        """Dieudonné Hakizimana
Est-ce que vous connaissez l'atelier ?
Avez-vous déjà plié un coupon ?
Travaillez-vous chaque matin ?
Plusieurs commandes attendent. Certains tissus sont fragiles.
Aucun outil ne sort sans note.
Tout le monde range avant midi.
Puis-je compter sur vous ?
Dieudonné
Atelier du Tissu""",
        tf_item=(
            "Dieudonné autorise de sortir les outils sans note.",
            False,
            "« Aucun outil ne sort sans note. »",
        ),
        qcm_item=(
            "Quelle question est une inversion avec je ?",
            [
                "Est-ce que vous connaissez l'atelier",
                "Avez-vous déjà plié un coupon",
                "Puis-je compter sur vous",
                "Tout le monde range",
            ],
            2,
            "Puis-je…",
        ),
        pairs=[
            ("est-ce que vous connaissez", "atelier"),
            ("avez-vous déjà plié", "coupon"),
            ("chaque matin", "rythme"),
            ("aucun outil", "règle"),
        ],
        fill_item=("___ outil ne sort sans note.", "Aucun"),
        words=["Avez-vous", "déjà", "plié", "un", "coupon", "?"],
        anagram=("aucun", "Zéro outil dehors : … outil ne sort sans note."),
        error=(
            "Est-ce que avez-vous déjà plié un coupon ?",
            "Avez-vous déjà plié un coupon ?",
            "Pas d'est-ce que + inversion ensemble.",
        ),
        pic_start=28,
        pic_words=["une poignée", "une étoile", "une offre", "un CV"],
        short_p="Imitez : sept lignes, trois questions formelles, trois indéfinis.",
        audio="Lisez votre feuille, sans aller trop vite.",
    ),
    _l(
        "EL",
        "EL — Questions et indéfinis",
        "Retenir est-ce que, l'inversion simple, et chaque / tout / plusieurs / certains / aucun.",
        "Apprenez la fiche.",
        "Fiche d'Aline",
        """Question formelle :
est-ce que + sujet + verbe : Est-ce que vous êtes prêt ?
inversion : verbe + sujet : Avez-vous un exemple ? Travaillez-vous ?
Puis-je (pas peux-je, peu usité). Qu'avez-vous appris ?
On n'empile pas : est-ce que avez-vous… (incorrect).
Indéfinis : chaque (singulier) ; tout / toute / tous / toutes ;
plusieurs (pluriel) ; certains / certaines ; aucun / aucune + ne.
Chaque matin. Tout le monde. Plusieurs ateliers.
Certains jours. Aucun retard. Aucune expérience n'est inutile.""",
        tf_item=(
            "On peut dire « est-ce que avez-vous ».",
            False,
            "Une seule forme à la fois.",
        ),
        qcm_item=(
            "« Aucun » s'accorde comment avec « expérience » ?",
            ["aucun expérience", "aucune expérience", "aucuns expériences", "aucune expériences"],
            1,
            "Aucune + nom féminin singulier.",
        ),
        pairs=[
            ("est-ce que", "forme longue"),
            ("inversion", "forme courte"),
            ("chaque / tout", "totalité"),
            ("aucun / aucune", "zéro + ne"),
        ],
        fill_item=("___ expérience n'est inutile. (zéro, fém.)", "Aucune"),
        words=["Travaillez-vous", "chaque", "matin", "?"],
        anagram=("inversion", "Avez-vous : le verbe passe devant le sujet, cette…"),
        error=(
            "Aucun expériences ne sont inutiles.",
            "Aucune expérience n'est inutile.",
            "Aucune + singulier. Ne… pas de pluriel ici.",
        ),
        pic_start=29,
        pic_words=["une étoile", "une offre", "un CV", "une qualité"],
        short_p="Rédigez six questions formelles et une phrase pour chaque indéfini.",
        audio="Enregistrez la fiche, puis un mini-entretien de six répliques.",
    ),
]


SEQUENCES = [
    {"title": "Une offre à saisir", "lessons": S1},
    {"title": "Se présenter professionnellement", "lessons": S2},
    {"title": "Proposer un service", "lessons": S3},
    {"title": "Oser un choix", "lessons": S4},
    {"title": "Un parcours à raconter", "lessons": S5},
    {"title": "Répondre avec assurance", "lessons": S6},
]
