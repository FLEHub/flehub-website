import { CertificatesPanel } from '@/components/school/certificates-panel';
import { getSchoolSpaceData } from '@/lib/school/data';

export const dynamic = 'force-dynamic';

export default async function SchoolCertificatesPage() {
  const data = await getSchoolSpaceData();
  const eligibleResults = data.results.filter(
    (result: any) => result.validated_by_admin && result.overall_pass
  );

  return (
    <div className="mx-auto max-w-7xl space-y-6 p-4 sm:p-6">
      <div>
        <p className="text-sm font-semibold text-[#00A550]">Certificats</p>
        <h1 className="text-2xl font-bold text-gray-900">Téléchargement des certificats</h1>
        <p className="mt-1 text-sm text-gray-600">
          Les certificats sont disponibles après validation administrative des résultats réussis.
        </p>
      </div>
      <CertificatesPanel certificates={data.certificates} eligibleResults={eligibleResults} />
    </div>
  );
}
