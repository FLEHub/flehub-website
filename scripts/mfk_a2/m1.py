"""A2 Module 1 — Escale en France (univers Seuil des Sources)."""

from factory import L

IMG = "mfk-a2-m1"
IMG_DIR = IMG

MODULE = {
    "title": "A2 — Escale en France",
    "description": (
        "Grande étape A2-1 : comparer des séjours, faire des démarches, "
        "organiser un déplacement, trouver un logement, situer un lieu "
        "et suivre un itinéraire — sous le figuier du Seuil des Sources "
        "(Rukiri-Nord), avec une escale inventée à Val-des-Peupliers."
    ),
}


def _l(comp, title, obj, cons, st, sp, **kw):
    return L(IMG, comp, title, obj, cons, st, sp, **kw)


# ---------------------------------------------------------------------------
# Séquence 1 — Comparer des séjours (comparatifs)
# ---------------------------------------------------------------------------

S1 = [
    _l(
        "CO",
        "CO — Deux séjours sous le figuier",
        "Comprendre une comparaison de séjours : plus… que, moins… que, aussi… que.",
        "Lisez le dialogue (à écouter avec l'enseignant). Qui compare quoi ?",
        "Banc du Seuil, carnet de Léa",
        """Léa : Mon séjour à Mwezi-Haut était plus calme que celui de Patrick.
Patrick : C'est vrai. Le mien était moins calme, mais plus vivant.
Aline : Le stage à Val-des-Peupliers est aussi long que celui de l'an dernier.
Marc : L'Auberge des Figues est plus proche que la Maison des Vents.
Hawa : Moi, je trouve le lac des Nénuphars moins cher que Port de la Brise.
Joël : Le minibus Figuier 7 est aussi pratique que la Moto-Figuier.""",
        tf_item=(
            "Léa dit que Mwezi-Haut était plus calme que le séjour de Patrick.",
            True,
            "Léa : « plus calme que celui de Patrick. »",
        ),
        qcm_item=(
            "Selon Marc, quel lieu est plus proche ?",
            [
                "La Maison des Vents",
                "L'Auberge des Figues",
                "Port de la Brise",
                "Le Bureau des Escales",
            ],
            1,
            "Marc : « L'Auberge des Figues est plus proche que la Maison des Vents. »",
        ),
        pairs=[
            ("plus calme que", "Léa / Mwezi-Haut"),
            ("moins calme", "Patrick"),
            ("aussi long que", "Aline / le stage"),
            ("moins cher que", "Hawa / le lac"),
        ],
        fill_item=("Le stage est ___ long que celui de l'an dernier.", "aussi"),
        words=["L'Auberge", "est", "plus", "proche", "que", "la", "Maison", "."],
        anagram=("calme", "Un séjour sans bruit, plus… que l'autre."),
        error=(
            "Le lac est plus cher que Port de la Brise, d'après Hawa.",
            "Le lac est moins cher que Port de la Brise, d'après Hawa.",
            "Hawa dit moins cher, pas plus cher.",
        ),
        pic_start=0,
        pic_words=["comparer", "une valise", "un billet", "une carte"],
        short_p="Notez trois comparaisons entendues (plus / moins / aussi).",
        audio="Enregistrez : Mon séjour était plus calme. Le tien était moins cher. Le stage est aussi long.",
    ),
    _l(
        "CE",
        "CE — Fiches de comparaison",
        "Lire des fiches qui comparent deux séjours.",
        "Lisez les fiches épinglées au figuier, sans aller trop vite.",
        "Tableau ocre, Salle des Herbes",
        """Fiche Léa — Mwezi-Haut : plus haut, moins bruyant, aussi vert que le Seuil.
Fiche Patrick — Val-des-Peupliers : plus de cours, moins de silence, aussi loin que Port de la Brise.
Fiche Rose — Île de Sable-Rouge : plus chaude que Rive d'Orage, moins chère que l'Auberge.
Fiche Solange Mukamana — Bureau des Escales : les dossiers sont plus clairs que l'an dernier.
Règle : plus + adj + que / moins + adj + que / aussi + adj + que.""",
        tf_item=(
            "Rose écrit que l'île est moins chère que l'Auberge.",
            True,
            "Fiche Rose : « moins chère que l'Auberge. »",
        ),
        qcm_item=(
            "Qui parle de dossiers plus clairs ?",
            ["Léa", "Patrick", "Rose", "Solange"],
            3,
            "Fiche Solange, Bureau des Escales.",
        ),
        pairs=[
            ("plus haut", "Léa"),
            ("plus de cours", "Patrick"),
            ("plus chaude", "Rose"),
            ("plus clairs", "Solange"),
        ],
        fill_item=("Mwezi-Haut est ___ bruyant que la ville.", "moins"),
        words=["Val-des-Peupliers", "est", "aussi", "loin", "que", "Port", "."],
        anagram=("moins", "Le contraire de plus, devant un adjectif."),
        error=(
            "L'île est plus chère que l'Auberge, écrit Rose.",
            "L'île est moins chère que l'Auberge, écrit Rose.",
            "Rose écrit moins chère.",
        ),
        pic_start=4,
        pic_words=["un bureau", "un formulaire", "une enveloppe", "une affiche"],
        short_p="Recopiez une fiche et ajoutez une comparaison à vous.",
        audio="Lisez les quatre fiches à voix haute, sans aller trop vite.",
    ),
    _l(
        "PO",
        "PO — Dire plus, moins, aussi",
        "Comparer deux lieux ou deux séjours à voix haute.",
        "Répétez les modèles, puis comparez deux lieux du Seuil.",
        "Modèles d'Aline",
        """Le Seuil est plus calme que le marché.
Le marché est moins calme que le Seuil.
La Table des Sources est aussi ouverte que l'infirmerie.
Mon sac est plus léger que celui de Marc.
Ta chambre sera moins chère que l'auberge.
Ce stage est aussi utile que le précédent.""",
        tf_item=(
            "« Aussi » sert à dire que deux choses sont égales.",
            True,
            "Aussi + adjectif + que = égalité.",
        ),
        qcm_item=(
            "Quelle phrase marque une égalité ?",
            [
                "plus calme que",
                "moins cher que",
                "aussi utile que",
                "meilleur que",
            ],
            2,
            "Aussi + adjectif + que.",
        ),
        pairs=[
            ("plus… que", "supériorité"),
            ("moins… que", "infériorité"),
            ("aussi… que", "égalité"),
            ("celui de Marc", "le sac de Marc"),
        ],
        fill_item=("La Table est ___ ouverte que l'infirmerie.", "aussi"),
        words=["Mon", "sac", "est", "plus", "léger", "que", "le", "tien", "."],
        anagram=("aussi", "Pour dire une égalité : … grand que."),
        error=(
            "Le Seuil est plus calme que le marché n'est.",
            "Le Seuil est plus calme que le marché.",
            "Après que, on reprend le nom, sans n'est ici.",
        ),
        pic_start=8,
        pic_words=["un minibus", "un sac", "un horaire", "un plan"],
        short_p="Écrivez six comparaisons : deux plus, deux moins, deux aussi.",
        audio="Enregistrez les six modèles, puis deux comparaisons à vous.",
    ),
    _l(
        "PE",
        "PE — Ma fiche de séjour",
        "Écrire une courte fiche qui compare deux séjours.",
        "Imitez la fiche de Patrick.",
        "Fiche de Patrick, Cahier du chemin",
        """Patrick Habimana
Mon séjour à Val-des-Peupliers sera plus long que celui de Léa.
Il sera moins cher que l'Auberge des Figues.
Les cours seront aussi denses que ceux d'Aline.
Je prendrai un sac plus léger que l'an dernier.
Patrick
Seuil des Sources — Rukiri-Nord""",
        tf_item=(
            "Patrick écrit que son séjour sera plus court que celui de Léa.",
            False,
            "« sera plus long que celui de Léa. »",
        ),
        qcm_item=(
            "Que compare Patrick avec l'Auberge ?",
            ["La durée", "Le prix", "La couleur", "Le silence"],
            1,
            "« moins cher que l'Auberge ».",
        ),
        pairs=[
            ("plus long", "Léa"),
            ("moins cher", "l'Auberge"),
            ("aussi denses", "les cours d'Aline"),
            ("plus léger", "le sac"),
        ],
        fill_item=("Les cours seront ___ denses que ceux d'Aline.", "aussi"),
        words=["Il", "sera", "moins", "cher", "que", "l'Auberge", "."],
        anagram=("leger", "Plus… que l'an dernier : un sac qui pèse peu. (sans accent)"),
        error=(
            "Mon séjour sera plus longue que celui de Léa.",
            "Mon séjour sera plus long que celui de Léa.",
            "Séjour est masculin : long, pas longue.",
        ),
        pic_start=12,
        pic_words=["une annonce", "une clé", "une règle", "une fenêtre"],
        short_p="Imitez : cinq lignes, trois comparatifs différents.",
        audio="Lisez votre fiche, une phrase, une pause, sans aller trop vite.",
    ),
    _l(
        "EL",
        "EL — Plus, moins, aussi",
        "Retenir la forme des comparatifs d'égalité et d'inégalité.",
        "Apprenez la fiche.",
        "Fiche du carnet",
        """plus + adjectif + que : plus calme que
moins + adjectif + que : moins cher que
aussi + adjectif + que : aussi long que
Accord : un séjour plus long / une auberge plus proche / des cours plus denses
celui / celle / ceux / celles pour éviter de répéter : celui de Patrick
Attention : bon → meilleur (pas plus bon). Petit → plus petit (ou moindre, rare).
Ne pas dire : plus bien. On dit mieux.""",
        tf_item=(
            "On dit « plus bon » pour comparer deux plats.",
            False,
            "On dit meilleur, pas plus bon.",
        ),
        qcm_item=(
            "Quelle forme est correcte ?",
            ["plus bien", "mieux", "plus bonnement", "aussi bien que pas"],
            1,
            "Mieux remplace plus bien.",
        ),
        pairs=[
            ("plus… que", "supériorité"),
            ("moins… que", "infériorité"),
            ("aussi… que", "égalité"),
            ("meilleur", "comparatif de bon"),
        ],
        fill_item=("Ce thé est ___ que l'autre. (bon)", "meilleur"),
        words=["Cette", "chambre", "est", "plus", "proche", "que", "l'autre", "."],
        anagram=("meilleur", "Le comparatif de bon, pas « plus bon »."),
        error=(
            "Ce stage est plus bon que l'autre.",
            "Ce stage est meilleur que l'autre.",
            "Bon → meilleur.",
        ),
        pic_start=16,
        pic_words=["une maison", "un jardin", "un escalier", "un banc"],
        short_p="Conjuguez cinq adjectifs au comparatif (plus / moins / aussi / meilleur).",
        audio="Enregistrez la fiche, puis trois exemples à vous.",
    ),
]


