#!/usr/bin/env python3
"""Dump every learner-facing French string for the proofreading pass."""

from pathlib import Path

from content import SEQUENCES

ROOT = Path(__file__).resolve().parents[2]
OUT = ROOT / "docs/Relecture_MFK_A1_Module7_textes.txt"


def walk(obj, acc: list[str]) -> None:
    if isinstance(obj, str):
        acc.append(obj)
    elif isinstance(obj, dict):
        for value in obj.values():
            walk(value, acc)
    elif isinstance(obj, list):
        for item in obj:
            walk(item, acc)


def main() -> None:
    lines = []
    for seq in SEQUENCES:
        lines.append("=" * 72)
        lines.append(seq["title"])
        lines.append("=" * 72)
        for lesson in seq["lessons"]:
            lines.append("")
            lines.append(f"--- {lesson['title']} ({lesson['competency']}) ---")
            lines.append(lesson["content"])
            for ex in lesson["exercises"]:
                texts: list[str] = []
                walk(ex["content"], texts)
                for text in texts:
                    if text.startswith("/elearning/"):
                        continue
                    lines.append(f"[{ex['type']}] {text}")
            lines.append("")
    OUT.write_text("\n".join(lines), encoding="utf-8")
    print(f"Wrote {OUT}")


if __name__ == "__main__":
    main()
