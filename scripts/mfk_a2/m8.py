"""A2 Module 8 — Le monde en direct (univers Seuil des Sources)."""

from factory import L

IMG = "mfk-a2-m8"
IMG_DIR = IMG

MODULE = {
    "title": "A2 — Le monde en direct",
    "description": (
        "Grande étape A2-8 : raconter un fait à la voix passive, nominaliser "
        "une info, réagir avec le gérondif, suggérer au conditionnel, "
        "espérer au subjonctif et parler d'un livre avec on — depuis le "
        "studio de Radio Figuier, émission « Le monde en direct », "
        "au Seuil des Sources (Rukiri-Nord)."
    ),
}


def _l(comp, title, obj, cons, st, sp, **kw):
    return L(IMG, comp, title, obj, cons, st, sp, **kw)


# ---------------------------------------------------------------------------
# Séquence 1 — Un fait à raconter (forme passive)
# ---------------------------------------------------------------------------

S1 = [
    _l(
        "CO",
        "CO — Ouverture d'antenne",
        "Repérer le passif : être + participe (a été + PP) et le complément d'agent par.",
        "Lisez le dialogue (à écouter avec l'enseignant). Qui fait ? Qu'est-ce qui est fait ?",
        "Studio de Radio Figuier, casque de Léa",
        """Léa : Bonjour. Ici Radio Figuier, « Le monde en direct ».
Marc : Le pont des Herbes a été réparé hier. Il a été consolidé par Dieudonné.
Aline : La nouvelle a été lue à sept heures. Elle a été reprise par Hawa.
Patrick : Deux tuteurs ont été plantés. Ils ont été choisis par Rose.
Joël : Le micro a été testé. Il n'a pas encore été rangé.
Hawa : Une page a été tamponnée au Bureau des Escales. Elle a été signée par Solange.
Karim : Le bulletin a été écrit ce matin. Il sera relu avant l'antenne.
Lila : Rien n'a été inventé : chaque fait a été vérifié.
Yvette : L'infirmerie a été ouverte plus tôt. Elle a été préparée par Noura.""",
        tf_item=(
            "Le pont a été réparé : le pont est l'objet du verbe, pas l'auteur.",
            True,
            "Passif : on met en avant le fait, pas forcément l'auteur.",
        ),
        qcm_item=(
            "Par qui les tuteurs ont-ils été choisis ?",
            ["Marc", "Rose", "Kévin", "Ibrahim"],
            1,
            "Patrick : « choisis par Rose. »",
        ),
        pairs=[
            ("a été réparé", "le pont"),
            ("a été lue", "la nouvelle"),
            ("ont été plantés", "deux tuteurs"),
            ("par Dieudonné", "agent"),
        ],
        fill_item=("Le pont des Herbes ___ été réparé hier.", "a"),
        words=["La", "nouvelle", "a", "été", "lue", "."],
        anagram=("repare", "Le pont l'a été hier (sans accent)."),
        error=(
            "Le pont a réparé hier par Dieudonné.",
            "Le pont a été réparé hier par Dieudonné.",
            "Passif : être + participe.",
        ),
        pic_start=0,
        pic_words=["la voix passive", "un journal", "un micro", "un titre"],
        short_p="Notez cinq passifs et, s'il y en a, l'agent (par…).",
        audio="Enregistrez : Le pont a été réparé. La nouvelle a été lue. Deux tuteurs ont été plantés.",
    ),
    _l(
        "CE",
        "CE — Feuille de une",
        "Lire un bulletin local entièrement au passif.",
        "Lisez la feuille, sans aller trop vite.",
        "Feuille de une, Radio Figuier",
        """Le monde en direct — bulletin du Seuil
Le marché des Lampions a été ouvert à l'aube. Il a été tenu par Mado et Sami.
Une barque a été trouvée près du lac des Nénuphars. Elle a été ramenée par Benoît.
Le Cahier des racines a été relu. Trois noms ont été ajoutés.
L'Atelier du Tissu a été visité. Un coupon ocre a été offert par Dieudonné.
Aucune rumeur n'a été confirmée. Chaque phrase a été pesée.
Prochaine émission : le fait sera raconté de nouveau à midi.
Studio Figuier — Rukiri-Nord""",
        tf_item=(
            "La barque a été ramenée par Benoît.",
            True,
            "Deuxième fait du bulletin.",
        ),
        qcm_item=(
            "Qu'est-ce qui a été offert par Dieudonné ?",
            ["Une barque", "Un coupon ocre", "Un micro", "Un tuteur"],
            1,
            "« Un coupon ocre a été offert. »",
        ),
        pairs=[
            ("a été ouvert", "marché"),
            ("a été trouvée", "barque"),
            ("ont été ajoutés", "trois noms"),
            ("a été pesée", "chaque phrase"),
        ],
        fill_item=("Trois noms ont ___ ajoutés.", "été"),
        words=["Aucune", "rumeur", "n'a", "été", "confirmée", "."],
        anagram=("barque", "Elle a été trouvée près du lac."),
        error=(
            "Une barque a trouvé près du lac par Benoît.",
            "Une barque a été trouvée près du lac des Nénuphars.",
            "Passif féminin : a été trouvée.",
        ),
        pic_start=4,
        pic_words=["une nominalisation", "des mots", "un cahier", "une antenne"],
        short_p="Recopiez le bulletin et encadrez été + participe.",
        audio="Lisez le bulletin, sans aller trop vite.",
    ),
    _l(
        "PO",
        "PO — Dire a été + participe",
        "Passer de l'actif au passif à l'oral.",
        "Répétez, puis transformez deux faits du Seuil.",
        "Modèles de Marc",
        """Le pont a été réparé.
La nouvelle a été lue.
Les tuteurs ont été plantés.
Le micro a été testé.
La page a été signée.
Rien n'a été inventé.
Le fait sera raconté.
Il a été consolidé par Dieudonné.""",
        tf_item=(
            "Au passif, le participe s'accorde avec le sujet.",
            True,
            "La nouvelle a été lue. Les tuteurs ont été plantés.",
        ),
        qcm_item=(
            "« Dieudonné a réparé le pont » au passif, c'est…",
            [
                "Dieudonné a été réparé par le pont",
                "Le pont a été réparé par Dieudonné",
                "Le pont a réparé Dieudonné",
                "Le pont est réparer",
            ],
            1,
            "Objet → sujet. Agent : par.",
        ),
        pairs=[
            ("être + PP", "passif"),
            ("par + nom", "agent"),
            ("accord", "avec le sujet"),
            ("sera raconté", "passif futur"),
        ],
        fill_item=("Les tuteurs ___ été plantés.", "ont"),
        words=["Le", "micro", "a", "été", "testé", "."],
        anagram=("agent", "Le complément introduit par par."),
        error=(
            "La nouvelle a été lu à sept heures.",
            "La nouvelle a été lue à sept heures.",
            "Sujet féminin : lue.",
        ),
        pic_start=8,
        pic_words=["le gérondif", "deux actions", "un vélo", "une main"],
        short_p="Transformez six phrases actives en passif.",
        audio="Enregistrez les huit modèles, puis deux transformations.",
    ),
    _l(
        "PE",
        "PE — Mon fait du jour",
        "Écrire un mini-bulletin au passif.",
        "Imitez le fait de Hawa.",
        "Fait de Hawa Diallo",
        """Hawa Diallo
Ce matin, la Table des Sources a été nettoyée.
Deux seaux ont été remplis. Ils ont été posés par Joël.
La nouvelle a été lue à Radio Figuier. Elle a été notée par Léa.
Rien n'a été oublié. Le cahier a été refermé.
Hawa
Émission « Le monde en direct »""",
        tf_item=(
            "Les seaux ont été posés par Léa.",
            False,
            "« Ils ont été posés par Joël. »",
        ),
        qcm_item=(
            "Qui a noté la nouvelle ?",
            ["Marc", "Léa", "Karim", "Mado"],
            1,
            "« notée par Léa. »",
        ),
        pairs=[
            ("a été nettoyée", "Table des Sources"),
            ("ont été remplis", "seaux"),
            ("a été lue", "nouvelle"),
            ("a été refermé", "cahier"),
        ],
        fill_item=("Rien n'___ été oublié.", "a"),
        words=["Deux", "seaux", "ont", "été", "remplis", "."],
        anagram=("nettoyee", "La table l'a été ce matin (sans accent)."),
        error=(
            "La Table des Sources a été nettoyé.",
            "La Table des Sources a été nettoyée.",
            "Table : féminin → nettoyée.",
        ),
        pic_start=12,
        pic_words=["une suggestion", "une bulle", "un carnet", "une table"],
        short_p="Imitez : cinq phrases au passif, un agent au moins.",
        audio="Lisez votre fait, une phrase, une pause, sans aller trop vite.",
    ),
    _l(
        "EL",
        "EL — Forme passive",
        "Retenir être + participe, l'accord, et par + agent.",
        "Apprenez la fiche.",
        "Fiche du studio",
        """Actif : Dieudonné a réparé le pont.
Passif : Le pont a été réparé (par Dieudonné).
Temps : a été + PP (passé). est + PP (présent). sera + PP (futur).
Accord du PP avec le sujet : la nouvelle a été lue ; les noms ont été ajoutés.
Agent facultatif : par + personne. Sans agent : Le pont a été réparé.
On choisit le passif pour mettre le fait en avant, comme à la radio.
Pas : le pont a réparé (si le pont n'est pas l'auteur).""",
        tf_item=(
            "L'agent est obligatoire au passif.",
            False,
            "On peut dire : Le pont a été réparé.",
        ),
        qcm_item=(
            "Quelle forme est un passif au passé ?",
            ["a réparé", "a été réparé", "répare", "va réparer"],
            1,
            "A été + PP.",
        ),
        pairs=[
            ("être + PP", "passif"),
            ("par", "agent"),
            ("accord", "sujet"),
            ("sans agent", "fait seul"),
        ],
        fill_item=("Le fait ___ raconté à midi. (futur passif)", "sera"),
        words=["Le", "pont", "a", "été", "réparé", "."],
        anagram=("passif", "La voix qui met le fait en sujet."),
        error=(
            "Deux tuteurs a été planté.",
            "Deux tuteurs ont été plantés.",
            "Pluriel : ont été plantés.",
        ),
        pic_start=16,
        pic_words=["le subjonctif", "un monde", "un cœur", "un nuage"],
        short_p="Tableau : six verbes, actif / passif, accord.",
        audio="Enregistrez la fiche et six passifs.",
    ),
]


