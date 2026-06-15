import Link from 'next/link';
import { CheckCircle2, XCircle } from 'lucide-react';
import { getServiceClient } from '@/lib/supabase/service';

interface VerifyPageProps {
  params: { code: string };
}

export default async function VerifyCertificatePage({ params }: VerifyPageProps) {
  const supabase = getServiceClient();

  if (!supabase) {
    return (
      <main className="min-h-screen bg-[#F5F5F5] flex items-center justify-center p-6">
        <section className="max-w-lg w-full rounded-2xl bg-white shadow-sm border p-8 text-center">
          <XCircle className="w-12 h-12 text-amber-500 mx-auto mb-4" />
          <h1 className="text-2xl font-bold text-gray-900">Vérification indisponible</h1>
          <p className="text-sm text-gray-500 mt-2">
            La clé serveur Supabase n&apos;est pas configurée pour la vérification publique.
          </p>
        </section>
      </main>
    );
  }

  const { data: certificate } = await supabase
    .from('certificates')
    .select(
      `
      id,
      certificate_uuid,
      certificate_number,
      level,
      cefr_level,
      issue_date,
      students (first_name, last_name),
      schools (name, school_name, district)
    `
    )
    .or(`certificate_uuid.eq.${params.code},verification_code.eq.${params.code}`)
    .maybeSingle();

  return (
    <main className="min-h-screen bg-[#F5F5F5] flex items-center justify-center p-6">
      <section className="max-w-xl w-full rounded-2xl bg-white shadow-sm border p-8 text-center">
        {certificate ? (
          <>
            <CheckCircle2 className="w-14 h-14 text-[#00A550] mx-auto mb-4" />
            <h1 className="text-2xl font-bold text-gray-900">Certificat FLEHub valide</h1>
            <p className="text-sm text-gray-500 mt-2">
              Ce certificat a été émis par FLEHub et peut être vérifié officiellement.
            </p>
            <div className="mt-6 text-left rounded-xl bg-[#F5F5F5] p-4 space-y-2 text-sm">
              <p>
                <span className="font-semibold">Élève :</span>{' '}
                {(certificate as any).students?.first_name} {(certificate as any).students?.last_name}
              </p>
              <p>
                <span className="font-semibold">École :</span>{' '}
                {(certificate as any).schools?.name ?? (certificate as any).schools?.school_name}
              </p>
              <p>
                <span className="font-semibold">Niveau :</span>{' '}
                {certificate.level ?? certificate.cefr_level}
              </p>
              <p>
                <span className="font-semibold">Date :</span>{' '}
                {certificate.issue_date
                  ? new Date(certificate.issue_date).toLocaleDateString('fr-RW')
                  : '—'}
              </p>
              <p>
                <span className="font-semibold">Numéro :</span>{' '}
                {certificate.certificate_number ?? certificate.id}
              </p>
            </div>
          </>
        ) : (
          <>
            <XCircle className="w-14 h-14 text-red-500 mx-auto mb-4" />
            <h1 className="text-2xl font-bold text-gray-900">Certificat introuvable</h1>
            <p className="text-sm text-gray-500 mt-2">
              Aucun certificat valide ne correspond à ce code de vérification.
            </p>
          </>
        )}
        <Link href="/" className="inline-flex mt-6 text-sm font-semibold text-[#00A550] hover:underline">
          Retour à FLEHub
        </Link>
      </section>
    </main>
  );
}
