"""Helpers to assemble B1 lessons from compact specs."""

from __future__ import annotations

from helpers import lesson, ten

from draw import SETS


def svg_names(img_dir: str) -> list[str]:
    return SETS[img_dir][1]


def body(objectif: str, consigne: str, support_title: str, support: str) -> str:
    return (
        f"Objectif\n{objectif.strip()}\n\n"
        f"Consigne\n{consigne.strip()}\n\n"
        f"Support — {support_title.strip()}\n{support.strip()}"
    )


def pics(img_dir: str, start: int, words: list[str]) -> list[tuple[str, str]]:
    names = svg_names(img_dir)
    return [(names[(start + i) % len(names)], words[i]) for i in range(4)]


def L(
    img_dir: str,
    competency: str,
    title: str,
    objectif: str,
    consigne: str,
    support_title: str,
    support: str,
    *,
    tf_item: tuple,
    qcm_item: tuple,
    pairs: list[tuple[str, str]],
    fill_item: tuple[str, str],
    words: list[str],
    anagram: tuple[str, str],
    error: tuple[str, str, str],
    pic_start: int,
    pic_words: list[str],
    short_p: str,
    audio: str,
) -> dict:
    prompt, answer = fill_item
    if not prompt.startswith("Complétez"):
        prompt = f"Complétez :\n{prompt}"
        fill_item = (prompt, answer)
    return lesson(
        title,
        competency,
        body(objectif, consigne, support_title, support),
        ten(
            img_dir,
            tf_item=tf_item,
            qcm_item=qcm_item,
            pairs=pairs,
            fill_item=fill_item,
            words=words,
            anagram=anagram,
            error=error,
            pictures=pics(img_dir, pic_start, pic_words),
            short_p=short_p,
            audio=audio,
        ),
    )
