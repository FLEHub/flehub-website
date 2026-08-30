"""B1 Module 7 — L'esprit d'innovation (univers Seuil des Sources)."""

from factory import L

IMG = "mfk-b1-m7"
IMG_DIR = IMG

MODULE = {
    "title": "B1 — L'esprit d'innovation",
    "description": (
        "Grande étape B1-7 : présenter un talent, expliquer une découverte, "
        "argumenter pas à pas, imaginer demain, tester un prototype et "
        "pitcher devant la cour — Lila, Dieudonné et Karim inventent la "
        "Lampe-Figue et le Filtre des Herbes sous le figuier, au Seuil "
        "des Sources (Rukiri-Nord)."
    ),
}


def _l(comp, title, obj, cons, st, sp, **kw):
    return L(IMG, comp, title, obj, cons, st, sp, **kw)


# ---------------------------------------------------------------------------
# Séquence 1 — Des talents à découvrir (relatifs composés)
# ---------------------------------------------------------------------------

S1 = [
    _l(
        "CO",
        "CO — Trois talents sous le figuier",
        "Présenter une innovation et des jeunes talents ; relatifs composés.",
        "Lisez le dialogue. À qui, duquel, avec lequel : qui invente quoi ?",
        "Ombre du figuier, banc de test",
        """Lila : Voici le projet auquel je pense depuis la saison sèche : une lanterne.
Karim : C'est l'idée à laquelle on revient chaque soir. On l'appelle Lampe-Figue.
Dieudonné : Voici l'arbre sous lequel on travaille, et l'outil avec lequel je coupe.
Aline : Les jeunes auxquels on s'adresse savent déjà mesurer.
Patrick : Le filtre duquel on parle nettoie l'eau de la rive.
Hawa : La rive de laquelle l'eau vient s'appelle encore Rive d'Orage.
Joël : Les outils desquels Dieudonné a besoin sont simples : fil, verre, tissu.
Rose : La lampe à laquelle Lila travaille charge au soleil.
Marc : Le banc sur lequel on pose le prototype est ocre.
Solange : Le dossier auquel le Bureau s'intéresse reste ouvert.
Mado : Les stands devant lesquels on expliquera sont au Marché des Lampions.
Sami : Le rythme avec lequel je soutiens l'atelier, c'est trois frappes.""",
        tf_item=(
            "Le projet auquel Lila pense est une lanterne.",
            True,
            "Lila : « le projet auquel je pense… une lanterne. »",
        ),
        qcm_item=(
            "Comment appelle-t-on la lanterne ?",
            ["Filtre des Herbes", "Lampe-Figue", "Feuille du Seuil", "Radio Figuier"],
            1,
            "Karim : « On l'appelle Lampe-Figue. »",
        ),
        pairs=[
            ("auquel", "projet / penser à"),
            ("à laquelle", "idée / revenir à"),
            ("duquel", "filtre / parler de"),
            ("avec lequel", "outil / couper"),
        ],
        fill_item=("Voici le projet ___ je pense depuis la saison sèche.", "auquel"),
        words=["Voici", "le", "filtre", "duquel", "on", "parle", "."],
        anagram=("auquel", "Penser à + projet masculin : le pronom…"),
        error=(
            "Voici le projet que je pense depuis la saison sèche.",
            "Voici le projet auquel je pense depuis la saison sèche.",
            "Penser à → auquel.",
        ),
        pic_start=0,
        pic_words=["un relatif", "un talent", "une présentation", "une lampe"],
        short_p="Notez six relatifs composés et le verbe qui les appelle.",
        audio="Enregistrez : le projet auquel je pense ; l'idée à laquelle on revient ; le filtre duquel on parle ; l'outil avec lequel je coupe.",
    ),
    _l(
        "CE",
        "CE — Portraits inventeurs",
        "Lire trois portraits de talents et leurs relatifs composés.",
        "Lisez les portraits, sans aller trop vite.",
        "Cahier du chemin, page ocre",
        """Portrait Lila Sow
Voix de Radio Figuier. La lanterne à laquelle elle travaille s'appelle Lampe-Figue.
C'est le soleil grâce auquel le verre chauffe le petit fil.
Portrait Dieudonné
Atelier du Tissu. Les outils desquels il a besoin tiennent dans un sac.
C'est le figuier sous lequel il pose le banc de test.
Portrait Karim
Il note l'idée à laquelle le groupe revient. Il dessine le filtre duquel on parle.
Les jeunes auxquels Aline s'adresse peuvent répéter le schéma.
La rive de laquelle l'eau trouble arrive n'est pas loin.
Le dossier auquel Solange pense restera au Bureau des Escales.
Trois talents, deux objets : Lampe-Figue et Filtre des Herbes.
Seuil des Sources — Rukiri-Nord""",
        tf_item=(
            "Dieudonné range ses outils dans un coffre de pierre.",
            False,
            "« tiennent dans un sac. »",
        ),
        qcm_item=(
            "Grâce à quoi le verre de la lanterne chauffe-t-il le fil ?",
            ["la rivière", "le soleil", "le tambour", "le marché"],
            1,
            "« le soleil grâce auquel le verre chauffe. »",
        ),
        pairs=[
            ("à laquelle", "lanterne / Lila"),
            ("desquels", "outils / Dieudonné"),
            ("duquel", "filtre / Karim"),
            ("auxquels", "jeunes / Aline"),
        ],
        fill_item=("Les outils ___ il a besoin tiennent dans un sac.", "desquels"),
        words=["C'est", "le", "figuier", "sous", "lequel", "il", "pose", "le", "banc", "."],
        anagram=("desquels", "Avoir besoin de + outils pluriels."),
        error=(
            "Les outils que Dieudonné a besoin tiennent dans un sac.",
            "Les outils desquels il a besoin tiennent dans un sac.",
            "Avoir besoin de → desquels.",
        ),
        pic_start=1,
        pic_words=["un talent", "une présentation", "une lampe", "une explication"],
        short_p="Recopiez un portrait et encadrez les relatifs composés.",
        audio="Lisez les trois portraits, sans aller trop vite.",
    ),
    _l(
        "PO",
        "PO — Dire auquel, duquel, avec lequel",
        "Présenter un talent à l'oral avec des relatifs composés.",
        "Répétez, puis présentez un objet de la cour.",
        "Modèles d'Aline",
        """Le projet auquel je pense est simple.
L'idée à laquelle on revient s'appelle Lampe-Figue.
Le filtre duquel on parle tient dans une calebasse.
La rive de laquelle l'eau vient est haute.
Les outils desquels il a besoin sont là.
Les jeunes auxquels on s'adresse écoutent.
L'outil avec lequel je coupe est net.
Le banc sur lequel on pose la lampe est stable.
C'est un talent de la cour.
Ce n'est pas un secret d'ailleurs.
On montre. On nomme. On relie.
On n'invente pas un pronom au hasard.""",
        tf_item=(
            "« Parler de » appelle souvent duquel / de laquelle / desquels.",
            True,
            "Le filtre duquel on parle.",
        ),
        qcm_item=(
            "« Penser à un projet » → le projet…",
            ["que je pense", "dont je pense à", "auquel je pense", "qui je pense"],
            2,
            "Penser à → auquel.",
        ),
        pairs=[
            ("penser à", "auquel"),
            ("parler de", "duquel"),
            ("avoir besoin de", "desquels"),
            ("couper avec", "avec lequel"),
        ],
        fill_item=("L'outil ___ lequel je coupe est net.", "avec"),
        words=["Le", "projet", "auquel", "je", "pense", "est", "simple", "."],
        anagram=("laquelle", "Revenir à + idée féminin : à…"),
        error=(
            "L'idée que on revient chaque soir s'appelle Lampe-Figue.",
            "L'idée à laquelle on revient s'appelle Lampe-Figue.",
            "Revenir à → à laquelle.",
        ),
        pic_start=2,
        pic_words=["une présentation", "une lampe", "une explication", "un schéma"],
        short_p="Écrivez huit relatives : auquel, à laquelle, duquel, desquels, auxquels, avec lequel.",
        audio="Enregistrez les modèles, puis deux portraits à vous.",
    ),
    _l(
        "PE",
        "PE — Mon portrait de talent",
        "Écrire la présentation d'un talent et d'une innovation.",
        "Imitez le portrait de Karim, sans aller trop vite.",
        "Portrait de Karim, Cahier du chemin",
        """Karim
Le projet auquel je m'accroche s'appelle Filtre des Herbes.
C'est l'eau de laquelle la cour a besoin après la crue.
L'idée à laquelle Lila m'a lié, c'est aussi la Lampe-Figue.
Les fils desquels Dieudonné a besoin passent dans le verre.
Les jeunes auxquels on montrera le schéma pourront répéter.
L'arbre sous lequel on teste reste le figuier du Seuil.
Je n'emprunte aucun nom d'ailleurs. Tout est né ici.
Karim
Rukiri-Nord""",
        tf_item=(
            "Karim emprunte un nom d'une ville lointaine.",
            False,
            "« Je n'emprunte aucun nom d'ailleurs. »",
        ),
        qcm_item=(
            "De quoi la cour a-t-elle besoin après la crue ?",
            ["d'un tambour", "de l'eau", "d'un titre", "d'une rumeur"],
            1,
            "« l'eau de laquelle la cour a besoin. »",
        ),
        pairs=[
            ("auquel", "projet / filtre"),
            ("de laquelle", "eau"),
            ("desquels", "fils"),
            ("auxquels", "jeunes"),
        ],
        fill_item=("Le projet ___ je m'accroche s'appelle Filtre des Herbes.", "auquel"),
        words=["Tout", "est", "né", "ici", "."],
        anagram=("accroche", "Karim s'y… : le projet ne le lâche pas."),
        error=(
            "Le projet que je m'accroche s'appelle Filtre des Herbes.",
            "Le projet auquel je m'accroche s'appelle Filtre des Herbes.",
            "S'accrocher à → auquel.",
        ),
        pic_start=3,
        pic_words=["une lampe", "une explication", "un schéma", "un filtre"],
        short_p="Imitez : six relatives composées, deux objets du Seuil.",
        audio="Lisez votre portrait, sans aller trop vite.",
    ),
    _l(
        "EL",
        "EL — Pronoms relatifs composés",
        "Retenir auquel, à laquelle, duquel, de laquelle, desquels, auxquels, avec lequel.",
        "Apprenez la fiche.",
        "Fiche d'Aline",
        """À + lequel
auquel (m.s.) à laquelle (f.s.) auxquels (m.p.) auxquelles (f.p.)
penser à, s'intéresser à, s'accrocher à, s'adresser à
De + lequel
duquel de laquelle desquels desquelles
parler de, avoir besoin de, venir de
Autres prépositions
avec lequel / avec laquelle ; sous lequel ; sur lequel ; grâce auquel
On n'écrit pas : le projet que je pense (penser à).
On n'écrit pas : les outils que j'ai besoin (besoin de).
Dont peut remplacer duquel parfois : le filtre dont on parle.
Au Seuil : Lampe-Figue, Filtre des Herbes, figuier, banc de test.
Relier le nom et la préposition du verbe : voilà le geste.""",
        tf_item=(
            "« S'adresser à » appelle auxquels / à laquelle, pas que.",
            True,
            "Les jeunes auxquels on s'adresse.",
        ),
        qcm_item=(
            "« Avoir besoin des outils » → les outils…",
            ["que j'ai besoin", "dont j'ai besoin à", "desquels j'ai besoin", "à lesquels j'ai besoin"],
            2,
            "Besoin de → desquels.",
        ),
        pairs=[
            ("auquel", "penser à"),
            ("duquel", "parler de"),
            ("desquels", "besoin de"),
            ("avec lequel", "couper avec"),
        ],
        fill_item=("Les jeunes ___ on s'adresse écoutent.", "auxquels"),
        words=["Le", "filtre", "dont", "on", "parle", "tient", "."],
        anagram=("preposition", "À, de, avec : elle appelle le composé (sans accent)."),
        error=(
            "Les jeunes que on s'adresse écoutent sous le figuier.",
            "Les jeunes auxquels on s'adresse écoutent.",
            "S'adresser à → auxquels.",
        ),
        pic_start=4,
        pic_words=["une explication", "un schéma", "un filtre", "une main"],
        short_p="Tableau : verbe + préposition + relatif, huit lignes.",
        audio="Enregistrez la fiche et huit relatives.",
    ),
]


