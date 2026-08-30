"""B1 Module 8 — Un monde de culture (univers Seuil des Sources)."""

from factory import L

IMG = "mfk-b1-m8"
IMG_DIR = IMG

MODULE = {
    "title": "B1 — Un monde de culture",
    "description": (
        "Grande étape B1-8 : écrire une critique enthousiaste, s'informer "
        "sur un parcours, réagir à une œuvre, dire pourquoi lire, tenir "
        "une soirée lecture et programmer une saison — Saison des Voix, "
        "tambour de Sami, pages de Mado, pièce « La cour n'oublie pas », "
        "au Seuil des Sources (Rukiri-Nord)."
    ),
}


def _l(comp, title, obj, cons, st, sp, **kw):
    return L(IMG, comp, title, obj, cons, st, sp, **kw)


# ---------------------------------------------------------------------------
# Séquence 1 — Une critique enthousiaste (superlatif)
# ---------------------------------------------------------------------------

S1 = [
    _l(
        "CO",
        "CO — Le plus émouvant de la veillée",
        "Présenter une œuvre et une critique positive ; superlatifs.",
        "Lisez le dialogue. Qu'est-ce qui est le plus, la meilleure, le moins ?",
        "Salle des Herbes, affiche ocre",
        """Léa : « La cour n'oublie pas » est le spectacle le plus émouvant de la saison.
Marc : C'est la meilleure soirée que j'ai vécue sous le figuier.
Aline : Le moins attendu, c'est le silence après le tambour de Sami.
Patrick : Mado a lu la plus juste des pages du Cahier du chemin.
Hawa : Dieudonné a tissé le plus beau coupon pour le rideau.
Joël : Ce n'est pas le moins réussi : c'est le plus vivant.
Lila : Radio Figuier dira : la pièce la plus claire de la Saison des Voix.
Karim : Le moins long n'est pas le moins fort. Vingt minutes ont suffi.
Solange : La meilleure trace, c'est la feuille tamponnée au Bureau.
Rose : J'ai vu le moins attendu : Kévin a pleuré sans bruit.
Mado : La page la plus simple était la plus écoutée.
Sami : Le rythme le moins pressé a porté toute la cour.""",
        tf_item=(
            "Karim dit que vingt minutes n'ont pas suffi.",
            False,
            "« Vingt minutes ont suffi. »",
        ),
        qcm_item=(
            "Selon Léa, quel spectacle est le plus émouvant ?",
            [
                "un cri du marché",
                "« La cour n'oublie pas »",
                "un bulletin d'eau",
                "un tampon seul",
            ],
            1,
            "Léa nomme la pièce inventée de la cour.",
        ),
        pairs=[
            ("le plus émouvant", "Léa / pièce"),
            ("la meilleure soirée", "Marc"),
            ("le moins attendu", "silence / Kévin"),
            ("la plus juste", "page / Mado"),
        ],
        fill_item=("C'est ___ meilleure soirée que j'ai vécue sous le figuier.", "la"),
        words=["C'est", "la", "meilleure", "soirée", "."],
        anagram=("emouvant", "Léa : le plus… de la saison (sans accent)."),
        error=(
            "« La cour n'oublie pas » est le spectacle le plus émouvante de la saison.",
            "« La cour n'oublie pas » est le spectacle le plus émouvant de la saison.",
            "Spectacle est masculin : émouvant.",
        ),
        pic_start=0,
        pic_words=["un superlatif", "une affiche", "une œuvre", "une étoile"],
        short_p="Notez six superlatifs : trois plus, trois moins.",
        audio="Enregistrez : le plus émouvant, la meilleure soirée, le moins attendu, la plus juste.",
    ),
    _l(
        "CE",
        "CE — Critique de la première",
        "Lire une critique positive d'une œuvre de la cour.",
        "Lisez la critique, sans aller trop vite.",
        "Feuille de Lila, Radio Figuier",
        """Critique — « La cour n'oublie pas »
C'est la pièce la plus émouvante que la Saison des Voix ait ouverte.
Le moins attendu, c'est le rôle muet de Kévin : il a tenu le seau.
Sami a donné le rythme le plus juste : ni trop vite, ni trop sourd.
Mado a lu la meilleure page du Cahier du chemin, celle du figuier.
Dieudonné a tendu le rideau le moins lourd, le plus ocre.
On ne compare pas avec un titre d'ailleurs : on reste au Seuil.
La cour a offert le silence le plus dense après la dernière frappe.
Aline dit que c'est le moins long des spectacles, et le plus net.
Solange a tamponné : « première réussie ».
Je recommande cette œuvre à ceux qui écoutent vraiment.
Lila Sow
Saison des Voix — Rukiri-Nord""",
        tf_item=(
            "Kévin a tenu un long discours.",
            False,
            "« le rôle muet de Kévin : il a tenu le seau. »",
        ),
        qcm_item=(
            "Qui a tendu le rideau ?",
            ["Sami", "Mado", "Dieudonné", "Lila"],
            2,
            "« Dieudonné a tendu le rideau. »",
        ),
        pairs=[
            ("la plus émouvante", "pièce"),
            ("le moins attendu", "rôle muet"),
            ("le plus juste", "rythme / Sami"),
            ("la meilleure page", "Mado"),
        ],
        fill_item=("C'est la pièce la plus ___ que la saison ait ouverte.", "émouvante"),
        words=["Je", "recommande", "cette", "œuvre", "."],
        anagram=("recommande", "Lila le fait : elle… cette œuvre."),
        error=(
            "C'est la pièce le plus émouvant que la saison ait ouverte.",
            "C'est la pièce la plus émouvante que la saison ait ouverte.",
            "Pièce est féminin : la plus émouvante.",
        ),
        pic_start=1,
        pic_words=["une affiche", "une œuvre", "une étoile", "un parcours"],
        short_p="Recopiez la critique et encadrez les superlatifs.",
        audio="Lisez la critique, sans aller trop vite.",
    ),
    _l(
        "PO",
        "PO — Dire le plus, le moins, la meilleure",
        "Présenter une œuvre à l'oral avec des superlatifs.",
        "Répétez, puis critiquez positivement un geste du Seuil.",
        "Modèles d'Aline",
        """C'est le spectacle le plus émouvant.
C'est la meilleure soirée de la saison.
C'est le moins attendu.
C'est la page la plus juste.
C'est le rideau le moins lourd.
C'est le rythme le plus vivant.
C'est la voix la moins pressée.
C'est le silence le plus dense.
Je recommande cette œuvre.
Je ne compare pas avec ailleurs.
Je reste sous le figuier.
Je parle après avoir écouté.""",
        tf_item=(
            "« Bon » au superlatif féminin, c'est « la meilleure ».",
            True,
            "La meilleure soirée, la meilleure page.",
        ),
        qcm_item=(
            "« Le moins attendu » exprime…",
            [
                "le sommet positif de attendu",
                "le bas de l'échelle de attendu",
                "un passif",
                "un futur",
            ],
            1,
            "Moins + adjectif = le plus bas degré.",
        ),
        pairs=[
            ("le plus + adj.", "sommet"),
            ("le moins + adj.", "degré bas"),
            ("bon → le meilleur / la meilleure", "irrégulier"),
            ("je recommande", "critique positive"),
        ],
        fill_item=("C'est ___ meilleure soirée de la saison.", "la"),
        words=["Je", "recommande", "cette", "œuvre", "."],
        anagram=("meilleure", "Bon, au sommet, au féminin."),
        error=(
            "C'est la plus meilleure soirée de la saison sous le figuier.",
            "C'est la meilleure soirée de la saison.",
            "Meilleure suffit : pas plus meilleure.",
        ),
        pic_start=2,
        pic_words=["une œuvre", "une étoile", "un parcours", "un tambour"],
        short_p="Écrivez huit superlatifs : 4 plus, 2 moins, 2 meilleur(e).",
        audio="Enregistrez les modèles, puis une critique de huit phrases.",
    ),
    _l(
        "PE",
        "PE — Ma critique enthousiaste",
        "Écrire une courte critique positive.",
        "Imitez la critique de Hawa, sans aller trop vite.",
        "Critique de Hawa Diallo",
        """Hawa Diallo
« La cour n'oublie pas » est la pièce la plus émouvante que j'ai entendue ici.
Le moins attendu, c'est le seau de Kévin : il n'a rien dit, la cour a compris.
Sami a tenu le rythme le plus juste. Mado a lu la meilleure page.
C'est la soirée la moins longue, et la plus nette.
Je ne cherche pas un titre d'ailleurs. Je reste au Seuil.
Je recommande cette œuvre à Radio Figuier, demain matin.
Le silence après la dernière frappe était le plus dense.
Hawa
Saison des Voix — Rukiri-Nord""",
        tf_item=(
            "Hawa cherche un titre d'ailleurs pour comparer.",
            False,
            "« Je ne cherche pas un titre d'ailleurs. »",
        ),
        qcm_item=(
            "Qui n'a rien dit ?",
            ["Sami", "Mado", "Kévin", "Lila"],
            2,
            "« le seau de Kévin : il n'a rien dit. »",
        ),
        pairs=[
            ("la plus émouvante", "pièce"),
            ("le moins attendu", "seau / Kévin"),
            ("le plus juste", "Sami"),
            ("la meilleure page", "Mado"),
        ],
        fill_item=("Je ___ cette œuvre à Radio Figuier.", "recommande"),
        words=["Je", "reste", "au", "Seuil", "."],
        anagram=("attendue", "Le moins… : le seau de Kévin (accord)."),
        error=(
            "C'est la soirée le moins longue et le plus nette de la saison.",
            "C'est la soirée la moins longue, et la plus nette.",
            "Soirée est féminin : la moins, la plus.",
        ),
        pic_start=3,
        pic_words=["une étoile", "un parcours", "un tambour", "une scène"],
        short_p="Imitez : quatre superlatifs, un refus d'ailleurs, une recommandation.",
        audio="Lisez votre critique, sans aller trop vite.",
    ),
    _l(
        "EL",
        "EL — Superlatif de la critique",
        "Retenir le plus, le moins, le meilleur / la meilleure.",
        "Apprenez la fiche.",
        "Fiche d'Aline",
        """Superlatif de supériorité
le / la / les plus + adjectif : le plus émouvant, la plus nette
Superlatif d'infériorité
le / la / les moins + adjectif : le moins attendu, la moins longue
Irrégulier
bon → le meilleur / la meilleure / les meilleurs / les meilleures
Accord avec le nom : la pièce la plus émouvante ; le spectacle le plus émouvant
On n'écrit pas : la plus meilleure.
On n'écrit pas : le plus émouvante (si le nom est masculin).
Critique positive : je recommande ; c'est vivant ; c'est net.
On ne compare pas avec un titre d'ailleurs.
Œuvres du Seuil : « La cour n'oublie pas », Cahier du chemin, tambour de Sami.
Présenter une œuvre : titre, geste, effet sur la cour.""",
        tf_item=(
            "« La plus meilleure » est une forme correcte.",
            False,
            "Meilleure suffit.",
        ),
        qcm_item=(
            "« Une page juste » au sommet, c'est…",
            [
                "la plus juste",
                "le plus juste",
                "la plus meilleure juste",
                "plus juste que juste",
            ],
            0,
            "Page féminin : la plus juste.",
        ),
        pairs=[
            ("le plus", "sommet"),
            ("le moins", "degré bas"),
            ("la meilleure", "bon / fém."),
            ("accord", "avec le nom"),
        ],
        fill_item=("Bon → la ___ page.", "meilleure"),
        words=["Je", "recommande", "cette", "œuvre", "."],
        anagram=("irregulier", "Bon → meilleur : un superlatif… (sans accent)."),
        error=(
            "C'est la plus meilleure page du Cahier du chemin.",
            "C'est la meilleure page du Cahier du chemin.",
            "Pas de plus devant meilleure.",
        ),
        pic_start=4,
        pic_words=["un parcours", "un tambour", "une scène", "un billet"],
        short_p="Tableau : 8 adjectifs au superlatif, accord noté.",
        audio="Enregistrez la fiche et huit superlatifs.",
    ),
]


