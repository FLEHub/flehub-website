'use client';

import { useEffect, useMemo, useState } from 'react';
import { CheckCircle2, RefreshCw, XCircle } from 'lucide-react';
import { Button } from '@/components/ui/button';
import { Badge } from '@/components/ui/badge';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Input } from '@/components/ui/input';
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from '@/components/ui/table';

export default function AdminSchoolResultsPage() {
  const [data, setData] = useState<any>({ results: [], students: [], schools: [], sessions: [] });
  const [loading, setLoading] = useState(true);
  const [feedback, setFeedback] = useState<Record<string, string>>({});

  const load = async () => {
    setLoading(true);
    const response = await fetch('/api/admin-school-results', { cache: 'no-store' });
    if (response.ok) setData(await response.json());
    setLoading(false);
  };

  useEffect(() => {
    load();
  }, []);

  const students = useMemo(
    () => new Map(data.students.map((student: any) => [student.id, student])),
    [data.students]
  );
  const schools = useMemo(
    () => new Map(data.schools.map((school: any) => [school.id, school])),
    [data.schools]
  );
  const sessions = useMemo(
    () => new Map(data.sessions.map((session: any) => [session.id, session])),
    [data.sessions]
  );

  const update = async (resultId: string, action: 'validate' | 'reject') => {
    await fetch('/api/admin-school-results', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ action, result_id: resultId, feedback: feedback[resultId] }),
    });
    await load();
  };

  return (
    <div className="p-6 space-y-6">
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-2xl font-bold text-gray-900">Validation des résultats écoles</h1>
          <p className="text-sm text-gray-500">Valider ou rejeter les résultats soumis par les écoles.</p>
        </div>
        <Button variant="outline" onClick={load} disabled={loading}>
          <RefreshCw className={`w-4 h-4 mr-2 ${loading ? 'animate-spin' : ''}`} />
          Actualiser
        </Button>
      </div>

      <Card>
        <CardHeader>
          <CardTitle>Résultats soumis</CardTitle>
        </CardHeader>
        <CardContent className="p-0">
          <Table>
            <TableHeader>
              <TableRow>
                <TableHead>École</TableHead>
                <TableHead>Élève</TableHead>
                <TableHead>Session</TableHead>
                <TableHead>Score</TableHead>
                <TableHead>Statut</TableHead>
                <TableHead>Retour admin</TableHead>
                <TableHead className="text-right">Actions</TableHead>
              </TableRow>
            </TableHeader>
            <TableBody>
              {data.results.map((result: any) => {
                const student = students.get(result.student_id) as any;
                const school = schools.get(result.school_id) as any;
                const session = sessions.get(result.exam_session_id) as any;
                return (
                  <TableRow key={result.id}>
                    <TableCell>{school?.name ?? school?.school_name ?? '—'}</TableCell>
                    <TableCell>{student ? `${student.first_name} ${student.last_name}` : '—'}</TableCell>
                    <TableCell>{session?.title ?? '—'}</TableCell>
                    <TableCell>{result.total_score ?? '—'}/100</TableCell>
                    <TableCell>
                      <Badge>{result.validation_status}</Badge>
                    </TableCell>
                    <TableCell className="min-w-[220px]">
                      <Input
                        placeholder="Motif de rejet/correction"
                        value={feedback[result.id] ?? result.admin_feedback ?? ''}
                        onChange={(event) =>
                          setFeedback((prev) => ({ ...prev, [result.id]: event.target.value }))
                        }
                      />
                    </TableCell>
                    <TableCell className="text-right space-x-2">
                      <Button
                        size="sm"
                        className="bg-[#00A550] hover:bg-[#008040] text-white"
                        disabled={!result.submitted}
                        onClick={() => update(result.id, 'validate')}
                      >
                        <CheckCircle2 className="w-4 h-4 mr-1" />
                        Valider
                      </Button>
                      <Button
                        size="sm"
                        variant="outline"
                        disabled={!result.submitted}
                        onClick={() => update(result.id, 'reject')}
                      >
                        <XCircle className="w-4 h-4 mr-1 text-red-600" />
                        Rejeter
                      </Button>
                    </TableCell>
                  </TableRow>
                );
              })}
            </TableBody>
          </Table>
        </CardContent>
      </Card>
    </div>
  );
}