# ---------------------------------------------------------------------------
# Séquence 2 — Expliquer une découverte
# ---------------------------------------------------------------------------

S2 = [
    _l(
        "CO",
        "CO — On appelle ça, cela permet de",
        "Expliquer simplement une innovation.",
        "Lisez le dialogue. Comment dit-on le nom et l'usage ?",
        "Atelier sous le figuier",
        """Karim : On appelle ça une Lampe-Figue. Ce n'est pas une étoile.
Lila : Cela permet de lire le Cahier du chemin après le crépuscule.
Dieudonné : On appelle ça un Filtre des Herbes. Le tissu retient le trouble.
Aline : Cela permet de verser une eau plus claire dans la calebasse.
Patrick : On n'appelle pas ça une machine d'ailleurs. C'est un prototype du Seuil.
Hawa : Cela permet de réduire la peur quand la rive est haute.
Joël : On appelle ça un banc de test. On y pose la lampe.
Rose : Cela permet de voir si le fil tient trois soirs.
Marc : Expliquer, c'est dire le nom, le geste, le bénéfice.
Solange : Cela permet au Bureau de comprendre sans dessin compliqué.
Mado : On appelle ça aussi une lanterne solaire, si l'on veut simple.
Sami : Cela permet de tenir une veillée sans crier au marché.""",
        tf_item=(
            "Karim dit que la Lampe-Figue est une étoile.",
            False,
            "« Ce n'est pas une étoile. »",
        ),
        qcm_item=(
            "Que permet la Lampe-Figue, selon Lila ?",
            [
                "de fermer Radio Figuier",
                "de lire après le crépuscule",
                "de vendre le figuier",
                "d'inventer une rumeur",
            ],
            1,
            "« Cela permet de lire le Cahier du chemin après le crépuscule. »",
        ),
        pairs=[
            ("on appelle ça", "donner le nom"),
            ("cela permet de", "dire l'usage"),
            ("Lampe-Figue", "lire le soir"),
            ("Filtre des Herbes", "eau plus claire"),
        ],
        fill_item=("On ___ ça une Lampe-Figue.", "appelle"),
        words=["Cela", "permet", "de", "lire", "après", "le", "crépuscule", "."],
        anagram=("prototype", "Patrick : ce n'est pas une machine d'ailleurs, c'est un…"),
        error=(
            "On appelle ça de lire après le crépuscule.",
            "Cela permet de lire le Cahier du chemin après le crépuscule.",
            "On appelle ça + nom. Cela permet de + infinitif.",
        ),
        pic_start=5,
        pic_words=["un schéma", "un filtre", "une main", "une progression"],
        short_p="Notez quatre « on appelle ça » et quatre « cela permet de ».",
        audio="Enregistrez : On appelle ça une Lampe-Figue. Cela permet de lire après le crépuscule.",
    ),
    _l(
        "CE",
        "CE — Fiche découverte",
        "Lire une explication simple des deux objets.",
        "Lisez la fiche, sans aller trop vite.",
        "Schéma de Karim, feuille ocre",
        """Deux découvertes sous le figuier
1. On appelle ça Lampe-Figue.
Cela permet de garder une lueur sur le banc sans feu de paille.
Le verre, le fil, le soleil : trois gestes.
2. On appelle ça Filtre des Herbes.
Cela permet de retenir le trouble de la rive avant de boire.
Le tissu de Dieudonné, la calebasse, la patience : trois gestes.
Comment expliquer
On donne le nom. On montre. On dit cela permet de + verbe.
On évite les mots d'ailleurs. On reste au Seuil.
Aline : une phrase courte vaut mieux qu'un discours.
Lila : on peut le dire à Radio Figuier en une minute.
Solange : le Bureau comprend si le bénéfice est clair.
Rukiri-Nord""",
        tf_item=(
            "La Lampe-Figue sert à faire un feu de paille.",
            False,
            "« sans feu de paille. »",
        ),
        qcm_item=(
            "Combien de gestes pour le filtre ?",
            ["un", "deux", "trois", "dix"],
            2,
            "Tissu, calebasse, patience.",
        ),
        pairs=[
            ("Lampe-Figue", "lueur / banc"),
            ("Filtre des Herbes", "trouble / rive"),
            ("on appelle ça", "nom"),
            ("cela permet de", "usage"),
        ],
        fill_item=("Cela permet de retenir le ___ de la rive.", "trouble"),
        words=["On", "donne", "le", "nom", "."],
        anagram=("calebasse", "On y verse l'eau après le tissu."),
        error=(
            "Cela permet ça Filtre des Herbes pour retenir le trouble.",
            "On appelle ça Filtre des Herbes. Cela permet de retenir le trouble.",
            "Nom d'un côté, usage de l'autre.",
        ),
        pic_start=6,
        pic_words=["un filtre", "une main", "une progression", "une opinion"],
        short_p="Recopiez la fiche et ajoutez un troisième objet inventé au Seuil.",
        audio="Lisez les deux découvertes, sans aller trop vite.",
    ),
    _l(
        "PO",
        "PO — Expliquer en une minute",
        "Présenter une innovation à l'oral avec on appelle ça / cela permet de.",
        "Répétez, puis expliquez un objet de la cour.",
        "Modèles de Lila",
        """On appelle ça une Lampe-Figue.
Cela permet de lire le soir.
On appelle ça un Filtre des Herbes.
Cela permet de clarifier l'eau.
On montre le verre. On montre le tissu.
Le geste est simple. Le bénéfice est clair.
Ce n'est pas une étoile. Ce n'est pas une machine d'ailleurs.
C'est un prototype du Seuil.
Je dis le nom. Je dis l'usage. Je m'arrête.
Je n'ajoute pas de peur. Je n'ajoute pas de rumeur.
Une minute suffit.
Radio Figuier peut le reprendre.""",
        tf_item=(
            "Lila conseille d'ajouter une rumeur pour intéresser.",
            False,
            "« Je n'ajoute pas de rumeur. »",
        ),
        qcm_item=(
            "Quelle durée Lila vise-t-elle ?",
            ["huit minutes", "une heure", "une minute", "un jour"],
            2,
            "« Une minute suffit. »",
        ),
        pairs=[
            ("on appelle ça", "nom"),
            ("cela permet de", "usage"),
            ("prototype", "Seuil"),
            ("une minute", "durée"),
        ],
        fill_item=("Cela permet de ___ l'eau.", "clarifier"),
        words=["Une", "minute", "suffit", "."],
        anagram=("clarifier", "Le filtre le fait : rendre l'eau moins trouble."),
        error=(
            "On appelle ça de clarifier l'eau le soir sous le figuier.",
            "On appelle ça un Filtre des Herbes. Cela permet de clarifier l'eau.",
            "On appelle ça + nom.",
        ),
        pic_start=7,
        pic_words=["une main", "une progression", "une opinion", "d'abord ensuite"],
        short_p="Écrivez deux explications d'une minute : nom, geste, bénéfice.",
        audio="Enregistrez les modèles, puis une explication chronométrée.",
    ),
    _l(
        "PE",
        "PE — Ma fiche d'innovation",
        "Écrire une explication simple d'une découverte.",
        "Imitez la fiche de Dieudonné, sans aller trop vite.",
        "Fiche de Dieudonné, Atelier du Tissu",
        """Dieudonné
On appelle ça une Lampe-Figue.
Cela permet de poser une lueur sur le banc de test.
On appelle ça aussi un Filtre des Herbes.
Cela permet de passer l'eau trouble à travers mon tissu ocre.
Je montre le fil. Je montre le verre. Je montre le soleil.
Je ne dis pas de mot d'ailleurs. Je reste sous le figuier.
Le bénéfice : lire, verser, moins craindre la nuit et la rive.
Dieudonné
Seuil des Sources""",
        tf_item=(
            "Dieudonné refuse de montrer le fil.",
            False,
            "« Je montre le fil. »",
        ),
        qcm_item=(
            "De quelle couleur est le tissu du filtre ?",
            ["bleu", "ocre", "noir", "blanc de neige"],
            1,
            "« mon tissu ocre. »",
        ),
        pairs=[
            ("Lampe-Figue", "lueur / banc"),
            ("Filtre des Herbes", "tissu ocre"),
            ("on appelle ça", "nom"),
            ("cela permet de", "usage"),
        ],
        fill_item=("On ___ ça une Lampe-Figue.", "appelle"),
        words=["Je", "montre", "le", "verre", "."],
        anagram=("benefice", "Lire, verser, moins craindre (sans accent)."),
        error=(
            "Cela permet ça une Lampe-Figue sur le banc de test.",
            "On appelle ça une Lampe-Figue. Cela permet de poser une lueur sur le banc.",
            "Nom puis usage.",
        ),
        pic_start=8,
        pic_words=["une progression", "une opinion", "d'abord ensuite", "un cahier"],
        short_p="Imitez : deux noms, deux usages, trois gestes, un bénéfice.",
        audio="Lisez votre fiche, sans aller trop vite.",
    ),
    _l(
        "EL",
        "EL — On appelle ça / cela permet de",
        "Retenir les formules pour présenter une innovation.",
        "Apprenez la fiche.",
        "Fiche courte",
        """Donner le nom
On appelle ça + nom : On appelle ça une Lampe-Figue.
Présenter = dire le nom sans copier ailleurs.
Dire l'usage
Cela permet de + infinitif : Cela permet de lire le soir.
Cela permet de clarifier l'eau.
Montrer
Je montre le verre, le fil, le tissu.
Ordre utile : nom → geste → bénéfice.
On n'écrit pas : on appelle ça de lire.
On n'écrit pas : cela permet ça une lampe.
Une minute à Radio Figuier suffit.
Mots du Seuil seulement : figuier, rive, calebasse, banc de test.
Innovation = un geste nouveau pour un besoin de la cour.""",
        tf_item=(
            "« On appelle ça » est suivi d'un nom.",
            True,
            "On appelle ça une Lampe-Figue.",
        ),
        qcm_item=(
            "Après « cela permet », on met…",
            ["un adjectif seul", "de + infinitif", "un subjonctif obligatoire", "un passif"],
            1,
            "Cela permet de + verbe.",
        ),
        pairs=[
            ("on appelle ça", "nom"),
            ("cela permet de", "usage"),
            ("je montre", "geste"),
            ("bénéfice", "lire / verser"),
        ],
        fill_item=("Cela permet ___ lire le soir.", "de"),
        words=["On", "appelle", "ça", "une", "lanterne", "."],
        anagram=("innovation", "Un geste nouveau pour un besoin de la cour."),
        error=(
            "On appelle ça de lire le soir sous le figuier.",
            "On appelle ça une Lampe-Figue. Cela permet de lire le soir.",
            "Nom ≠ usage.",
        ),
        pic_start=9,
        pic_words=["une opinion", "d'abord ensuite", "un cahier", "un doute"],
        short_p="Inventez quatre objets du Seuil : nom + cela permet de.",
        audio="Enregistrez la fiche et six phrases modèles.",
    ),
]


