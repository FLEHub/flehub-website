"""B2 Module 4 — Vivre avec la technologie (univers Seuil des Sources)."""

from factory import L

IMG = "mfk-b2-m4"
IMG_DIR = IMG

MODULE = {
    "title": "B2 — Vivre avec la technologie",
    "description": (
        "Grande étape B2-4 : lire une actualité technologique, mesurer une "
        "évolution, relier mémoire et réseaux, raisonner sur la déconnexion, "
        "puis rédiger une charte et tenir un débat — Lampe-Figue, Filtre des "
        "Herbes, fil de Radio Figuier (réseau local inventé), cour du Seuil "
        "des Sources (Rukiri-Nord)."
    ),
}

_PICS = [
    "une actualité",
    "une inversion",
    "un préfixe",
    "une lampe",
    "une durée",
    "un réseau",
    "une horloge",
    "un graphique",
    "une reprise",
    "une cause",
    "une mémoire",
    "une antenne",
    "un connecteur",
    "une pause",
    "une charte",
    "un interrupteur",
    "un débat",
    "un casque",
    "un studio",
    "un filtre",
    "un appareil",
    "un écran",
    "un banc",
    "une oreille",
    "une feuille",
    "une alerte",
    "un soleil",
    "un groupe",
    "un micro",
    "une porte",
]


def _pw(start: int) -> list[str]:
    return [_PICS[(start + i) % 30] for i in range(4)]


def _l(comp, title, obj, cons, st, sp, **kw):
    return L(IMG, comp, title, obj, cons, st, sp, **kw)


# ---------------------------------------------------------------------------
# Séquence 1 — Actualité technologique
# ---------------------------------------------------------------------------

S1 = [
    _l(
        "CO",
        "CO — Faut-il allumer la Lampe-Figue ?",
        "Suivre une actualité inventée ; inversion et préfixes négatifs ; avantages et inconvénients.",
        "Lisez le dialogue. Quels avantages, quels inconvénients, quelles questions inversées ?",
        "Studio de Radio Figuier, fil du soir",
        """Lila : Actualité du Seuil : la Lampe-Figue relie désormais trois cours par le fil. Faut-il s'en réjouir sans réserve ?
Léa : Peut-on entendre une voix loin du figuier ? Oui. Est-ce utile ? Oui. Est-ce toujours souhaitable ? J'en doute.
Patrick : Doit-on tout filtrer par le Filtre des Herbes ? Un message inutile fatigue. Un message impossible à retracer inquiète.
Marc : Attention aux préfixes : in- avant une consonne, im- devant p ou b, ir- devant r. On dit impossible, pas inpossible.
Hawa : L'avantage, c'est la mémoire partagée. L'inconvénient, c'est la méfiance : on devient mécontent dès qu'une voix tarde.
Joël : Déconnecter une soirée, est-ce irresponsable ? Je ne crois pas. Rester allumé sans écoute, cela l'est davantage.
Rose : La lampe est imparfaite, et c'est tant mieux. Un outil trop sûr devient imprudent.
Solange : Le Bureau peut dater un usage. Il ne peut pas interdire une méfiance. Faut-il une règle ? Oui. Une panique ? Non.
Karim : Avantage : on retrace une décision. Inconvénient : on déforme une rumeur plus vite.
Aline : Peut-on vivre avec le fil sans s'y soumettre ? C'est la seule question qui m'intéresse.
Dieudonné : J'ai construit la lampe. Je n'ai pas construit l'obéissance. Débrancher reste possible.
Sami : Trois frappes valent mieux qu'une alerte trop nette. Le fil est irrégulier ? Qu'il le reste.
Yvette : Incomplet n'est pas inutile. Invisible n'est pas innocent. Choisissez vos préfixes avec soin.
Félicie : Léa a mis le casque. Elle entend trop. Peut-elle l'enlever ? Oui, et c'est déjà une réponse.""",
        tf_item=(
            "Marc rappelle que l'on dit impossible, pas inpossible.",
            True,
            "im- devant p ou b.",
        ),
        qcm_item=(
            "Quelle question intéresse surtout Aline ?",
            [
                "Faut-il interdire le thé ?",
                "Peut-on vivre avec le fil sans s'y soumettre ?",
                "Doit-on vendre la lampe au marché ?",
                "Faut-il fermer le figuier ?",
            ],
            1,
            "Aline : vivre avec le fil sans s'y soumettre.",
        ),
        pairs=[
            ("faut-il / peut-on / doit-on", "inversion"),
            ("impossible / imprudent", "im- devant p"),
            ("déconnecter / débrancher", "préfixe dé-"),
            ("méfiance / mécontent", "préfixe mé-"),
        ],
        fill_item=("On dit ___ , pas inpossible.", "impossible"),
        words=["Faut-il", "s'en", "réjouir", "sans", "réserve", "?"],
        anagram=("inversion", "Tour Faut-il… ? Peut-on… ? le verbe passe avant le sujet."),
        error=(
            "Cette alerte est inpossible à ignorer, et Léa garde encore le casque trop longtemps.",
            "Cette alerte est impossible à ignorer, et Léa garde encore le casque trop longtemps.",
            "im- devant p : impossible.",
        ),
        pic_start=0,
        pic_words=_pw(0),
        short_p="Notez trois questions inversées, trois préfixes et un avantage plus un inconvénient.",
        audio="Enregistrez : Faut-il s'en réjouir ? Peut-on vivre avec le fil ? Doit-on tout filtrer ? C'est impossible.",
    ),
    _l(
        "CE",
        "CE — Brève du fil",
        "Lire une brève d'actualité technologique inventée (inversion, préfixes, pour et contre).",
        "Lisez la brève, sans aller trop vite.",
        "Feuille du soir, Radio Figuier",
        """Brève — Le fil relie trois cours
Depuis la dernière lune, la Lampe-Figue porte des voix d'une cour à l'autre. Faut-il y voir un progrès ? Peut-on s'en passer ? Doit-on tout accepter ?
Avantages. On entend une décision loin du banc. On retrace un mot. Un voisin invisible n'est plus tout à fait absent.
Inconvénients. Un message inutile circule aussi vite qu'un message juste. La méfiance grandit. On devient mécontent dès qu'une voix tarde. Déconnecter paraît alors irresponsable, à tort.
Le Filtre des Herbes, d'abord conçu pour l'eau de la rive, sert désormais à écarter les rumeurs trop brutes. Il reste imparfait. Imparfait n'est pas inutile.
Préfixes à tenir : in- (inutile, incomplet, invisible) ; im- (impossible, imprudent, imparfait) ; ir- (irresponsable, irrégulier) ; dé- (déconnecter, débrancher) ; mé- (mécontent, méfiance).
Aline : peut-on vivre avec le fil sans s'y soumettre ? Dieudonné : débrancher reste possible. Solange : une règle, pas une panique.
Marc rappelle : on ne dit pas inpossible. On dit impossible.
Léa a trop porté le casque. Félicie lui a demandé : peux-tu l'enlever ? L'inversion, au Seuil, n'est pas un luxe. C'est une politesse du doute.
Karim : avantage, on retrace une décision ; inconvénient, on déforme une rumeur plus vite.
Sami : trois frappes valent mieux qu'une alerte trop nette. Le fil est irrégulier ? Qu'il le reste.
Rukiri-Nord — à relire avant d'allumer la lampe ce soir.""",
        tf_item=(
            "Le Filtre des Herbes, d'après la brève, est d'abord né pour l'eau de la rive.",
            True,
            "« d'abord conçu pour l'eau de la rive ».",
        ),
        qcm_item=(
            "Que rappelle Marc au sujet du mot « impossible » ?",
            [
                "On dit inpossible",
                "On dit impossible, pas inpossible",
                "On dit dépossible",
                "On dit mépossible",
            ],
            1,
            "im- devant p.",
        ),
        pairs=[
            ("faut-il / peut-on", "questions d'actualité"),
            ("inutile / incomplet", "in-"),
            ("déconnecter", "dé-"),
            ("méfiance", "mé-"),
        ],
        fill_item=("Déconnecter paraît alors ___ , à tort.", "irresponsable"),
        words=["Peut-on", "vivre", "avec", "le", "fil", "sans", "s'y", "soumettre", "?"],
        anagram=("avantage", "Côté utile d'un outil : entendre loin, retracer un mot, relier une cour."),
        error=(
            "Rester allumé sans écoute est irresponsable, et cette alerte reste inpossible à classer sans le Filtre.",
            "Rester allumé sans écoute est irresponsable, et cette alerte reste impossible à classer sans le Filtre.",
            "Impossible, pas inpossible.",
        ),
        pic_start=1,
        pic_words=_pw(1),
        short_p="Recopiez avantages et inconvénients, puis trois questions inversées à vous.",
        audio="Lisez la brève, sans aller trop vite.",
    ),
    _l(
        "PO",
        "PO — Dire Faut-il, Peut-on, c'est impossible",
        "Poser à l'oral des questions inversées et nommer avantages, inconvénients, préfixes.",
        "Répétez, puis débattez une minute : faut-il allumer la Lampe-Figue ce soir ?",
        "Modèles d'Aline et de Lila",
        """Faut-il allumer la lampe ce soir ?
Peut-on s'en passer une heure ?
Doit-on tout filtrer ?
Est-ce utile ? Est-ce souhaitable ?
C'est impossible à ignorer, pas inpossible.
C'est imprudent de rester casqué trop longtemps.
Déconnecter n'est pas irresponsable.
La méfiance grandit trop vite.
Avantage : on retrace un mot.
Inconvénient : une rumeur circule aussi vite.
Lila : l'inversion ouvre le doute. Ce n'est pas un piège.
Marc : im- devant p ou b ; ir- devant r.
Léa : je peux enlever le casque. Puis-je le dire ainsi ? Oui.
Dieudonné : débrancher reste possible. Je l'ai prévu.""",
        tf_item=(
            "Lila présente l'inversion comme une ouverture du doute.",
            True,
            "« l'inversion ouvre le doute. »",
        ),
        qcm_item=(
            "Quelle forme est correcte ?",
            [
                "inpossible",
                "impossible",
                "inprudent",
                "inresponsable",
            ],
            1,
            "im- devant p : impossible.",
        ),
        pairs=[
            ("faut-il", "devoir / question"),
            ("peut-on", "possibilité"),
            ("im- / ir-", "p-b / r"),
            ("dé- / mé-", "enlever / mal"),
        ],
        fill_item=("___-on s'en passer une heure ?", "Peut"),
        words=["Déconnecter", "n'est", "pas", "irresponsable", "."],
        anagram=("prefixe", "Petit morceau devant le mot : in- im- ir- dé- mé-. (sans accent)"),
        error=(
            "Faut-il tout filtrer ce soir, et cette rumeur reste inprudente à répéter sans le banc ?",
            "Faut-il tout filtrer ce soir, et cette rumeur reste imprudente à répéter sans le banc ?",
            "im- devant p : imprudente.",
        ),
        pic_start=2,
        pic_words=_pw(2),
        short_p="Écrivez six questions inversées et quatre mots à préfixe négatif, avec une phrase chacun.",
        audio="Enregistrez les dix premiers modèles, puis deux questions à vous.",
    ),
    _l(
        "PE",
        "PE — Ma brève pour ou contre",
        "Écrire une brève argumentée : actualité de la Lampe-Figue, pour et contre, inversion, préfixes.",
        "Imitez la brève de Léa Niyonzima, sans aller trop vite.",
        "Brève de Léa, casque posé",
        """Léa Niyonzima — Seuil des Sources
Faut-il se réjouir que le fil relie trois cours ? Peut-on s'en passer ? Doit-on tout accepter ? Je pose les trois questions avant d'allumer.
Avantage : j'entends Aline loin du banc, et je retrace un mot que j'avais mal tenu. Ce n'est pas inutile.
Inconvénient : la méfiance. Je deviens mécontente dès qu'une voix tarde. Le casque rend invisible le visage d'en face. C'est imprudent.
On dit impossible, pas inpossible. On dit irresponsable, pas inresponsable. Déconnecter une heure n'est pas irresponsable ; rester allumée sans écoute l'est davantage.
Le Filtre des Herbes reste imparfait. Imparfait n'est pas inutile. Une rumeur trop brute doit pouvoir s'arrêter.
Dieudonné a construit la lampe, non l'obéissance. Aline demande : peut-on vivre avec le fil sans s'y soumettre ? Ma réponse : oui, si l'on ose débrancher.
Faut-il une règle ? Oui. Une panique ? Non. Solange peut dater un usage ; elle ne peut pas interdire une méfiance.
Joël a raison : rester allumée sans écoute est plus grave que déconnecter une soirée.
Yvette : incomplet n'est pas inutile. Invisible n'est pas innocent. Je choisis mes préfixes avec soin.
Je pose le casque. J'écris ceci à la main. Cela n'est pas négligeable.
Léa""",
        tf_item=(
            "Léa considère que déconnecter une heure est irresponsable.",
            False,
            "« Déconnecter une heure n'est pas irresponsable. »",
        ),
        qcm_item=(
            "Que n'a pas construit Dieudonné, selon Léa ?",
            [
                "La lampe",
                "L'obéissance",
                "Le banc",
                "Le figuier",
            ],
            1,
            "« la lampe, non l'obéissance. »",
        ),
        pairs=[
            ("faut-il / peut-on / doit-on", "trois questions"),
            ("méfiance / mécontente", "mé-"),
            ("déconnecter", "n'est pas irresponsable"),
            ("imparfait", "n'est pas inutile"),
        ],
        fill_item=("On dit ___ , pas inpossible.", "impossible"),
        words=["Je", "pose", "le", "casque", "."],
        anagram=("inconvenient", "Côté lourd d'un outil : méfiance, rumeur, visage invisible. (sans accent)"),
        error=(
            "Rester casquée sans visage est inprudent, et le fil continue pourtant d'être utile à la cour.",
            "Rester casquée sans visage est imprudent, et le fil continue pourtant d'être utile à la cour.",
            "im- devant p : imprudent.",
        ),
        pic_start=3,
        pic_words=_pw(3),
        short_p="Imitez : douze à quinze lignes, trois inversions, quatre préfixes, un pour, un contre.",
        audio="Lisez votre brève, sans aller trop vite.",
    ),
    _l(
        "EL",
        "EL — Inversion et préfixes négatifs",
        "Retenir l'inversion interrogative et les préfixes in- im- ir- dé- mé-.",
        "Apprenez la fiche.",
        "Fiche d'Aline, actualité du fil",
        """Inversion : verbe + sujet (+ complément)
Faut-il + infinitif ? Peut-on + infinitif ? Doit-on + infinitif ?
Est-ce utile ? L'inversion n'est pas un luxe : elle ouvre le doute.
Préfixes négatifs ou de retournement :
in- : inutile, incomplet, invisible, innocent (attention au sens)
im- devant p ou b : impossible, imprudent, imparfait (pas inpossible, inprudent)
ir- devant r : irresponsable, irrégulier (pas inresponsable)
dé- : déconnecter, débrancher (enlever le lien)
mé- : mécontent, méfiance (mal, à côté)
Avantage / inconvénient : deux colonnes, un critère, une conclusion mesurée.
On peut vivre avec le fil sans s'y soumettre. Débrancher reste possible.
Éviter : je faut (toujours il faut). Faut-il = il faut, inversé.
Bien que + subj. : bien que ce soit imparfait, l'outil sert.
À + le = au fil ; de + le = du casque.""",
        tf_item=(
            "On écrit « inprudent » devant un p.",
            False,
            "imprudent.",
        ),
        qcm_item=(
            "Quelle série est juste ?",
            [
                "inpossible / inprudent / inresponsable",
                "impossible / imprudent / irresponsable",
                "dépossible / méprudent / irinutile",
                "in- devant toutes les lettres",
            ],
            1,
            "im- / ir- selon la lettre qui suit.",
        ),
        pairs=[
            ("faut-il", "il faut inversé"),
            ("im- / ir-", "p-b / r"),
            ("dé-", "enlever le lien"),
            ("mé-", "mal / à côté"),
        ],
        fill_item=("___-il allumer la lampe ce soir ?", "Faut"),
        words=["C'est", "impossible", "à", "ignorer", "."],
        anagram=("question", "Phrase inversée qui ouvre un doute, pas un piège."),
        error=(
            "Doit-on tout filtrer ce soir, et ce voisin n'est pas inresponsable s'il débranche une heure ?",
            "Doit-on tout filtrer ce soir, et ce voisin n'est pas irresponsable s'il débranche une heure ?",
            "ir- devant r : irresponsable.",
        ),
        pic_start=4,
        pic_words=_pw(4),
        short_p="Tableau : cinq préfixes, deux mots chacun, plus six questions inversées.",
        audio="Enregistrez la fiche et six formes : Faut-il, Peut-on, impossible, imprudent, irresponsable, déconnecter.",
    ),
]


