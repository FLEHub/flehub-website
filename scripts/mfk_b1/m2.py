"""B1 Module 2 — S'installer autrement (univers Seuil des Sources)."""

from factory import L

IMG = "mfk-b1-m2"
IMG_DIR = IMG

MODULE = {
    "title": "B1 — S'installer autrement",
    "description": (
        "Grande étape B1-2 : exprimer un sentiment, anticiper un souci de santé, "
        "remplir des papiers, nuancer des goûts, trouver un rythme et tisser "
        "un voisinage — au Pavillon du Saule et à la Maison des Vents "
        "(Rive-des-Saules, Val-des-Peupliers), avec l'Infirmerie des Herbes "
        "et le Bureau des Escales."
    ),
}


def _l(comp, title, obj, cons, st, sp, **kw):
    return L(IMG, comp, title, obj, cons, st, sp, **kw)


# ---------------------------------------------------------------------------
# Séquence 1 — Un souci du quotidien (subjonctif : sentiments, volonté)
# ---------------------------------------------------------------------------

S1 = [
    _l(
        "CO",
        "CO — Une tasse, un bruit, un accord",
        "Comprendre je suis content(e) que, j'ai peur que, il faut que, je veux que + subjonctif.",
        "Lisez le dialogue (à écouter avec l'enseignant). Qui a peur de quoi ? Qui veut quoi ?",
        "Cuisine du Pavillon du Saule, soir",
        """Léa : J'ai peur que le voisin n'entende trop nos voix, ce soir, au Pavillon du Saule.
Patrick : Je suis content que tu en parles. Il faut que nous trouvions une solution.
Aline : Je veux que chacun range sa tasse. J'ai peur qu'on se plaigne encore.
Marc : Je suis content qu'Hawa soit rentrée. Il faut qu'elle se repose.
Hawa : J'ai peur que la tasse cassée n'agace Karim. Il faut que je m'excuse.
Joël : Je veux que tu parles à Karim, Léa. Il est juste, au fond.
Rose : Je suis contente que Félicie propose un thé. Ça calme.
Karim : J'ai peur que le bruit dure. Il faut que nous fermions la porte plus tôt.
Solange : Je suis contente que vous cherchiez un accord, pas une dispute.
Yvette : Il faut que tu viennes à l'infirmerie si tu as mal à la tête, Hawa.
Lila : Je veux que nous écrivions un mot au voisin, sans colère.
Dieudonné : Je suis content que le Pavillon reste ouvert. Il faut que l'on s'écoute.""",
        tf_item=(
            "Patrick est content que Léa parle du bruit.",
            True,
            "Patrick : « Je suis content que tu en parles. »",
        ),
        qcm_item=(
            "Que veut Aline ?",
            [
                "Que Karim parte",
                "Que chacun range sa tasse",
                "Que Léa casse une tasse",
                "Que Hawa crie",
            ],
            1,
            "Aline : « Je veux que chacun range sa tasse. »",
        ),
        pairs=[
            ("je suis content que", "sentiment + subjonctif"),
            ("j'ai peur que", "crainte + subjonctif"),
            ("il faut que", "obligation + subjonctif"),
            ("je veux que", "volonté + subjonctif"),
        ],
        fill_item=("Il faut que nous ___ une solution. (trouver)", "trouvions"),
        words=["Il", "faut", "que", "nous", "fermions", "la", "porte", "."],
        anagram=("trouvions", "Il faut que nous… une solution : forme de trouver au subjonctif, nous."),
        error=(
            "Il faut que nous trouvons une solution, dit Patrick sous le saule.",
            "Il faut que nous trouvions une solution, dit Patrick sous le saule.",
            "Après il faut que : subjonctif, trouvions (pas trouvons).",
        ),
        pic_start=0,
        pic_words=["un sentiment", "un souci", "un voisin", "une tasse"],
        short_p="Notez deux craintes, deux obligations et un souhait entendus.",
        audio="Enregistrez : J'ai peur que le bruit dure. Je suis content que tu en parles. Il faut que nous trouvions une solution.",
    ),
    _l(
        "CE",
        "CE — Mot collé à la porte",
        "Lire un mot qui exprime sentiments et solutions au subjonctif.",
        "Lisez le mot, sans aller trop vite.",
        "Feuille ocre, porte du Pavillon du Saule",
        """Pavillon du Saule — mot aux habitants
Je suis contente que vous soyez rentrés sans crier.
J'ai peur que le couloir reste trop bruyant après vingt-deux heures.
Il faut que chacun pose sa tasse dans le bac, pas sur le banc.
Je veux que Léa et Karim parlent demain, près du saule.
Il faut que nous évitions une dispute : un mot suffit.
Je suis content que Félicie prépare le thé de la Table des Sources.
J'ai peur qu'Hawa ne se plaigne de la tête, après la chute de la tasse.
Il faut que tu viennes me voir, Hawa, à l'Infirmerie des Herbes.
Solange Mukamana a écrit : je veux que le tampon attende le matin.
Karim Bamba : je suis content que l'on cherche un accord.
Lila Sow : il faut que le mot reste poli, même si l'on est fatigué.
Dieudonné : je veux que la porte reste ouverte le jour, fermée la nuit.""",
        tf_item=(
            "On peut crier dans le couloir après vingt-deux heures.",
            False,
            "« J'ai peur que le couloir reste trop bruyant après vingt-deux heures. »",
        ),
        qcm_item=(
            "Où Hawa doit-elle aller, d'après le mot ?",
            [
                "Au Marché des Lampions",
                "À Radio Figuier",
                "À l'Infirmerie des Herbes",
                "À Val-des-Peupliers",
            ],
            2,
            "« Il faut que tu viennes me voir, Hawa, à l'Infirmerie des Herbes. »",
        ),
        pairs=[
            ("que vous soyez rentrés", "contentement"),
            ("que le couloir reste", "crainte"),
            ("que chacun pose", "obligation"),
            ("que Léa et Karim parlent", "volonté"),
        ],
        fill_item=("Je suis contente que vous ___ rentrés. (être)", "soyez"),
        words=["Il", "faut", "que", "tu", "viennes", "me", "voir", "."],
        anagram=("plaigne", "J'ai peur qu'Hawa se… de la tête : forme de se plaindre."),
        error=(
            "Je suis contente que vous êtes rentrés sans crier, au Pavillon.",
            "Je suis contente que vous soyez rentrés sans crier, au Pavillon.",
            "Après je suis content(e) que : subjonctif, soyez.",
        ),
        pic_start=1,
        pic_words=["un souci", "un voisin", "une tasse", "une infirmerie"],
        short_p="Recopiez le mot et encadrez chaque que + verbe au subjonctif.",
        audio="Lisez le mot collé à la porte, sans aller trop vite.",
    ),
    _l(
        "PO",
        "PO — Dire sa crainte, son souhait",
        "Exprimer un sentiment ou une volonté avec le subjonctif présent.",
        "Répétez les modèles, puis parlez d'un souci du Pavillon.",
        "Modèles d'Aline, banc du saule",
        """Je suis content que tu parles.
Je suis contente qu'il soit rentré.
J'ai peur que le bruit dure.
J'ai peur qu'on se plaigne.
Il faut que nous trouvions un accord.
Il faut que tu viennes tôt.
Je veux que chacun range.
Je veux que vous écriviez un mot.
Il faut que la porte soit fermée.
Je suis content que Félicie propose un thé.
J'ai peur qu'Hawa ait mal.
Je veux que l'on s'écoute.""",
        tf_item=(
            "Après « j'ai peur que », on emploie le subjonctif.",
            True,
            "J'ai peur que le bruit dure / qu'on se plaigne.",
        ),
        qcm_item=(
            "Quelle phrase est correcte ?",
            [
                "Il faut que tu viens tôt",
                "Il faut que tu viennes tôt",
                "Je faut que tu viennes tôt",
                "Il faut que tu vas tôt",
            ],
            1,
            "Il faut que + subjonctif : tu viennes. Toujours il faut.",
        ),
        pairs=[
            ("je suis content que", "joie / soulagement"),
            ("j'ai peur que", "crainte"),
            ("il faut que", "nécessité"),
            ("je veux que", "souhait personnel"),
        ],
        fill_item=("J'ai peur qu'on se ___. (se plaindre)", "plaigne"),
        words=["Je", "veux", "que", "vous", "écriviez", "un", "mot", "."],
        anagram=("cherchiez", "Je suis content que vous… un accord : forme de chercher, vous."),
        error=(
            "J'ai peur que le bruit dure trop, et il faut que tu vas t'excuser.",
            "J'ai peur que le bruit dure trop, et il faut que tu ailles t'excuser.",
            "Aller au subjonctif : que tu ailles (pas tu vas).",
        ),
        pic_start=2,
        pic_words=["un voisin", "une tasse", "une infirmerie", "une conséquence"],
        short_p="Écrivez huit phrases : deux de chaque structure (content / peur / faut / veux).",
        audio="Enregistrez les douze modèles, puis deux phrases à vous sur un souci du quotidien.",
    ),
    _l(
        "PE",
        "PE — Mon mot au voisin",
        "Écrire un mot poli qui dit une crainte et une solution.",
        "Imitez le mot de Léa.",
        "Mot de Léa Niyonzima, enveloppe ocre",
        """Léa Niyonzima
Pavillon du Saule — Rive-des-Saules
Karim, je suis contente que tu lises ce mot sans colère.
J'ai peur que nos voix aient gêné ta porte, hier soir.
Il faut que nous fermions plus tôt, je le sais.
Je veux que tu viennes boire un thé à la Table des Sources.
Je suis contente que Félicie soit d'accord pour le plateau.
Il faut que Hawa se repose : la tasse est tombée près d'elle.
J'ai peur qu'elle ait mal à la tête ; Yvette la verra.
Je veux que l'on trouve un horaire, pas une dispute.
Il faut que le couloir reste calme après vingt-deux heures.
Merci d'avance. Léa""",
        tf_item=(
            "Léa veut une dispute avec Karim.",
            False,
            "« Je veux que l'on trouve un horaire, pas une dispute. »",
        ),
        qcm_item=(
            "Que propose Léa à Karim ?",
            [
                "Partir à Val-des-Peupliers",
                "Crier dans le couloir",
                "Boire un thé à la Table des Sources",
                "Casser une tasse",
            ],
            2,
            "« Je veux que tu viennes boire un thé à la Table des Sources. »",
        ),
        pairs=[
            ("que tu lises", "contentement"),
            ("que nos voix aient gêné", "crainte"),
            ("que nous fermions", "obligation"),
            ("que tu viennes boire", "invitation"),
        ],
        fill_item=("Il faut que nous ___ plus tôt. (fermer)", "fermions"),
        words=["Je", "suis", "contente", "que", "tu", "lises", "ce", "mot", "."],
        anagram=("fermions", "Il faut que nous… plus tôt : forme de fermer au subjonctif, nous."),
        error=(
            "Je suis contente que tu lis ce mot sans colère, près du saule.",
            "Je suis contente que tu lises ce mot sans colère, près du saule.",
            "Après je suis contente que : subjonctif, lises.",
        ),
        pic_start=3,
        pic_words=["une tasse", "une infirmerie", "une conséquence", "un thermomètre"],
        short_p="Imitez : dix lignes, au moins un content que, un peur que, deux il faut que.",
        audio="Lisez votre mot au voisin, sans aller trop vite.",
    ),
    _l(
        "EL",
        "EL — Subjonctif des sentiments",
        "Retenir le subjonctif après je suis content que, j'ai peur que, il faut que, je veux que.",
        "Apprenez la fiche.",
        "Fiche du Cahier du chemin",
        """Sentiment / volonté / obligation + que → subjonctif présent.
Je suis content(e) que tu parles / qu'il soit rentré / que vous soyez calmes.
J'ai peur que le bruit dure / qu'on se plaigne / qu'elle ait mal.
Il faut que nous trouvions / que tu viennes / qu'il fasse silence.
Je veux que chacun range / que vous écriviez / qu'on s'écoute.
être : que je sois, que tu sois, qu'il soit, que nous soyons, que vous soyez, qu'ils soient
avoir : que j'aie, que tu aies, qu'il ait, que nous ayons
aller : que j'aille, que tu ailles, qu'il aille, que nous allions
faire : que je fasse, que nous fassions / venir : que tu viennes
Toujours : il faut (pas je faut, pas ils faut).
On ne dit pas : je suis content que tu viens. On dit : que tu viennes.
Ne explétif possible : j'ai peur qu'il ne tombe (soutenu).""",
        tf_item=(
            "On dit « je faut que tu viennes ».",
            False,
            "Toujours il faut, 3e personne du singulier.",
        ),
        qcm_item=(
            "« Aller » au subjonctif, tu :",
            ["vas", "ailles", "iras", "allais"],
            1,
            "Que tu ailles.",
        ),
        pairs=[
            ("que tu sois", "être"),
            ("que tu ailles", "aller"),
            ("que nous fassions", "faire"),
            ("que tu viennes", "venir"),
        ],
        fill_item=("Il faut que tu ___ prudent. (être)", "sois"),
        words=["Je", "suis", "content", "qu'il", "soit", "rentré", "."],
        anagram=("soyez", "Il faut que vous… calmes : forme d'être au subjonctif, vous."),
        error=(
            "Ils faut que vous soyez calmes après vingt-deux heures, au Pavillon.",
            "Il faut que vous soyez calmes après vingt-deux heures, au Pavillon.",
            "Il faut reste au singulier : il faut.",
        ),
        pic_start=4,
        pic_words=["une infirmerie", "une conséquence", "un thermomètre", "un conseil"],
        short_p="Tableau : six verbes (être, avoir, aller, faire, venir, trouver) au subjonctif tu / nous / il.",
        audio="Enregistrez la fiche, puis six exemples à vous.",
    ),
]


