"""B1 Module 6 — S'informer, s'exprimer (univers Seuil des Sources)."""

from factory import L

IMG = "mfk-b1-m6"
IMG_DIR = IMG

MODULE = {
    "title": "B1 — S'informer, s'exprimer",
    "description": (
        "Grande étape B1-6 : analyser une source, relater un fait, "
        "démasquer une rumeur, tenir le micro, préparer le journal parlé "
        "et respecter l'éthique de l'antenne — à Radio Figuier, entre "
        "la rumeur du Marché des Lampions et la nouvelle vérifiée de "
        "la rivière, au Seuil des Sources (Rukiri-Nord)."
    ),
}


def _l(comp, title, obj, cons, st, sp, **kw):
    return L(IMG, comp, title, obj, cons, st, sp, **kw)


# ---------------------------------------------------------------------------
# Séquence 1 — Lire une source (concession, passif, médias)
# ---------------------------------------------------------------------------

S1 = [
    _l(
        "CO",
        "CO — Quelle source à l'antenne ?",
        "Analyser une source : média traditionnel ou voix du marché ; concession et passif.",
        "Lisez le dialogue (à écouter avec l'enseignant). Quelle source est vérifiée ?",
        "Studio de Radio Figuier, casque de Léa",
        """Léa : J'ai lu la Feuille du Seuil. C'est une source écrite, pesée par Lila.
Marc : Au Marché des Lampions, une voix a couru sans nom. Ce n'est pas une source.
Aline : Un média traditionnel, ici, c'est Radio Figuier ou la Feuille du Seuil.
Patrick : Un média social de la cour, c'est une phrase répétée de banc en banc.
Hawa : Bien que la rumeur circule, la crue n'a pas été confirmée.
Joël : Pourtant, le marché était inquiet dès l'aube.
Lila : Cependant, chaque fait a été pesé avant l'antenne.
Karim : Néanmoins, on relatera seulement ce qui a été vu à la rivière.
Solange : La nouvelle a été lue à sept heures. Elle a été reprise par Hawa.
Mado : D'après le Bureau des Escales, le pont des Herbes tient encore.
Sami : Selon Dieudonné, l'eau est haute, mais la cour n'est pas inondée.
Dieudonné : Rien n'a été inventé : le niveau a été mesuré ce matin.""",
        tf_item=(
            "Hawa dit que la crue a été confirmée.",
            False,
            "Hawa : « la crue n'a pas été confirmée. »",
        ),
        qcm_item=(
            "Selon Aline, un média traditionnel du Seuil, c'est…",
            [
                "une voix sans nom au marché",
                "Radio Figuier ou la Feuille du Seuil",
                "un cri sous le figuier",
                "un message inventé",
            ],
            1,
            "Aline nomme Radio Figuier et la Feuille du Seuil.",
        ),
        pairs=[
            ("bien que + subjonctif", "Hawa / circule"),
            ("pourtant", "Joël"),
            ("cependant", "Lila"),
            ("néanmoins", "Karim"),
        ],
        fill_item=("Bien que la rumeur ___, la crue n'a pas été confirmée.", "circule"),
        words=["La", "nouvelle", "a", "été", "lue", "."],
        anagram=("pourtant", "Joël l'emploie : un lien d'opposition, pas bien que."),
        error=(
            "Bien que la rumeur circule, la crue a confirmé ce matin.",
            "Bien que la rumeur circule, la crue n'a pas été confirmée.",
            "Passif : a été confirmée. Hawa nie la crue.",
        ),
        pic_start=0,
        pic_words=["une source", "une concession", "la voix passive", "deux médias"],
        short_p="Notez deux sources vérifiées et deux voix non vérifiées.",
        audio="Enregistrez : Bien que la rumeur circule, le fait a été pesé. Pourtant le marché était inquiet.",
    ),
    _l(
        "CE",
        "CE — Deux colonnes au tableau",
        "Lire une analyse de sources : médias de la cour contre voix du marché.",
        "Lisez le tableau, sans aller trop vite.",
        "Tableau ocre, Salle des Herbes",
        """Feuille d'Aline Uwase — Lire une source
Colonne 1 — médias de la cour : Radio Figuier, Feuille du Seuil, Bureau des Escales.
Colonne 2 — voix du marché : une phrase sans auteur, un cri répété, un geste inquiet.
On relate un fait : on dit ce qui a été vu, mesuré, signé.
On ne relate pas une peur : on la nomme comme rumeur.
Bien que le marché parle fort, le niveau a été mesuré par Dieudonné.
Pourtant certains bancs restent tendus.
Cependant Lila n'ouvrira l'antenne que sur un fait pesé.
Néanmoins Karim notera la rumeur à part, dans le Cahier du chemin.
Règle : bien que + subjonctif ; pourtant / cependant / néanmoins + indicatif.
Passif : le niveau a été mesuré ; la nouvelle a été lue.
Seuil des Sources — Rukiri-Nord""",
        tf_item=(
            "Karim jette la rumeur : il ne la note pas.",
            False,
            "« Karim notera la rumeur à part, dans le Cahier du chemin. »",
        ),
        qcm_item=(
            "Qui a mesuré le niveau de l'eau ?",
            ["Marc", "Mado", "Dieudonné", "Sami"],
            2,
            "« mesuré par Dieudonné. »",
        ),
        pairs=[
            ("Radio Figuier", "média de la cour"),
            ("phrase sans auteur", "voix du marché"),
            ("bien que", "subjonctif"),
            ("pourtant", "indicatif"),
        ],
        fill_item=("Bien que le marché parle fort, le niveau ___ été mesuré.", "a"),
        words=["La", "nouvelle", "a", "été", "lue", "."],
        anagram=("cependant", "Lila l'écrit : un autre mot de concession, pas pourtant."),
        error=(
            "Bien que le marché parle fort, le niveau a mesurer par Dieudonné.",
            "Bien que le marché parle fort, le niveau a été mesuré par Dieudonné.",
            "Passif : a été mesuré.",
        ),
        pic_start=1,
        pic_words=["une concession", "un passif", "deux médias", "un récit"],
        short_p="Recopiez les deux colonnes et ajoutez une source de la cour.",
        audio="Lisez les deux colonnes, sans aller trop vite.",
    ),
    _l(
        "PO",
        "PO — Relater sans céder à la rumeur",
        "Relater un fait à l'oral : concession et voix passive.",
        "Répétez les modèles, puis relatez un fait du Seuil.",
        "Modèles de Lila Sow",
        """Bien que la rumeur circule, le pont tient.
Pourtant le marché était inquiet.
Cependant le fait a été vérifié.
Néanmoins on ouvrira l'antenne à huit heures.
La nouvelle a été lue par Hawa.
Le niveau a été mesuré ce matin.
Rien n'a été inventé.
On relatera seulement ce qui a été vu.
D'après Solange, le dossier est clair.
Selon Dieudonné, l'eau est haute.
Ce n'est pas une source : c'est une voix sans nom.
Radio Figuier pèse chaque phrase.""",
        tf_item=(
            "« Bien que » demande le subjonctif.",
            True,
            "Bien que la rumeur circule.",
        ),
        qcm_item=(
            "Quelle phrase est au passif ?",
            [
                "Le pont tient",
                "Le marché était inquiet",
                "Le niveau a été mesuré",
                "On ouvrira l'antenne",
            ],
            2,
            "A été + participe.",
        ),
        pairs=[
            ("bien que", "subjonctif"),
            ("pourtant", "opposition"),
            ("a été lue", "passif"),
            ("d'après", "source nommée"),
        ],
        fill_item=("Le niveau ___ été mesuré ce matin.", "a"),
        words=["Rien", "n'a", "été", "inventé", "."],
        anagram=("neanmoins", "Karim l'emploie : concession, sans accent."),
        error=(
            "Bien que la rumeur circule, le fait a vérifier hier.",
            "Bien que la rumeur circule, le fait a été vérifié.",
            "Passif : a été vérifié.",
        ),
        pic_start=2,
        pic_words=["un passif", "deux médias", "un récit", "un fait passé"],
        short_p="Écrivez six phrases : deux bien que, deux pourtant, deux passifs.",
        audio="Enregistrez les modèles, puis deux faits relatés à vous.",
    ),
    _l(
        "PE",
        "PE — Ma note de source",
        "Écrire une courte analyse de source avec concession et passif.",
        "Imitez la note de Patrick, sans aller trop vite.",
        "Note de Patrick Habimana, Cahier du chemin",
        """Patrick Habimana
J'ai lu deux sources ce matin.
La Feuille du Seuil a été signée par Solange. C'est une source.
Au Marché des Lampions, une voix a couru sans nom. Ce n'est pas une source.
Bien que le marché parle fort, la crue n'a pas été confirmée.
Pourtant les paniers étaient déjà plus hauts.
Cependant le niveau a été mesuré par Dieudonné.
Néanmoins je relaterai seulement le chiffre vu à la rivière.
Patrick
Radio Figuier — Rukiri-Nord""",
        tf_item=(
            "Patrick traite la voix du marché comme une source signée.",
            False,
            "« Ce n'est pas une source. »",
        ),
        qcm_item=(
            "Qui a signé la Feuille du Seuil ?",
            ["Lila", "Hawa", "Solange", "Marc"],
            2,
            "« signée par Solange. »",
        ),
        pairs=[
            ("Feuille du Seuil", "source"),
            ("voix sans nom", "pas une source"),
            ("bien que", "marché / crue"),
            ("a été mesuré", "Dieudonné"),
        ],
        fill_item=("Bien que le marché parle fort, la crue n'a pas ___ confirmée.", "été"),
        words=["Pourtant", "les", "paniers", "étaient", "déjà", "plus", "hauts", "."],
        anagram=("relaterai", "Patrick le fera : dire le fait, au futur."),
        error=(
            "La Feuille du Seuil a signé par Solange ce matin.",
            "La Feuille du Seuil a été signée par Solange.",
            "Passif féminin : a été signée.",
        ),
        pic_start=3,
        pic_words=["deux médias", "un récit", "un fait passé", "un titre"],
        short_p="Imitez : huit lignes, une concession, deux passifs.",
        audio="Lisez votre note, une phrase, une pause, sans aller trop vite.",
    ),
    _l(
        "EL",
        "EL — Concession et voix passive",
        "Retenir bien que + subjonctif, pourtant / cependant / néanmoins, et le passif.",
        "Apprenez la fiche.",
        "Fiche du studio",
        """Concession
bien que + subjonctif : Bien que la rumeur circule, on ouvre l'antenne.
pourtant / cependant / néanmoins + indicatif : Pourtant le marché était inquiet.
On ne dit pas : bien que la rumeur circule pas (oubli du subjonctif juste).
Voix passive
Actif : Dieudonné a mesuré le niveau.
Passif : Le niveau a été mesuré (par Dieudonné).
Accord : la nouvelle a été lue ; les faits ont été pesés.
Agent facultatif : par + personne.
Relater : dire ce qui a été vu, sans inventer.
Média de la cour ≠ voix du marché.
Au Seuil : Radio Figuier pèse ; le marché répète.""",
        tf_item=(
            "Après pourtant, on met le subjonctif.",
            False,
            "Pourtant + indicatif. Le subjonctif suit bien que.",
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
            ("bien que", "subjonctif"),
            ("pourtant", "indicatif"),
            ("être + PP", "passif"),
            ("par", "agent"),
        ],
        fill_item=("Bien que la rumeur ___, on ouvre l'antenne.", "circule"),
        words=["Le", "niveau", "a", "été", "mesuré", "."],
        anagram=("indicatif", "Le mode après pourtant, cependant, néanmoins."),
        error=(
            "Bien que la rumeur circule, le niveau a mesurer ce matin.",
            "Bien que la rumeur circule, le niveau a été mesuré.",
            "Passif : a été mesuré.",
        ),
        pic_start=4,
        pic_words=["un récit", "un fait passé", "un titre", "un carnet"],
        short_p="Tableau : six phrases, concession à gauche, passif à droite.",
        audio="Enregistrez la fiche et six phrases modèles.",
    ),
]


