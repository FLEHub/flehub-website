"""B1 Module 5 — Étudier et travailler autrement (univers Seuil des Sources)."""

from factory import L

IMG = "mfk-b1-m5"
IMG_DIR = IMG

MODULE = {
    "title": "B1 — Étudier et travailler autrement",
    "description": (
        "Grande étape B1-5 : dire son parcours, se préparer à l'entretien, "
        "oser une expérience, raconter une journée de métier, vivre un stage "
        "à Radio Figuier et faire le bilan — Patrick et Joël cherchent leur voie, "
        "Léa rejoint l'antenne, Dieudonné ouvre l'Atelier du Tissu, "
        "Aline prépare les entretiens, au Seuil des Sources (Rukiri-Nord)."
    ),
}


def _l(comp, title, obj, cons, st, sp, **kw):
    return L(IMG, comp, title, obj, cons, st, sp, **kw)


# ---------------------------------------------------------------------------
# Séquence 1 — Dire son parcours
# ---------------------------------------------------------------------------

S1 = [
    _l(
        "CO",
        "CO — Parcours sous le figuier",
        "Comprendre une motivation et les articulateurs d'une lettre.",
        "Lisez le dialogue. Quel parcours ? Quels articulateurs ?",
        "Banc du Seuil, lettres ouvertes",
        """Patrick : Tout d'abord, je veux relire mon parcours avec Aline.
Joël : En effet, sans plan, la lettre part trop vite.
Léa : Par ailleurs, Radio Figuier attend une page claire, pas vingt.
Marc : De plus, il faut dire pourquoi on choisit ce lieu, pas un autre.
Hawa : Enfin, on clôt : dans l'attente de votre réponse.
Aline : Je vous prie de garder un ton calme, assez précis.
Dieudonné : Tout d'abord l'atelier, ensuite les sacs, enfin le relais.
Rose : En effet, Joël a déjà porté des seaux : cela compte.
Karim : Par ailleurs, Solange lira les lettres au Bureau des Escales.
Lila : De plus, un stage n'est pas un discours : une preuve suffit.
Félicie : Dans l'attente de votre réponse, la table reste ouverte jeudi.
Patrick : Je vous prie d'agréer, Madame, mes salutations attentives.""",
        tf_item=(
            "Hawa clôt avec « dans l'attente de votre réponse ».",
            True,
            "Hawa : « Enfin, on clôt : dans l'attente de votre réponse. »",
        ),
        qcm_item=(
            "Que demande Aline pour le ton ?",
            [
                "Un ton extrêmement long",
                "Un ton calme, assez précis",
                "Un ton crié",
                "Aucun ton, seulement des chiffres",
            ],
            1,
            "Aline : « un ton calme, assez précis. »",
        ),
        pairs=[
            ("tout d'abord", "ouverture"),
            ("en effet", "justification"),
            ("par ailleurs / de plus", "ajout"),
            ("dans l'attente de", "clôture"),
        ],
        fill_item=("___ d'abord, je veux relire mon parcours.", "Tout"),
        words=["En", "effet", "sans", "plan", "la", "lettre", "part", "trop", "vite", "."],
        anagram=("ailleurs", "Articulateur d'ajout : par…, Radio Figuier attend une page."),
        error=(
            "Tout dabord je veux relire mon parcours avec Aline.",
            "Tout d'abord je veux relire mon parcours avec Aline.",
            "Tout d'abord, avec apostrophe.",
        ),
        pic_start=0,
        pic_words=["une lettre", "un articulateur", "un parcours", "un curriculum"],
        short_p="Notez cinq articulateurs entendus et leur rôle (ouvrir, justifier, ajouter, clore).",
        audio="Enregistrez : Tout d'abord. En effet. Par ailleurs. De plus. Enfin. Dans l'attente de votre réponse.",
    ),
    _l(
        "CE",
        "CE — Lettre de motivation de Patrick",
        "Lire une lettre de parcours avec articulateurs.",
        "Lisez la lettre, sans aller trop vite.",
        "Lettre de Patrick Habimana",
        """Patrick Habimana — Seuil des Sources, Rukiri-Nord
Madame Sow,
Tout d'abord, je vous écris pour le relais du matin à Radio Figuier.
En effet, j'ai déjà tenu le Cahier des racines et porté des seaux à la rive.
Par ailleurs, Joël peut confirmer ces gestes, sans discours trop long.
De plus, Aline m'a aidé à dire mon parcours en une page.
Enfin, je joins une feuille de dates, assez claire.
Dans l'attente de votre réponse, je reste joignable à la cour.
Je vous prie d'agréer, Madame, mes salutations attentives.
Patrick Habimana
Copie : Aline Uwase
Copie au Cahier des racines, sous le figuier.""",
        tf_item=(
            "Patrick écrit à Madame Sow pour un relais à Radio Figuier.",
            True,
            "« pour le relais du matin à Radio Figuier. »",
        ),
        qcm_item=(
            "Qui peut confirmer les gestes de Patrick ?",
            ["Solange seule", "Joël", "Un minibus", "Félicie seulement"],
            1,
            "« Joël peut confirmer ces gestes. »",
        ),
        pairs=[
            ("tout d'abord", "je vous écris"),
            ("en effet", "Cahier et seaux"),
            ("par ailleurs", "Joël"),
            ("je vous prie", "clôture"),
        ],
        fill_item=("___ plus, Aline m'a aidé à dire mon parcours.", "De"),
        words=["Dans", "l'attente", "de", "votre", "réponse", "je", "reste", "joignable", "."],
        anagram=("attente", "Formule de clôture : dans l'… de votre réponse."),
        error=(
            "Je vous prie d'agréer Madame mes salutation attentives.",
            "Je vous prie d'agréer Madame mes salutations attentives.",
            "Salutations au pluriel.",
        ),
        pic_start=1,
        pic_words=["un articulateur", "un parcours", "un curriculum", "un entretien"],
        short_p="Recopiez la lettre et encadrez les sept articulateurs de la séquence.",
        audio="Lisez la lettre de Patrick, sans aller trop vite.",
    ),
    _l(
        "PO",
        "PO — Enchaîner une lettre",
        "Dire un parcours avec tout d'abord, en effet, par ailleurs, de plus, enfin, clôture.",
        "Répétez, puis dites votre parcours en six étapes.",
        "Modèles de Joël",
        """Tout d'abord, je me présente.
En effet, j'ai déjà porté des seaux.
Par ailleurs, l'atelier me connaît.
De plus, je sais relayer une heure.
Enfin, je joins une page.
Dans l'attente de votre réponse…
Je vous prie d'agréer mes salutations.
Je veux ce relais, pas un autre.
Mon parcours reste local.
Assez d'une page.
Pas trop de discours.
Aline m'écoute.""",
        tf_item=(
            "« En effet » sert à justifier, pas à conclure.",
            True,
            "Justification après l'ouverture.",
        ),
        qcm_item=(
            "Quelle formule clôt la lettre ?",
            [
                "Tout d'abord",
                "Dans l'attente de votre réponse",
                "Par ailleurs",
                "De plus",
            ],
            1,
            "Clôture : dans l'attente de…",
        ),
        pairs=[
            ("tout d'abord", "1"),
            ("en effet", "preuve"),
            ("de plus", "ajout"),
            ("enfin", "avant la clôture"),
        ],
        fill_item=("Je vous ___ d'agréer mes salutations.", "prie"),
        words=["Tout", "d'abord", "je", "me", "présente", "."],
        anagram=("parcours", "Ce qu'on raconte dans la lettre : son… , pas vingt pages."),
        error=(
            "Par ailleur l'atelier me connaît déjà.",
            "Par ailleurs l'atelier me connaît déjà.",
            "Ailleurs, avec s.",
        ),
        pic_start=2,
        pic_words=["un parcours", "un curriculum", "un entretien", "une porte"],
        short_p="Écrivez six phrases orales, une par articulateur de la fiche.",
        audio="Enregistrez les modèles, puis votre parcours en six étapes.",
    ),
    _l(
        "PE",
        "PE — Ma lettre de parcours",
        "Écrire une lettre de motivation avec les articulateurs.",
        "Imitez la lettre de Joël, sans aller trop vite.",
        "Lettre de Joël Mugisha",
        """Joël Mugisha
Seuil des Sources, Rukiri-Nord
Madame Hakizimana,
Tout d'abord, je vous écris pour aider à l'Atelier du Tissu le matin.
En effet, j'ai déjà plié des sacs et porté des seaux à la rive.
Par ailleurs, Patrick peut confirmer ces heures.
De plus, Aline a relu cette page avec moi.
Enfin, je joins trois dates libres.
Dans l'attente de votre réponse, je reste à la cour.
Je vous prie d'agréer, Madame, mes salutations.
Joël""",
        tf_item=(
            "Joël écrit à Madame Hakizimana pour l'atelier le matin.",
            True,
            "« pour aider à l'Atelier du Tissu le matin. »",
        ),
        qcm_item=(
            "Que joint Joël à la fin ?",
            ["Vingt pages", "Trois dates libres", "Un passeport", "Une cravate"],
            1,
            "« je joins trois dates libres. »",
        ),
        pairs=[
            ("tout d'abord", "l'atelier"),
            ("en effet", "sacs et seaux"),
            ("par ailleurs", "Patrick"),
            ("dans l'attente de", "clôture"),
        ],
        fill_item=("___ , je joins trois dates libres.", "Enfin"),
        words=["Je", "vous", "prie", "d'agréer", "mes", "salutations", "."],
        anagram=("motivation", "La lettre dit pourquoi on veut ce relais : une… claire."),
        error=(
            "Dans l'attente de votre reponse je reste à la cour trop vite.",
            "Dans l'attente de votre réponse je reste à la cour trop vite.",
            "Réponse, avec accent.",
        ),
        pic_start=3,
        pic_words=["un curriculum", "un entretien", "une porte", "une cravate"],
        short_p="Imitez : une lettre de dix à douze lignes, sept articulateurs.",
        audio="Lisez votre lettre, sans aller trop vite.",
    ),
    _l(
        "EL",
        "EL — Articulateurs de lettre",
        "Retenir tout d'abord, en effet, par ailleurs, de plus, enfin, dans l'attente de, je vous prie.",
        "Apprenez la fiche.",
        "Fiche d'Aline",
        """Ouverture : tout d'abord (apostrophe : d'abord).
Justification : en effet (on prouve, on explique).
Ajout : par ailleurs / de plus (une idée de plus, sans tout répéter).
Fin du développement : enfin.
Attente : dans l'attente de votre réponse / de votre lecture.
Clôture : je vous prie d'agréer… / je vous prie de + infinitif.
Parcours : ce que j'ai déjà fait, ici, au Seuil, assez d'une page.
Destinataires inventés : Madame Sow, Madame Hakizimana, Bureau des Escales.
Ne pas dire : tout dabord (sans apostrophe).
Ne pas dire : par ailleur (sans s).
Ne pas dire : je vous pries.
Ordre fréquent : tout d'abord → en effet → par ailleurs → de plus → enfin → attente → prie.""",
        tf_item=(
            "On écrit « je vous pries » à la clôture.",
            False,
            "Je vous prie, sans s.",
        ),
        qcm_item=(
            "Quel articulateur justifie ?",
            ["tout d'abord", "en effet", "enfin", "dans l'attente de"],
            1,
            "En effet = justification.",
        ),
        pairs=[
            ("tout d'abord", "ouvrir"),
            ("en effet", "justifier"),
            ("par ailleurs", "ajouter"),
            ("je vous prie", "clore"),
        ],
        fill_item=("Par ___ , l'atelier me connaît.", "ailleurs"),
        words=["Dans", "l'attente", "de", "votre", "réponse", "."],
        anagram=("justifier", "Rôle de « en effet » : … ce qu'on vient de dire."),
        error=(
            "Je vous pries d'agréer mes salutations attentives.",
            "Je vous prie d'agréer mes salutations attentives.",
            "Je vous prie, 1re personne, sans s.",
        ),
        pic_start=4,
        pic_words=["un entretien", "une porte", "une cravate", "une note"],
        short_p="Rédigez une mini-lettre de huit lignes en suivant l'ordre de la fiche.",
        audio="Enregistrez la fiche et les sept articulateurs.",
    ),
]


