"""B1 Module 3 — Organiser la fête (univers Seuil des Sources)."""

from factory import L

IMG = "mfk-b1-m3"
IMG_DIR = IMG

MODULE = {
    "title": "B1 — Organiser la fête",
    "description": (
        "Grande étape B1-3 : proposer une sortie, convaincre un groupe, "
        "comparer des fêtes et des coutumes, observer les comportements, "
        "préparer concrètement puis faire le bilan — Veillée des Lampions "
        "au Marché des Lampions et à la Salle des Herbes, avec le tambour "
        "de Sami Niyonteze et le tissu de Rose Iradukunda."
    ),
}


def _l(comp, title, obj, cons, st, sp, **kw):
    return L(IMG, comp, title, obj, cons, st, sp, **kw)


# ---------------------------------------------------------------------------
# Séquence 1 — Proposer une sortie (conseil ; mise en relief)
# ---------------------------------------------------------------------------

S1 = [
    _l(
        "CO",
        "CO — Une veillée à proposer",
        "Comprendre un conseil (tu devrais, si j'étais toi, à ta place) et la mise en relief c'est… qui / que.",
        "Lisez le dialogue. Qui conseille Joël ? Sur quoi insiste-t-on ?",
        "Banc du figuier, avant-veille",
        """Léa : Tu devrais venir à la Veillée des Lampions, Joël. C'est Sami qui joue du tambour.
Patrick : Si j'étais toi, je laisserais la moto une soirée. C'est la fête que tout le Seuil attend.
Aline : À ta place, je dirais oui tout de suite. C'est Rose qui a cousu les tissus ocre.
Marc : Tu devrais écouter Radio Figuier : c'est Lila qui a lu l'affiche ce matin.
Hawa : Si j'étais toi, je prendrais un ticket tôt. C'est le cortège que je ne veux pas manquer.
Joël : Je serais plus calme si je savais l'heure. C'est l'horaire qui me bloque.
Karim : À ta place, je demanderais à Solange. C'est elle qui garde les places du banc.
Rose : Tu devrais voir le tissu avant. C'est la cape que Dieudonné a tendue.
Félicie : Si j'étais toi, je viendrais dîner d'abord. C'est la Table des Sources qui ouvre le soir.
Sami : C'est vous qui donnez le rythme, pas seulement le tambour.
Lila : À ta place, Joël, je ne resterais pas sous le capot. C'est la veillée que la cour prépare.
Dieudonné : Tu devrais entrer par la Salle des Herbes. C'est le seuil que j'ai décoré.""",
        tf_item=(
            "C'est Sami qui joue du tambour, d'après Léa.",
            True,
            "Léa : « C'est Sami qui joue du tambour. »",
        ),
        qcm_item=(
            "Que dit Patrick à Joël ?",
            [
                "Tu dois vendre la moto",
                "Si j'étais toi, je laisserais la moto une soirée",
                "C'est Joël qui joue du tambour",
                "À ta place, je partirais à Val-des-Peupliers",
            ],
            1,
            "Patrick : « Si j'étais toi, je laisserais la moto une soirée. »",
        ),
        pairs=[
            ("tu devrais", "conseil direct"),
            ("si j'étais toi", "conseil par identification"),
            ("à ta place", "même idée, autre formule"),
            ("c'est… qui / que", "mise en relief"),
        ],
        fill_item=("Si j'étais toi, je ___ la moto une soirée. (laisser)", "laisserais"),
        words=["Tu", "devrais", "venir", "à", "la", "veillée", "."],
        anagram=("devrais", "Tu… y aller : conseil, conditionnel de devoir."),
        error=(
            "Si j'étais toi, je serai plus calme demain soir, à la Salle des Herbes.",
            "Si j'étais toi, je serais plus calme demain soir, à la Salle des Herbes.",
            "Après si + imparfait : conditionnel, serais (pas serai).",
        ),
        pic_start=0,
        pic_words=["une sortie", "un conseil", "un relief", "une lanterne"],
        short_p="Notez trois conseils et trois mises en relief (qui / que).",
        audio="Enregistrez : Tu devrais venir. Si j'étais toi, je laisserais la moto. À ta place, je dirais oui. C'est Sami qui joue.",
    ),
    _l(
        "CE",
        "CE — Affiche collée au figuier",
        "Lire une affiche qui conseille et met en relief les rôles.",
        "Lisez l'affiche, sans aller trop vite.",
        "Affiche ocre, Marché des Lampions",
        """Veillée des Lampions — Salle des Herbes
Tu devrais arriver avant dix-neuf heures : c'est Félicie qui ouvre la table.
Si j'étais toi, je prendrais le minibus Figuier 7, pas la moto trop tard.
À ta place, j'écouterais Lila Sow : c'est elle qui lit le programme à Radio Figuier.
C'est Sami Niyonteze qui donne le premier coup de tambour.
C'est le tissu de Rose Iradukunda que l'on tend au fond de la salle.
C'est Dieudonné qui a fixé les lanternes, pas n'importe qui.
Tu devrais garder un siège pour Hawa : Yvette a dit qu'elle viendrait si la gorge le permettait.
Si j'étais toi, je n'inviterais pas trop de monde d'un coup : le banc est étroit.
À ta place, je remercierais Karim : c'est lui qui a cédé la clé du local.
C'est la cour du Seuil qui invite, pas une enseigne de passage.
Joël, tu devrais juste poser une clé : c'est l'outil que tu peux laisser.
Solange Mukamana : les places du premier rang, c'est le Bureau des Escales qui les note.""",
        tf_item=(
            "C'est Dieudonné qui a fixé les lanternes.",
            True,
            "« C'est Dieudonné qui a fixé les lanternes, pas n'importe qui. »",
        ),
        qcm_item=(
            "Qui lit le programme à Radio Figuier ?",
            ["Rose", "Sami", "Lila Sow", "Joël"],
            2,
            "« c'est elle qui lit le programme à Radio Figuier » (Lila Sow).",
        ),
        pairs=[
            ("tu devrais arriver", "avant 19 h"),
            ("si j'étais toi", "minibus Figuier 7"),
            ("c'est Sami qui", "tambour"),
            ("c'est le tissu que", "Rose"),
        ],
        fill_item=("À ta place, j'___ Lila Sow. (écouter)", "écouterais"),
        words=["C'est", "Sami", "qui", "donne", "le", "premier", "coup", "."],
        anagram=("place", "À ta… je partirais plus tôt : on se met dans la situation de l'autre."),
        error=(
            "C'est Rose que a cousu les tissus ocre, pour la Salle des Herbes.",
            "C'est Rose qui a cousu les tissus ocre, pour la Salle des Herbes.",
            "Rose = sujet du verbe coudre → c'est… qui.",
        ),
        pic_start=1,
        pic_words=["un conseil", "un relief", "une lanterne", "un but"],
        short_p="Recopiez l'affiche et encadrez tu devrais / si j'étais toi / c'est… qui / que.",
        audio="Lisez l'affiche collée au figuier, sans aller trop vite.",
    ),
    _l(
        "PO",
        "PO — Conseiller et mettre en relief",
        "Donner un conseil et insister sur un élément avec c'est… qui / que.",
        "Répétez, puis conseillez un camarade pour une sortie du Seuil.",
        "Modèles de Marc",
        """Tu devrais venir.
Tu devrais écouter Lila.
Si j'étais toi, je partirais tôt.
Si j'étais toi, je serais plus calme.
À ta place, je dirais oui.
À ta place, je ne resterais pas ici.
C'est Sami qui joue.
C'est Léa qui a proposé.
C'est la veillée que nous préparons.
C'est le tissu que Rose a cousu.
C'est vous qui donnez le rythme.
Je serais d'accord, si l'horaire était clair.""",
        tf_item=(
            "« Je serais » est un conditionnel, pas un futur.",
            True,
            "Si j'étais toi, je serais plus calme. Futur : je serai.",
        ),
        qcm_item=(
            "Quelle phrase met en relief le COD ?",
            [
                "C'est Sami qui joue",
                "C'est la veillée que nous préparons",
                "Tu devrais venir",
                "À ta place, je dirais oui",
            ],
            1,
            "Que = COD (la veillée). Qui = sujet.",
        ),
        pairs=[
            ("tu devrais + inf.", "conseil"),
            ("si + imparfait", "conditionnel ensuite"),
            ("c'est… qui", "sujet en relief"),
            ("c'est… que", "COD en relief"),
        ],
        fill_item=("Si j'étais toi, je ___ plus calme. (être)", "serais"),
        words=["C'est", "la", "veillée", "que", "nous", "préparons", "."],
        anagram=("serais", "Si j'étais toi, je… plus calme : conditionnel d'être."),
        error=(
            "À ta place, je resterai sous le capot pendant toute la veillée, Joël.",
            "À ta place, je resterais sous le capot pendant toute la veillée, Joël.",
            "Conseil irréel : conditionnel resterais, pas futur resterai.",
        ),
        pic_start=2,
        pic_words=["un relief", "une lanterne", "un but", "un souhait"],
        short_p="Écrivez six conseils (deux de chaque formule) et quatre mises en relief.",
        audio="Enregistrez les douze modèles, puis deux conseils à vous.",
    ),
    _l(
        "PE",
        "PE — Mon mot d'invitation",
        "Écrire un mot qui conseille et met en relief les rôles de la veillée.",
        "Imitez le mot d'Hawa.",
        "Mot d'Hawa Diallo",
        """Hawa Diallo
Infirmerie des Herbes — vers la Salle des Herbes
Joël, tu devrais venir, même une heure. C'est Sami qui ouvre au tambour.
Si j'étais toi, je prendrais le minibus, pas la moto trop tard.
À ta place, je garderais un siège près de Yvette, au cas où.
C'est Rose qui a cousu le tissu ocre. C'est ce tissu que l'on verra au fond.
C'est Léa qui a proposé la sortie, pas moi : je transmets.
Tu devrais écouter Lila à Radio Figuier : c'est elle qui lit l'horaire.
Je serais plus rassurée si tu disais oui avant midi.
C'est la cour du Seuil que l'on invite, à Rive-des-Saules comme à Val-des-Peupliers.
Hawa""",
        tf_item=(
            "Hawa dit que c'est elle qui a proposé la sortie.",
            False,
            "« C'est Léa qui a proposé la sortie, pas moi. »",
        ),
        qcm_item=(
            "Quel conseil Hawa donne-t-elle sur le transport ?",
            [
                "Prendre la moto tard",
                "Marcher jusqu'à Val-des-Peupliers",
                "Prendre le minibus, pas la moto trop tard",
                "Rester à l'infirmerie",
            ],
            2,
            "« Si j'étais toi, je prendrais le minibus, pas la moto trop tard. »",
        ),
        pairs=[
            ("tu devrais venir", "conseil"),
            ("si j'étais toi", "minibus"),
            ("c'est Sami qui", "tambour"),
            ("c'est Léa qui", "proposition"),
        ],
        fill_item=("Je ___ plus rassurée si tu disais oui. (être)", "serais"),
        words=["C'est", "Rose", "qui", "a", "cousu", "le", "tissu", "."],
        anagram=("relief", "C'est Léa qui : on met un mot en…"),
        error=(
            "Si j'étais toi, je prendrai le minibus, pas la moto trop tard, Joël.",
            "Si j'étais toi, je prendrais le minibus, pas la moto trop tard, Joël.",
            "Si + imparfait → conditionnel : prendrais.",
        ),
        pic_start=3,
        pic_words=["une lanterne", "un but", "un souhait", "un ticket"],
        short_p="Imitez : dix lignes, trois formules de conseil et trois c'est… qui / que.",
        audio="Lisez votre mot d'invitation, sans aller trop vite.",
    ),
    _l(
        "EL",
        "EL — Conseil et mise en relief",
        "Retenir tu devrais, si j'étais toi, à ta place, et c'est… qui / que.",
        "Apprenez la fiche.",
        "Fiche de Lila",
        """Conseil : tu devrais + infinitif. Tu devrais venir. Vous devriez écouter.
Si + imparfait, conditionnel : si j'étais toi, je partirais / je serais plus calme.
À ta place, je + conditionnel : à ta place, je dirais oui / je ne resterais pas.
Futur je serai ≠ conditionnel je serais. Conseil irréel : serais.
C'est + nom + qui + verbe : c'est Sami qui joue (sujet en relief).
C'est + nom + que + sujet + verbe : c'est la veillée que nous préparons (COD).
Ce sont + pluriel + qui : ce sont les lanternes qui éclairent.
On ne dit pas : c'est Rose que a cousu. On dit : c'est Rose qui a cousu.
Accord : si j'étais (imparfait d'être). Pas : si je serais.
Le conseil reste poli : tu devrais, pas tu dois trop sec ici.
On peut combiner : tu devrais venir, c'est Sami qui joue.
Toujours il faut (si l'on ajoute une obligation) : il faut que tu viennes.""",
        tf_item=(
            "On dit « si je serais toi ».",
            False,
            "Si + imparfait : si j'étais toi.",
        ),
        qcm_item=(
            "Quelle forme est un conditionnel ?",
            ["je serai", "je serais", "je suis", "j'étais"],
            1,
            "Je serais = conditionnel. Je serai = futur.",
        ),
        pairs=[
            ("tu devrais", "devoir au conditionnel"),
            ("si j'étais toi", "imparfait + conseil"),
            ("c'est… qui", "sujet"),
            ("c'est… que", "COD"),
        ],
        fill_item=("C'est la veillée ___ nous préparons.", "que"),
        words=["Si", "j'étais", "toi", "je", "partirais", "tôt", "."],
        anagram=("etais", "Si j'… toi : imparfait après si (sans accent)."),
        error=(
            "Si je serais toi, je partirais tôt à la Salle des Herbes, Joël.",
            "Si j'étais toi, je partirais tôt à la Salle des Herbes, Joël.",
            "Après si : imparfait étais, pas conditionnel serais.",
        ),
        pic_start=4,
        pic_words=["un but", "un souhait", "un ticket", "un micro"],
        short_p="Tableau : trois conseils, deux qui, deux que, une phrase je serais.",
        audio="Enregistrez la fiche et six exemples (trois conseils, trois mises en relief).",
    ),
]