# ---------------------------------------------------------------------------
# Séquence 2 — Écrire un fait divers (PC, imparfait, PQP)
# ---------------------------------------------------------------------------

S2 = [
    _l(
        "CO",
        "CO — Hier à la rivière",
        "Repérer le récit : imparfait (cadre), PC (faits), PQP (avant) ; on a annoncé que.",
        "Lisez le dialogue. Quel temps pour le cadre, quel temps pour l'événement ?",
        "Rive ocre, carnet de Marc",
        """Marc : Hier, le ciel était gris. L'eau montait déjà.
Léa : On a annoncé que le pont des Herbes restait ouvert.
Aline : Avant l'aube, Dieudonné avait mesuré le niveau.
Patrick : Les paniers étaient plus hauts. Puis Mado a déplacé le stand.
Hawa : On a annoncé que personne n'avait dormi sous la rive.
Joël : Sami a porté deux seaux. Il avait préparé les cordes la veille.
Lila : Le studio était calme. Ensuite Hawa a lu le bulletin.
Karim : On a annoncé que la cour n'était pas inondée.
Solange : J'avais tamponné la feuille avant que Lila n'ouvre l'antenne.
Mado : Le marché bruissait. Puis la voix sans nom s'est tue.
Sami : J'ai frappé le tambour une fois : le Seuil a écouté.
Dieudonné : J'avais noué la corde. Ensuite j'ai fixé la marque sur le pieu.""",
        tf_item=(
            "Dieudonné avait mesuré le niveau avant l'aube : c'est un plus-que-parfait.",
            True,
            "Aline : « avait mesuré » — avant le moment du récit.",
        ),
        qcm_item=(
            "Quel temps pose le cadre « le ciel était gris » ?",
            ["passé composé", "imparfait", "plus-que-parfait", "futur"],
            1,
            "Imparfait : cadre, description.",
        ),
        pairs=[
            ("était gris", "imparfait / cadre"),
            ("a annoncé", "passé composé"),
            ("avait mesuré", "plus-que-parfait"),
            ("a lu", "fait du bulletin"),
        ],
        fill_item=("On ___ annoncé que le pont restait ouvert.", "a"),
        words=["On", "a", "annoncé", "que", "le", "pont", "restait", "ouvert", "."],
        anagram=("cadre", "L'imparfait le pose : ciel, eau, marché."),
        error=(
            "Hier, le ciel a été gris pendant que l'eau montait déjà depuis longtemps.",
            "Hier, le ciel était gris pendant que l'eau montait déjà depuis longtemps.",
            "Cadre : imparfait (était), pas a été.",
        ),
        pic_start=5,
        pic_words=["un fait passé", "un titre", "un carnet", "une rumeur"],
        short_p="Classez six verbes : imparfait / PC / PQP.",
        audio="Enregistrez : Le ciel était gris. On a annoncé que le pont restait ouvert. Dieudonné avait mesuré.",
    ),
    _l(
        "CE",
        "CE — Fait divers de la rive",
        "Lire un récit journalistique au passé.",
        "Lisez le fait divers, sans aller trop vite.",
        "Feuille de une, Radio Figuier",
        """Fait divers — La rive a tenu
Hier matin, le marché était déjà ouvert. L'eau montait le long des pieux.
On a annoncé que le pont des Herbes restait praticable.
Avant l'ouverture, Dieudonné avait marqué le niveau sur le bois.
Mado a relevé les paniers. Elle avait noué les toiles la veille.
Sami a frappé le tambour. La cour a cessé de courir.
Lila a lu le bulletin à huit heures. Rien n'avait été inventé.
Selon Solange, le dossier de la rive avait été tamponné à l'aube.
Pourtant une voix sans nom avait couru au Marché des Lampions.
Cependant le chiffre mesuré a calmé les bancs.
Radio Figuier — Rukiri-Nord
Prochaine une : le soir, si l'eau change.""",
        tf_item=(
            "Mado avait noué les toiles la veille : l'action est antérieure.",
            True,
            "Plus-que-parfait : avant le relevage des paniers.",
        ),
        qcm_item=(
            "À quelle heure Lila a-t-elle lu le bulletin ?",
            ["à l'aube", "à midi", "à huit heures", "à minuit"],
            2,
            "« Lila a lu le bulletin à huit heures. »",
        ),
        pairs=[
            ("était ouvert", "imparfait"),
            ("a relevé", "passé composé"),
            ("avait marqué", "plus-que-parfait"),
            ("on a annoncé que", "relais du fait"),
        ],
        fill_item=("Dieudonné ___ marqué le niveau sur le bois.", "avait"),
        words=["Mado", "a", "relevé", "les", "paniers", "."],
        anagram=("praticable", "Le pont restait… : on pouvait encore passer."),
        error=(
            "Dieudonné a marqué le niveau avant l'ouverture déjà depuis la nuit.",
            "Avant l'ouverture, Dieudonné avait marqué le niveau sur le bois.",
            "Antériorité : plus-que-parfait.",
        ),
        pic_start=6,
        pic_words=["un titre", "un carnet", "une rumeur", "le marché"],
        short_p="Recopiez le fait divers et soulignez PC, imparfait, PQP.",
        audio="Lisez le fait divers, sans aller trop vite.",
    ),
    _l(
        "PO",
        "PO — Raconter hier",
        "Rapporter des faits passés à l'oral avec les trois temps.",
        "Répétez, puis racontez un fait de la cour.",
        "Modèles de Hawa Diallo",
        """Le marché était ouvert.
L'eau montait.
On a annoncé que le pont tenait.
Dieudonné avait mesuré le niveau.
Mado a relevé les paniers.
Elle avait noué les toiles.
Sami a frappé le tambour.
Lila a lu le bulletin.
Rien n'avait été inventé.
La cour a écouté.
Le ciel était gris.
Puis le soleil a percé.""",
        tf_item=(
            "« On a annoncé que » introduit un fait rapporté.",
            True,
            "On = la rédaction. Que + phrase au passé.",
        ),
        qcm_item=(
            "« Elle avait noué les toiles » situe l'action…",
            [
                "après le relevage",
                "en même temps que le ciel",
                "avant le relevage",
                "au futur",
            ],
            2,
            "Plus-que-parfait : avant.",
        ),
        pairs=[
            ("était / montait", "cadre"),
            ("a annoncé / a lu", "événements"),
            ("avait mesuré", "avant"),
            ("on a annoncé que", "relais"),
        ],
        fill_item=("Elle ___ noué les toiles la veille.", "avait"),
        words=["On", "a", "annoncé", "que", "le", "pont", "tenait", "."],
        anagram=("bulletin", "Hawa ou Lila le lit à l'antenne."),
        error=(
            "On a annoncé que Dieudonné mesure le niveau hier avant l'aube.",
            "On a annoncé que Dieudonné avait mesuré le niveau.",
            "Fait antérieur : plus-que-parfait.",
        ),
        pic_start=7,
        pic_words=["un carnet", "une rumeur", "le marché", "une loupe"],
        short_p="Écrivez un récit de huit phrases : 3 imparfaits, 3 PC, 2 PQP.",
        audio="Enregistrez les modèles, puis votre récit d'hier.",
    ),
    _l(
        "PE",
        "PE — Mon fait divers",
        "Écrire un récit journalistique au passé.",
        "Imitez le fait de Rose, sans aller trop vite.",
        "Fait de Rose Iradukunda",
        """Rose Iradukunda
Hier, la Table des Sources était encore humide.
On a annoncé que personne n'avait glissé.
Joël avait posé deux nattes avant l'ouverture.
Puis Léa a essuyé le banc. Marc a noté l'heure.
Le figuier donnait peu d'ombre. Le vent poussait les feuilles.
Hawa a lu trois phrases. Rien n'avait été ajouté.
Pourtant une voix du marché avait parlé d'une chute.
Cependant aucun témoin n'a confirmé.
Rose
Feuille de une — Radio Figuier""",
        tf_item=(
            "Un témoin a confirmé la chute.",
            False,
            "« aucun témoin n'a confirmé. »",
        ),
        qcm_item=(
            "Qui avait posé les nattes ?",
            ["Léa", "Marc", "Joël", "Hawa"],
            2,
            "« Joël avait posé deux nattes. »",
        ),
        pairs=[
            ("était humide", "imparfait"),
            ("a essuyé", "passé composé"),
            ("avait posé", "plus-que-parfait"),
            ("on a annoncé que", "ouverture du récit"),
        ],
        fill_item=("On a annoncé que personne n'___ glissé.", "avait"),
        words=["Léa", "a", "essuyé", "le", "banc", "."],
        anagram=("temoin", "Aucun… n'a confirmé (sans accent)."),
        error=(
            "Joël a posé deux nattes avant l'ouverture déjà la veille au soir.",
            "Joël avait posé deux nattes avant l'ouverture.",
            "Antériorité : plus-que-parfait.",
        ),
        pic_start=8,
        pic_words=["une rumeur", "le marché", "une loupe", "un tampon"],
        short_p="Imitez : dix lignes, les trois temps, une phrase on a annoncé que.",
        audio="Lisez votre fait divers, sans aller trop vite.",
    ),
    _l(
        "EL",
        "EL — PC, imparfait, plus-que-parfait",
        "Retenir le rôle de chaque temps dans un récit journalistique.",
        "Apprenez la fiche.",
        "Fiche d'Aline",
        """Imparfait : cadre, description, habitude du moment.
Le marché était ouvert. L'eau montait.
Passé composé : faits, événements, ce qui fait avancer le récit.
Mado a relevé les paniers. Hawa a lu le bulletin.
Plus-que-parfait : une action déjà faite avant un autre passé.
Dieudonné avait mesuré. Elle avait noué les toiles.
On a annoncé que + phrase : relais du fait (souvent imparfait ou PQP dans que).
On a annoncé que le pont restait ouvert.
On a annoncé que personne n'avait dormi sous la rive.
Pas : on a annoncé que Dieudonné mesure hier.
Ordre utile : cadre (imp.) → avant (PQP) → faits (PC).
Radio Figuier raconte ainsi la rive.""",
        tf_item=(
            "Le plus-que-parfait place un fait avant un autre passé.",
            True,
            "Avoir / être à l'imparfait + participe.",
        ),
        qcm_item=(
            "Pour le cadre « le ciel… gris », on dit…",
            [
                "le ciel a été gris",
                "le ciel était gris",
                "le ciel avait été gris seulement",
                "le ciel sera gris",
            ],
            1,
            "Imparfait de description.",
        ),
        pairs=[
            ("imparfait", "cadre"),
            ("passé composé", "événement"),
            ("plus-que-parfait", "avant"),
            ("on a annoncé que", "relais"),
        ],
        fill_item=("Dieudonné ___ mesuré le niveau avant l'aube.", "avait"),
        words=["Le", "marché", "était", "ouvert", "."],
        anagram=("evenement", "Le PC le raconte (sans accent)."),
        error=(
            "On a annoncé que Dieudonné mesure le niveau hier à l'aube.",
            "On a annoncé que Dieudonné avait mesuré le niveau.",
            "Dans que, le fait antérieur se met au plus-que-parfait.",
        ),
        pic_start=9,
        pic_words=["le marché", "une loupe", "un tampon", "une mise en évidence"],
        short_p="Transformez six phrases : cadre, avant, événement.",
        audio="Enregistrez la fiche et six phrases aux trois temps.",
    ),
]