# ---------------------------------------------------------------------------
# Séquence 2 — Se préparer à l'entretien
# ---------------------------------------------------------------------------

S2 = [
    _l(
        "CO",
        "CO — Aline prépare l'entretien",
        "Repérer les conseils d'embauche : vous devriez, il vaudrait mieux, évitez de.",
        "Lisez le dialogue. Quels conseils ? Quels pièges ?",
        "Salle des Herbes, notes d'Aline",
        """Aline : Vous devriez arriver dix minutes avant, pas trop tôt non plus.
Patrick : Il vaudrait mieux préparer deux exemples, assez clairs.
Joël : Évitez de parler trop vite : une phrase, une pause.
Léa : Vous devriez écouter la question jusqu'au bout.
Marc : Il vaudrait mieux regarder la personne, pas seulement la feuille.
Hawa : Évitez de critiquer un ancien relais.
Dieudonné : Vous devriez montrer un sac, un geste, une heure tenue.
Rose : Il vaudrait mieux saluer Solange si elle passe.
Karim : Évitez d'inventer une ville ou une enseigne.
Lila : Vous devriez répéter votre ouverture, pas tout le discours.
Félicie : Il vaudrait mieux remercier, même si la réponse attend.
Aline : Évitez de dire « je sais tout » : nuancez.""",
        tf_item=(
            "Joël conseille d'éviter de parler trop vite.",
            True,
            "Joël : « Évitez de parler trop vite. »",
        ),
        qcm_item=(
            "Combien d'exemples Patrick devrait-il préparer ?",
            ["Aucun", "Deux", "Vingt", "Un seul mot"],
            1,
            "« deux exemples, assez clairs. »",
        ),
        pairs=[
            ("vous devriez", "conseil poli"),
            ("il vaudrait mieux", "conseil plus net"),
            ("évitez de", "interdit doux"),
            ("dix minutes avant", "horaire"),
        ],
        fill_item=("___ de parler trop vite.", "Évitez"),
        words=["Vous", "devriez", "arriver", "dix", "minutes", "avant", "."],
        anagram=("devriez", "Conseil à vous : vous… écouter jusqu'au bout."),
        error=(
            "Évitez de inventer une ville ou une enseigne.",
            "Évitez d'inventer une ville ou une enseigne.",
            "Éviter d' + voyelle.",
        ),
        pic_start=5,
        pic_words=["une porte", "une cravate", "une note", "un risque"],
        short_p="Classez six conseils : devriez / vaudrait mieux / évitez de.",
        audio="Enregistrez : Vous devriez arriver avant. Il vaudrait mieux préparer deux exemples. Évitez de parler trop vite.",
    ),
    _l(
        "CE",
        "CE — Fiche conseils d'Aline",
        "Lire une fiche d'entretien avec vous devriez, il vaudrait mieux, évitez de.",
        "Lisez la fiche, sans aller trop vite.",
        "Fiche d'Aline Uwase",
        """Entretien au Seuil — conseils
1. Vous devriez saluer, puis attendre qu'on vous offre le banc.
2. Il vaudrait mieux dire votre parcours en huit phrases, pas plus.
3. Évitez de lire toute la lettre à voix haute.
4. Vous devriez donner un exemple tenu : un seau, un sac, une heure.
5. Il vaudrait mieux poser une question à la fin.
6. Évitez d'interrompre Lila ou Dieudonné.
7. Vous devriez remercier, même si on vous dit « on écrit ».
8. Il vaudrait mieux un vêtement simple qu'une cravate trop inventée.
9. Évitez de promettre ce que la cour ne peut pas tenir.
10. Vous devriez arriver par le figuier, assez calmes.
11. Karim : il vaudrait mieux un dossier d'une page.
12. Solange : évitez de taper trop fort à la porte du Bureau.""",
        tf_item=(
            "Aline recommande de lire toute la lettre à voix haute.",
            False,
            "Point 3 : « Évitez de lire toute la lettre. »",
        ),
        qcm_item=(
            "Que vaut-il mieux faire à la fin ?",
            [
                "Partir sans un mot",
                "Poser une question",
                "Crier un chiffre",
                "Signer pour les autres",
            ],
            1,
            "« poser une question à la fin. »",
        ),
        pairs=[
            ("vous devriez saluer", "ouverture"),
            ("il vaudrait mieux dire", "huit phrases"),
            ("évitez de lire", "toute la lettre"),
            ("évitez d'interrompre", "Lila ou Dieudonné"),
        ],
        fill_item=("Il vaudrait mieux poser une ___ à la fin.", "question"),
        words=["Évitez", "de", "promettre", "ce", "que", "la", "cour", "ne", "peut", "pas", "tenir", "."],
        anagram=("interrompre", "Évitez d'… Lila : laissez-la finir sa phrase."),
        error=(
            "Évitez de interrompre Lila ou Dieudonné pendant l'entretien.",
            "Évitez d'interrompre Lila ou Dieudonné pendant l'entretien.",
            "D'interrompre, élision.",
        ),
        pic_start=6,
        pic_words=["une cravate", "une note", "un risque", "une expérience"],
        short_p="Recopiez la fiche et ajoutez deux conseils à vous, avec les mêmes formules.",
        audio="Lisez les douze points, sans aller trop vite.",
    ),
    _l(
        "PO",
        "PO — Conseiller pour l'entretien",
        "Donner des conseils d'embauche à voix haute.",
        "Répétez, puis conseillez Patrick ou Léa.",
        "Modèles d'Aline",
        """Vous devriez arriver un peu avant.
Vous devriez écouter jusqu'au bout.
Il vaudrait mieux deux exemples.
Il vaudrait mieux une question à la fin.
Évitez de parler trop vite.
Évitez d'inventer un lieu.
Vous devriez remercier.
Il vaudrait mieux une page.
Évitez de tout promettre.
Saluez.
Attendez le banc.
Restez clairs.""",
        tf_item=(
            "« Évitez de » + infinitif exprime un conseil négatif.",
            True,
            "Évitez de parler trop vite.",
        ),
        qcm_item=(
            "Quelle forme est correcte devant une voyelle ?",
            [
                "évitez de inventer",
                "évitez d'inventer",
                "évitez inventer",
                "évitez que inventer",
            ],
            1,
            "Éviter d' + voyelle.",
        ),
        pairs=[
            ("vous devriez", "vous / devoir au conditionnel"),
            ("il vaudrait mieux", "conseil net"),
            ("évitez de", "ne pas faire"),
            ("évitez d'", "devant voyelle"),
        ],
        fill_item=("Vous ___ écouter jusqu'au bout.", "devriez"),
        words=["Il", "vaudrait", "mieux", "deux", "exemples", "."],
        anagram=("exemples", "Il vaudrait mieux en préparer deux, assez clairs."),
        error=(
            "Il vaudrait mieux de préparer deux exemples assez clairs.",
            "Il vaudrait mieux préparer deux exemples assez clairs.",
            "Il vaudrait mieux + infinitif, sans de.",
        ),
        pic_start=7,
        pic_words=["une note", "un risque", "une expérience", "un nuage"],
        short_p="Écrivez six conseils : deux de chaque formule.",
        audio="Enregistrez les modèles, puis trois conseils à Patrick.",
    ),
    _l(
        "PE",
        "PE — Mes conseils d'entretien",
        "Écrire une fiche de conseils pour un entretien au Seuil.",
        "Imitez la fiche de Léa, sans aller trop vite.",
        "Fiche de Léa Niyonzima",
        """Léa Niyonzima
Vous devriez arriver par le figuier, assez calmes.
Il vaudrait mieux préparer deux exemples tenus.
Évitez de parler trop vite : une phrase, une pause.
Vous devriez écouter Lila jusqu'au bout.
Il vaudrait mieux poser une question à la fin.
Évitez d'inventer une enseigne ou une ville.
Vous devriez remercier, même si la réponse attend.
Léa
Radio Figuier — notes d'entretien
Seuil des Sources""",
        tf_item=(
            "Léa demande d'inventer une enseigne.",
            False,
            "« Évitez d'inventer une enseigne ou une ville. »",
        ),
        qcm_item=(
            "Par où Léa dit-elle d'arriver ?",
            ["Par le marché seulement", "Par le figuier", "Par un minibus de ville", "Par la rivière à minuit"],
            1,
            "« arriver par le figuier. »",
        ),
        pairs=[
            ("vous devriez arriver", "figuier"),
            ("il vaudrait mieux préparer", "deux exemples"),
            ("évitez de parler", "trop vite"),
            ("évitez d'inventer", "enseigne"),
        ],
        fill_item=("Évitez ___ parler trop vite.", "de"),
        words=["Vous", "devriez", "remercier", "même", "si", "la", "réponse", "attend", "."],
        anagram=("remercier", "Vous devriez… même si la réponse attend."),
        error=(
            "Évitez de parler trop vite une phrase une pause trop longues.",
            "Évitez de parler trop vite une phrase une pause trop longue.",
            "Une pause trop longue, accord avec pause.",
        ),
        pic_start=8,
        pic_words=["un risque", "une expérience", "un nuage", "un badge"],
        short_p="Imitez : dix lignes, trois formules de conseil, deux exemples du Seuil.",
        audio="Lisez votre fiche, sans aller trop vite.",
    ),
    _l(
        "EL",
        "EL — Conseils d'embauche",
        "Retenir vous devriez, il vaudrait mieux, évitez de.",
        "Apprenez la fiche.",
        "Fiche de l'entretien",
        """Vous devriez + infinitif : devoir au conditionnel, conseil poli.
Il vaudrait mieux + infinitif : conseil plus net, sans de.
Il vaudrait mieux que + subjonctif : autre sujet (qu'il écoute).
Évitez de + infinitif : conseil négatif.
Évitez d' + voyelle : évitez d'inventer, évitez d'interrompre.
Pièges au Seuil : parler trop vite, tout promettre, inventer un lieu réel,
lire toute la lettre, une cravate trop inventée, taper trop fort.
Gestes utiles : saluer, attendre le banc, deux exemples, une question, remercier.
Ne pas dire : vous devez de arriver.
Ne pas dire : il vaudrait mieux de + infinitif.
Ne pas dire : évitez de + voyelle sans élision.
Conditionnel : je devrais, tu devrais, il devrait, nous devrions, vous devriez.""",
        tf_item=(
            "« Évitez d'interrompre » est la forme devant voyelle.",
            True,
            "Élision : d'interrompre.",
        ),
        qcm_item=(
            "Quelle série est correcte ?",
            [
                "vous devez de / évitez de inventer",
                "vous devriez / évitez d'inventer",
                "vous devriez de / évitez inventer",
                "il faut de / évitez que inventer",
            ],
            1,
            "Devriez + infinitif ; évitez d' + voyelle.",
        ),
        pairs=[
            ("vous devriez", "conseil"),
            ("il vaudrait mieux", "conseil net"),
            ("évitez de", "négatif"),
            ("évitez d'", "voyelle"),
        ],
        fill_item=("Évitez ___ interrompre Lila.", "d'"),
        words=["Vous", "devriez", "saluer", "puis", "attendre", "."],
        anagram=("conditionnel", "Devriez et vaudrait : un temps pour conseiller, le…"),
        error=(
            "Vous devriez de arriver dix minutes avant l'entretien.",
            "Vous devriez arriver dix minutes avant l'entretien.",
            "Devriez + infinitif, sans de.",
        ),
        pic_start=9,
        pic_words=["une expérience", "un nuage", "un badge", "un gérondif"],
        short_p="Conjuguez devoir au conditionnel et écrivez trois évitez de / d'.",
        audio="Enregistrez la fiche et six conseils.",
    ),
]