# ---------------------------------------------------------------------------
# Séquence 2 — Spectacles et parcours
# ---------------------------------------------------------------------------

S2 = [
    _l(
        "CO",
        "CO — Deux parcours, une saison",
        "S'informer sur un parcours artistique et un spectacle vivant.",
        "Lisez le dialogue. Qui a suivi quel chemin ?",
        "Scène des Herbes, banc de Sami",
        """Sami : Mon parcours ? Le marché, puis le figuier, puis la scène.
Mado : Le mien passe par les pages. J'écris, je rature, je lis.
Aline : Un spectacle vivant, ici, c'est un corps, un son, un silence.
Patrick : On s'informe : où, quand, combien de temps, qui joue.
Hawa : La Saison des Voix ouvre à la Salle des Herbes, à dix-huit heures.
Joël : Le parcours de Dieudonné, c'est le tissu : mesurer, couper, tendre.
Lila : Radio Figuier annoncera les horaires, pas une rumeur de salle pleine.
Karim : Le parcours de Kévin est le moins parlé : il porte le seau.
Solange : Le Bureau affiche le programme. On peut le relire.
Rose : Léa note les sièges. Marc note les lanternes.
Léa : Je m'informe avant d'entrer : durée, entrée libre, silence demandé.
Marc : Un parcours, ce n'est pas une liste d'ailleurs. C'est une suite de gestes.""",
        tf_item=(
            "L'entrée de la Saison des Voix est payante et secrète.",
            False,
            "Léa : entrée libre, silence demandé.",
        ),
        qcm_item=(
            "À quelle heure ouvre la saison, selon Hawa ?",
            ["à midi", "à dix-huit heures", "à minuit", "à l'aube"],
            1,
            "« à dix-huit heures. »",
        ),
        pairs=[
            ("parcours de Sami", "marché / figuier / scène"),
            ("parcours de Mado", "écrire / raturer / lire"),
            ("spectacle vivant", "corps / son / silence"),
            ("s'informer", "où / quand / durée"),
        ],
        fill_item=("Un spectacle ___, ici, c'est un corps, un son, un silence.", "vivant"),
        words=["On", "s'informe", "avant", "d'entrer", "."],
        anagram=("parcours", "Suite de gestes : marché, figuier, scène."),
        error=(
            "Un parcours, c'est une liste d'ailleurs copiée sur un titre inconnu.",
            "Un parcours, ce n'est pas une liste d'ailleurs. C'est une suite de gestes.",
            "On reste au Seuil.",
        ),
        pic_start=5,
        pic_words=["un tambour", "une scène", "un billet", "un pronom"],
        short_p="Notez trois parcours et trois infos pratiques.",
        audio="Enregistrez : où, quand, combien de temps, qui joue. Entrée libre. Silence demandé.",
    ),
    _l(
        "CE",
        "CE — Programme vivant",
        "Lire un programme de spectacles et de parcours.",
        "Lisez le programme, sans aller trop vite.",
        "Affiche de saison, figuier",
        """Saison des Voix — programme du Seuil
Mercredi 18 h — Salle des Herbes
« La cour n'oublie pas » — pièce vivante, vingt minutes.
Parcours Sami : trois frappes, un silence, une dernière frappe.
Parcours Mado : une page du Cahier du chemin, puis une autre.
Parcours Dieudonné : rideau ocre, coupon montré à la fin.
Jeudi 17 h — ombre du figuier
Cercle lecture. Entrée libre. Lanternes de la cour.
Vendredi 18 h — Marché des Lampions
Tambour et voix : Sami, puis une page de Mado sur un stand.
On s'informe au Bureau des Escales. Solange a les heures.
On n'invente pas une salle d'ailleurs.
Durée, lieu, geste : trois infos suffisent.
Rukiri-Nord""",
        tf_item=(
            "Le cercle lecture a lieu le vendredi au marché.",
            False,
            "Jeudi 17 h — ombre du figuier.",
        ),
        qcm_item=(
            "Combien dure la pièce ?",
            ["deux heures", "vingt minutes", "huit minutes", "un jour"],
            1,
            "« vingt minutes. »",
        ),
        pairs=[
            ("mercredi 18 h", "pièce"),
            ("jeudi 17 h", "cercle lecture"),
            ("vendredi 18 h", "marché"),
            ("Bureau", "heures / Solange"),
        ],
        fill_item=("On s'informe au Bureau des ___.", "Escales"),
        words=["Entrée", "libre", "."],
        anagram=("programme", "Lieux, heures, gestes : le… de la saison."),
        error=(
            "Jeudi 17 h — Marché des Lampions, pièce de deux heures.",
            "Jeudi 17 h — ombre du figuier. Cercle lecture.",
            "Le jeudi est le cercle, pas la pièce.",
        ),
        pic_start=6,
        pic_words=["une scène", "un billet", "un pronom", "une critique"],
        short_p="Recopiez le programme et ajoutez un samedi inventé au Seuil.",
        audio="Lisez le programme, sans aller trop vite.",
    ),
    _l(
        "PO",
        "PO — Demander un parcours",
        "S'informer à l'oral sur un spectacle vivant.",
        "Répétez les questions, puis informez un camarade.",
        "Questions de Patrick",
        """Où joue-t-on ce soir ?
À quelle heure est-ce que ça commence ?
Combien de temps cela dure-t-il ?
Qui frappe ? Qui lit ? Qui tend le rideau ?
Est-ce un spectacle vivant ?
L'entrée est-elle libre ?
Doit-on garder le silence ?
Quel est le parcours de Sami ?
Quel est le parcours de Mado ?
Où s'informer si j'arrive tard ?
Au Bureau des Escales.
Sous le figuier, à dix-huit heures.""",
        tf_item=(
            "Patrick pose des questions pour s'informer, pas pour juger.",
            True,
            "Où, quand, durée, qui.",
        ),
        qcm_item=(
            "Où s'informer si l'on arrive tard ?",
            [
                "dans une rumeur",
                "au Bureau des Escales",
                "sous l'eau",
                "nulle part",
            ],
            1,
            "Solange a les heures.",
        ),
        pairs=[
            ("où / à quelle heure", "lieu / temps"),
            ("combien de temps", "durée"),
            ("qui", "parcours"),
            ("entrée libre / silence", "consignes"),
        ],
        fill_item=("L'entrée est-elle ___ ?", "libre"),
        words=["Où", "joue-t-on", "ce", "soir", "?"],
        anagram=("vivant", "Un spectacle… : corps, son, silence."),
        error=(
            "Où joue-t-on ce soir à quelle salle d'ailleurs payante ?",
            "Où joue-t-on ce soir ? Sous le figuier, à dix-huit heures.",
            "On répond au Seuil.",
        ),
        pic_start=7,
        pic_words=["un billet", "un pronom", "une critique", "un livre"],
        short_p="Écrivez dix questions d'information sur la saison.",
        audio="Enregistrez les questions, puis deux réponses complètes.",
    ),
    _l(
        "PE",
        "PE — Ma fiche parcours",
        "Écrire une fiche d'information sur un parcours artistique.",
        "Imitez la fiche de Mado, sans aller trop vite.",
        "Fiche de Mado, Cahier du chemin",
        """Mado
Parcours : j'écris sous le figuier, je rature à la Table des Sources, je lis à la Salle des Herbes.
Spectacle vivant du mercredi : « La cour n'oublie pas », vingt minutes.
Lieu : Salle des Herbes. Heure : dix-huit heures. Entrée libre.
Silence demandé après la dernière frappe de Sami.
On s'informe auprès de Solange si l'on arrive après le salut.
Je ne copie aucun programme d'ailleurs.
Mon geste : une page, puis une autre, sans courir.
Mado
Saison des Voix — Rukiri-Nord""",
        tf_item=(
            "Mado court d'une page à l'autre.",
            False,
            "« sans courir. »",
        ),
        qcm_item=(
            "Où Mado rature-t-elle ?",
            [
                "au Marché des Lampions",
                "à la Table des Sources",
                "sous l'eau",
                "au Bureau seulement",
            ],
            1,
            "« je rature à la Table des Sources. »",
        ),
        pairs=[
            ("écrire", "figuier"),
            ("raturer", "Table des Sources"),
            ("lire", "Salle des Herbes"),
            ("s'informer", "Solange"),
        ],
        fill_item=("Entrée ___. Silence demandé.", "libre"),
        words=["Je", "ne", "copie", "aucun", "programme", "d'ailleurs", "."],
        anagram=("rature", "Mado le fait à la Table : elle… une phrase."),
        error=(
            "Lieu : une salle d'ailleurs. Heure : on verra. Entrée secrète.",
            "Lieu : Salle des Herbes. Heure : dix-huit heures. Entrée libre.",
            "Une fiche informe vraiment.",
        ),
        pic_start=8,
        pic_words=["un pronom", "une critique", "un livre", "un micro"],
        short_p="Imitez : parcours en trois gestes, lieu, heure, consigne.",
        audio="Lisez votre fiche, sans aller trop vite.",
    ),
    _l(
        "EL",
        "EL — S'informer sur un spectacle",
        "Retenir les questions et le lexique du spectacle vivant.",
        "Apprenez la fiche.",
        "Fiche programme",
        """Questions
Où ? À quelle heure ? Combien de temps ? Qui ?
L'entrée est-elle libre ? Doit-on garder le silence ?
Lexique : spectacle vivant = corps, son, silence, scène, rideau, frappe
parcours : une suite de gestes, pas une liste d'ailleurs
saison : plusieurs soirs reliés (Saison des Voix)
Infos : durée, lieu, heure, entrée, silence, où s'informer
Au Seuil : Salle des Herbes, figuier, Marché des Lampions, Bureau des Escales
On n'invente pas une salle lointaine.
On n'annonce pas une salle pleine comme une preuve.
Radio Figuier dit les heures. Solange les a sur feuille.
Un billet, ici, peut être une feuille ocre : entrée libre.""",
        tf_item=(
            "Un parcours est une liste copiée ailleurs.",
            False,
            "Suite de gestes du Seuil.",
        ),
        qcm_item=(
            "Que signifie « spectacle vivant » au Seuil ?",
            [
                "un écran seulement",
                "un corps, un son, un silence",
                "une rumeur",
                "un tampon",
            ],
            1,
            "Aline : corps, son, silence.",
        ),
        pairs=[
            ("où / quand", "questions"),
            ("vivant", "corps / son"),
            ("parcours", "gestes"),
            ("saison", "plusieurs soirs"),
        ],
        fill_item=("Un ___ , ici, c'est une suite de gestes.", "parcours"),
        words=["L'entrée", "est-elle", "libre", "?"],
        anagram=("silence", "Demandé après la dernière frappe."),
        error=(
            "On annonce une salle pleine d'ailleurs comme une preuve de qualité.",
            "On n'annonce pas une salle pleine comme une preuve. Radio Figuier dit les heures.",
            "S'informer ≠ vanter une foule.",
        ),
        pic_start=9,
        pic_words=["une critique", "un livre", "un micro", "une question"],
        short_p="Rédigez six questions et six réponses sur un soir de saison.",
        audio="Enregistrez la fiche et un dialogue d'information.",
    ),
]