# ---------------------------------------------------------------------------
# Séquence 2 — Info du jour (nominalisation)
# ---------------------------------------------------------------------------

S2 = [
    _l(
        "CO",
        "CO — Des verbes, des noms",
        "Repérer la nominalisation : décider → la décision, annoncer → l'annonce…",
        "Lisez le dialogue. Quel nom vient de quel verbe ?",
        "Salle des Herbes, carnets ouverts",
        """Léa : On a décidé d'ouvrir plus tôt. Voici la décision.
Marc : Patrick a proposé un titre. J'aime la proposition.
Aline : Solange a annoncé l'heure. L'annonce est au tableau.
Hawa : On protège le figuier. La protection continue.
Joël : Rose a choisi le micro bleu. Le choix est clair.
Karim : Ils ont ouvert le studio. L'ouverture était calme.
Lila : On a fermé la fenêtre. La fermeture a réduit le vent.
Yvette : Marc a présenté les faits. Sa présentation était nette.
Ibrahim : On informe le Seuil. L'information passe à huit heures.""",
        tf_item=(
            "Décider donne le nom décision.",
            True,
            "Léa : voici la décision.",
        ),
        qcm_item=(
            "Quel nom correspond à choisir ?",
            ["la chose", "le choix", "la choisie", "le choisiement"],
            1,
            "Choisir → le choix.",
        ),
        pairs=[
            ("décider", "la décision"),
            ("proposer", "la proposition"),
            ("protéger", "la protection"),
            ("ouvrir / fermer", "l'ouverture / la fermeture"),
        ],
        fill_item=("On a décidé → voici la ___.", "décision"),
        words=["Le", "choix", "est", "clair", "."],
        anagram=("annonce", "Solange l'a faite : l'… de l'heure."),
        error=(
            "On a décidé : voici le décider du matin.",
            "On a décidé d'ouvrir plus tôt. Voici la décision.",
            "Le nom, c'est la décision.",
        ),
        pic_start=4,
        pic_words=["une nominalisation", "des mots", "un cahier", "une antenne"],
        short_p="Notez huit couples verbe → nom entendus.",
        audio="Enregistrez : On a décidé. Voici la décision. On protège. La protection continue. Rose a choisi. Le choix est clair.",
    ),
    _l(
        "CE",
        "CE — Fil d'infos",
        "Lire un fil où chaque verbe est repris par un nom.",
        "Lisez le fil, sans aller trop vite.",
        "Cahier d'infos, Radio Figuier",
        """Fil du matin
1. Décider d'avancer l'émission → la décision d'Aline.
2. Proposer un invité (Dieudonné) → la proposition de Marc.
3. Annoncer le vent à Rive d'Orage → l'annonce de Lila.
4. Protéger les jeunes plants → la protection de Joël.
5. Arriver de Mwezi-Haut → l'arrivée de Karim.
6. Présenter le bulletin → la présentation de Léa.
7. Informer la Maison des Vents → l'information de Solange.
Aucun nom n'est copié d'ailleurs : tout est né au Seuil.""",
        tf_item=(
            "L'arrivée concerne Karim, venu de Mwezi-Haut.",
            True,
            "Point 5.",
        ),
        qcm_item=(
            "À qui appartient la proposition ?",
            ["Aline", "Marc", "Joël", "Yvette"],
            1,
            "« la proposition de Marc. »",
        ),
        pairs=[
            ("décider", "décision"),
            ("arriver", "arrivée"),
            ("présenter", "présentation"),
            ("informer", "information"),
        ],
        fill_item=("Protéger → la ___.", "protection"),
        words=["L'annonce", "de", "Lila", "parle", "du", "vent", "."],
        anagram=("arrivee", "Le nom de arriver (sans accent)."),
        error=(
            "Décider d'avancer : voici le décision.",
            "Décider d'avancer l'émission → la décision d'Aline.",
            "Décision est féminin : la.",
        ),
        pic_start=1,
        pic_words=["un journal", "un micro", "un titre", "une nominalisation"],
        short_p="Recopiez le fil et ajoutez deux couples verbe → nom.",
        audio="Lisez les sept points du fil, sans aller trop vite.",
    ),
    _l(
        "PO",
        "PO — Dire le nom du verbe",
        "Remplacer un verbe d'action par son nom à l'oral.",
        "Répétez, puis nominalisez deux infos à vous.",
        "Modèles de Léa",
        """On a décidé. C'est la décision.
Il a proposé. C'est la proposition.
Elle a annoncé. C'est l'annonce.
Nous protégeons. C'est la protection.
Vous avez choisi. C'est le choix.
Ils ont ouvert. C'est l'ouverture.
J'ai fermé. C'est la fermeture.
Tu as informé. C'est l'information.""",
        tf_item=(
            "Beaucoup de noms en -tion viennent d'un verbe.",
            True,
            "Décision, proposition, protection, information.",
        ),
        qcm_item=(
            "« Ouvrir » donne…",
            ["l'ouvert", "l'ouverture", "l'ouvrance", "le ouvrir"],
            1,
            "L'ouverture.",
        ),
        pairs=[
            ("-er → souvent -tion", "décider / décision"),
            ("choisir", "le choix"),
            ("arriver", "l'arrivée"),
            ("fermer", "la fermeture"),
        ],
        fill_item=("Ils ont ouvert → c'est l'___.", "ouverture"),
        words=["C'est", "la", "proposition", "."],
        anagram=("fermeture", "Le nom qui suit : j'ai fermé."),
        error=(
            "Vous avez choisi : c'est la choisement.",
            "Vous avez choisi. C'est le choix.",
            "Choisir → le choix.",
        ),
        pic_start=20,
        pic_words=["un livre", "le pronom on", "un lecteur", "une couverture"],
        short_p="Écrivez huit phrases : verbe, puis nom.",
        audio="Enregistrez les huit modèles, puis deux nominalisations.",
    ),
    _l(
        "PE",
        "PE — Mon fil d'infos",
        "Écrire un fil d'infos qui nominalise chaque verbe.",
        "Imitez le fil de Patrick.",
        "Fil de Patrick Habimana",
        """Patrick Habimana
J'ai décidé de parler du pont : voici ma décision.
Marc a proposé l'ordre des faits : sa proposition est juste.
Léa a annoncé l'heure : l'annonce a circulé.
On protège encore la rive : la protection continue.
J'ai choisi un mot simple : le choix aide les auditeurs.
Patrick
Radio Figuier""",
        tf_item=(
            "Patrick a choisi un mot compliqué.",
            False,
            "« un mot simple : le choix aide… »",
        ),
        qcm_item=(
            "Quel nom reprend « j'ai décidé » ?",
            ["la proposition", "la décision", "l'ouverture", "le choix"],
            1,
            "« voici ma décision. »",
        ),
        pairs=[
            ("décidé", "décision"),
            ("proposé", "proposition"),
            ("annoncé", "annonce"),
            ("choisi", "choix"),
        ],
        fill_item=("On protège encore la rive : la ___ continue.", "protection"),
        words=["Voici", "ma", "décision", "."],
        anagram=("auditeurs", "Le choix simple les aide, à la radio."),
        error=(
            "J'ai décidé : voici mon décider.",
            "J'ai décidé de parler du pont : voici ma décision.",
            "Nom : la décision.",
        ),
        pic_start=24,
        pic_words=["un studio", "une carte", "une horloge", "une feuille"],
        short_p="Imitez : cinq lignes, cinq nominalisations.",
        audio="Lisez votre fil, sans aller trop vite.",
    ),
    _l(
        "EL",
        "EL — Nominalisation",
        "Retenir comment passer du verbe au nom.",
        "Apprenez la fiche.",
        "Fiche d'Aline",
        """Verbe → nom
décider → la décision ; proposer → la proposition ; présenter → la présentation
annoncer → l'annonce ; informer → l'information
protéger → la protection ; choisir → le choix
ouvrir → l'ouverture ; fermer → la fermeture ; arriver → l'arrivée
Souvent : -er → -tion / -sion. Parfois un nom court : le choix, l'annonce.
Article : la / l' / le. On ne laisse pas le verbe tel quel comme nom.""",
        tf_item=(
            "Tous les noms viennent d'un verbe en -tion.",
            False,
            "Le choix, l'annonce : d'autres formes.",
        ),
        qcm_item=(
            "« Arriver » donne…",
            ["l'arrivage seulement", "l'arrivée", "le arriver", "l'arrivé"],
            1,
            "L'arrivée.",
        ),
        pairs=[
            ("décider", "décision"),
            ("choisir", "choix"),
            ("ouvrir", "ouverture"),
            ("annoncer", "annonce"),
        ],
        fill_item=("Informer → l'___.", "information"),
        words=["C'est", "l'ouverture", "du", "studio", "."],
        anagram=("suffixe", "Souvent -tion : un… du verbe."),
        error=(
            "Protéger le figuier : voici le protéger du Seuil.",
            "On protège le figuier. Voici la protection.",
            "Nom : la protection.",
        ),
        pic_start=26,
        pic_words=["une horloge", "une feuille", "un casque", "une fenêtre"],
        short_p="Listez douze verbes d'info et leur nom.",
        audio="Enregistrez la fiche et douze couples.",
    ),
]


