"""B2 Module 5 — Questions de société (univers Seuil des Sources)."""

from factory import L

IMG = "mfk-b2-m5"
IMG_DIR = IMG

MODULE = {
    "title": "B2 — Questions de société",
    "description": (
        "Grande étape B2-5 : analyser un enjeu à la voix passive, prendre position "
        "au subjonctif, décrire un fait culturel et politique inventé de la cour, "
        "nuancer une comparaison, enquêter à Rukiri-Nord et signer un éditorial "
        "pour le Cahier des racines — autour de l'eau, des heures calmes, des "
        "lanternes et de l'accès à la Salle des Herbes, au Seuil des Sources."
    ),
}

_PIC = [
    "la voix passive",
    "un enjeu",
    "une banderole",
    "un titre",
    "le subjonctif",
    "une position",
    "un micro",
    "une balance",
    "un fait politique",
    "un fait culturel",
    "une urne",
    "la Salle des Herbes",
    "une alternative",
    "une comparaison",
    "une enquête",
    "une loupe",
    "un éditorial",
    "le Cahier des racines",
    "une plume",
    "un tampon",
    "la rivière",
    "le figuier",
    "des citoyens",
    "une affiche",
    "la radio",
    "un doute",
    "une prise de position",
    "un vote",
    "une feuille",
    "une nuance",
]


def _pw(start: int) -> list[str]:
    return [_PIC[(start + i) % len(_PIC)] for i in range(4)]


def _l(comp, title, obj, cons, st, sp, **kw):
    return L(IMG, comp, title, obj, cons, st, sp, **kw)


# ---------------------------------------------------------------------------
# Séquence 1 — Un enjeu à analyser (voix passive)
# ---------------------------------------------------------------------------

S1 = [
    _l(
        "CO",
        "CO — Ce qui a été décidé à la rivière",
        "Repérer la voix passive qui met en valeur un élément (a été décidé, est porté par).",
        "Lisez le dialogue (à écouter avec l'enseignant). Quel enjeu est mis en avant, et par qui la mesure est-elle portée ?",
        "Assemblée sous le figuier, seaux alignés",
        """Aline : Un enjeu a été posé ce matin : l'eau de la rivière, pas le tambour, pas la lanterne.
Dieudonné : Il a été décidé que les seaux ne seraient remplis qu'entre six heures et huit heures.
Hawa : Cette mesure est portée par ceux qui marchent jusqu'à l'eau, pas par ceux qui commentent du banc.
Rose : La rivière a été protégée, dit-on ; or les heures, elles, ont été affichées trop haut, loin des yeux.
Marc : Ce qui a été voté n'est pas un caprice : c'est un partage. Le partage a été relaté dans le Cahier des racines.
Léa : Pourtant le texte a été rédigé sans les voix du soir. Qui a été consulté, au juste ?
Solange : Le tampon a été apposé au Bureau des Escales. Une décision tamponnée n'est pas encore une décision comprise.
Patrick : L'affiche a été collée au figuier ; elle est lue par les anciens, rarement par les enfants.
Lila : À Radio Figuier, le fait sera examiné ce soir : pas la colère, le chiffre de l'eau.
Joël : Les seaux communs ont été comptés. Trois manquent. Cela n'a pas été inventé.
Karim : Si l'eau est contestée par Noura, que l'on dise pourquoi, et que l'on nomme l'agent : contestée par qui ?
Yvette : Une règle portée par la cour tient mieux qu'une règle portée par un seul tampon.
Mado : Je retiens : on met en valeur ce qui a été fait à l'eau, pas qui a parlé le plus fort.
Aline : Notez le passif : a été décidé, est porté par, a été affiché, sera examiné. L'élément mis en avant devient sujet.""",
        tf_item=(
            "Dieudonné dit qu'il a été décidé de remplir les seaux toute la journée.",
            False,
            "Les seaux ne seraient remplis qu'entre six heures et huit heures.",
        ),
        qcm_item=(
            "Selon Hawa, par qui la mesure est-elle portée ?",
            [
                "Par Radio Figuier seulement",
                "Par ceux qui marchent jusqu'à l'eau",
                "Par un tampon sans voix",
                "Par les enfants du soir",
            ],
            1,
            "Hawa : portée par ceux qui marchent jusqu'à l'eau.",
        ),
        pairs=[
            ("il a été décidé", "heures des seaux"),
            ("est portée par", "ceux qui marchent"),
            ("a été relaté", "Cahier des racines"),
            ("sera examiné", "Radio Figuier"),
        ],
        fill_item=("Cette mesure ___ portée par ceux qui marchent jusqu'à l'eau.", "est"),
        words=["Il", "a", "été", "décidé", "que", "les", "seaux", "auraient", "des", "heures", "."],
        anagram=("decide", "On l'a fait voter : un choix collectif, sans accent sur le verbe."),
        error=(
            "La mesure a été voter hier, et elle est portée par Hawa.",
            "La mesure a été votée hier, et elle est portée par Hawa.",
            "Passif féminin : a été votée, accord avec mesure.",
        ),
        pic_start=0,
        pic_words=_pw(0),
        short_p="Notez quatre passifs et, pour chacun, l'élément mis en valeur (sujet).",
        audio="Enregistrez : Il a été décidé que l'eau serait partagée. Cette mesure est portée par Hawa. La rivière a été protégée.",
    ),
    _l(
        "CE",
        "CE — Feuille d'analyse : l'eau mise en sujet",
        "Lire une analyse d'enjeu où le passif met la rivière et la mesure au premier plan.",
        "Lisez la feuille, sans aller trop vite.",
        "Feuille de Marc Nkurunziza, Cahier des racines",
        """Enjeu — l'eau de la rivière (Rukiri-Nord, Seuil des Sources)
Ce qui a été décidé : un créneau unique, six heures-huit heures, pour les seaux communs.
Ce qui est mis en valeur : la rivière, pas le nom de celui qui parle le plus fort.
La mesure est portée par Dieudonné et Hawa ; elle est contestée par Noura, qui arrive après le minibus.
L'affiche a été collée trop haut : elle n'est pas lue par les enfants, à peine par Yvette.
Le chiffre des seaux a été vérifié : trois manquent ; cela n'a pas été inventé au marché.
Le tampon a été apposé par Solange. Un tampon n'est pas un argument ; il est seulement posé.
À Radio Figuier, le dossier sera examiné sans crier. Lila pèse ce qui a été vu à l'eau.
On relatera le partage, pas la rumeur d'une crue. La crue n'a pas été confirmée.
Question d'analyse : si l'on dit « Dieudonné a décidé », on met l'homme en avant ; si l'on dit « il a été décidé », on met la décision.
Aline : le passif n'efface pas l'agent ; il le recule, quand on veut éclairer l'enjeu.
Joël : une règle portée par la cour se tient ; une règle portée par un seul banc se fissure.
Mado : analyser, c'est choisir le sujet de la phrase autant que le fond.
Seuil des Sources — ne pas aller trop vite : l'eau n'attend pas le style, mais le style dit qui compte.""",
        tf_item=(
            "La feuille affirme que la crue a été confirmée.",
            False,
            "« La crue n'a pas été confirmée. »",
        ),
        qcm_item=(
            "Pourquoi coller l'affiche trop haut pose-t-il problème ?",
            [
                "Parce que Solange refuse le tampon",
                "Parce qu'elle n'est pas lue par les enfants",
                "Parce que la rivière a disparu",
                "Parce que Radio Figuier a fermé",
            ],
            1,
            "« elle n'est pas lue par les enfants »",
        ),
        pairs=[
            ("il a été décidé", "un créneau unique"),
            ("est portée par", "Dieudonné et Hawa"),
            ("est contestée par", "Noura"),
            ("sera examiné", "le dossier à la radio"),
        ],
        fill_item=("L'affiche ___ été collée trop haut.", "a"),
        words=["La", "mesure", "est", "portée", "par", "Hawa", "."],
        anagram=("portee", "La mesure l'est par Hawa : participe du passif, sans accent."),
        error=(
            "Les seaux ont été compté ce matin, et trois manquent encore.",
            "Les seaux ont été comptés ce matin, et trois manquent encore.",
            "Passif pluriel : ont été comptés, accord avec seaux.",
        ),
        pic_start=1,
        pic_words=_pw(1),
        short_p="Recopiez l'analyse et encadrez chaque passif ; notez l'élément sujet.",
        audio="Lisez la feuille de Marc, sans aller trop vite.",
    ),
    _l(
        "PO",
        "PO — Dire a été décidé, est porté par",
        "Mettre un enjeu en valeur à l'oral en choisissant le sujet du passif.",
        "Répétez les modèles, puis reformulez un fait actif au passif pour éclairer l'eau.",
        "Modèles d'Aline et de Dieudonné",
        """Il a été décidé que l'eau serait partagée.
Cette mesure est portée par la cour.
La rivière a été protégée dès l'aube.
L'affiche a été lue par Yvette, pas par les enfants.
Le tampon a été apposé au Bureau des Escales.
Les seaux ont été comptés.
Le dossier sera examiné ce soir.
Rien n'a été inventé au marché.
Une règle contestée par Noura doit encore être expliquée.
Ce qui a été voté n'efface pas ce qui a été oublié.
On met la rivière en sujet : la rivière a été ménagée.
On recule l'agent : par Hawa, par Solange, par l'assemblée.
Aline : le passif n'est pas un mensonge ; c'est un projecteur.
Marc : si l'agent compte, on le nomme après par.""",
        tf_item=(
            "Au passif, l'élément mis en valeur devient le sujet de la phrase.",
            True,
            "Aline : le passif est un projecteur.",
        ),
        qcm_item=(
            "Quelle phrase met la rivière en valeur ?",
            [
                "Dieudonné a protégé la rivière",
                "Hawa a parlé de la rivière",
                "La rivière a été protégée dès l'aube",
                "On a vu Dieudonné",
            ],
            2,
            "La rivière est sujet du passif.",
        ),
        pairs=[
            ("il a été décidé", "décision mise en sujet"),
            ("est porté par", "agent reculé"),
            ("a été lue", "affiche / Yvette"),
            ("sera examiné", "futur passif"),
        ],
        fill_item=("Les seaux ___ été comptés. (avoir)", "ont"),
        words=["Cette", "mesure", "est", "portée", "par", "la", "cour", "."],
        anagram=("affiche", "Papier collé au figuier, trop haut pour les enfants."),
        error=(
            "La rivière a été protéger dès l'aube, et le seau a été partagé.",
            "La rivière a été protégée dès l'aube, et le seau a été partagé.",
            "Passif : été + protégée, pas l'infinitif.",
        ),
        pic_start=2,
        pic_words=_pw(2),
        short_p="Transformez six phrases actives en passif ; soulignez le nouvel élément sujet.",
        audio="Enregistrez les six premiers modèles, puis deux passifs à vous sur l'eau.",
    ),
    _l(
        "PE",
        "PE — Mon analyse d'un enjeu",
        "Écrire une analyse argumentative où le passif met en valeur l'eau et la mesure.",
        "Imitez l'analyse de Hawa Diallo, sans aller trop vite.",
        "Analyse de Hawa, Cahier des racines",
        """Hawa Diallo — Seuil des Sources, Rukiri-Nord
Un enjeu a été posé, et il n'est pas mince : l'eau de la rivière, partagée ou gaspillée.
Il a été décidé qu'un créneau unique vaudrait pour les seaux communs. Cette décision est portée par ceux qui marchent.
Je mets la rivière en sujet : elle a été ménagée à l'aube, elle a été oubliée à midi, quand Noura arrive.
L'affiche a été collée trop haut ; elle n'est donc pas lue par tout le monde, et cela a été constaté par Yvette.
Le tampon a été apposé par Solange. Je ne le conteste pas ; je dis seulement qu'un tampon n'explique pas une soif.
Trois seaux ont été comptés manquants. Cela n'a pas été inventé au Marché des Lampions.
Si le dossier est examiné ce soir à Radio Figuier, qu'il le soit sans crier : le chiffre d'abord, la colère ensuite.
Une règle contestée par Noura n'est pas une règle nulle : elle est encore à expliquer, pas à jeter.
Je conclus : ce qui a été voté tient si ce qui a été oublié est nommé. Autrement, la mesure se fissure.
Hawa
Copie : Aline Uwase, Marc Nkurunziza, Bureau des Escales""",
        tf_item=(
            "Hawa dit qu'un tampon suffit à expliquer une soif.",
            False,
            "« un tampon n'explique pas une soif. »",
        ),
        qcm_item=(
            "Que met Hawa en sujet pour éclairer l'enjeu ?",
            [
                "Le tambour de Sami",
                "La rivière",
                "Le minibus Figuier 7",
                "Un palais",
            ],
            1,
            "« Je mets la rivière en sujet. »",
        ),
        pairs=[
            ("il a été décidé", "créneau unique"),
            ("est portée par", "ceux qui marchent"),
            ("a été collée", "affiche trop haute"),
            ("n'a pas été inventé", "les trois seaux"),
        ],
        fill_item=("Trois seaux ___ été comptés manquants.", "ont"),
        words=["Un", "enjeu", "a", "été", "posé", "ce", "matin", "."],
        anagram=("mesure", "Règle votée pour l'eau : créneau, seaux, tampon."),
        error=(
            "La décision a été pris trop vite, et elle est encore portée par Hawa.",
            "La décision a été prise trop vite, et elle est encore portée par Hawa.",
            "Accord : décision au féminin → prise.",
        ),
        pic_start=3,
        pic_words=_pw(3),
        short_p="Imitez : quinze lignes argumentatives, six passifs, l'eau mise en sujet, un agent nommé par.",
        audio="Lisez votre analyse, une phrase, une pause, sans aller trop vite.",
    ),
    _l(
        "EL",
        "EL — Voix passive pour mettre en valeur",
        "Retenir formation, accord et choix du sujet au passif.",
        "Apprenez la fiche.",
        "Fiche d'Aline, passif d'analyse",
        """Passif = être (conjugué) + participe passé.
Présent : la mesure est portée (par Hawa). PC : il a été décidé / la rivière a été protégée.
Futur : le dossier sera examiné. Agent : par + nom (facultatif).
On met en valeur l'élément devenu sujet : la rivière a été ménagée (l'eau, pas l'homme).
Impersonnel : il a été décidé que + indicatif. Il a été relaté que les seaux manquaient.
Accord du PP avec le sujet : la mesure a été votée ; les seaux ont été comptés ; l'affiche a été lue.
On ne dit pas : a été voter / a été protéger (infinitif). On ne dit pas : les seaux a été compté.
Actif → passif : Dieudonné a mesuré le niveau → le niveau a été mesuré (par Dieudonné).
Si l'agent compte politiquement, on le garde : contestée par Noura. S'il pèse trop, on le recule.
Le passif n'efface pas la responsabilité ; il choisit le projecteur.
À + le = au Bureau. De + le = du Cahier des racines.
Bien que la mesure soit contestée, elle a été tamponnée. (concession déjà connue)
Au Seuil : on analyse un enjeu, on ne crie pas un nom.""",
        tf_item=(
            "Au passif, le participe s'accorde avec le sujet.",
            True,
            "La mesure a été votée ; les seaux ont été comptés.",
        ),
        qcm_item=(
            "« Dieudonné a mesuré le niveau » au passif, c'est…",
            [
                "Dieudonné a été mesuré par le niveau",
                "Le niveau a mesuré Dieudonné",
                "Le niveau a été mesuré par Dieudonné",
                "Le niveau est mesurer",
            ],
            2,
            "Objet → sujet. Agent : par.",
        ),
        pairs=[
            ("être + PP", "passif"),
            ("par", "agent"),
            ("il a été décidé", "impersonnel"),
            ("a été votée", "accord féminin"),
        ],
        fill_item=("L'affiche a été ___ par Yvette. (lire)", "lue"),
        words=["Le", "dossier", "sera", "examiné", "ce", "soir", "."],
        anagram=("agent", "Celui par qui l'action est faite, reculé après par."),
        error=(
            "Les heures ont été affiché trop haut, et l'eau a été ménagée.",
            "Les heures ont été affichées trop haut, et l'eau a été ménagée.",
            "Heures au féminin pluriel → affichées.",
        ),
        pic_start=4,
        pic_words=_pw(4),
        short_p="Tableau : huit actifs → huit passifs ; marquez l'élément mis en valeur.",
        audio="Enregistrez la fiche et six passifs : décidé, portée, protégée, lue, examinés, contestée.",
    ),
]


