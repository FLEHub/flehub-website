import { Download, FileText } from 'lucide-react';
import { Badge } from '@/components/ui/badge';
import { Button } from '@/components/ui/button';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { getSchoolSpaceData } from '@/lib/school/data';
import { COMPETENCIES } from '@/lib/school/constants';

export const dynamic = 'force-dynamic';

export default async function SchoolExamsPage() {
  const data = await getSchoolSpaceData();
  const enrolledSessionIds = new Set(data.enrollments.map((enrollment: any) => enrollment.exam_session_id));

  return (
    <div className="mx-auto max-w-7xl space-y-6 p-4 sm:p-6">
      <div>
        <p className="text-sm font-semibold text-[#00A550]">Examens</p>
        <h1 className="text-2xl font-bold text-gray-900">Sujets officiels</h1>
        <p className="mt-1 text-sm text-gray-600">
          Les téléchargements privés sont autorisés uniquement pour les sessions où votre école a des élèves inscrits.
        </p>
      </div>

      <div className="grid gap-4">
        {data.sessions.map((session: any) => {
          const isEligible = enrolledSessionIds.has(session.id);
          const papers = data.papers.filter((paper: any) => paper.exam_session_id === session.id);
          return (
            <Card key={session.id}>
              <CardHeader>
                <div className="flex flex-col gap-2 sm:flex-row sm:items-center sm:justify-between">
                  <CardTitle className="flex items-center gap-2 text-base">
                    <FileText className="h-5 w-5 text-[#00A550]" />
                    {session.title}
                  </CardTitle>
                  <div className="flex gap-2">
                    <Badge variant="secondary">{session.cefr_level}</Badge>
                    <Badge className={isEligible ? 'bg-[#E8F8F0] text-[#00A550]' : 'bg-gray-100 text-gray-500'}>
                      {isEligible ? 'Téléchargement autorisé' : 'Aucun élève inscrit'}
                    </Badge>
                  </div>
                </div>
              </CardHeader>
              <CardContent>
                <p className="mb-4 text-sm text-gray-600">
                  Date : {new Date(session.exam_date).toLocaleDateString('fr-FR')} · Statut : {session.status}
                </p>
                <div className="grid gap-3 sm:grid-cols-2 lg:grid-cols-5">
                  {COMPETENCIES.map((competency) => {
                    const hasPaper = papers.some((paper: any) => paper.competency === competency.key);
                    return (
                      <Button
                        key={competency.key}
                        asChild
                        variant={hasPaper && isEligible ? 'default' : 'outline'}
                        className={hasPaper && isEligible ? 'bg-[#00A550] text-white hover:bg-[#007A3D]' : ''}
                        disabled={!hasPaper || !isEligible}
                      >
                        <a href={hasPaper && isEligible ? `/api/school/exams/${session.id}/papers/${competency.key}` : '#'} aria-disabled={!hasPaper || !isEligible}>
                          <Download className="mr-2 h-4 w-4" />
                          {competency.key === 'LANGUE' ? 'Langue' : competency.key}
                        </a>
                      </Button>
                    );
                  })}
                </div>
              </CardContent>
            </Card>
          );
        })}
        {data.sessions.length === 0 && (
          <Card>
            <CardContent className="py-10 text-center text-gray-500">
              Aucune session examen disponible.
            </CardContent>
          </Card>
        )}
      </div>
    </div>
  );
}
