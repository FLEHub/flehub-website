"""Transforme un kernel compact en dict sb() prêt pour assemble.build_lesson."""
from __future__ import annotations

from spec_util import sb


def _split_wo(sentence: str) -> list[str]:
    if "," in sentence:
        raise ValueError(f"comma in word_order: {sentence!r}")
    parts = sentence.strip().split()
    if parts[-1] != ".":
        parts.append(".")
    return parts


def materialize(k: dict) -> dict:
    titles = k.get("titles") or [
        f"CO — {k['title']}",
        f"CE — {k['ce_doc']}",
        f"PO — Dire et concéder : {k['title']}",
        f"PE — {k['pe_model']}",
        f"EL — {k['lang']}",
    ]
    support_titles = k.get("support_titles") or [
        f"Débat Radio Figuier — {k['title']}",
        k["ce_doc"],
        "Modèles d'Aline Uwase, banc du figuier",
        k["pe_header"].split("—")[0].strip(),
        "Fiche d'Aline Uwase, banc ocre",
    ]
    tfs = k["tfs"]
    qcms = k["qcms"]
    fills = k["fills"]
    wos = [_split_wo(s) if isinstance(s, str) else s for s in k["wos"]]
    anas = k["anas"]
    errors = k["errors"]
    shorts = k["shorts"]
    return sb(
        title=k["title"],
        lang=k["lang"],
        obj=k["obj"],
        lines=k["lines"],
        pairs=k["pairs"],
        titles=titles,
        support_titles=support_titles,
        tfs=tfs,
        qcms=qcms,
        fills=fills,
        wos=wos,
        anas=anas,
        errors=errors,
        shorts=shorts,
        ce_doc=k["ce_doc"],
        pe_model=k["pe_model"],
        pe_header=k["pe_header"],
        pe_sign=k["pe_sign"],
        pe_tail=k["pe_tail"],
        lang_ex=k["lang_ex"],
        el_trap=k["el_trap"],
        el_register=k["el_register"],
        el_colloc=k["el_colloc"],
        audio_extra=k.get("audio_extra", ""),
        c2_aside=k.get("c2_aside", ""),
    )