# ---------------------------------------------------------------------------
# Séquence 2 — Anticiper un problème de santé (conséquence)
# ---------------------------------------------------------------------------

S2 = [
    _l(
        "CO",
        "CO — Hawa à l'Infirmerie des Herbes",
        "Comprendre un souci de santé et les marqueurs de conséquence : donc, alors, si bien que, c'est pourquoi.",
        "Lisez le dialogue. Qu'est-ce qui entraîne quoi ?",
        "Infirmerie des Herbes, banc de Yvette",
        """Yvette : Tu as de la fièvre, Hawa, donc tu restes ici jusqu'à midi.
Hawa : J'ai trop marché hier, alors j'ai mal à la gorge ce matin.
Léa : Elle n'a pas dormi, si bien que sa voix est cassée.
Patrick : C'est pourquoi nous avons prévenu Aline, à la Maison des Vents.
Marc : Le thermomètre monte, donc on n'envoie personne au Marché.
Joël : Tu tousses, alors tu bois la tisane de Yvette, sans discuter.
Rose : Hawa a glissé près de la tasse, si bien que le coude est marqué.
Aline : C'est pourquoi il faut de l'ombre et du silence, pas Radio Figuier.
Karim : Elle a trop porté le bac, donc le dos proteste.
Félicie : Je prépare un bouillon, alors tu manges lentement.
Lila : La fièvre tombe un peu, si bien que Yvette sourit enfin.
Dieudonné : C'est pourquoi on reporte la visite à Rive-des-Saules.""",
        tf_item=(
            "Hawa doit rester à l'infirmerie jusqu'à midi.",
            True,
            "Yvette : « donc tu restes ici jusqu'à midi. »",
        ),
        qcm_item=(
            "Pourquoi a-t-on prévenu Aline ?",
            [
                "Parce que Karim est en colère",
                "Parce que Hawa n'a pas dormi et que sa voix est cassée",
                "Parce que le marché est fermé",
                "Parce que Dieudonné part",
            ],
            1,
            "Léa : voix cassée. Patrick : « C'est pourquoi nous avons prévenu Aline. »",
        ),
        pairs=[
            ("donc tu restes", "fièvre → repos"),
            ("alors j'ai mal", "marche → gorge"),
            ("si bien que sa voix", "insomnie → voix cassée"),
            ("c'est pourquoi", "on a prévenu Aline"),
        ],
        fill_item=("Tu as de la fièvre, ___ tu restes ici.", "donc"),
        words=["Tu", "tousses", "alors", "tu", "bois", "la", "tisane", "."],
        anagram=("fievre", "Hawa a trop chaud ; le thermomètre monte (sans accent)."),
        error=(
            "Tu as de la fièvre, donc tu restes ici jusqu'à midi, et ils faut de l'ombre.",
            "Tu as de la fièvre, donc tu restes ici jusqu'à midi, et il faut de l'ombre.",
            "Il faut au singulier, même avec plusieurs causes.",
        ),
        pic_start=5,
        pic_words=["une conséquence", "un thermomètre", "un conseil", "un formulaire"],
        short_p="Notez quatre enchaînements : cause → donc / alors / si bien que / c'est pourquoi.",
        audio="Enregistrez : Tu as de la fièvre, donc tu restes. Elle n'a pas dormi, si bien que sa voix est cassée. C'est pourquoi nous avons prévenu Aline.",
    ),
    _l(
        "CE",
        "CE — Fiche de Yvette Mukeshimana",
        "Lire une fiche de santé qui enchaîne causes et conséquences.",
        "Lisez la fiche, sans aller trop vite.",
        "Cahier de l'Infirmerie des Herbes",
        """Fiche Hawa Diallo — Pavillon du Saule
Température haute le matin, donc repos jusqu'à quatorze heures.
Toux sèche, alors tisane des herbes toutes les deux heures.
Peu de sommeil, si bien que la voix reste fragile.
C'est pourquoi Radio Figuier attendra : pas de micro aujourd'hui.
Le coude est marqué, donc on évite de porter le bac.
Elle a trop marché vers Rive-des-Saules, alors les pieds brûlent.
Yvette demande le silence, si bien que Joël ferme la porte.
C'est pourquoi Léa apporte le bouillon de Félicie, pas un plat épicé.
Si la fièvre monte encore, alors on prévient Solange au Bureau des Escales.
Hawa a soif, donc l'eau du Seuil reste à portée.
Elle sourit un peu, si bien que Marc range le thermomètre.
C'est pourquoi la visite à Val-des-Peupliers est reportée à jeudi.""",
        tf_item=(
            "Hawa peut prendre le micro de Radio Figuier aujourd'hui.",
            False,
            "« C'est pourquoi Radio Figuier attendra : pas de micro aujourd'hui. »",
        ),
        qcm_item=(
            "Que doit boire Hawa toutes les deux heures ?",
            [
                "Un café trop fort",
                "La tisane des herbes",
                "Le thé du Marché seulement",
                "Rien du tout",
            ],
            1,
            "« alors tisane des herbes toutes les deux heures. »",
        ),
        pairs=[
            ("donc repos", "température"),
            ("alors tisane", "toux"),
            ("si bien que la voix", "peu de sommeil"),
            ("c'est pourquoi", "pas de micro"),
        ],
        fill_item=("Peu de sommeil, si bien ___ la voix reste fragile.", "que"),
        words=["C'est", "pourquoi", "la", "visite", "est", "reportée", "."],
        anagram=("tisane", "Yvette la verse : infusion d'herbes de l'infirmerie."),
        error=(
            "Peu de sommeil, si bien que la voix reste fragile, donc ils faut le silence.",
            "Peu de sommeil, si bien que la voix reste fragile, donc il faut le silence.",
            "Il faut : toujours 3e personne du singulier.",
        ),
        pic_start=6,
        pic_words=["un thermomètre", "un conseil", "un formulaire", "un pronom"],
        short_p="Recopiez la fiche et soulignez donc, alors, si bien que, c'est pourquoi.",
        audio="Lisez la fiche de Yvette, sans aller trop vite.",
    ),
    _l(
        "PO",
        "PO — Dire donc, alors, si bien que",
        "Enchaîner un problème de santé et sa conséquence à voix haute.",
        "Répétez, puis parlez d'un petit mal du Seuil.",
        "Modèles de Yvette",
        """Tu as de la fièvre, donc tu te reposes.
Tu tousses, alors tu bois.
Tu n'as pas dormi, si bien que ta voix casse.
C'est pourquoi on ferme la porte.
Le dos proteste, donc tu ne portes plus le bac.
Les pieds brûlent, alors tu t'assieds.
La fièvre tombe, si bien que je souris.
C'est pourquoi la visite attend.
Tu as soif, donc tu bois l'eau du Seuil.
Tu parles trop, alors tu te tais un peu.
Le silence aide, si bien que le mal recule.
C'est pourquoi Aline est prévenue.""",
        tf_item=(
            "« Si bien que » introduit une conséquence, souvent plus forte.",
            True,
            "Tu n'as pas dormi, si bien que ta voix casse.",
        ),
        qcm_item=(
            "Quel marqueur reprend toute une cause déjà dite ?",
            ["donc", "alors", "si bien que", "c'est pourquoi"],
            3,
            "C'est pourquoi reprend l'idée précédente.",
        ),
        pairs=[
            ("donc", "conséquence directe"),
            ("alors", "conséquence, parfois conseil"),
            ("si bien que", "conséquence intense"),
            ("c'est pourquoi", "reprise explicative"),
        ],
        fill_item=("Tu n'as pas dormi, si bien ___ ta voix casse.", "que"),
        words=["Tu", "as", "de", "la", "fièvre", "donc", "tu", "te", "reposes", "."],
        anagram=("alors", "Tu tousses trop, … tu te reposes : mot de conséquence."),
        error=(
            "Tu n'as pas dormi, si bien ta voix casse, à l'infirmerie des Herbes.",
            "Tu n'as pas dormi, si bien que ta voix casse, à l'infirmerie des Herbes.",
            "Si bien que : on garde que.",
        ),
        pic_start=7,
        pic_words=["un conseil", "un formulaire", "un pronom", "un message"],
        short_p="Écrivez huit phrases : deux donc, deux alors, deux si bien que, deux c'est pourquoi.",
        audio="Enregistrez les douze modèles, puis deux enchaînements à vous.",
    ),
    _l(
        "PE",
        "PE — Ma fiche santé",
        "Écrire une courte fiche qui relie un mal et ses conséquences.",
        "Imitez la fiche de Patrick.",
        "Fiche de Patrick Habimana",
        """Patrick Habimana
Maison des Vents — relais du Seuil
J'ai trop porté le bois, donc le dos me rappelle d'arrêter.
J'ai marché sans pause, alors les genoux chauffent.
Je n'ai pas bu, si bien que la tête tourne un peu.
C'est pourquoi je passe à l'Infirmerie des Herbes, comme Hawa.
Yvette a mesuré, donc je reste assis une heure.
Je tousse à peine, alors je prends la tisane quand même.
Le silence m'aide, si bien que je peux écrire ce mot.
C'est pourquoi je reporte le minibus vers Val-des-Peupliers.
Léa m'apporte de l'eau, donc je ne me lève pas.
Aline est prévenue, alors personne ne m'attend au Bureau.
Patrick""",
        tf_item=(
            "Patrick reporte le minibus vers Val-des-Peupliers.",
            True,
            "« C'est pourquoi je reporte le minibus vers Val-des-Peupliers. »",
        ),
        qcm_item=(
            "Pourquoi Patrick passe-t-il à l'infirmerie ?",
            [
                "Pour chercher un tampon",
                "Parce qu'il a trop porté, marché, et pas assez bu",
                "Pour crier après Karim",
                "Pour danser au marché",
            ],
            1,
            "Les trois premières lignes : dos, genoux, tête → c'est pourquoi l'infirmerie.",
        ),
        pairs=[
            ("donc le dos", "trop porté"),
            ("alors les genoux", "sans pause"),
            ("si bien que la tête", "pas bu"),
            ("c'est pourquoi", "infirmerie"),
        ],
        fill_item=("Je n'ai pas bu, si bien que la tête ___.", "tourne"),
        words=["C'est", "pourquoi", "je", "reste", "assis", "une", "heure", "."],
        anagram=("pourquoi", "C'est… Hawa reste : on explique le lien de cause."),
        error=(
            "J'ai trop porté le bois, donc le dos me rappelle d'arrêter, et je suis content que Yvette est là.",
            "J'ai trop porté le bois, donc le dos me rappelle d'arrêter, et je suis content que Yvette soit là.",
            "Je suis content que + subjonctif : soit.",
        ),
        pic_start=8,
        pic_words=["un formulaire", "un pronom", "un message", "un tampon"],
        short_p="Imitez : dix lignes, les quatre marqueurs de conséquence au moins une fois.",
        audio="Lisez votre fiche santé, sans aller trop vite.",
    ),
    _l(
        "EL",
        "EL — Marqueurs de conséquence",
        "Retenir donc, alors, si bien que, c'est pourquoi.",
        "Apprenez la fiche.",
        "Fiche de Yvette",
        """Conséquence : ce qui suit une cause.
donc : tu as de la fièvre, donc tu te reposes. (direct, souvent après une virgule)
alors : tu tousses, alors tu bois. (conséquence ou conseil immédiat)
si bien que + indicative : elle n'a pas dormi, si bien que sa voix casse.
c'est pourquoi + phrase : reprise de toute la cause. C'est pourquoi on ferme.
Ne pas confondre : parce que (cause) / donc (conséquence).
On ne dit pas : si bien ta voix casse. On dit : si bien que.
alors ≠ à l'heure (ce n'est pas un moment ici).
Lexique santé : fièvre, toux, gorge, tisane, thermomètre, repos, silence.
Il faut + infinitif : il faut se reposer (pas je faut).
Si l'on ajoute que : il faut que tu te reposes (subjonctif).
Phrase trop longue : on coupe, on garde un seul marqueur par lien.""",
        tf_item=(
            "« Parce que » et « donc » disent la même chose.",
            False,
            "Parce que = cause. Donc = conséquence.",
        ),
        qcm_item=(
            "Quelle phrase est correcte ?",
            [
                "Si bien ta voix casse",
                "Si bien que ta voix casse",
                "Si bien de ta voix casse",
                "Si bien à ta voix casse",
            ],
            1,
            "Si bien que + phrase.",
        ),
        pairs=[
            ("donc", "lien court"),
            ("alors", "suite immédiate"),
            ("si bien que", "résultat fort"),
            ("c'est pourquoi", "explication reprise"),
        ],
        fill_item=("Elle n'a pas dormi, ___ bien que sa voix casse.", "si"),
        words=["Tu", "as", "de", "la", "fièvre", "donc", "tu", "te", "reposes", "."],
        anagram=("lien", "Donc, alors, si bien que : ils marquent un… de cause à effet."),
        error=(
            "Hawa tousse trop, parce que donc elle boit la tisane à l'infirmerie.",
            "Hawa tousse trop, donc elle boit la tisane à l'infirmerie.",
            "Un seul marqueur : donc (conséquence), pas parce que donc.",
        ),
        pic_start=9,
        pic_words=["un pronom", "un message", "un tampon", "un goût"],
        short_p="Rédigez un mini-tableau : quatre marqueurs, une phrase santé chacun.",
        audio="Enregistrez la fiche et quatre exemples de conséquence.",
    ),
]


