'use client';

import { useCallback, useEffect, useMemo, useState } from 'react';
import Link from 'next/link';
import { useParams, useRouter } from 'next/navigation';
import { createClient } from '@/lib/supabase/client';
import { Card, CardContent } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Badge } from '@/components/ui/badge';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import { Textarea } from '@/components/ui/textarea';
import { Skeleton } from '@/components/ui/skeleton';
import { Slider } from '@/components/ui/slider';
import {
  AlertTriangle,
  ArrowLeft,
  CheckCircle2,
  Loader2,
  Mic,
  Trophy,
  X,
} from 'lucide-react';

const SCORE_TOTAL_MAX = 60;

const CRITERIA = [
  {
    key: 'score_interaction',
    label: 'Interaction / spontanéité',
    hint: 'Écoute, réactivité, capacité à échanger',
  },
  {
    key: 'score_fluidite',
    label: 'Aisance et fluidité',
    hint: 'Débit, hésitations, naturel',
  },
  {
    key: 'score_structure',
    label: 'Structuration du discours',
    hint: 'Organisation, enchaînements, clarté',
  },
  {
    key: 'score_vocabulaire',
    label: 'Richesse du vocabulaire',
    hint: 'Précision, variété, adéquation',
  },
  {
    key: 'score_grammaire',
    label: 'Correction grammaticale',
    hint: 'Morphosyntaxe, accords, constructions',
  },
  {
    key: 'score_prononciation',
    label: 'Prononciation',
    hint: 'Articulation, intonation, intelligibilité',
  },
] as const;

type ScoreKey = (typeof CRITERIA)[number]['key'];

type ScoreForm = Record<ScoreKey, string>;

interface EvaluationInfo {
  id: string;
  session_id: string;
  student_id: string;
  student_name: string;
  session_titre: string;
  evaluated_at: string | null;
  commentaire_general: string;
}

const emptyScores = (): ScoreForm => ({
  score_interaction: '',
  score_fluidite: '',
  score_structure: '',
  score_vocabulaire: '',
  score_grammaire: '',
  score_prononciation: '',
});

function parseScore(raw: string): number | null {
  if (raw.trim() === '') return null;
  const n = Number.parseInt(raw, 10);
  if (!Number.isFinite(n)) return null;
  return Math.min(10, Math.max(0, n));
}

function scoreFromDb(value: number | null | undefined): string {
  if (value === null || value === undefined) return '';
  return String(value);
}

