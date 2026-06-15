'use client';

import { useMemo, useState } from 'react';
import { toast } from 'sonner';
import { Upload, UserPlus } from 'lucide-react';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { CEFR_LEVELS, type CefrLevel } from '@/lib/school/constants';

type Props = {
  students: any[];
  sessions: any[];
};

const emptyForm = {
  first_name: '',
  last_name: '',
  date_of_birth: '',
  gender: 'M',
  grade: '',
  cefr_level: 'A1' as CefrLevel,
  exam_session_id: '',
};

export function StudentsManager({ students, sessions }: Props) {
  const [form, setForm] = useState(emptyForm);
  const [editingId, setEditingId] = useState<string | null>(null);
  const [loading, setLoading] = useState(false);
  const [csvLoading, setCsvLoading] = useState(false);

  const sessionsForLevel = useMemo(
    () => sessions.filter((session) => session.cefr_level === form.cefr_level),
    [sessions, form.cefr_level]
  );

  function update(field: string, value: string) {
    setForm((current) => ({
      ...current,
      [field]: value,
      ...(field === 'cefr_level' ? { exam_session_id: '' } : {}),
    }));
  }

  async function submitStudent(event: React.FormEvent) {
    event.preventDefault();
    setLoading(true);
    const endpoint = editingId ? `/api/school/students/${editingId}` : '/api/school/students';
    const method = editingId ? 'PATCH' : 'POST';

    const res = await fetch(endpoint, {
      method,
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(form),
    });
    const payload = await res.json().catch(() => ({}));
    setLoading(false);

    if (!res.ok) {
      toast.error(payload.error ?? "Impossible d'enregistrer l'élève.");
      return;
    }

    toast.success(editingId ? 'Élève mis à jour.' : 'Élève inscrit.');
    window.location.reload();
  }

  async function removeStudent(id: string) {
    if (!confirm('Retirer définitivement cet élève ?')) return;
    const res = await fetch(`/api/school/students/${id}`, { method: 'DELETE' });
    if (!res.ok) {
      const payload = await res.json().catch(() => ({}));
      toast.error(payload.error ?? "Suppression impossible.");
      return;
    }
    toast.success('Élève retiré.');
    window.location.reload();
  }

  async function uploadCsv(event: React.ChangeEvent<HTMLInputElement>) {
    const file = event.target.files?.[0];
    if (!file) return;
    setCsvLoading(true);
    const body = new FormData();
    body.append('file', file);
    const res = await fetch('/api/school/students/bulk', { method: 'POST', body });
    const payload = await res.json().catch(() => ({}));
    setCsvLoading(false);

    if (!res.ok) {
      toast.error(payload.error ?? 'Import CSV impossible.');
      return;
    }
    toast.success(`${payload.created} élève(s) importé(s).`);
    if (payload.errors?.length) {
      toast.warning(payload.errors.slice(0, 3).join(' '));
    }
    window.location.reload();
  }

  function edit(student: any) {
    setEditingId(student.id);
    setForm({
      ...emptyForm,
      first_name: student.first_name ?? '',
      last_name: student.last_name ?? '',
      date_of_birth: student.date_of_birth ?? '',
      gender: student.gender ?? 'M',
      grade: student.grade ?? '',
    });
  }

  return (
    <div className="grid gap-6 lg:grid-cols-[380px_1fr]">
      <Card>
        <CardHeader>
          <CardTitle className="flex items-center gap-2 text-base">
            <UserPlus className="h-5 w-5 text-[#00A550]" />
            {editingId ? 'Modifier un élève' : 'Inscrire un élève'}
          </CardTitle>
        </CardHeader>
        <CardContent>
          <form onSubmit={submitStudent} className="space-y-4">
            <div className="grid grid-cols-2 gap-3">
              <div>
                <Label>Prénom</Label>
                <Input value={form.first_name} onChange={(e) => update('first_name', e.target.value)} required />
              </div>
              <div>
                <Label>Nom</Label>
                <Input value={form.last_name} onChange={(e) => update('last_name', e.target.value)} required />
              </div>
            </div>
            <div>
              <Label>Date de naissance</Label>
              <Input type="date" value={form.date_of_birth} onChange={(e) => update('date_of_birth', e.target.value)} />
            </div>
            <div className="grid grid-cols-2 gap-3">
              <div>
                <Label>Genre</Label>
                <select className="h-10 w-full rounded-md border px-3 text-sm" value={form.gender} onChange={(e) => update('gender', e.target.value)}>
                  <option value="M">M</option>
                  <option value="F">F</option>
                </select>
              </div>
              <div>
                <Label>Classe</Label>
                <Input value={form.grade} onChange={(e) => update('grade', e.target.value)} required />
              </div>
            </div>
            {!editingId && (
              <>
                <div>
                  <Label>Niveau CECRL</Label>
                  <select className="h-10 w-full rounded-md border px-3 text-sm" value={form.cefr_level} onChange={(e) => update('cefr_level', e.target.value)}>
                    {CEFR_LEVELS.map((level) => (
                      <option key={level} value={level}>{level}</option>
                    ))}
                  </select>
                </div>
                <div>
                  <Label>Session examen active</Label>
                  <select className="h-10 w-full rounded-md border px-3 text-sm" value={form.exam_session_id} onChange={(e) => update('exam_session_id', e.target.value)}>
                    <option value="">Créer sans session</option>
                    {sessionsForLevel.map((session) => (
                      <option key={session.id} value={session.id}>
                        {session.title} - {new Date(session.exam_date).toLocaleDateString('fr-FR')}
                      </option>
                    ))}
                  </select>
                </div>
              </>
            )}
            <Button disabled={loading} className="w-full bg-[#00A550] text-white hover:bg-[#007A3D]">
              {loading ? 'Enregistrement...' : editingId ? 'Mettre à jour' : 'Inscrire'}
            </Button>
            {editingId && (
              <Button type="button" variant="outline" className="w-full" onClick={() => { setEditingId(null); setForm(emptyForm); }}>
                Annuler
              </Button>
            )}
          </form>

          <div className="mt-6 rounded-2xl border border-dashed p-4">
            <Label className="flex cursor-pointer items-center gap-2 text-sm font-medium text-[#00A550]">
              <Upload className="h-4 w-4" />
              {csvLoading ? 'Import en cours...' : 'Importer un CSV'}
              <input type="file" accept=".csv,text/csv" className="hidden" onChange={uploadCsv} disabled={csvLoading} />
            </Label>
            <p className="mt-2 text-xs text-gray-500">
              Colonnes : first_name, last_name, date_of_birth, gender, grade, cefr_level.
            </p>
          </div>
        </CardContent>
      </Card>

      <Card>
        <CardHeader>
          <CardTitle className="text-base">Mes élèves ({students.length})</CardTitle>
        </CardHeader>
        <CardContent>
          <div className="overflow-x-auto">
            <table className="w-full text-sm">
              <thead>
                <tr className="border-b text-left text-gray-500">
                  <th className="py-2 pr-4">Nom complet</th>
                  <th className="py-2 pr-4">Naissance</th>
                  <th className="py-2 pr-4">Genre</th>
                  <th className="py-2 pr-4">Classe</th>
                  <th className="py-2">Actions</th>
                </tr>
              </thead>
              <tbody>
                {students.map((student) => (
                  <tr key={student.id} className="border-b last:border-0">
                    <td className="py-3 pr-4 font-medium">{student.first_name} {student.last_name}</td>
                    <td className="py-3 pr-4 text-gray-600">{student.date_of_birth ?? '-'}</td>
                    <td className="py-3 pr-4">{student.gender}</td>
                    <td className="py-3 pr-4">{student.grade}</td>
                    <td className="py-3">
                      <div className="flex gap-2">
                        <Button size="sm" variant="outline" onClick={() => edit(student)}>Modifier</Button>
                        <Button size="sm" variant="destructive" onClick={() => removeStudent(student.id)}>Retirer</Button>
                      </div>
                    </td>
                  </tr>
                ))}
                {students.length === 0 && (
                  <tr>
                    <td colSpan={5} className="py-10 text-center text-gray-500">
                      Aucun élève inscrit pour le moment.
                    </td>
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
