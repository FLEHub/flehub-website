import { exerciseTypeLabels, type ExerciseType } from '@/lib/elearning-exercises';
import {
  extractGrammarPoint,
  extractLexicalField,
  firstNonEmptyLines,
  firstQuestions,
  firstSentences,
  parseLessonSections,
} from '@/lib/elearning/lesson-sections';

export type SheetCompetency = 'CO' | 'CE' | 'PE' | 'PO' | 'EL' | string;

export interface SheetExercise {
  title: string;
  exercise_type: string;
  order_index: number;
}

export interface SheetLesson {
  id: string;
  title: string;
  competency: SheetCompetency | null;
  content: string | null;
  order_index: number;
  exercises: SheetExercise[];
}

export interface SheetSequenceInput {
  id: string;
  title: string;
  order_index: number;
  lessons: SheetLesson[];
}

export interface SheetModuleInput {
  id: string;
  title: string;
  description: string | null;
  cefr_level: string | null;
  published?: boolean;
  sequences: SheetSequenceInput[];
  /** Rang du module dans le niveau (1-based), si connu. */
  moduleNumber?: number;
}

export interface SequenceRecap {
  title: string;
  communicationGoal: string;
  grammarPoint: string;
  lexicalField: string;
}

export interface SequenceSheet {
  index: number;
  title: string;
  communicationGoal: string;
  linguisticGoal: string;
  supportSummary: string[];
  rundown: {
    warmup: { duration: string; text: string };
    comprehension: { duration: string; text: string };
    language: { duration: string; text: string };
    production: { duration: string; text: string };
  };
  lessonExercises: {
    competency: string;
    lessonTitle: string;
    items: { title: string; typeLabel: string }[];
  }[];
}

export interface PedagogicalSheet {
  moduleTitle: string;
  cefrLevel: string;
  description: string;
  moduleNumber: number;
  filename: string;
  recap: SequenceRecap[];
  sequences: SequenceSheet[];
}

const COMP_ORDER = ['CO', 'CE', 'PO', 'PE', 'EL'] as const;

function lessonByComp(lessons: SheetLesson[], comp: string): SheetLesson | undefined {
  return lessons.find((l) => (l.competency || '').toUpperCase() === comp);
}

function typeLabel(type: string): string {
  if (type in exerciseTypeLabels) {
    return exerciseTypeLabels[type as ExerciseType];
  }
  return type || 'Exercice';
}

export function parseModuleNumber(
  title: string,
  description: string | null | undefined,
  fallback?: number
): number {
  const fromDesc = description?.match(/Grande étape\s+(?:[ABC][12]\s*[-–—]\s*)?(\d+)/i);
  if (fromDesc?.[1]) return Number(fromDesc[1]);
  const fromTitle = title.match(/\bmodule\s*(\d+)\b/i);
  if (fromTitle?.[1]) return Number(fromTitle[1]);
  return fallback && fallback > 0 ? fallback : 1;
}

export function slugifyModuleTitle(title: string): string {
  const withoutLevel = title.replace(/^(A1|A2|B1|B2|C1|C2)\s*[—–-]\s*/i, '');
  return withoutLevel
    .normalize('NFD')
    .replace(/[\u0300-\u036f]/g, '')
    .toLowerCase()
    .replace(/[^a-z0-9]+/g, '-')
    .replace(/^-+|-+$/g, '')
    .slice(0, 48) || 'module';
}

export function pedagogicalFilename(sheet: Pick<PedagogicalSheet, 'cefrLevel' | 'moduleNumber' | 'moduleTitle'>): string {
  const level = (sheet.cefrLevel || 'XX').toUpperCase();
  const slug = slugifyModuleTitle(sheet.moduleTitle);
  return `fiche-pedagogique_MFK_${level}_module${sheet.moduleNumber}_${slug}.pdf`;
}