# ---------------------------------------------------------------------------
# Séquence 3 — Réagir à une œuvre (double pronom)
# ---------------------------------------------------------------------------

S3 = [
    _l(
        "CO",
        "CO — Je le lui ai dit",
        "Réagir à une critique ; double pronominalisation.",
        "Lisez le dialogue. Où vont le, la, les, lui, me, te ?",
        "Micro d'avis, banc de la cour",
        """Léa : J'ai lu la critique de Lila. Je le lui ai dit : elle est juste.
Marc : On me l'a conseillée, cette pièce. J'y suis allé.
Aline : Je te les envoie, les deux pages de Mado.
Patrick : Ne me le répète pas : j'ai déjà entendu le seau de Kévin.
Hawa : Elle nous les a montrés, les coupons du rideau.
Joël : Je vous le promets : je garderai le silence.
Lila : Tu me l'as dit trop vite. Dis-le-moi plus lentement.
Karim : Je les lui ai rendus, les sièges, après la pièce.
Rose : On te l'a défendu, de crier. Tu as bien fait.
Solange : Je le leur ai lu, le programme, au Bureau.
Mado : Ne nous les cache pas, tes ratures : elles enseignent.
Sami : Je te le joue une fois, le rythme, pas deux.""",
        tf_item=(
            "Patrick veut qu'on lui répète encore le seau de Kévin.",
            False,
            "« Ne me le répète pas. »",
        ),
        qcm_item=(
            "« Je te les envoie » : les, c'est…",
            [
                "Lila et Hawa",
                "les deux pages de Mado",
                "les tambours",
                "les tampons",
            ],
            1,
            "Aline : les deux pages.",
        ),
        pairs=[
            ("je le lui ai dit", "critique / Lila"),
            ("on me l'a conseillée", "pièce"),
            ("je te les envoie", "pages"),
            ("ne me le répète pas", "Patrick"),
        ],
        fill_item=("Je ___ lui ai dit : elle est juste.", "le"),
        words=["Ne", "me", "le", "répète", "pas", "."],
        anagram=("promette", "Joël : je vous le… (silence)."),
        error=(
            "Je lui le ai dit : la critique est juste.",
            "Je le lui ai dit : elle est juste.",
            "COD (le) avant COI (lui).",
        ),
        pic_start=10,
        pic_words=["un livre", "un micro", "une question", "l'importance"],
        short_p="Notez six doubles pronoms et ce qu'ils remplacent.",
        audio="Enregistrez : Je le lui ai dit. On me l'a conseillé. Je te les envoie. Ne me le répète pas.",
    ),
    _l(
        "CE",
        "CE — Réponses à la critique",
        "Lire des réactions qui commentent une œuvre.",
        "Lisez les réactions, sans aller trop vite.",
        "Cahier des avis, Salle des Herbes",
        """Réactions à la critique de Lila
Léa : Je le lui ai dit, à Lila : sa phrase sur le silence est la plus juste.
Marc : On me l'a conseillé, ce texte. Je le trouve net, pas cruel.
Aline : Je te les copie, tes doutes, Karim : ils aident la cour.
Patrick : Ne me le répète pas comme une rumeur. Dis-le comme un avis.
Hawa : Elle me l'a lu trop vite. Je le lui redemanderai demain.
Joël : Vous nous l'avez promis, le silence. Nous l'avons tenu.
Mado : Je les lui ai montrées, mes ratures. Elle n'a pas ri.
Sami : Je te le tiens, le tempo, si tu m'écoutes.
On réagit : on dit d'accord, pas d'accord, j'ajoute, je précise.
On ne déchire pas une critique. On lui répond.
Saison des Voix
Rukiri-Nord""",
        tf_item=(
            "Mado dit que Lila a ri des ratures.",
            False,
            "« Elle n'a pas ri. »",
        ),
        qcm_item=(
            "Que trouve Marc du texte de Lila ?",
            ["cruel", "net, pas cruel", "trop long", "faux"],
            1,
            "« net, pas cruel. »",
        ),
        pairs=[
            ("je le lui ai dit", "Léa / Lila"),
            ("on me l'a conseillé", "Marc"),
            ("ne me le répète pas", "Patrick"),
            ("je les lui ai montrées", "ratures / Mado"),
        ],
        fill_item=("On ne déchire pas une critique. On ___ répond.", "lui"),
        words=["On", "lui", "répond", "."],
        anagram=("reagir", "Dire d'accord ou pas : … à une œuvre (sans accent)."),
        error=(
            "Je lui les ai montrées, mes ratures, trop tard le soir.",
            "Je les lui ai montrées, mes ratures.",
            "Les (COD) avant lui (COI).",
        ),
        pic_start=11,
        pic_words=["un micro", "une question", "l'importance", "un cahier"],
        short_p="Recopiez quatre réactions et ajoutez la vôtre avec un double pronom.",
        audio="Lisez les réactions, sans aller trop vite.",
    ),
    _l(
        "PO",
        "PO — Le lui, me le, te les",
        "Placer deux pronoms à l'oral.",
        "Répétez, puis réagissez à une critique de la cour.",
        "Modèles d'Aline",
        """Je le lui ai dit.
On me l'a conseillé.
Je te les envoie.
Ne me le répète pas.
Elle nous les a montrés.
Je vous le promets.
Dis-le-moi.
Je les lui ai rendus.
On te l'a défendu.
Je le leur ai lu.
Ne nous les cache pas.
Je te le joue.""",
        tf_item=(
            "À l'impératif affirmatif, on dit souvent « dis-le-moi ».",
            True,
            "Traits d'union : dis-le-moi.",
        ),
        qcm_item=(
            "L'ordre le plus fréquent devant le verbe conjugué, c'est…",
            [
                "lui + le",
                "le / la / les puis lui / leur",
                "leur + les + me",
                "y + le + me",
            ],
            1,
            "Je le lui ai dit. Je les lui ai rendus.",
        ),
        pairs=[
            ("me / te / nous / vous", "avant le/la/les"),
            ("le / la / les", "avant lui / leur"),
            ("ne… pas", "entoure le groupe"),
            ("dis-le-moi", "impératif"),
        ],
        fill_item=("Je ___ lui ai dit.", "le"),
        words=["Dis-le-moi", "."],
        anagram=("ordre", "Me, le, lui : un… à retenir."),
        error=(
            "Je lui le ai dit après la pièce sous le figuier.",
            "Je le lui ai dit après la pièce sous le figuier.",
            "Le avant lui ; élision : je le lui ai.",
        ),
        pic_start=12,
        pic_words=["une question", "l'importance", "un cahier", "un lecteur"],
        short_p="Transformez huit phrases : deux noms → deux pronoms.",
        audio="Enregistrez les douze modèles, puis quatre réactions à vous.",
    ),
    _l(
        "PE",
        "PE — Ma réaction",
        "Écrire une réaction à une critique, avec doubles pronoms.",
        "Imitez la réaction de Rose, sans aller trop vite.",
        "Réaction de Rose Iradukunda",
        """Rose Iradukunda
J'ai lu Lila. Je le lui ai dit : sa critique est la plus nette.
On me l'a conseillé, ce silence après le tambour. Je l'ai tenu.
Je te les envoie, Léa, mes deux phrases d'avis.
Ne me le répète pas comme une une : c'est un commentaire, pas une rumeur.
Elle nous les a montrées, les ratures de Mado. Je les trouve utiles.
Je vous le promets : je reviendrai jeudi au cercle.
C'est la réaction la plus calme que je sache écrire.
Rose
Saison des Voix — Rukiri-Nord""",
        tf_item=(
            "Rose traite la critique comme une rumeur de une.",
            False,
            "« c'est un commentaire, pas une rumeur. »",
        ),
        qcm_item=(
            "À qui Rose envoie-t-elle ses deux phrases ?",
            ["Lila", "Mado", "Léa", "Sami"],
            2,
            "« Je te les envoie, Léa. »",
        ),
        pairs=[
            ("je le lui ai dit", "Lila"),
            ("on me l'a conseillé", "silence"),
            ("je te les envoie", "phrases / Léa"),
            ("je vous le promets", "cercle jeudi"),
        ],
        fill_item=("Je te ___ envoie, Léa, mes deux phrases d'avis.", "les"),
        words=["Je", "vous", "le", "promets", "."],
        anagram=("commentaire", "Pas une rumeur : un…"),
        error=(
            "Je lui le ai dit : sa critique est la plus nette.",
            "Je le lui ai dit : sa critique est la plus nette.",
            "Le avant lui.",
        ),
        pic_start=13,
        pic_words=["l'importance", "un cahier", "un lecteur", "une soirée"],
        short_p="Imitez : cinq doubles pronoms, un accord, un refus de rumeur.",
        audio="Lisez votre réaction, sans aller trop vite.",
    ),
    _l(
        "EL",
        "EL — Double pronominalisation",
        "Retenir l'ordre des pronoms pour réagir.",
        "Apprenez la fiche.",
        "Fiche des pronoms",
        """Devant le verbe conjugué
me / te / nous / vous + le / la / les + lui / leur
Je le lui ai dit. On me l'a conseillé. Je te les envoie.
Négation : ne me le répète pas. Ne nous les cache pas.
Impératif : dis-le-moi. Envoie-les-lui. Montre-les-nous.
Accord : on me l'a conseillée (la pièce). Elle nous les a montrés (les coupons).
On n'écrit pas : je lui le ai dit. On n'écrit pas : je les te envoie.
Réagir : d'accord / pas d'accord / j'ajoute / je précise
On répond à une critique. On ne la déchire pas.
Au Seuil : Lila, Mado, Sami, la pièce, le Cahier du chemin.""",
        tf_item=(
            "« Je les te envoie » est l'ordre correct.",
            False,
            "Je te les envoie.",
        ),
        qcm_item=(
            "« Ne me le répète pas » place les pronoms…",
            [
                "après pas",
                "entre ne et pas",
                "avant ne",
                "nulle part",
            ],
            1,
            "Ne + pronoms + verbe + pas.",
        ),
        pairs=[
            ("me / te + le", "avant lui"),
            ("le + lui", "COD puis COI"),
            ("dis-le-moi", "impératif"),
            ("accord", "avec le COD si avant"),
        ],
        fill_item=("Je te ___ envoie.", "les"),
        words=["Ne", "nous", "les", "cache", "pas", "."],
        anagram=("pronoms", "Le, lui, me, te : ce sont des…"),
        error=(
            "Je les te envoie demain matin sous le figuier.",
            "Je te les envoie demain matin sous le figuier.",
            "Te avant les.",
        ),
        pic_start=14,
        pic_words=["un cahier", "un lecteur", "une soirée", "une lampe"],
        short_p="Fiche personnelle : 10 phrases, tous les schémas de la leçon.",
        audio="Enregistrez la fiche et dix doubles pronoms.",
    ),
]


