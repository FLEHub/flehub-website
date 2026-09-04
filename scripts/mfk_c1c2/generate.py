#!/usr/bin/env python3
"""Build idempotent SQL seeds for all MFK C1–C2 modules (same architecture as B2)."""

from __future__ import annotations

import importlib
import json
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(Path(__file__).resolve().parent))

from draw import ensure_svgs

PACKS = [
    ("m1", "20260904120000_elearning_mfk_c1_module1_colline_demain.sql"),
    ("m2", "20260904120100_elearning_mfk_c1_module2_faims_figuier.sql"),
    ("m3", "20260904120200_elearning_mfk_c1_module3_soigner_autrement.sql"),
    ("m4", "20260904120300_elearning_mfk_c1_module4_corps_visibles.sql"),
    ("m5", "20260904120400_elearning_mfk_c1_module5_monde_cour.sql"),
    ("m6", "20260904120500_elearning_mfk_c1_module6_travailler_seuil.sql"),
    ("m7", "20260904120600_elearning_mfk_c2_module1_bonheurs_utopies.sql"),
    ("m8", "20260904120700_elearning_mfk_c2_module2_parler_nos_francais.sql"),
    ("m9", "20260904120800_elearning_mfk_c2_module3_ere_du_fil.sql"),
    ("m10", "20260904120900_elearning_mfk_c2_module4_figuier_se_souvient.sql"),
    ("m11", "20260904121000_elearning_mfk_c2_module5_cultures_croisees.sql"),
    ("m12", "20260904121100_elearning_mfk_c2_module6_revolutions_rive.sql"),
]


def helpers_sql(label: str, img_dir: str) -> str:
    return f"""/*
  Seed eLearning MFK — {label}

  Micro-monde : cour « Le Seuil des Sources », Rukiri-Nord.
  6 séquences × 5 leçons × 10 exercices (tous les types).
  Illustrations originales : /elearning/{img_dir}/
  Module laissé en brouillon (published = false).
  Aucune table nouvelle. Idempotent. Éditable via « Gérer le contenu ».
  A1 / A2 / B1 / B2 inchangés.
*/

CREATE OR REPLACE FUNCTION pg_temp.mfk_upsert_lesson(
  p_sequence_id uuid,
  p_title text,
  p_competency text,
  p_content text,
  p_order integer
) RETURNS uuid
LANGUAGE plpgsql
AS $$
DECLARE
  v_id uuid;
BEGIN
  SELECT l.id INTO v_id
  FROM elearning_lessons l
  WHERE l.sequence_id = p_sequence_id
    AND l.competency = p_competency
  ORDER BY l.order_index
  LIMIT 1;

  IF v_id IS NULL THEN
    INSERT INTO elearning_lessons (
      sequence_id, title, competency, content_type, content, order_index
    )
    VALUES (
      p_sequence_id, p_title, p_competency, 'text', p_content, p_order
    )
    RETURNING id INTO v_id;
  ELSE
    UPDATE elearning_lessons
    SET
      title = p_title,
      content_type = 'text',
      content = p_content,
      order_index = p_order
    WHERE id = v_id;
  END IF;

  DELETE FROM elearning_exercises
  WHERE lesson_id = v_id
    AND order_index BETWEEN 0 AND 9;

  RETURN v_id;
END;
$$;

CREATE OR REPLACE FUNCTION pg_temp.mfk_seed_exercise(
  p_lesson_id uuid,
  p_title text,
  p_type text,
  p_content jsonb,
  p_order integer
) RETURNS void
LANGUAGE plpgsql
AS $$
BEGIN
  INSERT INTO elearning_exercises (
    lesson_id, title, exercise_type, content, order_index
  )
  VALUES (
    p_lesson_id, p_title, p_type, p_content, p_order
  );
END;
$$;
"""


def sql_str(value: str) -> str:
    return "'" + value.replace("'", "''") + "'"


