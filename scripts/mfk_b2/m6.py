"""B2 Module 6 — Faire évoluer la société (univers Seuil des Sources)."""

from factory import L

IMG = "mfk-b2-m6"
IMG_DIR = IMG

MODULE = {
    "title": "B2 — Faire évoluer la société",
    "description": (
        "Grande étape B2-6 : dresser un bilan sous condition, formuler une prise "
        "de conscience et des recommandations, engager une action citoyenne avec "
        "les indéfinis, dénoncer et proposer par des locutions, siéger à "
        "l'assemblée sous le figuier et déposer une motion formelle au Bureau "
        "des Escales — pour que l'eau, les heures calmes, les lanternes et la "
        "Salle des Herbes évoluent au Seuil des Sources (Rukiri-Nord)."
    ),
}

_PIC = [
    "un bilan",
    "une condition",
    "une assemblée",
    "un graphique",
    "un conseil",
    "un regret",
    "une recommandation",
    "une conscience",
    "une action",
    "un indéfini",
    "une pétition",
    "un seau",
    "une locution",
    "un accord",
    "une dénonciation",
    "une solution",
    "une motion",
    "un tampon",
    "une lettre officielle",
    "une porte",
    "le compost",
    "un arbre",
    "un groupe",
    "un appel",
    "une banderole",
    "des signatures",
    "un soleil",
    "une hypothèse",
    "une feuille",
    "un cœur citoyen",
]


def _pw(start: int) -> list[str]:
    return [_PIC[(start + i) % len(_PIC)] for i in range(4)]


def _l(comp, title, obj, cons, st, sp, **kw):
    return L(IMG, comp, title, obj, cons, st, sp, **kw)


# ---------------------------------------------------------------------------
# Séquence 1 — Dresser un bilan (condition)
# ---------------------------------------------------------------------------

S1 = [
    _l(
        "CO",
        "CO — Si l'eau revient, à condition que…",
        "Repérer les conditions d'un bilan : si, à condition que + subj., pourvu que, à moins que, en cas de.",
        "Lisez le dialogue (à écouter avec l'enseignant). À quelles conditions le bilan de la cour tient-il ?",
        "Table des Sources, graphique ocre",
        """Aline : Dressons le bilan. Si l'eau a été ménagée à l'aube, le soir reste à expliquer.
Dieudonné : Le chiffre tient, à condition que les seaux manquants soient retrouvés.
Hawa : Pourvu que Noura trouve encore de l'eau après le minibus, le créneau pourra s'élargir d'une demi-heure.
Rose : À moins que la rivière ne baisse encore, nous n'ouvrirons pas un second créneau cette semaine.
Solange : En cas de pénurie, le Bureau tamponnera une file, pas une rumeur.
Marc : Si nous avions écouté Noura plus tôt, le bilan serait moins boiteux d'un côté.
Léa : Le soir tient, à condition que le tambour cesse à l'heure dite.
Sami : Pourvu que la veillée reste une fête, j'accepte de frapper plus court.
Patrick : À moins que Solange ne refuse le tampon, la motion des lanternes reste valable.
Karim : En cas de clé perdue, on n'ouvre pas la Salle des Herbes avec une pierre.
Lila : Si l'enquête a été entendue, le bilan doit la citer, pas la fondre.
Joël : À condition que chacun signe, le graphique des seaux pourra être affiché au figuier.
Yvette : Pourvu que la fatigue ne décide pas à notre place, nous finirons ce bilan.
Mado : En cas de désaccord, on reconvoque l'assemblée, on n'invente pas un chef.
Aline : Cinq outils : si + indicatif ou imparfait ; à condition que / pourvu que / à moins que + subj. ; en cas de + nom.""",
        tf_item=(
            "Rose n'ouvrira un second créneau que si la rivière ne baisse pas.",
            True,
            "« À moins que la rivière ne baisse encore, nous n'ouvrirons pas un second créneau. »",
        ),
        qcm_item=(
            "Que tamponnera Solange en cas de pénurie ?",
            [
                "Une rumeur du marché",
                "Une file",
                "Un sceau d'État",
                "Un interdiction du figuier",
            ],
            1,
            "« le Bureau tamponnera une file, pas une rumeur. »",
        ),
        pairs=[
            ("si l'eau a été ménagée", "le soir reste à expliquer"),
            ("à condition que", "seaux retrouvés / tambour / signatures"),
            ("pourvu que", "Noura / veillée / fatigue"),
            ("à moins que / en cas de", "rivière / tampon / pénurie / clé"),
        ],
        fill_item=("Le chiffre tient, à condition que les seaux manquants ___ retrouvés. (être)", "soient"),
        words=["En", "cas", "de", "pénurie", "le", "Bureau", "tamponnera", "une", "file", "."],
        anagram=("pourvu", "Lien de condition optimiste : … que la veillée reste une fête."),
        error=(
            "Le chiffre tient à condition que les seaux sont retrouvés, et le graphique pourra être affiché.",
            "Le chiffre tient à condition que les seaux soient retrouvés, et le graphique pourra être affiché.",
            "À condition que + subjonctif : soient, pas sont.",
        ),
        pic_start=0,
        pic_words=_pw(0),
        short_p="Notez cinq conditions du bilan, une par outil (si, à condition que, pourvu que, à moins que, en cas de).",
        audio="Enregistrez : Si l'eau a été ménagée, le soir reste à expliquer. À condition que les seaux soient retrouvés. En cas de pénurie, on tamponne une file.",
    ),
    _l(
        "CE",
        "CE — Bilan conditionnel de la cour",
        "Lire un bilan qui articule si, à condition que, pourvu que, à moins que et en cas de.",
        "Lisez le bilan, sans aller trop vite.",
        "Bilan de Marc Nkurunziza, Cahier des racines",
        """Bilan — ce qui tient, à quelles conditions (Seuil des Sources)
Eau. Si le créneau d'aube a été respecté quatre matins sur sept, le niveau a tenu.
Le bilan reste juste, à condition que les trois seaux manquants soient nommés, non cachés.
Pourvu que Noura trouve encore de quoi remplir après le Figuier 7, Hawa accepte d'ouvrir une demi-heure de plus.
À moins que la rivière ne baisse, nous n'inventerons pas un second créneau cette semaine.
En cas de pénurie, Solange tamponnera une file au Bureau des Escales.
Si nous avions écouté le pont plus tôt, cette file serait déjà écrite.
Heures calmes. Le soir s'améliore, à condition que le dernier morceau cesse.
Pourvu que la veillée reste une fête, Sami frappe plus court.
À moins que la fatigue ne gagne, l'assemblée pourra revoir l'heure.
Lanternes. Douze restes ont été vus. Si le panier ocre est utilisé, l'huile n'atteint plus l'eau.
En cas de récidive, la motion n°14 sera relue, non criée.
Salle. La clé tient, à condition qu'elle rentre au tiroir.
Pourvu que ceux du minibus soient inscrits, l'accès cessera d'être un secret.
En cas de clé perdue, on n'ouvre pas avec une pierre.
Aline : un bilan sans condition est un vœu. Un bilan avec cinq outils est une carte.""",
        tf_item=(
            "Hawa refuse toute demi-heure de plus, même si Noura trouve de l'eau.",
            False,
            "Pourvu que Noura trouve encore de quoi remplir, Hawa accepte d'ouvrir une demi-heure de plus.",
        ),
        qcm_item=(
            "Que fera-t-on en cas de clé perdue ?",
            [
                "Ouvrir avec une pierre",
                "Ne pas ouvrir avec une pierre",
                "Vendre la salle",
                "Couper Radio Figuier",
            ],
            1,
            "« on n'ouvre pas avec une pierre. »",
        ),
        pairs=[
            ("si le créneau a été respecté", "le niveau a tenu"),
            ("à condition que", "seaux nommés / tambour / clé"),
            ("pourvu que", "Noura / veillée / minibus"),
            ("en cas de", "pénurie / récidive / clé perdue"),
        ],
        fill_item=("À moins que la rivière ne ___, nous n'ouvrirons pas un second créneau. (baisser)", "baisse"),
        words=["Un", "bilan", "sans", "condition", "est", "un", "vœu", "."],
        anagram=("bilan", "Texte qui dit ce qui tient, et à quelles conditions cela tient."),
        error=(
            "Le soir s'améliore à condition que le dernier morceau cesse, et pourvu que la veillée restera une fête.",
            "Le soir s'améliore à condition que le dernier morceau cesse, et pourvu que la veillée reste une fête.",
            "Pourvu que + subjonctif : reste, pas le futur restera.",
        ),
        pic_start=1,
        pic_words=_pw(1),
        short_p="Recopiez le bilan et encadrez si / à condition que / pourvu que / à moins que / en cas de.",
        audio="Lisez le bilan de Marc, sans aller trop vite.",
    ),
    _l(
        "PO",
        "PO — Dire les conditions du bilan",
        "Formuler à l'oral un bilan sous condition, en variant les cinq outils.",
        "Répétez, puis dressez le bilan d'un enjeu avec au moins trois conditions.",
        "Modèles d'Aline et de Dieudonné",
        """Si l'eau a été ménagée, le soir reste à expliquer.
Le chiffre tient, à condition que les seaux soient nommés.
Pourvu que Noura trouve encore de l'eau, on ouvrira une demi-heure.
À moins que la rivière ne baisse, pas de second créneau.
En cas de pénurie, on tamponne une file.
Si nous avions écouté plus tôt, le bilan serait moins boiteux.
Le soir tient, à condition que le tambour cesse.
Pourvu que la veillée reste une fête, Sami frappe plus court.
À moins que Solange ne refuse, la motion reste valable.
En cas de clé perdue, on n'ouvre pas avec une pierre.
Si chacun signe, le graphique ira au figuier.
Aline : à condition que et pourvu que + subjonctif. En cas de + nom.
Marc : si + imparfait ouvre une hypothèse ; si + présent ouvre un réel possible.
Rose : à moins que prend souvent un ne explétif.""",
        tf_item=(
            "« En cas de » est suivi d'un nom, non d'un subjonctif.",
            True,
            "En cas de pénurie / de clé perdue / de récidive.",
        ),
        qcm_item=(
            "Quelle phrase emploie correctement à moins que ?",
            [
                "À moins que la rivière baisse pas",
                "À moins que la rivière ne baisse",
                "À moins que la rivière baissera",
                "À moins de que la rivière est",
            ],
            1,
            "À moins que + ne explétif + subjonctif.",
        ),
        pairs=[
            ("si + présent / PC", "réel possible"),
            ("si + imparfait", "hypothèse"),
            ("à condition que / pourvu que", "subjonctif"),
            ("en cas de", "nom"),
        ],
        fill_item=("Pourvu que la veillée ___ une fête, Sami frappe plus court. (rester)", "reste"),
        words=["En", "cas", "de", "clé", "perdue", "on", "n'ouvre", "pas", "avec", "une", "pierre", "."],
        anagram=("condition", "Lien sans lequel le bilan n'est qu'un vœu : si, pourvu que, en cas de."),
        error=(
            "À moins que la rivière baisse encore, le Bureau tamponnera une file en cas de pénurie.",
            "À moins que la rivière ne baisse encore, le Bureau tamponnera une file en cas de pénurie.",
            "À moins que + ne explétif + subjonctif.",
        ),
        pic_start=2,
        pic_words=_pw(2),
        short_p="Écrivez dix phrases de bilan : deux par outil de condition.",
        audio="Enregistrez les six premiers modèles, puis un bilan à vous en trois conditions.",
    ),
    _l(
        "PE",
        "PE — Mon bilan sous condition",
        "Écrire un bilan argumenté qui pose ce qui tient et à quelles conditions.",
        "Imitez le bilan de Hawa Diallo, sans aller trop vite.",
        "Bilan de Hawa, Cahier des racines",
        """Hawa Diallo — bilan de l'eau, et des autres voix
Si le créneau d'aube a été respecté, la rivière a tenu.
Je le dis sans triomphe : le bilan reste juste, à condition que les trois seaux manquants soient nommés.
Pourvu que Noura trouve encore de quoi remplir après le minibus, j'accepte d'ouvrir une demi-heure.
À moins que la rivière ne baisse, je n'inventerai pas un second créneau cette semaine.
En cas de pénurie, que Solange tamponne une file, non une rumeur.
Si nous avions écouté le pont plus tôt, cette file serait déjà sur l'affiche.
Le soir n'est pas mon enjeu premier, mais le bilan de la cour le contient.
Il tient, à condition que le tambour cesse à l'heure.
Pourvu que la veillée reste une fête, Sami peut frapper plus court.
Les lanternes : si le panier ocre est utilisé, l'huile n'atteint plus l'eau.
En cas de récidive, la motion sera relue.
La salle : la clé tient, à condition qu'elle rentre.
Pourvu que ceux du minibus soient inscrits, l'accès cessera d'être un secret.
Un bilan sans condition est un vœu.
Le mien en a cinq, et je les tiens.""",
        tf_item=(
            "Hawa invente un second créneau dès cette semaine, quoi qu'il arrive à la rivière.",
            False,
            "À moins que la rivière ne baisse, elle n'inventera pas un second créneau.",
        ),
        qcm_item=(
            "Que demande Hawa en cas de pénurie ?",
            [
                "Une rumeur au marché",
                "Une file tamponnée par Solange",
                "La fermeture du figuier",
                "Un sceau d'État",
            ],
            1,
            "« que Solange tamponne une file, non une rumeur. »",
        ),
        pairs=[
            ("si le créneau a été respecté", "la rivière a tenu"),
            ("à condition que", "seaux / tambour / clé"),
            ("pourvu que", "Noura / veillée / minibus"),
            ("en cas de", "pénurie / récidive"),
        ],
        fill_item=("Si nous avions écouté plus tôt, cette file ___ déjà sur l'affiche. (être, cond.)", "serait"),
        words=["Un", "bilan", "sans", "condition", "est", "un", "vœu", "."],
        anagram=("penurie", "Manque d'eau : en cas de… on tamponne une file. (sans accent)"),
        error=(
            "Le bilan reste juste à condition que les seaux sont nommés, et pourvu que Noura trouve encore de l'eau.",
            "Le bilan reste juste à condition que les seaux soient nommés, et pourvu que Noura trouve encore de l'eau.",
            "À condition que + subjonctif : soient, pas sont.",
        ),
        pic_start=3,
        pic_words=_pw(3),
        short_p="Imitez : quinze lignes de bilan, les cinq outils de condition, deux enjeux au moins.",
        audio="Lisez votre bilan, une phrase, une pause, sans aller trop vite.",
    ),
    _l(
        "EL",
        "EL — Condition : si, pourvu que, en cas de",
        "Retenir les cinq outils de condition et le mode qui les suit.",
        "Apprenez la fiche.",
        "Fiche d'Aline, conditions du bilan",
        """Si + présent / passé composé → futur ou présent (réel possible) :
Si l'eau a été ménagée, le soir reste à expliquer. Si chacun signe, le graphique ira au figuier.
Si + imparfait → conditionnel (hypothèse) : si nous avions écouté, le bilan serait moins boiteux.
Si + plus-que-parfait → conditionnel passé (regret d'hypothèse) : si nous avions parlé, nous aurions évité la file.
À condition que + subjonctif : le chiffre tient, à condition que les seaux soient nommés.
Pourvu que + subjonctif (condition + souhait) : pourvu que Noura trouve de l'eau.
À moins que + (ne explétif) + subjonctif : à moins que la rivière ne baisse.
En cas de + nom : en cas de pénurie, de clé perdue, de récidive, de désaccord.
On ne dit pas : à condition que les seaux sont… On ne dit pas : en cas que + phrase (on dit au cas où + cond., ou en cas de + nom).
Au cas où + conditionnel : au cas où la rivière baisserait, Solange ouvrirait une file.
Il faut (pas je faut). À + le = au Bureau, au figuier.
Un bilan sans condition est un vœu ; un bilan conditionné est une carte pour agir.""",
        tf_item=(
            "« Pourvu que » se construit avec l'indicatif, comme « si ».",
            False,
            "Pourvu que + subjonctif. Si + indicatif (ou imparfait).",
        ),
        qcm_item=(
            "Quelle suite est correcte après « en cas de » ?",
            [
                "en cas de que l'eau baisse",
                "en cas de pénurie",
                "en cas de soient les seaux",
                "en cas de à moins que",
            ],
            1,
            "En cas de + nom.",
        ),
        pairs=[
            ("si + PC / présent", "réel possible"),
            ("si + imparfait", "conditionnel"),
            ("à condition que / pourvu que / à moins que", "subjonctif"),
            ("en cas de", "nom"),
        ],
        fill_item=("À condition que les seaux ___ nommés, le bilan reste juste. (être)", "soient"),
        words=["Pourvu", "que", "Noura", "trouve", "de", "l'eau", "."],
        anagram=("hypothese", "Si + imparfait, puis le mode du possible. (sans accent)"),
        error=(
            "Le chiffre tient à condition que les seaux soient nommés, et en cas que pénurie on tamponne une file.",
            "Le chiffre tient à condition que les seaux soient nommés, et en cas de pénurie on tamponne une file.",
            "En cas de + nom, pas en cas que.",
        ),
        pic_start=4,
        pic_words=_pw(4),
        short_p="Tableau : cinq outils, le mode qui suit, deux exemples chacun.",
        audio="Enregistrez la fiche et cinq phrases, un outil chacune.",
    ),
]