# ---------------------------------------------------------------------------
# Séquence 3 — Démasquer une rumeur
# ---------------------------------------------------------------------------

S3 = [
    _l(
        "CO",
        "CO — Il paraît, on confirme",
        "Distinguer rumeur et fait : d'après, selon, il paraît que / il a été confirmé que.",
        "Lisez le dialogue. Qui vérifie ? Qui répète ?",
        "Marché des Lampions, banc de Mado",
        """Mado : Il paraît que le pont s'est cassé. Je n'ai rien vu.
Sami : Selon un passant, l'eau a tout pris. Il n'a pas donné son nom.
Léa : D'après Dieudonné, le pont tient. Il a montré la marque.
Marc : Il a été confirmé que le niveau est haut, pas que le pont est rompu.
Aline : Il paraît que n'est pas une preuve. C'est une rumeur.
Patrick : Selon la Feuille du Seuil, la rive est praticable.
Hawa : D'après Solange, le dossier a été tamponné.
Joël : Il paraît que Joël a fui. C'est faux : je suis là.
Lila : Il a été confirmé que personne n'a quitté la cour.
Karim : J'écris : rumeur d'un côté, fait de l'autre.
Yvette : Selon l'infirmerie, aucun blessé n'a été reçu.
Dieudonné : Venez voir le pieu. Le bois n'a pas cédé.""",
        tf_item=(
            "« Il paraît que le pont s'est cassé » est présenté comme une preuve.",
            False,
            "Mado n'a rien vu. Aline : ce n'est pas une preuve.",
        ),
        qcm_item=(
            "Qui montre la marque sur le pont ?",
            ["Sami", "Dieudonné", "Joël", "Karim"],
            1,
            "Léa : « D'après Dieudonné… Il a montré la marque. »",
        ),
        pairs=[
            ("il paraît que", "rumeur"),
            ("il a été confirmé que", "fait pesé"),
            ("d'après Dieudonné", "source nommée"),
            ("selon un passant", "source faible"),
        ],
        fill_item=("Il ___ que le pont s'est cassé. Je n'ai rien vu.", "paraît"),
        words=["Il", "a", "été", "confirmé", "que", "le", "niveau", "est", "haut", "."],
        anagram=("parait", "Il… que : rumeur, sans accent."),
        error=(
            "Il a été confirmé que le pont s'est cassé, d'après Mado qui n'a rien vu.",
            "Il paraît que le pont s'est cassé, d'après Mado qui n'a rien vu.",
            "Sans preuve, on dit il paraît que, pas il a été confirmé que.",
        ),
        pic_start=10,
        pic_words=["une loupe", "un tampon", "une mise en évidence", "un micro"],
        short_p="Classez six phrases : rumeur / fait confirmé.",
        audio="Enregistrez : Il paraît que… D'après Dieudonné… Il a été confirmé que…",
    ),
    _l(
        "CE",
        "CE — Deux versions au figuier",
        "Lire une rumeur et sa vérification.",
        "Lisez les deux versions, sans aller trop vite.",
        "Affiche ocre, tronc du figuier",
        """Version A — voix du Marché des Lampions
Il paraît que le pont des Herbes s'est ouvert en deux.
Selon un panier anonyme, l'eau a emporté une barque.
D'après « on », Sami a cessé de frapper par peur.
Version B — vérification de Radio Figuier
Il a été confirmé que le pont tient : Dieudonné a montré le pieu.
Selon la Feuille du Seuil, aucune barque n'a disparu.
D'après Sami, le tambour a sonné pour rassembler, pas pour fuir.
Règle : d'après / selon + une source qu'on nomme.
Il paraît que = on répète sans preuve.
Il a été confirmé que = un fait a été pesé.
Karim a collé les deux versions. La cour a choisi B.
Cahier du chemin — Rukiri-Nord""",
        tf_item=(
            "La version B dit qu'une barque a disparu.",
            False,
            "« aucune barque n'a disparu. »",
        ),
        qcm_item=(
            "Pourquoi Sami a-t-il frappé, d'après la version B ?",
            [
                "par peur",
                "pour vendre un panier",
                "pour rassembler",
                "pour fermer Radio Figuier",
            ],
            2,
            "« pour rassembler, pas pour fuir. »",
        ),
        pairs=[
            ("il paraît que", "version A"),
            ("il a été confirmé que", "version B"),
            ("panier anonyme", "source faible"),
            ("Dieudonné / pieu", "preuve"),
        ],
        fill_item=("Il a été ___ que le pont tient.", "confirmé"),
        words=["Il", "paraît", "que", "le", "pont", "tient", "."],
        anagram=("anonyme", "Un panier sans nom : source…"),
        error=(
            "Il a été confirmé que le pont s'est ouvert en deux, version A sans preuve.",
            "Il a été confirmé que le pont tient : Dieudonné a montré le pieu.",
            "La confirmation suit la preuve, pas la rumeur.",
        ),
        pic_start=11,
        pic_words=["un tampon", "une mise en évidence", "un micro", "un argument"],
        short_p="Recopiez B et barre d'une croix chaque phrase de A.",
        audio="Lisez A puis B, sans aller trop vite.",
    ),
    _l(
        "PO",
        "PO — Nommer la source",
        "Vérifier à l'oral : d'après, selon, il paraît que, il a été confirmé que.",
        "Répétez, puis corrigez une rumeur de la cour.",
        "Modèles de Karim",
        """Il paraît que le pont est rompu.
D'après Dieudonné, le pont tient.
Selon Solange, le dossier est clair.
Il a été confirmé que la cour est sèche.
Il paraît que Joël a fui.
Selon Joël, il est resté.
D'après Yvette, aucun blessé n'est venu.
Il a été confirmé que le tambour rassemblait.
Ce n'est pas une preuve.
C'est une voix sans nom.
Je vérifie avant l'antenne.
Je nomme ma source.""",
        tf_item=(
            "« Selon » doit être suivi d'une source qu'on peut nommer.",
            True,
            "Selon Solange, selon Joël — pas selon on.",
        ),
        qcm_item=(
            "Quelle formule pèse un fait ?",
            [
                "il paraît que",
                "on dit que",
                "il a été confirmé que",
                "quelqu'un a crié que",
            ],
            2,
            "Confirmation = fait pesé.",
        ),
        pairs=[
            ("il paraît que", "sans preuve"),
            ("d'après", "source"),
            ("selon", "source"),
            ("il a été confirmé que", "fait"),
        ],
        fill_item=("___ Solange, le dossier est clair.", "Selon"),
        words=["Je", "nomme", "ma", "source", "."],
        anagram=("verifier", "Karim le fait avant l'antenne (sans accent)."),
        error=(
            "Selon on, le pont tient vraiment ce matin.",
            "D'après Dieudonné, le pont tient.",
            "Selon / d'après + une personne ou un écrit, pas on.",
        ),
        pic_start=12,
        pic_words=["une mise en évidence", "un micro", "un argument", "un pupitre"],
        short_p="Écrivez huit phrases : 3 il paraît, 3 d'après/selon, 2 confirmé.",
        audio="Enregistrez les modèles, puis une rumeur corrigée.",
    ),
    _l(
        "PE",
        "PE — Ma vérification",
        "Écrire une note qui démasque une rumeur.",
        "Imitez la note de Léa, sans aller trop vite.",
        "Note de Léa Niyonzima",
        """Léa Niyonzima
Il paraît que la Table des Sources a disparu sous l'eau.
D'après Félicie, la table était seulement humide.
Selon Joël, deux nattes avaient été posées.
Il a été confirmé que personne n'a glissé.
La rumeur partait du Marché des Lampions.
La preuve venait de la cour et de l'infirmerie.
Je n'écrirai pas « il paraît » à l'antenne sans nom.
Je peux écrire « selon Yvette » ou « d'après Félicie ».
Léa
Cahier du chemin — Radio Figuier""",
        tf_item=(
            "Léa veut dire « il paraît » à l'antenne sans nommer personne.",
            False,
            "« Je n'écrirai pas « il paraît » à l'antenne sans nom. »",
        ),
        qcm_item=(
            "Selon qui les nattes avaient-elles été posées ?",
            ["Félicie", "Yvette", "Joël", "Mado"],
            2,
            "« Selon Joël, deux nattes avaient été posées. »",
        ),
        pairs=[
            ("il paraît que", "table disparue"),
            ("d'après Félicie", "table humide"),
            ("selon Joël", "nattes"),
            ("il a été confirmé que", "personne n'a glissé"),
        ],
        fill_item=("Il a été ___ que personne n'a glissé.", "confirmé"),
        words=["D'après", "Félicie", "la", "table", "était", "humide", "."],
        anagram=("infirmerie", "Yvette y reçoit : aucun blessé."),
        error=(
            "Il a été confirmé que personne a glissé sous la Table des Sources.",
            "Il a été confirmé que personne n'a glissé sous la Table des Sources.",
            "Personne… n'a : la négation ne disparaît pas.",
        ),
        pic_start=13,
        pic_words=["un micro", "un argument", "un pupitre", "un journal"],
        short_p="Imitez : une rumeur, deux sources nommées, une confirmation.",
        audio="Lisez votre vérification, sans aller trop vite.",
    ),
    _l(
        "EL",
        "EL — D'après, selon, il paraît, confirmé",
        "Retenir les formules qui pèsent ou qui répètent.",
        "Apprenez la fiche.",
        "Fiche de Lila",
        """Rumeur
il paraît que + indicatif : on répète, on n'a pas vu.
on dit que : même prudence.
Fait pesé
il a été confirmé que + indicatif : une preuve existe.
Source nommée
d'après + nom : D'après Dieudonné, le pont tient.
selon + nom : Selon Solange, le dossier est clair.
On évite : selon on / d'après les gens.
On peut écrire la rumeur à part, dans le Cahier du chemin.
On ne la lit pas comme une une.
Au Seuil : le marché répète ; Radio Figuier nomme.
Vérifier = aller voir, demander, comparer deux versions.""",
        tf_item=(
            "« D'après les gens » est une source assez nommée.",
            False,
            "On nomme une personne ou un écrit.",
        ),
        qcm_item=(
            "Quelle formule introduit une rumeur ?",
            [
                "il a été confirmé que",
                "d'après Dieudonné",
                "il paraît que",
                "selon la Feuille du Seuil",
            ],
            2,
            "Il paraît que = sans preuve.",
        ),
        pairs=[
            ("il paraît que", "rumeur"),
            ("d'après + nom", "source"),
            ("selon + nom", "source"),
            ("il a été confirmé que", "preuve"),
        ],
        fill_item=("___ Dieudonné, le pont tient.", "D'après"),
        words=["Je", "vérifie", "avant", "l'antenne", "."],
        anagram=("preuve", "Sans elle, on ne confirme pas."),
        error=(
            "D'après les gens du marché, il a été confirmé que le pont est rompu.",
            "D'après les gens du marché, il paraît que le pont est rompu.",
            "Source floue : il paraît, pas il a été confirmé.",
        ),
        pic_start=14,
        pic_words=["un argument", "un pupitre", "un journal", "un studio"],
        short_p="Écrivez une mini-charte : 4 formules, 4 exemples du Seuil.",
        audio="Enregistrez la fiche et huit formules.",
    ),
]