# ---------------------------------------------------------------------------
# Séquence 2 — Évolution sociétale
# ---------------------------------------------------------------------------

S2 = [
    _l(
        "CO",
        "CO — Depuis que le fil existe",
        "Repérer l'expression de la durée : depuis que, il y a… que, ça fait… que, en + durée.",
        "Lisez le dialogue. Depuis quand le fil change-t-il la cour, et en combien de temps ?",
        "Banc du figuier, graphique d'usage",
        """Aline : Depuis que le fil existe, on s'assemble autrement. On ne s'assemble pas moins : on s'assemble plus tôt, parfois trop tôt.
Léa : Il y a trois lunes que je porte trop souvent le casque. Ça fait deux saisons que Patrick me le dit.
Patrick : En une soirée, une rumeur traverse trois cours. En trois soirs, une habitude s'installe. La durée n'est pas un détail.
Marc : Depuis que Dieudonné a posé la troisième lampe, le graphique d'usage grimpe. Ce n'est pas une preuve de sagesse.
Hawa : Ça fait une lune que le Marché des Lampions vend des « relais » inventés. Depuis lors, certains croient que plus vite veut dire mieux.
Joël : Il y a longtemps que Sami refuse de frapper dans le bruit du fil. Depuis qu'il s'est tu un jeudi, on l'écoute davantage.
Rose : En deux après-midi, j'ai cousu une housse pour la lampe. Depuis que la housse existe, on ose l'éteindre.
Solange : Le Bureau date depuis le premier fil. Il y a un an que le tampon suit l'usage, pas l'inverse.
Karim : Depuis que l'on mesure, on compare. En six jeudis, on a trop comparé.
Lila : Radio Figuier répète : ça fait trop longtemps que l'on parle du fil sans parler du banc.
Dieudonné : J'y travaille depuis la saison sèche. En trois soirs, on peut apprendre à débrancher. Il y a trop longtemps que l'on croit le contraire.
Yvette : Depuis que les enfants imitent le casque, la cour a une responsabilité de plus.
Félicie : Ça fait une heure que Léa n'a pas levé les yeux. Il y a assez longtemps que cela dure.
Sami : Depuis que le fil vibre, je compte plus lentement. En trois frappes, le temps revient.""",
        tf_item=(
            "Patrick dit qu'une habitude peut s'installer en trois soirs.",
            True,
            "« En trois soirs, une habitude s'installe. »",
        ),
        qcm_item=(
            "Que permet la housse de Rose, depuis qu'elle existe ?",
            [
                "D'interdire le thé",
                "D'oser éteindre la lampe",
                "De vendre le fil",
                "De fermer le Bureau",
            ],
            1,
            "« on ose l'éteindre. »",
        ),
        pairs=[
            ("depuis que + indicatif", "le fil existe / la housse existe"),
            ("il y a… que", "trois lunes / longtemps"),
            ("ça fait… que", "deux saisons / une heure"),
            ("en + durée", "une soirée / trois soirs"),
        ],
        fill_item=("___ que le fil existe, on s'assemble autrement.", "Depuis"),
        words=["En", "trois", "soirs", "une", "habitude", "s'installe", "."],
        anagram=("duree", "Temps qui passe : depuis que, il y a… que, ça fait… que, en. (sans accent)"),
        error=(
            "Depuis que le fil a existé demain, on s'assemble trop tôt, et le graphique grimpe sans sagesse.",
            "Depuis que le fil existe, on s'assemble trop tôt, et le graphique grimpe sans sagesse.",
            "Depuis que + indicatif présent pour un fait qui continue.",
        ),
        pic_start=5,
        pic_words=_pw(5),
        short_p="Notez six expressions de durée entendues et le changement qu'elles mesurent.",
        audio="Enregistrez : Depuis que le fil existe. Il y a trois lunes que. Ça fait deux saisons que. En trois soirs.",
    ),
    _l(
        "CE",
        "CE — Chronique d'une habitude",
        "Lire un texte sur l'évolution de la cour depuis l'arrivée du fil.",
        "Lisez la chronique, sans aller trop vite.",
        "Chronique de Lila, horloge du studio",
        """Chronique — Depuis que le fil a rejoint le figuier
Depuis que la Lampe-Figue relie trois cours, le Seuil n'a pas perdu le banc. Il l'a parfois oublié une heure, ce qui n'est pas la même chose.
Il y a trois lunes que Léa porte trop le casque. Ça fait deux saisons que Patrick le lui dit, et ça fait une heure, ce soir, qu'elle n'a pas levé les yeux.
En une soirée, une rumeur traverse le fil. En trois soirs, une habitude s'installe. En six jeudis, on croit que cela a toujours existé.
Depuis que Rose a cousu la housse, on ose éteindre. Depuis que Sami s'est tu un jeudi, on frappe moins par-dessus les voix.
Dieudonné y travaille depuis la saison sèche. Il y a trop longtemps que l'on croit débrancher impossible. En trois soirs, on peut l'apprendre.
Le Bureau date depuis le premier fil. Solange : le tampon suit l'usage, pas l'inverse. Il y a un an que cette phrase tient.
Aline : depuis que l'on mesure, on compare trop. Karim : en six jeudis, le graphique a remplacé trop de conversations.
Ce que la chronique refuse, c'est de confondre vitesse et évolution. Une société peut changer en douceur. Elle peut aussi se presser en vain.
Yvette : depuis que les enfants imitent le casque, la cour a une responsabilité de plus.
Sami : depuis que le fil vibre, je compte plus lentement. En trois frappes, le temps revient.
Rukiri-Nord — à lire avant de croire que « depuis toujours » veut dire « depuis le fil ».""",
        tf_item=(
            "La chronique affirme que le Seuil a perdu le banc depuis le fil.",
            False,
            "« n'a pas perdu le banc. Il l'a parfois oublié une heure. »",
        ),
        qcm_item=(
            "En combien de soirs une habitude peut-elle s'installer, d'après le texte ?",
            [
                "En une saison seulement",
                "En trois soirs",
                "En dix ans",
                "En une minute obligatoire",
            ],
            1,
            "« En trois soirs, une habitude s'installe. »",
        ),
        pairs=[
            ("depuis que", "la lampe relie / Rose a cousu"),
            ("il y a… que", "trois lunes / un an"),
            ("ça fait… que", "deux saisons / une heure"),
            ("en + durée", "une soirée / trois soirs / six jeudis"),
        ],
        fill_item=("___ fait deux saisons que Patrick le lui dit.", "Ça"),
        words=["Depuis", "que", "Rose", "a", "cousu", "la", "housse", "on", "ose", "éteindre", "."],
        anagram=("habitude", "Geste répété qui s'installe parfois en trois soirs seulement."),
        error=(
            "Il y a trois lunes depuis que je porte le casque, et Patrick me le dit encore ce soir sous l'arbre.",
            "Il y a trois lunes que je porte le casque, et Patrick me le dit encore ce soir sous l'arbre.",
            "Il y a + durée + que (pas depuis que après il y a + durée).",
        ),
        pic_start=6,
        pic_words=_pw(6),
        short_p="Recopiez quatre phrases de durée et expliquez le changement mesuré.",
        audio="Lisez la chronique, sans aller trop vite.",
    ),
    _l(
        "PO",
        "PO — Dire depuis que, ça fait… que",
        "Exprimer à l'oral une durée et une évolution de la cour.",
        "Répétez, puis racontez depuis quand le fil a changé un geste à vous.",
        "Modèles de Patrick et d'Aline",
        """Depuis que le fil existe, on s'assemble autrement.
Il y a trois lunes que je porte trop le casque.
Ça fait deux saisons que l'on en parle.
En trois soirs, une habitude s'installe.
Depuis que la housse existe, on ose éteindre.
Il y a longtemps que Sami refuse le bruit.
Ça fait une heure qu'elle n'a pas levé les yeux.
En une soirée, une rumeur traverse trois cours.
Aline : depuis que + indicatif. Le fait continue.
Marc : il y a… que / ça fait… que : même idée, tons différents.
Léa : en + durée = le temps nécessaire, pas le point de départ.
Joël : ne mélangez pas « depuis que » et « il y a… que » dans la même attache.
Rose : une évolution se dit avec un avant et un après.
Yvette : finissez par ce qui a changé, pas seulement par l'horloge.""",
        tf_item=(
            "« En trois soirs » indique le temps nécessaire, non le point de départ.",
            True,
            "Léa : en + durée = temps nécessaire.",
        ),
        qcm_item=(
            "Quelle phrase est correcte ?",
            [
                "Il y a trois lunes depuis que je porte",
                "Il y a trois lunes que je porte le casque",
                "Depuis que il y a trois lunes que",
                "En depuis trois soirs que",
            ],
            1,
            "Il y a + durée + que.",
        ),
        pairs=[
            ("depuis que", "point de départ encore vrai"),
            ("il y a… que", "durée écoulée"),
            ("ça fait… que", "durée, ton plus oral"),
            ("en + durée", "temps nécessaire"),
        ],
        fill_item=("___ trois soirs, une habitude s'installe.", "En"),
        words=["Ça", "fait", "une", "heure", "qu'elle", "n'a", "pas", "levé", "les", "yeux", "."],
        anagram=("evolution", "Changement d'une cour dans le temps, ni trop vanté ni nié. (sans accent)"),
        error=(
            "Depuis que le fil existe encore demain matin, on compare trop, et le graphique remplace la conversation.",
            "Depuis que le fil existe, on compare trop, et le graphique remplace la conversation.",
            "Depuis que + fait présent qui dure, pas un futur.",
        ),
        pic_start=7,
        pic_words=_pw(7),
        short_p="Écrivez huit phrases : deux depuis que, deux il y a… que, deux ça fait… que, deux en + durée.",
        audio="Enregistrez les huit premiers modèles, puis trois phrases à vous.",
    ),
    _l(
        "PE",
        "PE — Mon évolution depuis le fil",
        "Écrire un texte argumenté sur une évolution, avec des expressions de durée.",
        "Imitez la note de Patrick Habimana, sans aller trop vite.",
        "Note de Patrick, horloge ocre",
        """Patrick Habimana — Seuil des Sources
Depuis que le fil existe, je n'ai pas perdu Léa. Je l'ai parfois perdue une heure, ce qui n'est pas la même chose.
Il y a trois lunes qu'elle porte trop le casque. Ça fait deux saisons que je le lui dis, et ça fait une heure, ce soir, qu'elle n'a pas levé les yeux.
En une soirée, une rumeur traverse trois cours. En trois soirs, une habitude s'installe. En six jeudis, on croit que cela a toujours existé. Je refuse cette illusion.
Depuis que Rose a cousu la housse, on ose éteindre. Depuis que Sami s'est tu un jeudi, on écoute davantage. Ce sont deux évolutions que je défends.
Dieudonné y travaille depuis la saison sèche. Il y a trop longtemps que l'on croit débrancher impossible. En trois soirs, on peut l'apprendre. J'ai commencé.
Aline a raison : depuis que l'on mesure, on compare trop. Le graphique n'est pas une sagesse.
Je n'accuse pas la lampe. J'accuse une durée mal dite. « Depuis toujours » ne veut pas dire « depuis le fil ».
Lila répète : ça fait trop longtemps que l'on parle du fil sans parler du banc. Je m'y range.
En une soirée on peut s'inquiéter. En trois soirs on peut apprendre. Je choisis la seconde durée.
Félicie : ça fait une heure que Léa n'a pas levé les yeux. Il y a assez longtemps que cela dure, et je l'écris sans colère.
Patrick""",
        tf_item=(
            "Patrick dit qu'il a perdu Léa depuis que le fil existe.",
            False,
            "Il ne l'a pas perdue ; il l'a parfois perdue une heure.",
        ),
        qcm_item=(
            "Que refuse Patrick comme illusion ?",
            [
                "Le thé du jeudi",
                "Croire qu'une habitude récente a toujours existé",
                "La housse de Rose",
                "Les trois frappes",
            ],
            1,
            "En six jeudis, on croit que cela a toujours existé.",
        ),
        pairs=[
            ("depuis que le fil existe", "on n'a pas perdu"),
            ("il y a trois lunes que", "le casque"),
            ("en trois soirs", "une habitude"),
            ("depuis que Rose a cousu", "on ose éteindre"),
        ],
        fill_item=("___ fait deux saisons que je le lui dis.", "Ça"),
        words=["En", "six", "jeudis", "on", "croit", "que", "cela", "a", "toujours", "existé", "."],
        anagram=("graphique", "Dessin d'usage qui grimpe, sans prouver à lui seul une sagesse."),
        error=(
            "Ça fait deux saisons depuis que je le lui dis, et elle n'a pas levé les yeux depuis une heure.",
            "Ça fait deux saisons que je le lui dis, et elle n'a pas levé les yeux depuis une heure.",
            "Ça fait + durée + que (un seul attache).",
        ),
        pic_start=8,
        pic_words=_pw(8),
        short_p="Imitez : treize à seize lignes, au moins six expressions de durée, un avant et un après.",
        audio="Lisez votre note, sans aller trop vite.",
    ),
    _l(
        "EL",
        "EL — Exprimer la durée",
        "Retenir depuis que, il y a… que, ça fait… que, en + durée, et leurs pièges.",
        "Apprenez la fiche.",
        "Fiche d'Aline, durée",
        """depuis que + indicatif : le point de départ dure encore
Depuis que le fil existe, on s'assemble autrement.
depuis + nom / date : depuis la saison sèche, depuis jeudi, depuis trois lunes
il y a + durée + que + indicatif : Il y a trois lunes que je porte le casque.
ça fait + durée + que : plus oral, même idée. Ça fait une heure qu'elle n'a pas levé les yeux.
en + durée : temps nécessaire pour un résultat. En trois soirs, on apprend à débrancher.
Pièges :
ne pas écrire « il y a trois lunes depuis que » (double attache)
ne pas mettre un futur après depuis que si le fait dure maintenant
depuis ≠ pendant (pendant = toute la période, souvent close)
Évolution : un avant, un après, un critère. Le graphique n'est pas une sagesse.
« Depuis toujours » ne veut pas dire « depuis le fil ».
Bien que + subj. : bien que cela fasse deux saisons, le débat tient.
À + le = au graphique ; de + le = du casque.""",
        tf_item=(
            "« Depuis » et « pendant » disent toujours la même chose.",
            False,
            "Pendant couvre une période, souvent close ; depuis ouvre un point encore vrai.",
        ),
        qcm_item=(
            "Quelle phrase est fautive ?",
            [
                "Depuis que le fil existe on s'assemble autrement",
                "Il y a trois lunes que je porte le casque",
                "Il y a trois lunes depuis que je porte",
                "Ça fait une heure qu'elle n'a pas levé les yeux",
            ],
            2,
            "Double attache : il y a… depuis que.",
        ),
        pairs=[
            ("depuis que", "point de départ encore vrai"),
            ("il y a… que", "durée écoulée"),
            ("ça fait… que", "durée plus orale"),
            ("en + durée", "temps nécessaire"),
        ],
        fill_item=("___ la saison sèche, Dieudonné y travaille.", "Depuis"),
        words=["En", "trois", "soirs", "on", "peut", "l'apprendre", "."],
        anagram=("depuis", "Mot qui ouvre un point de départ encore vrai, avant que ou un nom."),
        error=(
            "Pendant que trois lunes que je porte le casque, Patrick me le dit encore sous le figuier.",
            "Il y a trois lunes que je porte le casque, et Patrick me le dit encore sous le figuier.",
            "Il y a + durée + que ; garder la seconde clause.",
        ),
        pic_start=9,
        pic_words=_pw(9),
        short_p="Construisez douze phrases : trois par tour de durée, sur le fil et le banc.",
        audio="Enregistrez la fiche et quatre modèles, un par tour.",
    ),
]