# ---------------------------------------------------------------------------
# Séquence 3 — Oser une expérience
# ---------------------------------------------------------------------------

S3 = [
    _l(
        "CO",
        "CO — Oser sous le figuier",
        "Comprendre une prise de risque et sa valorisation : j'ai appris à, cela m'a permis de.",
        "Lisez le dialogue. Qui a osé ? Qu'a-t-il appris ?",
        "Cour du Seuil, après un essai",
        """Joël : J'ai osé porter les seaux trop lourds : j'ai appris à demander de l'aide.
Patrick : Cela m'a permis de parler moins vite au Bureau.
Léa : J'ai osé le micro : j'ai appris à respirer avant la phrase.
Dieudonné : Oser l'atelier, cela m'a permis de montrer un sac fini.
Aline : Valorisez le risque : pas « j'ai échoué », « j'ai appris à… ».
Marc : J'ai appris à écouter Lila jusqu'au bout.
Hawa : Cela m'a permis de nuancer, pas de tout promettre.
Rose : J'ai osé signer la première : j'ai appris à tenir une heure.
Karim : Cela m'a permis de relire la lettre sans trembler.
Lila : J'ai appris à couper un discours trop long.
Félicie : Oser la table un jour de foule, cela m'a permis de ranger plus tôt.
Solange : Le Bureau aime un risque raconté, pas un risque caché.""",
        tf_item=(
            "Aline veut qu'on valorise le risque par « j'ai appris à ».",
            True,
            "Aline : pas « j'ai échoué », « j'ai appris à… ».",
        ),
        qcm_item=(
            "Qu'a permis à Patrick de parler moins vite ?",
            [
                "Un voyage dans une grande ville",
                "L'expérience racontée ici",
                "Une cravate",
                "Fermer Radio Figuier",
            ],
            1,
            "« Cela m'a permis de parler moins vite. »",
        ),
        pairs=[
            ("j'ai osé", "prise de risque"),
            ("j'ai appris à", "compétence"),
            ("cela m'a permis de", "résultat"),
            ("valoriser", "dire l'apport"),
        ],
        fill_item=("J'ai ___ à demander de l'aide.", "appris"),
        words=["Cela", "m'a", "permis", "de", "parler", "moins", "vite", "."],
        anagram=("oser", "Prendre un risque utile : … le micro, l'atelier, la table."),
        error=(
            "J'ai appris de demander de l'aide trop vite.",
            "J'ai appris à demander de l'aide trop vite.",
            "Apprendre à + infinitif.",
        ),
        pic_start=10,
        pic_words=["un nuage", "un badge", "un gérondif", "un participe"],
        short_p="Notez trois risques et, pour chacun, j'ai appris à / cela m'a permis de.",
        audio="Enregistrez : J'ai osé. J'ai appris à demander. Cela m'a permis de parler moins vite.",
    ),
    _l(
        "CE",
        "CE — Portraits d'expériences",
        "Lire des portraits qui valorisent une prise de risque.",
        "Lisez les portraits, sans aller trop vite.",
        "Mur de la Maison des Vents",
        """Portrait Joël : j'ai osé le compost trop tôt ; j'ai appris à commencer petit.
Portrait Patrick : oser la lettre, cela m'a permis de classer mon parcours.
Portrait Léa : j'ai osé le premier micro ; j'ai appris à dire une phrase, puis à taire.
Portrait Dieudonné : oser un sac trop large, cela m'a permis de recoudre un fond.
Portrait Aline : valorisez : j'ai appris à / cela m'a permis de, pas seulement j'ai raté.
Portrait Marc : j'ai appris à filmer sans parler par-dessus Lila.
Portrait Hawa : cela m'a permis de mesurer l'eau, de moins en moins gaspiller.
Portrait Rose : j'ai osé le premier nom du Cahier ; j'ai appris à relayer.
Portrait Lila : oser une heure d'antenne trop calme, cela m'a permis d'écouter la cour.
Portrait Félicie : j'ai appris à ouvrir la table sans tout poser d'un coup.
Portrait Karim : cela m'a permis de porter un dossier d'une page.
Portrait Solange : le Bureau lit les risques dits, pas les risques cachés.""",
        tf_item=(
            "Dieudonné a appris, en osant un sac trop large, à recoudre un fond.",
            True,
            "« cela m'a permis de recoudre un fond. »",
        ),
        qcm_item=(
            "Que valorise Aline, d'après le mur ?",
            [
                "Seulement « j'ai raté »",
                "J'ai appris à / cela m'a permis de",
                "Inventer une ville",
                "Cacher le risque",
            ],
            1,
            "Portrait Aline : valorisez ces deux formules.",
        ),
        pairs=[
            ("Joël", "commencer petit"),
            ("Léa", "une phrase puis taire"),
            ("Dieudonné", "recoudre un fond"),
            ("Lila", "écouter la cour"),
        ],
        fill_item=("Oser la lettre, cela m'a ___ de classer mon parcours.", "permis"),
        words=["J'ai", "appris", "à", "commencer", "petit", "."],
        anagram=("valoriser", "Transformer un risque en compétence : … l'expérience."),
        error=(
            "Cela m'a permis à classer mon parcours trop vite.",
            "Cela m'a permis de classer mon parcours trop vite.",
            "Permettre de + infinitif.",
        ),
        pic_start=11,
        pic_words=["un badge", "un gérondif", "un participe", "un pronom"],
        short_p="Choisissez trois portraits et réécrivez-les à la 1re personne.",
        audio="Lisez les douze portraits, sans aller trop vite.",
    ),
    _l(
        "PO",
        "PO — Valoriser un risque",
        "Raconter une expérience osée et la valoriser.",
        "Répétez, puis valorisez un geste à vous.",
        "Modèles de Patrick",
        """J'ai osé écrire.
J'ai appris à classer.
Cela m'a permis de parler moins vite.
J'ai osé le micro.
J'ai appris à respirer.
Cela m'a permis d'écouter.
J'ai osé l'atelier.
J'ai appris à recoudre.
Cela m'a permis de montrer un sac.
Je ne dis pas seulement « j'ai raté ».
Je valorise.
Je nuance.""",
        tf_item=(
            "« Cela m'a permis de » introduit un résultat.",
            True,
            "Résultat de l'expérience.",
        ),
        qcm_item=(
            "Quelle construction est correcte ?",
            [
                "j'ai appris de classer",
                "j'ai appris à classer",
                "cela m'a permis à classer",
                "j'ai appris classer",
            ],
            1,
            "Apprendre à + infinitif.",
        ),
        pairs=[
            ("j'ai osé", "risque"),
            ("j'ai appris à", "geste appris"),
            ("cela m'a permis de", "résultat"),
            ("valoriser", "dire l'apport"),
        ],
        fill_item=("Cela m'a permis ___ parler moins vite.", "de"),
        words=["J'ai", "osé", "le", "micro", "."],
        anagram=("respirer", "Léa a appris à… avant la phrase au micro."),
        error=(
            "J'ai appris à classer cela m'a permis à parler moins vite.",
            "J'ai appris à classer cela m'a permis de parler moins vite.",
            "Permis de, pas permis à.",
        ),
        pic_start=12,
        pic_words=["un gérondif", "un participe", "un pronom", "une horloge"],
        short_p="Écrivez six phrases : deux osé, deux appris à, deux permis de.",
        audio="Enregistrez les modèles, puis une expérience à vous.",
    ),
    _l(
        "PE",
        "PE — Mon expérience osée",
        "Écrire un portrait qui valorise une prise de risque.",
        "Imitez le portrait de Dieudonné, sans aller trop vite.",
        "Portrait de Dieudonné Hakizimana",
        """Dieudonné Hakizimana
J'ai osé un sac trop large pour la rive.
J'ai appris à recoudre un fond solide.
Cela m'a permis de montrer un geste fini à Joël.
J'ai osé dire non à trop de tissu perdu.
J'ai appris à commencer par trois sacs.
Cela m'a permis de tenir l'heure du matin.
Je valorise : pas seulement « j'ai raté ».
Dieudonné
Atelier du Tissu
Seuil des Sources — Rukiri-Nord""",
        tf_item=(
            "Dieudonné a appris à commencer par trois sacs.",
            True,
            "« J'ai appris à commencer par trois sacs. »",
        ),
        qcm_item=(
            "À qui a-t-il montré un geste fini ?",
            ["Solange", "Joël", "Lila", "Un minibus"],
            1,
            "« à Joël. »",
        ),
        pairs=[
            ("osé un sac trop large", "risque"),
            ("appris à recoudre", "geste"),
            ("permis de montrer", "résultat"),
            ("commencer par trois", "mesure"),
        ],
        fill_item=("J'ai appris ___ recoudre un fond solide.", "à"),
        words=["Cela", "m'a", "permis", "de", "tenir", "l'heure", "."],
        anagram=("recoudre", "Dieudonné a appris à… un fond trop faible."),
        error=(
            "J'ai appris à recoudre un fond solide trop solides.",
            "J'ai appris à recoudre un fond solide trop solide.",
            "Fond est masculin singulier : solide.",
        ),
        pic_start=13,
        pic_words=["un participe", "un pronom", "une horloge", "un stage"],
        short_p="Imitez : dix lignes, deux risques, deux j'ai appris à, deux cela m'a permis de.",
        audio="Lisez votre portrait, sans aller trop vite.",
    ),
    _l(
        "EL",
        "EL — Valoriser une expérience",
        "Retenir j'ai osé, j'ai appris à, cela m'a permis de.",
        "Apprenez la fiche.",
        "Fiche du risque utile",
        """Prise de risque : j'ai osé + nom / infinitif (j'ai osé le micro / oser écrire).
Compétence : j'ai appris à + infinitif (pas apprendre de + infinitif ici).
Résultat : cela m'a permis de + infinitif (pas permis à + infinitif).
Devant voyelle : cela m'a permis d'écouter.
Valoriser : transformer l'échec apparent en apport (j'ai appris à demander).
Ne pas rester à « j'ai raté » seul.
Exemples du Seuil : seaux trop lourds, sac trop large, premier micro, lettre,
table un jour de foule, heure d'antenne trop calme.
Accord : j'ai appris (invariable ici) ; cela (neutre) m'a permis.
Ne pas dire : j'ai appris de + infinitif (sens « on m'a dit » est autre).
Ne pas dire : cela m'a permis à.
On peut relier : en osant X, j'ai appris à Y.""",
        tf_item=(
            "On dit « cela m'a permis à classer ».",
            False,
            "Permis de + infinitif.",
        ),
        qcm_item=(
            "« Cela m'a permis ___ écouter. »",
            ["de", "d'", "à", "pour"],
            1,
            "Devant voyelle : d'écouter.",
        ),
        pairs=[
            ("j'ai osé", "risque"),
            ("j'ai appris à", "compétence"),
            ("cela m'a permis de", "résultat"),
            ("valoriser", "dire l'apport"),
        ],
        fill_item=("Cela m'a permis ___ écouter la cour.", "d'"),
        words=["J'ai", "appris", "à", "demander", "de", "l'aide", "."],
        anagram=("competence", "Ce qu'on a appris à faire. (sans accent)"),
        error=(
            "En osant le micro j'ai appris de respirer avant la phrase.",
            "En osant le micro j'ai appris à respirer avant la phrase.",
            "Apprendre à + infinitif.",
        ),
        pic_start=14,
        pic_words=["un pronom", "une horloge", "un stage", "un casque"],
        short_p="Transformez six échecs apparents en j'ai appris à / cela m'a permis de.",
        audio="Enregistrez la fiche et quatre valorisations.",
    ),
]


