'use client';

import { useEffect, useState } from 'react';
import { createClient } from '@/lib/supabase/client';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Skeleton } from '@/components/ui/skeleton';
import { AlertTriangle, Award, Download, ShieldCheck } from 'lucide-react';
import { Button } from '@/components/ui/button';

type CEFR = 'A1' | 'A2' | 'B1' | 'B2' | 'C1' | 'C2';

interface Certificate {
  id: string;
  certificate_number: string;
  verification_code: string;
  cefr_level: CEFR;
  issue_date: string;
  pdf_url: string | null;
  full_name: string;
  email: string;
}

const CEFR_COLORS: Record<CEFR, string> = {
  A1: 'bg-slate-100 text-slate-600',
  A2: 'bg-blue-50 text-blue-600',
  B1: 'bg-teal-50 text-teal-600',
  B2: 'bg-[#E6F5EE] text-[#00A550]',
  C1: 'bg-orange-50 text-orange-600',
  C2: 'bg-purple-50 text-purple-700',
};

const CEFR_LABELS: Record<CEFR, string> = {
  A1: 'Beginner', A2: 'Elementary', B1: 'Intermediate',
  B2: 'Upper-Intermediate', C1: 'Advanced', C2: 'Mastery',
};

export default function SchoolCertificatesPage() {
  const supabase = createClient();

  const [certificates, setCertificates] = useState<Certificate[]>([]);
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

      const { data: certs } = await supabase
        .from('certificates')
        .select('id, certificate_number, verification_code, cefr_level, issue_date, pdf_url, learners(profile_id, profiles(full_name, email))')
        .eq('school_id', school.id)
        .order('issue_date', { ascending: false });

      const mapped: Certificate[] = (certs ?? []).map((c: any) => ({
        id: c.id,
        certificate_number: c.certificate_number,
        verification_code: c.verification_code,
        cefr_level: c.cefr_level,
        issue_date: c.issue_date,
        pdf_url: c.pdf_url ?? null,
        full_name: c.learners?.profiles?.full_name ?? 'Unknown',
        email: c.learners?.profiles?.email ?? '',
      }));

      setCertificates(mapped);
    } catch {
      setError('Failed to load certificates. Please refresh.');
    } finally {
      setLoading(false);
    }
  }

  const levelCounts = certificates.reduce<Partial<Record<CEFR, number>>>((acc, c) => {
    acc[c.cefr_level] = (acc[c.cefr_level] ?? 0) + 1;
    return acc;
  }, {});

  return (
    <div className="p-6 space-y-6 max-w-7xl mx-auto">
      <div>
        <h1 className="text-2xl font-bold text-gray-900">Certificates</h1>
        <p className="text-sm text-gray-500 mt-1">All certificates issued to your school's students.</p>
      </div>

      {error && (
        <div className="flex items-center gap-2 rounded-lg bg-red-50 border border-red-200 px-4 py-3 text-sm text-red-700">
          <AlertTriangle className="w-4 h-4 flex-shrink-0" />
          {error}
        </div>
      )}

      {/* Level breakdown */}
      {!loading && certificates.length > 0 && (
        <div className="flex flex-wrap gap-2">
          <span className="text-xs text-gray-500 self-center mr-1">Breakdown:</span>
          {(Object.entries(levelCounts) as [CEFR, number][]).map(([level, count]) => (
            <span key={level} className={`text-xs px-2.5 py-1 rounded-full font-semibold ${CEFR_COLORS[level]}`}>
              {level}: {count}
            </span>
          ))}
        </div>
      )}

      <Card className="border-0 shadow-sm">
        <CardHeader className="pb-3">
          <div className="flex items-center gap-2">
            <div className="w-8 h-8 rounded-lg bg-amber-50 flex items-center justify-center">
              <Award className="w-4 h-4 text-amber-600" />
            </div>
            <CardTitle className="text-base font-semibold">
              Issued Certificates
              {!loading && <span className="ml-2 text-sm font-normal text-gray-400">({certificates.length})</span>}
            </CardTitle>
          </div>
        </CardHeader>
        <CardContent className="p-0">
          {loading ? (
            <div className="p-5 space-y-3">
              {Array.from({ length: 5 }).map((_, i) => <Skeleton key={i} className="h-14 w-full" />)}
            </div>
          ) : certificates.length === 0 ? (
            <div className="flex flex-col items-center py-16 text-gray-400">
              <div className="w-12 h-12 rounded-xl bg-amber-50 flex items-center justify-center mb-3">
                <Award className="w-6 h-6 text-amber-500" />
              </div>
              <p className="text-sm font-medium text-gray-700">No certificates issued yet</p>
              <p className="text-xs text-gray-400 mt-1">Certificates are generated automatically when a student passes an exam.</p>
            </div>
          ) : (
            <div className="overflow-x-auto">
              <table className="w-full text-sm">
                <thead>
                  <tr className="border-b border-gray-100">
                    {['Student', 'Certificate Number', 'Level', 'Issue Date', 'Verification Code', 'Actions'].map((h) => (
                      <th key={h} className="text-left py-2.5 px-3 text-xs text-gray-500 font-medium first:pl-5">{h}</th>
                    ))}
                  </tr>
                </thead>
                <tbody>
                  {certificates.map((cert) => (
                    <tr key={cert.id} className="border-b border-gray-50 hover:bg-gray-50/60 transition-colors">
                      <td className="py-3 pl-5 pr-3">
                        <p className="font-medium text-gray-900">{cert.full_name}</p>
                        <p className="text-xs text-gray-400">{cert.email}</p>
                      </td>
                      <td className="py-3 px-3">
                        <span className="font-mono text-xs text-gray-700 bg-gray-100 px-2 py-0.5 rounded">
                          {cert.certificate_number}
                        </span>
                      </td>
                      <td className="py-3 px-3">
                        <div>
                          <span className={`text-xs px-2.5 py-0.5 rounded font-bold ${CEFR_COLORS[cert.cefr_level] ?? 'bg-gray-100 text-gray-600'}`}>
                            {cert.cefr_level}
                          </span>
                          <p className="text-xs text-gray-400 mt-0.5">{CEFR_LABELS[cert.cefr_level]}</p>
                        </div>
                      </td>
                      <td className="py-3 px-3 text-sm text-gray-600">
                        {new Date(cert.issue_date).toLocaleDateString('en-RW', { day: 'numeric', month: 'long', year: 'numeric' })}
                      </td>
                      <td className="py-3 px-3">
                        <div className="flex items-center gap-1.5">
                          <ShieldCheck className="w-3.5 h-3.5 text-[#00A550] flex-shrink-0" />
                          <span className="font-mono text-xs text-gray-600">{cert.verification_code}</span>
                        </div>
                      </td>
                      <td className="py-3 px-3">
                        {cert.pdf_url ? (
                          <Button variant="ghost" size="sm" className="h-7 text-xs text-amber-600 hover:bg-amber-50" asChild>
                            <a href={cert.pdf_url} target="_blank" rel="noopener noreferrer">
                              <Download className="w-3.5 h-3.5 mr-1" />
                              Download
                            </a>
                          </Button>
                        ) : (
                          <span className="text-xs text-gray-300">No PDF</span>
                        )}
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