# ---------------------------------------------------------------------------
# Séquence 2 — Convaincre le groupe (but ; informer sur un événement)
# ---------------------------------------------------------------------------

S2 = [
    _l(
        "CO",
        "CO — Convaincre sous le figuier",
        "Repérer le but : pour, afin de, pour que, afin que, de façon à — et l'info sur la veillée.",
        "Lisez le dialogue. Pourquoi organise-t-on la fête ? Qui informe ?",
        "Cour du Seuil, réunion courte",
        """Marc : On se réunit pour danser, pas pour se disputer.
Léa : Afin de réunir Rive-des-Saules et Val-des-Peupliers, on ouvre la Salle des Herbes.
Aline : Je parle pour que Sami puisse jouer au milieu, pas dans un coin.
Patrick : Afin que Rose accroche le tissu, Dieudonné tient l'échelle.
Hawa : On range de façon à laisser un passage, pour les lanternes.
Lila : Radio Figuier informe : la veillée commence à vingt heures, entrée libre.
Karim : Je cède la clé pour que le local reste accessible, pas fermé à double tour.
Joël : Je viens afin de voir, pas afin de réparer la moto.
Félicie : Je cuisine pour que chacun mange un peu, même tard.
Sami : Frappez le tambour de façon à appeler, pas à couvrir les voix.
Solange : Le Bureau des Escales affiche l'heure afin que personne n'arrive à minuit.
Yvette : Hawa s'assoit près de moi pour que je surveille la gorge, sans ruminer.""",
        tf_item=(
            "L'entrée de la veillée est libre, d'après Lila.",
            True,
            "Lila : « entrée libre. »",
        ),
        qcm_item=(
            "Pourquoi Aline parle-t-elle ?",
            [
                "Pour fermer la salle",
                "Pour que Sami puisse jouer au milieu",
                "Afin de vendre des tickets",
                "Pour réparer la moto",
            ],
            1,
            "Aline : « pour que Sami puisse jouer au milieu. »",
        ),
        pairs=[
            ("pour danser", "but + infinitif"),
            ("afin de réunir", "but + infinitif"),
            ("pour que Sami puisse", "but + subjonctif"),
            ("de façon à laisser", "but / manière"),
        ],
        fill_item=("Je parle pour que Sami ___ jouer au milieu. (pouvoir)", "puisse"),
        words=["On", "se", "réunit", "pour", "danser", "."],
        anagram=("afin", "… de réunir le groupe : but, souvent suivi de de."),
        error=(
            "Je parle pour que Sami peut jouer au milieu, pas dans un coin, sous le figuier.",
            "Je parle pour que Sami puisse jouer au milieu, pas dans un coin, sous le figuier.",
            "Pour que + subjonctif : puisse (pas peut).",
        ),
        pic_start=5,
        pic_words=["un souhait", "un ticket", "un micro", "une coutume"],
        short_p="Notez deux buts à l'infinitif et deux buts au subjonctif, plus une info d'horaire.",
        audio="Enregistrez : On se réunit pour danser. Afin de réunir les rives. Pour que Sami puisse jouer. Radio Figuier informe : vingt heures.",
    ),
    _l(
        "CE",
        "CE — Annonce de Radio Figuier",
        "Lire une annonce d'événement qui enchaîne buts et informations.",
        "Lisez l'annonce, sans aller trop vite.",
        "Feuille de Lila Sow, studio",
        """Radio Figuier — annonce de la Veillée des Lampions
On allume les lanternes pour éclairer la Salle des Herbes, pas la route entière.
Afin de laisser passer le cortège, le Marché des Lampions range les étals à dix-neuf heures.
Aline parle pour que chacun entende Sami Niyonteze au tambour.
Dieudonné tient l'échelle afin que Rose accroche le tissu ocre sans tomber.
On ouvre de façon à accueillir Rive-des-Saules et Val-des-Peupliers.
Horaire : vingt heures. Entrée libre. Bancs limités : Karim cède la clé du local.
Félicie Ndayishimiye cuisine pour que personne ne reste le ventre vide.
Yvette s'installe près d'Hawa afin que la gorge ne force pas.
Solange Mukamana affiche au Bureau des Escales, pour informer les retardataires.
Joël Mugisha vient afin de voir, de façon à ne pas rater le premier coup.
C'est Léa qui a proposé, pour que la cour se retrouve autrement.
On éteint à minuit, afin que le Pavillon du Saule retrouve le silence.""",
        tf_item=(
            "Le marché range les étals à dix-neuf heures pour laisser passer le cortège.",
            True,
            "« Afin de laisser passer le cortège, le Marché… range les étals à dix-neuf heures. »",
        ),
        qcm_item=(
            "À quelle heure commence la veillée ?",
            ["Dix-neuf heures", "Vingt heures", "Minuit", "Midi"],
            1,
            "« Horaire : vingt heures. »",
        ),
        pairs=[
            ("pour éclairer", "lanternes"),
            ("afin de laisser passer", "cortège"),
            ("pour que chacun entende", "tambour"),
            ("afin que Rose accroche", "tissu"),
        ],
        fill_item=("Aline parle pour que chacun ___ Sami. (entendre)", "entende"),
        words=["On", "ouvre", "de", "façon", "à", "accueillir", "."],
        anagram=("puisse", "Pour que Sami… jouer : subjonctif de pouvoir, il."),
        error=(
            "Dieudonné tient l'échelle afin que Rose accroche le tissu ocre et qu'elle ne tombe pas, pour que tout le monde voit.",
            "Dieudonné tient l'échelle afin que Rose accroche le tissu ocre et qu'elle ne tombe pas, pour que tout le monde voie.",
            "Pour que + subjonctif : voie (pas voit).",
        ),
        pic_start=6,
        pic_words=["un ticket", "un micro", "une coutume", "un pronom"],
        short_p="Recopiez l'annonce et classez : infinitif (pour / afin de / de façon à) vs subjonctif (pour que / afin que).",
        audio="Lisez l'annonce de Radio Figuier, sans aller trop vite.",
    ),
    _l(
        "PO",
        "PO — Dire pour, afin que",
        "Exprimer un but et informer sur un événement à voix haute.",
        "Répétez, puis convainquez le groupe pour une fête du Seuil.",
        "Modèles d'Aline",
        """On se réunit pour danser.
Afin de réunir les deux rives, on ouvre la salle.
Je parle pour que Sami puisse jouer.
Dieudonné tient l'échelle afin que Rose accroche.
On range de façon à laisser un passage.
La veillée commence à vingt heures.
L'entrée est libre.
Je cède la clé pour que le local reste ouvert.
Je cuisine pour que chacun mange.
On affiche afin que personne n'arrive trop tard.
On éteint à minuit, afin que le silence revienne.
Joël vient afin de voir.""",
        tf_item=(
            "Pour / afin de + infinitif ; pour que / afin que + subjonctif.",
            True,
            "Même sujet → infinitif. Changement de sujet → que + subj.",
        ),
        qcm_item=(
            "Quelle phrase exige le subjonctif ?",
            [
                "On se réunit pour danser",
                "Afin de réunir les deux rives, on ouvre",
                "Je parle pour que Sami puisse jouer",
                "On range de façon à laisser un passage",
            ],
            2,
            "Pour que + subjonctif (sujet différent : je / Sami).",
        ),
        pairs=[
            ("pour + inf.", "même élan, verbe simple"),
            ("afin de + inf.", "but un peu plus formel"),
            ("pour que + subj.", "autre sujet"),
            ("de façon à + inf.", "but et manière"),
        ],
        fill_item=("On affiche afin que personne n'___ trop tard. (arriver)", "arrive"),
        words=["Je", "parle", "pour", "que", "Sami", "puisse", "jouer", "."],
        anagram=("facon", "De… à : but et manière (sans accent)."),
        error=(
            "Je cède la clé pour que le local reste ouvert, afin que Karim peut partir tôt.",
            "Je cède la clé pour que le local reste ouvert, afin que Karim puisse partir tôt.",
            "Afin que + subjonctif : puisse.",
        ),
        pic_start=7,
        pic_words=["un micro", "une coutume", "un pronom", "une opposition"],
        short_p="Écrivez dix phrases de but : cinq infinitifs, cinq pour que / afin que.",
        audio="Enregistrez les douze modèles, puis une mini-annonce d'événement.",
    ),
    _l(
        "PE",
        "PE — Mon mot pour convaincre",
        "Écrire un mot qui informe et donne des buts pour rallier le groupe.",
        "Imitez le mot de Léa.",
        "Mot de Léa Niyonzima",
        """Léa Niyonzima
Cahier du chemin — Veillée des Lampions
On allume pour éclairer la Salle des Herbes, pas toute la rive.
Afin de réunir Rive-des-Saules et Val-des-Peupliers, venez dès vingt heures.
Je propose cette sortie pour que Sami puisse jouer au milieu.
Dieudonné tiendra l'échelle afin que Rose accroche le tissu sans danger.
On range de façon à laisser un passage aux lanternes.
Lila informera à Radio Figuier : entrée libre, bancs limités.
Karim cède la clé pour que le local reste accessible.
Félicie cuisine afin que chacun mange un peu, même tard.
On éteint à minuit, pour que le Pavillon retrouve le silence.
Léa""",
        tf_item=(
            "L'entrée est payante, d'après Léa.",
            False,
            "« entrée libre, bancs limités. »",
        ),
        qcm_item=(
            "Pourquoi Léa propose-t-elle la sortie ?",
            [
                "Pour fermer Radio Figuier",
                "Pour que Sami puisse jouer au milieu",
                "Afin de vendre la moto de Joël",
                "Pour que Yvette parte",
            ],
            1,
            "« pour que Sami puisse jouer au milieu. »",
        ),
        pairs=[
            ("pour éclairer", "lanternes"),
            ("afin de réunir", "les deux rives"),
            ("pour que Sami puisse", "tambour au milieu"),
            ("afin que Rose accroche", "tissu"),
        ],
        fill_item=("Karim cède la clé pour que le local ___ accessible. (rester)", "reste"),
        words=["On", "allume", "pour", "éclairer", "la", "salle", "."],
        anagram=("veillee", "La nuit des lampions, à la Salle des Herbes (sans accent)."),
        error=(
            "Je propose cette sortie pour que Sami peut jouer au milieu, sous le figuier.",
            "Je propose cette sortie pour que Sami puisse jouer au milieu, sous le figuier.",
            "Pour que + subjonctif : puisse.",
        ),
        pic_start=8,
        pic_words=["une coutume", "un pronom", "une opposition", "une danse"],
        short_p="Imitez : dix lignes, quatre buts différents et deux infos (heure, entrée).",
        audio="Lisez votre mot pour convaincre, sans aller trop vite.",
    ),
    _l(
        "EL",
        "EL — Exprimer le but",
        "Retenir pour, afin de, pour que, afin que, de façon à.",
        "Apprenez la fiche.",
        "Fiche d'Aline",
        """Même sujet → infinitif : on allume pour éclairer. Afin de réunir, on ouvre.
De façon à + infinitif : on range de façon à laisser un passage.
Sujet différent → pour que / afin que + subjonctif.
Je parle pour que Sami puisse jouer. Dieudonné tient afin que Rose accroche.
Pouvoir au subjonctif : que je puisse, que tu puisses, qu'il puisse, que nous puissions.
Voir : que je voie, qu'il voie. Rester : qu'il reste. Entendre : qu'il entende.
Afin que personne n'arrive : ne explétif possible après personne.
Informer : horaire, lieu, entrée, qui fait quoi (c'est X qui…).
On ne dit pas : pour que Sami peut. On dit : pour que Sami puisse.
pour ≠ pour que : pour + nom ou infinitif ; pour que + phrase au subj.
afin de / afin que : plus soutenu, même logique.
Toujours il faut, si obligation : il faut que tu viennes pour que ça tienne.""",
        tf_item=(
            "« Pour que » se construit avec l'infinitif.",
            False,
            "Pour que + subjonctif. Pour + infinitif.",
        ),
        qcm_item=(
            "« Pouvoir » au subjonctif, il :",
            ["peut", "pourra", "puisse", "pouvait"],
            2,
            "Qu'il puisse.",
        ),
        pairs=[
            ("pour / afin de", "infinitif"),
            ("pour que / afin que", "subjonctif"),
            ("de façon à", "infinitif"),
            ("sujet différent", "que + subj."),
        ],
        fill_item=("Je parle pour que Sami ___ jouer. (pouvoir)", "puisse"),
        words=["Afin", "de", "réunir", "les", "deux", "rives", "."],
        anagram=("objectif", "Pour, afin de, pour que : on exprime un…"),
        error=(
            "On ouvre la salle afin que tout le monde peut entrer, dès vingt heures.",
            "On ouvre la salle afin que tout le monde puisse entrer, dès vingt heures.",
            "Afin que + subjonctif : puisse.",
        ),
        pic_start=9,
        pic_words=["un pronom", "une opposition", "une danse", "un démonstratif"],
        short_p="Transformez : On ouvre. On veut que Sami joue. / Rose accroche. Dieudonné aide.",
        audio="Enregistrez la fiche et six buts (trois inf., trois subj.).",
    ),
]