# ---------------------------------------------------------------------------
# Séquence 4 — Pourquoi lire (interrogation)
# ---------------------------------------------------------------------------

S4 = [
    _l(
        "CO",
        "CO — Qu'est-ce qui nous tient ?",
        "Questionner l'importance des livres ; interrogation.",
        "Lisez le dialogue. Qu'est-ce qui / qu'est-ce que / inversion ?",
        "Banc des livres, ombre du figuier",
        """Aline : Qu'est-ce qui tient la cour ensemble, le soir ?
Mado : Qu'est-ce que nous lisons, si ce n'est nos propres pages ?
Patrick : Avez-vous ouvert le Cahier du chemin cette semaine ?
Léa : Pourquoi lire, si l'on peut seulement écouter le tambour ?
Marc : Parce que la page garde ce que le son laisse filer.
Hawa : Qu'est-ce qui vous émeut dans « Le figuier n'oublie pas » ?
Joël : Qu'est-ce que Kévin a compris sans une phrase ?
Lila : Avez-vous entendu la lecture de Mado jusqu'au bout ?
Karim : Pourquoi lire à voix haute, sous le figuier ?
Solange : Pour que le Bureau n'ait pas que des tampons dans le dossier.
Rose : Qu'est-ce qui manque si personne n'ouvre un cahier ?
Sami : Le rythme. Mais le rythme seul n'écrit pas les noms.""",
        tf_item=(
            "Marc dit que la page est inutile si le tambour joue.",
            False,
            "« la page garde ce que le son laisse filer. »",
        ),
        qcm_item=(
            "« Qu'est-ce qui tient la cour » : qui reprend…",
            ["l'objet", "le sujet", "un lieu", "une heure"],
            1,
            "Qu'est-ce qui = sujet.",
        ),
        pairs=[
            ("qu'est-ce qui", "sujet"),
            ("qu'est-ce que", "objet"),
            ("avez-vous", "inversion"),
            ("pourquoi lire", "infinitif"),
        ],
        fill_item=("___-vous ouvert le Cahier du chemin cette semaine ?", "Avez"),
        words=["Pourquoi", "lire", "?"],
        anagram=("ensemble", "Aline : ce qui tient la cour…"),
        error=(
            "Qu'est-ce que tient la cour ensemble le soir sous le figuier ?",
            "Qu'est-ce qui tient la cour ensemble, le soir ?",
            "Sujet du verbe tenir → qu'est-ce qui.",
        ),
        pic_start=15,
        pic_words=["un lecteur", "une soirée", "une lampe", "un cercle"],
        short_p="Classez huit questions : qui / que / inversion / infinitif.",
        audio="Enregistrez : Qu'est-ce qui tient la cour ? Qu'est-ce que nous lisons ? Avez-vous ouvert le cahier ? Pourquoi lire ?",
    ),
    _l(
        "CE",
        "CE — Éloge de la page",
        "Lire un texte sur l'importance des livres au Seuil.",
        "Lisez l'éloge, sans aller trop vite.",
        "Page de Mado, Cahier du chemin",
        """Pourquoi lire au Seuil des Sources
Qu'est-ce qui reste après la frappe de Sami ? Une page peut le garder.
Qu'est-ce que nous devons aux anciens de la cour ? Des noms, des gestes.
Avez-vous vu « Le figuier n'oublie pas » ? Ce n'est pas un titre d'ailleurs.
C'est le livre inventé de la cour, relu chaque saison.
Pourquoi lire à voix haute ? Pour que Léa, Joël, Kévin entendent leur nom.
Pourquoi lire seul ? Pour raturer sans honte, à la Table des Sources.
Un livre, ici, n'est pas une vitrine. C'est un banc, une lampe, une mémoire.
Radio Figuier peut le dire. Elle ne remplace pas la page.
Solange range une copie au Bureau. La cour range l'autre sous le figuier.
Lisez. Relisez. Offrez une phrase, pas une rumeur.
Mado
Rukiri-Nord""",
        tf_item=(
            "« Le figuier n'oublie pas » est présenté comme un titre d'ailleurs.",
            False,
            "« Ce n'est pas un titre d'ailleurs. »",
        ),
        qcm_item=(
            "Pourquoi lire à voix haute, selon Mado ?",
            [
                "pour remplacer Sami",
                "pour que des prénoms soient entendus",
                "pour faire une rumeur",
                "pour fermer le Bureau",
            ],
            1,
            "« Pour que Léa, Joël, Kévin entendent leur nom. »",
        ),
        pairs=[
            ("qu'est-ce qui reste", "après la frappe"),
            ("qu'est-ce que nous devons", "noms / gestes"),
            ("avez-vous vu", "le livre de la cour"),
            ("pourquoi lire", "voix haute / seul"),
        ],
        fill_item=("Avez-vous vu « Le figuier n'oublie ___ » ?", "pas"),
        words=["Lisez", "."],
        anagram=("memoire", "La page est un banc, une lampe, une… (sans accent)."),
        error=(
            "Qu'est-ce que reste après la frappe de Sami sous le figuier ?",
            "Qu'est-ce qui reste après la frappe de Sami ?",
            "Rester → sujet : qu'est-ce qui.",
        ),
        pic_start=16,
        pic_words=["une soirée", "une lampe", "un cercle", "un banc"],
        short_p="Recopiez quatre questions de l'éloge et répondez-y.",
        audio="Lisez l'éloge, sans aller trop vite.",
    ),
    _l(
        "PO",
        "PO — Poser la question juste",
        "Interroger à l'oral : qui, que, inversion, infinitif.",
        "Répétez, puis debatez : pourquoi lire ?",
        "Modèles d'Aline",
        """Qu'est-ce qui vous émeut ?
Qu'est-ce que vous gardez d'une page ?
Avez-vous relu le cahier ?
Pourquoi lire sous le figuier ?
Pourquoi lire à voix haute ?
Pourquoi lire seul ?
Qu'est-ce qui manque sans livre ?
Qu'est-ce que le tambour ne peut pas écrire ?
Avez-vous prêté votre page ?
Pourquoi offrir une phrase ?
Je lis pour garder les noms.
Nous lisons pour nous entendre.""",
        tf_item=(
            "« Pourquoi lire » est une question à l'infinitif.",
            True,
            "Infinitif : question générale.",
        ),
        qcm_item=(
            "Pour l'objet « vous gardez une page », on demande…",
            [
                "qu'est-ce qui vous gardez",
                "qu'est-ce que vous gardez",
                "avez-vous qui",
                "pourquoi que",
            ],
            1,
            "Qu'est-ce que + sujet + verbe.",
        ),
        pairs=[
            ("qu'est-ce qui", "sujet"),
            ("qu'est-ce que", "objet"),
            ("avez-vous", "inversion"),
            ("pourquoi + inf.", "question large"),
        ],
        fill_item=("Qu'est-ce ___ vous émeut ?", "qui"),
        words=["Avez-vous", "relu", "le", "cahier", "?"],
        anagram=("debattre", "Pourquoi lire : on peut échanger des raisons, sans accent."),
        error=(
            "Qu'est-ce qui vous gardez d'une page sous le figuier ?",
            "Qu'est-ce que vous gardez d'une page ?",
            "Garder + objet → qu'est-ce que.",
        ),
        pic_start=17,
        pic_words=["une lampe", "un cercle", "un banc", "une saison"],
        short_p="Écrivez douze questions : 3 qui, 3 que, 3 inversions, 3 pourquoi + inf.",
        audio="Enregistrez les modèles, puis un échange de huit répliques.",
    ),
    _l(
        "PE",
        "PE — Pourquoi je lis",
        "Écrire un texte qui justifie la lecture, avec des questions.",
        "Imitez le texte de Léa, sans aller trop vite.",
        "Texte de Léa Niyonzima",
        """Léa Niyonzima
Qu'est-ce qui me tient, le soir ? Une phrase de Mado, parfois deux.
Qu'est-ce que je garde ? Les noms de la cour, pas une rumeur.
Avez-vous ouvert « Le figuier n'oublie pas » ? Je l'ai relu sous la lampe.
Pourquoi lire ? Pour que le tambour de Sami ne reste pas seul.
Pourquoi lire à voix haute ? Pour que Joël entende qu'on l'a vu.
Je n'emprunte pas un titre d'ailleurs. J'emprunte le Cahier du chemin.
La page garde ce que le son laisse filer.
Léa
Seuil des Sources — Rukiri-Nord""",
        tf_item=(
            "Léa emprunte un titre d'ailleurs.",
            False,
            "« Je n'emprunte pas un titre d'ailleurs. »",
        ),
        qcm_item=(
            "Pourquoi Léa lit-elle à voix haute ?",
            [
                "pour fermer Radio Figuier",
                "pour que Joël entende qu'on l'a vu",
                "pour vendre le cahier",
                "pour remplacer Solange",
            ],
            1,
            "« Pour que Joël entende qu'on l'a vu. »",
        ),
        pairs=[
            ("qu'est-ce qui me tient", "phrase de Mado"),
            ("qu'est-ce que je garde", "noms"),
            ("avez-vous ouvert", "livre de la cour"),
            ("pourquoi lire", "tambour / Joël"),
        ],
        fill_item=("Pourquoi ___ ? Pour que le tambour de Sami ne reste pas seul.", "lire"),
        words=["J'emprunte", "le", "Cahier", "du", "chemin", "."],
        anagram=("emprunte", "Léa le refuse pour un titre d'ailleurs ; elle… le cahier."),
        error=(
            "Qu'est-ce que me tient, le soir, sous la lampe du figuier ?",
            "Qu'est-ce qui me tient, le soir ?",
            "Sujet → qu'est-ce qui.",
        ),
        pic_start=18,
        pic_words=["un cercle", "un banc", "une saison", "un calendrier"],
        short_p="Imitez : deux qui, deux que, une inversion, deux pourquoi.",
        audio="Lisez votre texte, sans aller trop vite.",
    ),
    _l(
        "EL",
        "EL — Qu'est-ce qui, qu'est-ce que, inversion",
        "Retenir les formes d'interrogation pour parler des livres.",
        "Apprenez la fiche.",
        "Fiche questions",
        """Sujet
Qu'est-ce qui + verbe : Qu'est-ce qui vous émeut ?
Objet
Qu'est-ce que + sujet + verbe : Qu'est-ce que vous gardez ?
Inversion
Avez-vous ouvert le cahier ? L'entrée est-elle libre ?
Infinitif
Pourquoi lire ? Pourquoi lire à voix haute ? Pourquoi offrir une phrase ?
On n'écrit pas : qu'est-ce que tient la cour (sujet → qui).
On n'écrit pas : qu'est-ce qui vous gardez (objet → que).
Importance des livres au Seuil
garder les noms, relire « Le figuier n'oublie pas », raturer sans honte
Radio Figuier dit. La page garde.
Répondre : je lis pour… / nous lisons pour que + subjonctif.""",
        tf_item=(
            "« Qu'est-ce qui » introduit le sujet.",
            True,
            "Qu'est-ce qui vous émeut ?",
        ),
        qcm_item=(
            "« Avez-vous relu » est…",
            ["un qu'est-ce qui", "une inversion", "un infinitif", "un passif"],
            1,
            "Inversion sujet-verbe.",
        ),
        pairs=[
            ("qu'est-ce qui", "sujet"),
            ("qu'est-ce que", "objet"),
            ("avez-vous", "inversion"),
            ("pourquoi lire", "infinitif"),
        ],
        fill_item=("Qu'est-ce ___ vous gardez ?", "que"),
        words=["Pourquoi", "lire", "à", "voix", "haute", "?"],
        anagram=("inversion", "Avez-vous : une… du sujet."),
        error=(
            "Qu'est-ce qui vous gardez d'une page du Cahier du chemin ?",
            "Qu'est-ce que vous gardez d'une page ?",
            "Objet → que.",
        ),
        pic_start=19,
        pic_words=["un banc", "une saison", "un calendrier", "un tissu"],
        short_p="Inventez 12 questions sur « Le figuier n'oublie pas ».",
        audio="Enregistrez la fiche et douze questions.",
    ),
]


