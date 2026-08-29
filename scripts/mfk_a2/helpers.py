"""Shared exercise builders for MFK A2 seeds."""

from __future__ import annotations


def tf(statement: str, correct: bool, explanation: str) -> dict:
    return {
        "type": "true_false",
        "content": {
            "statement": statement,
            "correct": correct,
            "explanation": explanation,
        },
    }


def qcm(question: str, options: list[str], correct: int, explanation: str) -> dict:
    return {
        "type": "qcm",
        "content": {
            "question": question,
            "options": [
                {"text": text, "correct": i == correct} for i, text in enumerate(options)
            ],
            "explanation": explanation,
        },
    }


def match(pairs: list[tuple[str, str]]) -> dict:
    return {
        "type": "matching",
        "content": {"pairs": [{"left": a, "right": b} for a, b in pairs]},
    }


def fill(prompt: str, answer: str) -> dict:
    return {"type": "fill_blank", "content": {"prompt": prompt, "answer": answer}}


def wo(words: list[str]) -> dict:
    return {"type": "word_order", "content": {"words": words}}


def ana(word: str, hint: str) -> dict:
    return {"type": "anagram", "content": {"word": word, "hint": hint}}


def err(bad: str, good: str, explanation: str) -> dict:
    return {
        "type": "find_error",
        "content": {
            "sentence_with_error": bad,
            "correct_sentence": good,
            "explanation": explanation,
        },
    }


def img(prefix: str, pairs: list[tuple[str, str]]) -> dict:
    return {
        "type": "image_match",
        "content": {
            "pairs": [
                {"image_path": f"/elearning/{prefix}/{name}.svg", "word": word}
                for name, word in pairs
            ]
        },
    }


def short(prompt: str) -> dict:
    return {"type": "short_answer", "content": {"prompt": prompt}}


def aud(instructions: str) -> dict:
    return {"type": "audio_record", "content": {"instructions": instructions}}


def lesson(title: str, competency: str, content: str, exercises: list[dict]) -> dict:
    if len(exercises) != 10:
        raise ValueError(f"{title}: expected 10 exercises, got {len(exercises)}")
    types = [e["type"] for e in exercises]
    if len(set(types)) != 10:
        raise ValueError(f"{title}: duplicate or missing types {types}")
    return {
        "title": title,
        "competency": competency,
        "content": content.strip() + "\n",
        "exercises": exercises,
    }


def ten(
    prefix: str,
    *,
    tf_item: tuple,
    qcm_item: tuple,
    pairs: list[tuple[str, str]],
    fill_item: tuple[str, str],
    words: list[str],
    anagram: tuple[str, str],
    error: tuple[str, str, str],
    pictures: list[tuple[str, str]],
    short_p: str,
    audio: str,
) -> list[dict]:
    return [
        tf(*tf_item),
        qcm(*qcm_item),
        match(pairs),
        fill(*fill_item),
        wo(words),
        ana(*anagram),
        err(*error),
        img(prefix, pictures),
        short(short_p),
        aud(audio),
    ]
