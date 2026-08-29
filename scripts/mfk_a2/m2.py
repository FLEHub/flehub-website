"""A2 Module 2 — Aventures partagées (univers Seuil des Sources)."""

from factory import L

IMG = "mfk-a2-m2"
IMG_DIR = IMG

MODULE = {
    "title": "A2 — Aventures partagées",
    "description": (
        "Grande étape A2-2 : raconter une expérience, poser des règles, "
        "partager des émotions, mettre en relief un week-end, nommer "
        "l'aventure et dater un parcours — après les préparatifs, sous "
        "le figuier du Seuil des Sources (Rukiri-Nord), vers Mwezi-Haut "
        "et la Maison des Vents."
    ),
}


def _l(comp, title, obj, cons, st, sp, **kw):
    return L(IMG, comp, title, obj, cons, st, sp, **kw)


# ---------------------------------------------------------------------------
# Séquence 1 — Une expérience à raconter (accord du participe avec être)
# ---------------------------------------------------------------------------

S1 = [
    _l(
        "CO",
        "CO — Retours sous le figuier",
        "Repérer l'accord du participe passé avec être : allé(e), parti(e), resté(e).",
        "Lisez le dialogue (à écouter avec l'enseignant). Qui est allé où ?",
        "Banc du Seuil, soirée ocre",
        """Léa : Hier, je suis allée jusqu'au premier virage de Mwezi-Haut.
Patrick : Moi, je suis parti avant l'aube, avec le minibus Figuier 7.
Rose : Hawa et moi, nous sommes parties ensemble, vers le lac des Nénuphars.
Hawa : C'est vrai. Nous sommes restées une heure au bord de l'eau.
Marc : Je suis resté sous le figuier : j'avais le Cahier du chemin.
Solange : Je suis née près de Rive d'Orage, mais je suis devenue guide ici.
Joël : Léa est revenue tard. Kévin est tombé sur une racine, sans gravité.
Aline : Notez : elle est allée, elles sont parties, il est tombé.""",
        tf_item=(
            "Rose et Hawa sont parties ensemble vers le lac.",
            True,
            "Rose : « nous sommes parties ensemble, vers le lac ». ",
        ),
        qcm_item=(
            "Qui est resté sous le figuier ?",
            ["Patrick", "Marc", "Joël", "Kévin"],
            1,
            "Marc : « Je suis resté sous le figuier. »",
        ),
        pairs=[
            ("je suis allée", "Léa"),
            ("je suis parti", "Patrick"),
            ("nous sommes parties", "Rose et Hawa"),
            ("il est tombé", "Kévin"),
        ],
        fill_item=("Léa est ___ tard. (revenir, fém.)", "revenue"),
        words=["Nous", "sommes", "parties", "ensemble", "."],
        anagram=("allée", "Léa est… jusqu'au virage : participe féminin."),
        error=(
            "Rose et Hawa sont partis ensemble vers le lac.",
            "Rose et Hawa sont parties ensemble vers le lac.",
            "Deux femmes : parties, avec e et s.",
        ),
        pic_start=0,
        pic_words=["un récit", "une valise", "une photo", "un accord"],
        short_p="Notez quatre participes entendus et leur sujet (il / elle / elles).",
        audio="Enregistrez : Je suis allée. Nous sommes parties. Il est tombé. Je suis resté.",
    ),
    _l(
        "CE",
        "CE — Cartes du Cahier du chemin",
        "Lire des récits courts et vérifier l'accord avec être.",
        "Lisez les cartes épinglées au figuier, sans aller trop vite.",
        "Cahier du chemin, page mauve",
        """Carte Léa — Je suis allée à Mwezi-Haut. Je suis revenue avant la nuit.
Carte Patrick — Je suis parti tôt. Je ne suis pas resté au camp.
Carte Rose et Hawa — Nous sommes nées ici, près du Seuil. Nous sommes devenues amies sur le sentier.
Carte Kévin — Je suis tombé, puis je suis resté assis près d'un arbre.
Carte Solange — J'étais partie à Rive d'Orage ; je suis devenue guide à la Maison des Vents.
Règle : avec être, le participe s'accorde avec le sujet.""",
        tf_item=(
            "Patrick est resté au camp.",
            False,
            "Carte Patrick : « Je ne suis pas resté au camp. »",
        ),
        qcm_item=(
            "Qui écrit « nous sommes devenues amies » ?",
            ["Léa", "Patrick", "Rose et Hawa", "Kévin"],
            2,
            "Carte Rose et Hawa.",
        ),
        pairs=[
            ("allée / revenue", "Léa"),
            ("parti", "Patrick"),
            ("nées / devenues", "Rose et Hawa"),
            ("tombé", "Kévin"),
        ],
        fill_item=("Nous sommes ___ amies sur le sentier.", "devenues"),
        words=["Je", "suis", "tombé", "puis", "je", "suis", "resté", "."],
        anagram=("nées", "Rose et Hawa : nous sommes… ici, près du Seuil."),
        error=(
            "Nous sommes devenu amies sur le sentier.",
            "Nous sommes devenues amies sur le sentier.",
            "Sujet féminin pluriel : devenues.",
        ),
        pic_start=1,
        pic_words=["une valise", "une photo", "un accord", "une affiche"],
        short_p="Recopiez deux cartes et soulignez chaque accord.",
        audio="Lisez les cinq cartes à voix haute, sans aller trop vite.",
    ),
    _l(
        "PO",
        "PO — Dire je suis allé(e)",
        "Accorder le participe à l'oral selon le sujet.",
        "Répétez les modèles, puis racontez une sortie du Seuil.",
        "Modèles d'Aline",
        """Je suis allé au lac. / Je suis allée au lac.
Tu es parti tôt. / Tu es partie tôt.
Il est resté. / Elle est restée.
Nous sommes revenus. / Nous sommes revenues.
Elles sont parties.
Il est tombé. / Elle est tombée.
Je suis né ici. / Je suis née ici.
Il est devenu guide. / Elle est devenue guide.""",
        tf_item=(
            "Après être, le participe s'accorde avec le sujet.",
            True,
            "Elle est restée, elles sont parties.",
        ),
        qcm_item=(
            "Quelle forme va avec « Léa et Rose » ?",
            ["sont parti", "sont partie", "sont parties", "est parties"],
            2,
            "Elles sont parties.",
        ),
        pairs=[
            ("allé / allée", "masculin / féminin"),
            ("parti / partie", "un / une personne"),
            ("resté / restée", "accord du sujet"),
            ("elles sont parties", "féminin pluriel"),
        ],
        fill_item=("Elle est ___ sous le figuier. (rester)", "restée"),
        words=["Elles", "sont", "parties", "vers", "le", "lac", "."],
        anagram=("tombée", "Hawa est… : elle a perdu l'équilibre, féminin."),
        error=(
            "Léa est allé jusqu'au virage.",
            "Léa est allée jusqu'au virage.",
            "Léa : féminin, allée.",
        ),
        pic_start=2,
        pic_words=["une photo", "un accord", "une affiche", "un panneau"],
        short_p="Écrivez six phrases : trois masculines, trois féminines, avec être.",
        audio="Enregistrez les modèles, puis deux phrases à vous (un homme, une femme).",
    ),
    _l(
        "PE",
        "PE — Mon récit d'étape",
        "Écrire un court récit avec des participes accordés.",
        "Imitez le récit de Rose.",
        "Récit de Rose Iradukunda",
        """Rose Iradukunda
Je suis partie à l'aube vers le lac des Nénuphars.
Hawa est restée près de moi : nous sommes allées sans courir.
Solange est devenue notre guide pour une heure.
Kévin est tombé, puis il est revenu vers le groupe.
Je suis née ici, et je suis revenue plus calme.
Rose
Seuil des Sources — après Mwezi-Haut""",
        tf_item=(
            "Rose dit qu'elle est née ailleurs.",
            False,
            "« Je suis née ici. »",
        ),
        qcm_item=(
            "Qui est devenue guide pour une heure ?",
            ["Hawa", "Rose", "Solange", "Léa"],
            2,
            "« Solange est devenue notre guide. »",
        ),
        pairs=[
            ("je suis partie", "Rose"),
            ("nous sommes allées", "Rose et Hawa"),
            ("est devenue", "Solange"),
            ("est tombé", "Kévin"),
        ],
        fill_item=("Je suis ___ ici. (naître, fém.)", "née"),
        words=["Nous", "sommes", "allées", "sans", "courir", "."],
        anagram=("revenue", "Rose est… plus calme : elle est rentrée."),
        error=(
            "Hawa est resté près de moi.",
            "Hawa est restée près de moi.",
            "Hawa : féminin, restée.",
        ),
        pic_start=3,
        pic_words=["un accord", "une affiche", "un panneau", "un conseil"],
        short_p="Imitez : six lignes, quatre verbes différents avec être.",
        audio="Lisez votre récit, une phrase, une pause, sans aller trop vite.",
    ),
    _l(
        "EL",
        "EL — Accord avec être",
        "Retenir l'accord du participe passé conjugué avec être.",
        "Apprenez la fiche.",
        "Fiche du carnet",
        """Avec être, le participe s'accorde avec le sujet.
allé / allée / allés / allées
parti / partie / partis / parties
resté / restée / restés / restées
né / née / nés / nées
devenu / devenue / devenus / devenues
revenu / revenue / revenus / revenues
tombé / tombée / tombés / tombées
Elles sont parties. (pas : elles sont parti)
Attention : je suis allé (homme) / je suis allée (femme).""",
        tf_item=(
            "On écrit « elles sont parti » sans e ni s.",
            False,
            "Elles sont parties.",
        ),
        qcm_item=(
            "Quelle forme est correcte pour Rose ?",
            ["est allé", "est allée", "sont allé", "est allés"],
            1,
            "Rose : elle est allée.",
        ),
        pairs=[
            ("être + PP", "accord avec le sujet"),
            ("elles sont parties", "fém. pluriel"),
            ("il est devenu", "masc. singulier"),
            ("je suis née", "femme qui parle"),
        ],
        fill_item=("Elles sont ___ vers le lac. (partir)", "parties"),
        words=["Je", "suis", "allée", "à", "Mwezi-Haut", "."],
        anagram=("devenue", "Solange est… guide : elle a changé de rôle."),
        error=(
            "Elles sont parti trop tôt.",
            "Elles sont parties trop tôt.",
            "Féminin pluriel : parties.",
        ),
        pic_start=4,
        pic_words=["une affiche", "un panneau", "un conseil", "un carnet"],
        short_p="Conjuguez sept verbes avec être au féminin et au masculin.",
        audio="Enregistrez la fiche, puis quatre exemples à vous.",
    ),
]


