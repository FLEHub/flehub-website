"""B1 Module 1 — Ailleurs, un nouveau chez-soi (univers Seuil des Sources)."""

from factory import L

IMG = "mfk-b1-m1"
IMG_DIR = IMG

MODULE = {
    "title": "B1 — Ailleurs, un nouveau chez-soi",
    "description": (
        "Grande étape B1-1 : choisir un lieu de vie, formuler un souhait, "
        "caractériser un quartier, raconter des souvenirs d'arrivée, "
        "comparer deux rives et écrire à ceux qui restent — Léa et Patrick "
        "envisagent de s'installer à Rive-des-Saules (Val-des-Peupliers), "
        "Aline les accompagne, le Pavillon du Saule ouvre ses clés, et les "
        "lettres reviennent vers le figuier du Seuil des Sources (Rukiri-Nord)."
    ),
}


def _l(comp, title, obj, cons, st, sp, **kw):
    return L(IMG, comp, title, obj, cons, st, sp, **kw)


# ---------------------------------------------------------------------------
# Séquence 1 — Choisir un lieu de vie (verbes prépositionnels, mise en garde)
# ---------------------------------------------------------------------------

S1 = [
    _l(
        "CO",
        "CO — Songer à l'autre rive",
        "Repérer les verbes prépositionnels d'expatriation et les mises en garde.",
        "Lisez le dialogue (à écouter avec l'enseignant). Qui s'installe où, et de quoi Aline met-elle en garde ?",
        "Table des Sources, cartes ocre",
        """Aline : Vous songez à vous installer où, exactement, après l'escale ?
Léa : Je songe à Rive-des-Saules, un quartier de Val-des-Peupliers.
Patrick : Moi, je rêve d'un étage au Pavillon du Saule, près du pont.
Marc : Attention : s'installer à une ville n'est pas s'installer dans un quartier.
Hawa : Il faudra s'habituer au rythme du minibus Figuier 7, même là-bas.
Joël : Et s'adapter aux voisins : Noura, Ibrahim et Mado passent souvent.
Rose : Je vous mets en garde : ne dépendez pas trop d'un seul ami pour le loyer.
Solange : Comptez sur le Bureau des Escales pour les clés, pas sur le hasard.
Karim : Si vous vous éloignez du Seuil, tenez tout de même à vos habitudes du figuier.
Lila : Radio Figuier relayera vos nouvelles, si vous tenez à rester liés.
Yvette : Le jardin du saule est calme, mais le loyer dépend du nombre de chambres.
Aline : Notez : s'installer à / dans, s'habituer à, s'adapter à, dépendre de, rêver de, tenir à, songer à, s'éloigner de, compter sur.""",
        tf_item=(
            "Rose met Léa et Patrick en garde contre une trop grande dépendance à un seul ami.",
            True,
            "Rose : « ne dépendez pas trop d'un seul ami pour le loyer. »",
        ),
        qcm_item=(
            "Selon Marc, quelle distinction faut-il faire ?",
            [
                "S'habituer et s'adapter sont interdits",
                "S'installer à une ville n'est pas s'installer dans un quartier",
                "Le loyer ne dépend de rien",
                "Radio Figuier refuse les nouvelles",
            ],
            1,
            "Marc oppose la ville et le quartier.",
        ),
        pairs=[
            ("s'installer dans", "un quartier"),
            ("dépendre de", "un ami / le loyer"),
            ("compter sur", "le Bureau des Escales"),
            ("s'éloigner de", "le Seuil"),
        ],
        fill_item=("Je songe ___ Rive-des-Saules.", "à"),
        words=["Je", "rêve", "d'un", "étage", "au", "Pavillon", "."],
        anagram=("installer", "Poser ses bagages pour longtemps, à une ville ou dans un quartier."),
        error=(
            "Léa s'installe à le Pavillon du Saule, et elle compte sur Aline.",
            "Léa s'installe au Pavillon du Saule, et elle compte sur Aline.",
            "À + le = au, devant Pavillon.",
        ),
        pic_start=0,
        pic_words=["des critères", "une carte", "une valise", "une clé"],
        short_p="Notez cinq verbes prépositionnels entendus et leur complément (à / de / dans / sur).",
        audio="Enregistrez : Je songe à Rive-des-Saules. Je m'installe au pavillon. Je compte sur Aline. Je tiens au figuier.",
    ),
    _l(
        "CE",
        "CE — Critères et mises en garde",
        "Lire une fiche de critères et des mises en garde pour un nouveau chez-soi.",
        "Lisez la fiche épinglée au figuier, sans aller trop vite.",
        "Fiche d'Aline Uwase, Salle des Herbes",
        """Fiche — Choisir un lieu de vie (Rive-des-Saules / Seuil)
1. S'installer à Val-des-Peupliers : la ville inventée, le tampon, le minibus.
2. S'installer dans le quartier Rive-des-Saules : rues, pont, Pavillon du Saule.
3. S'habituer au silence différent : ici le figuier, là-bas le saule et l'eau.
4. S'adapter aux voisins (Noura, Ibrahim, Félicie) sans tout changer de soi.
5. Le loyer dépend du nombre de chambres ; ne dépendez pas d'un seul salaire.
6. Rêver d'un étage calme est légitime ; songer à partir n'est pas trahir.
7. Tenir à ses habitudes du Seuil : le thé, la radio, le banc ocre.
8. S'éloigner de Rukiri-Nord demande du courage ; compter sur Solange aide.
Mise en garde de Rose : n'idéalisez pas ailleurs. Mise en garde de Marc : lisez le règlement.
Karim Bamba : les clés se retirent au Bureau des Escales, jamais sous une pierre.
Lila Sow : si vous tenez à rester liés, envoyez un mot chaque jeudi.
Aline : un critère n'est pas un caprice ; une mise en garde n'est pas un refus.""",
        tf_item=(
            "Karim dit qu'on peut laisser les clés sous une pierre.",
            False,
            "Karim : les clés se retirent au bureau, jamais sous une pierre.",
        ),
        qcm_item=(
            "Qui demande d'envoyer un mot chaque jeudi ?",
            ["Rose", "Marc", "Lila Sow", "Félicie"],
            2,
            "Lila : « envoyez un mot chaque jeudi. »",
        ),
        pairs=[
            ("s'habituer à", "un silence différent"),
            ("dépendre de", "le nombre de chambres"),
            ("tenir à", "les habitudes du Seuil"),
            ("compter sur", "Solange"),
        ],
        fill_item=("Le loyer dépend ___ nombre de chambres.", "du"),
        words=["S'installer", "dans", "le", "quartier", "demande", "du", "courage", "."],
        anagram=("habituer", "Rendre normal un nouveau rythme, un autre silence."),
        error=(
            "Il fautons s'habituer au minibus, même si le jardin reste calme.",
            "Il faut s'habituer au minibus, même si le jardin reste calme.",
            "Toujours il faut, à la 3e personne.",
        ),
        pic_start=1,
        pic_words=["une carte", "une valise", "une clé", "un verbe"],
        short_p="Recopiez quatre critères et deux mises en garde, puis ajoutez le vôtre.",
        audio="Lisez les douze lignes de la fiche, sans aller trop vite.",
    ),
    _l(
        "PO",
        "PO — Dire s'installer, s'adapter, tenir à",
        "Employer à l'oral les verbes prépositionnels d'un choix de vie.",
        "Répétez les modèles, puis parlez d'un lieu où vous songeriez à vous installer.",
        "Modèles d'Aline, banc du Seuil",
        """Je m'installe à Val-des-Peupliers.
Je m'installe dans le quartier Rive-des-Saules.
Je m'habitue au bruit du pont.
Je m'adapte aux voisins du Pavillon du Saule.
Le loyer dépend du jardin, pas seulement des murs.
Je rêve d'un étage qui donne sur l'eau.
Je tiens à mes jeudis sous le figuier.
Je songe à partir sans tout quitter.
Je m'éloigne de Rukiri-Nord, mais je compte sur vous.
Aline nous met en garde : ailleurs n'efface pas ici.
Patrick : Je dépends encore du minibus Figuier 7.
Léa : Je tiens à écrire, même si je m'éloigne.""",
        tf_item=(
            "« Dépendre » se construit avec de, pas avec à.",
            True,
            "Dépendre de quelqu'un / de quelque chose.",
        ),
        qcm_item=(
            "Quelle phrase est correcte ?",
            [
                "Je m'habitue de le pont",
                "Je tiens de mes jeudis",
                "Je m'installe dans le quartier",
                "Je compte à Solange",
            ],
            2,
            "S'installer dans + quartier.",
        ),
        pairs=[
            ("s'habituer à", "un bruit / un rythme"),
            ("s'adapter à", "des voisins"),
            ("rêver de", "un étage"),
            ("mettre en garde", "Aline"),
        ],
        fill_item=("Je tiens ___ mes jeudis sous le figuier.", "à"),
        words=["Je", "compte", "sur", "vous", "même", "loin", "."],
        anagram=("dependre", "Avoir besoin de quelqu'un ou d'un loyer pour tenir. (sans accent)"),
        error=(
            "Je dépends à Aline pour les clés, et je tiens au figuier.",
            "Je dépends d'Aline pour les clés, et je tiens au figuier.",
            "Dépendre de, pas dépendre à.",
        ),
        pic_start=2,
        pic_words=["une valise", "une clé", "un verbe", "une lettre"],
        short_p="Écrivez huit phrases : un verbe prépositionnel différent dans chacune.",
        audio="Enregistrez les six premiers modèles, puis deux phrases à vous.",
    ),
    _l(
        "PE",
        "PE — Ma mise en garde",
        "Écrire une courte mise en garde et un choix de lieu avec des verbes prépositionnels.",
        "Imitez la note de Léa Niyonzima.",
        "Note de Léa, enveloppe ocre",
        """Léa Niyonzima — Seuil des Sources, Rukiri-Nord
Je songe à m'installer dans le quartier Rive-des-Saules.
Je m'installerai à Val-des-Peupliers, au Pavillon du Saule, si Karim accepte.
Je tiens à nos jeudis ; je ne m'éloignerai pas de vous dans mon cœur.
Je compte sur Aline et sur Solange pour les papiers.
Je vous mets en garde : ne rêvez pas d'un ailleurs sans loyer, sans voisins, sans règles.
Le calme dépend du pont autant que du jardin.
Je m'habituerai à l'eau ; Patrick s'adaptera au silence différent.
Noura et Ibrahim pourront nous aider, mais nous ne dépendrons pas d'eux seuls.
Je rêve d'un étage simple, pas d'un palais.
À bientôt sous le figuier, même si la valise part.
Léa""",
        tf_item=(
            "Léa dit qu'elle dépendra seulement de Noura et d'Ibrahim.",
            False,
            "« nous ne dépendrons pas d'eux seuls. »",
        ),
        qcm_item=(
            "Que met Léa en garde de ne pas faire ?",
            [
                "Écrire à Aline",
                "Rêver d'un ailleurs sans loyer ni règles",
                "Prendre le minibus",
                "Saluer Karim",
            ],
            1,
            "Elle met en garde contre un ailleurs idéalisé.",
        ),
        pairs=[
            ("songer à", "s'installer"),
            ("tenir à", "les jeudis"),
            ("mettre en garde", "un ailleurs sans règles"),
            ("s'habituer à", "l'eau"),
        ],
        fill_item=("Je compte ___ Aline et sur Solange.", "sur"),
        words=["Je", "ne", "m'éloignerai", "pas", "de", "vous", "."],
        anagram=("eloigner", "Partir plus loin de la cour, sans couper le lien. (sans accent)"),
        error=(
            "Ne vous éloignez pas à vos amis, et comptez sur Rose.",
            "Ne vous éloignez pas de vos amis, et comptez sur Rose.",
            "S'éloigner de, pas s'éloigner à.",
        ),
        pic_start=3,
        pic_words=["une clé", "un verbe", "une lettre", "un souhait"],
        short_p="Imitez : dix lignes, cinq verbes prépositionnels, une mise en garde.",
        audio="Lisez votre note, une phrase, une pause, sans aller trop vite.",
    ),
    _l(
        "EL",
        "EL — Verbes prépositionnels d'expatriation",
        "Retenir la préposition fixe de chaque verbe et la mise en garde.",
        "Apprenez la fiche.",
        "Fiche du carnet d'Aline",
        """s'installer à + ville : s'installer à Val-des-Peupliers
s'installer dans + quartier / bâtiment : s'installer dans Rive-des-Saules / au pavillon (à + le)
s'habituer à + nom / infinitif : s'habituer au silence, s'habituer à marcher
s'adapter à : s'adapter aux voisins, à un règlement
dépendre de : le loyer dépend du jardin ; je dépends de vous (pas dépendre à)
rêver de : rêver d'un étage, rêver de rester
tenir à : tenir à une habitude, tenir à écrire (cela compte beaucoup)
songer à : songer à partir, songer à un étage (y penser longtemps)
s'éloigner de : s'éloigner du Seuil, de ses amis
compter sur : compter sur Solange, sur le minibus
Mettre en garde (contre un danger) : Aline nous met en garde.
Attention : à + le = au ; de + le = du. Bien que + subjonctif : bien que ce soit loin.""",
        tf_item=(
            "On dit « je dépends à mes amis ».",
            False,
            "Dépendre de, jamais dépendre à.",
        ),
        qcm_item=(
            "« Tenir à écrire » signifie surtout…",
            [
                "refuser d'écrire",
                "trouver l'écriture importante",
                "dépendre du papier",
                "s'éloigner de la lettre",
            ],
            1,
            "Tenir à = accorder de l'importance.",
        ),
        pairs=[
            ("s'habituer à", "un nouveau rythme"),
            ("dépendre de", "un loyer / une personne"),
            ("songer à", "un départ possible"),
            ("compter sur", "une aide fiable"),
        ],
        fill_item=("On s'adapte ___ un règlement.", "à"),
        words=["Aline", "nous", "met", "en", "garde", "."],
        anagram=("adapter", "Changer un peu ses habitudes pour coller au lieu nouveau."),
        error=(
            "On s'habitue de un nouveau rythme, et on s'adapte au quartier.",
            "On s'habitue à un nouveau rythme, et on s'adapte au quartier.",
            "S'habituer à, pas s'habituer de.",
        ),
        pic_start=4,
        pic_words=["un verbe", "une lettre", "un souhait", "une demande"],
        short_p="Construisez neuf phrases, une par verbe de la fiche, avec la bonne préposition.",
        audio="Enregistrez la fiche, puis trois mises en garde à vous.",
    ),
]


