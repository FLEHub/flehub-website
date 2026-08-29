"""A2 Module 6 — Petits gestes, grand quotidien (univers Seuil des Sources)."""

from factory import L

IMG = "mfk-a2-m6"
IMG_DIR = IMG

MODULE = {
    "title": "A2 — Petits gestes, grand quotidien",
    "description": (
        "Grande étape A2-6 : suivre des instructions du jour, rédiger une recette, "
        "lire un mode d'emploi, raconter une réussite, prendre soin de soi "
        "et enchaîner des actions — dans la cuisine de Félicie Ndayishimiye "
        "et sur le tableau de la cour, au Seuil des Sources (Rukiri-Nord)."
    ),
}


def _l(comp, title, obj, cons, st, sp, **kw):
    return L(IMG, comp, title, obj, cons, st, sp, **kw)


# ---------------------------------------------------------------------------
# Séquence 1 — Instructions du jour (conjugaison -cer / -ger / -yer / -ayer)
# ---------------------------------------------------------------------------

S1 = [
    _l(
        "CO",
        "CO — Tableau de Félicie",
        "Repérer nous commençons, nous mangeons, nous essuyons, j'essaie / je paie.",
        "Lisez le dialogue (à écouter avec l'enseignant). Quels verbes change-t-on ?",
        "Cuisine ocre, tablier de Félicie",
        """Aline : Lisez le tableau. Nous commençons à sept heures.
Félicie : Vous rangez les bols. Ensuite, nous rangeons la table.
Léa : J'essuie le banc. Nous essuyons aussi les tasses.
Patrick : J'essaie la recette verte. Nous essayons ensemble.
Hawa : Je paie les herbes au Marché des Lampions. Nous payons ce soir.
Joël : Nous avançons le banc trop près de l'eau.
Rose : On mange tôt. Nous mangeons sous le figuier.
Marc : Je place les paniers. Nous plaçons tout près de la Table des Sources.
Dieudonné : J'emploie le tablier ocre. Nous employons les nôtres aussi.""",
        tf_item=(
            "Félicie dit : nous rangeons la table.",
            True,
            "Félicie : « nous rangeons la table. » — -ger : e devant ons.",
        ),
        qcm_item=(
            "Quelle forme est correcte pour commencer à la 1re personne du pluriel ?",
            ["nous commencons", "nous commençons", "nous commençonsse", "nous commenceons"],
            1,
            "Devant o, c devient ç : nous commençons.",
        ),
        pairs=[
            ("nous commençons", "-cer → ç"),
            ("nous rangeons", "-ger → geo"),
            ("nous essuyons", "-yer → yons"),
            ("j'essaie / je paie", "-ayer : ai ou ay"),
        ],
        fill_item=("Nous ___ à sept heures. (commencer)", "commençons"),
        words=["Nous", "mangeons", "sous", "le", "figuier", "."],
        anagram=("essuyons", "Nous… les tasses : verbe essuyer à nous."),
        error=(
            "Nous commencons à sept heures.",
            "Nous commençons à sept heures.",
            "Devant o, on écrit ç : commençons.",
        ),
        pic_start=0,
        pic_words=["commencer", "manger", "essuyer", "un tableau"],
        short_p="Notez quatre formes : un -cer, un -ger, un -yer, un -ayer.",
        audio="Enregistrez : Nous commençons. Nous mangeons. Nous essuyons. J'essaie. Je paie.",
    ),
    _l(
        "CE",
        "CE — Mot du matin",
        "Lire des consignes du jour avec les verbes en -cer, -ger, -yer, -ayer.",
        "Lisez le mot épinglé au figuier, sans aller trop vite.",
        "Tableau de la cour, craie ocre",
        """Mot du matin — Félicie Ndayishimiye
Nous commençons par l'eau froide. Nous plaçons les bols à gauche.
Nous mangeons après le marché, pas avant.
Nous rangeons les paniers. Nous partageons le pain de Mado.
J'essuie le banc. Vous essuyez les tasses de Rose.
J'essaie le sel de Noura. Vous essayez la recette de Joël.
Je paie Ibrahim pour les figues. Nous payons ensemble le soir.
Nous balayons la Salle des Herbes. Je balaie d'abord le seuil.
Merci. Félicie — cuisine du Seuil.""",
        tf_item=(
            "On mange avant le marché.",
            False,
            "« Nous mangeons après le marché, pas avant. »",
        ),
        qcm_item=(
            "Qui paie Ibrahim pour les figues ?",
            ["Patrick", "Félicie (je paie)", "Solange", "Karim"],
            1,
            "« Je paie Ibrahim pour les figues. »",
        ),
        pairs=[
            ("nous plaçons", "les bols"),
            ("nous partageons", "le pain"),
            ("vous essuyez", "les tasses"),
            ("nous balayons", "la salle"),
        ],
        fill_item=("Nous ___ les paniers. (ranger)", "rangeons"),
        words=["Nous", "plaçons", "les", "bols", "à", "gauche", "."],
        anagram=("partageons", "Nous… le pain : verbe partager à nous."),
        error=(
            "Nous mangons après le marché, pas avant.",
            "Nous mangeons après le marché, pas avant.",
            "Manger : nous mangeons (e devant ons).",
        ),
        pic_start=4,
        pic_words=["une recette", "un bol", "une cuillère", "un cahier"],
        short_p="Recopiez le mot et soulignez commençons, rangeons, essuyez, payons.",
        audio="Lisez le mot de Félicie, sans aller trop vite.",
    ),
    _l(
        "PO",
        "PO — Dire nous commençons",
        "Prononcer les formes nous et je des verbes en -cer, -ger, -yer, -ayer.",
        "Répétez les modèles, puis donnez deux consignes de cuisine.",
        "Modèles d'Aline",
        """Nous commençons maintenant.
Nous avançons le banc.
Nous mangeons sous le figuier.
Nous rangeons les bols.
J'essuie. Nous essuyons.
J'essaie. Nous essayons.
Je paie. Nous payons.
Je balaie. Nous balayons.""",
        tf_item=(
            "On écrit nous mangeons avec un e devant ons.",
            True,
            "Pour garder le son [ʒ] : mangeons.",
        ),
        qcm_item=(
            "Quelle paire est correcte ?",
            [
                "j'essaie / nous essaiions",
                "j'essaye / nous essayons",
                "j'essai / nous essuyons",
                "j'essuye / nous essaions",
            ],
            1,
            "Essayer : j'essaie ou j'essaye ; nous essayons.",
        ),
        pairs=[
            ("placer → nous", "plaçons"),
            ("changer → nous", "changeons"),
            ("nettoyer → nous", "nettoyons"),
            ("payer → je", "paie ou paye"),
        ],
        fill_item=("Nous ___ le banc. (avancer)", "avançons"),
        words=["J'essuie", "le", "banc", "."],
        anagram=("balayons", "Nous… la salle : verbe balayer à nous."),
        error=(
            "Nous avanceons le banc.",
            "Nous avançons le banc.",
            "Avancer : ç devant o.",
        ),
        pic_start=8,
        pic_words=["un mode d'emploi", "une hypothèse", "quelqu'un", "une boîte"],
        short_p="Conjuguez commencer, manger, essuyer, payer au nous et au je.",
        audio="Enregistrez les huit modèles, puis deux consignes à vous.",
    ),
    _l(
        "PE",
        "PE — Mes consignes du jour",
        "Écrire cinq consignes avec -cer, -ger, -yer, -ayer.",
        "Imitez la liste de Félicie.",
        "Liste de Félicie Ndayishimiye",
        """Félicie Ndayishimiye
Nous commençons par laver les mains.
Nous plaçons les herbes à droite.
Nous mangeons après avoir rangé.
J'essuie la Table des Sources. Vous essuyez les tasses.
J'essaie le sel. Nous payons Mado ce soir.
Félicie
Cuisine du Seuil — Rukiri-Nord""",
        tf_item=(
            "Félicie écrit nous plaçons les herbes à gauche.",
            False,
            "« Nous plaçons les herbes à droite. »",
        ),
        qcm_item=(
            "Quelle phrase utilise un verbe en -ger ?",
            [
                "Nous commençons par laver",
                "Nous mangeons après avoir rangé",
                "J'essuie la Table",
                "Nous payons Mado",
            ],
            1,
            "Manger → nous mangeons.",
        ),
        pairs=[
            ("commençons", "laver les mains"),
            ("plaçons", "herbes à droite"),
            ("mangeons", "après avoir rangé"),
            ("payons", "Mado"),
        ],
        fill_item=("J'___ le sel. (essayer, forme en ai)", "essaie"),
        words=["Nous", "commençons", "par", "laver", "les", "mains", "."],
        anagram=("plaçons", "Nous… les herbes : verbe placer à nous (avec ç)."),
        error=(
            "Nous placeons les herbes à droite.",
            "Nous plaçons les herbes à droite.",
            "Placer : ç devant o.",
        ),
        pic_start=12,
        pic_words=["un accord", "une assiette", "une tâche", "un sourire"],
        short_p="Imitez : cinq lignes, quatre familles de verbes.",
        audio="Lisez votre liste, une phrase, une pause, sans aller trop vite.",
    ),
    _l(
        "EL",
        "EL — -cer, -ger, -yer, -ayer",
        "Retenir les changements d'orthographe à nous et à je.",
        "Apprenez la fiche.",
        "Fiche du carnet ocre",
        """-cer : c → ç devant a / o. nous commençons, nous avançons, nous plaçons
-ger : on garde e devant a / o. nous mangeons, nous rangeons, nous partageons
-yer : y → i devant e muet. j'essuie, tu essuies ; nous essuyons (y reste)
essayer : j'essaie ou j'essaye ; nous essayons
payer / balayer : je paie ou je paye ; je balaie ou je balaye ; nous payons
employer / nettoyer : j'emploie, nous employons ; je nettoie, nous nettoyons
On n'écrit pas : nous commencons, nous mangeons sans e, nous essuions.
Au Seuil, Félicie écrit ces formes au tableau de la cour chaque matin.""",
        tf_item=(
            "On peut écrire j'essaie et j'essaye.",
            True,
            "Les deux formes sont acceptées.",
        ),
        qcm_item=(
            "Quelle forme est fausse ?",
            ["nous commençons", "nous mangeons", "nous essuyons", "nous commencons"],
            3,
            "Il manque la cédille : commençons.",
        ),
        pairs=[
            ("commencer", "nous commençons"),
            ("manger", "nous mangeons"),
            ("essuyer", "j'essuie / nous essuyons"),
            ("payer", "je paie / nous payons"),
        ],
        fill_item=("Nous ___ les tasses. (essuyer)", "essuyons"),
        words=["Je", "paie", "les", "herbes", "."],
        anagram=("cedille", "Le petit signe sous le c de commençons (sans accent)."),
        error=(
            "Nous essuions les tasses.",
            "Nous essuyons les tasses.",
            "À nous, y reste : essuyons.",
        ),
        pic_start=16,
        pic_words=["un pronom", "un miroir", "une serviette", "une brosse"],
        short_p="Faites un tableau : six verbes, je et nous.",
        audio="Enregistrez la fiche, puis quatre formes à vous.",
    ),
]


