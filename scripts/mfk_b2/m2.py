"""B2 Module 2 — Mémoire du Seuil (univers Seuil des Sources)."""

from factory import L

IMG = "mfk-b2-m2"
IMG_DIR = IMG

MODULE = {
    "title": "B2 — Mémoire du Seuil",
    "description": (
        "Grande étape B2-2 : former des hypothèses sur le passé, relier un métier "
        "à une société qui change, nommer des lieux d'enfance, comparer trois "
        "voix du récit, ouvrir les archives du Cahier du chemin et tenir une "
        "table ronde — « ce que le figuier a vu » — avec Sami, Mado, Dieudonné, "
        "Aline Uwase et Radio Figuier, au Seuil des Sources (Rukiri-Nord)."
    ),
}


def _l(comp, title, obj, cons, st, sp, **kw):
    return L(IMG, comp, title, obj, cons, st, sp, **kw)


# ---------------------------------------------------------------------------
# Séquence 1 — Hypothèses sur le passé (si + PQP → conditionnel passé)
# ---------------------------------------------------------------------------

S1 = [
    _l(
        "CO",
        "CO — Si j'avais su, sous le figuier",
        "Repérer si + plus-que-parfait et le conditionnel passé pour une hypothèse non réalisée.",
        "Lisez l'entretien (à écouter avec l'enseignant). Quelles actions n'ont pas eu lieu ?",
        "Entretien sous le figuier, photos ocre",
        """Sami : Si j'avais su que le Cahier du chemin dormait si longtemps, j'aurais ouvert plus tôt.
Mado : Si nous avions écouté les anciens avant la pluie, nous aurions noté d'autres noms.
Aline Uwase : Attention : si + plus-que-parfait, ensuite le conditionnel passé. Pas « si j'aurais ».
Léa Niyonzima : Si j'avais su le pont si glissant, je serais restée trois jeudis de plus.
Patrick Habimana : Si tu m'avais prévenu, j'aurais porté la valise autrement, moins vite.
Marc Nkurunziza : Si Lila avait enregistré Sami à temps, Radio Figuier aurait une archive, pas seulement un écho.
Hawa Diallo : Si nous n'avions pas attendu, nous aurions perdu moins de voix.
Joël Mugisha : Si j'avais su le vent de ce soir-là, j'aurais accroché moins haut.
Rose Iradukunda : Si l'on m'avait dit le nom du premier lin, j'aurais cousu une pièce de plus, pour la cour.
Solange Mukamana : Si le tampon avait été posé, nous saurions la date. Là, nous hypothesons.
Karim Bamba : Si j'avais su qui payait l'huile, j'aurais moins crié sur le prix.
Lila Sow : Si j'avais tendu le micro plus tôt, j'aurais moins de regrets, plus de bandes.
Félicie : Si Dieudonné avait réparé la table avant, le cahier n'aurait pas glissé.
Yvette : Si nous avions nommé les dangers, quelqu'un se serait moins brûlé les doigts.""",
        tf_item=(
            "Aline accepte la tournure « si j'aurais su » comme correcte.",
            False,
            "Aline : si + plus-que-parfait, ensuite le conditionnel passé. Pas « si j'aurais ».",
        ),
        qcm_item=(
            "Que dit Sami qu'il aurait fait, s'il avait su pour le cahier ?",
            [
                "Il aurait fermé le figuier",
                "Il aurait ouvert plus tôt",
                "Il aurait vendu les photos",
                "Il aurait quitté Rukiri-Nord",
            ],
            1,
            "Si j'avais su […], j'aurais ouvert plus tôt.",
        ),
        pairs=[
            ("si j'avais su", "plus-que-parfait"),
            ("j'aurais ouvert", "conditionnel passé"),
            ("si nous avions écouté", "hypothèse non réalisée"),
            ("pas si j'aurais", "erreur fréquente"),
        ],
        fill_item=("Si j'avais su, j'___ ouvert plus tôt. (avoir, cond. passé)", "aurais"),
        words=["Si", "j'avais", "su", "j'aurais", "ouvert", "plus", "tôt", "."],
        anagram=("hypothese", "Idée sur ce qui a pu se passer, sans preuve fermée. (sans accent)"),
        error=(
            "Si j'aurais su que le cahier dormait, j'aurais ouvert plus tôt, et Mado aurait noté les noms.",
            "Si j'avais su que le cahier dormait, j'aurais ouvert plus tôt, et Mado aurait noté les noms.",
            "Si + plus-que-parfait : si j'avais su, pas si j'aurais su.",
        ),
        pic_start=0,
        pic_words=["une hypothèse", "un plus-que-parfait", "un conditionnel", "une photo"],
        short_p="Relevez cinq phrases si + PQP et le conditionnel passé qui les suit.",
        audio="Enregistrez : Si j'avais su, j'aurais ouvert plus tôt. Si nous avions écouté, nous aurions noté.",
    ),
    _l(
        "CE",
        "CE — Hypothèses sur une pluie oubliée",
        "Lire un article qui forme des hypothèses précises sur un passé non prouvé.",
        "Lisez l'article de Mado, sans aller trop vite.",
        "Article de Mado, feuille pour le Cahier du chemin",
        """On ne sait pas tout de la pluie qui a taché le premier cahier. On peut pourtant former des hypothèses avec soin.
Si Sami avait ouvert le coffre avant l'orage, les pages n'auraient pas gondolé.
Si Lila avait tendu le micro ce soir-là, Radio Figuier aurait une voix, pas seulement un écho.
Si Dieudonné avait calé la table, le bol de Félicie n'aurait pas versé sur l'encre.
Aline écrit : parler du passé avec précision, ce n'est pas inventer une légende.
C'est dire ce que l'on tient (un tampon manquant) et ce que l'on imagine (une date).
Marc ajoute que « si j'avais su » n'est pas un reproche : c'est une grammaire du regret utile.
Si nous avions noté qui payait l'huile, Karim crierait moins aujourd'hui.
Si Rose avait su le nom du premier lin, elle aurait cousu une pièce pour la cour, dit-elle.
Léa et Patrick, s'ils avaient su le pont si glissant, seraient restés un jeudi de plus.
Yvette nuance : si l'on avait nommé le danger, quelqu'un se serait moins brûlé.
Solange refuse les dates inventées : on forme une hypothèse, on n'imprime pas un faux tampon.
Joël, s'il avait su le vent, aurait accroché moins haut : voilà une hypothèse utile pour demain.
Nous relirons cet article lorsque nous aurons ouvert le coffre, pas avant d'avoir les mains propres.""",
        tf_item=(
            "Solange accepte d'imprimer un tampon avec une date inventée.",
            False,
            "On forme une hypothèse, on n'imprime pas un faux tampon.",
        ),
        qcm_item=(
            "Selon Aline, parler du passé avec précision, c'est…",
            [
                "Inventer une légende complète",
                "Dire ce que l'on tient et ce que l'on imagine",
                "Se taire",
                "Corriger Sami seulement",
            ],
            1,
            "Dire ce que l'on tient (tampon manquant) et ce que l'on imagine (une date).",
        ),
        pairs=[
            ("si Sami avait ouvert", "les pages n'auraient pas gondolé"),
            ("si Lila avait tendu", "une voix, pas un écho"),
            ("si Dieudonné avait calé", "l'encre sauvée"),
            ("si Joël avait su le vent", "moins haut"),
        ],
        fill_item=("Si nous avions noté qui payait, Karim ___ moins aujourd'hui. (crier, cond.)", "crierait"),
        words=["Si", "Sami", "avait", "ouvert", "les", "pages", "tiendraient", "."],
        anagram=("savais", "Imparfait de savoir, personne je, dans une hypothèse non réalisée."),
        error=(
            "Si Lila aurait tendu le micro ce soir-là, Radio Figuier aurait une voix, et Sami parlerait encore.",
            "Si Lila avait tendu le micro ce soir-là, Radio Figuier aurait une voix, et Sami parlerait encore.",
            "Si + plus-que-parfait : si Lila avait tendu, pas si Lila aurait.",
        ),
        pic_start=1,
        pic_words=["un plus-que-parfait", "un conditionnel", "une photo", "un métier"],
        short_p="Soulignez six hypothèses et dites ce qui est tenu, ce qui est imaginé.",
        audio="Lisez l'article, sans aller trop vite.",
    ),
    _l(
        "PO",
        "PO — Dire si j'avais su, j'aurais",
        "Prononcer des hypothèses non réalisées avec si + PQP et le conditionnel passé.",
        "Répétez les modèles, puis formulez trois regrets utiles du Seuil.",
        "Modèles d'Aline et de Sami, banc ocre",
        """Si j'avais su, j'aurais ouvert plus tôt.
Si nous avions écouté, nous aurions noté les noms.
Si tu m'avais prévenu, j'aurais ralenti.
Si Lila avait enregistré, nous aurions une archive.
Si Dieudonné avait calé la table, le cahier n'aurait pas glissé.
Si j'avais su le vent, j'aurais accroché moins haut.
Si elle avait nommé le danger, quelqu'un se serait moins brûlé.
Si vous aviez tamponné, nous saurions la date.
Je serais resté un jeudi de plus si j'avais su le pont.
Nous n'aurions pas perdu ces voix si nous n'avions pas attendu.
Aline : jamais « si j'aurais su ».
Sami : le regret sert demain, pas seulement à se plaindre.
Mado : dites ce que vous tenez, puis ce que vous imaginez.
Lila : une hypothèse, une pause, le micro près de la bouche.""",
        tf_item=(
            "On dit « si j'aurais su » à l'oral soigné du Seuil.",
            False,
            "Aline : jamais « si j'aurais su ». On dit si j'avais su.",
        ),
        qcm_item=(
            "Quelle phrase est correcte ?",
            [
                "Si j'aurais su, j'ouvrais",
                "Si j'avais su, j'aurais ouvert plus tôt",
                "Si je saurai, j'aurais ouvert",
                "Si j'aurais, j'avais ouvert",
            ],
            1,
            "Si + PQP, conditionnel passé.",
        ),
        pairs=[
            ("si j'avais su", "j'aurais ouvert"),
            ("si nous avions écouté", "nous aurions noté"),
            ("si elle avait nommé", "se serait moins brûlé"),
            ("jamais", "si j'aurais"),
        ],
        fill_item=("Si tu m'avais prévenu, j'___ ralenti. (avoir, cond. passé)", "aurais"),
        words=["Si", "nous", "avions", "écouté", "nous", "aurions", "noté", "."],
        anagram=("aurions", "Conditionnel passé, personne nous, pour l'action qui n'a pas eu lieu."),
        error=(
            "Si j'avais su le pont, je serai resté un jeudi de plus, et Léa aurait écrit.",
            "Si j'avais su le pont, je serais resté un jeudi de plus, et Léa aurait écrit.",
            "Conditionnel passé avec être : je serais resté, pas je serai resté.",
        ),
        pic_start=2,
        pic_words=["un conditionnel", "une photo", "un métier", "une société"],
        short_p="Écrivez huit phrases : si + PQP + conditionnel passé, sur la mémoire du Seuil.",
        audio="Enregistrez les huit premiers modèles, puis trois regrets utiles à vous.",
    ),
    _l(
        "PE",
        "PE — Mes hypothèses sur le coffre",
        "Écrire un texte d'hypothèses précises avec si + PQP et le conditionnel passé.",
        "Imitez la note de Sami.",
        "Note de Sami, photo glissée dans le cahier",
        """Sami — Seuil des Sources, Rukiri-Nord
Si j'avais su que le coffre du Cahier du chemin dormait sous la table, j'aurais appelé Dieudonné dès l'aube.
Si nous avions écouté les anciens avant la pluie, nous aurions plus de noms et moins de taches.
Si Lila avait tendu le micro ce soir-là, Radio Figuier aurait une archive, pas seulement un écho.
Je tiens ceci : le tampon manque. J'imagine ceci : une date juste après la grande pluie.
Si Karim avait su qui payait l'huile, il aurait moins crié, et nous aurions mieux pesé.
Si Rose avait entendu le nom du premier lin, elle aurait cousu une pièce pour la cour.
Léa, si elle avait su le pont, serait restée un jeudi ; Patrick aussi, je crois.
Aline a raison : ce n'est pas une légende. C'est une grammaire pour ne plus perdre.
Si j'avais ouvert plus tôt, j'aurais moins de regrets, plus de pages.
Voilà ce que je peux dire, sans faux tampon.
Sami""",
        tf_item=(
            "Sami prétend connaître la date exacte et l'imprimer au tampon.",
            False,
            "Il tient le tampon manquant ; il imagine une date. Pas de faux tampon.",
        ),
        qcm_item=(
            "Que tiendra Sami, et qu'imagine-t-il ?",
            [
                "Il tient une légende, il imagine un pont",
                "Il tient le tampon manquant, il imagine une date après la pluie",
                "Il ne tient rien",
                "Il tient Radio Figuier",
            ],
            1,
            "Je tiens ceci : le tampon manque. J'imagine ceci : une date…",
        ),
        pairs=[
            ("si j'avais su", "j'aurais appelé Dieudonné"),
            ("si nous avions écouté", "plus de noms"),
            ("si Lila avait tendu", "une archive"),
            ("tenir / imaginer", "tampon / date"),
        ],
        fill_item=("Si Lila avait tendu le micro, Radio Figuier ___ une archive. (avoir, cond.)", "aurait"),
        words=["Je", "tiens", "ceci", "le", "tampon", "manque", "."],
        anagram=("regret", "Sentiment : on n'a pas agi, on imagine l'autre suite possible."),
        error=(
            "Si j'aurais ouvert plus tôt, j'aurais moins de regrets, et le cahier serait plus lisible.",
            "Si j'avais ouvert plus tôt, j'aurais moins de regrets, et le cahier serait plus lisible.",
            "Si + plus-que-parfait : si j'avais ouvert.",
        ),
        pic_start=3,
        pic_words=["une photo", "un métier", "une société", "un atelier"],
        short_p="Imitez : douze lignes, quatre si + PQP, une phrase « je tiens / j'imagine ».",
        audio="Lisez votre note, sans aller trop vite.",
    ),
    _l(
        "EL",
        "EL — Si + plus-que-parfait, conditionnel passé",
        "Retenir la construction des hypothèses sur un passé non réalisé.",
        "Apprenez la fiche.",
        "Fiche d'Aline Uwase, photo ocre",
        """Parler du passé avec précision : séparer ce que l'on tient et ce que l'on imagine.
Hypothèse non réalisée : Si + plus-que-parfait, + conditionnel passé.
Si j'avais su, j'aurais ouvert. Si nous avions écouté, nous aurions noté.
Si elle avait nommé le danger, quelqu'un se serait moins brûlé. (être + participe)
Formation du PQP : avoir / être à l'imparfait + participe (j'avais su, elle était partie).
Formation du conditionnel passé : avoir / être au conditionnel présent + participe (j'aurais ouvert, je serais resté).
Erreur fréquente : Si j'aurais su → Si j'avais su.
Ne pas mettre le conditionnel dans la proposition en si.
Je serai (futur réel) ≠ je serais (conditionnel) ≠ je serais resté (cond. passé, être).
Je ferai (1 r) ; je pourrai (2 r) ; il faut (3e pers.).
Le regret sert demain : Joël accrochera moins haut s'il a compris le vent.
Pas de faux tampon : on forme une hypothèse, on n'imprime pas une date inventée.
Cahier du chemin, Radio Figuier, table de Dieudonné : trois lieux pour vérifier.
Il faut un exemple tenu, un exemple imaginé, dans chaque texte.""",
        tf_item=(
            "Le conditionnel se place dans la proposition introduite par si.",
            False,
            "Jamais si j'aurais. Si + PQP ; le conditionnel est dans l'autre proposition.",
        ),
        qcm_item=(
            "Quelle série est correcte ?",
            [
                "Si j'aurais su, j'avais ouvert",
                "Si j'avais su, j'aurais ouvert",
                "Si je saurai, j'ouvre",
                "Si j'aurais, j'aurais",
            ],
            1,
            "Si + PQP + conditionnel passé.",
        ),
        pairs=[
            ("si + PQP", "condition non réalisée"),
            ("conditionnel passé", "conséquence non advenue"),
            ("je tiens", "fait vérifiable"),
            ("j'imagine", "hypothèse"),
        ],
        fill_item=("Si elle avait nommé le danger, quelqu'un se ___ moins brûlé. (être, cond. passé)", "serait"),
        words=["Si", "j'avais", "su", "j'aurais", "ouvert", "."],
        anagram=("condition", "Rapport : si ceci avait eu lieu, cela aurait suivi."),
        error=(
            "Si nous avions écouté, nous aurions noté, et il fautons un exemple tenu dans chaque texte.",
            "Si nous avions écouté, nous aurions noté, et il faut un exemple tenu dans chaque texte.",
            "Toujours il faut, à la 3e personne.",
        ),
        pic_start=4,
        pic_words=["un métier", "une société", "un atelier", "une ligne"],
        short_p="Conjuguez six verbes au PQP et au conditionnel passé ; écrivez quatre phrases si…",
        audio="Enregistrez la fiche, puis cinq hypothèses correctes.",
    ),
]