def boot_sql(title: str, description: str, cefr: str) -> str:
    t = sql_str(title)
    d = sql_str(description)
    c = sql_str(cefr)
    return f"""
DO $$
DECLARE
  v_teacher_id uuid;
  v_teacher_email text;
  v_module_id uuid;
  v_seq_id uuid;
  v_lesson_id uuid;
  v_module_title text := {t};
BEGIN
  SELECT t.id, p.email
    INTO v_teacher_id, v_teacher_email
  FROM teachers t
  JOIN profiles p ON p.id = t.profile_id
  WHERE lower(p.email) = 'murick50@gmail.com'
  LIMIT 1;

  IF v_teacher_id IS NULL THEN
    SELECT t.id, p.email
      INTO v_teacher_id, v_teacher_email
    FROM teachers t
    JOIN profiles p ON p.id = t.profile_id
    ORDER BY t.created_at ASC NULLS LAST
    LIMIT 1;
  END IF;

  IF v_teacher_id IS NULL THEN
    RAISE EXCEPTION
      'Seed {cefr} impossible : aucun enseignant (teachers) trouvé.';
  END IF;

  RAISE NOTICE 'Seed {cefr} : enseignant % (%) — %', v_teacher_email, v_teacher_id, v_module_title;

  SELECT m.id INTO v_module_id
  FROM elearning_modules m
  WHERE m.teacher_id = v_teacher_id
    AND m.title = v_module_title
  LIMIT 1;

  IF v_module_id IS NULL THEN
    INSERT INTO elearning_modules (
      teacher_id, title, description, cefr_level, published
    )
    VALUES (
      v_teacher_id,
      v_module_title,
      {d},
      {c},
      false
    )
    RETURNING id INTO v_module_id;
  ELSE
    UPDATE elearning_modules
    SET
      description = {d},
      cefr_level = {c},
      published = false,
      updated_at = now()
    WHERE id = v_module_id;
  END IF;
"""


def json_dollar(obj: object) -> str:
    dumped = json.dumps(obj, ensure_ascii=False, indent=2)
    if "$j$" in dumped:
        raise ValueError("JSON contains dollar-quote terminator")
    return f"$j${dumped}$j$::jsonb"


def content_dollar(text: str) -> str:
    if "$c$" in text:
        raise ValueError("Lesson content contains dollar-quote terminator")
    return f"$c${text}$c$"


def emit_exercises(lines: list[str], exercises: list[dict]) -> None:
    order = [
        "true_false",
        "qcm",
        "matching",
        "fill_blank",
        "word_order",
        "anagram",
        "find_error",
        "image_match",
        "short_answer",
        "audio_record",
    ]
    by_type = {ex["type"]: ex for ex in exercises}
    missing = [t for t in order if t not in by_type]
    if missing:
        raise ValueError(f"Missing exercise types: {missing}")
    titles = {
        "true_false": "Vrai ou faux",
        "qcm": "Choisissez la bonne réponse",
        "matching": "Associez",
        "fill_blank": "Complétez",
        "word_order": "Remettez les mots dans l'ordre",
        "anagram": "Lettres dans l'ordre",
        "find_error": "Trouvez l'erreur",
        "image_match": "Image et mot",
        "short_answer": "Réponse libre",
        "audio_record": "Enregistrez",
    }
    for i, typ in enumerate(order):
        ex = by_type[typ]
        lines.append("  PERFORM pg_temp.mfk_seed_exercise(")
        lines.append("    v_lesson_id,")
        lines.append(f"    {sql_str(titles[typ])},")
        lines.append(f"    {sql_str(typ)},")
        lines.append(f"    {json_dollar(ex['content'])},")
        lines.append(f"    {i}")
        lines.append("  );")
        lines.append("")