# ---------------------------------------------------------------------------
# Séquence 2 — Premières démarches (y / en)
# ---------------------------------------------------------------------------

S2 = [
    _l(
        "CO",
        "CO — Au Bureau des Escales",
        "Repérer les pronoms y et en dans des démarches.",
        "Lisez le dialogue. Où va-t-on ? De quoi parle-t-on ?",
        "Guichet de Solange Mukamana",
        """Solange : Vous avez les papiers ? J'y pense depuis hier.
Léa : Oui. J'en ai trois : une photo, une lettre, un tampon.
Patrick : On y va demain matin, au Bureau des Escales.
Aline : N'y allez pas trop tard. On y reste une heure.
Marc : J'en parle à Radio Figuier ce soir.
Hawa : Moi, j'en prends une copie. J'y retourne jeudi.""",
        tf_item=(
            "Léa a trois papiers.",
            True,
            "Léa : « J'en ai trois. »",
        ),
        qcm_item=(
            "Que remplace « y » dans « On y va demain » ?",
            ["Les papiers", "Le Bureau des Escales", "Radio Figuier", "La copie"],
            1,
            "Y = au Bureau des Escales (lieu).",
        ),
        pairs=[
            ("j'y pense", "à la démarche"),
            ("j'en ai trois", "des papiers"),
            ("on y va", "au bureau"),
            ("j'en parle", "de la démarche"),
        ],
        fill_item=("N'___ allez pas trop tard.", "y"),
        words=["J'en", "prends", "une", "copie", "."],
        anagram=("pense", "J'y… depuis hier : avoir dans la tête."),
        error=(
            "J'y ai trois papiers.",
            "J'en ai trois papiers.",
            "En remplace de + nom (des papiers).",
        ),
        pic_start=4,
        pic_words=["un bureau", "un formulaire", "une enveloppe", "une affiche"],
        short_p="Notez deux phrases avec y et deux avec en.",
        audio="Enregistrez : J'y pense. J'en ai trois. On y va demain. J'en parle ce soir.",
    ),
    _l(
        "CE",
        "CE — Mot du bureau",
        "Lire un mot officiel qui utilise y et en.",
        "Lisez le mot, sans aller trop vite.",
        "Mot de Solange, tampon ocre",
        """Bureau des Escales — Val-des-Peupliers (ville inventée)
Chers voyageurs du Seuil,
Pensez-y avant jeudi. Apportez-en deux copies.
On y reçoit le matin seulement.
N'en parlez pas trop vite autour de vous : les places sont limitées.
Vous y trouverez Karim Bamba, au deuxième bureau.
Solange Mukamana""",
        tf_item=(
            "On reçoit toute la journée au bureau.",
            False,
            "« On y reçoit le matin seulement. »",
        ),
        qcm_item=(
            "Qui se trouve au deuxième bureau ?",
            ["Aline", "Karim Bamba", "Joël", "Rose"],
            1,
            "« Vous y trouverez Karim Bamba. »",
        ),
        pairs=[
            ("pensez-y", "à la démarche"),
            ("apportez-en", "des copies"),
            ("on y reçoit", "au bureau"),
            ("n'en parlez pas", "de l'offre"),
        ],
        fill_item=("Apportez-___ deux copies.", "en"),
        words=["On", "y", "reçoit", "le", "matin", "seulement", "."],
        anagram=("copies", "Il en faut deux, pour le dossier."),
        error=(
            "Pensez-en avant jeudi.",
            "Pensez-y avant jeudi.",
            "Penser à → y.",
        ),
        pic_start=1,
        pic_words=["une valise", "un billet", "une carte", "un bureau"],
        short_p="Recopiez le mot et soulignez y et en.",
        audio="Lisez le mot de Solange, sans aller trop vite.",
    ),
    _l(
        "PO",
        "PO — Dire y et en",
        "Remplacer un lieu ou une quantité par y ou en.",
        "Répétez, puis parlez d'une démarche à vous.",
        "Modèles de Patrick",
        """J'y vais demain.
Tu y penses ?
Nous en parlons ce soir.
J'en ai assez.
N'y restez pas trop longtemps.
Elle en prend deux.""",
        tf_item=(
            "« Y » remplace souvent un lieu introduit par à, chez, dans.",
            True,
            "Aller à / penser à → y.",
        ),
        qcm_item=(
            "Quelle phrase utilise en pour une quantité ?",
            ["J'y vais", "Tu y penses", "J'en ai assez", "N'y restez pas"],
            2,
            "En = de cela / une quantité.",
        ),
        pairs=[
            ("y", "à ce lieu / à cela"),
            ("en", "de cela / une quantité"),
            ("j'y vais", "au bureau"),
            ("j'en ai", "des copies"),
        ],
        fill_item=("Nous ___ parlons ce soir.", "en"),
        words=["N'y", "restez", "pas", "trop", "longtemps", "."],
        anagram=("assez", "J'en ai… : la quantité suffit."),
        error=(
            "Je vais y demain au bureau.",
            "J'y vais demain au bureau.",
            "Y se place avant le verbe conjugué.",
        ),
        pic_start=20,
        pic_words=["un panneau", "une flèche", "un carnet", "un pont"],
        short_p="Écrivez quatre phrases : deux y, deux en.",
        audio="Enregistrez les six modèles, puis deux phrases à vous.",
    ),
    _l(
        "PE",
        "PE — Ma liste de démarches",
        "Écrire une liste de démarches avec y et en.",
        "Imitez la liste de Léa.",
        "Liste de Léa, enveloppe ocre",
        """Léa Niyonzima
J'y vais lundi, au Bureau des Escales.
J'en apporte deux photos.
J'y pense chaque soir.
J'en parle à Aline.
N'oubliez pas le tampon.
Léa""",
        tf_item=(
            "Léa apporte deux photos.",
            True,
            "« J'en apporte deux photos. »",
        ),
        qcm_item=(
            "À qui Léa en parle-t-elle ?",
            ["Marc", "Aline", "Karim", "Hawa"],
            1,
            "« J'en parle à Aline. »",
        ),
        pairs=[
            ("j'y vais", "lundi"),
            ("j'en apporte", "photos"),
            ("j'y pense", "chaque soir"),
            ("j'en parle", "Aline"),
        ],
        fill_item=("J'___ apporte deux photos.", "en"),
        words=["J'y", "pense", "chaque", "soir", "."],
        anagram=("tampon", "Il ne faut pas l'oublier sur le dossier."),
        error=(
            "N'en oubliez pas le tampon au bureau.",
            "N'oubliez pas le tampon au bureau.",
            "Oublier quelque chose : n'oubliez pas (pas n'en oubliez pas ici).",
        ),
        pic_start=24,
        pic_words=["une radio", "une table", "un cahier", "une horloge"],
        short_p="Imitez : cinq lignes avec y et en.",
        audio="Lisez votre liste, sans aller trop vite.",
    ),
    _l(
        "EL",
        "EL — Pronoms y et en",
        "Retenir la place et le sens de y et en.",
        "Apprenez la fiche.",
        "Fiche d'Aline",
        """Y remplace : à + lieu / à + chose (penser à, aller à, rester à).
En remplace : de + nom / une quantité (parler de, avoir de, prendre de).
Place : y / en avant le verbe : j'y vais, j'en parle.
À l'impératif affirmatif : vas-y, prends-en. Négatif : n'y va pas, n'en prends pas.
Attention : j'y (élision). Pas : je y.
Ne pas confondre : j'en ai (quantité) / j'y suis (lieu).""",
        tf_item=(
            "On écrit « je y vais ».",
            False,
            "Élision : j'y vais.",
        ),
        qcm_item=(
            "« Parler de la démarche » se remplace par…",
            ["y parler", "en parler", "le parler", "lui parler"],
            1,
            "Parler de → en parler.",
        ),
        pairs=[
            ("aller à", "y aller"),
            ("penser à", "y penser"),
            ("parler de", "en parler"),
            ("avoir des copies", "en avoir"),
        ],
        fill_item=("___-y ! (impératif de aller, tu)", "Vas"),
        words=["N'en", "prends", "pas", "trop", "."],
        anagram=("endroit", "Y remplace souvent un… (un lieu)."),
        error=(
            "Je y pense depuis hier.",
            "J'y pense depuis hier.",
            "Élision : j'y.",
        ),
        pic_start=26,
        pic_words=["un cahier", "une horloge", "un nuage", "un soleil"],
        short_p="Transformez : Je vais au bureau. / J'ai deux photos. / Je parle de cela.",
        audio="Enregistrez la fiche et trois transformations.",
    ),
]


