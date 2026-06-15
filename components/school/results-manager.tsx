'use client';

import { useMemo, useState } from 'react';
import { toast } from 'sonner';
import { Save, Send } from 'lucide-react';
import { Button } from '@/components/ui/button';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import { Badge } from '@/components/ui/badge';
import { COMPETENCIES, RESULT_STATUS_LABELS } from '@/lib/school/constants';

type Props = {
  students: any[];
  sessions: any[];
  enrollments: any[];
  results: any[];
  averages: any[];
};

const emptyScores = Object.fromEntries(COMPETENCIES.map((c) => [c.scoreKey, '']));

export function ResultsManager({ students, sessions, enrollments, results, averages }: Props) {
  const [studentId, setStudentId] = useState('');
  const [examSessionId, setExamSessionId] = useState('');
  const [scores, setScores] = useState<Record<string, string>>(emptyScores);
  const [loading, setLoading] = useState(false);
  const [levelFilter, setLevelFilter] = useState('');
  const [sessionFilter, setSessionFilter] = useState('');
  const [gradeFilter, setGradeFilter] = useState('');

  const enrolledOptions = useMemo(() => {
    return enrollments.filter((enrollment) => enrollment.status === 'active');
  }, [enrollments]);

  const filteredResults = results.filter((result) => {
    const levelOk = !levelFilter || result.exam_sessions?.cefr_level === levelFilter;
    const sessionOk = !sessionFilter || result.exam_session_id === sessionFilter;
    const gradeOk = !gradeFilter || result.students?.grade === gradeFilter;
    return levelOk && sessionOk && gradeOk;
  });

  const grades = Array.from(new Set(students.map((student) => student.grade).filter(Boolean)));

  function selectEnrollment(value: string) {
    const enrollment = enrolledOptions.find((item) => item.id === value);
    if (!enrollment) return;
    setStudentId(enrollment.student_id);
    setExamSessionId(enrollment.exam_session_id);
  }

  async function submit(action: 'draft' | 'submit') {
    if (!studentId || !examSessionId) {
      toast.error('Sélectionnez un élève et une session.');
      return;
    }
    setLoading(true);
    const res = await fetch('/api/school/results', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ student_id: studentId, exam_session_id: examSessionId, action, ...scores }),
    });
    const payload = await res.json().catch(() => ({}));
    setLoading(false);

    if (!res.ok) {
      toast.error(payload.error ?? 'Enregistrement impossible.');
      return;
    }
    toast.success(action === 'submit' ? 'Résultats soumis à validation.' : 'Brouillon enregistré.');
    window.location.reload();
  }

  const query = new URLSearchParams();
  if (levelFilter) query.set('level', levelFilter);
  if (sessionFilter) query.set('session', sessionFilter);
  if (gradeFilter) query.set('grade', gradeFilter);

  return (
    <div className="space-y-6">
      <div className="grid gap-6 lg:grid-cols-[420px_1fr]">
        <Card>
          <CardHeader>
            <CardTitle className="text-base">Saisie des résultats</CardTitle>
          </CardHeader>
          <CardContent className="space-y-4">
            <div>
              <Label>Élève inscrit à une session</Label>
              <select className="h-10 w-full rounded-md border px-3 text-sm" onChange={(e) => selectEnrollment(e.target.value)} defaultValue="">
                <option value="">Sélectionner</option>
                {enrolledOptions.map((enrollment) => (
                  <option key={enrollment.id} value={enrollment.id}>
                    {enrollment.students?.first_name} {enrollment.students?.last_name} - {enrollment.exam_sessions?.title}
                  </option>
                ))}
              </select>
            </div>
            <div className="grid grid-cols-2 gap-3">
              {COMPETENCIES.map((competency) => (
                <div key={competency.key}>
                  <Label>{competency.key === 'LANGUE' ? 'Langue' : competency.key}</Label>
                  <Input
                    type="number"
                    min={0}
                    max={100}
                    value={scores[competency.scoreKey] ?? ''}
                    onChange={(e) => setScores((current) => ({ ...current, [competency.scoreKey]: e.target.value }))}
                    placeholder="0-100"
                  />
                </div>
              ))}
            </div>
            <div className="grid gap-2 sm:grid-cols-2">
              <Button disabled={loading} variant="outline" onClick={() => submit('draft')}>
                <Save className="mr-2 h-4 w-4" />
                Brouillon
              </Button>
              <Button disabled={loading} className="bg-[#00A550] text-white hover:bg-[#007A3D]" onClick={() => submit('submit')}>
                <Send className="mr-2 h-4 w-4" />
                Soumettre
              </Button>
            </div>
            <p className="text-xs text-gray-500">
              Après soumission, les résultats sont verrouillés jusqu'à validation ou rejet par l'administration.
            </p>
          </CardContent>
        </Card>

        <Card>
          <CardHeader>
            <CardTitle className="text-base">Moyennes par compétence</CardTitle>
          </CardHeader>
          <CardContent className="space-y-4">
            {averages.map((item) => (
              <div key={item.key}>
                <div className="mb-1 flex justify-between text-sm">
                  <span>{item.label}</span>
                  <strong>{item.average}/100</strong>
                </div>
                <div className="h-4 rounded-full bg-gray-100">
                  <div className="h-4 rounded-full bg-[#00A550]" style={{ width: `${Math.min(100, item.average)}%` }} />
                </div>
              </div>
            ))}
          </CardContent>
        </Card>
      </div>

      <Card>
        <CardHeader>
          <div className="flex flex-col gap-4 lg:flex-row lg:items-center lg:justify-between">
            <CardTitle className="text-base">Tableau des résultats</CardTitle>
            <div className="flex flex-wrap gap-2">
              <select className="h-9 rounded-md border px-3 text-sm" value={levelFilter} onChange={(e) => setLevelFilter(e.target.value)}>
                <option value="">Tous niveaux</option>
                {Array.from(new Set(sessions.map((session) => session.cefr_level))).map((level) => (
                  <option key={level} value={level}>{level}</option>
                ))}
              </select>
              <select className="h-9 rounded-md border px-3 text-sm" value={sessionFilter} onChange={(e) => setSessionFilter(e.target.value)}>
                <option value="">Toutes sessions</option>
                {sessions.map((session) => (
                  <option key={session.id} value={session.id}>{session.title}</option>
                ))}
              </select>
              <select className="h-9 rounded-md border px-3 text-sm" value={gradeFilter} onChange={(e) => setGradeFilter(e.target.value)}>
                <option value="">Toutes classes</option>
                {grades.map((grade) => <option key={grade} value={grade}>{grade}</option>)}
              </select>
              <Button asChild variant="outline" size="sm">
                <a href={`/api/school/reports/export?format=xlsx&${query.toString()}`}>Excel</a>
              </Button>
              <Button asChild variant="outline" size="sm">
                <a href={`/api/school/reports/export?format=pdf&${query.toString()}`}>PDF</a>
              </Button>
            </div>
          </div>
        </CardHeader>
        <CardContent>
          <div className="overflow-x-auto">
            <table className="w-full text-sm">
              <thead>
                <tr className="border-b text-left text-gray-500">
                  <th className="py-2 pr-3">Élève</th>
                  <th className="py-2 pr-3">Session</th>
                  {COMPETENCIES.map((competency) => <th key={competency.key} className="py-2 pr-3">{competency.key === 'LANGUE' ? 'Langue' : competency.key}</th>)}
                  <th className="py-2 pr-3">Résultat</th>
                  <th className="py-2">Statut</th>
                </tr>
              </thead>
              <tbody>
                {filteredResults.map((result) => (
                  <tr key={result.id} className="border-b last:border-0">
                    <td className="py-3 pr-3 font-medium">{result.students?.first_name} {result.students?.last_name}</td>
                    <td className="py-3 pr-3">{result.exam_sessions?.title}</td>
                    {COMPETENCIES.map((competency) => <td key={competency.key} className="py-3 pr-3">{result[competency.scoreKey]}</td>)}
                    <td className="py-3 pr-3">
                      <Badge className={result.overall_pass ? 'bg-[#E8F8F0] text-[#00A550]' : 'bg-red-50 text-red-600'}>
                        {result.overall_pass ? 'Réussite' : 'Échec'}
                      </Badge>
                    </td>
                    <td className="py-3">
                      {RESULT_STATUS_LABELS[result.status] ?? result.status}
                      {result.admin_feedback && <p className="text-xs text-red-600">{result.admin_feedback}</p>}
                    </td>
                  </tr>
                ))}
                {filteredResults.length === 0 && (
                  <tr>
                    <td colSpan={9} className="py-10 text-center text-gray-500">Aucun résultat trouvé.</td>
                  </tr>
                )}
              </tbody>
            </table>
          </div>
        </CardContent>
      </Card>
    </div>
  );
}