# ---------------------------------------------------------------------------
# Séquence 3 — Des papiers à remplir (impératif + pronoms ; discours indirect)
# ---------------------------------------------------------------------------

S3 = [
    _l(
        "CO",
        "CO — Au Bureau des Escales",
        "Repérer l'impératif avec pronoms et le discours indirect : il m'a dit de, elle demande si.",
        "Lisez le dialogue. Qui dit de faire quoi ? Qui demande si… ?",
        "Guichet de Solange Mukamana, Val-des-Peupliers",
        """Solange : Remplissez-le, le formulaire. Donnez-le-moi ensuite.
Karim : Apportez-les-moi, les photos. Ne les jetez pas.
Léa : Il m'a dit de signer ici, pas là-bas.
Patrick : Elle demande si j'ai une pièce ocre, pour le tampon.
Aline : Dites-lui la date. Répétez-la-lui, sans aller trop vite.
Marc : Solange m'a dit de photocopier la page, deux fois.
Hawa : Karim demande si je peux attendre jusqu'à midi.
Joël : Ne me le cachez pas, le tarif. Expliquez-le-nous.
Rose : On m'a dit de revenir jeudi, au Bureau des Escales.
Lila : Elle demande si le Pavillon du Saule est bien notre adresse.
Dieudonné : Donnez-les-leur, les copies, à Solange et à Karim.
Félicie : Il m'a dit de ne pas plier le papier encore humide.""",
        tf_item=(
            "Solange veut le formulaire après qu'on l'a rempli.",
            True,
            "« Remplissez-le. Donnez-le-moi ensuite. »",
        ),
        qcm_item=(
            "Que signifie « Il m'a dit de signer ici » ?",
            [
                "Il a signé à la place de Léa",
                "On a rapporté un ordre : signer ici",
                "Léa demande si elle signe",
                "Karim jette les photos",
            ],
            1,
            "Discours indirect : dire de + infinitif.",
        ),
        pairs=[
            ("donnez-le-moi", "impératif + pronoms"),
            ("ne les jetez pas", "impératif négatif"),
            ("il m'a dit de signer", "ordre rapporté"),
            ("elle demande si", "question rapportée"),
        ],
        fill_item=("Il m'a dit ___ signer ici.", "de"),
        words=["Donnez-le-moi", "ensuite", "."],
        anagram=("tampon", "Karim le pose sur le dossier, à l'encre ocre."),
        error=(
            "Solange m'a dit que je signe ici, pas là-bas, au Bureau des Escales.",
            "Solange m'a dit de signer ici, pas là-bas, au Bureau des Escales.",
            "Ordre rapporté : dire de + infinitif.",
        ),
        pic_start=10,
        pic_words=["un message", "un tampon", "un goût", "une façon"],
        short_p="Notez trois impératifs avec pronoms et deux paroles rapportées.",
        audio="Enregistrez : Donnez-le-moi. Apportez-les-moi. Il m'a dit de signer. Elle demande si j'ai une pièce.",
    ),
    _l(
        "CE",
        "CE — Consigne du tampon ocre",
        "Lire des formalités : impératif pronominal et paroles rapportées.",
        "Lisez la consigne, sans aller trop vite.",
        "Affiche du Bureau des Escales",
        """Bureau des Escales — Val-des-Peupliers (ville inventée)
Remplissez-le à l'encre, le cadre du haut.
Apportez-les-nous, les deux photocopies, avant onze heures.
Ne les pliez pas. Donnez-les-moi à plat.
Solange Mukamana a dit de signer au bas, pas en marge.
Karim Bamba demande si l'adresse du Pavillon du Saule est complète.
Dites-lui votre nom. Épelez-le-lui si besoin.
On nous a dit de ne pas coller la photo trop tôt : le tampon d'abord.
Elle demande si Hawa peut attendre, à cause de l'infirmerie.
Rapportez-le-moi, le dossier, dès que Yvette aura signé le verso.
Ne me le rendez pas incomplet. Vérifiez-le avant.
Lila Sow a dit de garder une copie au Cahier du chemin.
Joël : on m'a demandé si le minibus Figuier 7 passait jeudi.""",
        tf_item=(
            "On colle la photo avant le tampon.",
            False,
            "« Ne pas coller la photo trop tôt : le tampon d'abord. »",
        ),
        qcm_item=(
            "Qui demande si l'adresse du Pavillon est complète ?",
            ["Solange", "Yvette", "Karim Bamba", "Félicie"],
            2,
            "« Karim Bamba demande si l'adresse du Pavillon du Saule est complète. »",
        ),
        pairs=[
            ("remplissez-le", "cadre du haut"),
            ("apportez-les-nous", "photocopies"),
            ("a dit de signer", "Solange"),
            ("demande si l'adresse", "Karim"),
        ],
        fill_item=("Karim demande ___ l'adresse est complète.", "si"),
        words=["Ne", "les", "pliez", "pas", "."],
        anagram=("photocopie", "Il en faut deux : une reproduction du papier."),
        error=(
            "Karim demande est-ce que l'adresse du Pavillon est complète, ce matin.",
            "Karim demande si l'adresse du Pavillon est complète, ce matin.",
            "Question rapportée : demander si (pas est-ce que après demander).",
        ),
        pic_start=11,
        pic_words=["un tampon", "un goût", "une façon", "un marché"],
        short_p="Recopiez six consignes et transformez-en deux en discours indirect.",
        audio="Lisez la consigne du tampon ocre, sans aller trop vite.",
    ),
    _l(
        "PO",
        "PO — Donnez-le-moi, il m'a dit de",
        "Placer les pronoms à l'impératif et rapporter un ordre ou une question.",
        "Répétez, puis parlez d'une démarche à vous.",
        "Modèles de Solange",
        """Remplissez-le.
Donnez-le-moi.
Apportez-les-nous.
Ne les jetez pas.
Dites-lui la date.
Répétez-la-lui.
Il m'a dit de signer.
Elle demande si j'ai une photo.
On m'a dit de revenir jeudi.
Ne me le cachez pas.
Expliquez-le-nous.
Il m'a dit de ne pas plier.""",
        tf_item=(
            "À l'impératif affirmatif, le pronom se colle après le verbe.",
            True,
            "Donnez-le-moi. Apportez-les-nous.",
        ),
        qcm_item=(
            "Quelle phrase est correcte ?",
            [
                "Donnez-moi-le",
                "Donnez-le-moi",
                "Le donnez-moi",
                "Donnez moi le",
            ],
            1,
            "COD (le) avant COI (moi) : donnez-le-moi.",
        ),
        pairs=[
            ("verbe-le-moi", "impératif affirmatif"),
            ("ne les + verbe pas", "impératif négatif"),
            ("dire de + infinitif", "ordre rapporté"),
            ("demander si + phrase", "question rapportée"),
        ],
        fill_item=("Donnez-___-moi. (le formulaire)", "le"),
        words=["Il", "m'a", "dit", "de", "signer", "."],
        anagram=("apportez", "…-les-moi : forme de apporter à l'impératif, vous."),
        error=(
            "Donnez-moi-le ensuite, au guichet de Solange, sans attendre.",
            "Donnez-le-moi ensuite, au guichet de Solange, sans attendre.",
            "À l'impératif : le avant moi.",
        ),
        pic_start=12,
        pic_words=["un goût", "une façon", "un marché", "un panier"],
        short_p="Écrivez six impératifs avec pronoms et quatre paroles rapportées.",
        audio="Enregistrez les douze modèles, puis deux consignes à vous.",
    ),
    _l(
        "PE",
        "PE — Ma liste de formalités",
        "Écrire des consignes et des paroles rapportées pour un dossier.",
        "Imitez la liste de Marc.",
        "Liste de Marc Nkurunziza",
        """Marc Nkurunziza
Bureau des Escales — dossier Pavillon du Saule
Remplissez-le avant dix heures. Donnez-le-moi ensuite.
Apportez-les-nous, les photos. Ne les pliez pas.
Solange m'a dit de signer au bas, à l'encre ocre.
Karim demande si l'adresse de Rive-des-Saules est exacte.
Dites-lui mon nom. Épelez-le-lui, s'il lève le sourcil.
On m'a dit de photocopier la page de Yvette, le verso santé.
Elle demande si Hawa peut venir demain, pas aujourd'hui.
Rapportez-le-moi dès que le tampon est sec.
Ne me le rendez pas sans copie. Vérifiez-le.
Marc""",
        tf_item=(
            "Marc dit de plier les photos.",
            False,
            "« Ne les pliez pas. »",
        ),
        qcm_item=(
            "Que demande Karim, d'après Marc ?",
            [
                "Si le thé est prêt",
                "Si l'adresse de Rive-des-Saules est exacte",
                "Si Dieudonné danse",
                "Si la radio joue",
            ],
            1,
            "« Karim demande si l'adresse de Rive-des-Saules est exacte. »",
        ),
        pairs=[
            ("remplissez-le", "avant dix heures"),
            ("a dit de signer", "Solange"),
            ("demande si l'adresse", "Karim"),
            ("a dit de photocopier", "verso santé"),
        ],
        fill_item=("Solange m'a dit ___ signer au bas.", "de"),
        words=["Ne", "les", "pliez", "pas", "."],
        anagram=("demander", "Elle veut savoir si : le verbe… si."),
        error=(
            "Karim demande si est-ce que l'adresse de Rive-des-Saules est exacte.",
            "Karim demande si l'adresse de Rive-des-Saules est exacte.",
            "Une seule interrogation : demander si + phrase, sans est-ce que.",
        ),
        pic_start=13,
        pic_words=["une façon", "un marché", "un panier", "un rythme"],
        short_p="Imitez : dix lignes, trois impératifs à pronoms et trois discours indirects.",
        audio="Lisez votre liste de formalités, sans aller trop vite.",
    ),
    _l(
        "EL",
        "EL — Impératif pronominal et discours indirect",
        "Retenir l'ordre des pronoms et les structures il m'a dit de / elle demande si.",
        "Apprenez la fiche.",
        "Fiche de Solange",
        """Impératif affirmatif : verbe-pronom-pronom. Donnez-le-moi. Apportez-les-nous.
Ordre : le / la / les avant moi / toi / lui / nous / vous / leur.
Traits d'union. Moi, toi (pas me, te) après le verbe : donne-le-moi.
Impératif négatif : pronoms avant le verbe. Ne le lui donnez pas. Ne les jetez pas.
Discours indirect — ordre : il m'a dit de + infinitif. Elle m'a dit de ne pas plier.
Discours indirect — question oui/non : elle demande si + indicative.
On ne dit pas : il m'a dit que je signe (ordre). On dit : il m'a dit de signer.
On ne dit pas : elle demande est-ce que. On dit : elle demande si.
Présent de report : on garde le présent si l'info reste vraie.
Attention : dites-lui (pas dites-le à lui, trop lourd ici).
Épelez-le-lui : le = le nom, lui = à Karim.
Toujours il faut : il faut signer (infinitif) / il faut que tu signes (subj.).""",
        tf_item=(
            "On écrit « donnez-moi-le ».",
            False,
            "Donnez-le-moi : le avant moi.",
        ),
        qcm_item=(
            "« Elle m'a dit de revenir » rapporte…",
            ["une question", "un ordre ou un conseil", "une comparaison", "un souhait sans verbe"],
            1,
            "Dire de + infinitif = ordre / conseil rapporté.",
        ),
        pairs=[
            ("donnez-le-moi", "affirmatif"),
            ("ne le lui donnez pas", "négatif"),
            ("dit de + inf.", "ordre rapporté"),
            ("demande si", "question rapportée"),
        ],
        fill_item=("Ne ___ jetez pas. (les photos)", "les"),
        words=["Elle", "demande", "si", "j'ai", "une", "photo", "."],
        anagram=("ordre", "Donnez-le-moi : le… des pronoms à l'impératif."),
        error=(
            "Ne jetez-les pas trop vite, près du tampon ocre du bureau.",
            "Ne les jetez pas trop vite, près du tampon ocre du bureau.",
            "À l'impératif négatif, le pronom passe avant le verbe.",
        ),
        pic_start=14,
        pic_words=["un marché", "un panier", "un rythme", "une habitude"],
        short_p="Transformez : Donnez le dossier à Solange. / Karim : « Signez ! » / Solange : « Avez-vous une photo ? »",
        audio="Enregistrez la fiche et six transformations.",
    ),
]


