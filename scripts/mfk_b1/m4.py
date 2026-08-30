"""B1 Module 4 — Agir pour demain (univers Seuil des Sources)."""

from factory import L

IMG = "mfk-b1-m4"
IMG_DIR = IMG

MODULE = {
    "title": "B1 — Agir pour demain",
    "description": (
        "Grande étape B1-4 : rendre compte d'une expérience, adhérer et nuancer, "
        "débattre de solutions, présenter un projet pour la rive, persuader d'agir "
        "et mesurer l'impact — autour du figuier, du compost et de la petite "
        "rivière du Seuil des Sources (Rukiri-Nord), jusqu'au Bureau des Escales."
    ),
}


def _l(comp, title, obj, cons, st, sp, **kw):
    return L(IMG, comp, title, obj, cons, st, sp, **kw)


# ---------------------------------------------------------------------------
# Séquence 1 — Rendre compte, adhérer, nuancer
# ---------------------------------------------------------------------------

S1 = [
    _l(
        "CO",
        "CO — Compte rendu sous le figuier",
        "Comprendre un compte rendu d'expérience : adhésion, réserves, indéfinis de quantité.",
        "Lisez le dialogue (à écouter avec l'enseignant). Qui adhère ? Qui nuance ?",
        "Banc du figuier, après l'assemblée",
        """Léa : Hier, sous le figuier, nous avons rendu compte de la rive.
Patrick : Quelques voisins sont venus. Plusieurs ont parlé trop vite.
Hawa : La plupart des habitants veulent protéger le figuier.
Marc : Tout le monde n'est pas d'accord : j'ai encore des réserves.
Joël : Aucun seau n'était prêt, pourtant certains ont déjà composté.
Rose : Chaque sac de feuilles compte, même s'il est petit.
Aline : J'adhère à l'idée, mais je nuance : il faut du temps.
Karim : Certains gestes sont clairs. D'autres restent flous pour le Bureau.
Lila : Radio Figuier a noté tout cela pour le Cahier des racines.
Solange : Le Bureau des Escales lira quelques pages, pas toutes d'un coup.
Félicie : J'adhère aussi, sans cacher mes doutes sur le rythme.
Dieudonné : Plusieurs tissus de l'atelier serviront de sacs, pas tous.""",
        tf_item=(
            "Hawa dit que la plupart des habitants veulent protéger le figuier.",
            True,
            "Hawa : « La plupart des habitants veulent protéger le figuier. »",
        ),
        qcm_item=(
            "Que dit Joël des seaux ?",
            [
                "Tous les seaux étaient prêts",
                "Aucun seau n'était prêt",
                "Chaque seau était plein",
                "Quelques seaux ont disparu",
            ],
            1,
            "Joël : « Aucun seau n'était prêt. »",
        ),
        pairs=[
            ("quelques voisins", "un petit nombre"),
            ("la plupart des habitants", "presque tous"),
            ("aucun seau", "pas un seul"),
            ("chaque sac", "un par un"),
        ],
        fill_item=("___ seau n'était prêt.", "Aucun"),
        words=["La", "plupart", "des", "habitants", "veulent", "protéger", "le", "figuier", "."],
        anagram=("quelques", "Un petit nombre de voisins, pas la majorité."),
        error=(
            "La plupart des habitants veut protéger le figuier.",
            "La plupart des habitants veulent protéger le figuier.",
            "La plupart + nom pluriel : verbe au pluriel.",
        ),
        pic_start=0,
        pic_words=["un compte rendu", "une quantité", "une réserve", "un cahier"],
        short_p="Notez deux adhésions et deux réserves entendues, avec un indéfini chacune.",
        audio="Enregistrez : Quelques voisins sont venus. La plupart veulent protéger. J'adhère, mais je nuance.",
    ),
    _l(
        "CE",
        "CE — Pages du Cahier des racines",
        "Lire un compte rendu écrit avec indéfinis de quantité, adhésion et réserves.",
        "Lisez les pages épinglées, sans aller trop vite.",
        "Cahier des racines, feuille ocre",
        """Assemblée du Seuil — compte rendu
Quelques voix ont ouvert la séance sous le figuier.
Plusieurs habitants ont décrit la rive : plastique, terre sèche, odeur.
La plupart des présents adhèrent au compost de la cour.
Certains nuancent : trop d'outils, trop peu de relais le soir.
Aucun enfant n'est resté sans tâche : chaque seau a un nom.
Tout le compost ira près de la Table des Sources, pas plus loin.
Rose écrit : j'adhère, à condition que le rythme reste humain.
Karim note : plusieurs sacs, pas tous, viendront de l'Atelier du Tissu.
Solange Mukamana lira tout le cahier avant jeudi.
Félicie ajoute une réserve : aucun feu près de l'eau.
Dieudonné signe : chaque tissu réemployé compte.""",
        tf_item=(
            "Tous les sacs viendront de l'Atelier du Tissu.",
            False,
            "Karim : « plusieurs sacs, pas tous. »",
        ),
        qcm_item=(
            "Quelle réserve Félicie ajoute-t-elle ?",
            [
                "Aucun compost dans la cour",
                "Aucun feu près de l'eau",
                "Aucune signature avant jeudi",
                "Aucun enfant à l'assemblée",
            ],
            1,
            "« aucun feu près de l'eau. »",
        ),
        pairs=[
            ("quelques voix", "ouverture"),
            ("la plupart des présents", "adhésion au compost"),
            ("certains", "nuancent le rythme"),
            ("chaque seau", "un nom"),
        ],
        fill_item=("___ enfant n'est resté sans tâche.", "Aucun"),
        words=["Certains", "nuancent", "le", "rythme", "du", "projet", "."],
        anagram=("certains", "Pas tous : une partie des habitants, au masculin pluriel."),
        error=(
            "Aucun enfant est resté sans tâche.",
            "Aucun enfant n'est resté sans tâche.",
            "Aucun s'emploie avec ne.",
        ),
        pic_start=1,
        pic_words=["une quantité", "une réserve", "un cahier", "un participe"],
        short_p="Recopiez le compte rendu et soulignez tous les indéfinis de quantité.",
        audio="Lisez les pages du Cahier des racines, sans aller trop vite.",
    ),
    _l(
        "PO",
        "PO — Adhérer et nuancer",
        "Dire une adhésion, une réserve et une quantité à voix haute.",
        "Répétez les modèles, puis parlez de la rive du Seuil.",
        "Modèles d'Aline",
        """Quelques voisins sont déjà là.
Plusieurs ont adhéré sans réserve.
La plupart des gestes sont simples.
Tout le compost reste dans la cour.
Aucun sac ne part trop loin.
Certains doutent encore du rythme.
Chaque seau a sa place.
J'adhère à l'idée, mais je nuance.
Nous adhérons, à condition d'aller lentement.
Plusieurs tissus serviront, pas tous.
La plupart veulent signer.
Aucun feu n'est prévu près de l'eau.""",
        tf_item=(
            "« La plupart » annonce souvent un verbe au pluriel.",
            True,
            "La plupart des gestes sont simples.",
        ),
        qcm_item=(
            "Quelle phrase exprime une réserve ?",
            [
                "Plusieurs ont adhéré sans réserve",
                "J'adhère à l'idée mais je nuance",
                "Tout le compost reste dans la cour",
                "Chaque seau a sa place",
            ],
            1,
            "Adhérer + mais je nuance.",
        ),
        pairs=[
            ("quelques", "un petit nombre"),
            ("plusieurs", "plus de deux"),
            ("tout", "l'ensemble"),
            ("aucun… ne", "zéro"),
        ],
        fill_item=("___ seau a sa place.", "Chaque"),
        words=["J'adhère", "à", "l'idée", "mais", "je", "nuance", "."],
        anagram=("chaque", "Un par un : … seau a sa place."),
        error=(
            "Chaque seaux a sa place près du figuier.",
            "Chaque seau a sa place près du figuier.",
            "Chaque + nom singulier.",
        ),
        pic_start=2,
        pic_words=["une réserve", "un cahier", "un participe", "un débat"],
        short_p="Écrivez six phrases : deux adhésions, deux réserves, deux indéfinis différents.",
        audio="Enregistrez les modèles, puis deux phrases à vous : j'adhère / je nuance.",
    ),
    _l(
        "PE",
        "PE — Mon compte rendu",
        "Écrire un court compte rendu d'expérience avec adhésion, réserve et indéfinis.",
        "Imitez le compte rendu de Patrick, sans aller trop vite.",
        "Compte rendu de Patrick Habimana",
        """Patrick Habimana
Quelques voisins sont venus sous le figuier.
Plusieurs ont parlé de la petite rivière.
La plupart des présents adhèrent au compost.
J'adhère aussi, mais je nuance : aucun geste ne doit brûler l'équipe.
Certains préfèrent les seaux le matin, d'autres le soir.
Chaque page du Cahier des racines portera un nom.
Tout le plastique ramassé ira hors de la rive.
Patrick
Seuil des Sources — Rukiri-Nord
Cahier des racines""",
        tf_item=(
            "Patrick refuse le compost.",
            False,
            "« J'adhère aussi, mais je nuance. »",
        ),
        qcm_item=(
            "Que portera chaque page, d'après Patrick ?",
            ["Un tampon de ville", "Un nom", "Un prix", "Un horaire de minibus"],
            1,
            "« Chaque page … portera un nom. »",
        ),
        pairs=[
            ("quelques voisins", "sont venus"),
            ("la plupart des présents", "adhèrent"),
            ("aucun geste", "ne doit brûler"),
            ("chaque page", "un nom"),
        ],
        fill_item=("___ le plastique ramassé ira hors de la rive.", "Tout"),
        words=["Plusieurs", "ont", "parlé", "de", "la", "rivière", "."],
        anagram=("nuance", "Adhérer sans tout accepter : on… le rythme."),
        error=(
            "Tout les plastiques ramassés iront hors de la rive.",
            "Tous les plastiques ramassés iront hors de la rive.",
            "Tous les + nom pluriel masculin.",
        ),
        pic_start=3,
        pic_words=["un cahier", "un participe", "un débat", "un adverbe"],
        short_p="Imitez : dix lignes, trois indéfinis, une adhésion et une réserve.",
        audio="Lisez votre compte rendu, une phrase, une pause, sans aller trop vite.",
    ),
    _l(
        "EL",
        "EL — Indéfinis de quantité",
        "Retenir quelques, plusieurs, la plupart, tout, aucun, certains, chaque.",
        "Apprenez la fiche.",
        "Fiche du carnet, ombre du figuier",
        """quelques + nom pluriel : un petit nombre (quelques voisins).
plusieurs + nom pluriel : plus de deux, sans tout dire.
la plupart des + nom pluriel : verbe souvent au pluriel (veulent).
tout / toute / tous / toutes : l'ensemble (tout le compost / tous les sacs).
aucun / aucune + ne + verbe au singulier : pas un seul.
certains / certaines : une partie, souvent avec une réserve.
chaque + nom singulier : un par un (chaque seau).
Adhésion : j'adhère à… / je suis d'accord pour…
Réserve : je nuance / j'adhère, mais… / à condition que…
Ne pas dire : la plupart veut (avec un nom pluriel).
Ne pas dire : aucun… est (sans ne).
Ne pas dire : chaque seaux.""",
        tf_item=(
            "On dit « chaque seaux » au pluriel.",
            False,
            "Chaque + singulier.",
        ),
        qcm_item=(
            "Quelle forme est correcte ?",
            [
                "Aucun seau était prêt",
                "Aucun seau n'était prêt",
                "Aucuns seaux n'étaient prêtes",
                "Aucun des seau est prêt",
            ],
            1,
            "Aucun + ne + singulier.",
        ),
        pairs=[
            ("quelques", "petit nombre"),
            ("la plupart des", "presque tous"),
            ("aucun… ne", "zéro"),
            ("chaque", "un par un"),
        ],
        fill_item=("La plupart des habitants ___ signer. (vouloir)", "veulent"),
        words=["Aucun", "feu", "n'est", "prévu", "près", "de", "l'eau", "."],
        anagram=("plusieurs", "Plus de deux habitants, sans dire tout le groupe."),
        error=(
            "Certains habitants nuance encore le rythme.",
            "Certains habitants nuancent encore le rythme.",
            "Certains + verbe au pluriel : nuancent.",
        ),
        pic_start=4,
        pic_words=["un participe", "un débat", "un adverbe", "une intensité"],
        short_p="Construisez sept phrases, une pour chaque indéfini de la fiche.",
        audio="Enregistrez la fiche, puis trois exemples à vous.",
    ),
]


