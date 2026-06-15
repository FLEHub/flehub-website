import { NextRequest, NextResponse } from 'next/server';
import JSZip from 'jszip';
import { generateCertificatePdf } from '@/lib/school/certificates';
import { jsonError, requireSchool, SchoolApiError } from '@/lib/school/server';

export async function GET(request: NextRequest) {
  try {
    const { supabase, school } = await requireSchool({ approved: true });
    const origin = new URL(request.url).origin;

    const { data: results, error } = await supabase
      .from('student_results')
      .select('id')
      .eq('school_id', school.id)
      .eq('overall_pass', true)
      .eq('validated_by_admin', true);

    if (error) throw error;
    if (!results?.length) {
      throw new SchoolApiError('Aucun certificat validé disponible.', 404);
    }

    const zip = new JSZip();
    for (const result of results) {
      const certificate = await generateCertificatePdf({
        schoolId: school.id,
        resultId: result.id,
        origin,
      });
      zip.file(certificate.filename, certificate.bytes);
    }

    const content = await zip.generateAsync({ type: 'nodebuffer' });
    return new NextResponse(content, {
      headers: {
        'Content-Type': 'application/zip',
        'Content-Disposition': 'attachment; filename="certificats-flehub.zip"',
      },
    });
  } catch (error) {
    return jsonError(error);
  }
}
