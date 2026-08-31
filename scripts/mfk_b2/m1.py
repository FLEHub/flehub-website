"""B2 Module 1 — Tendances du Seuil (univers Seuil des Sources)."""

from factory import L

IMG = "mfk-b2-m1"
IMG_DIR = IMG

MODULE = {
    "title": "B2 — Tendances du Seuil",
    "description": (
        "Grande étape B2-1 : analyser une mode, interroger une consommation, "
        "opposer des vacances, introduire un texte explicatif, débattre sous "
        "le figuier et signer une chronique pour Radio Figuier — Rose Iradukunda "
        "coupe un tissu à la Salle des Herbes, Félicie compare le Marché des "
        "Lampions au Marché des Herbes, Lila Sow tend le micro, et le Seuil des "
        "Sources (Rukiri-Nord) discute de ce qui passe et de ce qui reste."
    ),
}


def _l(comp, title, obj, cons, st, sp, **kw):
    return L(IMG, comp, title, obj, cons, st, sp, **kw)


# ---------------------------------------------------------------------------
# Séquence 1 — Mode et apparence (participe présent / adjectif verbal, ayant fini)
# ---------------------------------------------------------------------------

S1 = [
    _l(
        "CO",
        "CO — Un tissu convaincant, des lanternes fatiguantes",
        "Distinguer participe présent et adjectif verbal ; repérer le participe composé d'antériorité.",
        "Lisez l'entretien (à écouter avec l'enseignant). Qui parle d'une action, qui parle d'une qualité ?",
        "Entretien sous le figuier, lanternes du soir",
        """Lila Sow : Rose, votre tissu convainc-t-il encore, ou convainc-t-il trop ?
Rose Iradukunda : Ayant fini l'ourlet ce matin, je peux dire : le tissu est convaincant, pas seulement convainquant les passants.
Aline Uwase : Attention : convainquant décrit l'action ; convaincant, la qualité. Les deux ne s'écrivent pas pareil.
Patrick Habimana : Ces lanternes sont fatigantes à porter, alors que les coudre n'est pas fatiguant si l'on s'arrête.
Léa Niyonzima : Étant partie avant midi, Hawa n'a pas vu le premier essayage. Antériorité : elle était déjà loin.
Marc Nkurunziza : Une mode provocante n'est pas une mode provoquant un scandale : l'une juge, l'autre agit.
Hawa Diallo : Je trouve les arguments de Rose convaincants. J'entends le c, pas le qu.
Joël Mugisha : Ayant choisi le lin ocre, elle refuse le plastique brillant du Marché des Lampions.
Solange Mukamana : Une coupe naviguant entre deux rives reste plus intéressante qu'un modèle trop navigant, trop sage.
Karim Bamba : Analysons : qui porte, qui vend, qui copie. Une tendance n'est pas un ordre.
Félicie : Les lanternes du figuier éclairent le tissu ; le tissu n'éclaire pas forcément les lanternes.
Dieudonné : Moi, je répare. Une couture fatiguant les doigts n'est pas forcément une mode fatigante à voir.
Yvette : Lila, gardez le micro : le Seuil a besoin d'un avis, pas d'un défilé muet.
Mado : Sami dira ce soir si le lin convainc les anciens autant que les plus jeunes.""",
        tf_item=(
            "Rose emploie « convaincant » pour la qualité du tissu, et « convainquant » pour l'action sur les passants.",
            True,
            "Rose oppose la qualité (convaincant) et l'action (convainquant les passants).",
        ),
        qcm_item=(
            "Selon Aline, quelle distinction faut-il retenir ?",
            [
                "Les deux formes s'écrivent toujours pareil",
                "Convainquant décrit l'action, convaincant la qualité",
                "Le participe composé est interdit sous le figuier",
                "Fatigant et fatiguant n'existent pas",
            ],
            1,
            "Aline : convainquant = action ; convaincant = qualité.",
        ),
        pairs=[
            ("convainquant", "action, invariable"),
            ("convaincant", "qualité, accord"),
            ("ayant fini", "antériorité, avoir"),
            ("étant partie", "antériorité, être"),
        ],
        fill_item=("Ayant ___ l'ourlet, Rose peut parler. (finir)", "fini"),
        words=["Le", "tissu", "est", "convaincant", "ce", "soir", "."],
        anagram=("convaincant", "Adjectif : un argument qui emporte l'adhésion, avec un c."),
        error=(
            "Ayant fini l'ourlet, Rose rangea le lin, et cette coupe est convainquant.",
            "Ayant fini l'ourlet, Rose rangea le lin, et cette coupe est convaincante.",
            "Adjectif verbal : convaincant s'accorde (convaincante).",
        ),
        pic_start=0,
        pic_words=["une mode", "un participe", "un adjectif", "un tissu"],
        short_p="Relevez trois participes présents et trois adjectifs verbaux, puis une forme ayant / étant + participe.",
        audio="Enregistrez : Ayant fini l'ourlet, je range. Le tissu est convaincant. Les lanternes sont fatigantes.",
    ),
    _l(
        "CE",
        "CE — Analyser une mode au Seuil",
        "Lire un article qui analyse une tendance (tissu, lanternes) et les formes en -ant.",
        "Lisez l'article épinglé à la Salle des Herbes, sans aller trop vite.",
        "Article de Mado, Cahier du chemin",
        """Analyser une mode, ce n'est pas l'adorer.
Rose Iradukunda coupe, à la Salle des Herbes, un lin ocre qui traverse le Seuil des Sources.
Ayant fini trois ourlets avant l'aube, elle a pu comparer le tissu aux lanternes du soir.
Ces lanternes, fatiguant les bras de Joël, restent pourtant moins fatigantes à regarder qu'un plastique trop brillant.
Une mode convainquant les passants du Marché des Lampions n'est pas forcément une mode convaincante pour Karim.
Il faut distinguer l'action (participe présent, invariable) et la qualité (adjectif verbal, accordé).
Étant rentrée de Rive-des-Saules, Léa a noté : le même lin paraît plus calme sous le figuier qu'au Pavillon du Saule.
Marc écrit que le Seuil n'importe pas une tendance : il la discute.
Solange ajoute qu'une coupe provocante peut rester juste, si elle ne cherche pas seulement à provoquer.
Lila Sow relira ce texte à Radio Figuier : analyser, ce n'est pas condamner.
Félicie, elle, regarde les mains : une couture fatiguant les doigts mérite un salaire, pas seulement un compliment.
Yvette rappelle qu'une lanterne n'est pas un bijou ; c'est un outil de soirée, un signal.
Sami, plus prudent, demande : qui copie qui, et pour quel marché ?
Nous tiendrons ce débat jeudi, ayant lu ce cahier, pas en le feuilletant trop vite.""",
        tf_item=(
            "L'article dit qu'analyser une mode, c'est l'adorer.",
            False,
            "Première ligne : analyser, ce n'est pas l'adorer.",
        ),
        qcm_item=(
            "Que rappelle Yvette au sujet des lanternes ?",
            [
                "Qu'elles valent un bijou de Lampe-Figue",
                "Qu'elles sont interdites sous le figuier",
                "Qu'une lanterne est un outil de soirée, un signal",
                "Que Rose refuse toutes les lanternes",
            ],
            2,
            "Yvette : une lanterne n'est pas un bijou ; c'est un outil, un signal.",
        ),
        pairs=[
            ("fatiguant les bras", "participe présent"),
            ("moins fatigantes", "adjectif verbal"),
            ("étant rentrée", "antériorité, être"),
            ("ayant lu", "antériorité, avoir"),
        ],
        fill_item=("Une mode ___ les passants n'est pas forcément convaincante. (convaincre, p. présent)", "convainquant"),
        words=["Ayant", "fini", "trois", "ourlets", "elle", "compare", "."],
        anagram=("fatiguant", "Participe : une couture qui lasse les bras, avec un u."),
        error=(
            "Les lanternes sont fatiguantes à regarder, et Joël les porte encore.",
            "Les lanternes sont fatigantes à regarder, et Joël les porte encore.",
            "Adjectif verbal : fatigant, sans u ; fatiguant est le participe.",
        ),
        pic_start=1,
        pic_words=["un participe", "un adjectif", "un tissu", "une assiette"],
        short_p="Soulignez cinq formes en -ant et classez-les : action ou qualité.",
        audio="Lisez l'article, sans aller trop vite.",
    ),
    _l(
        "PO",
        "PO — Dire ayant fini, étant partie, convaincant",
        "Prononcer le participe composé et opposer à l'oral action et qualité.",
        "Répétez les modèles, puis analysez une mode que vous voyez au Seuil.",
        "Modèles d'Aline et de Rose, banc du figuier",
        """Ayant fini l'ourlet, je range les ciseaux.
Étant partie tôt, Hawa n'a pas vu l'essayage.
Ce tissu est convaincant : il emporte l'adhésion.
Cette coupe, convainquant les passants, reste simple.
Les lanternes sont fatigantes à porter le soir.
Porter les lanternes, fatiguant les bras, demande un relais.
Une mode provocante n'est pas forcément une mode provoquant la colère.
Ayant choisi le lin, Rose refuse le plastique.
Étant rentrée, Léa compare les deux rives.
Il faut un avis, pas un silence.
Je serai prête jeudi, ayant relu mes notes.
Patrick : le participe présent ne s'accorde pas.
Rose : l'adjectif verbal, lui, s'accorde.
Lila : gardez ces phrases pour le micro, clairement.""",
        tf_item=(
            "Le participe présent s'accorde avec le nom comme un adjectif.",
            False,
            "Patrick : le participe présent ne s'accorde pas.",
        ),
        qcm_item=(
            "Quelle phrase marque l'antériorité avec être ?",
            [
                "Ce tissu est convaincant",
                "Ayant fini l'ourlet, je range",
                "Étant partie tôt, Hawa n'a pas vu l'essayage",
                "Les lanternes sont fatigantes",
            ],
            2,
            "Étant partie : être + participe, action déjà faite.",
        ),
        pairs=[
            ("ayant fini", "j'ai déjà fini"),
            ("étant partie", "elle était déjà partie"),
            ("convaincant", "qualité"),
            ("convainquant", "action"),
        ],
        fill_item=("Étant ___ tôt, Hawa n'a pas vu l'essayage. (partir, fém.)", "partie"),
        words=["Ayant", "choisi", "le", "lin", "Rose", "refuse", "."],
        anagram=("ayant", "Forme en -ant de avoir, suivie d'un participe, pour l'avant."),
        error=(
            "Étant parti trop tôt, Hawa a manqué l'essayage, et le lin reste ocre.",
            "Étant partie trop tôt, Hawa a manqué l'essayage, et le lin reste ocre.",
            "Avec être, le participe s'accorde : Hawa → partie.",
        ),
        pic_start=2,
        pic_words=["un adjectif", "un tissu", "une assiette", "une consommation"],
        short_p="Écrivez six phrases : trois ayant / étant + participe, trois oppositions action / qualité.",
        audio="Enregistrez les huit premiers modèles, puis deux analyses à vous.",
    ),
    _l(
        "PE",
        "PE — Mon analyse d'une mode",
        "Écrire une courte analyse de tendance avec participes et adjectifs verbaux.",
        "Imitez la note de Rose Iradukunda.",
        "Note de Rose, Salle des Herbes",
        """Rose Iradukunda — Seuil des Sources, Rukiri-Nord
Ayant fini l'ourlet du lin ocre, je peux comparer sans me hâter.
Cette coupe est convaincante pour le jeudi, pas seulement convainquant les passants du Marché des Lampions.
Les lanternes, fatiguant les bras de Joël, restent moins fatigantes à voir qu'un plastique trop lisse.
Étant rentrée de Val-des-Peupliers, Léa m'a dit que le même tissu change de voix sous le saule.
Je refuse une mode provocante qui ne ferait que provoquer, sans habiller personne.
Il faut un salaire pour les doigts, pas seulement un compliment pour l'œil.
Karim demandera qui copie qui ; j'aurai déjà noté trois réponses.
Je serai au banc, ayant relu ces lignes, si Lila ouvre le micro.
Une tendance n'est pas un ordre : on l'analyse, on ne l'obéit pas.
Félicie apportera un bol ; Dieudonné un relais pour les lanternes.
Voilà mon avis, ni trop doux, ni trop dur.
Rose""",
        tf_item=(
            "Rose écrit qu'une tendance est un ordre auquel on obéit.",
            False,
            "« Une tendance n'est pas un ordre : on l'analyse, on ne l'obéit pas. »",
        ),
        qcm_item=(
            "Que refuse Rose ?",
            [
                "Le lin ocre",
                "Une mode provocante qui ne ferait que provoquer",
                "Le bol de Félicie",
                "Le micro de Lila",
            ],
            1,
            "Elle refuse une mode qui provoque sans habiller.",
        ),
        pairs=[
            ("ayant fini", "pouvoir comparer"),
            ("convaincante", "qualité de la coupe"),
            ("fatiguant les bras", "action"),
            ("étant rentrée", "Léa"),
        ],
        fill_item=("Cette coupe est ___ pour le jeudi. (convaincant, fém.)", "convaincante"),
        words=["Une", "tendance", "n'est", "pas", "un", "ordre", "."],
        anagram=("lanternes", "Lumières de papier accrochées le soir au Seuil."),
        error=(
            "Je serais au banc jeudi dès que j'aurai relu ces lignes, et Lila ouvrira le micro.",
            "Je serai au banc jeudi dès que j'aurai relu ces lignes, et Lila ouvrira le micro.",
            "Futur réel : je serai, pas le conditionnel je serais.",
        ),
        pic_start=3,
        pic_words=["un tissu", "une assiette", "une consommation", "un marché"],
        short_p="Imitez : douze lignes, deux formes ayant / étant, deux paires action / qualité.",
        audio="Lisez votre analyse, sans aller trop vite.",
    ),
    _l(
        "EL",
        "EL — Participe présent, adjectif verbal, ayant fini",
        "Retenir l'orthographe, l'accord et l'antériorité des formes en -ant.",
        "Apprenez la fiche.",
        "Fiche d'Aline Uwase, banc ocre",
        """Participe présent : invariable, valeur de verbe (action).
nous convainquons → convainquant ; nous fatiguons → fatiguant ; nous provoquons → provoquant.
Adjectif verbal : s'accorde, valeur de qualité ; parfois autre orthographe.
convaincant(e)(s), fatigant(e)(s), provocant(e)(s), différent(e)(s).
Une mode convainquant les passants / un argument convaincant.
Une couture fatiguant les bras / une soirée fatigante.
Participe composé (antériorité) : ayant + participe passé (avoir) ; étant + participe passé (être).
Ayant fini l'ourlet, Rose range. Étant partie, Hawa n'a rien vu.
Ayant / étant se placent souvent en tête, suivis d'une virgule.
Ne pas écrire : cette mode est convainquant (accord manquant).
Ne pas écrire : les lanternes sont fatiguantes (u du verbe, ici c'est l'adjectif).
Analyser une mode : qui porte, qui vend, qui copie, qui paie les mains.
Tissu de Rose, lanternes du figuier, Salle des Herbes : le Seuil discute, il n'obéit pas.
Il faut un exemple de chaque forme, pas seulement une liste morte.""",
        tf_item=(
            "L'adjectif verbal reste toujours invariable.",
            False,
            "L'adjectif verbal s'accorde ; le participe présent, lui, est invariable.",
        ),
        qcm_item=(
            "Quelle forme marque l'antériorité avec avoir ?",
            [
                "étant partie",
                "convaincant",
                "ayant fini",
                "fatigantes",
            ],
            2,
            "Ayant + participe passé.",
        ),
        pairs=[
            ("convainquant", "nous convainquons"),
            ("convaincant", "qualité, accord"),
            ("ayant fini", "antériorité avoir"),
            ("étant partie", "antériorité être"),
        ],
        fill_item=("Une soirée ___ n'est pas une couture fatiguant les bras. (fatigant, fém.)", "fatigante"),
        words=["Ayant", "fini", "l'ourlet", "Rose", "range", "."],
        anagram=("ourlets", "Bords de vêtement que l'on coud pour achever une pièce."),
        error=(
            "Il fautons distinguer l'action et la qualité, et Rose a déjà fini l'ourlet.",
            "Il faut distinguer l'action et la qualité, et Rose a déjà fini l'ourlet.",
            "Toujours il faut, à la 3e personne.",
        ),
        pic_start=4,
        pic_words=["une assiette", "une consommation", "un marché", "une horloge"],
        short_p="Dressez un tableau : six paires participe / adjectif, plus quatre phrases ayant / étant.",
        audio="Enregistrez la fiche, puis quatre phrases d'analyse.",
    ),
]


