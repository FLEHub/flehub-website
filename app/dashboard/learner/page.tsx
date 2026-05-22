'use client';

export const dynamic = 'force-dynamic';

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
  BookOpen,
  CheckCircle2,
  ClipboardList,
  Award,
  Play,
  Calendar,
  Download,
  Phone,
  Smartphone,
  ArrowRight,
} from 'lucide-react';

type CEFR = 'A1' | 'A2' | 'B1' | 'B2' | 'C1' | 'C2';
type Competency = 'EO' | 'EE' | 'CO' | 'CE' | 'EL';

const competencyLabels: Record<Competency, string> = {
  EO: 'Expression Orale',
  EE: 'Expression Ecrite',
  CO: 'Compréhension Orale',
  CE: 'Compréhension Ecrite',
  EL: 'Eléments Linguistiques',
};

interface LearnerStats {
  coursesInProgress: number;
  exercisesCompleted: number;
  examsTaken: number;
  certificates: number;
}

interface CourseCard {
  id: string;
  title: string;
  cefr_level: CEFR;
  competency: Competency;
  content_type: string;
  duration_minutes: number;
  progress_percent: number;
}

interface ExamSession {
  id: string;
  title: string;
  cefr_level: CEFR;
  exam_date: string;
  registration_deadline: string;
  venue: string;
  price_rwf: number;
}

interface CompetencyProgress {
  competency: Competency;
  average_score: number;
  attempts: number;
}

interface Certificate {
  id: string;
  cefr_level: CEFR;
  issued_at: string;
  certificate_number: string;
  verification_code: string;
}

const cefrColors: Record<CEFR, string> = {
  A1: 'bg-green-100 text-green-700',
  A2: 'bg-lime-100 text-lime-700',
  B1: 'bg-yellow-100 text-yellow-700',
  B2: 'bg-orange-100 text-orange-700',
  C1: 'bg-red-100 text-red-700',
  C2: 'bg-rose-100 text-rose-700',
};