# ---------------------------------------------------------------------------
# Séquence 4 — Une journée de métier
# ---------------------------------------------------------------------------

S4 = [
    _l(
        "CO",
        "CO — Journée à l'atelier et à l'antenne",
        "Repérer le pronom où et distinguer gérondif et participe présent.",
        "Lisez le dialogue. Où ? En arrivant ou arrivant ?",
        "Atelier du Tissu / seuil de Radio Figuier",
        """Dieudonné : L'atelier où je couds ouvre à sept heures.
Léa : La radio où Lila parle est derrière le figuier.
Marc : En arrivant, je range les casques. Arrivant trop vite, je casse le silence.
Aline : Une personne arrivant sans saluer fatigue l'équipe.
Patrick : Le banc où Joël pose sa feuille reste libre le matin.
Joël : En écoutant, j'apprends. Écoutant seulement, je n'ose pas encore.
Hawa : Le jour où Félicie ouvre tôt, la table suffit.
Rose : En marchant vers la rive, on voit le lieu où l'on trie.
Karim : Le Bureau où Solange lit n'aime pas une personne criant.
Lila : En parlant, je respire. Parlant trop, je perds l'heure.
Félicie : La cour où l'on se retrouve ferme après le dernier seau.
Dieudonné : Une équipe travaillant calmement tient mieux qu'une équipe courant partout.""",
        tf_item=(
            "Marc oppose « en arrivant » (gérondif) et « arrivant trop vite » (participe).",
            True,
            "Marc : les deux formes, deux emplois.",
        ),
        qcm_item=(
            "Où Dieudonné coud-il ?",
            [
                "Au Bureau des Escales",
                "À l'atelier",
                "Dans un minibus",
                "Sous un pont de ville",
            ],
            1,
            "« L'atelier où je couds. »",
        ),
        pairs=[
            ("où", "lieu ou moment"),
            ("en arrivant", "gérondif"),
            ("arrivant trop vite", "participe / cause"),
            ("une personne arrivant", "qui arrive"),
        ],
        fill_item=("L'atelier ___ je couds ouvre à sept heures.", "où"),
        words=["En", "arrivant", "je", "range", "les", "casques", "."],
        anagram=("atelier", "Le lieu où Dieudonné coud les sacs de la rive."),
        error=(
            "L'atelier que je couds ouvre à sept heures.",
            "L'atelier où je couds ouvre à sept heures.",
            "Lieu : où, pas que.",
        ),
        pic_start=15,
        pic_words=["une horloge", "un stage", "un casque", "un atelier"],
        short_p="Notez trois où, deux gérondifs et deux participes présents.",
        audio="Enregistrez : L'atelier où je couds. En arrivant, je range. Une personne arrivant sans saluer.",
    ),
    _l(
        "CE",
        "CE — Fil d'une journée",
        "Lire le fil d'une journée avec où, gérondif et participe présent.",
        "Lisez le fil, sans aller trop vite.",
        "Fil de Dieudonné et de Léa",
        """7 h — l'atelier où Dieudonné allume, en arrivant, la lampe ocre.
7 h 20 — une personne arrivant trop tard range d'abord, parle ensuite.
8 h — le banc où Joël pose le cahier ; en écoutant, Patrick note.
9 h — la radio où Léa essaie le casque. Parlant trop vite, elle recommence.
10 h — le jour où Félicie ouvre la table, en portant deux cruches.
11 h — le lieu où l'on trie près de la rive. En marchant, on voit les sacs.
12 h — une équipe mangeant sous le figuier laisse de la place.
14 h — le Bureau où Solange lit, une page arrivant déjà tamponnée.
16 h — en fermant l'atelier, Dieudonné compte trois sacs tenus.
17 h — la cour où l'on se dit au revoir, sans courir.
18 h — Radio Figuier, l'heure où Lila coupe, écoutant la cour encore.
Règle : en + participe = gérondif ; participe seul = cause ou adjectif.""",
        tf_item=(
            "À 16 h, Dieudonné compte trois sacs en fermant l'atelier.",
            True,
            "« en fermant l'atelier, Dieudonné compte trois sacs. »",
        ),
        qcm_item=(
            "Que fait Léa à 9 h si elle parle trop vite ?",
            [
                "Elle ferme le Bureau",
                "Elle recommence",
                "Elle coud un sac",
                "Elle part à Val-des-Peupliers",
            ],
            1,
            "« Parlant trop vite, elle recommence. »",
        ),
        pairs=[
            ("l'atelier où", "Dieudonné"),
            ("la radio où", "Léa"),
            ("en arrivant", "gérondif"),
            ("parlant trop vite", "participe"),
        ],
        fill_item=("Le banc ___ Joël pose le cahier reste libre.", "où"),
        words=["En", "fermant", "l'atelier", "Dieudonné", "compte", "trois", "sacs", "."],
        anagram=("gérondif", "En + participe : en arrivant, en écoutant. Le nom de cette forme."),
        error=(
            "Le jour que Félicie ouvre la table on porte deux cruches.",
            "Le jour où Félicie ouvre la table on porte deux cruches.",
            "Moment : le jour où.",
        ),
        pic_start=16,
        pic_words=["un stage", "un casque", "un atelier", "un micro"],
        short_p="Recopiez six heures et indiquez où / en + participe / participe seul.",
        audio="Lisez le fil de la journée, sans aller trop vite.",
    ),
    _l(
        "PO",
        "PO — Où, en arrivant, arrivant",
        "Situer et relier : où ; gérondif versus participe présent.",
        "Répétez, puis racontez une heure de métier.",
        "Modèles de Lila",
        """C'est l'atelier où je couds.
C'est la radio où je parle.
C'est le jour où l'on ouvre tôt.
En arrivant, je salue.
En écoutant, j'apprends.
Arrivant trop vite, je casse le silence.
Une personne arrivant sans saluer fatigue.
En fermant, je compte.
Parlant trop, je perds l'heure.
Le lieu où l'on trie est près de la rive.
Le Bureau où Solange lit reste calme.
On avance en marchant, pas en criant.""",
        tf_item=(
            "« En arrivant » porte en ; « arrivant trop vite » n'en a pas.",
            True,
            "Gérondif vs participe.",
        ),
        qcm_item=(
            "Quelle phrase contient un gérondif ?",
            [
                "Arrivant trop vite je casse le silence",
                "En arrivant je salue",
                "Une personne arrivant sans saluer",
                "La radio où je parle",
            ],
            1,
            "En + participe.",
        ),
        pairs=[
            ("où", "lieu / moment"),
            ("en + participe", "gérondif"),
            ("participe seul", "cause ou adjectif"),
            ("une personne arrivant", "qui arrive"),
        ],
        fill_item=("___ écoutant j'apprends.", "En"),
        words=["C'est", "la", "radio", "où", "je", "parle", "."],
        anagram=("silence", "Arrivant trop vite Marc casse le… de l'antenne."),
        error=(
            "En arrivant trop vite je casse le silence de la radio où je parle trop.",
            "Arrivant trop vite je casse le silence de la radio où je parle trop.",
            "Cause : participe sans en, pas le gérondif ici.",
        ),
        pic_start=17,
        pic_words=["un casque", "un atelier", "un micro", "un bilan"],
        short_p="Écrivez six phrases : deux où, deux en + participe, deux participes seuls.",
        audio="Enregistrez les modèles, puis une heure à l'atelier ou à la radio.",
    ),
    _l(
        "PE",
        "PE — Ma journée de métier",
        "Écrire le fil d'une journée avec où, gérondif et participe présent.",
        "Imitez la journée de Félicie, sans aller trop vite.",
        "Journée de Félicie Ndayishimiye",
        """Félicie Ndayishimiye
La cour où je dresse la table ouvre tôt.
En arrivant, je pose deux cruches.
Une personne arrivant trop vite attend le banc.
Le jour où Joël aide, on range plus vite.
En écoutant Aline, je nuance les heures.
Parlant trop, je perds le fil : je recommence.
La table où l'on signe reste claire.
Félicie
Table des Sources
Seuil des Sources — Rukiri-Nord""",
        tf_item=(
            "Félicie pose deux cruches en arrivant.",
            True,
            "« En arrivant, je pose deux cruches. »",
        ),
        qcm_item=(
            "Que fait une personne arrivant trop vite ?",
            ["Elle coud", "Elle attend le banc", "Elle ferme le Bureau", "Elle filme"],
            1,
            "« attend le banc. »",
        ),
        pairs=[
            ("la cour où", "table"),
            ("en arrivant", "cruches"),
            ("une personne arrivant", "attend"),
            ("le jour où", "Joël"),
        ],
        fill_item=("La table ___ l'on signe reste claire.", "où"),
        words=["En", "écoutant", "Aline", "je", "nuance", "les", "heures", "."],
        anagram=("cruches", "Félicie en pose deux en arrivant à la table."),
        error=(
            "La cour que je dresse la table ouvre tôt.",
            "La cour où je dresse la table ouvre tôt.",
            "Lieu : où.",
        ),
        pic_start=18,
        pic_words=["un atelier", "un micro", "un bilan", "un cahier"],
        short_p="Imitez : dix lignes, trois où, deux gérondifs, un participe seul.",
        audio="Lisez votre journée, sans aller trop vite.",
    ),
    _l(
        "EL",
        "EL — Pronom où, gérondif, participe présent",
        "Retenir où et la différence en arrivant / arrivant / une personne arrivant.",
        "Apprenez la fiche.",
        "Fiche de Lila",
        """Où = lieu ou moment : l'atelier où je couds ; le jour où l'on ouvre.
On ne dit pas : l'atelier que je couds (lieu) ; le jour que Félicie ouvre (moment).
Gérondif : en + participe présent (en arrivant, en écoutant, en fermant).
Emploi du gérondif : simultanéité, moyen, condition légère.
Participe présent seul : cause (Arrivant trop vite, je casse le silence).
Participe adjectival : une personne arrivant / une équipe travaillant.
Le participe présent est invariable (arrivant, parlant, travaillant).
Ne pas mettre en si l'on veut une cause nette ou un adjectif.
Ne pas oublier en si l'on veut le gérondif de manière.
L'élision : l'atelier où l'on trie (l'on pour le son).
Même radical : arriver → arrivant ; écouter → écoutant ; fermer → fermant.
Parler → parlant (pas parlanté).""",
        tf_item=(
            "Le participe présent s'accorde comme un adjectif court.",
            False,
            "Il est invariable : arrivant.",
        ),
        qcm_item=(
            "« Une personne ___ sans saluer fatigue. »",
            ["en arrivant", "arrivant", "arrivée de", "où arrivant"],
            1,
            "Adjectival : une personne arrivant.",
        ),
        pairs=[
            ("où", "lieu / moment"),
            ("en arrivant", "gérondif"),
            ("arrivant trop vite", "cause"),
            ("une personne arrivant", "adjectif verbal"),
        ],
        fill_item=("C'est le jour ___ l'on ouvre tôt.", "où"),
        words=["Une", "personne", "arrivant", "sans", "saluer", "fatigue", "."],
        anagram=("invariable", "Le participe présent ne change pas : il est…"),
        error=(
            "En arrivants trop vite je casse le silence de l'antenne.",
            "En arrivant trop vite je casse le silence de l'antenne.",
            "Participe invariable : arrivant.",
        ),
        pic_start=19,
        pic_words=["un micro", "un bilan", "un cahier", "un tampon"],
        short_p="Transformez six phrases : où / en + p.p. / p.p. seul / personne + p.p.",
        audio="Enregistrez la fiche et six exemples.",
    ),
]


