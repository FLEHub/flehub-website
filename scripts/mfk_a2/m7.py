"""A2 Module 7 — Mémoire et engagement (univers Seuil des Sources)."""

from factory import L

IMG = "mfk-a2-m7"
IMG_DIR = IMG

MODULE = {
    "title": "A2 — Mémoire et engagement",
    "description": (
        "Grande étape A2-7 : comprendre un récit aux trois temps du passé, "
        "raconter un souvenir, enchaîner des faits, défendre une cause, "
        "agir pour la nature et donner son avis — autour du figuier et de "
        "la petite rivière, avec le Cahier des racines, au Seuil des Sources "
        "(Rukiri-Nord)."
    ),
}


def _l(comp, title, obj, cons, st, sp, **kw):
    return L(IMG, comp, title, obj, cons, st, sp, **kw)


# ---------------------------------------------------------------------------
# Séquence 1 — Un récit à comprendre (PC / imparfait / PQP)
# ---------------------------------------------------------------------------

S1 = [
    _l(
        "CO",
        "CO — Sous le figuier d'avant",
        "Distinguer passé composé, imparfait et plus-que-parfait dans un récit.",
        "Lisez le dialogue (à écouter avec l'enseignant). Quel temps pour quel fait ?",
        "Banc du Seuil, photo ocre",
        """Aline : Le figuier était déjà là. On se retrouvait chaque soir.
Patrick : Un jour, la rivière a débordé. Elle avait déjà monté deux fois.
Léa : Nous avons tiré les bancs. Joël avait préparé des seaux.
Marc : Dieudonné cousait un tissu pour protéger le tronc. Il a fini à l'aube.
Hawa : Rose chantait. Puis elle a signé la première page.
Solange : Karim avait affiché un mot. Nous l'avons lu trop tard.
Lila : Il pleuvait. Nous avons quand même tenu le Cahier des racines.
Joël : J'avais oublié mon crayon. Léa m'en a prêté un.
Yvette : La cour sentait l'herbe. On a respiré, puis on a décidé.""",
        tf_item=(
            "Le figuier était déjà là : c'est un imparfait de décor.",
            True,
            "Aline pose le décor avec l'imparfait.",
        ),
        qcm_item=(
            "Quel fait est antérieur à « la rivière a débordé » ?",
            [
                "On a respiré",
                "Elle avait déjà monté deux fois",
                "Rose a signé",
                "Léa a prêté un crayon",
            ],
            1,
            "Plus-que-parfait : action déjà faite avant une autre au passé.",
        ),
        pairs=[
            ("était / se retrouvait", "imparfait, décor ou habitude"),
            ("a débordé / avons tiré", "passé composé, fait"),
            ("avait monté / avait préparé", "plus-que-parfait"),
            ("pleuvait", "arrière-plan"),
        ],
        fill_item=("Joël ___ préparé des seaux. (avoir, PQP)", "avait"),
        words=["La", "rivière", "a", "débordé", "."],
        anagram=("deborde", "La rivière l'a fait un jour (sans accent)."),
        error=(
            "Un jour, la rivière débordait tout d'un coup et c'est tout.",
            "Un jour, la rivière a débordé.",
            "Fait soudain, daté : passé composé.",
        ),
        pic_start=0,
        pic_words=["un récit", "trois temps", "un cahier", "une photo"],
        short_p="Classez neuf verbes du dialogue : PC / imparfait / PQP.",
        audio="Enregistrez : Le figuier était déjà là. La rivière a débordé. Elle avait déjà monté.",
    ),
    _l(
        "CE",
        "CE — Page du Cahier des racines",
        "Lire un récit qui mélange les trois temps du passé.",
        "Lisez la page, sans aller trop vite.",
        "Cahier des racines, première feuille",
        """Page 1 — mémoire de la cour
Le figuier donnait déjà de l'ombre. Les enfants jouaient près de l'eau.
Un soir, le niveau a monté. La terre avait déjà glissé derrière l'Atelier du Tissu.
Nous avons formé une chaîne. Hawa avait apporté des lampions du marché.
Dieudonné a tendu le tissu. Il cousait encore quand Aline a crié.
On a sauvé les jeunes plants. On n'avait jamais vu une crue si rapide.
Solange a ouvert le Bureau des Escales. Karim y avait laissé la clé.
Nous avons décidé d'écrire. Le cahier s'est appelé Cahier des racines.""",
        tf_item=(
            "On avait déjà vu une crue aussi rapide.",
            False,
            "« On n'avait jamais vu une crue si rapide. »",
        ),
        qcm_item=(
            "Qui avait apporté des lampions ?",
            ["Marc", "Hawa", "Kévin", "Ibrahim"],
            1,
            "« Hawa avait apporté des lampions. »",
        ),
        pairs=[
            ("donnait / jouaient", "imparfait"),
            ("a monté / avons formé", "passé composé"),
            ("avait glissé / avait apporté", "plus-que-parfait"),
            ("cousait encore", "action en cours"),
        ],
        fill_item=("Karim y ___ laissé la clé.", "avait"),
        words=["Nous", "avons", "décidé", "d'écrire", "."],
        anagram=("lampions", "Hawa les avait apportés du marché."),
        error=(
            "Un soir, le niveau montait tout à coup comme un fait unique.",
            "Un soir, le niveau a monté.",
            "Fait unique, daté : passé composé.",
        ),
        pic_start=4,
        pic_words=["un souvenir", "une horloge", "un banc", "une lettre"],
        short_p="Recopiez la page et coloriez PC / imparfait / PQP de trois couleurs.",
        audio="Lisez la page 1 du Cahier des racines, sans aller trop vite.",
    ),
    _l(
        "PO",
        "PO — Dire les trois temps",
        "Raconter un même souvenir en choisissant PC, imparfait ou PQP.",
        "Répétez, puis parlez d'un soir sous le figuier.",
        "Modèles de Marc",
        """Il pleuvait.
Le figuier était grand.
Nous nous retrouvions souvent.
Puis l'eau a monté.
Nous avons tiré les bancs.
Joël avait préparé des seaux.
J'avais oublié mon crayon.
Léa m'en a prêté un.""",
        tf_item=(
            "L'imparfait sert surtout au décor et à l'habitude.",
            True,
            "Il pleuvait. Nous nous retrouvions.",
        ),
        qcm_item=(
            "Quelle phrase est au plus-que-parfait ?",
            [
                "Il pleuvait",
                "L'eau a monté",
                "Joël avait préparé des seaux",
                "Léa m'en a prêté un",
            ],
            2,
            "avait + participe : PQP.",
        ),
        pairs=[
            ("imparfait", "décor / habitude"),
            ("passé composé", "fait achevé"),
            ("plus-que-parfait", "avant un autre passé"),
            ("puis", "bascule vers le PC"),
        ],
        fill_item=("J'___ oublié mon crayon.", "avais"),
        words=["Il", "pleuvait", "."],
        anagram=("habitude", "L'imparfait raconte aussi une… du soir."),
        error=(
            "Joël a préparé des seaux avant que l'eau monte, donc on dit il prépare.",
            "Joël avait préparé des seaux.",
            "Fait déjà accompli avant un autre passé : PQP.",
        ),
        pic_start=8,
        pic_words=["une suite", "des flèches", "un calendrier", "un pont"],
        short_p="Écrivez six phrases : deux de chaque temps.",
        audio="Enregistrez les huit modèles, puis un souvenir à vous.",
    ),
    _l(
        "PE",
        "PE — Ma page de mémoire",
        "Écrire un récit court qui utilise les trois temps du passé.",
        "Imitez la page de Léa.",
        "Page de Léa Niyonzima",
        """Léa Niyonzima
La cour était calme. Le figuier donnait de l'ombre.
Un soir, l'eau a touché le banc. Elle avait déjà reculé deux fois.
Nous avons porté les jeunes plants. Patrick avait ouvert le seau.
J'ai signé le Cahier des racines. Je n'avais jamais écrit si vite.
Dieudonné cousait encore. Il avait déjà tendu le premier coupon.
Léa
Seuil des Sources — Rukiri-Nord""",
        tf_item=(
            "Léa avait déjà souvent écrit aussi vite.",
            False,
            "« Je n'avais jamais écrit si vite. »",
        ),
        qcm_item=(
            "Quel temps pour « Le figuier donnait de l'ombre » ?",
            ["passé composé", "imparfait", "plus-que-parfait", "présent"],
            1,
            "Imparfait de décor.",
        ),
        pairs=[
            ("était / donnait", "imparfait"),
            ("a touché / avons porté", "passé composé"),
            ("avait reculé / avait ouvert", "plus-que-parfait"),
            ("n'avais jamais écrit", "PQP + jamais"),
        ],
        fill_item=("Patrick ___ ouvert le seau.", "avait"),
        words=["La", "cour", "était", "calme", "."],
        anagram=("racines", "Le cahier porte ce nom : Cahier des…"),
        error=(
            "Un soir, l'eau touchait le banc tout à coup une seule fois.",
            "Un soir, l'eau a touché le banc.",
            "Fait unique : passé composé.",
        ),
        pic_start=12,
        pic_words=["une cause", "une affiche", "une main", "un arbre"],
        short_p="Imitez : six lignes, les trois temps au moins une fois chacun.",
        audio="Lisez votre page, une phrase, une pause, sans aller trop vite.",
    ),
    _l(
        "EL",
        "EL — PC, imparfait, PQP",
        "Retenir le rôle de chaque temps dans un récit.",
        "Apprenez la fiche.",
        "Fiche d'Aline",
        """Imparfait : décor, habitude, action en cours. Il pleuvait. On se retrouvait.
Passé composé : fait achevé, souvent daté ou soudain. L'eau a monté. Nous avons signé.
Plus-que-parfait : déjà fait avant un autre moment du passé. Il avait préparé. J'avais oublié.
Repères : un jour / soudain / puis → souvent PC.
déjà / jamais + PQP : On n'avait jamais vu. Elle avait déjà monté.
On ne raconte pas tout à l'imparfait si les faits avancent.
Exemple Seuil : Le figuier était là. Un soir, l'eau a monté. Joël avait préparé des seaux.
Le PQP se place souvent avant un PC dans la même histoire.""",
        tf_item=(
            "Le plus-que-parfait se forme avec l'imparfait de avoir / être + participe.",
            True,
            "avait préparé, était déjà parti.",
        ),
        qcm_item=(
            "« Un jour » entraîne souvent…",
            ["l'imparfait seulement", "le passé composé", "le futur", "l'impératif"],
            1,
            "Repère de fait : PC.",
        ),
        pairs=[
            ("décor", "imparfait"),
            ("fait", "passé composé"),
            ("avant-avant", "plus-que-parfait"),
            ("déjà / jamais", "souvent PQP"),
        ],
        fill_item=("On n'___ jamais vu une crue si rapide.", "avait"),
        words=["Nous", "nous", "retrouvions", "souvent", "."],
        anagram=("anterieur", "Le PQP dit qu'un fait est… à un autre (sans accent)."),
        error=(
            "Il a plu tout le temps, chaque soir, comme une habitude.",
            "Il pleuvait chaque soir.",
            "Habitude : imparfait.",
        ),
        pic_start=16,
        pic_words=["la nature", "la préposition à", "la préposition de", "un seau"],
        short_p="Réécrivez un mini-récit de six verbes en justifiant chaque temps.",
        audio="Enregistrez la fiche et six exemples.",
    ),
]