# ---------------------------------------------------------------------------
# Séquence 3 — Réagir avec justesse (gérondif)
# ---------------------------------------------------------------------------

S3 = [
    _l(
        "CO",
        "CO — En parlant, en écoutant",
        "Repérer le gérondif : en + participe présent (en marchant, en écoutant).",
        "Lisez le dialogue. Quelles actions se font en même temps ?",
        "Couloir du studio, casques à la main",
        """Léa : En ouvrant l'antenne, souriez. En parlant, regardez le voyant ocre.
Marc : J'ai compris en écoutant Hawa. J'ai noté en relisant le fil.
Aline : En marchant vers le micro, on respire. En respirant, on pose la voix.
Patrick : Joël est tombé en courant. Il a réagi en riant, pas en criant.
Rose : En signant, elle a regardé Rose… non : Hawa a regardé Rose en signant.
Karim : On informe en précisant la source. On corrige en restant calmes.
Lila : Tout en écoutant, j'ai préparé l'eau. Deux actions ensemble.
Yvette : En fermant la porte, baissez la voix. En partant, rangez le casque.
Noura : Je me suis trompée en lisant trop vite. J'ai rattrapé en répétant.""",
        tf_item=(
            "Le gérondif commence par en + forme en -ant.",
            True,
            "En ouvrant, en parlant, en écoutant.",
        ),
        qcm_item=(
            "Comment Joël a-t-il réagi ?",
            ["En criant", "En riant", "En dormant", "En payant"],
            1,
            "« en riant, pas en criant. »",
        ),
        pairs=[
            ("en ouvrant", "sourire"),
            ("en écoutant", "comprendre"),
            ("en courant", "tomber"),
            ("en répétant", "rattraper"),
        ],
        fill_item=("J'ai compris ___ écoutant Hawa.", "en"),
        words=["En", "parlant", "regardez", "le", "voyant", "."],
        anagram=("voyant", "Le petit feu ocre du studio."),
        error=(
            "J'ai compris à écouter Hawa.",
            "J'ai compris en écoutant Hawa.",
            "Gérondif : en + -ant.",
        ),
        pic_start=8,
        pic_words=["le gérondif", "deux actions", "un vélo", "une main"],
        short_p="Notez six gérondifs et l'action principale à côté.",
        audio="Enregistrez : En ouvrant l'antenne, souriez. J'ai compris en écoutant. En marchant, on respire.",
    ),
    _l(
        "CE",
        "CE — Consignes d'antenne",
        "Lire des consignes construites avec le gérondif.",
        "Lisez les consignes, sans aller trop vite.",
        "Feuille collée, studio Figuier",
        """Consignes — réagir avec justesse
1. En arrivant, saluez. En partant, remerciez.
2. En lisant un nom, articulez. En hésitant, respirez.
3. On ne corrige pas en humiliant. On précise en restant doux.
4. En entendant une rumeur, vérifiez. En doutant, dites-le.
5. Tout en écoutant l'invité, notez un mot-clé.
6. En fermant l'émission, rappelez le Cahier du chemin.
Léa et Marc — Radio Figuier""",
        tf_item=(
            "On peut corriger en humiliant, d'après la feuille.",
            False,
            "« On ne corrige pas en humiliant. »",
        ),
        qcm_item=(
            "Que fait-on en doutant ?",
            ["On cache", "On le dit", "On rit seulement", "On ferme le pont"],
            1,
            "« En doutant, dites-le. »",
        ),
        pairs=[
            ("en arrivant", "saluer"),
            ("en hésitant", "respirer"),
            ("en doutant", "dire"),
            ("en fermant", "rappeler le cahier"),
        ],
        fill_item=("Tout ___ écoutant l'invité, notez un mot-clé.", "en"),
        words=["En", "hésitant", "respirez", "."],
        anagram=("articulez", "On le fait en lisant un nom."),
        error=(
            "En arriver, saluez.",
            "En arrivant, saluez.",
            "Gérondif : en + -ant, pas l'infinitif.",
        ),
        pic_start=28,
        pic_words=["un casque", "une fenêtre", "la voix passive", "un journal"],
        short_p="Recopiez et transformez deux consignes en « on + gérondif ».",
        audio="Lisez les six consignes, sans aller trop vite.",
    ),
    _l(
        "PO",
        "PO — Dire en + -ant",
        "Réagir à l'oral en enchaînant deux actions avec le gérondif.",
        "Répétez, puis racontez deux gestes faits en même temps.",
        "Modèles de Marc",
        """En ouvrant, je souris.
En parlant, je regarde le voyant.
J'ai compris en écoutant.
Il est tombé en courant.
On informe en précisant.
On corrige en restant calmes.
Tout en écoutant, je note.
En partant, je range.""",
        tf_item=(
            "« Tout en » insiste sur la simultanéité.",
            True,
            "Tout en écoutant, je note.",
        ),
        qcm_item=(
            "Quelle forme est un gérondif ?",
            ["pour écouter", "en écoutant", "à écouter", "d'écouter"],
            1,
            "En + -ant.",
        ),
        pairs=[
            ("en + -ant", "gérondif"),
            ("simultanéité", "en même temps"),
            ("manière", "en précisant / en riant"),
            ("tout en", "deux actions ensemble"),
        ],
        fill_item=("Il est tombé ___ courant.", "en"),
        words=["Tout", "en", "écoutant", "je", "note", "."],
        anagram=("simultane", "Deux actions en même temps (sans accent)."),
        error=(
            "J'ai compris pour écoutant Hawa.",
            "J'ai compris en écoutant Hawa.",
            "Pas pour + -ant. En + -ant.",
        ),
        pic_start=12,
        pic_words=["une suggestion", "une bulle", "un carnet", "une table"],
        short_p="Écrivez huit phrases au gérondif : quatre manières, quatre simultanées.",
        audio="Enregistrez les huit modèles, puis deux réactions à vous.",
    ),
    _l(
        "PE",
        "PE — Mes réactions",
        "Écrire des réactions justes avec le gérondif.",
        "Imitez la liste de Rose.",
        "Réactions de Rose Iradukunda",
        """Rose Iradukunda
En entendant une rumeur, je vérifie.
En parlant au micro, je regarde Léa.
J'ai compris le vent en écoutant Lila.
On corrige en restant doux, jamais en humiliant.
Tout en notant, je respire.
En fermant, je remercie les auditeurs du Seuil.
Rose
Radio Figuier""",
        tf_item=(
            "Rose humilie quand elle corrige.",
            False,
            "« jamais en humiliant. »",
        ),
        qcm_item=(
            "Comment Rose a-t-elle compris le vent ?",
            ["En criant", "En écoutant Lila", "En courant", "En payant"],
            1,
            "« en écoutant Lila. »",
        ),
        pairs=[
            ("en entendant", "vérifier"),
            ("en parlant", "regarder Léa"),
            ("en écoutant", "comprendre"),
            ("en fermant", "remercier"),
        ],
        fill_item=("Tout ___ notant, je respire.", "en"),
        words=["En", "entendant", "une", "rumeur", "je", "vérifie", "."],
        anagram=("rumeur", "En l'entendant, Rose vérifie."),
        error=(
            "En entendre une rumeur, je vérifie.",
            "En entendant une rumeur, je vérifie.",
            "Entendant, pas entendre.",
        ),
        pic_start=16,
        pic_words=["le subjonctif", "un monde", "un cœur", "un nuage"],
        short_p="Imitez : six lignes, six gérondifs.",
        audio="Lisez vos réactions, sans aller trop vite.",
    ),
    _l(
        "EL",
        "EL — Le gérondif",
        "Retenir en + -ant : simultanéité, manière, et quelques orthographes.",
        "Apprenez la fiche.",
        "Fiche de Léa",
        """Gérondif = en + participe présent
parler → en parlant ; écouter → en écoutant ; ouvrir → en ouvrant
Verbes en -ger : en mangeant (e garde). -cer : en commençant (ç).
Sens 1 : en même temps. Sens 2 : manière (en précisant, en riant).
tout en + -ant : deux actions ensemble, parfois un léger contraste.
Ne pas confondre : pour + infinitif (but) et en + -ant (manière / temps).
Un seul sujet : En partant, rangez (vous partez et vous rangez).""",
        tf_item=(
            "« Pour écouter » est un gérondif.",
            False,
            "Pour + infinitif = but. Gérondif = en écoutant.",
        ),
        qcm_item=(
            "« Commencer » au gérondif s'écrit…",
            ["en commencant", "en commençant", "en commencent", "en commencer"],
            1,
            "Ç devant a : commençant.",
        ),
        pairs=[
            ("en + -ant", "forme"),
            ("pour + inf.", "but"),
            ("tout en", "ensemble"),
            ("un sujet", "même personne"),
        ],
        fill_item=("Pour le but on dit pour + infinitif ; pour la manière : ___ + -ant.", "en"),
        words=["En", "commençant", "souriez", "."],
        anagram=("maniere", "En précisant, en riant : le sens… (sans accent)."),
        error=(
            "En commencant l'antenne, souriez.",
            "En commençant l'antenne, souriez.",
            "Commencer : ç devant a.",
        ),
        pic_start=20,
        pic_words=["un livre", "le pronom on", "un lecteur", "une couverture"],
        short_p="Conjuguez huit verbes au gérondif avec une phrase chacun.",
        audio="Enregistrez la fiche et huit gérondifs.",
    ),
]