# ---------------------------------------------------------------------------
# Séquence 5 — Soirée lecture (EXTRA)
# ---------------------------------------------------------------------------

S5 = [
    _l(
        "CO",
        "CO — Cercle sous le figuier",
        "Suivre une soirée lecture et le rôle du Cahier du chemin.",
        "Lisez le dialogue. Qui lit ? Qui écoute ? Qui rature ?",
        "Cercle des voix, lampe-page",
        """Mado : On s'assoit en cercle. La Lampe-Figue suffit pour une page.
Aline : Qu'est-ce qui ouvre ? Une frappe de Sami, puis le silence.
Léa : Je te les lis, tes ratures, si tu veux. Sinon je lis les miennes.
Patrick : Avez-vous apporté le Cahier du chemin ? Il est au milieu.
Hawa : On me l'a conseillé, ce cercle. Je le trouve le plus calme.
Joël : Ne me le répète pas trop vite. Lisez plus lentement.
Lila : Radio Figuier n'enregistre pas ce soir. C'est pour la cour seulement.
Karim : Pourquoi lire ici, et pas au marché ? Parce que le marché vend.
Rose : La meilleure page n'est pas la plus longue.
Solange : Je le leur ai dit aux absents : on relira demain à la Table.
Kévin : Je n'ai rien dit. J'ai tenu le seau des lanternes éteintes.
Sami : Une frappe pour ouvrir. Une frappe pour fermer. Rien entre les deux, sauf la page.""",
        tf_item=(
            "Radio Figuier enregistre toute la soirée.",
            False,
            "Lila : « n'enregistre pas ce soir. »",
        ),
        qcm_item=(
            "Où est le Cahier du chemin, selon Patrick ?",
            ["au Bureau", "au milieu du cercle", "sous l'eau", "au marché"],
            1,
            "« Il est au milieu. »",
        ),
        pairs=[
            ("cercle", "sous le figuier"),
            ("Cahier du chemin", "milieu"),
            ("pas d'enregistrement", "Lila"),
            ("seau / lanternes", "Kévin"),
        ],
        fill_item=("Radio Figuier n'___ pas ce soir.", "enregistre"),
        words=["Il", "est", "au", "milieu", "."],
        anagram=("cercle", "On s'assoit ainsi sous le figuier."),
        error=(
            "Radio Figuier enregistre ce soir pour le marché entier.",
            "Radio Figuier n'enregistre pas ce soir. C'est pour la cour seulement.",
            "Le cercle est intime.",
        ),
        pic_start=20,
        pic_words=["une saison", "un calendrier", "un tissu", "une danse"],
        short_p="Notez le rituel : frappe, silence, page, frappe.",
        audio="Enregistrez le rituel du cercle, puis une page lue lentement.",
    ),
    _l(
        "CE",
        "CE — Règles du cercle",
        "Lire les règles d'une soirée lecture.",
        "Lisez les règles, sans aller trop vite.",
        "Feuille du cercle, Cahier du chemin",
        """Règles — soirée lecture sous le figuier
1. On s'assoit en cercle. Le cahier est au milieu.
2. Sami ouvre par une frappe. On se tait.
3. On lit une page, pas trois. La plus juste suffit.
4. On peut montrer ses ratures. On ne se moque pas.
5. Qu'est-ce qui est interdit ? La rumeur, le cri, l'enregistrement.
6. Qu'est-ce que l'on offre ? Une phrase, un silence, un prénom.
7. Avez-vous un doute ? Demandez après la page, pas pendant.
8. Pourquoi lire ici ? Pour que la cour s'entende sans micro.
9. Kévin peut tenir le seau sans parler. C'est un rôle.
10. Une frappe ferme. On range la Lampe-Figue.
Signé : Mado, Aline, Sami
Rukiri-Nord""",
        tf_item=(
            "On lit trois pages d'un trait.",
            False,
            "« On lit une page, pas trois. »",
        ),
        qcm_item=(
            "Quand demande-t-on si l'on a un doute ?",
            ["pendant la page", "après la page", "au marché", "jamais"],
            1,
            "« après la page, pas pendant. »",
        ),
        pairs=[
            ("une page", "pas trois"),
            ("ratures", "sans moquerie"),
            ("interdit", "rumeur / cri / enregistrement"),
            ("Kévin", "seau / rôle"),
        ],
        fill_item=("On lit une page, pas ___.", "trois"),
        words=["On", "ne", "se", "moque", "pas", "."],
        anagram=("moquerie", "Interdite quand on montre les ratures."),
        error=(
            "On lit trois pages et on se moque des ratures pour rire.",
            "On lit une page, pas trois. On peut montrer ses ratures. On ne se moque pas.",
            "Le cercle protège.",
        ),
        pic_start=21,
        pic_words=["un calendrier", "un tissu", "une danse", "une radio"],
        short_p="Recopiez cinq règles et ajoutez-en une à vous.",
        audio="Lisez les dix règles, sans aller trop vite.",
    ),
    _l(
        "PO",
        "PO — Tenir le cercle",
        "Animer une soirée lecture à l'oral.",
        "Répétez les formules, puis animez un mini-cercle.",
        "Formules de Mado",
        """Asseyez-vous. Le cahier est au milieu.
Sami, une frappe. Merci.
J'ouvre une page. Je la lis sans courir.
Je te les montre, mes ratures, si tu veux.
Ne me le coupe pas. Attends la fin.
Qu'est-ce qui vous reste ? Dites un mot.
Avez-vous un doute ? Après, pas pendant.
Pourquoi relire cette phrase ? Parce qu'elle tient.
Je vous le promets : on fermera à l'heure.
Une frappe. On range.
Merci à la cour.
Merci au figuier.""",
        tf_item=(
            "Mado autorise qu'on coupe la lecture.",
            False,
            "« Ne me le coupe pas. »",
        ),
        qcm_item=(
            "Que demande Mado juste après la page ?",
            [
                "une rumeur",
                "un mot de ce qui reste",
                "un enregistrement",
                "un cri",
            ],
            1,
            "« Qu'est-ce qui vous reste ? Dites un mot. »",
        ),
        pairs=[
            ("une frappe", "ouvrir / fermer"),
            ("sans courir", "lire"),
            ("après, pas pendant", "doutes"),
            ("un mot", "reste"),
        ],
        fill_item=("Ne me le ___ pas. Attends la fin.", "coupe"),
        words=["Dites", "un", "mot", "."],
        anagram=("animer", "Tenir le cercle : … la soirée."),
        error=(
            "Ne le me coupe pas dès la première ligne. Attends la fin.",
            "Ne me le coupe pas dès la première ligne. Attends la fin.",
            "Ordre : me + le + verbe.",
        ),
        pic_start=22,
        pic_words=["un tissu", "une danse", "une radio", "une couverture"],
        short_p="Écrivez un canevas d'animation de douze phrases.",
        audio="Enregistrez les formules, puis une ouverture et une fermeture.",
    ),
    _l(
        "PE",
        "PE — Ma page pour le cercle",
        "Écrire une page destinée à la soirée lecture.",
        "Imitez la page de Mado, sans aller trop vite.",
        "Page de Mado, Cahier du chemin",
        """Mado
Sous le figuier, la cour n'oublie pas les noms.
Qu'est-ce qui reste quand Sami se tait ? Cette ligne.
Qu'est-ce que je rature ? La peur d'être trop simple.
Avez-vous entendu Kévin sans qu'il parle ? Moi, oui.
Pourquoi lire ceci à voix haute ? Pour que Joël se reconnaisse.
Je le vous promettrais trop fort : je vous le promets, simplement.
Une page, pas trois. La meilleure n'est pas la plus longue.
Mado
Soirée lecture — Seuil des Sources""",
        tf_item=(
            "Mado veut lire trois pages.",
            False,
            "« Une page, pas trois. »",
        ),
        qcm_item=(
            "Que rature Mado ?",
            [
                "les noms de la cour",
                "la peur d'être trop simple",
                "le tambour",
                "le figuier",
            ],
            1,
            "« La peur d'être trop simple. »",
        ),
        pairs=[
            ("qu'est-ce qui reste", "cette ligne"),
            ("qu'est-ce que je rature", "peur"),
            ("avez-vous entendu", "Kévin"),
            ("pourquoi lire", "Joël"),
        ],
        fill_item=("Une page, pas ___.", "trois"),
        words=["La", "cour", "n'oublie", "pas", "les", "noms", "."],
        anagram=("reconnait", "Joël se… (sans accent)."),
        error=(
            "Je le vous promets trop fort sous le figuier ce soir.",
            "Je vous le promets trop fort sous le figuier ce soir.",
            "Vous avant le.",
        ),
        pic_start=23,
        pic_words=["une danse", "une radio", "une couverture", "un masque"],
        short_p="Imitez : une page courte, deux questions, un superlatif, un pronom double.",
        audio="Lisez votre page, sans aller trop vite.",
    ),
    _l(
        "EL",
        "EL — Tenir une soirée lecture",
        "Retenir le rituel du cercle et du Cahier du chemin.",
        "Apprenez la fiche.",
        "Fiche du cercle",
        """Rituel : cercle, cahier au milieu, frappe, page, mot, frappe
Objets : Cahier du chemin, Lampe-Figue, seau de Kévin, tambour de Sami
Interdit : rumeur, cri, moquerie, enregistrement, couper la voix
Autorisé : ratures, silence, un mot après, rôle muet
Langue : qu'est-ce qui vous reste ? Avez-vous un doute ? Pourquoi relire ?
Je te les montre. Ne me le coupe pas. Je vous le promets.
La meilleure page n'est pas la plus longue.
On lit pour la cour, pas pour une une.
Radio Figuier peut attendre au matin.
Sous le figuier, une page suffit.""",
        tf_item=(
            "Le cercle autorise la moquerie si elle est douce.",
            False,
            "Moquerie interdite.",
        ),
        qcm_item=(
            "Où pose-t-on le cahier ?",
            ["au marché", "au milieu", "sous l'eau", "au Bureau seulement"],
            1,
            "Au milieu du cercle.",
        ),
        pairs=[
            ("frappe", "ouvrir / fermer"),
            ("page", "une, pas trois"),
            ("interdit", "rumeur / cri"),
            ("autorisé", "ratures / silence"),
        ],
        fill_item=("La meilleure page n'est pas la plus ___.", "longue"),
        words=["Une", "page", "suffit", "."],
        anagram=("rituel", "Cercle, frappe, page, frappe : un…"),
        error=(
            "On pose le cahier au marché et on enregistre pour rire.",
            "Le cahier est au milieu. Enregistrement interdit.",
            "Le cercle protège la page.",
        ),
        pic_start=24,
        pic_words=["une radio", "une couverture", "un masque", "un pupitre"],
        short_p="Charte personnelle du cercle : 8 articles.",
        audio="Enregistrez la fiche et le rituel complet.",
    ),
]


