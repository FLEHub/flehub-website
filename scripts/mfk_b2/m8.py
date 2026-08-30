"""B2 Module 8 — Modèles éducatifs (univers Seuil des Sources)."""

from factory import L

IMG = "mfk-b2-m8"
IMG_DIR = IMG

MODULE = {
    "title": "B2 — Modèles éducatifs",
    "description": (
        "Grande étape B2-8 : formuler un objectif, commenter des résultats, "
        "discuter l'utilité d'un tampon de cour, comparer deux modèles, "
        "lire le bilan d'Aline et signer un manifeste — l'Atelier d'Aline "
        "et l'école de la cour s'inventent sous le figuier, le Cahier du "
        "chemin tient lieu de journal, au Seuil des Sources (Rukiri-Nord)."
    ),
}


def _l(comp, title, obj, cons, st, sp, **kw):
    return L(IMG, comp, title, obj, cons, st, sp, **kw)


# ---------------------------------------------------------------------------
# Séquence 1 — Objectifs et expériences novatrices
# ---------------------------------------------------------------------------

S1 = [
    _l(
        "CO",
        "CO — Un atelier qui puisse tenir",
        "Repérer les relatives de souhait ou de but (qui puisse, afin que) et le subjonctif de l'opinion.",
        "Lisez le dialogue. Quels objectifs Aline pose-t-elle, et comment doute-t-elle ?",
        "Atelier d'Aline, pupitre sous le figuier",
        """Aline : Je cherche un atelier qui puisse tenir sans titre d'ailleurs, afin que chacun ose une page.
Patrick : Je ne pense pas que le Cahier du chemin soit un diplôme ; il est essentiel que ce soit un journal.
Léa : Il est essentiel que Joël trouve un relais qui puisse durer trois minutes, afin que l'oreille se repose.
Marc : Je ne pense pas qu'une expérience novatrice consiste à crier plus fort ; elle consiste à oser un geste.
Dieudonné : Un coupon qui puisse se tendre sans se déchirer, afin que l'apprenti voie un geste fini.
Lila : Je ne pense pas que l'antenne remplace l'atelier ; il est essentiel que les deux portes restent ouvertes.
Joël : Aline veut une heure qui puisse se noter, afin que Solange tamponne une feuille lisible.
Rose : Je ne pense pas que l'on apprenne trop vite ; il est essentiel que l'on recommence sans honte.
Hawa : Un banc qui puisse accueillir ceux qui doutent, afin que personne n'idéalise un modèle.
Karim : Il est essentiel que le Bureau des Escales lise la page, encore que le tampon ne fasse pas le geste.
Félicie : Je ne pense pas que le thé soit un détail : c'est une pause qui puisse tenir le groupe.
Mado : J'écrirai un objectif qui puisse se relire demain, afin que le Cahier reste honnête.
Yvette : Aline : relatives de but, qui puisse / afin que ; opinion : je ne pense pas que, il est essentiel que — subjonctif.""",
        tf_item=(
            "Patrick pense que le Cahier du chemin est déjà un diplôme.",
            False,
            "Il ne pense pas que ce soit un diplôme ; c'est un journal.",
        ),
        qcm_item=(
            "Que cherche Aline, d'après la première réplique ?",
            [
                "Un titre d'ailleurs",
                "Un atelier qui puisse tenir, afin que chacun ose une page",
                "Une école lointaine",
                "Un verdict trop vite signé",
            ],
            1,
            "Aline : atelier qui puisse tenir, afin que chacun ose.",
        ),
        pairs=[
            ("qui puisse", "relative de but"),
            ("afin que", "but + subjonctif"),
            ("je ne pense pas que", "opinion + subj."),
            ("il est essentiel que", "nécessité + subj."),
        ],
        fill_item=("Je cherche un atelier ___ puisse tenir sans titre d'ailleurs.", "qui"),
        words=["Il", "est", "essentiel", "que", "ce", "soit", "un", "journal", "."],
        anagram=("puisse", "Subjonctif de pouvoir, dans une relative de but : un atelier qui…"),
        error=(
            "Je ne pense pas que le Cahier est un diplôme, et il est essentiel que ce soit un journal.",
            "Je ne pense pas que le Cahier soit un diplôme, et il est essentiel que ce soit un journal.",
            "Je ne pense pas que + subjonctif : soit, pas est.",
        ),
        pic_start=0,
        pic_words=["un objectif", "un subjonctif", "un atelier", "un cahier"],
        short_p="Notez quatre relatives (qui puisse / afin que) et quatre opinions au subjonctif.",
        audio="Enregistrez : Un atelier qui puisse tenir. Afin que chacun ose. Je ne pense pas que ce soit un diplôme. Il est essentiel que les portes restent ouvertes.",
    ),
    _l(
        "CE",
        "CE — Objectifs de l'Atelier d'Aline",
        "Lire une page d'objectifs qui enchaîne relatives de but et subjonctif d'opinion.",
        "Lisez la page, sans aller trop vite.",
        "Page d'Aline Uwase, Atelier d'Aline",
        """Objectifs — Atelier d'Aline, saison sèche
Je cherche un atelier qui puisse tenir sous le figuier, afin que personne n'emprunte un modèle d'ailleurs.
Je ne pense pas que le Cahier du chemin soit un diplôme ; il est essentiel que ce soit un journal de gestes tenus.
Léa veut un relais qui puisse durer trois minutes, afin que l'oreille de Joël se repose.
Dieudonné demande un coupon qui puisse se tendre sans se déchirer, afin que l'apprenti voie un geste fini.
Je ne pense pas qu'une expérience novatrice consiste à crier plus fort ; il est essentiel qu'elle ose un geste simple.
Lila écrit qu'il est essentiel que les deux portes restent ouvertes, afin que Patrick compare sans trahir.
Karim rappelle qu'un tampon qui puisse se lire ne fait pas le geste ; Solange en convient.
Hawa souhaite un banc qui puisse accueillir ceux qui doutent, afin que l'on n'idéalise pas trop vite.
Rose : je ne pense pas que l'on apprenne sans recommencer ; il est essentiel que la honte reste dehors.
Mado notera un objectif qui puisse se relire demain, afin que la page reste honnête.
Félicie : une pause qui puisse tenir le groupe n'est pas un détail.
Yvette : ces lignes n'inventent pas une école lointaine ; elles tiennent l'Atelier d'Aline.
Aline Uwase — Seuil des Sources, Rukiri-Nord
Copie au Cahier du chemin""",
        tf_item=(
            "Aline présente le Cahier du chemin comme un diplôme officiel.",
            False,
            "Elle ne pense pas que ce soit un diplôme ; c'est un journal.",
        ),
        qcm_item=(
            "Que veut Léa, d'après la page ?",
            [
                "Un relais sans fin",
                "Un relais qui puisse durer trois minutes",
                "Fermer l'atelier",
                "Un titre d'ailleurs",
            ],
            1,
            "« un relais qui puisse durer trois minutes. »",
        ),
        pairs=[
            ("atelier qui puisse", "tenir sous le figuier"),
            ("afin que", "personne n'emprunte"),
            ("je ne pense pas que", "le Cahier soit un diplôme"),
            ("il est essentiel que", "les portes restent ouvertes"),
        ],
        fill_item=("Il est essentiel que ce ___ un journal. (être, subj.)", "soit"),
        words=["Afin", "que", "chacun", "ose", "une", "page", "."],
        anagram=("essentiel", "Il est… que : nécessité d'opinion, suivie du subjonctif."),
        error=(
            "Il est essentiel que les portes restent ouvertes, et je ne pense pas que l'on apprend trop vite.",
            "Il est essentiel que les portes restent ouvertes, et je ne pense pas que l'on apprenne trop vite.",
            "Je ne pense pas que + subjonctif : apprenne.",
        ),
        pic_start=1,
        pic_words=["un subjonctif", "un atelier", "un cahier", "un résultat"],
        short_p="Recopiez la page et encadrez qui puisse, afin que, je ne pense pas que, il est essentiel que.",
        audio="Lisez la page d'objectifs, sans aller trop vite.",
    ),
    _l(
        "PO",
        "PO — Dire qui puisse, je ne pense pas que",
        "Formuler à l'oral un objectif (relative de but) et une opinion au subjonctif.",
        "Répétez, puis posez un objectif pour l'Atelier d'Aline et une opinion nuancée.",
        "Modèles d'Aline et de Patrick",
        """Je cherche un atelier qui puisse tenir.
Afin que chacun ose une page.
Je ne pense pas que ce soit un diplôme.
Il est essentiel que ce soit un journal.
Un relais qui puisse durer trois minutes.
Afin que l'oreille se repose.
Je ne pense pas que l'on crie plus fort.
Il est essentiel que les deux portes restent ouvertes.
Un banc qui puisse accueillir ceux qui doutent.
Afin que personne n'idéalise.
Je ne pense pas que l'on apprenne sans recommencer.
Il est essentiel que la honte reste dehors.
Aline : le subjonctif porte le souhait et le doute.
Léa : un objectif se dit sans titre d'ailleurs.""",
        tf_item=(
            "Après « je ne pense pas que » et « il est essentiel que », on met le subjonctif.",
            True,
            "Les modèles le montrent.",
        ),
        qcm_item=(
            "Quelle phrase est correcte ?",
            [
                "Je ne pense pas que c'est un diplôme",
                "Je ne pense pas que ce soit un diplôme",
                "Il est essentiel que c'est un journal",
                "Un atelier qui peut afin que on ose",
            ],
            1,
            "Je ne pense pas que + subjonctif.",
        ),
        pairs=[
            ("qui puisse", "but dans la relative"),
            ("afin que", "but + subj."),
            ("je ne pense pas que", "doute"),
            ("il est essentiel que", "nécessité"),
        ],
        fill_item=("Je ne pense pas que l'on ___ trop vite. (apprendre, subj.)", "apprenne"),
        words=["Un", "atelier", "qui", "puisse", "tenir", "."],
        anagram=("objectif", "Ce que l'Atelier d'Aline vise : un geste, une page, pas un titre."),
        error=(
            "Je cherche un atelier qui peut tenir sans titre, et afin que chacun ose une page.",
            "Je cherche un atelier qui puisse tenir sans titre, et afin que chacun ose une page.",
            "Relative de but : qui puisse, pas qui peut.",
        ),
        pic_start=2,
        pic_words=["un atelier", "un cahier", "un résultat", "un graphique"],
        short_p="Écrivez huit phrases : deux qui puisse, deux afin que, deux je ne pense pas que, deux il est essentiel que.",
        audio="Enregistrez les six premiers modèles, puis un objectif et une opinion à vous.",
    ),
    _l(
        "PE",
        "PE — Mes objectifs d'atelier",
        "Écrire une page d'objectifs avec relatives de but et subjonctif d'opinion.",
        "Imitez la page de Patrick Habimana, sans aller trop vite.",
        "Page de Patrick Habimana",
        """Patrick Habimana — objectifs pour l'Atelier d'Aline
Je cherche un matin qui puisse tenir à l'atelier, afin que je voie un coupon fini avant le thé.
Je ne pense pas que le Cahier du chemin soit un diplôme ; il est essentiel que j'y note les gestes, même fragiles.
Léa veut un relais qui puisse durer trois minutes, afin que Joël apprenne à couper sans honte.
Je ne pense pas qu'il faille crier plus fort pour innover ; il est essentiel qu'on ose un geste simple.
Dieudonné demande un fil qui puisse se tendre, afin que l'apprenti-tissu voie la fin du sac.
Lila écrit qu'il est essentiel que les deux portes restent ouvertes, afin que je compare sans trahir.
Hawa souhaite un banc qui puisse accueillir mon doute, afin que je n'idéalise ni l'atelier ni l'antenne.
Rose : je ne pense pas que l'on apprenne trop vite ; il est essentiel que je recommence.
Mado notera cette page, afin qu'elle puisse se relire demain.
Aline, je vous la tends : ce n'est pas un titre d'ailleurs, c'est un objectif de cour.
Patrick
Seuil des Sources — Rukiri-Nord""",
        tf_item=(
            "Patrick écrit qu'il faut crier plus fort pour innover.",
            False,
            "Il ne pense pas qu'il faille crier plus fort.",
        ),
        qcm_item=(
            "Que Patrick ne pense-t-il pas que le Cahier soit ?",
            [
                "Un journal",
                "Un diplôme",
                "Une page",
                "Un banc",
            ],
            1,
            "« Je ne pense pas que le Cahier du chemin soit un diplôme. »",
        ),
        pairs=[
            ("un matin qui puisse", "tenir à l'atelier"),
            ("afin que", "je voie un coupon fini"),
            ("je ne pense pas que", "ce soit un diplôme"),
            ("il est essentiel que", "j'y note les gestes"),
        ],
        fill_item=("Je ne pense pas qu'il ___ crier plus fort. (falloir, subj.)", "faille"),
        words=["Afin", "que", "je", "compare", "sans", "trahir", "."],
        anagram=("pense", "Je ne… pas que : opinion négative, puis le subjonctif."),
        error=(
            "Il est essentiel que j'y note les gestes, et je ne pense pas que le Cahier est un diplôme.",
            "Il est essentiel que j'y note les gestes, et je ne pense pas que le Cahier soit un diplôme.",
            "Je ne pense pas que + subjonctif : soit.",
        ),
        pic_start=3,
        pic_words=["un cahier", "un résultat", "un graphique", "un commentaire"],
        short_p="Imitez : douze à quinze lignes, trois qui puisse / afin que, deux je ne pense pas que, deux il est essentiel que.",
        audio="Lisez votre page, sans aller trop vite.",
    ),
    _l(
        "EL",
        "EL — Relatives de but et subjonctif d'opinion",
        "Retenir qui puisse, afin que, je ne pense pas que, il est essentiel que.",
        "Apprenez la fiche.",
        "Fiche d'Aline, souhait et opinion",
        """Relative de but : un atelier qui puisse tenir ; un relais qui puisse durer ; un banc qui puisse accueillir.
Afin que + subjonctif : afin que chacun ose, afin que l'oreille se repose, afin que la page reste honnête.
Je ne pense pas que + subjonctif : je ne pense pas que ce soit un diplôme ; je ne pense pas que l'on apprenne trop vite.
Il est essentiel que + subjonctif : il est essentiel que ce soit un journal ; il est essentiel que les portes restent ouvertes.
Je pense que + indicatif (opinion positive) ≠ je ne pense pas que + subjonctif.
Il faut que + subjonctif : il faut que tu notes ; il n'est pas correct d'écrire je faut.
Qui puisse = subjonctif de pouvoir (but, souhait), pas qui peut (simple fait).
On n'emprunte pas un nom d'école d'ailleurs. On dit Atelier d'Aline, Cahier du chemin, école de la cour.
Attention : soit / apprenne / faille / restent / ose.
À + le = au Cahier, à l'atelier. De + le = du figuier.
Un objectif se dit ; il ne se crie pas.
On vise un geste de cour, non un titre emprunté.""",
        tf_item=(
            "Après « je pense que », on met en général l'indicatif ; après « je ne pense pas que », le subjonctif.",
            True,
            "Opposition rappelée dans la fiche.",
        ),
        qcm_item=(
            "« Un atelier qui puisse tenir » emploie puisse parce que…",
            [
                "c'est un simple fait déjà vrai",
                "c'est un but / un souhait dans la relative",
                "c'est un passé composé",
                "c'est une litote",
            ],
            1,
            "Relative de but.",
        ),
        pairs=[
            ("qui puisse", "relative de but"),
            ("afin que", "but"),
            ("je ne pense pas que", "subj."),
            ("je pense que", "indicatif"),
        ],
        fill_item=("Afin que chacun ___ une page. (oser, subj.)", "ose"),
        words=["Il", "est", "essentiel", "que", "les", "portes", "restent", "ouvertes", "."],
        anagram=("relative", "Une… de but : un atelier qui puisse tenir."),
        error=(
            "Je pense pas que ce soit un diplôme, et il est essentiel que ce soit un journal.",
            "Je ne pense pas que ce soit un diplôme, et il est essentiel que ce soit un journal.",
            "Négation : je ne pense pas, avec ne.",
        ),
        pic_start=4,
        pic_words=["un résultat", "un graphique", "un commentaire", "une loupe"],
        short_p="Transformez six phrases : trois relatives de but, trois opinions au subjonctif.",
        audio="Enregistrez la fiche et six phrases, une par formule.",
    ),
]