# ---------------------------------------------------------------------------
# Séquence 2 — Tendance alimentaire (futur antérieur, consommation)
# ---------------------------------------------------------------------------

S2 = [
    _l(
        "CO",
        "CO — Le bol de Félicie, deux marchés",
        "Repérer le futur antérieur et les arguments sur la consommation.",
        "Lisez le débat (à écouter avec l'enseignant). Quand l'action sera-t-elle déjà finie ?",
        "Débat à la Table des Sources, bols ocre",
        """Félicie : Quand j'aurai fini ce bol, je le laverai moi-même. Pas de pile pour plus tard.
Karim Bamba : Dès que le Marché des Lampions aura fermé, le Marché des Herbes ouvrira encore une heure.
Aline Uwase : Une fois que vous aurez comparé les prix, vous parlerez de goût, pas seulement d'argent.
Léa Niyonzima : Je mangerai sous le figuier quand Patrick aura choisi les feuilles, pas avant.
Patrick Habimana : Si je prends trop vite, je n'aurai rien compris au bol. Il faut du temps.
Marc Nkurunziza : Contrairement au plastique des Lampions, les herbes se nomment, se pèsent, se discutent.
Hawa Diallo : Lorsque nous aurons goûté les deux marchés, nous pourrons voter, pas seulement crier.
Joël Mugisha : Je ferai la file aux Herbes dès que j'aurai posé les lanternes.
Rose Iradukunda : Une consommation convaincante n'est pas une consommation qui convainc par le bruit.
Solange Mukamana : Lila, quand tu auras enregistré ces voix, tu couperas les insultes, pas les doutes.
Lila Sow : Radio Figuier relayera le débat lorsque Félicie aura parlé jusqu'au fond du bol.
Dieudonné : Moi, je réparerai la table une fois que vous aurez fini de taper dessus.
Yvette : Il faut un prix juste. Quand le Seuil aura payé les mains, il pourra parler de tendance.
Sami : Les anciens diront, après que nous aurons écouté, si le bol ressemble encore à celui d'autrefois.""",
        tf_item=(
            "Félicie lavera le bol avant de l'avoir fini.",
            False,
            "Quand j'aurai fini ce bol, je le laverai : d'abord finir, ensuite laver.",
        ),
        qcm_item=(
            "Que fera Karim dès que le Marché des Lampions aura fermé ?",
            [
                "Il fermera aussi le Marché des Herbes",
                "Le Marché des Herbes ouvrira encore une heure",
                "Il interdira les bols",
                "Il partira à Val-des-Peupliers",
            ],
            1,
            "Karim : le Marché des Herbes ouvrira encore une heure.",
        ),
        pairs=[
            ("quand j'aurai fini", "ensuite je laverai"),
            ("dès que … aura fermé", "l'autre marché continue"),
            ("une fois que vous aurez comparé", "ensuite le goût"),
            ("lorsque nous aurons goûté", "ensuite voter"),
        ],
        fill_item=("Quand j'___ fini ce bol, je le laverai. (avoir, FA)", "aurai"),
        words=["Quand", "j'aurai", "fini", "je", "laverai", "le", "bol", "."],
        anagram=("consommation", "Façon d'acheter et de manger, discutée aux deux marchés."),
        error=(
            "Quand j'aurai fini le bol, je le laverai, et je ferrai la file aux Herbes.",
            "Quand j'aurai fini le bol, je le laverai, et je ferai la file aux Herbes.",
            "Futur de faire : je ferai, un seul r.",
        ),
        pic_start=5,
        pic_words=["une consommation", "un marché", "une horloge", "des vacances"],
        short_p="Notez cinq futur antérieurs et l'action qui vient après chacun.",
        audio="Enregistrez : Quand j'aurai fini ce bol, je le laverai. Dès que le marché aura fermé, je rentrerai.",
    ),
    _l(
        "CE",
        "CE — Manger après avoir choisi",
        "Lire un article sur la consommation au Seuil et le futur antérieur.",
        "Lisez la chronique du Marché des Herbes, sans aller trop vite.",
        "Chronique de Lila Sow, Radio Figuier",
        """On ne parle pas d'un bol comme on parle d'une mode : on l'épuise, ou on le respecte.
Félicie sert, chaque matin, un plat dont le nom change selon les bottes du Marché des Herbes.
Ce marché-là n'existe sur aucune carte officielle : le Seuil l'a inventé, entre le figuier et la Salle des Herbes.
Le Marché des Lampions, lui, brille plus tôt et ferme plus vite ; il vend aussi des feuilles, mais trop emballées.
Quand les Lampions auront fermé, les Herbes auront encore des voix, des balances, des doutes.
Il faut avoir comparé les deux files avant de crier à la trahison.
Dès que le Seuil aura payé le juste prix, il pourra parler de « tendance alimentaire » sans rougir.
Une fois que vous aurez goûté le bol, vous direz s'il console ou s'il montre.
Marc Nkurunziza écrit que consommer, ce n'est pas collectionner des assiettes.
Aline rappelle le futur antérieur : l'action sera déjà faite quand l'autre commencera.
Joël, lorsqu'il aura posé la dernière lanterne, s'assiéra ; pas avant.
Léa et Patrick iront à Rive-des-Saules seulement quand ils auront laissé un mot à Félicie.
Yvette note les estomacs sensibles : une tendance n'excuse pas une indigestion.
Nous jugerons jeudi, lorsque nous aurons fini d'écouter, pas lorsque nous aurons fini de nous interrompre.""",
        tf_item=(
            "Le Marché des Herbes figure sur les cartes officielles de Rukiri-Nord.",
            False,
            "Le Seuil l'a inventé ; il n'existe sur aucune carte officielle.",
        ),
        qcm_item=(
            "Quand Joël s'assiéra-t-il, selon la chronique ?",
            [
                "Avant d'avoir posé les lanternes",
                "Lorsqu'il aura posé la dernière lanterne",
                "Seulement à Val-des-Peupliers",
                "Jamais, par principe",
            ],
            1,
            "Lorsqu'il aura posé la dernière lanterne, il s'assiéra ; pas avant.",
        ),
        pairs=[
            ("quand … auront fermé", "les Herbes continuent"),
            ("dès que … aura payé", "ensuite parler"),
            ("une fois que vous aurez goûté", "ensuite dire"),
            ("lorsque nous aurons fini", "ensuite juger"),
        ],
        fill_item=("Dès que le Seuil ___ payé le juste prix, il pourra parler. (avoir, FA)", "aura"),
        words=["Une", "fois", "que", "vous", "aurez", "goûté", "parlez", "."],
        anagram=("herbes", "Végétaux du marché inventé, pas seulement ceux du jardin."),
        error=(
            "Quand je finirai le bol, je le laverai déjà, et Félicie rangera les cuillères.",
            "Quand j'aurai fini le bol, je le laverai déjà, et Félicie rangera les cuillères.",
            "Antériorité au futur : quand j'aurai fini, pas quand je finirai.",
        ),
        pic_start=6,
        pic_words=["un marché", "une horloge", "des vacances", "une opposition"],
        short_p="Recopiez quatre phrases au futur antérieur et dites l'action qui suit.",
        audio="Lisez la chronique, sans aller trop vite.",
    ),
    _l(
        "PO",
        "PO — Dire quand j'aurai fini",
        "Employer à l'oral le futur antérieur avec quand, dès que, une fois que, lorsque.",
        "Répétez, puis parlez d'un repas que vous ne commencerez qu'après un choix.",
        "Modèles de Félicie et d'Aline",
        """Quand j'aurai fini ce bol, je le laverai.
Dès que le marché aura fermé, je rentrerai sous le figuier.
Une fois que tu auras goûté, tu diras le vrai, pas le poli.
Lorsque nous aurons comparé les deux files, nous voterons.
Après que vous aurez payé, vous pourrez critiquer le prix.
Je n'ouvrirai pas l'assiette avant d'avoir choisi.
Nous serons calmes lorsque la balance aura parlé.
Tu auras compris le bol seulement quand tu l'auras fini.
Ils partiront à Rive-des-Saules dès qu'ils auront laissé un mot.
Je ferai la file aux Herbes, pas aux Lampions trop vite.
Je pourrai juger seulement lorsque j'aurai écouté Yvette.
Félicie : le futur antérieur, c'est « déjà fait » dans le futur.
Aline : pas de pile pour plus tard, pas de jugement trop tôt.
Lila : dites-le au micro, une phrase, une pause.""",
        tf_item=(
            "« Quand j'aurai fini » place la fin du bol avant le lavage.",
            True,
            "Futur antérieur : action déjà accomplie avant l'autre.",
        ),
        qcm_item=(
            "Quelle phrase est au futur antérieur ?",
            [
                "Je lave le bol",
                "Je laverai le bol",
                "Quand j'aurai fini ce bol, je le laverai",
                "J'ai fini ce bol",
            ],
            2,
            "J'aurai fini = avoir au futur + participe.",
        ),
        pairs=[
            ("quand j'aurai fini", "ensuite laver"),
            ("dès que … aura fermé", "ensuite rentrer"),
            ("une fois que tu auras goûté", "ensuite dire"),
            ("lorsque nous aurons comparé", "ensuite voter"),
        ],
        fill_item=("Une fois que tu ___ goûté, tu diras le vrai. (avoir, FA)", "auras"),
        words=["Dès", "que", "le", "marché", "aura", "fermé", "je", "rentrerai", "."],
        anagram=("aurons", "Forme de avoir au futur, personne nous, avant un participe."),
        error=(
            "Lorsque nous aurons comparé les files, nous pourai voter sans crier.",
            "Lorsque nous aurons comparé les files, nous pourrons voter sans crier.",
            "Futur de pouvoir : nous pourrons, deux r.",
        ),
        pic_start=7,
        pic_words=["une horloge", "des vacances", "une opposition", "une concession"],
        short_p="Écrivez huit phrases : quand / dès que / une fois que / lorsque + futur antérieur.",
        audio="Enregistrez les six premiers modèles, puis deux phrases à vous.",
    ),
    _l(
        "PE",
        "PE — Ma note de consommation",
        "Écrire une note argumentée sur un bol, deux marchés et le futur antérieur.",
        "Imitez la note de Félicie.",
        "Note de Félicie, Marché des Herbes",
        """Félicie — Seuil des Sources, derrière la Salle des Herbes
Quand j'aurai fini de servir, je m'assiérai. Pas avant, pas sur le comptoir des Lampions.
Le Marché des Herbes n'a pas de tampon officiel ; il a des balances et des noms.
Dès que les Lampions auront fermé leur bruit, nos feuilles parleront plus clairement.
Une fois que vous aurez goûté le bol, vous direz s'il console ou s'il montre trop.
Il faut un prix qui tienne les mains, pas seulement l'œil.
Je ferai la soupe de jeudi lorsque Léa aura laissé son mot pour Rive-des-Saules.
Patrick aura compris le goût seulement quand il aura fini, lentement.
Yvette veillera : une tendance n'excuse pas une indigestion.
Lila, quand tu auras coupé les insultes, tu pourras garder les doutes.
Karim demandera qui invente le marché ; je répondrai : ceux qui pèsent.
Je serai là, ayant déjà lavé le bol, si le Seuil veut encore un avis.
Félicie""",
        tf_item=(
            "Félicie s'assiéra avant d'avoir fini de servir.",
            False,
            "Quand j'aurai fini de servir, je m'assiérai. Pas avant.",
        ),
        qcm_item=(
            "Que répondra Félicie à Karim, qui demande qui invente le marché ?",
            [
                "Radio Figuier seulement",
                "Ceux qui pèsent",
                "Val-des-Peupliers",
                "Personne",
            ],
            1,
            "« je répondrai : ceux qui pèsent. »",
        ),
        pairs=[
            ("quand j'aurai fini", "ensuite s'asseoir"),
            ("dès que … auront fermé", "les feuilles parlent"),
            ("une fois que vous aurez goûté", "ensuite dire"),
            ("lorsque Léa aura laissé", "ensuite la soupe"),
        ],
        fill_item=("Je ferai la soupe lorsque Léa ___ laissé son mot. (avoir, FA)", "aura"),
        words=["Je", "serai", "là", "ayant", "déjà", "lavé", "le", "bol", "."],
        anagram=("lampions", "Lumières du marché du soir, plus emballées que les feuilles."),
        error=(
            "Dès que les Lampions auront fermé, je pourai parler plus clairement, et le bol attendra.",
            "Dès que les Lampions auront fermé, je pourrai parler plus clairement, et le bol attendra.",
            "Futur de pouvoir : je pourrai, deux r.",
        ),
        pic_start=8,
        pic_words=["des vacances", "une opposition", "une concession", "une valise"],
        short_p="Imitez : douze lignes, quatre futur antérieurs, un avis sur les deux marchés.",
        audio="Lisez votre note, sans aller trop vite.",
    ),
    _l(
        "EL",
        "EL — Futur antérieur et consommation",
        "Retenir la formation et les emplois du futur antérieur.",
        "Apprenez la fiche.",
        "Fiche d'Aline, horloge de la Salle des Herbes",
        """Futur antérieur = avoir / être au futur + participe passé.
j'aurai fini, tu auras goûté, elle aura fermé, nous aurons comparé, vous aurez payé, ils auront voté.
Avec être : je serai rentrée, nous serons partis (accord).
Emplois : action déjà accomplie dans le futur, souvent après quand, dès que, une fois que, lorsque, après que.
Quand j'aurai fini le bol, je le laverai. (d'abord finir, ensuite laver)
Ne pas dire : quand je finirai le bol, je le laverai déjà — on veut l'antériorité.
Ne pas confondre je serai (futur) et je serais (conditionnel).
Ne pas écrire je ferrai (un r : je ferai) ni je pourai (deux r : je pourrai).
Consommation au Seuil : Marché des Herbes (inventé, balances, noms) / Marché des Lampions (bruit, emballages).
Bol de Félicie : servir, goûter, laver, payer les mains.
Une tendance alimentaire n'excuse pas un prix injuste ni une indigestion.
Il faut avoir comparé avant de crier.
Radio Figuier relayera lorsque Lila aura coupé les insultes, pas les doutes.
Le futur antérieur sert l'argument : on ne juge pas trop tôt.""",
        tf_item=(
            "On forme le futur antérieur avec avoir ou être au futur, plus un participe passé.",
            True,
            "j'aurai fini / je serai rentrée.",
        ),
        qcm_item=(
            "Quelle forme est correcte pour un futur réel ?",
            [
                "je serais prêt demain",
                "je serai prêt demain",
                "je suis prêt demain uniquement",
                "je serais été prêt",
            ],
            1,
            "Futur de être : je serai.",
        ),
        pairs=[
            ("quand j'aurai fini", "ensuite une autre action"),
            ("je serai", "futur"),
            ("je serais", "conditionnel"),
            ("je ferai / je pourrai", "1 r / 2 r"),
        ],
        fill_item=("Nous ___ comparé les deux files avant de voter. (avoir, FA)", "aurons"),
        words=["Quand", "j'aurai", "fini", "je", "jugerai", "."],
        anagram=("horloge", "Objet qui rappelle qu'une action sera déjà faite avant l'autre."),
        error=(
            "Quand j'aurai fini le bol je le laverai, et je serais prêt pour le jeudi réel.",
            "Quand j'aurai fini le bol je le laverai, et je serai prêt pour le jeudi réel.",
            "Projet réel : je serai, pas je serais.",
        ),
        pic_start=9,
        pic_words=["une opposition", "une concession", "une valise", "une conjonction"],
        short_p="Conjuguez six verbes au futur antérieur et écrivez quatre phrases avec quand / dès que.",
        audio="Enregistrez la fiche, puis cinq phrases au futur antérieur.",
    ),
]