# ---------------------------------------------------------------------------
# Séquence 2 — Un métier, une société (Dieudonné, Aline, Radio)
# ---------------------------------------------------------------------------

S2 = [
    _l(
        "CO",
        "CO — Trois métiers, une cour qui change",
        "Comprendre comment l'on décrit un métier et son évolution sociale au Seuil.",
        "Lisez le débat. Qui fait quoi, et qu'est-ce qui a changé ?",
        "Débat à la Salle des Herbes, outils sur la table",
        """Dieudonné : Autrefois je réparais seulement les bancs. Désormais je cale aussi le coffre du cahier : le métier a grossi.
Aline Uwase : J'accompagnais les arrivées. Aujourd'hui j'enseigne aussi à formuler un avis, pas seulement à trouver une clé.
Lila Sow : Radio Figuier n'est plus un écho du soir. C'est un métier : couper, garder, dater.
Marc Nkurunziza : Une société change quand un geste devient une responsabilité nommée.
Rose Iradukunda : Mon ourlet n'est plus un passe-temps : c'est un salaire, ou ce n'est pas un métier.
Karim Bamba : Si l'on n'avait pas dit « qui paie », ces métiers resteraient des faveurs.
Solange Mukamana : Le Bureau n'existe pas ici comme tampon d'État ; le Seuil tamponne autrement : par le cahier.
Hawa Diallo : Joël accroche ; Félicie sert ; Yvette veille. Trois métiers invisibles dès qu'on parle trop de « vocations ».
Léa Niyonzima : À Rive-des-Saules, on nomme autrement les mêmes gestes. Ce n'est pas plus noble.
Patrick Habimana : Si j'avais appris plus tôt le nom des outils, j'aurais moins gâché le bois.
Sami : Les anciens réparaient sans le dire. Nous, nous devons le dire, sinon la radio l'oublie.
Mado : Décrire un métier, c'est dire les gestes, les risques, les dettes, pas seulement le titre.
Félicie : Mon bol nourrit une société qui discute : sans lui, le débat s'écroule à midi.
Yvette : Un métier qui nie le danger n'est pas adulte, même s'il plaît.""",
        tf_item=(
            "Dieudonné dit que son métier n'a pas changé : il répare seulement les bancs.",
            False,
            "Désormais il cale aussi le coffre du cahier : le métier a grossi.",
        ),
        qcm_item=(
            "Selon Mado, décrire un métier, c'est surtout…",
            [
                "Donner un titre trop beau",
                "Dire les gestes, les risques, les dettes",
                "Cacher qui paie",
                "Imiter Val-des-Peupliers",
            ],
            1,
            "Gestes, risques, dettes, pas seulement le titre.",
        ),
        pairs=[
            ("Dieudonné", "réparer, caler"),
            ("Aline", "accompagner, enseigner l'avis"),
            ("Lila", "couper, garder, dater"),
            ("Rose", "ourlet et salaire"),
        ],
        fill_item=("Une société change quand un geste devient une ___ nommée.", "responsabilité"),
        words=["Décrire", "un", "métier", "c'est", "dire", "les", "gestes", "."],
        anagram=("metier", "Ensemble de gestes payés, pas seulement un titre. (sans accent)"),
        error=(
            "Si l'on n'avait pas dit qui paie, ces métiers resteraient des faveurs, et je ferrai encore semblant que c'est une vocation.",
            "Si l'on n'avait pas dit qui paie, ces métiers resteraient des faveurs, et je ferai encore semblant que c'est une vocation.",
            "Futur de faire : je ferai, un seul r.",
        ),
        pic_start=5,
        pic_words=["une société", "un atelier", "une ligne", "un passé"],
        short_p="Notez trois métiers, un geste chacun, et ce qui a changé dans la société du Seuil.",
        audio="Enregistrez : Autrefois je réparais les bancs. Désormais je cale aussi le coffre. C'est un métier.",
    ),
    _l(
        "CE",
        "CE — Du geste au métier, du métier à la cour",
        "Lire un article sur l'évolution sociale des métiers du Seuil.",
        "Lisez l'article de Marc, sans aller trop vite.",
        "Article de Marc Nkurunziza, ligne du temps ocre",
        """Une société se lit à ses métiers, pas seulement à ses fêtes.
Dieudonné répare : autrefois un banc, désormais un coffre, une table, parfois un micro trop lâche.
Si l'on n'avait pas nommé ce geste, il serait resté une faveur, et Lila n'aurait personne à créditer.
Aline Uwase accompagne encore les arrivées ; elle enseigne aussi à tenir un avis sous le figuier.
Radio Figuier, sous Lila Sow, est devenu un métier d'écoute : couper les insultes, garder les doutes, dater les bandes.
Rose Iradukunda a imposé un salaire à l'ourlet : sans cela, la couture restait un « don » trop commode.
Félicie, Joël, Yvette tiennent des métiers que l'on oublie dès que l'on parle trop de vocation.
Karim a raison : une société qui ne dit pas qui paie ment sur ses métiers.
Sami rappelle que les anciens réparaient sans affiche ; nous, nous devons afficher, sinon l'archive saute.
À Rive-des-Saules, les mêmes gestes portent d'autres noms : ce n'est pas une noblesse, c'est une autre cour.
Léa écrit que partir n'efface pas ces dettes : on emporte le souvenir d'un métier, pas seulement d'un arbre.
Mado classe : titre, gestes, risques, dettes, évolution.
Solange refuse le faux tampon « métier officiel » : le Seuil nomme autrement, par le cahier.
Nous jugerons ces évolutions lorsque nous aurons écouté ceux qui ont les mains dessus, pas seulement ceux qui ont le micro.""",
        tf_item=(
            "L'article dit qu'à Rive-des-Saules les mêmes gestes sont plus nobles.",
            False,
            "Ce n'est pas une noblesse, c'est une autre cour.",
        ),
        qcm_item=(
            "Que classe Mado pour décrire un métier ?",
            [
                "Seulement le titre",
                "Titre, gestes, risques, dettes, évolution",
                "Seulement le salaire",
                "Seulement la vocation",
            ],
            1,
            "Mado classe : titre, gestes, risques, dettes, évolution.",
        ),
        pairs=[
            ("Dieudonné", "banc, coffre, table"),
            ("Aline", "arrivées et avis"),
            ("Lila", "écoute datée"),
            ("Rose", "salaire de l'ourlet"),
        ],
        fill_item=("Si l'on n'avait pas nommé ce geste, il ___ resté une faveur. (être, cond. passé)", "serait"),
        words=["Une", "société", "se", "lit", "à", "ses", "métiers", "."],
        anagram=("societe", "Ensemble de dettes, de gestes et de noms, autour d'une cour. (sans accent)"),
        error=(
            "Radio Figuier est devenu un métier d'écoute, et Lila serai prête demain à l'heure fixée pour dater les bandes.",
            "Radio Figuier est devenu un métier d'écoute, et Lila sera prête demain à l'heure fixée pour dater les bandes.",
            "Futur réel : elle sera, pas serai (1re pers.) ni serais.",
        ),
        pic_start=6,
        pic_words=["un atelier", "une ligne", "un passé", "un lieu"],
        short_p="Pour quatre métiers : titre, un geste, un risque, une évolution.",
        audio="Lisez l'article, sans aller trop vite.",
    ),
    _l(
        "PO",
        "PO — Dire un métier sans le décorer",
        "Décrire à l'oral un métier du Seuil : gestes, risques, dettes, évolution.",
        "Répétez, puis présentez un métier en deux minutes, sans slogan.",
        "Modèles d'Aline, Dieudonné et Lila",
        """Autrefois je réparais les bancs ; désormais je cale aussi le coffre.
J'accompagne les arrivées, et j'enseigne à tenir un avis.
Je coupe les insultes, je garde les doutes, je date les bandes.
Mon ourlet n'est un métier que s'il est payé.
Un geste devient une responsabilité dès qu'on le nomme.
Si l'on n'avait pas dit qui paie, cela resterait une faveur.
Les risques : le dos, la flamme, l'encre versée, la voix trop vite.
Les dettes : envers ceux qui ont réparé sans affiche.
À Rive-des-Saules, on nomme autrement ; ce n'est pas plus noble.
Décrire, ce n'est pas décorer.
Dieudonné : montrez l'outil, pas seulement le mot.
Aline : dites l'évolution en une phrase.
Lila : une phrase, une pause.
Mado : titre, gestes, risques, dettes.""",
        tf_item=(
            "Décrire un métier, d'après les modèles, c'est surtout le décorer.",
            False,
            "Décrire, ce n'est pas décorer.",
        ),
        qcm_item=(
            "Quand un geste devient-il une responsabilité ?",
            [
                "Quand on le cache",
                "Dès qu'on le nomme",
                "Seulement à Val-des-Peupliers",
                "Jamais, par principe",
            ],
            1,
            "Un geste devient une responsabilité dès qu'on le nomme.",
        ),
        pairs=[
            ("autrefois / désormais", "évolution"),
            ("gestes", "réparer, caler, couper"),
            ("risques", "dos, flamme, encre"),
            ("dettes", "ceux sans affiche"),
        ],
        fill_item=("Mon ourlet n'est un métier que s'il est ___.", "payé"),
        words=["Décrire", "ce", "n'est", "pas", "décorer", "."],
        anagram=("atelier", "Lieu où Dieudonné et Rose tiennent leurs outils, pas une vitrine."),
        error=(
            "Si l'on n'avait pas nommé ce geste, il serait resté une faveur, et je pourai encore l'oublier demain.",
            "Si l'on n'avait pas nommé ce geste, il serait resté une faveur, et je pourrai encore l'oublier demain.",
            "Futur de pouvoir : je pourrai, deux r.",
        ),
        pic_start=7,
        pic_words=["une ligne", "un passé", "un lieu", "une préposition"],
        short_p="Écrivez un portrait oral de douze phrases : un métier, évolution, risques, dettes.",
        audio="Enregistrez les huit premiers modèles, puis votre portrait de deux minutes.",
    ),
    _l(
        "PE",
        "PE — Portrait d'un métier du Seuil",
        "Écrire le portrait argumenté d'un métier et de son évolution sociale.",
        "Imitez le portrait de Dieudonné.",
        "Portrait par Dieudonné, établi ocre",
        """Dieudonné — Seuil des Sources, derrière la Salle des Herbes
Autrefois je réparais les bancs du figuier. Désormais je cale le coffre du Cahier du chemin, et parfois le pied du micro.
Si l'on n'avait pas nommé ces gestes, ils seraient restés des faveurs, et Radio Figuier n'aurait personne à créditer.
Aline enseigne à tenir un avis ; Lila date les bandes ; Rose impose un salaire à l'ourlet. Nous formons une société, pas une vitrine.
Les risques : le dos, l'encre versée, une table qui lâche sous le cahier.
Les dettes : envers ceux qui réparaient sans affiche, dit Sami.
À Rive-des-Saules, on dirait autrement ; ce n'est pas plus noble.
Karim demandera qui paie le bois : je répondrai, dès que j'aurai fini de caler.
Yvette veillera au dos. Félicie tiendra le bol de midi, sinon le métier s'écroule.
Je ne décore pas. Je décris.
Si j'avais appris plus tôt le nom de chaque outil, j'aurais moins gâché.
Voilà mon métier, ni trop fier, ni trop humble.
Dieudonné""",
        tf_item=(
            "Dieudonné dit qu'à Rive-des-Saules les mêmes gestes sont plus nobles.",
            False,
            "On dirait autrement ; ce n'est pas plus noble.",
        ),
        qcm_item=(
            "Que répondra Dieudonné à Karim, et à quelle condition ?",
            [
                "Il ne répondra jamais",
                "Il répondra dès qu'il aura fini de caler",
                "Il vendra le coffre",
                "Il partira au pavillon",
            ],
            1,
            "Je répondrai, dès que j'aurai fini de caler.",
        ),
        pairs=[
            ("autrefois", "les bancs"),
            ("désormais", "coffre et micro"),
            ("risques", "dos, encre, table"),
            ("dettes", "sans affiche"),
        ],
        fill_item=("Dès que j'___ fini de caler, je répondrai. (avoir, FA)", "aurai"),
        words=["Je", "ne", "décore", "pas", "je", "décris", "."],
        anagram=("evolution", "Changement d'un geste qui devient une responsabilité. (sans accent)"),
        error=(
            "Dès que j'aurai fini de caler, je répondrai, et je serais prêt à l'heure réelle du jeudi.",
            "Dès que j'aurai fini de caler, je répondrai, et je serai prêt à l'heure réelle du jeudi.",
            "Heure déjà fixée : je serai, pas je serais.",
        ),
        pic_start=8,
        pic_words=["un passé", "un lieu", "une préposition", "un banc"],
        short_p="Imitez : un portrait de douze lignes, évolution, risques, dettes, une hypothèse si + PQP.",
        audio="Lisez votre portrait, sans aller trop vite.",
    ),
    _l(
        "EL",
        "EL — Décrire un métier, lire une société",
        "Retenir le lexique et les structures pour un portrait de métier.",
        "Apprenez la fiche.",
        "Fiche d'Aline et de Mado, ligne du temps",
        """Décrire un métier : titre, gestes, outils, risques, dettes, évolution.
Autrefois + imparfait ; désormais / aujourd'hui + présent.
Un geste devient une responsabilité dès qu'on le nomme.
Si + PQP + conditionnel passé : si l'on n'avait pas nommé, cela serait resté une faveur.
Futur antérieur avant de répondre : dès que j'aurai fini de caler, je répondrai.
Métiers du Seuil : Dieudonné (réparer, caler), Aline (accompagner, enseigner l'avis), Lila / Radio (couper, garder, dater).
Autres gestes à nommer : Rose (ourlet payé), Félicie (bol), Joël (lanternes), Yvette (danger).
Société : qui paie, qui copie, qui oublie, qui archive.
Rive-des-Saules nomme autrement : ce n'est pas plus noble.
Décrire ≠ décorer. Titre ≠ vocation trop commode.
Je ferai (1 r) ; je pourrai (2 r) ; il faut (3e pers.) ; je serai / je serais.
Bien que le métier change, il faut dire les dettes.
Pas de faux tampon « officiel » : le Seuil nomme par le cahier.
Il faut un risque et une dette dans chaque portrait.""",
        tf_item=(
            "Un titre suffit à décrire un métier, selon la fiche.",
            False,
            "Titre, gestes, outils, risques, dettes, évolution.",
        ),
        qcm_item=(
            "Quelle opposition de temps structure l'évolution ?",
            [
                "seulement le futur",
                "autrefois + imparfait / désormais + présent",
                "seulement le passé simple",
                "seulement le conditionnel",
            ],
            1,
            "Autrefois je réparais ; désormais je cale.",
        ),
        pairs=[
            ("autrefois", "imparfait"),
            ("désormais", "présent"),
            ("si on n'avait pas nommé", "faveur"),
            ("dès que j'aurai fini", "ensuite répondre"),
        ],
        fill_item=("Autrefois je ___ les bancs ; désormais je cale le coffre. (réparer, imp.)", "réparais"),
        words=["Un", "geste", "nommé", "devient", "une", "responsabilité", "."],
        anagram=("dettes", "Ce que l'on doit à ceux qui ont agi sans affiche."),
        error=(
            "Bien que le métier change, il fautons dire les dettes, et Aline tient l'avis.",
            "Bien que le métier change, il faut dire les dettes, et Aline tient l'avis.",
            "Toujours il faut, à la 3e personne.",
        ),
        pic_start=9,
        pic_words=["un lieu", "une préposition", "un banc", "un récit"],
        short_p="Tableau : six métiers du Seuil, un geste, un risque, une évolution chacun.",
        audio="Enregistrez la fiche, puis le portrait d'un métier en six phrases.",
    ),
]