# ---------------------------------------------------------------------------
# Séquence 3 — Argumenter pas à pas
# ---------------------------------------------------------------------------

S3 = [
    _l(
        "CO",
        "CO — D'abord la lampe, ensuite le filtre",
        "Suivre un argument : concept, opinion, progression chronologique.",
        "Lisez le dialogue. Quels mots d'ordre entendez-vous ?",
        "Cahier d'argument, banc ocre",
        """Karim : D'abord, le concept : une lueur sans feu de paille.
Lila : Ensuite, mon opinion : la cour en a besoin pour le Cahier du chemin.
Dieudonné : Par ailleurs, le filtre répond à la rive trouble.
Aline : En outre, les gestes restent simples : fil, verre, tissu.
Patrick : En conclusion, ce sont des talents de chez nous, pas d'ailleurs.
Hawa : D'abord j'écoute le concept. Ensuite je donne mon avis.
Joël : Par ailleurs, le banc de test est déjà là.
Rose : En outre, Radio Figuier peut expliquer en une minute.
Marc : En conclusion, je suis pour les deux prototypes.
Solange : D'abord le dossier. Ensuite la démonstration sous le figuier.
Mado : Par ailleurs, le marché voudra voir, pas seulement entendre.
Sami : En conclusion, je frapperai trois fois à l'ouverture du pitch.""",
        tf_item=(
            "Patrick dit que les talents viennent d'ailleurs.",
            False,
            "« des talents de chez nous, pas d'ailleurs. »",
        ),
        qcm_item=(
            "Quel mot ouvre l'argument de Karim ?",
            ["en conclusion", "par ailleurs", "d'abord", "ensuite"],
            2,
            "« D'abord, le concept… »",
        ),
        pairs=[
            ("d'abord", "concept"),
            ("ensuite", "opinion"),
            ("par ailleurs / en outre", "ajout"),
            ("en conclusion", "fermeture"),
        ],
        fill_item=("___ , le concept : une lueur sans feu de paille.", "D'abord"),
        words=["En", "conclusion", "je", "suis", "pour", "les", "deux", "prototypes", "."],
        anagram=("concept", "Karim l'ouvre : l'idée avant l'opinion."),
        error=(
            "En conclusion le concept, d'abord je suis pour les deux prototypes.",
            "D'abord, le concept : une lueur sans feu de paille. En conclusion, ce sont des talents de chez nous.",
            "On ouvre par d'abord, on ferme par en conclusion.",
        ),
        pic_start=10,
        pic_words=["d'abord ensuite", "un cahier", "un doute", "un futur"],
        short_p="Notez la chaîne : d'abord, ensuite, par ailleurs, en outre, en conclusion.",
        audio="Enregistrez : D'abord le concept. Ensuite mon opinion. Par ailleurs le filtre. En outre les gestes. En conclusion, je suis pour.",
    ),
    _l(
        "CE",
        "CE — Argument en cinq marches",
        "Lire un texte qui progresse d'un concept à une conclusion.",
        "Lisez l'argument, sans aller trop vite.",
        "Feuille de Lila, Radio Figuier",
        """Pourquoi soutenir la Lampe-Figue et le Filtre des Herbes
D'abord, le concept est clair : lueur solaire, eau plus nette.
Ensuite, mon opinion : la cour gagne deux gestes utiles, zéro mot d'ailleurs.
Par ailleurs, Dieudonné sait déjà couper et coudre.
En outre, Karim sait déjà dessiner le schéma pour Aline.
En conclusion, le Bureau des Escales peut ouvrir le dossier sans crainte.
On ne mélange pas concept et opinion : on les enchaîne.
On n'écrit pas tout d'un bloc : on marche.
Hawa relira à l'antenne si Lila le demande.
Mado pourra voir au marché après la démonstration.
Sami tiendra le temps : trois minutes, pas plus, plus tard.
Seuil des Sources — Rukiri-Nord""",
        tf_item=(
            "Lila mélange concept et opinion dans la même marche.",
            False,
            "« On ne mélange pas concept et opinion : on les enchaîne. »",
        ),
        qcm_item=(
            "Que sait déjà faire Karim, selon le texte ?",
            [
                "tamponner le Bureau",
                "dessiner le schéma",
                "frapper le tambour",
                "tenir le marché",
            ],
            1,
            "« Karim sait déjà dessiner le schéma. »",
        ),
        pairs=[
            ("d'abord", "concept clair"),
            ("ensuite", "opinion / cour"),
            ("par ailleurs", "Dieudonné"),
            ("en conclusion", "Bureau"),
        ],
        fill_item=("___ , Dieudonné sait déjà couper et coudre.", "Par ailleurs"),
        words=["On", "marche", "."],
        anagram=("enchaine", "Concept puis opinion : on les… (sans accent)."),
        error=(
            "D'abord mon opinion, en conclusion le concept n'est pas encore clair.",
            "D'abord, le concept est clair. Ensuite, mon opinion : la cour gagne deux gestes.",
            "Concept avant opinion.",
        ),
        pic_start=11,
        pic_words=["un cahier", "un doute", "un futur", "une balance"],
        short_p="Recopiez les cinq marches et changez l'opinion.",
        audio="Lisez l'argument en marquant les liaisons, sans aller trop vite.",
    ),
    _l(
        "PO",
        "PO — Marcher dans l'argument",
        "Enchaîner concept et opinion à l'oral.",
        "Répétez, puis argumentez pour un objet de la cour.",
        "Modèles de Marc",
        """D'abord, le concept est simple.
Ensuite, je trouve cela utile.
Par ailleurs, on a déjà le banc.
En outre, on a déjà le tissu.
En conclusion, je soutiens le prototype.
D'abord j'écoute. Ensuite je parle.
Par ailleurs je montre. En outre je cite une source.
En conclusion je m'arrête.
Je ne recommence pas au milieu.
Je ne conclus pas deux fois.
Un pas, puis l'autre.
La cour suit si j'ordonne.""",
        tf_item=(
            "Marc conseille de conclure deux fois pour convaincre.",
            False,
            "« Je ne conclus pas deux fois. »",
        ),
        qcm_item=(
            "Quel mot ajoute un argument sans le conclure ?",
            ["d'abord", "en conclusion", "par ailleurs", "stop"],
            2,
            "Par ailleurs / en outre = ajout.",
        ),
        pairs=[
            ("d'abord", "ouvrir"),
            ("ensuite", "deuxième pas"),
            ("par ailleurs", "ajout"),
            ("en conclusion", "fermer"),
        ],
        fill_item=("___ , je soutiens le prototype.", "En conclusion"),
        words=["D'abord", "le", "concept", "est", "simple", "."],
        anagram=("soutiens", "Marc le fait : il… le prototype."),
        error=(
            "En conclusion d'abord le concept est simple et ensuite je m'arrête déjà.",
            "D'abord, le concept est simple. En conclusion, je soutiens le prototype.",
            "Un seul ouvre-marche, une seule conclusion.",
        ),
        pic_start=12,
        pic_words=["un doute", "un futur", "une balance", "un nuage"],
        short_p="Écrivez un argument de cinq phrases, une liaison chacune.",
        audio="Enregistrez les modèles, puis un argument de cinq pas.",
    ),
    _l(
        "PE",
        "PE — Mon argument en marches",
        "Écrire un argument qui progresse du concept à la conclusion.",
        "Imitez l'argument de Rose, sans aller trop vite.",
        "Argument de Rose Iradukunda",
        """Rose Iradukunda
D'abord, le concept : une lampe qui boit le soleil sous le figuier.
Ensuite, mon opinion : nous pourrons lire le Cahier du chemin plus tard.
Par ailleurs, le filtre protégera les tasses de Félicie.
En outre, aucun nom d'ailleurs n'est nécessaire.
En conclusion, je vote pour le test de demain.
Je sépare le concept et l'avis.
Je n'écris pas tout d'un souffle.
Rose
Seuil des Sources""",
        tf_item=(
            "Rose vote contre le test.",
            False,
            "« je vote pour le test de demain. »",
        ),
        qcm_item=(
            "Que protégera le filtre, selon Rose ?",
            ["Radio Figuier", "les tasses de Félicie", "le tambour", "le Bureau"],
            1,
            "« le filtre protégera les tasses de Félicie. »",
        ),
        pairs=[
            ("d'abord", "concept / lampe"),
            ("ensuite", "opinion / cahier"),
            ("par ailleurs", "filtre / tasses"),
            ("en conclusion", "vote / test"),
        ],
        fill_item=("___ , je vote pour le test de demain.", "En conclusion"),
        words=["Je", "sépare", "le", "concept", "et", "l'avis", "."],
        anagram=("souffle", "Rose n'écrit pas tout d'un…"),
        error=(
            "En conclusion le concept : une lampe, d'abord je vote contre.",
            "D'abord, le concept : une lampe qui boit le soleil. En conclusion, je vote pour le test.",
            "Ordre des marches.",
        ),
        pic_start=13,
        pic_words=["un futur", "une balance", "un nuage", "un prototype"],
        short_p="Imitez : cinq liaisons, concept distinct de l'opinion.",
        audio="Lisez votre argument, sans aller trop vite.",
    ),
    _l(
        "EL",
        "EL — D'abord, ensuite, par ailleurs, en outre, en conclusion",
        "Retenir la progression d'un argument.",
        "Apprenez la fiche.",
        "Fiche de progression",
        """Ouvrir
D'abord : le concept, la définition, le geste.
Enchaîner
Ensuite : l'opinion, le premier avis.
Ajouter
Par ailleurs : un autre aspect (souvent une personne, un lieu).
En outre : encore un ajout, souvent un geste ou une preuve.
Fermer
En conclusion : le vote, la demande, l'arrêt.
On ne met pas en conclusion au début.
On ne met pas d'abord après avoir déjà conclu.
Concept ≠ opinion : on les marche, on ne les mélange pas.
Au Seuil : Lampe-Figue, Filtre des Herbes, banc de test, Bureau.
Cinq pas suffisent pour Radio Figuier.""",
        tf_item=(
            "« En outre » conclut l'argument.",
            False,
            "En outre ajoute. En conclusion ferme.",
        ),
        qcm_item=(
            "Où place-t-on le concept ?",
            ["en conclusion", "d'abord", "nulle part", "après le vote"],
            1,
            "D'abord = ouvrir par le concept.",
        ),
        pairs=[
            ("d'abord", "concept"),
            ("ensuite", "opinion"),
            ("par ailleurs / en outre", "ajout"),
            ("en conclusion", "vote"),
        ],
        fill_item=("___ : le concept, la définition, le geste.", "D'abord"),
        words=["Concept", "et", "opinion", "se", "marchent", "."],
        anagram=("progression", "D'abord… en conclusion : une…"),
        error=(
            "En conclusion d'abord le concept et ensuite j'ajoute encore une conclusion.",
            "D'abord : le concept. En conclusion : le vote.",
            "Une ouverture, une fermeture.",
        ),
        pic_start=14,
        pic_words=["une balance", "un nuage", "un prototype", "un atelier"],
        short_p="Rédigez une fiche personnelle de cinq marches sur un autre geste du Seuil.",
        audio="Enregistrez la fiche et un argument modèle.",
    ),
]


