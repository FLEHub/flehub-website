'use client';

import { useEffect, useState } from 'react';
import { createClient } from '@/lib/supabase/client';
import type { CefrLevel, ElearningCertificate } from '@/lib/types';
import { Card, CardContent } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Badge } from '@/components/ui/badge';
import { Skeleton } from '@/components/ui/skeleton';
import {
  Award,
  Download,
  Copy,
  CheckCheck,
  ShieldCheck,
  Calendar,
  Hash,
} from 'lucide-react';

type CEFR = CefrLevel;

interface OfficialCertificate {
  id: string;
  source: 'official';
  cefr_level: CEFR;
  issued_at: string;
  certificate_number: string;
  verification_code: string;
  exam_title?: string;
  exam_date?: string;
  pdf_url?: string | null;
}

interface LevelCertificate {
  id: string;
  source: 'elearning';
  cefr_level: CEFR;
  issued_at: string;
  certificate_number: string;
  pdf_path: string | null;
}

type DisplayCertificate = OfficialCertificate | LevelCertificate;

const cefrColors: Record<CEFR, string> = {
  A1: 'bg-green-100 text-green-700 border-green-200',
  A2: 'bg-lime-100 text-lime-700 border-lime-200',
  B1: 'bg-yellow-100 text-yellow-700 border-yellow-200',
  B2: 'bg-orange-100 text-orange-700 border-orange-200',
  C1: 'bg-red-100 text-red-700 border-red-200',
  C2: 'bg-rose-100 text-rose-700 border-rose-200',
};

const cefrGradients: Record<CEFR, string> = {
  A1: 'from-green-50 to-emerald-50 border-green-200',
  A2: 'from-lime-50 to-green-50 border-lime-200',
  B1: 'from-yellow-50 to-amber-50 border-yellow-200',
  B2: 'from-orange-50 to-amber-50 border-orange-200',
  C1: 'from-red-50 to-orange-50 border-red-200',
  C2: 'from-rose-50 to-pink-50 border-rose-200',
};

const cefrDescriptions: Record<CEFR, string> = {
  A1: 'Breakthrough / Introductory',
  A2: 'Waystage / Elementary',
  B1: 'Threshold / Intermediate',
  B2: 'Vantage / Upper Intermediate',
  C1: 'Effective Operational Proficiency',
  C2: 'Mastery / Proficiency',
};