# ---------------------------------------------------------------------------
# Séquence 3 — Lieux d'enfance (passé simple en CE, prépositions de lieu)
# ---------------------------------------------------------------------------

S3 = [
    _l(
        "CO",
        "CO — Au-delà du figuier, en contrebas du pont",
        "Repérer les prépositions de lieu précises pour des lieux d'enfance.",
        "Lisez les souvenirs. Où se situent les lieux, les uns par rapport aux autres ?",
        "Souvenirs à la Table des Sources, carte de Rukiri-Nord",
        """Sami : Au-delà du figuier, il y avait un sentier que les enfants n'avaient pas le droit de nommer trop fort.
Mado : En contrebas du futur pont — il n'était alors qu'une planche — nous posions les pieds dans l'eau.
Aline Uwase : À travers la cour, on courait jusqu'à la Salle des Herbes, sans regarder Lampe-Figue.
Léa Niyonzima : Le long de ce qui deviendrait Rive-des-Saules, ma grand-mère tenait une ombre, pas encore un pavillon.
Patrick Habimana : Vis-à-vis du banc ocre, un second banc, plus bas, servait aux plus jeunes.
Hawa Diallo : À proximité du Marché des Lampions — déjà bruyant — on vendait moins, on échangeait plus.
Joël Mugisha : En amont de la cour, le vent prenait les lanternes trop tôt. J'aurais dû le savoir.
Rose Iradukunda : Derrière la Salle des Herbes, un lin séchait : mon premier tissu, dit-elle, n'était pas encore un métier.
Karim Bamba : Au-delà des herbes, quelqu'un payait déjà l'huile, mais sans le dire.
Lila Sow : Radio Figuier n'existait pas. Il y avait une voix, à travers les feuilles, rien d'autre.
Félicie : En contrebas de la table, un bol plus petit : mon enfance tenait là.
Dieudonné : Autour du figuier, les racines faisaient des sièges. J'ai appris le bois là, pas ailleurs.
Yvette : À travers les flammes trop hautes, on voyait déjà le danger, si l'on acceptait de le nommer.
Marc Nkurunziza : Une préposition précise vaut une légende vague.""",
        tf_item=(
            "Sami situe le sentier interdit en contrebas du figuier.",
            False,
            "Au-delà du figuier, il y avait un sentier.",
        ),
        qcm_item=(
            "Où Mado posait-elle les pieds, selon son souvenir ?",
            [
                "Au-delà de Lampe-Figue seulement",
                "En contrebas du futur pont, dans l'eau",
                "Vis-à-vis de Radio Figuier",
                "À Val-des-Peupliers déjà",
            ],
            1,
            "En contrebas du futur pont, dans l'eau.",
        ),
        pairs=[
            ("au-delà de", "plus loin que"),
            ("en contrebas de", "plus bas que"),
            ("à travers", "en traversant"),
            ("vis-à-vis de", "en face de"),
        ],
        fill_item=("___ du figuier, il y avait un sentier. (plus loin)", "Au-delà"),
        words=["En", "contrebas", "du", "pont", "nous", "posions", "les", "pieds", "."],
        anagram=("enfance", "Temps des premiers lieux, avant que les métiers aient un nom."),
        error=(
            "À travers la cour on courait, et il fautons une préposition précise plutôt qu'une légende vague.",
            "À travers la cour on courait, et il faut une préposition précise plutôt qu'une légende vague.",
            "Toujours il faut, à la 3e personne.",
        ),
        pic_start=10,
        pic_words=["une préposition", "un banc", "un récit", "trois voix"],
        short_p="Relevez six prépositions de lieu et le lieu qu'elles situent.",
        audio="Enregistrez : Au-delà du figuier, un sentier. En contrebas du pont, l'eau. À travers la cour, on courait.",
    ),
    _l(
        "CE",
        "CE — Ce que l'enfance prit et ce que nous vîmes",
        "Comprendre un récit d'enfance au passé simple et situer les lieux.",
        "Lisez le récit de Sami, sans aller trop vite.",
        "Récit de Sami, archive du Cahier du chemin",
        """Sami dit alors la vérité qu'il tenait, non celle qu'il imaginait.
Il prit la photo ocre, la posa vis-à-vis du banc, et nous vîmes enfin le sentier au-delà du figuier.
Elle — Mado — ouvrit le cahier ; l'encre parut plus claire en contrebas de la tache de pluie.
Nous fûmes saisis : à travers la cour, un second figuier, plus jeune, avait existé, puis disparu.
Il fallut un silence. Lila ne dit mot ; Aline, elle, reprit : « Situez, ne décorez pas. »
Karim vint plus tard ; il écrivit en marge le mot « huile », rien d'autre.
Les anciens parlèrent : en amont de la cour, le vent prit toujours les lanternes trop tôt.
Léa lut la ligne du pont ; Patrick, en contrebas, reconnut l'eau de ses pieds d'enfant.
Rose passa le doigt sur un lin dessiné : ce tissu-là, dit-elle, n'était pas encore un métier.
Dieudonné toucha une racine ; il fut, un instant, l'enfant qui apprit le bois.
Yvette nota le danger : à travers les flammes trop hautes, quelqu'un se brûla, jadis.
Félicie, elle, garda le petit bol : son enfance tenait encore là, à proximité de la table.
Joël vit, sur la photo, une lanterne trop haute, et il promit de moins haut.
Nous relûmes la page lorsque le soleil baissa ; le passé simple, ici, n'était pas une parure : il faisait voir.""",
        tf_item=(
            "Le récit dit que Lila parla longuement pendant le silence.",
            False,
            "Lila ne dit mot ; Aline reprit : « Situez, ne décorez pas. »",
        ),
        qcm_item=(
            "Que vîmes-nous, selon Sami, à travers la cour ?",
            [
                "Radio Figuier déjà bâtie",
                "Un second figuier, plus jeune, puis disparu",
                "Le Pavillon du Saule",
                "Un tampon officiel",
            ],
            1,
            "À travers la cour, un second figuier, plus jeune, avait existé, puis disparu.",
        ),
        pairs=[
            ("il prit / nous vîmes", "passé simple"),
            ("au-delà du figuier", "le sentier"),
            ("en contrebas de la tache", "l'encre plus claire"),
            ("à travers la cour", "le second figuier"),
        ],
        fill_item=("Il ___ la photo ocre et la posa vis-à-vis du banc. (prendre, PS)", "prit"),
        words=["Nous", "vîmes", "enfin", "le", "sentier", "."],
        anagram=("contrebas", "Plus bas que le pont ou que la tache : l'eau, l'encre plus claire."),
        error=(
            "Nous vîmes le sentier au-delà du figuier, et Sami prit la photo, puis il fallutons un silence.",
            "Nous vîmes le sentier au-delà du figuier, et Sami prit la photo, puis il fallut un silence.",
            "Passé simple de falloir : il fallut, invariable à la 3e personne.",
        ),
        pic_start=11,
        pic_words=["un banc", "un récit", "trois voix", "un cahier"],
        short_p="Relevez huit passés simples et quatre prépositions de lieu, avec leur complément.",
        audio="Lisez le récit, sans aller trop vite.",
    ),
    _l(
        "PO",
        "PO — Dire au-delà, en contrebas, à travers",
        "Situer à l'oral des lieux d'enfance avec des prépositions précises.",
        "Répétez, puis décrivez trois lieux de votre enfance sans légende vague.",
        "Modèles d'Aline et de Sami, carte ocre",
        """Au-delà du figuier, il y avait un sentier.
En contrebas du pont, nous posions les pieds dans l'eau.
À travers la cour, on courait jusqu'aux herbes.
Le long de la future rive, une ombre tenait lieu de pavillon.
Vis-à-vis du banc ocre, un banc plus bas servait aux plus jeunes.
À proximité du marché déjà bruyant, on échangeait plus qu'on ne vendait.
En amont de la cour, le vent prenait les lanternes.
Autour des racines, j'ai appris le bois.
Derrière la salle, un lin séchait.
Une préposition précise vaut une légende vague.
Sami : situez d'abord, racontez ensuite.
Mado : un lieu, une préposition, un geste.
Lila : une phrase, une pause.
Marc : ne décorez pas.""",
        tf_item=(
            "« En contrebas de » signifie plus loin, au même niveau.",
            False,
            "En contrebas de = plus bas que (pont, tache, table).",
        ),
        qcm_item=(
            "Quelle préposition convient pour « en traversant l'espace » ?",
            [
                "en contrebas de",
                "à travers",
                "vis-à-vis de seulement",
                "en amont de seulement",
            ],
            1,
            "À travers la cour, à travers les feuilles, à travers les flammes.",
        ),
        pairs=[
            ("au-delà de", "plus loin"),
            ("en contrebas de", "plus bas"),
            ("à travers", "en traversant"),
            ("en amont de", "plus haut / avant sur le cours"),
        ],
        fill_item=("___ la cour, on courait jusqu'aux herbes.", "À travers"),
        words=["Au-delà", "du", "figuier", "il", "y", "avait", "un", "sentier", "."],
        anagram=("traverse", "Action de passer d'un bord à l'autre d'une cour ou d'une flamme."),
        error=(
            "En contrebas du pont nous posions les pieds, et je ferrai encore ce chemin demain à l'aube.",
            "En contrebas du pont nous posions les pieds, et je ferai encore ce chemin demain à l'aube.",
            "Futur de faire : je ferai, un seul r.",
        ),
        pic_start=12,
        pic_words=["un récit", "trois voix", "un cahier", "des archives"],
        short_p="Écrivez dix phrases de lieu : au-delà, en contrebas, à travers, le long de, vis-à-vis.",
        audio="Enregistrez les huit premiers modèles, puis trois lieux d'enfance à vous.",
    ),
    _l(
        "PE",
        "PE — Mes lieux d'enfance",
        "Écrire un souvenir de lieux d'enfance avec prépositions précises.",
        "Imitez le souvenir de Mado.",
        "Souvenir de Mado, plume ocre",
        """Mado — Rukiri-Nord, encore le Seuil
Au-delà du figuier, le sentier existait ; nous n'avions pas le droit de le nommer trop fort.
En contrebas de la planche — ce n'était pas encore un pont — je posais les pieds dans l'eau, et Léa riait.
À travers la cour, on courait jusqu'à la Salle des Herbes ; Lampe-Figue n'était qu'une lueur.
Vis-à-vis du banc des plus grands, notre banc plus bas servait de frontière.
À proximité des Lampions déjà bruyants, on échangeait des feuilles, on vendait peu.
Si j'avais su qu'un second figuier disparaîtrait, j'aurais dessiné plus tôt.
Dieudonné, autour des racines, apprenait le bois ; Rose, derrière la salle, un lin.
Yvette nommait déjà le danger à travers les flammes trop hautes.
Je tiens la photo. J'imagine l'heure. Je n'imprime pas de faux tampon.
Sami dit que situer, ce n'est pas décorer. Je le crois.
Voilà mes lieux, ni trop doux, ni trop nets.
Mado""",
        tf_item=(
            "Mado imprime un tampon avec une heure inventée.",
            False,
            "Je tiens la photo. J'imagine l'heure. Je n'imprime pas de faux tampon.",
        ),
        qcm_item=(
            "Que ferait Mado, si elle avait su la disparition du second figuier ?",
            [
                "Elle aurait fermé la cour",
                "Elle aurait dessiné plus tôt",
                "Elle aurait vendu la photo",
                "Elle aurait quitté le Seuil",
            ],
            1,
            "Si j'avais su […], j'aurais dessiné plus tôt.",
        ),
        pairs=[
            ("au-delà du figuier", "le sentier"),
            ("en contrebas de la planche", "l'eau"),
            ("à travers la cour", "la Salle des Herbes"),
            ("vis-à-vis du banc", "frontière"),
        ],
        fill_item=("En contrebas de la planche, je posais les pieds ___ l'eau.", "dans"),
        words=["Situer", "ce", "n'est", "pas", "décorer", "."],
        anagram=("souvenir", "Image d'un lieu d'enfance, tenue par une photo ou une phrase."),
        error=(
            "Si j'aurais su qu'un second figuier disparaîtrait, j'aurais dessiné plus tôt, et Sami aurait vu le croquis.",
            "Si j'avais su qu'un second figuier disparaîtrait, j'aurais dessiné plus tôt, et Sami aurait vu le croquis.",
            "Si + plus-que-parfait : si j'avais su.",
        ),
        pic_start=13,
        pic_words=["trois voix", "un cahier", "des archives", "une table"],
        short_p="Imitez : douze lignes, cinq prépositions de lieu, une hypothèse si + PQP.",
        audio="Lisez votre souvenir, sans aller trop vite.",
    ),
    _l(
        "EL",
        "EL — Prépositions de lieu et passé simple lu",
        "Retenir les prépositions précises et reconnaître le passé simple à la lecture.",
        "Apprenez la fiche.",
        "Fiche d'Aline, carte de Rukiri-Nord",
        """Prépositions : au-delà de (plus loin), en contrebas de (plus bas), à travers (en traversant).
le long de, vis-à-vis de, à proximité de, en amont de, autour de, derrière.
Au-delà du figuier ; en contrebas du pont ; à travers la cour.
Une préposition précise vaut une légende vague.
Passé simple (à reconnaître en CE, pas à inventer partout) :
il dit / elle dit ; il prit / elle prit ; nous vîmes / ils virent ; il fut / nous fûmes.
il vint, elle ouvrit, il écrivit, il fallut, ils parlèrent, elle reprit, nous relûmes.
Il prit la photo ; nous vîmes le sentier ; il fallut un silence.
Le passé simple fait voir une action close ; l'imparfait décrit le décor (il y avait un sentier).
Si + PQP reste utile : si j'avais su, j'aurais dessiné.
Ne pas écrire il fallutons : il fallut.
Lieux d'enfance du Seuil : sentier, planche, racines, petit bol, lin derrière la salle.
Situez d'abord, racontez ensuite.
Il faut un lieu, une préposition, un geste.""",
        tf_item=(
            "« Nous vîmes » est un imparfait de voir.",
            False,
            "Nous vîmes : passé simple de voir, personne nous.",
        ),
        qcm_item=(
            "Quel est le passé simple de prendre, à la 3e personne du singulier ?",
            [
                "il prenait",
                "il prit",
                "il a pris seulement",
                "il prendra",
            ],
            1,
            "Il prit la photo.",
        ),
        pairs=[
            ("au-delà de", "plus loin"),
            ("en contrebas de", "plus bas"),
            ("à travers", "en traversant"),
            ("il prit / nous vîmes", "passé simple"),
        ],
        fill_item=("Nous ___ le sentier au-delà du figuier. (voir, PS)", "vîmes"),
        words=["Il", "prit", "la", "photo", "ocre", "."],
        anagram=("vimes", "Passé simple de voir, personne nous, sans accent ici."),
        error=(
            "Nous vîmes le sentier, et il fallutons un silence avant qu'Aline reprît la parole.",
            "Nous vîmes le sentier, et il fallut un silence avant qu'Aline reprît la parole.",
            "Il fallut, jamais fallutons.",
        ),
        pic_start=14,
        pic_words=["un cahier", "des archives", "une table", "un micro"],
        short_p="Tableau : six prépositions + exemple ; six passés simples relevés ou conjugués.",
        audio="Enregistrez la fiche, puis six phrases de lieu et trois phrases au passé simple lu.",
    ),
]


