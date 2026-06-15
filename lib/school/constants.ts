export const CEFR_LEVELS = ['A1', 'A2', 'B1', 'B2', 'C1', 'C2'] as const;
export type CefrLevel = (typeof CEFR_LEVELS)[number];

export const COMPETENCIES = [
  { key: 'EO', scoreKey: 'score_eo', label: 'Expression Orale' },
  { key: 'EE', scoreKey: 'score_ee', label: 'Expression Écrite' },
  { key: 'CO', scoreKey: 'score_co', label: 'Compréhension Orale' },
  { key: 'CE', scoreKey: 'score_ce', label: 'Compréhension Écrite' },
  { key: 'LANGUE', scoreKey: 'score_langue', label: 'Étude de la Langue' },
] as const;

export type Competency = (typeof COMPETENCIES)[number]['key'];
export type ScoreKey = (typeof COMPETENCIES)[number]['scoreKey'];

export const SCHOOL_TYPE_LABELS: Record<string, string> = {
  primary: 'Primaire',
  secondary: 'Secondaire',
  both: 'Primaire et secondaire',
};

export const SCHOOL_STATUS_LABELS: Record<string, string> = {
  pending: 'En attente',
  approved: 'Approuvé',
  rejected: 'Rejeté',
  suspended: 'Suspendu',
};

export const RESULT_STATUS_LABELS: Record<string, string> = {
  draft: 'Brouillon',
  submitted: 'Soumis',
  validated: 'Validé',
  rejected: 'Corrections demandées',
};

export function normalizeCefrLevel(value: unknown): CefrLevel | null {
  return typeof value === 'string' && CEFR_LEVELS.includes(value as CefrLevel)
    ? (value as CefrLevel)
    : null;
}

export function normalizeCompetency(value: unknown): Competency | null {
  return typeof value === 'string' && COMPETENCIES.some((c) => c.key === value)
    ? (value as Competency)
    : null;
}

export function sanitizeFileName(value: string) {
  return value
    .normalize('NFD')
    .replace(/[\u0300-\u036f]/g, '')
    .replace(/[^a-zA-Z0-9._-]+/g, '-')
    .replace(/^-+|-+$/g, '')
    .toLowerCase();
}

export function calculateOverallPass(
  scores: Record<ScoreKey, number>,
  passThreshold = 60,
  competencyThreshold = 0
) {
  const values = COMPETENCIES.map((competency) => scores[competency.scoreKey]);
  const average = values.reduce((sum, score) => sum + score, 0) / values.length;
  const competenciesOk = values.every((score) => score >= competencyThreshold);
  return {
    average,
    passed: average >= passThreshold && competenciesOk,
  };
}
