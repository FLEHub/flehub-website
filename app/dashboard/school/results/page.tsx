import { ResultsManager } from '@/components/school/results-manager';
import { getSchoolSpaceData } from '@/lib/school/data';

export const dynamic = 'force-dynamic';

export default async function SchoolResultsPage() {
  const data = await getSchoolSpaceData();

  return (
    <div className="mx-auto max-w-7xl space-y-6 p-4 sm:p-6">
      <div>
        <p className="text-sm font-semibold text-[#00A550]">Résultats</p>
        <h1 className="text-2xl font-bold text-gray-900">Saisie et rapports</h1>
        <p className="mt-1 text-sm text-gray-600">
          Saisissez les cinq compétences, sauvegardez en brouillon, puis soumettez à validation admin.
        </p>
      </div>
      <ResultsManager
        students={data.students}
        sessions={data.sessions}
        enrollments={data.enrollments}
        results={data.results}
        averages={data.metrics.competencyAverages}
      />
    </div>
  );
}
