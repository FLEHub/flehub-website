'use client';

import { useEffect, useState } from 'react';
import { createClient } from '@/lib/supabase/client';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Badge } from '@/components/ui/badge';
import { Skeleton } from '@/components/ui/skeleton';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import {
  Dialog,
  DialogContent,
  DialogHeader,
  DialogTitle,
  DialogFooter,
} from '@/components/ui/dialog';
import {
  Users,
  UserPlus,
  Search,
  GraduationCap,
  FileEdit,
  AlertTriangle,
} from 'lucide-react';
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from '@/components/ui/select';

type CEFR = 'A1' | 'A2' | 'B1' | 'B2' | 'C1' | 'C2';

interface Student {
  id: string;
  profile_id: string;
  full_name: string;
  email: string;
  cefr_level: CEFR | null;
  enrolled_at: string;
  last_exam_result: number | null;
  last_exam_passed: boolean | null;
}

const CEFR_COLORS: Record<CEFR, string> = {
  A1: 'bg-slate-100 text-slate-600',
  A2: 'bg-blue-50 text-blue-600',
  B1: 'bg-teal-50 text-teal-600',
  B2: 'bg-[#E6F5EE] text-[#00A550]',
  C1: 'bg-orange-50 text-orange-600',
  C2: 'bg-purple-50 text-purple-700',
};

const COMPETENCIES = ['EO', 'EE', 'CO', 'CE', 'EL'] as const;
type CompKey = (typeof COMPETENCIES)[number];

const emptyScores: Record<CompKey, string> = { EO: '', EE: '', CO: '', CE: '', EL: '' };