# ---------------------------------------------------------------------------
# Séquence 2 — Expliquer et commenter des résultats
# ---------------------------------------------------------------------------

S2 = [
    _l(
        "CO",
        "CO — Chiffres sous le figuier",
        "Comprendre et commenter des résultats inventés de l'Atelier d'Aline.",
        "Lisez le dialogue. Quels chiffres entend-on, et comment les commente-t-on ?",
        "Atelier d'Aline, graphique ocre",
        """Aline : Vingt-quatre apprenants se sont inscrits au Cahier du chemin, cette saison sèche.
Patrick : Dix-huit ont tenu au moins huit pages : cela montre que le journal tient, pour trois sur quatre.
Léa : Douze ont osé un relais de trois minutes, soit la moitié ; on constate que l'oreille s'ouvre, sans crier.
Marc : Neuf ont mesuré un coupon à l'atelier : ces chiffres indiquent qu'un geste de main reste plus rare qu'une page.
Dieudonné : Six ont tenu l'antenne un jeudi, un quart seulement ; cela n'empêche pas de continuer.
Lila : Trois ont demandé un second essai ; ces chiffres montrent qu'on ose recommencer, et c'est déjà beaucoup.
Joël : Deux n'ont pas ouvert le cahier ; je ne pense pas que ce soit un échec, encore qu'il faille les relancer.
Rose : Zéro n'est parti sans mot : il est essentiel que l'on commente cela, afin que personne n'idéalise le silence.
Hawa : Dix-huit sur vingt-quatre, c'est soixante-quinze pour cent ; on peut toutefois noter que six pages manquent encore.
Karim : Ces résultats n'inventent pas une école d'ailleurs ; ils commentent l'Atelier d'Aline.
Solange : Un tampon sur une feuille lisible n'ajoute rien si le chiffre n'est pas compris.
Félicie : On constate que le thé a tenu le groupe : ce n'est pas un chiffre, c'est une pause.
Mado : J'écrirai : cela montre que, on constate que, ces chiffres indiquent que — sans enfler.
Aline : Commenter, ce n'est pas juger trop vite ; c'est relier un nombre à un geste.""",
        tf_item=(
            "Dix-huit apprenants sur vingt-quatre ont tenu au moins huit pages.",
            True,
            "Patrick : trois sur quatre.",
        ),
        qcm_item=(
            "Que montrent les trois seconds essais, selon Lila ?",
            [
                "Que tout le monde a réussi du premier coup",
                "Qu'on ose recommencer",
                "Que l'atelier ferme",
                "Qu'il faut un titre d'ailleurs",
            ],
            1,
            "Lila : on ose recommencer.",
        ),
        pairs=[
            ("18 / 24", "huit pages / 75 %"),
            ("12 / 24", "relais / la moitié"),
            ("9 / 24", "coupon mesuré"),
            ("6 / 24", "antenne un jeudi"),
        ],
        fill_item=("Cela ___ que le journal tient, pour trois sur quatre.", "montre"),
        words=["On", "constate", "que", "l'oreille", "s'ouvre", "."],
        anagram=("chiffres", "Nombres de l'Atelier d'Aline : pages, relais, coupons, jeudis."),
        error=(
            "Ces chiffres indiquent que un geste de main reste plus rare, et la moitié a osé le relais.",
            "Ces chiffres indiquent qu'un geste de main reste plus rare, et la moitié a osé le relais.",
            "Que + un s'élide : qu'un.",
        ),
        pic_start=5,
        pic_words=["un graphique", "un commentaire", "une loupe", "un diplôme"],
        short_p="Notez six chiffres et, pour chacun, la formule de commentaire entendue.",
        audio="Enregistrez : Vingt-quatre inscrits. Dix-huit pages tenues. Cela montre que. On constate que. Ces chiffres indiquent que.",
    ),
    _l(
        "CE",
        "CE — Bulletin de l'Atelier d'Aline",
        "Lire un bulletin qui explique et commente des résultats inventés.",
        "Lisez le bulletin, sans aller trop vite.",
        "Bulletin d'Aline Uwase",
        """Bulletin — Atelier d'Aline, saison sèche (chiffres inventés)
Vingt-quatre apprenants se sont inscrits au Cahier du chemin.
Dix-huit ont tenu au moins huit pages, soit trois sur quatre : cela montre que le journal tient.
Douze ont osé un relais de trois minutes, la moitié : on constate que l'oreille s'ouvre, encore que le silence coûte.
Neuf ont mesuré un coupon à l'atelier : ces chiffres indiquent qu'un geste de main reste plus rare qu'une page.
Six ont tenu l'antenne un jeudi, un quart : cela n'empêche pas de continuer, afin que le jeudi reste une porte.
Trois ont demandé un second essai : ces résultats montrent qu'on ose recommencer, et c'est déjà beaucoup.
Deux n'ont pas ouvert le cahier ; je ne pense pas que ce soit un échec, encore qu'il faille les relancer.
Zéro n'est parti sans mot : il est essentiel que l'on commente ce silence, afin que personne ne l'idéalise.
Hawa note : dix-huit sur vingt-quatre, soixante-quinze pour cent ; on peut toutefois rappeler que six pages manquent.
Karim : ces chiffres n'appartiennent à aucune école d'ailleurs ; ils commentent la cour.
Solange : un tampon n'explique rien si le nombre n'est pas lu.
Mado recopiera ce bulletin au Cahier du chemin, afin qu'il puisse se relire.
Commenter, ce n'est pas juger trop vite : c'est relier un nombre à un geste du Seuil.""",
        tf_item=(
            "Deux apprenants n'ont pas ouvert le cahier, et Aline y voit déjà un échec définitif.",
            False,
            "Elle ne pense pas que ce soit un échec.",
        ),
        qcm_item=(
            "Combien ont mesuré un coupon à l'atelier ?",
            ["Vingt-quatre", "Dix-huit", "Neuf", "Trois"],
            2,
            "« Neuf ont mesuré un coupon. »",
        ),
        pairs=[
            ("cela montre que", "le journal tient"),
            ("on constate que", "l'oreille s'ouvre"),
            ("ces chiffres indiquent", "geste de main plus rare"),
            ("ces résultats montrent", "on ose recommencer"),
        ],
        fill_item=("On ___ que l'oreille s'ouvre, encore que le silence coûte.", "constate"),
        words=["Cela", "montre", "que", "le", "journal", "tient", "."],
        anagram=("resultat", "Ce que le bulletin commente, sans enfler. (sans accent)"),
        error=(
            "Ces chiffres indiquent que le geste reste rare, et on constate l'oreille s'ouvre trop vite.",
            "Ces chiffres indiquent que le geste reste rare, et on constate que l'oreille s'ouvre trop vite.",
            "On constate que + phrase.",
        ),
        pic_start=6,
        pic_words=["un commentaire", "une loupe", "un diplôme", "une probabilité"],
        short_p="Recopiez le bulletin et soulignez toutes les formules de commentaire ; recopiez les huit chiffres.",
        audio="Lisez le bulletin, sans aller trop vite.",
    ),
    _l(
        "PO",
        "PO — Dire cela montre que",
        "Commenter à l'oral un chiffre de l'Atelier d'Aline.",
        "Répétez, puis commentez deux chiffres : un qui rassure, un qui reste fragile.",
        "Modèles d'Aline et de Hawa",
        """Vingt-quatre se sont inscrits.
Dix-huit ont tenu huit pages.
Cela montre que le journal tient.
On constate que l'oreille s'ouvre.
Ces chiffres indiquent qu'un geste de main reste rare.
Ces résultats montrent qu'on ose recommencer.
La moitié a osé le relais.
Un quart a tenu l'antenne.
Je ne pense pas que deux silences soient un échec.
Il est essentiel que l'on relance.
On peut toutefois noter que six pages manquent.
Commenter n'est pas juger trop vite.
Relier un nombre à un geste.
Aline : sans enfler, sans idéaliser.""",
        tf_item=(
            "Commenter un chiffre, c'est le relier à un geste, non le juger trop vite.",
            True,
            "Aline le rappelle.",
        ),
        qcm_item=(
            "Quelle formule introduit un commentaire de résultat ?",
            [
                "Je faut que",
                "Cela montre que",
                "Bonjour seulement",
                "Un titre d'ailleurs",
            ],
            1,
            "Cela montre que.",
        ),
        pairs=[
            ("cela montre que", "le journal tient"),
            ("on constate que", "l'oreille s'ouvre"),
            ("ces chiffres indiquent", "geste rare"),
            ("un quart", "antenne un jeudi"),
        ],
        fill_item=("Ces chiffres ___ qu'un geste de main reste rare. (indiquer, présent)", "indiquent"),
        words=["La", "moitié", "a", "osé", "le", "relais", "."],
        anagram=("commente", "On… un nombre : on le relie à un geste, on ne l'enfle pas."),
        error=(
            "Cela montre le journal tient déjà, et on constate que l'oreille s'ouvre.",
            "Cela montre que le journal tient déjà, et on constate que l'oreille s'ouvre.",
            "Cela montre que + phrase.",
        ),
        pic_start=7,
        pic_words=["une loupe", "un diplôme", "une probabilité", "une question"],
        short_p="Écrivez huit commentaires : deux par formule (montre, constate, indiquent, résultats montrent).",
        audio="Enregistrez les six premiers modèles, puis deux commentaires à vous.",
    ),
    _l(
        "PE",
        "PE — Mon commentaire de résultats",
        "Écrire un commentaire argumenté des chiffres de l'Atelier d'Aline.",
        "Imitez le commentaire de Marc Nkurunziza, sans aller trop vite.",
        "Commentaire de Marc Nkurunziza",
        """Marc Nkurunziza — lire les chiffres sans les enfler
Vingt-quatre inscrits au Cahier du chemin : cela montre que l'Atelier d'Aline attire, encore que deux n'aient pas ouvert la page.
Dix-huit ont tenu huit pages, trois sur quatre : on constate que le journal tient, et il est essentiel que les six autres soient relancés.
Douze ont osé le relais, la moitié : ces chiffres indiquent que l'oreille s'ouvre, sans nier que le silence coûte.
Neuf ont mesuré un coupon : je ne pense pas que ce soit peu ; un geste de main demande plus de temps qu'une phrase.
Six jeudis tenus, un quart : on peut toutefois continuer, afin que la porte de Lila reste une porte.
Trois seconds essais : ces résultats montrent qu'on ose recommencer, et c'est déjà beaucoup.
Zéro n'est parti sans mot : il est essentiel que l'on commente ce silence, afin que personne ne l'idéalise.
Ces nombres n'appartiennent à aucune école d'ailleurs ; ils commentent la cour.
Solange : un tampon n'explique rien si le chiffre n'est pas lu.
Je tends cette page à Aline, afin qu'elle puisse la relire au pupitre.
Marc
Cahier du chemin — Seuil des Sources""",
        tf_item=(
            "Marc juge que neuf coupons mesurés, c'est forcément trop peu pour continuer.",
            False,
            "Il ne pense pas que ce soit peu.",
        ),
        qcm_item=(
            "Que montrent les trois seconds essais, selon Marc ?",
            [
                "Un échec définitif",
                "Qu'on ose recommencer",
                "La fermeture de l'atelier",
                "Un titre d'ailleurs",
            ],
            1,
            "« on ose recommencer. »",
        ),
        pairs=[
            ("cela montre que", "l'atelier attire"),
            ("on constate que", "le journal tient"),
            ("ces chiffres indiquent", "l'oreille s'ouvre"),
            ("ces résultats montrent", "on ose recommencer"),
        ],
        fill_item=("Il est essentiel que l'on ___ ce silence. (commenter, subj.)", "commente"),
        words=["Commenter", "n'est", "pas", "juger", "trop", "vite", "."],
        anagram=("indique", "Ces chiffres… que : un verbe pour relier le nombre au geste."),
        error=(
            "Ces résultats montrent qu'on ose recommencer, et je ne pense pas que neuf coupons est trop peu.",
            "Ces résultats montrent qu'on ose recommencer, et je ne pense pas que neuf coupons soient trop peu.",
            "Je ne pense pas que + subjonctif : soient.",
        ),
        pic_start=8,
        pic_words=["un diplôme", "une probabilité", "une question", "un tampon"],
        short_p="Imitez : quinze lignes, les huit chiffres, quatre formules de commentaire, une opinion au subjonctif.",
        audio="Lisez votre commentaire, sans aller trop vite.",
    ),
    _l(
        "EL",
        "EL — Commenter un chiffre",
        "Retenir les formules qui expliquent un résultat sans l'enfler.",
        "Apprenez la fiche.",
        "Fiche d'Aline, résultats",
        """Formules : cela montre que ; on constate que ; ces chiffres indiquent que ; ces résultats montrent que.
Fractions inventées de l'Atelier d'Aline : 18/24 = 3/4 = 75 % ; 12/24 = 1/2 ; 6/24 = 1/4.
On relie le nombre à un geste : pages tenues, relais osé, coupon mesuré, jeudi tenu, second essai.
On n'enfle pas. On n'idéalise pas le silence. Zéro départ sans mot se commente, il ne se célèbre pas trop vite.
Je ne pense pas que deux cahiers fermés soient un échec. Il est essentiel que l'on relance.
Encore qu'il faille relancer, on peut toutefois continuer.
Élision : qu'un geste, qu'on ose, qu'elle puisse.
Cela montre que + phrase (pas : cela montre le journal tient).
On constate que + phrase (pas : on constate l'oreille s'ouvre, sans que).
Ces chiffres n'appartiennent à aucune école d'ailleurs.
Attention : indiquent (ils), montre (cela). Accord du verbe avec le sujet.
Commenter un nombre, c'est le relier à un geste du Seuil.""",
        tf_item=(
            "On dit « cela montre le journal tient » sans que.",
            False,
            "Cela montre que + phrase.",
        ),
        qcm_item=(
            "18 sur 24, dans le bulletin, égale…",
            [
                "un quart",
                "trois sur quatre",
                "la moitié",
                "zéro",
            ],
            1,
            "Trois sur quatre, soixante-quinze pour cent.",
        ),
        pairs=[
            ("cela montre que", "commentaire"),
            ("18 / 24", "trois sur quatre"),
            ("12 / 24", "la moitié"),
            ("6 / 24", "un quart"),
        ],
        fill_item=("Ces chiffres ___ qu'un geste de main reste rare. (indiquer)", "indiquent"),
        words=["On", "n'enfle", "pas", "les", "nombres", "."],
        anagram=("pourcent", "Dix-huit sur vingt-quatre : soixante-quinze… (sans accent)."),
        error=(
            "Cela montrent que le journal tient, et on constate que l'oreille s'ouvre.",
            "Cela montre que le journal tient, et on constate que l'oreille s'ouvre.",
            "Cela : verbe au singulier, montre.",
        ),
        pic_start=9,
        pic_words=["une probabilité", "une question", "un tampon", "une initiative"],
        short_p="Rédigez un tableau : chiffre, fraction, formule de commentaire, geste relié.",
        audio="Enregistrez la fiche et quatre commentaires, un par formule.",
    ),
]