# ---------------------------------------------------------------------------
# Séquence 2 — Prise de conscience et recommandations
# ---------------------------------------------------------------------------

S2 = [
    _l(
        "CO",
        "CO — On pourrait, j'aurais dû",
        "Repérer le conditionnel d'atténuation et le conditionnel passé de regret.",
        "Lisez le dialogue. Quelles recommandations s'entendent, et quels regrets ?",
        "Banc du figuier, après le bilan",
        """Aline : On pourrait élargir le créneau d'une demi-heure, sans casser l'aube.
Hawa : Il faudrait que Noura soit prévenue la veille, pas au moment du seau vide.
Rose : Je suggérerais de baisser le micro plus tôt. Vous feriez mieux d'écrire l'heure, Lila.
Sami : J'aurais dû finir le morceau avant vingt et une heures. Je le dis sans théâtre.
Léa : Nous n'aurions pas dû laisser douze lanternes au bord de l'eau. Il aurait fallu le panier dès le premier jeudi.
Patrick : On devrait relire la motion avant de crier. Un conditionnel atténue ; il n'efface pas le fait.
Solange : J'aurais dû tamponner la file dès la première soif du pont. Voilà mon regret.
Dieudonné : Il vaudrait mieux compter les seaux à deux, plutôt que de les croire rangés.
Noura : Vous pourriez afficher l'heure à hauteur d'enfant. Ce n'est pas un ordre ; c'est une recommandation.
Marc : Nous aurions dû écouter le silence de Noura comme un fait, pas comme un aveu.
Joël : On pourrait convoquer l'assemblée sans attendre l'orage.
Yvette : Je recommanderais une pause entre le tambour et le micro. La cour respirerait.
Karim : Il aurait fallu que la clé rentre le soir même. J'aurais dû la réclamer.
Lila : Atténuer, c'est on pourrait / il faudrait / je suggérerais. Regretter, c'est j'aurais dû / nous n'aurions pas dû / il aurait fallu.""",
        tf_item=(
            "Sami formule un regret au conditionnel passé : j'aurais dû finir plus tôt.",
            True,
            "Sami : « J'aurais dû finir le morceau avant vingt et une heures. »",
        ),
        qcm_item=(
            "Que suggérerait Rose à Lila ?",
            [
                "Fermer Radio Figuier",
                "Écrire l'heure / baisser le micro plus tôt",
                "Interdire Hawa",
                "Cacher les seaux",
            ],
            1,
            "Je suggérerais de baisser le micro ; vous feriez mieux d'écrire l'heure.",
        ),
        pairs=[
            ("on pourrait / il faudrait", "atténuation"),
            ("je suggérerais / vous feriez mieux", "recommandation polie"),
            ("j'aurais dû", "regret personnel"),
            ("nous n'aurions pas dû / il aurait fallu", "regret collectif"),
        ],
        fill_item=("J'___ dû finir le morceau avant vingt et une heures. (avoir, cond. passé)", "aurais"),
        words=["On", "pourrait", "élargir", "le", "créneau", "d'une", "demi-heure", "."],
        anagram=("regret", "Ce que Sami et Solange portent : j'aurais dû, trop tard pour l'aube."),
        error=(
            "J'aurais du finir le morceau plus tôt, et on pourrait encore élargir le créneau.",
            "J'aurais dû finir le morceau plus tôt, et on pourrait encore élargir le créneau.",
            "Dû (devoir) prend l'accent ; du est l'article.",
        ),
        pic_start=5,
        pic_words=_pw(5),
        short_p="Classez six répliques : atténuation d'un côté, regret de l'autre.",
        audio="Enregistrez : On pourrait élargir le créneau. Il faudrait que Noura soit prévenue. J'aurais dû finir plus tôt.",
    ),
    _l(
        "CE",
        "CE — Carnet de conscience",
        "Lire des recommandations atténuées et des regrets au conditionnel passé.",
        "Lisez le carnet, sans aller trop vite.",
        "Carnet d'Aline Uwase, Salle des Herbes",
        """Prise de conscience — recommandations et regrets (Seuil)
On pourrait élargir l'eau d'une demi-heure, à condition que l'aube tienne. Il faudrait que Noura soit prévenue la veille.
Je suggérerais d'afficher l'heure à hauteur d'enfant. Vous feriez mieux de ne pas coller l'affiche trop haut : cela a déjà été vu.
Sami écrit : j'aurais dû cesser plus tôt. Léa et Patrick : nous n'aurions pas dû laisser l'huile à la rivière. Il aurait fallu le panier dès le premier jeudi.
Solange : j'aurais dû tamponner la file dès la première soif du pont. Dieudonné : il vaudrait mieux compter les seaux à deux.
Marc : nous aurions dû entendre le silence de Noura comme un fait. Joël : on pourrait convoquer l'assemblée sans attendre l'orage.
Yvette recommanderait une pause entre le tambour et le micro. La cour respirerait, et Radio Figuier n'aurait pas à crier par-dessus.
Karim : il aurait fallu que la clé rentre le soir même. J'aurais dû la réclamer, plutôt que de croire le tiroir plein.
Atténuation : on pourrait, il faudrait, je suggérerais, vous feriez mieux, il vaudrait mieux, on devrait.
Regret : j'aurais dû + infinitif ; nous n'aurions pas dû ; il aurait fallu (que + subj.).
Une recommandation n'est pas un ordre. Un regret n'est pas une injure.
Pour que la cour évolue, il faut que le conditionnel reste un outil, pas un rideau.
Rukiri-Nord — conscience de cour, pas confession d'ailleurs.
Lila lira trois regrets et trois recommandations ce soir, sans théâtre.""",
        tf_item=(
            "Le carnet présente la recommandation comme un ordre sec.",
            False,
            "« Une recommandation n'est pas un ordre. »",
        ),
        qcm_item=(
            "Quel regret Solange écrit-elle ?",
            [
                "Avoir trop chanté",
                "N'avoir pas tamponné la file dès la première soif du pont",
                "Avoir vendu la clé",
                "Avoir fermé le figuier",
            ],
            1,
            "« j'aurais dû tamponner la file dès la première soif du pont. »",
        ),
        pairs=[
            ("on pourrait / il faudrait", "eau / Noura"),
            ("je suggérerais / vous feriez mieux", "affiche"),
            ("j'aurais dû", "Sami / Solange / Karim"),
            ("nous n'aurions pas dû", "huile à la rivière"),
        ],
        fill_item=("Nous n'___ pas dû laisser l'huile à la rivière.", "aurions"),
        words=["Une", "recommandation", "n'est", "pas", "un", "ordre", "."],
        anagram=("conscience", "Moment où la cour voit ce qu'elle aurait dû faire plus tôt."),
        error=(
            "On pourrait élargir le créneau d'une demi-heure, et j'aurais du tamponner la file plus tôt.",
            "On pourrait élargir le créneau d'une demi-heure, et j'aurais dû tamponner la file plus tôt.",
            "Dû de devoir, avec accent, au conditionnel passé.",
        ),
        pic_start=6,
        pic_words=_pw(6),
        short_p="Recopiez trois recommandations et trois regrets ; soulignez les conditionnels.",
        audio="Lisez le carnet d'Aline, sans aller trop vite.",
    ),
    _l(
        "PO",
        "PO — Dire on pourrait, j'aurais dû",
        "Recommander avec le conditionnel d'atténuation et avouer un regret au passé.",
        "Répétez, puis formulez deux recommandations et deux regrets sur la cour.",
        "Modèles de Sami, Solange et Aline",
        """On pourrait élargir le créneau.
Il faudrait que Noura soit prévenue.
Je suggérerais de baisser le micro.
Vous feriez mieux d'écrire l'heure.
Il vaudrait mieux compter les seaux à deux.
On devrait relire la motion avant de crier.
J'aurais dû finir plus tôt.
Nous n'aurions pas dû laisser l'huile à l'eau.
Il aurait fallu le panier dès le premier jeudi.
J'aurais dû tamponner la file plus tôt.
Nous aurions dû entendre le silence de Noura.
Il aurait fallu que la clé rentre le soir même.
Aline : le conditionnel présent atténue l'ordre. Le conditionnel passé porte le regret.
Patrick : j'aurais dû + infinitif. Il aurait fallu que + subjonctif.""",
        tf_item=(
            "« J'aurais dû » se construit avec un infinitif, non avec un subjonctif direct.",
            True,
            "J'aurais dû finir / tamponner / réclamer.",
        ),
        qcm_item=(
            "Quelle phrase est un regret au conditionnel passé ?",
            [
                "On pourrait élargir le créneau",
                "Je suggérerais de baisser le micro",
                "J'aurais dû finir plus tôt",
                "Il faut de l'eau",
            ],
            2,
            "J'aurais dû + infinitif.",
        ),
        pairs=[
            ("on pourrait / on devrait", "atténuation"),
            ("il faudrait que", "atténuation + subj."),
            ("j'aurais dû", "regret + inf."),
            ("il aurait fallu que", "regret + subj."),
        ],
        fill_item=("Il aurait fallu que la clé ___ le soir même. (rentrer)", "rentre"),
        words=["J'aurais", "dû", "tamponner", "la", "file", "plus", "tôt", "."],
        anagram=("recommander", "Dire on pourrait, il faudrait, sans transformer l'avis en ordre."),
        error=(
            "On pourrait élargir le créneau demain, et j'aurais dus finir le morceau plus tôt.",
            "On pourrait élargir le créneau demain, et j'aurais dû finir le morceau plus tôt.",
            "Dû reste invariable ici : j'aurais dû + infinitif.",
        ),
        pic_start=7,
        pic_words=_pw(7),
        short_p="Écrivez dix phrases : cinq atténuations, cinq regrets (dont un il aurait fallu que).",
        audio="Enregistrez les six premiers modèles, puis deux recommandations et un regret à vous.",
    ),
    _l(
        "PE",
        "PE — Mes recommandations et mes regrets",
        "Écrire une prise de conscience : recommandations atténuées et regrets au passé.",
        "Imitez la page de Sami, sans aller trop vite.",
        "Page de Sami, Cahier des racines",
        """Sami — conscience, après la veillée
J'aurais dû finir le morceau avant vingt et une heures.
Je le dis sans théâtre, et je le tiens.
Nous n'aurions pas dû laisser l'huile au bord de l'eau.
Il aurait fallu le panier ocre dès le premier jeudi, plutôt que de croire l'herbe assez propre.
On pourrait garder la veillée et raccourcir la fin.
Il faudrait que Radio Figuier baisse le micro avant le dernier rythme, afin que la rive respire.
Je suggérerais une pause entre le tambour et la parole.
Vous feriez mieux d'écrire l'heure à hauteur d'enfant, Lila : Yvette l'a déjà dit.
Il vaudrait mieux que Rose et moi parlions avant l'assemblée, à condition que personne n'en fasse un duel.
On devrait relire la motion n°14 sans crier.
Un conditionnel atténue ; il n'efface pas les douze lanternes qui ont été vues.
Solange, j'entends ton regret : tu aurais dû tamponner la file plus tôt.
Moi, j'aurais dû écouter Noura comme un fait.
Pour que la cour évolue, il faut que nos « on pourrait » deviennent des gestes, pourvu que l'aube des seaux tienne encore.""",
        tf_item=(
            "Sami refuse d'avouer le moindre regret sur l'heure du tambour.",
            False,
            "Première phrase : j'aurais dû finir avant vingt et une heures.",
        ),
        qcm_item=(
            "Quelle recommandation Sami adresse-t-il à Lila ?",
            [
                "Fermer l'antenne",
                "Écrire l'heure à hauteur d'enfant",
                "Interdire Rose",
                "Cacher le panier",
            ],
            1,
            "« Vous feriez mieux d'écrire l'heure à hauteur d'enfant, Lila. »",
        ),
        pairs=[
            ("j'aurais dû finir", "regret du tambour"),
            ("nous n'aurions pas dû", "huile"),
            ("on pourrait / il faudrait", "veillée et micro"),
            ("vous feriez mieux", "heure à hauteur d'enfant"),
        ],
        fill_item=("Il aurait fallu le panier ___ le premier jeudi.", "dès"),
        words=["J'aurais", "dû", "écouter", "Noura", "comme", "un", "fait", "."],
        anagram=("atténuer", "Rendre l'ordre plus souple : on pourrait, je suggérerais."),
        error=(
            "On pourrait garder la veillée, et nous n'aurions pas dûs laisser l'huile à l'eau.",
            "On pourrait garder la veillée, et nous n'aurions pas dû laisser l'huile à l'eau.",
            "Dû invariable devant un infinitif : pas dûs.",
        ),
        pic_start=8,
        pic_words=_pw(8),
        short_p="Imitez : quinze lignes, trois atténuations, trois regrets, un pour que ou pourvu que.",
        audio="Lisez votre page, une phrase, une pause, sans aller trop vite.",
    ),
    _l(
        "EL",
        "EL — Conditionnel d'atténuation et de regret",
        "Retenir les formes du conditionnel présent (conseil) et du conditionnel passé (regret).",
        "Apprenez la fiche.",
        "Fiche d'Aline, conditionnels citoyens",
        """Atténuation (conditionnel présent) :
on pourrait + inf. ; on devrait + inf. ; je suggérerais de + inf.
il faudrait + inf. / il faudrait que + subj. ; il vaudrait mieux que + subj.
vous feriez mieux de + inf. ; je recommanderais + nom / de + inf.
Regret (conditionnel passé) :
j'aurais dû / tu aurais dû / nous aurions dû + infinitif
nous n'aurions pas dû + inf. (regret d'une action faite)
il aurait fallu + inf. / il aurait fallu que + subj.
j'aurais voulu que + subj. (souhait trop tard)
Dû (devoir) s'écrit avec accent, invariable devant l'infinitif : j'aurais dû parler, nous aurions dû écouter.
On ne dit pas : j'aurais du parler (article). On ne dit pas : j'aurais dus parler (accord fautif).
Futur ≠ cond. : je pourrai (futur, 2 r) / je pourrais (cond.). je ferai / je ferais. je serai / je serais.
Une recommandation n'est pas un ordre. Un regret n'est pas une injure.
Pour que la cour évolue, le conditionnel doit devenir un geste, à condition que l'on signe encore.""",
        tf_item=(
            "On accorde « dû » au pluriel devant un infinitif : nous aurions dûs.",
            False,
            "Dû reste invariable devant l'infinitif.",
        ),
        qcm_item=(
            "Quelle forme est le futur de pouvoir ?",
            [
                "je pourai",
                "je pourrais",
                "je pourrai",
                "je pouvrai",
            ],
            2,
            "Futur : je pourrai (deux r). Conditionnel : je pourrais.",
        ),
        pairs=[
            ("on pourrait / je suggérerais", "atténuation"),
            ("il faudrait que", "atténuation + subj."),
            ("j'aurais dû", "regret + inf."),
            ("il aurait fallu que", "regret + subj."),
        ],
        fill_item=("Demain, je ___ relire la motion. (pouvoir, futur)", "pourrai"),
        words=["J'aurais", "dû", "tamponner", "la", "file", "."],
        anagram=("fallu", "Il aurait… que la clé rentre : regret impersonnel."),
        error=(
            "On pourrait convoquer l'assemblée, et je pourai proposer une pause demain.",
            "On pourrait convoquer l'assemblée, et je pourrai proposer une pause demain.",
            "Futur de pouvoir : pourrai, deux r, sans ais.",
        ),
        pic_start=9,
        pic_words=_pw(9),
        short_p="Conjuguez pouvoir, devoir, falloir (il), suggérer au cond. présent et au cond. passé (je / nous).",
        audio="Enregistrez la fiche et six formes : pourrait, faudrait, suggérerais, aurais dû, n'aurions pas dû, aurait fallu.",
    ),
]


