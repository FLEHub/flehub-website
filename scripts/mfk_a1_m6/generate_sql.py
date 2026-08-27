#!/usr/bin/env python3
"""Build the idempotent SQL seed for MFK A1 Module 6 from content.py."""

from __future__ import annotations

import json
from pathlib import Path

from content import MODULE, SEQUENCES

ROOT = Path(__file__).resolve().parents[2]
OUT = ROOT / "supabase/migrations/20260827140000_elearning_mfk_a1_module6_histoires_vecues.sql"

HELPERS = r"""/*
  Seed eLearning MFK — Module 6 A1 « Histoires vécues »

  Même micro-monde que les Modules 3, 4 et 5 : cour « Le Seuil des Sources », Rukiri-Nord.
  Cahier des histoires inventé sous le figuier.
  6 séquences × 5 leçons × 10 exercices (tous les types).
  Illustrations originales : /elearning/mfk-a1-m6/
  Module laissé en brouillon (published = false).
  Aucune table nouvelle. Idempotent. Éditable via « Gérer le contenu ».
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

BOOT = r"""
DO $$
DECLARE
  v_teacher_id uuid;
  v_teacher_email text;
  v_module_id uuid;
  v_seq_id uuid;
  v_lesson_id uuid;
  v_module_title text := %s;
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
      'Seed A1 Module 6 impossible : aucun enseignant (teachers) trouvé.';
  END IF;

  RAISE NOTICE 'Seed Module 6 : enseignant %% (%%)', v_teacher_email, v_teacher_id;

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
      %s,
      'A1',
      false
    )
    RETURNING id INTO v_module_id;
  ELSE
    UPDATE elearning_modules
    SET
      description = %s,
      cefr_level = 'A1',
      published = false,
      updated_at = now()
    WHERE id = v_module_id;
  END IF;
"""


def sql_str(value: str) -> str:
    return "'" + value.replace("'", "''") + "'"


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


def main() -> None:
    lines = [
        HELPERS,
        BOOT
        % (
            sql_str(MODULE["title"]),
            sql_str(MODULE["description"]),
            sql_str(MODULE["description"]),
        ),
    ]

    for seq_index, seq in enumerate(SEQUENCES):
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

    OUT.parent.mkdir(parents=True, exist_ok=True)
    OUT.write_text("\n".join(lines), encoding="utf-8")
    n_lessons = sum(len(s["lessons"]) for s in SEQUENCES)
    n_ex = sum(len(l["exercises"]) for s in SEQUENCES for l in s["lessons"])
    print(f"Wrote {OUT} ({n_lessons} lessons, {n_ex} exercises)")


if __name__ == "__main__":
    main()