# ---------------------------------------------------------------------------
# Séquence 4 — Raconter l'histoire autrement (oral, archive, radio)
# ---------------------------------------------------------------------------

S4 = [
    _l(
        "CO",
        "CO — Trois voix pour le même soir",
        "Comparer un récit oral, une archive écrite et une bande radio.",
        "Lisez la confrontation. Que garde chaque voix, que perd-elle ?",
        "Confrontation sous le figuier, trois supports",
        """Sami : À l'oral, je peux hésiter, répéter, montrer la photo. Je perds la date exacte.
Mado : L'archive du Cahier du chemin garde l'encre et la marge. Elle perd le souffle, le silence.
Lila Sow : La radio garde une voix datée. Elle perd le geste de la main sur la racine.
Aline Uwase : Raconter autrement, ce n'est pas se contredire : c'est changer d'outil.
Marc Nkurunziza : Si nous n'avions qu'une voix, nous prendrions une légende pour une preuve.
Léa Niyonzima : L'oral de Sami m'a fait voir le sentier ; l'archive m'a fait toucher la tache.
Patrick Habimana : La bande de Lila m'a fait entendre le vent. Sans elle, j'aurais trop vite conclu.
Hawa Diallo : Chaque voix a une dette : l'oral envers la date, l'écrit envers le souffle, la radio envers le geste.
Joël Mugisha : Je crois les trois, à condition de les nommer comme trois, pas comme une.
Rose Iradukunda : Une histoire cousue d'une seule voix laisse un ourlet trop serré.
Solange Mukamana : Pas de faux tampon pour unifier ce qui doit rester multiple.
Karim Bamba : Qui paie l'enregistrement ? Qui garde le cahier ? Ce sont déjà des choix de récit.
Félicie : Mon bol n'apparaît que dans l'oral de Sami. L'archive l'a oublié. C'est un argument.
Yvette : Le danger, lui, doit être dans les trois voix, sinon l'une des trois ment.""",
        tf_item=(
            "Aline dit que raconter autrement, c'est forcément se contredire.",
            False,
            "Raconter autrement, ce n'est pas se contredire : c'est changer d'outil.",
        ),
        qcm_item=(
            "Que perd la radio, selon Lila ?",
            [
                "La voix datée",
                "Le geste de la main sur la racine",
                "Toute vérité",
                "Le vent",
            ],
            1,
            "Elle perd le geste de la main sur la racine.",
        ),
        pairs=[
            ("récit oral", "souffle, photo, pas de date"),
            ("archive", "encre, marge, pas de souffle"),
            ("radio", "voix datée, pas de geste"),
            ("trois voix", "pas une légende"),
        ],
        fill_item=("Raconter autrement, c'est changer d'___, pas se contredire.", "outil"),
        words=["Chaque", "voix", "a", "une", "dette", "."],
        anagram=("archive", "Page datée du cahier, qui garde l'encre et perd le souffle."),
        error=(
            "Si nous n'avions qu'une voix, nous prendrions une légende pour une preuve, et il fautons les nommer comme trois.",
            "Si nous n'avions qu'une voix, nous prendrions une légende pour une preuve, et il faut les nommer comme trois.",
            "Toujours il faut, à la 3e personne.",
        ),
        pic_start=15,
        pic_words=["des archives", "une table", "un micro", "une lettre"],
        short_p="Pour oral, archive, radio : un gain, une perte, une dette.",
        audio="Enregistrez : L'oral garde le souffle. L'archive garde l'encre. La radio garde une voix datée.",
    ),
    _l(
        "CE",
        "CE — La même pluie, trois récits",
        "Lire un article qui compare trois versions du même événement.",
        "Lisez l'article de Marc, sans aller trop vite.",
        "Article de Marc, trois colonnes ocre",
        """La pluie qui tacha le cahier existe désormais en trois récits, et c'est une richesse, non un scandale.
Sami dit — à l'oral, sous le figuier — qu'il prit trop tard la décision d'ouvrir le coffre.
L'archive, elle, n'écrit pas « trop tard » : elle montre une tache, une marge, un tampon manquant.
Radio Figuier, lorsque Lila eut tendu le micro, garda le vent et perdit la main de Dieudonné sur le bois.
Nous vîmes, en comparant, ce que chaque voix refuse de porter.
Si nous avions cru Sami seul, nous aurions une faute et peu de preuves.
Si nous avions cru l'archive seule, nous aurions une tache et peu de souffle.
Si nous avions cru la bande seule, nous aurions un vent et peu de table.
Aline conclut : raconter autrement, c'est assumer une dette, pas corriger les autres.
Félicie n'apparaît que dans l'oral : l'oubli du bol est déjà un choix de société.
Yvette exige que le danger — flamme, encre, dos — traverse les trois voix.
Solange refuse un tampon unique qui ferait « la » version.
Léa, à Rive-des-Saules, entendra surtout la radio ; elle devra venir pour l'archive.
Karim demandera qui paie la bande : c'est encore raconter, autrement.
Nous publierons les trois, lorsque nous aurons daté chacune, pas une synthèse trop lisse.""",
        tf_item=(
            "L'article présente les trois récits comme un scandale à corriger.",
            False,
            "Trois récits, et c'est une richesse, non un scandale.",
        ),
        qcm_item=(
            "Que garde Radio Figuier, et que perd-elle, dans cet article ?",
            [
                "Elle garde la table, elle perd le vent",
                "Elle garde le vent, elle perd la main de Dieudonné sur le bois",
                "Elle garde le bol, elle perd Sami",
                "Elle ne garde rien",
            ],
            1,
            "Garda le vent et perdit la main de Dieudonné sur le bois.",
        ),
        pairs=[
            ("oral de Sami", "« trop tard », peu de preuves"),
            ("archive", "tache, marge, tampon manquant"),
            ("radio", "vent, pas de table"),
            ("trois voix", "richesse, pas scandale"),
        ],
        fill_item=("Si nous avions cru Sami seul, nous ___ une faute et peu de preuves. (avoir, cond. passé)", "aurions"),
        words=["Raconter", "autrement", "c'est", "assumer", "une", "dette", "."],
        anagram=("echo", "Ce qui reste d'une voix quand la bande ou le geste manque. (sans accent)"),
        error=(
            "Si nous aurions cru l'archive seule, nous aurions une tache et peu de souffle, et Léa l'entendrait de loin.",
            "Si nous avions cru l'archive seule, nous aurions une tache et peu de souffle, et Léa l'entendrait de loin.",
            "Si + plus-que-parfait : si nous avions cru.",
        ),
        pic_start=16,
        pic_words=["une table", "un micro", "une lettre", "un pont"],
        short_p="Remplissez trois colonnes : oral / archive / radio — gain, perte, oubli.",
        audio="Lisez l'article, sans aller trop vite.",
    ),
    _l(
        "PO",
        "PO — Dire ce que chaque voix garde",
        "Comparer à l'oral trois outils du récit : oral, archive, radio.",
        "Répétez, puis racontez le même fait de trois façons, en nommant l'outil.",
        "Modèles d'Aline, Sami et Lila",
        """À l'oral, je peux montrer la photo ; je perds la date.
Dans l'archive, je garde l'encre ; je perds le souffle.
À la radio, je garde une voix datée ; je perds le geste.
Raconter autrement, ce n'est pas se contredire.
Chaque voix a une dette.
Si nous n'avions qu'une voix, nous prendrions une légende pour une preuve.
L'oubli du bol est déjà un choix.
Le danger doit traverser les trois voix.
Je crois les trois, à condition de les nommer comme trois.
Pas de tampon unique.
Sami : l'oral hésite, c'est permis.
Mado : l'écrit date, c'est une dette envers l'heure.
Lila : la bande se coupe, c'est un métier.
Marc : publiez les trois, pas une synthèse trop lisse.""",
        tf_item=(
            "On doit unifier les trois voix par un seul tampon, selon les modèles.",
            False,
            "Pas de tampon unique. Publiez les trois.",
        ),
        qcm_item=(
            "Que risque-t-on, si l'on n'a qu'une voix ?",
            [
                "Rien",
                "Prendre une légende pour une preuve",
                "Gagner les trois dettes",
                "Mieux dater",
            ],
            1,
            "Nous prendrions une légende pour une preuve.",
        ),
        pairs=[
            ("oral", "photo, pas de date"),
            ("archive", "encre, pas de souffle"),
            ("radio", "voix datée, pas de geste"),
            ("trois voix", "richesse"),
        ],
        fill_item=("Chaque voix a une ___.", "dette"),
        words=["Pas", "de", "tampon", "unique", "."],
        anagram=("souffle", "Ce que l'oral garde et que la page ne peut plus porter."),
        error=(
            "Si nous n'avions qu'une voix, nous prendrions une légende pour une preuve, et je ferrai une synthèse trop lisse.",
            "Si nous n'avions qu'une voix, nous prendrions une légende pour une preuve, et je ferai une synthèse trop lisse.",
            "Futur de faire : je ferai, un seul r.",
        ),
        pic_start=17,
        pic_words=["un micro", "une lettre", "un pont", "des racines"],
        short_p="Racontez le même fait en trois blocs de quatre phrases : oral, archive, radio.",
        audio="Enregistrez les huit premiers modèles, puis vos trois versions d'un même fait.",
    ),
    _l(
        "PE",
        "PE — La même histoire, autrement",
        "Réécrire un fait en trois voix : orale, archive, radio.",
        "Imitez la triple note de Léa Niyonzima.",
        "Triple note de Léa, Pavillon du Saule et figuier",
        """Léa Niyonzima — trois voix, un même soir
Voix orale : Sami me dit — et je l'entends encore — qu'il prit trop tard le coffre ; sa main tremblait, la photo aussi.
Voix archive : « Tache. Marge. Tampon manquant. Bol non mentionné. » J'écris sec, je perds le tremblement.
Voix radio : Lila garda le vent ; on n'entend pas Dieudonné. Si j'avais eu seulement cette bande, j'aurais trop vite conclu.
Raconter autrement, ce n'est pas se contredire. C'est payer trois dettes.
Je tiens la tache. J'imagine l'heure. Je refuse un tampon unique.
À Rive-des-Saules, j'entendrai surtout l'antenne ; je devrai revenir pour le cahier.
Patrick, s'il n'avait entendu que moi, aurait une légende trop nette.
Yvette : que le danger passe dans les trois voix.
Félicie : que le bol, un jour, soit écrit.
Voilà mon essai, ni trop lisse, ni trop triple.
Léa""",
        tf_item=(
            "Léa veut un tampon unique pour unifier les trois voix.",
            False,
            "Je refuse un tampon unique.",
        ),
        qcm_item=(
            "Que risque Patrick, s'il n'entend que Léa ?",
            [
                "Rien",
                "Une légende trop nette",
                "De perdre le pont",
                "De réparer le coffre",
            ],
            1,
            "S'il n'avait entendu que moi, il aurait une légende trop nette.",
        ),
        pairs=[
            ("voix orale", "tremblement, « trop tard »"),
            ("voix archive", "tache, marge, sec"),
            ("voix radio", "vent, pas Dieudonné"),
            ("trois dettes", "pas se contredire"),
        ],
        fill_item=("Si j'avais eu seulement cette bande, j'___ trop vite conclu. (avoir, cond. passé)", "aurais"),
        words=["Je", "refuse", "un", "tampon", "unique", "."],
        anagram=("triple", "Trois voix pour un même soir, sans les fondre trop tôt."),
        error=(
            "Si j'avais eu seulement cette bande, j'aurais trop vite conclu, et je serais à l'antenne demain à l'heure dite.",
            "Si j'avais eu seulement cette bande, j'aurais trop vite conclu, et je serai à l'antenne demain à l'heure dite.",
            "Rendez-vous réel : je serai, pas je serais.",
        ),
        pic_start=18,
        pic_words=["une lettre", "un pont", "des racines", "un écho"],
        short_p="Imitez : trois blocs, un fait, gains et pertes, une phrase « je tiens / j'imagine ».",
        audio="Lisez votre triple note, sans aller trop vite.",
    ),
    _l(
        "EL",
        "EL — Oral, archive, radio : trois outils",
        "Retenir ce que chaque voix garde, perd, et doit aux autres.",
        "Apprenez la fiche.",
        "Fiche d'Aline, trois colonnes",
        """Récit oral : souffle, hésitation, photo montrée, geste. Perd souvent la date.
Archive (Cahier du chemin) : encre, marge, tampon, heure. Perd le souffle et parfois un bol.
Radio Figuier : voix datée, vent, coupe professionnelle. Perd le geste, parfois la table.
Raconter autrement = changer d'outil, pas se contredire.
Chaque voix a une dette envers les deux autres.
Si + PQP : si nous n'avions qu'une voix, nous prendrions une légende pour une preuve.
Publier les trois, dater chacune, refuser le tampon unique.
Le danger (Yvette) doit traverser les trois voix.
L'oubli d'un métier (Félicie, Dieudonné) est déjà un choix de société.
Passé simple possible dans l'archive lue : il prit, nous vîmes, il dit.
Bien que les voix diffèrent, il faut les garder ensemble.
Je ferai trois versions (1 r) ; je pourrai les comparer (2 r).
Léa, loin, entendra surtout la radio : elle devra revenir pour le cahier.
Il faut nommer l'outil avant de raconter.""",
        tf_item=(
            "L'oubli du bol dans l'archive n'est pas un choix, selon la fiche.",
            False,
            "L'oubli d'un métier est déjà un choix de société.",
        ),
        qcm_item=(
            "Que doit-on faire des trois voix ?",
            [
                "N'en garder qu'une",
                "Les publier, les dater, refuser le tampon unique",
                "Les fondre en un slogan",
                "Les cacher à Léa",
            ],
            1,
            "Publier les trois, dater chacune, refuser le tampon unique.",
        ),
        pairs=[
            ("oral", "souffle, pas de date"),
            ("archive", "encre, pas de souffle"),
            ("radio", "voix datée, pas de geste"),
            ("dette", "envers les deux autres"),
        ],
        fill_item=("Il faut nommer l'___ avant de raconter.", "outil"),
        words=["Publier", "les", "trois", "dater", "chacune", "."],
        anagram=("outil", "Moyen de raconter : voix, page ou bande, chacun avec une perte."),
        error=(
            "Bien que les voix diffèrent, il fautons les garder ensemble, et Léa reviendra pour le cahier.",
            "Bien que les voix diffèrent, il faut les garder ensemble, et Léa reviendra pour le cahier.",
            "Toujours il faut, à la 3e personne.",
        ),
        pic_start=19,
        pic_words=["un pont", "des racines", "un écho", "une carte"],
        short_p="Tableau à trois colonnes : garde, perd, dette — oral, archive, radio.",
        audio="Enregistrez la fiche, puis le même fait en trois phrases d'outils différents.",
    ),
]


