#!/usr/bin/env python3
"""Émet des migrations UPDATE idempotentes à partir des seeds MFK existants."""
from __future__ import annotations

import json
import re
from collections import Counter, defaultdict
from pathlib import Path

from fr_fix import (
    IMAGE_RENAMES,
    fix_c_lesson,
    rewrite_find_error_agreement,
    walk_json,
)

ROOT = Path(__file__).resolve().parents[2]
MIG = ROOT / "supabase/migrations"

C_BLOCK = re.compile(
    r"v_lesson_id := pg_temp\.mfk_upsert_lesson\(\s*"
    r"v_seq_id,\s*'((?:[^']|'')+)',\s*'([A-Z]+)',\s*"
    r"\$c\$(.*?)\$c\$",
    re.S,
)
EX_BLOCK = re.compile(
    r"PERFORM pg_temp\.mfk_seed_exercise\(\s*"
    r"v_lesson_id,\s*'((?:[^']|'')+)',\s*'([a-z_]+)',\s*"
    r"\$j\$(.*?)\$j\$::jsonb,\s*(\d+)",
    re.S,
)
MOD_TITLE = re.compile(r"v_module_title text := '((?:[^']|'')+)'")
SEQ_TITLE = re.compile(r"AND s\.title = '((?:[^']|'')+)'")
MOD_DESC = re.compile(
    r"INSERT INTO elearning_modules[\s\S]{0,500}?VALUES\s*\(\s*v_teacher_id,\s*v_module_title,\s*'((?:[^']|'')+)'",
    re.S,
)


def unescape(s: str) -> str:
    return s.replace("''", "'")


def sql_str(s: str) -> str:
    return "'" + s.replace("'", "''") + "'"


def parse_file(path: Path) -> dict:
    text = path.read_text(encoding="utf-8")
    titles = MOD_TITLE.findall(text)
    module = unescape(titles[0]) if titles else path.name
    descs = MOD_DESC.findall(text)
    description = unescape(descs[0]) if descs else ""

    # Walk the file to attach sequence titles to lessons/exercises
    seq = None
    lessons = []
    pos_to_seq = []
    for m in SEQ_TITLE.finditer(text):
        pos_to_seq.append((m.start(), unescape(m.group(1))))

    def seq_at(pos: int) -> str:
        cur = ""
        for p, title in pos_to_seq:
            if p <= pos:
                cur = title
            else:
                break
        return cur

    for m in C_BLOCK.finditer(text):
        lessons.append(
            {
                "seq": seq_at(m.start()),
                "title": unescape(m.group(1)),
                "comp": m.group(2),
                "content": m.group(3),
                "exercises": [],
            }
        )

    # Attach exercises to the most recent lesson before them
    lesson_starts = [m.start() for m in C_BLOCK.finditer(text)]
    for m in EX_BLOCK.finditer(text):
        idx = 0
        for i, start in enumerate(lesson_starts):
            if start < m.start():
                idx = i
            else:
                break
        lessons[idx]["exercises"].append(
            {
                "title": unescape(m.group(1)),
                "type": m.group(2),
                "json": json.loads(m.group(3)),
                "order": int(m.group(4)),
            }
        )

    return {
        "file": path.name,
        "module": module,
        "description": description,
        "lessons": lessons,
    }


def is_c_level(title: str) -> bool:
    return title.startswith("C1 — ") or title.startswith("C2 — ")