# ---------------------------------------------------------------------------
# Séquence 2 — Prendre position (emplois du subjonctif)
# ---------------------------------------------------------------------------

S2 = [
    _l(
        "CO",
        "CO — Je veux que le soir reste tenable",
        "Repérer le subjonctif de volonté, de doute, de sentiment, de but et de concession.",
        "Lisez le dialogue. Qui prend quelle position, et quel emploi du subjonctif entend-on ?",
        "Banc du figuier, après la veillée",
        """Rose : Je veux que le tambour cesse après vingt et une heures. Les enfants doivent dormir.
Sami : Je doute que le silence soit une fête. Une veillée sans rythme n'est plus une veillée.
Aline : Je suis heureuse que la cour discute sans crier. Un avis n'est pas une injure.
Léa : Nous demandons que Radio Figuier baisse le micro, afin que la rive respire.
Patrick : Il faut que chacun parle, bien que la fatigue pèse déjà sur les paupières.
Marc : Je crains que cette règle ne casse la veillée. Craindre que : subjonctif, souvent avec ne explétif.
Hawa : Je souhaite que l'on trouve une heure, pas un interdit. Volonté n'est pas veto.
Joël : Quoique Sami tienne à son tambour, il peut frapper plus tôt. Concession.
Solange : J'exige que les heures calmes soient affichées au Bureau, pour que le tampon suive la voix.
Noura : Je ne suis pas sûre que vingt et une heures conviennent à ceux du minibus.
Lila : Il se peut que le soir tienne si l'on coupe seulement le dernier morceau.
Yvette : Je regrette que l'on oppose fête et sommeil. On peut vouloir les deux.
Dieudonné : Pour que les seaux de l'aube restent possibles, il faut que la cour dorme un peu.
Aline : Cinq emplois : volonté, doute, sentiment, but, concession. Tous appellent le subjonctif ici.""",
        tf_item=(
            "Rose emploie une volonté : je veux que le tambour cesse.",
            True,
            "Rose : « Je veux que le tambour cesse après vingt et une heures. »",
        ),
        qcm_item=(
            "Quel emploi illustre « bien que la fatigue pèse » ?",
            [
                "le but",
                "le doute",
                "la concession",
                "le passif impersonnel",
            ],
            2,
            "Bien que + subjonctif = concession.",
        ),
        pairs=[
            ("je veux que / j'exige que", "volonté"),
            ("je doute que / il se peut que", "doute"),
            ("je suis heureuse que / je crains que", "sentiment"),
            ("afin que / pour que / bien que", "but ou concession"),
        ],
        fill_item=("Je veux que le tambour ___ après vingt et une heures. (cesser)", "cesse"),
        words=["Je", "doute", "que", "le", "silence", "soit", "une", "fête", "."],
        anagram=("cesse", "Rose le veut pour le tambour : s'arrêter, au subjonctif."),
        error=(
            "Je veux que le tambour cesse à l'heure dite, et il faut que chacun parlent sans crier.",
            "Je veux que le tambour cesse à l'heure dite, et il faut que chacun parle sans crier.",
            "Chacun appelle le singulier : parle, pas parlent.",
        ),
        pic_start=5,
        pic_words=_pw(5),
        short_p="Classez cinq répliques : volonté, doute, sentiment, but, concession.",
        audio="Enregistrez : Je veux que le tambour cesse. Je doute que le silence soit une fête. Bien que la fatigue pèse, il faut que chacun parle.",
    ),
    _l(
        "CE",
        "CE — Prises de position sur les heures calmes",
        "Lire des avis où le subjonctif porte la volonté, le doute, le sentiment, le but et la concession.",
        "Lisez le recueil, sans aller trop vite.",
        "Recueil d'Aline, Salle des Herbes",
        """Heures calmes — cinq voix, cinq emplois (Seuil des Sources)
Rose — volonté : je veux que le tambour cesse à vingt et une heures ; j'exige que l'affiche soit lisible.
Sami — doute : je doute que l'on puisse fêter sans rythme ; il n'est pas sûr que la cour accepte un silence plat.
Aline — sentiment : je suis heureuse que l'on discute ; je crains que la colère n'étouffe l'argument.
Léa et Patrick — but : nous parlons afin que la rive respire, pour que les enfants dorment, pour que l'aube des seaux reste possible.
Marc — concession : bien que la veillée soit précieuse, quoique Sami tienne à son tambour, une heure doit finir.
Solange ajoute : il faut que le Bureau tamponne ce que la voix a dit, afin que la règle ne flotte pas.
Noura : je ne suis pas certaine que vingt et une heures aillent à ceux du minibus Figuier 7.
Lila : il se peut que l'on coupe seulement le dernier morceau. Un doute n'est pas un refus.
Yvette : je regrette que l'on oppose fête et sommeil. On peut souhaiter que les deux tiennent.
Joël : encore que la cour soit lasse, elle peut voter sans crier.
Position n'est pas injure. Le subjonctif porte l'avis ; il ne le durcit pas.
Rukiri-Nord — veillée inventée de la cour, pas une fête d'ailleurs.
Aline : relisez chaque que, et nommez l'emploi avant de juger l'avis.""",
        tf_item=(
            "Yvette veut que l'on choisisse entre fête et sommeil, sans les deux.",
            False,
            "Elle regrette qu'on les oppose ; on peut souhaiter que les deux tiennent.",
        ),
        qcm_item=(
            "Quelle formule de Solange exprime un but ?",
            [
                "je doute que l'on puisse fêter",
                "afin que la règle ne flotte pas",
                "je suis heureuse que l'on discute",
                "bien que la veillée soit précieuse",
            ],
            1,
            "Afin que + subjonctif = but.",
        ),
        pairs=[
            ("je veux que / j'exige que", "Rose"),
            ("je doute que", "Sami"),
            ("bien que / quoique", "Marc"),
            ("afin que / pour que", "Léa / Solange"),
        ],
        fill_item=("Bien que la veillée ___ précieuse, une heure doit finir. (être)", "soit"),
        words=["Il", "faut", "que", "le", "Bureau", "tamponne", "la", "voix", "."],
        anagram=("doute", "Sami l'exprime : il n'est pas sûr que le silence soit une fête."),
        error=(
            "Bien que la veillée est précieuse, Sami tient encore à son tambour.",
            "Bien que la veillée soit précieuse, Sami tient encore à son tambour.",
            "Bien que + subjonctif : soit, pas est.",
        ),
        pic_start=6,
        pic_words=_pw(6),
        short_p="Recopiez cinq phrases, une par emploi, et soulignez le verbe au subjonctif.",
        audio="Lisez le recueil d'Aline, sans aller trop vite.",
    ),
    _l(
        "PO",
        "PO — Dire je veux que, je doute que, bien que",
        "Prendre position à l'oral avec les cinq emplois du subjonctif.",
        "Répétez, puis donnez votre avis sur les heures calmes en variant les emplois.",
        "Modèles de Rose, Sami et Aline",
        """Je veux que le soir reste tenable.
J'exige que l'affiche soit basse, lisible.
Je doute que le silence plaise à Sami.
Il se peut que l'on coupe seulement la fin.
Je suis heureuse que la cour discute.
Je crains que la colère n'étouffe l'argument.
Je regrette que l'on oppose fête et sommeil.
Nous parlons afin que la rive respire.
Il faut que chacun s'exprime.
Bien que la veillée soit précieuse, une heure finit.
Quoique Sami tienne au tambour, il peut frapper plus tôt.
Je souhaite que l'on trouve un créneau, pas un interdit.
Aline : le subjonctif porte l'avis ; le ton, lui, reste calme.
Patrick : une position se dit, elle ne s'impose pas au cri.""",
        tf_item=(
            "« Je crains que » se construit avec le subjonctif, souvent avec ne explétif.",
            True,
            "Je crains que la colère n'étouffe l'argument.",
        ),
        qcm_item=(
            "Quelle phrase exprime une concession ?",
            [
                "Je veux que le soir reste tenable",
                "Je doute que le silence plaise à Sami",
                "Bien que la veillée soit précieuse une heure finit",
                "J'exige que l'affiche soit basse",
            ],
            2,
            "Bien que + subjonctif.",
        ),
        pairs=[
            ("je veux que", "volonté"),
            ("je doute que", "doute"),
            ("je crains que", "sentiment"),
            ("bien que", "concession"),
        ],
        fill_item=("Afin que la rive ___, nous baissons le micro. (respirer)", "respire"),
        words=["Je", "souhaite", "que", "l'on", "trouve", "un", "créneau", "."],
        anagram=("crains", "Sentiment : j'ai peur que la colère n'étouffe l'argument."),
        error=(
            "Je veux que le tambour cesse après l'heure dite, et je doute que le silence est une fête.",
            "Je veux que le tambour cesse après l'heure dite, et je doute que le silence soit une fête.",
            "Douter que + subjonctif : soit, pas est.",
        ),
        pic_start=7,
        pic_words=_pw(7),
        short_p="Écrivez dix phrases : deux par emploi (volonté, doute, sentiment, but, concession).",
        audio="Enregistrez les huit premiers modèles, puis deux positions à vous.",
    ),
    _l(
        "PE",
        "PE — Ma prise de position",
        "Écrire un avis argumenté qui emploie les cinq familles du subjonctif.",
        "Imitez la position de Léa Niyonzima, sans aller trop vite.",
        "Position de Léa, enveloppe ocre",
        """Léa Niyonzima — heures calmes, Seuil des Sources
Je veux que la veillée reste une fête, et j'exige que le dernier morceau cesse à vingt et une heures.
Je doute que Sami perde sa place si le tambour finit plus tôt ; il se peut que le rythme tienne mieux, plus court.
Je suis heureuse que la cour en discute sous le figuier. Je crains pourtant que la fatigue n'empêche d'écouter Noura.
Nous demandons que Radio Figuier baisse le micro, afin que la rive respire et pour que les enfants dorment.
Bien que la veillée soit précieuse, quoique Joël aime le bruit ami, une heure doit pouvoir finir sans injure.
Il faut que Solange tamponne ce que nous dirons, pour que la règle ne flotte pas d'un banc à l'autre.
Je regrette que l'on oppose sommeil et fête. Je souhaite que les deux tiennent, chacun à son temps.
Patrick ajoute : je ne suis pas sûr que vingt et une heures aillent à ceux du minibus ; encore que l'heure soit stricte, on peut l'ajuster.
Ma position n'est pas un cri : c'est un que, plusieurs fois, avec le mode qui convient.
Léa
Copie : Aline, Sami, Rose, Cahier des racines""",
        tf_item=(
            "Léa veut supprimer la veillée pour imposer le silence toute la nuit.",
            False,
            "Elle veut que la veillée reste une fête, et que le dernier morceau cesse à vingt et une heures.",
        ),
        qcm_item=(
            "Que demande Léa à Radio Figuier ?",
            [
                "Fermer l'antenne pour toujours",
                "Baisser le micro afin que la rive respire",
                "Interdire le figuier",
                "Changer Solange",
            ],
            1,
            "« que Radio Figuier baisse le micro, afin que la rive respire »",
        ),
        pairs=[
            ("je veux que / j'exige que", "volonté"),
            ("je doute que / il se peut que", "doute"),
            ("je crains que / je suis heureuse que", "sentiment"),
            ("afin que / bien que", "but / concession"),
        ],
        fill_item=("Bien que la veillée ___ précieuse, une heure doit finir. (être)", "soit"),
        words=["Il", "faut", "que", "Solange", "tamponne", "notre", "voix", "."],
        anagram=("veillee", "Fête du soir sous le figuier, sans accent, que Léa veut garder."),
        error=(
            "Je souhaite que les deux tiennent chacun à son temps, et je veux que Radio Figuier baissent le micro.",
            "Je souhaite que les deux tiennent chacun à son temps, et je veux que Radio Figuier baisse le micro.",
            "Radio Figuier, sujet singulier : baisse, pas baissent.",
        ),
        pic_start=8,
        pic_words=_pw(8),
        short_p="Imitez : quinze lignes, cinq emplois du subjonctif, une position claire sur les heures calmes.",
        audio="Lisez votre position, une phrase, une pause, sans aller trop vite.",
    ),
    _l(
        "EL",
        "EL — Emplois du subjonctif pour l'avis",
        "Retenir volonté, doute, sentiment, but et concession au subjonctif présent.",
        "Apprenez la fiche.",
        "Fiche d'Aline, subjonctif d'opinion",
        """Volonté : vouloir / exiger / demander / souhaiter / il faut que + subj.
Je veux que tu parles. J'exige que l'affiche soit lisible. Il faut que chacun s'exprime.
Doute : douter que / il se peut que / il n'est pas sûr que / je ne suis pas certain(e) que + subj.
Je doute que le silence plaise. Il se peut que l'on coupe la fin.
Sentiment : être heureux que / craindre que / regretter que / être étonné que + subj.
Je crains que la colère n'étouffe l'argument. (ne explétif, pas une négation)
But : pour que / afin que + subj. (sujet différent). Pour + infinitif si même sujet.
Concession : bien que / quoique / encore que + subj. Pourtant / cependant + indicatif.
Formes : que je sois, que tu aies, qu'il fasse, que nous prenions, que vous puissiez, qu'ils aillent.
Cesser au subj. : que le tambour cesse. Tenir : quoiqu'il tienne. Aller : que l'heure aille.
On ne dit pas : je doute que le silence est… On dit : soit.
Après une volonté négative : je ne veux pas que tu cries (subj. quand même).
Prendre position, c'est choisir l'emploi, puis la forme, puis le ton.""",
        tf_item=(
            "« Pourtant » se construit comme « bien que », avec le subjonctif.",
            False,
            "Pourtant + indicatif. Bien que + subjonctif.",
        ),
        qcm_item=(
            "« Je crains que la colère n'étouffe » : le ne est…",
            [
                "une négation obligatoire de tout l'avis",
                "un ne explétif, pas une négation",
                "une erreur à barrer toujours",
                "un passif",
            ],
            1,
            "Ne explétif après craindre que.",
        ),
        pairs=[
            ("vouloir / exiger / il faut que", "volonté"),
            ("douter / il se peut que", "doute"),
            ("craindre / regretter", "sentiment"),
            ("bien que / afin que", "concession / but"),
        ],
        fill_item=("Il faut que chacun ___ . (s'exprimer)", "s'exprime"),
        words=["Je", "ne", "veux", "pas", "que", "tu", "cries", "."],
        anagram=("exigent", "Ils… que l'affiche soit lisible : volonté forte, troisième personne."),
        error=(
            "Je doute que le silence est plat, et je veux que tu parles sans crier.",
            "Je doute que le silence soit plat, et je veux que tu parles sans crier.",
            "Douter que + subjonctif : soit, pas est.",
        ),
        pic_start=9,
        pic_words=_pw(9),
        short_p="Conjuguez être, avoir, faire, pouvoir, aller, cesser au subjonctif (il / nous / vous).",
        audio="Enregistrez la fiche et cinq phrases, un emploi chacune.",
    ),
]