# ---------------------------------------------------------------------------
# Séquence 3 — Action citoyenne (indéfinis)
# ---------------------------------------------------------------------------

S3 = [
    _l(
        "CO",
        "CO — Quiconque signe, chacun porte",
        "Repérer adjectifs et pronoms indéfinis dans une action de cour.",
        "Lisez le dialogue. Qui peut agir, et avec quels indéfinis le dit-on ?",
        "Cour du figuier, cahier de signatures",
        """Solange : Quiconque signe la feuille peut porter un seau demain à l'aube. Quiconque : une personne, n'importe laquelle.
Hawa : Chacun prendra son tour. Chacune, si l'on parle des voix de Noura et d'Yvette, aussi.
Rose : N'importe quel jeudi convient pour compter les lanternes, pourvu que le panier soit là.
Léa : Certains doutent encore. Certaines voix du pont n'ont pas été inscrites. Il faut que toutes le soient.
Patrick : Plusieurs ont déjà porté l'huile jusqu'au compost. Tout le monde n'était pas là, mais plusieurs, oui.
Joël : Tout geste utile compte. Toute excuse trop longue recule l'action. Tous les seaux manquants ont un nom.
Aline : On laisse d'aucuns au bord du dictionnaire : c'est rare, littéraire ; ici l'on dit certains.
Noura : Quiconque arrive par le minibus a le droit d'inscrire une plage à la Salle des Herbes.
Karim : N'importe quelle clé trouvée se rend au Bureau, pas à n'importe qui dans l'herbe.
Lila : Plusieurs écouteront l'antenne ; chacun pourra répondre par un mot, pas par un cri.
Mado : Tout n'est pas urgent. Certaines tâches attendent le jeudi ; d'autres, l'aube.
Dieudonné : Chacun selon ses forces : l'un compte, l'autre porte, un troisième signe.
Yvette : N'importe quel enfant peut lire l'affiche, si elle est assez basse.
Marc : L'action citoyenne, ici, ce n'est pas une foule sans visage : c'est quiconque, chacun, plusieurs, tout — nommé.""",
        tf_item=(
            "Solange réserve la feuille aux seuls anciens, à l'exclusion de quiconque d'autre.",
            False,
            "« Quiconque signe la feuille peut porter un seau. »",
        ),
        qcm_item=(
            "Que dit Aline de « d'aucuns » ?",
            [
                "C'est le mot obligatoire du Seuil",
                "C'est rare et littéraire ; ici l'on dit certains",
                "Cela remplace toujours chacun",
                "Cela interdit de signer",
            ],
            1,
            "Aline : on préfère certains.",
        ),
        pairs=[
            ("quiconque", "n'importe quelle personne"),
            ("chacun / chacune", "tour à tour"),
            ("n'importe quel / quelle", "jeudi / clé / enfant"),
            ("certains / plusieurs / tout", "part ou totalité"),
        ],
        fill_item=("___ signe la feuille peut porter un seau demain.", "Quiconque"),
        words=["Chacun", "prendra", "son", "tour", "à", "l'aube", "."],
        anagram=("quiconque", "N'importe quelle personne : celle qui signe, celle du minibus."),
        error=(
            "Quiconque signent la feuille peut porter un seau, et chacun prendra son tour.",
            "Quiconque signe la feuille peut porter un seau, et chacun prendra son tour.",
            "Quiconque appelle la 3e personne du singulier : signe, pas signent.",
        ),
        pic_start=10,
        pic_words=_pw(10),
        short_p="Notez six indéfinis entendus et la personne ou le geste qu'ils désignent.",
        audio="Enregistrez : Quiconque signe peut porter un seau. Chacun prendra son tour. N'importe quel jeudi convient. Certains doutent encore.",
    ),
    _l(
        "CE",
        "CE — Appel à signer",
        "Lire un appel citoyen qui enchaîne quiconque, chacun, n'importe quel, certains, plusieurs, tout.",
        "Lisez l'appel, sans aller trop vite.",
        "Appel de Solange, Bureau des Escales",
        """Appel — action de cour, signatures au figuier
Quiconque habite Rukiri-Nord, quiconque passe par le Seuil, peut signer. On ne demande pas un titre ; on demande un nom lisible.
Chacun portera, une fois au moins, un seau ou une lanterne éteinte jusqu'au panier. Chacune qui enseigne un geste, Hawa ou Félicie, pourra réserver la salle.
N'importe quel jeudi convient pour compter. N'importe quelle affiche trop haute sera recollée plus bas. N'importe quel enfant doit pouvoir la lire.
Certains doutent que le créneau tienne. Certaines voix du pont n'ont pas encore été inscrites : il faut que toutes le soient, plutôt qu'on décide sans elles.
Plusieurs ont déjà porté l'huile au compost. Plusieurs écouteront Lila ce soir. Ce n'est pas tout le monde ; c'est déjà une action.
Tout geste utile compte. Toute excuse trop longue recule le jeudi. Tous les seaux manquants ont un nom. Toutes les heures s'écrivent au Bureau.
On n'emploiera pas d'aucuns : le mot est rare ; ici l'on dit certains, et cela suffit.
Quiconque trouve une clé la rend, pas à n'importe qui. Karim l'a rappelé.
Marc : l'action citoyenne a des visages. L'indéfini n'efface pas le prénom ; il ouvre la porte.
Aline : quiconque + 3e pers. du singulier. Chacun + singulier. Plusieurs + pluriel.
Seuil des Sources — signer, c'est déjà faire évoluer, pourvu que l'on revienne demain.
Solange — tampon à côté, pas à la place de la signature.""",
        tf_item=(
            "L'appel exige un titre officiel avant toute signature.",
            False,
            "« On ne demande pas un titre ; on demande un nom lisible. »",
        ),
        qcm_item=(
            "Que doivent faire tous les seaux manquants, d'après l'appel ?",
            [
                "Disparaître du bilan",
                "Avoir un nom",
                "Servir de tambour",
                "Aller sous une pierre",
            ],
            1,
            "« Tous les seaux manquants ont un nom. »",
        ),
        pairs=[
            ("quiconque", "habite / passe / trouve une clé"),
            ("chacun / chacune", "porter / réserver"),
            ("n'importe quel", "jeudi / affiche / enfant"),
            ("certains / plusieurs / tout", "doute / compost / geste"),
        ],
        fill_item=("___ geste utile compte.", "Tout"),
        words=["Plusieurs", "ont", "déjà", "porté", "l'huile", "au", "compost", "."],
        anagram=("chacun", "Un à un, son tour de seau : pronom singulier de l'action."),
        error=(
            "Quiconque habitent Rukiri-Nord peut signer, et chacun portera un seau une fois.",
            "Quiconque habite Rukiri-Nord peut signer, et chacun portera un seau une fois.",
            "Quiconque + 3e pers. singulier : habite.",
        ),
        pic_start=11,
        pic_words=_pw(11),
        short_p="Recopiez l'appel et encadrez tous les indéfinis ; notez le verbe qui suit.",
        audio="Lisez l'appel de Solange, sans aller trop vite.",
    ),
    _l(
        "PO",
        "PO — Dire quiconque, chacun, plusieurs",
        "Employer à l'oral les indéfinis pour lancer une action sans fermer la porte.",
        "Répétez, puis lancez un appel : qui peut signer, qui porte, qui doute encore.",
        "Modèles de Solange et d'Aline",
        """Quiconque signe peut porter un seau.
Chacun prendra son tour.
Chacune pourra réserver la salle.
N'importe quel jeudi convient.
N'importe quelle affiche trop haute sera recollée.
Certains doutent encore.
Plusieurs ont déjà porté l'huile.
Tout geste utile compte.
Toute excuse trop longue recule l'action.
Tous les seaux manquants ont un nom.
Quiconque trouve une clé la rend.
Pas à n'importe qui, dans l'herbe.
Aline : quiconque + il (signe, habite, trouve).
Marc : certains / plusieurs ouvrent une part ; tout ouvre le total.""",
        tf_item=(
            "« N'importe qui » et « n'importe quel » se construisent de la même façon.",
            False,
            "N'importe qui = pronom. N'importe quel + nom (jeudi, affiche, enfant).",
        ),
        qcm_item=(
            "Quelle phrase est correcte ?",
            [
                "Quiconque signent demain",
                "Quiconque signe peut porter un seau",
                "Chacun prennent leur tour",
                "Tout les geste compte",
            ],
            1,
            "Quiconque + 3e pers. singulier.",
        ),
        pairs=[
            ("quiconque", "3e pers. singulier"),
            ("chacun / chacune", "un à un"),
            ("n'importe quel + nom", "jeudi / affiche"),
            ("plusieurs / certains", "une part"),
        ],
        fill_item=("N'importe ___ jeudi convient pour compter.", "quel"),
        words=["Tout", "geste", "utile", "compte", "sous", "le", "figuier", "."],
        anagram=("plusieurs", "Plus d'un, pas tous : ceux qui ont déjà porté l'huile."),
        error=(
            "Chacun prendra son tour à l'aube, et n'importe quels jeudi convient pour compter.",
            "Chacun prendra son tour à l'aube, et n'importe quel jeudi convient pour compter.",
            "N'importe quel + nom singulier : quel jeudi.",
        ),
        pic_start=12,
        pic_words=_pw(12),
        short_p="Écrivez douze phrases : deux par indéfini (quiconque, chacun, n'importe quel, certains, plusieurs, tout).",
        audio="Enregistrez les huit premiers modèles, puis un appel à vous.",
    ),
    _l(
        "PE",
        "PE — Mon appel citoyen",
        "Écrire un appel à l'action qui emploie les indéfinis sans effacer les prénoms.",
        "Imitez l'appel de Rose Iradukunda, sans aller trop vite.",
        "Appel de Rose, feuille ocre",
        """Rose Iradukunda — quiconque veut que la cour évolue
Quiconque habite le Seuil, quiconque descend du Figuier 7, peut signer cette feuille.
Je ne demande pas un titre ; je demande un nom.
Chacun portera, une fois, un seau ou une lanterne éteinte.
Chacune qui sait un geste, Hawa ou Félicie, pourra ouvrir une plage à la salle, à condition que Solange inscrive l'heure.
N'importe quel jeudi convient pour compter les restes.
N'importe quelle affiche trop haute sera recollée : n'importe quel enfant doit pouvoir la lire.
Certains doutent encore, et c'est un fait, non une injure.
Certaines voix du pont n'ont pas été inscrites : il faut que toutes le soient, plutôt qu'on décide sans elles.
Plusieurs ont déjà marché jusqu'au compost.
Ce n'est pas tout le monde ; c'est déjà trop précieux pour le taire.
Tout geste utile compte.
Toute excuse trop longue recule le jeudi.
Tous les seaux manquants ont un nom, et je le rappellerai.
Quiconque trouve une clé la rend au Bureau, pas à n'importe qui.
D'aucuns diraient autrement ; ici l'on dit certains, et l'on avance.""",
        tf_item=(
            "Rose refuse les signatures de ceux du minibus.",
            False,
            "« quiconque descend du Figuier 7 peut signer. »",
        ),
        qcm_item=(
            "Que deviennent les affiches trop hautes, d'après Rose ?",
            [
                "Elles sont brûlées",
                "Elles sont recollées plus bas",
                "Elles vont à la rivière",
                "Elles remplacent le tampon",
            ],
            1,
            "« N'importe quelle affiche trop haute sera recollée. »",
        ),
        pairs=[
            ("quiconque", "Seuil / minibus / clé"),
            ("chacun / chacune", "seau / salle"),
            ("n'importe quel", "jeudi / affiche / enfant"),
            ("certains / plusieurs / tout", "doute / compost / geste"),
        ],
        fill_item=("Il faut que ___ les voix du pont soient inscrites.", "toutes"),
        words=["Quiconque", "trouve", "une", "clé", "la", "rend", "."],
        anagram=("signer", "Porter son nom sur la feuille ocre, premier geste de l'action."),
        error=(
            "Certains doute encore sous le figuier, et plusieurs ont déjà porté l'huile.",
            "Certains doutent encore sous le figuier, et plusieurs ont déjà porté l'huile.",
            "Certains + verbe au pluriel : doutent.",
        ),
        pic_start=13,
        pic_words=_pw(13),
        short_p="Imitez : quinze lignes, six indéfinis, un prénom au moins, pas de d'aucuns obligatoire.",
        audio="Lisez votre appel, une phrase, une pause, sans aller trop vite.",
    ),
    _l(
        "EL",
        "EL — Adjectifs et pronoms indéfinis",
        "Retenir accords et constructions de quiconque, chacun, n'importe quel, certains, plusieurs, tout.",
        "Apprenez la fiche.",
        "Fiche d'Aline, indéfinis citoyens",
        """Quiconque = n'importe quelle personne. Toujours 3e pers. singulier :
Quiconque signe / habite / trouve. On ne dit pas : quiconque signent.
Chacun (m.) / chacune (f.) : singulier. Chacun prendra son tour. Chacune pourra réserver.
N'importe qui (pronom) / n'importe quel + nom : n'importe quel jeudi, n'importe quelle affiche, n'importe quels seaux, n'importe quelles heures.
N'importe qui ≠ n'importe quel. Pas à n'importe qui (personne). N'importe quelle clé (objet).
Certains / certaines : pluriel. Certains doutent. Certaines voix n'ont pas été inscrites.
Plusieurs : pluriel, une part (plus d'un, pas tous). Plusieurs ont porté l'huile.
Tout + nom singulier : tout geste. Toute excuse. Tous les seaux. Toutes les heures.
Tout le monde = singulier (tout le monde est là). Tous = pluriel.
D'aucuns : rare, littéraire (= certains). Au Seuil, on dit certains. On peut le reconnaître, on ne l'exige pas.
L'indéfini ouvre la porte ; il n'efface pas le prénom. Quiconque s'appelle encore Noura, Sami, Yvette.
À + le = au Bureau. De + le = du pont.""",
        tf_item=(
            "« Tout le monde » se construit au pluriel : tout le monde sont là.",
            False,
            "Tout le monde est là : singulier.",
        ),
        qcm_item=(
            "Quelle série est correcte ?",
            [
                "quiconque signent / chacun prennent",
                "quiconque signe / chacun prendra / certains doutent",
                "n'importe qui jeudi / tout les geste",
                "d'aucuns obligatoire partout",
            ],
            1,
            "Singulier pour quiconque et chacun ; pluriel pour certains.",
        ),
        pairs=[
            ("quiconque", "3e pers. singulier"),
            ("chacun / chacune", "un à un"),
            ("n'importe quel + nom", "choix ouvert"),
            ("certains / plusieurs", "une part"),
        ],
        fill_item=("Tout le monde ___ déjà là. (être)", "est"),
        words=["N'importe", "quel", "enfant", "peut", "lire", "l'affiche", "."],
        anagram=("indefini", "Classe de mots : quiconque, chacun, plusieurs, tout. (sans accent)"),
        error=(
            "Tout le monde sont déjà sous le figuier, et chacun prendra son tour.",
            "Tout le monde est déjà sous le figuier, et chacun prendra son tour.",
            "Tout le monde + 3e pers. singulier : est.",
        ),
        pic_start=14,
        pic_words=_pw(14),
        short_p="Tableau d'accords : quiconque, chacun, n'importe quel(le)(s), certains, plusieurs, tout/toute/tous/toutes.",
        audio="Enregistrez la fiche et six phrases, un indéfini chacune.",
    ),
]