# ---------------------------------------------------------------------------
# Séquence 5 — Archives du Cahier du chemin (EXTRA)
# ---------------------------------------------------------------------------

S5 = [
    _l(
        "CO",
        "CO — Ouvrir le Cahier du chemin",
        "Comprendre les gestes et les règles d'une archive vivante au Seuil.",
        "Lisez la séance d'ouverture. Qui a le droit d'écrire, de dater, de refuser ?",
        "Séance d'archives, table calée par Dieudonné",
        """Solange Mukamana : On n'ouvre pas le Cahier du chemin comme on ouvre une valise. On date, on signe, on laisse une marge.
Sami : Si nous avions ouvert plus tôt, moins de pages auraient gondolé. C'est un regret utile, pas une honte.
Mado : J'écris à l'encre. Le crayon ment trop vite. La marge est pour le doute, pas pour la décoration.
Aline Uwase : Une archive n'appartient pas à celui qui parle le plus fort. Elle appartient à ceux qui pourront encore lire.
Lila Sow : Je peux déposer une bande. Je ne peux pas coller un slogan sur une page déjà sèche.
Marc Nkurunziza : Il fallut des règles : qui ajoute, qui relit, qui refuse un faux tampon.
Karim Bamba : Notez qui paie l'encre et l'huile. Sinon l'archive ment sur la société.
Rose Iradukunda : Je glisse un échantillon de lin, pas une publicité.
Léa Niyonzima : De Rive-des-Saules, j'enverrai une lettre. Elle devra entrer par la marge, pas par la une.
Patrick Habimana : Si j'avais su la règle de la marge, j'aurais moins écrit au milieu.
Hawa Diallo : Joël date les lanternes ; Félicie, un bol. Les gestes aussi s'archivent.
Dieudonné : La table tient. Sans cela, pas d'archive, seulement une pile.
Yvette : Notez les brûlures. Une archive adulte n'efface pas le danger.
Sami : Ce que le figuier a vu n'entre pas tout. Il entre ce que l'on peut encore vérifier, ou honnêtement imaginer.""",
        tf_item=(
            "Solange dit qu'on ouvre le cahier comme une valise, sans dater.",
            False,
            "On n'ouvre pas le cahier comme une valise. On date, on signe, on laisse une marge.",
        ),
        qcm_item=(
            "À qui appartient l'archive, selon Aline ?",
            [
                "À celui qui parle le plus fort",
                "À ceux qui pourront encore lire",
                "À Radio Figuier seulement",
                "Au Pavillon du Saule",
            ],
            1,
            "Elle appartient à ceux qui pourront encore lire.",
        ),
        pairs=[
            ("dater / signer", "règles d'ouverture"),
            ("marge", "le doute"),
            ("encre", "pas le crayon trop vite"),
            ("faux tampon", "refuser"),
        ],
        fill_item=("La marge est pour le ___, pas pour la décoration.", "doute"),
        words=["On", "date", "on", "signe", "on", "laisse", "une", "marge", "."],
        anagram=("chemin", "Nom du cahier : il mène d'une date à une autre, sans slogan."),
        error=(
            "Si j'avais su la règle de la marge, j'aurais moins écrit au milieu, et je serai plus prudent si c'était à refaire.",
            "Si j'avais su la règle de la marge, j'aurais moins écrit au milieu, et je serais plus prudent si c'était à refaire.",
            "Hypothèse non réelle : je serais, pas le futur je serai.",
        ),
        pic_start=20,
        pic_words=["des racines", "un écho", "une carte", "une horloge"],
        short_p="Notez six règles d'archive entendues, et qui les prononce.",
        audio="Enregistrez : On date, on signe, on laisse une marge. L'archive appartient à ceux qui pourront encore lire.",
    ),
    _l(
        "CE",
        "CE — Feuillets du Cahier du chemin",
        "Lire des extraits d'archives et en comprendre le statut (tenu / hypothesé).",
        "Lisez les feuillets, sans aller trop vite.",
        "Feuillets du Cahier du chemin, encre et marge",
        """Feuillet 1. Sami écrivit : « Je tiens le tampon manquant. J'imagine une date après la pluie. »
Feuillet 2. Mado ajouta en marge : « Tache vérifiée. Bol de Félicie non mentionné dans la page sèche. »
Feuillet 3. Lila déposa : « Bande du vent. Dieudonné absent de l'écoute. Datée, signée. »
Il dit, plus bas, qu'une archive n'efface pas une autre voix : elle la cote.
Nous vîmes ensuite la main de Rose : un lin glissé, sans prix, avec un doute en marge sur le nom.
Karim vint et écrivit : « Huile : qui paie ? » — question, pas slogan.
Aline reprit : appartenir à ceux qui liront, c'est laisser de l'air, pas remplir.
Léa, de Rive-des-Saules, envoya une lettre : elle entra par la marge, comme convenu.
Yvette nota une brûlure ancienne ; Solange refusa un tampon trop neuf, trop sûr.
Dieudonné signa le calage de la table : sans ce geste, les feuillets glisseraient encore.
Joël data une lanterne trop haute : hypothèse utile pour demain, dit-il.
Hawa copia les règles : dater, signer, marger, séparer tenu et imaginé.
Patrick lut trop vite au milieu ; il promit la marge désormais.
Nous relûmes le tout lorsque le soleil baissa : l'archive était devenue une société, pas un tiroir.""",
        tf_item=(
            "Solange accepte un tampon trop neuf et trop sûr.",
            False,
            "Solange refusa un tampon trop neuf, trop sûr.",
        ),
        qcm_item=(
            "Comment la lettre de Léa est-elle entrée dans le cahier ?",
            [
                "Par la une, en slogan",
                "Par la marge, comme convenu",
                "Elle fut refusée",
                "Par Radio Figuier seulement",
            ],
            1,
            "Elle entra par la marge, comme convenu.",
        ),
        pairs=[
            ("feuillet Sami", "tenir / imaginer"),
            ("marge de Mado", "tache / bol oublié"),
            ("bande de Lila", "datée, signée"),
            ("lettre de Léa", "par la marge"),
        ],
        fill_item=("Sami écrivit : je tiens le tampon manquant ; j'___ une date. (imaginer, prés.)", "imagine"),
        words=["Une", "archive", "n'efface", "pas", "une", "autre", "voix", "."],
        anagram=("feuillet", "Page datée, signée, avec une marge pour le doute."),
        error=(
            "Nous vîmes la main de Rose, et il fallutons refuser un tampon trop sûr, trop neuf.",
            "Nous vîmes la main de Rose, et il fallut refuser un tampon trop sûr, trop neuf.",
            "Passé simple : il fallut.",
        ),
        pic_start=21,
        pic_words=["un écho", "une carte", "une horloge", "un groupe"],
        short_p="Pour quatre feuillets : ce qui est tenu, ce qui est imaginé, qui signe.",
        audio="Lisez les feuillets, sans aller trop vite.",
    ),
    _l(
        "PO",
        "PO — Dire les règles de l'archive",
        "Formuler à l'oral les gestes qui rendent une archive honnête.",
        "Répétez, puis dictez une règle d'archive et un exemple.",
        "Modèles de Solange et de Mado",
        """On date, on signe, on laisse une marge.
La marge est pour le doute, pas pour la décoration.
J'écris à l'encre : le crayon ment trop vite.
Je sépare ce que je tiens et ce que j'imagine.
Je refuse un tampon trop neuf, trop sûr.
Une archive appartient à ceux qui pourront encore lire.
Je dépose une bande datée, je ne colle pas un slogan.
Notez qui paie l'encre et l'huile.
Les brûlures s'écrivent, elles ne s'effacent pas.
La lettre de loin entre par la marge, pas par la une.
Si j'avais su la règle, j'aurais moins écrit au milieu.
Solange : une règle, un exemple.
Mado : une phrase tenue, une phrase imaginée.
Dieudonné : d'abord la table, ensuite la page.""",
        tf_item=(
            "On peut coller un slogan sur une page déjà sèche, selon les modèles.",
            False,
            "Je dépose une bande datée, je ne colle pas un slogan.",
        ),
        qcm_item=(
            "Où entre la lettre de loin ?",
            [
                "Par la une",
                "Par la marge",
                "Par Radio Figuier seulement",
                "Elle n'entre jamais",
            ],
            1,
            "La lettre de loin entre par la marge, pas par la une.",
        ),
        pairs=[
            ("dater / signer", "ouverture"),
            ("marge", "doute"),
            ("encre", "pas le crayon"),
            ("tenu / imaginé", "séparer"),
        ],
        fill_item=("Je refuse un tampon trop neuf, trop ___.", "sûr"),
        words=["On", "date", "on", "signe", "on", "laisse", "une", "marge", "."],
        anagram=("tampon", "Marque de date trop sûre que Solange refuse si elle est trop neuve."),
        error=(
            "On date on signe on laisse une marge, et je pourai encore écrire au milieu si je me presse.",
            "On date on signe on laisse une marge, et je pourrai encore écrire au milieu si je me presse.",
            "Futur de pouvoir : je pourrai, deux r.",
        ),
        pic_start=22,
        pic_words=["une carte", "une horloge", "un groupe", "un récit oral"],
        short_p="Écrivez huit règles d'archive, chacune en une phrase orale.",
        audio="Enregistrez les huit premiers modèles, puis deux règles à vous.",
    ),
    _l(
        "PE",
        "PE — Ma page pour le Cahier du chemin",
        "Écrire une page d'archive : tenu, imaginé, daté, signé, marge.",
        "Imitez la page de Mado.",
        "Page de Mado, encre et marge",
        """Mado — Cahier du chemin, Seuil des Sources
Je date : jeudi, après que Dieudonné a calé la table. Je signe. Je laisse une marge.
Je tiens : une tache de pluie, un tampon manquant, la bande du vent déposée par Lila.
J'imagine : une heure juste après l'orage, sans l'imprimer.
Si nous avions ouvert plus tôt, moins de pages auraient gondolé : regret utile.
Rose a glissé un lin, sans prix. Félicie n'apparaît pas encore : oubli à corriger, en marge.
Karim a écrit « qui paie l'huile ? » — question, pas slogan.
Léa entre par la marge, depuis Rive-des-Saules. Patrick promet de ne plus écrire au milieu.
Yvette note une brûlure. Solange refuse un tampon trop sûr.
Sami dit : ce que le figuier a vu n'entre pas tout ; entre ce que l'on peut vérifier.
Aline : cette page appartient à ceux qui pourront encore lire.
Voilà mon feuillet, ni trop plein, ni trop fier.
Mado""",
        tf_item=(
            "Mado imprime l'heure imaginée au tampon.",
            False,
            "J'imagine : une heure […] sans l'imprimer.",
        ),
        qcm_item=(
            "Que dit Sami sur ce qui entre dans le cahier ?",
            [
                "Tout ce que le figuier a vu",
                "Ce que l'on peut vérifier, pas tout",
                "Seulement les slogans",
                "Seulement les photos de Léa",
            ],
            1,
            "N'entre pas tout ; entre ce que l'on peut vérifier.",
        ),
        pairs=[
            ("je tiens", "tache, tampon manquant, bande"),
            ("j'imagine", "une heure, sans imprimer"),
            ("marge", "Léa, oubli du bol"),
            ("refus", "tampon trop sûr"),
        ],
        fill_item=("Si nous avions ouvert plus tôt, moins de pages ___ gondolé. (avoir, cond. passé)", "auraient"),
        words=["Je", "date", "je", "signe", "je", "laisse", "une", "marge", "."],
        anagram=("marge", "Espace du doute, où entre la lettre de loin, pas le slogan."),
        error=(
            "Je date je signe je laisse une marge, et je serais à la table demain à l'heure déjà fixée par Solange.",
            "Je date je signe je laisse une marge, et je serai à la table demain à l'heure déjà fixée par Solange.",
            "Heure fixée : je serai, pas je serais.",
        ),
        pic_start=23,
        pic_words=["une horloge", "un groupe", "un récit oral", "une plume"],
        short_p="Imitez : une page datée, signée, tenue / imaginée, une marge, un refus.",
        audio="Lisez votre page d'archive, sans aller trop vite.",
    ),
    _l(
        "EL",
        "EL — Tenir une archive honnête",
        "Retenir les gestes, la langue et les interdits du Cahier du chemin.",
        "Apprenez la fiche.",
        "Fiche de Solange, règles ocre",
        """Ouvrir : dater, signer, laisser une marge.
Écrire à l'encre ; le crayon ment trop vite.
Séparer je tiens / j'imagine. Pas de faux tampon.
La marge : doute, lettre de loin, oubli à corriger (le bol).
Appartenir à ceux qui pourront encore lire : laisser de l'air.
Déposer une bande datée ≠ coller un slogan.
Noter qui paie l'encre et l'huile : l'archive dit aussi la société.
Noter les brûlures : une archive adulte n'efface pas le danger.
Si + PQP : si nous avions ouvert plus tôt, moins de pages auraient gondolé.
Passé simple lu : il dit, elle écrivit, nous vîmes, il fallut, Karim vint.
Bien que la page soit sèche, on peut encore marger.
Je ferai une copie (1 r) ; je pourrai relire (2 r) ; il faut une table calée.
Ce que le figuier a vu n'entre pas tout : entre ce que l'on vérifie.
Radio Figuier dépose, elle ne commande pas la une.""",
        tf_item=(
            "On peut encore ajouter une marge après que la page est sèche.",
            True,
            "Bien que la page soit sèche, on peut encore marger.",
        ),
        qcm_item=(
            "Quel couple doit rester séparé dans chaque feuillet ?",
            [
                "soleil / lanterne seulement",
                "je tiens / j'imagine",
                "Rose / Félicie seulement",
                "pont / bol seulement",
            ],
            1,
            "Séparer je tiens / j'imagine.",
        ),
        pairs=[
            ("dater / signer", "ouverture"),
            ("je tiens", "vérifiable"),
            ("j'imagine", "hypothèse"),
            ("marge", "doute et lettre"),
        ],
        fill_item=("Bien que la page ___ sèche, on peut encore marger. (être, subj.)", "soit"),
        words=["Pas", "de", "faux", "tampon", "."],
        anagram=("encre", "Matière de la page honnête, plus lente que le crayon."),
        error=(
            "Bien que la page soit sèche on peut encore marger, et il fautons une table calée.",
            "Bien que la page soit sèche on peut encore marger, et il faut une table calée.",
            "Toujours il faut, à la 3e personne.",
        ),
        pic_start=24,
        pic_words=["un groupe", "un récit oral", "une plume", "un soleil"],
        short_p="Rédigez un règlement d'archive en dix phrases, avec deux exemples de langue.",
        audio="Enregistrez la fiche, puis une mini-page datée de cinq lignes.",
    ),
]