# ---------------------------------------------------------------------------
# Séquence 4 — Tenir le micro (mise en évidence)
# ---------------------------------------------------------------------------

S4 = [
    _l(
        "CO",
        "CO — Ce qui compte, c'est le fait",
        "Capter l'attention et argumenter : ce qui… c'est, c'est… que, ce que.",
        "Lisez le dialogue. Qu'est-ce qu'on met en avant ?",
        "Pupitre de Marc, studio Figuier",
        """Marc : Ce qui inquiète le marché, c'est l'eau, pas le silence.
Léa : C'est le chiffre que nous lirons en premier.
Aline : Ce que je demande, c'est une phrase courte.
Patrick : Ce qui rassure, c'est une source nommée.
Hawa : C'est Dieudonné que j'ai interrogé, pas une voix sans nom.
Joël : Ce que le Seuil attend, c'est une heure claire.
Lila : Ce qui ouvre l'antenne, c'est le salut, puis le fait.
Karim : C'est la rumeur que nous écarterons ensuite.
Solange : Ce que le Bureau confirme, c'est la praticabilité du pont.
Mado : Ce qui a calmé les paniers, c'est le tambour de Sami.
Sami : C'est pour rassembler que j'ai frappé, pas pour alarmer.
Dieudonné : Ce que j'ai montré, c'est la marque sur le pieu.""",
        tf_item=(
            "Hawa a interrogé une voix sans nom.",
            False,
            "« C'est Dieudonné que j'ai interrogé, pas une voix sans nom. »",
        ),
        qcm_item=(
            "Selon Lila, qu'est-ce qui ouvre l'antenne ?",
            [
                "la rumeur",
                "le salut, puis le fait",
                "le tambour seul",
                "le silence",
            ],
            1,
            "« Ce qui ouvre l'antenne, c'est le salut, puis le fait. »",
        ),
        pairs=[
            ("ce qui… c'est", "sujet mis en avant"),
            ("c'est… que", "complément mis en avant"),
            ("ce que… c'est", "objet mis en avant"),
            ("c'est pour… que", "but mis en avant"),
        ],
        fill_item=("Ce qui rassure, ___ une source nommée.", "c'est"),
        words=["C'est", "le", "chiffre", "que", "nous", "lirons", "."],
        anagram=("rassure", "Patrick : ce qui… , c'est une source nommée."),
        error=(
            "Ce qui rassure, c'est que une source nommée seulement.",
            "Ce qui rassure, c'est une source nommée.",
            "Après c'est, le nom mis en avant, sans que inutile.",
        ),
        pic_start=15,
        pic_words=["un pupitre", "un journal", "un studio", "une horloge"],
        short_p="Notez six mises en évidence entendues.",
        audio="Enregistrez : Ce qui rassure, c'est une source. C'est le chiffre que nous lirons. Ce que je demande, c'est une phrase courte.",
    ),
    _l(
        "CE",
        "CE — Argument du matin",
        "Lire un texte qui explique et argumente avec la mise en évidence.",
        "Lisez l'argument, sans aller trop vite.",
        "Feuille de Karim, groupe rédaction",
        """Pourquoi lire le fait avant la rumeur
Ce qui capte l'oreille, c'est une phrase nette.
C'est le pont que nous plaçons en une, pas le cri du marché.
Ce que nous écartons, c'est la voix sans nom.
Argument 1 : une source nommée permet de vérifier.
Argument 2 : un chiffre mesuré calme mieux qu'un « il paraît ».
Argument 3 : le droit d'être entendu vient après le fait, pas à la place.
Ce qui unit la rédaction, c'est la charte de Radio Figuier.
C'est Lila que la cour écoute d'abord, puis Hawa.
Ce que Solange tamponne, c'est le dossier, pas la peur.
On explique : on dit pourquoi on a choisi cet ordre.
On argumente : on donne trois raisons, on conclut.
Studio Figuier — Rukiri-Nord""",
        tf_item=(
            "La une place le cri du marché avant le pont.",
            False,
            "« C'est le pont que nous plaçons en une, pas le cri du marché. »",
        ),
        qcm_item=(
            "Combien de raisons l'argument compte-t-il ?",
            ["une", "deux", "trois", "cinq"],
            2,
            "Argument 1, 2 et 3.",
        ),
        pairs=[
            ("ce qui capte", "phrase nette"),
            ("c'est le pont que", "une"),
            ("ce que nous écartons", "voix sans nom"),
            ("trois raisons", "argumenter"),
        ],
        fill_item=("Ce qui unit la rédaction, ___ la charte de Radio Figuier.", "c'est"),
        words=["C'est", "le", "pont", "que", "nous", "plaçons", "."],
        anagram=("argumente", "On… : on donne des raisons."),
        error=(
            "Ce qui capte l'oreille, c'est que une phrase nette seulement.",
            "Ce qui capte l'oreille, c'est une phrase nette.",
            "Ce qui + verbe, c'est + nom.",
        ),
        pic_start=16,
        pic_words=["un journal", "un studio", "une horloge", "un casque"],
        short_p="Recopiez les trois arguments et ajoutez-en un.",
        audio="Lisez l'argument, sans aller trop vite.",
    ),
    _l(
        "PO",
        "PO — Mettre en avant",
        "Expliquer et argumenter à l'oral avec ce qui, c'est… que, ce que.",
        "Répétez, puis mettez en avant un fait du Seuil.",
        "Modèles d'Aline",
        """Ce qui compte, c'est le fait.
C'est le chiffre que je lis.
Ce que je refuse, c'est la rumeur.
C'est Dieudonné que j'interroge.
Ce qui calme, c'est une heure fixe.
C'est pour rassembler que Sami frappe.
Ce que Solange confirme, c'est le dossier.
C'est Lila qui ouvre l'antenne.
Ce qui unit, c'est la charte.
Je commence par le salut.
J'explique ensuite le choix.
Je conclus par l'heure du prochain bulletin.""",
        tf_item=(
            "« C'est Lila qui ouvre » met Lila en évidence.",
            True,
            "C'est + nom + qui + verbe.",
        ),
        qcm_item=(
            "Pour mettre un COD en avant, on dit souvent…",
            [
                "ce qui… c'est",
                "c'est… que",
                "il paraît que",
                "bien que",
            ],
            1,
            "C'est le chiffre que je lis.",
        ),
        pairs=[
            ("ce qui… c'est", "sujet"),
            ("c'est… que", "COD / complément"),
            ("c'est… qui", "sujet nommé"),
            ("c'est pour… que", "but"),
        ],
        fill_item=("C'est le chiffre ___ je lis.", "que"),
        words=["Ce", "qui", "compte", "c'est", "le", "fait", "."],
        anagram=("evidence", "Mise en… : ce qui, c'est, ce que (sans accent)."),
        error=(
            "C'est le chiffre qui je lis en premier à l'antenne.",
            "C'est le chiffre que je lis en premier à l'antenne.",
            "COD : que, pas qui.",
        ),
        pic_start=17,
        pic_words=["un studio", "une horloge", "un casque", "l'éthique"],
        short_p="Transformez six phrases plates en mises en évidence.",
        audio="Enregistrez les modèles, puis deux arguments à vous.",
    ),
    _l(
        "PE",
        "PE — Mon micro",
        "Écrire un court argument pour l'antenne.",
        "Imitez le texte de Hawa, sans aller trop vite.",
        "Texte de Hawa Diallo",
        """Hawa Diallo
Ce qui ouvre mon micro, c'est le nom de Radio Figuier.
C'est le niveau de la rivière que je lis d'abord.
Ce que j'écarte, c'est la voix sans nom du marché.
C'est Dieudonné que je cite, pas « on ».
Ce qui rassure la cour, c'est une phrase courte.
C'est pour informer que je parle, pas pour alarmer.
Je conclus : prochain bulletin à midi, même pieu, même règle.
Hawa
Journal parlé — Seuil des Sources""",
        tf_item=(
            "Hawa cite « on » comme source principale.",
            False,
            "« C'est Dieudonné que je cite, pas « on ». »",
        ),
        qcm_item=(
            "Que lit Hawa d'abord ?",
            [
                "la voix du marché",
                "le niveau de la rivière",
                "un conte",
                "la charte entière",
            ],
            1,
            "« C'est le niveau de la rivière que je lis d'abord. »",
        ),
        pairs=[
            ("ce qui ouvre", "nom de Radio Figuier"),
            ("c'est le niveau que", "d'abord"),
            ("ce que j'écarte", "voix sans nom"),
            ("c'est pour informer que", "but"),
        ],
        fill_item=("C'est Dieudonné ___ je cite, pas « on ».", "que"),
        words=["Ce", "que", "j'écarte", "c'est", "la", "voix", "."],
        anagram=("alarmer", "Hawa refuse : elle informe, elle ne veut pas…"),
        error=(
            "C'est le niveau de la rivière qui je lis d'abord.",
            "C'est le niveau de la rivière que je lis d'abord.",
            "Lire quelque chose → que.",
        ),
        pic_start=18,
        pic_words=["une horloge", "un casque", "l'éthique", "un droit"],
        short_p="Imitez : six mises en évidence, un but, une conclusion.",
        audio="Lisez votre texte de micro, sans aller trop vite.",
    ),
    _l(
        "EL",
        "EL — Ce qui, c'est… que, ce que",
        "Retenir la mise en évidence pour argumenter.",
        "Apprenez la fiche.",
        "Fiche du pupitre",
        """Mettre en avant le sujet
Ce qui + verbe, c'est + nom : Ce qui rassure, c'est une source.
C'est + nom + qui + verbe : C'est Lila qui ouvre.
Mettre en avant l'objet
C'est + nom + que + sujet + verbe : C'est le chiffre que je lis.
Ce que + sujet + verbe, c'est + nom : Ce que je refuse, c'est la rumeur.
But
C'est pour + infinitif + que : C'est pour rassembler que Sami frappe.
On n'écrit pas : c'est le chiffre qui je lis.
On n'écrit pas : ce qui rassure, c'est que une source.
Capter l'attention : phrase courte, puis raison.
Argumenter : trois raisons, une conclusion.
Au Seuil : le micro sert à expliquer, pas à crier.""",
        tf_item=(
            "« Ce qui » reprend un sujet.",
            True,
            "Ce qui rassure = la chose qui rassure.",
        ),
        qcm_item=(
            "« Ce que je refuse, c'est la rumeur » met en avant…",
            ["le sujet Lila", "l'objet rumeur", "un passif", "un imparfait"],
            1,
            "Ce que = ce que je refuse.",
        ),
        pairs=[
            ("ce qui", "sujet"),
            ("ce que", "objet"),
            ("c'est… que", "objet nommé"),
            ("c'est… qui", "sujet nommé"),
        ],
        fill_item=("Ce ___ je refuse, c'est la rumeur.", "que"),
        words=["C'est", "Lila", "qui", "ouvre", "."],
        anagram=("pupitre", "Marc s'y tient pour parler."),
        error=(
            "C'est le chiffre qui je lis avant la rumeur.",
            "C'est le chiffre que je lis avant la rumeur.",
            "COD : que.",
        ),
        pic_start=19,
        pic_words=["un casque", "l'éthique", "un droit", "une charte"],
        short_p="Fiche personnelle : 8 phrases, les quatre schémas.",
        audio="Enregistrez la fiche et huit mises en évidence.",
    ),
]