# ---------------------------------------------------------------------------
# Séquence 2 — Une recette à rédiger (verbes prépositionnels)
# ---------------------------------------------------------------------------

S2 = [
    _l(
        "CO",
        "CO — Autour du bol",
        "Repérer essayer de, éviter de, réussir à, continuer à, commencer à, s'arrêter de.",
        "Lisez le dialogue. Quel verbe va avec de ? Quel verbe va avec à ?",
        "Table des Sources, recette de Félicie",
        """Félicie : Essayez de couper les herbes très fines.
Léa : J'évite de trop saler. Hawa a trop salé hier.
Patrick : Tu réussis à mélanger sans grumeaux ?
Aline : Continuez à tourner. Ne vous arrêtez pas de regarder le feu.
Marc : On commence à sentir le citron de Lila.
Joël : Je refuse de goûter trop tôt. J'attends.
Rose : J'accepte de noter les doses dans le Cahier du chemin.
Hawa : J'arrive à finir le potage. Je m'arrête de parler.
Yvette : Pensez à couvrir le bol. N'oubliez pas de le poser à gauche.""",
        tf_item=(
            "Réussir se construit avec à.",
            True,
            "Patrick : « Tu réussis à mélanger… »",
        ),
        qcm_item=(
            "Quelle construction est correcte ?",
            [
                "essayer à couper",
                "essayer de couper",
                "réussir de mélanger",
                "éviter à trop saler",
            ],
            1,
            "Essayer de + infinitif.",
        ),
        pairs=[
            ("essayer de", "couper"),
            ("éviter de", "trop saler"),
            ("réussir à", "mélanger"),
            ("s'arrêter de", "parler"),
        ],
        fill_item=("Continuez ___ tourner.", "à"),
        words=["Essayez", "de", "couper", "les", "herbes", "."],
        anagram=("eviter", "Le verbe… de trop saler (sans accent)."),
        error=(
            "J'essaie à couper les herbes.",
            "J'essaie de couper les herbes.",
            "Essayer de + infinitif.",
        ),
        pic_start=4,
        pic_words=["une recette", "un bol", "une cuillère", "un cahier"],
        short_p="Classez six verbes : + de ou + à.",
        audio="Enregistrez : J'essaie de couper. J'évite de saler. Je réussis à mélanger. Je continue à tourner.",
    ),
    _l(
        "CE",
        "CE — Recette du potage ocre",
        "Lire une recette qui enchaîne les verbes prépositionnels.",
        "Lisez la recette, sans aller trop vite.",
        "Feuille de Félicie, Salle des Herbes",
        """Potage ocre du Seuil — 4 bols
1. Commencez à laver les feuilles du Marché des Lampions.
2. Essayez de les ciseler sans les écraser.
3. Évitez de trop remplir le pot. Réussissez à laisser un doigt d'eau.
4. Continuez à tourner. Arrêtez-vous de tourner quand ça sent le citron.
5. Pensez à goûter. N'oubliez pas de poser le sel à droite.
6. Refusez de servir trop chaud. Acceptez de patienter deux minutes.
Félicie Ndayishimiye — cuisine du Seuil""",
        tf_item=(
            "On doit remplir le pot jusqu'au bord.",
            False,
            "« Évitez de trop remplir le pot. »",
        ),
        qcm_item=(
            "Quand s'arrête-t-on de tourner ?",
            [
                "Quand l'eau bout seulement",
                "Quand ça sent le citron",
                "Avant de laver",
                "Chez Ibrahim",
            ],
            1,
            "Point 4 de la recette.",
        ),
        pairs=[
            ("commencer à", "laver"),
            ("essayer de", "ciseler"),
            ("réussir à", "laisser un doigt"),
            ("penser à", "goûter"),
        ],
        fill_item=("Arrêtez-vous ___ tourner quand ça sent le citron.", "de"),
        words=["Continuez", "à", "tourner", "."],
        anagram=("ciseler", "Couper très fin, sans écraser les feuilles."),
        error=(
            "Réussissez de laisser un doigt d'eau.",
            "Réussissez à laisser un doigt d'eau.",
            "Réussir à + infinitif.",
        ),
        pic_start=1,
        pic_words=["manger", "essuyer", "un tableau", "une recette"],
        short_p="Recopiez la recette et encadrez de / à après chaque verbe.",
        audio="Lisez les six points de la recette, sans aller trop vite.",
    ),
    _l(
        "PO",
        "PO — Dire de et à",
        "Enchaîner à voix haute essayer de, éviter de, réussir à, continuer à.",
        "Répétez, puis parlez d'un geste de cuisine à vous.",
        "Modèles de Patrick",
        """J'essaie de couper droit.
J'évite de brûler le fond.
Je réussis à mélanger.
Je continue à tourner.
Je commence à sentir le citron.
Je m'arrête de parler.
Je pense à couvrir.
J'oublie de goûter ? Non.""",
        tf_item=(
            "S'arrêter se construit avec de.",
            True,
            "S'arrêter de + infinitif.",
        ),
        qcm_item=(
            "Quelle phrase est correcte ?",
            [
                "Je continue de tourner le feu trop",
                "Je continue à tourner",
                "Je réussis de mélanger",
                "J'évite à brûler",
            ],
            1,
            "Continuer à + infinitif.",
        ),
        pairs=[
            ("essayer / éviter / s'arrêter", "+ de"),
            ("réussir / continuer / commencer", "+ à"),
            ("penser", "+ à"),
            ("oublier / refuser / accepter", "+ de"),
        ],
        fill_item=("Je réussis ___ mélanger.", "à"),
        words=["Je", "m'arrête", "de", "parler", "."],
        anagram=("reussir", "Le verbe… à mélanger (sans accent)."),
        error=(
            "Je continue de tourner sans pause ici.",
            "Je continue à tourner.",
            "Continuer à + infinitif (sens « poursuivre »).",
        ),
        pic_start=20,
        pic_words=["avant de", "après", "une flèche", "une horloge"],
        short_p="Écrivez six phrases : trois + de, trois + à.",
        audio="Enregistrez les huit modèles, puis deux phrases à vous.",
    ),
    _l(
        "PE",
        "PE — Ma recette courte",
        "Écrire une recette de cinq lignes avec des verbes prépositionnels.",
        "Imitez la recette de Léa.",
        "Recette de Léa Niyonzima",
        """Léa Niyonzima
J'essaie de couper les figues de Sami.
J'évite de trop sucrer. Je réussis à garder le goût.
Je continue à tourner. Je commence à voir une crème.
Je m'arrête de parler pour goûter.
Je pense à servir sous le figuier.
Léa
Table des Sources""",
        tf_item=(
            "Léa sert à la Maison des Vents.",
            False,
            "« Je pense à servir sous le figuier. »",
        ),
        qcm_item=(
            "Que réussit Léa ?",
            ["À trop sucrer", "À garder le goût", "À brûler", "À cacher le bol"],
            1,
            "« Je réussis à garder le goût. »",
        ),
        pairs=[
            ("essaie de", "couper"),
            ("évite de", "trop sucrer"),
            ("réussit à", "garder le goût"),
            ("pense à", "servir"),
        ],
        fill_item=("Je m'arrête ___ parler pour goûter.", "de"),
        words=["J'essaie", "de", "couper", "les", "figues", "."],
        anagram=("sucrer", "Léa évite de trop… le potage."),
        error=(
            "Je réussis de garder le goût.",
            "Je réussis à garder le goût.",
            "Réussir à.",
        ),
        pic_start=24,
        pic_words=["un marché", "un panier", "de l'eau", "une plante"],
        short_p="Imitez : cinq lignes, au moins quatre verbes prépositionnels.",
        audio="Lisez votre recette, sans aller trop vite.",
    ),
    _l(
        "EL",
        "EL — Verbes + de / + à",
        "Retenir les constructions : essayer de, éviter de, réussir à, continuer à…",
        "Apprenez la fiche.",
        "Fiche d'Aline",
        """+ de : essayer de, éviter de, s'arrêter de, oublier de, refuser de, accepter de
+ à : réussir à, continuer à, commencer à, arriver à, penser à, hésiter à
Sens : de souvent « se détacher / tenter » ; à souvent « se diriger vers l'action »
Attention : commencer à (pas commencer de, en français courant).
Continuer à + infinitif = poursuivre. Continuer de existe, plus rare ici : on retient à.
Ne pas dire : je réussis de, j'essaie à.
Dans la cuisine de Félicie : on essaie de goûter, on réussit à tourner.
Pensez à couvrir. N'oubliez pas de poser le sel.""",
        tf_item=(
            "On dit « je réussis de » à l'A2 du Seuil.",
            False,
            "Réussir à.",
        ),
        qcm_item=(
            "« Oublier » se construit avec…",
            ["à", "de", "pour", "sur"],
            1,
            "Oublier de + infinitif.",
        ),
        pairs=[
            ("essayer de", "tenter"),
            ("éviter de", "ne pas faire"),
            ("réussir à", "y arriver"),
            ("s'arrêter de", "cesser"),
        ],
        fill_item=("N'oubliez pas ___ poser le sel.", "de"),
        words=["Je", "commence", "à", "sentir", "le", "citron", "."],
        anagram=("oublier", "Le verbe… de poser le sel à droite."),
        error=(
            "Je commence de laver les feuilles.",
            "Je commence à laver les feuilles.",
            "Commencer à + infinitif.",
        ),
        pic_start=26,
        pic_words=["de l'eau", "une plante", "un tablier", "une liste"],
        short_p="Complétez un tableau : huit verbes, de ou à, un exemple chacun.",
        audio="Enregistrez la fiche et six exemples.",
    ),
]