# ---------------------------------------------------------------------------
# Séquence 2 — Un souvenir à raconter (moment précis vs durée)
# ---------------------------------------------------------------------------

S2 = [
    _l(
        "CO",
        "CO — Ce matin-là, longtemps",
        "Opposer un moment précis et une durée : à huit heures / pendant / longtemps / depuis.",
        "Lisez le dialogue. Qu'est-ce qui dure ? Qu'est-ce qui arrive pile ?",
        "Banc longtemps occupé, horloge du Seuil",
        """Rose : Ce matin-là, à huit heures, le figuier a craqué.
Aline : Pendant deux heures, nous avons tenu les seaux.
Patrick : Longtemps, les enfants ont joué près de l'eau. Puis, soudain, ça s'est tu.
Léa : Depuis lundi, on surveille. Ça fait trois jours.
Marc : Un instant, j'ai cru que le pont cédait. Ensuite toute la journée, on a parlé.
Hawa : À midi pile, Solange a ouvert le cahier. Elle est restée une heure.
Joël : Toute la semaine, Dieudonné a cousu. À l'aube, il a fini.
Lila : Il y a deux ans, la rivière était plus large. Pendant l'été, on nageait.
Mado : Soudain, Kévin a crié. Nous sommes restés silencieux longtemps.""",
        tf_item=(
            "« À huit heures » marque un moment précis.",
            True,
            "Rose date le craquement.",
        ),
        qcm_item=(
            "Quelle expression indique une durée ?",
            ["ce matin-là", "à midi pile", "pendant deux heures", "soudain"],
            2,
            "Pendant + durée.",
        ),
        pairs=[
            ("à huit heures / à midi pile", "moment"),
            ("pendant deux heures", "durée"),
            ("longtemps / toute la semaine", "durée large"),
            ("soudain / un instant", "point"),
        ],
        fill_item=("___ deux heures, nous avons tenu les seaux.", "Pendant"),
        words=["Ce", "matin-là", "le", "figuier", "a", "craqué", "."],
        anagram=("soudain", "L'adverbe de Kévin : tout d'un coup."),
        error=(
            "À huit heures pendant, le figuier a craqué.",
            "Ce matin-là, à huit heures, le figuier a craqué.",
            "À + heure = moment, pas une durée.",
        ),
        pic_start=4,
        pic_words=["un souvenir", "une horloge", "un banc", "une lettre"],
        short_p="Listez quatre moments précis et quatre durées du dialogue.",
        audio="Enregistrez : Ce matin-là, à huit heures, le figuier a craqué. Pendant deux heures, nous avons tenu les seaux.",
    ),
    _l(
        "CE",
        "CE — Lettre de Rose",
        "Lire un souvenir qui alterne points dans le temps et durées.",
        "Lisez la lettre, sans aller trop vite.",
        "Lettre de Rose Iradukunda",
        """Chers amis du Seuil,
Il y a cinq ans, un après-midi, je me suis assise sous le figuier.
J'y suis restée longtemps. Toute la soirée, les lampions du marché brillaient.
À dix-sept heures précises, Aline a posé le premier seau.
Depuis ce jour, je reviens. Ça fait des mois que l'eau baisse.
Pendant l'hiver, la terre a glissé. En une nuit, le sentier a disparu.
Soudain, on a eu peur. Puis, pendant trois jours, on a reparlé.
Rose""",
        tf_item=(
            "Rose s'est assise il y a cinq ans.",
            True,
            "« Il y a cinq ans, un après-midi… »",
        ),
        qcm_item=(
            "Quand Aline a-t-elle posé le premier seau ?",
            ["Pendant l'hiver", "À dix-sept heures précises", "En une nuit", "Depuis lundi"],
            1,
            "Moment précis dans la lettre.",
        ),
        pairs=[
            ("il y a cinq ans", "distance depuis aujourd'hui"),
            ("longtemps / toute la soirée", "durée"),
            ("à dix-sept heures", "heure pile"),
            ("en une nuit", "durée courte fermée"),
        ],
        fill_item=("___ ce jour, je reviens.", "Depuis"),
        words=["J'y", "suis", "restée", "longtemps", "."],
        anagram=("lampions", "Ils brillaient toute la soirée au marché."),
        error=(
            "Depuis dix-sept heures précises Aline a posé le seau comme une durée.",
            "À dix-sept heures précises, Aline a posé le premier seau.",
            "Heure pile : à, pas depuis.",
        ),
        pic_start=1,
        pic_words=["trois temps", "un cahier", "une photo", "un souvenir"],
        short_p="Encadrez les moments (à, soudain, il y a) et les durées (pendant, longtemps, depuis).",
        audio="Lisez la lettre de Rose, sans aller trop vite.",
    ),
    _l(
        "PO",
        "PO — Dater ou durer",
        "Dire un souvenir en choisissant un point ou une durée.",
        "Répétez, puis racontez deux souvenirs : un moment, une durée.",
        "Modèles de Patrick",
        """À huit heures, ça a craqué.
Ce matin-là, j'ai eu peur.
Soudain, Kévin a crié.
Pendant deux heures, nous avons tenu.
Longtemps, les enfants ont joué.
Toute la semaine, Dieudonné a cousu.
Depuis lundi, on surveille.
Ça fait trois jours.""",
        tf_item=(
            "« Ça fait trois jours » exprime une durée jusqu'à maintenant.",
            True,
            "Équivalent proche de depuis trois jours.",
        ),
        qcm_item=(
            "Quelle phrase date un instant ?",
            [
                "Longtemps, les enfants ont joué",
                "À huit heures, ça a craqué",
                "Pendant deux heures, nous avons tenu",
                "Toute la semaine, il a cousu",
            ],
            1,
            "À + heure.",
        ),
        pairs=[
            ("à / soudain / ce matin-là", "point"),
            ("pendant / longtemps / toute", "durée"),
            ("depuis / ça fait", "durée qui continue"),
            ("il y a", "distance vers le passé"),
        ],
        fill_item=("___ lundi, on surveille.", "Depuis"),
        words=["Soudain", "Kévin", "a", "crié", "."],
        anagram=("longtemps", "Les enfants ont joué… : une grande durée."),
        error=(
            "Pendant huit heures pile, ça a craqué une seconde.",
            "À huit heures, ça a craqué.",
            "Un instant se date par à, pas par pendant.",
        ),
        pic_start=20,
        pic_words=["de plus en plus", "de moins en moins", "un graphique", "un micro"],
        short_p="Écrivez huit phrases : quatre points, quatre durées.",
        audio="Enregistrez les huit modèles, puis deux souvenirs à vous.",
    ),
    _l(
        "PE",
        "PE — Mon souvenir",
        "Écrire un souvenir qui oppose un moment précis et une durée.",
        "Imitez le souvenir de Joël.",
        "Souvenir de Joël Mugisha",
        """Joël Mugisha
Ce soir-là, à dix-neuf heures, j'ai entendu la rivière.
J'ai écouté longtemps. Pendant une heure, l'eau a parlé plus fort.
Soudain, un bois a claqué. Ensuite toute la nuit, on a veillé.
Depuis ce soir-là, je range les seaux près du banc.
Ça fait des semaines que je reviens.
Joël
Rive de la petite rivière — Seuil""",
        tf_item=(
            "Joël a entendu la rivière à dix-neuf heures.",
            True,
            "« à dix-neuf heures, j'ai entendu la rivière. »",
        ),
        qcm_item=(
            "Quelle durée suit le claquement ?",
            ["Une seconde seulement", "Toute la nuit", "Deux minutes à midi", "Il y a cinq ans"],
            1,
            "« Ensuite toute la nuit, on a veillé. »",
        ),
        pairs=[
            ("à dix-neuf heures", "moment"),
            ("longtemps / pendant une heure", "durée"),
            ("soudain", "point"),
            ("depuis / ça fait", "jusqu'à maintenant"),
        ],
        fill_item=("J'ai écouté ___.", "longtemps"),
        words=["Soudain", "un", "bois", "a", "claqué", "."],
        anagram=("veille", "On a… toute la nuit près de l'eau."),
        error=(
            "À dix-neuf heures pendant, j'ai entendu la rivière.",
            "Ce soir-là, à dix-neuf heures, j'ai entendu la rivière.",
            "L'heure pile n'est pas une durée.",
        ),
        pic_start=24,
        pic_words=["un groupe", "une banderole", "des signatures", "des racines"],
        short_p="Imitez : six lignes, deux moments, deux durées.",
        audio="Lisez votre souvenir, sans aller trop vite.",
    ),
    _l(
        "EL",
        "EL — Moment et durée",
        "Retenir les outils pour dater un instant ou mesurer une durée.",
        "Apprenez la fiche.",
        "Fiche de Lila",
        """Moment précis : à + heure ; ce matin-là ; un jour ; soudain ; à midi pile
Durée fermée : pendant deux heures ; en une nuit ; toute la semaine
Durée ouverte jusqu'à maintenant : depuis lundi ; ça fait trois jours
Distance : il y a cinq ans (on compte depuis aujourd'hui vers le passé)
Attention : depuis + début. Pendant + longueur. En + temps pour accomplir.
On ne dit pas : pendant huit heures pour un craquement d'une seconde.
Rose : ce matin-là, à huit heures (point). Pendant deux heures, on a tenu (durée).
Ça fait trois jours = depuis trois jours, jusqu'à maintenant.""",
        tf_item=(
            "« Il y a » et « depuis » veulent dire la même chose.",
            False,
            "Il y a = distance. Depuis = ça continue.",
        ),
        qcm_item=(
            "« Ça fait trois jours » est proche de…",
            ["à trois heures", "depuis trois jours", "soudain", "en une nuit"],
            1,
            "Durée qui continue.",
        ),
        pairs=[
            ("à / soudain", "point"),
            ("pendant / toute", "durée fermée"),
            ("depuis / ça fait", "durée ouverte"),
            ("il y a", "distance"),
        ],
        fill_item=("___ trois jours qu'on surveille.", "Ça fait"),
        words=["Depuis", "lundi", "on", "surveille", "."],
        anagram=("distance", "Il y a cinq ans : une… vers le passé."),
        error=(
            "Depuis deux heures, nous avons tenu les seaux et c'est fini hier.",
            "Pendant deux heures, nous avons tenu les seaux.",
            "Action finie, longueur close : pendant.",
        ),
        pic_start=26,
        pic_words=["des signatures", "des racines", "une rivière", "un soleil"],
        short_p="Complétez un tableau : six outils, un exemple souvenir chacun.",
        audio="Enregistrez la fiche et six exemples.",
    ),
]


