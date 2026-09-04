"""Validation d'un kernel de séquence C1/C2."""
from __future__ import annotations


def sb(
    *,
    title: str,
    lang: str,
    obj: str,
    lines: str,
    pairs: list[tuple[str, str]],
    titles: list[str],
    support_titles: list[str],
    tfs: list[tuple],
    qcms: list[tuple],
    fills: list[tuple[str, str]],
    wos: list[list[str]],
    anas: list[tuple[str, str]],
    errors: list[tuple[str, str, str]],
    shorts: list[str],
    ce_doc: str,
    pe_model: str,
    pe_header: str,
    pe_sign: str,
    pe_tail: str,
    lang_ex: list[str],
    el_trap: str,
    el_register: str,
    el_colloc: str,
    audio_extra: str = "",
    c2_aside: str = "",
) -> dict:
    body = [ln.strip() for ln in lines.strip().splitlines() if ln.strip()]
    if len(body) != 18:
        raise ValueError(f"{title}: 18 lines required, got {len(body)}")
    for key, val in {
        "tfs": tfs,
        "qcms": qcms,
        "fills": fills,
        "wos": wos,
        "anas": anas,
        "errors": errors,
        "shorts": shorts,
        "titles": titles,
        "support_titles": support_titles,
    }.items():
        if len(val) != 5:
            raise ValueError(f"{title}: {key} needs 5 items")
    if len(pairs) != 4:
        raise ValueError(f"{title}: 4 matching pairs")
    if len(lang_ex) != 4:
        raise ValueError(f"{title}: 4 lang_ex")
    for wo in wos:
        for tok in wo:
            if "," in tok:
                raise ValueError(f"{title}: comma in {tok!r}")
    for word, hint in anas:
        if word.casefold() in hint.casefold():
            raise ValueError(f"{title}: anagram hint contains {word!r}")
    for q in qcms:
        if len(q[1]) != 4:
            raise ValueError(f"{title}: qcm needs 4 options")
    return {
        "title": title,
        "lang": lang,
        "obj": obj,
        "lines": body,
        "pairs": pairs,
        "titles": titles,
        "support_titles": support_titles,
        "tfs": tfs,
        "qcms": qcms,
        "fills": fills,
        "wos": wos,
        "anas": anas,
        "errors": errors,
        "shorts": shorts,
        "ce_doc": ce_doc,
        "pe_model": pe_model,
        "pe_header": pe_header,
        "pe_sign": pe_sign,
        "pe_tail": pe_tail,
        "lang_ex": lang_ex,
        "el_trap": el_trap,
        "el_register": el_register,
        "el_colloc": el_colloc,
        "audio_extra": audio_extra,
        "c2_aside": c2_aside,
    }
