import { NextRequest, NextResponse } from 'next/server';
import { jsonError, requireSchool } from '@/lib/school/server';
import { sanitizeFileName } from '@/lib/school/constants';

const ACCEPTED: Record<string, string[]> = {
  logo: ['image/png', 'image/jpeg'],
  signature: ['image/png'],
};

function extensionFor(file: File) {
  if (file.type === 'image/jpeg') return 'jpg';
  return 'png';
}

export async function POST(request: NextRequest) {
  try {
    const { supabase, school } = await requireSchool({ approved: true });
    const form = await request.formData();
    const kind = String(form.get('kind') ?? '');
    const file = form.get('file');

    if (kind !== 'logo' && kind !== 'signature') {
      return NextResponse.json({ error: "Type d'image invalide." }, { status: 400 });
    }
    if (!(file instanceof File)) {
      return NextResponse.json({ error: 'Aucun fichier reçu.' }, { status: 400 });
    }
    if (!ACCEPTED[kind].includes(file.type)) {
      return NextResponse.json(
        {
          error:
            kind === 'signature'
              ? 'La signature doit être un PNG.'
              : 'Le logo doit être un PNG ou JPG.',
        },
        { status: 400 }
      );
    }

    const previousPath = kind === 'logo' ? school.logo_url : school.signature_url;
    const filename = `${kind}-${Date.now()}-${sanitizeFileName(file.name || kind)}.${extensionFor(file)}`;
    const path = `${school.id}/${filename}`;

    const { error: uploadError } = await supabase.storage.from('school-assets').upload(path, file, {
      contentType: file.type,
      upsert: true,
    });
    if (uploadError) throw uploadError;

    const { error: updateError } = await supabase
      .from('schools')
      .update({
        [kind === 'logo' ? 'logo_url' : 'signature_url']: path,
        updated_at: new Date().toISOString(),
      })
      .eq('id', school.id);
    if (updateError) throw updateError;

    if (previousPath && !/^https?:\/\//.test(previousPath)) {
      await supabase.storage.from('school-assets').remove([previousPath]);
    }

    const { data } = await supabase.storage.from('school-assets').createSignedUrl(path, 60 * 30);
    return NextResponse.json({ success: true, path, signedUrl: data?.signedUrl ?? null });
  } catch (error) {
    return jsonError(error);
  }
}