export default function LearnerDashboard() {
  const supabase = createClient();

  const [learnerId, setLearnerId] = useState<string | null>(null);
  const [cefrLevel, setCefrLevel] = useState<CEFR | null>(null);
  const [fullName, setFullName] = useState('');
  const [stats, setStats] = useState<LearnerStats | null>(null);
  const [courses, setCourses] = useState<CourseCard[]>([]);
  const [upcomingExams, setUpcomingExams] = useState<ExamSession[]>([]);
  const [competencyProgress, setCompetencyProgress] = useState<CompetencyProgress[]>([]);
  const [certificates, setCertificates] = useState<Certificate[]>([]);
  const [loading, setLoading] = useState(true);

  // Payment modal
  const [payModalOpen, setPayModalOpen] = useState(false);
  const [payExam, setPayExam] = useState<ExamSession | null>(null);
  const [payMethod, setPayMethod] = useState<'mtn' | 'airtel' | null>(null);
  const [payPhone, setPayPhone] = useState('');
  const [payProcessing, setPayProcessing] = useState(false);

  useEffect(() => {
    fetchData();
  }, []);

  async function fetchData() {
    try {
      const {
        data: { user },
      } = await supabase.auth.getUser();
      if (!user) return;

      const { data: profile } = await supabase
        .from('profiles')
        .select('full_name')
        .eq('id', user.id)
        .maybeSingle();

      setFullName(profile?.full_name ?? '');

      const { data: learner } = await supabase
        .from('learners')
        .select('id, cefr_level')
        .eq('profile_id', user.id)
        .maybeSingle();

      if (!learner) return;
      setLearnerId(learner.id);
      setCefrLevel(learner.cefr_level);

      // Fetch courses assigned (published courses matching learner's level)
      const { data: coursesData } = await supabase
        .from('courses')
        .select('id, title, cefr_level, competency, content_type, duration_minutes')
        .eq('is_published', true)
        .eq('cefr_level', learner.cefr_level ?? 'A1')
        .limit(6);

      // Get progress for each course
      const coursesWithProgress: CourseCard[] = await Promise.all(
        (coursesData ?? []).map(async (c: any) => {
          const { data: prog } = await supabase
            .from('learner_progress')
            .select('progress_percent')
            .eq('learner_id', learner.id)
            .eq('course_id', c.id)
            .maybeSingle();
          return { ...c, progress_percent: prog?.progress_percent ?? 0 };
        })
      );
      setCourses(coursesWithProgress);

      // Stats
      const { count: inProgressCount } = await supabase
        .from('learner_progress')
        .select('*', { count: 'exact', head: true })
        .eq('learner_id', learner.id)
        .lt('progress_percent', 100);

      const { count: exCompleted } = await supabase
        .from('learner_exercise_attempts')
        .select('*', { count: 'exact', head: true })
        .eq('learner_id', learner.id);

      const { count: examsTaken } = await supabase
        .from('exam_results')
        .select('*', { count: 'exact', head: true })
        .eq('learner_id', learner.id);

      const { count: certCount } = await supabase
        .from('certificates')
        .select('*', { count: 'exact', head: true })
        .eq('learner_id', learner.id);

      setStats({
        coursesInProgress: inProgressCount ?? 0,
        exercisesCompleted: exCompleted ?? 0,
        examsTaken: examsTaken ?? 0,
        certificates: certCount ?? 0,
      });

      // Upcoming exam sessions
      const now = new Date().toISOString();
      const { data: examData } = await supabase
        .from('exam_sessions')
        .select('id, title, cefr_level, exam_date, registration_deadline, venue, price_rwf')
        .gte('exam_date', now)
        .order('exam_date', { ascending: true })
        .limit(4);

      setUpcomingExams(examData ?? []);

      // Competency progress (from exercise attempts)
      const comps: Competency[] = ['EO', 'EE', 'CO', 'CE', 'EL'];
      const progData: CompetencyProgress[] = await Promise.all(
        comps.map(async (comp) => {
          const { data: attempts } = await supabase
            .from('learner_exercise_attempts')
            .select('score')
            .eq('learner_id', learner.id)
            .eq('competency', comp);

          const scores = (attempts ?? []).map((a: any) => a.score ?? 0);
          const avg = scores.length > 0 ? scores.reduce((a: number, b: number) => a + b, 0) / scores.length : 0;
          return { competency: comp, average_score: Math.round(avg), attempts: scores.length };
        })
      );
      setCompetencyProgress(progData);

      // Certificates
      const { data: certsData } = await supabase
        .from('certificates')
        .select('id, issued_at, verification_code, certificate_number, cefr_level')
        .eq('learner_id', learner.id)
        .order('issued_at', { ascending: false });

      const certsMapped: Certificate[] = (certsData ?? []).map((c: any) => ({
        id: c.id,
        cefr_level: c.cefr_level ?? 'A1',
        issued_at: c.issued_at,
        certificate_number: c.certificate_number ?? c.id.slice(0, 8).toUpperCase(),
        verification_code: c.verification_code ?? '',
      }));
      setCertificates(certsMapped);
    } catch (err) {
      console.error(err);
    } finally {
      setLoading(false);
    }
  }

  async function handlePayment() {
    if (!payExam || !learnerId || !payPhone) return;
    setPayProcessing(true);
    try {
      // Simulate payment: insert payment with status completed
      const { data: payment } = await supabase
        .from('payments')
        .insert({
          learner_id: learnerId,
          amount_rwf: payExam.price_rwf,
          currency: 'RWF',
          payment_method: payMethod === 'mtn' ? 'mtn_momo' : 'airtel_money',
          phone_number: payPhone,
          status: 'completed',
          payment_type: 'exam_registration',
          reference_id: payExam.id,
        })
        .select('id')
        .maybeSingle();

      if (payment?.id) {
        await supabase.from('exam_registrations').insert({
          learner_id: learnerId,
          exam_session_id: payExam.id,
          payment_id: payment.id,
          payment_status: 'paid',
          status: 'registered',
          registered_at: new Date().toISOString(),
        });
      }

      setPayModalOpen(false);
      setPayExam(null);
      setPayPhone('');
      setPayMethod(null);
      await fetchData();
      alert('Payment successful! You are now registered for the exam.');
    } catch (err) {
      console.error(err);
    } finally {
      setPayProcessing(false);
    }
  }

  const statCards = [
    { title: 'Courses In Progress', value: stats?.coursesInProgress ?? 0, icon: BookOpen, color: 'text-flehub-green', bg: 'bg-flehub-green-light' },
    { title: 'Exercises Completed', value: stats?.exercisesCompleted ?? 0, icon: CheckCircle2, color: 'text-blue-600', bg: 'bg-blue-50' },
    { title: 'Exams Taken', value: stats?.examsTaken ?? 0, icon: ClipboardList, color: 'text-orange-600', bg: 'bg-orange-50' },
    { title: 'Certificates', value: stats?.certificates ?? 0, icon: Award, color: 'text-amber-600', bg: 'bg-amber-50' },
  ];

  return (
    <div className="p-6 space-y-8 max-w-7xl mx-auto">
      {/* Welcome Header */}
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-3">
        <div>
          <h1 className="text-2xl font-bold text-gray-900">
            Welcome back{fullName ? `, ${fullName.split(' ')[0]}` : ''}!
          </h1>
          <div className="flex items-center gap-2 mt-1">
            <span className="text-gray-500 text-sm">Your level:</span>
            {loading ? (
              <Skeleton className="h-6 w-10" />
            ) : cefrLevel ? (
              <Badge className={`text-sm font-bold px-3 py-1 ${cefrColors[cefrLevel]}`}>
                {cefrLevel}
              </Badge>
            ) : (
              <Badge variant="outline" className="text-gray-400">Not set</Badge>
            )}
          </div>
        </div>
        <Button
          className="bg-flehub-green hover:bg-flehub-green/90 text-white self-start sm:self-auto"
          onClick={() => (window.location.href = '/dashboard/learner/exams')}
        >
          <Calendar className="w-4 h-4 mr-2" />
          Register for Next Exam
        </Button>
      </div>

      {/* Stat Cards */}
      <div className="grid grid-cols-2 lg:grid-cols-4 gap-4">
        {statCards.map((card) => (
          <Card key={card.title}>
            <CardContent className="pt-5 pb-4">
              {loading ? (
                <div className="space-y-2">
                  <Skeleton className="h-8 w-10" />
                  <Skeleton className="h-4 w-24" />
                </div>
              ) : (
                <div className="flex items-center justify-between">
                  <div>
                    <p className="text-2xl font-bold text-gray-900">{card.value}</p>
                    <p className="text-xs text-gray-500 mt-0.5 leading-tight">{card.title}</p>
                  </div>
                  <div className={`p-2.5 rounded-full ${card.bg}`}>
                    <card.icon className={`w-5 h-5 ${card.color}`} />
                  </div>
                </div>
              )}
            </CardContent>
          </Card>
        ))}
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        {/* Available Courses */}
        <Card className="lg:col-span-2">
          <CardHeader className="flex flex-row items-center justify-between pb-2">
            <CardTitle className="text-base font-semibold">Available Courses</CardTitle>
            <Button
              variant="ghost"
              size="sm"
              className="text-flehub-green text-xs"
              onClick={() => (window.location.href = '/dashboard/learner/courses')}
            >
              View all <ArrowRight className="w-3 h-3 ml-1" />
            </Button>
          </CardHeader>
          <CardContent>
            {loading ? (
              <div className="space-y-3">
                {Array.from({ length: 3 }).map((_, i) => (
                  <Skeleton key={i} className="h-16 w-full rounded-lg" />
                ))}
              </div>
            ) : courses.length === 0 ? (
              <div className="py-8 text-center text-gray-400">
                <BookOpen className="w-8 h-8 mx-auto mb-2 opacity-40" />
                <p className="text-sm">No courses available for your level yet</p>
              </div>
            ) : (
              <div className="space-y-2">
                {courses.map((c) => (
                  <div
                    key={c.id}
                    className="flex items-center gap-3 p-3 rounded-lg border border-gray-100 hover:border-flehub-green/30 hover:bg-flehub-green-light/30 transition-colors group"
                  >
                    <div className="p-2 rounded-lg bg-flehub-green-light shrink-0">
                      <BookOpen className="w-4 h-4 text-flehub-green" />
                    </div>
                    <div className="flex-1 min-w-0">
                      <p className="font-medium text-sm text-gray-900 truncate">{c.title}</p>
                      <div className="flex items-center gap-2 mt-1">
                        <div className="flex-1 bg-gray-200 rounded-full h-1.5 max-w-[120px]">
                          <div
                            className="bg-flehub-green h-1.5 rounded-full transition-all"
                            style={{ width: `${c.progress_percent}%` }}
                          />
                        </div>
                        <span className="text-xs text-gray-400">{c.progress_percent}%</span>
                      </div>
                    </div>
                    <Button
                      size="sm"
                      variant="ghost"
                      className="shrink-0 text-flehub-green hover:bg-flehub-green-light"
                    >
                      <Play className="w-3.5 h-3.5" />
                    </Button>
                  </div>
                ))}
              </div>
            )}
          </CardContent>
        </Card>

        {/* My Progress */}
        <Card>
          <CardHeader className="pb-2">
            <CardTitle className="text-base font-semibold">My Progress</CardTitle>
          </CardHeader>
          <CardContent className="space-y-3">
            {loading ? (
              Array.from({ length: 5 }).map((_, i) => (
                <div key={i} className="space-y-1">
                  <Skeleton className="h-3 w-24" />
                  <Skeleton className="h-2 w-full" />
                </div>
              ))
            ) : (
              competencyProgress.map((p) => (
                <div key={p.competency}>
                  <div className="flex items-center justify-between mb-1">
                    <span className="text-xs font-medium text-gray-700">
                      {p.competency}
                      <span className="text-gray-400 font-normal ml-1 hidden sm:inline">
                        — {competencyLabels[p.competency]}
                      </span>
                    </span>
                    <span className="text-xs text-gray-500">
                      {p.average_score > 0 ? `${p.average_score}%` : `${p.attempts} attempts`}
                    </span>
                  </div>
                  <div className="w-full bg-gray-200 rounded-full h-1.5">
                    <div
                      className="bg-[#00A550] h-1.5 rounded-full transition-all"
                      style={{ width: `${Math.min(100, p.average_score)}%` }}
                    />
                  </div>
                </div>
              ))
            )}
          </CardContent>
        </Card>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        {/* Upcoming Exams */}
        <Card>
          <CardHeader className="flex flex-row items-center justify-between pb-2">
            <CardTitle className="text-base font-semibold">Upcoming Exams</CardTitle>
            <Button
              variant="ghost"
              size="sm"
              className="text-flehub-green text-xs"
              onClick={() => (window.location.href = '/dashboard/learner/exams')}
            >
              All exams <ArrowRight className="w-3 h-3 ml-1" />
            </Button>
          </CardHeader>
          <CardContent className="space-y-3">
            {loading ? (
              Array.from({ length: 3 }).map((_, i) => <Skeleton key={i} className="h-16 w-full" />)
            ) : upcomingExams.length === 0 ? (
              <p className="text-sm text-gray-400 py-4 text-center">No upcoming exams</p>
            ) : (
              upcomingExams.map((exam) => (
                <div
                  key={exam.id}
                  className="flex items-center justify-between gap-2 p-3 rounded-lg border border-gray-100"
                >
                  <div>
                    <div className="flex items-center gap-2 mb-1">
                      <span className="font-medium text-sm text-gray-900">{exam.title}</span>
                      <Badge variant="secondary" className={`text-xs ${cefrColors[exam.cefr_level]}`}>
                        {exam.cefr_level}
                      </Badge>
                    </div>
                    <p className="text-xs text-gray-400">
                      {new Date(exam.exam_date).toLocaleDateString('en-RW')} · {exam.venue}
                    </p>
                    <p className="text-xs font-medium text-flehub-green mt-0.5">
                      {exam.price_rwf.toLocaleString()} RWF
                    </p>
                  </div>
                  <Button
                    size="sm"
                    className="bg-flehub-green hover:bg-flehub-green/90 text-white shrink-0"
                    onClick={() => {
                      setPayExam(exam);
                      setPayMethod(null);
                      setPayPhone('');
                      setPayModalOpen(true);
                    }}
                  >
                    Register
                  </Button>
                </div>
              ))
            )}
          </CardContent>
        </Card>

        {/* Certificates */}
        <Card>
          <CardHeader className="flex flex-row items-center justify-between pb-2">
            <CardTitle className="text-base font-semibold">My Certificates</CardTitle>
            <Button
              variant="ghost"
              size="sm"
              className="text-flehub-green text-xs"
              onClick={() => (window.location.href = '/dashboard/learner/certificates')}
            >
              View all <ArrowRight className="w-3 h-3 ml-1" />
            </Button>
          </CardHeader>
          <CardContent className="space-y-3">
            {loading ? (
              Array.from({ length: 2 }).map((_, i) => <Skeleton key={i} className="h-16 w-full" />)
            ) : certificates.length === 0 ? (
              <div className="text-center py-6 text-gray-400">
                <Award className="w-8 h-8 mx-auto mb-2 opacity-40" />
                <p className="text-sm">No certificates yet</p>
                <p className="text-xs mt-1">Pass an exam to earn your first certificate</p>
              </div>
            ) : (
              certificates.slice(0, 3).map((cert) => (
                <div
                  key={cert.id}
                  className="flex items-center justify-between gap-2 p-3 rounded-lg border border-amber-100 bg-amber-50"
                >
                  <div className="flex items-center gap-2">
                    <Award className="w-5 h-5 text-amber-600 shrink-0" />
                    <div>
                      <div className="flex items-center gap-1.5">
                        <span className="font-medium text-sm text-gray-900">DELF {cert.cefr_level}</span>
                        <Badge className={`text-xs ${cefrColors[cert.cefr_level]}`} variant="secondary">
                          {cert.cefr_level}
                        </Badge>
                      </div>
                      <p className="text-xs text-gray-500">
                        {new Date(cert.issued_at).toLocaleDateString('en-RW')} · #{cert.certificate_number}
                      </p>
                    </div>
                  </div>
                  <Button
                    size="sm"
                    variant="outline"
                    className="text-xs h-7 shrink-0"
                    onClick={() => alert('PDF generation coming soon')}
                  >
                    <Download className="w-3 h-3 mr-1" />
                    PDF
                  </Button>
                </div>
              ))
            )}
          </CardContent>
        </Card>
      </div>

      {/* Payment Modal */}
      <Dialog open={payModalOpen} onOpenChange={setPayModalOpen}>
        <DialogContent className="max-w-sm">
          <DialogHeader>
            <DialogTitle>Register for Exam</DialogTitle>
          </DialogHeader>
          {payExam && (
            <div className="space-y-4 py-2">
              <div className="p-3 rounded-lg bg-gray-50 border border-gray-100">
                <p className="font-semibold text-gray-900">{payExam.title}</p>
                <p className="text-sm text-gray-500 mt-0.5">
                  {new Date(payExam.exam_date).toLocaleDateString('en-RW')} · {payExam.venue}
                </p>
                <p className="text-lg font-bold text-flehub-green mt-2">
                  {payExam.price_rwf.toLocaleString()} RWF
                </p>
              </div>

              <div className="space-y-2">
                <Label>Choose Payment Method</Label>
                <div className="grid grid-cols-2 gap-2">
                  <button
                    className={`p-3 rounded-lg border-2 text-sm font-medium transition-colors ${
                      payMethod === 'mtn'
                        ? 'border-yellow-400 bg-yellow-50 text-yellow-800'
                        : 'border-gray-200 text-gray-600 hover:border-yellow-300'
                    }`}
                    onClick={() => setPayMethod('mtn')}
                  >
                    <Smartphone className="w-5 h-5 mx-auto mb-1 text-yellow-600" />
                    MTN MoMo
                  </button>
                  <button
                    className={`p-3 rounded-lg border-2 text-sm font-medium transition-colors ${
                      payMethod === 'airtel'
                        ? 'border-red-400 bg-red-50 text-red-800'
                        : 'border-gray-200 text-gray-600 hover:border-red-300'
                    }`}
                    onClick={() => setPayMethod('airtel')}
                  >
                    <Phone className="w-5 h-5 mx-auto mb-1 text-red-600" />
                    Airtel Money
                  </button>
                </div>
              </div>

              {payMethod && (
                <div className="space-y-1">
                  <Label>Phone Number</Label>
                  <Input
                    type="tel"
                    placeholder={payMethod === 'mtn' ? '07X XXX XXXX' : '073 XXX XXXX'}
                    value={payPhone}
                    onChange={(e) => setPayPhone(e.target.value)}
                  />
                  <p className="text-xs text-gray-400">
                    Enter the {payMethod === 'mtn' ? 'MTN MoMo' : 'Airtel Money'} registered number
                  </p>
                </div>
              )}
            </div>
          )}
          <DialogFooter>
            <Button variant="outline" onClick={() => setPayModalOpen(false)}>
              Cancel
            </Button>
            <Button
              className="bg-flehub-green hover:bg-flehub-green/90 text-white"
              onClick={handlePayment}
              disabled={payProcessing || !payMethod || !payPhone}
            >
              {payProcessing ? 'Processing...' : 'Confirm Payment'}
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>
    </div>
  );
}
