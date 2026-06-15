import { StudentsManager } from '@/components/school/students-manager';
import { getSchoolSpaceData } from '@/lib/school/data';

export const dynamic = 'force-dynamic';

export default async function SchoolStudentsPage() {
  const data = await getSchoolSpaceData();
  const activeSessions = data.sessions.filter((session: any) =>
    ['upcoming', 'ongoing'].includes(session.status)
  );

  return (
    <div className="mx-auto max-w-7xl space-y-6 p-4 sm:p-6">
      <div>
        <p className="text-sm font-semibold text-[#00A550]">Mes Élèves</p>
        <h1 className="text-2xl font-bold text-gray-900">Inscription des élèves</h1>
        <p className="mt-1 text-sm text-gray-600">
          Les élèves sont inscrits par prénom et nom uniquement. Aucun e-mail élève n'est utilisé.
        </p>
      </div>
      <StudentsManager students={data.students} sessions={activeSessions} />
    </div>
  );
}