# ---------------------------------------------------------------------------
# Séquence 5 — Préparer le journal parlé (EXTRA)
# ---------------------------------------------------------------------------

S5 = [
    _l(
        "CO",
        "CO — L'ordre de l'émission",
        "Repérer la structure d'un journal parlé au Seuil.",
        "Lisez le dialogue. Dans quel ordre passe l'émission ?",
        "Horloge d'antenne, studio Figuier",
        """Lila : D'abord le générique, puis mon salut.
Hawa : Ensuite le fait de la rivière, en trois phrases.
Marc : Après, un rappel de source : qui a vu, qui a mesuré.
Léa : Puis la météo du figuier, très courte.
Patrick : Ensuite l'agenda de la cour : Table, marché, infirmerie.
Aline : Plus tard, une voix invitée, jamais une rumeur.
Karim : Avant de fermer, on lit l'heure du prochain bulletin.
Solange : On ne mélange pas le dossier et le conte.
Mado : Le marché peut être cité s'il est nommé.
Sami : Un son de tambour peut ouvrir, pas remplacer le fait.
Joël : On chronomètre : huit minutes, pas plus.
Dieudonné : Si l'eau change, on refait le fait, pas tout le reste.""",
        tf_item=(
            "L'émission commence par la voix invitée.",
            False,
            "Lila : générique, puis salut.",
        ),
        qcm_item=(
            "Combien de minutes dure le journal, selon Joël ?",
            ["trois", "huit", "vingt", "une heure"],
            1,
            "« huit minutes, pas plus. »",
        ),
        pairs=[
            ("générique / salut", "ouverture"),
            ("fait de la rivière", "une"),
            ("voix invitée", "après le fait"),
            ("heure du prochain", "fermeture"),
        ],
        fill_item=("D'abord le générique, ___ mon salut.", "puis"),
        words=["On", "chronomètre", "huit", "minutes", "."],
        anagram=("generique", "Lila l'ouvre en premier (sans accent)."),
        error=(
            "D'abord la voix invitée, puis le générique et le salut de Lila.",
            "D'abord le générique, puis mon salut.",
            "L'ouverture précède l'invité.",
        ),
        pic_start=20,
        pic_words=["l'éthique", "un droit", "une charte", "une oreille"],
        short_p="Dessinez l'ordre de l'émission en six cases.",
        audio="Enregistrez l'ordre : générique, salut, fait, source, agenda, clôture.",
    ),
    _l(
        "CE",
        "CE — Conducteur du matin",
        "Lire la structure écrite d'une émission.",
        "Lisez le conducteur, sans aller trop vite.",
        "Feuille conducteur, Radio Figuier",
        """Conducteur — journal parlé du Seuil
1. Générique (20 secondes) — Lila.
2. Salut et date — Lila.
3. Fait 1 : niveau de la rivière — Hawa (chiffre, source Dieudonné).
4. Fait 2 : pont praticable — Marc (source Solange).
5. Rumeur écartée en une phrase, sans la répéter en détail — Karim.
6. Agenda : Marché des Lampions, Table des Sources, infirmerie — Léa.
7. Voix invitée du jour : Mado, deux minutes, stand des lampions.
8. Annonce du prochain bulletin (midi) — Lila.
9. Générique de fin.
Durée visée : huit minutes.
Interdit : une une sans source ; un conte à la place du fait.
Studio Figuier — Rukiri-Nord""",
        tf_item=(
            "Karim développe longuement la rumeur.",
            False,
            "« en une phrase, sans la répéter en détail. »",
        ),
        qcm_item=(
            "Qui dit le fait sur le niveau de la rivière ?",
            ["Lila", "Hawa", "Léa", "Mado"],
            1,
            "Fait 1 — Hawa.",
        ),
        pairs=[
            ("fait 1", "Hawa"),
            ("agenda", "Léa"),
            ("voix invitée", "Mado"),
            ("clôture", "Lila"),
        ],
        fill_item=("Durée visée : ___ minutes.", "huit"),
        words=["Annonce", "du", "prochain", "bulletin", "."],
        anagram=("conducteur", "La feuille qui ordonne l'émission."),
        error=(
            "Fait 1 : niveau de la rivière — Hawa sans aucune source nommée.",
            "Fait 1 : niveau de la rivière — Hawa (chiffre, source Dieudonné).",
            "Chaque fait porte une source.",
        ),
        pic_start=21,
        pic_words=["un droit", "une charte", "une oreille", "une antenne"],
        short_p="Recopiez le conducteur et changez la voix invitée.",
        audio="Lisez les neuf points, sans aller trop vite.",
    ),
    _l(
        "PO",
        "PO — Enchaîner l'émission",
        "Enchaîner à l'oral les parties d'un journal parlé.",
        "Répétez les formules de liaison, puis enchaînez un mini-journal.",
        "Formules de Lila",
        """Ici Radio Figuier, journal du Seuil.
Bonjour. Voici d'abord le fait de la rivière.
Selon Dieudonné, le niveau est haut.
Venons-en au pont : il reste praticable.
Une voix du marché a couru : elle n'a pas été confirmée.
Passons à l'agenda de la cour.
Nous recevons maintenant Mado.
Merci Mado. Prochain bulletin à midi.
Bonne écoute sous le figuier.
Je vous retrouve à midi.
Huit minutes, pas davantage.
Chaque fait a une source.""",
        tf_item=(
            "« Venons-en au pont » sert à changer de sujet.",
            True,
            "Liaison d'émission.",
        ),
        qcm_item=(
            "Quelle formule ouvre l'antenne ?",
            [
                "Merci Mado",
                "Ici Radio Figuier, journal du Seuil",
                "Passons à l'agenda",
                "Bonne écoute",
            ],
            1,
            "Salut d'ouverture.",
        ),
        pairs=[
            ("ici Radio Figuier", "ouverture"),
            ("venons-en au", "enchaînement"),
            ("passons à", "agenda"),
            ("prochain bulletin", "fermeture"),
        ],
        fill_item=("___-en au pont : il reste praticable.", "Venons"),
        words=["Passons", "à", "l'agenda", "de", "la", "cour", "."],
        anagram=("enchaine", "On… les parties (sans accent)."),
        error=(
            "Ici Radio Figuier, merci Mado et bonjour en même temps.",
            "Ici Radio Figuier, journal du Seuil. Bonjour.",
            "L'ouverture précède les remerciements.",
        ),
        pic_start=22,
        pic_words=["une charte", "une oreille", "une antenne", "une feuille"],
        short_p="Écrivez un mini-conducteur oral de dix phrases.",
        audio="Enregistrez un journal de huit phrases, chronométré.",
    ),
    _l(
        "PE",
        "PE — Mon conducteur",
        "Écrire la structure d'une émission de huit minutes.",
        "Imitez le conducteur de Patrick, sans aller trop vite.",
        "Conducteur de Patrick Habimana",
        """Patrick Habimana — journal du soir
1. Générique et salut.
2. Fait : le pieu de Dieudonné, chiffre du soir.
3. Source : Feuille du Seuil, tampon de Solange.
4. Rumeur écartée : une phrase, pas plus.
5. Agenda : Salle des Herbes, infirmerie, marché.
6. Voix invitée : Sami, pourquoi le tambour a rassemblé.
7. Heure du bulletin de demain.
8. Générique de fin.
Durée : huit minutes.
Interdit : une une sans nom.
Patrick
Radio Figuier""",
        tf_item=(
            "Patrick invite Dieudonné comme voix du soir.",
            False,
            "Voix invitée : Sami.",
        ),
        qcm_item=(
            "Que fait Patrick de la rumeur ?",
            [
                "Il la développe en trois minutes",
                "Il l'écarte en une phrase",
                "Il la place en une",
                "Il la chante",
            ],
            1,
            "« une phrase, pas plus. »",
        ),
        pairs=[
            ("fait", "pieu / chiffre"),
            ("source", "Solange"),
            ("invité", "Sami"),
            ("durée", "huit minutes"),
        ],
        fill_item=("Durée : ___ minutes.", "huit"),
        words=["Générique", "et", "salut", "."],
        anagram=("interdit", "Chez Patrick : une une sans nom est…"),
        error=(
            "Voix invitée : une voix sans nom du Marché des Lampions.",
            "Voix invitée : Sami, pourquoi le tambour a rassemblé.",
            "L'invité est nommé.",
        ),
        pic_start=23,
        pic_words=["une oreille", "une antenne", "une feuille", "une carte"],
        short_p="Imitez : huit points, une durée, un interdit.",
        audio="Lisez votre conducteur, sans aller trop vite.",
    ),
    _l(
        "EL",
        "EL — Structure d'une émission",
        "Retenir l'ordre d'un journal parlé.",
        "Apprenez la fiche.",
        "Fiche studio",
        """Ordre type — Radio Figuier
1. Générique 2. Salut et date 3. Fait principal
4. Source nommée 5. Rumeur écartée (une phrase)
6. Agenda de la cour 7. Voix invitée 8. Prochain bulletin 9. Générique
Liaisons
Ici… / Voici d'abord… / Venons-en à… / Passons à… / Nous recevons…
Merci… / Prochain bulletin à…
Durée visée : huit minutes.
Chaque fait porte une source.
On n'ouvre pas sur une rumeur.
On n'invite pas une voix sans nom.
Le tambour peut ouvrir le son, pas remplacer le texte.
Si l'eau change, on refait le fait, pas tout l'agenda.""",
        tf_item=(
            "On peut ouvrir le journal sur une rumeur si elle est forte.",
            False,
            "On n'ouvre pas sur une rumeur.",
        ),
        qcm_item=(
            "Quelle liaison annonce l'invité ?",
            [
                "Voici d'abord",
                "Nous recevons",
                "Prochain bulletin",
                "Générique",
            ],
            1,
            "Nous recevons + nom.",
        ),
        pairs=[
            ("voici d'abord", "fait"),
            ("venons-en à", "enchaînement"),
            ("nous recevons", "invité"),
            ("prochain bulletin", "clôture"),
        ],
        fill_item=("Nous ___ maintenant Mado.", "recevons"),
        words=["On", "n'ouvre", "pas", "sur", "une", "rumeur", "."],
        anagram=("liaisons", "Voici, venons-en, passons : les… de l'antenne."),
        error=(
            "On ouvre le journal sur une rumeur si le marché parle fort.",
            "On n'ouvre pas sur une rumeur.",
            "Le fait précède la rumeur écartée.",
        ),
        pic_start=24,
        pic_words=["une antenne", "une feuille", "une carte", "une rédaction"],
        short_p="Recopiez l'ordre type et inventez trois liaisons.",
        audio="Enregistrez la fiche et un enchaînement complet.",
    ),
]