# ---------------------------------------------------------------------------
# Séquence 5 — Un stage à la radio
# ---------------------------------------------------------------------------

S5 = [
    _l(
        "CO",
        "CO — Premier jour à Radio Figuier",
        "Comprendre le premier jour de stage de Léa avec Lila et Marc.",
        "Lisez le dialogue. Qui fait quoi à l'antenne ?",
        "Studio de Radio Figuier, casques ocre",
        """Lila : Léa, le plateau où tu t'assieds reste assez calme.
Léa : En arrivant, j'ai posé le casque. J'ai appris à attendre le geste.
Marc : Je filme le geste, pas le visage trop près. Tu pourrais respirer.
Lila : Évitez de parler par-dessus l'invité, même Joël, même Patrick.
Léa : Cela m'a permis d'écouter la cour avant d'ouvrir le micro.
Marc : Le jour où l'on reçoit Solange, on prépare une question, pas dix.
Lila : Tout d'abord le son, ensuite la phrase, enfin le silence.
Léa : Par ailleurs, Dieudonné passera pour le sac de l'antenne.
Marc : De plus, Aline viendra écouter, sans corriger à voix haute.
Lila : Il vaudrait mieux une minute nette qu'un quart d'heure trop plein.
Léa : J'adhère, mais je nuance : j'ai encore peur du silence.
Marc : En osant ce silence, tu tiens mieux qu'en parlant trop.""",
        tf_item=(
            "Lila demande d'éviter de parler par-dessus l'invité.",
            True,
            "Lila : « Évitez de parler par-dessus l'invité. »",
        ),
        qcm_item=(
            "Que prépare-t-on le jour où Solange vient ?",
            [
                "Dix questions",
                "Une question",
                "Un discours de vingt pages",
                "Une cravate pour Marc",
            ],
            1,
            "Marc : « une question, pas dix. »",
        ),
        pairs=[
            ("plateau où", "Léa"),
            ("en arrivant", "casque"),
            ("évitez de parler", "par-dessus"),
            ("une minute nette", "plutôt qu'un quart d'heure"),
        ],
        fill_item=("Le plateau ___ tu t'assieds reste assez calme.", "où"),
        words=["En", "arrivant", "j'ai", "posé", "le", "casque", "."],
        anagram=("casque", "Léa le pose en arrivant au plateau de Radio Figuier."),
        error=(
            "Évitez de parler par-dessus l'invité même Joël trop vites.",
            "Évitez de parler par-dessus l'invité même Joël trop vite.",
            "Trop vite, invariable.",
        ),
        pic_start=20,
        pic_words=["un bilan", "un cahier", "un tampon", "une table"],
        short_p="Notez les rôles de Léa, Lila et Marc au premier jour.",
        audio="Enregistrez : Le plateau où tu t'assieds. En arrivant j'ai posé le casque. Une minute nette.",
    ),
    _l(
        "CE",
        "CE — Carnet de stage de Léa",
        "Lire le carnet de stage à Radio Figuier.",
        "Lisez le carnet, sans aller trop vite.",
        "Carnet de Léa Niyonzima",
        """Stage — Radio Figuier, semaine 0 (préparation)
Lila Sow m'accueille au plateau où l'on teste le son.
Marc Nkurunziza filme en restant sur le geste, pas sur le visage.
En arrivant, je pose le casque ; arrivant trop vite, je refais le silence.
J'ai osé une minute : j'ai appris à respirer ; cela m'a permis d'écouter.
Tout d'abord le son. En effet, sans son net, la phrase tombe.
Par ailleurs, Dieudonné apporte un sac pour les nappes du micro.
De plus, Aline note sans m'interrompre.
Enfin, Lila coupe : assez d'une minute, pas trop de discours.
Le jour où Solange passe, une question suffit.
Évitez de parler par-dessus. Vous devriez remercier l'invité.
Il vaudrait mieux un silence tenu qu'une phrase trop longue.""",
        tf_item=(
            "Léa a osé une minute et a appris à respirer.",
            True,
            "« J'ai osé une minute : j'ai appris à respirer. »",
        ),
        qcm_item=(
            "Qui filme le geste, d'après le carnet ?",
            ["Aline", "Marc", "Solange", "Félicie"],
            1,
            "« Marc Nkurunziza filme. »",
        ),
        pairs=[
            ("Lila", "accueille"),
            ("Marc", "filme"),
            ("Dieudonné", "sac du micro"),
            ("Aline", "note sans interrompre"),
        ],
        fill_item=("Assez d'une minute, pas trop de ___.", "discours"),
        words=["Lila", "m'accueille", "au", "plateau", "où", "l'on", "teste", "le", "son", "."],
        anagram=("plateau", "Le lieu où Léa s'assied pour tester le son."),
        error=(
            "En arrivant je pose le casque arrivant trop vite je refais le silences.",
            "En arrivant je pose le casque arrivant trop vite je refais le silence.",
            "Silence au singulier.",
        ),
        pic_start=21,
        pic_words=["un cahier", "un tampon", "une table", "un tissu"],
        short_p="Recopiez le carnet et soulignez où, gérondif, articulateurs et conseils.",
        audio="Lisez le carnet de Léa, sans aller trop vite.",
    ),
    _l(
        "PO",
        "PO — Dire le plateau",
        "Parler du stage à Radio Figuier : rôles, où, gérondif, conseils.",
        "Répétez, puis présentez le plateau à un voisin.",
        "Modèles de Marc",
        """C'est le plateau où Léa s'assied.
En arrivant, elle pose le casque.
Lila accueille.
Je filme le geste.
Évitez de parler par-dessus.
Vous devriez remercier.
Il vaudrait mieux une minute nette.
J'ai appris à attendre.
Cela m'a permis d'écouter.
Le jour où Solange passe, une question.
Assez d'une minute.
Pas trop de discours.""",
        tf_item=(
            "Marc filme le geste, pas le visage trop près.",
            True,
            "Modèle : je filme le geste.",
        ),
        qcm_item=(
            "Quelle durée Lila préfère-t-elle ?",
            [
                "Un quart d'heure trop plein",
                "Une minute nette",
                "Vingt pages lues",
                "Toute la nuit",
            ],
            1,
            "Une minute nette.",
        ),
        pairs=[
            ("plateau où", "Léa"),
            ("en arrivant", "casque"),
            ("Lila", "accueille"),
            ("Marc", "filme"),
        ],
        fill_item=("Il vaudrait mieux une ___ nette.", "minute"),
        words=["Évitez", "de", "parler", "par-dessus", "."],
        anagram=("invité", "On évite de parler par-dessus l'… au micro."),
        error=(
            "C'est le plateau que Léa s'assied le matin.",
            "C'est le plateau où Léa s'assied le matin.",
            "S'asseoir à un lieu → où.",
        ),
        pic_start=22,
        pic_words=["un tampon", "une table", "un tissu", "une antenne"],
        short_p="Écrivez six phrases de plateau : où, gérondif, un conseil, un rôle.",
        audio="Enregistrez les modèles, puis une visite guidée du plateau.",
    ),
    _l(
        "PE",
        "PE — Mon carnet de radio",
        "Écrire un carnet de stage à Radio Figuier.",
        "Imitez le carnet de Marc, sans aller trop vite.",
        "Carnet de Marc Nkurunziza",
        """Marc Nkurunziza
Le plateau où Léa s'assied reste assez calme.
En arrivant, je filme le geste, pas le visage trop près.
Lila accueille ; j'ai appris à attendre son signe.
Cela m'a permis d'écouter la cour avant d'ouvrir.
Évitez de parler par-dessus l'invité.
Il vaudrait mieux une minute nette.
Le jour où Solange passe, une question suffit.
Marc
Radio Figuier
Seuil des Sources — Rukiri-Nord""",
        tf_item=(
            "Marc a appris à attendre le signe de Lila.",
            True,
            "« j'ai appris à attendre son signe. »",
        ),
        qcm_item=(
            "Que filme Marc ?",
            ["Le visage trop près", "Le geste", "La rivière seulement", "Le Bureau fermé"],
            1,
            "« je filme le geste. »",
        ),
        pairs=[
            ("plateau où", "Léa"),
            ("en arrivant", "filmer"),
            ("appris à attendre", "signe"),
            ("une minute nette", "durée"),
        ],
        fill_item=("Évitez de parler par-dessus l'___.", "invité"),
        words=["Il", "vaudrait", "mieux", "une", "minute", "nette", "."],
        anagram=("antenne", "Radio Figuier : Lila tient l'… , Léa essaie le casque."),
        error=(
            "En arrivant je filme le geste pas le visage trop près trop pres.",
            "En arrivant je filme le geste pas le visage trop près trop près.",
            "Près, avec accent.",
        ),
        pic_start=23,
        pic_words=["une table", "un tissu", "une antenne", "une poignée"],
        short_p="Imitez : un carnet de dix lignes, Léa / Lila / Marc, un où, un gérondif.",
        audio="Lisez votre carnet, sans aller trop vite.",
    ),
    _l(
        "EL",
        "EL — Lexique et formes du plateau",
        "Retenir le lexique de Radio Figuier et les formes déjà vues.",
        "Apprenez la fiche.",
        "Fiche de l'antenne",
        """Lieux : plateau, antenne, Radio Figuier, cour, figuier (pas une radio réelle).
Personnes : Léa (stage), Lila (antenne), Marc (geste filmé), Aline (écoute),
Solange (invitée possible), Dieudonné (sac du micro).
Où : le plateau où, le jour où, la radio où.
Gérondif : en arrivant, en restant, en osant.
Participe : arrivant trop vite, parlant trop.
Conseils : vous devriez, il vaudrait mieux, évitez de / d'.
Valoriser : j'ai appris à, cela m'a permis de / d'.
Articulateurs utiles à l'antenne : tout d'abord, en effet, enfin.
Durée : assez d'une minute, pas trop de discours, un silence tenu.
Ne pas parler par-dessus l'invité.
Ne pas inventer une enseigne d'antenne hors du Seuil.""",
        tf_item=(
            "Radio Figuier est une antenne inventée du Seuil.",
            True,
            "Pas une radio réelle.",
        ),
        qcm_item=(
            "Qui accueille Léa au plateau ?",
            ["Félicie", "Lila", "Karim", "Un guide de ville"],
            1,
            "Lila Sow, antenne.",
        ),
        pairs=[
            ("Léa", "stage"),
            ("Lila", "antenne"),
            ("Marc", "geste"),
            ("plateau où", "lieu"),
        ],
        fill_item=("Assez d'une minute, pas trop de ___.", "discours"),
        words=["Le", "jour", "où", "Solange", "passe", "une", "question", "suffit", "."],
        anagram=("silence", "Il vaudrait mieux un… tenu qu'une phrase trop longue."),
        error=(
            "Le plateau que Léa s'assied reste assez calme.",
            "Le plateau où Léa s'assied reste assez calme.",
            "Lieu : où.",
        ),
        pic_start=24,
        pic_words=["un tissu", "une antenne", "une poignée", "une étoile"],
        short_p="Faites un glossaire de dix mots du plateau, avec une phrase chacun.",
        audio="Enregistrez la fiche et une présentation de l'antenne.",
    ),
]