# ---------------------------------------------------------------------------
# Séquence 4 — Imaginer demain (doute et certitude)
# ---------------------------------------------------------------------------

S4 = [
    _l(
        "CO",
        "CO — Il se peut, je suis sûre",
        "Parler du futur : pour, contre, doute et certitude.",
        "Lisez le dialogue. Indicatif ou subjonctif après ces formules ?",
        "Nuage et soleil, banc du figuier",
        """Lila : Il est probable que la lampe tiendra trois soirs. (indicatif)
Karim : Il se peut que le fil casse dès la première nuit. (subjonctif)
Dieudonné : Il est possible que le tissu retienne trop d'eau. (subjonctif)
Aline : Je doute que le marché comprenne sans schéma. (subjonctif)
Patrick : Je suis sûr que le Bureau ouvrira le dossier. (indicatif)
Hawa : Je suis sûre que Radio Figuier expliquera sans crier. (indicatif)
Joël : Pour : on lira plus tard. Contre : on peut casser le verre.
Rose : Il est probable que Mado voudra une lanterne pour son stand.
Marc : Il se peut que Sami donne le tempo trop vite.
Solange : Je doute que l'on signe demain ; je suis sûre que l'on testera.
Mado : Pour le filtre, contre un essai trop près des tasses.
Sami : Il est possible que je frappe trop fort : je douterai moins après le test.""",
        tf_item=(
            "Après « il est probable que », Lila met le subjonctif.",
            False,
            "« Il est probable que la lampe tiendra » — indicatif.",
        ),
        qcm_item=(
            "Quelle formule appelle le subjonctif ?",
            [
                "il est probable que",
                "je suis sûr que",
                "il se peut que",
                "je suis sûre que",
            ],
            2,
            "Il se peut que + subjonctif.",
        ),
        pairs=[
            ("il est probable que", "indicatif"),
            ("il se peut que / il est possible que", "subjonctif"),
            ("je doute que", "subjonctif"),
            ("je suis sûr(e) que", "indicatif"),
        ],
        fill_item=("Il se peut que le fil ___ dès la première nuit.", "casse"),
        words=["Je", "suis", "sûr", "que", "le", "Bureau", "ouvrira", "le", "dossier", "."],
        anagram=("probable", "Cette formule prend l'indicatif, pas le doute."),
        error=(
            "Il est probable que la lampe tienne trois soirs sans aucun test.",
            "Il est probable que la lampe tiendra trois soirs.",
            "Il est probable que + indicatif.",
        ),
        pic_start=15,
        pic_words=["un nuage", "un prototype", "un atelier", "un fil"],
        short_p="Classez huit phrases : doute / certitude, mode employé.",
        audio="Enregistrez : Il est probable que… tiendra. Il se peut que… casse. Je doute que… comprenne. Je suis sûre que… expliquera.",
    ),
    _l(
        "CE",
        "CE — Pour, contre, demain",
        "Lire un débat sur l'avenir des deux prototypes.",
        "Lisez le débat, sans aller trop vite.",
        "Balance ocre, Salle des Herbes",
        """Débat du figuier — imaginer demain
Pour la Lampe-Figue : il est probable que les veillées dureront un peu plus.
Je suis sûre que Léa notera mieux le Cahier du chemin.
Contre : il se peut que le verre se fêle. Il est possible que le fil brûle.
Je doute que l'on ait assez de verre pour tout le marché.
Pour le Filtre des Herbes : il est probable que Félicie versera plus tranquillement.
Je suis sûr que Yvette verra moins de ventres noués.
Contre : il se peut que le tissu sente trop les herbes.
Je doute que l'eau soit claire dès le premier passage.
En conclusion : on teste demain, on ne crie pas aujourd'hui.
Aline a noté pour et contre. Solange a gardé la feuille.
Rukiri-Nord""",
        tf_item=(
            "Le débat conclut qu'on crie aujourd'hui sans tester.",
            False,
            "« on teste demain, on ne crie pas aujourd'hui. »",
        ),
        qcm_item=(
            "Qui, selon le texte, versera plus tranquillement ?",
            ["Mado", "Sami", "Félicie", "Marc"],
            2,
            "« Il est probable que Félicie versera… »",
        ),
        pairs=[
            ("il est probable que", "veillées / Félicie"),
            ("je suis sûre que", "Léa"),
            ("il se peut que", "verre / tissu"),
            ("je doute que", "verre assez / eau claire"),
        ],
        fill_item=("Je doute que l'on ___ assez de verre.", "ait"),
        words=["On", "teste", "demain", "."],
        anagram=("tranquillement", "Félicie versera ainsi, si le filtre tient."),
        error=(
            "Il est probable que les veillées durent un peu plus sans indicatif.",
            "Il est probable que les veillées dureront un peu plus.",
            "Probable + indicatif futur.",
        ),
        pic_start=16,
        pic_words=["un prototype", "un atelier", "un fil", "un banc"],
        short_p="Recopiez pour et contre et ajoutez une phrase de chaque côté.",
        audio="Lisez le débat, sans aller trop vite.",
    ),
    _l(
        "PO",
        "PO — Douter et être sûr",
        "Dire le futur, le pour, le contre, le doute et la certitude.",
        "Répétez, puis donnez un pour et un contre.",
        "Modèles d'Hawa",
        """Il est probable que la lampe tiendra.
Il se peut que le fil casse.
Il est possible que le tissu retienne trop.
Je doute que le marché attende.
Je suis sûre que Lila expliquera.
Je suis sûr que Dieudonné réparera.
Pour : on lira plus tard.
Contre : le verre peut fêler.
Demain, on testera.
On ne criera pas.
On mesurera. On notera.
Puis on décidera.""",
        tf_item=(
            "« Je doute que » est suivi du subjonctif.",
            True,
            "Je doute que le marché attende.",
        ),
        qcm_item=(
            "« Je suis sûre que Lila expliquera » : quel mode ?",
            ["subjonctif", "impératif", "indicatif", "infinitif seul"],
            2,
            "Être sûr(e) que + indicatif.",
        ),
        pairs=[
            ("probable", "indicatif"),
            ("se peut / possible", "subjonctif"),
            ("je doute que", "subjonctif"),
            ("je suis sûr(e) que", "indicatif"),
        ],
        fill_item=("Je doute que le marché ___.", "attende"),
        words=["Demain", "on", "testera", "."],
        anagram=("certitude", "Je suis sûre que : c'est une…"),
        error=(
            "Je suis sûre que Lila explique demain à l'antenne.",
            "Je suis sûre que Lila expliquera demain à l'antenne.",
            "Certitude sur demain : indicatif futur.",
        ),
        pic_start=17,
        pic_words=["un atelier", "un fil", "un banc", "un pitch"],
        short_p="Écrivez dix phrases : 2 par formule de doute ou de certitude.",
        audio="Enregistrez les modèles, puis un pour et un contre à vous.",
    ),
    _l(
        "PE",
        "PE — Ma balance de demain",
        "Écrire pour et contre avec doute et certitude.",
        "Imitez la balance de Joël, sans aller trop vite.",
        "Balance de Joël Mugisha",
        """Joël Mugisha
Il est probable que la Lampe-Figue m'aidera à ranger le soir.
Il se peut que je casse le verre si je cours.
Il est possible que le Filtre des Herbes change le goût de l'eau.
Je doute que je sache expliquer en une minute.
Je suis sûr que Dieudonné saura réparer.
Pour : moins de peur sous le figuier.
Contre : trop d'essais trop vite.
En conclusion, je viendrai au test, sans crier.
Joël
Cahier du chemin""",
        tf_item=(
            "Joël refuse de venir au test.",
            False,
            "« je viendrai au test, sans crier. »",
        ),
        qcm_item=(
            "Que craint Joël s'il court ?",
            ["le tambour", "de casser le verre", "la rumeur", "Solange"],
            1,
            "« Il se peut que je casse le verre si je cours. »",
        ),
        pairs=[
            ("il est probable que", "l'aidera"),
            ("il se peut que", "casse"),
            ("je doute que", "sache"),
            ("je suis sûr que", "saura"),
        ],
        fill_item=("Je doute que je ___ expliquer en une minute.", "sache"),
        words=["Je", "viendrai", "au", "test", "."],
        anagram=("ranger", "La lampe l'aidera à… le soir."),
        error=(
            "Il est probable que la Lampe-Figue m'aide sans jamais tenir.",
            "Il est probable que la Lampe-Figue m'aidera à ranger le soir.",
            "Probable + indicatif.",
        ),
        pic_start=18,
        pic_words=["un fil", "un banc", "un pitch", "un micro"],
        short_p="Imitez : quatre formules, un pour, un contre, une conclusion.",
        audio="Lisez votre balance, sans aller trop vite.",
    ),
    _l(
        "EL",
        "EL — Doute, certitude, futur",
        "Retenir les modes après les formules de doute et de certitude.",
        "Apprenez la fiche.",
        "Fiche des modes",
        """Indicatif (souvent futur)
Il est probable que + indicatif : Il est probable que la lampe tiendra.
Je suis sûr que / je suis sûre que + indicatif : Je suis sûre que Lila expliquera.
Subjonctif
Il se peut que + subj. : Il se peut que le fil casse.
Il est possible que + subj. : Il est possible que le tissu retienne trop.
Je doute que + subj. : Je doute que le marché attende.
Pour / contre
On pose un bénéfice, on pose un risque, on conclut par un test.
On n'écrit pas : il est probable que la lampe tienne (au Seuil, on tient l'indicatif).
On n'écrit pas : je suis sûre que Lila explique demain (futur attendu).
Demain on testera. On ne criera pas.
Lampe-Figue et Filtre des Herbes : deux futurs à mesurer.""",
        tf_item=(
            "« Il est possible que » prend le subjonctif.",
            True,
            "Il est possible que le tissu retienne trop.",
        ),
        qcm_item=(
            "« Il est probable que » + …",
            ["subjonctif", "impératif", "indicatif", "infinitif forcé"],
            2,
            "Probable + indicatif.",
        ),
        pairs=[
            ("probable / sûr(e)", "indicatif"),
            ("se peut / possible", "subjonctif"),
            ("douter", "subjonctif"),
            ("pour / contre", "bénéfice / risque"),
        ],
        fill_item=("Il est possible que le tissu ___ trop.", "retienne"),
        words=["On", "ne", "criera", "pas", "."],
        anagram=("subjonctif", "Se peut, possible, douter : ce mode-là."),
        error=(
            "Il est probable que le fil casse dès la première nuit.",
            "Il se peut que le fil casse dès la première nuit.",
            "Le doute fort : il se peut que + subjonctif. Le probable : indicatif.",
        ),
        pic_start=19,
        pic_words=["un banc", "un pitch", "un micro", "une affiche"],
        short_p="Tableau : 6 formules, 6 exemples, mode indiqué.",
        audio="Enregistrez la fiche et douze phrases (deux par formule).",
    ),
]