# ---------------------------------------------------------------------------
# Séquence 3 — Une suite de faits (prépositions et marqueurs temporels)
# ---------------------------------------------------------------------------

S3 = [
    _l(
        "CO",
        "CO — La chaîne des jours",
        "Suivre une suite : avant, après, pendant, depuis, jusqu'à, dès, lorsque, quand.",
        "Lisez le dialogue. Dans quel ordre les faits s'enchaînent-ils ?",
        "Calendrier ocre, pont des Herbes",
        """Solange : Avant la crue, le sentier était large.
Karim : Après la crue, on a posé des planches.
Aline : Pendant la pluie, personne n'est sorti. Dès l'aube, on a repris.
Léa : Lorsque le cahier est arrivé, tout le monde s'est tu.
Patrick : On a signé jusqu'à vingt heures. Depuis ce jour, on relit.
Marc : Quand Hawa a parlé, on a écouté. Ensuite Benoît a répété.
Rose : Après avoir tendu le tissu, Dieudonné s'est assis.
Joël : Avant de partir, Noura a compté les seaux.
Yvette : Jusqu'au pont, l'eau était claire. Puis elle a changé.""",
        tf_item=(
            "On a signé jusqu'à vingt heures.",
            True,
            "Patrick : limite de fin.",
        ),
        qcm_item=(
            "Que s'est-il passé dès l'aube ?",
            ["On a dormi", "On a repris", "On a fermé Radio Figuier", "On a vendu le figuier"],
            1,
            "Aline : « Dès l'aube, on a repris. »",
        ),
        pairs=[
            ("avant / après", "ordre"),
            ("pendant", "en même temps"),
            ("dès / lorsque / quand", "point de départ"),
            ("jusqu'à / depuis", "limite / continuité"),
        ],
        fill_item=("___ l'aube, on a repris.", "Dès"),
        words=["Lorsque", "le", "cahier", "est", "arrivé", "."],
        anagram=("planches", "On les a posées après la crue."),
        error=(
            "Dès que l'aube jusqu'à on a repris sans verbe juste.",
            "Dès l'aube, on a repris.",
            "Dès + moment : dès l'aube.",
        ),
        pic_start=8,
        pic_words=["une suite", "des flèches", "un calendrier", "un pont"],
        short_p="Notez huit marqueurs et le fait qu'ils introduisent.",
        audio="Enregistrez : Avant la crue. Après la crue. Pendant la pluie. Dès l'aube. Lorsque le cahier est arrivé.",
    ),
    _l(
        "CE",
        "CE — Chronologie du cahier",
        "Lire une chronologie dense en prépositions temporelles.",
        "Lisez la chronologie, sans aller trop vite.",
        "Feuille de Karim Bamba",
        """Cahier des racines — suite des faits
1. Avant mars, le figuier n'avait pas de tuteur.
2. Dès le 3 mars, on a planté deux piquets.
3. Pendant quatre jours, Dieudonné a lié le tissu.
4. Lorsque la pluie a cessé, Léa a mesuré l'eau.
5. On a veillé jusqu'au vendredi. Depuis le samedi, le niveau baisse.
6. Après la réunion, Solange a tamponné la page. Quand elle a tamponné, on a applaudi.
Seuil des Sources""",
        tf_item=(
            "Le tuteur existait déjà avant mars.",
            False,
            "« Avant mars, le figuier n'avait pas de tuteur. »",
        ),
        qcm_item=(
            "Combien de jours Dieudonné a-t-il lié le tissu ?",
            ["Deux", "Quatre", "Dix", "Un"],
            1,
            "« Pendant quatre jours. »",
        ),
        pairs=[
            ("avant mars", "pas de tuteur"),
            ("dès le 3 mars", "piquets"),
            ("pendant quatre jours", "tissu"),
            ("depuis le samedi", "niveau baisse"),
        ],
        fill_item=("On a veillé ___ vendredi.", "jusqu'au"),
        words=["Dès", "le", "3", "mars", "on", "a", "planté", "."],
        anagram=("tuteur", "Le figuier n'en avait pas avant mars."),
        error=(
            "Depuis le 3 mars on a planté et c'est fini le 3 au matin seulement.",
            "Dès le 3 mars, on a planté deux piquets.",
            "Dès = à partir de ce moment-là (démarrage).",
        ),
        pic_start=28,
        pic_words=["une rivière", "un soleil", "un récit", "trois temps"],
        short_p="Recopiez et reliez chaque date ou durée à son fait.",
        audio="Lisez les six points, sans aller trop vite.",
    ),
    _l(
        "PO",
        "PO — Enchaîner les faits",
        "Oraliser une suite avec avant, après, pendant, dès, lorsque, jusqu'à.",
        "Répétez, puis racontez trois jours d'engagement.",
        "Modèles d'Aline",
        """Avant la crue, le sentier était large.
Après la crue, on a posé des planches.
Pendant la pluie, on est restés.
Dès l'aube, on a repris.
Lorsque Hawa a parlé, on a écouté.
On a signé jusqu'à vingt heures.
Depuis ce jour, on relit.
Quand Solange a tamponné, on a applaudi.""",
        tf_item=(
            "« Lorsque » et « quand » peuvent introduire le même type de fait.",
            True,
            "Point dans la suite.",
        ),
        qcm_item=(
            "Quelle préposition marque la limite de fin ?",
            ["depuis", "dès", "jusqu'à", "avant"],
            2,
            "Jusqu'à vingt heures.",
        ),
        pairs=[
            ("avant", "plus tôt"),
            ("après", "plus tard"),
            ("dès", "à partir de"),
            ("jusqu'à", "fin"),
        ],
        fill_item=("___ ce jour, on relit.", "Depuis"),
        words=["Quand", "Hawa", "a", "parlé", "on", "a", "écouté", "."],
        anagram=("lorsque", "L'autre mot pour quand, plus posé."),
        error=(
            "Jusqu'à ce jour on relit encore maintenant sans depuis.",
            "Depuis ce jour, on relit.",
            "Continuité jusqu'à maintenant : depuis.",
        ),
        pic_start=12,
        pic_words=["une cause", "une affiche", "une main", "un arbre"],
        short_p="Écrivez une suite de huit faits avec huit marqueurs différents.",
        audio="Enregistrez les huit modèles, puis trois jours à vous.",
    ),
    _l(
        "PE",
        "PE — Ma suite de faits",
        "Écrire une chronologie avec prépositions et marqueurs temporels.",
        "Imitez la suite de Hawa.",
        "Suite de Hawa Diallo",
        """Hawa Diallo
Avant la réunion, j'ai lu la page.
Dès huit heures, on s'est assis sous le figuier.
Pendant une heure, chacun a parlé.
Lorsque Marc a proposé le nom, on a choisi Cahier des racines.
On a écrit jusqu'à midi. Depuis midi, le cahier circule.
Après la pause, j'ai porté le seau jusqu'au pont.
Hawa""",
        tf_item=(
            "Le cahier circule depuis midi.",
            True,
            "« Depuis midi, le cahier circule. »",
        ),
        qcm_item=(
            "Qui a proposé le nom ?",
            ["Léa", "Marc", "Karim", "Benoît"],
            1,
            "« Lorsque Marc a proposé le nom… »",
        ),
        pairs=[
            ("avant la réunion", "lire"),
            ("dès huit heures", "s'asseoir"),
            ("lorsque Marc a proposé", "choisir le nom"),
            ("jusqu'à midi", "écrire"),
        ],
        fill_item=("On a écrit ___ midi.", "jusqu'à"),
        words=["Dès", "huit", "heures", "on", "s'est", "assis", "."],
        anagram=("circule", "Depuis midi, le cahier… entre les mains."),
        error=(
            "Avant de la réunion, j'ai lu la page.",
            "Avant la réunion, j'ai lu la page.",
            "Avant + nom (sans de). Avant de + infinitif.",
        ),
        pic_start=16,
        pic_words=["la nature", "la préposition à", "la préposition de", "un seau"],
        short_p="Imitez : six lignes, six marqueurs temporels.",
        audio="Lisez votre suite, sans aller trop vite.",
    ),
    _l(
        "EL",
        "EL — Prépositions et marqueurs",
        "Retenir avant, après, pendant, depuis, jusqu'à, dès, lorsque, quand.",
        "Apprenez la fiche.",
        "Fiche de Solange",
        """avant + nom : avant la crue. avant de + infinitif : avant de partir
après + nom / après + infinitif : après la crue, après avoir signé
pendant + durée : pendant la pluie, pendant quatre jours
depuis + début (ça continue) : depuis samedi
jusqu'à + fin : jusqu'à vingt heures, jusqu'au pont (à + le = au)
dès + moment de départ : dès l'aube, dès le 3 mars
lorsque / quand + fait : Lorsque le cahier est arrivé…
Ensuite / puis / enfin enchaînent sans préposition : ensuite Benoît a répété.""",
        tf_item=(
            "On dit « avant de la réunion ».",
            False,
            "Avant + nom, sans de.",
        ),
        qcm_item=(
            "« Jusqu'à + le pont » donne…",
            ["jusqu'à le pont", "jusqu'au pont", "jusqu'aux pont", "jusque le pont"],
            1,
            "À + le = au.",
        ),
        pairs=[
            ("avant + nom", "sans de"),
            ("avant de", "infinitif"),
            ("depuis", "ça continue"),
            ("dès", "démarrage"),
        ],
        fill_item=("On a porté le seau ___ pont.", "jusqu'au"),
        words=["Pendant", "la", "pluie", "on", "est", "restés", "."],
        anagram=("demarrage", "Dès marque un… (sans accent)."),
        error=(
            "Avant de mars, le figuier n'avait pas de tuteur.",
            "Avant mars, le figuier n'avait pas de tuteur.",
            "Avant + nom de mois, sans de.",
        ),
        pic_start=20,
        pic_words=["de plus en plus", "de moins en moins", "un graphique", "un micro"],
        short_p="Rédigez huit mini-phrases, une par outil de la fiche.",
        audio="Enregistrez la fiche et huit exemples.",
    ),
]