# ---------------------------------------------------------------------------
# Séquence 2 — Débattre de solutions
# ---------------------------------------------------------------------------

S2 = [
    _l(
        "CO",
        "CO — Débat sur la rive",
        "Repérer le participe présent, le gérondif, les adverbes en -ment et l'intensité.",
        "Lisez le débat. Quelle solution ? Quelle intensité ?",
        "Rive du Seuil, cercle debout",
        """Patrick : En agissant maintenant, on évite un mal vraiment plus grand.
Léa : Étant trop pressés, certains déplacent trop de terre.
Marc : En écoutant chacun, on avance lentement, pas trop vite.
Hawa : La rive est particulièrement fragile près des racines.
Joël : En compostant ici, on réduit extrêmement les déchets de cuisine.
Rose : Je parle calmement : assez de seaux, pas trop de discours.
Aline : En étant clairs, nous convaincrons le Bureau plus facilement.
Karim : Lila a parlé clairement : l'eau monte vraiment trop vite.
Félicie : En rangeant le soir, on laisse la cour propre.
Dieudonné : Une équipe agissant trop vite abîme le tissu des sacs.
Solange : Le Bureau écoute attentivement, pas seulement les plus forts.
Lila : En mesurant chaque semaine, on débattra moins à vide.""",
        tf_item=(
            "Hawa dit que la rive est particulièrement fragile près des racines.",
            True,
            "Hawa : « particulièrement fragile près des racines. »",
        ),
        qcm_item=(
            "Que craint Léa si l'on est trop pressé ?",
            [
                "On manque de seaux",
                "On déplace trop de terre",
                "On éteint Radio Figuier",
                "On ferme le Bureau",
            ],
            1,
            "Léa : « trop de terre. »",
        ),
        pairs=[
            ("en agissant", "moyen / simultanéité"),
            ("étant trop pressés", "cause"),
            ("lentement", "adverbe en -ment"),
            ("particulièrement", "intensité"),
        ],
        fill_item=("___ agissant maintenant, on évite un mal plus grand.", "En"),
        words=["En", "agissant", "maintenant", "on", "évite", "un", "mal", "plus", "grand", "."],
        anagram=("lentement", "Pas trop vite : on avance…"),
        error=(
            "En agissant maintenant on évite un mal vraiment plus grands.",
            "En agissant maintenant on évite un mal vraiment plus grand.",
            "Mal est masculin singulier : grand.",
        ),
        pic_start=5,
        pic_words=["un débat", "un adverbe", "une intensité", "un projet"],
        short_p="Notez deux gérondifs, un participe présent et trois adverbes d'intensité.",
        audio="Enregistrez : En agissant maintenant. Étant trop pressés. La rive est particulièrement fragile.",
    ),
    _l(
        "CE",
        "CE — Notes de débat",
        "Lire des notes de solutions avec participe présent, -ment et intensité.",
        "Lisez les notes, sans aller trop vite.",
        "Feuille de Marc Nkurunziza",
        """Débat du mardi — solutions pour la rive
1. En retirant le plastique, on libère vraiment le courant.
2. Étant trop nombreux le même soir, on piétine les racines.
3. En arrosant lentement, le compost reste assez humide.
4. Une équipe agissant calmement convainc plus qu'une équipe criant.
5. La pente est extrêmement glissante après la pluie.
6. En parlant clairement, on évite les rumeurs du marché.
7. Trop de seaux vides fatiguent ; assez de relais suffit.
8. Joël : en triant particulièrement les épluchures, on aide Félicie.
9. Lila : Radio Figuier répétera attentivement les horaires.
10. Solange : le Bureau lira le débat en restant prudent.
11. Rose : en nuançant, on n'abandonne pas, on ajuste.
12. Aline : extrêmement utile, ce cercle, s'il reste humain.""",
        tf_item=(
            "Marc écrit qu'être trop nombreux le même soir piétine les racines.",
            True,
            "Point 2 : « Étant trop nombreux… on piétine les racines. »",
        ),
        qcm_item=(
            "Comment le compost reste-t-il assez humide ?",
            [
                "En criant plus fort",
                "En arrosant lentement",
                "En fermant la rive",
                "En courant extrêmement vite",
            ],
            1,
            "« En arrosant lentement. »",
        ),
        pairs=[
            ("en retirant", "le plastique"),
            ("étant trop nombreux", "piétiner"),
            ("extrêmement", "glissante"),
            ("assez", "de relais"),
        ],
        fill_item=("La pente est ___ glissante après la pluie.", "extrêmement"),
        words=["En", "parlant", "clairement", "on", "évite", "les", "rumeurs", "."],
        anagram=("vraiment", "Adverbe d'intensité : le courant est… libre."),
        error=(
            "En arrosant lentement le compost reste assez humides.",
            "En arrosant lentement le compost reste assez humide.",
            "Compost est masculin singulier : humide.",
        ),
        pic_start=6,
        pic_words=["un adverbe", "une intensité", "un projet", "un but"],
        short_p="Soulignez les -ment et classez-les : manière ou intensité.",
        audio="Lisez les douze notes, sans aller trop vite.",
    ),
    _l(
        "PO",
        "PO — Dire en agissant, trop, vraiment",
        "Débattre : gérondif, participe présent, adverbes en -ment, intensité.",
        "Répétez, puis proposez une solution pour la cour.",
        "Modèles de Léa",
        """En agissant tôt, on voit la rive.
Étant patients, nous avançons.
On parle calmement.
On avance lentement.
C'est vraiment utile.
C'est particulièrement fragile.
C'est extrêmement sale après l'orage.
Assez de seaux, pas trop de bruit.
En écoutant, on nuance.
Une voix criant trop fort fatigue.
En compostant ici, on aide Félicie.
On explique clairement le relais.""",
        tf_item=(
            "« En agissant » est un gérondif (en + participe présent).",
            True,
            "En + agissant.",
        ),
        qcm_item=(
            "Quelle phrase marque une intensité trop forte ?",
            [
                "On avance lentement",
                "C'est extrêmement sale",
                "Assez de seaux",
                "On parle calmement",
            ],
            1,
            "Extrêmement = intensité très haute.",
        ),
        pairs=[
            ("en + participe", "gérondif"),
            ("étant patients", "cause"),
            ("-ment", "adverbe"),
            ("trop / assez", "intensité"),
        ],
        fill_item=("C'est ___ fragile près des racines.", "particulièrement"),
        words=["En", "compostant", "ici", "on", "aide", "Félicie", "."],
        anagram=("agissant", "Gérondif : en… tôt, on voit la rive."),
        error=(
            "Étant trop pressés on avance extrêmement lentes.",
            "Étant trop pressés on avance extrêmement lentement.",
            "Adverbe : lentement, pas lentes.",
        ),
        pic_start=7,
        pic_words=["une intensité", "un projet", "un but", "une banderole"],
        short_p="Écrivez six phrases : deux en + participe, deux -ment, deux intensités.",
        audio="Enregistrez les modèles, puis un tour de débat à vous.",
    ),
    _l(
        "PE",
        "PE — Mon tour de débat",
        "Écrire un tour de débat avec gérondif, -ment et intensité.",
        "Imitez le tour de Joël, sans aller trop vite.",
        "Tour de Joël Mugisha",
        """Joël Mugisha
En agissant ce soir, on soulage vraiment la rive.
Étant trop nombreux, nous piétinerions les racines.
Je parle calmement : assez de seaux, pas trop de discours.
La pente est particulièrement glissante.
En triant les épluchures, on aide extrêmement Félicie.
Une équipe agissant lentement convainc mieux.
Joël
Rive du Seuil
Cahier des racines — débat du mardi""",
        tf_item=(
            "Joël veut trop de discours et peu de seaux.",
            False,
            "« assez de seaux, pas trop de discours. »",
        ),
        qcm_item=(
            "Qui Joël dit-il aider extrêmement ?",
            ["Solange", "Félicie", "Karim", "Lila"],
            1,
            "« on aide extrêmement Félicie. »",
        ),
        pairs=[
            ("en agissant", "ce soir"),
            ("calmement", "manière"),
            ("particulièrement", "glissante"),
            ("lentement", "convaincre"),
        ],
        fill_item=("Je parle ___ : assez de seaux.", "calmement"),
        words=["En", "triant", "les", "épluchures", "on", "aide", "Félicie", "."],
        anagram=("extremement", "Très très : on aide… Félicie. (sans accent)"),
        error=(
            "En agissant ce soir on soulage vraiment les rives trop vite.",
            "En agissant ce soir on soulage vraiment la rive trop vite.",
            "Ici : la rive, singulier, le lieu du débat.",
        ),
        pic_start=8,
        pic_words=["un projet", "un but", "une banderole", "un seau"],
        short_p="Imitez : dix lignes, deux gérondifs, deux -ment, une intensité.",
        audio="Lisez votre tour de débat, sans aller trop vite.",
    ),
    _l(
        "EL",
        "EL — Participe présent, -ment, intensité",
        "Retenir en agissant / étant, les adverbes en -ment et l'intensité.",
        "Apprenez la fiche.",
        "Fiche d'Aline",
        """Participe présent : agissant, étant, parlant, triant (invariable).
Gérondif = en + participe : en agissant, en écoutant (moyen, simultanéité).
Participe seul : étant trop pressés, nous piétinons (cause).
Adjectif verbal : une équipe agissant trop vite (qui agit).
Adverbes en -ment : lent / lente → lentement ; clair → clairement.
-ent → -emment : récent → récemment. -ant → -amment : constant → constamment.
Intensité : assez (suffisant) / trop (excessif) / vraiment / particulièrement / extrêmement.
Place : trop vite, assez humide, vraiment utile, particulièrement fragile.
Ne pas dire : en agissant de (le de est de trop).
Ne pas dire : extrêmement lentes pour un verbe (il faut l'adverbe).
Assez de + nom / assez + adjectif.
Trop de + nom / trop + adjectif / trop + adverbe.""",
        tf_item=(
            "Le gérondif se forme avec en + participe présent.",
            True,
            "En agissant.",
        ),
        qcm_item=(
            "« Récent » donne quel adverbe ?",
            ["récemment", "récentment", "récemmant", "récentemment"],
            0,
            "-ent → -emment : récemment.",
        ),
        pairs=[
            ("en agissant", "gérondif"),
            ("étant trop pressés", "cause"),
            ("clairement", "manière"),
            ("trop / assez", "dose"),
        ],
        fill_item=("On avance ___ pour protéger les racines.", "lentement"),
        words=["Étant", "patients", "nous", "avançons", "."],
        anagram=("clairement", "Adverbe de clair : parler… pour éviter les rumeurs."),
        error=(
            "En agissant de maintenant on avance trop vite.",
            "En agissant maintenant on avance trop vite.",
            "Gérondif : en + participe, sans de.",
        ),
        pic_start=9,
        pic_words=["un but", "une banderole", "un seau", "un geste"],
        short_p="Transformez : agit → en agissant ; clair → adverbe ; trop / assez + trois noms.",
        audio="Enregistrez la fiche et quatre exemples.",
    ),
]