# ---------------------------------------------------------------------------
# Séquence 3 — Un mode d'emploi (si + imparfait, pronoms indéfinis)
# ---------------------------------------------------------------------------

S3 = [
    _l(
        "CO",
        "CO — La boîte des herbes",
        "Comprendre si + imparfait → conditionnel, et quelqu'un / quelque chose / rien / personne / on.",
        "Lisez le dialogue. Que ferait-on si… ? Qui fait quoi ?",
        "Boîte ocre, Infirmerie des Herbes",
        """Aline : Si on ouvrait trop vite, on casserait le couvercle.
Félicie : Si quelqu'un appelait, on attendrait. On ne répond pas les mains mouillées.
Léa : Il n'y a personne dans le couloir. Il n'y a rien dans la boîte ?
Patrick : Si, il y a quelque chose : le sachet de Noura.
Hawa : Si personne ne lisait la notice, on se tromperait de dose.
Joël : On ferme toujours. Si on oubliait, l'odeur partirait.
Rose : Quelqu'un a laissé une cuillère. Ce n'est rien, je range.
Marc : Si on avait le temps, on relirait chaque ligne.
Yvette : On est prudents. Si quelque chose clochait, on irait voir Solange.""",
        tf_item=(
            "S'il n'y a personne dans le couloir, le couloir est vide.",
            True,
            "Personne = aucun être.",
        ),
        qcm_item=(
            "Que ferait-on si on ouvrait trop vite ?",
            [
                "On gagnerait du temps",
                "On casserait le couvercle",
                "On paierait Ibrahim",
                "On irait à Val-des-Peupliers",
            ],
            1,
            "Aline : « on casserait le couvercle. »",
        ),
        pairs=[
            ("si on ouvrait", "on casserait"),
            ("quelqu'un", "une personne"),
            ("rien", "aucune chose"),
            ("personne", "aucun être"),
        ],
        fill_item=("S'il n'y a ___ dans la boîte, elle est vide.", "rien"),
        words=["Si", "quelqu'un", "appelait", "on", "attendrait", "."],
        anagram=("couvercle", "On le casserait si on ouvrait trop vite."),
        error=(
            "Si on ouvre trop vite, on casserait le couvercle.",
            "Si on ouvrait trop vite, on casserait le couvercle.",
            "Si + imparfait → conditionnel.",
        ),
        pic_start=8,
        pic_words=["un mode d'emploi", "une hypothèse", "quelqu'un", "une boîte"],
        short_p="Notez deux phrases si + imparfait et trois indéfinis.",
        audio="Enregistrez : Si on ouvrait trop vite, on casserait le couvercle. Il n'y a personne. Il y a quelque chose.",
    ),
    _l(
        "CE",
        "CE — Notice de la boîte",
        "Lire un mode d'emploi avec hypothèses et indéfinis.",
        "Lisez la notice, sans aller trop vite.",
        "Notice collée, Infirmerie des Herbes",
        """Boîte des Herbes — mode d'emploi
1. On ouvre lentement. Si on forçait, on casserait le bois.
2. S'il n'y a plus rien, on va au Marché des Lampions.
3. Si quelqu'un d'autre a déjà mesuré, on ne recommence pas.
4. On ne laisse personne toucher le sachet de Noura sans gants.
5. Si quelque chose sentait trop fort, on aérerait la salle.
6. Questions : Yvette ou Lila Sow. On n'écrit rien au crayon sur le bois.
Seuil des Sources — Rukiri-Nord""",
        tf_item=(
            "On peut écrire au crayon sur le bois.",
            False,
            "« On n'écrit rien au crayon sur le bois. »",
        ),
        qcm_item=(
            "Que ferait-on si quelque chose sentait trop fort ?",
            ["On fermerait", "On aérerait la salle", "On paierait", "On cacherait Yvette"],
            1,
            "Point 5.",
        ),
        pairs=[
            ("si on forçait", "on casserait"),
            ("plus rien", "boîte vide"),
            ("quelqu'un d'autre", "a déjà mesuré"),
            ("personne", "sans gants"),
        ],
        fill_item=("On ne laisse ___ toucher le sachet sans gants.", "personne"),
        words=["On", "ouvre", "lentement", "."],
        anagram=("aererait", "On… la salle si l'odeur était trop forte (sans accent)."),
        error=(
            "Si on force, on casserait le bois.",
            "Si on forçait, on casserait le bois.",
            "Les deux verbes suivent si + imparfait / conditionnel.",
        ),
        pic_start=28,
        pic_words=["un tablier", "une liste", "commencer", "manger"],
        short_p="Recopiez trois hypothèses et encadrez quelqu'un / rien / personne / on.",
        audio="Lisez les six points de la notice, sans aller trop vite.",
    ),
    _l(
        "PO",
        "PO — Si on ouvrait…",
        "Former des hypothèses et utiliser les pronoms indéfinis à l'oral.",
        "Répétez, puis imaginez un geste de la cuisine.",
        "Modèles de Marc",
        """Si on ouvrait trop vite, on casserait tout.
Si quelqu'un appelait, on attendrait.
S'il n'y avait rien, on irait au marché.
Si personne ne lisait, on se tromperait.
On ferme toujours.
Il y a quelque chose ici.
Ce n'est rien.
Il n'y a personne.""",
        tf_item=(
            "« On » peut vouloir dire « nous » dans la notice.",
            True,
            "On ouvre = nous ouvrons.",
        ),
        qcm_item=(
            "Quelle phrase contient une hypothèse irréelle simple ?",
            [
                "On ferme toujours",
                "Si on ouvrait trop vite, on casserait tout",
                "Il y a quelque chose ici",
                "Ce n'est rien",
            ],
            1,
            "Si + imparfait + conditionnel.",
        ),
        pairs=[
            ("si + imparfait", "conditionnel"),
            ("quelqu'un", "une personne"),
            ("quelque chose", "une chose"),
            ("on", "nous / les gens"),
        ],
        fill_item=("Si personne ne lisait, on se ___.", "tromperait"),
        words=["Ce", "n'est", "rien", "."],
        anagram=("quelquun", "Une personne, pas personne : … (sans apostrophe)."),
        error=(
            "Si on aurait le temps, on relirait.",
            "Si on avait le temps, on relirait.",
            "Après si : imparfait, pas conditionnel.",
        ),
        pic_start=12,
        pic_words=["un accord", "une assiette", "une tâche", "un sourire"],
        short_p="Écrivez quatre phrases si + imparfait et quatre avec un indéfini.",
        audio="Enregistrez les huit modèles, puis deux hypothèses à vous.",
    ),
    _l(
        "PE",
        "PE — Ma notice",
        "Écrire un court mode d'emploi avec si et des indéfinis.",
        "Imitez la notice de Hawa.",
        "Notice de Hawa Diallo",
        """Hawa Diallo
On ouvre la boîte sans forcer.
Si on forçait, on casserait le bois.
S'il n'y a plus rien, on prévient Félicie.
On ne laisse personne tout seul avec le feu.
Si quelqu'un demandait de l'aide, on irait.
Ce n'est rien si on attend une minute.
Hawa
Infirmerie des Herbes""",
        tf_item=(
            "Hawa autorise à rester seul avec le feu.",
            False,
            "« On ne laisse personne tout seul avec le feu. »",
        ),
        qcm_item=(
            "Que fait-on s'il n'y a plus rien ?",
            ["On cache la boîte", "On prévient Félicie", "On part à Mwezi-Haut", "On paie Kévin"],
            1,
            "« on prévient Félicie. »",
        ),
        pairs=[
            ("si on forçait", "on casserait"),
            ("plus rien", "prévenir Félicie"),
            ("personne", "pas seul au feu"),
            ("quelqu'un", "demanderait de l'aide"),
        ],
        fill_item=("Si quelqu'un demandait de l'aide, on ___.", "irait"),
        words=["On", "ouvre", "la", "boîte", "sans", "forcer", "."],
        anagram=("forcer", "Si on… trop, le bois casse."),
        error=(
            "Si on forcerait, on casserait le bois.",
            "Si on forçait, on casserait le bois.",
            "Pas de conditionnel juste après si.",
        ),
        pic_start=16,
        pic_words=["un pronom", "un miroir", "une serviette", "une brosse"],
        short_p="Imitez : six lignes, deux si, trois indéfinis.",
        audio="Lisez votre notice, sans aller trop vite.",
    ),
    _l(
        "EL",
        "EL — Si et les indéfinis",
        "Retenir si + imparfait → conditionnel ; quelqu'un, quelque chose, rien, personne, on.",
        "Apprenez la fiche.",
        "Fiche de Lila Sow",
        """Si + imparfait, conditionnel : Si on avait le temps, on relirait.
Jamais : si on aurait. (si + conditionnel = faute ici)
quelqu'un = une personne (affirmation)
quelque chose = une chose
rien = aucune chose (avec ne : il n'y a rien)
personne = aucun être (avec ne : je ne vois personne)
on = nous / quelqu'un / les gens
rien et personne : le verbe a ne… """,
        tf_item=(
            "On dit « si j'aurais » dans cette leçon.",
            False,
            "Si + imparfait : si j'avais.",
        ),
        qcm_item=(
            "« Je ne vois… » + aucun être =",
            ["rien", "quelqu'un", "personne", "on"],
            2,
            "Je ne vois personne.",
        ),
        pairs=[
            ("si + imparfait", "condition"),
            ("conditionnel", "résultat imaginé"),
            ("rien", "chose nulle"),
            ("personne", "être nul"),
        ],
        fill_item=("Je ne vois ___. (aucun être)", "personne"),
        words=["Il", "n'y", "a", "rien", "."],
        anagram=("imparfait", "Le temps après si dans cette hypothèse."),
        error=(
            "Il n'y a pas personne dans le couloir.",
            "Il n'y a personne dans le couloir.",
            "Personne suffit : ne… personne, pas ne… pas personne.",
        ),
        pic_start=20,
        pic_words=["avant de", "après", "une flèche", "une horloge"],
        short_p="Transformez : On ouvre trop vite → Si on… / Il y a une personne → …",
        audio="Enregistrez la fiche et quatre transformations.",
    ),
]