# ---------------------------------------------------------------------------
# Séquence 3 — Fait culturel et politique
# ---------------------------------------------------------------------------

S3 = [
    _l(
        "CO",
        "CO — La veillée comme fait de la cour",
        "Décrire un fait inventé de la cour : assemblée, motion, veillée comme fait social.",
        "Lisez le dialogue. En quoi la veillée des lanternes est-elle à la fois culturelle et politique ?",
        "Cour du figuier, lanternes encore chaudes",
        """Marc : Un fait culturel, ici, ce n'est pas une fête d'ailleurs : c'est la veillée des lanternes, inventée par la cour.
Aline : Un fait politique, ici, ce n'est pas un parti : c'est une motion votée sous le figuier, tamponnée au Bureau des Escales.
Rose : Hier, l'assemblée s'est tenue. Une motion a été lue : que les lanternes ne restent pas au bord de la rivière.
Sami : La veillée rassemble. C'est un fait social : on y vient, on y parle, on y laisse parfois trop d'huile.
Léa : Ce qui a été voté concerne le déchet, pas la fête. On peut aimer la veillée et refuser le gaspillage.
Patrick : Solange a noté : motion n°14, Cahier des racines. Un numéro n'est pas une loi d'État ; c'est une règle de cour.
Hawa : Certains ont levé la main. D'autres ont gardé le silence. Le silence aussi est un fait.
Joël : On décrit : qui, où, quand, quelle motion, quel geste. On n'invente pas un ministre.
Lila : Radio Figuier relatera la veillée comme un fait, pas comme une campagne.
Yvette : Les enfants ont appris à poser la lanterne dans le panier, pas dans l'herbe.
Dieudonné : L'huile au bord de l'eau a été vue. Cela a été dit sans crier.
Mado : Fait culturel : on se rassemble. Fait politique : on vote une limite.
Karim : La Salle des Herbes a servi à compter les lanternes. L'accès, lui, viendra plus tard.
Aline : Décrire, c'est tenir les deux : le rite et la règle, sans les fondre.""",
        tf_item=(
            "Patrick dit que la motion n°14 est une loi d'État.",
            False,
            "« Un numéro n'est pas une loi d'État ; c'est une règle de cour. »",
        ),
        qcm_item=(
            "Que demandait la motion lue à l'assemblée ?",
            [
                "Interdire la veillée",
                "Que les lanternes ne restent pas au bord de la rivière",
                "Fermer Radio Figuier",
                "Changer le figuier",
            ],
            1,
            "Rose : lanternes hors du bord de la rivière.",
        ),
        pairs=[
            ("fait culturel", "veillée des lanternes"),
            ("fait politique", "motion tamponnée"),
            ("assemblée", "sous le figuier"),
            ("Cahier des racines", "motion n°14"),
        ],
        fill_item=("Une motion a été ___ : que les lanternes ne restent pas au bord de l'eau. (lire)", "lue"),
        words=["La", "veillée", "rassemble", "la", "cour", "chaque", "jeudi", "."],
        anagram=("motion", "Texte voté sous le figuier, puis tamponné au Bureau."),
        error=(
            "La veillée a été décrit comme un fait social, et la motion a été lue sans crier.",
            "La veillée a été décrite comme un fait social, et la motion a été lue sans crier.",
            "Accord : veillée féminin → décrite.",
        ),
        pic_start=10,
        pic_words=_pw(10),
        short_p="Notez trois traits culturels et trois traits politiques de la veillée inventée.",
        audio="Enregistrez : La veillée est un fait social. Une motion a été votée. On décrit le rite et la règle.",
    ),
    _l(
        "CE",
        "CE — Compte rendu de l'assemblée",
        "Lire le compte rendu d'un fait de cour : veillée, motion, tampon.",
        "Lisez le compte rendu, sans aller trop vite.",
        "Compte rendu de Lila Sow, Feuille du Seuil",
        """Assemblée sous le figuier — jeudi, Seuil des Sources (Rukiri-Nord)
Fait culturel : la veillée des lanternes a eu lieu comme chaque saison sèche inventée de la cour. On s'y retrouve, on y parle bas, on y pose une flamme.
Fait politique : une motion a été proposée par Rose, relue par Marc, portée par une part de l'assemblée.
Texte : les lanternes éteintes seront déposées dans le panier ocre, non au bord de la rivière.
Qui a levé la main : Hawa, Dieudonné, Yvette, Joël, Léa. Qui s'est tu : Noura, d'abord, puis a demandé l'heure du panier.
Solange a tamponné la motion n°14 au Bureau des Escales. Un tampon de cour n'est pas un sceau d'État.
Sami a dit que la veillée restait une fête. Personne n'a demandé qu'elle disparaisse.
L'huile au bord de l'eau a été vue par Dieudonné. Le fait a été relaté, pas dramatisé.
Karim a noté que la Salle des Herbes avait servi à compter. L'accès à la salle n'était pas à l'ordre du jour.
Radio Figuier relayera ce compte rendu ce soir, sans slogan.
Aline : décrire un fait, c'est séparer le rite (on se rassemble) et la règle (on ne jette pas l'huile).
Mado : un silence dans l'assemblée est aussi un fait : il sera nommé, pas interprété trop vite.
Patrick : nous n'avons ni parti ni tribune ; nous avons un figuier, un cahier, un tampon.
Fin de compte rendu — ne pas confondre veillée et campagne.""",
        tf_item=(
            "Quelqu'un a demandé que la veillée disparaisse.",
            False,
            "« Personne n'a demandé qu'elle disparaisse. »",
        ),
        qcm_item=(
            "Où les lanternes éteintes doivent-elles être déposées ?",
            [
                "Au bord de la rivière",
                "Dans le panier ocre",
                "Sous le minibus",
                "À Radio Figuier seulement",
            ],
            1,
            "« déposées dans le panier ocre, non au bord de la rivière. »",
        ),
        pairs=[
            ("veillée des lanternes", "fait culturel"),
            ("motion n°14", "fait politique de cour"),
            ("panier ocre", "lanternes éteintes"),
            ("Bureau des Escales", "tampon de Solange"),
        ],
        fill_item=("Solange a tamponné la motion ___ Bureau des Escales.", "au"),
        words=["Personne", "n'a", "demandé", "que", "la", "veillée", "disparaisse", "."],
        anagram=("assemblee", "Réunion sous le figuier, sans accent, où l'on vote une règle."),
        error=(
            "La motion a été proposer par Rose, et elle a été relue par Marc.",
            "La motion a été proposée par Rose, et elle a été relue par Marc.",
            "Passif : proposée, pas l'infinitif proposer.",
        ),
        pic_start=11,
        pic_words=_pw(11),
        short_p="Recopiez le compte rendu et séparez en deux colonnes : rite / règle.",
        audio="Lisez le compte rendu de Lila, sans aller trop vite.",
    ),
    _l(
        "PO",
        "PO — Décrire un fait de cour",
        "Relater à l'oral un fait culturel et un fait politique inventés, sans les fondre.",
        "Répétez, puis décrivez la veillée et la motion en deux temps.",
        "Modèles de Marc et d'Aline",
        """La veillée des lanternes est un fait culturel de la cour.
On s'y rassemble ; on y parle bas.
Une assemblée s'est tenue sous le figuier.
Une motion a été lue, puis tamponnée.
Le texte concerne les lanternes éteintes, pas la fête.
On dépose le reste dans le panier ocre.
Personne n'a demandé que la veillée disparaisse.
Un tampon de cour n'est pas un sceau d'État.
Le silence de Noura a été un fait ; il n'a pas été un vote.
Radio Figuier relatera sans slogan.
Le rite rassemble ; la règle limite un geste.
Nous n'avons ni parti ni tribune.
Aline : décrire, c'est nommer qui, où, quand, quel geste.
Marc : le politique, ici, tient dans une main levée.""",
        tf_item=(
            "On peut aimer la veillée et voter une limite sur l'huile.",
            True,
            "Le rite et la règle ne s'excluent pas.",
        ),
        qcm_item=(
            "Que n'est pas le tampon de Solange, d'après les modèles ?",
            [
                "Un acte du Bureau des Escales",
                "Un sceau d'État",
                "La suite d'une motion",
                "Une marque de cour",
            ],
            1,
            "« Un tampon de cour n'est pas un sceau d'État. »",
        ),
        pairs=[
            ("veillée", "fait culturel"),
            ("motion / assemblée", "fait politique de cour"),
            ("panier ocre", "geste réglé"),
            ("sans slogan", "Radio Figuier"),
        ],
        fill_item=("On dépose le reste ___ panier ocre.", "dans"),
        words=["Le", "rite", "rassemble", "et", "la", "règle", "limite", "un", "geste", "."],
        anagram=("lanterne", "Flamme de la veillée, à poser dans le panier une fois éteinte."),
        error=(
            "Un tampon de cour n'est pas un sceau d'État, et une motion a été lu sous le figuier.",
            "Un tampon de cour n'est pas un sceau d'État, et une motion a été lue sous le figuier.",
            "Motion féminin → lue.",
        ),
        pic_start=12,
        pic_words=_pw(12),
        short_p="Écrivez huit phrases : quatre sur le rite, quatre sur la motion.",
        audio="Enregistrez les six premiers modèles, puis votre description en deux temps.",
    ),
    _l(
        "PE",
        "PE — Mon compte rendu de fait",
        "Écrire le compte rendu argumenté d'un fait culturel et politique de la cour.",
        "Imitez le compte rendu de Patrick Habimana, sans aller trop vite.",
        "Compte rendu de Patrick, Cahier des racines",
        """Patrick Habimana — veillée et motion n°14
Je décris un fait, non une campagne. La veillée des lanternes, inventée par la cour du Seuil, a rassemblé jeudi ceux qui vivent à Rukiri-Nord.
C'est un fait culturel : on y vient pour la flamme, pour la voix basse, pour Sami, pas pour un drapeau.
C'est aussi un fait politique de cour : une assemblée s'est tenue sous le figuier, une motion a été lue.
Rose a proposé que les lanternes éteintes aillent au panier ocre, non à la rivière. Marc a relu. Des mains se sont levées.
Personne n'a exigé que la fête disparaisse. On a limité un geste, on n'a pas tué un rite.
Solange a tamponné au Bureau des Escales. J'écris clairement : ce tampon n'est pas un sceau d'État ; c'est une mémoire de cour.
L'huile au bord de l'eau a été vue. Le fait a été nommé. Dieudonné n'a pas crié.
Noura s'est tue d'abord, puis a demandé l'heure du panier. Ce silence est un fait ; je ne lui prête pas d'intention.
Radio Figuier relatera sans slogan. Je souhaite que ce compte rendu tienne dans le Cahier des racines.
Patrick
Copie : Lila Sow, Aline Uwase, Solange""",
        tf_item=(
            "Patrick prête à Noura l'intention de saboter la motion.",
            False,
            "« je ne lui prête pas d'intention. »",
        ),
        qcm_item=(
            "Que distingue Patrick dans son texte ?",
            [
                "Un parti et une tribune",
                "Un rite et une règle",
                "Un palais et un minibus",
                "Une ville réelle et une autre",
            ],
            1,
            "On a limité un geste, on n'a pas tué un rite.",
        ),
        pairs=[
            ("veillée", "fait culturel"),
            ("motion n°14", "fait politique de cour"),
            ("panier ocre", "limite d'un geste"),
            ("tampon", "mémoire de cour"),
        ],
        fill_item=("Personne n'a exigé que la fête ___ . (disparaître)", "disparaisse"),
        words=["On", "a", "limité", "un", "geste", "sans", "tuer", "un", "rite", "."],
        anagram=("gaspillage", "Huile et lanternes laissées au bord de l'eau, ce que la motion refuse."),
        error=(
            "Personne n'a exigé que la fête disparaisse, et l'huile au bord de l'eau a été vu.",
            "Personne n'a exigé que la fête disparaisse, et l'huile au bord de l'eau a été vue.",
            "Huile féminin → vue.",
        ),
        pic_start=13,
        pic_words=_pw(13),
        short_p="Imitez : quinze lignes, rite et règle séparés, un passif, un que + subjonctif, pas de parti réel.",
        audio="Lisez votre compte rendu, une phrase, une pause, sans aller trop vite.",
    ),
    _l(
        "EL",
        "EL — Décrire un fait culturel et politique",
        "Retenir le vocabulaire de l'assemblée de cour et la séparation rite / règle.",
        "Apprenez la fiche.",
        "Fiche de Marc, faits de cour",
        """Fait culturel (inventé) : un rite de la cour — veillée des lanternes, chants, voix basse.
Fait politique (inventé) : une règle votée — assemblée, motion, main levée, tampon au Bureau des Escales.
Fait social : on se rassemble ; le silence d'un banc est aussi un fait.
On décrit : qui, où, quand, quel geste, quel texte. On n'invente pas un État, un parti, un ministre.
Motion : texte proposé, lu, voté, tamponné. Numéro dans le Cahier des racines.
Assemblée : sous le figuier, pas une chambre réelle. Urne inventée si l'on compte les voix.
Passif utile : une motion a été lue ; l'huile a été vue ; le silence a été nommé.
Subjonctif utile : personne n'a demandé que la veillée disparaisse ; on a proposé que les restes aillent au panier.
Ne pas fondre : on peut aimer le rite et voter la règle.
Ne pas crier : Radio Figuier relatera sans slogan.
Vocabulaire : proposer, relire, voter, tamponner, relater, décrire, nommer.
À + le = au Bureau, au figuier. De + le = du Cahier.
Le politique, ici, tient dans une main levée, pas dans une tribune d'ailleurs.""",
        tf_item=(
            "Au Seuil, une motion tamponnée équivaut à une loi d'État.",
            False,
            "C'est une règle de cour, une mémoire, pas un sceau d'État.",
        ),
        qcm_item=(
            "Que doit-on séparer en décrivant la veillée ?",
            [
                "Le sel et le sucre seulement",
                "Le rite et la règle",
                "Léa et Patrick",
                "L'eau et le minibus sans lien",
            ],
            1,
            "Rite (rassembler) / règle (limiter un geste).",
        ),
        pairs=[
            ("veillée", "rite"),
            ("motion", "règle votée"),
            ("tampon", "Bureau des Escales"),
            ("sans slogan", "relater"),
        ],
        fill_item=("On a proposé que les restes ___ au panier. (aller)", "aillent"),
        words=["Une", "motion", "a", "été", "lue", "sous", "le", "figuier", "."],
        anagram=("relater", "Dire le fait vu, sans slogan et sans ministre inventé de trop."),
        error=(
            "On a proposé que les restes aillent au panier, et la veillée a été relater sans slogan.",
            "On a proposé que les restes aillent au panier, et la veillée a été relatée sans slogan.",
            "Passif : relatée, pas l'infinitif relater.",
        ),
        pic_start=14,
        pic_words=_pw(14),
        short_p="Rédigez un mini-lexique : dix mots de l'assemblée de cour, avec un exemple chacun.",
        audio="Enregistrez la fiche et une description en six phrases : trois rites, trois règles.",
    ),
]


