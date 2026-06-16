'use client';

import { useEffect, useMemo, useState } from 'react';
import {
  Award,
  BarChart3,
  Download,
  FileArchive,
  FileDown,
  FileText,
  GraduationCap,
  Loader2,
  Plus,
  RefreshCw,
  Save,
  Send,
  Settings,
  Trash2,
  Users,
} from 'lucide-react';
import {
  Bar,
  BarChart,
  CartesianGrid,
  ResponsiveContainer,
  Tooltip,
  XAxis,
  YAxis,
} from 'recharts';
import { Button } from '@/components/ui/button';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import { Badge } from '@/components/ui/badge';
import { Skeleton } from '@/components/ui/skeleton';
import { useToast } from '@/hooks/use-toast';
import {
  Dialog,
  DialogContent,
  DialogFooter,
  DialogHeader,
  DialogTitle,
} from '@/components/ui/dialog';
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from '@/components/ui/select';
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from '@/components/ui/table';

type Section = 'home' | 'students' | 'exams' | 'results' | 'certificates' | 'settings';
type CefrLevel = 'A1' | 'A2' | 'B1' | 'B2' | 'C1' | 'C2';
type Competency = 'EO' | 'EE' | 'CO' | 'CE' | 'LANGUE';
type Gender = 'M' | 'F';

const CEFR_LEVELS: CefrLevel[] = ['A1', 'A2', 'B1', 'B2', 'C1', 'C2'];
const COMPETENCIES: { key: Competency; label: string; column: keyof ResultRecord }[] = [
  { key: 'EO', label: 'Expression Orale', column: 'score_eo' },
  { key: 'EE', label: 'Expression Écrite', column: 'score_ee' },
  { key: 'CO', label: 'Compréhension Orale', column: 'score_co' },
  { key: 'CE', label: 'Compréhension Écrite', column: 'score_ce' },
  { key: 'LANGUE', label: 'Étude de la Langue', column: 'score_langue' },
];

interface SchoolRecord {
  id: string;
  display_name?: string;
  name?: string | null;
  school_name?: string | null;
  type?: 'primary' | 'secondary' | 'both' | null;
  address?: string | null;
  district?: string | null;
  director_name?: string | null;
  email?: string | null;
  phone?: string | null;
  status?: string | null;
  logo_url?: string | null;
  signature_url?: string | null;
  logo_signed_url?: string | null;
  signature_signed_url?: string | null;
}

interface StudentRecord {
  id: string;
  school_id: string;
  first_name: string;
  last_name: string;
  date_of_birth: string;
  gender: Gender;
  grade: string;
  created_at: string;
}

interface SchoolStudentRecord {
  id: string;
  school_id: string;
  first_name: string;
  last_name: string;
  created_at: string;
}

interface EnrollmentRecord {
  id: string;
  student_id: string;
  exam_session_id: string;
  cefr_level: CefrLevel;
  active: boolean;
  enrolled_at: string;
}

interface ExamSessionRecord {
  id: string;
  title: string;
  cefr_level: CefrLevel;
  exam_date: string;
  registration_deadline?: string | null;
  venue?: string | null;
  status: string;
}

interface ExamPaperRecord {
  id: string;
  exam_session_id: string;
  competency: Competency;
  file_path: string;
}

interface ResultRecord {
  id: string;
  student_id: string;
  exam_session_id: string;
  score_eo: number | null;
  score_ee: number | null;
  score_co: number | null;
  score_ce: number | null;
  score_langue: number | null;
  total_score: number | null;
  overall_pass: boolean;
  submitted: boolean;
  validated_by_admin: boolean;
  validation_status: 'draft' | 'submitted' | 'validated' | 'rejected';
  admin_feedback?: string | null;
}

interface CertificateRecord {
  id: string;
  student_id: string;
  level?: CefrLevel;
  cefr_level?: CefrLevel;
  issue_date?: string;
  certificate_uuid?: string;
  certificate_number?: string;
  pdf_url?: string | null;
  verified_url?: string | null;
}

interface SchoolSpaceData {
  school: SchoolRecord;
  schoolStudents: SchoolStudentRecord[];
  students: StudentRecord[];
  enrollments: EnrollmentRecord[];
  sessions: ExamSessionRecord[];
  examPapers: ExamPaperRecord[];
  downloads: Array<{ id: string; exam_id: string; competency: Competency; downloaded_at: string }>;
  results: ResultRecord[];
  certificates: CertificateRecord[];
  stats: {
    students: number;
    activeEnrollments: number;
    activeSessions: number;
    submittedResults: number;
    validatedPassResults: number;
    certificates: number;
    passRate: number;
  };
}

interface StudentForm {
  first_name: string;
  last_name: string;
}

interface ResultForm {
  student_id: string;
  exam_session_id: string;
  score_eo: string;
  score_ee: string;
  score_co: string;
  score_ce: string;
  score_langue: string;
}

interface ProfileForm {
  name: string;
  type: 'primary' | 'secondary' | 'both';
  address: string;
  district: string;
  director_name: string;
  email: string;
  phone: string;
  password: string;
}

const emptyStudentForm: StudentForm = {
  first_name: '',
  last_name: '',
};

const emptyResultForm: ResultForm = {
  student_id: '',
  exam_session_id: '',
  score_eo: '',
  score_ee: '',
  score_co: '',
  score_ce: '',
  score_langue: '',
};