# ---------------------------------------------------------------------------
# Séquence 3 — Un projet pour la rive
# ---------------------------------------------------------------------------

S3 = [
    _l(
        "CO",
        "CO — Présenter le projet rive",
        "Comprendre un projet local et le but : pour, afin de, pour que, afin que.",
        "Lisez la présentation. Quel but ? Qui doit agir ?",
        "Cour du Seuil, banderole ocre",
        """Patrick : Nous présentons un projet pour la rive du figuier.
Léa : On plante pour retenir la terre, afin de calmer l'eau.
Marc : Je parle fort pour que les enfants entendent le plan.
Hawa : On range les seaux afin que Félicie trouve tout le matin.
Joël : Venez signer pour que Solange lise le Cahier des racines.
Rose : On incite les voisins à relayer, pas à crier.
Aline : Un projet local : compost, sacs, horaires, rien de plus.
Karim : Afin de convaincre le Bureau, on reste précis.
Lila : Radio Figuier répète pour que personne n'arrive trop tard.
Dieudonné : Je couds des sacs pour porter sans déchirer.
Félicie : Venez tôt afin de préparer la Table des Sources.
Solange : J'écoute pour que le Bureau des Escales tranche juste.""",
        tf_item=(
            "Léa plante pour retenir la terre, afin de calmer l'eau.",
            True,
            "Léa : « pour retenir la terre, afin de calmer l'eau. »",
        ),
        qcm_item=(
            "Pourquoi Marc parle-t-il fort ?",
            [
                "Pour fermer la rive",
                "Pour que les enfants entendent le plan",
                "Afin de vendre des sacs",
                "Pour que Radio Figuier s'arrête",
            ],
            1,
            "« pour que les enfants entendent. »",
        ),
        pairs=[
            ("pour + infinitif", "même sujet"),
            ("afin de + infinitif", "même sujet, plus soigné"),
            ("pour que + subj.", "autre sujet"),
            ("afin que + subj.", "autre sujet, soigné"),
        ],
        fill_item=("On range les seaux afin ___ Félicie trouve tout.", "que"),
        words=["On", "plante", "pour", "retenir", "la", "terre", "."],
        anagram=("projet", "Un plan local pour la rive, présenté sous le figuier."),
        error=(
            "Je parle fort pour que les enfants entendre le plan.",
            "Je parle fort pour que les enfants entendent le plan.",
            "Pour que + subjonctif : entendent.",
        ),
        pic_start=10,
        pic_words=["une banderole", "un seau", "un geste", "une persuasion"],
        short_p="Classez quatre buts : infinitif ou subjonctif, et qui est le sujet.",
        audio="Enregistrez : On plante pour retenir. Afin de calmer l'eau. Pour que les enfants entendent.",
    ),
    _l(
        "CE",
        "CE — Affiche du projet local",
        "Lire une affiche qui présente et incite, avec pour / afin de / pour que / afin que.",
        "Lisez l'affiche, sans aller trop vite.",
        "Affiche épinglée au figuier",
        """Projet « Rive du Seuil » — appel
Nous agissons pour protéger le figuier et la petite rivière.
Venez le jeudi afin de voir le plan, les seaux, les sacs.
Signez pour que Solange porte le dossier au Bureau des Escales.
Laissez un relais afin que personne ne reste seul le soir.
On incite : parlez à un voisin, pas à toute la rue d'un coup.
Patrick coordonne pour tenir le rythme.
Léa note afin de garder les heures justes.
Marc filme pour que Radio Figuier montre le geste, pas le bruit.
Hawa prépare l'eau afin que le compost ne sèche pas.
Dieudonné tend les sacs pour porter sans perdre.
Félicie ouvre la table afin que chacun signe au calme.
Rose : un projet local, assez clair, pas trop large.""",
        tf_item=(
            "L'affiche demande de parler à toute la rue d'un coup.",
            False,
            "« parlez à un voisin, pas à toute la rue d'un coup. »",
        ),
        qcm_item=(
            "Pourquoi signer, d'après l'affiche ?",
            [
                "Pour fermer le compost",
                "Pour que Solange porte le dossier au Bureau",
                "Afin de vendre le figuier",
                "Pour que Félicie parte",
            ],
            1,
            "« pour que Solange porte le dossier. »",
        ),
        pairs=[
            ("pour protéger", "figuier et rivière"),
            ("afin de voir", "le plan"),
            ("pour que Solange porte", "le dossier"),
            ("afin que personne ne reste", "seul"),
        ],
        fill_item=("Signez pour ___ Solange porte le dossier.", "que"),
        words=["Venez", "le", "jeudi", "afin", "de", "voir", "le", "plan", "."],
        anagram=("inciter", "Pousser un voisin à venir : on… sans crier."),
        error=(
            "Signez pour que Solange porte le dossier afin de que le Bureau lise.",
            "Signez pour que Solange porte le dossier afin que le Bureau lise.",
            "Afin que + subjonctif, pas afin de que.",
        ),
        pic_start=11,
        pic_words=["un seau", "un geste", "une persuasion", "un compost"],
        short_p="Recopiez l'affiche et encadrez pour, afin de, pour que, afin que.",
        audio="Lisez l'affiche du projet, sans aller trop vite.",
    ),
    _l(
        "PO",
        "PO — Dire le but",
        "Présenter un projet et inciter : infinitif et subjonctif de but.",
        "Répétez, puis présentez un geste pour la rive.",
        "Modèles de Karim",
        """On agit pour protéger la rive.
On vient afin de voir le plan.
Je parle pour que tu entendes.
Nous rangeons afin que Félicie trouve.
Signez pour que Solange lise.
Incitez un voisin à relayer.
On filme pour montrer le geste.
On note afin de garder l'heure.
Je couds pour que les sacs tiennent.
On ouvre tôt afin que chacun signe.
N'élargissez pas trop le projet.
Restez locaux, assez clairs.""",
        tf_item=(
            "Pour que et afin que demandent le subjonctif.",
            True,
            "Pour que tu entendes / afin que Félicie trouve.",
        ),
        qcm_item=(
            "Même sujet : quelle construction ?",
            [
                "pour que + infinitif",
                "pour + infinitif",
                "afin que + infinitif",
                "pour de + subjonctif",
            ],
            1,
            "Même sujet : pour / afin de + infinitif.",
        ),
        pairs=[
            ("pour + infinitif", "même sujet"),
            ("afin de", "même sujet, soigné"),
            ("pour que", "autre sujet"),
            ("afin que", "autre sujet, soigné"),
        ],
        fill_item=("Je parle pour que tu ___. (entendre)", "entendes"),
        words=["On", "agit", "pour", "protéger", "la", "rive", "."],
        anagram=("afin", "Plus soigné que pour : … de voir le plan."),
        error=(
            "On vient afin que voir le plan sous le figuier.",
            "On vient afin de voir le plan sous le figuier.",
            "Même sujet : afin de + infinitif.",
        ),
        pic_start=12,
        pic_words=["un geste", "une persuasion", "un compost", "un arbre"],
        short_p="Écrivez six buts : deux pour, deux afin de, un pour que, un afin que.",
        audio="Enregistrez les modèles, puis un appel à un voisin.",
    ),
    _l(
        "PE",
        "PE — Mon projet local",
        "Écrire la présentation d'un projet et inciter à rejoindre.",
        "Imitez le projet de Hawa, sans aller trop vite.",
        "Projet de Hawa Diallo",
        """Hawa Diallo
Nous présentons un projet pour la rive du Seuil.
On plante pour retenir la terre afin de calmer l'eau.
Venez jeudi pour que Solange voie les signatures.
On range les seaux afin que Félicie trouve tout.
J'incite un voisin à relayer, pas à crier.
Marc filme pour que Radio Figuier montre le geste.
Hawa
Rive du figuier — Rukiri-Nord
Cahier des racines
Projet local : assez clair, pas trop large.""",
        tf_item=(
            "Hawa incite à crier dans la rue.",
            False,
            "« à relayer, pas à crier. »",
        ),
        qcm_item=(
            "Quand Hawa invite-t-elle à venir ?",
            ["Lundi", "Jeudi", "Dimanche", "À minuit"],
            1,
            "« Venez jeudi. »",
        ),
        pairs=[
            ("pour retenir", "la terre"),
            ("afin de calmer", "l'eau"),
            ("pour que Solange voie", "signatures"),
            ("afin que Félicie trouve", "les seaux"),
        ],
        fill_item=("Venez jeudi pour que Solange ___ les signatures.", "voie"),
        words=["J'incite", "un", "voisin", "à", "relayer", "."],
        anagram=("retenir", "On plante pour… la terre sur la pente."),
        error=(
            "Venez jeudi pour que Solange vois les signatures.",
            "Venez jeudi pour que Solange voie les signatures.",
            "Subjonctif de voir : qu'elle voie.",
        ),
        pic_start=13,
        pic_words=["une persuasion", "un compost", "un arbre", "un impact"],
        short_p="Imitez : un projet de dix lignes, deux infinitifs de but, deux subjonctifs.",
        audio="Lisez votre projet, sans aller trop vite.",
    ),
    _l(
        "EL",
        "EL — Infinitif et subjonctif de but",
        "Retenir pour, afin de, pour que, afin que.",
        "Apprenez la fiche.",
        "Fiche du projet",
        """Même sujet → infinitif :
pour + infinitif : on plante pour retenir.
afin de + infinitif : on vient afin de voir (plus soigné).
Sujet différent → subjonctif :
pour que + subjonctif : je parle pour que tu entendes.
afin que + subjonctif : on range afin qu'elle trouve.
Subjonctif utile : que je sois, que tu entendes, qu'il lise, que nous tenions,
que vous voyiez, qu'elles portent, qu'il accepte, qu'elle voie.
Incitement : venez, signez, parlez à un voisin, n'élargissez pas trop.
Ne pas dire : afin de que. On dit afin que.
Ne pas dire : pour que + infinitif (pour que entendre).
Ne pas dire : pour de protéger.
Après pour que / afin que : ne… pas se place autour du verbe.""",
        tf_item=(
            "On écrit « afin de que le Bureau lise ».",
            False,
            "Afin que, pas afin de que.",
        ),
        qcm_item=(
            "« Je filme ___ Radio Figuier montre le geste. »",
            ["pour", "afin de", "pour que", "pour de"],
            2,
            "Sujet différent : pour que + subjonctif.",
        ),
        pairs=[
            ("pour / afin de", "infinitif"),
            ("pour que / afin que", "subjonctif"),
            ("même sujet", "infinitif"),
            ("autre sujet", "subjonctif"),
        ],
        fill_item=("On range afin ___ elle trouve les seaux.", "qu'"),
        words=["Signez", "pour", "que", "Solange", "lise", "."],
        anagram=("accepte", "Subjonctif : pour que le Bureau… le dossier."),
        error=(
            "Je parle pour que tu entendre le plan de la rive.",
            "Je parle pour que tu entendes le plan de la rive.",
            "Pour que + subjonctif : entendes.",
        ),
        pic_start=14,
        pic_words=["un compost", "un arbre", "un impact", "un graphique"],
        short_p="Transformez six buts : trois même sujet, trois sujet différent.",
        audio="Enregistrez la fiche et six exemples.",
    ),
]