# ---------------------------------------------------------------------------
# Séquence 4 — Des suggestions à faire (conditionnel, suggérer / proposer de)
# ---------------------------------------------------------------------------

S4 = [
    _l(
        "CO",
        "CO — Autour de la table d'idées",
        "Repérer le conditionnel de suggestion : je suggérerais de, on pourrait, je proposerais de.",
        "Lisez le dialogue. Quelles idées sont des suggestions, pas des ordres ?",
        "Table des idées, studio",
        """Marc : Je suggérerais de commencer par le pont. On pourrait attendre Hawa.
Léa : Je proposerais de lire le titre deux fois. Tu devrais articuler.
Aline : Il vaudrait mieux vérifier chez Solange. On devrait noter l'heure.
Patrick : Je te conseillerais de baisser le micro. On pourrait sourire davantage.
Hawa : Et si on invitait Dieudonné ? Je suggérerais de lui laisser trois minutes.
Joël : On pourrait parler plus lentement. Je proposerais de couper les rumeurs.
Rose : J'aimerais qu'on respire. On devrait remercier Yvette.
Karim : Je ne donnerais pas un ordre. Je suggérerais seulement.
Lila : On pourrait ouvrir la fenêtre. Il vaudrait mieux éviter le vent trop fort.""",
        tf_item=(
            "« Je suggérerais de » est plus doux qu'un impératif.",
            True,
            "Suggestion au conditionnel.",
        ),
        qcm_item=(
            "Que propose Léa pour le titre ?",
            ["De le cacher", "De le lire deux fois", "De le vendre", "De le crier"],
            1,
            "« Je proposerais de lire le titre deux fois. »",
        ),
        pairs=[
            ("je suggérerais de", "commencer / lui laisser"),
            ("on pourrait", "attendre / sourire / parler"),
            ("je proposerais de", "lire / couper"),
            ("il vaudrait mieux", "vérifier / éviter"),
        ],
        fill_item=("Je suggérerais ___ commencer par le pont.", "de"),
        words=["On", "pourrait", "attendre", "Hawa", "."],
        anagram=("suggérerais", "Marc le dit pour commencer par le pont."),
        error=(
            "Je suggérerais à commencer par le pont.",
            "Je suggérerais de commencer par le pont.",
            "Suggérer de + infinitif.",
        ),
        pic_start=12,
        pic_words=["une suggestion", "une bulle", "un carnet", "une table"],
        short_p="Listez six suggestions et l'outil (pourrait / suggérerais / vaudrait).",
        audio="Enregistrez : Je suggérerais de commencer par le pont. On pourrait attendre Hawa. Je proposerais de lire le titre deux fois.",
    ),
    _l(
        "CE",
        "CE — Carnet de propositions",
        "Lire un carnet de suggestions au conditionnel.",
        "Lisez le carnet, sans aller trop vite.",
        "Carnet de Marc Nkurunziza",
        """Propositions — émission de midi
1. Je suggérerais de laisser un silence après chaque fait.
2. On pourrait inviter Lila pour le vent de Rive d'Orage.
3. Je proposerais de répéter les noms propres une fois.
4. Il vaudrait mieux ne pas crier « urgent » sans preuve.
5. Tu devrais regarder Léa avant d'ouvrir le micro.
6. On devrait remercier le Bureau des Escales.
Rien n'est un ordre. Tout est une idée, au Seuil.""",
        tf_item=(
            "Le carnet autorise à crier « urgent » sans preuve.",
            False,
            "« Il vaudrait mieux ne pas crier « urgent » sans preuve. »",
        ),
        qcm_item=(
            "Qui pourrait-on inviter pour le vent ?",
            ["Ibrahim", "Lila", "Kévin", "Mado"],
            1,
            "Point 2.",
        ),
        pairs=[
            ("suggérerais de", "silence"),
            ("pourrait", "inviter Lila"),
            ("proposerais de", "répéter les noms"),
            ("vaudrait mieux", "pas « urgent »"),
        ],
        fill_item=("Je proposerais ___ répéter les noms propres.", "de"),
        words=["On", "devrait", "remercier", "le", "Bureau", "."],
        anagram=("silence", "Marc en suggérerait un après chaque fait."),
        error=(
            "Je proposerais à répéter les noms propres.",
            "Je proposerais de répéter les noms propres une fois.",
            "Proposer de + infinitif.",
        ),
        pic_start=16,
        pic_words=["le subjonctif", "un monde", "un cœur", "un nuage"],
        short_p="Recopiez trois propositions et ajoutez la vôtre au conditionnel.",
        audio="Lisez les six propositions, sans aller trop vite.",
    ),
    _l(
        "PO",
        "PO — Dire on pourrait",
        "Faire des suggestions polies au conditionnel.",
        "Répétez, puis proposez deux idées pour l'émission.",
        "Modèles d'Aline",
        """Je suggérerais de commencer tôt.
On pourrait attendre une minute.
Je proposerais de sourire.
Il vaudrait mieux vérifier.
Tu devrais articuler.
On devrait remercier.
J'aimerais ouvrir plus tard.
Et si on invitait Dieudonné ?""",
        tf_item=(
            "« Et si on + imparfait » sert aussi à proposer.",
            True,
            "Et si on invitait…",
        ),
        qcm_item=(
            "Quelle phrase est une suggestion, pas un ordre sec ?",
            [
                "Commence !",
                "Je suggérerais de commencer tôt",
                "Tu commences maintenant point",
                "Il faut silence immédiat seulement",
            ],
            1,
            "Conditionnel + de.",
        ),
        pairs=[
            ("suggérer de / proposer de", "+ infinitif"),
            ("on pourrait / on devrait", "conditionnel"),
            ("il vaudrait mieux", "comparaison douce"),
            ("et si on", "imparfait"),
        ],
        fill_item=("On ___ attendre une minute.", "pourrait"),
        words=["Il", "vaudrait", "mieux", "vérifier", "."],
        anagram=("vaudrait", "Il… mieux vérifier chez Solange."),
        error=(
            "Je suggérerais commencer tôt sans de.",
            "Je suggérerais de commencer tôt.",
            "Suggérer de.",
        ),
        pic_start=24,
        pic_words=["un studio", "une carte", "une horloge", "une feuille"],
        short_p="Écrivez huit suggestions, outils différents.",
        audio="Enregistrez les huit modèles, puis deux idées à vous.",
    ),
    _l(
        "PE",
        "PE — Mes suggestions",
        "Écrire un carnet de suggestions au conditionnel.",
        "Imitez le carnet de Léa.",
        "Carnet de Léa Niyonzima",
        """Léa Niyonzima
Je suggérerais de respirer avant le premier mot.
On pourrait laisser Dieudonné présenter le tissu.
Je proposerais de lire le titre « Le monde en direct » sans le crier.
Il vaudrait mieux noter l'heure sur le cahier.
On devrait remercier ceux qui écoutent sous le figuier.
Léa
Studio Figuier""",
        tf_item=(
            "Léa veut qu'on crie le titre.",
            False,
            "« sans le crier. »",
        ),
        qcm_item=(
            "Que pourrait-on laisser faire à Dieudonné ?",
            ["Fermer la radio", "Présenter le tissu", "Casser le micro", "Vendre le pont"],
            1,
            "« présenter le tissu. »",
        ),
        pairs=[
            ("suggérerais de", "respirer"),
            ("pourrait", "Dieudonné"),
            ("proposerais de", "lire le titre"),
            ("devrait", "remercier"),
        ],
        fill_item=("On devrait remercier ceux qui écoutent sous le ___.", "figuier"),
        words=["Je", "suggérerais", "de", "respirer", "."],
        anagram=("respirer", "Léa le suggérerait avant le premier mot."),
        error=(
            "Je proposerais à lire le titre sans le crier.",
            "Je proposerais de lire le titre « Le monde en direct » sans le crier.",
            "Proposer de.",
        ),
        pic_start=2,
        pic_words=["un micro", "un titre", "une nominalisation", "des mots"],
        short_p="Imitez : cinq suggestions, cinq outils ou formes.",
        audio="Lisez votre carnet, sans aller trop vite.",
    ),
    _l(
        "EL",
        "EL — Conditionnel de suggestion",
        "Retenir je suggérerais de, on pourrait, je proposerais de, il vaudrait mieux.",
        "Apprenez la fiche.",
        "Fiche du carnet",
        """Conditionnel présent : je suggérerais, on pourrait, je proposerais, tu devrais
suggérer de + infinitif ; proposer de + infinitif
on pourrait / on devrait + infinitif (sans de)
il vaudrait mieux + infinitif
et si on + imparfait : Et si on invitait… ?
Plus poli que l'impératif : on suggère, on n'ordonne pas.
Attention : je suggérerais de (pas à). Je proposerais de (pas à).""",
        tf_item=(
            "« On pourrait » se construit sans de.",
            True,
            "On pourrait attendre. (pouvoir + inf.)",
        ),
        qcm_item=(
            "Quelle série est correcte ?",
            [
                "suggérer à / proposer à + inf.",
                "suggérer de / proposer de + inf.",
                "suggérer pour / proposer pour + inf. seulement",
                "suggérer en / proposer en + inf.",
            ],
            1,
            "De + infinitif.",
        ),
        pairs=[
            ("suggérer / proposer", "de + inf."),
            ("pouvoir / devoir", "inf. direct"),
            ("valoir mieux", "inf. direct"),
            ("et si on", "imparfait"),
        ],
        fill_item=("Et si on ___ Dieudonné ? (inviter, imparfait)", "invitait"),
        words=["On", "pourrait", "sourire", "davantage", "."],
        anagram=("poli", "Le conditionnel est plus… que l'impératif."),
        error=(
            "On pourrait de attendre Hawa.",
            "On pourrait attendre Hawa.",
            "Pouvoir + infinitif, sans de.",
        ),
        pic_start=6,
        pic_words=["un cahier", "une antenne", "le gérondif", "deux actions"],
        short_p="Transformez six impératifs en suggestions au conditionnel.",
        audio="Enregistrez la fiche et six suggestions.",
    ),
]