# ---------------------------------------------------------------------------
# Séquence 3 — Fêtes et coutumes (en / y ; négation ; opposition-concession)
# ---------------------------------------------------------------------------

S3 = [
    _l(
        "CO",
        "CO — Coutumes sous les lanternes",
        "Comprendre des différences culturelles : en / y, négation, alors que, tandis que, bien que, pourtant.",
        "Lisez le dialogue. Qui fait quoi autrement ?",
        "Salle des Herbes, avant le cortège",
        """Rose : Chez nous, on y va en famille, et on en parle dès l'aube.
Hawa : Chez moi, on n'allume jamais trop tôt, alors que Rose a déjà tendu le tissu.
Sami : Je n'en joue qu'après le silence, tandis que Kévin frappe trop vite.
Aline : Bien que la salle soit petite, on y tient tous, pourtant personne ne s'assoit n'importe où.
Patrick : Je n'y suis pas retourné l'an dernier, j'en avais assez ; cette année j'y vais.
Léa : On n'invite ni vendeur ni passant trop pressé, alors que le marché, lui, reste ouvert.
Marc : Yvette n'en sert plus de plat épicé, bien qu'Hawa aille mieux.
Joël : Je n'y connais rien, pourtant je reste.
Félicie : Je n'en prépare que deux plateaux, tandis que Dieudonné en veut trois.
Karim : Bien que j'aie cédé la clé, je n'y entre pas sans frapper.
Lila : Radio Figuier en parle, on y écoute ; pourtant le tambour n'a pas besoin d'antenne.
Dieudonné : On n'y danse pas encore : Sami n'a pas levé les baguettes.""",
        tf_item=(
            "Hawa allume toujours très tôt, comme Rose.",
            False,
            "Hawa : « on n'allume jamais trop tôt, alors que Rose a déjà tendu le tissu. »",
        ),
        qcm_item=(
            "Que dit Aline sur la salle ?",
            [
                "Elle est trop grande",
                "Bien qu'elle soit petite, on y tient tous",
                "Personne n'y entre",
                "On n'y danse jamais",
            ],
            1,
            "« Bien que la salle soit petite, on y tient tous. »",
        ),
        pairs=[
            ("on y va", "à la fête / à la salle"),
            ("on en parle", "de la coutume"),
            ("alors que / tandis que", "opposition"),
            ("bien que + subj.", "concession"),
        ],
        fill_item=("Bien que la salle ___ petite, on y tient. (être)", "soit"),
        words=["On", "n'allume", "jamais", "trop", "tôt", "."],
        anagram=("tandis", "… que : opposition, deux actions en même temps."),
        error=(
            "Bien que la salle est petite, on y tient tous, pourtant personne ne s'assoit n'importe où.",
            "Bien que la salle soit petite, on y tient tous, pourtant personne ne s'assoit n'importe où.",
            "Bien que + subjonctif : soit.",
        ),
        pic_start=10,
        pic_words=["une opposition", "une danse", "un démonstratif", "chacun"],
        short_p="Notez un en, un y, une opposition et une concession entendus.",
        audio="Enregistrez : On y va en famille. On en parle dès l'aube. Alors que Rose a déjà tendu. Bien que la salle soit petite.",
    ),
    _l(
        "CE",
        "CE — Cartes de fêtes",
        "Lire des cartes qui comparent des coutumes familiales.",
        "Lisez les cartes, sans aller trop vite.",
        "Cartes épinglées, Salle des Herbes",
        """Carte Rose — On y tend le tissu ocre. On n'en coupe jamais trop. Alors que Hawa attend la nuit.
Carte Hawa — Chez nous on n'allume qu'après le repas, tandis que le Seuil allume dès l'ombre.
Carte Sami — Je n'y frappe qu'après le silence. Bien que les enfants bougent, j'attends.
Carte Aline — On y tient tous, pourtant le banc reste étroit. On n'invite ni trop tôt ni trop fort.
Carte Patrick — J'en parle à Radio Figuier. Je n'y étais pas l'an dernier.
Carte Léa — On n'y danse pas encore. On en discute d'abord, alors que Joël voudrait déjà tourner.
Carte Marc — Bien que Lila y soit, le micro attend Sami. On n'en enregistre que le refrain.
Carte Félicie — Je n'en sers que deux. Tandis que Dieudonné en voudrait davantage.
Carte Karim — Je n'y entre pas sans frapper, bien que j'aie la clé.
Carte Yvette — Hawa n'y reste pas trop debout. Pourtant elle sourit.
Carte Lila — On en informe dès midi. On y écoute à dix-neuf heures trente.
Carte Dieudonné — On n'y accroche rien sans fil. Alors que le vent de Rive-des-Saules insiste.""",
        tf_item=(
            "Chez Hawa, on n'allume qu'après le repas.",
            True,
            "Carte Hawa : « on n'allume qu'après le repas. »",
        ),
        qcm_item=(
            "Quand Sami frappe-t-il, d'après sa carte ?",
            [
                "Dès que les enfants bougent",
                "Seulement après le silence",
                "Pendant le repas",
                "Jamais",
            ],
            1,
            "« Je n'y frappe qu'après le silence. »",
        ),
        pairs=[
            ("on y tend", "tissu / salle"),
            ("n'en coupe jamais", "tissu"),
            ("tandis que le Seuil", "opposition d'heures"),
            ("bien que j'aie la clé", "concession de Karim"),
        ],
        fill_item=("Bien que j'___ la clé, je n'y entre pas sans frapper. (avoir)", "aie"),
        words=["On", "n'allume", "qu'après", "le", "repas", "."],
        anagram=("coutume", "Usage d'une famille, transmis, pas une loi."),
        error=(
            "Bien que les enfants bougent trop, Sami attend le silence, et il faut que tout le monde est prêt.",
            "Bien que les enfants bougent trop, Sami attend le silence, et il faut que tout le monde soit prêt.",
            "Il faut que + subjonctif : soit.",
        ),
        pic_start=11,
        pic_words=["une danse", "un démonstratif", "chacun", "un geste"],
        short_p="Recopiez quatre cartes et soulignez en, y, alors que / tandis que, bien que.",
        audio="Lisez les douze cartes de fêtes, sans aller trop vite.",
    ),
    _l(
        "PO",
        "PO — Opposer, concéder, reprendre en et y",
        "Comparer deux coutumes : en / y, négation, opposition, concession.",
        "Répétez, puis parlez d'une fête de votre cour.",
        "Modèles de Rose",
        """On y va en famille.
On en parle dès l'aube.
On n'allume jamais trop tôt.
On n'en joue qu'après le silence.
Alors que Rose a déjà tendu, Hawa attend.
Tandis que Kévin frappe, Sami attend.
Bien que la salle soit petite, on y tient.
Pourtant personne ne s'assoit n'importe où.
Je n'y entre pas sans frapper.
Je n'en prépare que deux.
On n'y danse pas encore.
On n'invite ni trop tôt ni trop fort.""",
        tf_item=(
            "« Pourtant » se construit souvent sans que, contrairement à « bien que ».",
            True,
            "Pourtant + phrase à l'indicatif. Bien que + subjonctif.",
        ),
        qcm_item=(
            "Quelle phrase contient une concession au subjonctif ?",
            [
                "Alors que Rose a déjà tendu",
                "Pourtant personne ne s'assoit n'importe où",
                "Bien que la salle soit petite",
                "Tandis que Kévin frappe",
            ],
            2,
            "Bien que + subjonctif : soit.",
        ),
        pairs=[
            ("y", "à ce lieu / à cela"),
            ("en", "de cela / une quantité"),
            ("alors que / tandis que", "opposition"),
            ("bien que", "concession + subj."),
        ],
        fill_item=("On ___ parle dès l'aube. (de la fête)", "en"),
        words=["Bien", "que", "la", "salle", "soit", "petite", "."],
        anagram=("pourtant", "Opposition : l'idée contraire, souvent après une virgule."),
        error=(
            "On y va en famille, et on en parle dès l'aube, bien que Sami est fatigué.",
            "On y va en famille, et on en parle dès l'aube, bien que Sami soit fatigué.",
            "Bien que + subjonctif : soit.",
        ),
        pic_start=12,
        pic_words=["un démonstratif", "chacun", "un geste", "une tasse"],
        short_p="Écrivez huit phrases : deux en, deux y, deux oppositions, deux bien que.",
        audio="Enregistrez les douze modèles, puis une comparaison de deux coutumes.",
    ),
    _l(
        "PE",
        "PE — Ma carte de coutume",
        "Écrire une carte qui compare deux façons de fêter.",
        "Imitez la carte de Sami.",
        "Carte de Sami Niyonteze",
        """Sami Niyonteze
Tambour — Veillée des Lampions
Chez moi, on n'y frappe qu'après le silence. On en parle peu, on écoute.
Alors que Kévin voudrait déjà danser, j'attends que la salle se taise.
Tandis que Radio Figuier en dit long, le tambour n'y va qu'une fois prêt.
Bien que les enfants bougent, je ne commence pas. Pourtant je souris.
Je n'invite ni précipitation ni micro trop près.
On n'y danse pas encore : Léa l'a dit, et j'y consens.
Je n'en joue jamais trop fort pour couvrir Félicie.
Rose a tendu le tissu ; j'y pense, je n'y touche pas.
Sami""",
        tf_item=(
            "Sami frappe dès que les enfants bougent.",
            False,
            "« Bien que les enfants bougent, je ne commence pas. »",
        ),
        qcm_item=(
            "Que refuse Sami près du tambour ?",
            [
                "Le tissu de Rose",
                "La précipitation et le micro trop près",
                "Le silence",
                "Léa",
            ],
            1,
            "« Je n'invite ni précipitation ni micro trop près. »",
        ),
        pairs=[
            ("n'y frappe qu'après", "restriction + y"),
            ("alors que Kévin", "opposition"),
            ("bien que les enfants", "concession"),
            ("ni… ni", "deux refus"),
        ],
        fill_item=("On n'y frappe ___ après le silence.", "qu'"),
        words=["Je", "n'en", "joue", "jamais", "trop", "fort", "."],
        anagram=("silence", "Sami attend ce calme avant le premier coup."),
        error=(
            "Tandis que Radio Figuier en dit long, le tambour n'y va qu'une fois prêt, bien que je suis patient.",
            "Tandis que Radio Figuier en dit long, le tambour n'y va qu'une fois prêt, bien que je sois patient.",
            "Bien que + subjonctif : sois.",
        ),
        pic_start=13,
        pic_words=["chacun", "un geste", "une tasse", "une liste"],
        short_p="Imitez : dix lignes, en, y, une opposition, un bien que, une négation ni… ni.",
        audio="Lisez votre carte de coutume, sans aller trop vite.",
    ),
    _l(
        "EL",
        "EL — En, y, opposition, concession",
        "Retenir en / y, les négations utiles, alors que / tandis que / bien que / pourtant.",
        "Apprenez la fiche.",
        "Fiche de Patrick",
        """Y = à ce lieu / à cela : on y va, j'y pense, on y tient, je n'y entre pas.
En = de cela / une quantité : on en parle, j'en joue, je n'en prépare que deux.
Négation : ne… jamais / plus / que / pas encore / ni… ni / sans.
Opposition (indicatif) : alors que, tandis que. Même cadre, deux tableaux.
Concession : bien que + subjonctif. Bien que la salle soit petite. Bien que j'aie la clé.
Pourtant + indicative : pourtant je reste. Pas de que.
On ne dit pas : bien que la salle est. On dit : bien que la salle soit.
alors que ≠ à l'heure (ce n'est pas un moment ici).
en / y se placent avant le verbe : j'en parle, j'y vais. Impératif : vas-y, parles-en.
Après bien que : être → soit / sois / soyons ; avoir → aie / ait / ayons.
Pour lier à la fête : on y danse, on en parle, bien qu'il fasse chaud.
Il faut que + subj. reste disponible : il faut que le silence soit là.""",
        tf_item=(
            "« Tandis que » demande le subjonctif.",
            False,
            "Tandis que + indicatif. Bien que + subjonctif.",
        ),
        qcm_item=(
            "Quelle phrase est correcte ?",
            [
                "Bien que la salle est petite",
                "Bien que la salle soit petite",
                "Bien que la salle sera petite",
                "Bien que la salle être petite",
            ],
            1,
            "Bien que + subjonctif : soit.",
        ),
        pairs=[
            ("y", "à / dans ce lieu"),
            ("en", "de cela"),
            ("alors que", "opposition"),
            ("bien que", "concession + subj."),
        ],
        fill_item=("Je n'___ entre pas sans frapper. (à la salle)", "y"),
        words=["On", "en", "parle", "dès", "l'aube", "."],
        anagram=("concession", "Bien que : on admet un fait, puis on oppose."),
        error=(
            "On y tient tous, pourtant le banc reste étroit, bien que Karim a cédé la clé.",
            "On y tient tous, pourtant le banc reste étroit, bien que Karim ait cédé la clé.",
            "Bien que + subjonctif : ait.",
        ),
        pic_start=14,
        pic_words=["un geste", "une tasse", "une liste", "une tâche"],
        short_p="Transformez : Je vais à la salle. / Je parle de la fête. / La salle est petite, on tient.",
        audio="Enregistrez la fiche et six exemples (en, y, opposition, concession).",
    ),
]