# ---------------------------------------------------------------------------
# Séquence 6 — Bilan de la première semaine
# ---------------------------------------------------------------------------

S6 = [
    _l(
        "CO",
        "CO — Bilan sous le figuier",
        "Comprendre une synthèse de parcours avec gérondif.",
        "Lisez le bilan. Qui synthétise quoi ?",
        "Table des Sources, fin de la première semaine",
        """Aline : En faisant le bilan, on garde les preuves, pas les discours trop longs.
Patrick : En relisant ma lettre, j'ai vu ce que j'ai appris à classer.
Joël : En osant l'atelier, cela m'a permis de tenir trois matins.
Léa : En arrivant chaque jour, j'ai appris à attendre le signe de Lila.
Marc : En filmant le geste, j'ai moins parlé par-dessus.
Dieudonné : En recousant, j'ai sauvé deux sacs.
Hawa : En mesurant l'eau, on a mis de moins en moins de cruches.
Rose : En signant tôt, j'ai relayé sans crier.
Lila : En coupant à une minute, l'antenne reste nette.
Karim : En portant une page, le Bureau a lu plus vite.
Félicie : En ouvrant tôt, la table a suffi.
Solange : En lisant vos noms, je vois un parcours, pas une liste vide.""",
        tf_item=(
            "Joël a tenu trois matins en osant l'atelier.",
            True,
            "Joël : « cela m'a permis de tenir trois matins. »",
        ),
        qcm_item=(
            "Que garde-t-on en faisant le bilan, d'après Aline ?",
            [
                "Les discours trop longs",
                "Les preuves",
                "Les cravates",
                "Les villes réelles",
            ],
            1,
            "« on garde les preuves. »",
        ),
        pairs=[
            ("en faisant le bilan", "preuves"),
            ("en relisant", "Patrick"),
            ("en arrivant", "Léa"),
            ("en recousant", "Dieudonné"),
        ],
        fill_item=("___ faisant le bilan on garde les preuves.", "En"),
        words=["En", "filmant", "le", "geste", "j'ai", "moins", "parlé", "."],
        anagram=("bilan", "Synthèse de la première semaine, sous le figuier."),
        error=(
            "En faisant le bilan on garde les preuves pas les discours trop longue.",
            "En faisant le bilan on garde les preuves pas les discours trop longs.",
            "Discours trop longs, masculin pluriel.",
        ),
        pic_start=25,
        pic_words=["une antenne", "une poignée", "une étoile", "un calendrier"],
        short_p="Notez six gérondifs du bilan et l'apport de chacun.",
        audio="Enregistrez : En faisant le bilan. En osant l'atelier. En arrivant chaque jour.",
    ),
    _l(
        "CE",
        "CE — Synthèse de la semaine",
        "Lire une synthèse écrite de parcours, tissée de gérondifs.",
        "Lisez la synthèse, sans aller trop vite.",
        "Page collective, Cahier des racines",
        """Bilan — première semaine au Seuil
En disant nos parcours, Patrick et Joël ont tenu une page chacun.
En préparant l'entretien, Aline a répété : vous devriez, évitez de, il vaudrait mieux.
En osant un geste, chacun a pu dire : j'ai appris à, cela m'a permis de.
En racontant une journée, on a placé où, en arrivant, une personne arrivant.
En tenant le plateau, Léa, Lila et Marc ont gardé une minute nette.
Preuves : 3 matins d'atelier, 5 silences tenus, 2 sacs sauvés, 1 page au Bureau.
En mesurant, on voit de plus en plus de calme, de moins en moins de précipitation.
Dans l'attente de la deuxième semaine, nous vous prions de lire cette page.
En restant locaux, on n'invente ni ville ni enseigne.
Dieudonné : en recousant, on répare plus qu'on jette.
Félicie : en ouvrant tôt, la table suffit.
Solange : en tamponnant, le Bureau reconnaît un essai, pas une fin.""",
        tf_item=(
            "La synthèse refuse d'inventer une ville ou une enseigne.",
            True,
            "« on n'invente ni ville ni enseigne. »",
        ),
        qcm_item=(
            "Combien de silences tenus la page compte-t-elle ?",
            ["3", "5", "2", "1"],
            1,
            "« 5 silences tenus. »",
        ),
        pairs=[
            ("en disant nos parcours", "Patrick et Joël"),
            ("en préparant", "Aline"),
            ("en tenant le plateau", "Léa Lila Marc"),
            ("en recousant", "Dieudonné"),
        ],
        fill_item=("En mesurant on voit de plus en plus de ___.", "calme"),
        words=["En", "restant", "locaux", "on", "n'invente", "ni", "ville", "ni", "enseigne", "."],
        anagram=("synthese", "Page qui rassemble le parcours de la semaine. (sans accent)"),
        error=(
            "En disant nos parcours Patrick et Joël ont tenu une pages chacun.",
            "En disant nos parcours Patrick et Joël ont tenu une page chacun.",
            "Une page, singulier.",
        ),
        pic_start=26,
        pic_words=["une poignée", "une étoile", "un calendrier", "une ouverture"],
        short_p="Recopiez la synthèse et encadrez tous les gérondifs.",
        audio="Lisez la synthèse, sans aller trop vite.",
    ),
    _l(
        "PO",
        "PO — Synthétiser en + participe",
        "Faire le bilan à voix haute avec des gérondifs en chaîne.",
        "Répétez, puis dites votre semaine en six gérondifs.",
        "Modèles d'Aline",
        """En faisant le bilan, on garde les preuves.
En relisant, je classe.
En osant, j'apprends.
En arrivant, j'attends le signe.
En filmant, je parle moins.
En recousant, je répare.
En mesurant, je nuance.
En signant, je relais.
En coupant, je tiens l'heure.
En portant une page, je convaincs.
En ouvrant tôt, la table suffit.
En restant local, je reste juste.""",
        tf_item=(
            "Le gérondif permet d'enchaîner le bilan sans tout re-raconter.",
            True,
            "En + participe : synthèse.",
        ),
        qcm_item=(
            "Quelle phrase est un gérondif de bilan ?",
            [
                "J'ai un bilan",
                "En osant j'apprends",
                "Ose maintenant",
                "Le bilan est fini",
            ],
            1,
            "En osant.",
        ),
        pairs=[
            ("en relisant", "classer"),
            ("en osant", "apprendre"),
            ("en filmant", "moins parler"),
            ("en recousant", "réparer"),
        ],
        fill_item=("En ___ tôt la table suffit. (ouvrir)", "ouvrant"),
        words=["En", "faisant", "le", "bilan", "on", "garde", "les", "preuves", "."],
        anagram=("preuves", "On les garde en faisant le bilan, pas les longs discours."),
        error=(
            "En faisant le bilan on garde les preuves en restants locaux.",
            "En faisant le bilan on garde les preuves en restant locaux.",
            "Restant, invariable.",
        ),
        pic_start=27,
        pic_words=["une étoile", "un calendrier", "une ouverture", "une lettre"],
        short_p="Écrivez six gérondifs de bilan, un par jour inventé de la semaine.",
        audio="Enregistrez les modèles, puis votre semaine en six gérondifs.",
    ),
    _l(
        "PE",
        "PE — Mon bilan de semaine",
        "Écrire une synthèse de parcours avec gérondifs.",
        "Imitez le bilan de Patrick, sans aller trop vite.",
        "Bilan de Patrick Habimana",
        """Patrick Habimana
En disant mon parcours, j'ai tenu une page.
En préparant l'entretien, j'ai appris à écouter jusqu'au bout.
En osant la lettre, cela m'a permis de classer.
En arrivant à l'atelier avec Joël, j'ai vu le lieu où l'on coud.
En écoutant Léa à Radio Figuier, j'ai compris une minute nette.
En faisant ce bilan, je garde les preuves, pas trop de discours.
Dans l'attente de la suite, je vous prie de lire cette page.
Patrick
Seuil des Sources — Rukiri-Nord
Cahier des racines""",
        tf_item=(
            "Patrick a tenu une page en disant son parcours.",
            True,
            "Première ligne du bilan.",
        ),
        qcm_item=(
            "Où Patrick est-il arrivé avec Joël ?",
            ["Au minibus d'une ville", "À l'atelier", "Au lac seulement", "Chez une enseigne réelle"],
            1,
            "« le lieu où l'on coud. »",
        ),
        pairs=[
            ("en disant", "une page"),
            ("en préparant", "écouter"),
            ("en osant", "classer"),
            ("en faisant ce bilan", "preuves"),
        ],
        fill_item=("En faisant ce bilan je garde les ___.", "preuves"),
        words=["En", "osant", "la", "lettre", "cela", "m'a", "permis", "de", "classer", "."],
        anagram=("semaine", "Première… : le temps du bilan, sept jours au Seuil."),
        error=(
            "En faisant ce bilan je garde les preuves pas trop de discour.",
            "En faisant ce bilan je garde les preuves pas trop de discours.",
            "Discours, avec s.",
        ),
        pic_start=28,
        pic_words=["un calendrier", "une ouverture", "une lettre", "un articulateur"],
        short_p="Imitez : un bilan de dix lignes, six gérondifs, une phrase d'attente.",
        audio="Lisez votre bilan, sans aller trop vite.",
    ),
    _l(
        "EL",
        "EL — Synthèse : parcours et gérondif",
        "Relier le parcours de la semaine et le gérondif de synthèse.",
        "Apprenez la fiche.",
        "Fiche de clôture",
        """Bilan = preuves + gérondifs + une attente, pas un nouveau discours.
En + participe : en disant, en préparant, en osant, en arrivant, en filmant,
en recousant, en mesurant, en faisant le bilan, en restant locaux.
Le gérondif relie le parcours sans tout re-raconter : simultanéité et moyen.
On reprend : j'ai appris à / cela m'a permis de, à l'intérieur du bilan.
Où reste utile : le lieu où l'on coud, le plateau où Léa s'assied.
Clôture : dans l'attente de… ; je vous prie de lire cette page.
Preuves inventées : 3 matins, 5 silences, 2 sacs, 1 page.
Ne pas accorder le participe du gérondif (en restant, pas en restants).
Ne pas remplacer où par que pour un lieu ou un moment.
Ne pas inventer une ville ou une enseigne hors du Seuil.
Ordre possible : faits en gérondif → preuves chiffrées → attente.""",
        tf_item=(
            "Le gérondif du bilan s'accorde au pluriel : en restants.",
            False,
            "Invariable : en restant.",
        ),
        qcm_item=(
            "Quelle clôture convient au bilan ?",
            [
                "Criez la suite",
                "Dans l'attente de la suite je vous prie de lire",
                "Inventez une ville",
                "Effacez les preuves",
            ],
            1,
            "Attente + je vous prie.",
        ),
        pairs=[
            ("en disant", "parcours"),
            ("en osant", "apprentissage"),
            ("en faisant le bilan", "preuves"),
            ("dans l'attente de", "suite"),
        ],
        fill_item=("En ___ locaux on reste juste. (rester)", "restant"),
        words=["En", "faisant", "le", "bilan", "on", "garde", "les", "preuves", "."],
        anagram=("locaux", "En restant… : on n'invente ni ville ni enseigne."),
        error=(
            "En restants locaux on n'invente ni ville ni enseigne.",
            "En restant locaux on n'invente ni ville ni enseigne.",
            "Gérondif invariable : restant.",
        ),
        pic_start=29,
        pic_words=["une ouverture", "une lettre", "un articulateur", "un parcours"],
        short_p="Rédigez une fiche bilan : six gérondifs, trois preuves, une clôture.",
        audio="Enregistrez la fiche et votre synthèse en six gérondifs.",
    ),
]


SEQUENCES = [
    {"title": "Dire son parcours", "lessons": S1},
    {"title": "Se préparer à l'entretien", "lessons": S2},
    {"title": "Oser une expérience", "lessons": S3},
    {"title": "Une journée de métier", "lessons": S4},
    {"title": "Un stage à la radio", "lessons": S5},
    {"title": "Bilan de la première semaine", "lessons": S6},
]