# ---------------------------------------------------------------------------
# Séquence 3 — L'utilité des diplômes
# ---------------------------------------------------------------------------

S3 = [
    _l(
        "CO",
        "CO — Tampon ou geste ?",
        "Repérer le subjonctif de probabilité (il est peu probable que, il se peut que, il n'est pas sûr que).",
        "Lisez le dialogue. Le tampon de cour est-il utile, et qui en doute ?",
        "Bureau des Escales / banc du figuier",
        """Aline : Solange propose un tampon de cour, une feuille de tenue. Est-ce utile ?
Patrick : Il est peu probable que ce tampon remplace un geste tenu ; il se peut toutefois qu'il rassure.
Léa : Il n'est pas sûr que tout le monde en ait besoin ; Joël, lui, demande encore la page.
Marc : Il se peut que la feuille de tenue aide Karim à lire ; il est peu probable qu'elle fasse le coupon.
Dieudonné : Je ne pense pas qu'un tampon couse mieux qu'une main ; il n'est pas sûr qu'on doive le refuser.
Lila : Il est peu probable que Radio Figuier exige un titre d'ailleurs ; il se peut qu'une heure tenue suffise.
Joël : Il n'est pas sûr que je comprenne l'utilité demain ; il se peut que je la voie après trois relais.
Rose : Il est peu probable que l'on apprenne pour le tampon ; on apprend pour le geste, afin que le sac tienne.
Hawa : Il se peut que le Cahier du chemin vaille mieux qu'une feuille trop vite tamponnée.
Karim : Sans nier que le tampon compte au Bureau, il n'est pas sûr qu'il compte sous le figuier.
Solange : Je tamponnerai ce qui est lisible ; il est peu probable que je tamponne une rumeur.
Félicie : Il se peut que le thé discute mieux l'utilité qu'un long discours.
Mado : J'écrirai ces doutes, afin qu'ils puissent se relire : il n'est pas sûr, il se peut, il est peu probable.
Aline : Probabilité faible ou doute : subjonctif. On n'emprunte aucun diplôme d'ailleurs.""",
        tf_item=(
            "Aline rappelle qu'on n'emprunte aucun diplôme d'ailleurs.",
            True,
            "Dernière réplique.",
        ),
        qcm_item=(
            "Que Patrick dit-il qu'il est peu probable ?",
            [
                "Que le thé soit versé",
                "Que le tampon remplace un geste tenu",
                "Que Solange sache lire",
                "Que le figuier tombe",
            ],
            1,
            "« Il est peu probable que ce tampon remplace un geste tenu. »",
        ),
        pairs=[
            ("il est peu probable que", "le tampon remplace le geste"),
            ("il se peut que", "la feuille rassure / aide"),
            ("il n'est pas sûr que", "tout le monde en ait besoin"),
            ("Cahier du chemin", "vaut mieux parfois"),
        ],
        fill_item=("Il est peu probable que ce tampon ___ un geste. (remplacer, subj.)", "remplace"),
        words=["Il", "se", "peut", "que", "la", "feuille", "rassure", "."],
        anagram=("probable", "Il est peu… que : doute fort, puis le subjonctif."),
        error=(
            "Il est peu probable que le tampon remplacera le geste, et il se peut que la feuille rassure.",
            "Il est peu probable que le tampon remplace le geste, et il se peut que la feuille rassure.",
            "Il est peu probable que + subjonctif : remplace, pas le futur.",
        ),
        pic_start=10,
        pic_words=["une question", "un tampon", "une initiative", "une négation"],
        short_p="Notez six phrases de probabilité et ce qu'elles disent du tampon, de la feuille ou du Cahier.",
        audio="Enregistrez : Il est peu probable que le tampon remplace le geste. Il se peut que la feuille rassure. Il n'est pas sûr que tout le monde en ait besoin.",
    ),
    _l(
        "CE",
        "CE — Débat sur le tampon de cour",
        "Lire un débat argumenté sur l'utilité d'un tampon inventé, sans diplôme d'ailleurs.",
        "Lisez le débat, sans aller trop vite.",
        "Débat noté par Mado",
        """Débat — utilité du tampon de cour (feuille de tenue)
Aline ouvre : Solange propose un tampon de cour. Nous n'empruntons aucun diplôme d'ailleurs.
Patrick : il est peu probable que ce tampon remplace un geste tenu ; il se peut toutefois qu'il rassure ceux qui doutent.
Léa : il n'est pas sûr que Joël en ait besoin demain ; il se peut qu'une heure tenue suffise à Lila.
Marc : ces chiffres de l'atelier indiquent que neuf coupons valent déjà plus qu'une feuille trop vite tamponnée.
Dieudonné : je ne pense pas qu'un tampon couse ; il n'est pas sûr qu'on doive pourtant le refuser.
Lila : il est peu probable que l'antenne exige un titre ; il se peut qu'un relais de trois minutes parle assez.
Karim, sans nier que le Bureau aime une page lisible, doute qu'elle compte autant sous le figuier.
Solange : je tamponnerai ce qui est lisible ; il est peu probable que je tamponne une rumeur.
Hawa : il se peut que le Cahier du chemin vaille mieux ; il n'est pas sûr que le tampon soit inutile pour autant.
Rose : on apprend pour le geste, afin que le sac tienne, non pour l'encre du Bureau.
Félicie : il se peut que le thé discute mieux l'utilité qu'un verdict trop net.
Yvette : il est essentiel que l'on doute ici, afin que personne n'idéalise un tampon.
Conclusion provisoire : le tampon peut accompagner ; il est peu probable qu'il remplace. Le Cahier reste le journal.""",
        tf_item=(
            "La conclusion dit qu'il est peu probable que le tampon remplace le geste.",
            True,
            "« il peut accompagner ; il est peu probable qu'il remplace. »",
        ),
        qcm_item=(
            "Que tamponnera Solange, d'après le débat ?",
            [
                "Une rumeur",
                "Ce qui est lisible",
                "Un titre d'ailleurs",
                "Un casque cassé",
            ],
            1,
            "« je tamponnerai ce qui est lisible. »",
        ),
        pairs=[
            ("peu probable que", "remplace le geste"),
            ("il se peut que", "rassure / suffise / vaille"),
            ("il n'est pas sûr que", "Joël en ait besoin"),
            ("Cahier du chemin", "journal, pas diplôme"),
        ],
        fill_item=("Il n'est pas sûr que Joël en ___ besoin. (avoir, subj.)", "ait"),
        words=["Le", "Cahier", "reste", "le", "journal", "."],
        anagram=("diplome", "Mot qu'on n'emprunte pas ailleurs : ici on dit tampon de cour. (sans accent)"),
        error=(
            "Il se peut que la feuille rassure, et il n'est pas sûr que tout le monde a besoin du tampon.",
            "Il se peut que la feuille rassure, et il n'est pas sûr que tout le monde ait besoin du tampon.",
            "Il n'est pas sûr que + subjonctif : ait.",
        ),
        pic_start=11,
        pic_words=["un tampon", "une initiative", "une négation", "une différence"],
        short_p="Recopiez le débat et encadrez peu probable / il se peut / il n'est pas sûr ; indiquez le verbe au subjonctif.",
        audio="Lisez le débat, sans aller trop vite.",
    ),
    _l(
        "PO",
        "PO — Dire il se peut, il n'est pas sûr",
        "Exprimer à l'oral une probabilité ou un doute sur l'utilité d'un tampon de cour.",
        "Répétez, puis doutez à voix haute : tampon, feuille, Cahier.",
        "Modèles d'Aline et de Solange",
        """Il est peu probable que le tampon remplace le geste.
Il se peut que la feuille rassure.
Il n'est pas sûr que tout le monde en ait besoin.
Il se peut qu'une heure tenue suffise.
Il est peu probable que l'antenne exige un titre.
Il n'est pas sûr qu'on doive refuser le tampon.
Il se peut que le Cahier vaille mieux.
Il est peu probable que je tamponne une rumeur.
On apprend pour le geste, non pour l'encre.
Le tampon peut accompagner, rarement remplacer.
Je ne pense pas qu'un tampon couse.
Il est essentiel que l'on doute ici.
Aline : subjonctif après le doute.
Patrick : le Cahier reste le journal.""",
        tf_item=(
            "Les trois formules de probabilité appellent le subjonctif.",
            True,
            "Aline : subjonctif après le doute.",
        ),
        qcm_item=(
            "Quelle phrase est correcte ?",
            [
                "Il est peu probable que le tampon remplacera",
                "Il se peut que la feuille rassure",
                "Il n'est pas sûr que tout le monde a besoin",
                "Il se peut la feuille rassure",
            ],
            1,
            "Il se peut que + subjonctif (rassure).",
        ),
        pairs=[
            ("peu probable que", "doute fort"),
            ("il se peut que", "possibilité"),
            ("il n'est pas sûr que", "incertitude"),
            ("Cahier", "journal"),
        ],
        fill_item=("Il se peut que le Cahier ___ mieux. (valoir, subj.)", "vaille"),
        words=["On", "apprend", "pour", "le", "geste", "."],
        anagram=("rassure", "Il se peut que la feuille… ceux qui doutent."),
        error=(
            "Il se peut que le Cahier vaut mieux, et il est peu probable que le tampon remplace le geste.",
            "Il se peut que le Cahier vaille mieux, et il est peu probable que le tampon remplace le geste.",
            "Il se peut que + subjonctif : vaille.",
        ),
        pic_start=12,
        pic_words=["une initiative", "une négation", "une différence", "deux modèles"],
        short_p="Écrivez neuf phrases : trois par formule de probabilité, sur tampon / feuille / Cahier.",
        audio="Enregistrez les six premiers modèles, puis trois doutes à vous.",
    ),
    _l(
        "PE",
        "PE — Mon avis sur le tampon",
        "Écrire un avis argumenté sur l'utilité du tampon de cour.",
        "Imitez l'avis de Rose Iradukunda, sans aller trop vite.",
        "Avis de Rose Iradukunda",
        """Rose Iradukunda — tampon de cour, geste, Cahier
Il est peu probable que le tampon de Solange remplace un coupon tendu ; il se peut toutefois qu'il rassure Patrick.
Il n'est pas sûr que Joël en ait besoin demain ; il se peut qu'une heure tenue à l'antenne lui suffise.
Je ne pense pas qu'un tampon couse mieux qu'une main ; il n'est pas sûr pourtant qu'on doive le refuser.
Lila : il est peu probable que Radio Figuier exige un titre d'ailleurs ; Aline en convient.
Ces chiffres de l'atelier indiquent que neuf gestes tenus parlent déjà, encore que six pages manquent.
Il se peut que le Cahier du chemin vaille mieux qu'une feuille trop vite tamponnée.
Sans nier que le Bureau aime une page lisible, il n'est pas sûr qu'elle compte autant sous le figuier.
On apprend pour le geste, afin que le sac tienne, non pour l'encre.
Le tampon peut accompagner ; il est peu probable qu'il remplace. Le Cahier reste le journal.
Il est essentiel que l'on doute ici, afin que personne n'idéalise un tampon.
Rose
Copie : Aline Uwase, Solange — Seuil des Sources""",
        tf_item=(
            "Rose conclut que le tampon remplace déjà le geste.",
            False,
            "Il peut accompagner ; il est peu probable qu'il remplace.",
        ),
        qcm_item=(
            "Que Rose ne pense-t-elle pas qu'un tampon fasse ?",
            [
                "Rassurer parfois",
                "Coudre mieux qu'une main",
                "Accompagner",
                "Rester lisible",
            ],
            1,
            "« Je ne pense pas qu'un tampon couse mieux qu'une main. »",
        ),
        pairs=[
            ("peu probable que", "remplace un coupon"),
            ("il se peut que", "rassure / vaille"),
            ("il n'est pas sûr que", "Joël en ait besoin"),
            ("Cahier", "reste le journal"),
        ],
        fill_item=("Il n'est pas sûr qu'on ___ le refuser. (devoir, subj.)", "doive"),
        words=["Le", "Cahier", "reste", "le", "journal", "."],
        anagram=("utilite", "On discute l'… du tampon, pas celle d'un titre d'ailleurs. (sans accent)"),
        error=(
            "Il est peu probable que le tampon remplace le geste, et il n'est pas sûr que Joël en a besoin demain.",
            "Il est peu probable que le tampon remplace le geste, et il n'est pas sûr que Joël en ait besoin demain.",
            "Il n'est pas sûr que + subjonctif : ait.",
        ),
        pic_start=13,
        pic_words=["une négation", "une différence", "deux modèles", "un bilan"],
        short_p="Imitez : douze à quinze lignes, les trois formules de probabilité, tampon / feuille / Cahier, pas de diplôme d'ailleurs.",
        audio="Lisez votre avis, sans aller trop vite.",
    ),
    _l(
        "EL",
        "EL — Subjonctif de probabilité",
        "Retenir il est peu probable que, il se peut que, il n'est pas sûr que.",
        "Apprenez la fiche.",
        "Fiche d'Aline, probabilité",
        """Il est peu probable que + subjonctif : doute fort (il est peu probable que le tampon remplace).
Il se peut que + subjonctif : possibilité (il se peut que la feuille rassure ; il se peut qu'il vaille).
Il n'est pas sûr que + subjonctif : incertitude (il n'est pas sûr que tout le monde ait besoin ; qu'on doive).
Contrast : il est probable que + indicatif (certitude relative) ≠ il est peu probable que + subjonctif.
Verbes fréquents au subj. : remplace, rassure, ait, doive, vaille, suffise, couse.
On n'écrit pas : il est peu probable que le tampon remplacera. On n'écrit pas : il se peut que le Cahier vaut.
Tampon de cour, feuille de tenue : inventés au Seuil. Pas de diplôme d'ailleurs.
Le Cahier du chemin reste le journal d'apprentissage.
Le tampon peut accompagner ; il est peu probable qu'il remplace.
Attention : il faut que (pas je faut). À + le = au Bureau. Qu'on / qu'il / qu'elle.
Douter ici est une compétence ; idéaliser un tampon n'en est pas une.
Le Cahier du chemin reste le journal ; le tampon n'est qu'un accompagnement.""",
        tf_item=(
            "« Il est probable que » et « il est peu probable que » prennent le même mode.",
            False,
            "Probable + indicatif ; peu probable + subjonctif.",
        ),
        qcm_item=(
            "Quelle forme suit « il se peut que le Cahier » ?",
            [
                "vaut",
                "vaille",
                "vaudra",
                "valait seulement",
            ],
            1,
            "Subjonctif de valoir : vaille.",
        ),
        pairs=[
            ("peu probable que", "subj. / doute fort"),
            ("il se peut que", "subj. / possibilité"),
            ("il n'est pas sûr que", "subj. / incertitude"),
            ("il est probable que", "indicatif"),
        ],
        fill_item=("Il se peut qu'une heure tenue ___ . (suffire, subj.)", "suffise"),
        words=["Le", "tampon", "peut", "accompagner", "."],
        anagram=("doute", "Il n'est pas sûr, il se peut, peu probable : trois portes du…"),
        error=(
            "Il est peu probable que le tampon remplacera le geste, et le Cahier reste le journal.",
            "Il est peu probable que le tampon remplace le geste, et le Cahier reste le journal.",
            "Peu probable que + subjonctif, pas le futur.",
        ),
        pic_start=14,
        pic_words=["une différence", "deux modèles", "un bilan", "un projet"],
        short_p="Conjuguez remplacer, avoir, devoir, valoir au subjonctif après les trois formules.",
        audio="Enregistrez la fiche et six phrases, deux par formule.",
    ),
]


