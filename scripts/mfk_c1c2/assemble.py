"""Assembleur C1–C2 : kernels pédagogiques → leçons factory.L (architecture B2)."""
from __future__ import annotations

from factory import L
from draw import SETS

COMPS = ("CO", "CE", "PO", "PE", "EL")

VOICES = [
    "Marc Nkurunziza",
    "Léa Niyonzima",
    "Aline Uwase",
    "Patrick Habimana",
    "Hawa Diallo",
    "Joël Mugisha",
    "Rose Iradukunda",
    "Solange Mukamana",
    "Karim Bamba",
    "Félicie Ndayishimiye",
    "Dieudonné Hakizimana",
    "Lila Sow",
    "Yvette",
    "Mado",
    "Sami",
]


def _pic_words(img_dir: str, start: int) -> list[str]:
    names = SETS[img_dir][1]
    out = []
    for i in range(4):
        label = names[(start + i) % 30].replace("-", " ")
        out.append(label)
    return out


def _consigne(comp: str, seq: dict) -> str:
    if comp == "CO":
        return (
            "Lisez le débat (à écouter avec l'enseignant). "
            "Qu'est-ce qui est dit, qu'est-ce qui reste implicite, qui concède quoi ?"
        )
    if comp == "CE":
        return (
            f"Lisez « {seq['ce_doc']} », sans aller trop vite. "
            "Repérez la thèse, la concession, l'implicite et la proposition."
        )
    if comp == "PO":
        return (
            "Répétez les modèles, puis prenez position en une minute : "
            "thèse, concession, reformulation, proposition."
        )
    if comp == "PE":
        return f"Imitez {seq['pe_model']}."
    return "Apprenez la fiche, puis produisez des exemples justes au registre demandé."


def _objectif(comp: str, seq: dict, cefr: str) -> str:
    extra = (
        "Viser la nuance, la collocation et l'implicite."
        if cefr == "C1"
        else "Viser l'ironie, le sous-entendu, le registre et la synthèse de points de vue."
    )
    goals = {
        "CO": f"Comprendre un échange long et en extraire l'implicite. {seq['obj']} {extra}",
        "CE": f"Lire un texte argumenté long, synthétiser et reformuler. {seq['obj']} {extra}",
        "PO": f"Produire un oral structuré (thèse, concession, proposition). Point : {seq['lang']}.",
        "PE": f"Écrire un texte long et structuré. {seq['obj']} Point : {seq['lang']}.",
        "EL": f"Maîtriser {seq['lang']} au registre {cefr}, avec collocations et pièges de construction.",
    }
    return goals[comp]


