"""Correctifs français et de vraisemblance pour les textes MFK C1/C2."""
from __future__ import annotations

import re

VOWELS = "aeiouàâäéèêëîïôöùûüœ"

SPEAKER = (
    r"(?:Lila Sow|Marc Nkurunziza|Léa Niyonzima|Aline Uwase|Patrick Habimana|"
    r"Hawa Diallo|Joël Mugisha|Rose Iradukunda|Solange Mukamana|Karim Bamba|"
    r"Félicie Ndayishimiye|Dieudonné Hakizimana|Yvette|Mado|Sami|"
    r"Nina Kayitesi|Oscar Niyitegeka|Inès Mukama|Basile Habiyaremye|"
    r"Léa|Marc|Aline|Patrick|Hawa|Joël|Rose|Solange|Karim|Félicie|"
    r"Dieudonné|Lila|Nina|Oscar|Inès|Basile)"
)
SPEAKER_RE = re.compile(rf"^({SPEAKER}) : ")

IMAGE_RENAMES = {
    "/elearning/mfk-c2-m1/routinite.svg": (
        "/elearning/mfk-c2-m1/joie-horloge.svg",
        "routinite",
        "joie-horloge",
    ),
    "/elearning/mfk-c2-m4/souvenons-nous.svg": (
        "/elearning/mfk-c2-m4/pacte-rive.svg",
        "souvenons-nous",
        "pacte-rive",
    ),
    "/elearning/mfk-c2-m3/affiche-gaffe.svg": (
        "/elearning/mfk-c2-m3/campagne-deux-tons.svg",
        "affiche-gaffe",
        "campagne-deux-tons",
    ),
    "/elearning/mfk-c2-m6/rapport-alarmant.svg": (
        "/elearning/mfk-c2-m6/hypothese-crue.svg",
        "rapport alarmant",
        "hypothèse de crue",
    ),
    "/elearning/mfk-c1-m5/terre-accueil.svg": (
        "/elearning/mfk-c1-m5/accueil-cles.svg",
        "terre accueil",
        "accueil clés",
    ),
}

WORD_RENAMES = {
    "routinite": "joie-horloge",
    "rapport alarmant": "hypothèse de crue",
    "souvenons nous": "pacte rive",
    "terre accueil": "accueil clés",
    "affiche gaffe": "campagne deux tons",
}


def de_name(name: str) -> str:
    first = name.split()[0]
    if first[0].lower() in VOWELS:
        return "d'" + name
    return "de " + name


def fix_elision(text: str) -> str:
    """Élisions et contractions dans un texte déjà correct (pas une phrase-piège)."""
    text = re.sub(r"\bque une\b", "qu'une", text)
    text = re.sub(r"\bque un\b", "qu'un", text)
    text = re.sub(r"\bQue une\b", "Qu'une", text)
    text = re.sub(r"\bQue un\b", "Qu'un", text)
    text = re.sub(r"\bde le\b", "du", text)
    text = re.sub(r"\bDe le\b", "Du", text)
    text = re.sub(r"\bde les\b", "des", text)
    text = re.sub(r"\bDe les\b", "Des", text)
    text = re.sub(r"\bde une\b", "d'une", text)
    text = re.sub(r"\bde un\b", "d'un", text)
    text = re.sub(r"\bDe une\b", "D'une", text)
    text = re.sub(r"\bDe un\b", "D'un", text)
    # Noms propres à initiale vocalique après de
    text = re.sub(r"\bde (Aline|Oscar|Inès)\b", r"d'\1", text)
    text = re.sub(r"\bDe (Aline|Oscar|Inès)\b", r"D'\1", text)
    return text


def fix_presente(text: str) -> str:
    """N'accorde que si le sujet (début de phrase / d'item) est féminin."""

    def repl(m: re.Match[str]) -> str:
        return m.group(0)[:-8] + "présentée"

    return re.sub(
        r"(?m)^(?:Une|une|La|la)\s.{0,90}?\best présenté\b",
        repl,
        text,
    )


def fix_double_colon(text: str) -> str:
    return re.sub(
        r"(La proposition qui reste debout est celle-ci : )([^:\n]{1,80}) : ",
        r"\1\2 — ",
        text,
    )