# ---------------------------------------------------------------------------
# Séquence 4 — Nuancer une comparaison (subjonctif d'alternative)
# ---------------------------------------------------------------------------

S4 = [
    _l(
        "CO",
        "CO — Que ce soit l'aube ou le soir",
        "Repérer le subjonctif d'alternative : que ce soit… ou…, plutôt que + subjonctif.",
        "Lisez le dialogue. Comment nuance-t-on l'accès à la Salle des Herbes ?",
        "Seuil de la Salle des Herbes, clé de Solange",
        """Aline : Que ce soit l'aube ou le soir, la salle ne peut pas rester un secret de quelques-uns.
Solange : Je préfère une plage d'ouverture claire, plutôt que la clé circule sans trace.
Karim : Que la salle soit ouverte le matin ou qu'elle ferme à midi, il faut que l'heure soit écrite.
Léa : Plutôt que l'accès soit réservé aux seuls anciens, que l'on inscrive aussi ceux du minibus.
Patrick : Que ce soit Hawa ou Dieudonné, quiconque enseigne un geste utile devrait pouvoir réserver.
Rose : Je compare sans casser : la cour large vaut mieux, plutôt qu'un cercle étroit se reproduise.
Marc : Nuancer, ce n'est pas tout égaliser. Que ce soit l'eau ou la salle, chaque enjeu a sa mesure.
Noura : Plutôt qu'on décide sans nous, nous viendrons à l'assemblée, même tard.
Joël : Que les enfants passent ou que les anciens restent, le banc de la salle n'est pas une propriété.
Lila : Radio Figuier dira les deux heures, que ce soit jeudi ou dimanche.
Yvette : Je crains le tout ou rien. Que ce soit trop ouvert ou trop fermé, la cour perd.
Félicie : Plutôt que la salle serve de dépôt, qu'elle reste un lieu de parole.
Mado : Comparer A et B, puis choisir une voie, plutôt que l'on s'insulte.
Aline : Formules : que ce soit… ou… ; que… ou que… ; plutôt que + subjonctif.""",
        tf_item=(
            "Solange préfère que la clé circule sans trace.",
            False,
            "Elle préfère une plage claire, plutôt que la clé circule sans trace.",
        ),
        qcm_item=(
            "Que demande Léa, plutôt qu'un accès réservé aux anciens ?",
            [
                "Fermer la salle pour toujours",
                "Inscrire aussi ceux du minibus",
                "Vendre la clé au marché",
                "Interdire Hawa",
            ],
            1,
            "« que l'on inscrive aussi ceux du minibus »",
        ),
        pairs=[
            ("que ce soit l'aube ou le soir", "alternative d'heure"),
            ("plutôt que la clé circule", "Solange"),
            ("que… ou que…", "Karim / Joël"),
            ("plutôt qu'on décide sans nous", "Noura"),
        ],
        fill_item=("Que ce ___ l'aube ou le soir, la salle ne reste pas un secret.", "soit"),
        words=["Que", "ce", "soit", "l'aube", "ou", "le", "soir", "la", "salle", "reste", "commune", "."],
        anagram=("plutot", "Lien d'alternative : … que la clé circule sans trace. (sans accent)"),
        error=(
            "Que ce est l'aube ou le soir la salle reste commune, et je préfère une heure écrite plutôt que la clé circule sans trace.",
            "Que ce soit l'aube ou le soir la salle reste commune, et je préfère une heure écrite plutôt que la clé circule sans trace.",
            "Que ce soit : subjonctif de être.",
        ),
        pic_start=15,
        pic_words=_pw(15),
        short_p="Notez quatre alternatives : deux que ce soit… ou…, deux plutôt que + subj.",
        audio="Enregistrez : Que ce soit l'aube ou le soir, la salle reste commune. Plutôt que la clé circule sans trace, écrivons l'heure.",
    ),
    _l(
        "CE",
        "CE — Note de nuance sur la Salle des Herbes",
        "Lire une comparaison nuancée qui enchaîne que ce soit… ou… et plutôt que + subj.",
        "Lisez la note, sans aller trop vite.",
        "Note de Solange, Bureau des Escales",
        """Accès à la Salle des Herbes — comparer sans casser
Que ce soit l'aube ou le soir, une heure écrite vaut mieux qu'un bruit de clé.
Que la salle ouvre le jeudi ou qu'elle ouvre le dimanche, l'inscription se fait au Bureau, pas sous une pierre.
Plutôt que l'accès soit réservé aux seuls anciens, j'inscrirai aussi ceux du minibus Figuier 7, à condition qu'ils signent.
Plutôt que la clé circule sans trace, elle restera dans le tiroir tamponné. On la retire, on la rend.
Que ce soit Hawa, Dieudonné ou Félicie, quiconque prépare un geste utile peut réserver une plage.
Je compare deux peurs : trop fermé, la cour étouffe ; trop ouvert, la salle devient un dépôt.
Plutôt que l'on s'insulte, que l'on vote une plage, une durée, un nom sur le cahier.
Noura a dit : plutôt qu'on décide sans nous, nous viendrons, même après le pont.
Marc nuance : que ce soit l'eau, les lanternes ou la salle, chaque enjeu a sa mesure ; on ne copie pas une règle sur l'autre.
Aline : nuancer une comparaison, c'est garder les deux termes visibles, puis choisir.
Yvette : je crains le tout ou rien. Que ce soit trop d'huile ou trop de silence, la cour perd.
Lila relayera les deux heures, que ce soit par la radio ou par l'affiche du figuier.
Solange — Rukiri-Nord. Ce texte n'est pas un décret d'ailleurs ; c'est une nuance de cour.""",
        tf_item=(
            "Solange accepte que la clé circule sans trace si l'on est pressé.",
            False,
            "Plutôt que la clé circule sans trace, elle restera dans le tiroir tamponné.",
        ),
        qcm_item=(
            "Que fera Solange plutôt que de réserver la salle aux seuls anciens ?",
            [
                "Fermer le Bureau",
                "Inscrire aussi ceux du minibus, s'ils signent",
                "Cacher la clé sous une pierre",
                "Interdire le jeudi",
            ],
            1,
            "« j'inscrirai aussi ceux du minibus… à condition qu'ils signent »",
        ),
        pairs=[
            ("que ce soit l'aube ou le soir", "heure écrite"),
            ("plutôt que la clé circule", "tiroir tamponné"),
            ("que ce soit Hawa ou Félicie", "quiconque utile"),
            ("plutôt qu'on décide sans nous", "Noura"),
        ],
        fill_item=("Plutôt que l'accès ___ réservé aux anciens, on inscrira d'autres voix. (être)", "soit"),
        words=["Que", "ce", "soit", "le", "jeudi", "ou", "le", "dimanche", "on", "inscrit", "au", "Bureau", "."],
        anagram=("nuance", "Comparer deux peurs sans tout égaliser, puis choisir une plage."),
        error=(
            "Que ce soit l'aube ou le soir une heure écrite vaut mieux, et plutôt que la clé circulent sans trace elle restera au tiroir.",
            "Que ce soit l'aube ou le soir une heure écrite vaut mieux, et plutôt que la clé circule sans trace elle restera au tiroir.",
            "La clé, singulier : circule.",
        ),
        pic_start=16,
        pic_words=_pw(16),
        short_p="Recopiez la note et encadrez que ce soit / plutôt que + verbe au subjonctif.",
        audio="Lisez la note de Solange, sans aller trop vite.",
    ),
    _l(
        "PO",
        "PO — Dire que ce soit… ou…, plutôt que",
        "Nuancer à l'oral une comparaison avec le subjonctif d'alternative.",
        "Répétez, puis comparez deux accès à la salle sans tomber dans le tout ou rien.",
        "Modèles d'Aline et de Noura",
        """Que ce soit l'aube ou le soir, l'heure s'écrit.
Que ce soit jeudi ou dimanche, on inscrit au Bureau.
Que la salle ouvre tôt ou qu'elle ferme à midi, la clé se rend.
Plutôt que la clé circule sans trace, elle reste au tiroir.
Plutôt que l'accès soit réservé aux anciens, inscrivons ceux du minibus.
Plutôt qu'on décide sans nous, nous viendrons à l'assemblée.
Que ce soit Hawa ou Dieudonné, quiconque utile peut réserver.
Je compare trop fermé et trop ouvert : la cour perd dans les deux cas.
Nuancer, ce n'est pas tout égaliser.
Une plage vaut mieux qu'un secret.
Que ce soit l'eau ou la salle, chaque enjeu a sa mesure.
Aline : plutôt que + subjonctif met l'option refusée au mode de l'avis.
Noura : que… ou que… tient les deux portes ouvertes le temps de choisir.
Marc : le tout ou rien casse la comparaison.""",
        tf_item=(
            "« Plutôt que la clé circule » emploie le subjonctif après plutôt que.",
            True,
            "Circule : subjonctif (identique à l'indicatif ici, 3e pers.).",
        ),
        qcm_item=(
            "Quelle phrase est une alternative correcte ?",
            [
                "Que ce est l'aube ou le soir",
                "Que ce soit l'aube ou le soir l'heure s'écrit",
                "Que ce sera l'aube ou le soir",
                "Plutôt que de la clé est circulé",
            ],
            1,
            "Que ce soit A ou B.",
        ),
        pairs=[
            ("que ce soit… ou…", "deux termes tenus"),
            ("que… ou que…", "deux phrases au subj."),
            ("plutôt que + subj.", "option refusée"),
            ("nuancer", "pas tout égaliser"),
        ],
        fill_item=("Plutôt qu'on ___ sans nous, nous viendrons. (décider)", "décide"),
        words=["Que", "ce", "soit", "Hawa", "ou", "Dieudonné", "on", "peut", "réserver", "."],
        anagram=("alternative", "Deux voies tenues ensemble : aube ou soir, ouvert ou fermé."),
        error=(
            "Que ce soit l'aube ou le soir l'heure s'écrit, et plutôt que la clé circule sans trace elle restent au tiroir.",
            "Que ce soit l'aube ou le soir l'heure s'écrit, et plutôt que la clé circule sans trace elle reste au tiroir.",
            "Elle (la clé) : reste, pas restent.",
        ),
        pic_start=17,
        pic_words=_pw(17),
        short_p="Écrivez huit phrases : quatre que ce soit… ou…, quatre plutôt que + subj.",
        audio="Enregistrez les six premiers modèles, puis deux nuances à vous.",
    ),
    _l(
        "PE",
        "PE — Ma comparaison nuancée",
        "Écrire une comparaison argumentée avec que ce soit… ou… et plutôt que + subj.",
        "Imitez la note de Noura, sans aller trop vite.",
        "Note de Noura, Salle des Herbes",
        """Noura — accès à la Salle des Herbes, vue depuis le minibus
Que ce soit l'aube ou le soir, je ne peux pas toujours arriver à l'heure des anciens.
Cela n'annule pas mon droit d'apprendre un geste.
Plutôt que l'accès soit réservé à ceux qui habitent tout près du figuier, que l'on inscrive aussi ceux du Figuier 7.
Que la salle ouvre le jeudi ou qu'elle ouvre le dimanche, l'heure doit être écrite au Bureau des Escales, pas soufflée d'un banc à l'autre.
Plutôt que la clé circule sans trace, Solange la garde ; on la retire, on la rend.
Je m'y plie, et je le dis sans rancune.
Je compare deux peurs : trop fermé, je reste sur le pont ; trop ouvert, la salle devient un dépôt.
Félicie a raison de craindre le dépôt ; j'ai raison de craindre le secret.
Plutôt qu'on décide sans nous, nous viendrons à l'assemblée, même tard, même fatigués.
Que ce soit Hawa ou Dieudonné qui enseigne, quiconque prépare un geste utile devrait pouvoir réserver une plage.
Nuancer, pour moi, ce n'est pas tout égaliser : c'est refuser le tout ou rien.
Noura
Copie : Solange, Aline, Karim, Cahier des racines""",
        tf_item=(
            "Noura refuse de rendre la clé et veut qu'elle circule sans trace.",
            False,
            "Elle se plie à la règle : on la retire, on la rend.",
        ),
        qcm_item=(
            "Que refuse Noura, plutôt qu'un accès trop étroit ?",
            [
                "Que l'on inscrive ceux du minibus",
                "Que l'accès soit réservé à ceux qui habitent tout près",
                "Que Solange tamponne",
                "Que Félicie parle",
            ],
            1,
            "« Plutôt que l'accès soit réservé à ceux qui habitent tout près »",
        ),
        pairs=[
            ("que ce soit l'aube ou le soir", "droit d'apprendre"),
            ("plutôt que l'accès soit réservé", "inscrire le minibus"),
            ("plutôt que la clé circule", "Solange la garde"),
            ("plutôt qu'on décide sans nous", "venir à l'assemblée"),
        ],
        fill_item=("Que la salle ___ le jeudi ou qu'elle ouvre le dimanche, l'heure s'écrit. (ouvrir)", "ouvre"),
        words=["Nuancer", "ce", "n'est", "pas", "tout", "égaliser", "."],
        anagram=("inscrire", "Porter un nom sur le cahier du Bureau, pour une plage de salle."),
        error=(
            "Que ce soit l'aube ou le soir je viendrai, et plutôt que l'accès est réservé aux proches on inscrira le minibus.",
            "Que ce soit l'aube ou le soir je viendrai, et plutôt que l'accès soit réservé aux proches on inscrira le minibus.",
            "Plutôt que + subjonctif : soit, pas est.",
        ),
        pic_start=18,
        pic_words=_pw(18),
        short_p="Imitez : quinze lignes, trois que ce soit… ou…, trois plutôt que + subj., une peur de trop fermé et une de trop ouvert.",
        audio="Lisez votre note, une phrase, une pause, sans aller trop vite.",
    ),
    _l(
        "EL",
        "EL — Subjonctif d'alternative",
        "Retenir que ce soit… ou…, que… ou que…, plutôt que + subjonctif.",
        "Apprenez la fiche.",
        "Fiche d'Aline, alternatives",
        """Que ce soit A ou B + indicatif dans la suite, souvent :
Que ce soit l'aube ou le soir, l'heure s'écrit. (soit = subj. de être)
Que + phrase au subj. + ou que + phrase au subj. :
Que la salle ouvre tôt ou qu'elle ferme à midi, la clé se rend.
Plutôt que + subjonctif : option que l'on refuse, encore possible :
Plutôt que la clé circule sans trace, elle reste au tiroir.
Plutôt que l'accès soit réservé aux anciens, inscrivons les autres.
Plutôt qu'on décide sans nous, nous viendrons. (qu'on = que + on)
Fréquent aussi : plutôt que de + infinitif (même sujet) : plutôt que de crier, votons.
Ici on travaille le subjonctif d'alternative, plus marqué à l'oral soigné et à l'écrit.
Nuancer ≠ tout égaliser. On tient les deux termes, puis on choisit une mesure.
On ne dit pas : que ce est… / plutôt que l'accès est réservé (indicatif après plutôt que dans cet emploi).
Tout ou rien : à éviter. Que ce soit trop ouvert ou trop fermé, la cour perd.
À + le = au Bureau. De + le = du figuier.
Chaque enjeu (eau, lanternes, salle) a sa mesure : on ne copie pas une règle sur l'autre.""",
        tf_item=(
            "« Que ce soit » emploie le subjonctif de être.",
            True,
            "Soit = subjonctif, 3e personne.",
        ),
        qcm_item=(
            "Quelle construction refuse une option au subjonctif ?",
            [
                "parce que + indicatif seulement",
                "plutôt que la clé circule",
                "pendant que + imparfait seulement",
                "il y a + nom seulement",
            ],
            1,
            "Plutôt que + subjonctif.",
        ),
        pairs=[
            ("que ce soit A ou B", "deux termes"),
            ("que… ou que…", "deux phrases"),
            ("plutôt que + subj.", "option refusée"),
            ("plutôt que de + inf.", "même sujet, fréquent"),
        ],
        fill_item=("Que ce ___ trop ouvert ou trop fermé, la cour perd.", "soit"),
        words=["Plutôt", "que", "la", "clé", "circule", "sans", "trace", "elle", "reste", "au", "tiroir", "."],
        anagram=("egaliser", "Nuancer n'est pas tout… : on choisit encore une mesure. (sans accent)"),
        error=(
            "Que ce soit l'aube ou le soir l'heure s'écrit, et plutôt que l'accès est trop étroit on ouvrira une plage.",
            "Que ce soit l'aube ou le soir l'heure s'écrit, et plutôt que l'accès soit trop étroit on ouvrira une plage.",
            "Plutôt que + subjonctif : soit.",
        ),
        pic_start=19,
        pic_words=_pw(19),
        short_p="Transformez six comparaisons sèches en alternatives (que ce soit / plutôt que + subj.).",
        audio="Enregistrez la fiche et six alternatives.",
    ),
]


