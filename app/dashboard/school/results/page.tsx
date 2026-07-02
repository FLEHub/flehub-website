'use client';

import { useEffect, useState } from 'react';
import { createClient } from '@/lib/supabase/client';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Skeleton } from '@/components/ui/skeleton';
import { AlertTriangle, ClipboardList, TrendingUp, CheckCircle2, XCircle } from 'lucide-react';

type CEFR = 'A1' | 'A2' | 'B1' | 'B2' | 'C1' | 'C2';

interface ExamResult {
  id: string;
  learner_id: string;
  full_name: string;
  email: string;
  exam_title: string;
  cefr_level: CEFR;
  exam_date: string;
  score_eo: number | null;
  score_ee: number | null;
  score_co: number | null;
  score_ce: number | null;
  score_el: number | null;
  total_score: number | null;
  passed: boolean;
  created_at: string;
}

const CEFR_COLORS: Record<CEFR, string> = {
  A1: 'bg-slate-100 text-slate-600',
  A2: 'bg-blue-50 text-blue-600',
  B1: 'bg-teal-50 text-teal-600',
  B2: 'bg-[#E6F5EE] text-[#00A550]',
  C1: 'bg-orange-50 text-orange-600',
  C2: 'bg-purple-50 text-purple-700',
};

const COMP_LABELS = ['EO', 'EE', 'CO', 'CE', 'EL'];