# ---------------------------------------------------------------------------
# Séquence 2 — Règles et conseils (obligation, interdiction, subjonctif intro)
# ---------------------------------------------------------------------------

S2 = [
    _l(
        "CO",
        "CO — Avant la montée",
        "Comprendre il faut que + subjonctif et les interdictions.",
        "Lisez le dialogue. Quelles règles Aline et Karim donnent-ils ?",
        "Seuil de la Maison des Vents",
        """Aline : Il faut que vous partiez avant huit heures.
Karim : Il est important que tu sois prudent sur les pierres.
Patrick : Je veux que Léa revienne avant la nuit.
Léa : Il faut que nous fassions une pause à l'ombre.
Hawa : Il est interdit de courir près du ravin.
Joël : Défense de laisser un sac sur le sentier.
Rose : Il faut qu'il prenne de l'eau, Kévin.
Marc : Je veux que vous restiez ensemble.""",
        tf_item=(
            "On a le droit de courir près du ravin.",
            False,
            "Hawa : « Il est interdit de courir près du ravin. »",
        ),
        qcm_item=(
            "Que veut Patrick ?",
            [
                "Que Léa reste au camp",
                "Que Léa revienne avant la nuit",
                "Que Karim parte seul",
                "Que Joël coure",
            ],
            1,
            "« Je veux que Léa revienne avant la nuit. »",
        ),
        pairs=[
            ("il faut que vous partiez", "obligation"),
            ("il est important que tu sois", "conseil + subj."),
            ("il est interdit de", "interdiction"),
            ("défense de", "interdiction courte"),
        ],
        fill_item=("Il faut que nous ___ une pause. (faire)", "fassions"),
        words=["Il", "faut", "que", "tu", "sois", "prudent", "."],
        anagram=("fassions", "Il faut que nous… une pause : subjonctif de faire."),
        error=(
            "Il faut que vous partez avant huit heures.",
            "Il faut que vous partiez avant huit heures.",
            "Après il faut que : subjonctif, partiez.",
        ),
        pic_start=5,
        pic_words=["un panneau", "un conseil", "un carnet", "un cahier"],
        short_p="Notez deux obligations avec que et deux interdictions avec de.",
        audio="Enregistrez : Il faut que tu sois prudent. Il est interdit de courir. Défense de laisser un sac.",
    ),
    _l(
        "CE",
        "CE — Affiche de la Maison des Vents",
        "Lire des règles : subjonctif introductif et interdictions.",
        "Lisez l'affiche, sans aller trop vite.",
        "Panneau ocre, cour intérieure",
        """Maison des Vents — consignes de sortie
1. Il faut que chacun parte avec une gourde.
2. Il est important que vous soyez à l'heure au banc.
3. Je veux que le groupe fasse silence près des nids.
4. Il est interdit de cueillir les herbes de Solange.
5. Défense de fumer sous le figuier.
6. Il faut qu'Aline sache qui reste à l'infirmerie.
Karim Bamba — relais du Seuil""",
        tf_item=(
            "On peut cueillir les herbes de Solange.",
            False,
            "« Il est interdit de cueillir les herbes de Solange. »",
        ),
        qcm_item=(
            "Qui doit savoir qui reste à l'infirmerie ?",
            ["Karim", "Aline", "Patrick", "Lila"],
            1,
            "« Il faut qu'Aline sache qui reste. »",
        ),
        pairs=[
            ("il faut que chacun parte", "gourde"),
            ("que vous soyez", "à l'heure"),
            ("interdit de cueillir", "herbes"),
            ("défense de fumer", "figuier"),
        ],
        fill_item=("Il est important que vous ___ à l'heure. (être)", "soyez"),
        words=["Défense", "de", "fumer", "sous", "le", "figuier", "."],
        anagram=("soyez", "Il est important que vous… à l'heure : subjonctif d'être."),
        error=(
            "Il faut que Aline sait qui reste.",
            "Il faut qu'Aline sache qui reste.",
            "Savoir au subjonctif : sache. Élision : qu'Aline.",
        ),
        pic_start=6,
        pic_words=["un conseil", "un carnet", "un cahier", "la pluie"],
        short_p="Recopiez l'affiche et encadrez que + verbe au subjonctif.",
        audio="Lisez les six points, sans aller trop vite.",
    ),
    _l(
        "PO",
        "PO — Il faut que, défense de",
        "Donner un conseil avec le subjonctif et une interdiction avec de.",
        "Répétez, puis donnez des règles pour une sortie.",
        "Modèles d'Aline",
        """Il faut que tu partes tôt.
Il faut qu'il soit prudent.
Il faut que nous fassions une pause.
Il est important que vous restiez ensemble.
Je veux que Léa revienne.
Il est interdit de courir.
Défense de laisser un sac.""",
        tf_item=(
            "Après « il faut que », on emploie le subjonctif.",
            True,
            "Il faut que tu partes, que tu sois, que nous fassions.",
        ),
        qcm_item=(
            "Quelle phrase est une interdiction ?",
            [
                "Il faut que tu partes",
                "Je veux que Léa revienne",
                "Il est interdit de courir",
                "Il est important que vous restiez",
            ],
            2,
            "Interdit de + infinitif.",
        ),
        pairs=[
            ("il faut que + subj.", "obligation personnelle"),
            ("il est interdit de + inf.", "interdiction"),
            ("défense de + inf.", "panneau court"),
            ("je veux que", "souhait + subj."),
        ],
        fill_item=("Il faut qu'il ___ prudent. (être)", "soit"),
        words=["Il", "est", "interdit", "de", "courir", "."],
        anagram=("partiez", "Il faut que vous… tôt : subjonctif de partir, vous."),
        error=(
            "Il faut que nous faisons une pause.",
            "Il faut que nous fassions une pause.",
            "Faire au subjonctif : fassions.",
        ),
        pic_start=7,
        pic_words=["un carnet", "un cahier", "la pluie", "un rire"],
        short_p="Écrivez quatre il faut que et deux défense de / interdit de.",
        audio="Enregistrez les sept modèles, puis deux règles à vous.",
    ),
    _l(
        "PE",
        "PE — Mon mot de consignes",
        "Écrire des consignes avec subjonctif et interdiction.",
        "Imitez le mot d'Aline.",
        "Mot d'Aline Uwase",
        """Aline Uwase
Il faut que vous partiez ensemble.
Il est important que tu sois à l'heure au banc.
Je veux que Kévin prenne sa gourde.
Il est interdit de courir près du ravin.
Défense de laisser un sac sur le sentier.
Il faut que nous fassions silence près des nids.
Aline
Maison des Vents""",
        tf_item=(
            "Aline veut que Kévin oublie sa gourde.",
            False,
            "« Je veux que Kévin prenne sa gourde. »",
        ),
        qcm_item=(
            "Quelle phrase utilise le subjonctif de faire ?",
            [
                "Il faut que vous partiez ensemble",
                "Il faut que nous fassions silence",
                "Défense de laisser un sac",
                "Aline",
            ],
            1,
            "Fassions = subjonctif de faire.",
        ),
        pairs=[
            ("que vous partiez", "ensemble"),
            ("que tu sois", "à l'heure"),
            ("interdit de courir", "ravin"),
            ("défense de laisser", "sac"),
        ],
        fill_item=("Je veux que Kévin ___ sa gourde. (prendre)", "prenne"),
        words=["Il", "faut", "que", "nous", "fassions", "silence", "."],
        anagram=("prenne", "Je veux que Kévin… sa gourde : subjonctif de prendre."),
        error=(
            "Il est interdit que courir près du ravin.",
            "Il est interdit de courir près du ravin.",
            "Interdit de + infinitif (pas que).",
        ),
        pic_start=8,
        pic_words=["un cahier", "la pluie", "un rire", "un banc"],
        short_p="Imitez : six lignes, trois que + subj. et deux interdictions.",
        audio="Lisez votre mot, sans aller trop vite.",
    ),
    _l(
        "EL",
        "EL — Subjonctif et interdiction",
        "Retenir il faut que / je veux que + subj. et interdit de / défense de.",
        "Apprenez la fiche.",
        "Fiche d'Aline",
        """Après il faut que, il est important que, je veux que → subjonctif.
être : que je sois, que tu sois, qu'il soit, que nous soyons, que vous soyez
faire : que je fasse, que nous fassions
partir : que je parte, que vous partiez
prendre : que je prenne
savoir : qu'elle sache
Interdiction : il est interdit de + infinitif / défense de + infinitif
On ne dit pas : il faut que tu pars. On dit : il faut que tu partes.
Toujours : il faut (pas je faut).""",
        tf_item=(
            "On dit « je faut que tu partes ».",
            False,
            "Toujours il faut.",
        ),
        qcm_item=(
            "« Faire » au subjonctif, nous :",
            ["faisons", "fassions", "ferons", "faisions"],
            1,
            "Que nous fassions.",
        ),
        pairs=[
            ("il faut que", "subjonctif"),
            ("il est interdit de", "infinitif"),
            ("que tu sois", "être"),
            ("que nous fassions", "faire"),
        ],
        fill_item=("Il faut que tu ___ tôt. (partir)", "partes"),
        words=["Il", "faut", "qu'il", "soit", "prudent", "."],
        anagram=("sois", "Il faut que tu… prudent : subjonctif d'être, tu."),
        error=(
            "Je faut que vous restiez ensemble.",
            "Il faut que vous restiez ensemble.",
            "Toujours il faut, 3e personne.",
        ),
        pic_start=9,
        pic_words=["la pluie", "un rire", "un banc", "un week-end"],
        short_p="Complétez un tableau : six verbes au subjonctif (tu / nous / il).",
        audio="Enregistrez la fiche et cinq exemples.",
    ),
]