# ---------------------------------------------------------------------------
# Séquence 4 — Goûts et façons de vivre (négation nuancée)
# ---------------------------------------------------------------------------

S4 = [
    _l(
        "CO",
        "CO — Autour de la Table des Sources",
        "Repérer ne… que, ne… plus, ne… jamais, ne… ni… ni, ne… pas encore, sans.",
        "Lisez le dialogue. Qui n'aime quoi ? Qui a changé ?",
        "Table des Sources, midi",
        """Félicie : Je ne prends que du thé le matin, jamais de café trop fort.
Dieudonné : Moi, je ne me lève plus à l'aube : le Pavillon a changé mon rythme.
Léa : Je n'achète ni pain trop blanc ni friture, au Marché des Lampions.
Hawa : Je ne sors pas encore le soir : Yvette a dit d'attendre.
Patrick : Je range sans crier, et je n'invite plus d'inconnus dans le couloir.
Aline : Joël ne parle jamais trop fort après vingt-deux heures, maintenant.
Marc : Je n'écoute que Radio Figuier, pas d'autre antenne.
Rose : Je ne couds ni trop vite ni sans lumière, à l'Atelier du Tissu.
Karim : Je n'habite plus seul : le voisinage du saule m'a habitué aux voix.
Lila : Je ne suis pas encore inscrite à Val-des-Peupliers, le tampon attend.
Solange : On n'accepte que les dossiers complets, sans rature.
Yvette : Je ne sers ni plat épicé ni tisane froide, tant que la fièvre dure.""",
        tf_item=(
            "Félicie prend seulement du thé le matin.",
            True,
            "« Je ne prends que du thé le matin. » Ne… que = seulement.",
        ),
        qcm_item=(
            "Que signifie « je ne sors pas encore le soir », dit par Hawa ?",
            [
                "Elle ne sortira jamais",
                "Elle sort déjà tous les soirs",
                "Pour l'instant, elle ne sort pas ; cela pourra changer",
                "Elle n'a plus de soir",
            ],
            2,
            "Ne… pas encore = pas jusqu'à maintenant.",
        ),
        pairs=[
            ("ne… que", "seulement"),
            ("ne… plus", "cesser"),
            ("ne… jamais", "à aucun moment"),
            ("ne… ni… ni", "deux refus"),
        ],
        fill_item=("Je ne prends ___ du thé le matin.", "que"),
        words=["Je", "n'invite", "plus", "d'inconnus", "."],
        anagram=("jamais", "Ne parle… trop fort : à aucun moment."),
        error=(
            "Je ne prends que pas du thé le matin, à la Table des Sources.",
            "Je ne prends que du thé le matin, à la Table des Sources.",
            "Ne… que suffit : pas de pas en plus.",
        ),
        pic_start=15,
        pic_words=["un panier", "un rythme", "une habitude", "un calendrier"],
        short_p="Classez six phrases du dialogue selon la négation employée.",
        audio="Enregistrez : Je ne prends que du thé. Je ne me lève plus à l'aube. Je n'achète ni pain ni friture. Je ne sors pas encore.",
    ),
    _l(
        "CE",
        "CE — Cartes de façons de vivre",
        "Lire des cartes qui nuancent des goûts et des habitudes.",
        "Lisez les cartes, sans aller trop vite.",
        "Cartes épinglées au figuier",
        """Carte Félicie — Je ne cuisine que des herbes du Seuil, sans trop de sel.
Carte Dieudonné — Je ne travaille plus à la lumière trop tard : les yeux fatiguent.
Carte Léa — Je n'emporte ni radio ni tambour dans la chambre, pour Karim.
Carte Hawa — Je ne marche pas encore jusqu'à Rive-des-Saules : la gorge d'abord.
Carte Patrick — Je ne laisse jamais la tasse sur le banc, même vide.
Carte Aline — On n'ouvre le Pavillon qu'après le balayage, sans exception.
Carte Marc — Je n'enregistre plus trop fort : Radio Figuier a changé la règle.
Carte Rose — Je ne vends ni tissu trop lourd ni lanterne sans fil, au marché.
Carte Karim — Je n'accepte que les visites annoncées, jamais d'intrus.
Carte Lila — Je ne remplis pas encore le cadre « métier » : j'attends Solange.
Carte Yvette — On ne sert le bouillon que tiède, sans piment.
Carte Joël — Je ne répare plus la moto la nuit, si bien que le voisin dort.""",
        tf_item=(
            "Aline ouvre le Pavillon seulement après le balayage.",
            True,
            "« On n'ouvre le Pavillon qu'après le balayage. »",
        ),
        qcm_item=(
            "Qui ne marche pas encore jusqu'à Rive-des-Saules ?",
            ["Dieudonné", "Hawa", "Karim", "Joël"],
            1,
            "Carte Hawa : « Je ne marche pas encore jusqu'à Rive-des-Saules. »",
        ),
        pairs=[
            ("ne… que des herbes", "Félicie"),
            ("ne… plus à la lumière", "Dieudonné"),
            ("ni radio ni tambour", "Léa"),
            ("pas encore jusqu'à", "Hawa"),
        ],
        fill_item=("Je ne laisse ___ la tasse sur le banc.", "jamais"),
        words=["Je", "n'emporte", "ni", "radio", "ni", "tambour", "."],
        anagram=("seulement", "Ne… que du thé : rien d'autre, une idée de restriction."),
        error=(
            "Je n'achète ni pain trop blanc ou friture, au Marché des Lampions.",
            "Je n'achète ni pain trop blanc ni friture, au Marché des Lampions.",
            "Deux éléments refusés : ni… ni (pas ou).",
        ),
        pic_start=16,
        pic_words=["un rythme", "une habitude", "un calendrier", "une pause"],
        short_p="Recopiez quatre cartes et ajoutez la vôtre avec une négation différente.",
        audio="Lisez les douze cartes, sans aller trop vite.",
    ),
    _l(
        "PO",
        "PO — Nuancer un goût",
        "Comparer et nuancer avec les négations complexes.",
        "Répétez, puis parlez de vos façons de vivre au Seuil.",
        "Modèles de Félicie",
        """Je ne prends que du thé.
Je ne bois plus de café le soir.
Je ne crie jamais dans le couloir.
Je n'aime ni le bruit ni la friture.
Je ne sors pas encore tard.
Je range sans crier.
Je n'invite plus d'inconnus.
Je n'écoute que Radio Figuier.
Je ne couds jamais sans lumière.
Je n'habite plus seul.
Je ne suis pas encore inscrite.
On n'accepte que les dossiers complets.""",
        tf_item=(
            "« Sans » peut nuancer une façon de faire, sans ne.",
            True,
            "Je range sans crier. Sans + infinitif.",
        ),
        qcm_item=(
            "Quelle phrase exprime une restriction (seulement) ?",
            [
                "Je ne crie jamais",
                "Je ne prends que du thé",
                "Je n'aime ni le bruit ni la friture",
                "Je ne sors pas encore",
            ],
            1,
            "Ne… que = seulement.",
        ),
        pairs=[
            ("ne… que", "restriction"),
            ("ne… plus", "changement"),
            ("ne… pas encore", "attente"),
            ("sans + infinitif", "manière"),
        ],
        fill_item=("Je n'aime ___ le bruit ni la friture.", "ni"),
        words=["Je", "range", "sans", "crier", "."],
        anagram=("encore", "Pas… : l'action n'a pas eu lieu jusqu'ici."),
        error=(
            "Je ne prends que du thé le matin, et je suis content que Félicie est d'accord.",
            "Je ne prends que du thé le matin, et je suis content que Félicie soit d'accord.",
            "Je suis content que + subjonctif : soit.",
        ),
        pic_start=17,
        pic_words=["une habitude", "un calendrier", "une pause", "un voisinage"],
        short_p="Écrivez six phrases, une pour chaque négation de la fiche.",
        audio="Enregistrez les douze modèles, puis trois nuances à vous.",
    ),
    _l(
        "PE",
        "PE — Ma carte de goûts",
        "Écrire une carte qui dit ce que l'on fait, ce que l'on ne fait plus, ce que l'on n'accepte pas.",
        "Imitez la carte de Rose.",
        "Carte de Rose Iradukunda",
        """Rose Iradukunda
Atelier du Tissu — Pavillon du Saule
Je ne vends que des lanternes cousues ici, sans fil trop fragile.
Je ne travaille plus à minuit : le voisinage a besoin d'ombre.
Je n'accepte ni tissu trop lourd ni teinture trop vive, pour la veillée.
Je ne montre pas encore la cape ocre : Dieudonné la finit jeudi.
Je ne crie jamais quand une aiguille tombe, même si j'ai peur.
Je range sans bousculer les paniers du Marché des Lampions.
Léa n'emporte plus le tambour dans la chambre, c'est entendu.
Je ne suis pas encore à Val-des-Peupliers : le minibus attendra.
On n'ouvre l'atelier qu'après le thé de Félicie.
Rose""",
        tf_item=(
            "Rose travaille encore à minuit.",
            False,
            "« Je ne travaille plus à minuit. »",
        ),
        qcm_item=(
            "Que refuse Rose pour la veillée ?",
            [
                "Le thé de Félicie",
                "Le voisinage",
                "Le tissu trop lourd et la teinture trop vive",
                "Les lanternes cousues ici",
            ],
            2,
            "« Je n'accepte ni tissu trop lourd ni teinture trop vive. »",
        ),
        pairs=[
            ("ne… que des lanternes", "restriction"),
            ("ne… plus à minuit", "changement"),
            ("ni… ni", "deux refus"),
            ("pas encore la cape", "attente"),
        ],
        fill_item=("Je ne travaille ___ à minuit.", "plus"),
        words=["Je", "range", "sans", "bousculer", "les", "paniers", "."],
        anagram=("panier", "Rose range sans bousculer les… du marché."),
        error=(
            "Je n'accepte ni tissu trop lourd ni teinture trop vive, bien que la veillée est proche.",
            "Je n'accepte ni tissu trop lourd ni teinture trop vive, bien que la veillée soit proche.",
            "Bien que + subjonctif : soit.",
        ),
        pic_start=18,
        pic_words=["un calendrier", "une pause", "un voisinage", "une porte"],
        short_p="Imitez : dix lignes, les six formes de négation au moins une fois.",
        audio="Lisez votre carte de goûts, sans aller trop vite.",
    ),
    _l(
        "EL",
        "EL — Négations pour nuancer",
        "Retenir ne… que, ne… plus, ne… jamais, ne… ni… ni, ne… pas encore, sans.",
        "Apprenez la fiche.",
        "Fiche d'Aline",
        """ne… que = seulement : je ne prends que du thé (pas de pas).
ne… plus = cesser : je ne me lève plus à l'aube.
ne… jamais = à aucun moment : je ne crie jamais.
ne… ni… ni = deux éléments refusés : je n'aime ni le bruit ni la friture.
ne… pas encore = jusqu'ici, non : je ne sors pas encore.
sans + infinitif (pas de ne) : je range sans crier.
Élision : n' devant voyelle (n'aime, n'invite, n'habite).
On ne dit pas : je ne prends que pas. On ne dit pas : ni… ou.
Place : ne + pronom + verbe + que / plus / jamais.
pas encore : pas et encore restent ensemble après le verbe.
Comparer : plus (changement) ≠ pas encore (attente) ≠ jamais (définitif).
Sans ≠ ne… pas : sans crier décrit la manière.""",
        tf_item=(
            "« Ne… que » veut dire « jamais ».",
            False,
            "Ne… que = seulement. Jamais = à aucun moment.",
        ),
        qcm_item=(
            "Quelle phrase est une restriction ?",
            [
                "Je ne crie jamais",
                "Je ne sors pas encore",
                "Je ne prends que du thé",
                "Je n'habite plus seul",
            ],
            2,
            "Ne… que = seulement du thé.",
        ),
        pairs=[
            ("ne… que", "seulement"),
            ("ne… plus", "ne… plus maintenant"),
            ("ne… pas encore", "pas jusqu'ici"),
            ("sans + inf.", "manière"),
        ],
        fill_item=("Je ne sors ___ encore le soir.", "pas"),
        words=["Je", "ne", "prends", "que", "du", "thé", "."],
        anagram=("restriction", "Ne… que : une… , pas une interdiction totale."),
        error=(
            "Je ne prends que du thé le matin, sans de crier dans le couloir.",
            "Je ne prends que du thé le matin, sans crier dans le couloir.",
            "Sans + infinitif, sans de.",
        ),
        pic_start=19,
        pic_words=["une pause", "un voisinage", "une porte", "une clé"],
        short_p="Transformez six phrases affirmatives en six négations différentes.",
        audio="Enregistrez la fiche et six exemples nuancés.",
    ),
]