# ---------------------------------------------------------------------------
# Séquence 3 — Organiser un déplacement (COD / COI, synthèse)
# ---------------------------------------------------------------------------

S3 = [
    _l(
        "CO",
        "CO — Qui prépare le trajet",
        "Comprendre qui / à qui on donne, on dit, on montre (COD / COI).",
        "Lisez le dialogue. Qui fait quoi à qui ?",
        "Table des Sources, cartes étalées",
        """Marc : Je le prépare, le trajet. Je te le montre.
Léa : Tu me le donnes ce soir ?
Aline : Je lui explique l'horaire. Je le lui répète.
Patrick : Nous les prenons, les billets. On vous les laisse.
Hawa : Je leur écris un mot, à Solange et à Karim.
Joël : Ne me le dis pas trop vite : j'écoute.""",
        tf_item=(
            "Marc montre le trajet à Léa.",
            True,
            "« Je te le montre. »",
        ),
        qcm_item=(
            "Que signifie « Je le lui répète » ?",
            [
                "Aline répète l'horaire à Patrick",
                "Aline répète l'horaire à Léa (lui = Léa ou Patrick)",
                "Aline répète les billets",
                "Joël répète un mot",
            ],
            1,
            "Le = l'horaire (COD). Lui = à la personne (COI).",
        ),
        pairs=[
            ("le / les", "COD chose"),
            ("me / te / nous / vous", "COI personne"),
            ("lui / leur", "à lui / à eux"),
            ("je leur écris", "à Solange et Karim"),
        ],
        fill_item=("Je ___ le montre. (à toi)", "te"),
        words=["Je", "le", "lui", "répète", "."],
        anagram=("horaire", "Aline le lui explique : les heures du trajet."),
        error=(
            "Je lui le répète.",
            "Je le lui répète.",
            "COD (le) avant COI (lui).",
        ),
        pic_start=8,
        pic_words=["un minibus", "un sac", "un horaire", "un plan"],
        short_p="Notez qui donne quoi à qui.",
        audio="Enregistrez : Je te le montre. Je le lui répète. On vous les laisse.",
    ),
    _l(
        "CE",
        "CE — Billets et messages",
        "Lire des messages qui enchaînent COD et COI.",
        "Lisez les messages, sans aller trop vite.",
        "Cahier du chemin, page ocre",
        """Message de Marc : Je les ai pris, les billets. Je te les apporte.
Message d'Aline : Explique-lui le quai. Répète-le-lui.
Message de Hawa : Écris-leur. Ne leur dis pas le prix trop haut.
Message de Lila Sow : Je vous les envoie, les horaires. Lisez-les.
Ordre : me/te/nous/vous/lui/leur + le/la/les… sauf le lui / le leur.""",
        tf_item=(
            "Lila envoie les horaires.",
            True,
            "« Je vous les envoie, les horaires. »",
        ),
        qcm_item=(
            "Quelle consigne d'Aline est correcte ?",
            ["Explique-le-lui le quai", "Explique-lui le quai", "Lui explique le", "Explique le lui quai"],
            1,
            "Impératif : explique-lui + COD nominal.",
        ),
        pairs=[
            ("je te les apporte", "billets → toi"),
            ("répète-le-lui", "horaire → lui"),
            ("ne leur dis pas", "à eux"),
            ("je vous les envoie", "horaires → vous"),
        ],
        fill_item=("Je te ___ apporte. (les billets)", "les"),
        words=["Je", "vous", "les", "envoie", "."],
        anagram=("quai", "Aline veut qu'on lui explique ce bord de voie."),
        error=(
            "Répète-lui-le.",
            "Répète-le-lui.",
            "À l'impératif : le avant lui.",
        ),
        pic_start=28,
        pic_words=["un nuage", "un soleil", "comparer", "une valise"],
        short_p="Réécrivez deux messages en remplaçant les noms par des pronoms.",
        audio="Lisez les quatre messages, sans aller trop vite.",
    ),
    _l(
        "PO",
        "PO — Le, la, lui, leur",
        "Placer COD et COI dans une phrase orale.",
        "Répétez, puis parlez d'un trajet à organiser.",
        "Modèles de Marc",
        """Je le prépare.
Je te le donne.
Je le lui explique.
Nous vous les laissons.
Je leur écris.
Ne me le cache pas.""",
        tf_item=(
            "« Lui » et « leur » sont des COI.",
            True,
            "À lui / à eux → lui / leur.",
        ),
        qcm_item=(
            "Quelle phrase est correcte ?",
            ["Je lui le donne", "Je le lui donne", "Je donne le lui", "Je le donne lui"],
            1,
            "Je le lui donne.",
        ),
        pairs=[
            ("le / la / les", "COD"),
            ("lui / leur", "COI"),
            ("me / te", "COI (ou COD)"),
            ("ne me le cache pas", "ordre : ne + pronoms + verbe"),
        ],
        fill_item=("Je ___ lui explique. (le trajet)", "le"),
        words=["Ne", "me", "le", "cache", "pas", "."],
        anagram=("cache", "Ne me le… pas : garder l'info pour soi."),
        error=(
            "Nous les vous laissons.",
            "Nous vous les laissons.",
            "vous avant les.",
        ),
        pic_start=12,
        pic_words=["une annonce", "une clé", "une règle", "une fenêtre"],
        short_p="Écrivez cinq phrases avec deux pronoms.",
        audio="Enregistrez les six modèles, puis deux phrases à vous.",
    ),
    _l(
        "PE",
        "PE — Mon plan de trajet",
        "Écrire un plan de déplacement avec des pronoms.",
        "Imitez le plan de Hawa.",
        "Plan de Hawa Diallo",
        """Hawa Diallo
Je le prépare, le trajet vers Val-des-Peupliers.
Je te le montre demain.
Je le lui envoie, à Solange.
Nous vous les donnons, les copies.
Ne me les oubliez pas.
Hawa""",
        tf_item=(
            "Hawa envoie le trajet à Solange.",
            True,
            "« Je le lui envoie, à Solange. »",
        ),
        qcm_item=(
            "Que donne le groupe ?",
            ["Les valises", "Les copies", "Les clés", "Les tasses"],
            1,
            "« Nous vous les donnons, les copies. »",
        ),
        pairs=[
            ("je le prépare", "trajet"),
            ("je te le montre", "à toi"),
            ("je le lui envoie", "Solange"),
            ("nous vous les donnons", "copies"),
        ],
        fill_item=("Je le ___ envoie, à Solange.", "lui"),
        words=["Je", "te", "le", "montre", "demain", "."],
        anagram=("copies", "On vous les donne : des… du dossier."),
        error=(
            "Ne me les oublie pas les copies.",
            "Ne me les oubliez pas.",
            "Impératif vous + pronoms, sans répéter le nom.",
        ),
        pic_start=16,
        pic_words=["une maison", "un jardin", "un escalier", "un banc"],
        short_p="Imitez : un plan de cinq lignes avec pronoms.",
        audio="Lisez votre plan, sans aller trop vite.",
    ),
    _l(
        "EL",
        "EL — COD et COI, synthèse",
        "Retenir l'ordre des pronoms et les verbes à COI.",
        "Apprenez la fiche.",
        "Fiche de synthèse",
        """COD : me te le la nous vous les (l' devant voyelle)
COI : me te lui nous vous leur
Ordre fréquent : me/te/nous/vous + le/la/les
mais : le/la/les + lui/leur → je le lui dis
Verbes à COI : parler à, donner à, écrire à, expliquer à, envoyer à
Verbes à COD : préparer, montrer, prendre, laisser, cacher
Attention : je lui parle (pas je le parle, pour une personne).""",
        tf_item=(
            "On dit « je le parle » pour « je parle à Marc ».",
            False,
            "Parler à → je lui parle.",
        ),
        qcm_item=(
            "Quelle série est dans le bon ordre ?",
            ["lui le", "le lui", "les vous", "leur les je"],
            1,
            "le lui.",
        ),
        pairs=[
            ("donner à", "COI"),
            ("préparer", "COD"),
            ("je le lui dis", "ordre"),
            ("je lui parle", "personne"),
        ],
        fill_item=("Je ___ parle. (à Aline)", "lui"),
        words=["Je", "le", "leur", "envoie", "."],
        anagram=("expliquer", "Un verbe à COI : … à quelqu'un l'horaire."),
        error=(
            "Je le parle à Marc.",
            "Je lui parle.",
            "Parler à une personne → lui.",
        ),
        pic_start=20,
        pic_words=["un panneau", "une flèche", "un carnet", "un pont"],
        short_p="Classez six verbes : COD, COI, ou les deux.",
        audio="Enregistrez la fiche et quatre exemples.",
    ),
]