# ---------------------------------------------------------------------------
# Séquence 4 — Persuader d'agir
# ---------------------------------------------------------------------------

S4 = [
    _l(
        "CO",
        "CO — Persuader près du compost",
        "Comprendre des éco-gestes et la persuasion : tu pourrais, si on, il vaudrait mieux.",
        "Lisez le dialogue. Qui persuade ? Quel geste ?",
        "Compost de la cour, seaux alignés",
        """Joël : Tu pourrais apporter tes épluchures ici, pas plus loin.
Patrick : Si on commençait petit, le tas resterait propre.
Aline : Il vaudrait mieux rincer les seaux le soir.
Léa : Tu pourrais prévenir Rose avant de trop charger.
Marc : Si on filmait le geste, Radio Figuier relayerait sans crier.
Hawa : Il vaudrait mieux laisser l'eau à la rive, pas au chemin.
Rose : Tu pourrais signer d'abord, discuter ensuite.
Karim : Si on évitait le feu près de l'eau, Félicie serait plus calme.
Lila : Il vaudrait mieux répéter l'heure deux fois, assez lentement.
Dieudonné : Tu pourrais plier le sac plutôt que le jeter.
Félicie : Si on rangeait tôt, la Table des Sources resterait libre.
Solange : Il vaudrait mieux un dossier court pour le Bureau.""",
        tf_item=(
            "Aline conseille de rincer les seaux le soir.",
            True,
            "Aline : « Il vaudrait mieux rincer les seaux le soir. »",
        ),
        qcm_item=(
            "Que propose Patrick pour le tas ?",
            [
                "Tout brûler d'un coup",
                "Commencer petit",
                "Fermer le compost",
                "Partir à Val-des-Peupliers",
            ],
            1,
            "« Si on commençait petit. »",
        ),
        pairs=[
            ("tu pourrais", "suggestion douce"),
            ("si on + imparfait", "hypothèse / invitation"),
            ("il vaudrait mieux", "conseil plus fort"),
            ("épluchures ici", "éco-geste"),
        ],
        fill_item=("Il ___ mieux rincer les seaux le soir.", "vaudrait"),
        words=["Tu", "pourrais", "apporter", "tes", "épluchures", "ici", "."],
        anagram=("pourrais", "Suggestion à tu : tu… apporter un seau."),
        error=(
            "Il vaudrait mieux de rincer les seaux le soir.",
            "Il vaudrait mieux rincer les seaux le soir.",
            "Il vaudrait mieux + infinitif, sans de.",
        ),
        pic_start=15,
        pic_words=["un arbre", "un impact", "un graphique", "une hausse"],
        short_p="Notez trois éco-gestes et la formule de persuasion de chacun.",
        audio="Enregistrez : Tu pourrais apporter tes épluchures. Si on commençait petit. Il vaudrait mieux rincer.",
    ),
    _l(
        "CE",
        "CE — Feuille des éco-gestes",
        "Lire une feuille qui persuade d'agir par petits gestes.",
        "Lisez la feuille, sans aller trop vite.",
        "Feuille de Joël, compost de la cour",
        """Éco-gestes du Seuil — pour persuader sans crier
1. Tu pourrais trier les épluchures avant le marché.
2. Si on fermait bien le couvercle, les bêtes viendraient moins.
3. Il vaudrait mieux porter un seau à deux que trop charger.
4. Tu pourrais rincer, puis poser le seau à l'ombre du figuier.
5. Si on évitait le plastique près de l'eau, la rive respirerait.
6. Il vaudrait mieux prévenir Félicie avant un grand tas.
7. Tu pourrais signer le Cahier des racines d'une ligne claire.
8. Si on répétait l'heure à Radio Figuier, moins de monde arriverait trop tard.
9. Il vaudrait mieux un geste tenu qu'un discours extrêmement long.
10. Rose : tu pourrais relayer à un seul voisin, assez.
11. Karim : si on notait les seaux, aucun ne se perdrait.
12. Solange : il vaudrait mieux joindre deux pages, pas vingt.""",
        tf_item=(
            "La feuille recommande un discours extrêmement long.",
            False,
            "Point 9 : « un geste tenu qu'un discours extrêmement long. »",
        ),
        qcm_item=(
            "Que se passe-t-il si on ferme bien le couvercle ?",
            [
                "Les bêtes viennent plus",
                "Les bêtes viennent moins",
                "Le figuier tombe",
                "Le Bureau ferme",
            ],
            1,
            "« les bêtes viendraient moins. »",
        ),
        pairs=[
            ("tu pourrais trier", "épluchures"),
            ("si on fermait", "couvercle"),
            ("il vaudrait mieux porter", "à deux"),
            ("si on notait", "les seaux"),
        ],
        fill_item=("___ on fermait bien le couvercle, les bêtes viendraient moins.", "Si"),
        words=["Il", "vaudrait", "mieux", "prévenir", "Félicie", "."],
        anagram=("couvercle", "On le ferme bien pour que les bêtes viennent moins."),
        error=(
            "Si on fermera bien le couvercle les bêtes viendraient moins.",
            "Si on fermait bien le couvercle les bêtes viendraient moins.",
            "Si + imparfait pour une suggestion.",
        ),
        pic_start=16,
        pic_words=["un impact", "un graphique", "une hausse", "une loupe"],
        short_p="Recopiez six gestes et indiquez la formule : tu pourrais / si on / il vaudrait mieux.",
        audio="Lisez la feuille des éco-gestes, sans aller trop vite.",
    ),
    _l(
        "PO",
        "PO — Persuader sans crier",
        "Persuader : tu pourrais, si on, il vaudrait mieux.",
        "Répétez, puis persuadez un voisin d'un éco-geste.",
        "Modèles de Rose",
        """Tu pourrais apporter un seau.
Tu pourrais signer ici.
Si on commençait petit…
Si on évitait le feu près de l'eau…
Il vaudrait mieux rincer le soir.
Il vaudrait mieux un dossier court.
Tu pourrais prévenir Aline.
Si on rangeait tôt, la table resterait libre.
Il vaudrait mieux porter à deux.
N'obligez pas : persuadez.
Assez d'un geste tenu.
Pas trop de discours.""",
        tf_item=(
            "« Il vaudrait mieux » est un conseil au conditionnel.",
            True,
            "Conditionnel de valoir + infinitif.",
        ),
        qcm_item=(
            "Quelle phrase est une suggestion à tu ?",
            [
                "Il vaudrait mieux rincer",
                "Tu pourrais apporter un seau",
                "Si on commençait petit",
                "Signez tous maintenant",
            ],
            1,
            "Tu pourrais + infinitif.",
        ),
        pairs=[
            ("tu pourrais", "tu"),
            ("si on + imparfait", "groupe"),
            ("il vaudrait mieux", "conseil"),
            ("persuader", "sans obliger"),
        ],
        fill_item=("Tu ___ apporter un seau.", "pourrais"),
        words=["Si", "on", "commençait", "petit", "le", "tas", "resterait", "propre", "."],
        anagram=("vaudrait", "Il… mieux rincer : conseil au conditionnel."),
        error=(
            "Tu pourrais d'apporter un seau près du compost.",
            "Tu pourrais apporter un seau près du compost.",
            "Pouvoir + infinitif, sans de.",
        ),
        pic_start=17,
        pic_words=["un graphique", "une hausse", "une loupe", "un bureau"],
        short_p="Écrivez six persuasions : deux de chaque formule.",
        audio="Enregistrez les modèles, puis deux phrases à un voisin.",
    ),
    _l(
        "PE",
        "PE — Mon mot pour persuader",
        "Écrire un mot qui persuade d'un éco-geste.",
        "Imitez le mot de Dieudonné, sans aller trop vite.",
        "Mot de Dieudonné Hakizimana",
        """Dieudonné Hakizimana
Tu pourrais plier le sac plutôt que le jeter.
Si on commençait par trois sacs, l'atelier suivrait.
Il vaudrait mieux coudre un fond solide.
Tu pourrais prévenir Joël avant un grand tas.
Si on évitait le plastique près de l'eau, la rive respirerait.
Il vaudrait mieux un geste tenu qu'un discours trop long.
Dieudonné
Atelier du Tissu — Seuil des Sources
Cahier des racines""",
        tf_item=(
            "Dieudonné propose de commencer par trois sacs.",
            True,
            "« Si on commençait par trois sacs. »",
        ),
        qcm_item=(
            "Que vaudrait-il mieux coudre ?",
            ["Un drapeau de ville", "Un fond solide", "Une cravate", "Un rideau de scène"],
            1,
            "« un fond solide. »",
        ),
        pairs=[
            ("tu pourrais plier", "le sac"),
            ("si on commençait", "trois sacs"),
            ("il vaudrait mieux coudre", "fond solide"),
            ("si on évitait", "le plastique"),
        ],
        fill_item=("Il vaudrait ___ coudre un fond solide.", "mieux"),
        words=["Tu", "pourrais", "plier", "le", "sac", "."],
        anagram=("plier", "Le contraire de jeter le sac : le… d'abord."),
        error=(
            "Si on commencera par trois sacs l'atelier suivrait.",
            "Si on commençait par trois sacs l'atelier suivrait.",
            "Si + imparfait, pas le futur.",
        ),
        pic_start=18,
        pic_words=["une hausse", "une loupe", "un bureau", "une lettre"],
        short_p="Imitez : dix lignes, les trois formules de persuasion, deux éco-gestes.",
        audio="Lisez votre mot, sans aller trop vite.",
    ),
    _l(
        "EL",
        "EL — Persuader : tu pourrais, si on, il vaudrait mieux",
        "Retenir les formes pour persuader d'un geste.",
        "Apprenez la fiche.",
        "Fiche de persuasion",
        """Tu pourrais + infinitif : suggestion douce à une personne.
Vous pourriez + infinitif : même idée, vouvoiement.
Si on + imparfait, + conditionnel : invitation collective.
Si on commençait petit, le tas resterait propre.
Il vaudrait mieux + infinitif : conseil plus net (sans de).
Il vaudrait mieux que + subjonctif : autre sujet (il vaudrait mieux qu'elle lise).
Éco-gestes du Seuil : trier, rincer, porter à deux, fermer le couvercle,
éviter le plastique près de l'eau, plier un sac, signer une ligne.
Persuader ≠ ordonner : assez d'un geste, pas trop de discours.
Ne pas dire : tu pourrais de + infinitif.
Ne pas dire : il vaudrait mieux de + infinitif.
Ne pas dire : si on + futur pour cette suggestion.""",
        tf_item=(
            "On dit « il vaudrait mieux de rincer ».",
            False,
            "Sans de : il vaudrait mieux rincer.",
        ),
        qcm_item=(
            "Quelle phrase invite le groupe ?",
            [
                "Tu pourrais signer",
                "Si on rangeait tôt",
                "Il faut que tu signes tout de suite",
                "Signez ou partez",
            ],
            1,
            "Si on + imparfait.",
        ),
        pairs=[
            ("tu pourrais", "suggestion"),
            ("si on + imparfait", "invitation"),
            ("il vaudrait mieux", "conseil"),
            ("éco-geste", "petit acte"),
        ],
        fill_item=("Si on ___ petit, le tas resterait propre. (commencer)", "commençait"),
        words=["Il", "vaudrait", "mieux", "un", "dossier", "court", "."],
        anagram=("rincer", "Il vaudrait mieux… les seaux le soir."),
        error=(
            "Vous pourriez de prévenir Aline avant le grand tas.",
            "Vous pourriez prévenir Aline avant le grand tas.",
            "Pourriez + infinitif, sans de.",
        ),
        pic_start=19,
        pic_words=["une loupe", "un bureau", "une lettre", "un tampon"],
        short_p="Écrivez un mini-dialogue de persuasion (huit répliques, trois formules).",
        audio="Enregistrez la fiche et trois persuasions à vous.",
    ),
]


