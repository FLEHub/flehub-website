"""Construit les dicts sb() à partir de kernels compacts uniques."""
from __future__ import annotations

import re

from materialize import materialize

_VOWELS = "aeiouàâäéèêëîïôöùûüœh"


def _que(text: str) -> str:
    t = text.strip()
    if not t:
        return "que"
    if t[0].lower() in _VOWELS or t.lower().startswith(("une ", "un ", "y ")):
        return "qu'" + t
    return "que " + t


def _de(text: str) -> str:
    t = text.strip()
    if t.startswith("le "):
        return "du " + t[3:]
    if t.startswith("les "):
        return "des " + t[4:]
    if t.startswith("la "):
        return "de la " + t[3:]
    if t.startswith("une "):
        return "d'une " + t[4:]
    if t.startswith("un "):
        return "d'un " + t[3:]
    if t[0].lower() in _VOWELS:
        return "d'" + t
    return "de " + t


def _participe_presente(obstacle: str) -> str:
    o = obstacle.strip().lower()
    if o.startswith(("une ", "la ", "l'")):
        return "présentée"
    return "présenté"


def _proposal(text: str) -> str:
    return re.sub(r"^((?:une|un) [^:]{1,40}) : ", r"\1 — ", text.strip())


def _ressort(text: str) -> str:
    t = text.strip()
    if not t:
        return "Il ressort que la cour refuse de fusionner les voix."
    first = t[0].lower()
    if first in _VOWELS or t.lower().startswith(("une ", "un ", "y ")):
        return "Il ressort qu'" + t
    return "Il ressort que " + t


def _lines(k: dict) -> str:
    b = k["beats"]
    if len(b) != 8:
        raise ValueError(f"{k['title']}: 8 beats")
    who = k["who"]
    eighteen = [
        f"On parle trop vite {_de(k['theme'])}, comme si le mot dispensait d'en examiner le prix.",
        f"Encore que l'on {k['promise']}, {k['obstacle']} n'est pas un détail que l'on puisse ranger dans une note de bas de page.",
        f"{who} concède {_que(k['concede'])}, pour autant que {k['cond']}.",
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
        f"La proposition qui reste debout est celle-ci : {_proposal(k['proposal'])}",
        b[7],
        f"Nous clôturons sans fusionner les voix : {k['doc_a']} d'un côté, {k['doc_b']} de l'autre, et le point où elles refusent de se ressembler.",
    ]
    return "\n".join(eighteen)


def _tfs(k: dict) -> list[tuple]:
    return [
        (
            f"{k['obstacle'].rstrip('.')} est {_participe_presente(k['obstacle'])} comme un simple détail sans conséquence.",
            False,
            f"Le texte affirme au contraire {_que(k['obstacle'])} n'est pas un détail.",
        ),
        (
            f"Le texte refuse de fusionner {k['doc_a']} et {k['doc_b']} en une seule affiche.",
            True,
            "La clôture garde deux voix et le point où elles ne se ressemblent pas.",
        ),
        (
            f"{k['who']} transforme la concession en abandon de toute proposition.",
            False,
            f"{k['who']} concède {_que(k['concede'])}, pour autant que {k['cond']}.",
        ),
        (
            f"La proposition retenue est : {_proposal(k['proposal'])}",
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
                f"{k['concede'][0].upper() + k['concede'][1:] if k['concede'] else k['concede']} — à condition que {k['cond']}",
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