# ---------------------------------------------------------------------------
# Séquence 4 — Trouver un logement (impératif, devoir / il faut, négation renforcée)
# ---------------------------------------------------------------------------

S4 = [
    _l(
        "CO",
        "CO — Annonce à la Maison des Vents",
        "Comprendre des consignes pour un logement : impératif, il faut, ne… jamais / plus / rien.",
        "Lisez le dialogue. Quelles règles entend-on ?",
        "Cour de la Maison des Vents",
        """Karim : Lisez l'annonce. Appelez le matin.
Aline : Il faut montrer une pièce. Vous devez arriver avant vingt et une heures.
Léa : Ne faites jamais de bruit après vingt-deux heures.
Patrick : N'apportez plus de valise trop grande.
Rose : Ne laissez rien dans le couloir.
Joël : Demandez la clé. Ne la perdez pas.""",
        tf_item=(
            "On peut faire du bruit après vingt-deux heures.",
            False,
            "Léa : « Ne faites jamais de bruit après vingt-deux heures. »",
        ),
        qcm_item=(
            "Quand faut-il arriver, d'après Aline ?",
            ["Après minuit", "Avant vingt et une heures", "À midi seulement", "Le dimanche"],
            1,
            "« Vous devez arriver avant vingt et une heures. »",
        ),
        pairs=[
            ("lisez / appelez", "impératif"),
            ("il faut montrer", "obligation"),
            ("ne… jamais", "à aucun moment"),
            ("ne… rien", "aucune chose"),
        ],
        fill_item=("Ne laissez ___ dans le couloir.", "rien"),
        words=["Il", "faut", "montrer", "une", "pièce", "."],
        anagram=("jamais", "Ne faites… de bruit : à aucun moment."),
        error=(
            "Vous devez d'arriver avant vingt et une heures.",
            "Vous devez arriver avant vingt et une heures.",
            "Devoir + infinitif, sans de.",
        ),
        pic_start=12,
        pic_words=["une annonce", "une clé", "une règle", "une fenêtre"],
        short_p="Listez trois obligations et deux interdictions.",
        audio="Enregistrez : Lisez l'annonce. Il faut montrer une pièce. Ne laissez rien dans le couloir.",
    ),
    _l(
        "CE",
        "CE — Règlement de colocation",
        "Lire un règlement avec impératif et négation renforcée.",
        "Lisez le règlement, sans aller trop vite.",
        "Feuille épinglée, Maison des Vents",
        """Règlement — chambres du Seuil / relais de Val-des-Peupliers
1. Arrivez avant vingt et une heures. Il faut signer le cahier.
2. Ne fumez jamais dans la cour.
3. N'invitez plus d'inconnus sans prévenir Aline.
4. Ne jetez rien par la fenêtre.
5. Vous devez ranger le banc. Il ne faut pas laisser les tasses.
6. Demandez, n'exigez pas.""",
        tf_item=(
            "On peut fumer dans la cour.",
            False,
            "« Ne fumez jamais dans la cour. »",
        ),
        qcm_item=(
            "Que faut-il signer ?",
            ["Un contrat de ville", "Le cahier", "Un passeport", "Une carte bleue"],
            1,
            "« Il faut signer le cahier. »",
        ),
        pairs=[
            ("arrivez", "avant 21 h"),
            ("ne… jamais", "fumer"),
            ("n'invitez plus", "sans prévenir"),
            ("ne… rien", "par la fenêtre"),
        ],
        fill_item=("Il ne faut ___ laisser les tasses.", "pas"),
        words=["Ne", "fumez", "jamais", "dans", "la", "cour", "."],
        anagram=("ranger", "Vous devez… le banc : tout remettre en place."),
        error=(
            "Il faut de signer le cahier.",
            "Il faut signer le cahier.",
            "Il faut + infinitif, sans de.",
        ),
        pic_start=16,
        pic_words=["une maison", "un jardin", "un escalier", "un banc"],
        short_p="Recopiez le règlement et ajoutez une règle à vous.",
        audio="Lisez les six points, sans aller trop vite.",
    ),
    _l(
        "PO",
        "PO — Conseiller et interdire",
        "Donner des consignes : impératif, devoir, il faut, ne… jamais / plus / rien.",
        "Répétez, puis donnez des règles pour une chambre.",
        "Modèles d'Aline",
        """Appelez le matin.
Vous devez arriver tôt.
Il faut demander la clé.
Ne faites jamais de bruit.
N'apportez plus ce sac trop grand.
Ne laissez rien ici.""",
        tf_item=(
            "L'impératif peut servir à conseiller.",
            True,
            "Appelez, demandez, rangez…",
        ),
        qcm_item=(
            "Quelle négation signifie « à aucun moment » ?",
            ["ne… plus", "ne… jamais", "ne… rien", "ne… personne"],
            1,
            "Jamais = à aucun moment.",
        ),
        pairs=[
            ("devoir + infinitif", "obligation"),
            ("il faut + infinitif", "obligation"),
            ("ne… plus", "cesser"),
            ("ne… rien", "aucune chose"),
        ],
        fill_item=("Vous ___ arriver tôt.", "devez"),
        words=["Il", "faut", "demander", "la", "clé", "."],
        anagram=("devez", "Vous… arriver tôt : forme de devoir."),
        error=(
            "Il faut que demander la clé.",
            "Il faut demander la clé.",
            "Ici : il faut + infinitif (le subjonctif vient plus tard).",
        ),
        pic_start=24,
        pic_words=["une radio", "une table", "un cahier", "une horloge"],
        short_p="Écrivez six consignes : deux impératifs, deux il faut, deux négations.",
        audio="Enregistrez les six modèles, puis trois règles à vous.",
    ),
    _l(
        "PE",
        "PE — Mon mot au logement",
        "Écrire un mot de règles pour une colocation.",
        "Imitez le mot de Rose.",
        "Mot de Rose Iradukunda",
        """Rose Iradukunda
Arrivez avant vingt et une heures.
Il faut signer le cahier. Vous devez ranger la tasse.
Ne faites jamais de bruit tard.
N'oubliez plus la clé.
Ne laissez rien sous le banc.
Rose
Maison des Vents — relais du Seuil""",
        tf_item=(
            "Rose demande de laisser les affaires sous le banc.",
            False,
            "« Ne laissez rien sous le banc. »",
        ),
        qcm_item=(
            "Quelle phrase utilise devoir ?",
            [
                "Arrivez avant vingt et une heures",
                "Vous devez ranger la tasse",
                "Ne faites jamais de bruit",
                "Rose",
            ],
            1,
            "« Vous devez ranger la tasse. »",
        ),
        pairs=[
            ("arrivez", "impératif"),
            ("il faut signer", "cahier"),
            ("vous devez ranger", "tasse"),
            ("ne… jamais", "bruit"),
        ],
        fill_item=("N'oubliez ___ la clé.", "plus"),
        words=["Ne", "laissez", "rien", "sous", "le", "banc", "."],
        anagram=("signer", "Il faut… le cahier à l'arrivée."),
        error=(
            "Ne faites jamais de bruits tard le soir.",
            "Ne faites jamais de bruit tard le soir.",
            "Bruit au singulier dans cette règle.",
        ),
        pic_start=2,
        pic_words=["un billet", "une carte", "un bureau", "un formulaire"],
        short_p="Imitez : six lignes de règlement.",
        audio="Lisez votre mot, sans aller trop vite.",
    ),
    _l(
        "EL",
        "EL — Impératif, devoir, négation",
        "Retenir l'impératif, devoir / il faut, ne… jamais / plus / rien / personne.",
        "Apprenez la fiche.",
        "Fiche de la Maison des Vents",
        """Impératif : arrive / arrivez ; demande / demandez ; lis / lisez
devoir + infinitif : vous devez arriver
il faut + infinitif : il faut signer (toujours il)
Négation renforcée :
ne… pas / ne… plus (cesser) / ne… jamais (aucun moment)
ne… rien (aucune chose) / ne… personne (aucun être)
Place : Ne faites jamais. Ne laissez rien. N'invitez plus.
Attention : il faut (pas je faut). Devoir : je dois, tu dois, il doit, nous devons.""",
        tf_item=(
            "« Ne… plus » veut dire « à aucun moment ».",
            False,
            "Plus = cesser. Jamais = à aucun moment.",
        ),
        qcm_item=(
            "Quelle forme est correcte ?",
            ["je faut signer", "il faut signer", "tu faut signer", "nous faut signer"],
            1,
            "Toujours il faut.",
        ),
        pairs=[
            ("ne… plus", "cesser"),
            ("ne… jamais", "aucun moment"),
            ("ne… rien", "aucune chose"),
            ("ne… personne", "aucun être"),
        ],
        fill_item=("Nous ___ ranger le banc. (devoir)", "devons"),
        words=["Vous", "devez", "arriver", "tôt", "."],
        anagram=("personne", "Ne… ici : aucun être humain dans le couloir."),
        error=(
            "Je dois d'arriver avant vingt et une heures.",
            "Je dois arriver avant vingt et une heures.",
            "Devoir + infinitif, sans de.",
        ),
        pic_start=6,
        pic_words=["une enveloppe", "une affiche", "un minibus", "un sac"],
        short_p="Complétez un tableau : impératif tu/vous, devoir, quatre négations.",
        audio="Enregistrez la fiche et quatre exemples.",
    ),
]