# ---------------------------------------------------------------------------
# Séquence 3 — Mémoire et réseaux
# ---------------------------------------------------------------------------

S3 = [
    _l(
        "CO",
        "CO — Relire, reconstruire, retracer",
        "Repérer le préfixe re- et les liens de cause et de conséquence.",
        "Lisez le dialogue. Pourquoi retrace-t-on, et qu'est-ce qui s'ensuit ?",
        "Archives de Radio Figuier, nuage de mémoire",
        """Lila : On relit trop peu les voix du fil. On les réécoute, parfois. On les reconstruit, souvent, et mal.
Aline : Puisque le fil garde une trace, retracer devient possible. Parce que la trace est incomplète, reconstruire reste un risque.
Léa : J'ai relu le mot de jeudi. Je l'ai mal compris, si bien que j'ai répondu trop vite.
Patrick : On reprend une phrase, on la replace, on la retrace. Si l'on se presse, on la refait à l'envers.
Marc : Parce que n'est pas puisque. Parce que donne une cause. Puisque présente une cause déjà connue, presque évidente.
Hawa : Le réseau du fil relie. Il ne remplace pas la mémoire du banc. On peut retenir un visage sans le répéter à l'antenne.
Joël : On a trop répété une rumeur, de sorte que trois cours l'ont crue. Conséquence, pas intention.
Rose : Je recouds la housse. Je ne réinvente pas la lampe. Re- n'est pas toujours « encore une fois mieux ».
Solange : Le Bureau relit les dates. Il ne reconstruira pas un souvenir. Puisque la date est là, on peut au moins s'y accorder.
Karim : Parce que l'on mesure tout, on oublie de se taire, si bien que la mémoire devient un bruit.
Dieudonné : J'ai reconstruit le premier relais. Je l'ai refait, parce qu'il était irrégulier. Je ne le répéterai pas pour le plaisir.
Sami : On reprend le silence. On le replace. Sinon le fil le recouvre.
Yvette : Cause : parce que / puisque. Conséquence : si bien que / de sorte que. Tenez-les séparées.
Félicie : Léa a réécouté. Elle a relu. Elle a relevé le casque, de sorte que le visage d'en face est revenu.""",
        tf_item=(
            "Marc distingue « parce que » (cause) et « puisque » (cause déjà connue).",
            True,
            "Parce que donne une cause ; puisque la présente comme connue.",
        ),
        qcm_item=(
            "Pourquoi Léa a-t-elle répondu trop vite ?",
            [
                "Parce que Sami a interdit le fil",
                "Parce qu'elle a mal compris le mot, si bien qu'elle a répondu trop vite",
                "Parce que Solange a fermé le Bureau",
                "Parce que Rose a vendu la housse",
            ],
            1,
            "Mal compris, si bien que réponse trop vite.",
        ),
        pairs=[
            ("relire / réécouter / retracer", "préfixe re-"),
            ("parce que", "cause"),
            ("puisque", "cause déjà connue"),
            ("si bien que / de sorte que", "conséquence"),
        ],
        fill_item=("___ le fil garde une trace, retracer devient possible.", "Puisque"),
        words=["On", "relit", "trop", "peu", "les", "voix", "du", "fil", "."],
        anagram=("retracer", "Suivre à nouveau le chemin d'un mot, d'une décision, d'une rumeur."),
        error=(
            "On a trop répété cette rumeur, parce que trois cours l'ont crue sans revenir au banc.",
            "On a trop répété cette rumeur, si bien que trois cours l'ont crue sans revenir au banc.",
            "Conséquence : si bien que, pas parce que.",
        ),
        pic_start=10,
        pic_words=_pw(10),
        short_p="Notez cinq verbes en re- et quatre liens (deux causes, deux conséquences).",
        audio="Enregistrez : On relit. On reconstruit. On retrace. Parce que la trace est incomplète. Si bien que j'ai répondu trop vite.",
    ),
    _l(
        "CE",
        "CE — Mémoire du fil, mémoire du banc",
        "Lire un texte sur mémoire et réseau : re-, cause et conséquence.",
        "Lisez le texte, sans aller trop vite.",
        "Note d'Aline, antenne et banc",
        """Note — Relire n'est pas reconstruire
Le fil de Radio Figuier garde des traces. Puisque ces traces existent, retracer un mot devient possible. Parce qu'elles sont incomplètes, reconstruire reste un risque.
On relit trop peu. On réécoute parfois. On reprend une phrase, on la replace, on la refait à l'envers si l'on se presse.
Léa a mal compris le mot de jeudi, si bien qu'elle a répondu trop vite. Elle a ensuite relu, réécouté, relevé le casque, de sorte que le visage d'en face est revenu.
Joël : on a trop répété une rumeur, de sorte que trois cours l'ont crue. Ce n'était pas une intention. C'était une conséquence.
Marc : parce que n'est pas puisque. Tenez la cause juste. Karim : parce que l'on mesure tout, on oublie de se taire, si bien que la mémoire devient un bruit.
Le réseau relie. Il ne remplace pas la mémoire du banc. On peut retenir un visage sans le répéter à l'antenne.
Dieudonné a reconstruit le premier relais, parce qu'il était irrégulier. Il ne le répétera pas pour le plaisir.
Rose recoud. Solange relit les dates. Sami reprend le silence. Chacun son re-, chacun sa responsabilité.
Hawa : le réseau relie. Il ne remplace pas. On peut retenir un visage sans le répéter à l'antenne, je le redis.
Yvette : tenez cause et conséquence séparées, ou le raisonnement se brouille.
Rukiri-Nord — à relire avant de reconstruire une voix que l'on n'a pas vraiment entendue.""",
        tf_item=(
            "D'après la note, le réseau remplace la mémoire du banc.",
            False,
            "« Il ne remplace pas la mémoire du banc. »",
        ),
        qcm_item=(
            "Pourquoi Dieudonné a-t-il reconstruit le premier relais ?",
            [
                "Pour le plaisir de répéter",
                "Parce qu'il était irrégulier",
                "Parce que Rose l'a demandé au marché",
                "Parce que le figuier l'exigeait",
            ],
            1,
            "« parce qu'il était irrégulier. »",
        ),
        pairs=[
            ("puisque les traces existent", "retracer possible"),
            ("parce qu'elles sont incomplètes", "reconstruire risqué"),
            ("si bien que", "réponse trop vite"),
            ("de sorte que", "visage revenu / rumeur crue"),
        ],
        fill_item=("On a trop répété une rumeur, ___ sorte que trois cours l'ont crue.", "de"),
        words=["Le", "réseau", "relie", "il", "ne", "remplace", "pas", "la", "mémoire", "."],
        anagram=("memoire", "Ce que le banc garde d'un visage, au-delà d'une trace du fil. (sans accent)"),
        error=(
            "Puisque Léa a mal compris le mot, si bien qu'elle a répondu trop vite, et Patrick a attendu le visage.",
            "Léa a mal compris le mot, si bien qu'elle a répondu trop vite, et Patrick a attendu le visage.",
            "Une seule attache de conséquence : si bien que. Puisque en trop.",
        ),
        pic_start=11,
        pic_words=_pw(11),
        short_p="Recopiez deux causes et deux conséquences. Ajoutez trois verbes en re- à vous.",
        audio="Lisez la note, sans aller trop vite.",
    ),
    _l(
        "PO",
        "PO — Dire re-, parce que, si bien que",
        "Employer à l'oral le préfixe re- et les liens de cause / conséquence.",
        "Répétez, puis racontez une erreur de fil : cause et conséquence.",
        "Modèles de Marc et de Lila",
        """On relit trop peu.
On retrace un mot.
On reconstruit trop vite.
Parce que la trace est incomplète, le risque existe.
Puisque le fil garde une trace, retracer est possible.
J'ai mal compris, si bien que j'ai répondu trop vite.
On a trop répété, de sorte que trois cours l'ont crue.
Je relève le casque, de sorte que le visage revient.
Aline : re- = à nouveau, parfois « en arrière », pas toujours « mieux ».
Marc : parce que = cause ; puisque = cause déjà connue.
Léa : si bien que / de sorte que = conséquence.
Patrick : une cause n'est pas une excuse. Une conséquence n'est pas une intention.
Karim : tenez-les séparées, ou le raisonnement se brouille.
Yvette : finissez par ce que vous ferez ensuite : relire, ou vous taire.""",
        tf_item=(
            "« Re- » veut toujours dire « encore une fois, mieux ».",
            False,
            "Aline : pas toujours « mieux » ; parfois simplement à nouveau.",
        ),
        qcm_item=(
            "Quel couple exprime surtout une conséquence ?",
            [
                "parce que / puisque",
                "si bien que / de sorte que",
                "depuis que / en",
                "faut-il / peut-on",
            ],
            1,
            "Si bien que et de sorte que.",
        ),
        pairs=[
            ("relire / retracer", "à nouveau"),
            ("parce que", "cause"),
            ("puisque", "cause connue"),
            ("si bien que", "conséquence"),
        ],
        fill_item=("J'ai mal compris, ___ bien que j'ai répondu trop vite.", "si"),
        words=["On", "retrace", "un", "mot", "sans", "le", "refaire", "à", "l'envers", "."],
        anagram=("consequence", "Effet qui suit une cause : si bien que, de sorte que. (sans accent)"),
        error=(
            "Parce que l'on mesure tout si bien que la mémoire devient un bruit, et Karim refuse ce mélange.",
            "Parce que l'on mesure tout, la mémoire devient un bruit, et Karim refuse ce mélange.",
            "Une cause, puis un fait. Pas deux attaches collées.",
        ),
        pic_start=12,
        pic_words=_pw(12),
        short_p="Écrivez dix phrases : cinq verbes en re-, deux parce que, un puisque, un si bien que, un de sorte que.",
        audio="Enregistrez les huit premiers modèles, puis une mini-histoire cause / conséquence.",
    ),
    _l(
        "PE",
        "PE — Ma note de mémoire",
        "Écrire un texte sur mémoire et réseaux, avec re- et des liens de cause / conséquence.",
        "Imitez la note de Lila Sow, sans aller trop vite.",
        "Note de Lila, studio",
        """Lila Sow — Radio Figuier, Rukiri-Nord
On relit trop peu les voix du fil. On les réécoute, parfois. On les reconstruit, souvent, et mal, parce que la trace est incomplète.
Puisque le fil garde malgré tout une marque, retracer un mot devient possible. Je le fais. Je ne le refais pas à l'envers pour le plaisir.
J'ai laissé trop répéter une rumeur jeudi, de sorte que trois cours l'ont crue. Ce n'était pas mon intention. C'était une conséquence. Je la reconnais.
Léa a mal compris un mot, si bien qu'elle a répondu trop vite. Elle a ensuite relu, réécouté, relevé le casque, de sorte que le visage d'en face est revenu. Voilà une mémoire qui se répare.
Le réseau relie. Il ne remplace pas le banc. On peut retenir un visage sans le répéter à l'antenne.
Dieudonné a reconstruit le premier relais, parce qu'il était irrégulier. Rose recoud. Solange relit les dates. Sami reprend le silence. Chacun son re-.
Parce que l'on mesure tout, on oublie de se taire, si bien que la mémoire devient un bruit. Je refuse ce bruit à l'antenne.
Félicie a vu Léa relever le casque : le visage est revenu. C'est une conséquence que je veux relayer.
Sami reprend le silence. Sinon le fil le recouvre. Je veux que l'antenne s'en souvienne.
Je relirai cette note demain. Si je la reconstruis trop, je l'aurai trahie.
Lila""",
        tf_item=(
            "Lila nie toute responsabilité dans la rumeur du jeudi.",
            False,
            "Elle reconnaît la conséquence : trois cours l'ont crue.",
        ),
        qcm_item=(
            "Que ne remplace pas le réseau, selon Lila ?",
            [
                "Le tampon",
                "Le banc",
                "Le thé",
                "Le marché",
            ],
            1,
            "« Il ne remplace pas le banc. »",
        ),
        pairs=[
            ("parce que la trace est incomplète", "on reconstruit mal"),
            ("puisque une marque reste", "retracer possible"),
            ("de sorte que", "trois cours / visage revenu"),
            ("si bien que", "réponse trop vite / mémoire-bruit"),
        ],
        fill_item=("On peut ___ un visage sans le répéter à l'antenne.", "retenir"),
        words=["Le", "réseau", "relie", "il", "ne", "remplace", "pas", "le", "banc", "."],
        anagram=("reconstruire", "Refaire un ensemble à partir de traces, au risque de se tromper."),
        error=(
            "J'ai laissé trop répéter cette rumeur, parce que trois cours l'ont crue, et je le reconnais ce soir.",
            "J'ai laissé trop répéter cette rumeur, de sorte que trois cours l'ont crue, et je le reconnais ce soir.",
            "Conséquence : de sorte que.",
        ),
        pic_start=13,
        pic_words=_pw(13),
        short_p="Imitez : treize à seize lignes, au moins cinq re-, deux causes, deux conséquences.",
        audio="Lisez votre note, sans aller trop vite.",
    ),
    _l(
        "EL",
        "EL — Re- , cause et conséquence",
        "Retenir le préfixe re- et les articulations parce que, puisque, si bien que, de sorte que.",
        "Apprenez la fiche.",
        "Fiche d'Aline, mémoire",
        """re- : à nouveau, en arrière, parfois « en réponse »
relire, réécouter, reconstruire, retracer, reprendre, replacer, refaire, retenir, recoudre, relevé
Ré- devant voyelle : réécouter, répéter, réinventer (accent, euphonie)
re- n'est pas toujours « mieux ». Reconstruire trop vite, c'est souvent se tromper.
Cause :
parce que + indicatif : cause à expliquer (neutre)
puisque + indicatif : cause déjà connue, presque évidente
Conséquence :
si bien que + indicatif : résultat, souvent inattendu
de sorte que + indicatif : résultat (parfois une visée, selon le contexte)
Pièges : ne pas coller parce que et si bien que sans virgule / sans besoin
ne pas prendre une conséquence pour une intention
ne pas écrire parce que pour un résultat (trois cours l'ont crue → si bien que / de sorte que)
Mémoire du fil ≠ mémoire du banc. Relier n'est pas remplacer.
Bien que + subj. : bien que l'on retrace, on peut se tromper.""",
        tf_item=(
            "« Puisque » présente souvent une cause déjà connue.",
            True,
            "Presque évidente pour l'interlocuteur.",
        ),
        qcm_item=(
            "Pour un résultat non voulu, on préfère…",
            [
                "puisque seulement",
                "si bien que / de sorte que",
                "faut-il",
                "im- devant p",
            ],
            1,
            "Conséquence, pas cause.",
        ),
        pairs=[
            ("re-", "à nouveau / en arrière"),
            ("parce que", "cause à expliquer"),
            ("puisque", "cause connue"),
            ("si bien que", "conséquence"),
        ],
        fill_item=("___ le fil garde une marque, retracer est possible.", "Puisque"),
        words=["Relire", "n'est", "pas", "reconstruire", "."],
        anagram=("parceque", "Attache de cause neutre, en un mot d'exercice, sans espace."),
        error=(
            "On a trop laissé déformer ce mot, parce que trois cours l'ont déjà cru, et le banc n'y reconnaît plus rien.",
            "On a trop laissé déformer ce mot, si bien que trois cours l'ont déjà cru, et le banc n'y reconnaît plus rien.",
            "Résultat : si bien que, pas parce que.",
        ),
        pic_start=14,
        pic_words=_pw(14),
        short_p="Tableau : huit verbes en re-, deux parce que, deux puisque, deux si bien que, deux de sorte que.",
        audio="Enregistrez la fiche et six phrases, deux par type de lien, plus deux re-.",
    ),
]