# ---------------------------------------------------------------------------
# Séquence 5 — Le prototype sous le figuier (EXTRA)
# ---------------------------------------------------------------------------

S5 = [
    _l(
        "CO",
        "CO — Le soir du test",
        "Suivre le test de la Lampe-Figue sous le figuier.",
        "Lisez le dialogue. Qu'est-ce qui tient ? Qu'est-ce qui doute encore ?",
        "Banc de test, fils solaires",
        """Dieudonné : D'abord, je pose le verre. Ensuite, je tends le fil.
Lila : Il est probable que la lueur tienne jusqu'à la première étoile.
Karim : Il se peut que le fil glisse. Je le tiens.
Aline : Ce que je vois, c'est une lueur basse, nette.
Patrick : Le prototype auquel on tient ne fume pas.
Hawa : Cela permet de lire deux lignes du Cahier du chemin.
Joël : Je doute que cela suffise pour tout le marché. C'est déjà beaucoup pour le banc.
Rose : Je suis sûre que Léa notera l'heure.
Marc : Par ailleurs, le Filtre des Herbes attendra demain matin.
Solange : En conclusion, le dossier peut recevoir une première date.
Mado : Les stands auxquels on pensait attendront la Saison des Voix.
Sami : Je frappe une fois : le test est ouvert. Je frappe deux fois : on note.""",
        tf_item=(
            "Le prototype fume beaucoup, selon Patrick.",
            False,
            "« ne fume pas. »",
        ),
        qcm_item=(
            "Combien de lignes Hawa peut-elle lire ?",
            ["vingt", "deux", "aucune", "cent"],
            1,
            "« lire deux lignes du Cahier du chemin. »",
        ),
        pairs=[
            ("d'abord / ensuite", "Dieudonné"),
            ("il se peut que", "fil / Karim"),
            ("cela permet de", "lire"),
            ("en conclusion", "Solange / date"),
        ],
        fill_item=("Le prototype ___ on tient ne fume pas.", "auquel"),
        words=["Je", "frappe", "une", "fois", "."],
        anagram=("lueur", "Aline la voit : basse, nette."),
        error=(
            "Le prototype que on tient ne fume pas sous le figuier.",
            "Le prototype auquel on tient ne fume pas.",
            "Tenir à → auquel.",
        ),
        pic_start=20,
        pic_words=["un pitch", "un micro", "une affiche", "une horloge"],
        short_p="Notez le protocole : poser, tendre, lire, noter, dater.",
        audio="Enregistrez le test : Je pose le verre. Je tends le fil. Cela permet de lire deux lignes.",
    ),
    _l(
        "CE",
        "CE — Compte rendu du test",
        "Lire le compte rendu de la Lampe-Figue.",
        "Lisez le compte rendu, sans aller trop vite.",
        "Feuille de test, ombre du figuier",
        """Compte rendu — Lampe-Figue, premier soir
D'abord, Dieudonné a posé le verre sur le banc de test.
Ensuite, Karim a tendu le fil. Il se peut que le fil ait glissé une fois.
Par ailleurs, Lila a lu deux lignes du Cahier du chemin à voix haute.
En outre, aucune fumée n'a été vue. Il a été confirmé que le prototype ne fume pas.
En conclusion, Solange a noté une date au Bureau des Escales.
Il est probable que l'on recommence demain avec le Filtre des Herbes.
Je doute que le marché reçoive une lanterne dès cette semaine.
Je suis sûre que la cour a compris le geste.
On appelle ça un test, pas une fête.
Cela permet de mesurer, pas de crier victoire.
Signé : Aline Uwase
Rukiri-Nord""",
        tf_item=(
            "De la fumée a été vue pendant le test.",
            False,
            "« aucune fumée n'a été vue. »",
        ),
        qcm_item=(
            "Qui a signé le compte rendu ?",
            ["Lila", "Karim", "Aline", "Mado"],
            2,
            "« Signé : Aline Uwase. »",
        ),
        pairs=[
            ("d'abord", "verre / Dieudonné"),
            ("ensuite", "fil / Karim"),
            ("par ailleurs", "Lila / deux lignes"),
            ("en conclusion", "date / Solange"),
        ],
        fill_item=("On appelle ça un ___, pas une fête.", "test"),
        words=["Aucune", "fumée", "n'a", "été", "vue", "."],
        anagram=("mesure", "Le test permet de…, pas de crier."),
        error=(
            "Il est probable que l'on recommence demain et que le marché reçoive tout cette semaine.",
            "Il est probable que l'on recommence demain avec le Filtre des Herbes. Je doute que le marché reçoive une lanterne dès cette semaine.",
            "Probable + indicatif. Doute + subjonctif : on ne les fond pas.",
        ),
        pic_start=21,
        pic_words=["un micro", "une affiche", "une horloge", "une radio"],
        short_p="Recopiez le compte rendu et encadrez les liaisons.",
        audio="Lisez le compte rendu, sans aller trop vite.",
    ),
    _l(
        "PO",
        "PO — Dire le test",
        "Raconter un test de prototype à l'oral.",
        "Répétez, puis racontez un essai de la cour.",
        "Modèles de Karim",
        """D'abord, on a posé le verre.
Ensuite, on a tendu le fil.
Il se peut que le fil ait glissé.
Il a été confirmé que rien n'a fumé.
Cela permet de lire deux lignes.
Je doute que cela éclaire tout le marché.
Je suis sûr que l'on reprendra demain.
En conclusion, le test tient.
On appelle ça une Lampe-Figue.
On ne crie pas victoire.
On note l'heure.
On range le fil.""",
        tf_item=(
            "Karim crie victoire à la fin du test.",
            False,
            "« On ne crie pas victoire. »",
        ),
        qcm_item=(
            "Que range-t-on à la fin ?",
            ["le marché", "le fil", "Radio Figuier", "le Bureau"],
            1,
            "« On range le fil. »",
        ),
        pairs=[
            ("d'abord / ensuite", "protocole"),
            ("il se peut que", "glissé"),
            ("confirmé", "pas de fumée"),
            ("en conclusion", "le test tient"),
        ],
        fill_item=("On ne crie pas ___.", "victoire"),
        words=["On", "note", "l'heure", "."],
        anagram=("protocole", "Poser, tendre, lire, noter : un…"),
        error=(
            "On crie victoire dès que le fil tient une seconde.",
            "On ne crie pas victoire. En conclusion, le test tient.",
            "Mesurer d'abord, célébrer plus tard.",
        ),
        pic_start=22,
        pic_words=["une affiche", "une horloge", "une radio", "un outil"],
        short_p="Écrivez un test oral de dix phrases, cinq liaisons.",
        audio="Enregistrez les modèles, puis votre compte rendu parlé.",
    ),
    _l(
        "PE",
        "PE — Mon compte rendu de test",
        "Écrire le test de la Lampe-Figue.",
        "Imitez le compte rendu de Léa, sans aller trop vite.",
        "Compte rendu de Léa Niyonzima",
        """Léa Niyonzima
D'abord, Dieudonné a posé le verre sous le figuier.
Ensuite, Karim a tenu le fil. Il se peut qu'il ait tremblé.
Par ailleurs, Lila a lu deux lignes. Cela permet de voir l'usage.
En outre, il a été confirmé que le prototype ne fumait pas.
En conclusion, je suis sûre que nous reprendrons demain le Filtre des Herbes.
Je doute que le marché reçoive une lanterne dès ce soir.
On appelle ça un test. Ce n'est pas encore une fête.
Léa
Cahier du chemin""",
        tf_item=(
            "Léa pense que le marché recevra une lanterne dès ce soir.",
            False,
            "« Je doute que le marché reçoive une lanterne dès ce soir. »",
        ),
        qcm_item=(
            "Qui a lu deux lignes ?",
            ["Léa", "Karim", "Lila", "Solange"],
            2,
            "« Lila a lu deux lignes. »",
        ),
        pairs=[
            ("d'abord", "verre"),
            ("ensuite", "fil"),
            ("par ailleurs", "deux lignes"),
            ("en conclusion", "filtre demain"),
        ],
        fill_item=("On appelle ça un ___. Ce n'est pas encore une fête.", "test"),
        words=["Ce", "n'est", "pas", "encore", "une", "fête", "."],
        anagram=("tremble", "Il se peut que le fil l'ait fait."),
        error=(
            "Je suis sûre que le marché reçoive une lanterne dès ce soir.",
            "Je doute que le marché reçoive une lanterne dès ce soir.",
            "Le doute de Léa prend je doute que + subjonctif.",
        ),
        pic_start=23,
        pic_words=["une horloge", "une radio", "un outil", "une idée"],
        short_p="Imitez : cinq liaisons, un doute, une certitude, un nom d'objet.",
        audio="Lisez votre compte rendu, sans aller trop vite.",
    ),
    _l(
        "EL",
        "EL — Dire un test de prototype",
        "Retenir le lexique et les formules du test sous le figuier.",
        "Apprenez la fiche.",
        "Fiche du banc de test",
        """Gestes : poser le verre, tendre le fil, lire deux lignes, noter l'heure, ranger.
Formules : on appelle ça un test, pas une fête.
Cela permet de mesurer, pas de crier victoire.
Il se peut que le fil glisse. Il a été confirmé que rien n'a fumé.
Relatif : le prototype auquel on tient ; le banc sur lequel on pose.
Progression : d'abord, ensuite, par ailleurs, en outre, en conclusion.
Doute : je doute que le marché reçoive tout. Je suis sûre que l'on reprendra.
Objets : Lampe-Figue, Filtre des Herbes, Cahier du chemin, Bureau des Escales.
On n'emprunte pas de nom d'ailleurs.
On date. On signe. On revient demain.""",
        tf_item=(
            "Un test, au Seuil, égale une fête.",
            False,
            "On appelle ça un test, pas une fête.",
        ),
        qcm_item=(
            "Que fait-on du fil à la fin ?",
            ["on le vend", "on le range", "on le jette à la rive", "on l'oublie"],
            1,
            "Ranger le fil.",
        ),
        pairs=[
            ("poser / tendre", "gestes"),
            ("mesurer", "but du test"),
            ("auquel on tient", "prototype"),
            ("revenir demain", "suite"),
        ],
        fill_item=("Cela permet de ___, pas de crier victoire.", "mesurer"),
        words=["On", "date", "on", "signe", "."],
        anagram=("prototype", "Lampe-Figue encore fragile : un…"),
        error=(
            "On appelle ça une fête dès que deux lignes sont lues.",
            "On appelle ça un test, pas une fête.",
            "Mesurer ≠ célébrer trop tôt.",
        ),
        pic_start=24,
        pic_words=["une radio", "un outil", "une idée", "une feuille"],
        short_p="Checklist de test : 8 cases à cocher demain matin.",
        audio="Enregistrez la fiche et le protocole complet.",
    ),
]