# ---------------------------------------------------------------------------
# Séquence 4 — Une initiative, des différences
# ---------------------------------------------------------------------------

S4 = [
    _l(
        "CO",
        "CO — Ni l'atelier ni l'antenne seuls",
        "Repérer ne… ni… ni… et comparer deux modèles inventés : atelier sous le figuier et stage à Radio Figuier.",
        "Lisez le dialogue. En quoi les deux modèles diffèrent-ils, et que refuse-t-on ?",
        "Deux bancs face à face, figuier et antenne",
        """Aline : Nous comparons deux initiatives : l'atelier sous le figuier, le stage à Radio Figuier. Ni l'un ni l'autre n'est une école d'ailleurs.
Dieudonné : Mon modèle n'est ni un titre ni un palais ni une course : on mesure, on tend, on voit un geste fini.
Lila : Le stage n'est ni une scène ni un cri ni un relais sans fin : on écoute, on coupe à trois minutes.
Patrick : Je n'ai ni diplômé d'ailleurs ni tampon trop vite posé ni verdict : j'essaie les deux portes.
Léa : L'atelier forme les mains ; l'antenne forme l'oreille. Ni les mains ni l'oreille ne suffisent seules.
Marc : On ne compare ni pour trahir ni pour idéaliser ni pour juger trop vite : on décrit une différence.
Joël : Je n'ai ni la maîtrise du fil ni celle du micro, ni la honte de recommencer.
Rose : L'atelier n'est ni plus noble ni plus petit ; le stage n'est ni plus brillant ni plus faible.
Hawa : Cette initiative n'emprunte ni un nom lointain ni un règlement d'ailleurs ni une ville.
Karim : Solange ne tamponnera ni une rumeur ni une page illisible ni un titre emprunté.
Félicie : On ne décide ni trop tôt ni sans thé ni sans avoir entendu les deux voix.
Mado : J'écrirai : ne… ni… ni… ; deux modèles ; une différence, pas une guerre.
Yvette : Il est essentiel que l'on tienne les deux, afin que personne n'en ferme une.
Aline : Ne… ni… ni… nie plus d'un élément. Les deux modèles restent inventés, sous le figuier et à l'antenne.""",
        tf_item=(
            "Aline dit que ni l'atelier ni le stage n'est une école d'ailleurs.",
            True,
            "Première réplique.",
        ),
        qcm_item=(
            "Que forme surtout l'atelier, selon Léa ?",
            [
                "L'oreille seulement",
                "Les mains",
                "Un titre d'ailleurs",
                "Un verdict",
            ],
            1,
            "Léa : l'atelier forme les mains ; l'antenne, l'oreille.",
        ),
        pairs=[
            ("atelier sous le figuier", "mesurer / tendre / mains"),
            ("stage à Radio Figuier", "écouter / trois minutes / oreille"),
            ("ne… ni… ni…", "plus d'un élément nié"),
            ("ni pour trahir ni pour idéaliser", "Marc"),
        ],
        fill_item=("Ni l'un ___ l'autre n'est une école d'ailleurs.", "ni"),
        words=["L'atelier", "forme", "les", "mains", "."],
        anagram=("modele", "Atelier ou stage : un… inventé de la cour. (sans accent)"),
        error=(
            "Je n'ai ni titre d'ailleurs ou tampon trop vite posé, et j'essaie les deux portes.",
            "Je n'ai ni titre d'ailleurs ni tampon trop vite posé, et j'essaie les deux portes.",
            "Ne… ni… ni… : on reprend ni, pas ou.",
        ),
        pic_start=15,
        pic_words=["deux modèles", "un bilan", "un projet", "un banc"],
        short_p="Notez quatre différences et quatre phrases en ne… ni… ni… entendues.",
        audio="Enregistrez : Ni l'un ni l'autre n'est une école d'ailleurs. L'atelier forme les mains. L'antenne forme l'oreille. On ne compare ni pour trahir ni pour idéaliser.",
    ),
    _l(
        "CE",
        "CE — Deux modèles, une cour",
        "Lire une comparaison argumentée des deux initiatives inventées.",
        "Lisez la comparaison, sans aller trop vite.",
        "Feuille de Hawa Diallo",
        """Deux modèles — atelier sous le figuier / stage à Radio Figuier
L'atelier de Dieudonné n'est ni un palais ni une course ni un titre : on mesure, on tend, on voit un geste fini.
Le stage chez Lila n'est ni une scène ni un cri ni un relais sans fin : on écoute, on coupe à trois minutes, on pose le casque.
Patrick n'a ni diplôme d'ailleurs ni verdict : il essaie les deux portes, afin de comparer sans trahir.
Léa : l'atelier forme les mains ; l'antenne forme l'oreille. Ni les mains ni l'oreille ne suffisent seules.
Marc : on ne compare ni pour idéaliser ni pour juger trop vite ni pour fermer une porte.
Joël n'a ni la maîtrise du fil ni celle du micro, ni la honte de recommencer : c'est déjà une compétence.
Rose : l'atelier n'est ni plus noble ni plus petit ; le stage n'est ni plus brillant ni plus faible.
Cette initiative n'emprunte ni un nom lointain ni un règlement d'ailleurs ni une ville.
Solange ne tamponnera ni une rumeur ni une page illisible.
On ne décide ni trop tôt ni sans thé ni sans avoir entendu les deux voix.
Il est peu probable que l'un remplace l'autre ; il se peut que les deux tiennent le Seuil.
Il n'est pas sûr que Patrick doive choisir ce soir ; il est essentiel que les portes restent ouvertes.
Ces lignes n'inventent ni une école lointaine ni une guerre : elles décrivent une différence de la cour.""",
        tf_item=(
            "La feuille dit qu'il faut fermer une des deux portes ce soir.",
            False,
            "Il est essentiel que les portes restent ouvertes.",
        ),
        qcm_item=(
            "Que le stage chez Lila n'est-il pas, d'après la feuille ?",
            [
                "Une oreille",
                "Une scène, un cri, un relais sans fin",
                "Un relais de trois minutes",
                "Un casque posé",
            ],
            1,
            "« ni une scène ni un cri ni un relais sans fin. »",
        ),
        pairs=[
            ("atelier", "mains / coupon / geste fini"),
            ("stage radio", "oreille / trois minutes"),
            ("ni… ni… ni…", "palais / course / titre"),
            ("portes ouvertes", "essentiel"),
        ],
        fill_item=("Ni les mains ___ l'oreille ne suffisent seules.", "ni"),
        words=["On", "compare", "sans", "trahir", "."],
        anagram=("difference", "Ce que l'on décrit entre les deux modèles, sans guerre. (sans accent)"),
        error=(
            "On ne compare pas ni pour idéaliser ni pour juger trop vite, et les portes restent ouvertes.",
            "On ne compare ni pour idéaliser ni pour juger trop vite, et les portes restent ouvertes.",
            "Ne… ni… ni… : pas de pas devant ni.",
        ),
        pic_start=16,
        pic_words=["un bilan", "un projet", "un banc", "un livre"],
        short_p="Recopiez la feuille et dressez deux colonnes : atelier / stage ; encadrez ne… ni… ni…",
        audio="Lisez la comparaison, sans aller trop vite.",
    ),
    _l(
        "PO",
        "PO — Dire ne… ni… ni… et comparer",
        "Comparer à l'oral les deux modèles avec ne… ni… ni…",
        "Répétez, puis dites trois différences et une phrase en ni… ni… ni…",
        "Modèles d'Aline, de Dieudonné et de Lila",
        """Ni l'un ni l'autre n'est une école d'ailleurs.
L'atelier n'est ni un palais ni une course.
Le stage n'est ni une scène ni un cri.
L'atelier forme les mains.
L'antenne forme l'oreille.
Ni les mains ni l'oreille ne suffisent seules.
On ne compare ni pour trahir ni pour idéaliser.
Je n'ai ni titre ni verdict ni honte de recommencer.
L'atelier n'est ni plus noble ni plus petit.
Le stage n'est ni plus brillant ni plus faible.
Il est essentiel que les portes restent ouvertes.
On ne décide ni trop tôt ni sans thé.
Dieudonné : un geste fini.
Lila : trois minutes, un casque posé.""",
        tf_item=(
            "Ne… ni… ni… permet de nier plus d'un élément dans la même phrase.",
            True,
            "Aline l'a rappelé.",
        ),
        qcm_item=(
            "Quelle phrase est correcte ?",
            [
                "Je n'ai pas ni titre ni verdict",
                "Je n'ai ni titre ni verdict ni honte",
                "Je n'ai ni titre ou verdict",
                "Ni l'un ou l'autre n'est une école",
            ],
            1,
            "Je n'ai ni… ni… ni…",
        ),
        pairs=[
            ("atelier", "mains / geste fini"),
            ("stage", "oreille / trois minutes"),
            ("ne… ni… ni…", "plus d'un élément"),
            ("portes ouvertes", "les deux modèles"),
        ],
        fill_item=("On ne compare ___ pour trahir ni pour idéaliser.", "ni"),
        words=["Ni", "les", "mains", "ni", "l'oreille", "ne", "suffisent", "."],
        anagram=("initiative", "Les deux modèles de la cour : une… éducative, pas une guerre."),
        error=(
            "Ni l'un ou l'autre n'est une école d'ailleurs, et les portes restent ouvertes.",
            "Ni l'un ni l'autre n'est une école d'ailleurs, et les portes restent ouvertes.",
            "Ni l'un ni l'autre, pas ni l'un ou l'autre.",
        ),
        pic_start=17,
        pic_words=["un projet", "un banc", "un livre", "une radio"],
        short_p="Écrivez six phrases en ne… ni… ni… et quatre comparaisons atelier / stage.",
        audio="Enregistrez les huit premiers modèles, puis une comparaison à vous.",
    ),
    _l(
        "PE",
        "PE — Ma comparaison de modèles",
        "Écrire une comparaison argumentée des deux initiatives, avec ne… ni… ni…",
        "Imitez la comparaison de Joël Mugisha, sans aller trop vite.",
        "Comparaison de Joël Mugisha",
        """Joël Mugisha — deux modèles, sans en fermer un
L'atelier sous le figuier n'est ni un palais ni une course ni un titre : Dieudonné mesure, tend, montre un geste fini.
Le stage à Radio Figuier n'est ni une scène ni un cri ni un relais sans fin : Lila écoute, coupe à trois minutes, pose le casque.
Je n'ai ni la maîtrise du fil ni celle du micro, ni la honte de recommencer.
Léa dit que l'atelier forme les mains et que l'antenne forme l'oreille ; ni les unes ni l'autre ne suffisent seules.
On ne compare ni pour trahir ni pour idéaliser ni pour juger trop vite.
Patrick n'a ni diplôme d'ailleurs ni verdict : il essaie les deux portes, afin de voir.
Cette initiative n'emprunte ni un nom lointain ni un règlement d'ailleurs.
Il est peu probable que l'un remplace l'autre ; il se peut que les deux tiennent le Seuil.
Il n'est pas sûr que je doive choisir ce soir ; il est essentiel que les portes restent ouvertes.
On ne décide ni trop tôt ni sans thé ni sans avoir entendu Aline.
Joël
Cahier du chemin — Seuil des Sources""",
        tf_item=(
            "Joël a honte de recommencer, et il le dit comme une faute.",
            False,
            "Il n'a ni… ni la honte de recommencer.",
        ),
        qcm_item=(
            "Que Patrick n'a-t-il pas, d'après Joël ?",
            [
                "Deux portes à essayer",
                "Ni diplôme d'ailleurs ni verdict",
                "Le thé de Félicie",
                "Le Cahier du chemin",
            ],
            1,
            "« ni diplôme d'ailleurs ni verdict. »",
        ),
        pairs=[
            ("atelier", "geste fini / mains"),
            ("stage", "trois minutes / oreille"),
            ("ni… ni… ni…", "palais / course / titre"),
            ("portes ouvertes", "essentiel"),
        ],
        fill_item=("On ne décide ___ trop tôt ni sans thé.", "ni"),
        words=["Les", "portes", "restent", "ouvertes", "."],
        anagram=("ecole", "Ni l'un ni l'autre n'est une… d'ailleurs. (sans accent)"),
        error=(
            "Je n'ai pas ni la maîtrise du fil ni celle du micro, et je recommence sans honte.",
            "Je n'ai ni la maîtrise du fil ni celle du micro, et je recommence sans honte.",
            "Ne… ni… : pas de pas devant ni.",
        ),
        pic_start=18,
        pic_words=["un banc", "un livre", "une radio", "un groupe"],
        short_p="Imitez : quinze lignes, trois ne… ni… ni…, deux différences claires, une probabilité, un essentiel que.",
        audio="Lisez votre comparaison, sans aller trop vite.",
    ),
    _l(
        "EL",
        "EL — Ne… ni… ni… et comparaison de modèles",
        "Retenir la négation multiple et les axes de comparaison des deux initiatives.",
        "Apprenez la fiche.",
        "Fiche d'Aline, ni et différences",
        """Ne… ni… ni… : on nie plus d'un élément (je n'ai ni titre ni verdict ni honte).
Ni l'un ni l'autre + ne + verbe : ni l'un ni l'autre n'est une école d'ailleurs.
Pas : je n'ai pas ni. Pas : ni l'un ou l'autre. Pas : ni… ou…
Atelier sous le figuier : mesurer, tendre, geste fini, mains, silence des mains.
Stage à Radio Figuier : écouter, couper à trois minutes, casque, oreille, silence de l'antenne.
Comparer : plus / moins / ni plus noble ni plus petit. On décrit une différence, on ne fait pas une guerre.
On ne compare ni pour trahir ni pour idéaliser ni pour fermer une porte.
Réemploi : il est peu probable que l'un remplace l'autre ; il se peut que les deux tiennent ; il est essentiel que les portes restent ouvertes.
Aucun nom d'école d'ailleurs, aucune ville lointaine.
Attention : accord (ni les mains ni l'oreille ne suffisent). À + le = au figuier, à l'antenne.
Une initiative de cour se dit avec des gestes, pas avec un titre emprunté.
Les deux modèles restent ouverts : figuier le matin, antenne le jeudi.""",
        tf_item=(
            "On dit « je n'ai pas ni titre ni verdict ».",
            False,
            "Je n'ai ni titre ni verdict.",
        ),
        qcm_item=(
            "Quelle forme est correcte ?",
            [
                "Ni l'un ou l'autre n'est",
                "Ni l'un ni l'autre n'est une école d'ailleurs",
                "Je n'ai pas ni titre",
                "Ni titre ou verdict",
            ],
            1,
            "Ni l'un ni l'autre n'est.",
        ),
        pairs=[
            ("ne… ni… ni…", "plus d'un élément"),
            ("atelier", "mains / geste fini"),
            ("stage", "oreille / trois minutes"),
            ("ni pour trahir ni pour idéaliser", "comparer juste"),
        ],
        fill_item=("Ni l'un ni l'autre ___ une école d'ailleurs. (être, présent)", "n'est"),
        words=["On", "décrit", "une", "différence", "."],
        anagram=("comparer", "Mettre les deux modèles face à face, sans en fermer un."),
        error=(
            "Ni les mains ni l'oreille suffit seules, et les portes restent ouvertes.",
            "Ni les mains ni l'oreille ne suffisent seules, et les portes restent ouvertes.",
            "Sujets coordonnés par ni : verbe au pluriel, suffisent, avec ne.",
        ),
        pic_start=19,
        pic_words=["un livre", "une radio", "un groupe", "un pupitre"],
        short_p="Faites deux listes (atelier / stage) et six phrases en ne… ni… ni…",
        audio="Enregistrez la fiche et six phrases : trois ni, trois comparaisons.",
    ),
]


