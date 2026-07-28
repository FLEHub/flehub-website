export type ExerciseType =
  | 'qcm'
  | 'matching'
  | 'fill_blank'
  | 'short_answer'
  | 'word_order'
  | 'anagram'
  | 'true_false'
  | 'image_match'
  | 'find_error'
  | 'audio_record';

export const EXERCISE_TYPES: ExerciseType[] = [
  'qcm',
  'matching',
  'fill_blank',
  'short_answer',
  'word_order',
  'anagram',
  'true_false',
  'image_match',
  'find_error',
  'audio_record',
];

export const exerciseTypeLabels: Record<ExerciseType, string> = {
  qcm: 'QCM',
  matching: 'Association',
  fill_blank: 'Texte à trous',
  short_answer: 'Réponse libre',
  word_order: "Remettre les mots dans l'ordre",
  anagram: "Remettre les lettres dans l'ordre",
  true_false: 'Vrai ou Faux',
  image_match: 'Association image-mot',
  find_error: "Trouve l'erreur",
  audio_record: 'Enregistrement audio',
};

export interface QcmOption {
  text: string;
  correct: boolean;
}

export interface MatchingPair {
  left: string;
  right: string;
}

export interface ImageMatchPair {
  image_path: string;
  word: string;
}

export interface ExerciseFormState {
  question: string;
  options: QcmOption[];
  explanation: string;
  pairs: MatchingPair[];
  prompt: string;
  answer: string;
  // word_order
  correct_sentence: string;
  // anagram
  word: string;
  hint: string;
  // true_false
  statement: string;
  trueFalseCorrect: boolean;
  // image_match
  imagePairs: ImageMatchPair[];
  // find_error
  sentence_with_error: string;
  find_error_correct: string;
  // audio_record
  instructions: string;
}

export function splitWords(sentence: string): string[] {
  return sentence.trim().split(/\s+/).filter(Boolean);
}

export function splitLetters(word: string): string[] {
  return Array.from(word.normalize('NFC').replace(/\s+/g, ''));
}

export function emptyExerciseForm(): ExerciseFormState {
  return {
    question: '',
    options: [
      { text: '', correct: true },
      { text: '', correct: false },
      { text: '', correct: false },
      { text: '', correct: false },
    ],
    explanation: '',
    pairs: [
      { left: '', right: '' },
      { left: '', right: '' },
    ],
    prompt: '',
    answer: '',
    correct_sentence: '',
    word: '',
    hint: '',
    statement: '',
    trueFalseCorrect: true,
    imagePairs: [
      { image_path: '', word: '' },
      { image_path: '', word: '' },
    ],
    sentence_with_error: '',
    find_error_correct: '',
    instructions: '',
  };
}

export function parseExerciseForm(
  type: ExerciseType,
  raw: Record<string, unknown> | null | undefined
): ExerciseFormState {
  const base = emptyExerciseForm();
  if (!raw || typeof raw !== 'object') return base;

  if (type === 'qcm') {
    const question = typeof raw.question === 'string' ? raw.question : '';
    const explanation = typeof raw.explanation === 'string' ? raw.explanation : '';
    let options: QcmOption[] = base.options;

    if (Array.isArray(raw.options)) {
      const optionsList = raw.options as unknown[];
      if (optionsList.every((o) => typeof o === 'string')) {
        const correctIndex =
          typeof raw.correct_index === 'number' ? raw.correct_index : 0;
        const texts = optionsList as string[];
        options = [0, 1, 2, 3].map((i) => ({
          text: texts[i] ?? '',
          correct: i === correctIndex,
        }));
      } else {
        options = [0, 1, 2, 3].map((i) => {
          const item = optionsList[i] as Record<string, unknown> | undefined;
          return {
            text: typeof item?.text === 'string' ? item.text : '',
            correct: Boolean(item?.correct ?? item?.is_correct),
          };
        });
        if (!options.some((o) => o.correct)) options[0].correct = true;
      }
    }

    return { ...base, question, options, explanation };
  }

  if (type === 'matching') {
    const pairsRaw = Array.isArray(raw.pairs) ? raw.pairs : [];
    const pairs: MatchingPair[] =
      pairsRaw.length > 0
        ? pairsRaw.map((p) => {
            const pair = p as Record<string, unknown>;
            return {
              left: typeof pair?.left === 'string' ? pair.left : '',
              right: typeof pair?.right === 'string' ? pair.right : '',
            };
          })
        : base.pairs;
    return { ...base, pairs };
  }

  if (type === 'fill_blank') {
    return {
      ...base,
      prompt: typeof raw.prompt === 'string' ? raw.prompt : '',
      answer: typeof raw.answer === 'string' ? raw.answer : '',
    };
  }

  if (type === 'short_answer') {
    const prompt =
      typeof raw.prompt === 'string'
        ? raw.prompt
        : typeof raw.question === 'string'
          ? raw.question
          : '';
    return { ...base, prompt };
  }

  if (type === 'word_order') {
    if (typeof raw.sentence === 'string' && raw.sentence.trim()) {
      return { ...base, correct_sentence: raw.sentence };
    }
    if (Array.isArray(raw.words)) {
      return {
        ...base,
        correct_sentence: (raw.words as unknown[])
          .filter((w): w is string => typeof w === 'string')
          .join(' '),
      };
    }
    return base;
  }

  if (type === 'anagram') {
    return {
      ...base,
      word: typeof raw.word === 'string' ? raw.word : '',
      hint: typeof raw.hint === 'string' ? raw.hint : '',
    };
  }

  if (type === 'true_false') {
    return {
      ...base,
      statement: typeof raw.statement === 'string' ? raw.statement : '',
      trueFalseCorrect: Boolean(raw.correct),
      explanation: typeof raw.explanation === 'string' ? raw.explanation : '',
    };
  }

  if (type === 'image_match') {
    const pairsRaw = Array.isArray(raw.pairs) ? raw.pairs : [];
    const imagePairs: ImageMatchPair[] =
      pairsRaw.length > 0
        ? pairsRaw.map((p) => {
            const pair =
              p && typeof p === 'object' && !Array.isArray(p)
                ? (p as Record<string, unknown>)
                : {};
            const imagePathCandidates = [
              pair.image_path,
              pair.imagePath,
              pair.image,
              pair.path,
              pair.url,
            ];
            let image_path = '';
            for (const value of imagePathCandidates) {
              if (typeof value === 'string' && value.trim()) {
                image_path = value.trim();
                break;
              }
            }
            return {
              image_path,
              word: typeof pair.word === 'string' ? pair.word : '',
            };
          })
        : base.imagePairs;
    return { ...base, imagePairs };
  }

  if (type === 'find_error') {
    return {
      ...base,
      sentence_with_error:
        typeof raw.sentence_with_error === 'string' ? raw.sentence_with_error : '',
      find_error_correct:
        typeof raw.correct_sentence === 'string' ? raw.correct_sentence : '',
      explanation: typeof raw.explanation === 'string' ? raw.explanation : '',
    };
  }

  if (type === 'audio_record') {
    const instructions =
      typeof raw.instructions === 'string'
        ? raw.instructions
        : typeof raw.prompt === 'string'
          ? raw.prompt
          : '';
    return { ...base, instructions };
  }

  return base;
}