# ---------------------------------------------------------------------------
# Séquence 5 — Un lieu pas comme les autres (adverbes et locutions de lieu)
# ---------------------------------------------------------------------------

S5 = [
    _l(
        "CO",
        "CO — Visite de la Maison des Vents",
        "Repérer où se trouvent les choses : ici, là-bas, dehors, au-dessus, à gauche…",
        "Lisez le dialogue. Où est chaque lieu ?",
        "Seuil de la Maison des Vents",
        """Karim : Entrez. Ici, c'est l'accueil. Là-bas, c'est le jardin.
Léa : Le puits est dehors, derrière la cuisine.
Marc : La chambre est en haut, au-dessus de la salle.
Hawa : Le banc est en bas, à gauche de l'escalier.
Aline : Posez les sacs ici, tout près. Pas là-bas, trop loin.
Patrick : On se retrouve dehors, au milieu de la cour.""",
        tf_item=(
            "Le puits est à l'intérieur, devant la cuisine.",
            False,
            "Léa : « dehors, derrière la cuisine. »",
        ),
        qcm_item=(
            "Où est la chambre ?",
            ["En bas, à gauche", "En haut, au-dessus de la salle", "Dehors, derrière", "Au milieu du puits"],
            1,
            "Marc : « en haut, au-dessus de la salle. »",
        ),
        pairs=[
            ("ici", "accueil"),
            ("là-bas", "jardin"),
            ("dehors / derrière", "puits"),
            ("en haut / au-dessus", "chambre"),
        ],
        fill_item=("Le banc est en bas, ___ gauche de l'escalier.", "à"),
        words=["On", "se", "retrouve", "dehors", "."],
        anagram=("dehors", "Pas à l'intérieur : dans la cour, …"),
        error=(
            "La chambre est en bas, au-dessus de la salle.",
            "La chambre est en haut, au-dessus de la salle.",
            "Au-dessus va avec en haut.",
        ),
        pic_start=16,
        pic_words=["une maison", "un jardin", "un escalier", "un banc"],
        short_p="Placez cinq objets du dialogue avec un adverbe de lieu.",
        audio="Enregistrez : Ici c'est l'accueil. Là-bas c'est le jardin. Le puits est dehors.",
    ),
    _l(
        "CE",
        "CE — Plan annoté",
        "Lire un plan avec des locutions de lieu.",
        "Lisez la légende, sans aller trop vite.",
        "Plan de Lila Sow",
        """Maison des Vents — légende
Accueil : ici, juste à l'entrée.
Jardin : là-bas, tout au fond.
Puits : dehors, derrière la cuisine, tout près du muret.
Chambre ocre : en haut, au-dessus de la Salle des Herbes.
Banc : en bas, à droite de l'escalier, au milieu des pots.
Attention : tout près ≠ trop loin. En haut ≠ en bas.""",
        tf_item=(
            "Le jardin est tout au fond.",
            True,
            "« là-bas, tout au fond. »",
        ),
        qcm_item=(
            "Le banc est…",
            ["à gauche du puits", "à droite de l'escalier", "au-dessus de l'accueil", "derrière Lila"],
            1,
            "« à droite de l'escalier ».",
        ),
        pairs=[
            ("juste à l'entrée", "accueil"),
            ("tout au fond", "jardin"),
            ("tout près du muret", "puits"),
            ("au milieu des pots", "banc"),
        ],
        fill_item=("La chambre est en haut, ___-dessus de la salle.", "au"),
        words=["Le", "jardin", "est", "là-bas", "."],
        anagram=("entree", "L'accueil est juste à l'… (sans accent)."),
        error=(
            "Le puits est dedans, derrière la cuisine.",
            "Le puits est dehors, derrière la cuisine.",
            "Derrière la cuisine = dehors.",
        ),
        pic_start=18,
        pic_words=["un escalier", "un banc", "un panneau", "une flèche"],
        short_p="Redessinez le plan en cinq phrases de lieu.",
        audio="Lisez la légende, sans aller trop vite.",
    ),
    _l(
        "PO",
        "PO — Situer un lieu",
        "Situer des objets avec des adverbes et locutions.",
        "Répétez, puis décrivez la cour du Seuil.",
        "Modèles de Karim",
        """C'est ici.
C'est là-bas.
Le puits est dehors.
La salle est en bas.
La chambre est au-dessus.
Le banc est à gauche, tout près.""",
        tf_item=(
            "« Tout près » est le contraire de « trop loin ».",
            True,
            "Distance courte vs longue.",
        ),
        qcm_item=(
            "Quelle locution indique une position haute ?",
            ["en bas", "au-dessus", "derrière", "au milieu"],
            1,
            "Au-dessus = plus haut.",
        ),
        pairs=[
            ("ici / là-bas", "proche / distant"),
            ("dehors / dedans", "extérieur / intérieur"),
            ("en haut / en bas", "vertical"),
            ("à gauche / à droite", "horizontal"),
        ],
        fill_item=("Le banc est ___ près.", "tout"),
        words=["La", "chambre", "est", "au-dessus", "."],
        anagram=("gauche", "Le contraire de à droite."),
        error=(
            "Le banc est à le gauche.",
            "Le banc est à gauche.",
            "À gauche, sans article.",
        ),
        pic_start=22,
        pic_words=["un carnet", "un pont", "une radio", "une table"],
        short_p="Décrivez six lieux avec six locutions différentes.",
        audio="Enregistrez les six modèles, puis la cour du Seuil.",
    ),
    _l(
        "PE",
        "PE — Mon plan de lieu",
        "Écrire un plan court avec des locutions de lieu.",
        "Imitez le plan de Marc.",
        "Plan de Marc Nkurunziza",
        """Marc Nkurunziza
Ici, c'est l'accueil. Là-bas, le jardin.
Le puits est dehors, derrière la cuisine.
Ma chambre est en haut, au-dessus de la salle.
Le banc est en bas, à gauche, tout près.
On se retrouve au milieu de la cour.
Marc""",
        tf_item=(
            "Marc se retrouve au milieu de la cour.",
            True,
            "Dernière ligne du plan.",
        ),
        qcm_item=(
            "Où Marc place-t-il sa chambre ?",
            ["Dehors", "En haut", "Au puits", "À droite du marché"],
            1,
            "« en haut, au-dessus de la salle. »",
        ),
        pairs=[
            ("ici", "accueil"),
            ("là-bas", "jardin"),
            ("dehors", "puits"),
            ("en haut", "chambre"),
        ],
        fill_item=("On se retrouve ___ milieu de la cour.", "au"),
        words=["Le", "puits", "est", "dehors", "."],
        anagram=("milieu", "Au… de la cour : ni à gauche ni à droite."),
        error=(
            "Ma chambre est en haut, au-dessous de la salle.",
            "Ma chambre est en haut, au-dessus de la salle.",
            "Au-dessus = plus haut. Au-dessous = plus bas.",
        ),
        pic_start=26,
        pic_words=["un cahier", "une horloge", "un nuage", "un soleil"],
        short_p="Imitez : six lignes de plan.",
        audio="Lisez votre plan, sans aller trop vite.",
    ),
    _l(
        "EL",
        "EL — Adverbes et locutions de lieu",
        "Retenir ici, là-bas, dehors, en haut, au-dessus, à gauche, tout près…",
        "Apprenez la fiche.",
        "Fiche de Lila",
        """Adverbes : ici, là, là-bas, dehors, dedans, partout, loin, près
Locutions : en haut / en bas ; à gauche / à droite ; au-dessus / au-dessous
devant / derrière ; à côté de ; au milieu de ; tout près de ; tout au fond
Contractions : à + le = au (au milieu). De + le = du (près du muret).
Attention : au-dessus (accent et trait). Pas : au dessus.
À gauche (pas à le gauche).""",
        tf_item=(
            "On écrit « au dessus » en deux mots, sans trait.",
            False,
            "Au-dessus, avec un trait d'union.",
        ),
        qcm_item=(
            "« À + le milieu » donne…",
            ["à le milieu", "au milieu", "aux milieu", "du milieu"],
            1,
            "À + le = au.",
        ),
        pairs=[
            ("ici", "proche de moi"),
            ("là-bas", "plus loin"),
            ("au-dessus", "plus haut"),
            ("au-dessous", "plus bas"),
        ],
        fill_item=("Le banc est ___ côté de l'escalier.", "à"),
        words=["C'est", "tout", "au", "fond", "."],
        anagram=("derriere", "Le contraire de devant (sans accent)."),
        error=(
            "Posez les sacs à le milieu de la cour.",
            "Posez les sacs au milieu de la cour.",
            "À + le = au.",
        ),
        pic_start=10,
        pic_words=["un horaire", "un plan", "une annonce", "une clé"],
        short_p="Faites une liste de douze mots de lieu, avec un exemple chacun.",
        audio="Enregistrez la fiche et six exemples.",
    ),
]