# ---------------------------------------------------------------------------
# Séquence 5 — Trouver un rythme (EXTRA : habitudes vs changement)
# ---------------------------------------------------------------------------

S5 = [
    _l(
        "CO",
        "CO — Le fil des heures au Pavillon",
        "Comprendre un échange sur les habitudes qui restent et celles qui changent.",
        "Lisez le dialogue. Qu'est-ce qui reste ? Qu'est-ce qui change ?",
        "Banc du Pavillon du Saule, aube",
        """Aline : Je ne me lève plus à cinq heures, donc je suis moins tendue.
Léa : Je suis contente que tu dormes davantage. Il faut que le corps suive.
Patrick : Moi, je garde le thé de l'aube, je n'ai changé que l'heure du courrier.
Marc : J'ai trop enchaîné les dossiers, si bien que le Bureau m'a renvoyé au banc.
Hawa : Je ne marche pas encore jusqu'au marché, alors je m'arrête à l'infirmerie.
Joël : Il faut que nous trouvions une pause commune, pas chacun dans son coin.
Rose : Je ne couds plus le soir, c'est pourquoi la cape avance le matin.
Karim : J'ai peur que le nouveau rythme n'efface les visites. Je veux que l'on se voie.
Félicie : Je ne sers que midi et dix-neuf heures, sans plateau à minuit.
Dieudonné : Je n'allume plus l'atelier trop tard, si bien que Karim dort.
Lila : Solange a dit de dater le calendrier. Elle demande si jeudi reste libre.
Yvette : C'est pourquoi je coche repos, tisane, silence : un rythme, pas une course.""",
        tf_item=(
            "Aline se lève encore à cinq heures.",
            False,
            "« Je ne me lève plus à cinq heures. »",
        ),
        qcm_item=(
            "Que veut Karim ?",
            [
                "Que l'on cesse de se voir",
                "Que l'on se voie encore",
                "Que Radio Figuier joue la nuit",
                "Que Félicie serve à minuit",
            ],
            1,
            "« Je veux que l'on se voie. »",
        ),
        pairs=[
            ("ne… plus à cinq heures", "changement d'Aline"),
            ("n'ai changé que l'heure", "habitude de Patrick"),
            ("pas encore jusqu'au marché", "limite d'Hawa"),
            ("a dit de dater", "consigne de Solange"),
        ],
        fill_item=("Je suis contente que tu ___ davantage. (dormir)", "dormes"),
        words=["Il", "faut", "que", "nous", "trouvions", "une", "pause", "."],
        anagram=("rythme", "Le fil des heures, plus calme qu'avant."),
        error=(
            "Je suis contente que tu dors davantage, au Pavillon du Saule.",
            "Je suis contente que tu dormes davantage, au Pavillon du Saule.",
            "Dormir au subjonctif : que tu dormes.",
        ),
        pic_start=20,
        pic_words=["un voisinage", "une porte", "une clé", "un compromis"],
        short_p="Listez trois habitudes gardées et trois changements, avec le marqueur entendu.",
        audio="Enregistrez : Je ne me lève plus à cinq heures, donc je suis moins tendue. Il faut que nous trouvions une pause. Je veux que l'on se voie.",
    ),
    _l(
        "CE",
        "CE — Calendrier ocre de Lila",
        "Lire un calendrier qui oppose routines et ajustements.",
        "Lisez le calendrier, sans aller trop vite.",
        "Feuille de Lila Sow, Cahier du chemin",
        """Semaine au Pavillon du Saule
Lundi : thé à l'aube (habitude). Bureau des Escales à dix heures (changement).
Mardi : Hawa à l'infirmerie le matin, donc pas de marché. Silence jusqu'à midi.
Mercredi : Rose ne coud que le matin, si bien que le soir reste au voisinage.
Jeudi : Solange a dit de venir tamponner. Elle demande si Marc apporte les copies.
Vendredi : Joël ne répare plus la moto la nuit, c'est pourquoi Karim dort.
Samedi : Félicie ne sert ni minuit ni plateau froid. Table à dix-neuf heures.
Dimanche : pause commune sous le saule. Il faut que chacun pose son outil.
Je ne date pas encore Val-des-Peupliers : le minibus n'est pas sûr.
Aline n'ouvre plus à cinq heures, alors le couloir reste sombre plus longtemps.
Patrick n'a changé que l'heure du courrier : le thé, lui, n'a pas bougé.
Yvette : repos coché, sans exception, tant que la gorge d'Hawa grince.
Dieudonné : atelier éteint avant vingt-deux heures, pour que le Pavillon souffle.""",
        tf_item=(
            "Le dimanche, chacun doit poser son outil.",
            True,
            "« Il faut que chacun pose son outil. »",
        ),
        qcm_item=(
            "Quel jour Rose ne coud-elle que le matin ?",
            ["Lundi", "Mardi", "Mercredi", "Samedi"],
            2,
            "Mercredi : « Rose ne coud que le matin. »",
        ),
        pairs=[
            ("thé à l'aube", "habitude"),
            ("Bureau à dix heures", "changement"),
            ("ne coud que le matin", "restriction"),
            ("a dit de venir", "parole rapportée"),
        ],
        fill_item=("Il faut que chacun ___ son outil. (poser)", "pose"),
        words=["Aline", "n'ouvre", "plus", "à", "cinq", "heures", "."],
        anagram=("habitude", "Un geste répété chaque matin, devenu naturel."),
        error=(
            "Dieudonné éteint l'atelier avant vingt-deux heures, pour que le Pavillon souffle enfin et que Karim dort.",
            "Dieudonné éteint l'atelier avant vingt-deux heures, pour que le Pavillon souffle enfin et que Karim dorme.",
            "Pour que + subjonctif : que Karim dorme.",
        ),
        pic_start=21,
        pic_words=["une porte", "une clé", "un compromis", "un pavillon"],
        short_p="Recopiez trois jours : une habitude, un changement, une conséquence.",
        audio="Lisez le calendrier ocre de Lila, sans aller trop vite.",
    ),
    _l(
        "PO",
        "PO — Dire ce qui reste, ce qui change",
        "Synthétiser habitudes et changements avec les outils des séquences 1 à 4.",
        "Répétez, puis parlez de votre rythme au Seuil.",
        "Modèles de Patrick",
        """Je garde le thé de l'aube.
Je n'ai changé que l'heure.
Je ne me lève plus à cinq heures, donc je suis moins tendu.
Il faut que nous trouvions une pause.
Je suis content que tu dormes.
J'ai peur que l'on s'oublie.
On m'a dit de dater le jeudi.
Elle demande si le banc est libre.
Je ne marche pas encore jusqu'au marché.
Je range sans courir.
C'est pourquoi le couloir reste calme.
Je veux que l'on se voie.""",
        tf_item=(
            "On peut mêler subjonctif, conséquence et négation pour parler d'un rythme.",
            True,
            "Les modèles reprennent les outils des séquences précédentes.",
        ),
        qcm_item=(
            "Quelle phrase marque un changement d'habitude ?",
            [
                "Je garde le thé de l'aube",
                "Je ne me lève plus à cinq heures",
                "Elle demande si le banc est libre",
                "Je range sans courir",
            ],
            1,
            "Ne… plus = on ne le fait plus.",
        ),
        pairs=[
            ("je garde", "habitude"),
            ("ne… plus", "changement"),
            ("n'ai changé que", "petit ajustement"),
            ("il faut que nous trouvions", "objectif commun"),
        ],
        fill_item=("Je n'ai changé ___ l'heure.", "que"),
        words=["Je", "veux", "que", "l'on", "se", "voie", "."],
        anagram=("changer", "On veut… d'horaire : ne plus faire comme avant."),
        error=(
            "Il faut que nous trouvons une pause commune, sous le saule, avant midi.",
            "Il faut que nous trouvions une pause commune, sous le saule, avant midi.",
            "Il faut que + subjonctif : trouvions.",
        ),
        pic_start=22,
        pic_words=["une clé", "un compromis", "un pavillon", "un cahier"],
        short_p="Écrivez dix phrases : cinq habitudes, cinq changements, en variant les structures.",
        audio="Enregistrez les douze modèles, puis votre rythme en six phrases.",
    ),
    _l(
        "PE",
        "PE — Ma page de rythme",
        "Écrire une page qui dit ce que l'on garde, ce que l'on change, et pourquoi.",
        "Imitez la page de Joël.",
        "Page de Joël Mugisha",
        """Joël Mugisha
Pavillon du Saule — Rive-des-Saules
Je ne répare plus la moto la nuit, donc Karim dort, et je suis content qu'il dorme.
On m'a dit de ranger les outils avant vingt-deux heures. Aline demande si c'est fait.
Je n'ai changé que l'heure, pas le plaisir de l'huile et du silence.
Je ne sors pas encore jusqu'à Val-des-Peupliers : Hawa d'abord, l'infirmerie ensuite.
Il faut que nous trouvions une pause le dimanche, sous le saule.
J'ai peur que le travail n'efface les thés de Félicie, alors je les note.
Je range sans crier. Je n'invite ni client ni passant après le repas.
C'est pourquoi le couloir reste une allée, pas un atelier.
Je veux que Léa vienne voir la moto le matin, pas le soir.
Joël""",
        tf_item=(
            "Joël répare encore la moto la nuit.",
            False,
            "« Je ne répare plus la moto la nuit. »",
        ),
        qcm_item=(
            "Que veut Joël ?",
            [
                "Que Léa vienne le soir",
                "Que Léa vienne le matin",
                "Que Karim parte",
                "Que Félicie ferme la table",
            ],
            1,
            "« Je veux que Léa vienne voir la moto le matin, pas le soir. »",
        ),
        pairs=[
            ("ne… plus la nuit", "changement"),
            ("n'ai changé que l'heure", "restriction"),
            ("a dit de ranger", "consigne rapportée"),
            ("il faut que nous trouvions", "pause du dimanche"),
        ],
        fill_item=("Je veux que Léa ___ voir la moto le matin. (venir)", "vienne"),
        words=["Je", "ne", "répare", "plus", "la", "moto", "la", "nuit", "."],
        anagram=("calendrier", "Les jours marqués : lever, pause, infirmerie."),
        error=(
            "Je suis content qu'il dort, après vingt-deux heures, au Pavillon du Saule.",
            "Je suis content qu'il dorme, après vingt-deux heures, au Pavillon du Saule.",
            "Je suis content que + subjonctif : dorme.",
        ),
        pic_start=23,
        pic_words=["un compromis", "un pavillon", "un cahier", "une règle"],
        short_p="Imitez : dix lignes, habitude, changement, conséquence, un que + subjonctif.",
        audio="Lisez votre page de rythme, sans aller trop vite.",
    ),
    _l(
        "EL",
        "EL — Synthèse habitudes et changement",
        "Relier subjonctif, conséquence, discours indirect et négation pour parler d'un rythme.",
        "Apprenez la fiche.",
        "Fiche du banc",
        """Garder une habitude : présent, parfois ne… que (je n'ai changé que l'heure).
Changer : ne… plus / c'est pourquoi / donc. Je ne me lève plus, donc je suis calme.
Limiter : ne… pas encore. Hawa ne marche pas encore jusqu'au marché.
Sentiment sur le rythme : je suis content que tu dormes / j'ai peur que l'on s'oublie.
Objectif commun : il faut que nous trouvions une pause. Je veux que l'on se voie.
Parole rapportée : on m'a dit de dater. Elle demande si jeudi reste libre.
Pour que + subjonctif (but, déjà utile) : pour que le Pavillon souffle.
Sans + infinitif : ranger sans courir.
Un seul il faut, toujours 3e personne.
Ne pas empiler trop de marqueurs dans la même phrase.
Le calendrier aide : un jour, une phrase, un outil.
On écrit le rythme pour le voisinage, pas pour se juger.""",
        tf_item=(
            "« Je n'ai changé que l'heure » signifie que presque tout reste.",
            True,
            "Ne… que = seulement l'heure a changé.",
        ),
        qcm_item=(
            "Quelle structure pose un objectif commun ?",
            [
                "Je n'écoute que Radio Figuier",
                "Il faut que nous trouvions une pause",
                "Je range sans courir",
                "Elle demande si le banc est libre",
            ],
            1,
            "Il faut que + subjonctif, nous.",
        ),
        pairs=[
            ("ne… plus", "changement"),
            ("ne… que", "petit écart"),
            ("il faut que", "but du groupe"),
            ("dit de / demande si", "échos des autres"),
        ],
        fill_item=("Hawa ne marche ___ encore jusqu'au marché.", "pas"),
        words=["C'est", "pourquoi", "le", "couloir", "reste", "calme", "."],
        anagram=("synthese", "Cette séquence rassemble les outils déjà vus (sans accent)."),
        error=(
            "Il faut que nous trouvions une pause, pour que chacun se repose et que Aline est là.",
            "Il faut que nous trouvions une pause, pour que chacun se repose et qu'Aline soit là.",
            "Pour que + subjonctif : qu'Aline soit là.",
        ),
        pic_start=24,
        pic_words=["un pavillon", "un cahier", "une règle", "une oreille"],
        short_p="Rédigez un tableau : habitude / changement / outil grammatical / exemple.",
        audio="Enregistrez la fiche et un rythme personnel en cinq phrases liées.",
    ),
]