# ---------------------------------------------------------------------------
# Séquence 6 — L'éthique du micro (EXTRA)
# ---------------------------------------------------------------------------

S6 = [
    _l(
        "CO",
        "CO — Le droit de répondre",
        "Comprendre le droit de réponse et une limite éthique de l'antenne.",
        "Lisez le dialogue. Qui peut répondre ? Pourquoi ?",
        "Salle des Herbes, oreille de la cour",
        """Joël : On a dit que j'avais fui. Ce n'est pas vrai.
Lila : Tu as un droit de réponse. Tu parles après le fait, deux minutes.
Aline : Le droit de réponse, c'est le droit d'être entendu quand on a été nommé à tort.
Marc : On ne lit pas la rumeur une seconde fois pour « équilibrer ».
Léa : On lit la correction, puis Joël parle.
Patrick : La charte de Radio Figuier interdit d'humilier.
Hawa : Elle demande une source avant chaque nom.
Karim : Elle demande aussi d'écouter celui qu'on a blessé.
Solange : Le Bureau note la réponse. Elle reste au dossier.
Mado : Le marché n'a pas ce droit écrit : la radio, si.
Sami : Je peux offrir un son, pas une accusation.
Dieudonné : Si l'on me nomme à tort, je viendrai au pieu et au micro.""",
        tf_item=(
            "Lila refuse que Joël parle à l'antenne.",
            False,
            "« Tu as un droit de réponse. »",
        ),
        qcm_item=(
            "Combien de minutes Joël a-t-il pour répondre ?",
            ["huit", "vingt", "deux", "une heure"],
            2,
            "Lila : deux minutes.",
        ),
        pairs=[
            ("droit de réponse", "être entendu"),
            ("charte", "interdit d'humilier"),
            ("source avant chaque nom", "Hawa"),
            ("dossier", "Solange"),
        ],
        fill_item=("Tu as un droit de ___.", "réponse"),
        words=["Tu", "as", "un", "droit", "de", "réponse", "."],
        anagram=("humilier", "La charte l'interdit : faire honte à quelqu'un."),
        error=(
            "On lit la rumeur une seconde fois pour équilibrer, puis Joël se tait.",
            "On lit la correction, puis Joël parle.",
            "On ne répète pas la rumeur pour « équilibrer ».",
        ),
        pic_start=25,
        pic_words=["une feuille", "une carte", "une rédaction", "un nuage"],
        short_p="Notez trois règles éthiques entendues.",
        audio="Enregistrez : Tu as un droit de réponse. On lit la correction. La charte interdit d'humilier.",
    ),
    _l(
        "CE",
        "CE — Charte de Radio Figuier",
        "Lire une charte inventée de l'antenne.",
        "Lisez la charte, sans aller trop vite.",
        "Charte ocre, studio Figuier",
        """Charte de Radio Figuier — Seuil des Sources
1. Chaque nom cité a une source visible.
2. Une rumeur n'ouvre jamais le journal.
3. Celui ou celle qui a été nommé(e) à tort a deux minutes de réponse.
4. On ne répète pas l'accusation pour « faire juste ».
5. On n'humilie pas. On n'invente pas de titre cruel.
6. Le Cahier du chemin garde les versions. On peut les relire.
7. Lila peut refuser une phrase qui blesse sans informer.
8. Solange peut tamponner une correction au Bureau des Escales.
9. Le tambour rassemble ; il n'accuse pas.
10. Si l'eau, le marché ou la cour change, on corrige à l'antenne suivante.
Signée : Lila Sow, Aline Uwase, Solange Mukamana.
Rukiri-Nord — sous le figuier""",
        tf_item=(
            "Le tambour peut accuser quelqu'un s'il joue fort.",
            False,
            "Point 9 : il n'accuse pas.",
        ),
        qcm_item=(
            "Qui peut tamponner une correction ?",
            ["Sami", "Mado", "Solange", "Joël"],
            2,
            "Point 8.",
        ),
        pairs=[
            ("source visible", "article 1"),
            ("deux minutes", "droit de réponse"),
            ("Cahier du chemin", "versions"),
            ("corriger ensuite", "article 10"),
        ],
        fill_item=("Une rumeur n'___ jamais le journal.", "ouvre"),
        words=["On", "n'humilie", "pas", "."],
        anagram=("correction", "Solange peut la tamponner au Bureau."),
        error=(
            "Une rumeur ouvre le journal si elle vient du Marché des Lampions.",
            "Une rumeur n'ouvre jamais le journal.",
            "Article 2 de la charte.",
        ),
        pic_start=26,
        pic_words=["une carte", "une rédaction", "un nuage", "un soleil"],
        short_p="Recopiez cinq articles et ajoutez-en un à vous.",
        audio="Lisez les dix articles, sans aller trop vite.",
    ),
    _l(
        "PO",
        "PO — Répondre sans blesser",
        "Parler au micro après une erreur, selon la charte.",
        "Répétez, puis formulez un droit de réponse.",
        "Modèles de Joël",
        """On a dit que j'avais fui. C'est faux.
J'étais à la Table des Sources.
Je demande deux minutes de réponse.
Je nomme mes témoins : Félicie et Léa.
Je n'accuse personne en retour.
Je remercie Lila de corriger.
La charte me protège. Elle protège aussi les autres.
Je parle après le fait, pas à sa place.
Je reste calme. Je reste précis.
Je ne répète pas la rumeur.
Je dis où j'étais. Je dis qui m'a vu.
Merci à la cour de m'écouter.""",
        tf_item=(
            "Joël accuse le marché en retour.",
            False,
            "« Je n'accuse personne en retour. »",
        ),
        qcm_item=(
            "Quels témoins Joël nomme-t-il ?",
            [
                "Sami et Mado",
                "Félicie et Léa",
                "Karim et Marc",
                "Dieudonné et Solange",
            ],
            1,
            "« Félicie et Léa. »",
        ),
        pairs=[
            ("c'est faux", "démenti"),
            ("témoins", "Félicie / Léa"),
            ("deux minutes", "droit"),
            ("je n'accuse pas", "éthique"),
        ],
        fill_item=("Je n'___ personne en retour.", "accuse"),
        words=["Je", "demande", "deux", "minutes", "de", "réponse", "."],
        anagram=("temoins", "Félicie et Léa : ceux qui ont vu (sans accent)."),
        error=(
            "Je répète la rumeur en entier pour mieux la casser ensuite.",
            "Je ne répète pas la rumeur.",
            "La charte : on ne relit pas l'accusation.",
        ),
        pic_start=27,
        pic_words=["une rédaction", "un nuage", "un soleil", "une source"],
        short_p="Écrivez un droit de réponse de dix phrases.",
        audio="Enregistrez les modèles, puis votre réponse de deux minutes.",
    ),
    _l(
        "PE",
        "PE — Ma réponse à l'antenne",
        "Écrire un droit de réponse selon la charte.",
        "Imitez la réponse de Joël, sans aller trop vite.",
        "Réponse de Joël Mugisha",
        """Joël Mugisha
On a dit que j'avais fui la rive. C'est faux.
J'étais à la Table des Sources. Félicie m'a vu. Léa aussi.
Je demande le droit de réponse prévu par la charte.
Je ne répète pas la voix du marché.
Je remercie Radio Figuier de lire cette correction.
Je n'humilie personne. Je n'invente aucun nom.
Le Bureau des Escales peut joindre cette feuille au dossier.
Joël
Seuil des Sources — Rukiri-Nord""",
        tf_item=(
            "Joël invente un nom pour se défendre.",
            False,
            "« Je n'invente aucun nom. »",
        ),
        qcm_item=(
            "Où Joël était-il ?",
            [
                "au Marché des Lampions",
                "à la Table des Sources",
                "à Val-des-Peupliers",
                "sous la rive",
            ],
            1,
            "« J'étais à la Table des Sources. »",
        ),
        pairs=[
            ("c'est faux", "fuite"),
            ("témoins", "Félicie / Léa"),
            ("charte", "droit de réponse"),
            ("dossier", "Bureau des Escales"),
        ],
        fill_item=("Je n'invente aucun ___.", "nom"),
        words=["C'est", "faux", "."],
        anagram=("dossier", "Solange y joint la feuille."),
        error=(
            "On a dit que j'avais fui. Je répète toute la rumeur pour rire.",
            "On a dit que j'avais fui la rive. C'est faux.",
            "On dément, on ne rejoue pas la rumeur.",
        ),
        pic_start=28,
        pic_words=["un nuage", "un soleil", "une source", "une concession"],
        short_p="Imitez : démenti, lieu, témoins, remerciement, dossier.",
        audio="Lisez votre réponse, sans aller trop vite.",
    ),
    _l(
        "EL",
        "EL — Droit de réponse et charte",
        "Retenir l'éthique du micro de Radio Figuier.",
        "Apprenez la fiche.",
        "Fiche d'éthique",
        """Droit de réponse
Si l'on vous nomme à tort, vous parlez après le fait, deux minutes.
On lit une correction. On ne relit pas l'accusation.
Charte de Radio Figuier (inventée au Seuil)
source avant chaque nom ; pas de une-rumeur ; pas d'humiliation.
Cahier du chemin = mémoire des versions.
Lila peut refuser une phrase qui blesse.
Solange peut tamponner la correction.
Le tambour rassemble ; il n'accuse pas.
On corrige à l'émission suivante si le fait change.
On n'équilibre pas une erreur en la répétant.
On nomme ses témoins. On n'invente pas de nom.
Éthique = protéger la cour et la vérité du pieu.""",
        tf_item=(
            "Équilibrer une erreur, c'est relire l'accusation.",
            False,
            "On ne l'équilibre pas en la répétant.",
        ),
        qcm_item=(
            "Où garde-t-on les versions ?",
            [
                "dans un cri du marché",
                "dans le Cahier du chemin",
                "sous l'eau",
                "nulle part",
            ],
            1,
            "Cahier du chemin = mémoire.",
        ),
        pairs=[
            ("deux minutes", "réponse"),
            ("correction", "sans relire l'accusation"),
            ("Lila", "peut refuser"),
            ("Solange", "tampon"),
        ],
        fill_item=("Le tambour rassemble ; il n'___ pas.", "accuse"),
        words=["On", "nomme", "ses", "témoins", "."],
        anagram=("ethique", "Protéger la cour et le pieu (sans accent)."),
        error=(
            "On équilibre une accusation en la relisant deux fois.",
            "On lit une correction. On ne relit pas l'accusation.",
            "La charte refuse ce faux équilibre.",
        ),
        pic_start=29,
        pic_words=["un soleil", "une source", "une concession", "un passif"],
        short_p="Rédigez cinq articles personnels pour le micro de la cour.",
        audio="Enregistrez la fiche et votre serment d'antenne.",
    ),
]


SEQUENCES = [
    {"title": "Lire une source", "lessons": S1},
    {"title": "Écrire un fait divers", "lessons": S2},
    {"title": "Démasquer une rumeur", "lessons": S3},
    {"title": "Tenir le micro", "lessons": S4},
    {"title": "Préparer le journal parlé", "lessons": S5},
    {"title": "L'éthique du micro", "lessons": S6},
]
