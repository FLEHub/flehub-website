import Link from 'next/link';
import { Bell } from 'lucide-react';
import { Card, CardContent } from '@/components/ui/card';

export default function SchoolNotificationsPage() {
  return (
    <div className="p-4 md:p-6 max-w-4xl mx-auto">
      <Card>
        <CardContent className="p-8 text-center">
          <Bell className="w-10 h-10 text-[#00A550] mx-auto mb-3" />
          <h1 className="text-xl font-semibold text-gray-900">Notifications</h1>
          <p className="text-sm text-gray-500 mt-2">
            Les nouvelles notifications apparaissent dans la cloche en haut de l&apos;écran.
          </p>
          <Link href="/dashboard/school" className="inline-flex mt-4 text-sm font-semibold text-[#00A550] hover:underline">
            Retour à l&apos;accueil école
          </Link>
        </CardContent>
      </Card>
    </div>
  );
}