def validate(module: dict, sequences: list[dict], svg_dir: Path) -> None:
    used: set[str] = set()
    for seq in sequences:
        if len(seq["lessons"]) != 5:
            raise ValueError(f"{seq['title']}: expected 5 lessons")
        comps = [lesson["competency"] for lesson in seq["lessons"]]
        if comps != ["CO", "CE", "PO", "PE", "EL"]:
            raise ValueError(f"{seq['title']}: competencies {comps}")
        for lesson in seq["lessons"]:
            if lesson["competency"] == "PE" and "Imitez" not in lesson["content"]:
                raise ValueError(f"{lesson['title']}: PE consigne must use Imitez")
            for ex in lesson["exercises"]:
                if ex["type"] == "anagram":
                    word = ex["content"]["word"]
                    hint = ex["content"]["hint"]
                    if word.casefold() in hint.casefold():
                        raise ValueError(
                            f"{lesson['title']}: anagram hint contains {word!r}"
                        )
                if ex["type"] == "word_order":
                    for token in ex["content"]["words"]:
                        if "," in token:
                            raise ValueError(
                                f"{lesson['title']}: comma token {token!r}"
                            )
                if ex["type"] == "qcm":
                    options = ex["content"]["options"]
                    if len(options) != 4:
                        raise ValueError(f"{lesson['title']}: qcm needs 4 options")
                    if sum(1 for opt in options if opt["correct"]) != 1:
                        raise ValueError(f"{lesson['title']}: qcm needs one correct")
                if ex["type"] == "image_match":
                    for pair in ex["content"]["pairs"]:
                        name = pair["image_path"].rsplit("/", 1)[-1]
                        used.add(name)
                        path = svg_dir / name
                        if not path.exists():
                            raise ValueError(f"Missing SVG {path}")
    available = {p.name for p in svg_dir.glob("*.svg")}
    unused = available - used
    if unused:
        raise ValueError(f"{module['title']}: unused SVGs {sorted(unused)}")


def write_pack(mod_name: str, sql_name: str) -> None:
    pack = importlib.import_module(mod_name)
    module = pack.MODULE
    sequences = pack.SEQUENCES
    img_dir = pack.IMG_DIR
    cefr = module["cefr_level"]
    svg_dir = ROOT / "public/elearning" / img_dir
    ensure_svgs(img_dir)
    validate(module, sequences, svg_dir)

    lines = [
        helpers_sql(module["title"], img_dir),
        boot_sql(module["title"], module["description"], cefr),
    ]
    for seq_index, seq in enumerate(sequences):
        lines.append(f"  -- ===== {seq['title']} =====")
        lines.append("  SELECT s.id INTO v_seq_id")
        lines.append("  FROM elearning_sequences s")
        lines.append(
            "  WHERE s.module_id = v_module_id AND s.title = " + sql_str(seq["title"])
        )
        lines.append("  LIMIT 1;")
        lines.append("")
        lines.append("  IF v_seq_id IS NULL THEN")
        lines.append("    INSERT INTO elearning_sequences (module_id, title, order_index)")
        lines.append(f"    VALUES (v_module_id, {sql_str(seq['title'])}, {seq_index})")
        lines.append("    RETURNING id INTO v_seq_id;")
        lines.append("  ELSE")
        lines.append("    UPDATE elearning_sequences")
        lines.append(f"    SET order_index = {seq_index}")
        lines.append("    WHERE id = v_seq_id;")
        lines.append("  END IF;")
        lines.append("")
        for lesson_index, lesson in enumerate(seq["lessons"]):
            lines.append("  v_lesson_id := pg_temp.mfk_upsert_lesson(")
            lines.append("    v_seq_id,")
            lines.append(f"    {sql_str(lesson['title'])},")
            lines.append(f"    {sql_str(lesson['competency'])},")
            lines.append(f"    {content_dollar(lesson['content'])},")
            lines.append(f"    {lesson_index}")
            lines.append("  );")
            lines.append("")
            emit_exercises(lines, lesson["exercises"])
    lines.append("END;")
    lines.append("$$;")
    lines.append("")
    out = ROOT / "supabase/migrations" / sql_name
    out.write_text("\n".join(lines), encoding="utf-8")
    n_lessons = sum(len(s["lessons"]) for s in sequences)
    n_ex = sum(len(l["exercises"]) for s in sequences for l in s["lessons"])
    print(f"Wrote {out} ({n_lessons} lessons, {n_ex} exercises, {cefr})")


def main() -> None:
    names = sys.argv[1:] or [p[0] for p in PACKS]
    wanted = {n: sql for n, sql in PACKS}
    for name in names:
        if name not in wanted:
            raise SystemExit(f"Unknown pack {name}")
        write_pack(name, wanted[name])


if __name__ == "__main__":
    main()