function buildSequenceSheet(seq: SheetSequenceInput, index: number): SequenceSheet {
  const lessons = [...seq.lessons].sort((a, b) => a.order_index - b.order_index);
  const co = lessonByComp(lessons, 'CO');
  const ce = lessonByComp(lessons, 'CE');
  const po = lessonByComp(lessons, 'PO');
  const pe = lessonByComp(lessons, 'PE');
  const el = lessonByComp(lessons, 'EL');

  const coS = parseLessonSections(co?.content);
  const ceS = parseLessonSections(ce?.content);
  const poS = parseLessonSections(po?.content);
  const peS = parseLessonSections(pe?.content);
  const elS = parseLessonSections(el?.content);

  const communicationGoal =
    firstSentences(coS.objectif, 2) ||
    firstSentences(ceS.objectif, 2) ||
    '—';
  const linguisticGoal = extractGrammarPoint(elS.objectif, el?.title || '');
  const lexicalField = extractLexicalField(elS, el?.title || '');

  const supportLines: string[] = [];
  if (coS.supportTitle) supportLines.push(coS.supportTitle);
  supportLines.push(...firstNonEmptyLines(coS.supportBody, 4, 140));
  if (supportLines.length === 0 && ceS.supportTitle) {
    supportLines.push(ceS.supportTitle);
    supportLines.push(...firstNonEmptyLines(ceS.supportBody, 3, 140));
  }

  const warmupQs = firstQuestions(coS.consigne, 1);
  const warmup =
    warmupQs[0] ||
    (coS.consigne ? firstSentences(coS.consigne, 1) : '') ||
    (coS.supportTitle ? `À partir du support : ${coS.supportTitle}` : '—');

  const comprehensionParts = [
    ...firstQuestions(coS.consigne, 2),
    ...firstQuestions(ceS.consigne, 2),
  ];
  const comprehension =
    comprehensionParts.length > 0
      ? comprehensionParts.join(' ')
      : [coS.consigne, ceS.consigne].filter(Boolean).map((t) => firstSentences(t, 2)).join(' ') ||
        '—';

  const elExamples = firstNonEmptyLines(elS.ficheBody, 2, 120);
  const language = [linguisticGoal, ...elExamples].filter(Boolean).join(' — ') || '—';

  const production =
    [peS.consigne, poS.consigne]
      .filter(Boolean)
      .map((t) => firstSentences(t, 2))
      .join(' ') || '—';

  const lessonExercises: SequenceSheet['lessonExercises'] = COMP_ORDER.map((comp) => {
    const lesson = lessonByComp(lessons, comp);
    if (!lesson) return null;
    const items = [...lesson.exercises]
      .sort((a, b) => a.order_index - b.order_index)
      .map((ex) => ({
        title: ex.title?.trim() || 'Exercice',
        typeLabel: typeLabel(ex.exercise_type),
      }));
    return {
      competency: comp,
      lessonTitle: lesson.title,
      items,
    };
  }).filter((row): row is NonNullable<typeof row> => row !== null);

  // Leçons hors ordre CO/CE/PO/PE/EL
  for (const lesson of lessons) {
    const comp = (lesson.competency || '').toUpperCase();
    if (COMP_ORDER.includes(comp as (typeof COMP_ORDER)[number])) continue;
    lessonExercises.push({
      competency: comp || '—',
      lessonTitle: lesson.title,
      items: [...lesson.exercises]
        .sort((a, b) => a.order_index - b.order_index)
        .map((ex) => ({
          title: ex.title?.trim() || 'Exercice',
          typeLabel: typeLabel(ex.exercise_type),
        })),
    });
  }

  return {
    index,
    title: seq.title || `Séquence ${index}`,
    communicationGoal,
    linguisticGoal: linguisticGoal === '—' ? lexicalField : linguisticGoal,
    supportSummary: supportLines.length > 0 ? supportLines : ['Aucun support texte dans la leçon CO.'],
    rundown: {
      warmup: { duration: '5 min', text: warmup },
      comprehension: { duration: '15 min', text: comprehension },
      language: { duration: '10 min', text: language },
      production: { duration: '15 min', text: production },
    },
    lessonExercises,
  };
}

export function buildPedagogicalSheet(input: SheetModuleInput): PedagogicalSheet {
  const sequences = [...input.sequences].sort((a, b) => a.order_index - b.order_index);
  const moduleNumber = parseModuleNumber(input.title, input.description, input.moduleNumber);
  const recap: SequenceRecap[] = sequences.map((seq) => {
    const sheet = buildSequenceSheet(seq, 0);
    return {
      title: seq.title || 'Séquence',
      communicationGoal: sheet.communicationGoal,
      grammarPoint: sheet.linguisticGoal,
      lexicalField: extractLexicalField(
        parseLessonSections(lessonByComp(seq.lessons, 'EL')?.content),
        lessonByComp(seq.lessons, 'EL')?.title || ''
      ),
    };
  });

  const built = sequences.map((seq, i) => buildSequenceSheet(seq, i + 1));
  const sheet: PedagogicalSheet = {
    moduleTitle: input.title,
    cefrLevel: (input.cefr_level || '').toUpperCase() || '—',
    description: (input.description || '').trim(),
    moduleNumber,
    filename: '',
    recap,
    sequences: built,
  };
  sheet.filename = pedagogicalFilename(sheet);
  return sheet;
}
