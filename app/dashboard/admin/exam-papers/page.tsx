'use client';

import { useEffect, useMemo, useState } from 'react';
import { FileText, RefreshCw, Upload } from 'lucide-react';
import { Button } from '@/components/ui/button';
import { Badge } from '@/components/ui/badge';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Label } from '@/components/ui/label';
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from '@/components/ui/select';

const COMPETENCIES = [
  ['EO', 'Expression Orale'],
  ['EE', 'Expression Écrite'],
  ['CO', 'Compréhension Orale'],
  ['CE', 'Compréhension Écrite'],
  ['LANGUE', 'Étude de la Langue'],
] as const;

export default function AdminExamPapersPage() {
  const [data, setData] = useState<any>({ sessions: [], papers: [] });
  const [sessionId, setSessionId] = useState('');
  const [competency, setCompetency] = useState('EO');
  const [file, setFile] = useState<File | null>(null);
  const [loading, setLoading] = useState(true);
  const [message, setMessage] = useState('');

  const load = async () => {
    setLoading(true);
    const response = await fetch('/api/admin-exam-papers', { cache: 'no-store' });
    if (response.ok) setData(await response.json());
    setLoading(false);
  };

  useEffect(() => {
    load();
  }, []);

  const papersBySession = useMemo(() => {
    const map = new Map<string, any[]>();
    data.papers.forEach((paper: any) => {
      map.set(paper.exam_session_id, [...(map.get(paper.exam_session_id) ?? []), paper]);
    });
    return map;
  }, [data.papers]);

  const upload = async () => {
    if (!sessionId || !file) return;
    const form = new FormData();
    form.set('exam_session_id', sessionId);
    form.set('competency', competency);
    form.set('file', file);
    const response = await fetch('/api/admin-exam-papers', { method: 'POST', body: form });
    const result = await response.json();
    setMessage(response.ok ? 'Sujet téléversé.' : result.error ?? 'Upload impossible.');
    if (response.ok) {
      setFile(null);
      await load();
    }
  };

  return (
    <div className="p-6 space-y-6">
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-2xl font-bold text-gray-900">Sujets officiels PDF</h1>
          <p className="text-sm text-gray-500">Téléverser les PDF par session et compétence.</p>
        </div>
        <Button variant="outline" onClick={load} disabled={loading}>
          <RefreshCw className={`w-4 h-4 mr-2 ${loading ? 'animate-spin' : ''}`} />
          Actualiser
        </Button>
      </div>

      <Card>
        <CardHeader>
          <CardTitle>Téléverser un sujet</CardTitle>
        </CardHeader>
        <CardContent className="grid grid-cols-1 md:grid-cols-4 gap-3 items-end">
          <div>
            <Label>Session</Label>
            <Select value={sessionId} onValueChange={setSessionId}>
              <SelectTrigger><SelectValue placeholder="Session" /></SelectTrigger>
              <SelectContent>
                {data.sessions.map((session: any) => (
                  <SelectItem key={session.id} value={session.id}>
                    {session.title} — {session.cefr_level}
                  </SelectItem>
                ))}
              </SelectContent>
            </Select>
          </div>
          <div>
            <Label>Compétence</Label>
            <Select value={competency} onValueChange={setCompetency}>
              <SelectTrigger><SelectValue /></SelectTrigger>
              <SelectContent>
                {COMPETENCIES.map(([key, label]) => (
                  <SelectItem key={key} value={key}>{label}</SelectItem>
                ))}
              </SelectContent>
            </Select>
          </div>
          <div>
            <Label>PDF</Label>
            <input
              type="file"
              accept="application/pdf"
              onChange={(event) => setFile(event.target.files?.[0] ?? null)}
              className="block w-full text-sm"
            />
          </div>
          <Button onClick={upload} disabled={!sessionId || !file} className="bg-[#00A550] hover:bg-[#008040] text-white">
            <Upload className="w-4 h-4 mr-2" />
            Téléverser
          </Button>
          {message && <p className="text-sm text-gray-600 md:col-span-4">{message}</p>}
        </CardContent>
      </Card>

      <div className="grid grid-cols-1 lg:grid-cols-2 gap-4">
        {data.sessions.map((session: any) => {
          const papers = papersBySession.get(session.id) ?? [];
          return (
            <Card key={session.id}>
              <CardHeader>
                <CardTitle className="flex items-center justify-between">
                  <span>{session.title}</span>
                  <Badge>{session.cefr_level}</Badge>
                </CardTitle>
              </CardHeader>
              <CardContent className="space-y-2">
                {COMPETENCIES.map(([key, label]) => (
                  <div key={key} className="flex items-center justify-between rounded-lg border p-3">
                    <span className="flex items-center gap-2 text-sm">
                      <FileText className="w-4 h-4 text-[#00A550]" />
                      {label}
                    </span>
                    <Badge variant={papers.some((paper) => paper.competency === key) ? 'default' : 'secondary'}>
                      {papers.some((paper) => paper.competency === key) ? 'Disponible' : 'Manquant'}
                    </Badge>
                  </div>
                ))}
              </CardContent>
            </Card>
          );
        })}
      </div>
    </div>
  );
}