# ---------------------------------------------------------------------------
# Séquence 6 — Pitcher devant la cour (EXTRA)
# ---------------------------------------------------------------------------

S6 = [
    _l(
        "CO",
        "CO — Trois minutes sous le figuier",
        "Comprendre un oral de synthèse de trois minutes.",
        "Lisez le dialogue. Que doit contenir le pitch ?",
        "Affiche de pitch, cour du Seuil",
        """Aline : Trois minutes. Pas une de plus. La cour est là.
Lila : D'abord je nomme. On appelle ça Lampe-Figue et Filtre des Herbes.
Karim : Ensuite je montre le schéma. Cela permet de voir le geste.
Dieudonné : Par ailleurs je tiens l'outil avec lequel j'ai coupé.
Patrick : En outre on dit pour et contre, sans cacher le verre qui peut fêler.
Hawa : En conclusion on demande le droit de continuer le test.
Joël : Ce qui compte, c'est une phrase nette, pas un cri.
Rose : C'est le bénéfice que la cour doit retenir : lire, verser.
Marc : Il est probable que Mado pose une question. Répondez, puis silence.
Solange : Je suis sûre que le Bureau notera si le temps est tenu.
Mado : Je doute que l'on tienne si l'on recommence le concept deux fois.
Sami : J'ouvrirai par trois frappes. Je fermerai par une.""",
        tf_item=(
            "Aline autorise quatre minutes si c'est beau.",
            False,
            "« Trois minutes. Pas une de plus. »",
        ),
        qcm_item=(
            "Que doit retenir la cour, selon Rose ?",
            ["un cri", "lire et verser", "une rumeur", "un tampon seul"],
            1,
            "« le bénéfice… : lire, verser. »",
        ),
        pairs=[
            ("d'abord", "nommer"),
            ("ensuite", "schéma"),
            ("en conclusion", "demander de continuer"),
            ("trois minutes", "durée"),
        ],
        fill_item=("Trois minutes. Pas une de ___.", "plus"),
        words=["Ce", "qui", "compte", "c'est", "une", "phrase", "nette", "."],
        anagram=("synthese", "Oral court qui rassemble tout (sans accent)."),
        error=(
            "D'abord je recommence le concept deux fois, ensuite je nomme enfin.",
            "D'abord je nomme. On appelle ça Lampe-Figue et Filtre des Herbes.",
            "On ne recommence pas le concept.",
        ),
        pic_start=25,
        pic_words=["un outil", "une idée", "une feuille", "un soleil"],
        short_p="Listez les cinq marches du pitch et la durée.",
        audio="Enregistrez le plan : nommer, montrer, outil, pour-contre, demander.",
    ),
    _l(
        "CE",
        "CE — Fiche pitch",
        "Lire la fiche d'un oral de trois minutes.",
        "Lisez la fiche, sans aller trop vite.",
        "Fiche d'Aline, pupitre de la cour",
        """Pitch de la cour — 3 minutes
0:00 Sami : trois frappes.
0:10 Lila : On appelle ça Lampe-Figue. Cela permet de lire le soir.
0:40 Karim : On appelle ça Filtre des Herbes. Cela permet de clarifier l'eau.
1:10 Dieudonné : l'outil avec lequel on a coupé ; le banc sur lequel on a testé.
1:40 Pour : lire, verser. Contre : le verre peut fêler ; le tissu peut sentir.
2:10 Doute et certitude : il se peut que le fil glisse ; je suis sûre que l'on saura réparer.
2:40 En conclusion : nous demandons de continuer sous le figuier.
3:00 Sami : une frappe. Silence.
Interdit : mot d'ailleurs, rumeur, dépasser le temps.
Autorisé : un schéma, un verre, un coupon de tissu.
Seuil des Sources — Rukiri-Nord""",
        tf_item=(
            "On peut dépasser le temps si le schéma est beau.",
            False,
            "« Interdit : … dépasser le temps. »",
        ),
        qcm_item=(
            "Qui parle à 1:10 ?",
            ["Lila", "Karim", "Dieudonné", "Sami"],
            2,
            "Dieudonné : l'outil, le banc.",
        ),
        pairs=[
            ("0:10", "Lila / lampe"),
            ("0:40", "Karim / filtre"),
            ("1:40", "pour / contre"),
            ("2:40", "demande"),
        ],
        fill_item=("Interdit : mot d'ailleurs, rumeur, ___ le temps.", "dépasser"),
        words=["Silence", "."],
        anagram=("autorise", "Un schéma, un verre, un coupon : c'est…"),
        error=(
            "Interdit : un schéma. Autorisé : dépasser le temps et une rumeur.",
            "Interdit : mot d'ailleurs, rumeur, dépasser le temps. Autorisé : un schéma, un verre, un coupon.",
            "La fiche inverse serait fausse.",
        ),
        pic_start=26,
        pic_words=["une idée", "une feuille", "un soleil", "un cœur"],
        short_p="Recopiez la fiche-temps et changez l'ordre pour/contre.",
        audio="Lisez la fiche-temps, sans aller trop vite.",
    ),
    _l(
        "PO",
        "PO — Tenir trois minutes",
        "Pitcher à l'oral : synthèse nette.",
        "Répétez le canevas, puis parlez trois minutes.",
        "Canevas de Lila",
        """On appelle ça Lampe-Figue.
Cela permet de lire le soir.
On appelle ça Filtre des Herbes.
Cela permet de clarifier l'eau.
Voici l'outil avec lequel nous avons coupé.
Voici le banc sur lequel nous avons testé.
Pour : lire, verser. Contre : le verre peut fêler.
Il se peut que le fil glisse. Je suis sûre que l'on réparera.
En conclusion, nous demandons de continuer.
Merci à la cour. Merci à Sami.
Je m'arrête.
Le temps est tenu.""",
        tf_item=(
            "Le canevas oublie le contre.",
            False,
            "« Contre : le verre peut fêler. »",
        ),
        qcm_item=(
            "Quelle phrase ferme le pitch ?",
            [
                "On appelle ça Lampe-Figue",
                "Voici l'outil",
                "Nous demandons de continuer",
                "Sami ouvre",
            ],
            2,
            "En conclusion : continuer.",
        ),
        pairs=[
            ("on appelle ça", "noms"),
            ("cela permet de", "usages"),
            ("pour / contre", "balance"),
            ("en conclusion", "demande"),
        ],
        fill_item=("En conclusion, nous demandons de ___.", "continuer"),
        words=["Le", "temps", "est", "tenu", "."],
        anagram=("canevas", "La trame que Lila répète avant l'oral."),
        error=(
            "En conclusion on appelle ça encore deux fois le concept entier.",
            "En conclusion, nous demandons de continuer.",
            "La conclusion demande, elle ne renomme pas tout.",
        ),
        pic_start=27,
        pic_words=["une feuille", "un soleil", "un cœur", "un relatif"],
        short_p="Écrivez votre canevas de douze phrases, chronométrable.",
        audio="Enregistrez un pitch de trois minutes, puis arrêtez-vous.",
    ),
    _l(
        "PE",
        "PE — Mon pitch écrit",
        "Écrire la synthèse orale de trois minutes.",
        "Imitez le pitch de Karim, sans aller trop vite.",
        "Pitch de Karim",
        """Karim
On appelle ça Lampe-Figue. Cela permet de lire le Cahier du chemin.
On appelle ça Filtre des Herbes. Cela permet de verser une eau plus nette.
Voici l'arbre sous lequel nous testons, l'outil avec lequel Dieudonné coupe.
Pour : deux gestes utiles. Contre : le fil peut glisser, le verre peut fêler.
Il est probable que la cour comprendra. Il se peut que le marché attende.
Je suis sûr que nous saurons réparer. Je doute que l'on finisse ce soir.
En conclusion, nous demandons trois soirs de plus sous le figuier.
Karim
Seuil des Sources — Rukiri-Nord""",
        tf_item=(
            "Karim demande trois soirs de plus.",
            True,
            "« nous demandons trois soirs de plus. »",
        ),
        qcm_item=(
            "Quel arbre est cité ?",
            ["un peuplier d'ailleurs", "le figuier", "un pin", "aucun arbre"],
            1,
            "« l'arbre sous lequel nous testons » — le figuier du Seuil.",
        ),
        pairs=[
            ("Lampe-Figue", "lire"),
            ("Filtre des Herbes", "verser"),
            ("pour / contre", "gestes / risques"),
            ("en conclusion", "trois soirs"),
        ],
        fill_item=("Nous demandons trois soirs de ___.", "plus"),
        words=["Voici", "l'outil", "avec", "lequel", "Dieudonné", "coupe", "."],
        anagram=("comprendra", "Il est probable que la cour…"),
        error=(
            "Il est probable que la cour comprenne le schéma demain.",
            "Il est probable que la cour comprendra le schéma demain.",
            "Il est probable que + indicatif.",
        ),
        pic_start=28,
        pic_words=["un soleil", "un cœur", "un relatif", "un talent"],
        short_p="Imitez : noms, usages, relatif, pour-contre, doute, demande.",
        audio="Lisez votre pitch, chronométrez, sans aller trop vite.",
    ),
    _l(
        "EL",
        "EL — Synthèse de trois minutes",
        "Retenir le canevas d'un pitch de la cour.",
        "Apprenez la fiche.",
        "Fiche pitch",
        """Durée : trois minutes. Sami ouvre et ferme.
1. Nommer : on appelle ça… 2. Usage : cela permet de…
3. Relier : avec lequel, sous lequel, auquel
4. Balance : pour / contre
5. Modes : il se peut que + subj. ; je suis sûr(e) que + ind.
6. Conclusion : nous demandons de continuer
Interdit : mot d'ailleurs, rumeur, dépasser, recommencer le concept.
Autorisé : schéma, verre, tissu, une question de Mado, puis silence.
Ce qui compte, c'est une phrase nette.
C'est le bénéfice que la cour retient.
On n'écrit pas un roman. On marche.
Sous le figuier, le temps est une politesse.""",
        tf_item=(
            "On peut recommencer le concept si Mado n'a pas entendu.",
            False,
            "Interdit : recommencer le concept.",
        ),
        qcm_item=(
            "Qui ouvre et ferme le temps ?",
            ["Solange", "Sami", "Félicie", "Yvette"],
            1,
            "Sami : frappes.",
        ),
        pairs=[
            ("on appelle ça", "nommer"),
            ("cela permet de", "usage"),
            ("pour / contre", "balance"),
            ("nous demandons", "conclusion"),
        ],
        fill_item=("Sous le figuier, le temps est une ___.", "politesse"),
        words=["On", "n'écrit", "pas", "un", "roman", "."],
        anagram=("politesse", "Tenir le temps : une… sous le figuier."),
        error=(
            "On recommence le concept si Mado n'a pas entendu la première minute.",
            "Interdit : recommencer le concept. Une question de Mado, puis silence.",
            "On répond, on ne rejoue pas tout.",
        ),
        pic_start=29,
        pic_words=["un cœur", "un relatif", "un talent", "une présentation"],
        short_p="Écrivez votre charte personnelle de pitch en six articles.",
        audio="Enregistrez la fiche et un pitch d'entraînement de trois minutes.",
    ),
]


SEQUENCES = [
    {"title": "Des talents à découvrir", "lessons": S1},
    {"title": "Expliquer une découverte", "lessons": S2},
    {"title": "Argumenter pas à pas", "lessons": S3},
    {"title": "Imaginer demain", "lessons": S4},
    {"title": "Le prototype sous le figuier", "lessons": S5},
    {"title": "Pitcher devant la cour", "lessons": S6},
]