# ---------------------------------------------------------------------------
# Séquence 6 — Un voisinage à tisser (EXTRA : médiation, compromis)
# ---------------------------------------------------------------------------

S6 = [
    _l(
        "CO",
        "CO — La clé et la table",
        "Comprendre une médiation : chacun cède un peu pour que le Pavillon tienne.",
        "Lisez le dialogue. Qui cède quoi ? Quel accord sort ?",
        "Table partagée, Pavillon du Saule",
        """Aline : Il faut que chacun parle sans accuser. Je veux que l'on s'écoute.
Karim : J'ai peur que la clé circule trop. Je ne la prête plus à n'importe qui.
Léa : Je suis contente que tu le dises. On peut la poser ici, alors on la voit.
Patrick : Solange m'a dit de noter les allers. Elle demande si le cahier suffit.
Hawa : Je ne sors pas encore tard, donc je n'ai pas besoin de la clé la nuit.
Joël : Je n'entre ni par la fenêtre ni sans frapper. C'est déjà un geste.
Rose : Je ne couds plus après vingt-deux heures, si bien que le couloir se tait.
Marc : C'est pourquoi on range les outils à gauche, les tasses à droite.
Félicie : Je ne sers que deux plateaux. Sans troisième service, je tiens.
Dieudonné : Je veux que la porte reste ouverte le jour, fermée dès l'ombre.
Lila : On m'a dit de recopier l'accord. Je le donnerai au Bureau des Escales.
Yvette : Je suis contente que Hawa s'assoie. Il faut que le banc reste un banc, pas un atelier.""",
        tf_item=(
            "Karim ne veut plus prêter la clé à n'importe qui.",
            True,
            "« Je ne la prête plus à n'importe qui. »",
        ),
        qcm_item=(
            "Où Léa propose-t-elle de poser la clé ?",
            [
                "Sous le figuier",
                "Ici, sur la table, pour qu'on la voie",
                "À Val-des-Peupliers",
                "Dans la moto de Joël",
            ],
            1,
            "Léa : « On peut la poser ici, alors on la voit. »",
        ),
        pairs=[
            ("il faut que chacun parle", "règle de médiation"),
            ("ne la prête plus", "limite de Karim"),
            ("a dit de noter", "trace écrite"),
            ("porte ouverte le jour", "compromis de Dieudonné"),
        ],
        fill_item=("Je veux que l'on s'___. (s'écouter)", "écoute"),
        words=["Il", "faut", "que", "chacun", "parle", "sans", "accuser", "."],
        anagram=("partage", "La clé n'est plus à une seule personne : un…"),
        error=(
            "Il faut que chacun parle sans accuser, et je veux que l'on s'écoute pour que Karim est calme.",
            "Il faut que chacun parle sans accuser, et je veux que l'on s'écoute pour que Karim soit calme.",
            "Pour que + subjonctif : soit.",
        ),
        pic_start=25,
        pic_words=["un cahier", "une règle", "une oreille", "une main"],
        short_p="Notez trois concessions (qui cède quoi) et la phrase d'accord.",
        audio="Enregistrez : Il faut que chacun parle sans accuser. Je ne la prête plus à n'importe qui. Je veux que la porte reste ouverte le jour.",
    ),
    _l(
        "CE",
        "CE — Accord du Pavillon du Saule",
        "Lire un compromis écrit : médiation entre habitants.",
        "Lisez l'accord, sans aller trop vite.",
        "Feuille signée, table du saule",
        """Accord du Pavillon du Saule — Rive-des-Saules
1. Il faut que la clé reste sur la table le jour. Karim ne la prête plus dehors.
2. Léa a dit de frapper avant d'entrer. Joël demande si deux coups suffisent.
3. On n'ouvre plus l'atelier après vingt-deux heures, donc le couloir se tait.
4. Félicie ne sert que deux plateaux, sans service de minuit.
5. Hawa ne sort pas encore tard : Yvette garde le banc de l'infirmerie.
6. Dieudonné veut que la porte soit ouverte le jour, fermée dès l'ombre.
7. On range sans empiler les tasses sur les outils. Marc note la gauche et la droite.
8. Solange a dit de déposer une copie au Bureau des Escales, à Val-des-Peupliers.
9. Je suis contente que chacun signe, écrit Aline. J'ai peur qu'un oubli revienne.
10. C'est pourquoi le dimanche reste une pause commune, sous le saule.
11. On n'invite ni passant ni client la nuit.
12. Rose Iradukunda, Lila Sow, Patrick Habimana : signatures ocre.""",
        tf_item=(
            "L'atelier peut rester ouvert après vingt-deux heures.",
            False,
            "Point 3 : « On n'ouvre plus l'atelier après vingt-deux heures. »",
        ),
        qcm_item=(
            "Combien de plateaux Félicie sert-elle ?",
            ["Un seul", "Deux", "Trois", "Autant qu'on veut"],
            1,
            "« Félicie ne sert que deux plateaux. »",
        ),
        pairs=[
            ("clé sur la table", "compromis du jour"),
            ("frapper avant", "consigne de Léa"),
            ("deux plateaux", "limite de Félicie"),
            ("copie au Bureau", "trace chez Solange"),
        ],
        fill_item=("Dieudonné veut que la porte ___ ouverte le jour. (être)", "soit"),
        words=["On", "n'invite", "ni", "passant", "ni", "client", "la", "nuit", "."],
        anagram=("compromis", "Un accord où chacun cède un peu."),
        error=(
            "Dieudonné veut que la porte est ouverte le jour, fermée dès l'ombre, au Pavillon.",
            "Dieudonné veut que la porte soit ouverte le jour, fermée dès l'ombre, au Pavillon.",
            "Je veux que / il veut que + subjonctif : soit.",
        ),
        pic_start=26,
        pic_words=["une règle", "une oreille", "une main", "un soleil"],
        short_p="Recopiez l'accord et marquez qui cède, qui gagne, à chaque point.",
        audio="Lisez l'accord du Pavillon du Saule, sans aller trop vite.",
    ),
    _l(
        "PO",
        "PO — Proposer un compromis",
        "Mener une petite médiation à voix haute : dire sa limite, entendre l'autre, proposer.",
        "Répétez, puis jouez un accord pour une cour.",
        "Modèles d'Aline",
        """Il faut que chacun parle.
Je veux que l'on s'écoute.
J'ai peur que la clé se perde.
Je ne la prête plus à n'importe qui.
On peut la poser ici, alors on la voit.
On m'a dit de noter les allers.
Elle demande si deux coups suffisent.
Je ne sors pas encore tard, donc je n'en ai pas besoin.
La porte reste ouverte le jour, fermée dès l'ombre.
Je ne sers que deux plateaux.
On n'invite ni passant ni client la nuit.
Je suis contente que chacun signe.""",
        tf_item=(
            "Un compromis nomme une limite et une contrepartie.",
            True,
            "Clé sur la table le jour / pas prêtée dehors, par exemple.",
        ),
        qcm_item=(
            "Quelle phrase ouvre la médiation sans accuser ?",
            [
                "C'est de ta faute",
                "Il faut que chacun parle",
                "Je ne te parle plus",
                "Sors d'ici",
            ],
            1,
            "Aline : chacun parle, on s'écoute.",
        ),
        pairs=[
            ("il faut que chacun", "cadre"),
            ("je ne… plus", "limite"),
            ("on peut… alors", "proposition"),
            ("je suis contente que", "clôture"),
        ],
        fill_item=("Je suis contente que chacun ___. (signer)", "signe"),
        words=["On", "peut", "la", "poser", "ici", "."],
        anagram=("ecoute", "S'entendre : prêter l'… (sans accent)."),
        error=(
            "Je suis contente que chacun signe, bien que Karim a encore peur pour la clé.",
            "Je suis contente que chacun signe, bien que Karim ait encore peur pour la clé.",
            "Bien que + subjonctif : ait.",
        ),
        pic_start=27,
        pic_words=["une oreille", "une main", "un soleil", "un sentiment"],
        short_p="Écrivez un mini-dialogue de médiation : six répliques, un accord final.",
        audio="Enregistrez les douze modèles, puis un compromis à vous (clé, table ou horaire).",
    ),
    _l(
        "PE",
        "PE — Mon accord de voisinage",
        "Écrire un court accord : limites, contreparties, signatures.",
        "Imitez l'accord de Lila.",
        "Accord de Lila Sow",
        """Lila Sow
Pavillon du Saule — copie pour le Bureau des Escales
Il faut que la clé reste visible le jour. Karim ne la prête plus dehors.
Léa a dit de frapper deux fois. Joël demande si cela suffit : oui.
Je ne sors pas encore tard, donc je n'emprunte la clé qu'au matin.
On n'ouvre plus l'atelier après vingt-deux heures, si bien que le couloir se tait.
Félicie ne sert que deux plateaux, sans minuit. Dieudonné ferme dès l'ombre.
Je suis contente que Hawa s'assoie au banc : il faut que ce banc reste un banc.
On n'invite ni passant ni client la nuit.
C'est pourquoi le dimanche est une pause, sous le saule, à Rive-des-Saules.
Je veux que Solange tamponne cette copie. J'ai peur qu'on l'oublie.
Lila""",
        tf_item=(
            "Lila emprunte la clé seulement le matin, pour l'instant.",
            True,
            "« je n'emprunte la clé qu'au matin. »",
        ),
        qcm_item=(
            "Que veut Lila à la fin ?",
            [
                "Que Karim parte",
                "Que Solange tamponne la copie",
                "Que Félicie serve à minuit",
                "Que l'atelier reste ouvert",
            ],
            1,
            "« Je veux que Solange tamponne cette copie. »",
        ),
        pairs=[
            ("clé visible le jour", "contrepartie"),
            ("ne la prête plus dehors", "limite"),
            ("n'emprunte que le matin", "restriction"),
            ("veut que Solange tamponne", "trace officielle"),
        ],
        fill_item=("Je veux que Solange ___ cette copie. (tamponner)", "tamponne"),
        words=["On", "n'ouvre", "plus", "l'atelier", "après", "vingt-deux", "heures", "."],
        anagram=("voisinage", "Les gens de la porte à côté, au Pavillon."),
        error=(
            "Je veux que Solange tamponne cette copie, afin que le Bureau a une trace.",
            "Je veux que Solange tamponne cette copie, afin que le Bureau ait une trace.",
            "Afin que + subjonctif : ait.",
        ),
        pic_start=28,
        pic_words=["une main", "un soleil", "un sentiment", "un souci"],
        short_p="Imitez : dix lignes d'accord, deux limites, deux contreparties, un que + subjonctif.",
        audio="Lisez votre accord de voisinage, sans aller trop vite.",
    ),
    _l(
        "EL",
        "EL — Médier et conclure",
        "Retenir les formes utiles pour un compromis au Pavillon.",
        "Apprenez la fiche.",
        "Fiche d'Aline, médiation",
        """Cadre : il faut que chacun parle. Je veux que l'on s'écoute. Sans accuser.
Limite : je ne… plus / je ne… que / je n'accepte ni… ni.
Proposition : on peut…, alors… / c'est pourquoi…
But du compromis : pour que / afin que + subjonctif (pour que Karim soit calme).
Concession : bien que + subjonctif (bien qu'il ait peur).
Sentiment de clôture : je suis content(e) que chacun signe.
Crainte utile : j'ai peur qu'on l'oublie → d'où la copie au Bureau.
Paroles rapportées : X a dit de… / Y demande si…
La clé, la table, l'horaire : trois objets concrets valent mieux qu'un grand discours.
Toujours il faut (3e personne). Conditionnel plus tard : je serais d'accord si…
Un accord se recopie : Lila, Solange, tampon.
Le voisinage se tisse : petites phrases, signatures, silence partagé.""",
        tf_item=(
            "« Pour que » et « afin que » se construisent avec l'indicatif.",
            False,
            "Pour que / afin que + subjonctif.",
        ),
        qcm_item=(
            "Quelle phrase pose un but de médiation ?",
            [
                "Je ne la prête plus",
                "On n'invite ni passant ni client",
                "Pour que Karim soit calme",
                "Elle demande si deux coups suffisent",
            ],
            2,
            "Pour que + subjonctif = but.",
        ),
        pairs=[
            ("il faut que chacun", "cadre"),
            ("je ne… plus", "limite"),
            ("pour que + subj.", "but"),
            ("bien que + subj.", "concession"),
        ],
        fill_item=("Pour que Karim ___ calme. (être)", "soit"),
        words=["Je", "veux", "que", "l'on", "s'écoute", "."],
        anagram=("mediation", "Aider deux parties à s'accorder (sans accent)."),
        error=(
            "On pose la clé sur la table, afin que chacun la voit pendant le jour.",
            "On pose la clé sur la table, afin que chacun la voie pendant le jour.",
            "Afin que + subjonctif : voie (pas voit).",
        ),
        pic_start=29,
        pic_words=["un soleil", "un sentiment", "un souci", "un voisin"],
        short_p="Rédigez six formules types de médiation, une par ligne, à réemployer.",
        audio="Enregistrez la fiche et un mini-accord inventé (quatre phrases).",
    ),
]


SEQUENCES = [
    {"title": "Un souci du quotidien", "lessons": S1},
    {"title": "Anticiper un problème de santé", "lessons": S2},
    {"title": "Des papiers à remplir", "lessons": S3},
    {"title": "Goûts et façons de vivre", "lessons": S4},
    {"title": "Trouver un rythme", "lessons": S5},
    {"title": "Un voisinage à tisser", "lessons": S6},
]