# ---------------------------------------------------------------------------
# Séquence 4 — Raisonnement sur la déconnexion
# ---------------------------------------------------------------------------

S4 = [
    _l(
        "CO",
        "CO — Or le banc est encore là",
        "Suivre un raisonnement : en effet, or, aussi, ainsi, toutefois, par conséquent, en revanche.",
        "Lisez le dialogue. Qui relie quelle idée à quelle idée ?",
        "Cercle sous le figuier, interrupteur de la lampe",
        """Aline : Il faut raisonner, pas seulement s'indigner. En effet, la lampe n'est ni un ennemi ni un maître.
Léa : Je veux déconnecter une heure. Or le fil continue sans moi. Ainsi je découvre que la cour tient encore.
Patrick : Toutefois, une heure ne suffit pas si l'on y revient plus fébrile. En revanche, trois soirs apprennent la main.
Marc : Aussi faut-il distinguer envie et besoin. Aussi, ici, inverse : aussi faut-il, pas aussi on doit.
Hawa : Par conséquent, débrancher n'est pas trahir. C'est vérifier qu'un lien existe encore hors du fil.
Joël : En revanche, imposer le silence à tous serait une autre violence. Le milieu tient les deux bords.
Rose : En effet, la housse sert à cela : cacher la lumière, pas casser l'outil.
Solange : Or le Bureau ne peut pas dater une âme. Toutefois, il peut dater une pause collective.
Karim : Ainsi, un raisonnement a des charnières. Sans elles, ce n'est qu'une suite de colères.
Lila : À l'antenne, je dirai « toutefois » et « par conséquent ». Sous l'arbre, « or » sonne juste, s'il ouvre un fait.
Dieudonné : J'ai prévu l'interrupteur. En effet, un outil sans arrêt n'est plus un outil.
Sami : Aussi resterai-je à trois frappes. En revanche, je ne frapperai pas pour couvrir un débat.
Yvette : Connecteurs : en effet (preuve), or (fait qui tourne), aussi + inversion (conséquence soutenue), ainsi (manière / résultat), toutefois (réserve), par conséquent (conclusion), en revanche (contraste).
Félicie : Léa a posé le casque. Or son visage est revenu. Par conséquent, le banc a gagné une heure.""",
        tf_item=(
            "Marc rappelle qu'aussi, dans ce sens, entraîne une inversion : aussi faut-il.",
            True,
            "Aussi faut-il, pas aussi on doit.",
        ),
        qcm_item=(
            "Que vérifie Hawa en débranchant ?",
            [
                "Que le marché ferme",
                "Qu'un lien existe encore hors du fil",
                "Que Solange interdit le thé",
                "Que Sami vend le tambour",
            ],
            1,
            "« vérifier qu'un lien existe encore hors du fil. »",
        ),
        pairs=[
            ("en effet", "preuve / justification"),
            ("or", "fait qui tourne"),
            ("aussi + inversion", "conséquence soutenue"),
            ("toutefois / en revanche", "réserve / contraste"),
        ],
        fill_item=("___ faut-il distinguer envie et besoin.", "Aussi"),
        words=["Par", "conséquent", "débrancher", "n'est", "pas", "trahir", "."],
        anagram=("connecteur", "Mot qui articule une preuve, un tournant, une réserve, une conclusion."),
        error=(
            "Aussi on doit distinguer envie et besoin, et le banc attend encore une heure de visage.",
            "Aussi faut-il distinguer envie et besoin, et le banc attend encore une heure de visage.",
            "Aussi + inversion : aussi faut-il.",
        ),
        pic_start=15,
        pic_words=_pw(15),
        short_p="Notez sept connecteurs entendus et l'idée que chacun attache.",
        audio="Enregistrez : En effet la lampe n'est pas un maître. Or le fil continue. Aussi faut-il distinguer. Toutefois une heure ne suffit pas.",
    ),
    _l(
        "CE",
        "CE — Raisonner la pause",
        "Lire un texte argumenté sur la déconnexion, articulé par des connecteurs.",
        "Lisez le texte, sans aller trop vite.",
        "Feuille d'Aline, banc sans fil",
        """Texte — Déconnecter sans se perdre
On accuse trop vite la Lampe-Figue. En effet, l'outil n'allume pas tout seul : une main le fait.
Or le fil continue lorsqu'une personne s'arrête. Ainsi l'on découvre qu'une cour tient encore hors du relais.
Toutefois, une pause d'une heure ne suffit pas si l'on y revient plus fébrile qu'avant. En revanche, trois soirs apprennent un geste.
Aussi faut-il distinguer envie et besoin. On peut désirer le casque et n'en avoir pas besoin.
Par conséquent, débrancher n'est pas trahir. C'est vérifier qu'un lien existe encore : un visage, un tambour, un tissu, un banc.
En revanche, imposer le silence à tous serait une autre violence. Le milieu tient les deux bords.
Dieudonné a prévu l'interrupteur. En effet, un outil sans arrêt n'est plus un outil, c'est une contrainte.
Solange : or le Bureau ne date pas une âme. Toutefois, il peut dater une pause collective, si la cour le demande.
Lila relayera ces phrases. Elle n'en fera pas une alerte. Une alerte n'est pas un raisonnement.
Karim : un raisonnement a des charnières. Sans elles, ce n'est qu'une suite de colères.
Sami : aussi resterai-je à trois frappes. En revanche, je ne frapperai pas pour couvrir un débat.
Rukiri-Nord — à lire avant d'éteindre, et aussi avant de rallumer.""",
        tf_item=(
            "Le texte affirme qu'imposer le silence à tous serait une autre violence.",
            True,
            "« imposer le silence à tous serait une autre violence. »",
        ),
        qcm_item=(
            "Que prouve, selon le texte, le fait que le fil continue sans une personne ?",
            [
                "Que la cour est morte",
                "Qu'une cour tient encore hors du relais",
                "Que Dieudonné a échoué",
                "Que le Bureau doit punir",
            ],
            1,
            "La cour tient encore hors du relais.",
        ),
        pairs=[
            ("en effet", "l'outil n'allume pas tout seul"),
            ("or", "le fil continue sans soi"),
            ("aussi faut-il", "envie ≠ besoin"),
            ("par conséquent", "débrancher n'est pas trahir"),
        ],
        fill_item=("___ , une pause d'une heure ne suffit pas si l'on y revient plus fébrile.", "Toutefois"),
        words=["En", "revanche", "trois", "soirs", "apprennent", "un", "geste", "."],
        anagram=("toutefois", "Connecteur de réserve : on admet, puis l'on précise une limite."),
        error=(
            "Aussi on distingue trop vite envie et besoin, et Léa pose enfin le casque sur le banc.",
            "Aussi distingue-t-on trop vite envie et besoin, et Léa pose enfin le casque sur le banc.",
            "Aussi + inversion.",
        ),
        pic_start=16,
        pic_words=_pw(16),
        short_p="Recopiez le raisonnement en marquant chaque connecteur. Ajoutez un toutefois à vous.",
        audio="Lisez le texte, sans aller trop vite.",
    ),
    _l(
        "PO",
        "PO — Dire or, toutefois, par conséquent",
        "Articuler à l'oral un raisonnement sur la déconnexion.",
        "Répétez, puis tenez un raisonnement de huit phrases, avec au moins cinq connecteurs.",
        "Modèles de Karim et d'Aline",
        """En effet, la lampe n'est pas un maître.
Or le fil continue sans moi.
Ainsi la cour tient encore.
Toutefois, une heure ne suffit pas.
En revanche, trois soirs apprennent.
Aussi faut-il distinguer envie et besoin.
Par conséquent, débrancher n'est pas trahir.
En revanche, imposer le silence à tous serait violent.
Karim : un raisonnement a des charnières. Sans elles, ce n'est qu'une colère.
Marc : aussi + inversion, registre plus soutenu.
Léa : or ouvre un fait qui tourne, pas une insulte.
Patrick : toutefois pose une limite sans casser la thèse.
Lila : par conséquent clôt. Ne l'employez pas à chaque phrase.
Yvette : en revanche contraste deux gestes, pas deux personnes à blâmer.""",
        tf_item=(
            "« Or » ouvre un fait qui tourne, d'après Léa.",
            True,
            "Pas une insulte : un tournant.",
        ),
        qcm_item=(
            "Quelle phrase emploie correctement aussi au sens de « c'est pourquoi » ?",
            [
                "Aussi on doit se taire",
                "Aussi faut-il distinguer envie et besoin",
                "Aussi le banc est là seulement",
                "Aussi débrancher trahir",
            ],
            1,
            "Aussi + inversion.",
        ),
        pairs=[
            ("en effet", "justification"),
            ("or / ainsi", "tournant / résultat"),
            ("toutefois / en revanche", "réserve / contraste"),
            ("par conséquent", "conclusion"),
        ],
        fill_item=("___ le fil continue sans moi.", "Or"),
        words=["Aussi", "faut-il", "distinguer", "envie", "et", "besoin", "."],
        anagram=("raisonner", "Enchaîner des idées avec des charnières, sans se contenter d'une colère."),
        error=(
            "Aussi on conclut trop vite après une heure, et Hawa refuse pourtant cette phrase trop courte.",
            "Aussi conclut-on trop vite après une heure, et Hawa refuse pourtant cette phrase trop courte.",
            "Aussi + inversion : aussi conclut-on.",
        ),
        pic_start=17,
        pic_words=_pw(17),
        short_p="Écrivez sept phrases, un connecteur différent dans chacune, sur une pause au banc.",
        audio="Enregistrez les huit premiers modèles, puis votre raisonnement en une minute.",
    ),
    _l(
        "PE",
        "PE — Mon raisonnement pour une pause",
        "Écrire un texte argumenté sur la déconnexion, avec des connecteurs variés.",
        "Imitez le raisonnement de Hawa, sans aller trop vite.",
        "Raisonnement de Hawa, banc sans fil",
        """Hawa — Seuil des Sources
On accuse trop vite la Lampe-Figue. En effet, une main l'allume, une main peut l'éteindre.
Je veux une heure hors du fil. Or le relais continue sans moi. Ainsi je découvre que la cour tient encore : Sami, Rose, le figuier, le banc.
Toutefois, une heure ne suffit pas si je reviens plus fébrile. En revanche, trois soirs m'apprennent un geste, la main vers l'interrupteur.
Aussi faut-il distinguer envie et besoin. Je peux désirer le casque de Léa et n'en avoir pas besoin.
Par conséquent, débrancher n'est pas trahir Lila, ni Dieudonné, ni la cour. C'est vérifier qu'un lien existe encore hors du fil.
En revanche, je n'imposerai pas cette pause à tous. Ce serait une autre violence, et le milieu qu'Aline défend n'y survivrait pas.
Solange peut dater une pause collective. Elle ne datera pas mon âme. Or c'est déjà beaucoup.
Rose : en effet, la housse sert à cacher la lumière, pas à casser l'outil. Je m'y range.
Félicie : Léa a posé le casque. Or son visage est revenu. Par conséquent, le banc a gagné une heure.
Je pose ceci sous l'arbre. Je n'en ferai pas une alerte.
Hawa""",
        tf_item=(
            "Hawa veut imposer sa pause à toute la cour.",
            False,
            "« je n'imposerai pas cette pause à tous. »",
        ),
        qcm_item=(
            "Que permet, selon Hawa, le fait que le relais continue sans elle ?",
            [
                "De punir Lila",
                "De découvrir que la cour tient encore",
                "De vendre la lampe",
                "De fermer le Bureau",
            ],
            1,
            "La cour tient encore.",
        ),
        pairs=[
            ("en effet", "une main allume / éteint"),
            ("or / ainsi", "le relais continue / la cour tient"),
            ("aussi faut-il", "envie ≠ besoin"),
            ("par conséquent", "débrancher n'est pas trahir"),
        ],
        fill_item=("___ faut-il distinguer envie et besoin.", "Aussi"),
        words=["Débrancher", "n'est", "pas", "trahir", "."],
        anagram=("interrupteur", "Geste prévu par Dieudonné : arrêter la lampe sans la casser."),
        error=(
            "Aussi on doit distinguer envie et besoin, et trois soirs suffisent parfois à apprendre la main.",
            "Aussi faut-il distinguer envie et besoin, et trois soirs suffisent parfois à apprendre la main.",
            "Aussi + inversion : aussi faut-il.",
        ),
        pic_start=18,
        pic_words=_pw(18),
        short_p="Imitez : treize à seize lignes, au moins six connecteurs, une thèse, une réserve, une conclusion.",
        audio="Lisez votre raisonnement, sans aller trop vite.",
    ),
    _l(
        "EL",
        "EL — Connecteurs du raisonnement",
        "Retenir en effet, or, aussi, ainsi, toutefois, par conséquent, en revanche.",
        "Apprenez la fiche.",
        "Fiche d'Aline, connecteurs",
        """en effet : on justifie, on donne une preuve. En effet, une main allume.
or : on introduit un fait qui tourne le raisonnement. Or le fil continue sans moi.
aussi (conséquence soutenue) + inversion : Aussi faut-il… Aussi resterai-je…
ainsi : résultat ou manière. Ainsi la cour tient encore.
toutefois : réserve, limite. Toutefois, une heure ne suffit pas.
par conséquent : conclusion logique. Par conséquent, débrancher n'est pas trahir.
en revanche : contraste de deux gestes ou de deux effets (pas une insulte).
Ne pas employer aussi au sens de « c'est pourquoi » sans inversion.
Ne pas coller toutefois et par conséquent dans la même phrase sans besoin.
Un raisonnement : thèse → preuve → tournant → réserve → conclusion.
Déconnexion : vérifier un lien hors du fil, non punir, non imposer à tous.
Alerte ≠ raisonnement. Colère ≠ charnière.
Bien que + subj. : bien que ce soit difficile, on peut éteindre.
À + le = au banc ; de + le = du fil.""",
        tf_item=(
            "« Aussi faut-il » emploie une inversion.",
            True,
            "Aussi + verbe + sujet.",
        ),
        qcm_item=(
            "Quel connecteur ouvre surtout un fait qui tourne ?",
            [
                "en effet seulement",
                "or",
                "im- devant p",
                "depuis que",
            ],
            1,
            "Or = tournant.",
        ),
        pairs=[
            ("en effet", "preuve"),
            ("or", "tournant"),
            ("toutefois", "réserve"),
            ("par conséquent", "conclusion"),
        ],
        fill_item=("___ le fil continue sans moi.", "Or"),
        words=["En", "effet", "une", "main", "peut", "l'éteindre", "."],
        anagram=("contraste", "Rapport en revanche : deux gestes, deux effets, sans blâme de personne."),
        error=(
            "Aussi on conclut trop vite, et le banc attend encore qu'on distingue envie et besoin.",
            "Aussi conclut-on trop vite, et le banc attend encore qu'on distingue envie et besoin.",
            "Aussi + inversion : aussi conclut-on.",
        ),
        pic_start=19,
        pic_words=_pw(19),
        short_p="Rédigez un mini-raisonnement de dix phrases, un connecteur de la fiche par phrase.",
        audio="Enregistrez la fiche et sept phrases, un connecteur chacune.",
    ),
]