# ---------------------------------------------------------------------------
# Séquence 3 — Vacances et pratiques sociales (opposition et concession)
# ---------------------------------------------------------------------------

S3 = [
    _l(
        "CO",
        "CO — Partir ou rester, pourtant le jeudi",
        "Repérer opposition (alors que, tandis que, contrairement à) et concession (bien que, pourtant, néanmoins, quoi que).",
        "Lisez le débat. Qui oppose deux pratiques, qui concède sans céder ?",
        "Débat sous le figuier, valises à peine fermées",
        """Léa Niyonzima : Alors que Patrick rêve déjà de Rive-des-Saules, moi je tiens encore au banc ocre.
Patrick Habimana : Tandis que tu comptes les jeudis, je compte les jours de pont et d'eau.
Aline Uwase : Contrairement à une fuite, des vacances se préparent : dates, clés, mots.
Marc Nkurunziza : Bien que ce soit tentant, partir n'efface pas le Seuil ; ça le déplace.
Hawa Diallo : Quoi que vous décidiez, Radio Figuier reliera les voix.
Joël Mugisha : Pourtant les lanternes auront besoin d'un relais, même en août.
Rose Iradukunda : Néanmoins je coudrai : les vacances des uns sont le travail des autres.
Solange Mukamana : On peut aimer Val-des-Peupliers tout en refusant d'idéaliser le Pavillon du Saule.
Karim Bamba : Alors que le Marché des Lampions s'emballe, le figuier reste un rythme.
Lila Sow : Bien qu'il fasse chaud, nous enregistrerons le matin, pas à midi.
Félicie : Je resterai. Pourtant je ne juge pas ceux qui plient une valise.
Dieudonné : Tandis que certains partent, je répare les bancs : concession n'est pas défaite.
Yvette : Contrairement aux affiches trop gaies, un repos se mérite, il ne s'achète pas en trois mots.
Sami : Quoi que le Seuil invente comme « tendance des vacances », les anciens demanderont qui garde la cour.""",
        tf_item=(
            "Marc dit que partir efface complètement le Seuil.",
            False,
            "Bien que ce soit tentant, partir n'efface pas le Seuil ; ça le déplace.",
        ),
        qcm_item=(
            "Quelle conjonction de concession emploie Hawa ?",
            [
                "alors que",
                "tandis que",
                "contrairement à",
                "quoi que",
            ],
            3,
            "Hawa : Quoi que vous décidiez…",
        ),
        pairs=[
            ("alors que / tandis que", "opposition"),
            ("contrairement à", "opposition nominale"),
            ("bien que / quoi que", "concession + subjonctif"),
            ("pourtant / néanmoins", "concession, indicatif"),
        ],
        fill_item=("Bien que ce ___ tentant, partir n'efface pas le Seuil. (être, subj.)", "soit"),
        words=["Quoi", "que", "vous", "décidiez", "nous", "relierons", "."],
        anagram=("opposition", "Rapport entre deux pratiques qui ne vont pas ensemble."),
        error=(
            "Bien que ce est tentant, partir n'efface pas le Seuil, et Léa tient au banc.",
            "Bien que ce soit tentant, partir n'efface pas le Seuil, et Léa tient au banc.",
            "Bien que + subjonctif : soit, pas est.",
        ),
        pic_start=10,
        pic_words=["une concession", "une valise", "une conjonction", "un texte"],
        short_p="Relevez quatre oppositions et quatre concessions, avec le mot-outil.",
        audio="Enregistrez : Alors que tu pars, je reste. Bien que ce soit loin, nous tiendrons au jeudi.",
    ),
    _l(
        "CE",
        "CE — Vacances du Seuil, pratiques en débat",
        "Lire un article qui oppose et concède des pratiques de repos.",
        "Lisez l'édito de Marc, sans aller trop vite.",
        "Édito de Marc Nkurunziza, feuille ocre",
        """On appelle « vacances » un départ, alors que certains se reposent sans quitter Rukiri-Nord.
Tandis que Léa plie une chemise pour le Pavillon du Saule, Félicie allonge le temps du bol.
Contrairement aux affiches trop lisses, un repos se discute : qui garde la cour, qui paie les lanternes.
Bien que Val-des-Peupliers promette l'eau et le pont, le Seuil ne devient pas une erreur.
Pourtant l'envie de partir n'est pas une trahison ; elle est une hypothèse.
Néanmoins Joël demandera un relais : les vacances des uns sont le travail des autres.
Quoi que l'on choisisse, il faut un mot sous le figuier, pas un silence habillé de soleil.
Aline écrit que s'opposer, ce n'est pas se quereller : c'est nommer deux pratiques.
Karim ajoute qu'une tendance de voyage se vend trop vite au Marché des Lampions.
Lila tiendra le micro le matin, bien qu'il fasse déjà chaud.
Rose coudra, alors que d'autres nageront ; les deux gestes peuvent rester justes.
Sami, plus lent, rappelle les anciens : on partait moins, on racontait plus.
Yvette nuance : un estomac fatigué n'a pas les mêmes vacances qu'un dos reposé.
Nous lirons cet édito jeudi, ayant déjà entendu les deux rives, pas une seule.""",
        tf_item=(
            "L'édito dit que l'envie de partir est forcément une trahison.",
            False,
            "Pourtant l'envie de partir n'est pas une trahison ; elle est une hypothèse.",
        ),
        qcm_item=(
            "Que demandera Joël, selon Marc ?",
            [
                "La fermeture du figuier",
                "Un relais, parce que les vacances des uns sont le travail des autres",
                "Que Félicie parte",
                "Que Radio Figuier se taise",
            ],
            1,
            "Néanmoins Joël demandera un relais.",
        ),
        pairs=[
            ("alors que / tandis que", "deux pratiques en même temps"),
            ("contrairement à", "les affiches trop lisses"),
            ("bien que", "Val-des-Peupliers / le Seuil"),
            ("quoi que", "il faut un mot"),
        ],
        fill_item=("Quoi que l'on ___, il faut un mot sous le figuier. (choisir, subj.)", "choisisse"),
        words=["Pourtant", "partir", "n'est", "pas", "une", "trahison", "."],
        anagram=("concession", "Rapport : on admet un fait sans renoncer à son avis."),
        error=(
            "Bien qu'il fait déjà chaud, Lila tiendra le micro le matin, et Joël cherchera un relais.",
            "Bien qu'il fasse déjà chaud, Lila tiendra le micro le matin, et Joël cherchera un relais.",
            "Bien que + subjonctif : fasse, pas fait.",
        ),
        pic_start=11,
        pic_words=["une valise", "une conjonction", "un texte", "une flèche"],
        short_p="Classez huit connecteurs du texte : opposition ou concession.",
        audio="Lisez l'édito, sans aller trop vite.",
    ),
    _l(
        "PO",
        "PO — Dire alors que, bien que, néanmoins",
        "Enchaîner à l'oral opposition et concession sur les vacances du Seuil.",
        "Répétez les modèles, puis défendez un choix : partir ou rester.",
        "Modèles d'Aline, valise et banc",
        """Alors que tu plies la valise, je tiens au banc.
Tandis que le pont attire, le figuier retient.
Contrairement à une fuite, des vacances se préparent.
Bien que ce soit loin, nous écrirons le jeudi.
Quoi que vous décidiez, laissez un mot.
Pourtant je ne juge pas ceux qui partent.
Néanmoins il faut un relais pour les lanternes.
On peut aimer l'eau tout en refusant d'idéaliser le pavillon.
Je partirai trois jours, alors que Rose coudra encore.
Je resterai, bien que l'eau me tente.
Hawa : concession, ce n'est pas abandonner son avis.
Marc : opposition, ce n'est pas insulter.
Lila : une phrase d'opposition, une phrase de concession, puis le micro.
Sami : les anciens opposaient moins, ils concédaient plus lentement.""",
        tf_item=(
            "« Bien que » se construit avec le subjonctif.",
            True,
            "Bien que ce soit loin ; quoi que vous décidiez.",
        ),
        qcm_item=(
            "Quelle phrase est une opposition, pas une concession ?",
            [
                "Bien que ce soit loin, nous écrirons",
                "Pourtant je ne juge pas",
                "Néanmoins il faut un relais",
                "Alors que tu plies la valise, je tiens au banc",
            ],
            3,
            "Alors que oppose deux pratiques simultanées.",
        ),
        pairs=[
            ("alors que", "opposition"),
            ("bien que", "concession + subj."),
            ("pourtant", "concession, indicatif"),
            ("contrairement à", "opposition + nom"),
        ],
        fill_item=("Contrairement ___ une fuite, des vacances se préparent.", "à"),
        words=["Bien", "que", "ce", "soit", "loin", "nous", "écrirons", "."],
        anagram=("neanmoins", "Connecteur de concession, sans accent ici, proche de pourtant."),
        error=(
            "Quoi que vous décidez ce soir, laissez un mot, et Joël cherchera un relais.",
            "Quoi que vous décidiez ce soir, laissez un mot, et Joël cherchera un relais.",
            "Quoi que + subjonctif : décidiez.",
        ),
        pic_start=12,
        pic_words=["une conjonction", "un texte", "une flèche", "un cahier"],
        short_p="Écrivez dix phrases : cinq oppositions, cinq concessions, sur partir / rester.",
        audio="Enregistrez les huit premiers modèles, puis votre choix argumenté.",
    ),
    _l(
        "PE",
        "PE — Mon commentaire de vacances",
        "Écrire un commentaire qui oppose deux pratiques et concède sans céder.",
        "Imitez le commentaire de Léa Niyonzima.",
        "Commentaire de Léa, enveloppe pour le figuier",
        """Léa Niyonzima — vers Rive-des-Saules, encore au Seuil
Alors que Patrick compte déjà les planches du pont, je compte encore les jeudis.
Tandis que la valise se ferme, le banc ocre reste ouvert : les deux gestes existent.
Contrairement aux affiches du Marché des Lampions, je n'achète pas un repos en trois mots.
Bien que Val-des-Peupliers me tente, je refuse d'appeler le Seuil une erreur.
Pourtant je partirai trois jours : concession n'est pas oubli.
Néanmoins Joël aura un relais, et Félicie un mot, avant midi.
Quoi que Sami raconte des anciens, nous avons droit à une eau différente, sans trahir.
Je serai au Pavillon du Saule lorsque j'aurai laissé cette feuille sous le figuier.
Rose coudra, alors que je marcherai : je ne jugerai pas son lin, qu'elle ne juge pas mon pont.
Lila pourra lire ceci le matin, bien qu'il fasse chaud.
Voilà mon avis, ni trop léger, ni trop fidèle.
Léa""",
        tf_item=(
            "Léa appelle le Seuil une erreur parce qu'elle part.",
            False,
            "Bien que Val-des-Peupliers me tente, je refuse d'appeler le Seuil une erreur.",
        ),
        qcm_item=(
            "Combien de jours Léa part-elle, et à quelle condition pour Joël ?",
            [
                "Un mois, sans relais",
                "Trois jours, et Joël aura un relais",
                "Elle ne part jamais",
                "Elle part seulement si Rose ferme l'atelier",
            ],
            1,
            "Pourtant je partirai trois jours […] Joël aura un relais.",
        ),
        pairs=[
            ("alors que", "Patrick / jeudis"),
            ("contrairement à", "les affiches"),
            ("bien que", "Val-des-Peupliers"),
            ("néanmoins", "un relais"),
        ],
        fill_item=("Lila pourra lire ceci, bien qu'il ___ chaud. (faire, subj.)", "fasse"),
        words=["Pourtant", "je", "partirai", "trois", "jours", "."],
        anagram=("quoique", "Conjonction de concession en un mot, suivie du subjonctif."),
        error=(
            "Bien que Val-des-Peupliers me tente, je serais au pavillon dès que j'aurai laissé cette feuille : c'est un projet réel.",
            "Bien que Val-des-Peupliers me tente, je serai au pavillon dès que j'aurai laissé cette feuille : c'est un projet réel.",
            "Projet réel : je serai, pas je serais.",
        ),
        pic_start=13,
        pic_words=["un texte", "une flèche", "un cahier", "un débat"],
        short_p="Imitez : douze lignes, trois oppositions, trois concessions, un relais nommé.",
        audio="Lisez votre commentaire, sans aller trop vite.",
    ),
    _l(
        "EL",
        "EL — Opposition et concession",
        "Retenir les outils pour opposer deux faits et concéder sans abandonner.",
        "Apprenez la fiche.",
        "Fiche d'Aline, valise et banc",
        """Opposition : deux faits qui ne vont pas dans le même sens, souvent en même temps.
alors que + indicatif ; tandis que + indicatif ; contrairement à + nom.
Alors que tu pars, je reste. Tandis que l'eau attire, le figuier retient.
Contrairement à une fuite, des vacances se préparent.
Concession : on admet un obstacle, on maintient l'avis.
bien que / quoique / quoi que + subjonctif.
Bien qu'il fasse chaud, nous enregistrons. Quoi que vous décidiez, laissez un mot.
pourtant, néanmoins, toutefois + indicatif (souvent après une virgule, ou en tête).
Pourtant je ne juge pas. Néanmoins il faut un relais.
même si + indicatif (concession plus orale).
Ne pas écrire : bien que c'est loin → bien que ce soit loin.
Vacances au Seuil : partir à Rive-des-Saules / rester, garder la cour, payer les lanternes.
Les vacances des uns sont le travail des autres : Rose, Joël, Félicie, Dieudonné.
Il faut nommer la pratique, pas insulter la personne.
Une tendance de voyage se discute, elle ne s'obéit pas.""",
        tf_item=(
            "« Contrairement à » se construit avec un nom, pas avec une proposition complète.",
            True,
            "Contrairement à une fuite, contrairement aux affiches.",
        ),
        qcm_item=(
            "Quelle série demande le subjonctif ?",
            [
                "alors que, tandis que",
                "pourtant, néanmoins",
                "bien que, quoique, quoi que",
                "contrairement à seulement",
            ],
            2,
            "Bien que / quoique / quoi que + subjonctif.",
        ),
        pairs=[
            ("alors que / tandis que", "indicatif"),
            ("bien que / quoi que", "subjonctif"),
            ("pourtant / néanmoins", "indicatif"),
            ("contrairement à", "nom"),
        ],
        fill_item=("Alors que tu ___, je reste au banc. (partir, ind.)", "pars"),
        words=["Néanmoins", "il", "faut", "un", "relais", "."],
        anagram=("tandis", "Conjonction : pendant que, parfois pour opposer deux faits."),
        error=(
            "Bien que c'est loin, nous écrirons le jeudi, et Joël aura son relais.",
            "Bien que ce soit loin, nous écrirons le jeudi, et Joël aura son relais.",
            "Bien que + subjonctif : ce soit.",
        ),
        pic_start=14,
        pic_words=["une flèche", "un cahier", "un débat", "une table"],
        short_p="Rédigez un tableau : outils d'opposition / de concession, mode, un exemple chacun.",
        audio="Enregistrez la fiche, puis six phrases : trois oppositions, trois concessions.",
    ),
]