def apply_targeted(parsed: dict, stats: Counter) -> None:
    """Correctifs ponctuels A1–B2 (et quelques titres)."""
    mod = parsed["module"]

    def touch_lesson(pred, fn, kind: str) -> None:
        for les in parsed["lessons"]:
            if pred(les):
                new = fn(les)
                if new != les["content"] or (isinstance(new, tuple)):
                    if isinstance(new, tuple):
                        title, content = new
                        if title != les["title"]:
                            les["title"] = title
                            stats[kind] += 1
                        if content != les["content"]:
                            les["content"] = content
                            stats[kind] += 1
                    else:
                        les["content"] = new
                        stats[kind] += 1

    def touch_ex(pred, fn, kind: str) -> None:
        for les in parsed["lessons"]:
            for ex in les["exercises"]:
                if pred(les, ex):
                    new = fn(les, ex)
                    if new != ex["json"]:
                        ex["json"] = new
                        stats[kind] += 1

    # A1 M1 — élision titre + typo + anagrammes
    if mod == "A1 — Premiers repères":
        for les in parsed["lessons"]:
            if les["title"] == "CO — Un « bonjour » sous le auvent":
                les["title"] = "CO — Un « bonjour » sous l'auvent"
                stats["a1_titre"] += 1
            if "0 zéro  1 un" in les["content"]:
                les["content"] = les["content"].replace("  ", " ")
                stats["a1_typo"] += 1
            if "je suis  tu es" in les["content"]:
                les["content"] = les["content"].replace("  ", " ")
                stats["a1_typo"] += 1
        hint_map = {
            "Je parle français.": "Verbe après « je » pour une langue.",
            "Sonia le montre : un livre.": "Sonia le montre sur le muret.",
            "On le prend : un stylo.": "Inès le demande à Yvan.",
            "Ouvrez le cahier.": "Consigne d'Inès au début de l'atelier.",
            "C'est une table (la table pliante).": "Objet pliant de l'atelier.",
            "C'est un stylo. Objet masculin de la table.": "Objet masculin que Didier note sur sa liste.",
        }
        for les in parsed["lessons"]:
            for ex in les["exercises"]:
                if ex["type"] == "anagram" and ex["json"].get("hint") in hint_map:
                    ex["json"]["hint"] = hint_map[ex["json"]["hint"]]
                    stats["a1_anagramme"] += 1

    # A1 M6 — Yvette : colline + infirmerie
    if mod == "A1 — Histoires vécues":
        for les in parsed["lessons"]:
            if les["title"] == "CO — Yvette a choisi la colline":
                old = "Yvette : Maintenant, je suis ici. Je travaille à l'Infirmerie des Herbes."
                new = (
                    "Yvette : J'ai choisi la colline. Maintenant, je suis ici. "
                    "Je travaille à l'Infirmerie des Herbes."
                )
                if old in les["content"]:
                    les["content"] = les["content"].replace(old, new)
                    stats["a1_yvette"] += 1

    # A2 M4 — lanternes : allumer vs éteindre
    if mod == "A2 — Cultures en partage":
        for les in parsed["lessons"]:
            if "Faut-il allumer toutes les lanternes ?" in les["content"]:
                les["content"] = les["content"].replace(
                    "Noura : Faut-il allumer toutes les lanternes ?",
                    "Noura : Faut-il éteindre les lanternes à minuit ?",
                )
                stats["a2_lanternes"] += 1

    # A2 M8 — Feuille de une + casse Cahier
    if mod == "A2 — Le monde en direct":
        for les in parsed["lessons"]:
            if "Feuille de une" in les["title"] or "Feuille de une" in les["content"]:
                les["title"] = les["title"].replace("Feuille de une", "Feuille de la une")
                les["content"] = les["content"].replace("Feuille de une", "Feuille de la une")
                stats["a2_une"] += 1
            if "le cahier du Chemin" in les["content"]:
                les["content"] = les["content"].replace(
                    "le cahier du Chemin", "le Cahier du chemin"
                )
                stats["a2_cahier"] += 1

    # B1 M1 — matching
    if mod == "B1 — Ailleurs, un nouveau chez-soi":
        for les in parsed["lessons"]:
            for ex in les["exercises"]:
                if ex["type"] != "matching":
                    continue
                pairs = ex["json"].get("pairs") or []
                changed = False
                for p in pairs:
                    if p.get("right") == "ne pas s'éloigner des restants":
                        p["right"] = "ne pas s'éloigner de ceux qui restent"
                        changed = True
                if changed:
                    stats["b1_matching"] += 1

    # B2 M2 — hypothèsons / hypothétisé
    if mod == "B2 — Mémoire du Seuil":
        for les in parsed["lessons"]:
            if "hypothesons" in les["content"]:
                les["content"] = les["content"].replace("hypothesons", "hypothèsons")
                stats["b2_ortho"] += 1
            if "hypothesé" in les["content"]:
                les["content"] = les["content"].replace("hypothesé", "hypothétisé")
                stats["b2_ortho"] += 1

    # B2 M3 — casse Veillée
    if mod == "B2 — Une culture commune":
        if "Veillée des lampions" in parsed["description"]:
            parsed["description"] = parsed["description"].replace(
                "Veillée des lampions", "Veillée des Lampions"
            )
            stats["b2_casse"] += 1

    # B2 M4 — puisqu'une
    if mod == "B2 — Vivre avec la technologie":
        for les in parsed["lessons"]:
            for ex in les["exercises"]:
                if ex["type"] != "matching":
                    continue
                pairs = ex["json"].get("pairs") or []
                changed = False
                for p in pairs:
                    if p.get("left") == "puisque une marque reste":
                        p["left"] = "puisqu'une marque reste"
                        changed = True
                if changed:
                    stats["b2_elision"] += 1