# ---------------------------------------------------------------------------
# Séquence 4 — Une réussite à raconter (accord du PP avec avoir)
# ---------------------------------------------------------------------------

S4 = [
    _l(
        "CO",
        "CO — Les galettes de Hawa",
        "Repérer l'accord du participe passé avec avoir quand le COD est avant le verbe.",
        "Lisez le dialogue. Qu'est-ce qui a été fait ? Où est le COD ?",
        "Cuisine, assiettes encore chaudes",
        """Hawa : Je les ai faites, les galettes. Vous les avez vues ?
Félicie : La tasse que tu as cassée, je l'ai rangée.
Léa : Les herbes que j'ai coupées sentent bon.
Patrick : Les mots que j'ai écrits, Marc les a lus à Radio Figuier.
Aline : Quelle réussite ! Tu les as réussies, ces galettes.
Joël : Moi, j'ai préparé le thé. Je l'ai préparé trop fort.
Rose : Les figues que Sami a apportées, on les a partagées.
Marc : La lettre que j'ai envoyée à Solange est arrivée.
Noura : Bravo. Vous les avez bien faites.""",
        tf_item=(
            "Hawa dit : je les ai faites.",
            True,
            "COD les (galettes, fém. plur.) avant le verbe → faites.",
        ),
        qcm_item=(
            "Pourquoi écrit-on « la tasse que tu as cassée » ?",
            [
                "Parce que tasse est après le verbe",
                "Parce que le COD tasse (fém.) est avant (que)",
                "Parce que casser est un verbe en -ger",
                "Parce que Félicie est le sujet",
            ],
            1,
            "COD placé avant → accord avec le COD.",
        ),
        pairs=[
            ("je les ai faites", "galettes / fém. plur."),
            ("tasse que tu as cassée", "fém. sing."),
            ("herbes que j'ai coupées", "fém. plur."),
            ("j'ai préparé le thé", "COD après → pas d'accord"),
        ],
        fill_item=("Je les ai ___. (faire / galettes)", "faites"),
        words=["Vous", "les", "avez", "vues", "?"],
        anagram=("galettes", "Hawa les a faites : des… de la cuisine."),
        error=(
            "Je les ai fait, les galettes.",
            "Je les ai faites, les galettes.",
            "Les = galettes, féminin pluriel → faites.",
        ),
        pic_start=12,
        pic_words=["un accord", "une assiette", "une tâche", "un sourire"],
        short_p="Notez trois accords (COD avant) et une phrase sans accord (COD après).",
        audio="Enregistrez : Je les ai faites. La tasse que tu as cassée. Les herbes que j'ai coupées.",
    ),
    _l(
        "CE",
        "CE — Mot de réussite",
        "Lire un récit où l'accord avec avoir dépend de la place du COD.",
        "Lisez le mot, sans aller trop vite.",
        "Mot de Hawa, tableau de la cour",
        """Amies, amis du Seuil,
Les galettes que j'ai préparées, Félicie les a goûtées.
La recette que Léa a copiée est dans le Cahier du chemin.
Les erreurs que j'ai commises, je les ai corrigées.
J'ai ouvert la fenêtre. (fenêtre après → ouvert, pas ouverte ici ? Attention : COD après = pas d'accord.)
La fenêtre, je l'ai ouverte ensuite.
Merci à celles que j'ai remerciées ce matin.
Hawa Diallo""",
        tf_item=(
            "« J'ai ouvert la fenêtre » s'accorde.",
            False,
            "COD après le verbe : pas d'accord. Puis : je l'ai ouverte.",
        ),
        qcm_item=(
            "Quelle phrase montre un accord au féminin pluriel ?",
            [
                "J'ai ouvert la fenêtre",
                "Les galettes que j'ai préparées",
                "La recette que Léa a copiée",
                "Hawa Diallo",
            ],
            1,
            "Galettes = fém. plur. avant le verbe.",
        ),
        pairs=[
            ("préparées", "galettes"),
            ("copiée", "recette"),
            ("corrigées", "erreurs"),
            ("ouverte", "fenêtre / l'"),
        ],
        fill_item=("La fenêtre, je l'ai ___.", "ouverte"),
        words=["Je", "les", "ai", "corrigées", "."],
        anagram=("preparees", "Les galettes que j'ai… (sans accent)."),
        error=(
            "Les galettes que j'ai préparé sont chaudes.",
            "Les galettes que j'ai préparées sont chaudes.",
            "Que = galettes, fém. plur.",
        ),
        pic_start=16,
        pic_words=["un pronom", "un miroir", "une serviette", "une brosse"],
        short_p="Soulignez chaque COD placé avant et l'accord du participe.",
        audio="Lisez le mot de Hawa, sans aller trop vite.",
    ),
    _l(
        "PO",
        "PO — Dire je les ai faites",
        "Accorder à l'oral le participe passé quand le COD est avant.",
        "Répétez, puis racontez une petite réussite.",
        "Modèles d'Aline",
        """Je les ai faites.
Tu les as vues.
Il l'a cassée.
Nous les avons coupées.
Vous les avez lues.
Je l'ai ouverte.
J'ai préparé le thé.
Les lettres que j'ai écrites.""",
        tf_item=(
            "Si le COD est après, le participe avec avoir ne s'accorde pas.",
            True,
            "J'ai préparé le thé.",
        ),
        qcm_item=(
            "Quelle phrase s'accorde ?",
            [
                "J'ai préparé le thé",
                "J'ai ouvert la fenêtre",
                "Je l'ai ouverte",
                "J'ai écrit une lettre (lettre après)",
            ],
            2,
            "L' = la fenêtre, avant le verbe.",
        ),
        pairs=[
            ("les (fém.)", "faites / vues / coupées"),
            ("l' (fém.)", "cassée / ouverte"),
            ("COD après", "pas d'accord"),
            ("que + nom fém.", "accord"),
        ],
        fill_item=("Les lettres que j'ai ___. (écrire)", "écrites"),
        words=["Je", "l'ai", "ouverte", "."],
        anagram=("ouvertes", "Des fenêtres : je les ai…"),
        error=(
            "Je l'ai ouvert, la fenêtre.",
            "Je l'ai ouverte, la fenêtre.",
            "L' = fenêtre, féminin.",
        ),
        pic_start=24,
        pic_words=["un marché", "un panier", "de l'eau", "une plante"],
        short_p="Écrivez cinq phrases : trois avec accord, deux sans.",
        audio="Enregistrez les huit modèles, puis une réussite à vous.",
    ),
    _l(
        "PE",
        "PE — Ma réussite",
        "Écrire un court récit avec des accords du participe passé.",
        "Imitez le récit de Rose.",
        "Récit de Rose Iradukunda",
        """Rose Iradukunda
Les tisanes que j'ai préparées, Yvette les a bues.
La tasse que j'ai cassée, Félicie l'a remplacée.
Les doses que j'ai notées, Léa les a relues.
J'ai posé le plateau. Ensuite je l'ai posé trop vite ? Non : je l'ai posé, plateau = masc.
Les herbes, je les ai rincées.
Rose
Cuisine du Seuil""",
        tf_item=(
            "Rose a cassé une tasse.",
            True,
            "« La tasse que j'ai cassée. »",
        ),
        qcm_item=(
            "Pourquoi « posé » n'a pas de e ?",
            [
                "Parce que Rose est le sujet",
                "Parce que plateau est masculin (l' = plateau)",
                "Parce que c'est un verbe en -cer",
                "Parce que Yvette boit",
            ],
            1,
            "Accord avec le COD, pas avec le sujet.",
        ),
        pairs=[
            ("préparées", "tisanes"),
            ("cassée", "tasse"),
            ("notées", "doses"),
            ("rincées", "herbes"),
        ],
        fill_item=("Les herbes, je les ai ___.", "rincées"),
        words=["Félicie", "l'a", "remplacée", "."],
        anagram=("tisanes", "Yvette les a bues : des… d'herbes."),
        error=(
            "Les tisanes que j'ai préparé, Yvette les a bu.",
            "Les tisanes que j'ai préparées, Yvette les a bues.",
            "Tisanes : fém. plur. → préparées, bues.",
        ),
        pic_start=2,
        pic_words=["essuyer", "un tableau", "une recette", "un bol"],
        short_p="Imitez : cinq lignes, au moins trois accords visibles.",
        audio="Lisez votre récit, sans aller trop vite.",
    ),
    _l(
        "EL",
        "EL — Accord du PP avec avoir",
        "Retenir : accord seulement si le COD est placé avant le verbe.",
        "Apprenez la fiche.",
        "Fiche de synthèse",
        """Avec avoir : le participe s'accorde avec le COD si le COD est avant.
Je les ai faites. (les = galettes)
La tasse que j'ai cassée. (que = tasse)
Je l'ai ouverte. (l' = fenêtre)
Pas d'accord si le COD est après : J'ai fait les galettes. J'ai ouvert la fenêtre.
Pas d'accord avec le sujet : Hawa a réussi (pas réussie, même si Hawa est une femme).
Attention : les lettres que j'ai écrites ; les mots que j'ai lus ; les figues apportées.
Au Seuil : les galettes que j'ai faites ; la tasse que tu as cassée.""",
        tf_item=(
            "On accorde le participe avec le sujet quand l'auxiliaire est avoir.",
            False,
            "Avec avoir : accord avec le COD avant, jamais avec le sujet.",
        ),
        qcm_item=(
            "Quelle phrase est correcte ?",
            [
                "Hawa a réussie",
                "Hawa a réussi",
                "Hawa les a réussi, les galettes",
                "Hawa a faites les galettes",
            ],
            1,
            "Sujet + avoir : pas d'accord. Les galettes : Hawa les a réussies.",
        ),
        pairs=[
            ("COD avant", "accord"),
            ("COD après", "invariable"),
            ("sujet féminin + avoir", "pas d'accord"),
            ("que = COD", "regarder le nom avant que"),
        ],
        fill_item=("Hawa a ___. (réussir, pas de COD avant)", "réussi"),
        words=["La", "tasse", "que", "j'ai", "cassée", "."],
        anagram=("invariable", "Quand le COD est après, le participe reste…"),
        error=(
            "Hawa a réussie les galettes.",
            "Hawa a réussi. / Hawa les a réussies.",
            "Pas d'accord avec le sujet ; accord si les est avant.",
        ),
        pic_start=6,
        pic_words=["une cuillère", "un cahier", "un mode d'emploi", "une condition"],
        short_p="Transformez : J'ai fait les galettes. → Je les… / J'ai cassé la tasse. → …",
        audio="Enregistrez la fiche et cinq transformations.",
    ),
]