# ---------------------------------------------------------------------------
# Séquence 4 — Introduire un texte explicatif (conjonctions de temps)
# ---------------------------------------------------------------------------

S4 = [
    _l(
        "CO",
        "CO — Quand le texte commence à expliquer",
        "Repérer les conjonctions de temps qui ordonnent un texte explicatif.",
        "Lisez le briefing. Dans quel ordre Lila veut-elle les étapes ?",
        "Briefing à Radio Figuier, horloge du studio",
        """Lila Sow : Un texte explicatif n'est pas un récit d'aventure. Il fait comprendre un processus.
Aline Uwase : Lorsque le jeudi commence, on dit d'abord de quoi l'on parle, ensuite comment cela marche.
Marc Nkurunziza : Dès que le titre a nommé l'objet — lanternes, bol, tissu — les étapes peuvent suivre.
Rose Iradukunda : Une fois que l'on a décrit le geste, on peut en donner la raison.
Patrick Habimana : Tandis que tu expliques le « comment », évite déjà le « trop beau ».
Hawa Diallo : Aussi longtemps que les étapes manquent, l'auditeur doute, et il a raison.
Joël Mugisha : Quand j'aurai accroché la première lanterne, vous pourrez dire « ensuite ».
Léa Niyonzima : Après que Félicie a nommé les herbes, on comprend le bol ; avant, on devine.
Solange Mukamana : Jusqu'à ce que le Cahier du chemin soit ouvert, on n'invente pas une archive.
Karim Bamba : Introduire, c'est cadrer : lieu, objet, public. Pas un slogan.
Félicie : Aussi longtemps que le prix reste flou, l'explication du plat reste incomplète.
Dieudonné : Lorsque la table est stable, les voix portent. J'explique avec les mains.
Yvette : Dès que l'on promet trop, l'explication devient une publicité. Attention.
Sami : Les anciens expliquaient aussi longtemps que l'enfant tenait encore assis, pas plus.""",
        tf_item=(
            "Lila dit qu'un texte explicatif est d'abord un récit d'aventure.",
            False,
            "Un texte explicatif n'est pas un récit d'aventure. Il fait comprendre un processus.",
        ),
        qcm_item=(
            "Que faut-il faire, selon Marc, dès que le titre a nommé l'objet ?",
            [
                "Couper le micro",
                "Laisser les étapes suivre",
                "Raconter une légende seulement",
                "Interdire les conjonctions",
            ],
            1,
            "Dès que le titre a nommé l'objet, les étapes peuvent suivre.",
        ),
        pairs=[
            ("lorsque", "cadre temporel soutenu"),
            ("dès que", "immédiatement après"),
            ("une fois que", "après achèvement"),
            ("aussi longtemps que", "durée"),
        ],
        fill_item=("___ le jeudi commence, on dit d'abord de quoi l'on parle.", "Lorsque"),
        words=["Dès", "que", "le", "titre", "nomme", "l'objet", "expliquez", "."],
        anagram=("lorsque", "Conjonction de temps plus soutenue que quand."),
        error=(
            "Aussi longtemps que les étapes manquent l'auditeur doute, et il fautons un ordre clair.",
            "Aussi longtemps que les étapes manquent l'auditeur doute, et il faut un ordre clair.",
            "Toujours il faut, à la 3e personne.",
        ),
        pic_start=15,
        pic_words=["un cahier", "un débat", "une table", "un micro"],
        short_p="Notez cinq conjonctions de temps et l'étape qu'elles introduisent.",
        audio="Enregistrez : Lorsque le jeudi commence, on cadre. Dès que le titre nomme, on explique.",
    ),
    _l(
        "CE",
        "CE — Comment le Seuil allume ses lanternes",
        "Lire un texte explicatif ordonné par des conjonctions de temps.",
        "Lisez le texte de Joël, sans aller trop vite.",
        "Texte explicatif de Joël Mugisha, Salle des Herbes",
        """Comment le Seuil allume-t-il ses lanternes, le jeudi ?
Lorsque le soleil baisse derrière Rukiri-Nord, Joël sort les armatures de Lampe-Figue, rien d'autre.
Dès que Dieudonné a vérifié le fil, on peut parler de lumière, pas avant.
Une fois que Rose a glissé le papier ocre, la lanterne a une peau ; elle n'est plus un cercle vide.
Tandis que Karim pèse l'huile à la balance du Marché des Herbes, Lila prépare le micro : deux gestes, un même soir.
Aussi longtemps que le vent trop sec agite le figuier, on n'accroche pas trop haut.
Après que Félicie a posé le bol du relais, ceux qui portent peuvent s'arrêter sans honte.
Quand la première lanterne brûle, le Cahier du chemin s'ouvre : on note l'heure, pas un slogan.
Jusqu'à ce que Sami ait dit le nom des anciens, on n'appelle pas cela une fête, seulement une veille.
Aline cadre : objet (lanterne), lieu (cour), public (ceux qui restent et ceux qui passent).
Marc ajoute qu'expliquer, c'est refuser le « c'est magique » trop vite.
Léa, étant rentrée, compare : à Rive-des-Saules, le pont éclaire autrement ; ici, ce sont des mains.
Yvette rappelle qu'une flamme n'est pas un jouet : l'explication inclut le danger.
Nous relirons ces étapes jeudi, lorsque nous aurons fini d'écouter, pas lorsque nous aurons fini de nous presser.""",
        tf_item=(
            "On accroche les lanternes très haut même si le vent trop sec agite le figuier.",
            False,
            "Aussi longtemps que le vent trop sec agite le figuier, on n'accroche pas trop haut.",
        ),
        qcm_item=(
            "Que fait-on dès que Dieudonné a vérifié le fil ?",
            [
                "On ferme Radio Figuier",
                "On peut parler de lumière, pas avant",
                "On vend les lanternes aux Lampions",
                "On part au Pavillon du Saule",
            ],
            1,
            "Dès que Dieudonné a vérifié le fil, on peut parler de lumière.",
        ),
        pairs=[
            ("lorsque le soleil baisse", "sortir les armatures"),
            ("dès que le fil est vérifié", "parler de lumière"),
            ("une fois que le papier est glissé", "la lanterne a une peau"),
            ("aussi longtemps que le vent", "ne pas trop haut"),
        ],
        fill_item=("Une fois que Rose ___ glissé le papier, la lanterne a une peau. (avoir)", "a"),
        words=["Lorsque", "le", "soleil", "baisse", "Joël", "sort", "les", "armatures", "."],
        anagram=("explicatif", "Texte qui fait comprendre un processus, pas une aventure."),
        error=(
            "Lorsque le soleil baisse Joël sort les armatures, et il ferra la file trop vite s'il se presse.",
            "Lorsque le soleil baisse Joël sort les armatures, et il fera la file trop vite s'il se presse.",
            "Futur de faire : il fera, un seul r.",
        ),
        pic_start=16,
        pic_words=["un débat", "une table", "un micro", "une radio"],
        short_p="Numérotez les étapes du texte et recopiez la conjonction qui les ouvre.",
        audio="Lisez le texte explicatif, sans aller trop vite.",
    ),
    _l(
        "PO",
        "PO — Dire lorsque, dès que, une fois que",
        "Ordonner à l'oral un processus avec des conjonctions de temps.",
        "Répétez, puis expliquez un geste du Seuil en six étapes.",
        "Modèles d'Aline et de Lila, studio",
        """Lorsque le jeudi commence, on cadre l'objet.
Dès que le titre a nommé, les étapes suivent.
Une fois que le geste est décrit, on en donne la raison.
Tandis que l'un explique le comment, l'autre prépare le micro.
Aussi longtemps que les étapes manquent, on ne conclut pas.
Quand la première lanterne brûle, on note l'heure.
Après que le fil a été vérifié, on parle de lumière.
Jusqu'à ce que Sami ait dit les noms, on n'appelle pas cela une fête.
Je commencerai lorsque j'aurai ouvert le cahier.
Vous comprendrez dès que j'aurai montré les mains.
Nous arrêterons aussi longtemps que le vent sera trop sec.
Lila : une conjonction par étape, pas trois dans la même phrase.
Marc : expliquer, ce n'est pas décorer.
Aline : le public doit pouvoir refaire le geste.""",
        tf_item=(
            "« Aussi longtemps que » exprime une durée, pas un instant.",
            True,
            "Aussi longtemps que les étapes manquent / que le vent est trop sec.",
        ),
        qcm_item=(
            "Quelle conjonction convient pour « immédiatement après » ?",
            [
                "aussi longtemps que",
                "dès que",
                "tandis que seulement",
                "contrairement à",
            ],
            1,
            "Dès que = dès l'instant où.",
        ),
        pairs=[
            ("lorsque", "cadre"),
            ("dès que", "juste après"),
            ("une fois que", "après l'achèvement"),
            ("tandis que", "simultanéité"),
        ],
        fill_item=("Aussi longtemps que les étapes ___, on ne conclut pas. (manquer)", "manquent"),
        words=["Une", "fois", "que", "le", "geste", "est", "décrit", "expliquez", "."],
        anagram=("aussitot", "Mot : … que, pour une action qui suit sans délai. (sans accent)"),
        error=(
            "Dès que le titre aura nommé l'objet, je ferrai suivre les étapes, et Lila coupera les slogans.",
            "Dès que le titre aura nommé l'objet, je ferai suivre les étapes, et Lila coupera les slogans.",
            "Futur de faire : je ferai, un seul r.",
        ),
        pic_start=17,
        pic_words=["une table", "un micro", "une radio", "une couture"],
        short_p="Expliquez un geste en huit phrases, chacune ouverte par une conjonction différente.",
        audio="Enregistrez les huit premiers modèles, puis votre processus en six étapes.",
    ),
    _l(
        "PE",
        "PE — Mon texte explicatif",
        "Écrire un texte explicatif cadré et ordonné par le temps.",
        "Imitez le texte de Solange Mukamana.",
        "Texte de Solange, Cahier du chemin",
        """Solange Mukamana — Comment on ouvre le Cahier du chemin, le jeudi
Lorsque le soleil a assez baissé, on pose le cahier sur la table du figuier, pas par terre.
Dès que Karim a essuyé la poussière, Aline dit l'objet : ce que l'on veut comprendre ce soir.
Une fois que le titre est dit, on n'ajoute pas un slogan. On enchaîne les gestes.
Tandis que Lila règle le micro, Marc numérote les étapes à voix haute, pour que chacun suive.
Aussi longtemps que Sami n'a pas confirmé un nom d'ancien, on n'écrit pas ce nom.
Après que Rose a décrit un ourlet, on peut expliquer pourquoi le lin tient.
Quand Félicie a nommé une herbe, le bol cesse d'être un mystère.
Jusqu'à ce que Dieudonné ait dit « la table tient », on n'y pose pas le cahier trop lourd.
Je serai la gardienne de l'ordre : expliquer, c'est permettre de refaire, pas d'admirer.
Yvette ajoutera le danger s'il y a flamme ou couteau.
Voilà un cadre, ni trop sec, ni trop paré.
Solange""",
        tf_item=(
            "Solange veut qu'on ajoute un slogan dès que le titre est dit.",
            False,
            "Une fois que le titre est dit, on n'ajoute pas un slogan.",
        ),
        qcm_item=(
            "Aussi longtemps que Sami n'a pas confirmé un nom, que fait-on ?",
            [
                "On l'écrit quand même",
                "On n'écrit pas ce nom",
                "On ferme Radio Figuier",
                "On part au pavillon",
            ],
            1,
            "Aussi longtemps que Sami n'a pas confirmé, on n'écrit pas ce nom.",
        ),
        pairs=[
            ("lorsque", "poser le cahier"),
            ("dès que", "dire l'objet"),
            ("une fois que", "pas de slogan"),
            ("aussi longtemps que", "pas de nom douteux"),
        ],
        fill_item=("Lorsque le soleil a assez ___, on pose le cahier. (baisser)", "baissé"),
        words=["Expliquer", "c'est", "permettre", "de", "refaire", "."],
        anagram=("processus", "Suite d'étapes expliquées dans un texte clair."),
        error=(
            "Lorsque j'aurai ouvert le cahier, je serais la gardienne de l'ordre, et Marc numérotera.",
            "Lorsque j'aurai ouvert le cahier, je serai la gardienne de l'ordre, et Marc numérotera.",
            "Projet réel : je serai, pas je serais.",
        ),
        pic_start=18,
        pic_words=["un micro", "une radio", "une couture", "un bol"],
        short_p="Imitez : un processus en douze lignes, cinq conjonctions de temps différentes.",
        audio="Lisez votre texte explicatif, sans aller trop vite.",
    ),
    _l(
        "EL",
        "EL — Conjonctions de temps pour expliquer",
        "Retenir les conjonctions qui ordonnent un texte explicatif.",
        "Apprenez la fiche.",
        "Fiche de Lila, studio de Radio Figuier",
        """lorsque + indicatif : cadre, souvent plus soutenu que quand.
dès que + indicatif : immédiatement après (dès que le fil est vérifié).
une fois que + indicatif : après l'achèvement (une fois que le titre est dit).
tandis que + indicatif : simultanément (parfois aussi opposition).
aussi longtemps que + indicatif : durée, limite (aussi longtemps que le vent est sec).
quand : plus courant ; après que + indicatif ; jusqu'à ce que + subjonctif.
Introduire un texte explicatif : 1) nommer l'objet 2) cadrer lieu et public 3) ordonner les étapes 4) donner la raison 5) inclure le danger s'il y en a.
Ce n'est pas un récit d'aventure, ni une publicité, ni un slogan.
Objets du Seuil à expliquer : lanternes, bol, ourlet, ouverture du Cahier du chemin.
Futur antérieur possible : je commencerai lorsque j'aurai ouvert le cahier.
Ne pas entasser trois conjonctions dans la même phrase.
Le public doit pouvoir refaire le geste.
Radio Figuier : une phrase, une pause, pas trop vite.
Il faut un ordre, pas une magie.""",
        tf_item=(
            "« Jusqu'à ce que » se construit avec le subjonctif.",
            True,
            "Jusqu'à ce que Sami ait dit les noms / que Dieudonné ait dit que la table tient.",
        ),
        qcm_item=(
            "Quel est le premier geste pour introduire un texte explicatif, selon la fiche ?",
            [
                "Conclure",
                "Nommer l'objet",
                "Vendre le geste",
                "Couper les doutes",
            ],
            1,
            "1) nommer l'objet, puis cadrer, puis ordonner.",
        ),
        pairs=[
            ("lorsque", "cadre"),
            ("dès que", "juste après"),
            ("aussi longtemps que", "durée"),
            ("jusqu'à ce que", "subjonctif"),
        ],
        fill_item=("Jusqu'à ce que Sami ___ dit les noms, on attend. (avoir, subj.)", "ait"),
        words=["Dès", "que", "le", "fil", "est", "vérifié", "expliquez", "."],
        anagram=("chronologie", "Ordre des étapes dans le temps, pour faire comprendre."),
        error=(
            "Aussi longtemps que le vent est trop sec on attend, et il fautons un ordre des étapes.",
            "Aussi longtemps que le vent est trop sec on attend, et il faut un ordre des étapes.",
            "Toujours il faut, à la 3e personne.",
        ),
        pic_start=19,
        pic_words=["une radio", "une couture", "un bol", "une lanterne"],
        short_p="Pour cinq conjonctions : construction, valeur, une phrase explicative.",
        audio="Enregistrez la fiche, puis un mini-texte explicatif de six lignes.",
    ),
]