function formatDate(value?: string | null) {
  if (!value) return '—';
  return new Date(value).toLocaleDateString('fr-RW', {
    day: '2-digit',
    month: 'short',
    year: 'numeric',
  });
}

function fullName(student?: { first_name: string; last_name: string }) {
  return student ? `${student.first_name} ${student.last_name}` : 'Élève inconnu';
}

function statusLabel(result?: ResultRecord) {
  if (!result) return { label: 'Non saisi', className: 'bg-gray-100 text-gray-500' };
  if (result.validation_status === 'validated') {
    return result.overall_pass
      ? { label: 'Réussi validé', className: 'bg-[#E6F5EE] text-[#00A550]' }
      : { label: 'Échec validé', className: 'bg-red-50 text-red-600' };
  }
  if (result.validation_status === 'rejected') {
    return { label: 'Corrections demandées', className: 'bg-amber-50 text-amber-700' };
  }
  if (result.submitted) return { label: 'Soumis à validation', className: 'bg-blue-50 text-blue-700' };
  return { label: 'Brouillon', className: 'bg-gray-100 text-gray-600' };
}

async function apiPost(payload: Record<string, unknown>) {
  const response = await fetch('/api/school-space', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(payload),
  });
  const result = await response.json();
  if (!response.ok) throw new Error(result.error ?? 'Action impossible.');
  return result;
}

function downloadBlob(content: BlobPart, filename: string, type: string) {
  const blob = new Blob([content], { type });
  const url = URL.createObjectURL(blob);
  const anchor = document.createElement('a');
  anchor.href = url;
  anchor.download = filename;
  anchor.click();
  URL.revokeObjectURL(url);
}

function csvEscape(value: unknown) {
  const text = String(value ?? '');
  return `"${text.replace(/"/g, '""')}"`;
}