# ---------------------------------------------------------------------------
# Séquence 6 — Table ronde « ce que le figuier a vu » (EXTRA débat / synthèse)
# ---------------------------------------------------------------------------

S6 = [
    _l(
        "CO",
        "CO — Ce que le figuier a vu",
        "Suivre une table ronde qui synthétise hypothèses, métiers, lieux et voix.",
        "Lisez la table ronde. Qui synthétise, qui refuse la légende unique ?",
        "Table ronde sous le figuier, micro de Lila",
        """Aline Uwase : D'une part nous tenons des gestes ; d'autre part nous imaginons des heures. Le figuier a vu les deux.
Sami : Ce qu'il a vu, ce n'est pas un slogan. C'est un sentier, une pluie, une table calée, un bol oublié.
Mado : En somme, l'archive n'a pas tout pris. Elle a pris ce que nous pouvions encore vérifier.
Lila Sow : Autrement dit, trois voix restent nécessaires : oral, cahier, bande.
Marc Nkurunziza : Certes une synthèse console ; toutefois elle ne doit pas devenir un tampon unique.
Dieudonné : Pour ma part, je témoigne du bois. Si je n'avais pas calé, vous n'auriez plus de pages.
Rose Iradukunda : Je concède que le lin n'est pas le centre. Néanmoins un métier oublié fausse la mémoire.
Félicie : Mon bol n'apparaissait nulle part. Désormais il est une dette, pas une décoration.
Léa Niyonzima : De l'autre rive, j'entends surtout la radio. Je dois encore le cahier.
Patrick Habimana : Si nous n'avions écouté qu'une voix, nous aurions une légende trop nette.
Karim Bamba : Reste que quelqu'un paie l'huile, l'encre, le micro. La mémoire a un prix.
Yvette : Le danger vu par l'arbre — flammes trop hautes — doit rester dans la synthèse.
Solange Mukamana : Je refuse le faux tampon « tout a été dit ».
Joël Mugisha : Quoi que l'on vote, j'accrocherai moins haut : le vent, le figuier l'a vu.""",
        tf_item=(
            "Solange accepte le tampon « tout a été dit » pour clore la table ronde.",
            False,
            "Je refuse le faux tampon « tout a été dit ».",
        ),
        qcm_item=(
            "Selon Lila, combien de voix restent nécessaires ?",
            [
                "Une seule, la radio",
                "Trois : oral, cahier, bande",
                "Aucune",
                "Seulement l'archive",
            ],
            1,
            "Trois voix restent nécessaires : oral, cahier, bande.",
        ),
        pairs=[
            ("d'une part / d'autre part", "tenir / imaginer"),
            ("en somme", "l'archive n'a pas tout pris"),
            ("certes / toutefois", "synthèse ≠ tampon"),
            ("reste que", "la mémoire a un prix"),
        ],
        fill_item=("Si nous n'avions écouté qu'une voix, nous ___ une légende trop nette. (avoir, cond. passé)", "aurions"),
        words=["Je", "refuse", "le", "faux", "tampon", "."],
        anagram=("ronde", "Table où les voix tournent, sans qu'une seule referme le cercle."),
        error=(
            "Si nous n'avions écouté qu'une voix, nous aurions une légende trop nette, et je ferrai une synthèse trop lisse.",
            "Si nous n'avions écouté qu'une voix, nous aurions une légende trop nette, et je ferai une synthèse trop lisse.",
            "Futur de faire : je ferai, un seul r.",
        ),
        pic_start=25,
        pic_words=["un récit oral", "une plume", "un soleil", "un nuage"],
        short_p="Relevez six prises de parole et l'argument que chacune apporte à la synthèse.",
        audio="Enregistrez : D'une part nous tenons. D'autre part nous imaginons. En somme, l'archive n'a pas tout pris.",
    ),
    _l(
        "CE",
        "CE — Compte rendu : ce que le figuier a vu",
        "Lire le compte rendu argumenté de la table ronde.",
        "Lisez le compte rendu de Marc, sans aller trop vite.",
        "Compte rendu de Marc Nkurunziza, feuille pour le cahier",
        """La table ronde ne chercha pas une légende : elle chercha une mémoire tenable.
Aline ouvrit : d'une part les gestes tenus, d'autre part les heures imaginées.
Sami dit alors que le figuier avait vu un sentier, une pluie, une table, un bol oublié — pas un slogan.
Mado conclut, en somme, que l'archive n'avait pas tout pris, et que c'était juste.
Lila exigea trois voix ; Marc concéda qu'une synthèse console, toutefois elle ne tamponne pas.
Dieudonné prit la parole : si je n'avais pas calé, vous n'auriez plus de pages. Nous vîmes l'outil, enfin.
Rose et Félicie rappelèrent les métiers oubliés ; Karim, le prix de l'huile et de l'encre.
Léa, de Rive-des-Saules, écrivit qu'elle entendait surtout la radio et qu'elle devait encore le cahier.
Patrick ajouta l'hypothèse : une seule voix aurait fait une légende trop nette.
Yvette imposa le danger ; Joël promit des lanternes moins hautes ; Solange refusa « tout a été dit ».
Hawa nota les absents trop vite nommés : une synthèse n'efface pas une marge.
Il fallut voter sur des gestes — caler, dater, relayer, payer — non sur un mythe.
Nous relûmes le compte rendu lorsque le soleil baissa : le figuier n'avait pas parlé, il avait porté.
Radio Figuier diffuserait ce texte dès que Lila aurait coupé les insultes, pas les doutes.""",
        tf_item=(
            "Le compte rendu dit que l'on vota sur un mythe, non sur des gestes.",
            False,
            "Il fallut voter sur des gestes […], non sur un mythe.",
        ),
        qcm_item=(
            "Que promit Joël, à la fin de la table ronde ?",
            [
                "De fermer le figuier",
                "Des lanternes moins hautes",
                "De vendre l'huile",
                "De taire Yvette",
            ],
            1,
            "Joël promit des lanternes moins hautes.",
        ),
        pairs=[
            ("Sami", "sentier, pluie, table, bol"),
            ("Dieudonné", "caler ou plus de pages"),
            ("Léa", "radio d'abord, cahier encore"),
            ("Solange", "refus de « tout a été dit »"),
        ],
        fill_item=("Dès que Lila ___ coupé les insultes, Radio Figuier diffuserait. (avoir, FA / cond. contexte)", "aurait"),
        words=["Il", "fallut", "voter", "sur", "des", "gestes", "."],
        anagram=("memoire", "Ce que l'on tient et ce que l'on imagine, sans mythe unique. (sans accent)"),
        error=(
            "Il fallut voter sur des gestes, et bien que le figuier n'avait pas parlé il avait porté.",
            "Il fallut voter sur des gestes, et bien que le figuier n'ait pas parlé il avait porté.",
            "Bien que + subjonctif : n'ait pas parlé, pas l'indicatif n'avait.",
        ),
        pic_start=26,
        pic_words=["une plume", "un soleil", "un nuage", "une feuille"],
        short_p="Résumez la table ronde en huit lignes : quatre voix, deux refus, un vote.",
        audio="Lisez le compte rendu, sans aller trop vite.",
    ),
    _l(
        "PO",
        "PO — Dire la synthèse de la table ronde",
        "Tenir à l'oral une synthèse : connecteurs, hypothèses, refus du mythe.",
        "Répétez, puis tenez deux minutes : « ce que le figuier a vu ».",
        "Modèles d'Aline, Sami et Marc",
        """D'une part nous tenons des gestes ; d'autre part nous imaginons des heures.
En somme, l'archive n'a pas tout pris, et c'est juste.
Autrement dit, trois voix restent nécessaires.
Certes une synthèse console ; toutefois elle ne tamponne pas.
Reste que la mémoire a un prix : huile, encre, micro.
Si nous n'avions écouté qu'une voix, nous aurions une légende trop nette.
Je refuse le faux tampon « tout a été dit ».
Quoi que l'on vote, Joël accrochera moins haut.
Pour ma part, je témoigne du bois, du bol, du lin.
Le figuier n'a pas parlé : il a porté.
Aline : une phrase pour, une phrase contre, une phrase de synthèse.
Sami : nommez un geste vu, pas un devoir moral trop large.
Lila : une phrase, une pause.
Solange : gardez une marge, même à l'oral.""",
        tf_item=(
            "« En somme » sert ici à rouvrir trois dossiers oubliés.",
            False,
            "En somme clôt : l'archive n'a pas tout pris, et c'est juste.",
        ),
        qcm_item=(
            "Que dit-on du figuier, dans les modèles ?",
            [
                "Qu'il a parlé clairement",
                "Qu'il n'a pas parlé : il a porté",
                "Qu'il a voté",
                "Qu'il faut le couper",
            ],
            1,
            "Le figuier n'a pas parlé : il a porté.",
        ),
        pairs=[
            ("d'une part / d'autre part", "tenir / imaginer"),
            ("en somme", "clôture juste"),
            ("si + PQP", "légende trop nette"),
            ("je refuse", "tampon unique"),
        ],
        fill_item=("Le figuier n'a pas parlé : il a ___.", "porté"),
        words=["Je", "refuse", "le", "faux", "tampon", "."],
        anagram=("temoin", "Celui qui dit un geste vu, sans inventer un mythe. (sans accent)"),
        error=(
            "Quoi que l'on vote, Joël accrochera moins haut, et je serais sous l'arbre demain à l'heure dite de la table.",
            "Quoi que l'on vote, Joël accrochera moins haut, et je serai sous l'arbre demain à l'heure dite de la table.",
            "Rendez-vous réel : je serai, pas je serais.",
        ),
        pic_start=27,
        pic_words=["un soleil", "un nuage", "une feuille", "une hypothèse"],
        short_p="Écrivez une synthèse orale de douze phrases, avec six connecteurs.",
        audio="Enregistrez les huit premiers modèles, puis votre synthèse de deux minutes.",
    ),
    _l(
        "PE",
        "PE — Ma motion : ce que le figuier a vu",
        "Écrire une motion de synthèse pour clore la table ronde.",
        "Imitez la motion d'Aline Uwase.",
        "Motion d'Aline, banc du figuier",
        """Aline Uwase — motion pour le Seuil des Sources
D'une part nous tenons : un sentier au-delà, une tache, une table calée, un ourlet payé, un bol trop longtemps oublié.
D'autre part nous imaginons des heures, sans faux tampon.
En somme, ce que le figuier a vu n'est pas un mythe : c'est une suite de gestes et de dettes.
Certes une synthèse console ; toutefois elle n'efface ni la marge de Mado, ni la bande de Lila, ni l'oral de Sami.
Si nous n'avions écouté qu'une voix, nous aurions trahi l'arbre en le faisant parler trop net.
Je propose : dater, caler, relayer, payer, garder trois voix, refuser « tout a été dit ».
Quoi que Léa entende d'abord de Rive-des-Saules, le cahier lui reste dû.
Yvette : le danger reste. Joël : moins haut. Karim : qui paie. Dieudonné : la table.
Pour ma part, j'enseignerai encore à séparer tenu et imaginé.
Je serai sous l'arbre jeudi, lorsque nous aurons signé cette motion.
Aline""",
        tf_item=(
            "Aline veut faire parler le figuier d'une voix trop nette.",
            False,
            "Une seule voix aurait trahi l'arbre en le faisant parler trop net.",
        ),
        qcm_item=(
            "Que propose Aline, concrètement ?",
            [
                "Un slogan unique",
                "Dater, caler, relayer, payer, garder trois voix, refuser la formule trop sûre",
                "Fermer Radio Figuier",
                "Vendre le cahier",
            ],
            1,
            "Dater, caler, relayer, payer, garder trois voix, refuser « tout a été dit ».",
        ),
        pairs=[
            ("d'une part", "gestes tenus"),
            ("d'autre part", "heures imaginées"),
            ("en somme", "suite de gestes et de dettes"),
            ("je propose", "six verbes de motion"),
        ],
        fill_item=("Lorsque nous ___ signé cette motion, je serai sous l'arbre. (avoir, FA)", "aurons"),
        words=["Ce", "n'est", "pas", "un", "mythe", "."],
        anagram=("motion", "Texte voté qui propose des gestes, pas un mythe."),
        error=(
            "Lorsque nous aurons signé cette motion, je serais sous l'arbre jeudi, et Lila ouvrira le micro.",
            "Lorsque nous aurons signé cette motion, je serai sous l'arbre jeudi, et Lila ouvrira le micro.",
            "Jeudi fixé : je serai, pas je serais.",
        ),
        pic_start=28,
        pic_words=["un nuage", "une feuille", "une hypothèse", "un plus-que-parfait"],
        short_p="Imitez : une motion de douze lignes, connecteurs, une hypothèse, six verbes de geste.",
        audio="Lisez votre motion, sans aller trop vite.",
    ),
    _l(
        "EL",
        "EL — Synthèse de mémoire sous le figuier",
        "Retenir la langue de la table ronde : hypothèse, voix, motion.",
        "Apprenez la fiche.",
        "Fiche d'Aline et de Marc, clôture ocre",
        """Table ronde : d'une part / d'autre part ; en somme ; autrement dit ; certes / toutefois ; reste que.
Hypothèse : si + PQP + conditionnel passé (si nous n'avions écouté qu'une voix, nous aurions une légende).
Tenir / imaginer : séparés, toujours, même dans une motion.
Trois voix : oral, archive, radio — publier, dater, refuser le tampon unique.
Métiers dans la mémoire : Dieudonné, Aline, Lila, Rose, Félicie, Joël — les nommer.
Lieux : au-delà, en contrebas, à travers — situer avant de légender.
Passé simple lu dans les comptes rendus : il dit, elle prit, nous vîmes, il fallut.
Bien que le figuier n'ait pas parlé, il a porté (subjonctif après bien que).
Je serai jeudi (réel) / je serais (hypothèse) / j'aurais (cond. passé, avoir).
Je ferai (1 r) ; je pourrai (2 r) ; il faut (3e pers.).
Motion : proposer des gestes (dater, caler, relayer, payer), pas un mythe.
Ce que le figuier a vu : une suite, pas un slogan.
Radio Figuier diffuse après la coupe des insultes, pas des doutes.
Il faut une marge, même à la clôture.""",
        tf_item=(
            "La motion doit proposer un mythe plutôt que des gestes.",
            False,
            "Proposer des gestes, pas un mythe.",
        ),
        qcm_item=(
            "Quelle construction suit « bien que » dans la fiche ?",
            [
                "l'indicatif seulement",
                "le subjonctif (n'ait pas parlé)",
                "l'impératif",
                "le futur antérieur seulement",
            ],
            1,
            "Bien que le figuier n'ait pas parlé.",
        ),
        pairs=[
            ("si + PQP", "conditionnel passé"),
            ("tenir / imaginer", "séparer"),
            ("trois voix", "oral archive radio"),
            ("motion", "gestes, pas mythe"),
        ],
        fill_item=("Bien que le figuier n'___ pas parlé, il a porté. (avoir, subj.)", "ait"),
        words=["Il", "faut", "une", "marge", "même", "à", "la", "clôture", "."],
        anagram=("cloture", "Fin de la table ronde, avec une marge encore ouverte. (sans accent)"),
        error=(
            "Bien que le figuier n'ait pas parlé il a porté, et il fautons une marge même à la fin.",
            "Bien que le figuier n'ait pas parlé il a porté, et il faut une marge même à la fin.",
            "Toujours il faut, à la 3e personne.",
        ),
        pic_start=29,
        pic_words=["une feuille", "une hypothèse", "un plus-que-parfait", "un conditionnel"],
        short_p="Tableau final : hypothèse, trois voix, prépositions, connecteurs de synthèse — un exemple chacun.",
        audio="Enregistrez la fiche, puis une motion de cinq phrases.",
    ),
]


SEQUENCES = [
    {"title": "Hypothèses sur le passé", "lessons": S1},
    {"title": "Un métier, une société", "lessons": S2},
    {"title": "Lieux d'enfance", "lessons": S3},
    {"title": "Raconter l'histoire autrement", "lessons": S4},
    {"title": "Archives du Cahier du chemin", "lessons": S5},
    {"title": "Table ronde « ce que le figuier a vu »", "lessons": S6},
]