# ---------------------------------------------------------------------------
# Séquence 6 — Inventer une saison (EXTRA)
# ---------------------------------------------------------------------------

S6 = [
    _l(
        "CO",
        "CO — Programmer les voix",
        "Inventer et ordonner une saison culturelle au Seuil.",
        "Lisez le dialogue. Qui programme quoi ?",
        "Calendrier des voix, tissu de scène",
        """Aline : D'abord, on nomme la saison : Saison des Voix.
Lila : Ensuite, on place la pièce le mercredi : « La cour n'oublie pas ».
Mado : Par ailleurs, le jeudi reste au cercle lecture.
Sami : En outre, le vendredi porte le tambour au Marché des Lampions.
Karim : En conclusion, on garde un samedi blanc : il se peut que l'eau monte.
Patrick : Qu'est-ce qui manque ? Une danse de la cour, légère.
Rose : C'est Dieudonné que je vois pour le tissu de scène.
Hawa : Je vous le promets : Radio Figuier lira le calendrier, pas une rumeur.
Joël : Avez-vous pensé à Yvette ? Une pause d'herbes entre deux soirs.
Solange : Je le leur afficherai, aux portes du Bureau.
Léa : Pourquoi programmer ainsi ? Pour que personne n'oublie personne.
Marc : Le moins attendu, ce sera le seau de Kévin, chaque ouverture.""",
        tf_item=(
            "Le samedi est déjà plein de spectacles.",
            False,
            "Karim : samedi blanc, l'eau peut monter.",
        ),
        qcm_item=(
            "Quel jour la pièce est-elle placée ?",
            ["jeudi", "vendredi", "mercredi", "samedi"],
            2,
            "Lila : mercredi.",
        ),
        pairs=[
            ("mercredi", "pièce"),
            ("jeudi", "cercle"),
            ("vendredi", "tambour / marché"),
            ("samedi", "blanc / eau"),
        ],
        fill_item=("D'abord, on ___ la saison : Saison des Voix.", "nomme"),
        words=["On", "garde", "un", "samedi", "blanc", "."],
        anagram=("programmer", "Ordonner les soirs : … une saison."),
        error=(
            "D'abord on place la pièce, ensuite on nomme la saison trop tard.",
            "D'abord, on nomme la saison : Saison des Voix. Ensuite, on place la pièce.",
            "Nommer, puis placer.",
        ),
        pic_start=25,
        pic_words=["une couverture", "un masque", "un pupitre", "un théâtre"],
        short_p="Dessinez la semaine : quatre soirs, un blanc, une raison.",
        audio="Enregistrez le calendrier : mercredi pièce, jeudi cercle, vendredi marché, samedi blanc.",
    ),
    _l(
        "CE",
        "CE — Calendrier des Voix",
        "Lire un programme de saison inventé par la cour.",
        "Lisez le calendrier, sans aller trop vite.",
        "Feuille saison, Bureau des Escales",
        """Saison des Voix — calendrier
Mercredi — Salle des Herbes — 18 h
« La cour n'oublie pas », le spectacle le plus émouvant, vingt minutes.
Jeudi — figuier — 17 h
Cercle lecture, Cahier du chemin, Lampe-Figue. Une page, pas trois.
Vendredi — Marché des Lampions — 18 h
Tambour de Sami, page de Mado, coupon de Dieudonné.
Samedi — blanc : il se peut que la rive demande les bras.
Dimanche — Table des Sources : relecture à voix basse. Avez-vous noté les prénoms oubliés ?
Interdit : titre d'ailleurs, salle lointaine, une payante.
Autorisé : seau de Kévin, silence, droit de ne pas lire.
Signé : Aline, Lila, Mado, Sami, Solange — Rukiri-Nord""",
        tf_item=(
            "Le dimanche, on joue la pièce une seconde fois en courant.",
            False,
            "Relecture à voix basse.",
        ),
        qcm_item=(
            "Que fait-on le samedi, selon le calendrier ?",
            [
                "on joue deux pièces",
                "on le garde blanc",
                "on enregistre",
                "on vend des titres d'ailleurs",
            ],
            1,
            "Samedi — blanc.",
        ),
        pairs=[
            ("mercredi", "pièce"),
            ("jeudi", "cercle"),
            ("vendredi", "marché"),
            ("dimanche", "prénoms / voix basse"),
        ],
        fill_item=("Samedi — ___.", "blanc"),
        words=["Une", "page", "pas", "trois", "."],
        anagram=("calendrier", "La feuille qui range les soirs de la saison."),
        error=(
            "Interdit : seau de Kévin. Autorisé : titre d'ailleurs et salle lointaine.",
            "Interdit : titre d'ailleurs, salle lointaine, une payante. Autorisé : seau de Kévin, silence.",
            "La saison reste au Seuil.",
        ),
        pic_start=26,
        pic_words=["un masque", "un pupitre", "un théâtre", "un soleil"],
        short_p="Recopiez le calendrier et inventez un lundi de clôture.",
        audio="Lisez le calendrier, sans aller trop vite.",
    ),
    _l(
        "PO",
        "PO — Présenter la saison",
        "Présenter oralement un programme culturel.",
        "Répétez, puis présentez votre semaine de voix.",
        "Modèles de Lila",
        """Voici la Saison des Voix.
Ce qui ouvre, c'est la pièce de mercredi.
C'est le cercle que nous plaçons le jeudi.
Ce que le vendredi porte, c'est le tambour au marché.
Pourquoi garder le samedi blanc ? À cause de la rive.
Avez-vous une danse à proposer ? Dites-le-nous.
Je vous le lis, le calendrier, une fois.
Ne me le faites pas crier. C'est une saison, pas une rumeur.
La meilleure soirée sera celle où Kévin tiendra le seau.
Le moins attendu sera un silence juste.
Nous demandons votre oreille, pas votre argent.
Merci à la cour.""",
        tf_item=(
            "Lila demande de l'argent à l'entrée.",
            False,
            "« votre oreille, pas votre argent. »",
        ),
        qcm_item=(
            "Que porte le vendredi, selon Lila ?",
            ["un tampon", "le tambour au marché", "une crue", "un examen"],
            1,
            "« le tambour au marché. »",
        ),
        pairs=[
            ("ce qui ouvre", "pièce"),
            ("c'est le cercle que", "jeudi"),
            ("samedi blanc", "rive"),
            ("oreille / pas argent", "éthique"),
        ],
        fill_item=("Nous demandons votre ___, pas votre argent.", "oreille"),
        words=["Voici", "la", "Saison", "des", "Voix", "."],
        anagram=("proposer", "Une danse : Avez-vous une danse à… ?"),
        error=(
            "Nous demandons votre argent, pas votre oreille, dès l'affiche.",
            "Nous demandons votre oreille, pas votre argent.",
            "Saison gratuite de la cour.",
        ),
        pic_start=27,
        pic_words=["un pupitre", "un théâtre", "un soleil", "un superlatif"],
        short_p="Écrivez une présentation orale de dix phrases.",
        audio="Enregistrez les modèles, puis votre présentation de saison.",
    ),
    _l(
        "PE",
        "PE — Ma saison écrite",
        "Écrire le programme d'une saison culturelle inventée.",
        "Imitez le programme de Karim, sans aller trop vite.",
        "Programme de Karim",
        """Karim
Saison des Voix — ma proposition
D'abord, mercredi : « La cour n'oublie pas », le plus émouvant.
Ensuite, jeudi : cercle, Cahier du chemin, une page.
Par ailleurs, vendredi : Sami au marché, Mado, Dieudonné.
En outre, samedi blanc : il se peut que l'eau monte.
En conclusion, dimanche : qu'est-ce qui a manqué ? On le note.
Avez-vous mieux ? Dites-le-moi. Je vous les copie, les heures.
Je ne prends aucun titre d'ailleurs. Je reste au Seuil.
Karim
Rukiri-Nord""",
        tf_item=(
            "Karim prend un titre d'ailleurs pour le mercredi.",
            False,
            "« Je ne prends aucun titre d'ailleurs. »",
        ),
        qcm_item=(
            "Que fait Karim si quelqu'un a mieux ?",
            [
                "il refuse",
                "il copie les heures pour la personne",
                "il ferme la saison",
                "il part",
            ],
            1,
            "« Dites-le-moi. Je vous les copie, les heures. »",
        ),
        pairs=[
            ("d'abord", "pièce"),
            ("ensuite", "cercle"),
            ("par ailleurs", "marché"),
            ("en conclusion", "dimanche / manqué"),
        ],
        fill_item=("Dites-le-moi. Je vous ___ copie, les heures.", "les"),
        words=["Je", "reste", "au", "Seuil", "."],
        anagram=("proposition", "Karim l'écrit : sa… de saison."),
        error=(
            "Dites-moi-le. Je les vous copie, les heures, trop vite.",
            "Dites-le-moi. Je vous les copie, les heures.",
            "Impératif : dis-le-moi. Vous avant les.",
        ),
        pic_start=28,
        pic_words=["un théâtre", "un soleil", "un superlatif", "une affiche"],
        short_p="Imitez : cinq marches, une question, un double pronom, un refus d'ailleurs.",
        audio="Lisez votre programme, sans aller trop vite.",
    ),
    _l(
        "EL",
        "EL — Inventer une saison",
        "Retenir comment programmer la Saison des Voix.",
        "Apprenez la fiche.",
        "Fiche de saison",
        """Nommer : Saison des Voix — un nom du Seuil, pas d'ailleurs.
Placer : d'abord / ensuite / par ailleurs / en outre / en conclusion
Œuvres : « La cour n'oublie pas » ; « Le figuier n'oublie pas » ; Cahier du chemin
Gestes : pièce, cercle, tambour, tissu, seau, silence
Questions : qu'est-ce qui manque ? Avez-vous mieux ? Pourquoi ce jour-là ?
Pronoms : dites-le-moi. Je vous les copie. Nous demandons votre oreille.
Superlatif : le plus émouvant, la meilleure soirée, le moins attendu
Interdit : titre lointain, salle lointaine, une payante, rumeur de salle pleine
Un samedi blanc est une politesse faite à la rive.
La saison sert la cour, pas l'inverse.""",
        tf_item=(
            "Un samedi blanc est un oubli honteux.",
            False,
            "C'est une politesse faite à la rive.",
        ),
        qcm_item=(
            "Quel nom de saison est celui du Seuil ?",
            [
                "un nom d'ailleurs",
                "Saison des Voix",
                "un titre payant",
                "une rumeur",
            ],
            1,
            "Saison des Voix.",
        ),
        pairs=[
            ("nommer", "Saison des Voix"),
            ("placer", "marches"),
            ("samedi blanc", "rive"),
            ("oreille", "pas d'argent"),
        ],
        fill_item=("La saison sert la ___, pas l'inverse.", "cour"),
        words=["La", "saison", "sert", "la", "cour", "."],
        anagram=("politesse", "Le samedi blanc : une… faite à la rive."),
        error=(
            "Un samedi blanc est une politesse fait à la rive.",
            "Un samedi blanc est une politesse faite à la rive.",
            "Politesse : participe féminin faite.",
        ),
        pic_start=29,
        pic_words=["un soleil", "un superlatif", "une affiche", "une œuvre"],
        short_p="Rédigez la charte de votre saison : 8 articles, 4 soirs.",
        audio="Enregistrez la fiche et votre calendrier parlé.",
    ),
]


SEQUENCES = [
    {"title": "Une critique enthousiaste", "lessons": S1},
    {"title": "Spectacles et parcours", "lessons": S2},
    {"title": "Réagir à une œuvre", "lessons": S3},
    {"title": "Pourquoi lire", "lessons": S4},
    {"title": "Soirée lecture", "lessons": S5},
    {"title": "Inventer une saison", "lessons": S6},
]
