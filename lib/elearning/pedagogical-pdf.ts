import { jsPDF } from 'jspdf';
import type { PedagogicalSheet, SequenceSheet } from '@/lib/elearning/pedagogical-sheet';

const NAVY: [number, number, number] = [11, 31, 58];
const GREEN: [number, number, number] = [30, 107, 102];
const GRAY: [number, number, number] = [70, 70, 70];
const RULE: [number, number, number] = [200, 200, 200];
const HEADER_BG: [number, number, number] = [240, 244, 242];

function pdfSafe(text: string): string {
  return text
    .replace(/\u202f|\u00a0/g, ' ')
    .replace(/\u2018|\u2019/g, "'")
    .replace(/\u201c|\u201d/g, '"')
    .replace(/\u2026/g, '...')
    .replace(/\u2013/g, '-')
    .replace(/[\u0000-\u0008\u000b\u000c\u000e-\u001f]/g, '');
}

class SheetDoc {
  doc: jsPDF;
  pageW: number;
  pageH: number;
  margin = 14;
  y = 18;
  footerLabel: string;

  constructor(footerLabel: string) {
    this.doc = new jsPDF({ orientation: 'portrait', unit: 'mm', format: 'a4' });
    this.pageW = this.doc.internal.pageSize.getWidth();
    this.pageH = this.doc.internal.pageSize.getHeight();
    this.footerLabel = footerLabel;
  }

  get innerW() {
    return this.pageW - this.margin * 2;
  }

  ensure(h: number) {
    if (this.y + h > this.pageH - 16) {
      this.doc.addPage();
      this.y = 16;
    }
  }

  text(str: string, opts?: { size?: number; color?: [number, number, number]; bold?: boolean; x?: number }) {
    const size = opts?.size ?? 10;
    const color = opts?.color ?? GRAY;
    this.doc.setFont('helvetica', opts?.bold ? 'bold' : 'normal');
    this.doc.setFontSize(size);
    this.doc.setTextColor(...color);
    const lines = this.doc.splitTextToSize(pdfSafe(str), this.innerW) as string[];
    const lineH = size * 0.42;
    this.ensure(lines.length * lineH + 1);
    for (const line of lines) {
      this.doc.text(line, opts?.x ?? this.margin, this.y);
      this.y += lineH;
    }
    this.y += 1.2;
  }

  heading(str: string, size = 13) {
    this.y += 2;
    this.text(str, { size, bold: true, color: NAVY });
    this.doc.setDrawColor(...GREEN);
    this.doc.setLineWidth(0.4);
    this.doc.line(this.margin, this.y - 0.5, this.margin + 28, this.y - 0.5);
    this.y += 2;
  }

  labelBlock(label: string, body: string) {
    this.text(label, { size: 9, bold: true, color: GREEN });
    this.text(body || '—', { size: 10, color: GRAY });
  }

  table(headers: string[], rows: string[][], colWeights: number[]) {
    const total = colWeights.reduce((a, b) => a + b, 0);
    const widths = colWeights.map((w) => (w / total) * this.innerW);
    const pad = 1.4;
    const fontSize = 8;
    const lineH = 3.4;

    const drawRow = (cells: string[], header: boolean) => {
      this.doc.setFont('helvetica', header ? 'bold' : 'normal');
      this.doc.setFontSize(fontSize);
      const wrapped = cells.map((c, i) =>
        this.doc.splitTextToSize(pdfSafe(c || '—'), widths[i]! - pad * 2) as string[]
      );
      const maxLines = Math.max(1, ...wrapped.map((w) => w.length));
      const h = maxLines * lineH + pad * 2;
      this.ensure(h + 1);
      let x = this.margin;
      for (let i = 0; i < cells.length; i++) {
        if (header) {
          this.doc.setFillColor(...HEADER_BG);
          this.doc.rect(x, this.y, widths[i]!, h, 'F');
        }
        this.doc.setDrawColor(...RULE);
        this.doc.setLineWidth(0.2);
        this.doc.rect(x, this.y, widths[i]!, h);
        this.doc.setTextColor(...(header ? NAVY : GRAY));
        let ty = this.y + pad + 2.6;
        for (const line of wrapped[i]!) {
          this.doc.text(line, x + pad, ty);
          ty += lineH;
        }
        x += widths[i]!;
      }
      this.y += h;
    };

    drawRow(headers, true);
    for (const row of rows) drawRow(row, false);
    this.y += 3;
  }

  footers() {
    const pages = this.doc.getNumberOfPages();
    for (let i = 1; i <= pages; i++) {
      this.doc.setPage(i);
      this.doc.setFont('helvetica', 'normal');
      this.doc.setFontSize(8);
      this.doc.setTextColor(130, 130, 130);
      this.doc.text(
        pdfSafe(`${this.footerLabel}  ·  Fiche enseignant — préparation de séance`),
        this.margin,
        this.pageH - 8
      );
      this.doc.text(`${i} / ${pages}`, this.pageW - this.margin, this.pageH - 8, {
        align: 'right',
      });
    }
  }
}