export default function LearnerCertificatesPage() {
  const supabase = createClient();

  const [certificates, setCertificates] = useState<DisplayCertificate[]>([]);
  const [loading, setLoading] = useState(true);
  const [copiedId, setCopiedId] = useState<string | null>(null);
  const [downloadingId, setDownloadingId] = useState<string | null>(null);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    void fetchCertificates();
  }, []);

  async function fetchCertificates() {
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

      const [{ data: certs }, { data: elearningCerts }] = await Promise.all([
        supabase
          .from('certificates')
          .select(
            `
          id,
          issued_at,
          certificate_number,
          verification_code,
          cefr_level,
          pdf_url,
          exam_results (
            total_score,
            exam_sessions (title, exam_date)
          )
        `
          )
          .eq('learner_id', learner.id)
          .order('issued_at', { ascending: false }),
        supabase
          .from('elearning_certificates')
          .select(
            'id, learner_id, teacher_id, exam_score_id, level, certificate_number, pdf_path, issue_date'
          )
          .eq('learner_id', learner.id)
          .order('issue_date', { ascending: false }),
      ]);

      const officialMapped: OfficialCertificate[] = (certs ?? []).map(
        (c: any) => ({
          id: c.id,
          source: 'official' as const,
          cefr_level: c.cefr_level ?? 'A1',
          issued_at: c.issued_at,
          certificate_number:
            c.certificate_number ?? c.id.slice(0, 8).toUpperCase(),
          verification_code: c.verification_code ?? '',
          exam_title: c.exam_results?.exam_sessions?.title,
          exam_date: c.exam_results?.exam_sessions?.exam_date,
          pdf_url: c.pdf_url ?? null,
        })
      );

      const elearningMapped: LevelCertificate[] = (
        (elearningCerts as ElearningCertificate[]) ?? []
      ).map((c) => ({
        id: c.id,
        source: 'elearning' as const,
        cefr_level: c.level,
        issued_at: c.issue_date,
        certificate_number: c.certificate_number,
        pdf_path: c.pdf_path,
      }));

      const merged = [...officialMapped, ...elearningMapped].sort(
        (a, b) =>
          new Date(b.issued_at).getTime() - new Date(a.issued_at).getTime()
      );

      setCertificates(merged);
    } catch (err) {
      console.error(err);
    } finally {
      setLoading(false);
    }
  }

  function getVerifyUrl(cert: OfficialCertificate) {
    const base =
      typeof window !== 'undefined'
        ? window.location.origin
        : 'https://flehub.rw';
    return `${base}/verify/${cert.verification_code}`;
  }

  async function handleCopyVerify(cert: OfficialCertificate) {
    const url = getVerifyUrl(cert);
    try {
      await navigator.clipboard.writeText(url);
      setCopiedId(cert.id);
      setTimeout(() => setCopiedId(null), 2000);
    } catch {
      alert(url);
    }
  }

  async function handleDownload(cert: DisplayCertificate) {
    setError(null);
    setDownloadingId(cert.id);
    try {
      if (cert.source === 'elearning') {
        if (!cert.pdf_path) {
          setError('PDF non disponible pour ce certificat.');
          return;
        }
        const { data, error: dlErr } = await supabase.storage
          .from('elearning-certificates')
          .createSignedUrl(cert.pdf_path, 3600);
        if (dlErr || !data?.signedUrl) {
          setError('Impossible de télécharger le certificat.');
          return;
        }
        const a = document.createElement('a');
        a.href = data.signedUrl;
        a.download = `${cert.certificate_number}.pdf`;
        a.target = '_blank';
        a.rel = 'noopener noreferrer';
        a.click();
        return;
      }

      if (cert.pdf_url) {
        const a = document.createElement('a');
        a.href = cert.pdf_url;
        a.download = `${cert.certificate_number}.pdf`;
        a.target = '_blank';
        a.rel = 'noopener noreferrer';
        a.click();
        return;
      }

      setError('PDF generation coming soon');
    } finally {
      setDownloadingId(null);
    }
  }

  const elearningCount = certificates.filter((c) => c.source === 'elearning')
    .length;

  return (
    <div className="p-6 space-y-6 max-w-5xl mx-auto">
      <div>
        <h1 className="text-2xl font-bold text-gray-900">Certificats</h1>
        <p className="text-gray-500 text-sm mt-1">
          {loading
            ? '...'
            : `${certificates.length} certificat${certificates.length !== 1 ? 's' : ''} obtenu${certificates.length !== 1 ? 's' : ''}`}
        </p>
      </div>

      {error && (
        <div className="rounded-lg border border-red-200 bg-red-50 px-4 py-3 text-sm text-red-700">
          {error}
        </div>
      )}

      {loading ? (
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4">
          {Array.from({ length: 3 }).map((_, i) => (
            <Skeleton key={i} className="h-56 rounded-2xl" />
          ))}
        </div>
      ) : certificates.length === 0 ? (
        <div className="flex flex-col items-center justify-center py-24 text-gray-400">
          <div className="relative mb-4">
            <div className="w-20 h-20 rounded-full bg-gray-100 flex items-center justify-center">
              <Award className="w-10 h-10 opacity-30" />
            </div>
            <div className="absolute -bottom-1 -right-1 w-8 h-8 rounded-full bg-flehub-green-light flex items-center justify-center">
              <ShieldCheck className="w-4 h-4 text-flehub-green" />
            </div>
          </div>
          <p className="text-lg font-semibold text-gray-600 mb-1">
            Aucun certificat
          </p>
          <p className="text-sm text-center max-w-xs">
            Réussissez un examen ou validez un niveau avec votre enseignant pour
            obtenir un certificat.
          </p>
        </div>
      ) : (
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-5">
          {certificates.map((cert) => (
            <Card
              key={`${cert.source}-${cert.id}`}
              className={`bg-gradient-to-br ${cefrGradients[cert.cefr_level]} border-2 overflow-hidden`}
            >
              <CardContent className="pt-5 pb-4">
                <div className="flex items-start justify-between mb-4">
                  <div className="p-2.5 rounded-xl bg-white shadow-sm">
                    <Award className="w-7 h-7 text-amber-500" />
                  </div>
                  <div className="flex flex-col items-end gap-1">
                    <Badge
                      variant="outline"
                      className={`text-sm font-bold px-2.5 py-0.5 ${cefrColors[cert.cefr_level]}`}
                    >
                      {cert.cefr_level}
                    </Badge>
                    <span className="text-[10px] uppercase tracking-wide text-gray-500">
                      {cert.source === 'elearning'
                        ? 'Parcours individuel'
                        : 'Examen officiel'}
                    </span>
                  </div>
                </div>

                <div className="mb-4">
                  <p className="text-xs font-semibold text-gray-400 uppercase tracking-wider mb-0.5">
                    Certificat de niveau
                  </p>
                  <p className="text-lg font-bold text-gray-900">
                    Niveau {cert.cefr_level}
                  </p>
                  <p className="text-xs text-gray-500 mt-0.5">
                    {cefrDescriptions[cert.cefr_level]}
                  </p>
                </div>

                <div className="space-y-1.5 mb-4">
                  <div className="flex items-center gap-1.5 text-xs text-gray-600">
                    <Calendar className="w-3.5 h-3.5 text-gray-400 shrink-0" />
                    <span>
                      Délivré le{' '}
                      {new Date(cert.issued_at).toLocaleDateString('fr-FR', {
                        year: 'numeric',
                        month: 'long',
                        day: 'numeric',
                      })}
                    </span>
                  </div>
                  {cert.source === 'official' && cert.exam_date && (
                    <div className="flex items-center gap-1.5 text-xs text-gray-600">
                      <Calendar className="w-3.5 h-3.5 text-gray-400 shrink-0" />
                      <span>
                        Exam:{' '}
                        {new Date(cert.exam_date).toLocaleDateString('fr-FR', {
                          year: 'numeric',
                          month: 'short',
                          day: 'numeric',
                        })}
                      </span>
                    </div>
                  )}
                  <div className="flex items-center gap-1.5 text-xs text-gray-600">
                    <Hash className="w-3.5 h-3.5 text-gray-400 shrink-0" />
                    <span className="font-mono font-medium">
                      {cert.certificate_number}
                    </span>
                  </div>
                  {cert.source === 'official' && cert.verification_code && (
                    <div className="flex items-center gap-1.5 text-xs text-gray-600">
                      <ShieldCheck className="w-3.5 h-3.5 text-gray-400 shrink-0" />
                      <span className="font-mono">{cert.verification_code}</span>
                    </div>
                  )}
                </div>

                <div className="border-t border-dashed border-gray-300 my-3" />

                <div className="flex gap-2">
                  <Button
                    size="sm"
                    variant="outline"
                    className="flex-1 text-xs bg-white hover:bg-gray-50 h-8"
                    disabled={downloadingId === cert.id}
                    onClick={() => void handleDownload(cert)}
                  >
                    <Download className="w-3.5 h-3.5 mr-1" />
                    {downloadingId === cert.id ? '…' : 'Télécharger PDF'}
                  </Button>
                  {cert.source === 'official' && (
                    <Button
                      size="sm"
                      variant="outline"
                      className={`flex-1 text-xs h-8 ${
                        copiedId === cert.id
                          ? 'bg-flehub-green-light text-flehub-green border-flehub-green'
                          : 'bg-white hover:bg-gray-50'
                      }`}
                      onClick={() => void handleCopyVerify(cert)}
                    >
                      {copiedId === cert.id ? (
                        <>
                          <CheckCheck className="w-3.5 h-3.5 mr-1" />
                          Copié !
                        </>
                      ) : (
                        <>
                          <Copy className="w-3.5 h-3.5 mr-1" />
                          Vérifier
                        </>
                      )}
                    </Button>
                  )}
                </div>
              </CardContent>
            </Card>
          ))}
        </div>
      )}

      {elearningCount > 0 && (
        <div className="flex items-start gap-3 p-4 rounded-xl bg-gray-50 border border-gray-200">
          <Award className="w-5 h-5 text-flehub-green mt-0.5 shrink-0" />
          <div>
            <p className="text-sm font-medium text-gray-800">
              Certificats de parcours individuel
            </p>
            <p className="text-xs text-gray-500 mt-0.5">
              Ces certificats sont délivrés par votre enseignant après saisie
              des 5 notes d’examen papier pour un niveau CECRL.
            </p>
          </div>
        </div>
      )}
    </div>
  );
}