# ---------------------------------------------------------------------------
# Séquence 5 — Charte numérique de Radio Figuier (EXTRA)
# ---------------------------------------------------------------------------

S5 = [
    _l(
        "CO",
        "CO — Des articles pour le fil",
        "Suivre la rédaction d'une charte : devoirs, droits, pauses, ton posé.",
        "Lisez le dialogue. Quels articles tiennent, lesquels se discutent ?",
        "Studio de Radio Figuier, feuille de charte",
        """Lila : Une charte n'est pas une alerte. C'est un texte que l'on relit, et auquel on peut dire toutefois.
Aline : Article possible : on allume pour une voix, pas pour une rumeur. En effet, le fil n'est pas un marché.
Léa : Faut-il écrire le droit de débrancher ? Oui. Peut-on l'écrire sans en faire une gloire ? Oui aussi.
Patrick : Depuis que le fil existe, on manque d'un texte commun. Or un texte trop long ne se relit pas.
Marc : Aussi faut-il des phrases courtes. Ainsi chacun pourra les tenir.
Hawa : Parce que la méfiance grandit, on écrira : relire avant de renvoyer. Si bien que moins de rumeurs partiront brutes.
Joël : En revanche, interdire le casque serait imprudent. Léa doit pouvoir l'enlever, non le voir saisi.
Rose : Le Filtre des Herbes restera imparfait. On le dira. Imparfait n'est pas inutile.
Solange : Le Bureau date la charte. Il ne la possède pas. Toutefois, une date aide à revenir.
Karim : Par conséquent, chaque article dira un geste, une limite, une cause.
Dieudonné : J'ajoute : l'interrupteur reste accessible. Déconnecter n'est pas irresponsable.
Sami : Trois frappes avant une alerte. C'est mon article, si l'on veut.
Yvette : On n'y obéira pas comme à une mode. On s'y référera comme à un banc.
Félicie : Ce que je retiens, c'est le droit de lever les yeux. C'est déjà une charte.""",
        tf_item=(
            "Joël veut interdire le casque dans la charte.",
            False,
            "Interdire le casque serait imprudent.",
        ),
        qcm_item=(
            "Que date Solange, d'après le dialogue ?",
            [
                "Les âmes",
                "La charte, sans la posséder",
                "Les rumeurs seulement",
                "Le marché des lampions",
            ],
            1,
            "Elle date, elle ne possède pas.",
        ),
        pairs=[
            ("charte ≠ alerte", "texte à relire"),
            ("droit de débrancher", "Léa / Dieudonné"),
            ("relire avant de renvoyer", "moins de rumeurs"),
            ("interrupteur accessible", "Dieudonné"),
        ],
        fill_item=("Une charte n'est pas une ___.", "alerte"),
        words=["On", "allume", "pour", "une", "voix", "pas", "pour", "une", "rumeur", "."],
        anagram=("charte", "Texte commun de devoirs et de droits, à relire, non à brandir."),
        error=(
            "Voici la charte que je pense depuis jeudi, et Lila en relira les articles demain à l'antenne.",
            "Voici la charte à laquelle je pense depuis jeudi, et Lila en relira les articles demain à l'antenne.",
            "Penser à → à laquelle.",
        ),
        pic_start=20,
        pic_words=_pw(20),
        short_p="Notez six articles possibles et une réserve (toutefois / en revanche).",
        audio="Enregistrez : On allume pour une voix. Faut-il le droit de débrancher ? Relire avant de renvoyer. L'interrupteur reste accessible.",
    ),
    _l(
        "CE",
        "CE — Premier jet de la charte",
        "Lire une charte numérique inventée, argumentée et mesurée.",
        "Lisez la charte, sans aller trop vite.",
        "Charte du fil, Radio Figuier",
        """Charte du fil — Radio Figuier, Seuil des Sources (premier jet)
Depuis que le fil relie trois cours, il nous faut un texte commun. Or un texte trop long ne se relit pas. Aussi les articles seront-ils courts.
1. On allume pour une voix, pas pour une rumeur. En effet, le fil n'est pas un marché.
2. On relit avant de renvoyer. Parce qu'une trace est incomplète, reconstruire trop vite reste un risque.
3. Le Filtre des Herbes reste imparfait. Imparfait n'est pas inutile. On ne prétendra pas l'inverse.
4. Faut-il un droit de débrancher ? Oui. Déconnecter n'est pas irresponsable. L'interrupteur reste accessible.
5. Toutefois, une pause n'est pas une gloire. En revanche, l'imposer à tous serait une autre violence.
6. Peut-on porter un casque ? Oui. Doit-on pouvoir le poser ? Oui. Le visage d'en face compte.
7. Aussi faut-il distinguer envie et besoin. Ainsi l'on évitera de tout mesurer.
8. Radio Figuier relayera la voix, pas le compte, pas l'alerte pour l'alerte.
9. Le Bureau date. Il ne possède pas. Solange n'est pas maîtresse des âmes.
10. On s'y référera comme à un banc. On n'y obéira pas comme à une mode.
Par conséquent, nous relirons cette charte chaque saison. Ce qui nous lie, c'est une phrase juste.
Rukiri-Nord — à corriger ensemble, sans faste.""",
        tf_item=(
            "L'article 5 refuse de transformer la pause en gloire et refuse aussi de l'imposer à tous.",
            True,
            "Toutefois… En revanche…",
        ),
        qcm_item=(
            "Que relayera Radio Figuier, selon l'article 8 ?",
            [
                "Le compte et l'alerte pour l'alerte",
                "La voix, pas le compte, pas l'alerte pour l'alerte",
                "Les rumeurs brutes",
                "Le marché seulement",
            ],
            1,
            "La voix, rien que la voix utile.",
        ),
        pairs=[
            ("article 1", "voix, pas rumeur"),
            ("article 4", "droit de débrancher"),
            ("article 5", "toutefois / en revanche"),
            ("article 10", "banc, pas mode"),
        ],
        fill_item=("On n'___ obéira pas comme à une mode.", "y"),
        words=["On", "relit", "avant", "de", "renvoyer", "."],
        anagram=("devoir", "Ce qu'un article exige : relire, dater, ne pas renvoyer trop vite."),
        error=(
            "Aussi les articles seront courts demain, et Lila pourra les tenir à l'antenne sans les brandir.",
            "Aussi les articles seront-ils courts demain, et Lila pourra les tenir à l'antenne sans les brandir.",
            "Aussi + inversion : seront-ils.",
        ),
        pic_start=21,
        pic_words=_pw(21),
        short_p="Recopiez cinq articles et ajoutez le vôtre, avec une cause ou une réserve.",
        audio="Lisez la charte, sans aller trop vite.",
    ),
    _l(
        "PO",
        "PO — Dire un article de charte",
        "Formuler à l'oral des articles courts : droit, devoir, réserve.",
        "Répétez, puis dictez trois articles et un toutefois.",
        "Modèles de Lila et de Solange",
        """On allume pour une voix, pas pour une rumeur.
On relit avant de renvoyer.
L'interrupteur reste accessible.
Déconnecter n'est pas irresponsable.
Toutefois, une pause n'est pas une gloire.
En revanche, l'imposer à tous serait violent.
Aussi faut-il distinguer envie et besoin.
On n'y obéira pas comme à une mode.
Lila : un article tient en une respiration.
Aline : une charte ose le toutefois, sinon elle ment.
Marc : aussi + inversion, si l'on conclut.
Léa : faut-il / peut-on : le doute a sa place dans un article.
Patrick : depuis que le fil existe, ce texte manquait.
Yvette : finissez par le geste, pas par la menace.""",
        tf_item=(
            "Aline dit qu'une charte sans toutefois risque de mentir.",
            True,
            "Elle ose le toutefois, sinon elle ment.",
        ),
        qcm_item=(
            "Quelle phrase pose un droit, non une gloire ?",
            [
                "Une pause est une gloire",
                "L'interrupteur reste accessible",
                "On doit rester casqué",
                "Le Bureau possède les âmes",
            ],
            1,
            "L'accès à l'interrupteur = droit.",
        ),
        pairs=[
            ("on allume pour une voix", "devoir"),
            ("interrupteur accessible", "droit"),
            ("toutefois", "réserve"),
            ("on n'y obéira pas", "refus de la mode"),
        ],
        fill_item=("Déconnecter n'est pas ___.", "irresponsable"),
        words=["On", "n'y", "obéira", "pas", "comme", "à", "une", "mode", "."],
        anagram=("article", "Phrase courte d'une charte : un geste, une limite, parfois une cause."),
        error=(
            "Aussi on écrira des phrases trop longues, et personne ne relira la charte sous le figuier.",
            "Aussi écrira-t-on des phrases trop longues, et personne ne relira la charte sous le figuier.",
            "Aussi + inversion : aussi écrira-t-on.",
        ),
        pic_start=22,
        pic_words=_pw(22),
        short_p="Écrivez huit articles oraux : quatre devoirs, deux droits, un toutefois, un en revanche.",
        audio="Enregistrez les huit premiers modèles, puis trois articles à vous.",
    ),
    _l(
        "PE",
        "PE — Ma charte du fil",
        "Écrire une charte numérique argumentée pour Radio Figuier.",
        "Imitez la charte de Lila Sow, sans aller trop vite.",
        "Charte de Lila, encre du studio",
        """Lila Sow — Radio Figuier, Seuil des Sources
Depuis que le fil relie trois cours, il nous faut un texte commun. Or un texte trop long ne se relit pas. Aussi les articles seront-ils courts.
J'écris ceci, non une alerte.
1. On allume pour une voix, pas pour une rumeur. En effet, le fil n'est pas un marché.
2. On relit avant de renvoyer, parce qu'une trace est incomplète, si bien que reconstruire trop vite trompe.
3. Le Filtre des Herbes reste imparfait. On le dira. Imparfait n'est pas inutile.
4. Faut-il un droit de débrancher ? Oui. L'interrupteur reste accessible. Déconnecter n'est pas irresponsable.
5. Toutefois, une pause n'est pas une gloire. En revanche, l'imposer à tous serait une autre violence.
6. Peut-on porter un casque ? Oui. Doit-on pouvoir lever les yeux ? Oui. Le visage d'en face compte.
7. Aussi faut-il distinguer envie et besoin. Ainsi l'on évitera de tout mesurer.
8. Je relayerai la voix, pas le compte. Solange datera, sans posséder.
On s'y référera comme à un banc. On n'y obéira pas comme à une mode.
Par conséquent, nous relirons ces lignes chaque saison. Que la cour corrige.
Lila""",
        tf_item=(
            "Lila présente sa charte comme une alerte à brandir.",
            False,
            "« J'écris ceci, non une alerte. »",
        ),
        qcm_item=(
            "Que datera Solange, dans la charte de Lila ?",
            [
                "Les âmes",
                "Le texte, sans posséder",
                "Les rumeurs seulement",
                "Le casque de Léa",
            ],
            1,
            "Dater sans posséder.",
        ),
        pairs=[
            ("voix, pas rumeur", "article 1"),
            ("droit de débrancher", "article 4"),
            ("toutefois / en revanche", "article 5"),
            ("banc, pas mode", "clôture"),
        ],
        fill_item=("Aussi les articles seront-___ courts.", "ils"),
        words=["On", "allume", "pour", "une", "voix", "pas", "pour", "une", "rumeur", "."],
        anagram=("accessible", "Qualité de l'interrupteur : on peut l'atteindre, on n'a pas à le mériter."),
        error=(
            "Aussi les articles seront courts cette saison, et la cour pourra les relire sans les brandir.",
            "Aussi les articles seront-ils courts cette saison, et la cour pourra les relire sans les brandir.",
            "Aussi + inversion : seront-ils.",
        ),
        pic_start=23,
        pic_words=_pw(23),
        short_p="Imitez : quatorze à dix-huit lignes, au moins six articles, un toutefois, un par conséquent.",
        audio="Lisez votre charte, sans aller trop vite.",
    ),
    _l(
        "EL",
        "EL — Tenir une charte",
        "Retenir la forme d'une charte : articles courts, droits, devoirs, connecteurs.",
        "Apprenez la fiche.",
        "Fiche d'Aline, charte",
        """Charte = texte commun, relisible. Pas une alerte. Pas une mode.
Articles courts : un geste, une limite, parfois une cause.
Droits : débrancher, poser le casque, lever les yeux. L'interrupteur reste accessible.
Devoirs : allumer pour une voix ; relire avant de renvoyer ; ne pas prétendre que le Filtre est parfait.
Réserves : toutefois (la pause n'est pas une gloire) ; en revanche (ne pas imposer à tous).
Outils du module à réemployer :
inversion : Faut-il… ? Peut-on… ? Aussi les articles seront-ils…
préfixes : imparfait, irresponsable, déconnecter, méfiance
durée : depuis que le fil existe
re- / cause : relire, parce que la trace est incomplète
connecteurs : en effet, or, ainsi, par conséquent
On s'y réfère comme à un banc. On n'y obéit pas comme à une mode.
Le Bureau date. Il ne possède pas.
Bien que + subj. : bien que ce soit incomplet, nous signons.""",
        tf_item=(
            "Une charte, d'après la fiche, peut se passer de réserve.",
            False,
            "Sans toutefois, elle risque de mentir.",
        ),
        qcm_item=(
            "Quelle série décrit le mieux un article ?",
            [
                "Une alerte longue et une couronne",
                "Un geste, une limite, parfois une cause",
                "Un graphique seulement",
                "Un tampon d'âme",
            ],
            1,
            "Geste + limite + cause possible.",
        ),
        pairs=[
            ("droit", "débrancher / lever les yeux"),
            ("devoir", "relire avant de renvoyer"),
            ("toutefois", "pause ≠ gloire"),
            ("banc ≠ mode", "se référer / ne pas obéir"),
        ],
        fill_item=("On s'___ référera comme à un banc.", "y"),
        words=["Une", "charte", "n'est", "pas", "une", "alerte", "."],
        anagram=("relisible", "Qualité d'un texte court : on peut y revenir chaque saison."),
        error=(
            "Voici le texte que je réfère trop vite, et Lila refuse d'en faire une mode.",
            "Voici le texte auquel je me réfère trop vite, et Lila refuse d'en faire une mode.",
            "Se référer à → auquel.",
        ),
        pic_start=24,
        pic_words=_pw(24),
        short_p="Plan de charte : quatre devoirs, trois droits, deux réserves, une conclusion.",
        audio="Enregistrez la fiche et cinq articles, voix posée.",
    ),
]