# ---------------------------------------------------------------------------
# Séquence 2 — Formuler un souhait (conditionnel présent, demande polie)
# ---------------------------------------------------------------------------

S2 = [
    _l(
        "CO",
        "CO — Pourriez-vous ouvrir le pavillon ?",
        "Comprendre des souhaits et des demandes polies au conditionnel présent.",
        "Lisez le dialogue. Qui souhaite quoi, et qui formule une demande polie ?",
        "Seuil du Pavillon du Saule",
        """Karim : Vous voudriez visiter avant de décider, c'est raisonnable.
Léa : J'aimerais un étage qui donne sur le jardin, pas sur l'allée.
Patrick : Pourriez-vous nous montrer la chambre du fond, s'il vous plaît ?
Aline : On devrait lire le règlement avant de rêver trop fort.
Hawa : Je voudrais que le loyer reste clair : pas de surprise jeudi.
Joël : Est-ce que vous pourriez répéter le jour des clés, Karim ?
Rose : J'aimerais que Léa ne parte pas trop vite ; on devrait en parler.
Solange : Nous voudrions un tampon lisible, pas une signature floue.
Noura : Si vous vouliez un voisinage calme, vous seriez bien ici, le soir.
Ibrahim : On devrait aussi demander à Félicie : elle tient le cahier des chambres.
Marc : Je voudrais rester prudent : un souhait n'est pas encore un contrat.
Karim : Très bien. Je pourrais vous ouvrir demain à huit heures, si cela vous va.""",
        tf_item=(
            "Patrick emploie une demande polie avec « pourriez-vous ».",
            True,
            "Patrick : « Pourriez-vous nous montrer la chambre du fond… »",
        ),
        qcm_item=(
            "Qui tient le cahier des chambres, d'après Ibrahim ?",
            ["Solange", "Noura", "Félicie", "Joël"],
            2,
            "Ibrahim : « elle tient le cahier des chambres. »",
        ),
        pairs=[
            ("je voudrais", "un loyer clair / de la prudence"),
            ("j'aimerais", "un étage sur le jardin"),
            ("pourriez-vous", "montrer / répéter"),
            ("on devrait", "lire le règlement"),
        ],
        fill_item=("___-vous nous montrer la chambre du fond ?", "Pourriez"),
        words=["J'aimerais", "un", "étage", "sur", "le", "jardin", "."],
        anagram=("voudrais", "Souhait poli à la première personne, mode du possible."),
        error=(
            "Je voudrais un étage calme, et je ferrai le dossier dès demain.",
            "Je voudrais un étage calme, et je ferai le dossier dès demain.",
            "Futur de faire : ferai, un seul r.",
        ),
        pic_start=5,
        pic_words=["une lettre", "un souhait", "une demande", "un adjectif"],
        short_p="Notez trois souhaits et deux demandes polies, avec le verbe au conditionnel.",
        audio="Enregistrez : Je voudrais un étage calme. J'aimerais visiter. Pourriez-vous ouvrir ? On devrait lire le règlement.",
    ),
    _l(
        "CE",
        "CE — Lettre de souhait à Karim",
        "Lire une lettre polie qui formule des souhaits au conditionnel.",
        "Lisez la lettre, sans aller trop vite.",
        "Lettre de Léa à Karim Bamba",
        """Val-des-Peupliers, quartier Rive-des-Saules
Cher Karim,
Nous aimerions visiter le Pavillon du Saule avant jeudi.
Je voudrais un étage simple, avec une fenêtre sur le jardin, si cela se peut.
Patrick voudrait clarifier le loyer : pourriez-vous l'indiquer par écrit ?
On devrait aussi savoir à quelle heure on retire les clés au Bureau des Escales.
Aline nous a dit qu'on devrait lire le règlement ; nous le ferons, bien sûr.
J'aimerais que Noura et Ibrahim soient prévenus : nous tiendrions à les saluer.
Pourriez-vous, s'il vous plaît, nous recevoir demain matin plutôt que le soir ?
Nous serions reconnaissants d'une réponse courte, même par Radio Figuier.
Recevez, je vous prie, nos salutations attentives.
Léa Niyonzima et Patrick Habimana
Copie : Aline Uwase — Seuil des Sources""",
        tf_item=(
            "Léa demande une visite le soir plutôt que le matin.",
            False,
            "Elle demande demain matin plutôt que le soir.",
        ),
        qcm_item=(
            "Que voudrait Patrick, d'après la lettre ?",
            [
                "Un tambour de Sami",
                "Le loyer indiqué par écrit",
                "Partir sans clés",
                "Fermer le jardin",
            ],
            1,
            "« Patrick voudrait clarifier le loyer… par écrit. »",
        ),
        pairs=[
            ("nous aimerions", "visiter le pavillon"),
            ("je voudrais", "un étage simple"),
            ("pourriez-vous", "indiquer / recevoir"),
            ("nous serions", "reconnaissants"),
        ],
        fill_item=("On ___ aussi savoir l'heure des clés. (devoir, cond.)", "devrait"),
        words=["Nous", "aimerions", "visiter", "le", "pavillon", "."],
        anagram=("aimerais", "Autre verbe de souhait, première personne, plus doux que vouloir."),
        error=(
            "J'aimerais visiter le jardin, et je pourai venir jeudi.",
            "J'aimerais visiter le jardin, et je pourrai venir jeudi.",
            "Futur de pouvoir : pourrai, deux r.",
        ),
        pic_start=6,
        pic_words=["un souhait", "une demande", "un adjectif", "un banc"],
        short_p="Recopiez la lettre et soulignez tous les conditionnels.",
        audio="Lisez la lettre de Léa à voix haute, sans aller trop vite.",
    ),
    _l(
        "PO",
        "PO — Dire je voudrais, pourriez-vous",
        "Formuler à l'oral un souhait et une demande polie au conditionnel.",
        "Répétez, puis demandez poliment une information sur un logement.",
        "Modèles de Patrick et d'Aline",
        """Je voudrais un étage calme.
J'aimerais visiter demain.
Pourriez-vous m'indiquer le loyer ?
On devrait lire le règlement d'abord.
Nous aimerions saluer Noura.
Est-ce que vous pourriez répéter l'heure ?
Je serais plus tranquille avec une clé de rechange.
On devrait aussi prévenir Félicie.
Aline : un souhait se dit sans exiger.
Karim : une demande polie laisse à l'autre le droit de dire non.
Hawa : « je veux » sonne trop sec ici ; « je voudrais » ouvre la porte.
Léa : « pourriez-vous » vaut mieux que « vous devez m'ouvrir ».""",
        tf_item=(
            "« Pourriez-vous » est plus poli que « vous devez ».",
            True,
            "Léa oppose les deux formules.",
        ),
        qcm_item=(
            "Quelle phrase formule un conseil au conditionnel ?",
            [
                "Je voudrais un étage calme",
                "Pourriez-vous m'indiquer le loyer",
                "On devrait lire le règlement d'abord",
                "J'ouvre la porte",
            ],
            2,
            "On devrait = conseil, pas une exigence.",
        ),
        pairs=[
            ("je voudrais", "souhait"),
            ("j'aimerais", "souhait plus doux"),
            ("pourriez-vous", "demande polie"),
            ("on devrait", "conseil"),
        ],
        fill_item=("Je ___ plus tranquille avec une clé. (être, cond.)", "serais"),
        words=["Pourriez-vous", "m'indiquer", "le", "loyer", "?"],
        anagram=("pourriez", "Forme polie de pouvoir, adressée à vous, avant une demande."),
        error=(
            "Pourriez-vous m'indiquer le pavillon, et on devrais y aller tôt.",
            "Pourriez-vous m'indiquer le pavillon, et on devrait y aller tôt.",
            "On devrait : base de devoir + ait, pas ais.",
        ),
        pic_start=7,
        pic_words=["une demande", "un adjectif", "un banc", "un conseil"],
        short_p="Écrivez six répliques : deux je voudrais, deux j'aimerais, deux pourriez-vous.",
        audio="Enregistrez les six premiers modèles, puis une demande polie à vous.",
    ),
    _l(
        "PE",
        "PE — Ma demande polie",
        "Écrire une demande polie au conditionnel pour un logement.",
        "Imitez la demande de Patrick Habimana.",
        "Demande de Patrick, cahier bleu",
        """Patrick Habimana — Seuil des Sources
Cher Karim,
Je voudrais clarifier trois points avant de poser ma valise.
J'aimerais visiter le Pavillon du Saule avec Léa, demain si possible.
Pourriez-vous nous indiquer le loyer, l'heure des clés et la règle du jardin ?
On devrait aussi savoir si Noura accepte un voisinage de passage.
Je serais reconnaissant d'une réponse courte, même un mot à Radio Figuier.
Nous tiendrions à saluer Félicie, qui tient le cahier des chambres.
Aline nous a conseillé de ne pas exiger : nous demandons, nous n'imposons pas.
Si vous pouviez ouvrir le matin, ce serait plus simple pour le minibus Figuier 7.
Merci d'avance, et à bientôt sous le saule ou sous le figuier.
Patrick
Copie : Léa Niyonzima, Aline Uwase""",
        tf_item=(
            "Patrick impose l'heure d'ouverture à Karim.",
            False,
            "Il demande sans imposer ; Aline a conseillé de ne pas exiger.",
        ),
        qcm_item=(
            "Combien de points Patrick veut-il clarifier ?",
            ["Un", "Deux", "Trois", "Dix"],
            2,
            "« clarifier trois points avant de poser ma valise. »",
        ),
        pairs=[
            ("je voudrais", "clarifier"),
            ("j'aimerais", "visiter"),
            ("pourriez-vous", "indiquer trois infos"),
            ("je serais", "reconnaissant"),
        ],
        fill_item=("Si vous pouviez ouvrir le matin, ce ___ plus simple.", "serait"),
        words=["Je", "voudrais", "clarifier", "trois", "points", "."],
        anagram=("devrait", "On… lire le règlement : conseil, pas un ordre sec."),
        error=(
            "Je serai reconnaissant si vous pouviez garder une chambre, et je tiendrais au jardin.",
            "Je serais reconnaissant si vous pouviez garder une chambre, et je tiendrais au jardin.",
            "Conditionnel de être : serais, pas le futur serai.",
        ),
        pic_start=8,
        pic_words=["un adjectif", "un banc", "un conseil", "un jardin"],
        short_p="Imitez : une demande de dix lignes, avec voudrais, aimerais, pourriez-vous, devrait.",
        audio="Lisez votre demande, sans aller trop vite.",
    ),
    _l(
        "EL",
        "EL — Conditionnel présent et politesse",
        "Retenir la formation du conditionnel présent et son usage poli.",
        "Apprenez la fiche.",
        "Fiche d'Aline, conditionnel",
        """Conditionnel présent = radical du futur + terminaisons de l'imparfait
je voudrais / tu voudrais / il voudrait / nous voudrions / vous voudriez / ils voudraient
j'aimerais, tu aimerais, il aimerait…
je pourrais, vous pourriez (demande polie : pourriez-vous + infinitif ?)
on devrait + infinitif : conseil souple
je serais (cond.) ≠ je serai (futur, un r après e, pas ais)
je ferais (cond.) ≠ je ferai (futur, un seul r)
je pourrais (cond.) ≠ je pourrai (futur, deux r)
Politesse : je voudrais > je veux ; pourriez-vous > vous devez
Un souhait n'est pas un contrat. On peut répondre non.
Attention : il faut (pas je faut). Bien que + subjonctif : bien que ce soit tôt.
Si + imparfait → conditionnel : si vous pouviez ouvrir, ce serait plus simple.""",
        tf_item=(
            "« Je serai » et « je serais » ont le même temps.",
            False,
            "Serai = futur. Serais = conditionnel.",
        ),
        qcm_item=(
            "Quelle forme est le futur de pouvoir ?",
            ["je pourai", "je pourrais", "je pourrai", "je pouvrai"],
            2,
            "Futur : je pourrai (deux r). Conditionnel : je pourrais.",
        ),
        pairs=[
            ("je voudrais", "souhait"),
            ("pourriez-vous", "demande polie"),
            ("je serais", "conditionnel de être"),
            ("je ferai", "futur de faire"),
        ],
        fill_item=("Demain, je ___ le dossier. (faire, futur)", "ferai"),
        words=["On", "devrait", "lire", "le", "règlement", "."],
        anagram=("souhait", "Ce qu'on aimerait obtenir, dit sans l'exiger."),
        error=(
            "Nous voudrions un étage, mais je faut demander à Karim.",
            "Nous voudrions un étage, mais il faut demander à Karim.",
            "Toujours il faut, jamais je faut.",
        ),
        pic_start=9,
        pic_words=["un banc", "un conseil", "un jardin", "un pronom"],
        short_p="Conjuguez vouloir, aimer, pouvoir, devoir, être et faire au conditionnel présent (je / nous / vous).",
        audio="Enregistrez la fiche et six formes : voudrais, aimerais, pourriez, devrait, serais, ferais.",
    ),
]