# ---------------------------------------------------------------------------
# Séquence 5 — Prendre soin de soi (pronoms possessifs)
# ---------------------------------------------------------------------------

S5 = [
    _l(
        "CO",
        "CO — Serviettes à l'infirmerie",
        "Repérer le mien, la tienne, les nôtres, les vôtres, le sien, les leurs.",
        "Lisez le dialogue. À qui appartient chaque objet ?",
        "Infirmerie des Herbes, bassine d'eau",
        """Yvette : Prends la serviette. C'est la mienne, pas la tienne.
Hawa : La tienne est trop petite. La mienne sèche déjà.
Aline : Les brosses ? Les nôtres sont à gauche. Les vôtres sont à droite.
Patrick : Le peigne, c'est le sien, celui de Joël. Le mien est dans le sac.
Léa : Nos tasses ? Les nôtres. Les leurs sont celles de Mado et Sami.
Rose : Ton thé ou le mien ? Le tien est plus clair.
Marc : Vos gants ? Les vôtres. Les nôtres restent ici.
Félicie : Chacun range le sien. On ne mélange pas les nôtres et les leurs.
Benoît : J'ai pris le vôtre par erreur. Voici le mien.""",
        tf_item=(
            "Yvette dit que la serviette est la tienne.",
            False,
            "« C'est la mienne, pas la tienne. »",
        ),
        qcm_item=(
            "Où sont les brosses du groupe d'Aline ?",
            ["À droite", "À gauche", "Chez Ibrahim", "Sous le figuier"],
            1,
            "« Les nôtres sont à gauche. »",
        ),
        pairs=[
            ("la mienne", "serviette d'Yvette"),
            ("les nôtres", "brosses d'Aline"),
            ("le sien", "peigne de Joël"),
            ("les leurs", "tasses de Mado et Sami"),
        ],
        fill_item=("C'est la ___, pas la tienne.", "mienne"),
        words=["Les", "nôtres", "sont", "à", "gauche", "."],
        anagram=("mienne", "La serviette d'Yvette : la…"),
        error=(
            "C'est le mienne, la serviette.",
            "C'est la mienne, la serviette.",
            "Serviette est féminin : la mienne.",
        ),
        pic_start=16,
        pic_words=["un pronom", "un miroir", "une serviette", "une brosse"],
        short_p="Notez six possessifs entendus et leur propriétaire.",
        audio="Enregistrez : C'est la mienne. La tienne est trop petite. Les nôtres sont à gauche. Les vôtres sont à droite.",
    ),
    _l(
        "CE",
        "CE — Affiche « chacun le sien »",
        "Lire une affiche qui oppose mon / le mien, ton / le tien…",
        "Lisez l'affiche, sans aller trop vite.",
        "Affiche, Infirmerie des Herbes",
        """Chacun range le sien
La serviette : la mienne / la tienne / la sienne
Les gants : les miens / les tiens / les siens
Le bol de soin : le nôtre (groupe du matin) / le vôtre (groupe du soir)
Les huiles : les nôtres restent. Les leurs partent avec Lila.
Ne prenez pas le mien pour le tien.
Questions : Yvette, Noura, Ibrahim.
Seuil des Sources""",
        tf_item=(
            "Les huiles du groupe du matin restent.",
            True,
            "« Les nôtres restent. »",
        ),
        qcm_item=(
            "Le bol du groupe du soir, c'est…",
            ["le nôtre", "le vôtre", "le mien", "les leurs"],
            1,
            "« le vôtre (groupe du soir) »",
        ),
        pairs=[
            ("la mienne", "ma serviette"),
            ("le tien", "ton objet, masculin"),
            ("le nôtre", "notre bol, matin"),
            ("les leurs", "leurs huiles"),
        ],
        fill_item=("Ne prenez pas le mien pour le ___.", "tien"),
        words=["Chacun", "range", "le", "sien", "."],
        anagram=("serviette", "On range la sienne : un linge pour se sécher."),
        error=(
            "Le bol de soin : la nôtre.",
            "Le bol de soin : le nôtre.",
            "Bol est masculin : le nôtre.",
        ),
        pic_start=18,
        pic_words=["une serviette", "une brosse", "avant de", "après"],
        short_p="Recopiez l'affiche et ajoutez deux lignes : le mien / la tienne.",
        audio="Lisez l'affiche, sans aller trop vite.",
    ),
    _l(
        "PO",
        "PO — Dire le mien, la tienne",
        "Remplacer mon sac, ta tasse… par un pronom possessif.",
        "Répétez, puis parlez d'objets de soin.",
        "Modèles de Léa",
        """C'est le mien.
C'est la tienne.
Ce sont les nôtres.
Ce sont les vôtres.
C'est le sien.
Ce sont les leurs.
Le tien est plus clair.
La mienne sèche déjà.""",
        tf_item=(
            "« Les nôtres » remplace « nos + nom pluriel ».",
            True,
            "Nos brosses → les nôtres.",
        ),
        qcm_item=(
            "« Ta serviette » devient…",
            ["le tien", "la tienne", "les tiennes", "la vôtre"],
            1,
            "Serviette, féminin singulier : la tienne.",
        ),
        pairs=[
            ("mon / ma / mes", "le mien / la mienne / les miens"),
            ("ton / ta / tes", "le tien / la tienne / les tiens"),
            ("notre / nos", "le nôtre / les nôtres"),
            ("leur / leurs", "le leur / les leurs"),
        ],
        fill_item=("Ta serviette → la ___.", "tienne"),
        words=["C'est", "le", "sien", "."],
        anagram=("votres", "Ce sont les… : à vous (sans accent)."),
        error=(
            "C'est le tienne, ta tasse.",
            "C'est la tienne, ta tasse.",
            "Tasse : féminin → la tienne.",
        ),
        pic_start=22,
        pic_words=["une flèche", "une horloge", "un marché", "un panier"],
        short_p="Transformez huit groupes : mon thé, ta tasse, nos gants, vos huiles…",
        audio="Enregistrez les huit modèles, puis quatre objets à vous.",
    ),
    _l(
        "PE",
        "PE — Ma liste de soin",
        "Écrire une liste qui utilise les pronoms possessifs.",
        "Imitez la liste de Patrick.",
        "Liste de Patrick Habimana",
        """Patrick Habimana
La serviette : la mienne. La tienne reste au crochet.
Les brosses : les nôtres. Les vôtres partent ce soir.
Le peigne de Joël : le sien. Le mien est dans le sac.
Les tasses de Mado et Sami : les leurs.
Ton thé est trop fort. Le mien est plus clair.
Patrick
Infirmerie des Herbes""",
        tf_item=(
            "Le peigne de Joël, c'est le mien.",
            False,
            "« Le peigne de Joël : le sien. »",
        ),
        qcm_item=(
            "Quel thé est plus clair ?",
            ["Le tien", "Le mien (celui de Patrick)", "Le leur", "Le vôtre"],
            1,
            "« Le mien est plus clair. »",
        ),
        pairs=[
            ("la mienne", "serviette de Patrick"),
            ("les nôtres", "brosses du groupe"),
            ("le sien", "peigne de Joël"),
            ("les leurs", "tasses de Mado et Sami"),
        ],
        fill_item=("Le peigne de Joël : le ___.", "sien"),
        words=["La", "tienne", "reste", "au", "crochet", "."],
        anagram=("crochet", "La tienne reste à cet objet du mur."),
        error=(
            "Les tasses de Mado et Sami : les siens.",
            "Les tasses de Mado et Sami : les leurs.",
            "À eux / à elles : les leurs.",
        ),
        pic_start=26,
        pic_words=["de l'eau", "une plante", "un tablier", "une liste"],
        short_p="Imitez : six lignes, six possessifs différents.",
        audio="Lisez votre liste, sans aller trop vite.",
    ),
    _l(
        "EL",
        "EL — Pronoms possessifs",
        "Retenir le mien, la tienne, les nôtres, les vôtres et l'accord.",
        "Apprenez la fiche.",
        "Fiche d'Yvette",
        """Adjectif : mon / ton / son + nom. Pronom : le mien / le tien / le sien (sans le nom).
Féminin : la mienne, la tienne, la sienne, la nôtre, la vôtre, la leur
Pluriel : les miens / les miennes ; les nôtres ; les vôtres ; les leurs
nôtre / vôtre : accent circonflexe au pronom. Notre / votre (adjectifs) : pas d'accent.
Le mien = mon objet (masc.). La mienne = mon objet (fém.).
On ne dit pas : c'est mien. On dit : c'est le mien.
À l'infirmerie : la serviette, c'est la mienne ; les brosses, ce sont les nôtres.
Leur / leurs (adjectif) → le leur / les leurs (pronom).""",
        tf_item=(
            "On écrit « les notres » sans accent.",
            False,
            "Pronom : les nôtres, avec accent.",
        ),
        qcm_item=(
            "Quelle forme est un pronom ?",
            ["notre bol", "le nôtre", "nos gants", "votre thé"],
            1,
            "Le nôtre remplace le nom.",
        ),
        pairs=[
            ("mon bol", "le mien"),
            ("ta tasse", "la tienne"),
            ("nos brosses", "les nôtres"),
            ("leurs huiles", "les leurs"),
        ],
        fill_item=("Notre bol → le ___.", "nôtre"),
        words=["C'est", "la", "sienne", "."],
        anagram=("circonflexe", "L'accent de nôtre et de vôtre."),
        error=(
            "C'est mien, ce peigne.",
            "C'est le mien, ce peigne.",
            "Toujours article : le / la / les + pronom.",
        ),
        pic_start=10,
        pic_words=["quelqu'un", "une boîte", "un accord", "une assiette"],
        short_p="Tableau complet : adjectif → pronom, six personnes, deux genres.",
        audio="Enregistrez la fiche et huit pronoms.",
    ),
]