# ---------------------------------------------------------------------------
# Séquence 3 — Émotions et souvenirs (passé composé vs imparfait)
# ---------------------------------------------------------------------------

S3 = [
    _l(
        "CO",
        "CO — Sous la pluie, puis le rire",
        "Distinguer l'arrière-plan (imparfait) et l'événement (passé composé).",
        "Lisez le dialogue. Qu'est-ce qui durait ? Qu'est-ce qui est arrivé ?",
        "Figuier, après l'averse",
        """Léa : Il pleuvait fort. Soudain, Patrick a glissé, puis il a ri.
Hawa : Nous marchions vers le lac quand le soleil est revenu.
Marc : J'étais fatigué, alors je me suis assis sur le banc.
Rose : Kévin avait peur, mais il a continué.
Joël : Mado racontait une histoire. Tout le monde a écouté.
Aline : L'imparfait peint le décor. Le passé composé dit le fait.
Karim : Il faisait froid. Nous avons allumé le feu de camp.
Solange : Je me sentais légère. J'ai pris une photo.""",
        tf_item=(
            "« Il pleuvait » décrit un décor, pas un coup d'action unique.",
            True,
            "Imparfait = arrière-plan.",
        ),
        qcm_item=(
            "Quel verbe raconte l'événement soudain ?",
            ["pleuvait", "marchions", "a glissé", "faisait"],
            2,
            "Patrick a glissé : passé composé.",
        ),
        pairs=[
            ("il pleuvait", "imparfait / décor"),
            ("il a glissé", "passé composé / fait"),
            ("nous marchions", "en cours"),
            ("le soleil est revenu", "changement"),
        ],
        fill_item=("Il ___ fort. Soudain, Patrick a glissé. (pleuvoir)", "pleuvait"),
        words=["Nous", "marchions", "quand", "le", "soleil", "est", "revenu", "."],
        anagram=("pleuvait", "Le ciel versait de l'eau : décor à l'imparfait."),
        error=(
            "Il a plu fort et soudain Patrick glissait.",
            "Il pleuvait fort. Soudain, Patrick a glissé.",
            "Décor à l'imparfait, événement au passé composé.",
        ),
        pic_start=10,
        pic_words=["un rire", "un banc", "un week-end", "c'est qui"],
        short_p="Classez six verbes du dialogue : imparfait ou passé composé.",
        audio="Enregistrez : Il pleuvait. Soudain, il a glissé. Nous marchions. Le soleil est revenu.",
    ),
    _l(
        "CE",
        "CE — Pages d'émotions",
        "Lire des souvenirs qui mêlent imparfait et passé composé.",
        "Lisez les pages, sans aller trop vite.",
        "Cahier mauve, Salle des Herbes",
        """Page Léa — Le vent soufflait. J'ai vu l'Île de Sable-Rouge au loin.
Page Patrick — Nous étions silencieux. Puis Joël a chanté trop fort, et nous avons ri.
Page Hawa — J'avais froid aux mains. Rose m'a prêté ses gants.
Page Marc — La tente claquait. Sami a calé un piquet.
Page Yvette — Les lampions du marché brillaient. J'ai acheté une ficelle ocre.
Rappel : habitude / décor / émotion → imparfait. Fait unique → passé composé.""",
        tf_item=(
            "Léa a vu l'île pendant que le vent soufflait.",
            True,
            "Soufflait (décor) + j'ai vu (fait).",
        ),
        qcm_item=(
            "Qui a calé un piquet ?",
            ["Patrick", "Joël", "Sami", "Yvette"],
            2,
            "Page Marc : « Sami a calé un piquet. »",
        ),
        pairs=[
            ("le vent soufflait", "imparfait"),
            ("j'ai vu l'île", "passé composé"),
            ("nous avons ri", "événement"),
            ("les lampions brillaient", "décor"),
        ],
        fill_item=("J'___ froid aux mains. Rose m'a prêté ses gants.", "avais"),
        words=["Joël", "a", "chanté", "et", "nous", "avons", "ri", "."],
        anagram=("soufflait", "Le vent… : décor long, pas un seul coup."),
        error=(
            "Le vent a soufflé tout le temps et j'ai vu rien.",
            "Le vent soufflait tout le temps et je n'ai rien vu.",
            "Décor à l'imparfait ; ne… rien au passé composé.",
        ),
        pic_start=11,
        pic_words=["un banc", "un week-end", "c'est qui", "c'est que"],
        short_p="Recopiez une page et ajoutez une phrase à l'imparfait, une au PC.",
        audio="Lisez les cinq pages, sans aller trop vite.",
    ),
    _l(
        "PO",
        "PO — Raconter un souvenir",
        "Enchaîner un décor à l'imparfait et un fait au passé composé.",
        "Répétez, puis racontez deux minutes sous le figuier.",
        "Modèles de Marc",
        """Il pleuvait.
Nous marchions.
J'étais fatigué.
Soudain, Léa a ri.
Le soleil est revenu.
Nous avons allumé le feu.
Kévin avait peur, mais il a continué.""",
        tf_item=(
            "« Soudain » annonce souvent un passé composé.",
            True,
            "Un événement entre dans le décor.",
        ),
        qcm_item=(
            "Quelle phrase peint une émotion durable ?",
            ["Léa a ri", "Le soleil est revenu", "J'étais fatigué", "Nous avons allumé"],
            2,
            "Imparfait pour l'état.",
        ),
        pairs=[
            ("imparfait", "décor / émotion / habitude"),
            ("passé composé", "fait / changement"),
            ("soudain", "bascule"),
            ("quand + PC", "interruption"),
        ],
        fill_item=("Soudain, Léa ___ ri.", "a"),
        words=["J'étais", "fatigué", "alors", "je", "me", "suis", "assis", "."],
        anagram=("fatigué", "Marc l'était : état long, avant de s'asseoir. (avec accent)"),
        error=(
            "Nous avons marché quand le soleil revenait soudain.",
            "Nous marchions quand le soleil est revenu.",
            "Action en cours à l'imparfait, interruption au PC.",
        ),
        pic_start=12,
        pic_words=["un week-end", "c'est qui", "c'est que", "une tente"],
        short_p="Écrivez un souvenir de six lignes : trois imparfaits, trois PC.",
        audio="Enregistrez les modèles, puis un souvenir à vous.",
    ),
    _l(
        "PE",
        "PE — Ma page de souvenir",
        "Écrire un souvenir avec les deux temps du récit.",
        "Imitez la page de Léa.",
        "Page de Léa Niyonzima",
        """Léa Niyonzima
Il pleuvait sur le sentier de Mwezi-Haut.
Nous marchions sans parler.
J'avais les pieds mouillés.
Soudain, Patrick a glissé et tout le monde a ri.
Le soleil est revenu près du lac.
Je me suis sentie légère.
Léa
Sous le figuier — soir""",
        tf_item=(
            "Léa écrit que le groupe parlait beaucoup.",
            False,
            "« Nous marchions sans parler. »",
        ),
        qcm_item=(
            "Quel verbe est au passé composé ?",
            ["pleuvait", "marchions", "a glissé", "avais"],
            2,
            "Patrick a glissé.",
        ),
        pairs=[
            ("il pleuvait", "décor"),
            ("nous marchions", "action en cours"),
            ("a glissé / a ri", "faits"),
            ("je me suis sentie", "changement"),
        ],
        fill_item=("Je me suis ___ légère. (sentir, fém.)", "sentie"),
        words=["Le", "soleil", "est", "revenu", "près", "du", "lac", "."],
        anagram=("glissé", "Patrick a… : un fait soudain sur les pierres."),
        error=(
            "Je me suis senti légère.",
            "Je me suis sentie légère.",
            "Léa : accord du participe avec le sujet féminin (pronominal).",
        ),
        pic_start=13,
        pic_words=["c'est qui", "c'est que", "une tente", "une carte"],
        short_p="Imitez : six lignes, décor à l'imparfait, deux faits au PC.",
        audio="Lisez votre page, sans aller trop vite.",
    ),
    _l(
        "EL",
        "EL — Passé composé et imparfait",
        "Retenir quand raconter au PC et quand peindre à l'imparfait.",
        "Apprenez la fiche.",
        "Fiche du carnet",
        """Imparfait : décor, émotion, habitude, action en cours.
Il pleuvait. Nous marchions. J'avais peur. Mado racontait.
Passé composé : fait, changement, événement unique.
Il a glissé. Nous avons ri. Le soleil est revenu.
Souvent : imparfait + quand / soudain + passé composé.
Attention : j'étais (état) ≠ j'ai été (un moment vécu comme un fait).
Accord : je me suis sentie (féminin) / je me suis senti (masculin).""",
        tf_item=(
            "L'imparfait sert surtout à lister des faits soudains.",
            False,
            "L'imparfait peint le décor. Le PC dit le fait.",
        ),
        qcm_item=(
            "« Nous marchions quand… » continue souvent par…",
            ["il pleuvait encore", "le soleil est revenu", "j'étais fatigué", "Mado racontait"],
            1,
            "Quand + événement au PC.",
        ),
        pairs=[
            ("imparfait", "décor"),
            ("passé composé", "fait"),
            ("soudain", "bascule"),
            ("habitude", "imparfait"),
        ],
        fill_item=("Nous ___ quand Patrick a glissé. (marcher)", "marchions"),
        words=["Il", "pleuvait", ".", "Soudain", "il", "a", "ri", "."],
        anagram=("décor", "L'imparfait peint le… : le temps, le lieu, l'émotion."),
        error=(
            "Hier il a pleuvait et nous avons marché longtemps le décor.",
            "Hier il pleuvait et nous avons marché longtemps.",
            "Un seul auxiliaire : pleuvait (imparfait) / avons marché (PC).",
        ),
        pic_start=14,
        pic_words=["c'est que", "une tente", "une carte", "un sac"],
        short_p="Transformez cinq paires : décor (imp.) + fait (PC).",
        audio="Enregistrez la fiche et trois souvenirs courts.",
    ),
]