# ---------------------------------------------------------------------------
# Séquence 4 — Dénoncer et proposer (locutions, accord du PP)
# ---------------------------------------------------------------------------

S4 = [
    _l(
        "CO",
        "CO — Les mesures que nous avons prises",
        "Repérer les locutions prépositionnelles et l'accord du participe avec le COD antéposé.",
        "Lisez le dialogue. Que dénonce-t-on, que propose-t-on, et quels accords entend-on ?",
        "Assemblée naissante, affiche au figuier",
        """Marc : Il faut s'attaquer au gaspillage des lanternes, non aux personnes qui ont fêté.
Aline : Veillons à ce que le panier soit là. Veiller à une heure écrite, veiller à ce que Noura soit prévenue.
Rose : Cette motion aboutira à une règle de cour, à condition que Solange tamponne.
Hawa : Tout cela dépend encore du niveau de la rivière, et du minibus, et de notre mémoire.
Léa : Les mesures que nous avons prises restent fragiles. Prises s'accorde avec mesures, COD avant.
Patrick : La file que Solange a tamponnée n'est pas une rumeur. Tamponnée, féminin, parce que file est avant.
Joël : Les lanternes que nous avons éteintes iront au panier. Éteintes : COD lanternes, avant, féminin pluriel.
Solange : Les voix que j'ai entendues au Bureau n'étaient pas un cri. Entendues, accord.
Karim : Les clés que nous avons rendues ne circulent plus dans l'herbe. Rendues.
Noura : Je dénonce le tampon muet, et je propose une heure dite à la radio. Dénoncer n'est pas insulter.
Dieudonné : On s'attaque à l'huile, on veille au chiffre, on aboutit à une file, on dépend de l'eau.
Lila : Les recommandations que vous avez formulées, je les lirai sans théâtre. Formulées, COD avant.
Yvette : La pause que nous avons demandée entre tambour et micro n'est pas un caprice.
Mado : Accorder le participe, c'est encore une manière de ne pas effacer ce qui a été fait par qui.""",
        tf_item=(
            "Marc dit qu'il faut s'attaquer aux personnes qui ont fêté.",
            False,
            "« s'attaquer au gaspillage… non aux personnes »",
        ),
        qcm_item=(
            "Pourquoi écrit-on « les mesures que nous avons prises » ?",
            [
                "Parce que nous est pluriel seulement",
                "Parce que mesures, COD, est placé avant le verbe",
                "Parce que pris ne s'accorde jamais",
                "Parce que c'est un passif avec être",
            ],
            1,
            "Avoir + PP : accord avec le COD si le COD est avant.",
        ),
        pairs=[
            ("s'attaquer à", "gaspillage / huile"),
            ("veiller à / à ce que", "panier / heure / Noura"),
            ("aboutir à", "règle / file"),
            ("dépendre de", "rivière / minibus / mémoire"),
        ],
        fill_item=("Les mesures que nous avons ___ restent fragiles. (prendre)", "prises"),
        words=["Il", "faut", "s'attaquer", "au", "gaspillage", "des", "lanternes", "."],
        anagram=("mesures", "Décisions déjà prises : créneau, panier, file, clé au tiroir."),
        error=(
            "Les mesures que nous avons pris restent fragiles, et la file que Solange a tamponnée n'est pas une rumeur.",
            "Les mesures que nous avons prises restent fragiles, et la file que Solange a tamponnée n'est pas une rumeur.",
            "Mesures, COD avant, féminin pluriel → prises.",
        ),
        pic_start=15,
        pic_words=_pw(15),
        short_p="Notez quatre locutions et quatre accords COD avant (mot + participe).",
        audio="Enregistrez : Il faut s'attaquer au gaspillage. Veillons à ce que le panier soit là. Les mesures que nous avons prises restent fragiles.",
    ),
    _l(
        "CE",
        "CE — Dénoncer le geste, proposer la règle",
        "Lire un texte qui dénonce sans insulter et propose avec locutions et accords.",
        "Lisez la tribune, sans aller trop vite.",
        "Tribune de Léa Niyonzima, Cahier des racines",
        """Dénoncer et proposer — sans injure (Rukiri-Nord)
Nous nous attaquons au gaspillage, non à Sami. Nous nous attaquons au tampon muet, non à Solange. La personne n'est pas le geste.
Veillons à l'heure écrite. Veillons à ce que Noura soit prévenue. Veiller à + nom ; veiller à ce que + subjonctif.
Cette assemblée aboutira à une motion formelle, à condition que chacun signe. Aboutir à un texte, pas à un cri.
Tout dépend encore de la rivière, du minibus, de notre mémoire. On ne dit pas dépendre à.
Les mesures que nous avons prises (créneau, panier, file) restent fragiles. Les lanternes que nous avons éteintes trop tard ont marqué l'eau.
La pause que nous avons demandée n'a pas encore été tenue. Les voix que Lila a relues à l'antenne n'étaient pas un slogan.
Les clés que Karim a rendues ne circulent plus. La plage que Félicie a réservée tiendra, pourvu que l'heure rentre au cahier.
Je dénonce le tout ou rien. Je propose une demi-heure de plus à l'eau, une fin d'heure au tambour, une affiche plus basse.
Les recommandations que vous avez formulées, je les reprends : on pourrait, il faudrait, j'aurais dû — et maintenant un geste.
Aline : COD avant + avoir → accord. Les mesures que nous avons prises. Sans COD avant : nous avons pris des mesures (pas d'accord).
Patrick : s'attaquer à, veiller à, aboutir à, dépendre de. Quatre liens, un seul enjeu à la fois.
Seuil des Sources — dénoncer un geste, proposer une règle, accorder ce que l'on a déjà fait.""",
        tf_item=(
            "Léa s'attaque à Solange en personne, non au tampon muet.",
            False,
            "« au tampon muet, non à Solange. »",
        ),
        qcm_item=(
            "Quand n'accorde-t-on pas le participe avec avoir, d'après Aline ?",
            [
                "Toujours, jamais d'accord",
                "Quand le COD est après : nous avons pris des mesures",
                "Quand le sujet est féminin seulement",
                "Quand on emploie veiller à",
            ],
            1,
            "Sans COD avant, pas d'accord : pris.",
        ),
        pairs=[
            ("s'attaquer à", "gaspillage / tampon muet"),
            ("veiller à ce que", "Noura prévenue"),
            ("aboutir à", "motion formelle"),
            ("les mesures que nous avons prises", "COD avant"),
        ],
        fill_item=("Les lanternes que nous avons ___ trop tard ont marqué l'eau. (éteindre)", "éteintes"),
        words=["Tout", "dépend", "encore", "de", "la", "rivière", "."],
        anagram=("denoncer", "Nommer le geste nuisible, sans insulter la personne. (sans accent)"),
        error=(
            "Les lanternes que nous avons eteint trop tard ont marqué l'eau, et le panier attend encore.",
            "Les lanternes que nous avons éteintes trop tard ont marqué l'eau, et le panier attend encore.",
            "Lanternes, COD avant, féminin pluriel → éteintes.",
        ),
        pic_start=16,
        pic_words=_pw(16),
        short_p="Recopiez la tribune ; encadrez les locutions et les participes accordés.",
        audio="Lisez la tribune de Léa, sans aller trop vite.",
    ),
    _l(
        "PO",
        "PO — Dire s'attaquer à, les mesures que…",
        "Dénoncer et proposer à l'oral avec les locutions, et accorder le PP du COD avant.",
        "Répétez, puis dénoncez un geste et proposez une règle, avec un accord audible.",
        "Modèles de Marc, Léa et Aline",
        """Nous nous attaquons au gaspillage, non aux personnes.
Veillons à l'heure écrite.
Veillons à ce que Noura soit prévenue.
Cette assemblée aboutira à une motion.
Tout dépend encore de la rivière.
Les mesures que nous avons prises restent fragiles.
Les lanternes que nous avons éteintes iront au panier.
La file que Solange a tamponnée n'est pas une rumeur.
Les voix que j'ai entendues n'étaient pas un cri.
Les clés que nous avons rendues ne circulent plus.
La pause que nous avons demandée n'est pas un caprice.
Nous avons pris des mesures : pas d'accord, COD après.
Aline : entendre le e, le s, le es du participe, c'est déjà soigner le fait.
Patrick : dépendre de, pas dépendre à. Aboutir à, pas aboutir de.""",
        tf_item=(
            "« Nous avons pris des mesures » n'accorde pas le participe, car le COD est après.",
            True,
            "COD après → pris. COD avant → prises.",
        ),
        qcm_item=(
            "Quelle phrase est correcte ?",
            [
                "Nous dépendons à la rivière",
                "Nous aboutissons de une motion",
                "Les mesures que nous avons prises restent fragiles",
                "Nous nous attaquons de le gaspillage",
            ],
            2,
            "S'attaquer à ; aboutir à ; dépendre de ; prises, COD avant.",
        ),
        pairs=[
            ("s'attaquer à", "un geste, pas une personne"),
            ("veiller à / à ce que", "nom / subjonctif"),
            ("aboutir à / dépendre de", "résultat / source"),
            ("COD avant", "accord du PP"),
        ],
        fill_item=("Nous dépendons encore ___ la rivière.", "de"),
        words=["La", "file", "que", "Solange", "a", "tamponnée", "n'est", "pas", "une", "rumeur", "."],
        anagram=("accorder", "Faire porter au participe le genre et le nombre du COD placé avant."),
        error=(
            "Nous dépendons à la rivière encore cette semaine, et les mesures que nous avons prises restent fragiles.",
            "Nous dépendons de la rivière encore cette semaine, et les mesures que nous avons prises restent fragiles.",
            "Dépendre de, pas dépendre à.",
        ),
        pic_start=17,
        pic_words=_pw(17),
        short_p="Écrivez huit phrases : quatre locutions, quatre accords COD avant.",
        audio="Enregistrez les six premiers modèles, puis une dénonciation et une proposition à vous.",
    ),
    _l(
        "PE",
        "PE — Ma tribune : dénoncer et proposer",
        "Écrire une tribune qui dénonce un geste, propose une règle, accorde les participes.",
        "Imitez la tribune de Patrick Habimana, sans aller trop vite.",
        "Tribune de Patrick, encre du jeudi",
        """Patrick Habimana — dénoncer le geste, proposer la règle
Nous nous attaquons à l'huile laissée au bord de l'eau, non à ceux qui ont fêté.
Nous nous attaquons au tampon muet, non à Solange.
Veillons à l'affiche basse.
Veillons à ce que ceux du minibus soient inscrits.
Cette page aboutira à une motion, à condition que quiconque signe encore.
Tout dépend de la rivière, du pont, de notre mémoire : je ne dépends pas d'un cri.
Les mesures que nous avons prises — créneau, panier, file — restent fragiles.
Les lanternes que nous avons éteintes trop tard ont marqué l'eau, et je le nomme.
La pause que nous avons demandée n'a pas encore été tenue.
Les voix que Lila a relues n'étaient pas un slogan.
Les clés que Karim a rendues ne circulent plus.
Je dénonce le tout ou rien.
Je propose une demi-heure pour Noura, une fin d'heure pour Sami, une trace pour la clé.
Les recommandations que vous avez formulées, je les reprends, et j'aurais dû les dire plus tôt.
Pour que la cour évolue, il faut que ce que nous avons écrit soit aussi ce que nous faisons.""",
        tf_item=(
            "Patrick s'attaque à Solange en personne plutôt qu'au tampon muet.",
            False,
            "« au tampon muet, non à Solange. »",
        ),
        qcm_item=(
            "De quoi dépend encore la page de Patrick ?",
            [
                "D'un cri seulement",
                "De la rivière, du pont, de la mémoire",
                "D'un parti d'ailleurs",
                "D'une pierre sous le figuier",
            ],
            1,
            "« Tout dépend de la rivière, du pont, de notre mémoire. »",
        ),
        pairs=[
            ("s'attaquer à", "huile / tampon muet"),
            ("veiller à ce que", "minibus inscrit"),
            ("aboutir à", "motion"),
            ("mesures prises / lanternes éteintes", "accord COD avant"),
        ],
        fill_item=("Les clés que Karim a ___ ne circulent plus. (rendre)", "rendues"),
        words=["Je", "dénonce", "le", "tout", "ou", "rien", "."],
        anagram=("proposer", "Après avoir nommé le geste : avancer une règle, une demi-heure, une trace."),
        error=(
            "Les voix que Lila a relu n'étaient pas un slogan, et les clés que Karim a rendues ne circulent plus.",
            "Les voix que Lila a relues n'étaient pas un slogan, et les clés que Karim a rendues ne circulent plus.",
            "Voix, COD avant, féminin pluriel → relues.",
        ),
        pic_start=18,
        pic_words=_pw(18),
        short_p="Imitez : quinze lignes, quatre locutions, quatre accords COD avant, une dénonciation, une proposition.",
        audio="Lisez votre tribune, une phrase, une pause, sans aller trop vite.",
    ),
    _l(
        "EL",
        "EL — Locutions et accord du participe",
        "Retenir s'attaquer à, veiller à, aboutir à, dépendre de, et l'accord du PP avec COD avant.",
        "Apprenez la fiche.",
        "Fiche d'Aline, locutions et accords",
        """Locutions / verbes prépositionnels
s'attaquer à + nom (un geste, un problème, pas d'abord une personne)
veiller à + nom ; veiller à ce que + subjonctif
aboutir à + résultat (une motion, une file, une règle)
dépendre de + source (l'eau, le tampon, la mémoire) — pas dépendre à
Accord du participe passé avec avoir
COD avant le verbe → accord avec le COD :
les mesures que nous avons prises ; la file que j'ai tamponnée ; les lanternes que vous avez éteintes
les voix que Lila a relues ; les clés que nous avons rendues ; la pause que nous avons demandée
COD après → pas d'accord : nous avons pris des mesures ; Solange a tamponné une file
Être + PP (passif, déjà vu) : accord avec le sujet. Ici, le projecteur est le COD avant.
On ne dit pas : les mesures que nous avons pris (oubli de l'accord).
On ne dit pas : s'attaquer de / veiller de / aboutir de / dépendre à.
Dénoncer le geste, proposer la règle : deux mouvements, un seul ton calme.
À + le = au gaspillage, au Bureau. De + le = du pont, du minibus.""",
        tf_item=(
            "On dit « nous dépendons à la rivière ».",
            False,
            "Dépendre de, jamais dépendre à.",
        ),
        qcm_item=(
            "« Solange a tamponné une file » : pourquoi pas d'accord ?",
            [
                "Parce que Solange est un prénom",
                "Parce que le COD une file est après le verbe",
                "Parce que tamponner n'a jamais de participe",
                "Parce que c'est un subjonctif",
            ],
            1,
            "COD après → tamponné, invariable ici.",
        ),
        pairs=[
            ("s'attaquer à", "un geste"),
            ("veiller à ce que", "subjonctif"),
            ("aboutir à / dépendre de", "résultat / source"),
            ("COD avant", "prises / éteintes / relues"),
        ],
        fill_item=("Nous avons ___ des mesures dès l'aube. (prendre, COD après)", "pris"),
        words=["Veillons", "à", "ce", "que", "Noura", "soit", "prévenue", "."],
        anagram=("locution", "Groupe figé : s'attaquer à, veiller à, aboutir à, dépendre de."),
        error=(
            "Nous nous attaquons de le gaspillage depuis jeudi, et les mesures que nous avons prises restent fragiles.",
            "Nous nous attaquons au gaspillage depuis jeudi, et les mesures que nous avons prises restent fragiles.",
            "S'attaquer à (+ au devant le).",
        ),
        pic_start=19,
        pic_words=_pw(19),
        short_p="Transformez six phrases (COD après → COD avant) et accordez le participe.",
        audio="Enregistrez la fiche et six accords : prises, tamponnée, éteintes, relues, rendues, demandée.",
    ),
]


