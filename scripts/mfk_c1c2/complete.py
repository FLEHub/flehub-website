"""Complète un kernel compact : exercices de langue lexicalisés, puis expand_kernel."""
from __future__ import annotations

from expand_kernel import kernel, _ressort


def _beats(val) -> list[str]:
    if isinstance(val, list):
        return val
    parts = [p.strip() for p in val.split("|")]
    if len(parts) != 8:
        raise ValueError(f"need 8 beats, got {len(parts)}: {parts[0][:40]!r}...")
    return parts


def _pairs(d: dict) -> list[tuple[str, str]]:
    return [
        (d["w1"], d["d1"]),
        (d["w2"], d["d2"]),
        (d["w3"], d["d3"]),
        (d["w4"], d["d4"]),
    ]


def _grammar(d: dict) -> dict:
    """Exercices EL lexicalisés — un type de langue, un lexique unique."""
    lt = d["lang_type"]
    inf, subj = d.get("sv", ("discuter", "discute"))
    nom = d.get("nom", d["w1"])
    n2 = d.get("nom2", d["w2"])
    if lt == "nom_conc":
        fills = [
            (f"Encore que l'on ___ , {d['obstacle']} n'est pas un détail. ({inf}, subj.)", subj),
            (f"La ___ n'est un abri que si l'on en parle vraiment. ({d['w1']} déjà nom ou verbe à nominaliser)", nom),
            (f"Pour autant que l'on ___ , {d['who'].split()[0]} concède un point. ({inf}, subj.)", subj),
            ("Il ___ que deux voix valent mieux qu'une affiche. (ressortir)", "ressort"),
            (f"On dira la ___ plutôt qu'un slogan. (nom de {d['w2']})", n2),
        ]
        wos = [
            f"Encore que l'on {subj} la lumière {d['w1']} n'est pas un détail .",
            f"La {nom} n'est un abri que si l'on discute .",
            f"Je concède le point je n'abandonne pas {d['w4']} .",
            f"Un compte-rendu n'est pas une fusion des deux voix .",
            f"Pour autant que l'on {subj} {d['who'].split()[0]} concède .",
        ]
        trap = "indicatif après encore que"
        q = (
            "Quelle construction marque une concession réelle au subjonctif ?",
            [
                "parce que + indicatif seulement",
                "encore que / pour autant que + subjonctif",
                "afin de + infinitif uniquement",
                "depuis que interdit toute concession",
            ],
            1,
            "Encore que / pour autant que + subjonctif.",
        )
        tf = ("Après encore que, l'indicatif suffit pour une concession réelle.", False, "Subjonctif.")
        err0_bad = f"Encore que l'on {inf} trop vite, {d['obstacle']} n'est pas un détail, et {d['who']} écoute."
        err0_good = f"Encore que l'on {subj} trop vite, {d['obstacle']} n'est pas un détail, et {d['who']} écoute."
        err0_x = f"Après encore que : {subj}."
    elif lt == "rel_synthese":
        fills = [
            ("Voici ce ___ nous avons besoin pour tenir. (dont)", "dont"),
            ("Voilà ce ___ l'on s'engage en signant. (à quoi)", "à quoi"),
            (f"La ___ retient deux sources sans les fusionner. (synthétiser → nom)", "synthèse"),
            (f"Il n'est pas vrai que cela ___ un slogan. (être, subj.)", "soit"),
            (f"Pour autant que l'on ___ les règles, le partage tient. ({inf}, subj.)", subj),
        ]
        wos = [
            f"Voici ce dont nous avons besoin sous {d['w4']} .",
            "Voilà ce à quoi l'on s'engage en signant .",
            "Synthétiser n'est pas couper les aspérités des sources .",
            f"{d['who'].split()[0]} concède le partage pour autant que l'on nomme les règles .",
            f"La clé n'est pas un luxe c'est un droit de fermer .",
        ]
        trap = "ce que + besoin au lieu de ce dont"
        q = (
            "Quelle relative est juste pour le besoin ?",
            ["ce que nous avons besoin", "ce dont nous avons besoin", "ce qui nous avons besoin", "dont que nous avons besoin"],
            1,
            "Besoin + de → ce dont.",
        )
        tf = ("« Ce dont nous avons besoin » évite le calque « ce que besoin ».", True, "Construction de besoin.")
        err0_bad = f"Voici ce que nous avons besoin pour {d['theme']}, et {d['who']} écrit encore."
        err0_good = f"Voici ce dont nous avons besoin pour {d['theme']}, et {d['who']} écrit encore."
        err0_x = "Besoin se construit avec de : ce dont."
    elif lt == "reco":
        fills = [
            (f"Il convient que l'on ___ avant d'accélérer. ({inf}, subj.)", subj),
            (f"Il s'agit de ___ la pente, non de la nier. (nommer)", "nommer"),
            (f"Nous recommandons que la cour ___ un relais. ({inf}, subj.)", subj),
            (f"Encore que le camion ___ utile, il n'a pas tous les droits. (être, subj.)", "soit"),
            (f"On procédera à une ___ des heures, non à un slogan. (nominalisation de revoir)", "révision"),
        ]
        wos = [
            f"Il convient que l'on {subj} avant d'accélérer .",
            "Il s'agit de nommer la pente non de la nier .",
            f"Nous recommandons que la cour {subj} un relais .",
            "Une recommandation n'est pas un ordre crié .",
            f"Encore que le camion soit utile il n'a pas tous les droits .",
        ]
        trap = "indicatif après il convient que"
        q = (
            "Après « il convient que », quel mode ?",
            ["indicatif seulement", "subjonctif", "impératif uniquement", "conditionnel passé obligatoire"],
            1,
            "Il convient que + subjonctif.",
        )
        tf = ("« Il convient que » se construit avec le subjonctif.", True, "Volonté / opportunité.")
        err0_bad = f"Il convient que l'on {inf} trop tard, et {d['who']} refuse d'accélérer la pente."
        err0_good = f"Il convient que l'on {subj} trop tard, et {d['who']} refuse d'accélérer la pente."
        err0_x = f"Il convient que + {subj}."
    elif lt == "hypotypose":
        fills = [
            (f"On dirait que la rivière ___ une voix. (prendre, cond.)", "prendrait"),
            (f"Si la colline ___ parler, elle parlerait des racines. (pouvoir, imp.)", "pouvait"),
            (f"Une tour ___ l'ombre jusqu'au saule. (avaler, cond.)", "avalerait"),
            (f"Encore que le récit ___ inventé, il dit une peur vraie. (être, subj.)", "soit"),
            (f"L'___ du plan n'empêche pas d'écrire le cauchemar. (urbanisme déjà donné)", d["w1"]),
        ]
        wos = [
            "On dirait que la rivière prendrait une voix .",
            "Si la colline pouvait parler elle parlerait des racines .",
            "Une tour avalerait l'ombre jusqu'au saule .",
            "Le conditionnel ici n'est pas un rêve creux c'est une hypotypose .",
            "Encore que le récit soit inventé il dit une peur vraie .",
        ]
        trap = "indicatif plat là où le conditionnel peint"
        q = (
            "Dans une description fantastique, le conditionnel sert surtout à…",
            ["donner un ordre", "peindre une hypotypose, un comme si", "marquer un passé antérieur", "interdire la métaphore"],
            1,
            "Conditionnel d'imagination / hypotypose.",
        )
        tf = ("Le conditionnel peut peindre un comme si, pas seulement une politesse.", True, "Hypotypose.")
        err0_bad = f"On dirait que la rivière prend une voix demain soir, et {d['who']} écrit encore."
        err0_good = f"On dirait que la rivière prendrait une voix demain soir, et {d['who']} écrit encore."
        err0_x = "Hypotypose : conditionnel prendrait."
    elif lt == "compte_rendu":
        fills = [
            (f"Selon {d['who'].split()[0]}, il ___ que deux documents s'opposent. (ressortir)", "ressort"),
            ("D'après le second texte, on ___ une rampe avant les lanternes. (exiger, cond. atténué)", "exigerait"),
            (f"Il appert que {d['w1']} n'est pas un slogan.", "appert"),
            (f"Encore que l'on ___ les deux sources, on ne les fusionne pas. ({inf}, subj.)", subj),
            (f"Le compte-rendu ___ les désaccords, il ne les gomme pas. (accueillir)", "accueille"),
        ]
        wos = [
            f"Selon {d['who'].split()[0]} il ressort que deux documents s'opposent .",
            "D'après le second texte on exigerait une rampe .",
            "Un compte-rendu n'est pas une fusion .",
            f"Encore que l'on {subj} les sources on ne les fusionne pas .",
            "Il appert que le slogan ne tient pas lieu de plan .",
        ]
        trap = "fusionner les sources au lieu de les attribuer (selon / d'après)"
        q = (
            "Pour attribuer une idée à une source, on privilégie…",
            ["je pense que sans source", "selon / d'après / il ressort que", "il fautons", "un slogan"],
            1,
            "Marqueurs de compte-rendu.",
        )
        tf = ("« Selon X » permet d'attribuer sans fusionner.", True, "Compte-rendu.")
        err0_bad = f"Selon {d['who']}, il ressort que les deux textes est d'accord, et Lila coupe le micro."
        err0_good = f"Selon {d['who']}, il ressort que les deux textes sont d'accord, et Lila coupe le micro."
        err0_x = "Accord : les deux textes sont."
    elif lt == "stats":
        fills = [
            (f"La part de bols trop salés s'___ à près d'un tiers. (établir)", "établit"),
            ("Ces chiffres ___ une peur, ils ne la prouvent pas à eux seuls. (illustrer)", "illustrent"),
            (f"Alors que le sel ___, le jardin tient encore. (monter)", "monte"),
            (f"Il conviendrait que l'on ___ sans crier. ({inf}, subj.)", subj),
            (f"Une ___ n'est pas une sentence. (statistique)", "statistique"),
        ]
        wos = [
            "La part de bols trop salés s'établit à près d'un tiers .",
            "Ces chiffres illustrent une peur ils ne la prouvent pas .",
            "Alors que le sel monte le jardin tient encore .",
            f"Il conviendrait que l'on {subj} sans crier .",
            "Une statistique n'est pas une sentence .",
        ]
        trap = "prendre un pourcentage pour une preuve morale"
        q = (
            "Comment introduire un chiffre sans en faire une sentence ?",
            ["s'établir à / illustrer / alors que", "c'est vrai parce que chiffre", "le micro interdit les nombres", "on crie le pourcentage"],
            0,
            "Langue des données : s'établir à, illustrer, opposer.",
        )
        tf = ("Un chiffre peut illustrer sans conclure à lui seul.", True, "Prudence énonciative.")
        err0_bad = f"La part de bols trop salés s'établissent à un tiers, et {d['who']} refuse d'en faire une morale."
        err0_good = f"La part de bols trop salés s'établit à un tiers, et {d['who']} refuse d'en faire une morale."
        err0_x = "La part … s'établit (singulier)."
    elif lt in ("cause", "societe"):
        fills = [
            (f"Du fait que le prix ___, la colère n'est pas un caprice. (flamber)", "flambe"),
            (f"Si bien que les jardiniers ___ la rive. (quitter, fut. ou prés.)", "quittent"),
            (f"Encore que le marché ___ ouvert, la terre n'est pas payée. (être, subj.)", "soit"),
            (f"Il s'ensuit une ___ des files, non un silence. (nominalisation de allonger)", "allongement"),
            (f"On impute la hausse à {d['w2']}, non au bol. (mot de la séquence)", d["w2"].split()[0]),
        ]
        wos = [
            "Du fait que le prix flambe la colère n'est pas un caprice .",
            "Si bien que les jardiniers quittent la rive .",
            "Encore que le marché soit ouvert la terre n'est pas payée .",
            "Un fait de société se commente il ne se crie pas seulement .",
            f"{d['who'].split()[0]} impute la hausse à {d['w2']} .",
        ]
        trap = "confusion cause / concession"
        q = (
            "« Du fait que » introduit…",
            ["une concession", "une cause", "un but", "une hypotypose"],
            1,
            "Cause.",
        )
        tf = ("« Si bien que » introduit une conséquence.", True, "Conséquence.")
        err0_bad = f"Du fait que le prix flambent, {d['who']} refuse d'appeler cela un caprice, et Oscar écoute."
        err0_good = f"Du fait que le prix flambe, {d['who']} refuse d'appeler cela un caprice, et Oscar écoute."
        err0_x = "Le prix flambe, singulier."
    elif lt == "conseil":
        fills = [
            (f"On ___ lire l'étiquette deux fois, non l'application une fois. (faire mieux de, cond.)", "ferait mieux de"),
            (f"Il vaudrait mieux que tu ___ le bol avant le slogan. ({inf}, subj.)", subj),
            (f"Pourquoi ne pas ___ le Fil-des-Herbes comme un avis, non une loi ? (traiter)", "traiter"),
            (f"Encore que l'outil ___ pratique, il n'achète pas à notre place. (être, subj.)", "soit"),
            (f"Un ___ n'est pas un ordre. (conseil)", "conseil"),
        ]
        wos = [
            "On ferait mieux de lire l'étiquette deux fois .",
            f"Il vaudrait mieux que tu {subj} le bol avant le slogan .",
            "Pourquoi ne pas traiter l'outil comme un avis .",
            "Encore que l'outil soit pratique il n'achète pas à notre place .",
            "Un conseil n'est pas un ordre .",
        ]
        trap = "impératif brutal à la place du conditionnel de conseil"
        q = (
            "Pour conseiller sans ordonner, on privilégie…",
            ["fais ! seulement", "on ferait mieux de / il vaudrait mieux que", "il fautons", "le slogan"],
            1,
            "Conditionnel et subjonctif de conseil.",
        )
        tf = ("« On ferait mieux de » atténue un conseil.", True, "Conditionnel de conseil.")
        err0_bad = f"Il vaudrait mieux que tu {inf} le bol trop vite, et {d['who']} pose l'étiquette."
        err0_good = f"Il vaudrait mieux que tu {subj} le bol trop vite, et {d['who']} pose l'étiquette."
        err0_x = f"Il vaudrait mieux que + {subj}."
    elif lt == "disc_ind":
        fills = [
            (f"Joël a dit qu'il ___ le casque dès l'aube. (poser, cond. du DI passé)", "poserait"),
            (f"Rose a demandé si l'on ___ les mains dans l'accroche. (nommer, imp.)", "nommait"),
            (f"Karim a prétendu que les heures ___ déjà trop longues. (être, imp.)", "étaient"),
            (f"Lila a exigé que l'on ___ les insultes. ({inf}, subj.)", subj),
            (f"Le discours ___ n'est pas une sténographie : on change les temps. (rapporté)", "rapporté"),
        ]
        wos = [
            "Joël a dit qu'il poserait le casque dès l'aube .",
            "Rose a demandé si l'on nommait les mains dans l'accroche .",
            "Karim a prétendu que les heures étaient déjà trop longues .",
            f"Lila a exigé que l'on {subj} les insultes .",
            "Rapporter n'est pas sténographier .",
        ]
        trap = "garder le présent du DD dans un DI au passé"
        q = (
            "Dans un discours indirect au passé, « je poserai » devient souvent…",
            ["je poserai encore", "il poserait", "il a posé uniquement", "pose !"],
            1,
            "Futur → conditionnel dans le DI au passé.",
        )
        tf = ("Le discours indirect au passé décale souvent les temps.", True, "Concordance.")
        err0_bad = f"Joël a dit qu'il posera le casque dès l'aube, et {d['who']} prend des notes."
        err0_good = f"Joël a dit qu'il poserait le casque dès l'aube, et {d['who']} prend des notes."
        err0_x = "DI au passé : poserait."
    elif lt == "ironie":
        fills = [
            (f"Il ne s'agirait ___ d'un détail, à entendre certains. (ne … que)", "que"),
            (f"Loin de ___ la cour, le sourire la fatigue. (rassurer)", "rassurer"),
            (f"Fût-ce à voix basse, Mado ___ le contraire de ce qu'on affiche. (dire)", "dit"),
            (f"Si tant est que le bonheur s'___, il se vendrait déjà sous le figuier. (industrialiser)", "industrialise"),
            (f"L'___ n'est pas un rire : c'est un écart entre le dit et le visé. (ironie)", "ironie"),
        ]
        wos = [
            "Il ne s'agirait que d'un détail à entendre certains .",
            "Loin de rassurer la cour le sourire la fatigue .",
            "Fût-ce à voix basse Mado dit le contraire .",
            "Si tant est que le bonheur s'industrialise il se vendrait déjà .",
            "L'ironie n'est pas un rire c'est un écart .",
        ]
        trap = "prendre l'antiphrase au premier degré"
        q = (
            "« Il ne s'agirait que d'un détail » est souvent…",
            ["une preuve que c'est un détail", "un sous-entendu, parfois ironique", "un passé simple", "un ordre"],
            1,
            "Understatement / ironie.",
        )
        tf = ("L'ironie peut dire le contraire de ce qu'elle affirme.", True, "Antiphrase possible.")
        err0_bad = f"Si tant est que le bonheur s'industrialise, il se vend déjà, et {d['who']} sourit trop large."
        err0_good = f"Si tant est que le bonheur s'industrialise, il se vendrait déjà, et {d['who']} sourit trop large."
        err0_x = "Si tant est que + hypothese : se vendrait (irréel / doute)."
    elif lt == "registre":
        fills = [
            (f"Au registre soutenu, on dira ___ et non « c'est pas ouf ». (cela)", "cela"),
            (f"Encore que le tutoiement ___ possible sous le figuier, le micro de Lila vouvoie l'assemblée. (être, subj.)", "soit"),
            (f"Il convient que l'on ___ le niveau, non la personne. ({inf}, subj.)", subj),
            (f"Un ___ n'est pas une trahison : c'est un choix de relation. (registre)", "registre"),
            (f"Loin de ___, adapter le discours c'est respecter l'oreille. (tricher)", "tricher"),
        ]
        wos = [
            "Au registre soutenu on dira cela et non un mot trop large .",
            "Encore que le tutoiement soit possible le micro vouvoie l'assemblée .",
            f"Il convient que l'on {subj} le niveau non la personne .",
            "Un registre n'est pas une trahison c'est un choix .",
            "Adapter le discours c'est respecter l'oreille .",
        ]
        trap = "familier non signalé dans un discours d'assemblée"
        q = (
            "Changer de registre, c'est surtout…",
            ["parler « faux »", "ajuster la relation et l'oreille", "oublier la grammaire", "interdire le figuier"],
            1,
            "Variation de registre.",
        )
        tf = ("Le vouvoiement du micro peut coexister avec le tutoiement du banc.", True, "Registres situés.")
        err0_bad = f"Au registre soutenu, on dira ça ouais, et {d['who']} lit encore la motion."
        err0_good = f"Au registre soutenu, on dira cela, et {d['who']} lit encore la motion."
        err0_x = "Soutenu : cela, pas ça ouais."
    else:
        # default C1: concession + nominalisation + modalisation
        fills = [
            (f"Encore que l'on ___ , {d['obstacle']} demeure. ({inf}, subj.)", subj),
            (f"Il se peut que cela ___ plus grave qu'un slogan. (être, subj.)", "soit"),
            (f"On ___ que deux lectures s'offrent. (objecter)", "objectera"),
            (f"La ___ du problème précède le cri. (nominalisation de poser)", "pose"),
            (f"Pour autant que l'on ___ , la cour avance. ({inf}, subj.)", subj),
        ]
        wos = [
            f"Encore que l'on {subj} {d['obstacle']} demeure .",
            "Il se peut que cela soit plus grave qu'un slogan .",
            "On objectera que deux lectures s'offrent .",
            f"La pose du problème précède le cri .",
            f"Pour autant que l'on {subj} la cour avance .",
        ]
        trap = "modalisation oubliée (c'est vrai que / il se peut que)"
        q = (
            "« Il se peut que » se construit avec…",
            ["l'indicatif obligatoire", "le subjonctif", "l'impératif", "le passé simple obligatoire"],
            1,
            "Probabilité : subjonctif.",
        )
        tf = ("« Il se peut que » appelle le subjonctif.", True, "Modalisation.")
        err0_bad = f"Il se peut que cela est plus grave qu'un slogan, et {d['who']} baisse la voix."
        err0_good = f"Il se peut que cela soit plus grave qu'un slogan, et {d['who']} baisse la voix."
        err0_x = "Il se peut que + soit."

    errors = [
        (
            err0_bad,
            err0_good,
            err0_x,
        ),
        (
            f"La {d['w1']} de trop vite n'aide personne, et {d['hearer']} reprend le fil.",
            f"La précipitation n'aide personne, et {d['hearer']} reprend le fil.",
            "Éviter une construction calquée ; préférer un nom d'action juste (précipitation).",
        ),
        (
            f"{d['who']} écoute encore, et il fautons {inf} avant de crier.",
            f"{d['who']} écoute encore, et il faut {inf} avant de crier.",
            "Toujours il faut.",
        ),
        (
            f"Les arguments de {d['who']} est clairs, et Lila garde le micro ouvert.",
            f"Les arguments de {d['who']} sont clairs, et Lila garde le micro ouvert.",
            "Accord : les arguments sont.",
        ),
        (
            f"On va au {d['w3']} pour de vrai genre, et {d['hearer']} demande un registre plus net.",
            f"On va au {d['w3']} vraiment, et {d['hearer']} demande un registre plus net.",
            "Registre : éviter le marqueur trop oral « genre » dans un écrit soutenu.",
        ),
    ]
    # anagrams from pair words + extras; hints without the word
    extras = d.get("ana_extra", ["collocation", "implicite", "hypotaxe", "nuance", "registre"])
    words = [d["w1"], d["w2"], d["w3"], d["w4"], extras[0]]
    hints = [
        d["d1"],
        d["d2"],
        d["d3"],
        d["d4"],
        "Précision du discours, sans nommer le mot-cible.",
    ]
    anas = []
    for w, h in zip(words, hints):
        if w.casefold() in h.casefold():
            h = "Notion travaillée dans cette séquence, sans répéter l'orthographe cible."
        anas.append((w.split()[0], h))

    lang_ex = d.get(
        "lang_ex",
        [
            f"Encore que l'on {subj}, {d['obstacle']} n'est pas un détail.",
            f"{d['who']} concède que {d['concede']}, pour autant que {d['cond']}.",
            f"Autrement dit, {d['reform']}",
            _ressort(d["proposal"]),
        ],
    )
    return {
        "fills": fills,
        "wos": wos,
        "anas": anas,
        "errors": errors,
        "lang_ex": lang_ex,
        "el_trap": trap,
        "q_grammar": q,
        "tf_grammar": tf,
    }


def build(d: dict) -> dict:
    d = dict(d)
    d["beats"] = _beats(d["beats"])
    d["pairs"] = _pairs(d)
    g = _grammar(d)
    d.update(g)
    d.setdefault("el_register", "soutenu argumentatif, sans slogan")
    d.setdefault("el_colloc", "encore que, pour autant que, il ressort que")
    d.setdefault("pe_model", f"le texte de {d['who']}")
    d.setdefault("pe_header", f"{d['who']} — {d['ce_doc']}")
    d.setdefault("pe_sign", f"{d['who']}, Rukiri-Nord")
    d.setdefault("pe_tail", d["reform"])
    d.setdefault("audio_extra", f"Gardez {d['doc_a']} et {d['doc_b']} distincts.")
    # anagram word must be a single token without spaces for typical UI
    d["anas"] = [(a[0].replace(" ", ""), a[1]) for a in d["anas"]]
    return kernel(d)