# ---------------------------------------------------------------------------
# Séquence 3 — Un quartier à caractériser (adjectif, conseils, si + imparfait)
# ---------------------------------------------------------------------------

S3 = [
    _l(
        "CO",
        "CO — Un petit quartier calme",
        "Repérer la place de l'adjectif, des conseils et une hypothèse (si + imparfait).",
        "Lisez le dialogue. Comment caractérise-t-on Rive-des-Saules ?",
        "Pont des Saules, fin d'après-midi",
        """Marc : C'est un petit quartier calme, pas une grande ville bruyante.
Léa : Je vois un ancien pont et, plus loin, un pont ancien couvert de mousse.
Aline : Ancien avant le nom, c'est souvent « d'autrefois ». Après le nom, c'est l'âge réel.
Patrick : Si nous habitions ici, nous serions plus près de l'eau, moins près du figuier.
Hawa : Prenez un grand appartement lumineux plutôt qu'une petite chambre sombre.
Joël : Si j'avais une clé ce soir, je pourrais vous montrer le jardin du saule.
Rose : Évitez l'allée trop étroite à la tombée de la nuit ; restez sur le quai large.
Noura : Nous avons une jolie cour verte, et une maison haute derrière les peupliers.
Ibrahim : Si vous restiez trois mois, vous connaîtriez déjà tous les prénoms.
Félicie : Un jeune voisin silencieux vaut mieux qu'un vieux bruit gentil, parfois.
Dieudonné : Je conseillerais le premier étage : un bel étage clair, un escalier simple.
Yvette : Si le loyer était plus clair, davantage de gens du Seuil oseraient venir.""",
        tf_item=(
            "Aline dit qu'un ancien pont et un pont ancien veulent toujours dire la même chose.",
            False,
            "Elle distingue « d'autrefois » et l'âge réel.",
        ),
        qcm_item=(
            "Que conseillerait Dieudonné ?",
            [
                "Le sous-sol sans fenêtre",
                "Le premier étage, un bel étage clair",
                "L'allée trop étroite la nuit",
                "Une petite chambre sombre",
            ],
            1,
            "Dieudonné : « Je conseillerais le premier étage. »",
        ),
        pairs=[
            ("petit / calme", "quartier"),
            ("ancien pont", "d'autrefois"),
            ("si nous habitions", "nous serions"),
            ("grand / lumineux", "appartement"),
        ],
        fill_item=("C'est un ___ quartier calme.", "petit"),
        words=["Si", "nous", "habitions", "ici", "nous", "serions", "près", "de", "l'eau", "."],
        anagram=("ancien", "Adjectif d'âge : avant le nom, il dit souvent « d'autrefois »."),
        error=(
            "C'est un quartier petit calme, avec un ancien pont près du saule.",
            "C'est un petit quartier calme, avec un ancien pont près du saule.",
            "Petit (taille) se place avant le nom.",
        ),
        pic_start=10,
        pic_words=["un conseil", "un jardin", "un pronom", "un souvenir"],
        short_p="Notez quatre adjectifs (place) et deux phrases en si + imparfait → conditionnel.",
        audio="Enregistrez : C'est un petit quartier calme. Si nous habitions ici, nous serions plus près de l'eau.",
    ),
    _l(
        "CE",
        "CE — Portrait de Rive-des-Saules",
        "Lire un portrait de quartier et les conseils qui l'accompagnent.",
        "Lisez le portrait, sans aller trop vite.",
        "Feuille de Marc Nkurunziza",
        """Rive-des-Saules — portrait pour ceux du Seuil
C'est un petit quartier calme, une longue allée verte, un vieux quai bas.
On y voit un ancien pont (celui d'autrefois, en bois) et un pont de pierre plus récent.
La jolie cour du Pavillon du Saule reste ouverte le matin ; le soir, Félicie ferme.
Conseil : choisissez un grand appartement clair plutôt qu'une chambre étroite.
Conseil : évitez l'allée trop sombre après vingt et une heures ; prenez le quai.
Si vous aviez une clé, vous pourriez entrer sans réveiller Noura.
Si le minibus Figuier 7 arrivait plus tôt, le trajet serait moins long.
Yvette note : une jeune voisine attentive, un haut peuplier, une eau verte.
Mado ajoute : ce n'est pas une grande ville froide ; c'est un quartier vivant, simplement.
Sami passerait avec son tambour le jeudi, si la cour était libre.
Marc : caractériser, c'est choisir l'adjectif et sa place, puis oser un si.""",
        tf_item=(
            "Félicie ferme la cour le matin et l'ouvre le soir.",
            False,
            "La cour est ouverte le matin ; Félicie ferme le soir.",
        ),
        qcm_item=(
            "Que feriez-vous si vous aviez une clé, d'après le texte ?",
            [
                "Réveiller Noura",
                "Entrer sans réveiller Noura",
                "Fermer le pont",
                "Casser le tambour",
            ],
            1,
            "« vous pourriez entrer sans réveiller Noura. »",
        ),
        pairs=[
            ("petit / calme", "quartier"),
            ("ancien pont", "en bois, d'autrefois"),
            ("si vous aviez", "vous pourriez"),
            ("jeune / attentive", "voisine"),
        ],
        fill_item=("Si vous aviez une clé, vous ___ entrer. (pouvoir, cond.)", "pourriez"),
        words=["Choisissez", "un", "grand", "appartement", "clair", "."],
        anagram=("calme", "Sans bruit, derrière le saule, un quartier…"),
        error=(
            "Si nous avions une clé, nous pourrons entrer, et le jardin resterait ouvert.",
            "Si nous avions une clé, nous pourrions entrer, et le jardin resterait ouvert.",
            "Si + imparfait → conditionnel : pourrions, pas le futur pourrons.",
        ),
        pic_start=11,
        pic_words=["un jardin", "un pronom", "un souvenir", "une photo"],
        short_p="Recopiez le portrait et encadrez six adjectifs ; notez leur place.",
        audio="Lisez le portrait de Marc, sans aller trop vite.",
    ),
    _l(
        "PO",
        "PO — Conseiller et supposer",
        "Donner un conseil et construire une hypothèse : si + imparfait → conditionnel.",
        "Répétez, puis conseillez un étage et imaginez « si vous habitiez là ».",
        "Modèles de Marc et d'Aline",
        """C'est un petit quartier calme.
Prenez un bel étage clair.
Évitez l'allée trop étroite.
Si j'habitais là, je serais plus près de l'eau.
Si nous avions une clé, nous pourrions entrer.
Si le loyer était clair, davantage de gens viendraient.
Je conseillerais le premier étage.
Restez sur le large quai, le soir.
Aline : l'adjectif de taille, d'âge, de beauté se place souvent avant.
Patrick : calme, lumineux, sombre se placent souvent après.
Léa : un ancien pont n'est pas toujours un pont ancien.
Hawa : un conseil se dit à l'impératif ou avec « je conseillerais ».""",
        tf_item=(
            "Après si, on met l'imparfait, et le résultat se met au conditionnel.",
            True,
            "Si j'habitais là, je serais…",
        ),
        qcm_item=(
            "Quelle phrase est une hypothèse correcte ?",
            [
                "Si j'habite là, je serais libre",
                "Si j'habitais là, je serais plus près de l'eau",
                "Si j'habitais là, je serai plus près",
                "Si j'aurais une clé, j'entre",
            ],
            1,
            "Si + imparfait, puis conditionnel.",
        ),
        pairs=[
            ("petit / bel / ancien", "souvent avant le nom"),
            ("calme / lumineux", "souvent après le nom"),
            ("si + imparfait", "conditionnel"),
            ("je conseillerais", "conseil souple"),
        ],
        fill_item=("Si j'habitais là, je ___ plus près de l'eau. (être, cond.)", "serais"),
        words=["Je", "conseillerais", "le", "premier", "étage", "."],
        anagram=("vivions", "Si nous… là : imparfait de vivre, après si."),
        error=(
            "Si j'habitais là, je serai plus libre, et je tiendrais à ce banc.",
            "Si j'habitais là, je serais plus libre, et je tiendrais à ce banc.",
            "Après si + imparfait : serais, pas le futur serai.",
        ),
        pic_start=12,
        pic_words=["un pronom", "un souvenir", "une photo", "un pont"],
        short_p="Écrivez six conseils et quatre hypothèses (si + imparfait → conditionnel).",
        audio="Enregistrez les six premiers modèles, puis deux hypothèses à vous.",
    ),
    _l(
        "PE",
        "PE — Mon portrait de quartier",
        "Écrire un portrait avec la place de l'adjectif, un conseil et une hypothèse.",
        "Imitez le portrait de Hawa Diallo.",
        "Portrait de Hawa, cahier du chemin",
        """Hawa Diallo — Rive-des-Saules vue depuis le pont
C'est un petit quartier calme, une jolie cour verte, un haut peuplier.
J'y vois un ancien pont de bois et une longue allée claire.
Je conseillerais un grand appartement lumineux, pas une chambre étroite.
Évitez l'allée trop sombre après vingt et une heures ; restez près de l'eau.
Si j'habitais au Pavillon du Saule, je serais plus près de Noura, moins près du figuier.
Si nous avions une clé de rechange, nous pourrions rentrer sans réveiller Félicie.
Mado dit que c'est un quartier vivant, simplement, pas une ville froide.
Sami passerait le jeudi, si la cour était libre.
Je tiens à ce portrait honnête : ailleurs n'est ni parfait ni triste.
Hawa
Copie pour Aline et pour le banc du Seuil""",
        tf_item=(
            "Hawa conseille une chambre étroite plutôt qu'un grand appartement.",
            False,
            "Elle conseille un grand appartement lumineux.",
        ),
        qcm_item=(
            "Que se passerait-il si Hawa habitait au pavillon ?",
            [
                "Elle serait plus près de Noura",
                "Elle vendrait le figuier",
                "Elle fermerait le pont",
                "Elle quitterait le français",
            ],
            0,
            "« je serais plus près de Noura, moins près du figuier. »",
        ),
        pairs=[
            ("petit / jolie / haut", "avant le nom"),
            ("calme / verte / claire", "après le nom"),
            ("je conseillerais", "un appartement"),
            ("si j'habitais", "je serais"),
        ],
        fill_item=("Évitez l'allée trop sombre ; restez près ___ l'eau.", "de"),
        words=["C'est", "un", "petit", "quartier", "calme", "."],
        anagram=("conseil", "Recommandation de Marc ou d'Hawa pour choisir un étage."),
        error=(
            "Prenez un appartement grand lumineux, et restez près du pont.",
            "Prenez un grand appartement lumineux, et restez près du pont.",
            "Grand (taille) se place avant le nom.",
        ),
        pic_start=13,
        pic_words=["un souvenir", "une photo", "un pont", "deux rives"],
        short_p="Imitez : un portrait de dix lignes, trois adjectifs bien placés, un si, un conseil.",
        audio="Lisez votre portrait, sans aller trop vite.",
    ),
    _l(
        "EL",
        "EL — Place de l'adjectif et si hypothétique",
        "Retenir la place de l'adjectif et le système si + imparfait → conditionnel.",
        "Apprenez la fiche.",
        "Fiche de Marc, adjectifs et si",
        """Souvent avant le nom (taille, âge, beauté, bon/mauvais) :
un petit quartier, un grand appartement, un bel étage, un ancien pont, une jolie cour
Souvent après le nom (couleur, forme, qualité « de nature ») :
un quartier calme, un appartement lumineux, une allée sombre, une eau verte
Sens qui change : un ancien pont (d'autrefois) / un pont ancien (très vieux)
un brave homme / un homme brave
Si + imparfait → conditionnel présent (hypothèse non réelle maintenant) :
Si j'habitais là, je serais plus libre.
Si nous avions une clé, nous pourrions entrer.
Pas : si j'aurais… Pas : si + imparfait → futur (je serai).
Conseils : impératif (prenez, évitez) ou conditionnel (je conseillerais).
À + le = au : au milieu du quartier, au Pavillon du Saule.""",
        tf_item=(
            "On dit « si j'aurais une clé » dans cette hypothèse.",
            False,
            "Si + imparfait : si j'avais, jamais si j'aurais ici.",
        ),
        qcm_item=(
            "« Un ancien pont » veut dire surtout…",
            [
                "un pont tout neuf",
                "un pont d'autrefois / qui n'est plus le pont actuel",
                "un pont sans eau",
                "un pont interdit",
            ],
            1,
            "Ancien avant le nom : d'autrefois.",
        ),
        pairs=[
            ("petit / grand / bel", "avant"),
            ("calme / lumineux / sombre", "après"),
            ("si + imparfait", "conditionnel"),
            ("je conseillerais", "conseil"),
        ],
        fill_item=("Au ___ du quartier, un petit café calme. (milieu)", "milieu"),
        words=["Si", "j'avais", "une", "clé", "je", "pourrais", "entrer", "."],
        anagram=("hypothese", "Si + imparfait, puis le mode du possible. (sans accent)"),
        error=(
            "On écrit à le milieu du quartier un petit café calme.",
            "On écrit au milieu du quartier un petit café calme.",
            "À + le = au.",
        ),
        pic_start=14,
        pic_words=["une photo", "un pont", "deux rives", "un choix"],
        short_p="Faites deux listes d'adjectifs (avant / après) et quatre phrases en si.",
        audio="Enregistrez la fiche et quatre exemples : deux adjectifs, deux si.",
    ),
]