# ---------------------------------------------------------------------------
# Séquence 4 — Une cause à défendre (cause et conséquence)
# ---------------------------------------------------------------------------

S4 = [
    _l(
        "CO",
        "CO — Pourquoi le cahier",
        "Repérer parce que, puisque, à cause de, donc, alors, c'est pourquoi.",
        "Lisez le dialogue. Qu'est-ce qui cause ? Qu'est-ce qui suit ?",
        "Réunion sous le figuier",
        """Aline : On écrit parce que l'eau recule trop vite.
Patrick : Puisque tout le monde a vu la crue, on peut signer.
Léa : À cause des sacs trop lourds, la berge s'est cassée.
Marc : La terre a glissé, donc on plante des tuteurs.
Hawa : Il n'y a plus d'ombre au milieu, alors on protège le figuier.
Joël : C'est pourquoi le cahier s'appelle Cahier des racines.
Rose : Grâce aux lampions, on a veillé sans peur. (cause positive)
Solange : Karim a tamponné, donc la page est officielle ici, au Seuil.
Lila : On n'a pas assez d'eau claire, c'est pourquoi on agit.""",
        tf_item=(
            "« Parce que » introduit une cause.",
            True,
            "On écrit parce que l'eau recule.",
        ),
        qcm_item=(
            "Quelle expression introduit une conséquence ?",
            ["parce que", "puisque", "à cause de", "c'est pourquoi"],
            3,
            "C'est pourquoi + conséquence.",
        ),
        pairs=[
            ("parce que / puisque", "cause + phrase"),
            ("à cause de", "cause + nom"),
            ("donc / alors", "conséquence"),
            ("c'est pourquoi", "conséquence soulignée"),
        ],
        fill_item=("La terre a glissé, ___ on plante des tuteurs.", "donc"),
        words=["On", "écrit", "parce", "que", "l'eau", "recule", "."],
        anagram=("berge", "Elle s'est cassée à cause des sacs."),
        error=(
            "On écrit à cause que l'eau recule.",
            "On écrit parce que l'eau recule trop vite.",
            "Pas à cause que : parce que + phrase, à cause de + nom.",
        ),
        pic_start=12,
        pic_words=["une cause", "une affiche", "une main", "un arbre"],
        short_p="Notez trois causes et trois conséquences du dialogue.",
        audio="Enregistrez : On écrit parce que l'eau recule. La terre a glissé, donc on plante. C'est pourquoi le cahier s'appelle ainsi.",
    ),
    _l(
        "CE",
        "CE — Appel du Cahier des racines",
        "Lire un appel qui enchaîne causes et conséquences.",
        "Lisez l'appel, sans aller trop vite.",
        "Affiche, tableau de la cour",
        """Appel — Cahier des racines
Signez, puisque vous habitez le Seuil.
On agit parce que le figuier a craqué et parce que la rivière s'ensable.
À cause des plastiques du chemin, les nénuphars du lac vont moins bien.
La berge est fragile, donc on refuse les sacs trop lourds près de l'eau.
Il reste peu d'ombre, alors on arrose le soir.
C'est pourquoi nous demandons deux tuteurs et un seau commun.
Merci. Aline, Marc, Rose — Rukiri-Nord""",
        tf_item=(
            "L'appel demande deux tuteurs et un seau commun.",
            True,
            "Dernière phrase de demande.",
        ),
        qcm_item=(
            "Pourquoi les nénuphars vont-ils moins bien ?",
            [
                "À cause de Radio Figuier",
                "À cause des plastiques du chemin",
                "Parce que Marc chante",
                "Puisque Yvette dort",
            ],
            1,
            "« À cause des plastiques du chemin. »",
        ),
        pairs=[
            ("puisque vous habitez", "cause connue"),
            ("parce que le figuier a craqué", "cause"),
            ("à cause des plastiques", "cause + nom"),
            ("c'est pourquoi nous demandons", "conséquence"),
        ],
        fill_item=("La berge est fragile, ___ on refuse les sacs trop lourds.", "donc"),
        words=["Signez", "puisque", "vous", "habitez", "le", "Seuil", "."],
        anagram=("tuteurs", "On en demande deux pour le figuier."),
        error=(
            "On agit à cause que le figuier a craqué.",
            "On agit parce que le figuier a craqué.",
            "Parce que + phrase.",
        ),
        pic_start=16,
        pic_words=["la nature", "la préposition à", "la préposition de", "un seau"],
        short_p="Soulignez les causes en ocre et les conséquences en vert.",
        audio="Lisez l'appel, sans aller trop vite.",
    ),
    _l(
        "PO",
        "PO — Dire la cause, la suite",
        "Enchaîner à voix haute une cause et une conséquence.",
        "Répétez, puis défendez une petite cause du Seuil.",
        "Modèles de Marc",
        """On écrit parce que l'eau recule.
Puisque tout le monde a vu, on signe.
À cause des sacs, la berge casse.
Donc on plante des tuteurs.
Alors on protège le figuier.
C'est pourquoi le cahier existe.
Grâce aux lampions, on a veillé.
Il reste peu d'ombre, alors on arrose.""",
        tf_item=(
            "« Grâce à » introduit une cause plutôt positive.",
            True,
            "Grâce aux lampions ≠ à cause des sacs.",
        ),
        qcm_item=(
            "Quelle forme demande un nom (pas une phrase) ?",
            ["parce que", "puisque", "à cause de", "c'est pourquoi"],
            2,
            "À cause de + nom.",
        ),
        pairs=[
            ("parce que", "cause nouvelle"),
            ("puisque", "cause déjà connue"),
            ("donc / alors", "conséquence simple"),
            ("c'est pourquoi", "conséquence forte"),
        ],
        fill_item=("___ aux lampions, on a veillé.", "Grâce"),
        words=["Alors", "on", "protège", "le", "figuier", "."],
        anagram=("puisque", "Cause déjà connue de tout le monde."),
        error=(
            "À cause de l'eau recule, on écrit.",
            "On écrit parce que l'eau recule.",
            "À cause de + nom. Parce que + phrase.",
        ),
        pic_start=24,
        pic_words=["un groupe", "une banderole", "des signatures", "des racines"],
        short_p="Écrivez six paires cause → conséquence, outils différents.",
        audio="Enregistrez les huit modèles, puis une cause à vous.",
    ),
    _l(
        "PE",
        "PE — Mon appel",
        "Écrire un court appel avec causes et conséquences.",
        "Imitez l'appel de Rose.",
        "Appel de Rose Iradukunda",
        """Rose Iradukunda
Je signe parce que le figuier m'a donné de l'ombre.
Puisque la rivière nous a sauvés l'été, on la défend.
À cause des plastiques, l'eau est moins claire.
La terre glisse, donc on pose deux tuteurs.
Alors on arrose le soir, près de la rive.
C'est pourquoi je porte le Cahier des racines jusqu'à la Table des Sources.
Rose""",
        tf_item=(
            "Rose porte le cahier jusqu'à la Table des Sources.",
            True,
            "Dernière phrase.",
        ),
        qcm_item=(
            "Quelle cause utilise à cause de ?",
            ["le figuier", "la rivière", "les plastiques", "les tuteurs"],
            2,
            "« À cause des plastiques. »",
        ),
        pairs=[
            ("parce que le figuier", "ombre"),
            ("puisque la rivière", "l'été"),
            ("à cause des plastiques", "eau moins claire"),
            ("c'est pourquoi", "porter le cahier"),
        ],
        fill_item=("La terre glisse, ___ on pose deux tuteurs.", "donc"),
        words=["Je", "signe", "parce", "que", "le", "figuier", "m'a", "donné", "de", "l'ombre", "."],
        anagram=("plastiques", "À cause d'eux, l'eau est moins claire."),
        error=(
            "Je signe à cause que le figuier donne de l'ombre.",
            "Je signe parce que le figuier m'a donné de l'ombre.",
            "Parce que + phrase. À cause que n'existe pas.",
        ),
        pic_start=2,
        pic_words=["un cahier", "une photo", "un souvenir", "une horloge"],
        short_p="Imitez : cinq lignes, trois causes, deux conséquences.",
        audio="Lisez votre appel, sans aller trop vite.",
    ),
    _l(
        "EL",
        "EL — Cause et conséquence",
        "Retenir parce que, puisque, à cause de, grâce à, donc, alors, c'est pourquoi.",
        "Apprenez la fiche.",
        "Fiche du carnet",
        """Cause + phrase : parce que (info nouvelle), puisque (info déjà partagée)
Cause + nom : à cause de (négatif ou neutre), grâce à (positif)
Conséquence : donc, alors, c'est pourquoi
Place : cause d'abord ou conséquence d'abord. C'est pourquoi souvent en tête de phrase.
Pas : à cause que. Pas : grâce que.
Donc se place souvent après une virgule : La terre a glissé, donc on plante.
Au Seuil : on écrit parce que l'eau recule ; c'est pourquoi le cahier existe.
Alors est plus parlé ; c'est pourquoi est plus posé, bon pour un appel.""",
        tf_item=(
            "« Puisque » présente souvent une cause que l'autre connaît déjà.",
            True,
            "Puisque vous habitez le Seuil…",
        ),
        qcm_item=(
            "Quelle paire est juste ?",
            [
                "à cause que + phrase",
                "à cause de + nom",
                "grâce que + nom",
                "parce de + nom",
            ],
            1,
            "À cause de + nom.",
        ),
        pairs=[
            ("parce que", "cause + phrase"),
            ("à cause de", "cause + nom"),
            ("grâce à", "cause positive"),
            ("c'est pourquoi", "conséquence"),
        ],
        fill_item=("Pas « à cause que » : on dit ___ que.", "parce"),
        words=["C'est", "pourquoi", "le", "cahier", "existe", "."],
        anagram=("consequence", "Donc, alors, c'est pourquoi : la… (sans accent)."),
        error=(
            "Grâce que les lampions, on a veillé.",
            "Grâce aux lampions, on a veillé.",
            "Grâce à + nom (à + les = aux).",
        ),
        pic_start=6,
        pic_words=["un banc", "une lettre", "une suite", "des flèches"],
        short_p="Transformez six phrases : cause ↔ conséquence, outils différents.",
        audio="Enregistrez la fiche et six exemples.",
    ),
]


