import { NextRequest, NextResponse } from 'next/server';
import { PDFDocument, StandardFonts, rgb } from 'pdf-lib';
import * as XLSX from 'xlsx';
import { COMPETENCIES } from '@/lib/school/constants';
import { jsonError, requireSchool } from '@/lib/school/server';

function applyFilters(query: any, searchParams: URLSearchParams) {
  const level = searchParams.get('level');
  const session = searchParams.get('session');
  if (session) query = query.eq('exam_session_id', session);
  if (level) query = query.eq('exam_sessions.cefr_level', level);
  return query;
}

function rowsFrom(results: any[], grade?: string | null) {
  return results
    .filter((result) => !grade || result.students?.grade === grade)
    .map((result) => ({
      Élève: `${result.students?.first_name ?? ''} ${result.students?.last_name ?? ''}`.trim(),
      Classe: result.students?.grade ?? '',
      Session: result.exam_sessions?.title ?? '',
      Niveau: result.exam_sessions?.cefr_level ?? '',
      EO: result.score_eo ?? '',
      EE: result.score_ee ?? '',
      CO: result.score_co ?? '',
      CE: result.score_ce ?? '',
      Langue: result.score_langue ?? '',
      Statut: result.overall_pass ? 'Réussite' : 'Échec',
      Validation: result.validated_by_admin ? 'Validé' : result.status,
    }));
}

export async function GET(request: NextRequest) {
  try {
    const { supabase, school } = await requireSchool({ approved: true });
    const { searchParams } = new URL(request.url);
    const format = searchParams.get('format') === 'pdf' ? 'pdf' : 'xlsx';
    const grade = searchParams.get('grade');

    let query = supabase
      .from('student_results')
      .select(
        '*, students(first_name, last_name, grade), exam_sessions(title, cefr_level, exam_date)'
      )
      .eq('school_id', school.id)
      .order('created_at', { ascending: false });

    query = applyFilters(query, searchParams);
    const { data, error } = await query;
    if (error) throw error;

    const rows = rowsFrom(data ?? [], grade);

    if (format === 'xlsx') {
      const sheet = XLSX.utils.json_to_sheet(rows);
      const workbook = XLSX.utils.book_new();
      XLSX.utils.book_append_sheet(workbook, sheet, 'Résultats');
      const buffer = XLSX.write(workbook, { type: 'buffer', bookType: 'xlsx' });
      return new NextResponse(buffer, {
        headers: {
          'Content-Type': 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
          'Content-Disposition': 'attachment; filename="resultats-flehub.xlsx"',
        },
      });
    }

    const pdf = await PDFDocument.create();
    let page = pdf.addPage([842, 595]);
    const font = await pdf.embedFont(StandardFonts.Helvetica);
    const bold = await pdf.embedFont(StandardFonts.HelveticaBold);
    const green = rgb(0, 0.647, 0.314);
    let y = 540;

    page.drawText(`Rapport des résultats - ${school.name ?? school.school_name}`, {
      x: 40,
      y,
      size: 18,
      font: bold,
      color: green,
    });
    y -= 34;

    const headers = ['Élève', 'Classe', 'Niveau', ...COMPETENCIES.map((c) => c.key), 'Statut'];
    page.drawText(headers.join(' | '), { x: 40, y, size: 9, font: bold, color: rgb(0.1, 0.1, 0.1) });
    y -= 18;

    rows.forEach((row) => {
      if (y < 40) {
        page = pdf.addPage([842, 595]);
        y = 540;
      }
      const line = [
        row.Élève,
        row.Classe,
        row.Niveau,
        row.EO,
        row.EE,
        row.CO,
        row.CE,
        row.Langue,
        row.Statut,
      ].join(' | ');
      page.drawText(line.slice(0, 150), { x: 40, y, size: 8, font, color: rgb(0.2, 0.2, 0.2) });
      y -= 14;
    });

    const bytes = await pdf.save();
    return new NextResponse(bytes, {
      headers: {
        'Content-Type': 'application/pdf',
        'Content-Disposition': 'attachment; filename="rapport-resultats-flehub.pdf"',
      },
    });
  } catch (error) {
    return jsonError(error);
  }
}