# ---------------------------------------------------------------------------
# Séquence 4 — Souvenirs d'arrivée (pronoms où et dont)
# ---------------------------------------------------------------------------

S4 = [
    _l(
        "CO",
        "CO — Le jour où le minibus s'est arrêté",
        "Comprendre où et dont dans des souvenirs d'arrivée.",
        "Lisez le dialogue. Quel est le lieu où l'on arrive, et de quoi se souvient-on ?",
        "Banc du Seuil, photos étalées",
        """Léa : Le quartier où je suis descendue s'appelait déjà Rive-des-Saules.
Patrick : La ville dont je me souviens sentait l'eau et le bois mouillé.
Aline : Le jour où le minibus Figuier 7 s'est arrêté, Karim tenait deux clés.
Marc : Les gens dont nous parlons encore, c'est Noura, Ibrahim, Félicie.
Hawa : La raison dont Léa m'a parlé, c'était le silence différent, pas la fuite.
Joël : Le pavillon dont les fenêtres donnent sur le jardin m'a paru simple et juste.
Rose : L'allée où Sami a posé son tambour reste dans toutes les photos.
Solange : Le bureau où l'on tamponne, c'est celui des Escales, pas la Maison des Vents.
Mado : Je me souviens de la brume dont le pont était couvert, ce premier matin.
Yvette : L'heure où nous avons trop attendu nous a appris la patience.
Lila : Radio Figuier a gardé la voix dont Patrick riait encore, fatigué et content.
Aline : Où = lieu ou moment. Dont = de + nom (parler de, se souvenir de, possession).""",
        tf_item=(
            "Dont remplace souvent « de + nom » : se souvenir de, parler de.",
            True,
            "Aline le rappelle en clôture.",
        ),
        qcm_item=(
            "De quelle raison Léa a-t-elle parlé, d'après Hawa ?",
            [
                "La fuite",
                "Le silence différent",
                "Un tambour cassé",
                "Un tampon perdu",
            ],
            1,
            "Hawa : « le silence différent, pas la fuite. »",
        ),
        pairs=[
            ("le quartier où", "Léa est descendue"),
            ("la ville dont", "Patrick se souvient"),
            ("les gens dont", "nous parlons"),
            ("le jour où", "le minibus s'est arrêté"),
        ],
        fill_item=("La ville ___ je me souviens sentait l'eau.", "dont"),
        words=["Le", "quartier", "où", "je", "suis", "descendue", "était", "calme", "."],
        anagram=("souvenir", "Ce qui reste dans la mémoire après la première arrivée."),
        error=(
            "Le quartier que je vis est calme, et la ville dont je me souviens reste verte.",
            "Le quartier où je vis est calme, et la ville dont je me souviens reste verte.",
            "Vivre dans un lieu → où, pas que.",
        ),
        pic_start=15,
        pic_words=["un pont", "deux rives", "un choix", "un cahier"],
        short_p="Notez quatre relatives : deux avec où, deux avec dont.",
        audio="Enregistrez : Le quartier où je suis descendue. La ville dont je me souviens. Les gens dont nous parlons.",
    ),
    _l(
        "CE",
        "CE — Carnet d'arrivée de Léa",
        "Lire un carnet de souvenirs qui enchaîne où et dont.",
        "Lisez le carnet, sans aller trop vite.",
        "Carnet de Léa Niyonzima",
        """Le quartier où je suis descendue sentait déjà le saule et l'eau.
La ville dont je me souviens n'était pas bruyante : Val-des-Peupliers, rive nord.
Le jour où Karim a tendu les clés, Patrick a trop ri, de fatigue et de soulagement.
Les gens dont nous parlons encore tiennent le cahier, le pont, le thé du matin.
La raison dont j'ai parlé à Hawa, c'était d'apprendre un autre silence, pas de fuir.
Le pavillon dont les fenêtres donnent sur le jardin a une chambre simple, ocre.
L'allée où Sami a posé son tambour reste sur la photo pliée dans mon sac.
Le bureau où Solange tamponne ouvre tôt ; la Maison des Vents, elle, reste au Seuil.
Je me souviens de la brume dont le pont était couvert, et de la voix de Lila.
L'heure où le minibus Figuier 7 a trop tardé nous a appris à attendre ensemble.
Mado, Yvette et Félicie : trois prénoms dont je n'oublie plus l'ordre.
Aline dira : où pour le lieu et le moment ; dont pour « de cela ».""",
        tf_item=(
            "Léa dit qu'elle est descendue pour fuir le Seuil.",
            False,
            "La raison : apprendre un autre silence, pas fuir.",
        ),
        qcm_item=(
            "Où Solange tamponne-t-elle, d'après le carnet ?",
            [
                "À la Maison des Vents",
                "Au bureau des Escales",
                "Sous le figuier seulement",
                "Dans le minibus",
            ],
            1,
            "« Le bureau où Solange tamponne ouvre tôt. »",
        ),
        pairs=[
            ("le quartier où", "Léa est descendue"),
            ("la ville dont", "elle se souvient"),
            ("la raison dont", "elle a parlé à Hawa"),
            ("l'allée où", "Sami a posé son tambour"),
        ],
        fill_item=("Les gens ___ nous parlons tiennent le cahier.", "dont"),
        words=["Le", "jour", "où", "Karim", "a", "tendu", "les", "clés", "."],
        anagram=("dont", "Pronom pour remplacer de + nom après un antécédent."),
        error=(
            "Les gens que je parle sont restés au Seuil, et le pont où nous avons marché tient encore.",
            "Les gens dont je parle sont restés au Seuil, et le pont où nous avons marché tient encore.",
            "Parler de quelqu'un → dont, pas que.",
        ),
        pic_start=16,
        pic_words=["deux rives", "un choix", "un cahier", "un minibus"],
        short_p="Recopiez le carnet et encadrez où et dont ; indiquez ce qu'ils remplacent.",
        audio="Lisez le carnet de Léa, sans aller trop vite.",
    ),
    _l(
        "PO",
        "PO — Dire où et dont",
        "Relier un souvenir avec où (lieu, moment) et dont (de + nom).",
        "Répétez, puis racontez une arrivée avec où et dont.",
        "Modèles d'Aline et de Patrick",
        """C'est le quartier où je suis descendue.
C'est la ville dont je me souviens.
C'est le jour où le minibus s'est arrêté.
Ce sont les gens dont nous parlons.
C'est la raison dont Léa m'a parlé.
C'est le pavillon dont les fenêtres donnent sur le jardin.
C'est l'allée où Sami a joué.
C'est l'heure où nous avons trop attendu.
Aline : où = dans lequel / auquel moment.
Patrick : dont = de qui / de quoi / duquel.
Hawa : je me souviens de la ville → la ville dont je me souviens.
Joël : je parle des voisins → les voisins dont je parle.""",
        tf_item=(
            "« Dont » peut exprimer une possession : le pavillon dont les fenêtres…",
            True,
            "Dont = de + le pavillon.",
        ),
        qcm_item=(
            "« Je me souviens de la ville » se relie comment ?",
            [
                "la ville où je me souviens",
                "la ville que je me souviens",
                "la ville dont je me souviens",
                "la ville à qui je me souviens",
            ],
            2,
            "Se souvenir de → dont.",
        ),
        pairs=[
            ("où", "lieu ou moment"),
            ("dont", "de + nom"),
            ("se souvenir de", "dont"),
            ("parler de", "dont"),
        ],
        fill_item=("C'est le pavillon ___ les fenêtres donnent sur le jardin.", "dont"),
        words=["C'est", "le", "jour", "où", "le", "minibus", "s'est", "arrêté", "."],
        anagram=("quartier", "Le secteur autour du pavillon, celui où l'on descend."),
        error=(
            "C'est la ville que je me souviens, et le jour où le minibus s'est arrêté.",
            "C'est la ville dont je me souviens, et le jour où le minibus s'est arrêté.",
            "Se souvenir de → dont.",
        ),
        pic_start=17,
        pic_words=["un choix", "un cahier", "un minibus", "une lettre"],
        short_p="Écrivez huit relatives : quatre où, quatre dont (lieu, moment, souvenir, possession).",
        audio="Enregistrez les six premiers modèles, puis deux souvenirs à vous.",
    ),
    _l(
        "PE",
        "PE — Mes souvenirs d'arrivée",
        "Écrire un souvenir d'arrivée avec où et dont.",
        "Imitez le souvenir de Patrick Habimana.",
        "Souvenir de Patrick, photo pliée",
        """Patrick Habimana — première arrivée à Rive-des-Saules
Le quartier où le minibus m'a laissé sentait le bois mouillé.
La ville dont je me souviens encore, c'est Val-des-Peupliers sous la brume.
Le jour où Karim a ouvert le Pavillon du Saule, Léa a trop parlé, de joie.
Les gens dont je parle aujourd'hui — Noura, Ibrahim, Félicie — sont devenus des appuis.
Le pavillon dont les fenêtres donnent sur le jardin reste simple, et c'est assez.
L'allée où Sami a posé son tambour apparaît sur toutes les photos de Léa.
La raison dont Aline m'avait prévenu, c'était la fatigue, pas le regret.
Je tiens à cette page : ailleurs a un visage, des prénoms, une heure.
Patrick
Pour le figuier, quand nous rentrerons raconter.""",
        tf_item=(
            "Patrick dit que la raison dont Aline l'avait prévenu, c'était le regret.",
            False,
            "« c'était la fatigue, pas le regret. »",
        ),
        qcm_item=(
            "Que donnent les fenêtres du pavillon ?",
            [
                "Sur le marché",
                "Sur le jardin",
                "Sur Radio Figuier",
                "Sur Rukiri-Nord",
            ],
            1,
            "« dont les fenêtres donnent sur le jardin. »",
        ),
        pairs=[
            ("le quartier où", "le minibus l'a laissé"),
            ("la ville dont", "il se souvient"),
            ("le pavillon dont", "les fenêtres"),
            ("la raison dont", "Aline l'avait prévenu"),
        ],
        fill_item=("L'allée ___ Sami a posé son tambour est sur les photos.", "où"),
        words=["La", "ville", "dont", "je", "me", "souviens", "reste", "sous", "la", "brume", "."],
        anagram=("raison", "Le motif dont on parle : pourquoi l'on est parti ce jour-là."),
        error=(
            "Le pavillon où les fenêtres donnent sur le jardin est calme, et les voisins dont je parle sont Noura et Ibrahim.",
            "Le pavillon dont les fenêtres donnent sur le jardin est calme, et les voisins dont je parle sont Noura et Ibrahim.",
            "Possession (les fenêtres du pavillon) → dont.",
        ),
        pic_start=18,
        pic_words=["un cahier", "un minibus", "une lettre", "une enveloppe"],
        short_p="Imitez : dix lignes de souvenir, trois où, trois dont.",
        audio="Lisez votre souvenir, sans aller trop vite.",
    ),
    _l(
        "EL",
        "EL — Pronoms où et dont",
        "Retenir le choix entre où et dont, et les verbes qui appellent de.",
        "Apprenez la fiche.",
        "Fiche d'Aline, où et dont",
        """où = lieu (dans lequel) ou moment (le jour où, l'heure où)
le quartier où je vis ; la ville où nous sommes descendus
le jour où le minibus s'est arrêté ; l'heure où nous avons attendu
dont = de + qui / de + quoi / de + lequel
se souvenir de → la ville dont je me souviens
parler de → les gens dont je parle
avoir besoin de → l'aide dont nous avons besoin
possession : le pavillon dont les fenêtres donnent sur le jardin
On ne dit pas : la ville que je me souviens.
On ne dit pas : les gens que je parle (parler à → à qui ; parler de → dont).
Élision : le jour où elle arrive (où ne s'élide pas). Dont non plus.
Attention : je me souviens de la ville (pas je me souviens la ville).""",
        tf_item=(
            "On écrit « le jour qu'elle arrive » pour un moment.",
            False,
            "Le jour où elle arrive. Où ne s'élide pas.",
        ),
        qcm_item=(
            "« Les fenêtres du pavillon » se relie par…",
            [
                "le pavillon où les fenêtres",
                "le pavillon dont les fenêtres",
                "le pavillon que les fenêtres",
                "le pavillon à qui les fenêtres",
            ],
            1,
            "Possession → dont.",
        ),
        pairs=[
            ("où", "lieu / moment"),
            ("dont", "de + nom"),
            ("se souvenir de", "dont"),
            ("avoir besoin de", "dont"),
        ],
        fill_item=("Je me souviens ___ la ville clairement.", "de"),
        words=["C'est", "l'aide", "dont", "nous", "avons", "besoin", "."],
        anagram=("souviens", "Je me… de la ville : verbe de mémoire construit avec de."),
        error=(
            "Je me souviens la ville clairement, et le quartier où j'arrive reste ocre.",
            "Je me souviens de la ville clairement, et le quartier où j'arrive reste ocre.",
            "Se souvenir de + nom.",
        ),
        pic_start=19,
        pic_words=["un minibus", "une lettre", "une enveloppe", "une table"],
        short_p="Transformez six phrases simples en relatives : trois où, trois dont.",
        audio="Enregistrez la fiche et six relatives.",
    ),
]


