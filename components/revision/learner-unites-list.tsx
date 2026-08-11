'use client';

import { useEffect, useMemo, useState } from 'react';
import Link from 'next/link';
import { createClient } from '@/lib/supabase/client';
import { Card, CardContent } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Badge } from '@/components/ui/badge';
import { Skeleton } from '@/components/ui/skeleton';
import {
  AlertTriangle,
  ArrowLeft,
  BookOpen,
  ChevronRight,
  Download,
  FileText,
  Play,
} from 'lucide-react';

const PDF_BUCKET = 'revision-pdfs';

interface RevisionUnite {
  id: string;
  numero: number;
  titre: string;
}

interface RevisionPointRow {
  id: string;
  unite_id: string;
  numero: number;
  titre: string;
  questions_count: number;
  pdf_url: string | null;
  pdf_titre: string | null;
}

export default function LearnerRevisionUnitesList() {
  const supabase = useMemo(() => createClient(), []);
  const [unites, setUnites] = useState<RevisionUnite[]>([]);
  const [points, setPoints] = useState<RevisionPointRow[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [expandedUniteId, setExpandedUniteId] = useState<string | null>(null);
  const [openingPdfId, setOpeningPdfId] = useState<string | null>(null);

  useEffect(() => {
    async function load() {
      try {
        setError(null);
        const { data: unitesData, error: unitesError } = await supabase
          .from('revision_unites')
          .select('id, numero, titre')
          .order('numero', { ascending: true });
        if (unitesError) throw unitesError;

        const unitesList = (unitesData as RevisionUnite[]) ?? [];
        setUnites(unitesList);
        if (unitesList.length > 0) setExpandedUniteId(unitesList[0].id);

        const { data: pointsData, error: pointsError } = await supabase
          .from('revision_points')
          .select('id, unite_id, numero, titre')
          .order('numero', { ascending: true });
        if (pointsError) throw pointsError;

        const rawPoints =
          (pointsData as Omit<
            RevisionPointRow,
            'questions_count' | 'pdf_url' | 'pdf_titre'
          >[]) ?? [];
        const pointIds = rawPoints.map((p) => p.id);

        const questionCounts = new Map<string, number>();
        const pdfByPoint = new Map<
          string,
          { pdf_url: string; titre: string | null }
        >();

        if (pointIds.length > 0) {
          const [{ data: questionsData }, { data: ressourcesData }] =
            await Promise.all([
              supabase
                .from('revision_questions_pour_apprenants')
                .select('point_id')
                .in('point_id', pointIds),
              supabase
                .from('revision_ressources')
                .select('point_id, pdf_url, titre')
                .in('point_id', pointIds),
            ]);

          for (const q of questionsData ?? []) {
            const id = q.point_id as string;
            questionCounts.set(id, (questionCounts.get(id) ?? 0) + 1);
          }
          for (const r of ressourcesData ?? []) {
            pdfByPoint.set(r.point_id as string, {
              pdf_url: r.pdf_url as string,
              titre: (r.titre as string | null) ?? null,
            });
          }
        }

        setPoints(
          rawPoints.map((p) => {
            const pdf = pdfByPoint.get(p.id);
            return {
              ...p,
              questions_count: questionCounts.get(p.id) ?? 0,
              pdf_url: pdf?.pdf_url ?? null,
              pdf_titre: pdf?.titre ?? null,
            };
          })
        );
      } catch (err) {
        console.error(err);
        setError('Impossible de charger les unités de révision.');
      } finally {
        setLoading(false);
      }
    }
    void load();
  }, [supabase]);

  async function openPdf(point: RevisionPointRow) {
    if (!point.pdf_url) return;
    setOpeningPdfId(point.id);
    try {
      let url = point.pdf_url;
      if (!url.startsWith('http')) {
        const { data, error: signError } = await supabase.storage
          .from(PDF_BUCKET)
          .createSignedUrl(url, 3600);
        if (signError) throw signError;
        url = data.signedUrl;
      }
      window.open(url, '_blank', 'noopener,noreferrer');
    } catch (err) {
      console.error(err);
      setError('Impossible d’ouvrir la trace écrite.');
    } finally {
      setOpeningPdfId(null);
    }
  }

  return (
    <div className="p-6 space-y-6 max-w-4xl mx-auto">
      <div>
        <Link
          href="/dashboard/learner/preparation"
          className="inline-flex items-center gap-1.5 text-sm text-gray-500 hover:text-flehub-green mb-3"
        >
          <ArrowLeft className="w-4 h-4" />
          Retour à Préparation
        </Link>
        <h1 className="text-2xl font-bold text-gray-900">Révision</h1>
        <p className="text-gray-500 text-sm mt-1">
          Fiches et entraînements de grammaire / vocabulaire
        </p>
      </div>

      {error && (
        <div className="flex items-center gap-2 rounded-lg bg-red-50 border border-red-200 px-4 py-3 text-sm text-red-700">
          <AlertTriangle className="w-4 h-4 flex-shrink-0" />
          {error}
        </div>
      )}

      {loading ? (
        <div className="space-y-3">
          {Array.from({ length: 3 }).map((_, i) => (
            <Skeleton key={i} className="h-24 rounded-xl" />
          ))}
        </div>
      ) : unites.length === 0 ? (
        <Card className="border-dashed">
          <CardContent className="flex flex-col items-center justify-center py-16 text-center">
            <div className="p-3 rounded-lg bg-flehub-green-light mb-4">
              <BookOpen className="w-6 h-6 text-flehub-green" />
            </div>
            <h2 className="text-lg font-semibold text-gray-900">
              Aucune unité disponible
            </h2>
            <p className="text-sm text-gray-500 mt-1 max-w-sm">
              Les unités de révision apparaîtront ici dès qu’elles seront
              configurées.
            </p>
          </CardContent>
        </Card>
      ) : (
        <div className="space-y-4">
          {unites.map((unite) => {
            const unitePoints = points.filter((p) => p.unite_id === unite.id);
            const expanded = expandedUniteId === unite.id;
            return (
              <Card key={unite.id}>
                <CardContent className="p-0">
                  <button
                    type="button"
                    className="w-full flex items-center justify-between gap-3 p-5 text-left hover:bg-gray-50/80 transition-colors"
                    onClick={() =>
                      setExpandedUniteId(expanded ? null : unite.id)
                    }
                  >
                    <div className="flex items-center gap-3 min-w-0">
                      <div className="p-2 rounded-lg bg-flehub-green-light flex-shrink-0">
                        <BookOpen className="w-4 h-4 text-flehub-green" />
                      </div>
                      <div className="min-w-0">
                        <h2 className="font-semibold text-gray-900">
                          Unité {unite.numero} — {unite.titre}
                        </h2>
                        <p className="text-xs text-gray-500 mt-0.5">
                          {unitePoints.length} point
                          {unitePoints.length === 1 ? '' : 's'}
                        </p>
                      </div>
                    </div>
                    <ChevronRight
                      className={`w-5 h-5 text-gray-400 transition-transform ${
                        expanded ? 'rotate-90' : ''
                      }`}
                    />
                  </button>

                  {expanded && (
                    <div className="border-t border-gray-100 px-5 pb-5 space-y-3">
                      {unitePoints.length === 0 ? (
                        <p className="text-sm text-gray-500 pt-4">
                          Aucun point disponible pour cette unité.
                        </p>
                      ) : (
                        unitePoints.map((point) => {
                          const canTrain = point.questions_count === 10;
                          const hasPdf = Boolean(point.pdf_url);
                          return (
                            <div
                              key={point.id}
                              className="pt-3 space-y-2 border-b border-gray-50 last:border-0 pb-3 last:pb-0"
                            >
                              <div className="flex items-start justify-between gap-2">
                                <div className="min-w-0">
                                  <p className="text-sm font-medium text-gray-900">
                                    {point.numero}. {point.titre}
                                  </p>
                                  <div className="flex items-center gap-2 mt-1 flex-wrap">
                                    {canTrain ? (
                                      <Badge
                                        variant="outline"
                                        className="bg-flehub-green-light text-flehub-green border-flehub-green text-xs"
                                      >
                                        Entraînement prêt
                                      </Badge>
                                    ) : (
                                      <span className="text-xs text-gray-400">
                                        Questionnaire bientôt disponible
                                      </span>
                                    )}
                                    {hasPdf && (
                                      <span className="inline-flex items-center gap-1 text-xs text-gray-500">
                                        <FileText className="w-3 h-3" />
                                        Trace écrite
                                      </span>
                                    )}
                                  </div>
                                </div>
                              </div>
                              <div className="flex flex-col sm:flex-row gap-2">
                                <Button
                                  type="button"
                                  size="sm"
                                  variant="outline"
                                  disabled={!hasPdf || openingPdfId === point.id}
                                  onClick={() => void openPdf(point)}
                                >
                                  <Download className="w-4 h-4 mr-1.5" />
                                  {openingPdfId === point.id
                                    ? 'Ouverture…'
                                    : 'Réviser la fiche'}
                                </Button>
                                <Button
                                  asChild={canTrain}
                                  size="sm"
                                  disabled={!canTrain}
                                  className="bg-flehub-green hover:bg-flehub-green/90 text-white disabled:opacity-50"
                                >
                                  {canTrain ? (
                                    <Link
                                      href={`/dashboard/learner/preparation/revision/${point.id}/entrainement`}
                                    >
                                      <Play className="w-4 h-4 mr-1.5" />
                                      S&apos;entraîner
                                    </Link>
                                  ) : (
                                    <span>
                                      <Play className="w-4 h-4 mr-1.5 inline" />
                                      S&apos;entraîner
                                    </span>
                                  )}
                                </Button>
                              </div>
                            </div>
                          );
                        })
                      )}
                    </div>
                  )}
                </CardContent>
              </Card>
            );
          })}
        </div>
      )}
    </div>
  );
}