# ---------------------------------------------------------------------------
# Séquence 5 — Espérer un monde meilleur (subjonctif)
# ---------------------------------------------------------------------------

S5 = [
    _l(
        "CO",
        "CO — Souhaits d'antenne",
        "Repérer le subjonctif après il faut que, je veux que, pour que, avant que.",
        "Lisez le dialogue. Quel verbe change après que ?",
        "Studio, voyant ocre allumé",
        """Léa : Il faut que le Seuil soit entendu. Il faut que chacun ait sa phrase.
Marc : Je veux que l'eau reste claire. Je veux que vous fassiez attention.
Aline : On parle pour que les enfants puissent comprendre. Pour que rien ne se perde.
Patrick : Avant que l'émission finisse, remercions. Avant qu'on parte, rangeons.
Hawa : Il faut que Joël vienne. Je veux qu'il prenne le micro une minute.
Rose : Il faut que nous soyons justes. Pour que l'info aille jusqu'à Mwezi-Haut.
Karim : Je veux que Solange sache l'heure. Il faut qu'elle puisse tamponner.
Lila : Avant que le vent tourne, disons Rive d'Orage.
Yvette : Il faut que Noura soit prête. Pour que l'infirmerie ouvre à temps.""",
        tf_item=(
            "Après il faut que, le verbe n'est pas à l'indicatif.",
            True,
            "Il faut que le Seuil soit entendu. (subjonctif de être)",
        ),
        qcm_item=(
            "Quelle forme de faire apparaît après je veux que ?",
            ["faites", "fassiez", "feriez", "faisiez à l'indicatif"],
            1,
            "Je veux que vous fassiez attention.",
        ),
        pairs=[
            ("il faut que", "soit / ait / vienne"),
            ("je veux que", "reste / fassiez / sache"),
            ("pour que", "puissent / aille / ouvre"),
            ("avant que", "finisse / parte / tourne"),
        ],
        fill_item=("Il faut que le Seuil ___ entendu.", "soit"),
        words=["Je", "veux", "que", "l'eau", "reste", "claire", "."],
        anagram=("fassiez", "Je veux que vous… attention : subjonctif de faire."),
        error=(
            "Il faut que le Seuil est entendu.",
            "Il faut que le Seuil soit entendu.",
            "Être au subjonctif : soit.",
        ),
        pic_start=16,
        pic_words=["le subjonctif", "un monde", "un cœur", "un nuage"],
        short_p="Notez huit subjonctifs et le mot qui les déclenche (il faut que…).",
        audio="Enregistrez : Il faut que le Seuil soit entendu. Je veux que vous fassiez attention. Pour que les enfants puissent comprendre.",
    ),
    _l(
        "CE",
        "CE — Mot d'espoir",
        "Lire un mot qui enchaîne il faut que, je veux que, pour que, avant que.",
        "Lisez le mot, sans aller trop vite.",
        "Mot de Lila Sow, antenne",
        """Chers auditeurs du Seuil,
Il faut que la rivière reste vivante. Il faut que chacun pacifie sa voix.
Je veux que le figuier ait encore de l'ombre dans dix ans.
On informe pour que personne ne se trompe. Pour que l'espoir aille plus loin.
Avant que la nuit tombe, allumez un lampion au Marché, si vous le pouvez.
Il faut que nous fassions simple. Je veux que vous soyez là demain.
Lila
« Le monde en direct » — Radio Figuier""",
        tf_item=(
            "Lila veut que le figuier ait encore de l'ombre dans dix ans.",
            True,
            "Subjonctif de avoir : ait.",
        ),
        qcm_item=(
            "Que faut-il faire avant que la nuit tombe ?",
            ["Fermer le pont", "Allumer un lampion au marché", "Crier", "Partir à Val-des-Peupliers"],
            1,
            "« allumez un lampion au Marché »",
        ),
        pairs=[
            ("il faut que… reste / pacifie", "subjonctif"),
            ("je veux que… ait / soyez", "souhait"),
            ("pour que… trompe / aille", "but"),
            ("avant que… tombe", "antériorité"),
        ],
        fill_item=("Je veux que le figuier ___ encore de l'ombre.", "ait"),
        words=["Il", "faut", "que", "nous", "fassions", "simple", "."],
        anagram=("pacifie", "Il faut que chacun… sa voix."),
        error=(
            "Je veux que le figuier a encore de l'ombre.",
            "Je veux que le figuier ait encore de l'ombre dans dix ans.",
            "Avoir au subjonctif : ait.",
        ),
        pic_start=18,
        pic_words=["un monde", "un cœur", "un nuage", "un livre"],
        short_p="Encadrez que + subjonctif et le déclencheur.",
        audio="Lisez le mot de Lila, sans aller trop vite.",
    ),
    _l(
        "PO",
        "PO — Dire il faut que",
        "Former des souhaits et des buts au subjonctif.",
        "Répétez, puis exprimez deux espoirs pour le Seuil.",
        "Modèles de Marc",
        """Il faut que ce soit clair.
Il faut que tu aies le temps.
Je veux que vous fassiez simple.
Je veux qu'il vienne.
Pour que l'info aille loin.
Pour que nous puissions signer.
Avant que ça finisse.
Avant qu'on parte.""",
        tf_item=(
            "Le subjonctif de aller à la 3e personne est aille.",
            True,
            "Pour que l'info aille loin.",
        ),
        qcm_item=(
            "« Il faut que tu… le temps » (avoir) =",
            ["as", "aies", "auras", "avais"],
            1,
            "Aies : subjonctif de avoir.",
        ),
        pairs=[
            ("être", "soit / soyez / soyons"),
            ("avoir", "ait / aies / ayons"),
            ("faire", "fasse / fassiez / fassions"),
            ("aller / pouvoir / venir", "aille / puisse / vienne"),
        ],
        fill_item=("Pour que l'info ___ loin.", "aille"),
        words=["Il", "faut", "que", "ce", "soit", "clair", "."],
        anagram=("vienne", "Je veux qu'il… : subjonctif de venir."),
        error=(
            "Il faut que tu as le temps.",
            "Il faut que tu aies le temps.",
            "Avoir : aies.",
        ),
        pic_start=22,
        pic_words=["un lecteur", "une couverture", "un studio", "une carte"],
        short_p="Écrivez huit phrases : deux de chaque déclencheur.",
        audio="Enregistrez les huit modèles, puis deux espoirs à vous.",
    ),
    _l(
        "PE",
        "PE — Mon mot d'espoir",
        "Écrire un mot d'espoir avec le subjonctif.",
        "Imitez le mot de Hawa.",
        "Mot de Hawa Diallo",
        """Hawa Diallo
Il faut que le Seuil soit écouté jusqu'à Port de la Brise.
Je veux que nous fassions attention aux mots.
On parle pour que les enfants puissent répéter.
Avant que l'émission finisse, je souhaite que Marc remercie la cour.
Il faut que l'eau reste claire. Je veux que vous soyez fiers.
Hawa
Radio Figuier — Rukiri-Nord""",
        tf_item=(
            "Hawa veut que Marc remercie la cour avant la fin.",
            True,
            "« Avant que l'émission finisse… Marc remercie » — souhait dans la phrase.",
        ),
        qcm_item=(
            "Jusqu'où Hawa veut-elle que le Seuil soit écouté ?",
            ["Val-des-Peupliers seulement", "Port de la Brise", "Paris", "Lyon"],
            1,
            "« jusqu'à Port de la Brise. »",
        ),
        pairs=[
            ("il faut que… soit", "écouté"),
            ("je veux que… fassions", "attention"),
            ("pour que… puissent", "répéter"),
            ("avant que… finisse", "remercier"),
        ],
        fill_item=("Je veux que vous ___ fiers.", "soyez"),
        words=["Il", "faut", "que", "l'eau", "reste", "claire", "."],
        anagram=("soyez", "Je veux que vous… fiers : subjonctif de être."),
        error=(
            "Il faut que le Seuil est écouté jusqu'au port.",
            "Il faut que le Seuil soit écouté jusqu'à Port de la Brise.",
            "Soit, pas est.",
        ),
        pic_start=26,
        pic_words=["une horloge", "une feuille", "un casque", "une fenêtre"],
        short_p="Imitez : cinq lignes, quatre déclencheurs de subjonctif.",
        audio="Lisez votre mot, sans aller trop vite.",
    ),
    _l(
        "EL",
        "EL — Le subjonctif présent",
        "Retenir il faut que, je veux que, pour que, avant que, et les formes fréquentes.",
        "Apprenez la fiche.",
        "Fiche d'Aline",
        """Déclencheurs A2 : il faut que, je veux que, pour que, avant que
(« J'espère que » : plutôt indicatif. Ici on retient les quatre ci-dessus.)
être : que je sois, tu sois, il soit, nous soyons, vous soyez, ils soient
avoir : que j'aie, tu aies, il ait, nous ayons, vous ayez, ils aient
faire : que je fasse… nous fassions, vous fassiez
aller : que j'aille, il aille ; pouvoir : que je puisse ; venir : qu'il vienne
prendre : qu'il prenne ; savoir : qu'elle sache
Avant que + subjonctif. Pour que + subjonctif.""",
        tf_item=(
            "« J'espère que » prend surtout l'indicatif, pas le subjonctif de cette fiche.",
            True,
            "On réserve le subjonctif à il faut que, je veux que, pour que, avant que.",
        ),
        qcm_item=(
            "« Il faut que nous… » (être) =",
            ["sommes", "soyons", "serions", "étions"],
            1,
            "Soyons.",
        ),
        pairs=[
            ("il faut que", "nécessité"),
            ("je veux que", "volonté"),
            ("pour que", "but"),
            ("avant que", "avant un fait"),
        ],
        fill_item=("Il faut que nous ___ justes. (être)", "soyons"),
        words=["Pour", "que", "rien", "ne", "se", "perde", "."],
        anagram=("declencheurs", "Il faut que, je veux que : des… (sans accent)."),
        error=(
            "Pour que les enfants peuvent comprendre.",
            "On parle pour que les enfants puissent comprendre.",
            "Pouvoir au subjonctif : puissent.",
        ),
        pic_start=10,
        pic_words=["un vélo", "une main", "une suggestion", "une bulle"],
        short_p="Tableau : huit verbes irréguliers au subjonctif, une phrase chacun.",
        audio="Enregistrez la fiche et huit formes.",
    ),
]