export default function SchoolStudentsPage() {
  const supabase = createClient();

  const [schoolId, setSchoolId] = useState<string | null>(null);
  const [students, setStudents] = useState<Student[]>([]);
  const [examSessions, setExamSessions] = useState<{ id: string; title: string; cefr_level: CEFR; exam_date: string }[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  // Enroll dialog
  const [enrollOpen, setEnrollOpen] = useState(false);
  const [enrollEmail, setEnrollEmail] = useState('');
  const [enrollResult, setEnrollResult] = useState<{ id: string; full_name: string } | null>(null);
  const [enrollSearching, setEnrollSearching] = useState(false);
  const [enrollSaving, setEnrollSaving] = useState(false);
  const [enrollError, setEnrollError] = useState('');

  // Results dialog
  const [resultsOpen, setResultsOpen] = useState(false);
  const [selectedStudentId, setSelectedStudentId] = useState('');
  const [selectedExamId, setSelectedExamId] = useState('');
  const [scores, setScores] = useState<Record<CompKey, string>>({ ...emptyScores });
  const [resultsSaving, setResultsSaving] = useState(false);

  useEffect(() => { fetchData(); }, []);

  async function fetchData() {
    setLoading(true);
    setError(null);
    try {
      const { data: { user } } = await supabase.auth.getUser();
      if (!user) return;

      const { data: school } = await supabase
        .from('schools').select('id').eq('profile_id', user.id).maybeSingle();
      if (!school) return;
      setSchoolId(school.id);

      const { data: enrollments } = await supabase
        .from('school_enrollments')
        .select('id, enrolled_at, learners(id, profile_id, cefr_level, profiles(full_name, email))')
        .eq('school_id', school.id)
        .order('enrolled_at', { ascending: false });

      const mapped: Student[] = await Promise.all(
        (enrollments ?? []).map(async (e: any) => {
          const learner = e.learners;
          const profile = learner?.profiles;
          const { data: lastResult } = await supabase
            .from('exam_results').select('total_score, passed')
            .eq('learner_id', learner?.id).order('created_at', { ascending: false })
            .limit(1).maybeSingle();
          return {
            id: learner?.id ?? e.id,
            profile_id: learner?.profile_id ?? '',
            full_name: profile?.full_name ?? 'Unknown',
            email: profile?.email ?? '',
            cefr_level: learner?.cefr_level ?? null,
            enrolled_at: e.enrolled_at,
            last_exam_result: lastResult?.total_score ?? null,
            last_exam_passed: lastResult?.passed ?? null,
          };
        })
      );
      setStudents(mapped);

      const { data: sessions } = await supabase
        .from('exam_sessions').select('id, title, cefr_level, exam_date')
        .order('exam_date', { ascending: false }).limit(20);
      setExamSessions(sessions ?? []);
    } catch {
      setError('Failed to load students. Please refresh.');
    } finally {
      setLoading(false);
    }
  }

  async function searchLearner() {
    if (!enrollEmail.trim()) return;
    setEnrollSearching(true);
    setEnrollError('');
    setEnrollResult(null);
    try {
      const { data: profile } = await supabase
        .from('profiles').select('id, full_name')
        .eq('email', enrollEmail.trim().toLowerCase()).maybeSingle();
      if (!profile) { setEnrollError('No learner found with this email.'); return; }
      setEnrollResult({ id: profile.id, full_name: profile.full_name });
    } finally {
      setEnrollSearching(false);
    }
  }

  async function handleEnroll() {
    if (!schoolId || !enrollResult) return;
    setEnrollSaving(true);
    try {
      const { data: learner } = await supabase
        .from('learners').select('id').eq('profile_id', enrollResult.id).maybeSingle();
      if (!learner?.id) { setEnrollError('Learner profile not fully set up.'); return; }
      await supabase.from('school_enrollments').upsert({
        school_id: schoolId, learner_id: learner.id, enrolled_at: new Date().toISOString(),
      });
      setEnrollOpen(false);
      setEnrollEmail('');
      setEnrollResult(null);
      await fetchData();
    } finally {
      setEnrollSaving(false);
    }
  }

  function totalScore() {
    return COMPETENCIES.reduce((sum, k) => sum + (parseFloat(scores[k]) || 0), 0);
  }

  async function handleSaveResults() {
    if (!selectedStudentId || !selectedExamId || !schoolId) return;
    setResultsSaving(true);
    try {
      const scorePayload: Record<string, number> = {};
      COMPETENCIES.forEach((k) => { scorePayload[`score_${k.toLowerCase()}`] = parseFloat(scores[k]) || 0; });
      const total = totalScore();
      const passed = total >= 60;
      const { data: inserted } = await supabase
        .from('exam_results')
        .insert({ learner_id: selectedStudentId, exam_session_id: selectedExamId, ...scorePayload, total_score: total, passed, school_id: schoolId })
        .select('id').maybeSingle();
      if (passed && inserted?.id) {
        const { data: session } = await supabase
          .from('exam_sessions').select('cefr_level').eq('id', selectedExamId).maybeSingle();
        await supabase.from('certificates').insert({
          learner_id: selectedStudentId, exam_result_id: inserted.id, school_id: schoolId,
          cefr_level: session?.cefr_level ?? 'A1',
          issue_date: new Date().toISOString().split('T')[0],
          issued_at: new Date().toISOString(),
          verification_code: Math.random().toString(36).substring(2, 10).toUpperCase(),
          certificate_number: `CERT-${Date.now().toString(36).toUpperCase()}`,
        });
      }
      setResultsOpen(false);
      setScores({ ...emptyScores });
      setSelectedStudentId('');
      setSelectedExamId('');
      await fetchData();
    } finally {
      setResultsSaving(false);
    }
  }

  return (
    <div className="p-6 space-y-6 max-w-7xl mx-auto">
      <div className="flex items-center justify-between gap-4">
        <div>
          <h1 className="text-2xl font-bold text-gray-900">Students</h1>
          <p className="text-sm text-gray-500 mt-1">Manage enrolled students and enter exam results.</p>
        </div>
        <div className="flex items-center gap-2">
          <Button variant="outline" size="sm" onClick={() => { setResultsOpen(true); setScores({ ...emptyScores }); setSelectedStudentId(''); setSelectedExamId(''); }}>
            <FileEdit className="w-4 h-4 mr-1.5" />
            Enter Results
          </Button>
          <Button size="sm" className="bg-[#00A550] hover:bg-[#008040] text-white"
            onClick={() => { setEnrollOpen(true); setEnrollEmail(''); setEnrollResult(null); setEnrollError(''); }}>
            <UserPlus className="w-4 h-4 mr-1.5" />
            Enroll Student
          </Button>
        </div>
      </div>

      {error && (
        <div className="flex items-center gap-2 rounded-lg bg-red-50 border border-red-200 px-4 py-3 text-sm text-red-700">
          <AlertTriangle className="w-4 h-4 flex-shrink-0" />
          {error}
        </div>
      )}

      <Card className="border-0 shadow-sm">
        <CardHeader className="pb-3">
          <div className="flex items-center gap-2">
            <div className="w-8 h-8 rounded-lg bg-[#E6F5EE] flex items-center justify-center">
              <Users className="w-4 h-4 text-[#00A550]" />
            </div>
            <CardTitle className="text-base font-semibold">
              Enrolled Students
              {!loading && <span className="ml-2 text-sm font-normal text-gray-400">({students.length})</span>}
            </CardTitle>
          </div>
        </CardHeader>
        <CardContent className="p-0">
          {loading ? (
            <div className="p-5 space-y-3">
              {Array.from({ length: 5 }).map((_, i) => <Skeleton key={i} className="h-10 w-full" />)}
            </div>
          ) : students.length === 0 ? (
            <div className="flex flex-col items-center py-16 text-gray-400">
              <div className="w-12 h-12 rounded-xl bg-[#E6F5EE] flex items-center justify-center mb-3">
                <GraduationCap className="w-6 h-6 text-[#00A550]" />
              </div>
              <p className="text-sm font-medium text-gray-700">No students enrolled yet</p>
              <p className="text-xs text-gray-400 mt-1">Use the button above to enroll a learner.</p>
            </div>
          ) : (
            <div className="overflow-x-auto">
              <table className="w-full text-sm">
                <thead>
                  <tr className="border-b border-gray-100">
                    {['Name', 'Email', 'Level', 'Enrolled', 'Last Result', 'Actions'].map((h) => (
                      <th key={h} className="text-left py-2.5 px-4 text-xs text-gray-500 font-medium">{h}</th>
                    ))}
                  </tr>
                </thead>
                <tbody>
                  {students.map((s) => (
                    <tr key={s.id} className="border-b border-gray-50 hover:bg-gray-50/60 transition-colors">
                      <td className="py-3 px-4 font-medium text-gray-900">{s.full_name}</td>
                      <td className="py-3 px-4 text-xs text-gray-500">{s.email}</td>
                      <td className="py-3 px-4">
                        {s.cefr_level ? (
                          <span className={`text-xs px-2.5 py-0.5 rounded font-bold ${CEFR_COLORS[s.cefr_level]}`}>
                            {s.cefr_level}
                          </span>
                        ) : <span className="text-gray-300 text-xs">—</span>}
                      </td>
                      <td className="py-3 px-4 text-xs text-gray-400">
                        {new Date(s.enrolled_at).toLocaleDateString('en-RW', { day: 'numeric', month: 'short', year: 'numeric' })}
                      </td>
                      <td className="py-3 px-4">
                        {s.last_exam_result !== null ? (
                          <div className="flex items-center gap-1.5">
                            <span className="font-semibold text-gray-900">{s.last_exam_result}/100</span>
                            <span className={`text-xs px-2 py-0.5 rounded-full font-medium ${s.last_exam_passed ? 'bg-[#E6F5EE] text-[#00A550]' : 'bg-red-50 text-red-600'}`}>
                              {s.last_exam_passed ? 'Pass' : 'Fail'}
                            </span>
                          </div>
                        ) : <span className="text-xs text-gray-300">No result</span>}
                      </td>
                      <td className="py-3 px-4">
                        <Button variant="ghost" size="sm" className="h-7 text-xs text-[#00A550] hover:bg-[#E6F5EE]"
                          onClick={() => { setSelectedStudentId(s.id); setScores({ ...emptyScores }); setSelectedExamId(''); setResultsOpen(true); }}>
                          <FileEdit className="w-3.5 h-3.5 mr-1" />
                          Results
                        </Button>
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          )}
        </CardContent>
      </Card>

      {/* Enroll Dialog */}
      <Dialog open={enrollOpen} onOpenChange={setEnrollOpen}>
        <DialogContent className="max-w-sm">
          <DialogHeader><DialogTitle>Enroll Student</DialogTitle></DialogHeader>
          <div className="space-y-4 py-2">
            <p className="text-sm text-gray-500">Search for an existing learner by email to link them to your school.</p>
            <div className="space-y-1.5">
              <Label>Learner Email</Label>
              <div className="flex gap-2">
                <Input type="email" placeholder="learner@example.com" value={enrollEmail}
                  onChange={(e) => setEnrollEmail(e.target.value)}
                  onKeyDown={(e) => e.key === 'Enter' && searchLearner()}
                  className="border-gray-200 focus:border-[#00A550]" />
                <Button variant="outline" onClick={searchLearner} disabled={enrollSearching || !enrollEmail.trim()}>
                  <Search className="w-4 h-4" />
                </Button>
              </div>
            </div>
            {enrollError && <p className="text-sm text-red-500">{enrollError}</p>}
            {enrollResult && (
              <div className="flex items-center gap-2 p-3 bg-[#E6F5EE] rounded-lg">
                <GraduationCap className="w-5 h-5 text-[#00A550]" />
                <div>
                  <p className="text-sm font-medium text-[#00A550]">{enrollResult.full_name}</p>
                  <p className="text-xs text-gray-500">{enrollEmail}</p>
                </div>
              </div>
            )}
          </div>
          <DialogFooter>
            <Button variant="outline" onClick={() => setEnrollOpen(false)}>Cancel</Button>
            <Button className="bg-[#00A550] hover:bg-[#008040] text-white" onClick={handleEnroll} disabled={!enrollResult || enrollSaving}>
              {enrollSaving ? 'Enrolling…' : 'Enroll Student'}
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>

      {/* Results Dialog */}
      <Dialog open={resultsOpen} onOpenChange={setResultsOpen}>
        <DialogContent className="max-w-md">
          <DialogHeader><DialogTitle>Enter Exam Results</DialogTitle></DialogHeader>
          <div className="space-y-4 py-2">
            <div className="space-y-1.5">
              <Label>Student <span className="text-red-500">*</span></Label>
              <Select value={selectedStudentId} onValueChange={setSelectedStudentId}>
                <SelectTrigger className="border-gray-200"><SelectValue placeholder="Select student" /></SelectTrigger>
                <SelectContent>
                  {students.map((s) => <SelectItem key={s.id} value={s.id}>{s.full_name}</SelectItem>)}
                </SelectContent>
              </Select>
            </div>
            <div className="space-y-1.5">
              <Label>Exam Session <span className="text-red-500">*</span></Label>
              <Select value={selectedExamId} onValueChange={setSelectedExamId}>
                <SelectTrigger className="border-gray-200"><SelectValue placeholder="Select exam session" /></SelectTrigger>
                <SelectContent>
                  {examSessions.map((ex) => (
                    <SelectItem key={ex.id} value={ex.id}>
                      {ex.title} — {ex.cefr_level} ({new Date(ex.exam_date).toLocaleDateString('en-RW')})
                    </SelectItem>
                  ))}
                </SelectContent>
              </Select>
            </div>
            <div className="border-t border-gray-100 pt-3">
              <p className="text-sm font-medium text-gray-700 mb-3">Competency Scores (0–20 each)</p>
              <div className="grid grid-cols-5 gap-2">
                {COMPETENCIES.map((comp) => (
                  <div key={comp} className="space-y-1">
                    <Label className="text-xs font-semibold text-gray-600">{comp}</Label>
                    <Input type="number" min={0} max={20} placeholder="0" value={scores[comp]}
                      onChange={(e) => setScores({ ...scores, [comp]: e.target.value })}
                      className="text-center px-1 border-gray-200" />
                  </div>
                ))}
              </div>
              <div className="flex items-center justify-between mt-3 pt-3 border-t border-gray-100">
                <span className="text-sm text-gray-600">Total Score</span>
                <div className="flex items-center gap-2">
                  <span className="text-lg font-bold">{totalScore()}/100</span>
                  <span className={`text-xs px-2.5 py-0.5 rounded-full font-medium ${totalScore() >= 60 ? 'bg-[#E6F5EE] text-[#00A550]' : 'bg-red-50 text-red-600'}`}>
                    {totalScore() >= 60 ? 'Pass' : 'Fail'}
                  </span>
                </div>
              </div>
              <p className="text-xs text-gray-400 mt-1.5">Pass threshold: 60/100. Certificates auto-issued for passing students.</p>
            </div>
          </div>
          <DialogFooter>
            <Button variant="outline" onClick={() => setResultsOpen(false)}>Cancel</Button>
            <Button className="bg-[#00A550] hover:bg-[#008040] text-white" onClick={handleSaveResults}
              disabled={resultsSaving || !selectedStudentId || !selectedExamId}>
              {resultsSaving ? 'Saving…' : 'Save Results'}
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>
    </div>
  );
}