# ---------------------------------------------------------------------------
# Séquence 5 — Agir pour la nature (adjectif + à / de)
# ---------------------------------------------------------------------------

S5 = [
    _l(
        "CO",
        "CO — Prêts à agir",
        "Repérer facile à, content de, prêt à, fier de, et d'autres adj. + à / de.",
        "Lisez le dialogue. Quel adjectif va avec à ? Lequel va avec de ?",
        "Rive de la petite rivière",
        """Aline : C'est facile à dire, plus difficile à faire.
Patrick : Je suis content de signer. Je suis prêt à porter les seaux.
Léa : Nous sommes fiers de ce figuier. Il est bon à protéger.
Marc : L'eau est difficile à filtrer. On est capables de patienter.
Hawa : Je suis heureuse de voir les nénuphars. Je suis sûre de revenir.
Joël : On est fatigués de ramasser les plastiques. Pourtant utiles à éviter.
Rose : Je suis ravie d'aider. Le sentier est long à réparer.
Dieudonné : Le tissu est simple à tendre. Je suis fier de le coudre ici.
Yvette : Soyez prêts à écouter Lila. Elle est certaine de la dose d'eau.""",
        tf_item=(
            "« Content » se construit avec de.",
            True,
            "Patrick : content de signer.",
        ),
        qcm_item=(
            "Quelle construction est correcte ?",
            ["prêt de porter", "prêt à porter", "fier à ce figuier", "facile de dire (sens « aisé »)"],
            1,
            "Prêt à + infinitif.",
        ),
        pairs=[
            ("facile à / difficile à", "infinitif"),
            ("content de / fier de", "nom ou infinitif"),
            ("prêt à", "action"),
            ("capable de", "pouvoir"),
        ],
        fill_item=("Je suis ___ à porter les seaux.", "prêt"),
        words=["Je", "suis", "content", "de", "signer", "."],
        anagram=("nénuphars", "Hawa est heureuse de les voir au lac."),
        error=(
            "Je suis prêt de porter les seaux.",
            "Je suis prêt à porter les seaux.",
            "Prêt à + infinitif.",
        ),
        pic_start=16,
        pic_words=["la nature", "la préposition à", "la préposition de", "un seau"],
        short_p="Classez huit adjectifs : + à ou + de.",
        audio="Enregistrez : C'est facile à dire. Je suis content de signer. Je suis prêt à porter. Nous sommes fiers de ce figuier.",
    ),
    _l(
        "CE",
        "CE — Mot d'action",
        "Lire un mot d'engagement avec adjectifs + à / de.",
        "Lisez le mot, sans aller trop vite.",
        "Mot de Lila Sow",
        """Amies, amis,
Le figuier est précieux à garder. L'eau est difficile à partager si on gaspille.
Soyez contents de peu : un seau, deux tuteurs.
Soyez prêts à venir à l'aube. Soyez fiers de vos signatures.
Le plastique est mauvais à laisser près de la rive.
Nous sommes heureux de vous lire. Nous sommes certains de tenir.
Le chemin est long à réparer, mais utile à marcher ensemble.
Lila — lac des Nénuphars / Seuil""",
        tf_item=(
            "Lila dit que le plastique est bon à laisser près de l'eau.",
            False,
            "« mauvais à laisser près de la rive. »",
        ),
        qcm_item=(
            "De quoi faut-il être fiers ?",
            ["Des sacs lourds", "Des signatures", "Du gaspillage", "De Radio seulement"],
            1,
            "« fiers de vos signatures. »",
        ),
        pairs=[
            ("précieux à", "garder"),
            ("contents de", "peu"),
            ("prêts à", "venir"),
            ("fiers de", "signatures"),
        ],
        fill_item=("Soyez prêts ___ venir à l'aube.", "à"),
        words=["Le", "chemin", "est", "long", "à", "réparer", "."],
        anagram=("signatures", "Il faut en être fiers, dans le cahier."),
        error=(
            "Soyez fiers à vos signatures.",
            "Soyez fiers de vos signatures.",
            "Fier de + nom.",
        ),
        pic_start=18,
        pic_words=["la préposition de", "un seau", "de plus en plus", "de moins en moins"],
        short_p="Recopiez et encadrez à / de après chaque adjectif.",
        audio="Lisez le mot de Lila, sans aller trop vite.",
    ),
    _l(
        "PO",
        "PO — Dire facile à, fier de",
        "Enchaîner des adjectifs + à ou + de à propos de la nature.",
        "Répétez, puis parlez d'un geste pour le figuier.",
        "Modèles de Léa",
        """C'est facile à dire.
C'est difficile à faire.
Je suis content de signer.
Je suis prêt à agir.
Nous sommes fiers de ce figuier.
Je suis capable de patienter.
Je suis fatigué de ramasser.
Je suis heureux de revenir.""",
        tf_item=(
            "« Fatigué » se construit avec de.",
            True,
            "Fatigué de + infinitif / nom.",
        ),
        qcm_item=(
            "Quelle phrase est correcte ?",
            [
                "Je suis capable à patienter",
                "Je suis capable de patienter",
                "Je suis prêt de agir",
                "C'est facile de dire (sens A2 retenu : à)",
            ],
            1,
            "Capable de.",
        ),
        pairs=[
            ("facile / difficile / long / prêt / utile", "+ à"),
            ("content / fier / capable / fatigué / heureux / sûr", "+ de"),
            ("prêt à", "avenir proche"),
            ("fier de", "fierté"),
        ],
        fill_item=("Nous sommes fiers ___ ce figuier.", "de"),
        words=["Je", "suis", "prêt", "à", "agir", "."],
        anagram=("patienter", "Marc dit qu'on est capables de… près de l'eau."),
        error=(
            "C'est difficile de faire, dans le sens « dur à réaliser » ici.",
            "C'est difficile à faire.",
            "Difficile à + infinitif (qualité de l'action).",
        ),
        pic_start=22,
        pic_words=["un graphique", "un micro", "un groupe", "une banderole"],
        short_p="Écrivez huit phrases : quatre + à, quatre + de.",
        audio="Enregistrez les huit modèles, puis deux phrases à vous.",
    ),
    _l(
        "PE",
        "PE — Mon mot pour la rive",
        "Écrire un mot d'action avec adjectifs + à / de.",
        "Imitez le mot de Patrick.",
        "Mot de Patrick Habimana",
        """Patrick Habimana
Je suis content de porter le seau.
Je suis prêt à revenir dès l'aube.
Le figuier est facile à aimer, plus difficile à sauver.
Nous sommes fiers de nos signatures.
Je suis capable de parler sans crier.
Le plastique est mauvais à jeter ici.
Patrick
Petite rivière — Seuil des Sources""",
        tf_item=(
            "Patrick est prêt à revenir dès l'aube.",
            True,
            "Deuxième ligne.",
        ),
        qcm_item=(
            "Qu'est-ce qui est difficile à sauver ?",
            ["Le seau", "Le figuier", "Radio Figuier", "Le Bureau"],
            1,
            "« plus difficile à sauver. »",
        ),
        pairs=[
            ("content de", "porter"),
            ("prêt à", "revenir"),
            ("fiers de", "signatures"),
            ("mauvais à", "jeter"),
        ],
        fill_item=("Je suis capable ___ parler sans crier.", "de"),
        words=["Je", "suis", "content", "de", "porter", "le", "seau", "."],
        anagram=("sauver", "Le figuier est plus difficile à…"),
        error=(
            "Je suis prêt de revenir dès l'aube.",
            "Je suis prêt à revenir dès l'aube.",
            "Prêt à.",
        ),
        pic_start=26,
        pic_words=["des signatures", "des racines", "une rivière", "un soleil"],
        short_p="Imitez : six lignes, trois + à, trois + de.",
        audio="Lisez votre mot, sans aller trop vite.",
    ),
    _l(
        "EL",
        "EL — Adjectif + à / de",
        "Retenir facile à, content de, prêt à, fier de et les listes A2.",
        "Apprenez la fiche.",
        "Fiche d'Aline",
        """+ à + infinitif : facile à, difficile à, long à, dur à, bon à, mauvais à, utile à, prêt à, précieux à
+ de + nom ou infinitif : content de, heureux de, ravi de, fier de, sûr de, certain de, capable de, fatigué de
Sens : à souvent « pour faire / vis-à-vis de l'action ». de souvent « à propos de / source du sentiment ».
Attention : prêt à (pas prêt de). fier de (pas fier à). capable de.
facile à dire ≠ je suis facile (la personne).
Exemples rive : prêt à porter les seaux ; fier de ce figuier ; content de signer.
Difficile à filtrer. Utile à marcher ensemble. Fatigué de ramasser les plastiques.
On retient ces listes pour Agir pour la nature, pas d'autres prépositions au hasard.""",
        tf_item=(
            "On dit « fier à » devant un nom.",
            False,
            "Fier de.",
        ),
        qcm_item=(
            "« Utile » se construit souvent avec…",
            ["de + infinitif", "à + infinitif", "sur + infinitif", "en + infinitif"],
            1,
            "Utile à marcher / utile à + inf.",
        ),
        pairs=[
            ("prêt", "à"),
            ("fier", "de"),
            ("facile", "à"),
            ("content", "de"),
        ],
        fill_item=("C'est utile ___ marcher ensemble.", "à"),
        words=["Je", "suis", "sûr", "de", "revenir", "."],
        anagram=("sentiment", "Content, fier, heureux : un… + de."),
        error=(
            "Nous sommes capables à patienter.",
            "Nous sommes capables de patienter.",
            "Capable de.",
        ),
        pic_start=10,
        pic_words=["un calendrier", "un pont", "une cause", "une affiche"],
        short_p="Tableau : dix adjectifs, préposition, un exemple nature.",
        audio="Enregistrez la fiche et dix exemples.",
    ),
]