# ---------------------------------------------------------------------------
# Séquence 4 — Un week-end à thème (c'est… qui / c'est… que)
# ---------------------------------------------------------------------------

S4 = [
    _l(
        "CO",
        "CO — Qui a fait le week-end",
        "Repérer la mise en relief : c'est… qui (sujet), c'est… que (COD).",
        "Lisez le dialogue. Qui met quoi en avant ?",
        "Cour de la Maison des Vents",
        """Aline : C'est Léa qui a préparé le feu de camp.
Patrick : C'est le sentier que Marc a choisi, pas la route.
Hawa : C'est Rose qui a tendu la tente sous le figuier.
Joël : C'est la chanson que Mado a chantée, près des lampions.
Karim : Ce sont Patrick et moi qui avons porté l'eau.
Solange : C'est l'heure que vous avez oubliée, pas le lieu.
Léa : C'est Aline qui donne le thème : « vents et récits ».
Marc : C'est ce week-end que je garderai.""",
        tf_item=(
            "C'est Léa qui a préparé le feu.",
            True,
            "Aline met Léa en relief (sujet).",
        ),
        qcm_item=(
            "Que met Patrick en relief ?",
            ["La route", "Le sentier", "La tente", "L'eau"],
            1,
            "« C'est le sentier que Marc a choisi. »",
        ),
        pairs=[
            ("c'est Léa qui", "sujet mis en relief"),
            ("c'est le sentier que", "COD mis en relief"),
            ("ce sont Patrick et moi qui", "pluriel"),
            ("c'est l'heure que", "chose oubliée"),
        ],
        fill_item=("C'est Léa ___ a préparé le feu.", "qui"),
        words=["C'est", "le", "sentier", "que", "Marc", "a", "choisi", "."],
        anagram=("relief", "C'est… qui / que : on met un mot en…"),
        error=(
            "C'est Léa que a préparé le feu.",
            "C'est Léa qui a préparé le feu.",
            "Sujet → qui. COD → que.",
        ),
        pic_start=15,
        pic_words=["une tente", "une carte", "un sac", "une boussole"],
        short_p="Notez trois c'est… qui et deux c'est… que.",
        audio="Enregistrez : C'est Léa qui a préparé le feu. C'est le sentier que Marc a choisi.",
    ),
    _l(
        "CE",
        "CE — Programme du week-end",
        "Lire un programme qui insiste avec c'est… qui / que.",
        "Lisez le programme, sans aller trop vite.",
        "Feuille mauve, Table des Sources",
        """Week-end à thème — Maison des Vents
C'est Karim qui ouvre le samedi à neuf heures.
C'est la Salle des Herbes que nous gardons pour les récits.
C'est Félicie qui prépare la table, pas l'atelier.
C'est le silence que je demande après vingt-deux heures. (Aline)
Ce sont Hawa et Rose qui tiennent le feu.
C'est Mwezi-Haut que le dimanche réserve, si le ciel est clair.
Lila Sow — Radio Figuier annoncera : c'est ce thème que nous suivons.""",
        tf_item=(
            "Félicie prépare l'atelier, d'après le programme.",
            False,
            "« C'est Félicie qui prépare la table, pas l'atelier. »",
        ),
        qcm_item=(
            "Qui ouvre le samedi ?",
            ["Aline", "Karim", "Lila", "Félicie"],
            1,
            "« C'est Karim qui ouvre le samedi. »",
        ),
        pairs=[
            ("c'est Karim qui", "ouvre"),
            ("c'est la salle que", "récits"),
            ("ce sont Hawa et Rose qui", "feu"),
            ("c'est Mwezi-Haut que", "dimanche"),
        ],
        fill_item=("C'est la Salle des Herbes ___ nous gardons.", "que"),
        words=["C'est", "Karim", "qui", "ouvre", "le", "samedi", "."],
        anagram=("theme", "Week-end à… : vents et récits (sans accent)."),
        error=(
            "C'est la Salle des Herbes qui nous gardons.",
            "C'est la Salle des Herbes que nous gardons.",
            "Nous gardons la salle → que (COD).",
        ),
        pic_start=16,
        pic_words=["une carte", "un sac", "une boussole", "une liste"],
        short_p="Réécrivez trois lignes en enlevant puis en remettant c'est… qui / que.",
        audio="Lisez le programme, sans aller trop vite.",
    ),
    _l(
        "PO",
        "PO — Insister avec c'est",
        "Mettre un nom en relief à l'oral.",
        "Répétez, puis insistez sur un moment du week-end.",
        "Modèles de Karim",
        """C'est Léa qui prépare.
C'est Patrick qui porte l'eau.
C'est le sentier que nous prenons.
C'est la tente que Rose a tendue.
Ce sont eux qui chantent.
C'est ce week-end que je garde.""",
        tf_item=(
            "« Qui » reprend le sujet mis en avant.",
            True,
            "C'est Léa qui prépare : Léa = sujet.",
        ),
        qcm_item=(
            "On dit « C'est la tente… Rose a tendue » comment ?",
            ["qui", "que", "dont", "où"],
            1,
            "Rose a tendu la tente → que.",
        ),
        pairs=[
            ("c'est… qui", "sujet"),
            ("c'est… que", "COD"),
            ("ce sont… qui", "plusieurs personnes"),
            ("c'est ce week-end que", "moment"),
        ],
        fill_item=("Ce sont eux ___ chantent.", "qui"),
        words=["C'est", "la", "tente", "que", "Rose", "a", "tendue", "."],
        anagram=("tendue", "Rose a… la toile : participe accordé avec tente."),
        error=(
            "C'est eux qui chantent.",
            "Ce sont eux qui chantent.",
            "Pluriel : ce sont.",
        ),
        pic_start=17,
        pic_words=["un sac", "une boussole", "une liste", "un fil"],
        short_p="Écrivez six mises en relief : trois qui, trois que.",
        audio="Enregistrez les six modèles, puis deux phrases à vous.",
    ),
    _l(
        "PE",
        "PE — Mon billet de week-end",
        "Écrire un billet qui insiste avec c'est… qui / que.",
        "Imitez le billet de Marc.",
        "Billet de Marc Nkurunziza",
        """Marc Nkurunziza
C'est Léa qui a préparé le feu.
C'est le sentier que j'ai choisi.
C'est Aline qui a donné le thème.
Ce sont Hawa et Rose qui ont tenu la tente.
C'est ce silence que je garde, après les chansons.
C'est la Maison des Vents que nous quitterons lundi.
Marc""",
        tf_item=(
            "Marc dit que Joël a choisi le sentier.",
            False,
            "« C'est le sentier que j'ai choisi. » (Marc)",
        ),
        qcm_item=(
            "Qui a donné le thème ?",
            ["Léa", "Aline", "Karim", "Lila"],
            1,
            "« C'est Aline qui a donné le thème. »",
        ),
        pairs=[
            ("c'est Léa qui", "feu"),
            ("c'est le sentier que", "choix de Marc"),
            ("ce sont Hawa et Rose qui", "tente"),
            ("c'est ce silence que", "souvenir"),
        ],
        fill_item=("C'est Aline ___ a donné le thème.", "qui"),
        words=["C'est", "ce", "silence", "que", "je", "garde", "."],
        anagram=("quitterons", "Nous… la maison lundi : futur de quitter."),
        error=(
            "Ce sont Hawa et Rose que ont tenu la tente.",
            "Ce sont Hawa et Rose qui ont tenu la tente.",
            "Elles font l'action → qui.",
        ),
        pic_start=18,
        pic_words=["une boussole", "une liste", "un fil", "une horloge"],
        short_p="Imitez : six lignes, trois qui et trois que.",
        audio="Lisez votre billet, sans aller trop vite.",
    ),
    _l(
        "EL",
        "EL — C'est… qui, c'est… que",
        "Retenir la mise en relief du sujet et du complément.",
        "Apprenez la fiche.",
        "Fiche de Lila",
        """C'est + nom + qui + verbe : on insiste sur le sujet.
C'est Léa qui prépare. Ce sont Patrick et Joël qui portent.
C'est + nom + que + sujet + verbe : on insiste sur le COD.
C'est le sentier que Marc a choisi.
Élision : c'est l'heure qu'ils ont oubliée.
Pluriel des personnes : ce sont… qui (pas c'est eux qui, à l'écrit soigné).
Ne pas dire : c'est Léa que prépare.""",
        tf_item=(
            "On écrit « c'est Léa que prépare » pour le sujet.",
            False,
            "Sujet → qui.",
        ),
        qcm_item=(
            "« Marc a choisi le sentier » devient…",
            [
                "C'est Marc que a choisi le sentier",
                "C'est le sentier que Marc a choisi",
                "C'est le sentier qui Marc a choisi",
                "C'est Marc que le sentier",
            ],
            1,
            "COD le sentier → c'est le sentier que…",
        ),
        pairs=[
            ("c'est… qui", "sujet"),
            ("c'est… que", "COD"),
            ("ce sont… qui", "plusieurs"),
            ("qu'ils", "élision de que"),
        ],
        fill_item=("C'est l'heure ___ ils ont oubliée.", "qu'"),
        words=["Ce", "sont", "eux", "qui", "chantent", "."],
        anagram=("sujet", "C'est Léa qui : on insiste sur le… de la phrase."),
        error=(
            "C'est le sentier qui Marc a choisi.",
            "C'est le sentier que Marc a choisi.",
            "Marc a choisi le sentier → que.",
        ),
        pic_start=19,
        pic_words=["une liste", "un fil", "une horloge", "un calendrier"],
        short_p="Transformez six phrases simples en c'est… qui ou c'est… que.",
        audio="Enregistrez la fiche et six mises en relief.",
    ),
]


