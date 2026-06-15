import { notFound } from 'next/navigation';
import { CheckCircle, GraduationCap } from 'lucide-react';
import { getServiceClient } from '@/lib/supabase/service';

export const dynamic = 'force-dynamic';

export default async function CertificateVerificationPage({
  params,
}: {
  params: { uuid: string };
}) {
  const service = getServiceClient();
  if (!service) notFound();

  const { data: certificate } = await service
    .from('certificates')
    .select(
      'certificate_uuid, level, issue_date, pdf_url, students(first_name, last_name, grade), schools(name, school_name, director_name)'
    )
    .eq('certificate_uuid', params.uuid)
    .maybeSingle();

  if (!certificate) notFound();

  const student: any = certificate.students;
  const school: any = certificate.schools;

  return (
    <main className="min-h-screen bg-[#F5F5F5] px-4 py-10">
      <section className="mx-auto max-w-2xl rounded-3xl bg-white p-8 shadow-sm border border-gray-100">
        <div className="flex items-center gap-3 mb-8">
          <div className="flex h-12 w-12 items-center justify-center rounded-2xl bg-[#00A550]">
            <GraduationCap className="h-7 w-7 text-white" />
          </div>
          <div>
            <p className="text-sm font-semibold text-[#00A550]">FLEHub Rwanda</p>
            <h1 className="text-2xl font-bold text-gray-900">Vérification du certificat</h1>
          </div>
        </div>

        <div className="rounded-2xl border border-green-100 bg-green-50 p-5 flex gap-4">
          <CheckCircle className="h-8 w-8 text-[#00A550] flex-shrink-0" />
          <div>
            <h2 className="font-bold text-gray-900">Certificat authentique</h2>
            <p className="text-sm text-gray-600 mt-1">
              Ce certificat est enregistré dans FLEHub et peut être vérifié en ligne.
            </p>
          </div>
        </div>

        <dl className="mt-8 grid gap-4 sm:grid-cols-2">
          <div className="rounded-2xl bg-[#F5F5F5] p-4">
            <dt className="text-xs uppercase tracking-wide text-gray-500">Élève</dt>
            <dd className="mt-1 font-semibold text-gray-900">
              {student?.first_name} {student?.last_name}
            </dd>
          </div>
          <div className="rounded-2xl bg-[#F5F5F5] p-4">
            <dt className="text-xs uppercase tracking-wide text-gray-500">Niveau</dt>
            <dd className="mt-1 font-semibold text-gray-900">Niveau {certificate.level}</dd>
          </div>
          <div className="rounded-2xl bg-[#F5F5F5] p-4">
            <dt className="text-xs uppercase tracking-wide text-gray-500">Établissement</dt>
            <dd className="mt-1 font-semibold text-gray-900">{school?.name ?? school?.school_name}</dd>
          </div>
          <div className="rounded-2xl bg-[#F5F5F5] p-4">
            <dt className="text-xs uppercase tracking-wide text-gray-500">Date d&apos;émission</dt>
            <dd className="mt-1 font-semibold text-gray-900">
              {new Date(certificate.issue_date).toLocaleDateString('fr-FR')}
            </dd>
          </div>
        </dl>
      </section>
    </main>
  );
}
