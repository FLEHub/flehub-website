import type { SupabaseClient } from '@supabase/supabase-js';
import { generatePedagogicalPdf } from '@/lib/elearning/pedagogical-pdf';
import {
  buildPedagogicalSheet,
  type SheetLesson,
  type SheetModuleInput,
  type SheetSequenceInput,
} from '@/lib/elearning/pedagogical-sheet';

function triggerDownload(blob: Blob, filename: string) {
  const url = URL.createObjectURL(blob);
  const a = document.createElement('a');
  a.href = url;
  a.download = filename;
  a.rel = 'noopener';
  document.body.appendChild(a);
  a.click();
  a.remove();
  URL.revokeObjectURL(url);
}

export async function fetchPedagogicalModuleInput(
  supabase: SupabaseClient,
  moduleId: string,
  options?: { moduleNumber?: number }
): Promise<SheetModuleInput> {
  const { data: mod, error: modErr } = await supabase
    .from('elearning_modules')
    .select('id, title, description, cefr_level, published, created_at')
    .eq('id', moduleId)
    .maybeSingle();

  if (modErr) throw modErr;
  if (!mod) throw new Error('Module introuvable.');

  let moduleNumber = options?.moduleNumber;
  if (moduleNumber == null && mod.cefr_level) {
    const { data: siblings } = await supabase
      .from('elearning_modules')
      .select('id, created_at')
      .eq('cefr_level', mod.cefr_level)
      .order('created_at', { ascending: true });
    const idx = (siblings ?? []).findIndex((s) => s.id === mod.id);
    if (idx >= 0) moduleNumber = idx + 1;
  }

  const { data: seqRows, error: seqErr } = await supabase
    .from('elearning_sequences')
    .select('id, title, order_index')
    .eq('module_id', moduleId)
    .order('order_index', { ascending: true });
  if (seqErr) throw seqErr;

  const sequences: SheetSequenceInput[] = ((seqRows ?? []) as {
    id: string;
    title: string;
    order_index: number;
  }[]).map((s) => ({ ...s, lessons: [] }));

  if (sequences.length === 0) {
    return {
      id: mod.id,
      title: mod.title,
      description: mod.description,
      cefr_level: mod.cefr_level,
      published: mod.published,
      sequences,
      moduleNumber,
    };
  }

  const seqIds = sequences.map((s) => s.id);
  const { data: lessonRows, error: lesErr } = await supabase
    .from('elearning_lessons')
    .select('id, sequence_id, title, competency, content, order_index')
    .in('sequence_id', seqIds)
    .order('order_index', { ascending: true });
  if (lesErr) throw lesErr;

  const lessonsBySeq = new Map<string, SheetLesson[]>();
  for (const raw of lessonRows ?? []) {
    const row = raw as {
      id: string;
      sequence_id: string;
      title: string;
      competency: string | null;
      content: string | null;
      order_index: number;
    };
    const list = lessonsBySeq.get(row.sequence_id) ?? [];
    list.push({
      id: row.id,
      title: row.title,
      competency: row.competency,
      content: row.content,
      order_index: row.order_index,
      exercises: [],
    });
    lessonsBySeq.set(row.sequence_id, list);
  }

  const allLessons = Array.from(lessonsBySeq.values()).flat();
  if (allLessons.length > 0) {
    const { data: exRows, error: exErr } = await supabase
      .from('elearning_exercises')
      .select('id, lesson_id, title, exercise_type, order_index')
      .in(
        'lesson_id',
        allLessons.map((l) => l.id)
      )
      .order('order_index', { ascending: true });
    if (exErr) throw exErr;

    const byLesson = new Map<string, SheetLesson['exercises']>();
    for (const raw of exRows ?? []) {
      const row = raw as {
        lesson_id: string;
        title: string;
        exercise_type: string;
        order_index: number;
      };
      const list = byLesson.get(row.lesson_id) ?? [];
      list.push({
        title: row.title,
        exercise_type: row.exercise_type,
        order_index: row.order_index,
      });
      byLesson.set(row.lesson_id, list);
    }
    for (const lesson of allLessons) {
      lesson.exercises = byLesson.get(lesson.id) ?? [];
    }
  }

  for (const seq of sequences) {
    seq.lessons = lessonsBySeq.get(seq.id) ?? [];
  }

  return {
    id: mod.id,
    title: mod.title,
    description: mod.description,
    cefr_level: mod.cefr_level,
    published: mod.published,
    sequences,
    moduleNumber,
  };
}

export async function downloadPedagogicalPdfForModule(
  supabase: SupabaseClient,
  moduleId: string,
  options?: { moduleNumber?: number }
): Promise<string> {
  const input = await fetchPedagogicalModuleInput(supabase, moduleId, options);
  const sheet = buildPedagogicalSheet(input);
  const blob = generatePedagogicalPdf(sheet);
  triggerDownload(blob, sheet.filename);
  return sheet.filename;
}
