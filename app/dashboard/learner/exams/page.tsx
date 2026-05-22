'use client';

import { useEffect, useState } from 'react';
import { createClient } from '@/lib/supabase/client';
import { Card, CardContent } from '@/components/ui/card';
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
  Tabs,
  TabsContent,
  TabsList,
  TabsTrigger,
} from '@/components/ui/tabs';
import {
  Calendar,
  MapPin,
  Clock,
  Phone,
  Smartphone,
  CheckCircle2,
  XCircle,
  HelpCircle,
  ClipboardList,
} from 'lucide-react';

type CEFR = 'A1' | 'A2' | 'B1' | 'B2' | 'C1' | 'C2';

interface ExamSession {
  id: string;
  title: string;
  cefr_level: CEFR;
  exam_date: string;
  registration_deadline: string;
  venue: string;
  price_rwf: number;
  description?: string;
}

interface MyRegistration {
  id: string;
  exam_session_id: string;
  status: 'registered' | 'confirmed' | 'completed' | 'cancelled';
  registered_at: string;
  exam_title: string;
  exam_date: string;
  cefr_level: CEFR;
  venue: string;
  result?: {
    total_score: number;
    passed: boolean;
  } | null;
}

const cefrLevels: CEFR[] = ['A1', 'A2', 'B1', 'B2', 'C1', 'C2'];

const cefrColors: Record<CEFR, string> = {
  A1: 'bg-green-100 text-green-700',
  A2: 'bg-lime-100 text-lime-700',
  B1: 'bg-yellow-100 text-yellow-700',
  B2: 'bg-orange-100 text-orange-700',
  C1: 'bg-red-100 text-red-700',
  C2: 'bg-rose-100 text-rose-700',
};

const regStatusConfig: Record<
  MyRegistration['status'],
  { label: string; className: string; icon: React.ElementType }
> = {
  registered: { label: 'Registered', className: 'bg-blue-100 text-blue-700', icon: Clock },
  confirmed: { label: 'Confirmed', className: 'bg-flehub-green-light text-flehub-green', icon: CheckCircle2 },
  completed: { label: 'Completed', className: 'bg-gray-100 text-gray-600', icon: CheckCircle2 },
  cancelled: { label: 'Cancelled', className: 'bg-red-100 text-red-600', icon: XCircle },
};