export function buildExerciseContent(
  type: ExerciseType,
  form: ExerciseFormState
): Record<string, unknown> {
  switch (type) {
    case 'qcm':
      return {
        question: form.question.trim(),
        options: form.options.map((o) => ({
          text: o.text.trim(),
          correct: o.correct,
        })),
        explanation: form.explanation.trim(),
      };
    case 'matching':
      return {
        pairs: form.pairs.map((p) => ({
          left: p.left.trim(),
          right: p.right.trim(),
        })),
      };
    case 'fill_blank':
      return {
        prompt: form.prompt.trim(),
        answer: form.answer.trim(),
      };
    case 'short_answer':
      return {
        prompt: form.prompt.trim(),
      };
    case 'word_order':
      return {
        words: splitWords(form.correct_sentence),
      };
    case 'anagram':
      return {
        word: form.word.trim(),
        hint: form.hint.trim(),
      };
    case 'true_false':
      return {
        statement: form.statement.trim(),
        correct: form.trueFalseCorrect,
        explanation: form.explanation.trim(),
      };
    case 'image_match':
      return {
        pairs: form.imagePairs.map((p) => ({
          image_path: p.image_path.trim(),
          word: p.word.trim(),
        })),
      };
    case 'find_error':
      return {
        sentence_with_error: form.sentence_with_error.trim(),
        correct_sentence: form.find_error_correct.trim(),
        explanation: form.explanation.trim(),
      };
    case 'audio_record':
      return {
        instructions: form.instructions.trim(),
      };
    default:
      return {};
  }
}

export function validateExerciseForm(
  type: ExerciseType,
  form: ExerciseFormState
): string | null {
  if (type === 'qcm') {
    if (!form.question.trim()) return 'La question est obligatoire';
    if (form.options.some((o) => !o.text.trim())) return 'Remplissez les 4 réponses';
    if (!form.options.some((o) => o.correct)) return 'Cochez la bonne réponse';
    return null;
  }
  if (type === 'matching') {
    if (form.pairs.length < 1) return 'Ajoutez au moins une paire';
    if (form.pairs.some((p) => !p.left.trim() || !p.right.trim())) {
      return 'Remplissez toutes les paires';
    }
    return null;
  }
  if (type === 'fill_blank') {
    if (!form.prompt.trim()) return 'La phrase est obligatoire';
    if (!form.answer.trim()) return 'La réponse attendue est obligatoire';
    return null;
  }
  if (type === 'short_answer') {
    if (!form.prompt.trim()) return 'La consigne est obligatoire';
    return null;
  }
  if (type === 'word_order') {
    if (splitWords(form.correct_sentence).length < 2) {
      return 'Saisissez une phrase d’au moins deux mots';
    }
    return null;
  }
  if (type === 'anagram') {
    if (splitLetters(form.word).length < 2) {
      return 'Saisissez un mot d’au moins deux lettres';
    }
    return null;
  }
  if (type === 'true_false') {
    if (!form.statement.trim()) return 'L’affirmation est obligatoire';
    return null;
  }
  if (type === 'image_match') {
    if (form.imagePairs.length < 1) return 'Ajoutez au moins une paire';
    if (form.imagePairs.some((p) => !p.image_path.trim() || !p.word.trim())) {
      return 'Chaque paire doit avoir une image et un mot';
    }
    return null;
  }
  if (type === 'find_error') {
    if (!form.sentence_with_error.trim()) return 'La phrase avec erreur est obligatoire';
    if (!form.find_error_correct.trim()) return 'La phrase correcte est obligatoire';
    return null;
  }
  if (type === 'audio_record') {
    if (!form.instructions.trim()) return 'La consigne est obligatoire';
    return null;
  }
  return null;
}