def clean_speakers(text: str) -> str:
    lines = []
    for line in text.split("\n"):
        m = SPEAKER_RE.match(line)
        if not m:
            lines.append(line)
            continue
        who = m.group(1)
        rest = line[m.end() :]
        m2 = SPEAKER_RE.match(rest)
        if m2:
            # Préfixe figé (Nina Kayitesi :) + vrai locuteur déjà dans le beat
            line = rest
            who = m2.group(1)
            rest = line[m2.end() :]
        if rest.startswith(who):
            rest = rest[len(who) :].lstrip(" :")
            if rest.startswith("concède"):
                rest = "Je " + rest
            elif rest.startswith("garde le tarif"):
                rest = "Je garde le tarif bas dans ma version, sans le crier."
            line = f"{who} : {rest}"
        elif rest == "Hawa garde le tarif.":
            line = f"{who} : Je garde le tarif bas dans ma version, sans le crier."
        lines.append(line)
    return "\n".join(lines)


def fix_plausibility_phrases(text: str) -> str:
    text = text.replace(
        "Hawa garde le tarif.",
        "Hawa garde le tarif bas dans sa version, sans le crier.",
    )
    text = text.replace(
        "Hawa concède le mot généreux, pas le tarif.",
        "Hawa concède le mot généreux, pas le tarif trop bas qu'elle refuse de crier.",
    )
    text = text.replace(
        "une terre d'accueil se mesure aux clés",
        "un accueil de cour se mesure aux clés",
    )
    text = text.replace(
        "Une terre d'accueil se mesure aux clés",
        "Un accueil de cour se mesure aux clés",
    )
    return text


def fix_c_lesson(text: str) -> str:
    text = clean_speakers(text)
    text = fix_plausibility_phrases(text)
    text = fix_elision(text)
    text = fix_presente(text)
    text = fix_double_colon(text)
    return text


def fix_json_string(value: str, *, field: str, exercise_type: str) -> str:
    if field == "sentence_with_error":
        return value  # traité à part
    if exercise_type in {"find_error", "qcm", "true_false"} and field in {
        "text",
    }:
        # Distracteurs QCM : ne pas « corriger » une forme volontairement fausse
        if re.search(r"\b(?:à le|de le|de les|que une|que un)\b", value):
            return value
    text = fix_plausibility_phrases(value)
    text = fix_elision(text)
    text = fix_presente(text)
    text = fix_double_colon(text)
    for old_path, (new_path, old_word, new_word) in IMAGE_RENAMES.items():
        text = text.replace(old_path, new_path)
        if field == "word" and value.strip() in {old_word, old_word.replace("-", " ")}:
            return new_word
    if field == "word":
        return WORD_RENAMES.get(text, text)
    return text


def walk_json(obj, *, exercise_type: str):
    if isinstance(obj, dict):
        out = {}
        for k, v in obj.items():
            if isinstance(v, str):
                out[k] = fix_json_string(v, field=k, exercise_type=exercise_type)
            else:
                out[k] = walk_json(v, exercise_type=exercise_type)
        return out
    if isinstance(obj, list):
        return [walk_json(x, exercise_type=exercise_type) for x in obj]
    return obj


def rewrite_find_error_agreement(obj: dict, seq_title: str) -> dict:
    bad = obj.get("sentence_with_error", "")
    good = obj.get("correct_sentence", "")
    m = re.search(r"Les arguments de (.+?) est clairs", bad)
    if not m or "sont clairs" not in good:
        obj["correct_sentence"] = fix_elision(good)
        if "explanation" in obj:
            obj["explanation"] = fix_elision(obj["explanation"])
        return obj
    de = de_name(m.group(1))
    topic = seq_title.replace("'", "’")
    obj["sentence_with_error"] = (
        f"Les propos {de} sur « {topic} » est nets, et Lila laisse le micro ouvert."
    )
    obj["correct_sentence"] = (
        f"Les propos {de} sur « {topic} » sont nets, et Lila laisse le micro ouvert."
    )
    obj["explanation"] = "Accord : les propos sont nets."
    return obj