# ---------------------------------------------------------------------------
# Séquence 5 — Deux rives, un choix (synthèse)
# ---------------------------------------------------------------------------

S5 = [
    _l(
        "CO",
        "CO — Seuil ou Rive-des-Saules",
        "Comparer deux rives en réemployant verbes prépositionnels et conditionnel.",
        "Lisez le dialogue. Qui penche vers quelle rive, et à quelles conditions ?",
        "Table des Sources, deux cartes face à face",
        """Aline : D'un côté le Seuil des Sources ; de l'autre Rive-des-Saules. On compare, on ne juge pas.
Léa : Si je m'installais au Pavillon du Saule, je m'habituerais à l'eau, je tiendrais quand même au figuier.
Patrick : Je songerais à rester ici si le loyer là-bas dépendait trop d'un seul ami.
Marc : Le Seuil est plus calme le matin ; Rive-des-Saules est plus proche du pont et du minibus.
Hawa : Je voudrais les deux : compter sur Rose ici, m'adapter à Noura là-bas.
Joël : Si nous nous éloignions trop, Radio Figuier relierait encore les voix.
Rose : Je vous mets en garde : un choix n'efface pas l'autre rive, il la déplace.
Solange : Au Bureau des Escales, on tamponne un départ ; on ne tamponne pas un oubli.
Karim : Pourriez-vous essayer trois semaines au pavillon, avant de décider pour de bon ?
Lila : On devrait écrire chaque jeudi, bien que ce soit loin, afin que personne n'idéalise.
Mado : Si j'avais à choisir ce soir, je rêverais encore du banc ocre, et du saule aussi.
Dieudonné : Tenir aux deux rives, ce n'est pas hésiter : c'est refuser de couper.""",
        tf_item=(
            "Rose dit qu'un choix efface complètement l'autre rive.",
            False,
            "Rose : un choix déplace l'autre rive, il ne l'efface pas.",
        ),
        qcm_item=(
            "Que propose Karim avant de décider pour de bon ?",
            [
                "Vendre le figuier",
                "Essayer trois semaines au pavillon",
                "Couper Radio Figuier",
                "Oublier le Seuil",
            ],
            1,
            "Karim : essayer trois semaines avant de décider.",
        ),
        pairs=[
            ("si je m'installais", "je m'habituerais"),
            ("songer à rester", "Patrick"),
            ("compter sur / s'adapter à", "Hawa"),
            ("tenir aux deux rives", "Dieudonné"),
        ],
        fill_item=("Si je m'installais au pavillon, je ___ au figuier. (tenir, cond.)", "tiendrais"),
        words=["On", "devrait", "écrire", "chaque", "jeudi", "."],
        anagram=("rives", "Deux berges : le Seuil d'un côté, les Saules de l'autre."),
        error=(
            "Si nous partions, je serai moins seul, et Léa tiendrait au figuier.",
            "Si nous partions, je serais moins seul, et Léa tiendrait au figuier.",
            "Si + imparfait → serais, pas le futur serai.",
        ),
        pic_start=20,
        pic_words=["une lettre", "une enveloppe", "une table", "une radio"],
        short_p="Notez trois comparaisons et trois phrases qui mêlent prépositionnel + conditionnel.",
        audio="Enregistrez : Si je m'installais au pavillon, je tiendrais au figuier. On devrait écrire chaque jeudi.",
    ),
    _l(
        "CE",
        "CE — Cahier de comparaison",
        "Lire une synthèse qui compare le Seuil et Rive-des-Saules.",
        "Lisez le cahier, sans aller trop vite.",
        "Cahier de comparaison, page partagée",
        """Deux rives — critères (Aline, Marc, Lila)
Seuil des Sources : plus calme à l'aube, figuier, Table des Sources, Maison des Vents.
Rive-des-Saules : plus proche de l'eau, Pavillon du Saule, pont, minibus Figuier 7.
S'installer au Seuil, c'est rester dans ce que l'on connaît ; s'installer dans Rive-des-Saules, c'est s'adapter.
On s'habitue à la brume du pont ; on s'habitue aussi à l'ombre du figuier.
Le loyer là-bas dépend du jardin ; ici, on dépend davantage des habitudes partagées.
Léa rêverait d'un étage simple si Karim acceptait ; Patrick songerait à rester s'il fallait choisir trop vite.
On devrait compter sur Solange pour les tampons, sur Rose pour les mises en garde.
Bien que ce soit loin, Lila relayera les voix : s'éloigner n'est pas se taire.
Si nous tenions aux deux rives, nous pourrions essayer trois semaines, puis écrire.
Dieudonné : un choix clair vaut mieux qu'un silence flou ; pourtant, tenir aux deux n'est pas une faute.
Yvette : pourriez-vous relire ces lignes avant de poser la valise ?
Hawa : je voudrais que personne n'idéalise ailleurs, ni ici.""",
        tf_item=(
            "Le cahier dit que s'éloigner, c'est forcément se taire.",
            False,
            "« s'éloigner n'est pas se taire. »",
        ),
        qcm_item=(
            "De quoi le loyer de Rive-des-Saules dépend-il, d'après le cahier ?",
            [
                "Du tambour de Sami",
                "Du jardin",
                "De Radio Figuier seulement",
                "Du figuier",
            ],
            1,
            "« Le loyer là-bas dépend du jardin. »",
        ),
        pairs=[
            ("plus calme à l'aube", "Seuil"),
            ("plus proche de l'eau", "Rive-des-Saules"),
            ("compter sur", "Solange / Rose"),
            ("essayer trois semaines", "tenir aux deux rives"),
        ],
        fill_item=("On s'habitue ___ la brume du pont.", "à"),
        words=["S'éloigner", "n'est", "pas", "se", "taire", "."],
        anagram=("comparer", "Mettre deux lieux l'un en face de l'autre, sans les juger trop vite."),
        error=(
            "Le Seuil est plus calme, en revanche on s'habitue de la brume, et on rêve encore du saule.",
            "Le Seuil est plus calme, en revanche on s'habitue à la brume, et on rêve encore du saule.",
            "S'habituer à, pas s'habituer de.",
        ),
        pic_start=21,
        pic_words=["une enveloppe", "une table", "une radio", "une maison"],
        short_p="Recopiez le cahier et ajoutez deux critères à vous, un par rive.",
        audio="Lisez le cahier de comparaison, sans aller trop vite.",
    ),
    _l(
        "PO",
        "PO — Dire le choix des deux rives",
        "Réemployer à l'oral prépositionnels, conditionnel et comparaison.",
        "Répétez, puis dites vers quelle rive vous pencheriez, et pourquoi.",
        "Modèles de synthèse, Aline et Dieudonné",
        """Si je m'installais là-bas, je m'habituerais à l'eau.
Je tiendrais au figuier, même loin.
Je songerais à rester si le loyer dépendait trop d'un ami.
On devrait essayer trois semaines.
Je voudrais les deux rives, sans en trahir une.
Pourriez-vous nous laisser le temps de comparer ?
Le Seuil est plus calme ; Rive-des-Saules est plus proche du pont.
Je compte sur vous pour les jeudis.
Je m'adapterais aux voisins, bien que ce soit nouveau.
Je ne m'éloignerais pas de vous dans les lettres.
Dieudonné : tenir aux deux rives, ce n'est pas hésiter.
Léa : un choix déplace, il n'efface pas.""",
        tf_item=(
            "La synthèse réemploie le conditionnel et les verbes à préposition.",
            True,
            "Si je m'installais, je m'habituerais, je tiendrais…",
        ),
        qcm_item=(
            "Quelle phrase mélange correctement hypothèse et prépositionnel ?",
            [
                "Si je m'installe, je tiendrai de figuier",
                "Si je m'installais là-bas, je m'habituerais à l'eau",
                "Si j'aurais le loyer, je dépends",
                "Je songe de rester si je partirai",
            ],
            1,
            "Si + imparfait → conditionnel + s'habituer à.",
        ),
        pairs=[
            ("s'installer / s'habituer", "conditionnel"),
            ("tenir à / songer à", "lien et pensée"),
            ("plus calme / plus proche", "comparaison"),
            ("compter sur", "les jeudis"),
        ],
        fill_item=("Je songe ___ rester si le loyer dépend trop d'un ami.", "à"),
        words=["Je", "tiendrais", "au", "figuier", "même", "loin", "."],
        anagram=("serais", "Forme de être au mode du souhait, pas au futur."),
        error=(
            "Je songe de rester, mais je pourrais aussi m'installer au pavillon.",
            "Je songe à rester, mais je pourrais aussi m'installer au pavillon.",
            "Songer à, pas songer de.",
        ),
        pic_start=22,
        pic_words=["une table", "une radio", "une maison", "un bureau"],
        short_p="Écrivez huit phrases de synthèse : quatre si, deux comparatifs, deux prépositionnels.",
        audio="Enregistrez les six premiers modèles, puis votre choix de rive.",
    ),
    _l(
        "PE",
        "PE — Mon choix entre deux rives",
        "Écrire une synthèse personnelle : comparer, souhaiter, mettre en garde.",
        "Imitez la synthèse de Rose Iradukunda.",
        "Synthèse de Rose, encre ocre",
        """Rose Iradukunda — aux deux rives, sans en couper une
Si Léa s'installait au Pavillon du Saule, elle s'adapterait à Noura, et elle tiendrait au figuier.
Patrick songerait à rester ici si le loyer là-bas dépendait trop d'un seul salaire.
Je voudrais qu'ils essaient trois semaines : on devrait comparer avant d'idéaliser.
Le Seuil est plus calme à l'aube ; Rive-des-Saules est plus proche de l'eau et du pont.
Je les mets en garde : ne vous éloignez pas de ceux qui restent, comptez sur Lila.
Pourriez-vous écrire chaque jeudi, bien que ce soit loin ?
Je rêverais d'un jeudi ici et d'un jeudi là-bas, si le minibus Figuier 7 le permettait.
Tenir aux deux rives n'est pas hésiter : c'est refuser d'effacer une cour.
Aline, Solange, Karim : nous comptons sur vous pour que le choix reste lisible.
Rose
Seuil des Sources — copie pour le banc et pour le saule""",
        tf_item=(
            "Rose dit que tenir aux deux rives, c'est hésiter.",
            False,
            "« Tenir aux deux rives n'est pas hésiter. »",
        ),
        qcm_item=(
            "Que voudrait Rose que Léa et Patrick fassent ?",
            [
                "Couper Radio Figuier",
                "Essayer trois semaines avant d'idéaliser",
                "Vendre les clés",
                "Oublier Aline",
            ],
            1,
            "« Je voudrais qu'ils essaient trois semaines. »",
        ),
        pairs=[
            ("si Léa s'installait", "elle s'adapterait"),
            ("plus calme / plus proche", "Seuil / Rive-des-Saules"),
            ("mettre en garde", "ne pas s'éloigner des restants"),
            ("compter sur", "Lila / Aline"),
        ],
        fill_item=("Pourriez-vous écrire chaque jeudi, bien que ce ___ loin ?", "soit"),
        words=["Tenir", "aux", "deux", "rives", "n'est", "pas", "hésiter", "."],
        anagram=("tiens", "Je… à ce figuier : ce lieu compte beaucoup pour moi."),
        error=(
            "Bien qu'elle est attachée au Seuil, Léa s'adapterait à Rive-des-Saules, et Patrick compterait sur Aline.",
            "Bien qu'elle soit attachée au Seuil, Léa s'adapterait à Rive-des-Saules, et Patrick compterait sur Aline.",
            "Bien que + subjonctif : soit, pas est.",
        ),
        pic_start=23,
        pic_words=["une radio", "une maison", "un bureau", "un nuage"],
        short_p="Imitez : une synthèse de dix lignes, comparaison, si, prépositionnels, une mise en garde.",
        audio="Lisez votre synthèse, sans aller trop vite.",
    ),
    _l(
        "EL",
        "EL — Synthèse : prépositionnels et conditionnel",
        "Relier les verbes prépositionnels, le conditionnel et les comparatifs du choix.",
        "Apprenez la fiche.",
        "Fiche de synthèse des deux rives",
        """Réemploi 1 — verbes : s'installer à/dans, s'habituer à, s'adapter à,
dépendre de, rêver de, tenir à, songer à, s'éloigner de, compter sur
Réemploi 2 — conditionnel : je voudrais, j'aimerais, pourriez-vous, on devrait
Réemploi 3 — si + imparfait → conditionnel : si je m'installais, je m'habituerais
Réemploi 4 — comparaison : plus calme que, plus proche que, moins loin que
Ne pas confondre : je serai (futur) / je serais (cond.)
je ferai (futur, 1 r) / je ferais (cond.)
je pourrai (futur, 2 r) / je pourrais (cond.)
Bien que + subjonctif : bien que ce soit loin, bien qu'elle tienne au figuier
À + le = au : au Seuil, au pavillon, au milieu du pont
Un choix déplace une rive ; il n'efface pas l'autre.
Mettre en garde reste utile : ailleurs n'est pas un palais.""",
        tf_item=(
            "« Je ferai » s'écrit avec deux r.",
            False,
            "Futur de faire : ferai, un seul r.",
        ),
        qcm_item=(
            "Quelle série est correcte ?",
            [
                "je serai (cond.) / je serais (futur)",
                "je pourai (futur) / je pourrais (cond.)",
                "je ferai (futur) / je serais (cond.)",
                "je faut / nous faudrait",
            ],
            2,
            "Ferai = futur. Serais = conditionnel.",
        ),
        pairs=[
            ("si je m'installais", "je m'habituerais"),
            ("tenir à", "un figuier / un jeudi"),
            ("bien que", "subjonctif"),
            ("plus calme que", "le Seuil à l'aube"),
        ],
        fill_item=("Demain, je ___ le choix. (faire, futur)", "ferai"),
        words=["Bien", "que", "ce", "soit", "loin", "nous", "écrirons", "."],
        anagram=("songer", "Y penser longtemps, sans décider encore, avant de partir."),
        error=(
            "Je ferrai le choix demain, et je tiendrai à vous écrire.",
            "Je ferai le choix demain, et je tiendrai à vous écrire.",
            "Futur de faire : ferai, un seul r.",
        ),
        pic_start=24,
        pic_words=["une maison", "un bureau", "un nuage", "un soleil"],
        short_p="Rédigez un mini-tableau : cinq verbes, cinq conditionnels, deux si, deux comparatifs.",
        audio="Enregistrez la fiche et quatre phrases de réemploi.",
    ),
]


