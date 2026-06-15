import { NextRequest, NextResponse } from 'next/server';
import { jsonError, requireSchool, SchoolApiError } from '@/lib/school/server';
import { normalizeCefrLevel } from '@/lib/school/constants';

const REQUIRED_COLUMNS = ['first_name', 'last_name', 'date_of_birth', 'gender', 'grade', 'cefr_level'];

function parseCsvLine(line: string) {
  const values: string[] = [];
  let current = '';
  let quoted = false;

  for (let index = 0; index < line.length; index += 1) {
    const char = line[index];
    if (char === '"') {
      quoted = !quoted;
    } else if (char === ',' && !quoted) {
      values.push(current.trim().replace(/^"|"$/g, ''));
      current = '';
    } else {
      current += char;
    }
  }
  values.push(current.trim().replace(/^"|"$/g, ''));
  return values;
}

function parseCsv(text: string) {
  const lines = text.split(/\r?\n/).map((line) => line.trim()).filter(Boolean);
  if (lines.length < 2) throw new SchoolApiError('Le fichier CSV ne contient aucun élève.', 400);

  const headers = parseCsvLine(lines[0]).map((header) => header.toLowerCase());
  const missing = REQUIRED_COLUMNS.filter((column) => !headers.includes(column));
  if (missing.length > 0) {
    throw new SchoolApiError(`Colonnes manquantes : ${missing.join(', ')}.`, 400);
  }

  return lines.slice(1).map((line, lineIndex) => {
    const values = parseCsvLine(line);
    const row = Object.fromEntries(headers.map((header, index) => [header, values[index] ?? '']));
    return { row, line: lineIndex + 2 };
  });
}

export async function POST(request: NextRequest) {
  try {
    const { supabase, school } = await requireSchool({ approved: true });
    const form = await request.formData();
    const file = form.get('file');
    if (!(file instanceof File)) {
      return NextResponse.json({ error: 'Veuillez envoyer un fichier CSV.' }, { status: 400 });
    }

    const rows = parseCsv(await file.text());
    const created: string[] = [];
    const errors: string[] = [];

    for (const item of rows) {
      const first_name = String(item.row.first_name ?? '').trim();
      const last_name = String(item.row.last_name ?? '').trim();
      const date_of_birth = String(item.row.date_of_birth ?? '').trim() || null;
      const gender = String(item.row.gender ?? '').trim().toUpperCase();
      const grade = String(item.row.grade ?? '').trim();
      const cefr_level = normalizeCefrLevel(item.row.cefr_level);

      if (!first_name || !last_name || !grade || !['M', 'F'].includes(gender) || !cefr_level) {
        errors.push(`Ligne ${item.line}: données invalides.`);
        continue;
      }

      const { data: session } = await supabase
        .from('exam_sessions')
        .select('id')
        .eq('cefr_level', cefr_level)
        .in('status', ['upcoming', 'ongoing'])
        .order('exam_date', { ascending: true })
        .limit(1)
        .maybeSingle();

      const { data: student, error: studentError } = await supabase
        .from('students')
        .insert({ school_id: school.id, first_name, last_name, date_of_birth, gender, grade })
        .select('id')
        .single();

      if (studentError || !student) {
        errors.push(`Ligne ${item.line}: ${studentError?.message ?? 'création impossible'}.`);
        continue;
      }

      created.push(student.id);

      if (session?.id) {
        const { error: enrollmentError } = await supabase.from('student_enrollments').insert({
          student_id: student.id,
          exam_session_id: session.id,
          cefr_level,
        });
        if (enrollmentError) {
          errors.push(`Ligne ${item.line}: élève créé, inscription examen impossible (${enrollmentError.message}).`);
        }
      } else {
        errors.push(`Ligne ${item.line}: élève créé, aucune session active pour ${cefr_level}.`);
      }
    }

    return NextResponse.json({ success: true, created: created.length, errors });
  } catch (error) {
    return jsonError(error);
  }
}