# ---------------------------------------------------------------------------
# Séquence 5 — Enquête à Rukiri-Nord (EXTRA)
# ---------------------------------------------------------------------------

S5 = [
    _l(
        "CO",
        "CO — Quatre voix pour une enquête",
        "Relier passif, subjonctif et nuance dans une enquête de cour sur quatre enjeux.",
        "Lisez le dialogue. Quels faits ont été recueillis, et quelles positions s'entendent ?",
        "Table des Sources, carnets ouverts",
        """Lila : L'enquête a été ouverte à Rukiri-Nord. Quatre enjeux, pas un slogan : eau, heures calmes, lanternes, salle.
Marc : Il a été entendu vingt voix sous le figuier. Rien n'a été inventé au marché.
Hawa : Que ce soit l'aube ou midi, l'eau manque à ceux qui arrivent tard. Je veux que le créneau soit expliqué, pas seulement tamponné.
Sami : Je doute que la veillée meure si le tambour finit plus tôt. Il se peut que le rythme tienne mieux, plus court.
Rose : Les lanternes ont été comptées. Douze sont encore au bord de l'eau. Cela a été vu par Dieudonné.
Solange : Plutôt que la clé de la salle circule sans trace, elle restera au Bureau. Bien que certains râlent, la trace protège.
Noura : Je suis heureuse que l'enquête nous nomme. Plutôt qu'on décide sans le minibus, que l'on inscrive nos heures.
Patrick : Une motion a été relue. Personne n'a demandé que la fête disparaisse.
Joël : Que ce soit trop d'huile ou trop de silence, la cour perd. Nuancer, ce n'est pas tout égaliser.
Yvette : Je crains que la fatigue n'empêche d'écouter la quatrième voix, celle de la salle.
Karim : Le dossier sera examiné à Radio Figuier. L'enquête est portée par Lila et Marc, pas par un cri.
Aline : On relie : passif pour le fait, subjonctif pour l'avis, alternative pour la nuance.
Mado : Un chiffre a été posé ; un souhait a été dit ; une peur a été nommée. C'est déjà une enquête.
Dieudonné : Si l'eau a été ménagée, que les heures le soient aussi pour ceux du pont.""",
        tf_item=(
            "Douze lanternes ont été vues encore au bord de l'eau.",
            True,
            "Rose : « Douze sont encore au bord de l'eau. »",
        ),
        qcm_item=(
            "Par qui l'enquête est-elle portée ?",
            [
                "Par un cri du marché",
                "Par Lila et Marc",
                "Par un parti d'ailleurs",
                "Par le minibus vide",
            ],
            1,
            "Karim : portée par Lila et Marc.",
        ),
        pairs=[
            ("l'enquête a été ouverte", "passif de fait"),
            ("je veux que / je doute que", "avis au subj."),
            ("que ce soit trop d'huile ou trop de silence", "alternative"),
            ("plutôt que la clé circule", "Solange"),
        ],
        fill_item=("L'enquête ___ été ouverte à Rukiri-Nord.", "a"),
        words=["Rien", "n'a", "été", "inventé", "au", "marché", "."],
        anagram=("enquete", "Recueil de voix à Rukiri-Nord, sans accent, quatre enjeux."),
        error=(
            "L'enquête a été ouverte sous le figuier, et vingt voix ont été entendu.",
            "L'enquête a été ouverte sous le figuier, et vingt voix ont été entendues.",
            "Voix au féminin pluriel → entendues.",
        ),
        pic_start=20,
        pic_words=_pw(20),
        short_p="Notez un passif, un subjonctif d'avis et une alternative pour chaque enjeu (eau, soir, lanternes, salle).",
        audio="Enregistrez : L'enquête a été ouverte. Je veux que le créneau soit expliqué. Que ce soit trop d'huile ou trop de silence, la cour perd.",
    ),
    _l(
        "CE",
        "CE — Synthèse d'enquête",
        "Lire une synthèse qui relie faits passifs, avis au subjonctif et comparaisons nuancées.",
        "Lisez la synthèse, sans aller trop vite.",
        "Synthèse de Marc et Lila, Cahier des racines",
        """Enquête à Rukiri-Nord — quatre enjeux, une cour
Eau. Il a été décidé un créneau d'aube.
La mesure est portée par Hawa et Dieudonné ; elle est contestée par Noura.
Que ce soit six heures ou huit heures, l'heure doit être lisible.
Plutôt que le créneau reste un secret de tampon, qu'il soit dit à la radio.
Heures calmes. Rose veut que le tambour cesse à vingt et une heures.
Sami doute que le silence soit une fête.
Bien que la veillée soit précieuse, une fin d'heure a été demandée.
Personne n'a exigé que la fête disparaisse.
Lanternes. Douze restes ont été vus au bord de l'eau. Une motion a été tamponnée : panier ocre, non rivière.
Le rite rassemble ; la règle limite un geste.
Salle des Herbes. Solange préfère une trace, plutôt que la clé circule.
Noura demande que ceux du minibus soient inscrits, que la salle ouvre jeudi ou qu'elle ouvre dimanche.
Méthode. Vingt voix ont été entendues. Rien n'a été inventé.
L'enquête est portée par la radio et le cahier, pas par un cri.
Aline : le passif pose le fait ; le subjonctif porte l'avis ; l'alternative empêche le tout ou rien.
Yvette : je crains que l'on n'oublie la quatrième voix.
Joël : que ce soit l'eau ou la salle, chaque mesure reste distincte.""",
        tf_item=(
            "La synthèse dit que quelqu'un a exigé la disparition de la veillée.",
            False,
            "« Personne n'a exigé que la fête disparaisse. »",
        ),
        qcm_item=(
            "Combien de voix ont été entendues ?",
            [
                "Deux",
                "Douze",
                "Vingt",
                "Cent",
            ],
            2,
            "« Vingt voix ont été entendues. »",
        ),
        pairs=[
            ("créneau d'aube", "eau"),
            ("vingt et une heures", "heures calmes"),
            ("panier ocre", "lanternes"),
            ("trace de clé", "salle"),
        ],
        fill_item=("Plutôt que le créneau reste un secret, qu'il ___ dit à la radio. (être)", "soit"),
        words=["Vingt", "voix", "ont", "été", "entendues", "sous", "le", "figuier", "."],
        anagram=("synthese", "Texte qui relie quatre enjeux, sans accent, avant l'éditorial."),
        error=(
            "Vingt voix ont été entendues sous le figuier, et rien n'a été inventer au marché.",
            "Vingt voix ont été entendues sous le figuier, et rien n'a été inventé au marché.",
            "Passif : inventé, pas l'infinitif inventer.",
        ),
        pic_start=21,
        pic_words=_pw(21),
        short_p="Recopiez la synthèse et marquez P (passif), S (subjonctif), A (alternative) dans la marge.",
        audio="Lisez la synthèse d'enquête, sans aller trop vite.",
    ),
    _l(
        "PO",
        "PO — Dire les résultats sans crier",
        "Restituer à l'oral l'enquête : faits au passif, avis au subjonctif, nuances.",
        "Répétez, puis présentez l'enquête en quatre points, sans slogan.",
        "Modèles de Lila et d'Aline",
        """L'enquête a été ouverte à Rukiri-Nord.
Vingt voix ont été entendues.
L'eau : il a été décidé un créneau ; je veux qu'il soit expliqué.
Les heures calmes : je doute que la fête meure si le tambour finit plus tôt.
Les lanternes : douze restes ont été vus ; une motion a été tamponnée.
La salle : plutôt que la clé circule, elle reste au Bureau.
Que ce soit l'eau ou la salle, chaque mesure est distincte.
Bien que la veillée soit précieuse, une heure peut finir.
Personne n'a demandé que le rite disparaisse.
Nuancer, ce n'est pas tout égaliser.
Le dossier sera examiné à la radio.
Aline : on relie les outils, on ne les entasse pas.
Marc : un chiffre, un que, une alternative : déjà une enquête.
Karim : pas de parti, pas de tribune : un figuier, un cahier.""",
        tf_item=(
            "Les modèles refusent de fondre les quatre enjeux en un seul cri.",
            True,
            "Chaque mesure reste distincte.",
        ),
        qcm_item=(
            "Quelle phrase mêle passif de fait et volonté au subjonctif ?",
            [
                "Je crie plus fort que Sami",
                "Il a été décidé un créneau ; je veux qu'il soit expliqué",
                "On ferme tout",
                "Que ce est l'eau",
            ],
            1,
            "Passé passif + je veux que + subj.",
        ),
        pairs=[
            ("a été ouverte / ont été entendues", "faits"),
            ("je veux que / je doute que", "avis"),
            ("plutôt que la clé circule", "salle"),
            ("que ce soit l'eau ou la salle", "nuance"),
        ],
        fill_item=("Bien que la veillée ___ précieuse, une heure peut finir.", "soit"),
        words=["Le", "dossier", "sera", "examiné", "à", "la", "radio", "."],
        anagram=("chiffre", "Donnée vue : vingt voix, douze lanternes, un créneau d'aube."),
        error=(
            "L'enquête a été ouverte à Rukiri-Nord, et vingt voix ont été entendus trop vite.",
            "L'enquête a été ouverte à Rukiri-Nord, et vingt voix ont été entendues trop vite.",
            "Voix féminin pluriel → entendues.",
        ),
        pic_start=22,
        pic_words=_pw(22),
        short_p="Écrivez douze phrases d'enquête : trois par enjeu, en mêlant passif et subjonctif.",
        audio="Enregistrez les six premiers modèles, puis votre restitution en quatre points.",
    ),
    _l(
        "PE",
        "PE — Mon rapport d'enquête",
        "Écrire un rapport argumenté qui relie les quatre enjeux sans les fondre.",
        "Imitez le rapport de Lila Sow, sans aller trop vite.",
        "Rapport de Lila, Radio Figuier",
        """Lila Sow — enquête à Rukiri-Nord, pour le Cahier des racines
L'enquête a été ouverte sous le figuier.
Vingt voix ont été entendues.
Rien n'a été inventé au Marché des Lampions.
Eau. Il a été décidé un créneau d'aube.
Je veux que cette mesure soit expliquée à ceux du minibus, plutôt qu'elle reste un tampon muet.
Que ce soit six heures ou huit heures, l'heure doit être lue.
Heures calmes. Rose exige que le dernier morceau cesse.
Sami doute que le silence soit une fête.
Bien que la veillée soit précieuse, une fin d'heure a été demandée.
Personne n'a souhaité que le rite disparaisse.
Lanternes. Douze restes ont été vus. Une motion a été portée par Rose, relue par Marc, tamponnée par Solange.
Le rite rassemble ; la règle limite l'huile.
Salle. Plutôt que la clé circule sans trace, elle restera au Bureau.
Noura demande que ceux du pont soient inscrits, que la salle ouvre jeudi ou qu'elle ouvre dimanche.
Je crains que la fatigue n'efface la quatrième voix.
Que ce soit trop d'huile ou trop de silence, la cour perd.
Nuancer, ce n'est pas tout égaliser.""",
        tf_item=(
            "Lila dit que l'enquête a inventé des voix au marché.",
            False,
            "« Rien n'a été inventé au Marché des Lampions. »",
        ),
        qcm_item=(
            "Que craint Lila à la fin du rapport ?",
            [
                "Que Solange perde le tampon",
                "Que la fatigue n'efface la quatrième voix",
                "Que la rivière disparaisse",
                "Que Radio Figuier change de nom",
            ],
            1,
            "« Je crains que la fatigue n'efface la quatrième voix. »",
        ),
        pairs=[
            ("créneau d'aube", "eau"),
            ("dernier morceau", "heures calmes"),
            ("douze restes", "lanternes"),
            ("clé au Bureau", "salle"),
        ],
        fill_item=("Je crains que la fatigue n'___ la quatrième voix. (effacer)", "efface"),
        words=["Rien", "n'a", "été", "inventé", "au", "marché", "."],
        anagram=("rapport", "Texte d'enquête : faits, avis, nuances, sans slogan d'antenne."),
        error=(
            "L'enquête a été ouverte sous le figuier, et je veux que la mesure est expliquée au minibus.",
            "L'enquête a été ouverte sous le figuier, et je veux que la mesure soit expliquée au minibus.",
            "Vouloir que + subjonctif : soit, pas est.",
        ),
        pic_start=23,
        pic_words=_pw(23),
        short_p="Imitez : seize lignes, quatre enjeux, passifs, subjonctifs d'avis, une alternative, pas de slogan.",
        audio="Lisez votre rapport, une phrase, une pause, sans aller trop vite.",
    ),
    _l(
        "EL",
        "EL — Relier passif, avis et alternative",
        "Retenir comment une enquête de cour combine les outils des séquences 1 à 4.",
        "Apprenez la fiche.",
        "Fiche de synthèse d'enquête",
        """Fait (S1) : passif pour mettre en valeur l'élément.
L'enquête a été ouverte. Vingt voix ont été entendues. Une motion a été tamponnée.
Avis (S2) : subjonctif de volonté, doute, sentiment, but, concession.
Je veux que… / je doute que… / je crains que… / afin que… / bien que…
Fait de cour (S3) : séparer rite et règle. Personne n'a demandé que la veillée disparaisse.
Nuance (S4) : que ce soit A ou B ; plutôt que + subjonctif.
Que ce soit l'eau ou la salle, la mesure reste distincte.
Plutôt que la clé circule, elle reste au Bureau.
On ne fond pas les quatre enjeux. On ne crie pas un parti. On ne copie pas une méthode d'ailleurs.
Accords : voix entendues ; restes vus ; mesure portée ; enquête ouverte.
Il faut (pas je faut). À + le = au Bureau, au figuier.
Ne explétif : je crains que la fatigue n'efface.
Éditorial demain : on argumentera ; aujourd'hui on relie les outils.
Une enquête tient si le chiffre et le que restent visibles tous les deux.""",
        tf_item=(
            "La fiche autorise à fondre eau, soir, lanternes et salle en un seul cri.",
            False,
            "On ne fond pas les quatre enjeux.",
        ),
        qcm_item=(
            "Quel outil sert surtout à mettre un élément en valeur dans le fait ?",
            [
                "le tout ou rien",
                "la voix passive",
                "un slogan d'antenne",
                "un sceau d'État",
            ],
            1,
            "Passif = projecteur (S1).",
        ),
        pairs=[
            ("passif", "fait mis en sujet"),
            ("subjonctif", "avis"),
            ("que ce soit / plutôt que", "nuance"),
            ("rite / règle", "fait de cour"),
        ],
        fill_item=("Plutôt que la clé ___, elle reste au Bureau. (circuler)", "circule"),
        words=["On", "ne", "fond", "pas", "les", "quatre", "enjeux", "."],
        anagram=("outils", "Passif, subjonctif, alternative : ce que l'enquête relie."),
        error=(
            "Vingt voix ont été entendues sous le figuier, et je doute que le silence est une fête.",
            "Vingt voix ont été entendues sous le figuier, et je doute que le silence soit une fête.",
            "Douter que + subjonctif : soit.",
        ),
        pic_start=24,
        pic_words=_pw(24),
        short_p="Tableau à quatre colonnes (eau, soir, lanternes, salle) : un passif, un que, une alternative.",
        audio="Enregistrez la fiche et une mini-enquête de huit phrases.",
    ),
]