# ---------------------------------------------------------------------------
# Séquence 5 — Partir à l'aventure (genre des noms)
# ---------------------------------------------------------------------------

S5 = [
    _l(
        "CO",
        "CO — Que met-on dans le sac",
        "Repérer le genre : un/une, le/la, et quelques exceptions.",
        "Lisez le dialogue. Un ou une ? Le ou la ?",
        "Départ vers Mwezi-Haut",
        """Hawa : Je prends une image du Seuil, pour le moral.
Patrick : Moi, un arbre dessiné par Marc, plié dans le cahier.
Léa : Une aventure commence au premier pas. Un voyage, c'est plus long.
Joël : La boussole est dans le sac. Le sentier part derrière la tente.
Rose : Une carte, un journal, une photo, un récit : je mélange.
Kévin : La chaussure gauche est trop large. Le feu ? On l'allumera plus tard.
Aline : Attention : une image, un arbre, une aventure, un voyage.
Benoît : J'apporte une lampe. Noura garde le groupe sur la liste.""",
        tf_item=(
            "On dit « un image » pour une photo du Seuil.",
            False,
            "Hawa : « une image ». Image est féminin.",
        ),
        qcm_item=(
            "Quel mot est masculin parmi ces exceptions utiles ?",
            ["image", "aventure", "arbre", "tente"],
            2,
            "Un arbre. Une image, une aventure, une tente.",
        ),
        pairs=[
            ("une image", "féminin"),
            ("un arbre", "masculin"),
            ("une aventure", "féminin"),
            ("un voyage", "masculin"),
        ],
        fill_item=("Je prends ___ image du Seuil.", "une"),
        words=["Une", "aventure", "commence", "au", "premier", "pas", "."],
        anagram=("image", "Hawa en prend une : un dessin ou une photo du Seuil."),
        error=(
            "Je prends un image du Seuil.",
            "Je prends une image du Seuil.",
            "Image est féminin : une image.",
        ),
        pic_start=20,
        pic_words=["un fil", "une horloge", "un calendrier", "une flèche"],
        short_p="Listez huit noms du dialogue avec un/une ou le/la.",
        audio="Enregistrez : une image, un arbre, une aventure, un voyage, la boussole, le sac.",
    ),
    _l(
        "CE",
        "CE — Liste pour Mwezi-Haut",
        "Lire une liste et corriger le genre des noms.",
        "Lisez la liste, sans aller trop vite.",
        "Liste de Benoît Habumuremyi",
        """À prendre — montée vers Mwezi-Haut
une tente, un sac, une boussole, un sentier (sur la carte)
une image du figuier, un arbre pour l'ombre (point de rendez-vous)
une aventure courte, pas un voyage de trois semaines
une carte, un journal, une photo, un récit
une chaussure de rechange, un feu déjà prévu (pierre noire)
une lampe, un groupe de six, la gourde, le cahier
Benoît — vu par Aline : genres vérifiés.""",
        tf_item=(
            "La liste parle d'un voyage de trois semaines.",
            False,
            "« une aventure courte, pas un voyage de trois semaines ».",
        ),
        qcm_item=(
            "Quel objet est féminin ?",
            ["un sac", "un journal", "une boussole", "un récit"],
            2,
            "Une boussole.",
        ),
        pairs=[
            ("une tente / une boussole", "féminin"),
            ("un sac / un sentier", "masculin"),
            ("une photo / une lampe", "féminin"),
            ("un journal / un feu", "masculin"),
        ],
        fill_item=("___ arbre marque le rendez-vous.", "Un"),
        words=["Une", "boussole", "est", "dans", "le", "sac", "."],
        anagram=("boussole", "Elle indique le nord, dans le sac de Joël."),
        error=(
            "Je mets un boussole dans la sac.",
            "Je mets une boussole dans le sac.",
            "Une boussole (fém.). Le sac (masc.).",
        ),
        pic_start=21,
        pic_words=["une horloge", "un calendrier", "une flèche", "un groupe"],
        short_p="Recopiez la liste en deux colonnes : masculin / féminin.",
        audio="Lisez la liste complète, sans aller trop vite.",
    ),
    _l(
        "PO",
        "PO — Dire un ou une",
        "Nommer le matériel avec le bon genre.",
        "Répétez, puis préparez à voix haute le sac du groupe.",
        "Modèles d'Hawa",
        """C'est une image.
C'est un arbre.
C'est une aventure.
C'est un voyage.
Voici la boussole.
Voici le sentier.
J'oublie la tente. Je n'oublie pas le journal.""",
        tf_item=(
            "« Voyage » est masculin : un voyage, le voyage.",
            True,
            "Contrairement à une aventure.",
        ),
        qcm_item=(
            "Quelle paire est correcte ?",
            [
                "un image / une arbre",
                "une image / un arbre",
                "une image / une arbre",
                "un image / un arbre",
            ],
            1,
            "Une image, un arbre.",
        ),
        pairs=[
            ("une / la", "féminin"),
            ("un / le", "masculin"),
            ("au = à + le", "au sentier"),
            ("de + le = du", "près du feu"),
        ],
        fill_item=("Voici ___ sentier. (masc.)", "le"),
        words=["C'est", "une", "aventure", "."],
        anagram=("voyage", "Plus long qu'une aventure : un… vers Port de la Brise."),
        error=(
            "On se retrouve à le sentier derrière la tente.",
            "On se retrouve au sentier derrière la tente.",
            "À + le = au.",
        ),
        pic_start=22,
        pic_words=["un calendrier", "une flèche", "un groupe", "un feu"],
        short_p="Nommez dix objets de l'aventure avec un/une ou le/la.",
        audio="Enregistrez les modèles, puis votre sac (six noms).",
    ),
    _l(
        "PE",
        "PE — Ma liste d'aventure",
        "Écrire une liste de matériel avec les bons genres.",
        "Imitez la liste d'Hawa.",
        "Liste de Hawa Diallo",
        """Hawa Diallo
Je prends une image du Seuil et un arbre dessiné par Marc.
C'est une aventure, pas un voyage.
La boussole reste dans le sac.
Une carte, un journal, une photo, un récit.
J'allume le feu près de la tente.
Hawa
Vers Mwezi-Haut""",
        tf_item=(
            "Hawa dit que c'est un long voyage.",
            False,
            "« C'est une aventure, pas un voyage. »",
        ),
        qcm_item=(
            "Où reste la boussole ?",
            ["Dans la tente", "Dans le sac", "Sur l'arbre", "Au lac"],
            1,
            "« La boussole reste dans le sac. »",
        ),
        pairs=[
            ("une image / un arbre", "exceptions utiles"),
            ("une aventure / un voyage", "durée différente"),
            ("la boussole / le sac", "objets"),
            ("le feu / la tente", "camp"),
        ],
        fill_item=("C'est ___ aventure, pas un voyage.", "une"),
        words=["La", "boussole", "reste", "dans", "le", "sac", "."],
        anagram=("tente", "Toile dressée sous le figuier : une…"),
        error=(
            "Je prends un aventure et une voyage.",
            "Je prends une aventure et un voyage.",
            "Une aventure, un voyage.",
        ),
        pic_start=23,
        pic_words=["une flèche", "un groupe", "un feu", "une carte"],
        short_p="Imitez : six lignes, huit noms avec le bon article.",
        audio="Lisez votre liste, sans aller trop vite.",
    ),
    _l(
        "EL",
        "EL — Genre des noms",
        "Retenir un/une, le/la et quelques exceptions utiles.",
        "Apprenez la fiche.",
        "Fiche du carnet",
        """Masculin : un / le. Féminin : une / la.
Exceptions utiles : une image, un arbre, une aventure, un voyage.
Autres du sac : une tente, un sac, une boussole, un sentier.
une carte, un journal, une photo, un récit.
une chaussure, un feu, une lampe, un groupe.
Contractions : à + le = au (au sentier). de + le = du (près du feu).
On ne dit pas : un image, une arbre, à le sentier.""",
        tf_item=(
            "« Arbre » est féminin.",
            False,
            "Un arbre, le arbre → l'arbre.",
        ),
        qcm_item=(
            "« À + le sentier » s'écrit…",
            ["à le sentier", "au sentier", "aux sentier", "du sentier"],
            1,
            "À + le = au.",
        ),
        pairs=[
            ("une image", "fém. malgré -age parfois masc."),
            ("un arbre", "masc."),
            ("une aventure", "fém."),
            ("un voyage", "masc."),
        ],
        fill_item=("Nous marchons ___ sentier ocre. (à + le)", "au"),
        words=["C'est", "un", "arbre", "."],
        anagram=("arbre", "Grand végétal : un… donne de l'ombre au rendez-vous."),
        error=(
            "Posez la lampe à le milieu du camp.",
            "Posez la lampe au milieu du camp.",
            "À + le = au.",
        ),
        pic_start=24,
        pic_words=["un groupe", "un feu", "une carte", "un journal"],
        short_p="Faites deux listes de douze noms : masculin / féminin, avec un exemple.",
        audio="Enregistrez la fiche et les quatre exceptions.",
    ),
]