export default function LearnerExamsPage() {
  const supabase = createClient();

  const [learnerId, setLearnerId] = useState<string | null>(null);
  const [availableExams, setAvailableExams] = useState<ExamSession[]>([]);
  const [myRegistrations, setMyRegistrations] = useState<MyRegistration[]>([]);
  const [registeredExamIds, setRegisteredExamIds] = useState<Set<string>>(new Set());
  const [loading, setLoading] = useState(true);

  const [filterCefr, setFilterCefr] = useState<CEFR | 'all'>('all');

  // Payment dialog
  const [payOpen, setPayOpen] = useState(false);
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

      const { data: learner } = await supabase
        .from('learners')
        .select('id')
        .eq('profile_id', user.id)
        .maybeSingle();

      if (!learner) return;
      setLearnerId(learner.id);

      // Available exam sessions (future)
      const now = new Date().toISOString();
      const { data: exams } = await supabase
        .from('exam_sessions')
        .select('id, title, cefr_level, exam_date, registration_deadline, venue, price_rwf, description')
        .gte('exam_date', now)
        .order('exam_date', { ascending: true });

      setAvailableExams(exams ?? []);

      // My registrations
      const { data: regs } = await supabase
        .from('exam_registrations')
        .select(
          `
          id,
          exam_session_id,
          status,
          registered_at,
          exam_sessions (title, exam_date, cefr_level, venue),
          exam_results (total_score, passed)
        `
        )
        .eq('learner_id', learner.id)
        .order('registered_at', { ascending: false });

      const regsMapped: MyRegistration[] = (regs ?? []).map((r: any) => ({
        id: r.id,
        exam_session_id: r.exam_session_id,
        status: r.status,
        registered_at: r.registered_at,
        exam_title: r.exam_sessions?.title ?? 'Unknown',
        exam_date: r.exam_sessions?.exam_date ?? '',
        cefr_level: r.exam_sessions?.cefr_level ?? 'A1',
        venue: r.exam_sessions?.venue ?? '',
        result: r.exam_results ? { total_score: r.exam_results.total_score, passed: r.exam_results.passed } : null,
      }));

      setMyRegistrations(regsMapped);
      setRegisteredExamIds(new Set(regsMapped.map((r) => r.exam_session_id)));
    } catch (err) {
      console.error(err);
    } finally {
      setLoading(false);
    }
  }

  async function handlePayment() {
    if (!payExam || !learnerId || !payPhone || !payMethod) return;
    setPayProcessing(true);
    try {
      // Simulate payment insert
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

      setPayOpen(false);
      setPayExam(null);
      setPayPhone('');
      setPayMethod(null);
      await fetchData();
      alert('Payment successful! Registration confirmed.');
    } catch (err) {
      console.error(err);
    } finally {
      setPayProcessing(false);
    }
  }

  const filteredExams = availableExams.filter(
    (e) => filterCefr === 'all' || e.cefr_level === filterCefr
  );

  const isDeadlinePassed = (deadline: string) => new Date(deadline) < new Date();

  return (
    <div className="p-6 space-y-6 max-w-5xl mx-auto">
      {/* Header */}
      <div>
        <h1 className="text-2xl font-bold text-gray-900">Exams</h1>
        <p className="text-gray-500 text-sm mt-1">Register for official French language exams</p>
      </div>

      <Tabs defaultValue="available">
        <TabsList className="bg-gray-100">
          <TabsTrigger value="available">Available Exams</TabsTrigger>
          <TabsTrigger value="my">
            My Registrations
            {myRegistrations.length > 0 && (
              <Badge variant="secondary" className="ml-1.5 text-xs bg-flehub-green text-white">
                {myRegistrations.length}
              </Badge>
            )}
          </TabsTrigger>
        </TabsList>

        {/* Available Exams Tab */}
        <TabsContent value="available" className="space-y-4 mt-4">
          {/* CEFR Filter Chips */}
          <div className="flex flex-wrap gap-2 items-center">
            <span className="text-sm text-gray-500">Filter by level:</span>
            <Button
              variant={filterCefr === 'all' ? 'default' : 'outline'}
              size="sm"
              className={filterCefr === 'all' ? 'bg-flehub-green text-white' : ''}
              onClick={() => setFilterCefr('all')}
            >
              All
            </Button>
            {cefrLevels.map((l) => (
              <Button
                key={l}
                variant={filterCefr === l ? 'default' : 'outline'}
                size="sm"
                className={filterCefr === l ? 'bg-flehub-green text-white' : ''}
                onClick={() => setFilterCefr(l)}
              >
                {l}
              </Button>
            ))}
          </div>

          {loading ? (
            <div className="space-y-3">
              {Array.from({ length: 4 }).map((_, i) => (
                <Skeleton key={i} className="h-36 rounded-xl" />
              ))}
            </div>
          ) : filteredExams.length === 0 ? (
            <div className="flex flex-col items-center py-20 text-gray-400">
              <ClipboardList className="w-12 h-12 mb-3 opacity-40" />
              <p className="font-medium">No exams available</p>
              <p className="text-sm">Check back later for upcoming exam sessions</p>
            </div>
          ) : (
            <div className="space-y-3">
              {filteredExams.map((exam) => {
                const alreadyRegistered = registeredExamIds.has(exam.id);
                const deadlinePassed = isDeadlinePassed(exam.registration_deadline);

                return (
                  <Card key={exam.id} className="card-hover">
                    <CardContent className="py-4">
                      <div className="flex flex-col sm:flex-row sm:items-start gap-3">
                        <div className="flex-1 min-w-0">
                          <div className="flex flex-wrap items-center gap-2 mb-2">
                            <span className="font-semibold text-gray-900">{exam.title}</span>
                            <Badge
                              variant="secondary"
                              className={`text-xs font-bold ${cefrColors[exam.cefr_level]}`}
                            >
                              {exam.cefr_level}
                            </Badge>
                            {deadlinePassed && (
                              <Badge variant="secondary" className="text-xs bg-red-100 text-red-600">
                                Registration Closed
                              </Badge>
                            )}
                          </div>
                          {exam.description && (
                            <p className="text-sm text-gray-500 mb-2 line-clamp-1">{exam.description}</p>
                          )}
                          <div className="flex flex-wrap gap-3 text-sm text-gray-500">
                            <span className="flex items-center gap-1">
                              <Calendar className="w-3.5 h-3.5" />
                              {new Date(exam.exam_date).toLocaleDateString('en-RW', {
                                weekday: 'short',
                                year: 'numeric',
                                month: 'short',
                                day: 'numeric',
                              })}
                            </span>
                            <span className="flex items-center gap-1">
                              <MapPin className="w-3.5 h-3.5" />
                              {exam.venue}
                            </span>
                            <span className="flex items-center gap-1">
                              <Clock className="w-3.5 h-3.5" />
                              Deadline:{' '}
                              {new Date(exam.registration_deadline).toLocaleDateString('en-RW')}
                            </span>
                          </div>
                          <p className="text-base font-bold text-flehub-green mt-2">
                            {exam.price_rwf.toLocaleString()} RWF
                          </p>
                        </div>
                        <div className="shrink-0">
                          {alreadyRegistered ? (
                            <Badge
                              variant="secondary"
                              className="bg-flehub-green-light text-flehub-green border-flehub-green"
                            >
                              <CheckCircle2 className="w-3.5 h-3.5 mr-1" />
                              Registered
                            </Badge>
                          ) : (
                            <Button
                              size="sm"
                              className="bg-flehub-green hover:bg-flehub-green/90 text-white"
                              disabled={deadlinePassed}
                              onClick={() => {
                                setPayExam(exam);
                                setPayMethod(null);
                                setPayPhone('');
                                setPayOpen(true);
                              }}
                            >
                              Register
                            </Button>
                          )}
                        </div>
                      </div>
                    </CardContent>
                  </Card>
                );
              })}
            </div>
          )}
        </TabsContent>

        {/* My Registrations Tab */}
        <TabsContent value="my" className="space-y-3 mt-4">
          {loading ? (
            <div className="space-y-3">
              {Array.from({ length: 3 }).map((_, i) => (
                <Skeleton key={i} className="h-24 rounded-xl" />
              ))}
            </div>
          ) : myRegistrations.length === 0 ? (
            <div className="flex flex-col items-center py-20 text-gray-400">
              <HelpCircle className="w-12 h-12 mb-3 opacity-40" />
              <p className="font-medium">No registrations yet</p>
              <p className="text-sm">Register for an exam to see it here</p>
            </div>
          ) : (
            myRegistrations.map((reg) => {
              const cfg = regStatusConfig[reg.status];
              const StatusIcon = cfg.icon;

              return (
                <Card key={reg.id} className="card-hover">
                  <CardContent className="py-4">
                    <div className="flex flex-col sm:flex-row sm:items-start gap-3">
                      <div className="flex-1 min-w-0">
                        <div className="flex flex-wrap items-center gap-2 mb-1">
                          <span className="font-semibold text-gray-900">{reg.exam_title}</span>
                          <Badge
                            variant="secondary"
                            className={`text-xs font-bold ${cefrColors[reg.cefr_level]}`}
                          >
                            {reg.cefr_level}
                          </Badge>
                          <Badge
                            variant="secondary"
                            className={`text-xs flex items-center gap-1 ${cfg.className}`}
                          >
                            <StatusIcon className="w-3 h-3" />
                            {cfg.label}
                          </Badge>
                        </div>
                        <div className="flex flex-wrap gap-3 text-sm text-gray-500">
                          <span className="flex items-center gap-1">
                            <Calendar className="w-3.5 h-3.5" />
                            {reg.exam_date
                              ? new Date(reg.exam_date).toLocaleDateString('en-RW', {
                                  weekday: 'short',
                                  year: 'numeric',
                                  month: 'short',
                                  day: 'numeric',
                                })
                              : 'TBD'}
                          </span>
                          {reg.venue && (
                            <span className="flex items-center gap-1">
                              <MapPin className="w-3.5 h-3.5" />
                              {reg.venue}
                            </span>
                          )}
                        </div>
                      </div>

                      {/* Result */}
                      {reg.result && (
                        <div
                          className={`px-3 py-2 rounded-lg text-center shrink-0 ${
                            reg.result.passed
                              ? 'bg-flehub-green-light'
                              : 'bg-red-50'
                          }`}
                        >
                          <p
                            className={`text-lg font-bold ${
                              reg.result.passed ? 'text-flehub-green' : 'text-red-600'
                            }`}
                          >
                            {reg.result.total_score}/100
                          </p>
                          <p
                            className={`text-xs font-medium ${
                              reg.result.passed ? 'text-flehub-green' : 'text-red-500'
                            }`}
                          >
                            {reg.result.passed ? 'PASSED' : 'FAILED'}
                          </p>
                        </div>
                      )}
                    </div>
                  </CardContent>
                </Card>
              );
            })
          )}
        </TabsContent>
      </Tabs>

      {/* Payment Dialog */}
      <Dialog open={payOpen} onOpenChange={setPayOpen}>
        <DialogContent className="max-w-sm">
          <DialogHeader>
            <DialogTitle>Pay for Exam Registration</DialogTitle>
          </DialogHeader>
          {payExam && (
            <div className="space-y-4 py-2">
              <div className="p-3 rounded-lg bg-gray-50 border border-gray-100">
                <p className="font-semibold text-gray-900">{payExam.title}</p>
                <div className="flex flex-wrap gap-2 mt-1 text-xs text-gray-500">
                  <span className="flex items-center gap-1">
                    <Calendar className="w-3 h-3" />
                    {new Date(payExam.exam_date).toLocaleDateString('en-RW')}
                  </span>
                  <span className="flex items-center gap-1">
                    <MapPin className="w-3 h-3" />
                    {payExam.venue}
                  </span>
                </div>
                <p className="text-xl font-bold text-flehub-green mt-2">
                  {payExam.price_rwf.toLocaleString()} RWF
                </p>
              </div>

              <div className="space-y-2">
                <Label>Choose Payment Method</Label>
                <div className="grid grid-cols-2 gap-2">
                  <button
                    className={`p-3 rounded-lg border-2 text-sm font-medium transition-colors flex flex-col items-center gap-1 ${
                      payMethod === 'mtn'
                        ? 'border-yellow-400 bg-yellow-50 text-yellow-800'
                        : 'border-gray-200 text-gray-600 hover:border-yellow-200'
                    }`}
                    onClick={() => setPayMethod('mtn')}
                  >
                    <Smartphone className="w-5 h-5 text-yellow-500" />
                    Payer avec MTN MoMo
                  </button>
                  <button
                    className={`p-3 rounded-lg border-2 text-sm font-medium transition-colors flex flex-col items-center gap-1 ${
                      payMethod === 'airtel'
                        ? 'border-red-400 bg-red-50 text-red-800'
                        : 'border-gray-200 text-gray-600 hover:border-red-200'
                    }`}
                    onClick={() => setPayMethod('airtel')}
                  >
                    <Phone className="w-5 h-5 text-red-500" />
                    Payer avec Airtel Money
                  </button>
                </div>
              </div>

              {payMethod && (
                <div className="space-y-1">
                  <Label>
                    {payMethod === 'mtn' ? 'MTN MoMo' : 'Airtel Money'} Phone Number
                  </Label>
                  <Input
                    type="tel"
                    placeholder={payMethod === 'mtn' ? '078 XXX XXXX' : '073 XXX XXXX'}
                    value={payPhone}
                    onChange={(e) => setPayPhone(e.target.value)}
                  />
                  <p className="text-xs text-gray-400">
                    A payment prompt will be sent to this number
                  </p>
                </div>
              )}
            </div>
          )}
          <DialogFooter>
            <Button variant="outline" onClick={() => setPayOpen(false)}>
              Cancel
            </Button>
            <Button
              className="bg-flehub-green hover:bg-flehub-green/90 text-white"
              onClick={handlePayment}
              disabled={payProcessing || !payMethod || !payPhone.trim()}
            >
              {payProcessing ? 'Processing...' : 'Confirm & Pay'}
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>
    </div>
  );
}