# ---------------------------------------------------------------------------
# Séquence 6 — Éditorial pour le Cahier des racines (EXTRA)
# ---------------------------------------------------------------------------

S6 = [
    _l(
        "CO",
        "CO — Préparer l'éditorial",
        "Comprendre comment un éditorial de cour argumente sans crier, à partir de l'enquête.",
        "Lisez le dialogue. Quelles qualités d'un éditorial entend-on, et quels écueils ?",
        "Atelier du Cahier des racines, plume de Marc",
        """Marc : Un éditorial n'est pas un cri. Il prend position, il s'appuie sur ce qui a été entendu, il nuance.
Aline : On veut que le lecteur tienne jusqu'au bout. On doute qu'un slogan suffise. On est heureux que l'enquête existe.
Lila : Que ce soit l'eau ou la salle, chaque paragraphe aura sa mesure. Plutôt que l'on mélange tout, on numérotera les enjeux.
Rose : Je souhaite que l'on nomme les agents : portée par, contestée par. Le passif sans par devient parfois un brouillard.
Solange : Il faut que le tampon reste à sa place : une mémoire, pas une preuve d'infaillibilité.
Patrick : Bien que nous soyons las, nous écrirons sans injure. Un éditorial qui insulte n'est plus un éditorial.
Léa : Afin que Noura se reconnaisse, on dira le minibus. Afin que Sami se reconnaisse, on dira la veillée.
Joël : Je crains que l'on n'oublie le chiffre : vingt voix, douze lanternes, un créneau.
Hawa : Plutôt que la conclusion soit un tout ou rien, qu'elle ouvre une assemblée.
Karim : Le Cahier des racines n'est pas une tribune d'État. C'est un cahier de cour, relié, ocre.
Yvette : On relatera ce qui a été vu. On argumentera ce que l'on veut. On séparera les deux.
Mado : Titre possible : « Ce qui a été décidé n'efface pas ce qui a été oublié. »
Dieudonné : Si l'eau est mise en sujet, que la soif le soit aussi.
Aline : Forme : thèse, faits au passif, avis au subjonctif, alternative, ouverture. Pas de parti réel.""",
        tf_item=(
            "Marc dit qu'un éditorial peut se contenter d'un cri.",
            False,
            "« Un éditorial n'est pas un cri. »",
        ),
        qcm_item=(
            "Quel titre Mado propose-t-elle ?",
            [
                "Fermez la cour",
                "Ce qui a été décidé n'efface pas ce qui a été oublié",
                "Vive un parti d'ailleurs",
                "Silence total dès midi",
            ],
            1,
            "Mado cite le titre ocre.",
        ),
        pairs=[
            ("thèse + faits + avis", "forme de l'éditorial"),
            ("portée par / contestée par", "nommer l'agent"),
            ("que ce soit l'eau ou la salle", "paragraphes distincts"),
            ("Cahier des racines", "cahier de cour"),
        ],
        fill_item=("On veut que le lecteur ___ jusqu'au bout. (tenir)", "tienne"),
        words=["Un", "éditorial", "n'est", "pas", "un", "cri", "."],
        anagram=("editorial", "Texte d'avis argumenté pour le Cahier des racines, sans accent."),
        error=(
            "On veut que le lecteur tient jusqu'au bout, et on doute qu'un slogan suffise à la cour.",
            "On veut que le lecteur tienne jusqu'au bout, et on doute qu'un slogan suffise à la cour.",
            "Vouloir que + subjonctif : tienne, pas tient.",
        ),
        pic_start=25,
        pic_words=_pw(25),
        short_p="Notez la forme de l'éditorial (cinq étapes) et deux écueils à éviter.",
        audio="Enregistrez : Un éditorial n'est pas un cri. Que ce soit l'eau ou la salle, chaque paragraphe aura sa mesure.",
    ),
    _l(
        "CE",
        "CE — Éditorial-modèle du Cahier",
        "Lire un éditorial argumentatif qui réemploie passif, subjonctif et alternatives.",
        "Lisez l'éditorial, sans aller trop vite.",
        "Cahier des racines, une du jeudi",
        """Ce qui a été décidé n'efface pas ce qui a été oublié
L'enquête a été ouverte à Rukiri-Nord.
Vingt voix ont été entendues.
Nous voulons que ces voix restent visibles, plutôt qu'elles fondent dans un slogan.
Que ce soit l'eau, les heures calmes, les lanternes ou la salle, chaque enjeu a été nommé.
Il a été décidé un créneau d'aube : la mesure est portée par ceux qui marchent, et elle est contestée par ceux du minibus.
Nous demandons que l'heure soit expliquée, afin que Noura n'arrive plus devant un tampon muet.
Bien que la veillée soit précieuse, une fin d'heure a été demandée.
Nous doutons que Sami perde sa place si le tambour cesse plus tôt.
Personne n'a exigé que le rite disparaisse : on a limité l'huile, on n'a pas tué la flamme.
Douze restes ont été vus ; une motion a été tamponnée.
Plutôt que la clé de la Salle des Herbes circule sans trace, qu'elle reste au Bureau.
Plutôt que l'accès soit un secret d'anciens, que ceux du pont soient inscrits, que la salle ouvre jeudi ou qu'elle ouvre dimanche.
Nous craignons que la fatigue n'efface la quatrième voix.
Que ce soit trop d'huile ou trop de silence, la cour perd.
Nuancer, ce n'est pas tout égaliser ; c'est refuser le tout ou rien.
Le Cahier des racines n'est pas une tribune d'État. C'est une mémoire de cour.
Nous souhaitons que l'assemblée se tienne, pour que ce qui a été oublié soit enfin dit.""",
        tf_item=(
            "L'éditorial affirme que le Cahier des racines est une tribune d'État.",
            False,
            "« n'est pas une tribune d'État. C'est une mémoire de cour. »",
        ),
        qcm_item=(
            "Que demandent les rédacteurs pour l'eau ?",
            [
                "Supprimer les seaux",
                "Que l'heure soit expliquée afin que Noura ne trouve plus un tampon muet",
                "Interdire Hawa",
                "Fermer la rivière",
            ],
            1,
            "Expliquer l'heure, pas seulement tamponner.",
        ),
        pairs=[
            ("vingt voix ont été entendues", "fait"),
            ("nous voulons que / nous doutons que", "avis"),
            ("plutôt que la clé circule", "salle"),
            ("mémoire de cour", "Cahier des racines"),
        ],
        fill_item=("Nous doutons que Sami ___ sa place. (perdre)", "perde"),
        words=["Nuancer", "ce", "n'est", "pas", "tout", "égaliser", "."],
        anagram=("memoire", "Rôle du Cahier des racines, sans accent : garder les voix, pas crier."),
        error=(
            "L'enquête a été ouverte à Rukiri-Nord, et nous voulons que ces voix reste visibles.",
            "L'enquête a été ouverte à Rukiri-Nord, et nous voulons que ces voix restent visibles.",
            "Voix au pluriel : restent.",
        ),
        pic_start=26,
        pic_words=_pw(26),
        short_p="Recopiez l'éditorial et soulignez passifs, subjonctifs et alternatives.",
        audio="Lisez l'éditorial-modèle, sans aller trop vite.",
    ),
    _l(
        "PO",
        "PO — Dire la thèse et l'ouverture",
        "Prononcer thèse, arguments et ouverture d'un éditorial de cour.",
        "Répétez, puis formulez à l'oral votre thèse sur un des quatre enjeux.",
        "Modèles de Marc et d'Aline",
        """Un éditorial n'est pas un cri.
Ce qui a été décidé n'efface pas ce qui a été oublié.
Nous voulons que les voix restent visibles.
Que ce soit l'eau ou la salle, chaque paragraphe a sa mesure.
Il a été entendu vingt voix.
Nous doutons qu'un slogan suffise.
Bien que nous soyons las, nous écrirons sans injure.
Afin que Noura se reconnaisse, nous dirons le minibus.
Plutôt que la conclusion soit un tout ou rien, qu'elle ouvre une assemblée.
Le Cahier des racines est une mémoire de cour.
Nous souhaitons que l'assemblée se tienne.
Aline : thèse d'abord, chiffre ensuite, que ensuite, ouverture enfin.
Léa : le ton reste calme ; le mode, lui, travaille.
Rose : nommer l'agent après par, pour que le passif ne devienne pas un brouillard.""",
        tf_item=(
            "L'ouverture proposée est une assemblée, non un tout ou rien.",
            True,
            "Plutôt que la conclusion soit un tout ou rien, qu'elle ouvre une assemblée.",
        ),
        qcm_item=(
            "Quelle phrase pose la thèse reprise au titre ?",
            [
                "Fermez le figuier",
                "Ce qui a été décidé n'efface pas ce qui a été oublié",
                "Il n'y a plus d'eau nulle part ailleurs",
                "Sami doit partir",
            ],
            1,
            "Thèse = titre de Mado, repris ici.",
        ),
        pairs=[
            ("thèse", "décidé / oublié"),
            ("fait", "vingt voix"),
            ("avis", "nous voulons que"),
            ("ouverture", "assemblée"),
        ],
        fill_item=("Bien que nous ___ las, nous écrirons sans injure. (être)", "soyons"),
        words=["Le", "Cahier", "des", "racines", "est", "une", "mémoire", "de", "cour", "."],
        anagram=("these", "Phrase d'ouverture de l'éditorial, sans accent : ce que l'on soutient."),
        error=(
            "Nous voulons que les voix restent visibles, et nous doutons qu'un slogan suffit à tenir la cour.",
            "Nous voulons que les voix restent visibles, et nous doutons qu'un slogan suffise à tenir la cour.",
            "Douter que + subjonctif : suffise.",
        ),
        pic_start=27,
        pic_words=_pw(27),
        short_p="Écrivez une thèse, trois arguments (un passif, un que, une alternative) et une ouverture.",
        audio="Enregistrez les six premiers modèles, puis votre thèse.",
    ),
    _l(
        "PE",
        "PE — Mon éditorial",
        "Écrire un éditorial argumentatif pour le Cahier des racines.",
        "Imitez l'éditorial de Marc Nkurunziza, sans aller trop vite.",
        "Éditorial de Marc, encre ocre",
        """Marc Nkurunziza — Cahier des racines, Seuil des Sources
Ce qui a été décidé n'efface pas ce qui a été oublié.
Voilà ma thèse, et je la tiens.
L'enquête a été ouverte. Vingt voix ont été entendues.
Je veux que ces voix restent dans le cahier, plutôt qu'elles se perdent dans un cri.
Que ce soit l'eau ou la salle, je refuse de tout fondre.
Il a été décidé un créneau : la mesure est portée par Hawa, contestée par Noura.
Je demande que l'heure soit dite à Radio Figuier, afin que le minibus ne se heurte plus à un tampon muet.
Bien que la veillée soit précieuse, je souhaite que le dernier morceau cesse.
Je doute que Sami disparaisse pour si peu.
Douze lanternes ont été vues au bord de l'eau ; une motion a été tamponnée.
On a limité un geste ; on n'a pas tué un rite.
Plutôt que la clé circule sans trace, qu'elle reste chez Solange.
Plutôt que l'accès soit un secret, que ceux du pont soient inscrits.
Je crains que la fatigue n'efface la quatrième voix.
Que ce soit trop d'huile ou trop de silence, la cour perd.
Nuancer n'est pas tout égaliser.
Je souhaite que l'assemblée se tienne sous le figuier, pour que ce qui a été oublié soit enfin nommé.""",
        tf_item=(
            "Marc veut fondre eau et salle en un seul paragraphe de colère.",
            False,
            "« je refuse de tout fondre. »",
        ),
        qcm_item=(
            "Quelle ouverture Marc souhaite-t-il ?",
            [
                "Fermer le Cahier",
                "Que l'assemblée se tienne sous le figuier",
                "Interdire Noura",
                "Vendre Radio Figuier",
            ],
            1,
            "« Je souhaite que l'assemblée se tienne sous le figuier. »",
        ),
        pairs=[
            ("thèse", "décidé / oublié"),
            ("créneau / tampon muet", "eau"),
            ("motion / rite", "lanternes"),
            ("clé chez Solange", "salle"),
        ],
        fill_item=("Je souhaite que l'assemblée se ___ sous le figuier. (tenir)", "tienne"),
        words=["Je", "refuse", "de", "tout", "fondre", "."],
        anagram=("argument", "Ce qui porte l'éditorial : un fait, un que, une nuance, une ouverture."),
        error=(
            "Je veux que ces voix restent dans le cahier, et je doute que Sami disparaît pour si peu.",
            "Je veux que ces voix restent dans le cahier, et je doute que Sami disparaisse pour si peu.",
            "Douter que + subjonctif : disparaisse.",
        ),
        pic_start=28,
        pic_words=_pw(28),
        short_p="Imitez : seize à dix-huit lignes, thèse, quatre enjeux, passifs, subjonctifs, alternatives, ouverture d'assemblée.",
        audio="Lisez votre éditorial, une phrase, une pause, sans aller trop vite.",
    ),
    _l(
        "EL",
        "EL — L'éditorial de cour : outils et forme",
        "Retenir la forme de l'éditorial et le réemploi des outils B2 de l'avis.",
        "Apprenez la fiche.",
        "Fiche de Lila, éditorial",
        """Forme : titre-thèse ; faits (passif) ; avis (subjonctif) ; nuance (alternative) ; ouverture.
Thèse type : ce qui a été décidé n'efface pas ce qui a été oublié.
Faits : l'enquête a été ouverte ; vingt voix ont été entendues ; une motion a été tamponnée.
Avis : nous voulons que / nous doutons que / nous craignons que / afin que / bien que.
Nuance : que ce soit A ou B ; plutôt que + subj. Nuancer ≠ tout égaliser.
Ouverture : nous souhaitons que l'assemblée se tienne. Pas de tout ou rien.
Écueils : cri ; slogan ; parti réel ; sceau d'État prêté au tampon ; tout fondre.
Le Cahier des racines = mémoire de cour, pas tribune d'ailleurs.
Accords passif : voix entendues, restes vus, mesure portée, clé gardée.
Subj. utiles : tienne, soit, circule, disparaisse, soyons, perde, ouvre.
Il faut que le tampon reste une mémoire. (pas je faut)
À + le = au Cahier, au figuier, au Bureau.
Un éditorial tient si le lecteur entend encore les vingt voix à la dernière ligne.""",
        tf_item=(
            "La fiche présente le tampon du Bureau comme une preuve d'infaillibilité.",
            False,
            "Écueil : sceau d'État prêté au tampon. Le tampon est une mémoire.",
        ),
        qcm_item=(
            "Quel est l'ordre proposé pour l'éditorial ?",
            [
                "cri, injure, slogan, silence",
                "thèse, faits, avis, nuance, ouverture",
                "ouverture, puis rien",
                "faits seulement, sans avis",
            ],
            1,
            "Thèse → faits → avis → nuance → ouverture.",
        ),
        pairs=[
            ("passif", "faits"),
            ("subjonctif", "avis"),
            ("que ce soit / plutôt que", "nuance"),
            ("assemblée", "ouverture"),
        ],
        fill_item=("Nous souhaitons que l'assemblée se ___ . (tenir)", "tienne"),
        words=["Un", "éditorial", "n'est", "pas", "un", "cri", "."],
        anagram=("ouverture", "Fin de l'éditorial : convoquer l'assemblée, pas fermer tout."),
        error=(
            "Nous voulons que ces voix restent visibles, et nous doutons qu'un slogan suffit demain.",
            "Nous voulons que ces voix restent visibles, et nous doutons qu'un slogan suffise demain.",
            "Douter que + subjonctif : suffise.",
        ),
        pic_start=29,
        pic_words=_pw(29),
        short_p="Rédigez un plan d'éditorial en cinq cases, avec une phrase modèle dans chacune.",
        audio="Enregistrez la fiche et une mini-thèse de cinq phrases.",
    ),
]


SEQUENCES = [
    {"title": "Un enjeu à analyser", "lessons": S1},
    {"title": "Prendre position", "lessons": S2},
    {"title": "Fait culturel et politique", "lessons": S3},
    {"title": "Nuancer une comparaison", "lessons": S4},
    {"title": "Enquête à Rukiri-Nord", "lessons": S5},
    {"title": "Éditorial pour le Cahier des racines", "lessons": S6},
]
