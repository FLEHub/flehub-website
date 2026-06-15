import { Award, BarChart3, ClipboardList, FileText, Users } from 'lucide-react';
import Link from 'next/link';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Badge } from '@/components/ui/badge';
import { Button } from '@/components/ui/button';
import { getSchoolSpaceData } from '@/lib/school/data';
import { SCHOOL_STATUS_LABELS } from '@/lib/school/constants';

export const dynamic = 'force-dynamic';

export default async function SchoolDashboardPage() {
  const data = await getSchoolSpaceData();
  const cards = [
    { label: 'Élèves inscrits', value: data.metrics.totalStudents, icon: Users },
    { label: 'Inscriptions actives', value: data.metrics.activeEnrollments, icon: ClipboardList },
    { label: 'Résultats à finaliser', value: data.metrics.pendingResults, icon: FileText },
    { label: 'Certificats disponibles', value: data.metrics.eligibleCertificates, icon: Award },
  ];

  return (
    <div className="mx-auto max-w-7xl space-y-8 p-4 sm:p-6">
      <div className="rounded-3xl bg-white p-6 shadow-sm border border-gray-100">
        <div className="flex flex-col gap-4 sm:flex-row sm:items-start sm:justify-between">
          <div>
            <p className="text-sm font-semibold text-[#00A550]">Espace école</p>
            <h1 className="mt-1 text-2xl font-bold text-gray-900">
              {data.school.display_name}
            </h1>
            <p className="mt-2 max-w-2xl text-sm text-gray-600">
              Gérez vos élèves sans e-mail, téléchargez les sujets officiels, saisissez les
              résultats et récupérez les certificats validés.
            </p>
          </div>
          <Badge className="w-fit bg-[#E8F8F0] text-[#00A550] hover:bg-[#E8F8F0]">
            Statut : {SCHOOL_STATUS_LABELS[data.school.status ?? data.profile.status] ?? data.profile.status}
          </Badge>
        </div>
      </div>

      <div className="grid gap-4 sm:grid-cols-2 lg:grid-cols-4">
        {cards.map((card) => (
          <Card key={card.label} className="bg-[#F5F5F5] border-gray-100">
            <CardContent className="flex items-center justify-between p-5">
              <div>
                <p className="text-3xl font-bold text-gray-900">{card.value}</p>
                <p className="mt-1 text-sm text-gray-600">{card.label}</p>
              </div>
              <div className="rounded-2xl bg-white p-3 text-[#00A550]">
                <card.icon className="h-6 w-6" />
              </div>
            </CardContent>
          </Card>
        ))}
      </div>

      <div className="grid gap-6 lg:grid-cols-[1.2fr_0.8fr]">
        <Card>
          <CardHeader>
            <CardTitle className="flex items-center gap-2 text-base">
              <BarChart3 className="h-5 w-5 text-[#00A550]" />
              Performance par compétence
            </CardTitle>
          </CardHeader>
          <CardContent className="space-y-4">
            {data.metrics.competencyAverages.map((item) => (
              <div key={item.key}>
                <div className="mb-1 flex justify-between text-sm">
                  <span className="font-medium text-gray-700">{item.label}</span>
                  <span className="text-gray-500">{item.average}/100</span>
                </div>
                <div className="h-3 rounded-full bg-gray-100">
                  <div
                    className="h-3 rounded-full bg-[#00A550]"
                    style={{ width: `${Math.min(100, item.average)}%` }}
                  />
                </div>
              </div>
            ))}
          </CardContent>
        </Card>

        <Card>
          <CardHeader>
            <CardTitle className="text-base">Actions rapides</CardTitle>
          </CardHeader>
          <CardContent className="grid gap-3">
            <Button asChild className="bg-[#00A550] text-white hover:bg-[#007A3D]">
              <Link href="/dashboard/school/students">Inscrire des élèves</Link>
            </Button>
            <Button asChild variant="outline">
              <Link href="/dashboard/school/exams">Télécharger les sujets</Link>
            </Button>
            <Button asChild variant="outline">
              <Link href="/dashboard/school/results">Saisir les résultats</Link>
            </Button>
            <Button asChild variant="outline">
              <Link href="/dashboard/school/certificates">Télécharger les certificats</Link>
            </Button>
          </CardContent>
        </Card>
      </div>
    </div>
  );
}