# ---------------------------------------------------------------------------
# Séquence 5 — Bilan pédagogique d'Aline (EXTRA)
# ---------------------------------------------------------------------------

S5 = [
    _l(
        "CO",
        "CO — Ce que la saison a tenu",
        "Suivre le bilan pédagogique d'Aline et réemployer but, chiffres, doute et comparaison.",
        "Lisez le bilan parlé. Qu'est-ce qui a tenu, et qu'est-ce qui reste fragile ?",
        "Pupitre d'Aline, Cahier du chemin ouvert",
        """Aline : Je cherche un bilan qui puisse se relire, afin que personne n'enfle la saison.
Patrick : Cela montre que dix-huit pages ont tenu ; je ne pense pas que deux cahiers fermés soient un échec.
Léa : On constate que la moitié a osé le relais ; il est essentiel que Joël recommence sans honte.
Marc : Ces chiffres indiquent qu'un geste de main reste plus rare ; encore qu'il faille continuer.
Dieudonné : Il est peu probable que le tampon remplace le coupon ; il se peut que le journal suffise.
Lila : Ni l'atelier ni l'antenne n'a fermé ; il n'est pas sûr que Patrick doive choisir ce soir.
Joël : Je n'ai ni la maîtrise ni la honte ; un bilan qui puisse dire cela, c'est déjà beaucoup.
Rose : On ne compare ni pour trahir ni pour idéaliser : les deux modèles ont tenu le Seuil.
Hawa : Soixante-quinze pour cent de pages, un quart de jeudis : on peut toutefois relancer les six manquantes.
Karim : Solange n'a tamponné ni rumeur ni page illisible : cela aussi se commente.
Félicie : Il se peut que le thé ait tenu le groupe plus qu'un discours.
Mado : J'écrirai le bilan afin qu'il puisse rester honnête, sans titre d'ailleurs.
Yvette : Je ne pense pas qu'un bilan soit un verdict ; il est essentiel qu'il reste une page du Cahier.
Aline : Objectifs, chiffres, doute, différences : quatre portes du bilan, pas un mur.""",
        tf_item=(
            "Aline présente le bilan comme un verdict définitif.",
            False,
            "Yvette et Aline : ce n'est pas un verdict.",
        ),
        qcm_item=(
            "Que montrent les dix-huit pages, selon Patrick ?",
            [
                "Un échec",
                "Que le journal a tenu",
                "La fermeture de l'antenne",
                "Un diplôme d'ailleurs",
            ],
            1,
            "« dix-huit pages ont tenu. »",
        ),
        pairs=[
            ("qui puisse se relire", "bilan / but"),
            ("cela montre que", "18 pages"),
            ("peu probable que", "tampon remplace"),
            ("ni l'atelier ni l'antenne", "n'a fermé"),
        ],
        fill_item=("Je ne pense pas qu'un bilan ___ un verdict. (être, subj.)", "soit"),
        words=["Un", "bilan", "n'est", "pas", "un", "verdict", "."],
        anagram=("bilan", "Page d'Aline : ce qui a tenu, ce qui reste fragile, sans enfler."),
        error=(
            "Je ne pense pas qu'un bilan est un verdict, et il est essentiel qu'il reste une page du Cahier.",
            "Je ne pense pas qu'un bilan soit un verdict, et il est essentiel qu'il reste une page du Cahier.",
            "Je ne pense pas que + subjonctif : soit.",
        ),
        pic_start=20,
        pic_words=["un pupitre", "un soleil", "un nuage", "une feuille"],
        short_p="Notez quatre réussites et quatre fragilités du bilan, avec la formule qui les porte.",
        audio="Enregistrez : Un bilan qui puisse se relire. Cela montre que dix-huit pages ont tenu. Ni l'atelier ni l'antenne n'a fermé. Un bilan n'est pas un verdict.",
    ),
    _l(
        "CE",
        "CE — Bilan pédagogique d'Aline",
        "Lire le bilan argumenté de la saison à l'Atelier d'Aline.",
        "Lisez le bilan, sans aller trop vite.",
        "Bilan d'Aline Uwase",
        """Bilan pédagogique — Atelier d'Aline, saison sèche
Je cherche un bilan qui puisse se relire demain, afin que personne n'enfle ce que la cour a tenu.
Vingt-quatre inscrits, dix-huit pages : cela montre que le Cahier du chemin tient, pour trois sur quatre.
Douze relais, neuf coupons, six jeudis : on constate que l'oreille s'ouvre plus vite que la main, encore qu'il faille continuer.
Trois seconds essais : ces résultats montrent qu'on ose recommencer ; je ne pense pas que deux cahiers fermés soient un échec.
Il est peu probable que le tampon de cour remplace un geste ; il se peut que le journal suffise ; il n'est pas sûr que Patrick doive choisir ce soir.
Ni l'atelier sous le figuier ni le stage à Radio Figuier n'a fermé : on ne compare ni pour trahir ni pour idéaliser.
L'atelier n'est ni un palais ni une course ; le stage n'est ni une scène ni un cri. Les mains et l'oreille se répondent.
Solange n'a tamponné ni rumeur ni page illisible ; Karim l'a lu sans enfler.
Il est essentiel que les six pages manquantes soient relancées, afin que le silence ne s'installe pas.
Il se peut que le thé de Félicie ait tenu le groupe plus qu'un discours : ce n'est pas rien.
Ce bilan n'emprunte ni un nom d'école d'ailleurs ni un verdict. C'est une page du Cahier du chemin.
Aline Uwase — formatrice, Seuil des Sources
Copie : Dieudonné, Lila, Patrick, Mado""",
        tf_item=(
            "Aline écrit que l'oreille s'ouvre plus vite que la main.",
            True,
            "« l'oreille s'ouvre plus vite que la main. »",
        ),
        qcm_item=(
            "Que Aline ne pense-t-elle pas que deux cahiers fermés soient ?",
            [
                "Une page",
                "Un échec",
                "Un relais",
                "Un thé",
            ],
            1,
            "« je ne pense pas que deux cahiers fermés soient un échec. »",
        ),
        pairs=[
            ("18 / 24", "le journal tient"),
            ("oreille / main", "s'ouvre plus vite"),
            ("tampon", "peu probable qu'il remplace"),
            ("ni atelier ni stage", "n'a fermé"),
        ],
        fill_item=("Il est essentiel que les six pages ___ relancées. (être, subj.)", "soient"),
        words=["Ce", "bilan", "n'est", "pas", "un", "verdict", "."],
        anagram=("pedagogie", "Travail d'Aline : objectifs, gestes, doutes, sans titre d'ailleurs. (sans accent)"),
        error=(
            "Il est essentiel que les six pages sont relancées, et le Cahier reste le journal.",
            "Il est essentiel que les six pages soient relancées, et le Cahier reste le journal.",
            "Il est essentiel que + subjonctif : soient.",
        ),
        pic_start=21,
        pic_words=["un soleil", "un nuage", "une feuille", "un figuier"],
        short_p="Recopiez le bilan et classez : but, chiffre, doute, ni… ni, essentiel.",
        audio="Lisez le bilan d'Aline, sans aller trop vite.",
    ),
    _l(
        "PO",
        "PO — Dire le bilan de la saison",
        "Réemployer à l'oral les formules du module pour un bilan honnête.",
        "Répétez, puis dites ce qui a tenu et ce qui reste à relancer.",
        "Modèles d'Aline et de Mado",
        """Un bilan qui puisse se relire.
Afin que personne n'enfle.
Cela montre que le journal tient.
On constate que l'oreille s'ouvre.
Je ne pense pas que deux silences soient un échec.
Il est essentiel que l'on relance.
Il est peu probable que le tampon remplace.
Il se peut que le journal suffise.
Ni l'atelier ni l'antenne n'a fermé.
On ne compare ni pour trahir ni pour idéaliser.
Un bilan n'est pas un verdict.
Les mains et l'oreille se répondent.
Aline : quatre portes, pas un mur.
Patrick : j'essaierai encore les deux.""",
        tf_item=(
            "Le bilan réemploie but, commentaire, doute et comparaison.",
            True,
            "Aline : quatre portes.",
        ),
        qcm_item=(
            "Quelle phrase dit correctement le doute sur le tampon ?",
            [
                "Il est peu probable que le tampon remplacera",
                "Il est peu probable que le tampon remplace",
                "Il se peut le journal suffire",
                "Je n'ai pas ni atelier ni antenne",
            ],
            1,
            "Peu probable que + subjonctif.",
        ),
        pairs=[
            ("qui puisse", "bilan relisible"),
            ("cela montre que", "journal"),
            ("peu probable que", "tampon"),
            ("ni… ni…", "atelier / antenne"),
        ],
        fill_item=("Ni l'atelier ni l'antenne ___ fermé.", "n'a"),
        words=["Un", "bilan", "n'est", "pas", "un", "verdict", "."],
        anagram=("relancer", "Ce qu'il faut faire des six pages manquantes, sans juger trop vite."),
        error=(
            "Ni l'atelier ni l'antenne n'ont fermé uniquement la cour, et le bilan reste une page.",
            "Ni l'atelier ni l'antenne n'a fermé uniquement la cour, et le bilan reste une page.",
            "Ni l'un ni l'autre + verbe au singulier ici : n'a fermé.",
        ),
        pic_start=22,
        pic_words=["un nuage", "une feuille", "un figuier", "une craie"],
        short_p="Écrivez un oral de bilan en dix phrases : deux par porte (but, chiffre, doute, ni, essentiel).",
        audio="Enregistrez les huit premiers modèles, puis votre bilan en une minute.",
    ),
    _l(
        "PE",
        "PE — Mon bilan de saison",
        "Écrire un bilan pédagogique argumenté, à la manière d'Aline.",
        "Imitez le bilan de Léa Niyonzima, sans aller trop vite.",
        "Bilan de Léa Niyonzima",
        """Léa Niyonzima — bilan d'une oreille, pour Aline
Je cherche un bilan qui puisse se relire, afin que je n'enfle ni le relais ni le silence de Joël.
Cela montre que douze voix ont osé trois minutes ; on constate que l'oreille s'ouvre, encore que la main reste plus rare.
Je ne pense pas que deux cahiers fermés soient un échec ; il est essentiel que Mado les relance, afin qu'ils puissent s'ouvrir.
Il est peu probable que le tampon de Solange remplace un geste ; il se peut que le Cahier suffise ; il n'est pas sûr que Patrick doive choisir.
Ni l'atelier ni l'antenne n'a fermé : on ne compare ni pour trahir ni pour idéaliser.
L'atelier n'est ni un palais ni une course ; le stage n'est ni une scène ni un cri.
Dieudonné a dit qu'un geste fini valait mieux qu'un titre ; Lila a demandé si trois minutes tenaient : on me l'a confirmé.
Il se peut que le thé ait tenu le groupe ; ce n'est pas rien.
Ce bilan n'emprunte ni un nom d'école d'ailleurs ni un verdict. C'est une page du Cahier du chemin.
Léa
Copie : Aline Uwase — Seuil des Sources""",
        tf_item=(
            "Léa emprunte un nom d'école d'ailleurs pour signer son bilan.",
            False,
            "« n'emprunte ni un nom d'école d'ailleurs ni un verdict. »",
        ),
        qcm_item=(
            "Que Dieudonné a-t-il dit, d'après Léa ?",
            [
                "Qu'un titre valait mieux qu'un geste",
                "Qu'un geste fini valait mieux qu'un titre",
                "Qu'il fallait fermer l'antenne",
                "Que le thé était interdit",
            ],
            1,
            "« un geste fini valait mieux qu'un titre. »",
        ),
        pairs=[
            ("qui puisse se relire", "bilan"),
            ("cela montre que", "douze voix"),
            ("ni atelier ni antenne", "n'a fermé"),
            ("Cahier du chemin", "page, pas verdict"),
        ],
        fill_item=("Il n'est pas sûr que Patrick ___ choisir. (devoir, subj.)", "doive"),
        words=["Ce", "n'est", "pas", "rien", "."],
        anagram=("saison", "Période sèche de l'Atelier d'Aline, celle que le bilan relit."),
        error=(
            "Je ne pense pas que deux cahiers fermés sont un échec, et il est essentiel que Mado les relance.",
            "Je ne pense pas que deux cahiers fermés soient un échec, et il est essentiel que Mado les relance.",
            "Je ne pense pas que + subjonctif : soient.",
        ),
        pic_start=23,
        pic_words=["une feuille", "un figuier", "une craie", "une horloge"],
        short_p="Imitez : quinze lignes, but, chiffres, trois doutes, ne… ni… ni…, pas de verdict.",
        audio="Lisez votre bilan, sans aller trop vite.",
    ),
    _l(
        "EL",
        "EL — Langue du bilan pédagogique",
        "Relier dans un même texte but, commentaire, probabilité et comparaison.",
        "Apprenez la fiche.",
        "Fiche de synthèse du bilan",
        """Réemploi 1 — but : un bilan qui puisse se relire ; afin que personne n'enfle.
Réemploi 2 — opinion : je ne pense pas que ce soit un échec ; il est essentiel que l'on relance.
Réemploi 3 — chiffres : cela montre que ; on constate que ; ces chiffres indiquent que.
Réemploi 4 — probabilité : peu probable que ; il se peut que ; il n'est pas sûr que.
Réemploi 5 — ni… ni… : ni l'atelier ni l'antenne ; on ne compare ni pour trahir ni pour idéaliser.
Un bilan n'est pas un verdict. Le Cahier du chemin en est le lieu, pas un diplôme d'ailleurs.
Modes : subjonctif après but, opinion négative, essentiel, peu probable, il se peut, il n'est pas sûr.
Indicatif après cela montre que, on constate que, je pense que.
Ni l'un ni l'autre n'a / n'est. Pas : je n'ai pas ni.
Attention : soient / doive / faille / puisse. Il faut (pas je faut).
La formatrice signe Aline Uwase. Les portes restent ouvertes.
Un bilan honnête relie les chiffres aux gestes, sans en faire un verdict.""",
        tf_item=(
            "« Cela montre que » prend le subjonctif.",
            False,
            "Indicatif après cela montre que.",
        ),
        qcm_item=(
            "Quelle série est correcte pour le bilan ?",
            [
                "qui peut (but) / je n'ai pas ni / peu probable que remplacera",
                "qui puisse / je ne pense pas que ce soit / ni l'atelier ni l'antenne",
                "afin que on ose sans subj. / cela montrent / ni l'un ou l'autre",
                "il est essentiel que c'est / je faut relancer / un verdict obligatoire",
            ],
            1,
            "Puisse, soit, ni… ni…",
        ),
        pairs=[
            ("qui puisse / afin que", "but"),
            ("cela montre que", "indicatif"),
            ("peu probable que", "subjonctif"),
            ("ni… ni…", "deux modèles"),
        ],
        fill_item=("Afin que personne ___ la saison. (enfler, subj.)", "n'enfle"),
        words=["Les", "portes", "restent", "ouvertes", "."],
        anagram=("formatrice", "Rôle d'Aline à l'Atelier : elle forme, elle ne juge pas trop vite."),
        error=(
            "Cela montrent que le journal tient, et il est essentiel que l'on relance les six pages.",
            "Cela montre que le journal tient, et il est essentiel que l'on relance les six pages.",
            "Cela : singulier, montre.",
        ),
        pic_start=24,
        pic_words=["un figuier", "une craie", "une horloge", "un cœur"],
        short_p="Rédigez un tableau : cinq réemplois, un exemple tiré du bilan d'Aline.",
        audio="Enregistrez la fiche et cinq phrases, une par réemploi.",
    ),
]


