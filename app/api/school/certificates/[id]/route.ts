import { NextRequest, NextResponse } from 'next/server';
import { generateCertificatePdf } from '@/lib/school/certificates';
import { jsonError, requireSchool } from '@/lib/school/server';

export async function GET(
  request: NextRequest,
  { params }: { params: { id: string } }
) {
  try {
    const { school } = await requireSchool({ approved: true });
    const origin = new URL(request.url).origin;
    const result = await generateCertificatePdf({
      schoolId: school.id,
      resultId: request.nextUrl.searchParams.get('result') === '1' ? params.id : undefined,
      certificateId: request.nextUrl.searchParams.get('result') === '1' ? undefined : params.id,
      origin,
    });

    return new NextResponse(result.bytes, {
      headers: {
        'Content-Type': 'application/pdf',
        'Content-Disposition': `attachment; filename="${result.filename}"`,
      },
    });
  } catch (error) {
    return jsonError(error);
  }
}