# ---------------------------------------------------------------------------
# Séquence 4 — Autour de la soirée (démonstratifs et indéfinis)
# ---------------------------------------------------------------------------

S4 = [
    _l(
        "CO",
        "CO — Celle-ci, ceux-là, chacun",
        "Repérer les démonstratifs (celui-ci / celui-là, celle, ceux) et les indéfinis (chacun, n'importe qui, plusieurs, quiconque).",
        "Lisez le dialogue. De qui, de quoi parle-t-on ?",
        "Salle des Herbes, lanternes allumées",
        """Léa : Celle-ci, la lanterne près du tambour, est à Rose. Celle-là, au fond, est à Dieudonné.
Patrick : Celui de Sami, le siège, reste libre. Celui-là, près de la porte, est à Karim.
Aline : Ceux qui dansent déjà, ce sont Joël et Kévin. Celles de Félicie, les tasses, sont chaudes.
Marc : Chacun range sa place. N'importe qui ne prend pas le micro.
Hawa : Plusieurs ont salué Yvette. Quiconque a mal s'assoit, sans discuter.
Rose : Je préfère celui-ci, le fil ocre, pas celui-là trop pâle.
Sami : Celle que Léa a choisie éclaire juste. Celles du marché clignotent trop.
Karim : Ceux du premier banc, Solange les a notés. Chacun montre son nom.
Lila : N'importe qui peut écouter Radio Figuier. Quiconque parle au micro passe par moi.
Félicie : Plusieurs ont déjà mangé. Celle-ci, la louche, reste à la table.
Joël : Je prends celui-là, le plus loin, pour ne pas gêner.
Dieudonné : Chacun tient une lanterne. N'importe qui n'accroche pas sans moi.""",
        tf_item=(
            "La lanterne près du tambour est à Rose.",
            True,
            "Léa : « Celle-ci, la lanterne près du tambour, est à Rose. »",
        ),
        qcm_item=(
            "Qui peut parler au micro, d'après Lila ?",
            [
                "N'importe qui, sans prévenir",
                "Quiconque, mais en passant par Lila",
                "Seulement Sami",
                "Personne",
            ],
            1,
            "« Quiconque parle au micro passe par moi. »",
        ),
        pairs=[
            ("celui-ci / celle-ci", "le plus proche"),
            ("celui-là / celle-là", "plus loin"),
            ("chacun", "tous, un par un"),
            ("n'importe qui", "une personne non choisie"),
        ],
        fill_item=("___ range sa place. (tous, un par un)", "Chacun"),
        words=["Chacun", "range", "sa", "place", "."],
        anagram=("celui", "…-ci : le plus proche, un démonstratif."),
        error=(
            "Ceux qui dansent déjà, c'est Joël et Kévin, près de la Salle des Herbes.",
            "Ceux qui dansent déjà, ce sont Joël et Kévin, près de la Salle des Herbes.",
            "Pluriel : ce sont (pas c'est) devant Joël et Kévin.",
        ),
        pic_start=15,
        pic_words=["une tasse", "une liste", "une tâche", "une salle"],
        short_p="Listez quatre démonstratifs et quatre indéfinis entendus, avec ce qu'ils reprennent.",
        audio="Enregistrez : Celle-ci est à Rose. Celui-là est à Karim. Chacun range sa place. N'importe qui ne prend pas le micro.",
    ),
    _l(
        "CE",
        "CE — Consignes de soirée",
        "Lire des consignes qui opposent celui-ci / celui-là et encadrent chacun / quiconque.",
        "Lisez les consignes, sans aller trop vite.",
        "Feuille d'Aline, entrée de la salle",
        """Salle des Herbes — autour de la soirée
Prenez celle-ci, la lanterne stable. Laissez celle-là, trop fragile, au panier.
Celui de Sami ne se déplace pas. Celui-là, près de Yvette, reste un siège de repos.
Ceux qui portent le tissu passent à gauche. Celles de Rose, les épingles, restent dans la boîte.
Chacun salue en entrant. N'importe qui n'ouvre pas le local : Karim seulement, ou Dieudonné.
Plusieurs peuvent aider Félicie. Quiconque a les mains sales se lave au bac du Seuil.
Celle que Lila tient, la feuille d'horaire, ne se froisse pas.
Ceux du Bureau des Escales, Solange les a listés : pas de place fantôme.
Chacun tient sa tasse. Celle-ci se range ; celle-là, fêlée, se pose à part.
N'importe qui n'invite pas un passant. Quiconque entre a été nommé.
Plusieurs ont déjà un ticket ocre. Celui de Joël est resté sous le capot : il en cherche un autre.
Hawa s'assoit : celle de Yvette, la place, n'est pas un passage.
Dieudonné : ceux-ci, les crochets, oui ; ceux-là, trop fins, non.""",
        tf_item=(
            "N'importe qui peut ouvrir le local.",
            False,
            "« N'importe qui n'ouvre pas le local : Karim seulement, ou Dieudonné. »",
        ),
        qcm_item=(
            "Que fait quiconque a les mains sales ?",
            [
                "Prend le micro",
                "Se lave au bac du Seuil",
                "Danse au milieu",
                "Ouvre le local",
            ],
            1,
            "« Quiconque a les mains sales se lave au bac du Seuil. »",
        ),
        pairs=[
            ("celle-ci stable", "à prendre"),
            ("celle-là fragile", "au panier"),
            ("chacun salue", "entrée"),
            ("quiconque a les mains", "bac du Seuil"),
        ],
        fill_item=("___ salue en entrant.", "Chacun"),
        words=["N'importe", "qui", "n'ouvre", "pas", "le", "local", "."],
        anagram=("chacun", "Toutes les personnes, une par une."),
        error=(
            "Ceux qui portent le tissu passent à gauche, et il faut que chacun saluent en entrant.",
            "Ceux qui portent le tissu passent à gauche, et il faut que chacun salue en entrant.",
            "Chacun = un par un, verbe au singulier : salue. Subjonctif identique ici.",
        ),
        pic_start=16,
        pic_words=["une liste", "une tâche", "une salle", "un marché"],
        short_p="Recopiez six consignes et reliez chaque démonstratif ou indéfini à son nom.",
        audio="Lisez les consignes de soirée, sans aller trop vite.",
    ),
    _l(
        "PO",
        "PO — Celui-ci, chacun, quiconque",
        "Désigner et généraliser : démonstratifs et indéfinis à l'oral.",
        "Répétez, puis décrivez la salle pendant une fête.",
        "Modèles de Léa",
        """Celle-ci est à Rose.
Celle-là est à Dieudonné.
Celui de Sami reste libre.
Ceux qui dansent, ce sont Joël et Kévin.
Chacun range sa place.
N'importe qui ne prend pas le micro.
Plusieurs ont salué Yvette.
Quiconque a mal s'assoit.
Je préfère celui-ci, pas celui-là.
Celles de Félicie sont chaudes.
Ceux-ci, les crochets, oui.
Quiconque entre a été nommé.""",
        tf_item=(
            "« N'importe qui » et « quiconque » ne se placent pas toujours dans les mêmes phrases.",
            True,
            "N'importe qui souvent avec restriction (ne… pas). Quiconque = toute personne qui.",
        ),
        qcm_item=(
            "Quelle phrase est correcte au pluriel ?",
            [
                "C'est Joël et Kévin qui dansent déjà",
                "Ce sont Joël et Kévin qui dansent déjà",
                "C'est ceux qui dansent déjà Joël",
                "Ce Joël et Kévin dansent",
            ],
            1,
            "Ce sont + pluriel de personnes.",
        ),
        pairs=[
            ("celui-ci", "proche"),
            ("celui-là", "éloigné"),
            ("chacun", "distribution"),
            ("quiconque", "toute personne qui"),
        ],
        fill_item=("Je préfère celui-___, pas celui-là.", "ci"),
        words=["Quiconque", "a", "mal", "s'assoit", "."],
        anagram=("quiconque", "Toute personne, un indéfini large."),
        error=(
            "Chacun rangent sa place avant la danse, près des lanternes ocre.",
            "Chacun range sa place avant la danse, près des lanternes ocre.",
            "Chacun : verbe au singulier.",
        ),
        pic_start=17,
        pic_words=["une tâche", "une salle", "un marché", "un lendemain"],
        short_p="Écrivez huit phrases : quatre démonstratifs, quatre indéfinis.",
        audio="Enregistrez les douze modèles, puis décrivez quatre objets de la salle.",
    ),
    _l(
        "PE",
        "PE — Ma note de soirée",
        "Écrire une note qui désigne (celui-ci / celle-là) et encadre les comportements (chacun, quiconque).",
        "Imitez la note de Karim.",
        "Note de Karim Bamba",
        """Karim Bamba
Local de la Salle des Herbes
Celle-ci, la clé du jour, reste sur la table. Celle-là, la clé de nuit, ne sort pas.
Celui de Sami, le siège, ne se déplace pas. Celui-là, près de Yvette, est un repos.
Chacun frappe avant d'entrer. N'importe qui n'emprunte pas le local.
Plusieurs ont déjà rendu une lanterne. Quiconque casse un crochet me prévient.
Ceux qui portent le tissu passent à gauche. Celles de Rose restent dans la boîte.
Je préfère ceux-ci, les crochets larges, pas ceux-là trop fins.
Chacune des tasses de Félicie revient à la table. Celle fêlée se pose à part.
Quiconque parle au micro passe par Lila. Ce n'est pas n'importe qui.
Karim""",
        tf_item=(
            "La clé de nuit peut sortir, d'après Karim.",
            False,
            "« Celle-là, la clé de nuit, ne sort pas. »",
        ),
        qcm_item=(
            "Qui doit prévenir Karim si un crochet casse ?",
            ["Seulement Dieudonné", "N'importe qui sans le dire", "Quiconque casse un crochet", "Personne"],
            2,
            "« Quiconque casse un crochet me prévient. »",
        ),
        pairs=[
            ("celle-ci / celle-là", "deux clés"),
            ("chacun frappe", "entrée"),
            ("n'importe qui n'emprunte pas", "restriction"),
            ("quiconque casse", "prévenir"),
        ],
        fill_item=("___ frappe avant d'entrer.", "Chacun"),
        words=["Celle-ci", "reste", "sur", "la", "table", "."],
        anagram=("plusieurs", "Plus d'un, pas tous forcément."),
        error=(
            "Chacun frappent avant d'entrer, afin que le local reste en ordre, ce soir.",
            "Chacun frappe avant d'entrer, afin que le local reste en ordre, ce soir.",
            "Chacun : singulier, frappe. Afin que + subjonctif : reste (identique à l'indicatif ici).",
        ),
        pic_start=18,
        pic_words=["une salle", "un marché", "un lendemain", "un merci"],
        short_p="Imitez : dix lignes, trois démonstratifs et trois indéfinis au moins.",
        audio="Lisez votre note de soirée, sans aller trop vite.",
    ),
    _l(
        "EL",
        "EL — Démonstratifs et indéfinis",
        "Retenir celui-ci / celui-là / celle / ceux et chacun, n'importe qui, plusieurs, quiconque.",
        "Apprenez la fiche.",
        "Fiche de Marc",
        """Démonstratifs : celui, celle, ceux, celles. + -ci (proche) / -là (loin).
Celui de Sami = le siège de Sami. Celle-ci = cette lanterne-ci.
Ceux qui + verbe : ceux qui dansent. Celles que Rose a cousues.
Ce sont + pluriel de personnes. C'est + singulier (c'est Sami qui…).
Chacun / chacune : un par un, verbe au singulier. Chacun range. Chacune revient.
N'importe qui : une personne non choisie. Souvent avec ne… pas pour limiter.
Plusieurs : plus d'un, quantité vague. Plusieurs ont salué.
Quiconque = toute personne qui. Quiconque a mal s'assoit. Un peu soutenu.
On ne dit pas : chacun rangent. On ne dit pas : c'est Joël et Kévin (on dit ce sont).
celui sans article : pas le celui.
N'importe qui ≠ quiconque : le premier est flou ; le second pose une condition.
Pour la soirée : désigner (celle-ci) puis encadrer (chacun, quiconque).""",
        tf_item=(
            "On écrit « le celui de Sami ».",
            False,
            "Celui de Sami, sans article devant celui.",
        ),
        qcm_item=(
            "Quelle phrase est correcte ?",
            [
                "Chacun rangent",
                "Chacun range",
                "Chacun ranger",
                "Chacun as range",
            ],
            1,
            "Chacun + verbe singulier.",
        ),
        pairs=[
            ("celui-ci", "proche"),
            ("celui-là", "loin"),
            ("chacun", "un par un"),
            ("quiconque", "toute personne qui"),
        ],
        fill_item=("Ce ___ Joël et Kévin qui dansent. (être au pluriel)", "sont"),
        words=["Je", "préfère", "celui-ci", "pas", "celui-là", "."],
        anagram=("indefini", "Chacun, n'importe qui : un… (sans accent)."),
        error=(
            "C'est Joël et Kévin qui dansent déjà, près du tambour de Sami, ce soir.",
            "Ce sont Joël et Kévin qui dansent déjà, près du tambour de Sami, ce soir.",
            "Deux personnes : ce sont.",
        ),
        pic_start=19,
        pic_words=["un marché", "un lendemain", "un merci", "une photo"],
        short_p="Remplacez : cette lanterne-ci / ces sièges-là / toutes les personnes une à une / toute personne qui a mal.",
        audio="Enregistrez la fiche et huit exemples (quatre démonstratifs, quatre indéfinis).",
    ),
]


