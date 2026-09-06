#!/usr/bin/env python3
"""Extract pedagogical text from MFK SQL seeds and flag QA issues."""
from __future__ import annotations

import json
import re
from collections import Counter, defaultdict
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
MIG = ROOT / "supabase/migrations"

C_BLOCK = re.compile(r"\$c\$(.*?)\$c\$", re.S)
J_BLOCK = re.compile(r"\$j\$(.*?)\$j\$", re.S)
MOD_TITLE = re.compile(r"v_module_title text := '([^']+)'")
MOD_DESC = re.compile(
    r"INSERT INTO elearning_modules[\s\S]{0,400}?VALUES\s*\(\s*v_teacher_id,\s*v_module_title,\s*'((?:[^']|'')+)'",
    re.S,
)
SEQ_TITLE = re.compile(r"AND s\.title = '((?:[^']|'')+)'")
LESSON_TITLE = re.compile(
    r"v_lesson_id := pg_temp\.mfk_upsert_lesson\(\s*v_seq_id,\s*'((?:[^']|'')+)'",
    re.S,
)

COPYRIGHT = re.compile(
    r"cosmopolite|#bodypositive|circulez!|vague à l'âme|étrangéité|super candidat|"
    r"doux dingues|fais gaffe|pays membres|routinite|bienveilleurs|"
    r"alter ego|éditorial hachette|didier fle",
    re.I,
)
REAL_PLACES = re.compile(
    r"\b(Paris|Lyon|Marseille|Bordeaux|Toulouse|Lille|Nantes|Strasbourg|"
    r"Bruxelles|Genève|Montréal|Dakar|Abidjan|Kinshasa)\b"
)
TYPO_DOUBLE = re.compile(r"  +")
ASCII_QUOTES = re.compile(r'(?<![\\$])"')
MISSING_NBSP = re.compile(r"(?<![\s\u00a0\u202f])[:;!?]")
QUE_UNE = re.compile(r"\bque une\b|\bde le\b|\bà le\b|\bIl ressort que une\b", re.I)
FAUTONS = re.compile(r"\bfautons\b|\bfaisons faut\b")
META_ERROR = re.compile(r"\(accord|\(féminin|\(masculin|\(sans |au féminin|à la 3")


def unescape(s: str) -> str:
    return s.replace("''", "'")


def scan_file(path: Path) -> dict:
    text = path.read_text(encoding="utf-8")
    titles = MOD_TITLE.findall(text)
    flags: list[str] = []
    contents = C_BLOCK.findall(text)
    jsons = []
    for raw in J_BLOCK.findall(text):
        try:
            jsons.append(json.loads(raw))
        except json.JSONDecodeError as e:
            flags.append(f"JSON invalide: {e}")
    blobs = contents[:]
    for obj in jsons:
        blobs.append(json.dumps(obj, ensure_ascii=False))

    counts = Counter()
    samples = defaultdict(list)

    def add(kind: str, snippet: str) -> None:
        counts[kind] += 1
        if len(samples[kind]) < 8:
            samples[kind].append(re.sub(r"\s+", " ", snippet)[:180])

    for blob in blobs:
        if COPYRIGHT.search(blob):
            add("copyright", blob)
        if REAL_PLACES.search(blob) and "Val-des-Peupliers" not in blob:
            m = REAL_PLACES.search(blob)
            add(f"lieu_reel:{m.group(1)}", blob[max(0, m.start() - 40) : m.end() + 40])
        if QUE_UNE.search(blob):
            add("construction", QUE_UNE.search(blob).group(0) + " | " + blob[:120])
        if FAUTONS.search(blob) and "sentence_with_error" not in blob:
            # fautons in find_error wrong sentence is OK; in other text not
            add("fautons_hors_erreur", blob[:140])
        if META_ERROR.search(blob) and "sentence_with_error" in json.dumps(blob) if False else META_ERROR.search(blob):
            add("meta_commentaire", blob[:140])
        if TYPO_DOUBLE.search(blob):
            add("double_espace", blob[max(0, TYPO_DOUBLE.search(blob).start() - 20) :][:80])
        # ASCII quotes in learner-facing French (not JSON keys)
        if "«" not in blob and ASCII_QUOTES.search(blob) and "$" not in blob[:2]:
            if re.search(r"[A-Za-zÀ-ÿ]\s*\"|[\"«]", blob):
                add("guillemets_ascii", blob[:100])

    # typography in lesson content only
    for blob in contents:
        for m in re.finditer(r"[A-Za-zÀ-ÿ][:;!?]", blob):
            add("espace_avant_ponct", blob[max(0, m.start() - 15) : m.end() + 5])
        if re.search(r"<<|>>|''[^']", blob):
            add("guillemets_bizarres", blob[:80])

    for obj in jsons:
        dumped = json.dumps(obj, ensure_ascii=False)
        if obj.get("sentence_with_error") and META_ERROR.search(obj.get("sentence_with_error", "")):
            add("find_error_meta", obj["sentence_with_error"][:160])
        if obj.get("hint") and obj.get("word"):
            if obj["word"].casefold() in obj["hint"].casefold():
                add("anagramme_indice", f"{obj['word']} in {obj['hint']}")
        opts = obj.get("options")
        if isinstance(opts, list):
            correct = [o for o in opts if isinstance(o, dict) and o.get("correct")]
            if len(opts) == 4 and len(correct) != 1:
                add("qcm_correct", dumped[:120])

    return {
        "file": path.name,
        "module": unescape(titles[0]) if titles else path.name,
        "n_content": len(contents),
        "n_json": len(jsons),
        "counts": dict(counts),
        "samples": {k: v for k, v in samples.items()},
        "flags": flags,
    }


def main() -> None:
    files = sorted(MIG.glob("*elearning_mfk_*.sql"))
    out = ROOT / "scripts/mfk_qa/scan_report.json"
    results = []
    total = Counter()
    for f in files:
        r = scan_file(f)
        results.append(r)
        total.update(r["counts"])
        print(f"{r['module'][:42]:42} contents={r['n_content']:3} json={r['n_json']:4} issues={sum(r['counts'].values()):4}")
    out.write_text(json.dumps({"total": dict(total), "files": results}, ensure_ascii=False, indent=2), encoding="utf-8")
    print("\nTOTAL", dict(total))
    print("wrote", out)


if __name__ == "__main__":
    main()