# ---------------------------------------------------------------------------
# Séquence 5 — Débattre des tendances (EXTRA synthèse sous le figuier)
# ---------------------------------------------------------------------------

S5 = [
    _l(
        "CO",
        "CO — Pour et contre, sous le figuier",
        "Suivre une synthèse orale qui reprend mode, bol, vacances et explication.",
        "Lisez la table ronde. Qui synthétise, qui refuse le slogan ?",
        "Table ronde sous le figuier, jeudi",
        """Aline Uwase : D'une part le lin de Rose convainc ; d'autre part les lanternes fatiguent les bras. On tient les deux.
Marc Nkurunziza : En revanche, appeler tout cela « tendance » trop vite, c'est vendre avant d'avoir compris.
Lila Sow : Autrement dit : analyser, expliquer, puis débattre. Pas l'inverse.
Léa Niyonzima : Je concède que le pont attire, néanmoins le jeudi reste un argument.
Patrick Habimana : Certes le bol de Félicie console ; toutefois il ne remplace pas un salaire juste.
Hawa Diallo : D'un côté les Lampions brillent ; de l'autre les Herbes nomment. Je penche vers les noms.
Joël Mugisha : Pour ma part, je relayerai les lanternes, quoi que l'on vote sur les vacances.
Rose Iradukunda : Ayant fini trois ourlets, je peux dire : une mode n'est pas un ordre.
Solange Mukamana : En somme, le Seuil n'obéit pas ; il compare.
Karim Bamba : Reste que quelqu'un paie : les mains, l'huile, le micro.
Félicie : Je synthétise par un bol : quand vous aurez fini de crier, vous goûterez.
Dieudonné : La table tient. C'est déjà un argument.
Yvette : Attention aux estomacs et aux flammes : un débat n'efface pas un danger.
Sami : Les anciens diraient : ce que le figuier a vu, ce n'est pas un slogan. C'est une suite de gestes.""",
        tf_item=(
            "Solange conclut que le Seuil obéit aux tendances dès qu'elles brillent.",
            False,
            "En somme, le Seuil n'obéit pas ; il compare.",
        ),
        qcm_item=(
            "Dans quel ordre Lila veut-elle les opérations ?",
            [
                "Débattre, puis expliquer, puis analyser",
                "Vendre, puis voter",
                "Analyser, expliquer, puis débattre",
                "Crier, puis goûter",
            ],
            2,
            "Analyser, expliquer, puis débattre. Pas l'inverse.",
        ),
        pairs=[
            ("d'une part / d'autre part", "deux plateaux"),
            ("en revanche", "opposition forte"),
            ("certes / toutefois", "concession puis maintien"),
            ("en somme", "synthèse"),
        ],
        fill_item=("D'une part le lin convainc ; d'___ part les lanternes fatiguent.", "autre"),
        words=["En", "somme", "le", "Seuil", "compare", "."],
        anagram=("tendances", "Modes et habitudes qui circulent sous l'arbre."),
        error=(
            "Certes le bol console, toutefois il ne remplace pas un salaire, et je serais trop vite d'accord si je cède au slogan réel de jeudi.",
            "Certes le bol console, toutefois il ne remplace pas un salaire, et je serai trop vite d'accord si je cède au slogan réel de jeudi.",
            "Projet réel de jeudi : je serai, pas le conditionnel je serais.",
        ),
        pic_start=20,
        pic_words=["une couture", "un bol", "une lanterne", "un banc"],
        short_p="Relevez six connecteurs de débat et l'argument qu'ils portent.",
        audio="Enregistrez : D'une part le lin convainc. D'autre part les lanternes fatiguent. En somme, le Seuil compare.",
    ),
    _l(
        "CE",
        "CE — Synthèse des tendances du Seuil",
        "Lire une synthèse argumentée qui relie les quatre premières séquences.",
        "Lisez la synthèse de Mado, sans aller trop vite.",
        "Synthèse de Mado, feuille pour le figuier",
        """Quatre dossiers, une cour : voilà la semaine du Seuil des Sources.
D'une part, le tissu de Rose, convaincant pour les uns, convainquant les passants pour les autres, a forcé une grammaire : action ou qualité.
D'autre part, le bol de Félicie a forcé un temps : on jugera quand on aura fini, pas avant.
En revanche, les vacances ont opposé deux pratiques : partir vers Rive-des-Saules, rester et relayer.
Néanmoins personne n'a obtenu le droit d'insulter l'autre rive.
Le texte explicatif des lanternes a rappelé l'ordre : lorsque, dès que, une fois que, aussi longtemps que.
Autrement dit, une tendance n'est pas un orage : on peut l'analyser, l'expliquer, la débattre.
Certes le Marché des Lampions brille ; toutefois le Marché des Herbes nomme et pèse.
Karim a raison sur un point : quelqu'un paie, toujours.
Lila refuse le slogan ; Sami refuse l'oubli des anciens ; Yvette refuse le danger nié.
Ayant entendu les uns et les autres, Aline propose de voter sur des gestes, pas sur des mots à la mode.
Joël relayera quoi que l'on décide des valises.
Nous publierons cette synthèse à Radio Figuier lorsque nous aurons coupé les insultes, pas les doutes.
Le figuier, lui, n'a pas voté : il a porté les lanternes.""",
        tf_item=(
            "La synthèse dit qu'on peut voter sur des mots à la mode plutôt que sur des gestes.",
            False,
            "Aline propose de voter sur des gestes, pas sur des mots à la mode.",
        ),
        qcm_item=(
            "Que refuse Lila, dans cette synthèse ?",
            [
                "Le bol",
                "Le slogan",
                "Le relais de Joël",
                "Le Cahier du chemin",
            ],
            1,
            "Lila refuse le slogan.",
        ),
        pairs=[
            ("d'une part / d'autre part", "tissu / bol"),
            ("en revanche", "vacances"),
            ("certes / toutefois", "deux marchés"),
            ("autrement dit", "analyser expliquer débattre"),
        ],
        fill_item=("Nous publierons lorsque nous ___ coupé les insultes. (avoir, FA)", "aurons"),
        words=["Autrement", "dit", "une", "tendance", "s'analyse", "."],
        anagram=("synthese", "Texte court qui rassemble les avis pour et contre. (sans accent)"),
        error=(
            "Certes les Lampions brillent, toutefois les Herbes pèsent, et bien que ce est utile on garde les deux.",
            "Certes les Lampions brillent, toutefois les Herbes pèsent, et bien que ce soit utile on garde les deux.",
            "Bien que + subjonctif : ce soit.",
        ),
        pic_start=21,
        pic_words=["un bol", "une lanterne", "un banc", "un graphique"],
        short_p="Résumez en huit lignes les quatre dossiers, avec quatre connecteurs de débat.",
        audio="Lisez la synthèse, sans aller trop vite.",
    ),
    _l(
        "PO",
        "PO — Dire d'une part, en somme, toutefois",
        "Mener à l'oral une synthèse courte avec les connecteurs de débat.",
        "Répétez, puis tenez un avis de deux minutes sous le figuier.",
        "Modèles d'Aline, table du jeudi",
        """D'une part je reconnais le lin ; d'autre part je vois les bras fatigués.
En revanche je refuse le mot « tendance » trop tôt.
Certes le pont attire ; toutefois le jeudi reste un argument.
Néanmoins il faut un relais et un prix juste.
Autrement dit, on analyse avant de voter.
Pour ma part, je penche vers les noms du Marché des Herbes.
En somme, le Seuil compare, il n'obéit pas.
Reste que quelqu'un paie les mains.
Quoi que l'on décide, Joël relayera.
Je concède l'envie de partir, je maintiens le mot sous l'arbre.
Lila : une phrase pour, une phrase contre, une phrase de synthèse.
Marc : pas de slogan.
Karim : nommez qui paie.
Sami : nommez ce que le figuier a déjà vu.""",
        tf_item=(
            "« En somme » sert à ouvrir le débat, pas à le clore.",
            False,
            "En somme clôt : le Seuil compare, il n'obéit pas.",
        ),
        qcm_item=(
            "Quel couple introduit deux plateaux équilibrés ?",
            [
                "en somme / reste que",
                "d'une part / d'autre part",
                "quoi que / lorsque",
                "ayant fini / étant partie",
            ],
            1,
            "D'une part / d'autre part.",
        ),
        pairs=[
            ("d'une part", "premier plateau"),
            ("en revanche", "opposition"),
            ("certes / toutefois", "concession"),
            ("en somme", "clôture"),
        ],
        fill_item=("Certes le pont attire ; ___ le jeudi reste un argument.", "toutefois"),
        words=["Pour", "ma", "part", "je", "penche", "vers", "les", "noms", "."],
        anagram=("balance", "Image du pour et du contre, deux plateaux."),
        error=(
            "En somme le Seuil compare, et je ferrai le relais des lanternes dès que j'aurai fini mon avis.",
            "En somme le Seuil compare, et je ferai le relais des lanternes dès que j'aurai fini mon avis.",
            "Futur de faire : je ferai, un seul r.",
        ),
        pic_start=22,
        pic_words=["une lanterne", "un banc", "un graphique", "un nuage"],
        short_p="Écrivez un avis oral de douze phrases, avec six connecteurs de débat.",
        audio="Enregistrez les huit premiers modèles, puis votre synthèse de deux minutes.",
    ),
    _l(
        "PE",
        "PE — Ma synthèse sous le figuier",
        "Écrire une synthèse argumentée des tendances discutées au Seuil.",
        "Imitez la synthèse d'Aline Uwase.",
        "Synthèse d'Aline, banc ocre",
        """Aline Uwase — Seuil des Sources, Rukiri-Nord
D'une part le lin de Rose est convaincant ; d'autre part les lanternes, fatiguant les bras, exigent un relais.
En revanche je refuse d'appeler cela une « loi » du jeudi.
Certes Félicie console par le bol ; toutefois le prix des herbes reste un argument, pas un détail.
Néanmoins Léa peut partir trois jours, bien que le banc se vide un peu.
Autrement dit : on oppose, on concède, on n'insulte pas.
Quand nous aurons fini d'écouter Karim — qui paie ? — nous pourrons voter sur des gestes.
Quoi que Sami rappelle des anciens, le Seuil d'aujourd'hui a droit à un micro, pas à un silence pieux.
Pour ma part, je penche vers le Marché des Herbes, ayant comparé les emballages des Lampions.
En somme, une tendance s'analyse, s'explique, se débat. Elle ne s'obéit pas.
Je serai là jeudi, et Lila coupera les slogans.
Aline""",
        tf_item=(
            "Aline accepte d'appeler les habitudes du jeudi une « loi ».",
            False,
            "En revanche je refuse d'appeler cela une « loi » du jeudi.",
        ),
        qcm_item=(
            "Vers quel marché Aline penche-t-elle, et après quoi ?",
            [
                "Les Lampions, sans comparer",
                "Le Marché des Herbes, ayant comparé les emballages",
                "Aucun marché",
                "Seulement Lampe-Figue",
            ],
            1,
            "Pour ma part, je penche vers le Marché des Herbes, ayant comparé…",
        ),
        pairs=[
            ("d'une part / d'autre part", "lin / lanternes"),
            ("certes / toutefois", "bol / prix"),
            ("autrement dit", "opposer concéder"),
            ("en somme", "analyser expliquer débattre"),
        ],
        fill_item=("En somme, une tendance s'analyse : elle ne s'___ pas. (obéir)", "obéit"),
        words=["Je", "refuse", "d'appeler", "cela", "une", "loi", "."],
        anagram=("argument", "Preuve ou raison avancée pour emporter l'adhésion, au débat."),
        error=(
            "Quand nous aurons fini d'écouter Karim, nous pourai voter sur des gestes, et Lila coupera les slogans.",
            "Quand nous aurons fini d'écouter Karim, nous pourrons voter sur des gestes, et Lila coupera les slogans.",
            "Futur de pouvoir : nous pourrons, deux r.",
        ),
        pic_start=23,
        pic_words=["un banc", "un graphique", "un nuage", "un soleil"],
        short_p="Imitez : une synthèse de douze lignes, six connecteurs, un avis clair.",
        audio="Lisez votre synthèse, sans aller trop vite.",
    ),
    _l(
        "EL",
        "EL — Outils de la synthèse sous le figuier",
        "Retenir les connecteurs qui organisent un débat et une synthèse.",
        "Apprenez la fiche.",
        "Fiche d'Aline et de Marc, table du jeudi",
        """D'une part … d'autre part … : deux plateaux, sans écraser l'un.
En revanche : opposition plus nette après un premier argument.
Certes … toutefois / néanmoins : on concède, puis on maintient.
Autrement dit : on reformule, on clarifie, on refuse le slogan.
Pour ma part : on assume un avis, sans parler pour tout le Seuil.
En somme / en résumé : on clôt, on ne rouvre pas trois dossiers.
Reste que : on rappelle un fait qui résiste (qui paie ?).
Quoi que + subj. : concession large (quoi que l'on décide).
Ayant + participe : antériorité pour légitimer un avis (ayant comparé).
Quand nous aurons fini : futur antérieur avant le vote.
Ne pas écrire je serais pour un jeudi déjà fixé → je serai.
Ne pas écrire je ferrai / je pourai → je ferai / je pourrai.
Synthèse du Seuil : mode, bol, vacances, texte explicatif, puis débat.
Le figuier porte les lanternes ; il ne vote pas.""",
        tf_item=(
            "« Reste que » sert surtout à reformuler un slogan.",
            False,
            "Reste que rappelle un fait qui résiste, par exemple qui paie.",
        ),
        qcm_item=(
            "Quel connecteur clôt la synthèse ?",
            [
                "d'une part",
                "en somme",
                "certes",
                "tandis que",
            ],
            1,
            "En somme / en résumé ferment.",
        ),
        pairs=[
            ("d'une part / d'autre part", "deux plateaux"),
            ("certes / toutefois", "concession"),
            ("autrement dit", "reformulation"),
            ("en somme", "clôture"),
        ],
        fill_item=("Autrement ___ : on analyse avant de voter.", "dit"),
        words=["Reste", "que", "quelqu'un", "paie", "les", "mains", "."],
        anagram=("debat", "Échange d'avis sous l'arbre, pour et contre. (sans accent)"),
        error=(
            "En somme le Seuil compare, et il fautons un relais avant le vote de jeudi.",
            "En somme le Seuil compare, et il faut un relais avant le vote de jeudi.",
            "Toujours il faut, à la 3e personne.",
        ),
        pic_start=24,
        pic_words=["un graphique", "un nuage", "un soleil", "une feuille"],
        short_p="Tableau : huit connecteurs, valeur, un exemple chacun tiré du Seuil.",
        audio="Enregistrez la fiche, puis une mini-synthèse de huit lignes.",
    ),
]


