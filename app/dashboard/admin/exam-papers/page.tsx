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
import { createClient } from '@/lib/supabase/client';

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
  const [uploading, setUploading] = useState(false);
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
    setUploading(true);
    setMessage('');

    try {
      // 1. Upload direct vers Supabase Storage (pas via API)
      const supabase = createClient();
      const filePath = `${sessionId}/${competency}-${Date.now()}.pdf`;
      const { error: uploadError } = await supabase.storage
        .from('exam-papers')
        .upload(filePath, file, { contentType: 'application/pdf', upsert: true });

      if (uploadError) {
        setMessage('Erreur upload : ' + uploadError.message);
        setUploading(false);
        return;
      }

      // 2. Envoie juste les métadonnées à l'API
      const response = await fetch('/api/admin-exam-papers', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ exam_session_id: sessionId, competency, file_path: filePath }),
      });

      const result = await response.json();
      setMessage(response.ok ? 'Sujet téléversé avec succès ✅' : result.error ?? 'Erreur.');

      if (response.ok) {
        setFile(null);
        await load();
      }
    } catch {
      setMessage('Erreur inattendue.');
    }

    setUploading(false);
  };

  return (
    <div className="p-6 space-y-6">
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-2xl font-bold text-gray-900">Sujets officiels PDF</h1>
          <p className="text-sm text-gray-500">Téléverser les PDF par session et compétence.</p>
        </div>
        <Button variant="outline" onClick={load}