# ---------------------------------------------------------------------------
# Séquence 6 — Une suite d'actions (avant de / après + infinitif)
# ---------------------------------------------------------------------------

S6 = [
    _l(
        "CO",
        "CO — L'ordre du matin",
        "Repérer avant de / après + infinitif et les marqueurs d'abord, ensuite, puis, enfin.",
        "Lisez le dialogue. Dans quel ordre fait-on les gestes ?",
        "Cuisine, horloge de la Table des Sources",
        """Félicie : Avant de couper, lavez-vous les mains.
Aline : Après ranger les bols, on essuie la table.
Léa : D'abord l'eau. Ensuite le feu. Puis le sel. Enfin le goût.
Patrick : Avant de goûter, on attend une minute.
Hawa : Après avoir servi, on s'assoit sous le figuier.
Joël : On ne parle pas avant de couvrir le pot.
Rose : Après balayer, nous ouvrons la fenêtre.
Marc : D'abord le marché. Ensuite la cuisine. Puis le repos.
Kévin : Avant de partir, signez le cahier. Après signer, on range le crayon.""",
        tf_item=(
            "On se lave les mains après avoir coupé.",
            False,
            "Félicie : « Avant de couper, lavez-vous les mains. »",
        ),
        qcm_item=(
            "Quel est l'ordre de Léa ?",
            [
                "sel, feu, eau, goût",
                "eau, feu, sel, goût",
                "goût, eau, feu, sel",
                "feu, goût, sel, eau",
            ],
            1,
            "D'abord l'eau. Ensuite le feu. Puis le sel. Enfin le goût.",
        ),
        pairs=[
            ("avant de couper", "laver les mains"),
            ("après ranger", "essuyer"),
            ("d'abord / ensuite / puis / enfin", "ordre"),
            ("avant de partir", "signer"),
        ],
        fill_item=("___ de couper, lavez-vous les mains.", "Avant"),
        words=["Après", "ranger", "les", "bols", "on", "essuie", "."],
        anagram=("dabord", "Le premier marqueur de la liste de Léa (sans apostrophe)."),
        error=(
            "Avant couper, lavez-vous les mains.",
            "Avant de couper, lavez-vous les mains.",
            "Avant de + infinitif.",
        ),
        pic_start=20,
        pic_words=["avant de", "après", "une flèche", "une horloge"],
        short_p="Notez trois avant de, deux après, et la série d'abord… enfin.",
        audio="Enregistrez : Avant de couper, lavez-vous les mains. Après ranger, on essuie. D'abord l'eau, ensuite le feu.",
    ),
    _l(
        "CE",
        "CE — Suite affichée",
        "Lire une suite d'actions avec avant de, après, d'abord, ensuite.",
        "Lisez la suite, sans aller trop vite.",
        "Affiche du tableau de la cour",
        """Suite du jour — cuisine et cour
1. Avant d'ouvrir le marché, compter les paniers.
2. Après revenir, poser l'eau à la Table des Sources.
3. D'abord laver. Ensuite ciseler. Puis tourner. Enfin goûter.
4. Avant de servir, prévenir Yvette à l'infirmerie.
5. Après avoir rangé, balayer la Salle des Herbes.
6. Avant de signer le cahier, relire. Après signer, accrocher le crayon.
Félicie et Aline""",
        tf_item=(
            "On prévient Yvette après avoir servi.",
            False,
            "« Avant de servir, prévenir Yvette. »",
        ),
        qcm_item=(
            "Que fait-on après être revenu ?",
            [
                "Compter les paniers",
                "Poser l'eau à la Table des Sources",
                "Signer tout de suite",
                "Partir à Port de la Brise",
            ],
            1,
            "Point 2.",
        ),
        pairs=[
            ("avant d'ouvrir", "compter"),
            ("après revenir", "poser l'eau"),
            ("avant de servir", "Yvette"),
            ("après avoir rangé", "balayer"),
        ],
        fill_item=("Avant ___ servir, prévenir Yvette.", "de"),
        words=["D'abord", "laver", ".", "Ensuite", "ciseler", "."],
        anagram=("ciseler", "La deuxième action après laver, dans le point 3."),
        error=(
            "Après de ranger, balayer la salle.",
            "Après avoir rangé, balayer la Salle des Herbes.",
            "Après + infinitif (souvent avoir + PP) ; pas après de.",
        ),
        pic_start=0,
        pic_words=["commencer", "manger", "essuyer", "un tableau"],
        short_p="Recopiez la suite et numérotez les actions de 1 à 8.",
        audio="Lisez les six points, sans aller trop vite.",
    ),
    _l(
        "PO",
        "PO — Dire avant de, après",
        "Enchaîner des actions avec avant de, après, d'abord, ensuite, puis, enfin.",
        "Répétez, puis racontez votre matin.",
        "Modèles de Joël",
        """Avant de couper, je lave.
Après ranger, j'essuie.
D'abord l'eau.
Ensuite le feu.
Puis le sel.
Enfin je goûte.
Avant de partir, je signe.
Après signer, je range.""",
        tf_item=(
            "« Enfin » marque la dernière étape.",
            True,
            "D'abord… ensuite… puis… enfin.",
        ),
        qcm_item=(
            "Quelle forme est correcte ?",
            [
                "avant couper",
                "avant de couper",
                "avant à couper",
                "après de couper",
            ],
            1,
            "Avant de + infinitif.",
        ),
        pairs=[
            ("avant de", "action pas encore faite"),
            ("après + infinitif", "action déjà faite"),
            ("d'abord", "première"),
            ("enfin", "dernière"),
        ],
        fill_item=("___ ranger, j'essuie.", "Après"),
        words=["Avant", "de", "partir", "je", "signe", "."],
        anagram=("ensuite", "Le marqueur après d'abord, avant puis."),
        error=(
            "Avant à partir, je signe.",
            "Avant de partir, je signe.",
            "Avant de, pas avant à.",
        ),
        pic_start=8,
        pic_words=["un mode d'emploi", "une hypothèse", "quelqu'un", "une boîte"],
        short_p="Écrivez une suite de six gestes avec six marqueurs différents.",
        audio="Enregistrez les huit modèles, puis votre matin.",
    ),
    _l(
        "PE",
        "PE — Ma suite du jour",
        "Écrire une suite d'actions avec avant de / après et des marqueurs.",
        "Imitez la suite de Marc.",
        "Suite de Marc Nkurunziza",
        """Marc Nkurunziza
Avant de quitter la Maison des Vents, je bois de l'eau.
D'abord le banc. Ensuite le figuier. Puis la cuisine.
Après saluer Félicie, je lis le tableau.
Avant de goûter, j'attends.
Après avoir noté, j'accroche le crayon.
Marc
Seuil des Sources""",
        tf_item=(
            "Marc boit de l'eau après avoir quitté la maison.",
            False,
            "« Avant de quitter… je bois de l'eau. »",
        ),
        qcm_item=(
            "Que fait Marc après avoir salué Félicie ?",
            ["Il part à Rive d'Orage", "Il lit le tableau", "Il paie Ibrahim", "Il ferme Radio Figuier"],
            1,
            "« Après saluer Félicie, je lis le tableau. »",
        ),
        pairs=[
            ("avant de quitter", "boire"),
            ("d'abord", "le banc"),
            ("après saluer", "lire le tableau"),
            ("après avoir noté", "accrocher"),
        ],
        fill_item=("Avant ___ goûter, j'attends.", "de"),
        words=["Après", "saluer", "Félicie", "je", "lis", "."],
        anagram=("accroche", "Après avoir noté, il… le crayon."),
        error=(
            "Avant quitter la maison, je bois.",
            "Avant de quitter la Maison des Vents, je bois de l'eau.",
            "Avant de + infinitif.",
        ),
        pic_start=14,
        pic_words=["une tâche", "un sourire", "un pronom", "un miroir"],
        short_p="Imitez : six lignes, avant de, après, d'abord, ensuite.",
        audio="Lisez votre suite, sans aller trop vite.",
    ),
    _l(
        "EL",
        "EL — Avant de, après, marqueurs",
        "Retenir avant de + infinitif, après + infinitif, d'abord / ensuite / puis / enfin.",
        "Apprenez la fiche.",
        "Fiche du carnet",
        """Avant de + infinitif : Avant de couper, lavez. (l'action n'est pas encore faite)
Après + infinitif : Après ranger… / Après avoir rangé… (l'action est faite)
Pas : avant couper. Pas : après de ranger.
Marqueurs : d'abord, ensuite, puis, enfin. Aussi : puis, après cela, pour finir.
Avant d' + voyelle : avant d'ouvrir, avant d'essayer.
Même sujet pour avant de / après + infinitif. Si le sujet change : avant que (plus tard).
Suite type : d'abord l'eau, ensuite le feu, puis le sel, enfin le goût.
Après avoir signé, on accroche le crayon au tableau de la cour.""",
        tf_item=(
            "On écrit « avant d'ouvrir » avec d'.",
            True,
            "Élision : de + o → d'.",
        ),
        qcm_item=(
            "Quelle série est dans le bon ordre habituel ?",
            [
                "enfin / d'abord / puis",
                "d'abord / ensuite / puis / enfin",
                "puis / d'abord / enfin",
                "ensuite / enfin / d'abord",
            ],
            1,
            "D'abord… ensuite… puis… enfin.",
        ),
        pairs=[
            ("avant de", "pas encore"),
            ("après", "déjà fait"),
            ("d'abord", "1"),
            ("enfin", "dernier"),
        ],
        fill_item=("Avant ___ ouvrir, compter les paniers.", "d'"),
        words=["Après", "avoir", "rangé", "on", "balaye", "."],
        anagram=("marqueurs", "D'abord, ensuite, puis, enfin : des… de temps."),
        error=(
            "Avant ouvrir le marché, compter les paniers.",
            "Avant d'ouvrir le marché, compter les paniers.",
            "Avant de / d' + infinitif.",
        ),
        pic_start=4,
        pic_words=["une recette", "un bol", "une cuillère", "un cahier"],
        short_p="Écrivez huit phrases : quatre avant de, quatre après.",
        audio="Enregistrez la fiche et six exemples.",
    ),
]


SEQUENCES = [
    {"title": "Instructions du jour", "lessons": S1},
    {"title": "Une recette à rédiger", "lessons": S2},
    {"title": "Un mode d'emploi", "lessons": S3},
    {"title": "Une réussite à raconter", "lessons": S4},
    {"title": "Prendre soin de soi", "lessons": S5},
    {"title": "Une suite d'actions", "lessons": S6},
]
