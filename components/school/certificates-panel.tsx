'use client';

import { Download, Package } from 'lucide-react';
import { Button } from '@/components/ui/button';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';

type Props = {
  certificates: any[];
  eligibleResults: any[];
};

export function CertificatesPanel({ certificates, eligibleResults }: Props) {
  return (
    <div className="space-y-6">
      <Card>
        <CardHeader>
          <div className="flex flex-col gap-3 sm:flex-row sm:items-center sm:justify-between">
            <CardTitle className="text-base">Certificats validés</CardTitle>
            <Button asChild className="bg-[#00A550] text-white hover:bg-[#007A3D]" disabled={eligibleResults.length === 0}>
              <a href="/api/school/certificates/zip">
                <Package className="mr-2 h-4 w-4" />
                Télécharger tout (.zip)
              </a>
            </Button>
          </div>
        </CardHeader>
        <CardContent>
          <div className="overflow-x-auto">
            <table className="w-full text-sm">
              <thead>
                <tr className="border-b text-left text-gray-500">
                  <th className="py-2 pr-4">Élève</th>
                  <th className="py-2 pr-4">Classe</th>
                  <th className="py-2 pr-4">Niveau</th>
                  <th className="py-2 pr-4">Date</th>
                  <th className="py-2">Action</th>
                </tr>
              </thead>
              <tbody>
                {eligibleResults.map((result) => {
                  const certificate = certificates.find(
                    (item) => item.student_id === result.student_id && item.level === result.exam_sessions?.cefr_level
                  );
                  return (
                    <tr key={result.id} className="border-b last:border-0">
                      <td className="py-3 pr-4 font-medium">{result.students?.first_name} {result.students?.last_name}</td>
                      <td className="py-3 pr-4">{result.students?.grade}</td>
                      <td className="py-3 pr-4">Niveau {result.exam_sessions?.cefr_level}</td>
                      <td className="py-3 pr-4">
                        {certificate?.issue_date ? new Date(certificate.issue_date).toLocaleDateString('fr-FR') : 'À générer'}
                      </td>
                      <td className="py-3">
                        <Button asChild size="sm" className="bg-[#00A550] text-white hover:bg-[#007A3D]">
                          <a href={certificate ? `/api/school/certificates/${certificate.id}` : `/api/school/certificates/${result.id}?result=1`}>
                            <Download className="mr-2 h-4 w-4" />
                            PDF
                          </a>
                        </Button>
                      </td>
                    </tr>
                  );
                })}
                {eligibleResults.length === 0 && (
                  <tr>
                    <td colSpan={5} className="py-10 text-center text-gray-500">
                      Aucun élève avec résultat réussi validé par l&apos;administration.
                    </td>
                  </tr>
                )}
              </tbody>
            </table>
          </div>
        </CardContent>
      </Card>

      <Card className="bg-[#F5F5F5]">
        <CardContent className="p-5 text-sm text-gray-600">
          Les certificats incluent le logo officiel FLEHub, le logo de l&apos;école, la signature du directeur,
          les scores par compétence, un identifiant UUID et un QR code de vérification.
        </CardContent>
      </Card>
    </div>
  );
}