# ---------------------------------------------------------------------------
# Séquence 5 — Assemblée sous le figuier (EXTRA)
# ---------------------------------------------------------------------------

S5 = [
    _l(
        "CO",
        "CO — La cour se réunit pour évoluer",
        "Réemployer conditions, recommandations, indéfinis et locutions dans le débat d'assemblée.",
        "Lisez le dialogue. Quelles conditions, quels regrets et quelles propositions s'entendent ?",
        "Assemblée sous le figuier, urne inventée",
        """Aline : Si chacun s'exprime, à condition que l'on ne crie pas, cette assemblée aboutira à une motion.
Solange : Quiconque a signé peut parler. En cas de débordement, je lève le tampon, je ne lève pas la voix.
Hawa : On pourrait ouvrir une demi-heure, pourvu que l'aube tienne. J'aurais dû le dire dès la première soif du pont.
Sami : J'aurais dû cesser plus tôt. Je veillerai à l'heure, à moins que l'orage n'interrompe la veillée.
Rose : Nous nous attaquons à l'huile, non aux fêtards. Les mesures que nous avons prises tiennent, si le panier est là.
Noura : Certains n'ont pas été inscrits. Il faudrait que toutes les voix du minibus le soient, plutôt qu'on décide sans nous.
Léa : Plusieurs ont déjà porté. Tout geste compte. Cette page aboutira à un texte formel, demain, au Bureau.
Patrick : Les lanternes que nous avons éteintes trop tard, je les nomme encore. Nous n'aurions pas dû attendre douze restes.
Marc : Que ce soit l'eau ou la salle, chaque article de la motion restera distinct. Nuancer n'est pas tout égaliser.
Joël : En cas de désaccord, on vote. On ne dépend pas d'un chef inventé.
Lila : Je lirai ce qui aura été dit, sans slogan. Veillons à ce que le chiffre reste visible : vingt voix, trois seaux, douze lanternes.
Yvette : N'importe quel enfant doit comprendre l'affiche. Vous feriez mieux de la recoller ce soir.
Karim : Les clés que nous avons rendues restent au tiroir. Quiconque en trouve une la ramène.
Dieudonné : Pourvu que la rivière ne baisse, le bilan que nous avons dressé tiendra jusqu'à jeudi.
Mado : Dénoncer, recommander, conditionner, signer : c'est déjà faire évoluer la cour.""",
        tf_item=(
            "Rose s'attaque aux personnes qui ont fêté, non à l'huile.",
            False,
            "« Nous nous attaquons à l'huile, non aux fêtards. »",
        ),
        qcm_item=(
            "Que fera Solange en cas de débordement ?",
            [
                "Crier plus fort",
                "Lever le tampon, non la voix",
                "Fermer la rivière",
                "Annuler toutes les signatures",
            ],
            1,
            "« je lève le tampon, je ne lève pas la voix. »",
        ),
        pairs=[
            ("si / à condition que / pourvu que / en cas de", "conditions"),
            ("on pourrait / j'aurais dû / il faudrait", "recommandation et regret"),
            ("quiconque / chacun / certains / plusieurs / tout", "indéfinis"),
            ("s'attaquer à / aboutir à / veiller à", "locutions"),
        ],
        fill_item=("Les mesures que nous avons ___ tiennent si le panier est là.", "prises"),
        words=["Quiconque", "a", "signé", "peut", "parler", "."],
        anagram=("assemblee", "Réunion sous le figuier, sans accent, pour aboutir à une motion."),
        error=(
            "Les mesures que nous avons pris tiennent encore, et quiconque a signé peut parler.",
            "Les mesures que nous avons prises tiennent encore, et quiconque a signé peut parler.",
            "Mesures, COD avant → prises.",
        ),
        pic_start=20,
        pic_words=_pw(20),
        short_p="Notez une condition, une recommandation, un indéfini et une locution par enjeu.",
        audio="Enregistrez : Si chacun s'exprime, cette assemblée aboutira à une motion. Quiconque a signé peut parler. J'aurais dû le dire plus tôt.",
    ),
    _l(
        "CE",
        "CE — Procès-verbal de l'assemblée",
        "Lire le procès-verbal qui relie bilan conditionnel, regrets, indéfinis et propositions.",
        "Lisez le procès-verbal, sans aller trop vite.",
        "Procès-verbal d'Aline, Cahier des racines",
        """Assemblée sous le figuier — procès-verbal (Rukiri-Nord)
Ouverture. Quiconque avait signé a pu parler.
Chacun a eu la parole une fois.
En cas de débordement, Solange a levé le tampon, non la voix.
Eau. On pourrait ouvrir une demi-heure, à condition que l'aube tienne, pourvu que Noura soit prévenue.
Hawa : j'aurais dû le proposer plus tôt.
À moins que la rivière ne baisse, pas de second créneau. En cas de pénurie, une file.
Heures calmes. Sami : j'aurais dû cesser plus tôt. Il veillera à l'heure.
Rose ne s'attaque pas aux fêtards ; elle s'attaque à l'huile du dernier morceau trop long.
Lanternes. Les mesures que nous avons prises tiennent si le panier est là.
Les lanternes que nous avons éteintes trop tard ont été nommées.
Plusieurs ont déjà porté jusqu'au compost. Tout geste compte.
Salle. Certains n'étaient pas inscrits. Il faudrait que toutes les voix du minibus le soient.
Les clés que nous avons rendues restent au tiroir. Quiconque en trouve une la ramène.
Méthode. Que ce soit l'eau ou la salle, chaque article restera distinct.
Cette assemblée aboutira à une motion formelle au Bureau des Escales.
Nous ne dépendons pas d'un chef. Nous dépendons de l'eau, de la mémoire, des signatures.
Lila lira le chiffre : vingt voix, trois seaux, douze lanternes.""",
        tf_item=(
            "Le procès-verbal dit que la cour dépend d'un chef inventé.",
            False,
            "« Nous ne dépendons pas d'un chef. »",
        ),
        qcm_item=(
            "Quel chiffre Lila doit-elle lire ?",
            [
                "Un seul seau, zéro voix",
                "Vingt voix, trois seaux, douze lanternes",
                "Cent lanternes seulement",
                "Aucune signature",
            ],
            1,
            "Vingt / trois / douze.",
        ),
        pairs=[
            ("demi-heure / file", "eau"),
            ("j'aurais dû cesser", "Sami"),
            ("panier / compost", "lanternes"),
            ("voix du minibus / clés rendues", "salle"),
        ],
        fill_item=("Cette assemblée aboutira ___ une motion formelle.", "à"),
        words=["Nous", "ne", "dépendons", "pas", "d'un", "chef", "."],
        anagram=("verbal", "Procès-… : mémoire écrite de ce qui a été dit sous le figuier."),
        error=(
            "Cette assemblée aboutira à une motion formelle, et nous ne dépendons pas à un chef inventé.",
            "Cette assemblée aboutira à une motion formelle, et nous ne dépendons pas d'un chef inventé.",
            "Dépendre de, pas dépendre à.",
        ),
        pic_start=21,
        pic_words=_pw(21),
        short_p="Recopiez le PV et marquez C (condition), R (regret), I (indéfini), L (locution).",
        audio="Lisez le procès-verbal, sans aller trop vite.",
    ),
    _l(
        "PO",
        "PO — Dire le débat de l'assemblée",
        "Prendre la parole à l'assemblée en réemployant les outils des séquences 1 à 4.",
        "Répétez, puis prenez la parole une minute : condition, recommandation, indéfini, locution.",
        "Modèles d'assemblée, Aline et Marc",
        """Si chacun s'exprime, nous aboutirons à une motion.
À condition que l'on ne crie pas, Solange gardera le tampon baissé.
Quiconque a signé peut parler.
On pourrait ouvrir une demi-heure, pourvu que l'aube tienne.
J'aurais dû le dire plus tôt.
Nous nous attaquons à l'huile, non aux personnes.
Les mesures que nous avons prises tiennent encore.
Certains n'ont pas été inscrits ; il faudrait qu'ils le soient.
Plusieurs ont déjà porté ; tout geste compte.
En cas de désaccord, on vote.
Nous ne dépendons pas d'un chef.
Veillons à ce que le chiffre reste visible.
Aline : une prise de parole tient quatre outils, pas un cri.
Marc : dénoncer le geste, proposer l'article, conditionner la suite.""",
        tf_item=(
            "Les modèles autorisent à dépendre d'un chef inventé.",
            False,
            "« Nous ne dépendons pas d'un chef. »",
        ),
        qcm_item=(
            "Quelle phrase mêle indéfini et permission de parler ?",
            [
                "Fermez le figuier",
                "Quiconque a signé peut parler",
                "Je faut crier",
                "On dépend à un chef",
            ],
            1,
            "Quiconque + 3e pers. + permission.",
        ),
        pairs=[
            ("si / à condition que / pourvu que", "conditions"),
            ("on pourrait / j'aurais dû", "atténuation / regret"),
            ("quiconque / certains / plusieurs", "indéfinis"),
            ("s'attaquer à / veiller à / aboutir à", "locutions"),
        ],
        fill_item=("Veillons à ce que le chiffre ___ visible. (rester)", "reste"),
        words=["Nous", "nous", "attaquons", "à", "l'huile", "non", "aux", "personnes", "."],
        anagram=("debattre", "Parler sous le figuier, sans accent, pour aboutir à un article."),
        error=(
            "Quiconque a signé peut parler sous le figuier, et certains n'a pas encore été inscrits.",
            "Quiconque a signé peut parler sous le figuier, et certains n'ont pas encore été inscrits.",
            "Certains + pluriel : n'ont, pas n'a.",
        ),
        pic_start=22,
        pic_words=_pw(22),
        short_p="Écrivez une prise de parole de douze phrases : trois conditions, deux regrets, trois indéfinis, quatre locutions.",
        audio="Enregistrez les six premiers modèles, puis votre minute d'assemblée.",
    ),
    _l(
        "PE",
        "PE — Ma prise de parole sous le figuier",
        "Écrire une intervention d'assemblée qui réemploie les outils des quatre séquences.",
        "Imitez l'intervention de Noura, sans aller trop vite.",
        "Intervention de Noura, assemblée",
        """Noura — prise de parole, assemblée sous le figuier
Si chacun s'exprime, à condition que l'on ne me parle pas par-dessus, je dirai le pont.
Quiconque descend du Figuier 7 a le droit d'être inscrit.
On pourrait ouvrir une demi-heure, pourvu que Hawa tienne l'aube.
J'aurais dû le demander dès la première soif, et Solange aurait dû tamponner une file plus tôt.
À moins que la rivière ne baisse, je n'exige pas un second créneau.
En cas de pénurie, que l'on tamponne une file, non une rumeur.
Nous nous attaquons au tampon muet, non à Solange.
Veillons à ce que l'heure soit dite à la radio.
Cette assemblée aboutira à une motion, si chacun signe encore.
Les mesures que nous avons prises restent fragiles tant que certaines voix du pont n'ont pas été inscrites.
Il faudrait que toutes le soient, plutôt qu'on décide sans nous.
Plusieurs ont déjà porté l'huile. Tout geste compte.
Les clés que nous avons rendues doivent rester au tiroir : quiconque en trouve une la ramène.
Je ne dépends pas d'un chef.
Je dépends de l'eau, du minibus, de votre mémoire.
Que ce soit l'eau ou la salle, chaque article restera distinct.""",
        tf_item=(
            "Noura exige un second créneau dès cette semaine, quoi qu'il arrive à la rivière.",
            False,
            "À moins que la rivière ne baisse, elle n'exige pas un second créneau.",
        ),
        qcm_item=(
            "À quoi Noura dit-elle que l'assemblée s'attaque ?",
            [
                "À Solange en personne",
                "Au tampon muet, non à Solange",
                "Au figuier",
                "Au minibus",
            ],
            1,
            "« au tampon muet, non à Solange. »",
        ),
        pairs=[
            ("si / à condition que / pourvu que / en cas de", "conditions"),
            ("on pourrait / j'aurais dû", "recommandation / regret"),
            ("quiconque / certaines / plusieurs / tout", "indéfinis"),
            ("s'attaquer à / veiller à / aboutir à / dépendre de", "locutions"),
        ],
        fill_item=("Les mesures que nous avons ___ restent fragiles.", "prises"),
        words=["Je", "ne", "dépends", "pas", "d'un", "chef", "."],
        anagram=("intervention", "Prise de parole sous le figuier, avant la motion du Bureau."),
        error=(
            "Nous nous attaquons au tampon muet non à Solange, et je dépends encore à votre mémoire.",
            "Nous nous attaquons au tampon muet non à Solange, et je dépends encore de votre mémoire.",
            "Dépendre de, pas dépendre à.",
        ),
        pic_start=23,
        pic_words=_pw(23),
        short_p="Imitez : seize lignes d'assemblée, conditions, regrets, indéfinis, locutions, un accord COD avant.",
        audio="Lisez votre intervention, une phrase, une pause, sans aller trop vite.",
    ),
    _l(
        "EL",
        "EL — Synthèse d'assemblée : quatre boîtes à outils",
        "Relier condition, conditionnel, indéfinis et locutions pour une prise de parole.",
        "Apprenez la fiche.",
        "Fiche de synthèse sous le figuier",
        """Boîte 1 — condition (S1)
si + indicatif / imparfait ; à condition que / pourvu que / à moins que + subj. ; en cas de + nom
Boîte 2 — conscience (S2)
on pourrait, il faudrait, je suggérerais ; j'aurais dû, nous n'aurions pas dû, il aurait fallu
Boîte 3 — indéfinis (S3)
quiconque (+ singulier) ; chacun / chacune ; n'importe quel + nom ; certains ; plusieurs ; tout / tous
Boîte 4 — dénoncer / proposer (S4)
s'attaquer à (le geste) ; veiller à / à ce que ; aboutir à ; dépendre de
Accord : les mesures que nous avons prises ; les lanternes que nous avons éteintes
Que ce soit l'eau ou la salle, chaque article reste distinct. Nuancer ≠ tout égaliser.
On ne dépend pas d'un chef. On aboutit à une motion, pourvu que chacun signe.
Dû invariable devant l'infinitif. Quiconque signe, pas quiconque signent.
Il faut (pas je faut). À + le = au Bureau, au figuier.
Une assemblée tient si les quatre boîtes restent visibles dans la même voix.
Demain : le texte formel au Bureau des Escales.""",
        tf_item=(
            "La fiche autorise « je faut » à l'assemblée.",
            False,
            "Toujours il faut.",
        ),
        qcm_item=(
            "Quelle locution introduit le résultat attendu de l'assemblée ?",
            [
                "dépendre à",
                "aboutir à une motion",
                "s'attaquer de",
                "veiller de",
            ],
            1,
            "Aboutir à + résultat.",
        ),
        pairs=[
            ("si / pourvu que / en cas de", "condition"),
            ("on pourrait / j'aurais dû", "conseil / regret"),
            ("quiconque / chacun / plusieurs", "indéfinis"),
            ("s'attaquer à / aboutir à", "geste / résultat"),
        ],
        fill_item=("Cette assemblée aboutira ___ une motion, pourvu que chacun signe.", "à"),
        words=["Quiconque", "signe", "peut", "parler", "sous", "le", "figuier", "."],
        anagram=("boites", "Quatre ensembles d'outils pour une même voix. (sans accent)"),
        error=(
            "Quiconque signent encore peut parler, et nous aboutirons à une motion demain.",
            "Quiconque signe encore peut parler, et nous aboutirons à une motion demain.",
            "Quiconque + 3e pers. singulier : signe.",
        ),
        pic_start=24,
        pic_words=_pw(24),
        short_p="Tableau à quatre boîtes : deux phrases modèles dans chacune, prêtes pour l'assemblée.",
        audio="Enregistrez la fiche et une prise de parole de huit phrases, deux par boîte.",
    ),
]