# ---------------------------------------------------------------------------
# Séquence 6 — Parler d'un livre (le pronom on)
# ---------------------------------------------------------------------------

S6 = [
    _l(
        "CO",
        "CO — Autour de « Le figuier n'oublie pas »",
        "Repérer on = nous, on = quelqu'un, on = les gens, dans un échange sur un livre.",
        "Lisez le dialogue. Qui est « on » à chaque fois ?",
        "Table des Sources, couverture ocre",
        """Léa : On a lu « Le figuier n'oublie pas », le cahier du Chemin. On = nous, l'équipe.
Marc : On raconte qu'un arbre garde les voix. On = les gens, on dit que…
Aline : On a sonné à la porte du studio. On = quelqu'un, on ne sait pas qui.
Patrick : Dans le livre, on marche jusqu'à la rive. On = le lecteur, tout le monde.
Hawa : On aime ce titre. On n'oublie pas le Seuil. On = nous encore.
Joël : Si on ouvre la page 3, on voit un banc. On = n'importe qui.
Rose : On ne prête pas ce livre sans le noter. On = règle, les gens du Seuil.
Karim : On m'a dit que Lila l'avait copié à la main. On = quelqu'un.
Benoît : On finit par l'antenne. On = nous, Léa et Marc.""",
        tf_item=(
            "« On a sonné » désigne une personne non nommée.",
            True,
            "Aline : quelqu'un.",
        ),
        qcm_item=(
            "Dans « On raconte qu'un arbre garde les voix », on =",
            ["seulement Léa", "les gens / la rumeur", "le pont", "Dieudonné seul"],
            1,
            "On dit que… = les gens.",
        ),
        pairs=[
            ("on a lu", "nous, l'équipe"),
            ("on raconte", "les gens"),
            ("on a sonné", "quelqu'un"),
            ("si on ouvre", "n'importe qui"),
        ],
        fill_item=("___ a sonné à la porte du studio.", "On"),
        words=["On", "aime", "ce", "titre", "."],
        anagram=("rumeur", "On raconte… : la voix des gens."),
        error=(
            "On a lus le livre, accord avec nous.",
            "On a lu « Le figuier n'oublie pas ».",
            "On + verbe au singulier : on a lu.",
        ),
        pic_start=20,
        pic_words=["un livre", "le pronom on", "un lecteur", "une couverture"],
        short_p="Classez neuf « on » : nous / quelqu'un / les gens.",
        audio="Enregistrez : On a lu ce livre. On raconte qu'un arbre garde les voix. On a sonné à la porte.",
    ),
    _l(
        "CE",
        "CE — Note de lecture",
        "Lire une note où on change de sens selon la phrase.",
        "Lisez la note, sans aller trop vite.",
        "Note de Marc, Cahier du chemin",
        """Note — « Le figuier n'oublie pas » (titre inventé au Seuil)
On entre dans le récit par la cour. (on = le lecteur)
On dit que l'arbre répond aux enfants. (on = les gens)
Un soir, on frappe : c'est une voix sans nom. (on = quelqu'un)
On a choisi ce livre pour l'émission. (on = nous, Radio Figuier)
On ne révèle pas la dernière page. (on = règle collective)
Si on relit, on entend mieux le vent de Rive d'Orage.
Marc Nkurunziza""",
        tf_item=(
            "La dernière page est racontée en détail dans la note.",
            False,
            "« On ne révèle pas la dernière page. »",
        ),
        qcm_item=(
            "« On a choisi ce livre » : on =",
            ["un inconnu dans la rue", "nous, Radio Figuier", "seulement Yvette", "les oiseaux"],
            1,
            "Marc parle de l'équipe.",
        ),
        pairs=[
            ("on entre", "lecteur"),
            ("on dit que", "les gens"),
            ("on frappe", "quelqu'un"),
            ("on a choisi", "nous"),
        ],
        fill_item=("___ ne révèle pas la dernière page.", "On"),
        words=["Si", "on", "relit", "on", "entend", "mieux", "."],
        anagram=("derniere", "On ne révèle pas cette page (sans accent)."),
        error=(
            "On ont choisi ce livre pour l'émission.",
            "On a choisi ce livre pour l'émission.",
            "On + 3e personne du singulier.",
        ),
        pic_start=0,
        pic_words=["la voix passive", "un journal", "un micro", "un titre"],
        short_p="Recopiez et écrivez entre parenthèses le sens de chaque on.",
        audio="Lisez la note de Marc, sans aller trop vite.",
    ),
    _l(
        "PO",
        "PO — Dire on",
        "Utiliser on pour nous, pour quelqu'un, pour les gens.",
        "Répétez, puis parlez du livre avec trois on différents.",
        "Modèles de Léa",
        """On a lu ce livre.
On aime ce titre.
On raconte que l'arbre entend.
On a sonné.
On ne prête pas sans noter.
Si on ouvre la page 3, on voit un banc.
On finit à l'antenne.
On dit souvent ça, au Seuil.""",
        tf_item=(
            "Le verbe après on est au singulier.",
            True,
            "On a lu. On aime. On raconte.",
        ),
        qcm_item=(
            "Quelle phrase, ici, vaut surtout « quelqu'un » ?",
            ["On a lu ce livre", "On aime ce titre", "On a sonné", "On finit à l'antenne"],
            2,
            "On a sonné = une personne non nommée.",
        ),
        pairs=[
            ("on = nous", "on a lu / on finit"),
            ("on = les gens", "on raconte / on dit"),
            ("on = quelqu'un", "on a sonné"),
            ("on + verbe", "3e singulier"),
        ],
        fill_item=("___ dit souvent ça, au Seuil.", "On"),
        words=["On", "a", "sonné", "."],
        anagram=("singulier", "Après on, le verbe est au…"),
        error=(
            "On sommes d'accord : on ont lu le livre.",
            "On est d'accord. On a lu le livre.",
            "On + est / on + a, jamais sommes / ont.",
        ),
        pic_start=8,
        pic_words=["le gérondif", "deux actions", "un vélo", "une main"],
        short_p="Écrivez neuf phrases : trois nous, trois gens, trois quelqu'un.",
        audio="Enregistrez les huit modèles, puis trois on à vous.",
    ),
    _l(
        "PE",
        "PE — Ma note de livre",
        "Écrire une note de lecture qui joue sur les trois sens de on.",
        "Imitez la note de Patrick.",
        "Note de Patrick Habimana",
        """Patrick Habimana
On a lu « Le figuier n'oublie pas » sous le figuier. (nous)
On dit que la dernière phrase revient comme un vent. (les gens)
Un matin, on a laissé une feuille dans le livre. (quelqu'un)
Si on relit à voix haute, on entend la cour. (n'importe qui / nous)
On n'emprunte pas le livre sans le Cahier du chemin. (règle)
Patrick
Émission « Le monde en direct »""",
        tf_item=(
            "Patrick dit qu'on emprunte le livre sans rien noter.",
            False,
            "« On n'emprunte pas le livre sans le Cahier du chemin. »",
        ),
        qcm_item=(
            "Où a-t-on lu le livre, selon Patrick ?",
            ["À Port de la Brise", "Sous le figuier", "À l'Auberge seulement", "Chez Ibrahim"],
            1,
            "« sous le figuier. »",
        ),
        pairs=[
            ("on a lu", "nous"),
            ("on dit que", "les gens"),
            ("on a laissé", "quelqu'un"),
            ("on n'emprunte pas", "règle"),
        ],
        fill_item=("Si ___ relit à voix haute, on entend la cour.", "on"),
        words=["On", "a", "lu", "ce", "livre", "."],
        anagram=("emprunte", "On ne… pas le livre sans le cahier."),
        error=(
            "On ont lu ce livre sous le figuier.",
            "On a lu « Le figuier n'oublie pas » sous le figuier.",
            "On a, pas on ont.",
        ),
        pic_start=14,
        pic_words=["un carnet", "une table", "le subjonctif", "un monde"],
        short_p="Imitez : cinq lignes, les trois sens de on au moins une fois.",
        audio="Lisez votre note, sans aller trop vite.",
    ),
    _l(
        "EL",
        "EL — Le pronom on",
        "Retenir les trois valeurs de on et l'accord du verbe.",
        "Apprenez la fiche.",
        "Fiche du Cahier du chemin",
        """On + verbe à la 3e personne du singulier : on a, on est, on lit, on dit
1. on = nous (parlé, radio, groupe) : On a lu. On finit à l'antenne.
2. on = quelqu'un (identité cachée) : On a sonné. On a laissé une feuille.
3. on = les gens / tout le monde : On dit que… On raconte que…
Participe : on est allé (accord possible au sens nous, avancé). Ici : on a lu (invariable avec avoir si pas de COD avant).
On n'écrit pas : on sommes, on ont, on allons.
Élision : l'on (rare, après si, que : si l'on relit) — possible, pas obligatoire.""",
        tf_item=(
            "On écrit « on allons » quand on veut dire nous.",
            False,
            "On va. (singulier)",
        ),
        qcm_item=(
            "Quelle phrase est correcte ?",
            ["on sont d'accord", "on est d'accord", "on sommes d'accord", "on ont lu"],
            1,
            "On est.",
        ),
        pairs=[
            ("on = nous", "groupe qui parle"),
            ("on = quelqu'un", "inconnu"),
            ("on = les gens", "on dit que"),
            ("verbe", "3e singulier"),
        ],
        fill_item=("On ___ d'accord. (être)", "est"),
        words=["On", "dit", "que", "l'arbre", "entend", "."],
        anagram=("identite", "Quand on = quelqu'un, l'… est cachée (sans accent)."),
        error=(
            "On allons finir par l'antenne.",
            "On finit à l'antenne. / On va finir à l'antenne.",
            "On + 3e singulier.",
        ),
        pic_start=4,
        pic_words=["une nominalisation", "des mots", "un cahier", "une antenne"],
        short_p="Écrivez douze phrases : quatre par valeur de on.",
        audio="Enregistrez la fiche et neuf exemples.",
    ),
]


SEQUENCES = [
    {"title": "Un fait à raconter", "lessons": S1},
    {"title": "Info du jour", "lessons": S2},
    {"title": "Réagir avec justesse", "lessons": S3},
    {"title": "Des suggestions à faire", "lessons": S4},
    {"title": "Espérer un monde meilleur", "lessons": S5},
    {"title": "Parler d'un livre", "lessons": S6},
]