# ---------------------------------------------------------------------------
# Séquence 6 — Suivre un itinéraire (qui / que / à qui / avec qui)
# ---------------------------------------------------------------------------

S6 = [
    _l(
        "CO",
        "CO — Le chemin que Marc indique",
        "Comprendre un itinéraire avec qui, que, à qui, avec qui.",
        "Lisez le dialogue. Qui fait le chemin ? Que voit-on ?",
        "Départ sous le figuier",
        """Marc : Prenez le sentier qui descend vers le pont.
Léa : Le pont que tu décris, c'est celui des Herbes ?
Aline : La personne à qui vous demandez, c'est Solange.
Patrick : Le guide avec qui on marche, c'est Karim.
Hawa : Les panneaux qui sont ocre montrent la droite.
Joël : La rue que vous suivez va jusqu'au Bureau des Escales.""",
        tf_item=(
            "Le sentier qui descend va vers le pont.",
            True,
            "Marc : « le sentier qui descend vers le pont. »",
        ),
        qcm_item=(
            "À qui faut-il demander, d'après Aline ?",
            ["Karim", "Solange", "Joël", "Rose"],
            1,
            "« La personne à qui vous demandez, c'est Solange. »",
        ),
        pairs=[
            ("qui descend", "sentier / sujet"),
            ("que tu décris", "pont / COD"),
            ("à qui vous demandez", "Solange"),
            ("avec qui on marche", "Karim"),
        ],
        fill_item=("Le guide ___ qui on marche, c'est Karim.", "avec"),
        words=["Prenez", "le", "sentier", "qui", "descend", "."],
        anagram=("sentier", "Le petit chemin qui descend vers le pont."),
        error=(
            "Le pont qui tu décris est loin.",
            "Le pont que tu décris est loin.",
            "Que = COD. Qui = sujet.",
        ),
        pic_start=20,
        pic_words=["un panneau", "une flèche", "un carnet", "un pont"],
        short_p="Notez quatre relatives : qui, que, à qui, avec qui.",
        audio="Enregistrez : Le sentier qui descend. Le pont que tu décris. La personne à qui vous demandez.",
    ),
    _l(
        "CE",
        "CE — Itinéraire écrit",
        "Lire un itinéraire avec des relatifs.",
        "Lisez la feuille, sans aller trop vite.",
        "Feuille de Karim Bamba",
        """Itinéraire Seuil → Bureau des Escales
1. Suivez le mur qui borde le figuier.
2. Traversez le pont que les enfants appellent « pont des Herbes ».
3. Demandez à la femme à qui Solange a laissé la clé : c'est Yvette.
4. Marchez avec le groupe avec qui Patrick part à huit heures.
5. Les flèches qui sont peintes en ocre tournent à droite.
6. La place que vous voyez alors, c'est le Bureau.""",
        tf_item=(
            "Yvette est la femme à qui Solange a laissé la clé.",
            True,
            "Point 3 de l'itinéraire.",
        ),
        qcm_item=(
            "Que font les flèches ocre ?",
            ["Elles montent", "Elles tournent à droite", "Elles s'arrêtent", "Elles cachent le pont"],
            1,
            "« tournent à droite. »",
        ),
        pairs=[
            ("qui borde", "mur"),
            ("que les enfants appellent", "pont"),
            ("à qui Solange a laissé", "Yvette"),
            ("avec qui Patrick part", "groupe"),
        ],
        fill_item=("Suivez le mur ___ borde le figuier.", "qui"),
        words=["Traversez", "le", "pont", "que", "vous", "voyez", "."],
        anagram=("fleches", "Elles sont ocre et tournent (sans accent)."),
        error=(
            "La place qui vous voyez alors, c'est le Bureau.",
            "La place que vous voyez alors, c'est le Bureau.",
            "Vous voyez la place → que (COD).",
        ),
        pic_start=0,
        pic_words=["comparer", "une valise", "un billet", "une carte"],
        short_p="Recopiez l'itinéraire et encadrez les relatifs.",
        audio="Lisez les six points, sans aller trop vite.",
    ),
    _l(
        "PO",
        "PO — Relier avec qui et que",
        "Relier deux informations : qui, que, à qui, avec qui.",
        "Répétez, puis décrivez un chemin du Seuil.",
        "Modèles d'Aline",
        """C'est le sentier qui descend.
C'est le pont que je connais.
C'est la personne à qui je demande.
C'est le guide avec qui nous marchons.
Ce sont les panneaux qui tournent.
C'est la rue que vous suivez.""",
        tf_item=(
            "« Qui » est sujet de la relative.",
            True,
            "Le sentier qui descend : qui = le sentier.",
        ),
        qcm_item=(
            "On dit « la personne… je demande » comment ?",
            ["qui", "que", "à qui", "dont"],
            2,
            "Demander à quelqu'un → à qui.",
        ),
        pairs=[
            ("qui", "sujet"),
            ("que", "COD"),
            ("à qui", "COI"),
            ("avec qui", "accompagnement"),
        ],
        fill_item=("C'est le pont ___ je connais.", "que"),
        words=["C'est", "le", "guide", "avec", "qui", "nous", "marchons", "."],
        anagram=("connais", "Le pont que je… : j'ai déjà vu ce pont."),
        error=(
            "C'est la personne que je demande l'heure.",
            "C'est la personne à qui je demande l'heure.",
            "Demander à → à qui.",
        ),
        pic_start=8,
        pic_words=["un minibus", "un sac", "un horaire", "un plan"],
        short_p="Écrivez six relatives : deux de chaque type (qui / que / à qui / avec qui : mélangez).",
        audio="Enregistrez les six modèles, puis un itinéraire à vous.",
    ),
    _l(
        "PE",
        "PE — Mon itinéraire",
        "Écrire un itinéraire avec des pronoms relatifs.",
        "Imitez l'itinéraire de Léa.",
        "Itinéraire de Léa Niyonzima",
        """Léa Niyonzima
Suivez le sentier qui part du figuier.
Traversez le pont que Marc a décrit.
Demandez à la personne à qui Aline a écrit.
Marchez avec le groupe avec qui Patrick part.
La place que vous voyez, c'est le Bureau des Escales.
Léa""",
        tf_item=(
            "Léa part du figuier.",
            True,
            "« le sentier qui part du figuier. »",
        ),
        qcm_item=(
            "Avec qui Léa dit-elle de marcher ?",
            ["Le groupe de Patrick", "Karim seul", "Rose", "Les enfants du pont"],
            0,
            "« le groupe avec qui Patrick part. »",
        ),
        pairs=[
            ("qui part", "sentier"),
            ("que Marc a décrit", "pont"),
            ("à qui Aline a écrit", "personne"),
            ("avec qui Patrick part", "groupe"),
        ],
        fill_item=("La place ___ vous voyez, c'est le Bureau.", "que"),
        words=["Suivez", "le", "sentier", "qui", "part", "."],
        anagram=("decrit", "Le pont que Marc a… (sans accent)."),
        error=(
            "Demandez à la personne qui Aline a écrit.",
            "Demandez à la personne à qui Aline a écrit.",
            "Écrire à quelqu'un → à qui.",
        ),
        pic_start=14,
        pic_words=["une règle", "une fenêtre", "une maison", "un jardin"],
        short_p="Imitez : cinq phrases d'itinéraire avec relatifs.",
        audio="Lisez votre itinéraire, sans aller trop vite.",
    ),
    _l(
        "EL",
        "EL — Qui, que, à qui, avec qui",
        "Retenir le choix du pronom relatif.",
        "Apprenez la fiche.",
        "Fiche du carnet",
        """qui = sujet : le sentier qui descend
que = COD : le pont que je vois (qu' devant voyelle : que + il → qu'il)
à qui = COI personne : la femme à qui je parle
avec qui = accompagnement : le guide avec qui je marche
On ne dit pas : le pont qui je vois.
On ne dit pas : la personne que je parle (parler à → à qui).
Élision : le chemin qu'elle indique.""",
        tf_item=(
            "On écrit « le pont qui je vois ».",
            False,
            "Je vois le pont → que.",
        ),
        qcm_item=(
            "« Que + elle » s'écrit…",
            ["que elle", "qu'elle", "qui elle", "quel elle"],
            1,
            "Élision : qu'elle.",
        ),
        pairs=[
            ("qui", "sujet"),
            ("que / qu'", "COD"),
            ("à qui", "parler à"),
            ("avec qui", "marcher avec"),
        ],
        fill_item=("Le chemin ___ elle indique est ocre.", "qu'"),
        words=["C'est", "la", "femme", "à", "qui", "je", "parle", "."],
        anagram=("sujet", "Qui remplace le… de la relative."),
        error=(
            "C'est le guide que je marche.",
            "C'est le guide avec qui je marche.",
            "Marcher avec → avec qui.",
        ),
        pic_start=4,
        pic_words=["un bureau", "un formulaire", "une enveloppe", "une affiche"],
        short_p="Transformez six phrases simples en relatives.",
        audio="Enregistrez la fiche et six relatives.",
    ),
]


SEQUENCES = [
    {"title": "Comparer des séjours", "lessons": S1},
    {"title": "Premières démarches", "lessons": S2},
    {"title": "Organiser un déplacement", "lessons": S3},
    {"title": "Trouver un logement", "lessons": S4},
    {"title": "Un lieu pas comme les autres", "lessons": S5},
    {"title": "Suivre un itinéraire", "lessons": S6},
]