# ---------------------------------------------------------------------------
# Séquence 6 — Motion au Bureau des Escales (EXTRA, texte formel)
# ---------------------------------------------------------------------------

S6 = [
    _l(
        "CO",
        "CO — Préparer le texte formel",
        "Comprendre les formules d'une motion de cour destinée au Bureau des Escales.",
        "Lisez le dialogue. Quelles formules formelles entend-on, et que doit contenir la motion ?",
        "Seuil du Bureau des Escales, plume et tampon",
        """Solange : Une motion formelle n'est pas un cri. Elle s'adresse au Bureau, elle date, elle article, elle signe.
Aline : On écrira : « Le Seuil des Sources, réuni en assemblée sous le figuier, demande que… » Demander que + subjonctif.
Marc : Chaque article commencera par un verbe d'action : ouvrir, cesser, déposer, inscrire, tamponner.
Rose : Il faut s'attaquer aux gestes, non aux noms. Article 1 : l'eau. Article 2 : le soir. Article 3 : les lanternes. Article 4 : la salle.
Hawa : On posera les conditions : à condition que l'aube tienne ; pourvu que Noura soit prévenue ; en cas de pénurie, une file.
Léa : Les mesures que nous avons prises seront rappelées au passé, accordées : prises, éteintes, rendues, tamponnée.
Patrick : Formules : Vu l'enquête ; considérant que vingt voix ont été entendues ; demandons qu'il soit décidé…
Karim : Clôture : « Fait au Seuil des Sources, Rukiri-Nord. » Puis les signatures. Quiconque a parlé peut signer.
Lila : On pourrait atténuer l'article 2 : « il est recommandé que le tambour cesse », plutôt qu'une interdiction sèche.
Joël : À moins que Solange n'exige un article de trop, quatre articles suffisent. Nuancer, ce n'est pas tout fondre.
Yvette : Veuillez agréer, au Bureau, cette motion. Ce n'est pas une lettre d'amour ; c'est une politesse de cour.
Noura : Je veillerai à ce que le minibus apparaisse dans l'article 4. J'aurais dû le demander plus tôt, je le demande aujourd'hui.
Dieudonné : En cas de rejet, on reconvoque. On ne dépend pas d'un silence.
Mado : Titre : Motion n°15 — faire évoluer la cour. Numéro suivant la n°14 des lanternes.
Aline : Formel : vu, considérant, demande que, article, fait à, signatures. Calme : pas de parti, pas de sceau d'État.""",
        tf_item=(
            "Solange dit qu'une motion formelle peut se contenter d'un cri.",
            False,
            "« Une motion formelle n'est pas un cri. »",
        ),
        qcm_item=(
            "Combien d'articles Rose veut-elle, et sur quels enjeux ?",
            [
                "Un seul article sur le tambour",
                "Quatre articles : eau, soir, lanternes, salle",
                "Dix articles sur un parti",
                "Aucun article, seulement un slogan",
            ],
            1,
            "Eau, soir, lanternes, salle.",
        ),
        pairs=[
            ("vu / considérant / demande que", "formules"),
            ("article 1 à 4", "eau / soir / lanternes / salle"),
            ("fait au Seuil", "clôture"),
            ("quiconque a parlé", "peut signer"),
        ],
        fill_item=("Le Seuil demande que l'heure ___ dite à la radio. (être)", "soit"),
        words=["Une", "motion", "formelle", "n'est", "pas", "un", "cri", "."],
        anagram=("formules", "Vu, considérant, demande que, fait à : ossature du texte officiel."),
        error=(
            "Le Seuil demande que l'heure soit dite à la radio, et quiconque a parlé peuvent signer demain.",
            "Le Seuil demande que l'heure soit dite à la radio, et quiconque a parlé peut signer demain.",
            "Quiconque + 3e pers. singulier : peut, pas peuvent.",
        ),
        pic_start=25,
        pic_words=_pw(25),
        short_p="Notez six formules formelles et les quatre articles prévus.",
        audio="Enregistrez : Le Seuil des Sources, réuni en assemblée, demande que l'heure soit dite. Fait au Seuil des Sources, Rukiri-Nord.",
    ),
    _l(
        "CE",
        "CE — Motion-modèle n°15",
        "Lire une motion formelle qui articule conditions, recommandations et mesures déjà prises.",
        "Lisez la motion, sans aller trop vite.",
        "Motion n°15, Bureau des Escales",
        """Motion n°15 — Faire évoluer la cour
Vu l'enquête menée à Rukiri-Nord, considérant que vingt voix ont été entendues, considérant les mesures que nous avons prises,
le Seuil des Sources, réuni en assemblée sous le figuier, demande :
Article 1 — Eau. Qu'une demi-heure supplémentaire soit ouverte, à condition que l'aube tienne, pourvu que ceux du minibus soient prévenus. En cas de pénurie, qu'une file soit tamponnée, non une rumeur. À moins que la rivière ne baisse, pas de second créneau.
Article 2 — Heures calmes. Qu'il soit recommandé que le dernier morceau cesse à vingt et une heures. On pourrait garder la veillée. Personne n'exige que le rite disparaisse.
Article 3 — Lanternes. Que les restes soient déposés dans le panier ocre. Les lanternes que nous avons éteintes trop tard ont marqué l'eau ; nous nous attaquons à l'huile, non aux personnes.
Article 4 — Salle des Herbes. Que quiconque utile puisse inscrire une plage. Que les clés que nous avons rendues restent au tiroir. Veillons à ce que n'importe quel enfant lise l'affiche.
Il aurait fallu certaines de ces lignes plus tôt. Nous les demandons aujourd'hui, afin que la cour évolue.
Fait au Seuil des Sources, Rukiri-Nord.
Signatures : quiconque a parlé à l'assemblée. Tampon : Solange, Bureau des Escales.
Cette motion n'est pas un décret d'État. C'est un texte de cour, formel et calme.
Copie : Cahier des racines, Radio Figuier.""",
        tf_item=(
            "L'article 2 exige que la veillée disparaisse.",
            False,
            "« Personne n'exige que le rite disparaisse. » On pourrait garder la veillée.",
        ),
        qcm_item=(
            "Que prévoit l'article 1 en cas de pénurie ?",
            [
                "Un second créneau immédiat",
                "Une file tamponnée, non une rumeur",
                "La fermeture du figuier",
                "Un sceau d'État",
            ],
            1,
            "File tamponnée, pas de rumeur.",
        ),
        pairs=[
            ("article 1", "demi-heure / file"),
            ("article 2", "recommandation d'heure"),
            ("article 3", "panier / huile"),
            ("article 4", "plage / clés / affiche"),
        ],
        fill_item=("Le Seuil demande qu'une demi-heure supplémentaire ___ ouverte. (être)", "soit"),
        words=["Fait", "au", "Seuil", "des", "Sources", "Rukiri-Nord", "."],
        anagram=("articles", "Quatre parties de la motion : eau, soir, lanternes, salle."),
        error=(
            "Le Seuil demande qu'une demi-heure soit ouverte, et les lanternes que nous avons eteint iront au panier.",
            "Le Seuil demande qu'une demi-heure soit ouverte, et les lanternes que nous avons éteintes iront au panier.",
            "Lanternes, COD avant → éteintes.",
        ),
        pic_start=26,
        pic_words=_pw(26),
        short_p="Recopiez la motion et soulignez formules, conditions, accords et indéfinis.",
        audio="Lisez la motion-modèle, sans aller trop vite.",
    ),
    _l(
        "PO",
        "PO — Dire les formules de la motion",
        "Prononcer à l'oral les formules formelles et les quatre articles.",
        "Répétez, puis dictez un article formel sur l'enjeu de votre choix.",
        "Modèles de Solange et d'Aline",
        """Vu l'enquête menée à Rukiri-Nord,
considérant que vingt voix ont été entendues,
le Seuil des Sources demande que l'heure soit dite.
Article 1 : qu'une demi-heure soit ouverte, à condition que l'aube tienne.
Article 2 : qu'il soit recommandé que le tambour cesse.
Article 3 : que les restes soient déposés dans le panier.
Article 4 : que quiconque utile puisse inscrire une plage.
Fait au Seuil des Sources, Rukiri-Nord.
Veuillez agréer cette motion, au Bureau des Escales.
Nous nous attaquons aux gestes, non aux noms.
Les mesures que nous avons prises sont rappelées.
Quiconque a parlé peut signer.
Aline : le formel n'est pas froid ; il protège la cour d'un cri.
Solange : un tampon suit une signature, il ne la remplace pas.""",
        tf_item=(
            "La clôture « Fait au Seuil des Sources » date et situe le texte.",
            True,
            "Formule de clôture de cour.",
        ),
        qcm_item=(
            "Quelle ouverture est formelle ?",
            [
                "Salut les amis on crie",
                "Vu l'enquête menée à Rukiri-Nord",
                "Je faut un tampon",
                "Pas de titre",
            ],
            1,
            "Vu + considérant + demande que.",
        ),
        pairs=[
            ("vu / considérant", "ouverture"),
            ("demande que / qu'il soit", "articles au subj."),
            ("fait au Seuil", "clôture"),
            ("veuillez agréer", "politesse de Bureau"),
        ],
        fill_item=("Veuillez ___ cette motion au Bureau. (agréer)", "agréer"),
        words=["Fait", "au", "Seuil", "des", "Sources", "."],
        anagram=("tamponner", "Marquer la motion au Bureau, après les signatures, sans crier."),
        error=(
            "Le Seuil demande que l'heure est dite demain, et veuillez agréer cette motion au Bureau.",
            "Le Seuil demande que l'heure soit dite demain, et veuillez agréer cette motion au Bureau.",
            "Demander que + subjonctif : soit, pas est.",
        ),
        pic_start=27,
        pic_words=_pw(27),
        short_p="Écrivez les formules d'ouverture et de clôture, puis quatre articles d'une ligne.",
        audio="Enregistrez les formules vu / considérant / demande que / fait au Seuil, puis un article à vous.",
    ),
    _l(
        "PE",
        "PE — Ma motion au Bureau",
        "Écrire une motion formelle de cour, datée, articulée, signée.",
        "Imitez la motion de Marc Nkurunziza, sans aller trop vite.",
        "Motion de Marc, pour Solange",
        """Motion n°15 — Faire évoluer la cour (version Marc)
Vu l'enquête ouverte à Rukiri-Nord, considérant que vingt voix ont été entendues, considérant les mesures que nous avons prises,
le Seuil des Sources, réuni sous le figuier, demande :
Article 1. Qu'une demi-heure soit ouverte à l'eau, à condition que l'aube tienne, pourvu que Noura soit prévenue.
En cas de pénurie, qu'une file soit tamponnée. À moins que la rivière ne baisse, pas de second créneau.
Article 2. Qu'il soit recommandé que le dernier morceau cesse à vingt et une heures.
J'aurais dû l'écrire plus tôt ; je l'écris aujourd'hui. On pourrait garder la veillée.
Article 3. Que les restes soient portés au panier ocre.
Nous nous attaquons à l'huile, non aux personnes.
Les lanternes que nous avons éteintes trop tard ont été nommées.
Article 4. Que quiconque utile inscrive une plage à la Salle des Herbes.
Que les clés que nous avons rendues restent au tiroir.
Veillons à ce que n'importe quel enfant lise l'affiche.
Cette assemblée aboutira à ce texte, si chacun signe.
Nous ne dépendons pas d'un chef ; nous dépendons de l'eau et de la mémoire.
Fait au Seuil des Sources, Rukiri-Nord.
Veuillez agréer, au Bureau des Escales, cette motion de cour.
Elle n'est pas un décret d'État.""",
        tf_item=(
            "Marc présente la motion comme un décret d'État.",
            False,
            "« Elle n'est pas un décret d'État. »",
        ),
        qcm_item=(
            "Que rappelle Marc à l'article 2, au conditionnel passé ?",
            [
                "Qu'il aurait dû l'écrire plus tôt",
                "Qu'il vendra le figuier",
                "Qu'il interdira Hawa",
                "Qu'il cassera le tampon",
            ],
            0,
            "« J'aurais dû l'écrire plus tôt ; je l'écris aujourd'hui. »",
        ),
        pairs=[
            ("vu / considérant", "ouverture"),
            ("articles 1 à 4", "eau / soir / lanternes / salle"),
            ("fait au Seuil", "clôture"),
            ("veuillez agréer", "Bureau des Escales"),
        ],
        fill_item=("Fait ___ Seuil des Sources, Rukiri-Nord.", "au"),
        words=["Veuillez", "agréer", "cette", "motion", "de", "cour", "."],
        anagram=("officielle", "Qualité du texte : daté, articulé, signé, tamponné, sans cri."),
        error=(
            "Le Seuil demande qu'une demi-heure soit ouverte, et les mesures que nous avons pris seront rappelées.",
            "Le Seuil demande qu'une demi-heure soit ouverte, et les mesures que nous avons prises seront rappelées.",
            "Mesures, COD avant → prises.",
        ),
        pic_start=28,
        pic_words=_pw(28),
        short_p="Imitez : motion formelle de seize lignes, vu / considérant / quatre articles / fait à / signatures.",
        audio="Lisez votre motion, une phrase, une pause, sans aller trop vite.",
    ),
    _l(
        "EL",
        "EL — Motion formelle : ossature et réemploi",
        "Retenir l'ossature du texte formel et le réemploi des outils pour faire évoluer la cour.",
        "Apprenez la fiche.",
        "Fiche de Solange, motion au Bureau",
        """Ossature
Titre + numéro (Motion n°15). Vu + fait. Considérant que + indicatif (vingt voix ont été entendues).
Le Seuil demande que / qu'il soit + subjonctif. Articles numérotés, un enjeu chacun.
Fait à + lieu. Signatures. Tampon du Bureau des Escales. Veuillez agréer…
Réemploi
Condition : à condition que, pourvu que, à moins que, en cas de, si.
Atténuation / regret : on pourrait, il est recommandé que, j'aurais dû.
Indéfinis : quiconque, chacun, n'importe quel, certains, plusieurs, tout.
Locutions : s'attaquer à, veiller à ce que, aboutir à, dépendre de.
Accord : les mesures que nous avons prises ; les clés que nous avons rendues.
Formel ≠ froid. Formel ≠ décret d'État. Formel = calme + lisible + signé.
On ne fond pas les quatre articles. On ne crie pas un parti. On ne dit pas je faut.
À + le = au Bureau, au Seuil. De + le = du Cahier des racines.
Faire évoluer la société, ici, c'est faire évoluer la cour : eau, soir, lanternes, salle.
Si chacun signe, pourvu que Solange tamponne, le texte tiendra jusqu'à la prochaine assemblée.""",
        tf_item=(
            "La fiche confond motion de cour et décret d'État.",
            False,
            "Formel ≠ décret d'État. Formel = calme + lisible + signé.",
        ),
        qcm_item=(
            "Quel ordre d'ossature est proposé ?",
            [
                "cri, injure, silence",
                "titre, vu, considérant, demande que, articles, fait à, signatures",
                "signatures d'abord, puis rien",
                "un seul slogan sans article",
            ],
            1,
            "Ossature de la fiche.",
        ),
        pairs=[
            ("vu / considérant", "ouverture"),
            ("demande que + subj.", "corps"),
            ("articles distincts", "quatre enjeux"),
            ("fait à / signatures / tampon", "clôture"),
        ],
        fill_item=("Le Seuil demande qu'il ___ recommandé de cesser à l'heure. (être)", "soit"),
        words=["Fait", "au", "Seuil", "des", "Sources", "."],
        anagram=("ossature", "Squelette du texte formel : vu, articles, fait à, signatures."),
        error=(
            "Le Seuil demande que l'heure soit dite, et nous dépendons encore à un silence du Bureau.",
            "Le Seuil demande que l'heure soit dite, et nous dépendons encore d'un silence du Bureau.",
            "Dépendre de, pas dépendre à.",
        ),
        pic_start=29,
        pic_words=_pw(29),
        short_p="Rédigez l'ossature vide (titre, vu, considérant, quatre articles, fait à) avec une phrase modèle chacune.",
        audio="Enregistrez la fiche et une mini-motion de six phrases formelles.",
    ),
]


SEQUENCES = [
    {"title": "Dresser un bilan", "lessons": S1},
    {"title": "Prise de conscience et recommandations", "lessons": S2},
    {"title": "Action citoyenne", "lessons": S3},
    {"title": "Dénoncer et proposer", "lessons": S4},
    {"title": "Assemblée sous le figuier", "lessons": S5},
    {"title": "Motion au Bureau des Escales", "lessons": S6},
]