# ---------------------------------------------------------------------------
# Séquence 5 — Mesurer l'impact
# ---------------------------------------------------------------------------

S5 = [
    _l(
        "CO",
        "CO — Chiffres sous le figuier",
        "Comprendre des chiffres inventés et de plus en plus / de moins en moins.",
        "Lisez le dialogue. Qu'est-ce qui augmente ? Qu'est-ce qui diminue ?",
        "Micro de Radio Figuier, ombre du figuier",
        """Lila : Cette semaine : 12 seaux, 3 sacs de compost, 18 signatures.
Marc : La rive est de plus en plus claire, de moins en moins d'odeurs.
Patrick : On a de plus en plus de relais le matin : 4 puis 7.
Léa : De moins en moins de plastique près des racines : 20 morceaux, puis 9.
Joël : Le tas pèse de plus en plus : 8 kilos, puis 14.
Hawa : On met de moins en moins d'eau : 6 cruches, puis 4.
Rose : Les enfants viennent de plus en plus tôt : 5, puis 11.
Karim : Le Bureau lit de plus en plus vite nos pages courtes.
Aline : De moins en moins de disputes : 3 la première semaine, 1 ensuite.
Félicie : La table reste de plus en plus libre après le tri.
Dieudonné : 6 sacs tenus, 2 réparés : de moins en moins de pertes.
Solange : 18 noms, ce n'est pas 80 : assez pour commencer.""",
        tf_item=(
            "Léa dit qu'il y a de moins en moins de plastique près des racines.",
            True,
            "Léa : 20 morceaux, puis 9.",
        ),
        qcm_item=(
            "Combien de signatures Lila annonce-t-elle ?",
            ["12", "3", "18", "80"],
            2,
            "« 18 signatures. »",
        ),
        pairs=[
            ("de plus en plus claire", "la rive"),
            ("de moins en moins de plastique", "racines"),
            ("12 seaux", "cette semaine"),
            ("18 signatures", "assez pour commencer"),
        ],
        fill_item=("La rive est de ___ en plus claire.", "plus"),
        words=["On", "a", "de", "plus", "en", "plus", "de", "relais", "."],
        anagram=("chiffres", "12 seaux et 18 signatures : des… inventés pour le Seuil."),
        error=(
            "La rive est de plus en plus de claire après le tri.",
            "La rive est de plus en plus claire après le tri.",
            "De plus en plus + adjectif, sans de.",
        ),
        pic_start=20,
        pic_words=["un bureau", "une lettre", "un tampon", "une signature"],
        short_p="Relevez quatre chiffres et deux évolutions (plus / moins).",
        audio="Enregistrez : 12 seaux, 18 signatures. De plus en plus claire. De moins en moins de plastique.",
    ),
    _l(
        "CE",
        "CE — Graphique de la rivière",
        "Lire un relevé chiffré inventé avec de plus en plus / de moins en moins.",
        "Lisez le relevé, sans aller trop vite.",
        "Relevé de Lila Sow",
        """Impact — rivière du Seuil (chiffres du Cahier des racines)
Semaine 1 : 20 plastiques, 8 kilos de compost, 5 relais, 9 signatures.
Semaine 2 : 9 plastiques, 14 kilos, 7 relais, 18 signatures.
La rive devient de plus en plus claire.
On trouve de moins en moins de plastique près du figuier.
Le tas est de plus en plus lourd, de moins en moins d'eau versée (6 puis 4).
Les relais du matin sont de plus en plus nombreux.
Les disputes sont de moins en moins longues : 3 puis 1.
Radio Figuier répète : assez de preuves, pas trop de discours.
Karim : 2 pages lues, le Bureau avance de plus en plus.
Félicie : de moins en moins de seaux oubliés sous la table.
Dieudonné : 6 sacs tenus, de plus en plus solides.
Solange : 18 noms suffisent pour un premier tampon.""",
        tf_item=(
            "En semaine 2, il y a 18 signatures.",
            True,
            "Semaine 2 : 18 signatures.",
        ),
        qcm_item=(
            "Que deviennent les disputes ?",
            [
                "De plus en plus longues",
                "De moins en moins longues",
                "Elles disparaissent à zéro",
                "Elles passent à 80",
            ],
            1,
            "« de moins en moins longues : 3 puis 1. »",
        ),
        pairs=[
            ("20 puis 9", "plastiques"),
            ("8 puis 14", "kilos"),
            ("5 puis 7", "relais"),
            ("9 puis 18", "signatures"),
        ],
        fill_item=("On trouve de moins en ___ de plastique.", "moins"),
        words=["Les", "relais", "sont", "de", "plus", "en", "plus", "nombreux", "."],
        anagram=("graphique", "Le relevé de Lila : un… de la rivière, avec des chiffres."),
        error=(
            "On trouve de moins en moins plastique près du figuier.",
            "On trouve de moins en moins de plastique près du figuier.",
            "De moins en moins de + nom.",
        ),
        pic_start=21,
        pic_words=["une lettre", "un tampon", "une signature", "une rivière"],
        short_p="Dessinez le relevé en cinq phrases : deux hausses, deux baisses, un chiffre.",
        audio="Lisez le relevé de Lila, sans aller trop vite.",
    ),
    _l(
        "PO",
        "PO — Dire l'évolution",
        "Mesurer l'impact à voix haute : chiffres, de plus en plus, de moins en moins.",
        "Répétez, puis commentez deux chiffres du Seuil.",
        "Modèles de Marc",
        """Il y a 12 seaux.
Il y a 18 signatures.
La rive est de plus en plus claire.
On a de plus en plus de relais.
Le plastique est de moins en moins visible.
On met de moins en moins d'eau.
Les disputes sont de moins en moins longues.
Le tas est de plus en plus lourd.
Assez de preuves.
Pas trop de discours.
6 sacs tenus.
2 pages lues.""",
        tf_item=(
            "De plus en plus de + nom : la quantité augmente.",
            True,
            "De plus en plus de relais.",
        ),
        qcm_item=(
            "Quelle phrase décrit une baisse ?",
            [
                "De plus en plus de relais",
                "De moins en moins d'eau",
                "18 signatures",
                "Le tas est de plus en plus lourd",
            ],
            1,
            "De moins en moins d'eau.",
        ),
        pairs=[
            ("de plus en plus + adj.", "qualité qui monte"),
            ("de plus en plus de + nom", "quantité qui monte"),
            ("de moins en moins + adj.", "qualité qui baisse"),
            ("de moins en moins de + nom", "quantité qui baisse"),
        ],
        fill_item=("On a de plus en plus ___ relais.", "de"),
        words=["La", "rive", "est", "de", "plus", "en", "plus", "claire", "."],
        anagram=("relais", "De plus en plus de… le matin : 4 puis 7."),
        error=(
            "On a de plus en plus relais le matin sous le figuier.",
            "On a de plus en plus de relais le matin sous le figuier.",
            "De plus en plus de + nom.",
        ),
        pic_start=22,
        pic_words=["un tampon", "une signature", "une rivière", "un figuier"],
        short_p="Écrivez six mesures : trois hausses, trois baisses, avec au moins un chiffre.",
        audio="Enregistrez les modèles, puis deux phrases chiffrées à vous.",
    ),
    _l(
        "PE",
        "PE — Mon relevé d'impact",
        "Écrire un relevé avec des chiffres inventés et des évolutions.",
        "Imitez le relevé de Rose, sans aller trop vite.",
        "Relevé de Rose Iradukunda",
        """Rose Iradukunda
Semaine 1 : 20 plastiques, 5 relais, 9 signatures.
Semaine 2 : 9 plastiques, 7 relais, 18 signatures.
La rive est de plus en plus claire.
On trouve de moins en moins de plastique.
Les relais sont de plus en plus nombreux.
Les disputes sont de moins en moins longues.
Assez de preuves pour le Bureau, pas trop de discours.
Rose
Cahier des racines
Seuil des Sources — Rukiri-Nord""",
        tf_item=(
            "Rose passe de 9 à 18 signatures.",
            True,
            "Semaine 1 : 9. Semaine 2 : 18.",
        ),
        qcm_item=(
            "Que dit Rose des discours ?",
            [
                "Il en faut extrêmement",
                "Pas trop de discours",
                "Plus de discours que de preuves",
                "Aucun discours jamais",
            ],
            1,
            "« pas trop de discours. »",
        ),
        pairs=[
            ("20 puis 9", "plastiques"),
            ("5 puis 7", "relais"),
            ("de plus en plus claire", "rive"),
            ("de moins en moins longues", "disputes"),
        ],
        fill_item=("Les relais sont de plus en plus ___.", "nombreux"),
        words=["On", "trouve", "de", "moins", "en", "moins", "de", "plastique", "."],
        anagram=("preuves", "Assez de… pour le Bureau : chiffres et gestes tenus."),
        error=(
            "Les relais sont de plus en plus nombreuse le matin.",
            "Les relais sont de plus en plus nombreux le matin.",
            "Relais est masculin pluriel : nombreux.",
        ),
        pic_start=23,
        pic_words=["une signature", "une rivière", "un figuier", "un groupe"],
        short_p="Imitez : un relevé de dix lignes, quatre chiffres, deux évolutions.",
        audio="Lisez votre relevé, sans aller trop vite.",
    ),
    _l(
        "EL",
        "EL — De plus en plus, de moins en moins",
        "Retenir les structures d'évolution et la lecture de chiffres.",
        "Apprenez la fiche.",
        "Fiche des mesures",
        """De plus en plus + adjectif : de plus en plus claire / lourds / nombreux.
De moins en moins + adjectif : de moins en moins longue / visibles.
De plus en plus de + nom : de plus en plus de relais.
De moins en moins de + nom : de moins en moins de plastique.
Devant voyelle : de moins en moins d'eau (de → d').
On peut + verbe : on vient de plus en plus tôt.
Chiffres du Seuil (inventés) : 12 seaux, 3 sacs, 18 signatures, 8 puis 14 kilos.
Assez de + nom / trop de + nom pour juger l'impact.
Accord de l'adjectif : relais nombreux, rive claire, disputes longues.
Ne pas dire : de plus en plus de claire.
Ne pas dire : de moins en moins plastique (sans de).
Comparer deux semaines, pas inventer une ville réelle.""",
        tf_item=(
            "On écrit « de plus en plus de claire ».",
            False,
            "Adjectif : de plus en plus claire (sans de).",
        ),
        qcm_item=(
            "« De moins en moins ___ eau. »",
            ["de", "d'", "des", "du"],
            1,
            "Devant voyelle : d'eau.",
        ),
        pairs=[
            ("plus en plus + adj.", "hausse de qualité"),
            ("plus en plus de + nom", "hausse de quantité"),
            ("moins en moins + adj.", "baisse de qualité"),
            ("moins en moins de + nom", "baisse de quantité"),
        ],
        fill_item=("On met de moins en moins ___ eau.", "d'"),
        words=["Le", "tas", "est", "de", "plus", "en", "plus", "lourd", "."],
        anagram=("nombreux", "Les relais sont de plus en plus… : accord masculin pluriel."),
        error=(
            "On met de moins en moins de eau dans le compost.",
            "On met de moins en moins d'eau dans le compost.",
            "De + eau → d'eau.",
        ),
        pic_start=24,
        pic_words=["une rivière", "un figuier", "un groupe", "un micro"],
        short_p="Rédigez un tableau : quatre hausses, quatre baisses, avec chiffres inventés.",
        audio="Enregistrez la fiche et six mesures.",
    ),
]