def apply_c_level(parsed: dict, stats: Counter) -> None:
    for les in parsed["lessons"]:
        new_c = fix_c_lesson(les["content"])
        if new_c != les["content"]:
            les["content"] = new_c
            stats["c_lecon"] += 1
        for ex in les["exercises"]:
            old = json.dumps(ex["json"], ensure_ascii=False, sort_keys=True)
            obj = walk_json(ex["json"], exercise_type=ex["type"])
            if ex["type"] == "find_error":
                obj = rewrite_find_error_agreement(obj, les["seq"])
            new = json.dumps(obj, ensure_ascii=False, sort_keys=True)
            if new != old:
                ex["json"] = obj
                stats["c_exo"] += 1


def emit_module_updates(parsed: dict, orig: dict) -> list[str]:
    """Compare parsed (maybe edited) to orig and emit UPDATEs."""
    stmts = []
    mod = parsed["module"]
    if parsed["description"] != orig["description"] and parsed["description"]:
        stmts.append(
            "UPDATE elearning_modules\n"
            f"SET description = {sql_str(parsed['description'])}\n"
            f"WHERE title = {sql_str(mod)};"
        )

    orig_lessons = {(l["seq"], l["comp"]): l for l in orig["lessons"]}
    for les in parsed["lessons"]:
        ol = orig_lessons.get((les["seq"], les["comp"]))
        if not ol:
            continue
        title_changed = les["title"] != ol["title"]
        content_changed = les["content"] != ol["content"]
        if title_changed or content_changed:
            sets = []
            if title_changed:
                sets.append(f"title = {sql_str(les['title'])}")
            if content_changed:
                sets.append(f"content = $qa${les['content']}$qa$")
            stmts.append(
                "UPDATE elearning_lessons l\n"
                f"SET {', '.join(sets)}\n"
                "FROM elearning_sequences s\n"
                "JOIN elearning_modules m ON m.id = s.module_id\n"
                "WHERE l.sequence_id = s.id\n"
                f"  AND m.title = {sql_str(mod)}\n"
                f"  AND s.title = {sql_str(les['seq'])}\n"
                f"  AND l.competency = {sql_str(les['comp'])};"
            )
        orig_ex = {(e["type"], e["order"]): e for e in ol["exercises"]}
        for ex in les["exercises"]:
            oe = orig_ex.get((ex["type"], ex["order"]))
            if not oe:
                continue
            if json.dumps(ex["json"], ensure_ascii=False, sort_keys=True) != json.dumps(
                oe["json"], ensure_ascii=False, sort_keys=True
            ):
                payload = json.dumps(ex["json"], ensure_ascii=False, indent=2)
                stmts.append(
                    "UPDATE elearning_exercises e\n"
                    f"SET content = $qj${payload}$qj$::jsonb\n"
                    "FROM elearning_lessons l\n"
                    "JOIN elearning_sequences s ON s.id = l.sequence_id\n"
                    "JOIN elearning_modules m ON m.id = s.module_id\n"
                    "WHERE e.lesson_id = l.id\n"
                    f"  AND m.title = {sql_str(mod)}\n"
                    f"  AND s.title = {sql_str(les['seq'])}\n"
                    f"  AND l.competency = {sql_str(les['comp'])}\n"
                    f"  AND e.exercise_type = {sql_str(ex['type'])}\n"
                    f"  AND e.order_index = {ex['order']};"
                )
    return stmts