# ---------------------------------------------------------------------------
# Séquence 6 — Projet d'école de la cour (EXTRA manifeste)
# ---------------------------------------------------------------------------

S6 = [
    _l(
        "CO",
        "CO — Manifeste sous le figuier",
        "Comprendre un projet d'école de la cour et les formules d'un manifeste éducatif.",
        "Lisez le dialogue. Quels articles du manifeste entend-on ?",
        "Cour du figuier, feuille de manifeste",
        """Aline : Nous signerons un manifeste pour l'école de la cour. Elle n'est ni une école d'ailleurs ni un palais.
Patrick : Je cherche une école qui puisse tenir sous le figuier, afin que le Cahier du chemin reste le journal.
Léa : Il est essentiel que les deux portes restent ouvertes, encore que chacun tienne à son banc.
Marc : Il est peu probable qu'un tampon remplace un geste ; il se peut que la page suffise.
Dieudonné : L'école de la cour n'est ni un titre ni une course : on mesure, on tend, on voit.
Lila : Ni scène ni cri : un stage d'oreille, trois minutes, un casque posé.
Joël : Je ne pense pas que l'on apprenne trop vite ; on ne décide ni trop tôt ni sans thé.
Rose : On ne compare ni pour trahir ni pour idéaliser ; les mains et l'oreille se répondent.
Hawa : Cela montre que la saison a tenu ; on constate qu'il reste six pages à relancer.
Karim : Solange ne tamponnera ni rumeur ni page illisible ; le Bureau lit, il ne gouverne pas l'école.
Félicie : Il se peut que le thé soit déjà une leçon ; ce n'est pas rien.
Mado : J'écrirai le manifeste afin qu'il puisse se relire, sans nom d'ailleurs.
Yvette : Un manifeste n'est pas un verdict ; c'est une promesse de cour.
Aline : École de la cour : inventée ici. Atelier d'Aline, Cahier du chemin, deux portes, pas de ville lointaine.""",
        tf_item=(
            "Aline situe l'école de la cour ici, sans ville lointaine.",
            True,
            "Dernière réplique.",
        ),
        qcm_item=(
            "Que Patrick cherche-t-il ?",
            [
                "Une école d'ailleurs",
                "Une école qui puisse tenir sous le figuier",
                "Un palais",
                "Un verdict",
            ],
            1,
            "« une école qui puisse tenir sous le figuier. »",
        ),
        pairs=[
            ("école de la cour", "inventée ici"),
            ("qui puisse tenir", "sous le figuier"),
            ("deux portes", "atelier / antenne"),
            ("Cahier du chemin", "journal"),
        ],
        fill_item=("L'école de la cour n'est ___ une école d'ailleurs ni un palais.", "ni"),
        words=["Un", "manifeste", "n'est", "pas", "un", "verdict", "."],
        anagram=("manifeste", "Texte promis sous le figuier : articles d'une école inventée."),
        error=(
            "Je cherche une école qui peut tenir sous le figuier, et afin que le Cahier reste le journal.",
            "Je cherche une école qui puisse tenir sous le figuier, et afin que le Cahier reste le journal.",
            "Relative de but : qui puisse.",
        ),
        pic_start=25,
        pic_words=["une craie", "une horloge", "un cœur", "un objectif"],
        short_p="Notez six articles du manifeste et la formule (but, ni, doute, chiffre) qui les porte.",
        audio="Enregistrez : Une école qui puisse tenir sous le figuier. Ni une école d'ailleurs ni un palais. Le Cahier reste le journal. Un manifeste n'est pas un verdict.",
    ),
    _l(
        "CE",
        "CE — Manifeste de l'école de la cour",
        "Lire le manifeste éducatif argumenté du Seuil.",
        "Lisez le manifeste, sans aller trop vite.",
        "Manifeste — école de la cour",
        """Manifeste pour l'école de la cour — Seuil des Sources
Nous cherchons une école qui puisse tenir sous le figuier, afin que personne n'emprunte un nom d'ailleurs.
Elle n'est ni un palais ni une course ni un titre : elle est l'Atelier d'Aline le matin, Radio Figuier le jeudi.
Il est essentiel que les deux portes restent ouvertes, encore que chacun tienne à son banc.
Le Cahier du chemin est le journal : nous ne pensons pas qu'il soit un diplôme ; il est peu probable qu'un tampon le remplace.
Il se peut que la feuille de tenue rassure ; il n'est pas sûr que tout le monde en ait besoin.
Cela montre que dix-huit pages ont tenu ; on constate que l'oreille s'ouvre ; ces chiffres indiquent que la main demande plus de temps.
On ne compare ni pour trahir ni pour idéaliser : l'atelier forme les mains, le stage forme l'oreille.
On ne décide ni trop tôt ni sans thé ni sans avoir entendu les deux voix.
Solange ne tamponnera ni rumeur ni page illisible ; le Bureau lit, il ne gouverne pas l'école.
Il est essentiel que l'on ose recommencer, afin que la honte reste dehors.
Ce manifeste n'est pas un verdict : c'est une promesse de cour, relisible demain.
Signataires : Aline Uwase, Dieudonné Hakizimana, Lila Sow, Patrick Habimana, Mado
École de la cour — Rukiri-Nord
Aucune ville lointaine, aucun nom emprunté.""",
        tf_item=(
            "Le manifeste présente le Cahier du chemin comme un diplôme.",
            False,
            "« nous ne pensons pas qu'il soit un diplôme. »",
        ),
        qcm_item=(
            "Que le Bureau fait-il, selon le manifeste ?",
            [
                "Il gouverne l'école",
                "Il lit, il ne gouverne pas l'école",
                "Il ferme les portes",
                "Il impose un titre d'ailleurs",
            ],
            1,
            "« le Bureau lit, il ne gouverne pas l'école. »",
        ),
        pairs=[
            ("qui puisse tenir", "sous le figuier"),
            ("ni palais ni course ni titre", "école de la cour"),
            ("Cahier", "journal, pas diplôme"),
            ("deux portes", "atelier / jeudi radio"),
        ],
        fill_item=("Nous ne pensons pas qu'il ___ un diplôme. (être, subj.)", "soit"),
        words=["C'est", "une", "promesse", "de", "cour", "."],
        anagram=("promesse", "Le manifeste en est une : tenir l'école de la cour demain."),
        error=(
            "Nous ne pensons pas qu'il est un diplôme, et le Cahier reste le journal.",
            "Nous ne pensons pas qu'il soit un diplôme, et le Cahier reste le journal.",
            "Ne penser pas que + subjonctif : soit.",
        ),
        pic_start=26,
        pic_words=["une horloge", "un cœur", "un objectif", "un subjonctif"],
        short_p="Recopiez le manifeste et soulignez but, ni… ni, doute, chiffres, essentiel.",
        audio="Lisez le manifeste, sans aller trop vite.",
    ),
    _l(
        "PO",
        "PO — Dire un article du manifeste",
        "Prononcer un article de l'école de la cour avec les formules du module.",
        "Répétez, puis proposez un article à vous, sans nom d'ailleurs.",
        "Modèles d'Aline et de Patrick",
        """Une école qui puisse tenir sous le figuier.
Afin que le Cahier reste le journal.
Elle n'est ni un palais ni une course ni un titre.
Il est essentiel que les deux portes restent ouvertes.
Nous ne pensons pas que ce soit un diplôme.
Il est peu probable qu'un tampon remplace un geste.
On ne compare ni pour trahir ni pour idéaliser.
On ne décide ni trop tôt ni sans thé.
Cela montre que la saison a tenu.
Un manifeste n'est pas un verdict.
C'est une promesse de cour.
Dieudonné : un geste fini.
Lila : trois minutes, une oreille.
Aline : inventée ici, relisible demain.""",
        tf_item=(
            "Un article du manifeste peut mêler but, négation multiple et doute.",
            True,
            "Les modèles le font.",
        ),
        qcm_item=(
            "Quelle phrase ouvre correctement le manifeste ?",
            [
                "Une école qui peut tenir afin que le Cahier est le journal",
                "Une école qui puisse tenir sous le figuier",
                "Une école d'ailleurs seulement",
                "Un verdict obligatoire ce soir",
            ],
            1,
            "Qui puisse + lieu inventé.",
        ),
        pairs=[
            ("qui puisse", "tenir sous le figuier"),
            ("ni… ni… ni…", "palais / course / titre"),
            ("pas un diplôme", "Cahier / journal"),
            ("promesse de cour", "manifeste"),
        ],
        fill_item=("Un manifeste n'est pas un ___ .", "verdict"),
        words=["C'est", "une", "promesse", "de", "cour", "."],
        anagram=("cour", "École de la… : le lieu inventé, sous le figuier."),
        error=(
            "Il est essentiel que les deux portes restent ouvertes, et nous ne pensons pas que ce est un diplôme.",
            "Il est essentiel que les deux portes restent ouvertes, et nous ne pensons pas que ce soit un diplôme.",
            "Ne penser pas que + subjonctif : soit.",
        ),
        pic_start=27,
        pic_words=["un cœur", "un objectif", "un subjonctif", "un atelier"],
        short_p="Écrivez six articles oraux : but, ni… ni, essentiel, doute, chiffre, promesse.",
        audio="Enregistrez les huit premiers modèles, puis un article à vous.",
    ),
    _l(
        "PE",
        "PE — Mon manifeste éducatif",
        "Écrire un manifeste pour l'école de la cour, argumenté et local.",
        "Imitez le manifeste de Patrick Habimana, sans aller trop vite.",
        "Manifeste de Patrick Habimana",
        """Patrick Habimana — pour l'école de la cour
Je cherche une école qui puisse tenir sous le figuier, afin que le Cahier du chemin reste mon journal, non un diplôme.
Elle n'est ni un palais ni une course ni un titre d'ailleurs : elle est l'atelier de Dieudonné le matin, l'antenne de Lila le jeudi.
Il est essentiel que les deux portes restent ouvertes, encore que je doive un jour choisir un banc.
Je ne pense pas qu'un tampon remplace un geste ; il est peu probable qu'il couse ; il se peut toutefois qu'il rassure.
Il n'est pas sûr que j'en aie besoin demain ; il se peut qu'une page tenue suffise.
Cela montre que la saison a attiré vingt-quatre voix ; on constate que dix-huit pages ont tenu ; ces chiffres indiquent qu'il reste à relancer.
On ne compare ni pour trahir ni pour idéaliser : les mains et l'oreille se répondent.
On ne décide ni trop tôt ni sans thé ni sans avoir entendu Aline.
Ce manifeste n'est pas un verdict : c'est une promesse de cour, relisible au Cahier.
Aucune ville lointaine, aucun nom emprunté. École de la cour, Seuil des Sources.
Patrick
Copie : Aline Uwase, Mado""",
        tf_item=(
            "Patrick veut que le Cahier devienne un diplôme.",
            False,
            "Il reste son journal, non un diplôme.",
        ),
        qcm_item=(
            "Où l'école de Patrick se tient-elle le jeudi ?",
            [
                "Dans un palais",
                "À l'antenne de Lila",
                "Dans une ville lointaine",
                "Au Bureau seulement",
            ],
            1,
            "« l'antenne de Lila le jeudi. »",
        ),
        pairs=[
            ("qui puisse tenir", "sous le figuier"),
            ("ni palais ni course ni titre", "école de la cour"),
            ("tampon", "peu probable qu'il remplace"),
            ("promesse de cour", "pas un verdict"),
        ],
        fill_item=("Encore que je ___ un jour choisir un banc. (devoir, subj.)", "doive"),
        words=["C'est", "une", "promesse", "de", "cour", "."],
        anagram=("figuier", "Arbre sous lequel l'école de la cour peut tenir."),
        error=(
            "Je ne pense pas qu'un tampon remplace un geste, et il se peut que une page tenue suffise.",
            "Je ne pense pas qu'un tampon remplace un geste, et il se peut qu'une page tenue suffise.",
            "Que + une s'élide : qu'une.",
        ),
        pic_start=28,
        pic_words=["un objectif", "un subjonctif", "un atelier", "un cahier"],
        short_p="Imitez : un manifeste de quinze à dix-huit lignes, école de la cour, toutes les formules du module.",
        audio="Lisez votre manifeste, sans aller trop vite.",
    ),
    _l(
        "EL",
        "EL — Langue du manifeste éducatif",
        "Retenir les formules qui portent l'école de la cour.",
        "Apprenez la fiche.",
        "Fiche de clôture, école de la cour",
        """L'école de la cour est inventée au Seuil : Atelier d'Aline, Radio Figuier, Cahier du chemin.
Relative de but : une école qui puisse tenir. Afin que + subj. : afin que le journal reste.
Opinion : je ne pense pas que ce soit un diplôme ; il est essentiel que les portes restent ouvertes.
Chiffres : cela montre que ; on constate que ; ces chiffres indiquent que.
Probabilité : peu probable que ; il se peut que ; il n'est pas sûr que — subjonctif.
Ne… ni… ni… : ni palais ni course ni titre ; on ne compare ni pour trahir ni pour idéaliser.
Un manifeste n'est pas un verdict ; c'est une promesse de cour.
Pas de ville lointaine, pas de nom emprunté, pas de diplôme d'ailleurs.
Tampon de cour et feuille de tenue peuvent accompagner ; ils ne remplacent pas le geste.
Attention : puisse / soit / doive / ait / vaille / soient. Il faut (pas je faut).
À + le = au Seuil, au Cahier. Qu'une / qu'il / qu'on.
On signe après le thé, on relit demain.""",
        tf_item=(
            "Le manifeste accepte un nom d'école d'ailleurs.",
            False,
            "Pas de nom emprunté, pas de ville lointaine.",
        ),
        qcm_item=(
            "Quelle série porte correctement le manifeste ?",
            [
                "qui peut (but) / je n'ai pas ni / peu probable que remplacera",
                "qui puisse / ni palais ni titre / il se peut que la page suffise",
                "afin que c'est / cela montrent / ni l'un ou l'autre",
                "je faut / un verdict / une ville lointaine",
            ],
            1,
            "Puisse, ni… ni, il se peut que + subj.",
        ),
        pairs=[
            ("école de la cour", "inventée au Seuil"),
            ("Cahier du chemin", "journal"),
            ("deux portes", "atelier / radio"),
            ("promesse", "pas un verdict"),
        ],
        fill_item=("Une école ___ puisse tenir sous le figuier.", "qui"),
        words=["On", "signe", "après", "le", "thé", "."],
        anagram=("inventee", "L'école de la cour est… ici, pas ailleurs. (sans accent)"),
        error=(
            "À le Seuil on signe le manifeste après le thé, et le Cahier reste le journal.",
            "Au Seuil on signe le manifeste après le thé, et le Cahier reste le journal.",
            "À + le = au.",
        ),
        pic_start=29,
        pic_words=["un subjonctif", "un atelier", "un cahier", "un résultat"],
        short_p="Rédigez un tableau final : dix articles possibles du manifeste, chacun avec un point de langue.",
        audio="Enregistrez la fiche et cinq articles, chacun avec une formule différente.",
    ),
]


SEQUENCES = [
    {"title": "Objectifs et expériences novatrices", "lessons": S1},
    {"title": "Expliquer et commenter des résultats", "lessons": S2},
    {"title": "L'utilité des diplômes", "lessons": S3},
    {"title": "Une initiative, des différences", "lessons": S4},
    {"title": "Bilan pédagogique d'Aline", "lessons": S5},
    {"title": "Projet d'école de la cour", "lessons": S6},
]