# ---------------------------------------------------------------------------
# Séquence 6 — Convaincre le Bureau
# ---------------------------------------------------------------------------

S6 = [
    _l(
        "CO",
        "CO — Préparer la lettre à Solange",
        "Comprendre comment on prépare une lettre et une pétition pour le Bureau.",
        "Lisez le dialogue. Que doit contenir la lettre ?",
        "Table des Sources, Cahier des racines ouvert",
        """Patrick : On écrit à Solange pour que le Bureau des Escales tamponne le projet.
Léa : Tout d'abord les faits : 18 signatures, 12 seaux, une rive plus claire.
Marc : Ensuite une demande nette : un tampon, pas vingt pages.
Hawa : On joint le Cahier des racines afin qu'elle lise les noms.
Joël : Il vaudrait mieux rester polis et centrés sur la rive.
Rose : Si on signait tous sur une feuille, le geste serait clair.
Aline : Tu pourrais relire pour qu'aucune phrase ne parte trop vite.
Karim : La pétition tient en une page : assez, pas trop.
Lila : Radio Figuier lira la lettre afin que les absents sachent.
Dieudonné : J'ajoute trois sacs tenus pour montrer l'atelier.
Félicie : Je prie Solange de passer à la table jeudi.
Solange : J'ouvre le courrier ; convaincre, ce n'est pas crier.""",
        tf_item=(
            "La pétition doit tenir en une page.",
            True,
            "Karim : « La pétition tient en une page. »",
        ),
        qcm_item=(
            "Que joint-on afin que Solange lise les noms ?",
            [
                "Un billet de minibus",
                "Le Cahier des racines",
                "Une cravate",
                "Un contrat de ville",
            ],
            1,
            "Hawa : « On joint le Cahier des racines. »",
        ),
        pairs=[
            ("lettre à Solange", "Bureau des Escales"),
            ("18 signatures", "faits"),
            ("pétition", "une page"),
            ("Cahier des racines", "les noms"),
        ],
        fill_item=("On écrit à Solange pour que le Bureau ___ le projet.", "tamponne"),
        words=["On", "joint", "le", "Cahier", "des", "racines", "."],
        anagram=("petition", "Une page de noms pour le Bureau. (sans accent)"),
        error=(
            "On écrit à Solange pour que le Bureau tamponne le projets.",
            "On écrit à Solange pour que le Bureau tamponne le projet.",
            "Projet au singulier.",
        ),
        pic_start=25,
        pic_words=["un figuier", "un groupe", "un micro", "un soleil"],
        short_p="Listez les pièces de la lettre : faits, demande, pièce jointe, ton.",
        audio="Enregistrez : On écrit à Solange. 18 signatures. Une pétition d'une page. On joint le Cahier.",
    ),
    _l(
        "CE",
        "CE — Lettre et pétition",
        "Lire une lettre-pétition adressée à Solange, jointe au Cahier des racines.",
        "Lisez la lettre, sans aller trop vite.",
        "Lettre collective, tampon en attente",
        """Seuil des Sources, Rukiri-Nord
Madame Mukamana,
Nous vous écrivons pour que le Bureau des Escales reconnaisse le projet « Rive du Seuil ».
Tout d'abord les faits : 18 signatures, 12 seaux, de moins en moins de plastique.
Nous agissons afin de protéger le figuier et la petite rivière.
Nous joignons le Cahier des racines afin que vous lisiez les noms.
Il vaudrait mieux un tampon clair qu'un long silence.
Si le Bureau acceptait un premier essai, la cour tiendrait le rythme.
Nous vous prions de croire à notre engagement calme.
Les signataires : Patrick, Léa, Marc, Hawa, Joël, Rose, Aline, Karim, Lila,
Dieudonné, Félicie, et quelques voisins.
Pétition jointe : une page, assez de noms, pas trop de discours.""",
        tf_item=(
            "La lettre demande au Bureau de reconnaître le projet « Rive du Seuil ».",
            True,
            "Premier paragraphe de demande.",
        ),
        qcm_item=(
            "Que joignent les signataires ?",
            [
                "Un passeport",
                "Le Cahier des racines",
                "Un contrat de location",
                "Une carte de minibus",
            ],
            1,
            "« Nous joignons le Cahier des racines. »",
        ),
        pairs=[
            ("pour que le Bureau reconnaisse", "but"),
            ("afin de protéger", "figuier et rivière"),
            ("afin que vous lisiez", "les noms"),
            ("une page", "pétition"),
        ],
        fill_item=("Nous joignons le Cahier afin que vous ___ les noms.", "lisiez"),
        words=["Nous", "vous", "écrivons", "pour", "que", "le", "Bureau", "reconnaisse", "."],
        anagram=("tampon", "Solange le pose sur le dossier si le Bureau accepte."),
        error=(
            "Nous joignons le Cahier afin que vous lisez les noms.",
            "Nous joignons le Cahier afin que vous lisiez les noms.",
            "Afin que + subjonctif : lisiez.",
        ),
        pic_start=26,
        pic_words=["un groupe", "un micro", "un soleil", "une feuille"],
        short_p="Recopiez la lettre et indiquez faits, but, pièce, formule de politesse.",
        audio="Lisez la lettre à Solange, sans aller trop vite.",
    ),
    _l(
        "PO",
        "PO — Convaincre avec calme",
        "Oraliser une demande au Bureau : faits, but, ton poli.",
        "Répétez, puis convainquez Solange en six phrases.",
        "Modèles d'Aline",
        """Nous vous écrivons pour le projet.
Tout d'abord les faits.
Nous joignons le Cahier des racines.
Il vaudrait mieux un tampon clair.
Si le Bureau acceptait, nous tiendrions le rythme.
Nous vous prions de lire cette page.
Assez de noms, pas trop de discours.
La rive est de plus en plus claire.
On agit afin de protéger le figuier.
Signez ici pour que Solange voie.
Restez polis.
Restez précis.""",
        tf_item=(
            "Le ton demandé est poli et précis, pas crié.",
            True,
            "Restez polis. Restez précis.",
        ),
        qcm_item=(
            "Quelle formule ouvre les faits ?",
            [
                "Enfin les faits",
                "Tout d'abord les faits",
                "Dans l'attente des faits",
                "Je vous prie les faits",
            ],
            1,
            "Tout d'abord les faits.",
        ),
        pairs=[
            ("nous vous écrivons", "ouverture"),
            ("tout d'abord", "faits"),
            ("nous joignons", "Cahier"),
            ("nous vous prions", "clôture"),
        ],
        fill_item=("Si le Bureau ___, nous tiendrions le rythme. (accepter)", "acceptait"),
        words=["Nous", "joignons", "le", "Cahier", "des", "racines", "."],
        anagram=("precis", "Le contraire de flou, pour convaincre. (sans accent)"),
        error=(
            "Si le Bureau acceptera nous tiendrions le rythme.",
            "Si le Bureau acceptait nous tiendrions le rythme.",
            "Si + imparfait, pas le futur.",
        ),
        pic_start=27,
        pic_words=["un micro", "un soleil", "une feuille", "un compte rendu"],
        short_p="Écrivez six phrases orales pour Solange : faits, but, demande, politesse.",
        audio="Enregistrez les modèles, puis votre demande au Bureau.",
    ),
    _l(
        "PE",
        "PE — Ma lettre au Bureau",
        "Écrire une lettre-pétition à Solange, jointe au Cahier des racines.",
        "Imitez la lettre de Léa, sans aller trop vite.",
        "Lettre de Léa Niyonzima",
        """Léa Niyonzima
Seuil des Sources, Rukiri-Nord
Madame Mukamana,
Nous vous écrivons pour que le Bureau des Escales tamponne le projet « Rive du Seuil ».
Tout d'abord : 18 signatures, 12 seaux, de moins en moins de plastique.
Nous joignons le Cahier des racines afin que vous lisiez les noms.
Il vaudrait mieux un premier essai qu'un long silence.
Nous vous prions de croire à notre engagement.
Léa — pour le groupe du figuier
Pétition : une page.""",
        tf_item=(
            "Léa écrit au nom du groupe du figuier.",
            True,
            "« Léa — pour le groupe du figuier. »",
        ),
        qcm_item=(
            "Que vaudrait-il mieux, d'après Léa ?",
            [
                "Un long silence",
                "Un premier essai",
                "Vingt pages",
                "Fermer la rive",
            ],
            1,
            "« un premier essai qu'un long silence. »",
        ),
        pairs=[
            ("pour que le Bureau tamponne", "but"),
            ("18 signatures", "faits"),
            ("Cahier des racines", "pièce"),
            ("nous vous prions", "clôture"),
        ],
        fill_item=("Nous vous ___ de croire à notre engagement.", "prions"),
        words=["Nous", "vous", "écrivons", "pour", "le", "projet", "."],
        anagram=("engagement", "On prie Solange de croire à notre… calme."),
        error=(
            "Nous vous prions de croire à notre engagements.",
            "Nous vous prions de croire à notre engagement.",
            "Engagement au singulier après notre.",
        ),
        pic_start=28,
        pic_words=["un soleil", "une feuille", "un compte rendu", "une quantité"],
        short_p="Imitez : une lettre de dix à douze lignes à Solange, avec pétition d'une phrase.",
        audio="Lisez votre lettre, sans aller trop vite.",
    ),
    _l(
        "EL",
        "EL — Lettre, pétition, Cahier des racines",
        "Retenir le plan d'une lettre pour convaincre le Bureau.",
        "Apprenez la fiche.",
        "Fiche du courrier",
        """Plan : lieu et date ; Madame Mukamana, ; faits ; but ; pièce ; clôture.
Faits : chiffres inventés du Seuil, de plus en plus / de moins en moins.
But : pour que + subjonctif / afin de + infinitif / afin que + subjonctif.
Pièce : nous joignons le Cahier des racines.
Pétition : une page, des noms, une demande nette (un tampon, un essai).
Clôture : nous vous prions de + infinitif.
Ton : poli, précis, assez de preuves, pas trop de discours.
Convaincre ≠ crier. Inciter ≠ exiger.
Ne pas inventer une ville réelle ni une enseigne réelle.
Ne pas dire : afin de que vous lisez.
Subjonctif : que le Bureau reconnaisse / tamponne / accepte ; que vous lisiez.
Si + imparfait : si le Bureau acceptait, nous tiendrions.""",
        tf_item=(
            "La pétition du Seuil tient en une page.",
            True,
            "Une page, une demande nette.",
        ),
        qcm_item=(
            "Quelle clôture est adaptée ?",
            [
                "Répondez tout de suite",
                "Nous vous prions de lire cette page",
                "Tamponnez ou partez",
                "Criez au Bureau",
            ],
            1,
            "Nous vous prions de + infinitif.",
        ),
        pairs=[
            ("faits", "chiffres"),
            ("but", "pour que / afin que"),
            ("pièce", "Cahier des racines"),
            ("clôture", "nous vous prions"),
        ],
        fill_item=("Nous ___ le Cahier des racines.", "joignons"),
        words=["Nous", "vous", "prions", "de", "lire", "cette", "page", "."],
        anagram=("racines", "Le cahier des… : les noms sous le figuier."),
        error=(
            "Nous joignons le Cahier afin de que vous lisiez les noms.",
            "Nous joignons le Cahier afin que vous lisiez les noms.",
            "Afin que, pas afin de que.",
        ),
        pic_start=29,
        pic_words=["une feuille", "un compte rendu", "une quantité", "une réserve"],
        short_p="Rédigez le plan d'une lettre en six blocs, avec un exemple chacun.",
        audio="Enregistrez la fiche et la lecture de votre plan.",
    ),
]


SEQUENCES = [
    {"title": "Rendre compte, adhérer, nuancer", "lessons": S1},
    {"title": "Débattre de solutions", "lessons": S2},
    {"title": "Un projet pour la rive", "lessons": S3},
    {"title": "Persuader d'agir", "lessons": S4},
    {"title": "Mesurer l'impact", "lessons": S5},
    {"title": "Convaincre le Bureau", "lessons": S6},
]