function xmlEscape(value: unknown) {
  return String(value ?? '')
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;')
    .replace(/'/g, '&apos;');
}

function columnName(index: number) {
  let name = '';
  let current = index + 1;
  while (current > 0) {
    const remainder = (current - 1) % 26;
    name = String.fromCharCode(65 + remainder) + name;
    current = Math.floor((current - 1) / 26);
  }
  return name;
}

export function SchoolSpaceClient({ section }: { section: Section }) {
  const { toast } = useToast();
  const [data, setData] = useState<SchoolSpaceData | null>(null);
  const [loading, setLoading] = useState(true);
  const [saving, setSaving] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [studentOpen, setStudentOpen] = useState(false);
  const [studentForm, setStudentForm] = useState<StudentForm>(emptyStudentForm);
  const [resultForm, setResultForm] = useState<ResultForm>(emptyResultForm);
  const [filters, setFilters] = useState({ level: 'all', session: 'all', grade: 'all' });
  const [profileForm, setProfileForm] = useState<ProfileForm>({
    name: '',
    type: 'both',
    address: '',
    district: '',
    director_name: '',
    email: '',
    phone: '',
    password: '',
  });
  const [logoFile, setLogoFile] = useState<File | null>(null);
  const [signatureFile, setSignatureFile] = useState<File | null>(null);

  const load = async () => {
    setLoading(true);
    setError(null);
    try {
      const response = await fetch('/api/school-space', { cache: 'no-store' });
      const result = await response.json();
      if (!response.ok) throw new Error(result.error ?? 'Chargement impossible.');
      setData(result);
      setProfileForm({
        name: result.school.name ?? result.school.school_name ?? '',
        type: result.school.type ?? 'both',
        address: result.school.address ?? '',
        district: result.school.district ?? '',
        director_name: result.school.director_name ?? '',
        email: result.school.email ?? '',
        phone: result.school.phone ?? '',
        password: '',
      });
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Chargement impossible.');
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    load();
  }, []);

  const studentById = useMemo(() => {
    const map = new Map<string, StudentRecord>();
    data?.students.forEach((student) => map.set(student.id, student));
    return map;
  }, [data?.students]);

  const sessionById = useMemo(() => {
    const map = new Map<string, ExamSessionRecord>();
    data?.sessions.forEach((session) => map.set(session.id, session));
    return map;
  }, [data?.sessions]);

  const enrollmentByStudent = useMemo(() => {
    const map = new Map<string, EnrollmentRecord>();
    data?.enrollments.forEach((enrollment) => map.set(enrollment.student_id, enrollment));
    return map;
  }, [data?.enrollments]);

  const resultsByStudentSession = useMemo(() => {
    const map = new Map<string, ResultRecord>();
    data?.results.forEach((result) => map.set(`${result.student_id}:${result.exam_session_id}`, result));
    return map;
  }, [data?.results]);

  const filteredResults = useMemo(() => {
    if (!data) return [];
    return data.results.filter((result) => {
      const student = studentById.get(result.student_id);
      const session = sessionById.get(result.exam_session_id);
      return (
        (filters.level === 'all' || session?.cefr_level === filters.level) &&
        (filters.session === 'all' || result.exam_session_id === filters.session) &&
        (filters.grade === 'all' || student?.grade === filters.grade)
      );
    });
  }, [data, filters, sessionById, studentById]);

  const chartData = useMemo(() => {
    return COMPETENCIES.map(({ key, label, column }) => {
      const values = filteredResults
        .map((result) => result[column])
        .filter((value): value is number => typeof value === 'number');
      const average =
        values.length > 0
          ? Math.round(values.reduce((sum, value) => sum + value, 0) / values.length)
          : 0;
      return { competency: key, label, moyenne: average };
    });
  }, [filteredResults]);

  const grades = useMemo(() => {
    return Array.from(new Set(data?.students.map((student) => student.grade).filter(Boolean))).sort();
  }, [data?.students]);

  const openCreateStudent = () => {
    setStudentForm(emptyStudentForm);
    setStudentOpen(true);
  };

  const saveStudent = async () => {
    setSaving(true);
    try {
      await apiPost({
        action: 'createSchoolStudent',
        first_name: studentForm.first_name,
        last_name: studentForm.last_name,
      });
      toast({ title: 'Élève ajouté', description: 'Le registre de votre école a été mis à jour.' });
      setStudentOpen(false);
      await load();
    } catch (err) {
      toast({ title: 'Erreur', description: err instanceof Error ? err.message : 'Action impossible.' });
    } finally {
      setSaving(false);
    }
  };

  const deleteStudent = async (studentId: string) => {
    if (!confirm('Supprimer cet élève de la liste ?')) return;
    setSaving(true);
    try {
      await apiPost({ action: 'deleteSchoolStudent', student_id: studentId });
      toast({ title: 'Élève supprimé' });
      await load();
    } catch (err) {
      toast({ title: 'Erreur', description: err instanceof Error ? err.message : 'Suppression impossible.' });
    } finally {
      setSaving(false);
    }
  };

  const saveResult = async (submit: boolean) => {
    setSaving(true);
    try {
      await apiPost({
        action: submit ? 'submitResult' : 'saveResult',
        ...resultForm,
      });
      toast({
        title: submit ? 'Résultat soumis' : 'Brouillon enregistré',
        description: submit ? "Le résultat est verrouillé et envoyé à l'admin." : undefined,
      });
      setResultForm(emptyResultForm);
      await load();
    } catch (err) {
      toast({ title: 'Erreur résultat', description: err instanceof Error ? err.message : 'Enregistrement impossible.' });
    } finally {
      setSaving(false);
    }
  };

  const downloadPaper = async (examId: string, competency: Competency) => {
    setSaving(true);
    try {
      const result = await apiPost({ action: 'downloadPaper', exam_id: examId, competency });
      window.open(result.url, '_blank', 'noopener,noreferrer');
      toast({ title: 'Téléchargement autorisé', description: 'Le téléchargement a été journalisé.' });
      await load();
    } catch (err) {
      toast({ title: 'Sujet indisponible', description: err instanceof Error ? err.message : 'Téléchargement impossible.' });
    } finally {
      setSaving(false);
    }
  };

  const generateCertificate = async (resultId: string) => {
    setSaving(true);
    try {
      const result = await apiPost({ action: 'generateCertificate', result_id: resultId });
      if (result.url) window.open(result.url, '_blank', 'noopener,noreferrer');
      toast({ title: 'Certificat prêt' });
      await load();
    } catch (err) {
      toast({ title: 'Certificat impossible', description: err instanceof Error ? err.message : 'Génération impossible.' });
    } finally {
      setSaving(false);
    }
  };

  const downloadCertificatesZip = async () => {
    setSaving(true);
    try {
      const result = await apiPost({ action: 'generateCertificatesZip' });
      window.open(result.url, '_blank', 'noopener,noreferrer');
      toast({ title: 'Archive ZIP prête' });
      await load();
    } catch (err) {
      toast({ title: 'ZIP impossible', description: err instanceof Error ? err.message : 'Génération impossible.' });
    } finally {
      setSaving(false);
    }
  };

  const updateProfile = async () => {
    const form = new FormData();
    form.set('action', 'updateProfile');
    Object.entries(profileForm).forEach(([key, value]) => {
      if (key !== 'password') form.set(key, value);
    });
    if (logoFile) form.set('logo', logoFile);
    if (signatureFile) form.set('signature', signatureFile);

    setSaving(true);
    try {
      const response = await fetch('/api/school-space', { method: 'POST', body: form });
      const result = await response.json();
      if (!response.ok) throw new Error(result.error ?? 'Mise à jour impossible.');
      toast({ title: 'Profil école enregistré' });
      setLogoFile(null);
      setSignatureFile(null);
      await load();
    } catch (err) {
      toast({ title: 'Erreur profil', description: err instanceof Error ? err.message : 'Mise à jour impossible.' });
    } finally {
      setSaving(false);
    }
  };

  const changePassword = async () => {
    setSaving(true);
    try {
      await apiPost({ action: 'changePassword', password: profileForm.password });
      toast({ title: 'Mot de passe modifié' });
      setProfileForm((prev) => ({ ...prev, password: '' }));
    } catch (err) {
      toast({ title: 'Erreur mot de passe', description: err instanceof Error ? err.message : 'Modification impossible.' });
    } finally {
      setSaving(false);
    }
  };

  const exportRows = () => {
    return filteredResults.map((result) => {
      const student = studentById.get(result.student_id);
      const session = sessionById.get(result.exam_session_id);
      return {
        Élève: fullName(student),
        Classe: student?.grade ?? '',
        Niveau: session?.cefr_level ?? '',
        Session: session?.title ?? '',
        EO: result.score_eo ?? '',
        EE: result.score_ee ?? '',
        CO: result.score_co ?? '',
        CE: result.score_ce ?? '',
        'Étude de la Langue': result.score_langue ?? '',
        Total: result.total_score ?? '',
        Statut: statusLabel(result).label,
      };
    });
  };

  const exportCsv = () => {
    const rows = exportRows();
    const headers = Object.keys(rows[0] ?? { Élève: '', Classe: '', Niveau: '', Session: '' });
    const csv = [headers.join(','), ...rows.map((row) => headers.map((header) => csvEscape((row as any)[header])).join(','))].join('\n');
    downloadBlob(csv, 'resultats-flehub.csv', 'text/csv;charset=utf-8');
  };

  const exportXlsx = async () => {
    const JSZip = (await import('jszip')).default;
    const rows = exportRows();
    const headers = Object.keys(rows[0] ?? { Élève: '', Classe: '', Niveau: '', Session: '' });
    const tableRows = [headers, ...rows.map((row) => headers.map((header) => (row as any)[header]))];
    const sheetData = tableRows
      .map((row, rowIndex) => {
        const cells = row
          .map((value, columnIndex) => {
            const ref = `${columnName(columnIndex)}${rowIndex + 1}`;
            return `<c r="${ref}" t="inlineStr"><is><t>${xmlEscape(value)}</t></is></c>`;
          })
          .join('');
        return `<row r="${rowIndex + 1}">${cells}</row>`;
      })
      .join('');

    const zip = new JSZip();
    zip.file(
      '[Content_Types].xml',
      '<?xml version="1.0" encoding="UTF-8"?><Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types"><Default Extension="rels" ContentType="application/vnd.openxmlformats-package.relationships+xml"/><Default Extension="xml" ContentType="application/xml"/><Override PartName="/xl/workbook.xml" ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.sheet.main+xml"/><Override PartName="/xl/worksheets/sheet1.xml" ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.worksheet+xml"/></Types>'
    );
    zip.folder('_rels')?.file(
      '.rels',
      '<?xml version="1.0" encoding="UTF-8"?><Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships"><Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument" Target="xl/workbook.xml"/></Relationships>'
    );
    zip.folder('xl')?.file(
      'workbook.xml',
      '<?xml version="1.0" encoding="UTF-8"?><workbook xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships"><sheets><sheet name="Résultats" sheetId="1" r:id="rId1"/></sheets></workbook>'
    );
    zip.folder('xl')?.folder('_rels')?.file(
      'workbook.xml.rels',
      '<?xml version="1.0" encoding="UTF-8"?><Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships"><Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/worksheet" Target="worksheets/sheet1.xml"/></Relationships>'
    );
    zip.folder('xl')?.folder('worksheets')?.file(
      'sheet1.xml',
      `<?xml version="1.0" encoding="UTF-8"?><worksheet xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main"><sheetData>${sheetData}</sheetData></worksheet>`
    );

    const blob = await zip.generateAsync({
      type: 'blob',
      mimeType: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
    });
    const url = URL.createObjectURL(blob);
    const anchor = document.createElement('a');
    anchor.href = url;
    anchor.download = 'resultats-flehub.xlsx';
    anchor.click();
    URL.revokeObjectURL(url);
  };

  const exportPdf = () => {
    const rows = exportRows();
    const html = `
      <html><head><title>Résultats FLEHub</title>
      <style>body{font-family:Arial;padding:24px}table{border-collapse:collapse;width:100%}th,td{border:1px solid #ddd;padding:6px;font-size:12px}th{background:#00A550;color:white}</style>
      </head><body><h1>Résultats FLEHub</h1><table><thead><tr>${Object.keys(rows[0] ?? {}).map((h) => `<th>${h}</th>`).join('')}</tr></thead><tbody>${rows
        .map((row) => `<tr>${Object.values(row).map((v) => `<td>${v}</td>`).join('')}</tr>`)
        .join('')}</tbody></table><script>window.print()</script></body></html>`;
    const win = window.open('', '_blank');
    win?.document.write(html);
    win?.document.close();
  };

  if (loading) {
    return (
      <div className="p-4 md:p-6 space-y-4">
        <Skeleton className="h-28 w-full" />
        <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
          <Skeleton className="h-32" />
          <Skeleton className="h-32" />
          <Skeleton className="h-32" />
        </div>
      </div>
    );
  }

  if (error || !data) {
    return (
      <div className="p-4 md:p-6">
        <Card className="border-red-200 bg-red-50">
          <CardContent className="p-6 text-red-700">{error ?? 'Espace école indisponible.'}</CardContent>
        </Card>
      </div>
    );
  }

  const enrolledSessionIds = new Set(data.enrollments.map((enrollment) => enrollment.exam_session_id));
  const certificateByStudent = new Map(data.certificates.map((certificate) => [certificate.student_id, certificate]));

  return (
    <div className="p-4 md:p-6 space-y-6 max-w-7xl mx-auto">
      <div className="flex flex-col md:flex-row md:items-center justify-between gap-3">
        <div>
          <h1 className="text-2xl font-bold text-gray-900">{data.school.display_name}</h1>
          <p className="text-sm text-gray-500">
            Statut du compte :{' '}
            <Badge className="bg-[#E6F5EE] text-[#00A550] hover:bg-[#E6F5EE]">
              {data.school.status ?? 'approved'}
            </Badge>
          </p>
        </div>
        <Button variant="outline" onClick={load} disabled={saving}>
          <RefreshCw className="w-4 h-4 mr-2" />
          Actualiser
        </Button>
      </div>

      {section === 'home' && (
        <>
          <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
            {[
              { label: 'Élèves', value: data.stats.students, icon: Users },
              { label: 'Inscriptions actives', value: data.stats.activeEnrollments, icon: GraduationCap },
              { label: 'Résultats soumis', value: data.stats.submittedResults, icon: FileText },
              { label: 'Taux de réussite validé', value: `${data.stats.passRate}%`, icon: Award },
            ].map((stat) => (
              <Card key={stat.label} className="bg-[#F5F5F5] border-0">
                <CardContent className="p-5 flex items-center justify-between">
                  <div>
                    <p className="text-3xl font-bold text-gray-900">{stat.value}</p>
                    <p className="text-sm text-gray-500">{stat.label}</p>
                  </div>
                  <stat.icon className="w-8 h-8 text-[#00A550]" />
                </CardContent>
              </Card>
            ))}
          </div>

          {(!data.school.logo_url || !data.school.signature_url) && (
            <Card className="border-amber-200 bg-amber-50">
              <CardContent className="p-4 text-sm text-amber-800">
                Ajoutez le logo de l&apos;école et la signature du/de la directeur/directrice dans
                Paramètres avant de générer les certificats officiels.
              </CardContent>
            </Card>
          )}

          <Card>
            <CardHeader>
              <CardTitle>Sessions d&apos;examen de votre école</CardTitle>
            </CardHeader>
            <CardContent className="grid grid-cols-1 md:grid-cols-2 gap-3">
              {data.sessions.filter((session) => enrolledSessionIds.has(session.id)).length === 0 ? (
                <p className="text-sm text-gray-500">Aucune session avec élèves inscrits pour le moment.</p>
              ) : (
                data.sessions
                  .filter((session) => enrolledSessionIds.has(session.id))
                  .map((session) => (
                    <div key={session.id} className="rounded-xl border p-4 bg-white">
                      <p className="font-semibold text-gray-900">{session.title}</p>
                      <p className="text-sm text-gray-500">
                        Niveau {session.cefr_level} • {formatDate(session.exam_date)}
                      </p>
                    </div>
                  ))
              )}
            </CardContent>
          </Card>
        </>
      )}

      {section === 'students' && (
        <>
          <div className="flex flex-col sm:flex-row gap-2 sm:items-center justify-between">
            <div>
              <h2 className="text-xl font-semibold">Mes élèves</h2>
              <p className="text-sm text-gray-500">
                Inscription par prénom et nom uniquement — aucun email ni mot de passe élève.
              </p>
            </div>
            <Button onClick={openCreateStudent} className="bg-[#00A550] hover:bg-[#008040] text-white">
              <Plus className="w-4 h-4 mr-2" />
              Ajouter un élève
            </Button>
          </div>

          <Card>
            <CardContent className="p-0">
              <Table>
                <TableHeader>
                  <TableRow>
                    <TableHead>Prénom</TableHead>
                    <TableHead>Nom</TableHead>
                    <TableHead>Date d&apos;ajout</TableHead>
                    <TableHead className="text-right">Actions</TableHead>
                  </TableRow>
                </TableHeader>
                <TableBody>
                  {data.schoolStudents.length === 0 ? (
                    <TableRow>
                      <TableCell colSpan={4} className="py-8 text-center text-sm text-gray-500">
                        Aucun élève inscrit pour le moment.
                      </TableCell>
                    </TableRow>
                  ) : (
                    data.schoolStudents.map((student) => (
                      <TableRow key={student.id}>
                        <TableCell className="font-medium">{student.first_name}</TableCell>
                        <TableCell>{student.last_name}</TableCell>
                        <TableCell>{formatDate(student.created_at)}</TableCell>
                        <TableCell className="text-right">
                          <Button size="sm" variant="outline" onClick={() => deleteStudent(student.id)}>
                            <Trash2 className="w-3.5 h-3.5 text-red-600" />
                          </Button>
                        </TableCell>
                      </TableRow>
                    ))
                  )}
                </TableBody>
              </Table>
            </CardContent>
          </Card>
        </>
      )}

      {section === 'exams' && (
        <div className="grid grid-cols-1 lg:grid-cols-2 gap-4">
          {data.sessions.map((session) => {
            const hasEnrollment = enrolledSessionIds.has(session.id);
            return (
              <Card key={session.id}>
                <CardHeader>
                  <CardTitle className="flex items-center justify-between gap-2">
                    <span>{session.title}</span>
                    <Badge>{session.cefr_level}</Badge>
                  </CardTitle>
                  <p className="text-sm text-gray-500">
                    {formatDate(session.exam_date)} • {session.venue ?? 'Lieu à confirmer'}
                  </p>
                </CardHeader>
                <CardContent className="space-y-3">
                  {!hasEnrollment && (
                    <p className="text-sm text-amber-700 bg-amber-50 rounded-lg p-3">
                      Téléchargement disponible après inscription d&apos;au moins un élève à cette session.
                    </p>
                  )}
                  <div className="grid grid-cols-1 sm:grid-cols-2 gap-2">
                    {COMPETENCIES.map(({ key, label }) => {
                      const paper = data.examPapers.find(
                        (p) => p.exam_session_id === session.id && p.competency === key
                      );
                      return (
                        <Button
                          key={key}
                          variant="outline"
                          disabled={!hasEnrollment || !paper || saving}
                          onClick={() => downloadPaper(session.id, key)}
                          className="justify-start"
                        >
                          <Download className="w-4 h-4 mr-2" />
                          {label}
                        </Button>
                      );
                    })}
                  </div>
                </CardContent>
              </Card>
            );
          })}
        </div>
      )}

      {section === 'results' && (
        <>
          <Card>
            <CardHeader>
              <CardTitle>Saisir les résultats par compétence</CardTitle>
            </CardHeader>
            <CardContent className="space-y-4">
              <div className="grid grid-cols-1 md:grid-cols-2 gap-3">
                <div>
                  <Label>Élève</Label>
                  <Select
                    value={resultForm.student_id}
                    onValueChange={(value) => {
                      const enrollment = enrollmentByStudent.get(value);
                      setResultForm((prev) => ({
                        ...prev,
                        student_id: value,
                        exam_session_id: enrollment?.exam_session_id ?? prev.exam_session_id,
                      }));
                    }}
                  >
                    <SelectTrigger>
                      <SelectValue placeholder="Sélectionner un élève" />
                    </SelectTrigger>
                    <SelectContent>
                      {data.students.map((student) => (
                        <SelectItem key={student.id} value={student.id}>
                          {fullName(student)}
                        </SelectItem>
                      ))}
                    </SelectContent>
                  </Select>
                </div>
                <div>
                  <Label>Session</Label>
                  <Select
                    value={resultForm.exam_session_id}
                    onValueChange={(value) => setResultForm((prev) => ({ ...prev, exam_session_id: value }))}
                  >
                    <SelectTrigger>
                      <SelectValue placeholder="Sélectionner une session" />
                    </SelectTrigger>
                    <SelectContent>
                      {data.sessions
                        .filter((session) => enrolledSessionIds.has(session.id))
                        .map((session) => (
                          <SelectItem key={session.id} value={session.id}>
                            {session.title} — {session.cefr_level}
                          </SelectItem>
                        ))}
                    </SelectContent>
                  </Select>
                </div>
              </div>
              <div className="grid grid-cols-2 md:grid-cols-5 gap-3">
                {COMPETENCIES.map(({ key, label, column }) => (
                  <div key={key}>
                    <Label className="text-xs">{label}</Label>
                    <Input
                      type="number"
                      min={0}
                      max={100}
                      placeholder="0"
                      value={resultForm[column as keyof ResultForm] as string}
                      onChange={(event) =>
                        setResultForm((prev) => ({ ...prev, [column]: event.target.value }))
                      }
                    />
                  </div>
                ))}
              </div>
              <div className="flex flex-wrap gap-2">
                <Button
                  variant="outline"
                  disabled={saving || !resultForm.student_id || !resultForm.exam_session_id}
                  onClick={() => saveResult(false)}
                >
                  <Save className="w-4 h-4 mr-2" />
                  Enregistrer brouillon
                </Button>
                <Button
                  disabled={saving || !resultForm.student_id || !resultForm.exam_session_id}
                  onClick={() => saveResult(true)}
                  className="bg-[#00A550] hover:bg-[#008040] text-white"
                >
                  <Send className="w-4 h-4 mr-2" />
                  Soumettre à l&apos;admin
                </Button>
              </div>
            </CardContent>
          </Card>

          <Card>
            <CardHeader>
              <CardTitle className="flex items-center gap-2">
                <BarChart3 className="w-5 h-5 text-[#00A550]" />
                Rapport de performance
              </CardTitle>
            </CardHeader>
            <CardContent className="space-y-4">
              <div className="grid grid-cols-1 md:grid-cols-3 gap-3">
                <Select value={filters.level} onValueChange={(value) => setFilters((prev) => ({ ...prev, level: value }))}>
                  <SelectTrigger><SelectValue placeholder="Niveau" /></SelectTrigger>
                  <SelectContent>
                    <SelectItem value="all">Tous les niveaux</SelectItem>
                    {CEFR_LEVELS.map((level) => <SelectItem key={level} value={level}>{level}</SelectItem>)}
                  </SelectContent>
                </Select>
                <Select value={filters.session} onValueChange={(value) => setFilters((prev) => ({ ...prev, session: value }))}>
                  <SelectTrigger><SelectValue placeholder="Session" /></SelectTrigger>
                  <SelectContent>
                    <SelectItem value="all">Toutes les sessions</SelectItem>
                    {data.sessions.map((session) => <SelectItem key={session.id} value={session.id}>{session.title}</SelectItem>)}
                  </SelectContent>
                </Select>
                <Select value={filters.grade} onValueChange={(value) => setFilters((prev) => ({ ...prev, grade: value }))}>
                  <SelectTrigger><SelectValue placeholder="Classe" /></SelectTrigger>
                  <SelectContent>
                    <SelectItem value="all">Toutes les classes</SelectItem>
                    {grades.map((grade) => <SelectItem key={grade} value={grade}>{grade}</SelectItem>)}
                  </SelectContent>
                </Select>
              </div>
              <div className="h-64">
                <ResponsiveContainer width="100%" height="100%">
                  <BarChart data={chartData}>
                    <CartesianGrid strokeDasharray="3 3" />
                    <XAxis dataKey="competency" />
                    <YAxis domain={[0, 100]} />
                    <Tooltip />
                    <Bar dataKey="moyenne" fill="#00A550" radius={[8, 8, 0, 0]} />
                  </BarChart>
                </ResponsiveContainer>
              </div>
              <div className="flex flex-wrap gap-2">
                <Button variant="outline" onClick={exportCsv}><FileDown className="w-4 h-4 mr-2" />CSV</Button>
                <Button variant="outline" onClick={exportXlsx}><FileDown className="w-4 h-4 mr-2" />Excel .xlsx</Button>
                <Button variant="outline" onClick={exportPdf}><FileDown className="w-4 h-4 mr-2" />PDF</Button>
              </div>
            </CardContent>
          </Card>

          <Card>
            <CardContent className="p-0">
              <Table>
                <TableHeader>
                  <TableRow>
                    <TableHead>Élève</TableHead>
                    <TableHead>Session</TableHead>
                    <TableHead>EO</TableHead>
                    <TableHead>EE</TableHead>
                    <TableHead>CO</TableHead>
                    <TableHead>CE</TableHead>
                    <TableHead>Langue</TableHead>
                    <TableHead>Total</TableHead>
                    <TableHead>Statut</TableHead>
                  </TableRow>
                </TableHeader>
                <TableBody>
                  {filteredResults.map((result) => {
                    const status = statusLabel(result);
                    return (
                      <TableRow key={result.id}>
                        <TableCell>{fullName(studentById.get(result.student_id))}</TableCell>
                        <TableCell>{sessionById.get(result.exam_session_id)?.title ?? '—'}</TableCell>
                        <TableCell>{result.score_eo ?? '—'}</TableCell>
                        <TableCell>{result.score_ee ?? '—'}</TableCell>
                        <TableCell>{result.score_co ?? '—'}</TableCell>
                        <TableCell>{result.score_ce ?? '—'}</TableCell>
                        <TableCell>{result.score_langue ?? '—'}</TableCell>
                        <TableCell>{result.total_score ?? '—'}</TableCell>
                        <TableCell><Badge className={status.className}>{status.label}</Badge></TableCell>
                      </TableRow>
                    );
                  })}
                </TableBody>
              </Table>
            </CardContent>
          </Card>
        </>
      )}

      {section === 'certificates' && (
        <Card>
          <CardHeader className="flex flex-col md:flex-row md:items-center justify-between gap-3">
            <div>
              <CardTitle>Certificats</CardTitle>
              <p className="text-sm text-gray-500">Disponibles après validation admin des résultats réussis.</p>
            </div>
            <Button onClick={downloadCertificatesZip} disabled={saving} className="bg-[#00A550] hover:bg-[#008040] text-white">
              <FileArchive className="w-4 h-4 mr-2" />
              ZIP des admis
            </Button>
          </CardHeader>
          <CardContent className="p-0">
            <Table>
              <TableHeader>
                <TableRow>
                  <TableHead>Élève</TableHead>
                  <TableHead>Niveau</TableHead>
                  <TableHead>Score</TableHead>
                  <TableHead>Certificat</TableHead>
                  <TableHead className="text-right">Action</TableHead>
                </TableRow>
              </TableHeader>
              <TableBody>
                {data.results
                  .filter((result) => result.validated_by_admin && result.overall_pass)
                  .map((result) => {
                    const session = sessionById.get(result.exam_session_id);
                    const certificate = certificateByStudent.get(result.student_id);
                    return (
                      <TableRow key={result.id}>
                        <TableCell>{fullName(studentById.get(result.student_id))}</TableCell>
                        <TableCell>{session?.cefr_level ?? '—'}</TableCell>
                        <TableCell>{result.total_score}/100</TableCell>
                        <TableCell>{certificate?.certificate_number ?? 'À générer'}</TableCell>
                        <TableCell className="text-right">
                          <Button size="sm" onClick={() => generateCertificate(result.id)} disabled={saving}>
                            <Download className="w-4 h-4 mr-2" />
                            Télécharger
                          </Button>
                        </TableCell>
                      </TableRow>
                    );
                  })}
              </TableBody>
            </Table>
          </CardContent>
        </Card>
      )}

      {section === 'settings' && (
        <div className="grid grid-cols-1 lg:grid-cols-[1fr_360px] gap-6">
          <Card>
            <CardHeader>
              <CardTitle className="flex items-center gap-2">
                <Settings className="w-5 h-5 text-[#00A550]" />
                Profil institutionnel
              </CardTitle>
            </CardHeader>
            <CardContent className="space-y-4">
              <div className="grid grid-cols-1 md:grid-cols-2 gap-3">
                <div><Label>Nom de l&apos;établissement</Label><Input value={profileForm.name} onChange={(e) => setProfileForm((p) => ({ ...p, name: e.target.value }))} /></div>
                <div>
                  <Label>Type</Label>
                  <Select value={profileForm.type} onValueChange={(value) => setProfileForm((p) => ({ ...p, type: value as ProfileForm['type'] }))}>
                    <SelectTrigger><SelectValue /></SelectTrigger>
                    <SelectContent>
                      <SelectItem value="primary">Primaire</SelectItem>
                      <SelectItem value="secondary">Secondaire</SelectItem>
                      <SelectItem value="both">Primaire et secondaire</SelectItem>
                    </SelectContent>
                  </Select>
                </div>
                <div><Label>Directeur / Directrice</Label><Input value={profileForm.director_name} onChange={(e) => setProfileForm((p) => ({ ...p, director_name: e.target.value }))} /></div>
                <div><Label>E-mail officiel</Label><Input type="email" value={profileForm.email} onChange={(e) => setProfileForm((p) => ({ ...p, email: e.target.value }))} /></div>
                <div><Label>Téléphone</Label><Input value={profileForm.phone} onChange={(e) => setProfileForm((p) => ({ ...p, phone: e.target.value }))} /></div>
                <div><Label>District</Label><Input value={profileForm.district} onChange={(e) => setProfileForm((p) => ({ ...p, district: e.target.value }))} /></div>
                <div className="md:col-span-2"><Label>Adresse</Label><Input value={profileForm.address} onChange={(e) => setProfileForm((p) => ({ ...p, address: e.target.value }))} /></div>
              </div>
              <div className="grid grid-cols-1 md:grid-cols-2 gap-3">
                <div><Label>Logo école (PNG/JPG)</Label><Input type="file" accept="image/png,image/jpeg" onChange={(e) => setLogoFile(e.target.files?.[0] ?? null)} /></div>
                <div><Label>Signature directeur (PNG)</Label><Input type="file" accept="image/png" onChange={(e) => setSignatureFile(e.target.files?.[0] ?? null)} /></div>
              </div>
              <Button onClick={updateProfile} disabled={saving} className="bg-[#00A550] hover:bg-[#008040] text-white">
                {saving ? <Loader2 className="w-4 h-4 mr-2 animate-spin" /> : <Save className="w-4 h-4 mr-2" />}
                Enregistrer le profil
              </Button>

              <div className="border-t pt-4 space-y-2">
                <Label>Nouveau mot de passe</Label>
                <div className="flex gap-2">
                  <Input type="password" value={profileForm.password} onChange={(e) => setProfileForm((p) => ({ ...p, password: e.target.value }))} />
                  <Button variant="outline" onClick={changePassword} disabled={saving || profileForm.password.length < 8}>Changer</Button>
                </div>
              </div>
            </CardContent>
          </Card>

          <Card>
            <CardHeader>
              <CardTitle>Aperçu certificat</CardTitle>
            </CardHeader>
            <CardContent>
              <div className="rounded-xl border bg-white p-4 aspect-[1.35] flex flex-col justify-between">
                <div className="flex items-start justify-between">
                  <div className="font-bold text-[#00A550] text-xl">FLEHub</div>
                  <div className="w-24 h-16 border rounded bg-[#F5F5F5] flex items-center justify-center overflow-hidden">
                    {(logoFile || data.school.logo_signed_url) ? (
                      <img
                        alt="Logo école"
                        src={logoFile ? URL.createObjectURL(logoFile) : data.school.logo_signed_url ?? ''}
                        className="max-w-full max-h-full object-contain"
                      />
                    ) : (
                      <span className="text-xs text-gray-400">Logo</span>
                    )}
                  </div>
                </div>
                <div className="text-center">
                  <p className="text-xs uppercase text-gray-400">Certificat de réussite</p>
                  <p className="text-lg font-bold">Prénom Nom</p>
                  <p className="text-[#00A550] font-semibold">Niveau A2</p>
                </div>
                <div className="text-center">
                  <div className="mx-auto w-32 h-12 border rounded bg-[#F5F5F5] flex items-center justify-center overflow-hidden">
                    {(signatureFile || data.school.signature_signed_url) ? (
                      <img
                        alt="Signature directeur"
                        src={signatureFile ? URL.createObjectURL(signatureFile) : data.school.signature_signed_url ?? ''}
                        className="max-w-full max-h-full object-contain"
                      />
                    ) : (
                      <span className="text-xs text-gray-400">Signature</span>
                    )}
                  </div>
                  <p className="text-xs mt-1">{profileForm.director_name || 'Directeur / Directrice'}</p>
                </div>
              </div>
            </CardContent>
          </Card>
        </div>
      )}

      <Dialog open={studentOpen} onOpenChange={setStudentOpen}>
        <DialogContent>
          <DialogHeader>
            <DialogTitle>Ajouter un élève</DialogTitle>
          </DialogHeader>
          <div className="grid grid-cols-1 md:grid-cols-2 gap-3">
            <div><Label>Prénom</Label><Input value={studentForm.first_name} onChange={(e) => setStudentForm((p) => ({ ...p, first_name: e.target.value }))} /></div>
            <div><Label>Nom</Label><Input value={studentForm.last_name} onChange={(e) => setStudentForm((p) => ({ ...p, last_name: e.target.value }))} /></div>
            <p className="md:col-span-2 text-sm text-gray-500">
              Aucun compte élève ne sera créé, donc aucun email ni mot de passe n&apos;est requis.
            </p>
          </div>
          <DialogFooter>
            <Button variant="outline" onClick={() => setStudentOpen(false)}>Annuler</Button>
            <Button
              onClick={saveStudent}
              disabled={saving || !studentForm.first_name.trim() || !studentForm.last_name.trim()}
              className="bg-[#00A550] hover:bg-[#008040] text-white"
            >
              Enregistrer
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>
    </div>
  );
}