# ---------------------------------------------------------------------------
# Séquence 5 — Préparer la veillée (EXTRA : organisation concrète)
# ---------------------------------------------------------------------------

S5 = [
    _l(
        "CO",
        "CO — La liste avant vingt heures",
        "Comprendre une organisation concrète qui reprend conseil, but, rôles et objets.",
        "Lisez le dialogue. Qui fait quoi, pour que la veillée tienne ?",
        "Salle des Herbes, après-midi",
        """Aline : Tu devrais cocher la liste, Léa. C'est toi qui as proposé : tu suis.
Léa : Si j'étais toi, Joël, je porterais les bancs. C'est le passage que l'on doit garder.
Rose : J'apporte celui-ci, le tissu ocre, afin que Dieudonné l'accroche sans chercher.
Sami : Je n'y frappe qu'après le silence, pour que chacun entende le premier coup.
Félicie : Je ne sers que deux plateaux, de façon à tenir jusqu'à minuit.
Karim : Celle-ci, la clé, reste sur la table. N'importe qui ne l'emprunte pas.
Lila : Radio Figuier informe pour que Val-des-Peupliers n'arrive pas à vingt et une heures.
Hawa : Yvette a dit de m'asseoir. Plusieurs peuvent m'apporter de l'eau, pas n'importe quel verre.
Marc : C'est le micro que tu poses là, Lila, pas celui-là trop près du tambour.
Dieudonné : Quiconque monte à l'échelle me prévient. Je tiens afin que Rose ne tombe pas.
Patrick : On range sans crier, bien que le temps soit court.
Solange : Le Bureau note ceux du premier rang, pour que personne n'invente une place.""",
        tf_item=(
            "C'est Léa qui a proposé, donc elle suit la liste, d'après Aline.",
            True,
            "Aline : « C'est toi qui as proposé : tu suis. »",
        ),
        qcm_item=(
            "Que fait Sami, et pourquoi ?",
            [
                "Il frappe tout de suite pour couvrir les voix",
                "Il n'y frappe qu'après le silence, pour que chacun entende",
                "Il range les tasses",
                "Il prend la clé",
            ],
            1,
            "Sami : « Je n'y frappe qu'après le silence, pour que chacun entende. »",
        ),
        pairs=[
            ("tu devrais cocher", "conseil à Léa"),
            ("afin que Dieudonné l'accroche", "but du tissu"),
            ("celle-ci, la clé", "démonstratif concret"),
            ("quiconque monte", "règle d'échelle"),
        ],
        fill_item=("J'apporte le tissu afin que Dieudonné l'___. (accrocher)", "accroche"),
        words=["Tu", "devrais", "cocher", "la", "liste", "."],
        anagram=("taches", "Liste des… : ce qu'il faut faire (sans accent)."),
        error=(
            "Je n'y frappe qu'après le silence, pour que chacun entend le premier coup, dans la salle.",
            "Je n'y frappe qu'après le silence, pour que chacun entende le premier coup, dans la salle.",
            "Pour que + subjonctif : entende.",
        ),
        pic_start=20,
        pic_words=["un lendemain", "un merci", "une photo", "un balai"],
        short_p="Dressez la liste des rôles : nom, objet, but (pour / pour que).",
        audio="Enregistrez : Tu devrais cocher la liste. J'apporte celui-ci afin que Dieudonné l'accroche. Quiconque monte à l'échelle me prévient.",
    ),
    _l(
        "CE",
        "CE — Liste de tâches ocre",
        "Lire une liste d'organisation qui synthétise les outils du module.",
        "Lisez la liste, sans aller trop vite.",
        "Cahier du chemin, page Veillée",
        """Liste — Veillée des Lampions, Salle des Herbes
1. Léa coche. C'est elle qui a proposé. Tu devrais tout relire avant dix-neuf heures.
2. Joël porte les bancs afin de garder le passage. Si j'étais toi, j'en mettrais deux de côté.
3. Rose : celui-ci, le tissu. Dieudonné accroche pour que la salle ait un fond ocre.
4. Sami n'y frappe qu'après le silence. Bien que les enfants bougent, on attend.
5. Félicie ne sert que deux plateaux, sans troisième service.
6. Karim : celle-ci sur la table. N'importe qui n'ouvre pas. Quiconque emprunte signe.
7. Lila informe à Radio Figuier, de façon à prévenir Rive-des-Saules et Val-des-Peupliers.
8. Yvette a dit de garder un siège. Hawa s'y assoit. Plusieurs apportent de l'eau.
9. Marc pose celui-ci, le micro, pas celui-là trop près. C'est Lila qui parle d'abord.
10. Solange note ceux du premier rang, afin que personne n'invente une place.
11. On range sans crier. On n'invite ni passant ni vendeur trop pressé.
12. On éteint à minuit pour que le Pavillon du Saule retrouve le calme.""",
        tf_item=(
            "On éteint à minuit pour que le Pavillon retrouve le calme.",
            True,
            "Point 12 de la liste.",
        ),
        qcm_item=(
            "Qui doit signer s'il emprunte, d'après le point 6 ?",
            ["N'importe qui, sans trace", "Quiconque emprunte", "Seulement Rose", "Personne"],
            1,
            "« Quiconque emprunte signe. »",
        ),
        pairs=[
            ("c'est elle qui a proposé", "Léa"),
            ("celui-ci, le tissu", "Rose"),
            ("celle-ci sur la table", "clé / Karim"),
            ("ceux du premier rang", "Solange"),
        ],
        fill_item=("Dieudonné accroche pour que la salle ___ un fond ocre. (avoir)", "ait"),
        words=["On", "éteint", "à", "minuit", "pour", "que", "le", "Pavillon", "retrouve", "le", "calme", "."],
        anagram=("tambour", "Sami le porte : instrument de la veillée."),
        error=(
            "Dieudonné accroche pour que la salle a un fond ocre, dès dix-neuf heures.",
            "Dieudonné accroche pour que la salle ait un fond ocre, dès dix-neuf heures.",
            "Pour que + subjonctif : ait.",
        ),
        pic_start=21,
        pic_words=["un merci", "une photo", "un balai", "une radio"],
        short_p="Recopiez la liste et marquez conseil / but / démonstratif / indéfini.",
        audio="Lisez la liste de tâches ocre, sans aller trop vite.",
    ),
    _l(
        "PO",
        "PO — Répartir les tâches",
        "Organiser à voix haute : qui fait quoi, avec quel objet, dans quel but.",
        "Répétez, puis répartissez une veillée inventée.",
        "Modèles d'Aline",
        """Tu devrais cocher la liste.
C'est Léa qui suit.
J'apporte celui-ci, le tissu.
Dieudonné accroche afin que le fond tienne.
Sami n'y frappe qu'après le silence.
Chacun range sa place.
N'importe qui n'ouvre pas le local.
Quiconque monte me prévient.
On informe pour que les rives arrivent à l'heure.
On ne sert que deux plateaux.
On range sans crier.
On éteint à minuit, pour que le silence revienne.""",
        tf_item=(
            "Une bonne liste mêle personnes, objets et buts.",
            True,
            "Qui / quoi / pour que…",
        ),
        qcm_item=(
            "Quelle phrase pose un but au subjonctif ?",
            [
                "Tu devrais cocher la liste",
                "On ne sert que deux plateaux",
                "On informe pour que les rives arrivent à l'heure",
                "On range sans crier",
            ],
            2,
            "Pour que les rives arrivent : subjonctif (identique à l'indicatif pour -er, 3e pers. pl.).",
        ),
        pairs=[
            ("tu devrais", "lancer la tâche"),
            ("celui-ci", "désigner l'objet"),
            ("afin que / pour que", "but"),
            ("chacun / quiconque", "règle collective"),
        ],
        fill_item=("Quiconque monte me ___. (prévenir)", "prévient"),
        words=["C'est", "Léa", "qui", "suit", "."],
        anagram=("tissu", "Rose l'apporte : étoffe ocre de l'atelier."),
        error=(
            "On informe pour que les rives arrivent à l'heure, et il faut que Lila lit l'annonce.",
            "On informe pour que les rives arrivent à l'heure, et il faut que Lila lise l'annonce.",
            "Il faut que + subjonctif : lise.",
        ),
        pic_start=22,
        pic_words=["une photo", "un balai", "une radio", "un figuier"],
        short_p="Écrivez une liste orale de dix tâches, une phrase chacune.",
        audio="Enregistrez les douze modèles, puis votre répartition (six rôles).",
    ),
    _l(
        "PE",
        "PE — Ma liste de veillée",
        "Écrire une liste concrète : rôles, objets, buts, règles.",
        "Imitez la liste de Dieudonné.",
        "Liste de Dieudonné Hakizimana",
        """Dieudonné Hakizimana
Atelier du Tissu — Salle des Herbes
Tu devrais me passer celui-ci, le crochet large, pas celui-là trop fin.
C'est Rose qui tient le tissu. Je monte afin qu'elle n'ait pas à grimper.
Quiconque s'approche de l'échelle me prévient. N'importe qui n'y grimpe pas.
Sami n'y frappe qu'après le silence, pour que chacun entende.
Félicie ne sert que deux plateaux. Je n'en demande plus un troisième.
Karim laisse celle-ci, la clé, sur la table. Je ferme dès l'ombre.
Lila informe à Radio Figuier, de façon à ce que Val-des-Peupliers parte à temps.
On range sans crier, bien que le temps soit court.
On éteint à minuit pour que le Pavillon du Saule souffle.
Dieudonné""",
        tf_item=(
            "Dieudonné veut que Rose grimpe à sa place.",
            False,
            "« Je monte afin qu'elle n'ait pas à grimper. »",
        ),
        qcm_item=(
            "Quel crochet Dieudonné demande-t-il ?",
            [
                "Celui-là trop fin",
                "Celui-ci, le crochet large",
                "N'importe lequel",
                "Celui de Sami",
            ],
            1,
            "« celui-ci, le crochet large, pas celui-là trop fin. »",
        ),
        pairs=[
            ("celui-ci / celui-là", "deux crochets"),
            ("afin qu'elle n'ait pas", "but de sécurité"),
            ("quiconque s'approche", "règle d'échelle"),
            ("pour que chacun entende", "but du silence"),
        ],
        fill_item=("Je monte afin qu'elle n'___ pas à grimper. (avoir)", "ait"),
        words=["Je", "monte", "afin", "qu'elle", "n'ait", "pas", "à", "grimper", "."],
        anagram=("lanterne", "Lumière de papier, prête pour le cortège."),
        error=(
            "Je monte afin qu'elle n'a pas à grimper, près du fond ocre de la salle.",
            "Je monte afin qu'elle n'ait pas à grimper, près du fond ocre de la salle.",
            "Afin que + subjonctif : ait.",
        ),
        pic_start=23,
        pic_words=["un balai", "une radio", "un figuier", "un tissu"],
        short_p="Imitez : dix lignes, un conseil, deux buts, deux démonstratifs, un indéfini.",
        audio="Lisez votre liste de veillée, sans aller trop vite.",
    ),
    _l(
        "EL",
        "EL — Synthèse d'organisation",
        "Relier conseil, mise en relief, but, démonstratifs et indéfinis pour une liste efficace.",
        "Apprenez la fiche.",
        "Fiche de la Salle des Herbes",
        """Lancer : tu devrais / si j'étais toi / à ta place + conditionnel (je serais, je porterais).
Désigner le responsable : c'est Léa qui / c'est le micro que.
Désigner l'objet : celui-ci, celle-là, ceux du premier rang.
But, même sujet : pour / afin de / de façon à + infinitif.
But, autre sujet : pour que / afin que + subjonctif (puisse, ait, entende, voie).
Règle collective : chacun + singulier ; n'importe qui + souvent ne… pas ; quiconque + condition.
Concession du stress : bien que le temps soit court, on range sans crier.
Informer : horaire, entrée, qui parle (Radio Figuier, Lila).
Un seul il faut : il faut que tu coches / il faut cocher.
Ne pas empiler trop d'outils dans la même phrase.
La liste se lit à voix haute, une tâche, une pause.
Après minuit : autre séquence, le bilan.""",
        tf_item=(
            "« De façon à ce que » se construit avec le subjonctif.",
            True,
            "De façon à + inf. ; de façon à ce que + subj. (Lila, Val-des-Peupliers).",
        ),
        qcm_item=(
            "Quelle série va avec un changement de sujet ?",
            [
                "pour, afin de, de façon à",
                "pour que, afin que",
                "tu devrais, à ta place",
                "celui-ci, celle-là",
            ],
            1,
            "Pour que / afin que + subjonctif.",
        ),
        pairs=[
            ("c'est… qui", "rôle"),
            ("celui-ci", "objet"),
            ("pour que + subj.", "but"),
            ("chacun / quiconque", "règle"),
        ],
        fill_item=("C'est Léa ___ a proposé.", "qui"),
        words=["On", "range", "sans", "crier", "."],
        anagram=("organisation", "Répartir les rôles, les heures, les objets."),
        error=(
            "On éteint à minuit pour que le Pavillon retrouve le calme, et je serai d'accord si Joël aidait.",
            "On éteint à minuit pour que le Pavillon retrouve le calme, et je serais d'accord si Joël aidait.",
            "Si + imparfait → conditionnel serais, pas futur serai.",
        ),
        pic_start=24,
        pic_words=["une radio", "un figuier", "un tissu", "un tambour"],
        short_p="Tableau : tâche / qui / objet / but / outil grammatical.",
        audio="Enregistrez la fiche et une mini-liste de cinq tâches liées.",
    ),
]