# ---------------------------------------------------------------------------
# Séquence 6 — Écrire à ceux qui restent (lettre, politesse, deux rives)
# ---------------------------------------------------------------------------

S6 = [
    _l(
        "CO",
        "CO — Préparer la lettre du jeudi",
        "Comprendre comment on relie les deux rives par une lettre polie.",
        "Lisez le dialogue. À qui écrit-on, et quelles formules entend-on ?",
        "Cour du figuier, enveloppes ocre",
        """Aline : Vous écrirez à ceux qui restent : Rose, Joël, Marc, Hawa, et à moi.
Léa : J'aimerais commencer par « Chers amis du figuier », pas par un « salut » trop sec.
Patrick : Pourriez-vous relire la formule de clôture ? Je voudrais rester poli sans être raide.
Rose : On devrait raconter le pavillon sans idéaliser : le loyer, Noura, la brume du pont.
Joël : Tenez à nous dire l'heure où le minibus arrive, et les gens dont vous parlez.
Hawa : Comptez sur Radio Figuier si la lettre tarde ; Lila relayera un mot court.
Solange : Veuillez dater : Seuil ou Val-des-Peupliers, afin que l'on sache d'où vous parlez.
Karim : Si vous vous installiez vraiment, vous nous mettriez en garde contre nos illusions.
Mado : Reliez les deux rives : un détail d'ici, un détail de là-bas, dans chaque paragraphe.
Sami : Je voudrais que vous n'oubliiez pas le tambour du jeudi, même loin.
Yvette : Recevez, je vous prie… ou Bien à vous, selon le degré de proximité.
Lila : Une lettre polie n'est pas froide : elle tient à la personne, elle ne compte pas les lignes.""",
        tf_item=(
            "Léa préfère « Chers amis du figuier » à un salut trop sec.",
            True,
            "Première proposition de Léa.",
        ),
        qcm_item=(
            "Que fera Lila si la lettre tarde, d'après Hawa ?",
            [
                "Fermer le pavillon",
                "Relayer un mot court à la radio",
                "Cacher les enveloppes",
                "Interdire le jeudi",
            ],
            1,
            "Hawa : Radio Figuier relayera un mot court.",
        ),
        pairs=[
            ("chers amis du figuier", "ouverture"),
            ("veuillez dater", "Solange"),
            ("reliez les deux rives", "Mado"),
            ("bien à vous", "clôture proche"),
        ],
        fill_item=("Veuillez dater, afin que l'on sache ___ vous parlez.", "d'où"),
        words=["Chers", "amis", "du", "figuier", "nous", "vous", "écrivons", "."],
        anagram=("enveloppe", "Papier ocre où l'on glisse la lettre pour ceux de la cour."),
        error=(
            "Veuillez agréer, chers amis, mes salutations, et je vous écrit depuis le pavillon.",
            "Veuillez agréer, chers amis, mes salutations, et je vous écris depuis le pavillon.",
            "Présent : j'écris, pas je écrit.",
        ),
        pic_start=25,
        pic_words=["un bureau", "un nuage", "un soleil", "un figuier"],
        short_p="Notez trois formules d'ouverture ou de clôture et deux conseils pour relier les rives.",
        audio="Enregistrez : Chers amis du figuier. Pourriez-vous relire la clôture ? Nous tenons à vous écrire chaque jeudi.",
    ),
    _l(
        "CE",
        "CE — Lettre-modèle vers le figuier",
        "Lire une lettre polie qui relie Rive-des-Saules et le Seuil.",
        "Lisez la lettre, sans aller trop vite.",
        "Lettre de Léa et Patrick aux amis du figuier",
        """Val-des-Peupliers, Rive-des-Saules — jeudi
Chers amis du figuier,
Nous vous écrivons depuis le Pavillon du Saule, où le jardin sent déjà l'eau.
Nous aimerions que cette lettre tienne lieu de jeudi, bien que ce soit loin.
Le quartier dont nous commençons à nous souvenir s'appelle Rive-des-Saules ; le banc dont nous parlons encore, c'est le vôtre.
Si vous veniez trois jours, vous vous habitueriez au pont, et nous tiendrions à vous montrer Noura et Ibrahim.
Pourriez-vous dire à Solange que les tampons sont lisibles, et à Lila que nous comptons sur un mot radio si besoin ?
On devrait aussi rassurer Rose : nous ne nous éloignons pas de vous dans le cœur.
Patrick voudrait ajouter que le loyer dépend du jardin, pas d'un palais.
Recevez, chers amis, nos salutations fidèles. Bien à vous, sous le saule comme sous le figuier.
Léa Niyonzima et Patrick Habimana
Copie : Aline Uwase, Karim Bamba""",
        tf_item=(
            "La lettre dit que le loyer dépend d'un palais.",
            False,
            "Patrick : le loyer dépend du jardin, pas d'un palais.",
        ),
        qcm_item=(
            "Que devrait-on dire à Rose, d'après la lettre ?",
            [
                "Qu'ils vendent le figuier",
                "Qu'ils ne s'éloignent pas dans le cœur",
                "Que Radio Figuier ferme",
                "Que Karim refuse les clés",
            ],
            1,
            "« nous ne nous éloignons pas de vous dans le cœur. »",
        ),
        pairs=[
            ("chers amis du figuier", "ouverture"),
            ("le quartier dont", "ils se souviennent"),
            ("pourriez-vous dire", "Solange / Lila"),
            ("bien à vous", "clôture"),
        ],
        fill_item=("Nous aimerions que cette lettre tienne lieu de jeudi, bien que ce ___ loin.", "soit"),
        words=["Nous", "vous", "écrivons", "depuis", "le", "pavillon", "."],
        anagram=("formules", "Ouverture et clôture d'une lettre : veuillez, cordialement, bien à vous."),
        error=(
            "Nous vous embrassons fort, et on compte à votre réponse sous le figuier.",
            "Nous vous embrassons fort, et on compte sur votre réponse sous le figuier.",
            "Compter sur, pas compter à.",
        ),
        pic_start=26,
        pic_words=["un nuage", "un soleil", "un figuier", "une horloge"],
        short_p="Recopiez la lettre et soulignez politesse, où/dont, et les deux rives.",
        audio="Lisez la lettre-modèle, sans aller trop vite.",
    ),
    _l(
        "PO",
        "PO — Dire les formules de la lettre",
        "Prononcer des formules de politesse et relier à l'oral les deux rives.",
        "Répétez, puis dictez une mini-lettre à un ami du figuier.",
        "Modèles de Lila et d'Aline",
        """Chers amis du figuier,
Nous vous écrivons depuis l'autre rive.
Nous aimerions avoir de vos nouvelles.
Pourriez-vous lire cette lettre au banc, le jeudi ?
Nous tenons à vous rassurer : nous ne vous oublions pas.
Bien que ce soit loin, nous comptons sur vous.
Recevez, je vous prie, nos salutations fidèles.
Bien à vous.
Cordialement, si le ton est plus sage.
Aline : une formule n'est pas un masque ; elle protège le lien.
Patrick : relier, c'est un détail d'ici et un détail de là-bas.
Rose : on devrait finir par un prénom, pas par un silence.""",
        tf_item=(
            "« Recevez, je vous prie » est une clôture plus formelle que « Bien à vous ».",
            True,
            "Yvette et Lila distinguent les degrés de proximité.",
        ),
        qcm_item=(
            "Quelle ouverture convient aux amis du figuier ?",
            [
                "À qui de droit seulement",
                "Chers amis du figuier",
                "Urgent : partez",
                "Pas de formule",
            ],
            1,
            "Ouverture choisie par Léa et reprise ici.",
        ),
        pairs=[
            ("chers amis", "ouverture"),
            ("nous aimerions", "souhait"),
            ("pourriez-vous", "demande polie"),
            ("bien à vous", "clôture proche"),
        ],
        fill_item=("Nous tenons ___ vous rassurer.", "à"),
        words=["Recevez", "je", "vous", "prie", "nos", "salutations", "fidèles", "."],
        anagram=("relier", "Garder le lien entre les deux berges malgré la distance."),
        error=(
            "Je vous prie d'agréer cette lettre, et je tiens de ce lien entre les deux rives.",
            "Je vous prie d'agréer cette lettre, et je tiens à ce lien entre les deux rives.",
            "Tenir à un lien, pas tenir de.",
        ),
        pic_start=27,
        pic_words=["un soleil", "un figuier", "une horloge", "des critères"],
        short_p="Écrivez six formules : deux ouvertures, deux demandes, deux clôtures.",
        audio="Enregistrez les huit premières formules, puis une mini-lettre à vous.",
    ),
    _l(
        "PE",
        "PE — Ma lettre à ceux qui restent",
        "Écrire une lettre polie qui relie le Pavillon du Saule et le figuier.",
        "Imitez la lettre de Léa Niyonzima.",
        "Lettre de Léa, encre du jeudi",
        """Val-des-Peupliers, Pavillon du Saule
Chers amis du figuier — Rose, Joël, Marc, Hawa, Aline,
Je vous écris afin que vous soyez rassurés : nous nous habituons à l'eau, et nous tenons à vous.
Le quartier où nous dormons s'appelle Rive-des-Saules ; la cour dont nous parlons le soir, c'est encore la vôtre.
J'aimerais que vous lisiez cette lettre au banc, le jeudi, même s'il bruine.
Pourriez-vous dire à Solange et à Lila que nous comptons sur un mot, lettre ou radio ?
Si vous veniez, vous vous adapteriez au pont, et Patrick voudrait vous montrer le jardin du saule.
On devrait aussi prévenir Félicie : trois chambres, un loyer qui dépend du jardin.
Bien que ce soit loin, nous ne nous éloignons pas de vous.
Recevez, chers amis, nos salutations fidèles. Bien à vous, des deux rives.
Léa Niyonzima
Patrick signe aussi, un peu trop vite, de joie.""",
        tf_item=(
            "Léa demande qu'on lise la lettre au banc le jeudi.",
            True,
            "« que vous lisiez cette lettre au banc, le jeudi. »",
        ),
        qcm_item=(
            "De quoi le loyer dépend-il, dans la lettre de Léa ?",
            [
                "Du tambour",
                "Du jardin",
                "De Port-de-Brume",
                "D'un palais",
            ],
            1,
            "« un loyer qui dépend du jardin. »",
        ),
        pairs=[
            ("chers amis du figuier", "ouverture"),
            ("le quartier où", "ils dorment"),
            ("pourriez-vous dire", "Solange et Lila"),
            ("bien à vous", "des deux rives"),
        ],
        fill_item=("Je vous écris afin que vous ___ rassurés. (être, subj.)", "soyez"),
        words=["Bien", "que", "ce", "soit", "loin", "nous", "tenons", "à", "vous", "."],
        anagram=("figuier", "L'arbre de la cour : on écrit à ceux qui restent dessous."),
        error=(
            "Chers amis du figuier, je vous écris afin que vous soyez rassurés, et je m'habitue de l'odeur du saule.",
            "Chers amis du figuier, je vous écris afin que vous soyez rassurés, et je m'habitue à l'odeur du saule.",
            "S'habituer à, pas s'habituer de.",
        ),
        pic_start=28,
        pic_words=["un figuier", "une horloge", "des critères", "une carte"],
        short_p="Imitez : une lettre de dix à douze lignes, polie, qui relie les deux rives.",
        audio="Lisez votre lettre, sans aller trop vite.",
    ),
    _l(
        "EL",
        "EL — Politesse de la lettre et lien des rives",
        "Retenir les formules de lettre et les articulations qui relient deux lieux.",
        "Apprenez la fiche.",
        "Fiche de Lila, lettres du jeudi",
        """Ouvertures : Chers amis, Chère Aline, Chers amis du figuier
Souhaits : nous aimerions, je voudrais que + subjonctif (je voudrais que vous soyez)
Demandes : pourriez-vous + infinitif ? ; je vous prie de…
Lien : afin que + subj. ; bien que + subj. ; même si + indicatif
Relier les rives : un détail d'ici + un détail de là-bas ; où / dont pour les souvenirs
Clôtures : Recevez, je vous prie, nos salutations ; Bien à vous ; Cordialement
Date et lieu : Val-des-Peupliers, Rive-des-Saules — jeudi / Seuil des Sources
À + le = au Seuil, au pavillon. De + le = du jardin, du figuier.
Ne pas écrire : je vous écrit. On écrit : je vous écris.
Compter sur une réponse, tenir à un lien, s'habituer à un silence nouveau.
Une lettre polie n'est pas froide : elle protège ceux qui restent et ceux qui partent.""",
        tf_item=(
            "On écrit « je vous écrit » à la première personne.",
            False,
            "Je vous écris.",
        ),
        qcm_item=(
            "« Afin que vous soyez rassurés » emploie…",
            [
                "l'indicatif futur",
                "le subjonctif",
                "l'impératif seulement",
                "le passé composé",
            ],
            1,
            "Afin que + subjonctif.",
        ),
        pairs=[
            ("chers amis", "ouverture"),
            ("afin que / bien que", "subjonctif"),
            ("pourriez-vous", "demande"),
            ("bien à vous", "clôture"),
        ],
        fill_item=("Je vous ___ depuis le pavillon. (écrire, présent)", "écris"),
        words=["Recevez", "je", "vous", "prie", "nos", "salutations", "."],
        anagram=("politesse", "Ton d'une lettre : formules pour ne pas brusquer ceux qui restent."),
        error=(
            "À le Seuil, le figuier attend encore vos nouvelles, et nous relions les deux rives.",
            "Au Seuil, le figuier attend encore vos nouvelles, et nous relions les deux rives.",
            "À + le = au.",
        ),
        pic_start=29,
        pic_words=["une horloge", "des critères", "une carte", "une valise"],
        short_p="Rédigez un tableau : ouvertures, souhaits, demandes, liens (afin que / bien que), clôtures.",
        audio="Enregistrez la fiche et une mini-lettre de cinq lignes.",
    ),
]


SEQUENCES = [
    {"title": "Choisir un lieu de vie", "lessons": S1},
    {"title": "Formuler un souhait", "lessons": S2},
    {"title": "Un quartier à caractériser", "lessons": S3},
    {"title": "Souvenirs d'arrivée", "lessons": S4},
    {"title": "Deux rives, un choix", "lessons": S5},
    {"title": "Écrire à ceux qui restent", "lessons": S6},
]