# ---------------------------------------------------------------------------
# Séquence 6 — Donner son avis (de plus en plus / de moins en moins)
# ---------------------------------------------------------------------------

S6 = [
    _l(
        "CO",
        "CO — Autour du micro",
        "Repérer de plus en plus et de moins en moins (adjectif, adverbe, de + nom).",
        "Lisez le dialogue. Qu'est-ce qui augmente ? Qu'est-ce qui diminue ?",
        "Micro de la cour, avis croisés",
        """Marc : L'eau est de moins en moins claire. C'est visible.
Léa : Il y a de plus en plus de plastiques près du pont.
Aline : On est de plus en plus nombreux à signer. Tant mieux.
Patrick : Le figuier donne de moins en moins d'ombre au milieu.
Hawa : Je suis de plus en plus inquiète, et de moins en moins patiente.
Joël : On parle de plus en plus fort. On devrait parler plus doucement.
Rose : Il y a de moins en moins d'oiseaux le matin.
Solange : Les pages sont de plus en plus pleines. Le cahier avance.
Kévin : Moi, je suis de moins en moins d'accord avec les sacs lourds.""",
        tf_item=(
            "Léa voit de plus en plus de plastiques.",
            True,
            "De plus en plus de + nom.",
        ),
        qcm_item=(
            "Que dit Patrick du figuier ?",
            [
                "De plus en plus d'ombre",
                "De moins en moins d'ombre au milieu",
                "Plus d'oiseaux",
                "Moins de signatures",
            ],
            1,
            "« de moins en moins d'ombre »",
        ),
        pairs=[
            ("de plus en plus + adj.", "inquiète / nombreux / pleines"),
            ("de moins en moins + adj.", "claire / patiente"),
            ("de plus en plus de + nom", "plastiques"),
            ("de moins en moins de + nom", "oiseaux / ombre"),
        ],
        fill_item=("L'eau est de moins en moins ___.", "claire"),
        words=["Il", "y", "a", "de", "plus", "en", "plus", "de", "plastiques", "."],
        anagram=("plastiques", "Léa en voit de plus en plus près du pont."),
        error=(
            "Il y a de plus en plus plastiques près du pont.",
            "Il y a de plus en plus de plastiques près du pont.",
            "Devant un nom : de plus en plus de.",
        ),
        pic_start=20,
        pic_words=["de plus en plus", "de moins en moins", "un graphique", "un micro"],
        short_p="Notez quatre « plus » et quatre « moins » avec ce qui change.",
        audio="Enregistrez : L'eau est de moins en moins claire. Il y a de plus en plus de plastiques. On est de plus en plus nombreux.",
    ),
    _l(
        "CE",
        "CE — Avis affichés",
        "Lire des avis qui utilisent de plus en plus / de moins en moins.",
        "Lisez les avis, sans aller trop vite.",
        "Tableau de la cour, bandelettes",
        """Avis 1 — Aline : On est de plus en plus attentifs à la rive.
Avis 2 — Patrick : Il y a de moins en moins d'eau en août.
Avis 3 — Rose : Les enfants sont de plus en plus curieux du cahier.
Avis 4 — Joël : Je marche de moins en moins vite près des nids.
Avis 5 — Hawa : De plus en plus de signatures, de moins en moins de doutes.
Avis 6 — Marc : Le soir, on discute de plus en plus longtemps.
Avis 7 — Solange : Les pages sont de plus en plus pleines.
Règle : adj. / adv. sans de ; nom avec de (d' devant voyelle).""",
        tf_item=(
            "Patrick parle d'une baisse d'eau en août.",
            True,
            "« de moins en moins d'eau en août. »",
        ),
        qcm_item=(
            "Qui marche de moins en moins vite ?",
            ["Aline", "Rose", "Joël", "Marc"],
            2,
            "Avis 4.",
        ),
        pairs=[
            ("de plus en plus attentifs", "Aline"),
            ("de moins en moins d'eau", "Patrick"),
            ("de plus en plus curieux", "Rose"),
            ("de plus en plus longtemps", "Marc"),
        ],
        fill_item=("De plus en plus ___ signatures.", "de"),
        words=["On", "discute", "de", "plus", "en", "plus", "longtemps", "."],
        anagram=("curieux", "Les enfants le sont de plus en plus, devant le cahier."),
        error=(
            "Il y a de moins en moins eau en août.",
            "Il y a de moins en moins d'eau en août.",
            "De + nom ; d' devant voyelle.",
        ),
        pic_start=0,
        pic_words=["un récit", "trois temps", "un cahier", "une photo"],
        short_p="Recopiez deux avis et ajoutez le vôtre avec plus et moins.",
        audio="Lisez les six avis, sans aller trop vite.",
    ),
    _l(
        "PO",
        "PO — Dire plus, dire moins",
        "Donner un avis avec de plus en plus / de moins en moins.",
        "Répétez, puis donnez votre avis sur la rive.",
        "Modèles d'Aline",
        """C'est de plus en plus clair.
C'est de moins en moins simple.
Il y a de plus en plus de monde.
Il y a de moins en moins d'ombre.
Je suis de plus en plus convaincue.
On parle de moins en moins fort.
Les pages sont de plus en plus pleines.
Je suis de moins en moins d'accord.""",
        tf_item=(
            "Devant un adjectif, on n'ajoute pas de.",
            True,
            "De plus en plus clair (pas de clair).",
        ),
        qcm_item=(
            "Quelle phrase est correcte ?",
            [
                "de plus en plus de clair",
                "de plus en plus clair",
                "de plus en plus clairs de",
                "plus en plus de clair",
            ],
            1,
            "Adjectif : sans de.",
        ),
        pairs=[
            ("+ adjectif", "sans de"),
            ("+ adverbe", "sans de"),
            ("+ nom", "de / d'"),
            ("être d'accord", "de moins en moins d'accord"),
        ],
        fill_item=("Il y a de moins en moins ___ ombre.", "d'"),
        words=["Je", "suis", "de", "plus", "en", "plus", "convaincue", "."],
        anagram=("convaincue", "Aline l'est de plus en plus, au féminin."),
        error=(
            "Il y a de plus en plus monde sous le figuier.",
            "Il y a de plus en plus de monde.",
            "Nom : de plus en plus de.",
        ),
        pic_start=8,
        pic_words=["une suite", "des flèches", "un calendrier", "un pont"],
        short_p="Écrivez huit avis : quatre plus, quatre moins, noms et adjectifs.",
        audio="Enregistrez les huit modèles, puis trois avis à vous.",
    ),
    _l(
        "PE",
        "PE — Mon avis",
        "Écrire un avis structuré avec de plus en plus / de moins en moins.",
        "Imitez l'avis de Léa.",
        "Avis de Léa Niyonzima",
        """Léa Niyonzima
Je trouve l'eau de moins en moins claire près du pont.
Il y a de plus en plus de signatures, et de moins en moins de doutes.
Nous sommes de plus en plus prêts à agir à l'aube.
Le figuier donne de moins en moins d'ombre au milieu, donc on arrose.
Je suis de plus en plus fière du Cahier des racines.
Léa
Seuil des Sources""",
        tf_item=(
            "Léa a de plus en plus de doutes.",
            False,
            "« de moins en moins de doutes. »",
        ),
        qcm_item=(
            "De quoi Léa est-elle de plus en plus fière ?",
            ["Des sacs", "Du Cahier des racines", "De Radio seulement", "De Val-des-Peupliers"],
            1,
            "Dernière phrase avant la signature.",
        ),
        pairs=[
            ("de moins en moins claire", "eau"),
            ("de plus en plus de signatures", "cahier"),
            ("de plus en plus prêts", "agir"),
            ("de plus en plus fière", "Léa"),
        ],
        fill_item=("Je suis de plus en plus ___ du Cahier des racines.", "fière"),
        words=["Il", "y", "a", "de", "moins", "en", "moins", "de", "doutes", "."],
        anagram=("doutes", "Il y en a de moins en moins, d'après Léa."),
        error=(
            "Il y a de plus en plus signatures dans le cahier.",
            "Il y a de plus en plus de signatures.",
            "Devant un nom : de.",
        ),
        pic_start=14,
        pic_words=["une main", "un arbre", "la nature", "la préposition à"],
        short_p="Imitez : cinq lignes, plus et moins, un nom et un adjectif au moins.",
        audio="Lisez votre avis, sans aller trop vite.",
    ),
    _l(
        "EL",
        "EL — De plus en plus, de moins en moins",
        "Retenir les trois constructions : adjectif, adverbe, de + nom.",
        "Apprenez la fiche.",
        "Fiche de Marc",
        """de plus en plus + adjectif : de plus en plus clair / nombreux / fière
de moins en moins + adjectif : de moins en moins simple / patiente
+ adverbe : de plus en plus longtemps ; de moins en moins vite / fort
+ nom : de plus en plus de signatures ; de moins en moins d'eau (d' + voyelle)
Accord de l'adjectif : on est de plus en plus nombreux ; je suis de plus en plus fière.
On ne dit pas : de plus en plus de clair. On ne dit pas : de plus en plus signatures.
Sous le figuier : de plus en plus de signatures ; de moins en moins d'ombre au milieu.
Je suis de moins en moins d'accord avec les sacs trop lourds.""",
        tf_item=(
            "Devant un nom, il faut de (ou d').",
            True,
            "De plus en plus de monde.",
        ),
        qcm_item=(
            "« De moins en moins d'eau » : pourquoi d' ?",
            ["parce que moins est féminin", "devant une voyelle", "parce que c'est un verbe", "par hasard"],
            1,
            "De + eau → d'eau.",
        ),
        pairs=[
            ("+ adj.", "sans de"),
            ("+ adv.", "sans de"),
            ("+ nom", "de / d'"),
            ("accord", "avec le sujet de l'adjectif"),
        ],
        fill_item=("On parle de moins en moins ___. (intensité)", "fort"),
        words=["Les", "pages", "sont", "de", "plus", "en", "plus", "pleines", "."],
        anagram=("nombreux", "On est de plus en plus… à signer."),
        error=(
            "Je suis de plus en plus fier, Léa, au féminin.",
            "Je suis de plus en plus fière.",
            "Accord : fière avec Léa.",
        ),
        pic_start=4,
        pic_words=["un souvenir", "une horloge", "un banc", "une lettre"],
        short_p="Écrivez neuf phrases : trois adj., trois adv., trois noms.",
        audio="Enregistrez la fiche et neuf exemples.",
    ),
]


SEQUENCES = [
    {"title": "Un récit à comprendre", "lessons": S1},
    {"title": "Un souvenir à raconter", "lessons": S2},
    {"title": "Une suite de faits", "lessons": S3},
    {"title": "Une cause à défendre", "lessons": S4},
    {"title": "Agir pour la nature", "lessons": S5},
    {"title": "Donner son avis", "lessons": S6},
]
