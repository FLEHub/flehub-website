/*
  Relecture QA MFK — correctifs idempotents (niveau B1).
  UPDATE ciblés uniquement. Aucune table nouvelle.
  published n'est pas modifié.
  Clés métier : titre de module + titre de séquence + compétence
  (+ type et order_index pour les exercices).
*/

-- B1 — Ailleurs, un nouveau chez-soi
UPDATE elearning_exercises e
SET content = $qj${
  "pairs": [
    {
      "left": "si Léa s'installait",
      "right": "elle s'adapterait"
    },
    {
      "left": "plus calme / plus proche",
      "right": "Seuil / Rive-des-Saules"
    },
    {
      "left": "mettre en garde",
      "right": "ne pas s'éloigner de ceux qui restent"
    },
    {
      "left": "compter sur",
      "right": "Lila / Aline"
    }
  ]
}$qj$::jsonb
FROM elearning_lessons l
JOIN elearning_sequences s ON s.id = l.sequence_id
JOIN elearning_modules m ON m.id = s.module_id
WHERE e.lesson_id = l.id
  AND m.title = 'B1 — Ailleurs, un nouveau chez-soi'
  AND s.title = 'Deux rives, un choix'
  AND l.competency = 'PE'
  AND e.exercise_type = 'matching'
  AND e.order_index = 2;