function writeCover(d: SheetDoc, sheet: PedagogicalSheet) {
  d.doc.setFillColor(...NAVY);
  d.doc.rect(0, 0, d.pageW, 22, 'F');
  d.doc.setTextColor(255, 255, 255);
  d.doc.setFont('helvetica', 'bold');
  d.doc.setFontSize(11);
  d.doc.text('MFK  ·  Fiche pédagogique', d.margin, 10);
  d.doc.setFont('helvetica', 'normal');
  d.doc.setFontSize(9);
  d.doc.text('Espace enseignant  ·  préparation visioconférence', d.margin, 16);
  d.y = 30;

  d.text(sheet.moduleTitle, { size: 18, bold: true, color: NAVY });
  d.text(`Niveau CECRL : ${sheet.cefrLevel}    ·    Module ${sheet.moduleNumber}`, {
    size: 11,
    bold: true,
    color: GREEN,
  });
  if (sheet.description) {
    d.heading('Présentation');
    d.text(sheet.description, { size: 10 });
  }

  d.heading('Séquences du module');
  d.table(
    ['#', 'Séquence', 'Objectif de communication', 'Point de grammaire', 'Champ lexical'],
    sheet.recap.map((r, i) => [
      String(i + 1),
      r.title,
      r.communicationGoal,
      r.grammarPoint,
      r.lexicalField,
    ]),
    [8, 22, 28, 22, 20]
  );
}

function writeSequence(d: SheetDoc, seq: SequenceSheet) {
  d.doc.addPage();
  d.y = 16;
  d.text(`Séquence ${seq.index}`, { size: 9, bold: true, color: GREEN });
  d.text(seq.title, { size: 15, bold: true, color: NAVY });

  d.heading('Objectif de la séquence');
  d.labelBlock('Communicatif', seq.communicationGoal);
  d.labelBlock('Linguistique', seq.linguisticGoal);

  d.heading('Matériel / support à avoir sous les yeux');
  for (const line of seq.supportSummary) {
    d.text(`• ${line}`, { size: 9.5 });
  }

  d.heading('Déroulé suggéré (indicatif, adaptable)');
  const steps: [string, { duration: string; text: string }][] = [
    ['a. Mise en route / activation', seq.rundown.warmup],
    ['b. Compréhension (CO / CE)', seq.rundown.comprehension],
    ['c. Focus langue (EL)', seq.rundown.language],
    ['d. Production (PO / PE)', seq.rundown.production],
  ];
  for (const [label, step] of steps) {
    d.text(`${label}  ·  ${step.duration}`, { size: 10, bold: true, color: NAVY });
    d.text(step.text, { size: 9.5 });
  }

  d.heading('Exercices à donner en autonomie après la visio');
  const rows: string[][] = [];
  for (const lesson of seq.lessonExercises) {
    const lessonLabel = lesson.lessonTitle.replace(/^(CO|CE|PO|PE|EL)\s*[—–-]\s*/i, '');
    if (lesson.items.length === 0) {
      rows.push([lesson.competency, '—', lessonLabel, 'Aucun exercice']);
      continue;
    }
    lesson.items.forEach((it, i) => {
      rows.push([
        i === 0 ? lesson.competency : '',
        String(i + 1),
        it.title,
        it.typeLabel,
      ]);
    });
  }
  if (rows.length === 0) {
    d.text('Aucun exercice dans cette séquence.', { size: 9 });
  } else {
    d.table(['Comp.', '#', 'Titre', 'Type'], rows, [12, 8, 50, 30]);
  }
}

function renderSheet(sheet: PedagogicalSheet): jsPDF {
  const d = new SheetDoc(`${sheet.moduleTitle}  ·  ${sheet.cefrLevel}`);
  writeCover(d, sheet);
  for (const seq of sheet.sequences) writeSequence(d, seq);
  if (sheet.sequences.length === 0) {
    d.heading('Aucune séquence');
    d.text("Ce module n'a pas encore de séquence. La fiche se limitera à la page de présentation.");
  }
  d.footers();
  return d.doc;
}

export function generatePedagogicalPdfBytes(sheet: PedagogicalSheet): Uint8Array {
  const buffer = renderSheet(sheet).output('arraybuffer') as ArrayBuffer;
  return new Uint8Array(buffer);
}

export function generatePedagogicalPdf(sheet: PedagogicalSheet): Blob {
  return new Blob([generatePedagogicalPdfBytes(sheet)], { type: 'application/pdf' });
}