# ---------------------------------------------------------------------------
# Séquence 6 — Après la fête (EXTRA : raconter, remercier, bilan)
# ---------------------------------------------------------------------------

S6 = [
    _l(
        "CO",
        "CO — Le lendemain sous le figuier",
        "Comprendre un bilan oral : raconter, remercier, évaluer.",
        "Lisez le dialogue. Qu'est-ce qui a marché ? Que reste-t-il à faire ?",
        "Cour du Seuil, matin ocre",
        """Léa : C'est Sami qui a tenu le silence, donc le premier coup a porté. Merci à lui.
Patrick : Si j'étais Joël, je serais fier : tu as porté les bancs afin que le passage reste.
Aline : Bien que la salle ait été petite, on y a tenu. Pourtant deux tasses se sont fêlées.
Rose : Celle-ci, la cape, a tenu. Celle-là, trop fine, non. Merci à Dieudonné.
Hawa : Yvette m'a dit de m'asseoir. Je suis contente qu'elle ait veillé. Plusieurs m'ont saluée.
Marc : Lila a informé pour que Val-des-Peupliers arrive à l'heure. Quiconque était perdu l'a entendue.
Karim : N'importe qui n'a pas pris la clé. Chacun a signé. C'est pourquoi le local est intact.
Félicie : Je n'en ai servi que deux, si bien que rien n'a manqué. Merci à ceux qui ont rangé.
Joël : Tu devrais garder cette heure-là, Sami. C'est le rythme que la cour a aimé.
Sami : J'en joue encore dans la tête. Je n'y retournerais pas sans vous.
Solange : Le Bureau remercie. Il faut que Lila dépose le bilan, afin que l'on s'en souvienne.
Dieudonné : On balaie pour que le figuier reste une cour, pas une salle trop tard.""",
        tf_item=(
            "Deux tasses se sont fêlées, malgré une salle qui a tenu.",
            True,
            "Aline : « Bien que la salle ait été petite, on y a tenu. Pourtant deux tasses se sont fêlées. »",
        ),
        qcm_item=(
            "Que doit faire Lila, d'après Solange ?",
            [
                "Rejouer du tambour",
                "Déposer le bilan, afin que l'on s'en souvienne",
                "Vendre des tickets",
                "Ouvrir le local la nuit",
            ],
            1,
            "« Il faut que Lila dépose le bilan, afin que l'on s'en souvienne. »",
        ),
        pairs=[
            ("c'est Sami qui a tenu", "récit en relief"),
            ("merci à Dieudonné", "remerciement"),
            ("bien que la salle ait été", "concession au passé"),
            ("il faut que Lila dépose", "bilan à écrire"),
        ],
        fill_item=("Il faut que Lila ___ le bilan. (déposer)", "dépose"),
        words=["Merci", "à", "ceux", "qui", "ont", "rangé", "."],
        anagram=("balai", "On l'attrape le matin : pour la cour, après la danse."),
        error=(
            "Bien que la salle a été petite, on y a tenu, pourtant deux tasses se sont fêlées.",
            "Bien que la salle ait été petite, on y a tenu, pourtant deux tasses se sont fêlées.",
            "Bien que + subjonctif passé : ait été.",
        ),
        pic_start=25,
        pic_words=["un figuier", "un tissu", "un tambour", "une horloge"],
        short_p="Notez un succès, un regret, deux mercis et une tâche du lendemain.",
        audio="Enregistrez : C'est Sami qui a tenu le silence. Merci à Dieudonné. Bien que la salle ait été petite, on y a tenu. Il faut que Lila dépose le bilan.",
    ),
    _l(
        "CE",
        "CE — Bilan collé au figuier",
        "Lire un bilan écrit : récit, remerciements, suite.",
        "Lisez le bilan, sans aller trop vite.",
        "Feuille de Lila Sow, Radio Figuier",
        """Bilan — Veillée des Lampions
C'est Léa qui avait proposé. C'est la cour que l'on a retrouvée, pas une foule inconnue.
Sami n'y a frappé qu'après le silence, si bien que chacun a entendu. Merci à lui.
Rose a tendu celui-ci, le tissu ocre. Dieudonné a tenu l'échelle afin qu'elle n'ait pas à monter.
Félicie n'en a servi que deux. Pourtant personne n'est resté le ventre vide.
Bien que la salle ait été étroite, on y a dansé. Alors que Joël doutait, il a porté les bancs.
Karim : n'importe qui n'a pas pris la clé. Quiconque entrait signait. Le local est intact.
Hawa s'est assise : je suis contente qu'Yvette ait veillé. Plusieurs l'ont saluée.
On a éteint à minuit pour que le Pavillon du Saule retrouve le calme.
Il faut que nous balayions avant midi. Solange a dit de déposer cette feuille au Bureau.
On n'invite plus de cortège sans liste, c'est pourquoi celle de Léa restera au Cahier du chemin.
Merci à Radio Figuier, à Rive-des-Saules, à Val-des-Peupliers.
Lila Sow — lendemain ocre""",
        tf_item=(
            "Personne n'est resté le ventre vide, même avec deux plateaux.",
            True,
            "« Félicie n'en a servi que deux. Pourtant personne n'est resté le ventre vide. »",
        ),
        qcm_item=(
            "Que faut-il faire avant midi ?",
            ["Rejouer", "Balayer", "Ouvrir le marché", "Partir à moto"],
            1,
            "« Il faut que nous balayions avant midi. »",
        ),
        pairs=[
            ("c'est Léa qui avait proposé", "origine"),
            ("merci à lui", "Sami"),
            ("afin qu'elle n'ait pas", "Rose / échelle"),
            ("il faut que nous balayions", "lendemain"),
        ],
        fill_item=("Il faut que nous ___ avant midi. (balayer)", "balayions"),
        words=["Il", "faut", "que", "nous", "balayions", "avant", "midi", "."],
        anagram=("bilan", "On reprend ce qui a marché, ce qui reste."),
        error=(
            "Il faut que nous balayons avant midi, afin que la cour soit nette, sous le figuier.",
            "Il faut que nous balayions avant midi, afin que la cour soit nette, sous le figuier.",
            "Balayer au subjonctif, nous : balayions (pas balayons).",
        ),
        pic_start=26,
        pic_words=["un tissu", "un tambour", "une horloge", "un cœur"],
        short_p="Recopiez le bilan : soulignez un récit, un merci, un but, une suite.",
        audio="Lisez le bilan collé au figuier, sans aller trop vite.",
    ),
    _l(
        "PO",
        "PO — Raconter, remercier, conclure",
        "Faire un bilan oral : mise en relief au passé, merci, suite au subjonctif.",
        "Répétez, puis racontez une fête du Seuil.",
        "Modèles de Léa",
        """C'est Sami qui a tenu le silence.
C'est la cour que l'on a retrouvée.
Merci à Rose.
Merci à ceux qui ont rangé.
Bien que la salle ait été petite, on y a tenu.
Pourtant deux tasses se sont fêlées.
Je suis contente qu'Yvette ait veillé.
Il faut que nous balayions.
On a éteint pour que le silence revienne.
Je n'en servirais plus trois, si j'étais Félicie.
Tu devrais garder cette heure-là.
Quiconque voudra relire passera au Cahier du chemin.""",
        tf_item=(
            "Le bilan mêle passé (récit) et subjonctif (suite).",
            True,
            "A tenu / ait été / il faut que nous balayions.",
        ),
        qcm_item=(
            "Quelle phrase remercie un groupe ?",
            [
                "C'est Sami qui a tenu le silence",
                "Merci à ceux qui ont rangé",
                "Il faut que nous balayions",
                "Pourtant deux tasses se sont fêlées",
            ],
            1,
            "Merci à ceux qui…",
        ),
        pairs=[
            ("c'est… qui a", "récit en relief"),
            ("merci à", "gratitude"),
            ("bien que + subj. passé", "concession"),
            ("il faut que nous balayions", "suite"),
        ],
        fill_item=("Je suis contente qu'Yvette ___ veillé. (avoir)", "ait"),
        words=["Merci", "à", "Rose", "."],
        anagram=("remercier", "Dire sa gratitude à Rose, à Sami, à Félicie."),
        error=(
            "Je suis contente qu'Yvette a veillé, toute la soirée, près d'Hawa.",
            "Je suis contente qu'Yvette ait veillé, toute la soirée, près d'Hawa.",
            "Je suis content(e) que + subjonctif : ait veillé.",
        ),
        pic_start=27,
        pic_words=["un tambour", "une horloge", "un cœur", "une sortie"],
        short_p="Écrivez un bilan oral de dix phrases : trois récits, trois mercis, deux regrets, deux suites.",
        audio="Enregistrez les douze modèles, puis votre bilan en six phrases.",
    ),
    _l(
        "PE",
        "PE — Mon mot de remerciement",
        "Écrire un mot qui raconte, remercie et propose une suite.",
        "Imitez le mot de Rose.",
        "Mot de Rose Iradukunda",
        """Rose Iradukunda
Atelier du Tissu — lendemain de veillée
C'est Sami qui a tenu le silence, donc le tissu a pu se voir. Merci à lui.
C'est Dieudonné qui a tenu l'échelle, afin que je n'aie pas à monter. Merci.
Bien que la salle ait été petite, celle-ci, la cape, a tenu. Celle-là, non.
Je suis contente que Léa ait proposé. J'ai peur que l'on oublie la liste : il faut qu'on la recopie.
Chacun a rangé. N'importe qui n'a pas emporté un crochet. Quiconque en trouve un me le rend.
Félicie n'en a servi que deux, pourtant la table a suffi. Merci à ceux qui ont lavé.
On a éteint pour que le Pavillon souffle. Il faut que nous balayions avant midi.
Si j'étais Lila, je serais fière de l'annonce : Val-des-Peupliers est arrivé à l'heure.
Rose""",
        tf_item=(
            "Rose veut que l'on recopie la liste, de peur qu'on l'oublie.",
            True,
            "« J'ai peur que l'on oublie la liste : il faut qu'on la recopie. »",
        ),
        qcm_item=(
            "De qui Rose serait-elle fière, si elle était à sa place ?",
            ["Joël", "Karim", "Lila", "Yvette"],
            2,
            "« Si j'étais Lila, je serais fière de l'annonce. »",
        ),
        pairs=[
            ("c'est Sami qui", "récit"),
            ("merci à lui", "tambour"),
            ("afin que je n'aie pas", "échelle"),
            ("il faut que nous balayions", "suite"),
        ],
        fill_item=("Si j'étais Lila, je ___ fière de l'annonce. (être)", "serais"),
        words=["Il", "faut", "qu'on", "la", "recopie", "."],
        anagram=("lendemain", "Le jour après la veillée, le balai à la main."),
        error=(
            "Si j'étais Lila, je serai fière de l'annonce, car Val-des-Peupliers est arrivé à l'heure.",
            "Si j'étais Lila, je serais fière de l'annonce, car Val-des-Peupliers est arrivé à l'heure.",
            "Si + imparfait → conditionnel : serais.",
        ),
        pic_start=28,
        pic_words=["une horloge", "un cœur", "une sortie", "un conseil"],
        short_p="Imitez : dix lignes, un récit en relief, deux mercis, un que + subj., un je serais.",
        audio="Lisez votre mot de remerciement, sans aller trop vite.",
    ),
    _l(
        "EL",
        "EL — Raconter, remercier, boucler",
        "Retenir les formes du bilan : relief au passé, subjonctif passé, merci, suite.",
        "Apprenez la fiche.",
        "Fiche du lendemain",
        """Raconter : c'est X qui a + participe. C'est la cour que l'on a retrouvée.
Remercier : merci à + nom. Merci à ceux qui ont rangé. On peut nommer l'objet (le silence, l'échelle).
Concession au passé : bien que la salle ait été petite (avoir : ait été).
Sentiment au passé : je suis content(e) qu'elle ait veillé / que Léa ait proposé.
Suite : il faut que nous balayions / qu'on recopie. Pour que le Pavillon souffle.
Conditionnel de bilan : si j'étais Lila, je serais fière. Pas : je serai.
Y / en au passé : on y a tenu, je n'en ai servi que deux, j'en joue encore dans la tête.
Indéfinis : chacun a rangé ; n'importe qui n'a pas pris la clé ; quiconque voudra relire.
Un bilan tient sur une feuille : succès, limite, merci, tâche.
Toujours il faut, 3e personne.
On dépose au Bureau des Escales, afin que l'on s'en souvienne.
Le figuier redevient une cour : on balaie, on remercie, on note.""",
        tf_item=(
            "« Bien que la salle ait été petite » est un subjonctif passé.",
            True,
            "Ait été = avoir au subjonctif + été.",
        ),
        qcm_item=(
            "Quelle phrase est un conditionnel de bilan ?",
            [
                "Je serai fière demain sans condition",
                "Si j'étais Lila, je serais fière",
                "Je suis fière",
                "Il faut que je sois fière",
            ],
            1,
            "Si + imparfait + conditionnel.",
        ),
        pairs=[
            ("c'est… qui a", "récit"),
            ("merci à", "gratitude"),
            ("ait été / ait veillé", "subjonctif passé"),
            ("il faut que nous balayions", "suite"),
        ],
        fill_item=("Bien que la salle ___ été petite. (avoir)", "ait"),
        words=["C'est", "Sami", "qui", "a", "tenu", "le", "silence", "."],
        anagram=("souvenir", "Ce qui reste dans la tête, et sur la photo."),
        error=(
            "Je suis contente que Léa a proposé la veillée, et que Sami a tenu le silence.",
            "Je suis contente que Léa ait proposé la veillée, et que Sami ait tenu le silence.",
            "Je suis content(e) que + subjonctif : ait proposé, ait tenu.",
        ),
        pic_start=29,
        pic_words=["un cœur", "une sortie", "un conseil", "un relief"],
        short_p="Rédigez six formules de bilan réutilisables (récit, merci, concession, suite).",
        audio="Enregistrez la fiche et un bilan personnel en cinq phrases liées.",
    ),
]


SEQUENCES = [
    {"title": "Proposer une sortie", "lessons": S1},
    {"title": "Convaincre le groupe", "lessons": S2},
    {"title": "Fêtes et coutumes", "lessons": S3},
    {"title": "Autour de la soirée", "lessons": S4},
    {"title": "Préparer la veillée", "lessons": S5},
    {"title": "Après la fête", "lessons": S6},
]
