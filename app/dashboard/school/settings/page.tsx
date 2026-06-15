import { SettingsForm } from '@/components/school/settings-form';
import { getSchoolSpaceData } from '@/lib/school/data';

export const dynamic = 'force-dynamic';

export default async function SchoolSettingsPage() {
  const data = await getSchoolSpaceData();

  return (
    <div className="mx-auto max-w-7xl space-y-6 p-4 sm:p-6">
      <div>
        <p className="text-sm font-semibold text-[#00A550]">Paramètres</p>
        <h1 className="text-2xl font-bold text-gray-900">Profil et compte école</h1>
        <p className="mt-1 text-sm text-gray-600">
          Mettez à jour les informations officielles, le logo, la signature du directeur et le mot de passe.
        </p>
      </div>
      <SettingsForm school={data.school} />
    </div>
  );
}