export default function TcfEoEvaluationEditor() {
  const params = useParams();
  const router = useRouter();
  const evaluationId = params.evaluationId as string;
  const supabase = useMemo(() => createClient(), []);

  const [evaluation, setEvaluation] = useState<EvaluationInfo | null>(null);
  const [scores, setScores] = useState<ScoreForm>(emptyScores);
  const [commentaire, setCommentaire] = useState('');
  const [loading, setLoading] = useState(true);
  const [saving, setSaving] = useState(false);
  const [publishing, setPublishing] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [success, setSuccess] = useState<string | null>(null);

  const loadData = useCallback(async () => {
    try {
      setError(null);
      const { data, error: evalError } = await supabase
        .from('student_eo_evaluations')
        .select(
          `
          id,
          session_id,
          student_id,
          evaluated_at,
          commentaire_general,
          score_interaction,
          score_fluidite,
          score_structure,
          score_vocabulaire,
          score_grammaire,
          score_prononciation
        `
        )
        .eq('id', evaluationId)
        .maybeSingle();

      if (evalError) throw evalError;
      if (!data) {
        setError('Évaluation introuvable.');
        setEvaluation(null);
        return;
      }

      const { data: sessionData, error: sessionError } = await supabase
        .from('tcf_eo_sessions')
        .select('id, titre')
        .eq('id', data.session_id)
        .maybeSingle();
      if (sessionError) throw sessionError;

      let studentName = 'Apprenant';
      const { data: profile } = await supabase
        .from('profiles')
        .select('full_name')
        .eq('id', data.student_id)
        .maybeSingle();
      if (profile?.full_name?.trim()) {
        studentName = profile.full_name.trim();
      }

      setEvaluation({
        id: data.id,
        session_id: data.session_id,
        student_id: data.student_id,
        student_name: studentName,
        session_titre: sessionData?.titre ?? 'Séance EO',
        evaluated_at: data.evaluated_at,
        commentaire_general: data.commentaire_general ?? '',
      });

      setScores({
        score_interaction: scoreFromDb(data.score_interaction),
        score_fluidite: scoreFromDb(data.score_fluidite),
        score_structure: scoreFromDb(data.score_structure),
        score_vocabulaire: scoreFromDb(data.score_vocabulaire),
        score_grammaire: scoreFromDb(data.score_grammaire),
        score_prononciation: scoreFromDb(data.score_prononciation),
      });
      setCommentaire(data.commentaire_general ?? '');
    } catch (err) {
      console.error(err);
      setError(
        err instanceof Error
          ? err.message
          : 'Impossible de charger l’évaluation.'
      );
    } finally {
      setLoading(false);
    }
  }, [evaluationId, supabase]);

  useEffect(() => {
    if (evaluationId) void loadData();
  }, [evaluationId, loadData]);

  function updateScore(key: ScoreKey, value: string) {
    setScores((prev) => ({ ...prev, [key]: value }));
    setSuccess(null);
  }

  const parsedScores = useMemo(() => {
    const result = {} as Record<ScoreKey, number | null>;
    for (const criterion of CRITERIA) {
      result[criterion.key] = parseScore(scores[criterion.key]);
    }
    return result;
  }, [scores]);

  const allScoresFilled = useMemo(
    () => CRITERIA.every((c) => parsedScores[c.key] !== null),
    [parsedScores]
  );

  const total = useMemo(
    () =>
      CRITERIA.reduce((sum, c) => sum + (parsedScores[c.key] ?? 0), 0),
    [parsedScores]
  );

  const pourcentage = Math.round((total / SCORE_TOTAL_MAX) * 100);

  async function persist(options: { publish: boolean }) {
    const {
      data: { user },
    } = await supabase.auth.getUser();
    if (!user) {
      throw new Error('Session expirée. Reconnectez-vous.');
    }

    for (const criterion of CRITERIA) {
      const raw = scores[criterion.key];
      if (raw.trim() !== '' && parseScore(raw) === null) {
        throw new Error(
          `Score invalide pour « ${criterion.label} » (0 à 10).`
        );
      }
    }

    if (options.publish) {
      for (const criterion of CRITERIA) {
        if (parsedScores[criterion.key] === null) {
          throw new Error(
            'Remplissez les 6 scores avant de publier l’évaluation.'
          );
        }
      }
    }

    const payload = {
      score_interaction: parsedScores.score_interaction,
      score_fluidite: parsedScores.score_fluidite,
      score_structure: parsedScores.score_structure,
      score_vocabulaire: parsedScores.score_vocabulaire,
      score_grammaire: parsedScores.score_grammaire,
      score_prononciation: parsedScores.score_prononciation,
      commentaire_general: commentaire.trim() || null,
      evaluated_by: user.id,
      evaluated_at: options.publish ? new Date().toISOString() : null,
    };

    const { error: updateError } = await supabase
      .from('student_eo_evaluations')
      .update(payload)
      .eq('id', evaluationId);
    if (updateError) throw updateError;
  }

  async function handleSaveDraft() {
    setSaving(true);
    setError(null);
    setSuccess(null);
    try {
      await persist({ publish: false });
      setSuccess(
        'Brouillon enregistré. L’apprenant ne voit pas encore cette évaluation.'
      );
      await loadData();
    } catch (err) {
      console.error(err);
      setError(
        err instanceof Error
          ? err.message
          : 'Impossible d’enregistrer le brouillon.'
      );
    } finally {
      setSaving(false);
    }
  }

  async function handlePublish() {
    if (!evaluation || !allScoresFilled) return;
    setPublishing(true);
    setError(null);
    setSuccess(null);
    try {
      await persist({ publish: true });
      router.push(
        `/dashboard/teacher/preparation/tcf-eo/${evaluation.session_id}/evaluations?published=1`
      );
    } catch (err) {
      console.error(err);
      setError(
        err instanceof Error
          ? err.message
          : 'Impossible de publier l’évaluation.'
      );
    } finally {
      setPublishing(false);
    }
  }

  if (loading) {
    return (
      <div className="p-6 space-y-6 max-w-3xl mx-auto">
        <Skeleton className="h-8 w-72" />
        <Skeleton className="h-24 w-full" />
        <Skeleton className="h-64 w-full" />
      </div>
    );
  }

  if (!evaluation) {
    return (
      <div className="p-6 space-y-4 max-w-3xl mx-auto">
        <Link
          href="/dashboard/teacher/preparation"
          className="inline-flex items-center gap-1.5 text-sm text-gray-500 hover:text-flehub-green"
        >
          <ArrowLeft className="w-4 h-4" />
          Retour à Préparation
        </Link>
        <div className="flex items-center gap-2 rounded-lg bg-red-50 border border-red-200 px-4 py-3 text-sm text-red-700">
          <AlertTriangle className="w-4 h-4 flex-shrink-0" />
          {error || 'Évaluation introuvable.'}
        </div>
      </div>
    );
  }

  return (
    <div className="p-6 space-y-6 max-w-3xl mx-auto">
      <div>
        <Link
          href={`/dashboard/teacher/preparation/tcf-eo/${evaluation.session_id}/evaluations`}
          className="inline-flex items-center gap-1.5 text-sm text-gray-500 hover:text-flehub-green mb-3"
        >
          <ArrowLeft className="w-4 h-4" />
          Retour aux évaluations
        </Link>
        <div className="flex items-center gap-2 flex-wrap">
          <h1 className="text-2xl font-bold text-gray-900">
            Évaluation — {evaluation.student_name}
          </h1>
          <Badge
            variant="outline"
            className="bg-violet-100 text-violet-800 border-violet-200"
          >
            EO
          </Badge>
          <Badge
            variant="outline"
            className={
              evaluation.evaluated_at
                ? 'bg-flehub-green-light text-flehub-green border-flehub-green'
                : 'bg-gray-100 text-gray-600 border-gray-300'
            }
          >
            {evaluation.evaluated_at ? 'Publiée' : 'Brouillon'}
          </Badge>
        </div>
        <p className="text-sm text-gray-500 mt-1">{evaluation.session_titre}</p>
      </div>

      <Card className="border-violet-100 bg-violet-50/30">
        <CardContent className="p-4 flex items-center gap-3">
          <div className="p-2 rounded-lg bg-violet-100">
            <Trophy className="w-4 h-4 text-violet-700" />
          </div>
          <div>
            <p className="text-sm text-gray-500">Total en direct</p>
            <p className="text-xl font-bold text-gray-900">
              {total}/{SCORE_TOTAL_MAX}{' '}
              <span className="text-sm font-semibold text-violet-700">
                ({pourcentage}%)
              </span>
            </p>
          </div>
        </CardContent>
      </Card>

      {error && (
        <div className="flex items-center gap-2 rounded-lg bg-red-50 border border-red-200 px-4 py-3 text-sm text-red-700">
          <AlertTriangle className="w-4 h-4 flex-shrink-0" />
          <span className="flex-1">{error}</span>
          <button type="button" onClick={() => setError(null)}>
            <X className="w-4 h-4" />
          </button>
        </div>
      )}
      {success && (
        <div className="flex items-center gap-2 rounded-lg bg-flehub-green-light border border-flehub-green/30 px-4 py-3 text-sm text-flehub-green">
          <CheckCircle2 className="w-4 h-4 flex-shrink-0" />
          <span className="flex-1">{success}</span>
          <button type="button" onClick={() => setSuccess(null)}>
            <X className="w-4 h-4" />
          </button>
        </div>
      )}

      <Card>
        <CardContent className="p-6 space-y-6">
          <div className="flex items-center gap-2">
            <div className="p-2 rounded-lg bg-violet-50">
              <Mic className="w-4 h-4 text-violet-700" />
            </div>
            <h2 className="text-lg font-semibold text-gray-900">
              Grille de notation
            </h2>
          </div>

          <div className="space-y-5">
            {CRITERIA.map((criterion) => {
              const value = parsedScores[criterion.key];
              return (
                <div
                  key={criterion.key}
                  className="rounded-lg border border-gray-100 p-4 space-y-3"
                >
                  <div className="flex items-start justify-between gap-3">
                    <div>
                      <Label className="text-sm font-semibold text-gray-900">
                        {criterion.label}
                      </Label>
                      <p className="text-xs text-gray-400 mt-0.5">
                        {criterion.hint}
                      </p>
                    </div>
                    <Input
                      type="number"
                      min={0}
                      max={10}
                      step={1}
                      value={scores[criterion.key]}
                      onChange={(e) =>
                        updateScore(criterion.key, e.target.value)
                      }
                      className="w-20 h-8 text-center"
                      disabled={saving || publishing}
                    />
                  </div>
                  <Slider
                    min={0}
                    max={10}
                    step={1}
                    value={[value ?? 0]}
                    onValueChange={(v) =>
                      updateScore(criterion.key, String(v[0] ?? 0))
                    }
                    disabled={saving || publishing}
                  />
                </div>
              );
            })}
          </div>

          <div className="space-y-2">
            <Label htmlFor="commentaire_general">Commentaire général</Label>
            <Textarea
              id="commentaire_general"
              value={commentaire}
              onChange={(e) => {
                setCommentaire(e.target.value);
                setSuccess(null);
              }}
              rows={4}
              placeholder="Points forts, axes de progrès, conseils pour le prochain passage…"
              disabled={saving || publishing}
            />
          </div>
        </CardContent>
      </Card>

      <Card>
        <CardContent className="p-6 flex flex-col sm:flex-row sm:items-center gap-3 justify-between">
          <div>
            <p className="text-sm font-medium text-gray-900">
              {allScoresFilled
                ? 'Les 6 critères sont notés — vous pouvez publier.'
                : 'Remplissez les 6 scores (0–10) pour pouvoir publier.'}
            </p>
            <p className="text-xs text-gray-500 mt-1">
              Le brouillon n’est pas visible par l’apprenant tant que
              l’évaluation n’est pas publiée.
            </p>
          </div>
          <div className="flex flex-col sm:flex-row gap-2 shrink-0">
            <Button
              type="button"
              variant="outline"
              onClick={() => void handleSaveDraft()}
              disabled={saving || publishing}
            >
              {saving ? (
                <>
                  <Loader2 className="w-4 h-4 mr-1.5 animate-spin" />
                  Enregistrement…
                </>
              ) : (
                'Enregistrer le brouillon'
              )}
            </Button>
            <Button
              type="button"
              className="bg-violet-700 hover:bg-violet-800 text-white"
              onClick={() => void handlePublish()}
              disabled={!allScoresFilled || saving || publishing}
            >
              {publishing ? (
                <>
                  <Loader2 className="w-4 h-4 mr-1.5 animate-spin" />
                  Publication…
                </>
              ) : (
                'Publier l’évaluation'
              )}
            </Button>
          </div>
        </CardContent>
      </Card>
    </div>
  );
}
