-- Expand elearning_exercises.exercise_type with interactive activity types

ALTER TABLE elearning_exercises
  DROP CONSTRAINT IF EXISTS elearning_exercises_exercise_type_check;

ALTER TABLE elearning_exercises
  ADD CONSTRAINT elearning_exercises_exercise_type_check
  CHECK (
    exercise_type IN (
      'qcm',
      'matching',
      'fill_blank',
      'short_answer',
      'word_order',
      'anagram',
      'true_false',
      'image_match',
      'find_error'
    )
  );