# ---------------------------------------------------------------------------
# Séquence 6 — Une chronique pour Radio Figuier (EXTRA article / oral argumenté)
# ---------------------------------------------------------------------------

S6 = [
    _l(
        "CO",
        "CO — Préparer la chronique du jeudi",
        "Suivre la préparation d'une chronique argumentée pour Radio Figuier.",
        "Lisez la réunion de rédaction. Quelles parties Lila exige-t-elle ?",
        "Réunion à Radio Figuier, micro encore froid",
        """Lila Sow : Une chronique n'est pas un cri. Elle a un fait, un angle, une concession, une proposition.
Marc Nkurunziza : J'ouvrirai sur le lin de Rose, pas sur un slogan. Le fait d'abord.
Aline Uwase : Ensuite l'angle : qui paie les mains, qui copie, qui porte.
Léa Niyonzima : Je concéderai l'envie du pont, néanmoins je défendrai le jeudi.
Patrick Habimana : Attention au ton : argumenter, ce n'est pas humilier Rive-des-Saules.
Hawa Diallo : Dès que tu auras nommé les deux marchés, tu pourras juger, pas avant.
Joël Mugisha : Pour ma part, une minute sur le relais des lanternes, rien de plus.
Rose Iradukunda : Ayant fini l'ourlet, je peux parler du tissu sans le vendre.
Solange Mukamana : Le Cahier du chemin notera l'heure de diffusion, pas les applaudissements.
Karim Bamba : Reste que le prix des herbes doit apparaître, autrement la chronique ment.
Félicie : Je passerai au micro lorsque j'aurai lavé le bol. Un fait simple.
Dieudonné : Si la table grince, on l'entendra. Réparez avant, ou expliquez.
Yvette : Incluez le danger : flamme, estomac, dos. Une chronique adulte.
Sami : Terminez par ce que le figuier a vu, pas par ce qu'il « devrait » aimer.""",
        tf_item=(
            "Lila dit qu'une chronique peut se contenter d'un cri, sans concession.",
            False,
            "Une chronique n'est pas un cri. Elle a un fait, un angle, une concession, une proposition.",
        ),
        qcm_item=(
            "Que doit faire Hawa avant de juger les marchés ?",
            [
                "Couper le micro",
                "Les nommer tous les deux",
                "Partir au pavillon",
                "Interdire les herbes",
            ],
            1,
            "Dès que tu auras nommé les deux marchés, tu pourras juger, pas avant.",
        ),
        pairs=[
            ("fait", "ouvrir sans slogan"),
            ("angle", "qui paie, qui copie"),
            ("concession", "l'envie du pont"),
            ("proposition", "relais, prix, danger"),
        ],
        fill_item=("Une chronique a un fait, un angle, une concession, une ___.", "proposition"),
        words=["Une", "chronique", "n'est", "pas", "un", "cri", "."],
        anagram=("chronique", "Genre régulier, à l'antenne du Seuil, plus argumenté qu'un cri."),
        error=(
            "Dès que tu auras nommé les deux marchés, tu pourai juger, et Karim rappellera le prix.",
            "Dès que tu auras nommé les deux marchés, tu pourras juger, et Karim rappellera le prix.",
            "Futur de pouvoir : tu pourras, deux r.",
        ),
        pic_start=25,
        pic_words=["un nuage", "un soleil", "une feuille", "une balance"],
        short_p="Notez les quatre parties exigées par Lila et un exemple pour chacune.",
        audio="Enregistrez : Une chronique a un fait, un angle, une concession, une proposition.",
    ),
    _l(
        "CE",
        "CE — Chronique : ce que le jeudi refuse",
        "Lire une chronique argumentée diffusée à Radio Figuier.",
        "Lisez la chronique de Marc, sans aller trop vite.",
        "Chronique de Marc Nkurunziza, antenne du Seuil",
        """Ce jeudi, le Seuil des Sources n'a pas acheté une tendance : il l'a interrogée.
Le fait d'abord : Rose a fini trois ourlets ; Joël a accroché des lanternes ; Félicie a servi un bol nommé.
L'angle ensuite : qui copie le lin, qui pèse les herbes, qui relais les bras, qui paie.
Je concède que Rive-des-Saules et le Pavillon du Saule attirent : l'eau n'est pas une faute.
Néanmoins un départ de trois jours n'autorise pas à traiter le figuier de musée.
Contrairement aux affiches du Marché des Lampions, une chronique nomme les prix.
Bien que le Marché des Herbes soit inventé, il a des balances, donc une honnêteté.
Quand nous aurons fini d'écouter Yvette — flammes, estomacs — nous pourrons parler de fête.
Autrement dit, argumenter, c'est tenir un fait, une concession et une proposition dans la même voix.
Je propose : un relais pour les lanternes, un juste prix pour les mains, un mot sous l'arbre avant toute valise.
Lila coupera les insultes ; elle gardera les doutes. C'est déjà une éthique.
Sami rappellera les anciens, non pour fermer le micro, pour l'empêcher de trop vite.
Ayant comparé les deux rives, Léa et Patrick peuvent partir sans nous trahir, si le jeudi reste un rendez-vous.
Voilà ce que Radio Figuier peut dire, sans crier, sans vendre, sans obéir.""",
        tf_item=(
            "La chronique affirme que le Seuil a acheté une tendance sans l'interroger.",
            False,
            "Le Seuil n'a pas acheté une tendance : il l'a interrogée.",
        ),
        qcm_item=(
            "Quelle proposition concrète Marc avance-t-il ?",
            [
                "Fermer le Marché des Herbes",
                "Un relais, un juste prix, un mot avant toute valise",
                "Interdire Rive-des-Saules",
                "Remplacer Lila par un slogan",
            ],
            1,
            "Un relais pour les lanternes, un juste prix pour les mains, un mot sous l'arbre.",
        ),
        pairs=[
            ("le fait", "ourlets, lanternes, bol"),
            ("l'angle", "qui paie, qui copie"),
            ("la concession", "l'eau n'est pas une faute"),
            ("la proposition", "relais, prix, mot"),
        ],
        fill_item=("Bien que le Marché des Herbes ___ inventé, il a des balances. (être, subj.)", "soit"),
        words=["Argumenter", "c'est", "tenir", "un", "fait", "."],
        anagram=("editorial", "Article d'opinion signé, plus argumenté qu'un fait divers. (sans accent)"),
        error=(
            "Quand nous aurons fini d'écouter Yvette, nous pourrons parler de fête, et je serais à l'antenne à l'heure fixée.",
            "Quand nous aurons fini d'écouter Yvette, nous pourrons parler de fête, et je serai à l'antenne à l'heure fixée.",
            "Heure déjà fixée : je serai, pas je serais.",
        ),
        pic_start=26,
        pic_words=["un soleil", "une feuille", "une balance", "un cœur"],
        short_p="Repérez fait, angle, concession, proposition, et recopiez une phrase pour chacun.",
        audio="Lisez la chronique, sans aller trop vite.",
    ),
    _l(
        "PO",
        "PO — Dire une chronique à l'antenne",
        "Prononcer une chronique courte : fait, angle, concession, proposition.",
        "Répétez les modèles, puis tenez une chronique d'une minute.",
        "Modèles de Lila Sow, studio",
        """Le fait d'abord : Rose a fini l'ourlet, Joël a accroché, Félicie a servi.
L'angle ensuite : qui paie les mains, qui copie le lin.
Je concède que le pont attire.
Néanmoins le jeudi reste un rendez-vous, pas un musée.
Contrairement aux affiches, je nomme les prix.
Bien que le marché des plantes soit inventé, il pèse.
Quand j'aurai nommé les deux files, je jugerai.
Autrement dit, une chronique n'est pas un cri.
Je propose un relais, un juste prix, un mot sous l'arbre.
Pour ma part, je refuse le slogan.
En somme, le Seuil interroge, il n'achète pas trop vite.
Lila : une phrase, une pause, le micro près de la bouche.
Marc : tenez l'ordre des quatre parties.
Aline : le public doit pouvoir vous contredire, donc soyez clairs.
Sami : finissez par un geste vu, pas par un devoir moral trop large.""",
        tf_item=(
            "Lila demande de parler sans pause, pour remplir l'antenne.",
            False,
            "Une phrase, une pause, le micro près de la bouche.",
        ),
        qcm_item=(
            "Dans quel ordre les modèles placent-ils les parties ?",
            [
                "Proposition, cri, fait",
                "Fait, angle, concession, proposition",
                "Slogan, vote, silence",
                "Concession seulement",
            ],
            1,
            "Fait d'abord, angle, concession, proposition.",
        ),
        pairs=[
            ("le fait", "ourlet, lanterne, bol"),
            ("l'angle", "qui paie"),
            ("néanmoins", "le jeudi reste"),
            ("je propose", "relais, prix, mot"),
        ],
        fill_item=("Contrairement ___ affiches, je nomme les prix.", "aux"),
        words=["Une", "chronique", "n'est", "pas", "un", "cri", "."],
        anagram=("micro", "Objet du studio de Lila, pour prendre la voix sans crier."),
        error=(
            "Quand j'aurai nommé les deux files, je jugerai, et je ferrai une pause après chaque phrase.",
            "Quand j'aurai nommé les deux files, je jugerai, et je ferai une pause après chaque phrase.",
            "Futur de faire : je ferai, un seul r.",
        ),
        pic_start=27,
        pic_words=["une feuille", "une balance", "un cœur", "une mode"],
        short_p="Écrivez une chronique orale de dix phrases, dans l'ordre des quatre parties.",
        audio="Enregistrez les huit premiers modèles, puis votre chronique d'une minute.",
    ),
    _l(
        "PE",
        "PE — Ma chronique pour Radio Figuier",
        "Écrire une chronique argumentée destinée à l'antenne du Seuil.",
        "Imitez la chronique de Lila Sow.",
        "Chronique de Lila, papier du studio",
        """Lila Sow — Radio Figuier, Seuil des Sources
Le fait : ce jeudi, le lin ocre a convaincu plus d'oreilles que d'yeux ; les lanternes ont fatigué plus de bras que de regards.
L'angle : une tendance qui n'a pas de prix n'a pas de vérité. Karim a raison de demander qui paie.
Je concède que Val-des-Peupliers et le Pavillon du Saule offrent une eau que le figuier ne donne pas.
Néanmoins partir n'autorise pas à traiter nos jeudis de folklore.
Bien que le Marché des Herbes soit inventé, il nomme ce qu'il vend ; les Lampions, trop souvent, emballent.
Quand j'aurai coupé les insultes de l'enregistrement, je garderai les doutes : c'est mon métier.
Autrement dit, une chronique tient un fait, une concession et une proposition dans la même voix.
Je propose : un relais écrit pour Joël, un tarif dit à voix haute pour Félicie, un mot sous l'arbre avant toute valise.
Pour ma part, je refuse le slogan « soyez à la mode » : soyez précis.
En somme, le Seuil interroge ce qui passe, et il protège ce qui reste.
Vous m'entendrez demain, sans crier.
Lila""",
        tf_item=(
            "Lila dit que son métier est de couper les doutes et de garder les insultes.",
            False,
            "Elle coupera les insultes et gardera les doutes.",
        ),
        qcm_item=(
            "Quelles trois propositions concrètes Lila avance-t-elle ?",
            [
                "Fermer le figuier, vendre le lin, taire Karim",
                "Un relais pour Joël, un tarif pour Félicie, un mot avant la valise",
                "Partir tous à Rive-des-Saules",
                "Remplacer le bol par un slogan",
            ],
            1,
            "Relais écrit, tarif à voix haute, mot sous l'arbre.",
        ),
        pairs=[
            ("le fait", "lin et lanternes"),
            ("l'angle", "pas de prix, pas de vérité"),
            ("la concession", "l'eau de l'autre rive"),
            ("la proposition", "relais, tarif, mot"),
        ],
        fill_item=("Bien que le Marché des Herbes ___ inventé, il nomme ce qu'il vend. (être, subj.)", "soit"),
        words=["Je", "refuse", "le", "slogan", "soyez", "précis", "."],
        anagram=("figuier", "Arbre de la cour, témoin des débats du jeudi."),
        error=(
            "Quand j'aurai coupé les insultes, je garderai les doutes, et je serais à l'antenne demain à l'heure dite.",
            "Quand j'aurai coupé les insultes, je garderai les doutes, et je serai à l'antenne demain à l'heure dite.",
            "Rendez-vous réel : je serai, pas je serais.",
        ),
        pic_start=28,
        pic_words=["une balance", "un cœur", "une mode", "un participe"],
        short_p="Imitez : une chronique de douze à quatorze lignes, quatre parties visibles.",
        audio="Lisez votre chronique, sans aller trop vite.",
    ),
    _l(
        "EL",
        "EL — Tenir une chronique argumentée",
        "Retenir la structure et la langue d'une chronique pour Radio Figuier.",
        "Apprenez la fiche.",
        "Fiche de Lila et d'Aline, studio",
        """Structure : fait → angle → concession → proposition → clôture.
Fait : concret, daté, sans slogan (ourlet, bol, lanterne, heure).
Angle : question qui oriente (qui paie ? qui copie ? qui relais ?).
Concession : bien que / certes / je concède que — puis néanmoins / toutefois.
Proposition : un geste possible (relais, tarif dit, mot sous l'arbre).
Clôture : en somme / autrement dit / pour ma part — une phrase nette.
Langue : futur antérieur avant le jugement (quand j'aurai nommé, je jugerai).
Participe composé pour légitimer (ayant comparé, ayant fini).
Opposition et concession : alors que, contrairement à, bien que + subj.
Je serai à l'antenne (futur réel) / je serais (hypothèse).
Je ferai (1 r) ; je pourrai (2 r) ; il faut (3e pers.).
Ton : une phrase, une pause ; pas d'insulte ; garder les doutes.
Public du Seuil : ceux qui restent, ceux qui partent, ceux qui paient.
Radio Figuier n'obéit pas à une mode : elle l'interroge.""",
        tf_item=(
            "La proposition d'une chronique doit rester un slogan sans geste.",
            False,
            "Proposition : un geste possible (relais, tarif, mot).",
        ),
        qcm_item=(
            "Quel est l'ordre de la structure retenue ?",
            [
                "Slogan, vote, silence",
                "Fait, angle, concession, proposition, clôture",
                "Clôture, fait, cri",
                "Angle seulement",
            ],
            1,
            "Fait → angle → concession → proposition → clôture.",
        ),
        pairs=[
            ("fait", "concret, daté"),
            ("angle", "qui paie / qui copie"),
            ("concession", "bien que / certes"),
            ("proposition", "un geste possible"),
        ],
        fill_item=("Quand j'aurai nommé les deux files, je ___. (juger, futur)", "jugerai"),
        words=["Radio", "Figuier", "interroge", "une", "mode", "."],
        anagram=("antenne", "Lieu d'où Lila diffuse, sans crier, une voix argumentée."),
        error=(
            "Je serai à l'antenne demain, et il fautons une pause après chaque phrase argumentée.",
            "Je serai à l'antenne demain, et il faut une pause après chaque phrase argumentée.",
            "Toujours il faut, à la 3e personne.",
        ),
        pic_start=29,
        pic_words=["un cœur", "une mode", "un participe", "un adjectif"],
        short_p="Rédigez un plan de chronique : cinq parties, deux exemples de langue chacun.",
        audio="Enregistrez la fiche, puis une chronique de cinq phrases.",
    ),
]


SEQUENCES = [
    {"title": "Mode et apparence", "lessons": S1},
    {"title": "Tendance alimentaire", "lessons": S2},
    {"title": "Vacances et pratiques sociales", "lessons": S3},
    {"title": "Introduire un texte explicatif", "lessons": S4},
    {"title": "Débattre des tendances", "lessons": S5},
    {"title": "Une chronique pour Radio Figuier", "lessons": S6},
]
