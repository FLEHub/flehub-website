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
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from '@/components/ui/select';
import {
  Users,
  ClipboardList,
  Award,
  Clock,
  Search,
  UserPlus,
  FileEdit,
  Download,
  GraduationCap,
} from 'lucide-react';

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
  certificate_id: string | null;
}

interface ExamSession {
  id: string;
  title: string;
  cefr_level: CEFR;
  exam_date: string;
}

interface SchoolStats {
  totalStudents: number;
  examRegistrations: number;
  certificatesIssued: number;
  pendingResults: number;
}

const COMPETENCIES = ['EO', 'EE', 'CO', 'CE', 'EL'] as const;
type CompKey = (typeof COMPETENCIES)[number];

const emptyScores: Record<CompKey, string> = {
  EO: '',
  EE: '',
  CO: '',
  CE: '',
  EL: '',
};

export default function SchoolDashboard() {
  const supabase = createClient();

  const [schoolId, setSchoolId] = useState<string | null>(null);
  const [stats, setStats] = useState<SchoolStats | null>(null);
  const [students, setStudents] = useState<Student[]>([]);
  const [examSessions, setExamSessions] = useState<ExamSession[]>([]);
  const [loading, setLoading] = useState(true);
  const [fetchError, setFetchError] = useState<string | null>(null);
  const [profileSetupMissing, setProfileSetupMissing] = useState(false);

  // Enroll dialog
  const [enrollOpen, setEnrollOpen] = useState(false);
  const [enrollEmail, setEnrollEmail] = useState('');
  const [enrollResult, setEnrollResult] = useState<{ id: string; full_name: string } | null>(null);
  const [enrollSearching, setEnrollSearching] = useState(false);
  const [enrollSaving, setEnrollSaving] = useState(false);
  const [enrollError, setEnrollError] = useState('');

  // Exam results dialog
  const [resultsOpen, setResultsOpen] = useState(false);
  const [selectedStudentId, setSelectedStudentId] = useState('');
  const [selectedExamId, setSelectedExamId] = useState('');
  const [scores, setScores] = useState<Record<CompKey, string>>({ ...emptyScores });
  const [resultsSaving, setResultsSaving] = useState(false);

  useEffect(() => {
    fetchData();
  }, []);

  async function fetchData() {
    setFetchError(null);
    setProfileSetupMissing(false);

    try {
      const {
        data: { user },
      } = await supabase.auth.getUser();
      if (!user) {
        setFetchError('You must be signed in to view this dashboard.');
        return;
      }

      const { data: school, error: schoolError } = await supabase
        .from('schools')
        .select('*')
        .eq('profile_id', user.id)
        .maybeSingle();

      if (schoolError) {
        setFetchError(`Failed to load school profile: ${schoolError.message}`);
        return;
      }

      if (!school) {
        setProfileSetupMissing(true);
        return;
      }

      setSchoolId(school.id);

      const { data: enrollments, error: enrollmentsError } = await supabase
        .from('school_enrollments')
        .select(
          `
          id,
          enrolled_at,
          learners (
            id,
            profile_id,
            cefr_level,
            profiles (full_name, email)
          )
        `
        )
        .eq('school_id', school.id)
        .order('enrolled_at', { ascending: false });

      if (enrollmentsError) {
        setFetchError(`Failed to load enrolled students: ${enrollmentsError.message}`);
        return;
      }

      const studentsMapped: Student[] = await Promise.all(
        (enrollments ?? []).map(async (e: any) => {
          const learner = e.learners;
          const profile = learner?.profiles;

          // Get last exam result
          const { data: lastResult } = await supabase
            .from('exam_results')
            .select('total_score, passed, certificate_id')
            .eq('learner_id', learner?.id)
            .order('created_at', { ascending: false })
            .limit(1)
            .maybeSingle();

          return {
            id: learner?.id ?? e.id,
            profile_id: learner?.profile_id ?? '',
            full_name: profile?.full_name ?? 'Unknown',
            email: profile?.email ?? '',
            cefr_level: learner?.cefr_level ?? null,
            enrolled_at: e.enrolled_at,
            last_exam_result: lastResult?.total_score ?? null,
            last_exam_passed: lastResult?.passed ?? null,
            certificate_id: lastResult?.certificate_id ?? null,
          };
        })
      );

      setStudents(studentsMapped);

      const learnerIds = studentsMapped.map((s) => s.id).filter(Boolean);
      let regCount = 0;
      let pendingCount = 0;

      if (learnerIds.length > 0) {
        const { count, error: regError } = await supabase
          .from('exam_registrations')
          .select('*', { count: 'exact', head: true })
          .in('learner_id', learnerIds);

        if (regError) {
          setFetchError(`Failed to load exam registrations: ${regError.message}`);
          return;
        }

        regCount = count ?? 0;

        const { data: registrations, error: pendingError } = await supabase
          .from('exam_registrations')
          .select('id, learner_id, exam_session_id')
          .in('learner_id', learnerIds);

        if (pendingError) {
          setFetchError(`Failed to load pending results: ${pendingError.message}`);
          return;
        }

        const { data: results } = await supabase
          .from('exam_results')
          .select('learner_id, exam_session_id')
          .in('learner_id', learnerIds);

        const resultKeys = new Set(
          (results ?? []).map((r) => `${r.learner_id}:${r.exam_session_id}`)
        );

        pendingCount = (registrations ?? []).filter(
          (r) => !resultKeys.has(`${r.learner_id}:${r.exam_session_id}`)
        ).length;
      }

      const { count: certCount, error: certError } = await supabase
        .from('certificates')
        .select('*', { count: 'exact', head: true })
        .eq('school_id', school.id);

      if (certError) {
        setFetchError(`Failed to load certificates: ${certError.message}`);
        return;
      }

      setStats({
        totalStudents: studentsMapped.length,
        examRegistrations: regCount,
        certificatesIssued: certCount ?? 0,
        pendingResults: pendingCount,
      });

      const { data: exSessions, error: sessionsError } = await supabase
        .from('exam_sessions')
        .select('id, title, cefr_level, exam_date')
        .order('exam_date', { ascending: false })
        .limit(20);

      if (sessionsError) {
        setFetchError(`Failed to load exam sessions: ${sessionsError.message}`);
        return;
      }

      setExamSessions(exSessions ?? []);
    } catch (err) {
      console.error(err);
      setFetchError('An unexpected error occurred while loading the dashboard.');
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
        .from('profiles')
        .select('id, full_name')
        .eq('email', enrollEmail.trim().toLowerCase())
        .maybeSingle();

      if (!profile) {
        setEnrollError('No learner found with this email.');
        return;
      }
      setEnrollResult({ id: profile.id, full_name: profile.full_name });
    } finally {
      setEnrollSearching(false);
    }
  }

  async function handleEnroll() {
    if (!schoolId || !enrollResult) return;
    setEnrollSaving(true);
    try {
      // Get or create learner record
      const { data: learner } = await supabase
        .from('learners')
        .select('id')
        .eq('profile_id', enrollResult.id)
        .maybeSingle();

      const learnerId = learner?.id;
      if (!learnerId) {
        setEnrollError('Learner profile not fully set up.');
        return;
      }

      await supabase.from('school_enrollments').upsert({
        school_id: schoolId,
        learner_id: learnerId,
        enrolled_at: new Date().toISOString(),
      });

      setEnrollOpen(false);
      setEnrollEmail('');
      setEnrollResult(null);
      await fetchData();
    } catch (err) {
      console.error(err);
    } finally {
      setEnrollSaving(false);
    }
  }

  function totalScore() {
    return COMPETENCIES.reduce((sum, k) => sum + (parseFloat(scores[k]) || 0), 0);
  }

  function isPassed() {
    return totalScore() >= 60;
  }

  async function handleSaveResults() {
    if (!selectedStudentId || !selectedExamId) return;
    setResultsSaving(true);
    try {
      const scorePayload: Record<string, number> = {};
      COMPETENCIES.forEach((k) => {
        scorePayload[`score_${k.toLowerCase()}`] = parseFloat(scores[k]) || 0;
      });

      const total = totalScore();
      const passed = total >= 60;

      const { data: inserted } = await supabase
        .from('exam_results')
        .insert({
          learner_id: selectedStudentId,
          exam_session_id: selectedExamId,
          ...scorePayload,
          total_score: total,
          passed,
          school_id: schoolId,
        })
        .select('id')
        .maybeSingle();

      if (passed && inserted?.id) {
        // Create certificate
        const { data: examSession } = await supabase
          .from('exam_sessions')
          .select('cefr_level')
          .eq('id', selectedExamId)
          .maybeSingle();

        await supabase.from('certificates').insert({
          learner_id: selectedStudentId,
          exam_result_id: inserted.id,
          school_id: schoolId,
          cefr_level: examSession?.cefr_level ?? 'A1',
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
    } catch (err) {
      console.error(err);
    } finally {
      setResultsSaving(false);
    }
  }

  const statCards = [
    {
      title: 'Total Enrolled Students',
      value: stats?.totalStudents ?? 0,
      icon: Users,
      color: 'text-flehub-green',
      bg: 'bg-flehub-green-light',
    },
    {
      title: 'Exam Registrations',
      value: stats?.examRegistrations ?? 0,
      icon: ClipboardList,
      color: 'text-blue-600',
      bg: 'bg-blue-50',
    },
    {
      title: 'Certificates Issued',
      value: stats?.certificatesIssued ?? 0,
      icon: Award,
      color: 'text-amber-600',
      bg: 'bg-amber-50',
    },
    {
      title: 'Pending Results',
      value: stats?.pendingResults ?? 0,
      icon: Clock,
      color: 'text-rose-600',
      bg: 'bg-rose-50',
    },
  ];

  return (
    <div className="p-6 space-y-8 max-w-7xl mx-auto">
      {/* Header */}
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-2xl font-bold text-gray-900">School Dashboard</h1>
          <p className="text-gray-500 text-sm mt-1">Manage students, exams, and certificates</p>
        </div>
        <div className="flex gap-2">
          <Button
            variant="outline"
            size="sm"
            onClick={() => {
              setResultsOpen(true);
              setScores({ ...emptyScores });
              setSelectedStudentId('');
              setSelectedExamId('');
            }}
          >
            <FileEdit className="w-4 h-4 mr-1" />
            Enter Exam Results
          </Button>
          <Button
            size="sm"
            className="bg-flehub-green hover:bg-flehub-green/90 text-white"
            onClick={() => {
              setEnrollOpen(true);
              setEnrollEmail('');
              setEnrollResult(null);
              setEnrollError('');
            }}
          >
            <UserPlus className="w-4 h-4 mr-1" />
            Enroll Student
          </Button>
        </div>
      </div>

      {fetchError && (
        <div className="rounded-lg border border-red-200 bg-red-50 px-4 py-3 text-sm text-red-700">
          {fetchError}
        </div>
      )}

      {profileSetupMissing && (
        <div className="rounded-lg border border-amber-200 bg-amber-50 px-4 py-3 text-sm text-amber-800">
          Your school profile is not set up yet. Please contact an administrator or complete registration.
        </div>
      )}

      {/* Stat Cards */}
      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
        {statCards.map((card) => (
          <Card key={card.title}>
            <CardContent className="pt-6">
              {loading ? (
                <div className="space-y-2">
                  <Skeleton className="h-8 w-16" />
                  <Skeleton className="h-4 w-32" />
                </div>
              ) : (
                <div className="flex items-center justify-between">
                  <div>
                    <p className="text-3xl font-bold text-gray-900">{card.value}</p>
                    <p className="text-sm text-gray-500 mt-1">{card.title}</p>
                  </div>
                  <div className={`p-3 rounded-full ${card.bg}`}>
                    <card.icon className={`w-6 h-6 ${card.color}`} />
                  </div>
                </div>
              )}
            </CardContent>
          </Card>
        ))}
      </div>

      {/* Student List */}
      <Card>
        <CardHeader>
          <CardTitle className="text-base font-semibold">Enrolled Students</CardTitle>
        </CardHeader>
        <CardContent>
          {loading ? (
            <div className="space-y-3">
              {Array.from({ length: 5 }).map((_, i) => (
                <Skeleton key={i} className="h-10 w-full" />
              ))}
            </div>
          ) : students.length === 0 ? (
            <div className="flex flex-col items-center py-12 text-gray-400">
              <GraduationCap className="w-10 h-10 mb-2 opacity-40" />
              <p>No students enrolled yet</p>
            </div>
          ) : (
            <div className="overflow-x-auto">
              <table className="w-full text-sm">
                <thead>
                  <tr className="border-b border-gray-100">
                    <th className="text-left py-2 pr-4 text-gray-500 font-medium">Name</th>
                    <th className="text-left py-2 pr-4 text-gray-500 font-medium">Email</th>
                    <th className="text-left py-2 pr-4 text-gray-500 font-medium">Level</th>
                    <th className="text-left py-2 pr-4 text-gray-500 font-medium">Enrolled</th>
                    <th className="text-left py-2 pr-4 text-gray-500 font-medium">Last Result</th>
                    <th className="text-left py-2 text-gray-500 font-medium">Actions</th>
                  </tr>
                </thead>
                <tbody>
                  {students.map((s) => (
                    <tr key={s.id} className="border-b border-gray-50 hover:bg-gray-50">
                      <td className="py-2.5 pr-4 font-medium text-gray-900">{s.full_name}</td>
                      <td className="py-2.5 pr-4 text-gray-500 text-xs">{s.email}</td>
                      <td className="py-2.5 pr-4">
                        {s.cefr_level ? (
                          <Badge variant="secondary" className="text-xs">
                            {s.cefr_level}
                          </Badge>
                        ) : (
                          <span className="text-gray-300 text-xs">—</span>
                        )}
                      </td>
                      <td className="py-2.5 pr-4 text-xs text-gray-400">
                        {new Date(s.enrolled_at).toLocaleDateString('en-RW')}
                      </td>
                      <td className="py-2.5 pr-4">
                        {s.last_exam_result !== null ? (
                          <div className="flex items-center gap-1.5">
                            <span className="font-medium">{s.last_exam_result}/100</span>
                            <Badge
                              variant="secondary"
                              className={`text-xs ${
                                s.last_exam_passed
                                  ? 'bg-flehub-green-light text-flehub-green'
                                  : 'bg-red-100 text-red-600'
                              }`}
                            >
                              {s.last_exam_passed ? 'Pass' : 'Fail'}
                            </Badge>
                          </div>
                        ) : (
                          <span className="text-gray-300 text-xs">No result</span>
                        )}
                      </td>
                      <td className="py-2.5">
                        <div className="flex gap-1">
                          <Button
                            variant="ghost"
                            size="sm"
                            className="text-xs text-flehub-green hover:bg-flehub-green-light h-7"
                            onClick={() => {
                              setSelectedStudentId(s.id);
                              setScores({ ...emptyScores });
                              setSelectedExamId('');
                              setResultsOpen(true);
                            }}
                          >
                            <FileEdit className="w-3.5 h-3.5 mr-1" />
                            Results
                          </Button>
                          {s.last_exam_passed && s.certificate_id && (
                            <Button
                              variant="ghost"
                              size="sm"
                              className="text-xs text-amber-600 hover:bg-amber-50 h-7"
                              onClick={() => alert('PDF download coming soon')}
                            >
                              <Download className="w-3.5 h-3.5 mr-1" />
                              Certificate
                            </Button>
                          )}
                        </div>
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          )}
        </CardContent>
      </Card>

      {/* Enroll Student Dialog */}
      <Dialog open={enrollOpen} onOpenChange={setEnrollOpen}>
        <DialogContent className="max-w-sm">
          <DialogHeader>
            <DialogTitle>Enroll Student</DialogTitle>
          </DialogHeader>
          <div className="space-y-4 py-2">
            <p className="text-sm text-gray-500">
              Search for an existing learner profile by email address to link them to your school.
            </p>
            <div className="space-y-1">
              <Label>Learner Email</Label>
              <div className="flex gap-2">
                <Input
                  type="email"
                  placeholder="learner@example.com"
                  value={enrollEmail}
                  onChange={(e) => setEnrollEmail(e.target.value)}
                  onKeyDown={(e) => e.key === 'Enter' && searchLearner()}
                />
                <Button
                  variant="outline"
                  onClick={searchLearner}
                  disabled={enrollSearching || !enrollEmail.trim()}
                >
                  <Search className="w-4 h-4" />
                </Button>
              </div>
            </div>
            {enrollError && <p className="text-sm text-red-500">{enrollError}</p>}
            {enrollResult && (
              <div className="flex items-center gap-2 p-3 bg-flehub-green-light rounded-lg">
                <GraduationCap className="w-5 h-5 text-flehub-green" />
                <div>
                  <p className="text-sm font-medium text-flehub-green">{enrollResult.full_name}</p>
                  <p className="text-xs text-gray-500">{enrollEmail}</p>
                </div>
              </div>
            )}
          </div>
          <DialogFooter>
            <Button variant="outline" onClick={() => setEnrollOpen(false)}>
              Cancel
            </Button>
            <Button
              className="bg-flehub-green hover:bg-flehub-green/90 text-white"
              onClick={handleEnroll}
              disabled={!enrollResult || enrollSaving}
            >
              {enrollSaving ? 'Enrolling...' : 'Enroll Student'}
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>

      {/* Enter Exam Results Dialog */}
      <Dialog open={resultsOpen} onOpenChange={setResultsOpen}>
        <DialogContent className="max-w-md">
          <DialogHeader>
            <DialogTitle>Enter Exam Results</DialogTitle>
          </DialogHeader>
          <div className="space-y-4 py-2">
            <div className="space-y-1">
              <Label>Student <span className="text-red-500">*</span></Label>
              <Select value={selectedStudentId} onValueChange={setSelectedStudentId}>
                <SelectTrigger>
                  <SelectValue placeholder="Select student" />
                </SelectTrigger>
                <SelectContent>
                  {students.map((s) => (
                    <SelectItem key={s.id} value={s.id}>
                      {s.full_name}
                    </SelectItem>
                  ))}
                </SelectContent>
              </Select>
            </div>

            <div className="space-y-1">
              <Label>Exam Session <span className="text-red-500">*</span></Label>
              <Select value={selectedExamId} onValueChange={setSelectedExamId}>
                <SelectTrigger>
                  <SelectValue placeholder="Select exam session" />
                </SelectTrigger>
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
              <p className="text-sm font-medium text-gray-700 mb-3">
                Competency Scores (0–20 each, total /100)
              </p>
              <div className="grid grid-cols-5 gap-2">
                {COMPETENCIES.map((comp) => (
                  <div key={comp} className="space-y-1">
                    <Label className="text-xs font-semibold text-gray-600">{comp}</Label>
                    <Input
                      type="number"
                      min={0}
                      max={20}
                      placeholder="0"
                      value={scores[comp]}
                      onChange={(e) =>
                        setScores({ ...scores, [comp]: e.target.value })
                      }
                      className="text-center px-1"
                    />
                  </div>
                ))}
              </div>
              <div className="flex items-center justify-between mt-3 pt-3 border-t border-gray-100">
                <span className="text-sm text-gray-600">Total Score</span>
                <div className="flex items-center gap-2">
                  <span className="text-lg font-bold">{totalScore()}/100</span>
                  <Badge
                    variant="secondary"
                    className={`${
                      isPassed()
                        ? 'bg-flehub-green-light text-flehub-green'
                        : 'bg-red-100 text-red-600'
                    }`}
                  >
                    {isPassed() ? 'Pass' : 'Fail'}
                  </Badge>
                </div>
              </div>
              <p className="text-xs text-gray-400 mt-1">
                Pass threshold: 60/100 (60%). Certificates issued automatically for passing students.
              </p>
            </div>
          </div>
          <DialogFooter>
            <Button variant="outline" onClick={() => setResultsOpen(false)}>
              Cancel
            </Button>
            <Button
              className="bg-flehub-green hover:bg-flehub-green/90 text-white"
              onClick={handleSaveResults}
              disabled={resultsSaving || !selectedStudentId || !selectedExamId}
            >
              {resultsSaving ? 'Saving...' : 'Save Results'}
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>
    </div>
  );
}