LEVEL_FILES = {
    "a1": "20260906120000_elearning_mfk_qa_a1.sql",
    "a2": "20260906120100_elearning_mfk_qa_a2.sql",
    "b1": "20260906120200_elearning_mfk_qa_b1.sql",
    "b2": "20260906120300_elearning_mfk_qa_b2.sql",
    "c1": "20260906120400_elearning_mfk_qa_c1.sql",
    "c2": "20260906120500_elearning_mfk_qa_c2.sql",
}


def level_of(title: str) -> str:
    if title.startswith("A1"):
        return "a1"
    if title.startswith("A2"):
        return "a2"
    if title.startswith("B1"):
        return "b1"
    if title.startswith("B2"):
        return "b2"
    if title.startswith("C1"):
        return "c1"
    if title.startswith("C2"):
        return "c2"
    return "other"


HEADER = """\
/*
  Relecture QA MFK — correctifs idempotents (niveau {level}).
  UPDATE ciblés uniquement. Aucune table nouvelle.
  published n'est pas modifié.
  Clés métier : titre de module + titre de séquence + compétence
  (+ type et order_index pour les exercices).
*/

"""


def main() -> None:
    files = sorted(MIG.glob("*elearning_mfk_*.sql"))
    files = [f for f in files if "_qa_" not in f.name]
    by_level: dict[str, list[str]] = defaultdict(list)
    stats = Counter()
    per_module = []

    import copy

    for path in files:
        orig = parse_file(path)
        parsed = parse_file(path)  # fresh copy
        before = {
            "desc": parsed["description"],
            "lessons": copy.deepcopy(parsed["lessons"]),
        }
        apply_targeted(parsed, stats)
        if is_c_level(parsed["module"]):
            apply_c_level(parsed, stats)
        stmts = emit_module_updates(parsed, orig)
        n_lesson = sum(1 for s in stmts if "elearning_lessons" in s)
        n_ex = sum(1 for s in stmts if "elearning_exercises" in s)
        n_mod = sum(1 for s in stmts if "elearning_modules" in s and "JOIN" not in s)
        per_module.append(
            {
                "module": parsed["module"],
                "file": path.name,
                "updates_modules": n_mod,
                "updates_lessons": n_lesson,
                "updates_exercises": n_ex,
            }
        )
        if stmts:
            by_level[level_of(parsed["module"])].extend(
                [f"-- {parsed['module']}", *stmts, ""]
            )
        print(
            f"{parsed['module'][:42]:42} updates={len(stmts):4} "
            f"L={n_lesson} E={n_ex} M={n_mod}"
        )

    for level, name in LEVEL_FILES.items():
        body = by_level.get(level, [])
        out = MIG / name
        out.write_text(HEADER.format(level=level.upper()) + "\n".join(body), encoding="utf-8")
        print("wrote", out, "bytes", out.stat().st_size, "stmts", len(body))

    report = ROOT / "scripts/mfk_qa/emit_stats.json"
    report.write_text(
        json.dumps(
            {"stats": dict(stats), "modules": per_module},
            ensure_ascii=False,
            indent=2,
        ),
        encoding="utf-8",
    )
    print("stats", dict(stats))
    print("wrote", report)


if __name__ == "__main__":
    main()