# ---------------------------------------------------------------------------
# Séquence 6 — Le fil de mon parcours (il y a, pendant, depuis, dans)
# ---------------------------------------------------------------------------

S6 = [
    _l(
        "CO",
        "CO — Quand tout s'est enchaîné",
        "Repérer il y a, pendant, depuis et dans sur une ligne de temps.",
        "Lisez le dialogue. Quel marqueur pour quel moment ?",
        "Banc du figuier, bilan",
        """Léa : Il y a trois jours, nous sommes arrivés à la Maison des Vents.
Patrick : Pendant le week-end, il a plu, puis le ciel s'est ouvert.
Hawa : Depuis vendredi, je dors sous la tente.
Joël : Dans deux jours, nous irons jusqu'à Mwezi-Haut.
Marc : Il y a une heure, Kévin est tombé ; maintenant il va bien.
Aline : Pendant trois heures, vous avez marché sans pause trop longue.
Rose : Depuis ce matin, le groupe prépare les sacs.
Solange : Dans une semaine, le minibus Figuier 7 reviendra.""",
        tf_item=(
            "« Depuis vendredi » veut dire que Hawa dort encore sous la tente.",
            True,
            "Depuis = début dans le passé, action encore vraie.",
        ),
        qcm_item=(
            "Quel marqueur annonce un projet futur ?",
            ["il y a trois jours", "pendant le week-end", "depuis vendredi", "dans deux jours"],
            3,
            "Dans + durée = plus tard.",
        ),
        pairs=[
            ("il y a", "il y a X : c'était il y a…"),
            ("pendant", "durée terminée"),
            ("depuis", "ça continue"),
            ("dans", "plus tard"),
        ],
        fill_item=("___ deux jours, nous irons à Mwezi-Haut.", "Dans"),
        words=["Il", "y", "a", "trois", "jours", "nous", "sommes", "arrivés", "."],
        anagram=("depuis", "Hawa dort encore sous la toile : … vendredi."),
        error=(
            "Dans trois jours, nous sommes arrivés à la Maison.",
            "Il y a trois jours, nous sommes arrivés à la Maison.",
            "Fait passé révolu → il y a. Dans = futur.",
        ),
        pic_start=25,
        pic_words=["un feu", "une carte", "un journal", "une chaussure"],
        short_p="Classez huit phrases : il y a / pendant / depuis / dans.",
        audio="Enregistrez : Il y a trois jours. Pendant le week-end. Depuis vendredi. Dans deux jours.",
    ),
    _l(
        "CE",
        "CE — Fil du Cahier",
        "Lire une frise de temps avec les quatre marqueurs.",
        "Lisez la frise, sans aller trop vite.",
        "Frise de Solange Mukamana",
        """Fil du parcours — Seuil des Sources
Il y a dix jours : arrivée dans la cour, sous le figuier.
Pendant les trois premiers soirs : récits à la Table des Sources.
Depuis lundi : Radio Figuier enregistre les voix du groupe.
Dans quatre jours : montée vers Mwezi-Haut, si le ciel reste clair.
Il y a une nuit : feu de camp, chaussures près de la lampe.
Pendant une heure : silence demandé par Aline.
Ibrahim a ajouté : depuis l'aube, le minibus attend au Port de la Brise.""",
        tf_item=(
            "Radio Figuier a déjà arrêté d'enregistrer.",
            False,
            "« Depuis lundi : Radio Figuier enregistre » (ça continue).",
        ),
        qcm_item=(
            "Quand aura lieu la montée vers Mwezi-Haut ?",
            ["Il y a dix jours", "Pendant les soirs", "Depuis lundi", "Dans quatre jours"],
            3,
            "Futur : dans quatre jours.",
        ),
        pairs=[
            ("il y a dix jours", "arrivée"),
            ("pendant les soirs", "récits"),
            ("depuis lundi", "radio"),
            ("dans quatre jours", "montée"),
        ],
        fill_item=("___ lundi, la radio enregistre les voix.", "Depuis"),
        words=["Pendant", "une", "heure", "Aline", "a", "demandé", "silence", "."],
        anagram=("pendant", "Durée close : … une heure, puis le silence a cessé."),
        error=(
            "Depuis quatre jours, nous irons à Mwezi-Haut.",
            "Dans quatre jours, nous irons à Mwezi-Haut.",
            "Projet futur → dans. Depuis = déjà commencé.",
        ),
        pic_start=26,
        pic_words=["une carte", "un journal", "une chaussure", "une lampe"],
        short_p="Recopiez la frise et ajoutez une ligne avec chaque marqueur.",
        audio="Lisez la frise complète, sans aller trop vite.",
    ),
    _l(
        "PO",
        "PO — Dater avec quatre mots",
        "Situer un fait : il y a, pendant, depuis, dans.",
        "Répétez, puis datez votre semaine au Seuil.",
        "Modèles d'Aline",
        """Il y a deux jours, nous sommes partis.
Pendant le week-end, il a plu.
Depuis vendredi, je marche.
Dans une semaine, je reviendrai.
Il y a une heure, le groupe a ri.
Pendant trois heures, nous avons grimpé.""",
        tf_item=(
            "« Il y a » regarde vers le passé révolu.",
            True,
            "Il y a deux jours = two days ago.",
        ),
        qcm_item=(
            "Quelle phrase dit qu'une action continue ?",
            [
                "Il y a deux jours, nous sommes partis",
                "Pendant le week-end, il a plu",
                "Depuis vendredi, je marche",
                "Dans une semaine, je reviendrai",
            ],
            2,
            "Depuis + présent (souvent).",
        ),
        pairs=[
            ("il y a + durée", "passé révolu"),
            ("pendant + durée", "durée close"),
            ("depuis + moment", "encore vrai"),
            ("dans + durée", "futur"),
        ],
        fill_item=("___ vendredi, je marche.", "Depuis"),
        words=["Dans", "une", "semaine", "je", "reviendrai", "."],
        anagram=("reviendrai", "Dans une semaine je… : futur de revenir, un r après i."),
        error=(
            "Il y a une semaine, je reviendrai au Seuil.",
            "Dans une semaine, je reviendrai au Seuil.",
            "Futur → dans. Il y a = déjà passé.",
        ),
        pic_start=27,
        pic_words=["un journal", "une chaussure", "une lampe", "un récit"],
        short_p="Écrivez huit phrases : deux de chaque marqueur.",
        audio="Enregistrez les six modèles, puis votre frise orale.",
    ),
    _l(
        "PE",
        "PE — Le fil de ma semaine",
        "Écrire une frise personnelle avec les quatre marqueurs.",
        "Imitez le fil de Joël.",
        "Fil de Joël Mugisha",
        """Joël Mugisha
Il y a cinq jours, j'ai quitté Val-des-Peupliers.
Pendant le week-end, j'ai dormi à la Maison des Vents.
Depuis samedi, je prépare la montée.
Dans trois jours, je serai sur le sentier de Mwezi-Haut.
Il y a une heure, Léa a rangé les lampes.
Pendant une nuit, le vent a parlé dans les figues.
Joël""",
        tf_item=(
            "Joël écrit « je sera » pour le futur.",
            False,
            "« je serai sur le sentier » : futur en -ai.",
        ),
        qcm_item=(
            "Que fait Joël depuis samedi ?",
            ["Il dort encore à Val-des-Peupliers", "Il prépare la montée", "Il quitte le Seuil", "Il éteint Radio Figuier"],
            1,
            "« Depuis samedi, je prépare la montée. »",
        ),
        pairs=[
            ("il y a cinq jours", "départ"),
            ("pendant le week-end", "Maison des Vents"),
            ("depuis samedi", "prépare"),
            ("dans trois jours", "sentier"),
        ],
        fill_item=("Dans trois jours, je ___ sur le sentier. (être, futur)", "serai"),
        words=["Depuis", "samedi", "je", "prépare", "la", "montée", "."],
        anagram=("serai", "Dans trois jours je… là-haut : futur d'être, je."),
        error=(
            "Dans trois jours, je sera sur le sentier.",
            "Dans trois jours, je serai sur le sentier.",
            "Je serai (pas je sera).",
        ),
        pic_start=28,
        pic_words=["une chaussure", "une lampe", "un récit", "une valise"],
        short_p="Imitez : six lignes, les quatre marqueurs au moins une fois.",
        audio="Lisez votre fil, sans aller trop vite.",
    ),
    _l(
        "EL",
        "EL — Il y a, pendant, depuis, dans",
        "Retenir les quatre marqueurs de temps.",
        "Apprenez la fiche.",
        "Fiche du carnet",
        """Il y a + durée : le fait est fini, on compte en arrière.
Il y a trois jours, nous sommes arrivés.
Pendant + durée (ou pendant le week-end) : durée close.
Pendant trois heures, nous avons marché.
Depuis + moment / durée : ça a commencé, c'est encore vrai.
Depuis vendredi, je dors ici. (présent)
Dans + durée : plus tard.
Dans deux jours, nous irons à Mwezi-Haut.
Ne pas inverser : il y a ≠ dans.""",
        tf_item=(
            "« Dans deux jours » parle d'un fait déjà fini.",
            False,
            "Dans = futur.",
        ),
        qcm_item=(
            "Quelle phrase est correcte ?",
            [
                "Dans trois jours, nous sommes arrivés",
                "Il y a trois jours, nous sommes arrivés",
                "Depuis trois jours, nous irons",
                "Pendant demain, nous marchons",
            ],
            1,
            "Passé révolu → il y a.",
        ),
        pairs=[
            ("il y a", "en arrière"),
            ("pendant", "durée close"),
            ("depuis", "encore vrai"),
            ("dans", "en avant"),
        ],
        fill_item=("___ trois heures, nous avons marché. (durée close)", "Pendant"),
        words=["Il", "y", "a", "une", "heure", "il", "est", "tombé", "."],
        anagram=("marqueurs", "Il y a, pendant, depuis, dans : quatre… de temps."),
        error=(
            "Depuis deux jours, nous irons jusqu'au lac.",
            "Dans deux jours, nous irons jusqu'au lac.",
            "Futur → dans.",
        ),
        pic_start=29,
        pic_words=["une lampe", "un récit", "une valise", "une photo"],
        short_p="Rédigez une mini-frise de votre mois avec les quatre mots.",
        audio="Enregistrez la fiche et quatre exemples contrastés.",
    ),
]


SEQUENCES = [
    {"title": "Une expérience à raconter", "lessons": S1},
    {"title": "Règles et conseils", "lessons": S2},
    {"title": "Émotions et souvenirs", "lessons": S3},
    {"title": "Un week-end à thème", "lessons": S4},
    {"title": "Partir à l'aventure", "lessons": S5},
    {"title": "Le fil de mon parcours", "lessons": S6},
]
