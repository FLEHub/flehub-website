"""Construit les dicts sb() à partir de kernels compacts uniques."""
from __future__ import annotations

from materialize import materialize


def _ressort(text: str) -> str:
    t = text.strip()
    if not t:
        return "Il ressort que la cour refuse de fusionner les voix."
    first = t[0].lower()
    if first in "aeiouàâäéèêëîïôöùûüœh" or t.lower().startswith(("une ", "un ", "y ")):
        return "Il ressort qu'" + t
    return "Il ressort que " + t


def _lines(k: dict) -> str:
    b = k["beats"]
    if len(b) != 8:
        raise ValueError(f"{k['title']}: 8 beats")
    who = k["who"]
    eighteen = [
        f"On parle trop vite de {k['theme']}, comme si le mot dispensait d'en examiner le prix.",
        f"Encore que l'on {k['promise']}, {k['obstacle']} n'est pas un détail que l'on puisse ranger dans une note de bas de page.",
        f"{who} concède que {k['concede']}, pour autant que {k['cond']}.",
        f"Ce que l'on nomme {k['pairs'][0][0]}, ici, n'est pas un slogan : {k['pairs'][0][1]}.",
        b[0],
        b[1],
        b[2],
        b[3],
        b[4],
        b[5],
        f"Un chiffre, une trace : {k['datum']}",
        f"L'enjeu n'est pas d'avoir raison plus fort : {k['stake']}",
        b[6],
        f"{k['hearer']} entend, dans « {k['slogan']} », ceci qui n'est pas dit : {k['implicit']}",
        f"Autrement dit, {k['reform']}",
        f"La proposition qui reste debout est celle-ci : {k['proposal']}",
        b[7],
        f"Nous clôturons sans fusionner les voix : {k['doc_a']} d'un côté, {k['doc_b']} de l'autre, et le point où elles refusent de se ressembler.",
    ]
    return "\n".join(eighteen)


def _tfs(k: dict) -> list[tuple]:
    return [
        (
            f"{k['obstacle'].rstrip('.')} est présenté comme un simple détail sans conséquence.",
            False,
            f"Le texte affirme au contraire que {k['obstacle']} n'est pas un détail.",
        ),
        (
            f"Le texte refuse de fusionner {k['doc_a']} et {k['doc_b']} en une seule affiche.",
            True,
            "La clôture garde deux voix et le point où elles ne se ressemblent pas.",
        ),
        (
            f"{k['who']} transforme la concession en abandon de toute proposition.",
            False,
            f"{k['who']} concède que {k['concede']}, pour autant que {k['cond']}.",
        ),
        (
            f"La proposition retenue est : {k['proposal']}",
            True,
            k["proposal"],
        ),
        (
            k["tf_grammar"][0],
            k["tf_grammar"][1],
            k["tf_grammar"][2],
        ),
    ]


def _qcms(k: dict) -> list[tuple]:
    return [
        (
            f"Selon {k['hearer']}, que reste-t-il implicite dans « {k['slogan']} » ?",
            [k["decoy1"], k["implicit_short"], k["decoy2"], k["decoy3"]],
            1,
            k["implicit"],
        ),
        (
            f"Que faut-il retenir du fait ou du chiffre avancé ?",
            [
                "Rien n'est chiffré, tout est slogan",
                k["datum_short"],
                "Le chiffre annule la concession",
                "Le micro interdit les traces",
            ],
            1,
            k["datum"],
        ),
        (
            f"Que concède {k['who']}, et à quelle condition ?",
            [
                f"{k['who']} n'accorde rien et ferme le banc",
                f"{k['concede']} — à condition que {k['cond']}",
                f"{k['who']} abandonne {k['stake']}",
                "La concession vaut acceptation du slogan",
            ],
            1,
            f"Concession réelle, pas un abandon : {k['cond']}",
        ),
        (
            "Quelle proposition reste debout à la fin ?",
            [
                "Fusionner les deux documents en une affiche",
                k["proposal"],
                "Interdire toute nominalisation",
                "Couper le micro de Lila",
            ],
            1,
            k["proposal"],
        ),
        (
            k["q_grammar"][0],
            k["q_grammar"][1],
            k["q_grammar"][2],
            k["q_grammar"][3],
        ),
    ]


def _shorts(k: dict) -> list[str]:
    return [
        f"Reformulez l'implicite de « {k['slogan']} » et la concession de {k['who']}.",
        f"Synthétisez « {k['ce_doc']} » : thèse, concession, implicite, proposition (quinze lignes).",
        f"Écrivez six phrases orales justes : deux sur {k['lang']}, deux concessions, deux propositions.",
        f"Imitez {k['pe_model']} : vingt lignes, deux voix, une concession, une proposition.",
        f"Tableau de langue : six exemples justes de « {k['lang']} » et deux pièges commentés.",
    ]


def kernel(k: dict) -> dict:
    k = dict(k)
    k["lines"] = _lines(k)
    k["tfs"] = _tfs(k)
    k["qcms"] = _qcms(k)
    k.setdefault("shorts", _shorts(k))
    k.setdefault(
        "titles",
        [
            f"CO — {k['title']}",
            f"CE — {k['ce_doc']}",
            f"PO — {k['title']} : dire sans slogan",
            f"PE — {k['pe_model']}",
            f"EL — {k['lang']}",
        ],
    )
    k.setdefault(
        "support_titles",
        [
            f"Débat Radio Figuier — {k['title']}",
            k["ce_doc"],
            "Modèles d'Aline Uwase, banc du figuier",
            k["pe_header"],
            "Fiche d'Aline Uwase, banc ocre",
        ],
    )
    return materialize(k)