def _support(comp: str, seq: dict, cefr: str) -> str:
    t = seq["lines"]
    if len(t) < 18:
        raise ValueError(f"{seq['title']}: need 18 content lines, got {len(t)}")
    if comp == "CO":
        head = [
            f"Lila Sow : Radio Figuier. {t[0]}",
            f"{VOICES[0]} : {t[1]}",
            f"{VOICES[1]} : {t[2]}",
            f"{VOICES[2]} : {t[3]}",
            f"{VOICES[3]} : {t[4]}",
            f"{VOICES[4]} : {t[5]}",
            f"{VOICES[5]} : {t[6]}",
            f"{VOICES[6]} : {t[7]}",
            f"{VOICES[7]} : {t[8]}",
            f"{VOICES[8]} : {t[9]}",
            f"{VOICES[9]} : {t[10]}",
            f"{VOICES[10]} : {t[11]}",
            f"Yvette : {t[12]}",
            f"Mado : {t[13]}",
            f"Sami : {t[14]}",
            f"Lila Sow : Je reformule pour les auditeurs. {t[15]}",
            f"Nina Kayitesi : {t[16]}",
            f"Lila Sow : Nous clôturons sans clore. {t[17]}",
        ]
        if cefr == "C2":
            head.append("Mado, plus bas, sans hausser le ton : " + seq["c2_aside"])
        return "\n".join(head)
    if comp == "CE":
        paras = [
            t[0],
            t[1],
            t[2],
            t[3],
            t[4],
            t[5],
            t[6],
            t[7],
            t[8],
            t[9],
            t[10],
            t[11],
            t[12],
            t[13],
            t[14],
            t[15],
            t[16],
            t[17],
            f"Signé : {seq.get('ce_sign', seq['pe_sign'])} — Cahier des racines, Rukiri-Nord.",
        ]
        return "\n".join(paras)
    if comp == "PO":
        models = [
            t[1],
            t[2],
            t[3],
            seq["lang_ex"][0],
            seq["lang_ex"][1],
            seq["lang_ex"][2],
            seq["lang_ex"][3],
            t[5],
            t[8],
            t[15],
            "Je concède le point, je n'abandonne pas la proposition.",
            "Ce n'est pas que je refuse : c'est que je refuse qu'on nomme cela un détail.",
            "Autrement dit, l'implicite fait autant de travail que la thèse.",
            "En une minute : fait, angle, concession, proposition.",
            t[17],
            "Aline : gardez le souffle après la concession, pas avant la thèse.",
            "Patrick : le registre soutenu n'interdit pas la clarté.",
            "Lila : le micro n'aime ni le slogan ni le silence.",
        ]
        return "\n".join(models)
    if comp == "PE":
        return "\n".join(
            [
                seq["pe_header"],
                t[0],
                t[1],
                t[2],
                t[3],
                t[4],
                t[8],
                t[9],
                t[12],
                t[15],
                t[16],
                t[17],
                seq["lang_ex"][0],
                seq["lang_ex"][1],
                "Je n'écris pas pour vaincre : j'écris pour que la cour puisse relire.",
                seq["pe_tail"],
                seq["pe_sign"],
            ]
        )
    # EL
    return "\n".join(
        [
            f"Fiche {cefr} — {seq['lang']}",
            "On ne retient pas une liste : on retient des constructions et des collocations.",
            seq["lang_ex"][0],
            seq["lang_ex"][1],
            seq["lang_ex"][2],
            seq["lang_ex"][3],
            f"Piège : {seq['el_trap']}",
            f"Registre : {seq['el_register']}",
            f"Collocation : {seq['el_colloc']}",
            t[3],
            t[5],
            t[8],
            "Nominaliser, ce n'est pas alourdir : c'est nommer le processus (la densification, l'accueil, le rappel).",
            "Encore que / pour autant que / si tant est que : subjonctif, concession réelle, pas un ornement.",
            "Reformuler une source : on change la syntaxe, on garde la charge, on signale le point de vue.",
            "C1 : l'implicite se justifie. C2 : l'ironie se laisse entendre sans s'afficher.",
            "Exemple fautif à ne plus produire : " + seq["errors"][4][0],
            "Correction : " + seq["errors"][4][1],
            "Aline Uwase, banc ocre — Le Seuil des Sources.",
        ]
    )


def _audio(comp: str, seq: dict) -> str:
    if comp in ("CE", "PE"):
        return "Lisez le texte, sans aller trop vite."
    if comp == "CO":
        return (
            "Enregistrez une synthèse d'environ quatre-vingt-dix secondes : "
            "deux points de vue, un implicite, une proposition. "
            + seq["audio_extra"]
        )
    if comp == "PO":
        return (
            "Enregistrez quatre modèles, puis votre prise de position "
            "(thèse, concession, proposition). " + seq["audio_extra"]
        )
    return "Enregistrez la fiche, puis quatre phrases justes au registre demandé."


def _short(comp: str, seq: dict) -> str:
    return seq["shorts"][COMPS.index(comp)]


def build_lesson(
    img_dir: str,
    seq: dict,
    comp: str,
    cefr: str,
    pic_start: int,
) -> dict:
    i = COMPS.index(comp)
    title = seq["titles"][i]
    tf_item = seq["tfs"][i]
    qcm_item = seq["qcms"][i]
    fill_item = seq["fills"][i]
    words = seq["wos"][i]
    anagram = seq["anas"][i]
    error = seq["errors"][i]
    support_title = seq["support_titles"][i]
    pe_ok = "Imitez" in _consigne(comp, seq) if comp == "PE" else True
    if not pe_ok:
        raise ValueError("PE consigne")
    return L(
        img_dir,
        comp,
        title,
        _objectif(comp, seq, cefr),
        _consigne(comp, seq),
        support_title,
        _support(comp, seq, cefr),
        tf_item=tf_item,
        qcm_item=qcm_item,
        pairs=seq["pairs"],
        fill_item=fill_item,
        words=words,
        anagram=anagram,
        error=error,
        pic_start=pic_start,
        pic_words=_pic_words(img_dir, pic_start),
        short_p=_short(comp, seq),
        audio=_audio(comp, seq),
    )


def build_module(meta: dict, sequences: list[dict]) -> tuple[dict, list[dict], str]:
    img = meta["img"]
    cefr = meta["cefr_level"]
    built = []
    n = 0
    for seq in sequences:
        lessons = []
        for comp in COMPS:
            lessons.append(build_lesson(img, seq, comp, cefr, n))
            n += 1
        built.append({"title": seq["title"], "lessons": lessons})
    if n != 30:
        raise ValueError(f"{meta['title']}: expected 30 lessons, got {n}")
    module = {
        "title": meta["title"],
        "description": meta["description"],
        "cefr_level": cefr,
    }
    return module, built, img
