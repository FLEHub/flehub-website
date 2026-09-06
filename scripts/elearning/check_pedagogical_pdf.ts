/**
 * Vérifie la fiche PDF sur deux modules extraits des seeds (A1 et C1).
 * Usage : npx tsx scripts/elearning/check_pedagogical_pdf.ts
 */
import { mkdirSync, readFileSync, writeFileSync } from 'node:fs';
import { dirname, join, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';
import { generatePedagogicalPdfBytes } from '../../lib/elearning/pedagogical-pdf';
import {
  buildPedagogicalSheet,
  pedagogicalFilename,
  type SheetModuleInput,
} from '../../lib/elearning/pedagogical-sheet';

const root = resolve(dirname(fileURLToPath(import.meta.url)), '../..');

function unescapeSql(s: string): string {
  return s.replace(/''/g, "'");
}

function parseSeed(path: string): SheetModuleInput {
  const text = readFileSync(path, 'utf8');
  const titleM = text.match(/v_module_title text := '((?:[^']|'')+)'/);
  if (!titleM) throw new Error(`no title in ${path}`);
  const title = unescapeSql(titleM[1]!);
  const descM = text.match(
    /INSERT INTO elearning_modules[\s\S]{0,500}?VALUES\s*\(\s*v_teacher_id,\s*v_module_title,\s*'((?:[^']|'')+)'/
  );
  const description = descM ? unescapeSql(descM[1]!) : '';
  const level = title.match(/^(A1|A2|B1|B2|C1|C2)/)?.[1] ?? null;

  const seqPositions: { pos: number; title: string }[] = [];
  const seqRe = /AND s\.title = '((?:[^']|'')+)'/g;
  let sm: RegExpExecArray | null;
  while ((sm = seqRe.exec(text))) {
    seqPositions.push({ pos: sm.index, title: unescapeSql(sm[1]!) });
  }

  const seqAt = (pos: number) => {
    let cur = seqPositions[0]?.title ?? 'Séquence';
    for (const s of seqPositions) {
      if (s.pos <= pos) cur = s.title;
      else break;
    }
    return cur;
  };

  const lessonRe =
    /v_lesson_id := pg_temp\.mfk_upsert_lesson\(\s*v_seq_id,\s*'((?:[^']|'')+)',\s*'([A-Z]+)',\s*\$c\$(.*?)\$c\$/gs;
  const lessons: {
    pos: number;
    seq: string;
    title: string;
    competency: string;
    content: string;
  }[] = [];
  let lm: RegExpExecArray | null;
  while ((lm = lessonRe.exec(text))) {
    lessons.push({
      pos: lm.index,
      seq: seqAt(lm.index),
      title: unescapeSql(lm[1]!),
      competency: lm[2]!,
      content: lm[3]!,
    });
  }

  const exRe =
    /PERFORM pg_temp\.mfk_seed_exercise\(\s*v_lesson_id,\s*'((?:[^']|'')+)',\s*'([a-z_]+)',\s*\$j\$(.*?)\$j\$::jsonb,\s*(\d+)/gs;
  const exercises: { pos: number; title: string; type: string; order: number }[] = [];
  let em: RegExpExecArray | null;
  while ((em = exRe.exec(text))) {
    exercises.push({
      pos: em.index,
      title: unescapeSql(em[1]!),
      type: em[2]!,
      order: Number(em[4]),
    });
  }

  const seqTitles = Array.from(new Set(seqPositions.map((s) => s.title)));
  const sequences = seqTitles.map((seqTitle, i) => {
    const seqLessons = lessons.filter((l) => l.seq === seqTitle);
    return {
      id: `seq-${i}`,
      title: seqTitle,
      order_index: i,
      lessons: seqLessons.map((les, li) => {
        const nextPos = seqLessons[li + 1]?.pos ?? Number.POSITIVE_INFINITY;
        const items = exercises
          .filter((ex) => ex.pos > les.pos && ex.pos < nextPos)
          .map((ex) => ({
            title: ex.title,
            exercise_type: ex.type,
            order_index: ex.order,
          }));
        return {
          id: `les-${i}-${li}`,
          title: les.title,
          competency: les.competency,
          content: les.content,
          order_index: li,
          exercises: items,
        };
      }),
    };
  });

  return {
    id: 'seed',
    title,
    description,
    cefr_level: level,
    sequences,
  };
}

function assert(cond: unknown, msg: string): asserts cond {
  if (!cond) throw new Error(msg);
}

function checkModule(rel: string, expectLevel: string, expectMinSeq: number) {
  const input = parseSeed(join(root, rel));
  const sheet = buildPedagogicalSheet(input);
  assert(sheet.cefrLevel === expectLevel, `${sheet.moduleTitle}: level ${sheet.cefrLevel}`);
  assert(sheet.sequences.length >= expectMinSeq, `${sheet.moduleTitle}: ${sheet.sequences.length} seq`);
  assert(sheet.recap.length === sheet.sequences.length, 'recap mismatch');
  assert(sheet.filename.startsWith(`fiche-pedagogique_MFK_${expectLevel}_module`), sheet.filename);
  assert(sheet.filename.endsWith('.pdf'), sheet.filename);
  assert(pedagogicalFilename(sheet) === sheet.filename, 'filename helper');

  for (const seq of sheet.sequences) {
    assert(seq.communicationGoal.length > 2, `${seq.title}: empty comm goal`);
    assert(seq.linguisticGoal.length > 1, `${seq.title}: empty grammar`);
    assert(seq.supportSummary.length > 0, `${seq.title}: no support`);
    assert(seq.rundown.warmup.text.length > 2, `${seq.title}: warmup`);
    assert(seq.rundown.comprehension.text.length > 2, `${seq.title}: comprehension`);
    assert(seq.rundown.production.text.length > 2, `${seq.title}: production`);
    const exCount = seq.lessonExercises.reduce((n, l) => n + l.items.length, 0);
    assert(exCount >= 10, `${seq.title}: only ${exCount} exercises`);
  }

  const bytes = generatePedagogicalPdfBytes(sheet);
  const head = Buffer.from(bytes.slice(0, 5)).toString('ascii');
  assert(head === '%PDF-', `${sheet.moduleTitle}: not a PDF (${head})`);
  assert(bytes.length > 4000, `${sheet.moduleTitle}: PDF too small (${bytes.length})`);

  const outDir = join(root, 'tmp/fiches-pedagogiques');
  mkdirSync(outDir, { recursive: true });
  const outPath = join(outDir, sheet.filename);
  writeFileSync(outPath, bytes);
  console.log(
    `OK  ${sheet.moduleTitle}  seq=${sheet.sequences.length}  ` +
      `pages≈${sheet.sequences.length + 1}  ${bytes.length} o  → ${outPath}`
  );
  console.log(`    grammar[0]=${sheet.recap[0]?.grammarPoint.slice(0, 80)}`);
  console.log(`    comm[0]=${sheet.recap[0]?.communicationGoal.slice(0, 80)}`);
  return { sheet, outPath, bytes };
}

const a1 = checkModule(
  'supabase/migrations/20260814120000_elearning_mfk_a1_module1_premiers_reperes.sql',
  'A1',
  4
);
const c1 = checkModule(
  'supabase/migrations/20260904120000_elearning_mfk_c1_module1_colline_demain.sql',
  'C1',
  6
);

assert(!a1.sheet.filename.includes(' '), 'spaces in A1 filename');
assert(c1.sheet.filename.includes('colline'), c1.sheet.filename);
console.log('\nDeux modules (A1 et C1) : fiches PDF valides.');
