'use client';

import { useEffect, useState } from 'react';
import { createClient } from '@/lib/supabase/client';
import { Button } from '@/components/ui/button';
import { Badge } from '@/components/ui/badge';
import { Card, CardContent, CardHeader } from '@/components/ui/card';
import {
  Dialog,
  DialogContent,
  DialogHeader,
  DialogTitle,
} from '@/components/ui/dialog';
import { RadioGroup, RadioGroupItem } from '@/components/ui/radio-group';
import { Label } from '@/components/ui/label';
import { Textarea } from '@/components/ui/textarea';
import { Input } from '@/components/ui/input';
import { ScrollArea } from '@/components/ui/scroll-area';
import {
  CheckCircle2,
  XCircle,
  Loader2,
  Trophy,
  BookOpenCheck,
  Clock,
  List,
} from 'lucide-react';

interface Exercise {
  id: string;
  title: string;
  type: 'qcm' | 'fill_blank' | 'short_answer';
  cefr_level: string;
  time_limit_minutes?: number;
  is_published: boolean;
  questions?: Question[];
}

interface Question {
  id: string;
  exercise_id: string;
  question_text: string;
  options?: string[];
  correct_answer?: string;
  points: number;
  order_index: number;
}

interface Answer {
  questionId: string;
  value: string;
}

const TYPE_COLORS: Record<string, string> = {
  qcm: 'bg-blue-100 text-blue-700',
  fill_blank: 'bg-purple-100 text-purple-700',
  short_answer: 'bg-amber-100 text-amber-700',
};

const TYPE_LABELS: Record<string, string> = {
  qcm: 'Multiple Choice',
  fill_blank: 'Fill in the Blank',
  short_answer: 'Short Answer',
};

const CEFR_ORDER = ['A1', 'A2', 'B1', 'B2', 'C1', 'C2'];

function groupByLevel(exercises: Exercise[]): Record<string, Exercise[]> {
  const map: Record<string, Exercise[]> = {};
  for (const ex of exercises) {
    if (!map[ex.cefr_level]) map[ex.cefr_level] = [];
    map[ex.cefr_level].push(ex);
  }
  return map;
}