export default function SchoolResultsPage() {
  const supabase = createClient();

  const [results, setResults] = useState<ExamResult[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

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

      // Get all learner IDs enrolled in this school
      const { data: enrollments } = await supabase
        .from('school_enrollments')
        .select('learners(id, profile_id, cefr_level, profiles(full_name, email))')
        .eq('school_id', school.id);

      const learnerMap: Record<string, { full_name: string; email: string; cefr_level: CEFR | null }> = {};
      for (const e of (enrollments ?? []) as any[]) {
        const learner = e.learners;
        if (learner?.id) {
          learnerMap[learner.id] = {
            full_name: learner.profiles?.full_name ?? 'Unknown',
            email: learner.profiles?.email ?? '',
            cefr_level: learner.cefr_level ?? null,
          };
        }
      }

      const learnerIds = Object.keys(learnerMap);
      if (learnerIds.length === 0) { setResults([]); return; }

      const { data: rawResults } = await supabase
        .from('exam_results')
        .select('id, learner_id, exam_session_id, score_eo, score_ee, score_co, score_ce, score_el, total_score, passed, created_at, exam_sessions(title, cefr_level, exam_date)')
        .in('learner_id', learnerIds)
        .order('created_at', { ascending: false });

      const mapped: ExamResult[] = (rawResults ?? []).map((r: any) => ({
        id: r.id,
        learner_id: r.learner_id,
        full_name: learnerMap[r.learner_id]?.full_name ?? 'Unknown',
        email: learnerMap[r.learner_id]?.email ?? '',
        exam_title: r.exam_sessions?.title ?? '—',
        cefr_level: r.exam_sessions?.cefr_level ?? 'A1',
        exam_date: r.exam_sessions?.exam_date ?? r.created_at,
        score_eo: r.score_eo,
        score_ee: r.score_ee,
        score_co: r.score_co,
        score_ce: r.score_ce,
        score_el: r.score_el,
        total_score: r.total_score,
        passed: r.passed,
        created_at: r.created_at,
      }));

      setResults(mapped);
    } catch {
      setError('Failed to load exam results. Please refresh.');
    } finally {
      setLoading(false);
    }
  }

  const passCount = results.filter((r) => r.passed).length;
  const failCount = results.filter((r) => !r.passed).length;
  const avgScore = results.length
    ? Math.round(results.reduce((s, r) => s + (r.total_score ?? 0), 0) / results.length)
    : 0;

  return (
    <div className="p-6 space-y-6 max-w-7xl mx-auto">
      <div>
        <h1 className="text-2xl font-bold text-gray-900">Exam Results</h1>
        <p className="text-sm text-gray-500 mt-1">All exam results for your enrolled students.</p>
      </div>

      {error && (
        <div className="flex items-center gap-2 rounded-lg bg-red-50 border border-red-200 px-4 py-3 text-sm text-red-700">
          <AlertTriangle className="w-4 h-4 flex-shrink-0" />
          {error}
        </div>
      )}

      {/* Summary stats */}
      {!loading && results.length > 0 && (
        <div className="grid grid-cols-1 sm:grid-cols-3 gap-4">
          {[
            { label: 'Total Results', value: results.length, icon: ClipboardList, color: 'text-[#00A550]', bg: 'bg-[#E6F5EE]' },
            { label: 'Average Score', value: `${avgScore}/100`, icon: TrendingUp, color: 'text-blue-600', bg: 'bg-blue-50' },
            { label: 'Pass Rate', value: results.length ? `${Math.round((passCount / results.length) * 100)}%` : '—', icon: CheckCircle2, color: 'text-amber-600', bg: 'bg-amber-50' },
          ].map((s) => (
            <Card key={s.label} className="border-0 shadow-sm">
              <CardContent className="p-5">
                <div className="flex items-center justify-between">
                  <div>
                    <p className="text-xs text-gray-500 font-medium">{s.label}</p>
                    <p className="text-2xl font-bold text-gray-900 mt-1">{s.value}</p>
                  </div>
                  <div className={`w-10 h-10 rounded-xl flex items-center justify-center ${s.bg}`}>
                    <s.icon className={`w-5 h-5 ${s.color}`} />
                  </div>
                </div>
              </CardContent>
            </Card>
          ))}
        </div>
      )}

      <Card className="border-0 shadow-sm">
        <CardHeader className="pb-3">
          <div className="flex items-center gap-2">
            <div className="w-8 h-8 rounded-lg bg-[#E6F5EE] flex items-center justify-center">
              <ClipboardList className="w-4 h-4 text-[#00A550]" />
            </div>
            <CardTitle className="text-base font-semibold">
              All Results
              {!loading && <span className="ml-2 text-sm font-normal text-gray-400">({results.length})</span>}
            </CardTitle>
            {!loading && results.length > 0 && (
              <div className="ml-auto flex items-center gap-2 text-xs">
                <span className="flex items-center gap-1 text-[#00A550]"><CheckCircle2 className="w-3.5 h-3.5" />{passCount} passed</span>
                <span className="flex items-center gap-1 text-red-500"><XCircle className="w-3.5 h-3.5" />{failCount} failed</span>
              </div>
            )}
          </div>
        </CardHeader>
        <CardContent className="p-0">
          {loading ? (
            <div className="p-5 space-y-3">
              {Array.from({ length: 5 }).map((_, i) => <Skeleton key={i} className="h-12 w-full" />)}
            </div>
          ) : results.length === 0 ? (
            <div className="flex flex-col items-center py-16 text-gray-400">
              <div className="w-12 h-12 rounded-xl bg-[#E6F5EE] flex items-center justify-center mb-3">
                <ClipboardList className="w-6 h-6 text-[#00A550]" />
              </div>
              <p className="text-sm font-medium text-gray-700">No exam results yet</p>
              <p className="text-xs text-gray-400 mt-1">Results will appear here once entered for enrolled students.</p>
            </div>
          ) : (
            <div className="overflow-x-auto">
              <table className="w-full text-sm">
                <thead>
                  <tr className="border-b border-gray-100">
                    {['Student', 'Exam Session', 'Level', 'EO', 'EE', 'CO', 'CE', 'EL', 'Total', 'Result'].map((h) => (
                      <th key={h} className="text-left py-2.5 px-3 text-xs text-gray-500 font-medium first:pl-5">{h}</th>
                    ))}
                  </tr>
                </thead>
                <tbody>
                  {results.map((r) => (
                    <tr key={r.id} className="border-b border-gray-50 hover:bg-gray-50/60 transition-colors">
                      <td className="py-3 pl-5 pr-3">
                        <p className="font-medium text-gray-900 text-sm">{r.full_name}</p>
                        <p className="text-xs text-gray-400">{r.email}</p>
                      </td>
                      <td className="py-3 px-3">
                        <p className="text-sm text-gray-700 max-w-[140px] truncate">{r.exam_title}</p>
                        <p className="text-xs text-gray-400 mt-0.5">
                          {new Date(r.exam_date).toLocaleDateString('en-RW', { day: 'numeric', month: 'short', year: 'numeric' })}
                        </p>
                      </td>
                      <td className="py-3 px-3">
                        <span className={`text-xs px-2.5 py-0.5 rounded font-bold ${CEFR_COLORS[r.cefr_level] ?? 'bg-gray-100 text-gray-600'}`}>
                          {r.cefr_level}
                        </span>
                      </td>
                      {[r.score_eo, r.score_ee, r.score_co, r.score_ce, r.score_el].map((sc, i) => (
                        <td key={COMP_LABELS[i]} className="py-3 px-3 text-sm text-gray-700 font-medium">
                          {sc !== null ? sc : <span className="text-gray-300">—</span>}
                        </td>
                      ))}
                      <td className="py-3 px-3">
                        <span className="font-bold text-gray-900">{r.total_score ?? '—'}</span>
                        <span className="text-xs text-gray-400">/100</span>
                      </td>
                      <td className="py-3 px-3">
                        <span className={`text-xs px-2.5 py-0.5 rounded-full font-medium ${r.passed ? 'bg-[#E6F5EE] text-[#00A550]' : 'bg-red-50 text-red-600'}`}>
                          {r.passed ? 'Pass' : 'Fail'}
                        </span>
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          )}
        </CardContent>
      </Card>
    </div>
  );
}