# ---------------------------------------------------------------------------
# Séquence 6 — Débat « Lampe-Figue et le fil » (EXTRA)
# ---------------------------------------------------------------------------

S6 = [
    _l(
        "CO",
        "CO — La lampe n'est pas le maître",
        "Suivre un débat argumenté : thèses, concessions, conclusions, sans slogan.",
        "Lisez le débat. Qui défend quoi, et quelles charnières tiennent ?",
        "Salle des Herbes, groupe autour de la lampe",
        """Aline : Nous débattons. Nous ne votons pas une couronne. Faut-il garder la Lampe-Figue telle quelle ? Peut-on vivre avec le fil sans s'y soumettre ?
Dieudonné : J'ai construit l'outil. En effet, je l'assume. Or je n'ai pas construit l'obéissance. Aussi faut-il garder l'interrupteur visible.
Léa : Depuis que je porte le casque, je perds des visages. Toutefois, j'entends Aline loin du banc. En revanche, trois soirs sans fil m'ont rendu le regard.
Patrick : Parce que Léa disparaissait une heure, j'ai trop accusé la lampe, si bien que j'ai oublié la main qui l'allume. Je corrige.
Marc : Une thèse n'est pas une insulte. « La lampe est utile » et « la lampe n'est pas un maître » peuvent rester ensemble.
Hawa : Par conséquent, je défends la charte. Débrancher n'est pas irresponsable. Imposer le silence à tous le serait.
Joël : En revanche, vanter la déconnexion comme une gloire vide le débat. C'est une autre affiche.
Rose : Le Filtre des Herbes reste imparfait. On peut s'y fier un peu, jamais tout à fait.
Solange : Le Bureau date le débat. Il ne le tranche pas.
Karim : Ainsi, le milieu tient : assez de fil pour relier, assez de banc pour se voir.
Lila : Je relayerai les deux bords. Je ne choisirai pas un camp pour faire du bruit.
Sami : Trois frappes. Ensuite, on parle. Pas l'inverse.
Yvette : Le mieux, c'est une phrase que l'enfant du Seuil comprendra : la lampe sert, elle ne commande pas.
Félicie : Or le visage est revenu. Par conséquent, le débat a déjà servi.""",
        tf_item=(
            "Dieudonné dit avoir construit l'obéissance en même temps que la lampe.",
            False,
            "« je n'ai pas construit l'obéissance. »",
        ),
        qcm_item=(
            "Que relayera Lila, d'après le débat ?",
            [
                "Un seul camp, pour faire du bruit",
                "Les deux bords",
                "Le marché seulement",
                "Une couronne",
            ],
            1,
            "Les deux bords, pas un camp.",
        ),
        pairs=[
            ("faut-il / peut-on", "questions du débat"),
            ("or / aussi faut-il", "tournant / conclusion soutenue"),
            ("toutefois / en revanche", "casque utile / regard rendu"),
            ("la lampe sert", "elle ne commande pas"),
        ],
        fill_item=("La lampe sert, elle ne ___ pas.", "commande"),
        words=["Débrancher", "n'est", "pas", "irresponsable", "."],
        anagram=("debat", "Échange de thèses et de réserves, sans couronne ni camp de bruit. (sans accent)"),
        error=(
            "Aussi on garde l'interrupteur visible, et Dieudonné refuse que l'outil devienne un maître.",
            "Aussi garde-t-on l'interrupteur visible, et Dieudonné refuse que l'outil devienne un maître.",
            "Aussi + inversion : aussi garde-t-on.",
        ),
        pic_start=25,
        pic_words=_pw(25),
        short_p="Notez trois thèses, deux concessions et la phrase de milieu (Karim ou Yvette).",
        audio="Enregistrez : Faut-il garder la lampe ? Peut-on vivre avec le fil sans s'y soumettre ? La lampe sert, elle ne commande pas.",
    ),
    _l(
        "CE",
        "CE — Compte rendu du débat",
        "Lire le compte rendu argumenté du débat « Lampe-Figue et le fil ».",
        "Lisez le compte rendu, sans aller trop vite.",
        "Compte rendu d'Aline, Salle des Herbes",
        """Compte rendu — Débat « Lampe-Figue et le fil »
On a débattu sans couronne. Faut-il garder l'outil ? Peut-on vivre avec le fil sans s'y soumettre ? Les deux questions sont restées ouvertes, et c'est tant mieux.
Dieudonné a assumé la construction. En effet, un outil a un auteur. Or il n'a pas construit l'obéissance. Aussi l'interrupteur restera-t-il visible.
Léa a tenu les deux bords : depuis que le casque existe, des visages se perdent ; toutefois, une voix lointaine s'entend ; en revanche, trois soirs sans fil lui ont rendu le regard.
Patrick a corrigé une cause : parce qu'il accusait trop la lampe, il oubliait la main, si bien que le débat devenait une insulte. Il a retiré l'insulte.
Hawa a conclu : par conséquent, la charte tient. Débrancher n'est pas irresponsable. Imposer le silence à tous le serait.
Joël a prévenu : vanter la pause comme une gloire vide le débat. Rose a rappelé que le Filtre reste imparfait. Solange a daté, sans trancher.
Karim : assez de fil pour relier, assez de banc pour se voir. Yvette : la lampe sert, elle ne commande pas.
Lila relayera les deux bords. Sami a ouvert et fermé par trois frappes.
Ainsi le milieu a tenu. Un débat qui choisit un camp trop tôt n'est plus un débat, c'est une alerte.
Félicie : or le visage est revenu. Par conséquent, le débat a déjà servi.
Marc : « la lampe est utile » et « la lampe n'est pas un maître » peuvent rester ensemble.
Rukiri-Nord — à relire avant la prochaine assemblée.""",
        tf_item=(
            "Le compte rendu dit que les deux questions sont restées ouvertes.",
            True,
            "« Les deux questions sont restées ouvertes, et c'est tant mieux. »",
        ),
        qcm_item=(
            "Que restera-t-il visible, selon Dieudonné repris par Aline ?",
            [
                "Une couronne",
                "L'interrupteur",
                "Le casque obligatoire",
                "Le marché",
            ],
            1,
            "L'interrupteur restera visible.",
        ),
        pairs=[
            ("deux questions ouvertes", "tant mieux"),
            ("interrupteur visible", "Dieudonné"),
            ("deux bords de Léa", "voix lointaine / regard"),
            ("milieu de Karim", "fil + banc"),
        ],
        fill_item=("La lampe sert, elle ne ___ pas.", "commande"),
        words=["Les", "deux", "questions", "sont", "restées", "ouvertes", "."],
        anagram=("compte", "Texte qui dit ce qui s'est tenu dans un débat, sans y ajouter une couronne."),
        error=(
            "Aussi l'interrupteur restera visible demain, et la cour pourra encore débattre sans se soumettre.",
            "Aussi l'interrupteur restera-t-il visible demain, et la cour pourra encore débattre sans se soumettre.",
            "Aussi + inversion : restera-t-il.",
        ),
        pic_start=26,
        pic_words=_pw(26),
        short_p="Recopiez le milieu du débat (Karim / Yvette) et deux concessions. Ajoutez la vôtre.",
        audio="Lisez le compte rendu, sans aller trop vite.",
    ),
    _l(
        "PO",
        "PO — Dire sa thèse, tenir le milieu",
        "Débattre à l'oral : thèse, concession, conclusion, sans camp de bruit.",
        "Répétez, puis tenez deux minutes : Lampe-Figue et le fil, pour, contre, milieu.",
        "Modèles d'Aline et de Karim",
        """Faut-il garder la lampe ? Oui, avec un interrupteur visible.
Peut-on vivre avec le fil sans s'y soumettre ? Oui, si l'on ose débrancher.
En effet, l'outil a un auteur. Or il n'a pas d'obéissance.
Toutefois, le casque fait perdre des visages.
En revanche, une voix lointaine s'entend.
Par conséquent, la charte tient.
Ainsi le milieu tient : assez de fil, assez de banc.
La lampe sert, elle ne commande pas.
Aline : une thèse n'est pas une insulte.
Marc : deux phrases peuvent rester ensemble.
Léa : je tiens les deux bords, ou je mens.
Joël : une gloire de pause vide le débat.
Lila : je relayerai les deux bords.
Yvette : une phrase d'enfant clôt mieux qu'un slogan.""",
        tf_item=(
            "Léa dit qu'elle ment si elle ne tient qu'un bord.",
            True,
            "« je tiens les deux bords, ou je mens. »",
        ),
        qcm_item=(
            "Quelle phrase dit le milieu ?",
            [
                "Il faut tout éteindre pour toujours",
                "Assez de fil, assez de banc",
                "Le Bureau tranche les âmes",
                "Une couronne pour Dieudonné",
            ],
            1,
            "Karim : assez de fil, assez de banc.",
        ),
        pairs=[
            ("faut-il / peut-on", "questions"),
            ("or / toutefois", "tournant / réserve"),
            ("par conséquent", "la charte tient"),
            ("milieu", "fil + banc"),
        ],
        fill_item=("La lampe sert, elle ne ___ pas.", "commande"),
        words=["Assez", "de", "fil", "assez", "de", "banc", "."],
        anagram=("milieu", "Place du débat : assez de lien, assez de visage, sans camp de bruit."),
        error=(
            "Aussi on tient le milieu demain, et Lila relayera les deux bords sans en faire une alerte.",
            "Aussi tiendra-t-on le milieu demain, et Lila relayera les deux bords sans en faire une alerte.",
            "Aussi + inversion : aussi tiendra-t-on.",
        ),
        pic_start=27,
        pic_words=_pw(27),
        short_p="Écrivez un débat en dix répliques : deux questions, deux thèses, deux toutefois, deux conclusions, un milieu.",
        audio="Enregistrez les huit premiers modèles, puis votre prise de position en une minute.",
    ),
    _l(
        "PE",
        "PE — Ma prise de position",
        "Écrire une prise de position argumentée pour le débat « Lampe-Figue et le fil ».",
        "Imitez la prise de position de Dieudonné, sans aller trop vite.",
        "Prise de position de Dieudonné, atelier",
        """Dieudonné — Seuil des Sources
Faut-il garder la Lampe-Figue ? Oui. Peut-on vivre avec le fil sans s'y soumettre ? Oui, et c'est la seule question qui me tient.
J'ai construit l'outil. En effet, je l'assume. Or je n'ai pas construit l'obéissance. Aussi l'interrupteur restera-t-il visible, accessible, sans gloire.
Depuis que trois cours s'entendent, une voix lointaine est un bien. Toutefois, un casque trop longtemps porté fait perdre un visage. En revanche, trois soirs sans fil rendent le regard.
Parce que l'on m'a parfois traité en maître, j'ai trop tardé à dire ceci, si bien que le débat glissait vers une affiche. Je corrige.
Déconnecter n'est pas irresponsable. Imposer le silence à tous le serait. Vanter la pause comme une gloire le serait aussi.
Par conséquent, je signe la charte de Lila, avec ses toutefois. Ainsi le milieu tient : assez de fil pour relier, assez de banc pour se voir.
La lampe sert. Elle ne commande pas. Si un enfant du Seuil peut le répéter, le débat a servi.
Karim a dit le milieu mieux que moi : assez de fil pour relier, assez de banc pour se voir.
Lila relayera les deux bords. Je n'ai pas besoin d'un camp pour exister.
Que Solange date. Qu'elle ne tranche pas. Que Sami frappe, puis que l'on parle.
Dieudonné""",
        tf_item=(
            "Dieudonné refuse de signer la charte de Lila.",
            False,
            "« je signe la charte de Lila, avec ses toutefois. »",
        ),
        qcm_item=(
            "Quelle est, pour Dieudonné, la seule question qui le tient ?",
            [
                "Faut-il vendre la lampe ?",
                "Peut-on vivre avec le fil sans s'y soumettre ?",
                "Faut-il fermer le figuier ?",
                "Doit-on interdire le tambour ?",
            ],
            1,
            "Vivre avec le fil sans s'y soumettre.",
        ),
        pairs=[
            ("j'assume l'outil", "pas l'obéissance"),
            ("toutefois / en revanche", "voix / visage"),
            ("par conséquent", "je signe la charte"),
            ("milieu", "fil + banc"),
        ],
        fill_item=("Aussi l'interrupteur restera-___ visible.", "t-il"),
        words=["La", "lampe", "sert", "elle", "ne", "commande", "pas", "."],
        anagram=("obeissance", "Ce que Dieudonné n'a pas construit, et qu'il refuse à l'outil. (sans accent)"),
        error=(
            "Aussi l'interrupteur restera visible ce soir, et la cour pourra encore débattre sans se soumettre.",
            "Aussi l'interrupteur restera-t-il visible ce soir, et la cour pourra encore débattre sans se soumettre.",
            "Aussi + inversion : restera-t-il.",
        ),
        pic_start=28,
        pic_words=_pw(28),
        short_p="Imitez : quatorze à dix-huit lignes, deux questions, six connecteurs, un milieu, une phrase d'enfant.",
        audio="Lisez votre prise de position, sans aller trop vite.",
    ),
    _l(
        "EL",
        "EL — Tenir un débat B2",
        "Retenir la charpente d'un débat : questions, thèses, concessions, milieu, conclusion.",
        "Apprenez la fiche.",
        "Fiche d'Aline, débat",
        """Débat = questions ouvertes + thèses + concessions + milieu. Pas une couronne. Pas une alerte.
Ouvrir : Faut-il… ? Peut-on… ? Doit-on… ?
Tenir deux phrases ensemble : utile / pas maître ; relier / se voir ; voix / visage.
Connecteurs : en effet, or, aussi + inversion, ainsi, toutefois, par conséquent, en revanche.
Durée : depuis que, ça fait… que, en trois soirs.
Cause / conséquence : parce que, puisque, si bien que, de sorte que.
Préfixes : imparfait, irresponsable, déconnecter, méfiance.
re- : relire, retracer, reconstruire — sans refaire à l'envers.
Charte : articles courts, droit de débrancher, relire avant de renvoyer.
Milieu utile au Seuil : assez de fil pour relier, assez de banc pour se voir.
Phrase de clôture : la lampe sert, elle ne commande pas.
Lila relayera les deux bords. Solange date, elle ne tranche pas. Sami frappe, puis l'on parle.
Bien que + subj. : bien que l'on ne soit pas d'accord, le débat tient.
Éviter : plus bon, inpossible, aussi on doit, le texte que je pense, parce que pour un résultat.""",
        tf_item=(
            "Un débat, d'après la fiche, doit choisir un camp dès l'ouverture.",
            False,
            "Questions ouvertes. Un camp trop tôt = une alerte.",
        ),
        qcm_item=(
            "Quelle phrase clôt le mieux, selon la fiche ?",
            [
                "La lampe commande, elle ne sert pas",
                "La lampe sert, elle ne commande pas",
                "Le Bureau tranche les âmes",
                "Une couronne pour le fil",
            ],
            1,
            "Sert / ne commande pas.",
        ),
        pairs=[
            ("faut-il / peut-on", "ouverture"),
            ("toutefois / en revanche", "concession"),
            ("par conséquent", "conclusion"),
            ("fil + banc", "milieu"),
        ],
        fill_item=("Assez de fil pour relier, assez de ___ pour se voir.", "banc"),
        words=["La", "lampe", "sert", "elle", "ne", "commande", "pas", "."],
        anagram=("position", "Texte où l'on dit sa thèse, sa réserve et son milieu, sans slogan."),
        error=(
            "Voici le débat que je pense encore ce soir, et Aline en relira le compte rendu demain sous l'arbre.",
            "Voici le débat auquel je pense encore ce soir, et Aline en relira le compte rendu demain sous l'arbre.",
            "Penser à → auquel.",
        ),
        pic_start=29,
        pic_words=_pw(29),
        short_p="Plan de débat : deux questions, deux thèses, deux concessions, un milieu, une phrase de clôture.",
        audio="Enregistrez la fiche et la phrase : la lampe sert, elle ne commande pas.",
    ),
]


SEQUENCES = [
    {"title": "Actualité technologique", "lessons": S1},
    {"title": "Évolution sociétale", "lessons": S2},
    {"title": "Mémoire et réseaux", "lessons": S3},
    {"title": "Raisonnement sur la déconnexion", "lessons": S4},
    {"title": "Charte numérique de Radio Figuier", "lessons": S5},
    {"title": "Débat « Lampe-Figue et le fil »", "lessons": S6},
]