export default function LearnerExercisesPage() {
  const supabase = createClient();

  const [currentUser, setCurrentUser] = useState<{ id: string } | null>(null);
  const [exercises, setExercises] = useState<Exercise[]>([]);
  const [loading, setLoading] = useState(true);
  const [activeExercise, setActiveExercise] = useState<Exercise | null>(null);
  const [questions, setQuestions] = useState<Question[]>([]);
  const [loadingQuestions, setLoadingQuestions] = useState(false);
  const [answers, setAnswers] = useState<Answer[]>([]);
  const [submitted, setSubmitted] = useState(false);
  const [score, setScore] = useState<{ earned: number; total: number } | null>(null);
  const [submitting, setSubmitting] = useState(false);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    const init = async () => {
      setLoading(true);
      const { data: { user } } = await supabase.auth.getUser();
      if (!user) { setLoading(false); return; }
      setCurrentUser({ id: user.id });

      const { data, error: fetchErr } = await supabase
        .from('exercises')
        .select('id,title,type,cefr_level,time_limit_minutes,is_published')
        .eq('is_published', true)
        .order('cefr_level')
        .order('title');

      if (fetchErr) setError('Failed to load exercises.');
      else setExercises((data as Exercise[]) || []);
      setLoading(false);
    };
    init();
  }, [supabase]);

  const openExercise = async (exercise: Exercise) => {
    setLoadingQuestions(true);
    setSubmitted(false);
    setScore(null);
    setAnswers([]);
    setActiveExercise(exercise);

    const { data, error: qErr } = await supabase
      .from('questions')
      .select('*')
      .eq('exercise_id', exercise.id)
      .order('order_index');

    if (qErr || !data) {
      setError('Failed to load questions.');
      setLoadingQuestions(false);
      return;
    }
    const qs = (data as Question[]).map((q) => ({
      ...q,
      options:
        typeof q.options === 'string'
          ? JSON.parse(q.options)
          : Array.isArray(q.options)
          ? q.options
          : [],
    }));
    setQuestions(qs);
    setAnswers(qs.map((q) => ({ questionId: q.id, value: '' })));
    setLoadingQuestions(false);
  };

  const setAnswer = (questionId: string, value: string) => {
    setAnswers((prev) =>
      prev.map((a) => (a.questionId === questionId ? { ...a, value } : a))
    );
  };

  const getAnswer = (questionId: string) =>
    answers.find((a) => a.questionId === questionId)?.value || '';

  const handleSubmit = async () => {
    if (!activeExercise || !currentUser) return;
    setSubmitting(true);

    let earned = 0;
    let total = 0;

    for (const q of questions) {
      total += q.points || 1;
      const ans = getAnswer(q.id).trim().toLowerCase();
      if (activeExercise.type === 'qcm' && q.correct_answer) {
        if (ans === q.correct_answer.toLowerCase()) earned += q.points || 1;
      }
      // fill_blank and short_answer: give credit if answered (manual grading scenario)
      if (activeExercise.type === 'fill_blank' && q.correct_answer) {
        if (ans === q.correct_answer.toLowerCase()) earned += q.points || 1;
      }
    }

    setScore({ earned, total });
    setSubmitted(true);

    // Upsert learner progress
    const { error: progressErr } = await supabase.from('learner_progress').upsert({
      learner_id: currentUser.id,
      exercise_id: activeExercise.id,
      status: 'completed',
      score: earned,
      max_score: total,
      completed_at: new Date().toISOString(),
    });

    if (progressErr) setError('Progress could not be saved.');
    setSubmitting(false);
  };

  const closeExercise = () => {
    setActiveExercise(null);
    setQuestions([]);
    setAnswers([]);
    setSubmitted(false);
    setScore(null);
  };

  const grouped = groupByLevel(exercises);
  const sortedLevels = CEFR_ORDER.filter((l) => grouped[l]);

  if (loading) {
    return (
      <div className="flex items-center justify-center min-h-[60vh]">
        <Loader2 className="h-8 w-8 animate-spin" style={{ color: '#00A550' }} />
      </div>
    );
  }

  return (
    <div className="p-6 max-w-5xl mx-auto space-y-6">
      <div>
        <h1 className="text-2xl font-bold">Exercises</h1>
        <p className="text-sm text-muted-foreground mt-1">
          Practice with exercises grouped by CEFR level
        </p>
      </div>

      {error && (
        <div className="bg-destructive/10 text-destructive px-4 py-2 rounded-lg text-sm">
          {error}
        </div>
      )}

      {sortedLevels.length === 0 ? (
        <div className="text-center py-16 text-muted-foreground">
          <BookOpenCheck className="h-12 w-12 mx-auto mb-3 opacity-20" />
          <p className="font-medium">No exercises available</p>
        </div>
      ) : (
        sortedLevels.map((level) => (
          <div key={level}>
            <div className="flex items-center gap-2 mb-3">
              <div
                className="text-white text-xs font-bold px-2.5 py-1 rounded-full"
                style={{ backgroundColor: '#00A550' }}
              >
                {level}
              </div>
              <div className="h-px flex-1 bg-border" />
            </div>
            <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4">
              {grouped[level].map((ex) => (
                <Card key={ex.id} className="hover:shadow-md transition-shadow">
                  <CardHeader className="pb-2 pt-4 px-4">
                    <div className="flex items-start justify-between gap-2">
                      <h3 className="font-semibold text-sm leading-tight line-clamp-2 flex-1">
                        {ex.title}
                      </h3>
                    </div>
                    <div className="flex flex-wrap gap-1.5 mt-2">
                      <span
                        className={`text-[10px] font-medium px-2 py-0.5 rounded-full ${TYPE_COLORS[ex.type] || 'bg-muted text-muted-foreground'}`}
                      >
                        {TYPE_LABELS[ex.type] || ex.type}
                      </span>
                    </div>
                  </CardHeader>
                  <CardContent className="px-4 pb-4">
                    <div className="flex items-center gap-3 text-xs text-muted-foreground mb-3">
                      {ex.time_limit_minutes && (
                        <span className="flex items-center gap-1">
                          <Clock className="h-3 w-3" />
                          {ex.time_limit_minutes} min
                        </span>
                      )}
                    </div>
                    <Button
                      size="sm"
                      className="w-full text-white text-xs"
                      style={{ backgroundColor: '#00A550' }}
                      onClick={() => openExercise(ex)}
                    >
                      Start Exercise
                    </Button>
                  </CardContent>
                </Card>
              ))}
            </div>
          </div>
        ))
      )}

      {/* Exercise Modal */}
      <Dialog open={!!activeExercise} onOpenChange={(open) => { if (!open) closeExercise(); }}>
        <DialogContent className="sm:max-w-2xl max-h-[90vh] flex flex-col p-0">
          <DialogHeader className="px-6 pt-6 pb-4 border-b shrink-0">
            <DialogTitle className="pr-6">{activeExercise?.title}</DialogTitle>
            {activeExercise && (
              <div className="flex items-center gap-2 mt-1">
                <Badge variant="outline" style={{ color: '#00A550', borderColor: '#00A550' }}>
                  {activeExercise.cefr_level}
                </Badge>
                <span
                  className={`text-[10px] font-medium px-2 py-0.5 rounded-full ${TYPE_COLORS[activeExercise.type]}`}
                >
                  {TYPE_LABELS[activeExercise.type]}
                </span>
                {activeExercise.time_limit_minutes && (
                  <span className="text-xs text-muted-foreground flex items-center gap-1">
                    <Clock className="h-3 w-3" />
                    {activeExercise.time_limit_minutes} min
                  </span>
                )}
              </div>
            )}
          </DialogHeader>

          <ScrollArea className="flex-1 px-6 py-4">
            {loadingQuestions ? (
              <div className="flex items-center justify-center py-12">
                <Loader2 className="h-6 w-6 animate-spin" style={{ color: '#00A550' }} />
              </div>
            ) : submitted && score ? (
              /* Result Screen */
              <div className="flex flex-col items-center justify-center py-8 space-y-4">
                {score.earned >= score.total * 0.7 ? (
                  <div className="h-20 w-20 rounded-full flex items-center justify-center bg-green-50">
                    <Trophy className="h-10 w-10 text-yellow-500" />
                  </div>
                ) : (
                  <div className="h-20 w-20 rounded-full flex items-center justify-center bg-muted">
                    <BookOpenCheck className="h-10 w-10 text-muted-foreground" />
                  </div>
                )}

                <div className="text-center">
                  <p className="text-3xl font-bold">
                    {score.earned}{' '}
                    <span className="text-muted-foreground text-xl font-normal">
                      / {score.total}
                    </span>
                  </p>
                  <p className="text-muted-foreground text-sm mt-1">
                    {score.total > 0
                      ? `${Math.round((score.earned / score.total) * 100)}% score`
                      : 'Submitted'}
                  </p>
                  <p className="font-medium mt-2">
                    {score.earned >= score.total * 0.8
                      ? 'Excellent work!'
                      : score.earned >= score.total * 0.5
                      ? 'Good effort!'
                      : 'Keep practicing!'}
                  </p>
                </div>

                {/* Per-question review */}
                {activeExercise?.type !== 'short_answer' && (
                  <div className="w-full mt-4 space-y-3">
                    <p className="text-sm font-semibold flex items-center gap-2">
                      <List className="h-4 w-4" />
                      Review
                    </p>
                    {questions.map((q, i) => {
                      const userAns = getAnswer(q.id).trim().toLowerCase();
                      const correct = q.correct_answer?.toLowerCase();
                      const isCorrect = correct ? userAns === correct : !!userAns;
                      return (
                        <div key={q.id} className="bg-muted/40 rounded-lg p-3 space-y-1">
                          <p className="text-sm font-medium">
                            Q{i + 1}. {q.question_text}
                          </p>
                          <div className="flex items-center gap-2 text-sm">
                            {isCorrect ? (
                              <CheckCircle2 className="h-4 w-4 text-green-500 shrink-0" />
                            ) : (
                              <XCircle className="h-4 w-4 text-red-500 shrink-0" />
                            )}
                            <span className={isCorrect ? 'text-green-700' : 'text-red-600'}>
                              Your answer: {getAnswer(q.id) || '(blank)'}
                            </span>
                          </div>
                          {!isCorrect && q.correct_answer && (
                            <p className="text-xs text-muted-foreground pl-6">
                              Correct: {q.correct_answer}
                            </p>
                          )}
                        </div>
                      );
                    })}
                  </div>
                )}
              </div>
            ) : (
              /* Question Form */
              <div className="space-y-6">
                {questions.length === 0 ? (
                  <p className="text-center text-muted-foreground py-8 text-sm">
                    No questions found for this exercise.
                  </p>
                ) : (
                  questions.map((q, i) => (
                    <div key={q.id} className="space-y-3">
                      <div className="flex items-start justify-between gap-4">
                        <p className="text-sm font-medium leading-relaxed">
                          <span
                            className="font-bold mr-2"
                            style={{ color: '#00A550' }}
                          >
                            {i + 1}.
                          </span>
                          {q.question_text}
                        </p>
                        <span className="text-xs text-muted-foreground shrink-0">
                          {q.points || 1} pt{(q.points || 1) !== 1 ? 's' : ''}
                        </span>
                      </div>

                      {activeExercise?.type === 'qcm' && Array.isArray(q.options) && q.options.length > 0 ? (
                        <RadioGroup
                          value={getAnswer(q.id)}
                          onValueChange={(v) => setAnswer(q.id, v)}
                          className="space-y-2 pl-5"
                        >
                          {q.options.map((opt: string, oi: number) => (
                            <div key={oi} className="flex items-center space-x-2">
                              <RadioGroupItem
                                value={opt}
                                id={`${q.id}-opt-${oi}`}
                                style={{ accentColor: '#00A550' }}
                              />
                              <Label
                                htmlFor={`${q.id}-opt-${oi}`}
                                className="text-sm cursor-pointer"
                              >
                                {opt}
                              </Label>
                            </div>
                          ))}
                        </RadioGroup>
                      ) : activeExercise?.type === 'fill_blank' ? (
                        <div className="pl-5">
                          <Input
                            placeholder="Fill in the blank..."
                            value={getAnswer(q.id)}
                            onChange={(e) => setAnswer(q.id, e.target.value)}
                            className="max-w-sm"
                          />
                        </div>
                      ) : activeExercise?.type === 'short_answer' ? (
                        <div className="pl-5">
                          <Textarea
                            placeholder="Write your answer..."
                            rows={3}
                            value={getAnswer(q.id)}
                            onChange={(e) => setAnswer(q.id, e.target.value)}
                          />
                        </div>
                      ) : null}

                      {i < questions.length - 1 && <div className="border-b" />}
                    </div>
                  ))
                )}
              </div>
            )}
          </ScrollArea>

          {/* Footer actions */}
          <div className="px-6 py-4 border-t shrink-0 flex items-center justify-between">
            {submitted ? (
              <>
                <p className="text-sm text-muted-foreground">
                  Progress saved
                </p>
                <Button
                  onClick={closeExercise}
                  className="text-white"
                  style={{ backgroundColor: '#00A550' }}
                >
                  Close
                </Button>
              </>
            ) : (
              <>
                <p className="text-xs text-muted-foreground">
                  {questions.length} question{questions.length !== 1 ? 's' : ''}
                </p>
                <div className="flex gap-2">
                  <Button variant="outline" onClick={closeExercise} size="sm">
                    Cancel
                  </Button>
                  <Button
                    onClick={handleSubmit}
                    disabled={
                      submitting ||
                      loadingQuestions ||
                      questions.length === 0
                    }
                    size="sm"
                    className="text-white"
                    style={{ backgroundColor: '#00A550' }}
                  >
                    {submitting && <Loader2 className="h-4 w-4 animate-spin mr-2" />}
                    Submit
                  </Button>
                </div>
              </>
            )}
          </div>
        </DialogContent>
      </Dialog>
    </div>
  );
}
