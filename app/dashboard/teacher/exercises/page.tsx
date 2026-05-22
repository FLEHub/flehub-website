'use client';

import { useEffect, useState } from 'react';
import { createClient } from '@/lib/supabase/client';
import { Card, CardContent } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Badge } from '@/components/ui/badge';
import { Skeleton } from '@/components/ui/skeleton';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import { Textarea } from '@/components/ui/textarea';
import { Switch } from '@/components/ui/switch';
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
import { RadioGroup, RadioGroupItem } from '@/components/ui/radio-group';
import { Plus, ListChecks, PenSquare, Trash2, ChevronRight } from 'lucide-react';

type CEFR = 'A1' | 'A2' | 'B1' | 'B2' | 'C1' | 'C2';
type ExerciseType = 'qcm' | 'matching' | 'fill_blank' | 'short_answer';

interface Exercise {
  id: string;
  title: string;
  description: string;
  exercise_type: ExerciseType;
  cefr_level: CEFR;
  time_limit_minutes: number;
  is_published: boolean;
  created_at: string;
  question_count?: number;
}

interface QCMQuestion {
  question_text: string;
  option_a: string;
  option_b: string;
  option_c: string;
  option_d: string;
  correct_answer: 'A' | 'B' | 'C' | 'D';
  points: number;
}

interface FillBlankQuestion {
  question_text: string;
  correct_answer: string;
  points: number;
}

interface ShortAnswerQuestion {
  question_text: string;
  sample_answer: string;
  points: number;
}

interface MatchingQuestion {
  left_items: string[];
  right_items: string[];
  points: number;
}

type AnyQuestion = QCMQuestion | FillBlankQuestion | ShortAnswerQuestion | MatchingQuestion;

const cefrLevels: CEFR[] = ['A1', 'A2', 'B1', 'B2', 'C1', 'C2'];

const exerciseTypeLabels: Record<ExerciseType, string> = {
  qcm: 'QCM',
  matching: 'Matching',
  fill_blank: 'Fill Blank',
  short_answer: 'Short Answer',
};

const exerciseTypeColors: Record<ExerciseType, string> = {
  qcm: 'bg-blue-100 text-blue-700',
  matching: 'bg-teal-100 text-teal-700',
  fill_blank: 'bg-amber-100 text-amber-700',
  short_answer: 'bg-rose-100 text-rose-700',
};

const emptyExerciseForm = {
  title: '',
  description: '',
  exercise_type: '' as ExerciseType | '',
  cefr_level: '' as CEFR | '',
  time_limit_minutes: 30,
  is_published: false,
};

function emptyQuestion(type: ExerciseType): AnyQuestion {
  switch (type) {
    case 'qcm':
      return { question_text: '', option_a: '', option_b: '', option_c: '', option_d: '', correct_answer: 'A', points: 1 } as QCMQuestion;
    case 'fill_blank':
      return { question_text: '', correct_answer: '', points: 1 } as FillBlankQuestion;
    case 'short_answer':
      return { question_text: '', sample_answer: '', points: 1 } as ShortAnswerQuestion;
    case 'matching':
      return { left_items: ['', ''], right_items: ['', ''], points: 2 } as MatchingQuestion;
  }
}

export default function TeacherExercisesPage() {
  const supabase = createClient();

  const [exercises, setExercises] = useState<Exercise[]>([]);
  const [teacherId, setTeacherId] = useState<string | null>(null);
  const [loading, setLoading] = useState(true);
  const [saving, setSaving] = useState(false);

  // Exercise dialog
  const [exDialogOpen, setExDialogOpen] = useState(false);
  const [editingEx, setEditingEx] = useState<Exercise | null>(null);
  const [exForm, setExForm] = useState({ ...emptyExerciseForm });

  // Question dialog
  const [qDialogOpen, setQDialogOpen] = useState(false);
  const [selectedExercise, setSelectedExercise] = useState<Exercise | null>(null);
  const [question, setQuestion] = useState<AnyQuestion | null>(null);
  const [savingQ, setSavingQ] = useState(false);

  useEffect(() => {
    fetchData();
  }, []);

  async function fetchData() {
    try {
      const {
        data: { user },
      } = await supabase.auth.getUser();
      if (!user) return;

      const { data: teacher } = await supabase
        .from('teachers')
        .select('id')
        .eq('profile_id', user.id)
        .maybeSingle();

      if (!teacher) return;
      setTeacherId(teacher.id);

      const { data: exList } = await supabase
        .from('exercises')
        .select('*')
        .eq('teacher_id', teacher.id)
        .order('created_at', { ascending: false });

      // For each exercise, get question count
      const withCounts = await Promise.all(
        (exList ?? []).map(async (ex) => {
          const { count } = await supabase
            .from('exercise_questions')
            .select('*', { count: 'exact', head: true })
            .eq('exercise_id', ex.id);
          return { ...ex, question_count: count ?? 0 };
        })
      );

      setExercises(withCounts);
    } catch (err) {
      console.error(err);
    } finally {
      setLoading(false);
    }
  }

  function openCreateExercise() {
    setEditingEx(null);
    setExForm({ ...emptyExerciseForm });
    setExDialogOpen(true);
  }

  async function handleSaveExercise() {
    if (!teacherId || !exForm.title || !exForm.exercise_type || !exForm.cefr_level) return;
    setSaving(true);
    try {
      const payload = {
        title: exForm.title,
        description: exForm.description,
        exercise_type: exForm.exercise_type,
        cefr_level: exForm.cefr_level,
        time_limit_minutes: Number(exForm.time_limit_minutes),
        is_published: exForm.is_published,
        teacher_id: teacherId,
      };

      if (editingEx) {
        await supabase.from('exercises').update(payload).eq('id', editingEx.id);
      } else {
        await supabase.from('exercises').insert(payload);
      }

      setExDialogOpen(false);
      await fetchData();
    } catch (err) {
      console.error(err);
    } finally {
      setSaving(false);
    }
  }

  async function handleDeleteExercise(id: string) {
    await supabase.from('exercise_questions').delete().eq('exercise_id', id);
    await supabase.from('exercises').delete().eq('id', id);
    await fetchData();
  }

  function openAddQuestion(exercise: Exercise) {
    setSelectedExercise(exercise);
    setQuestion(emptyQuestion(exercise.exercise_type));
    setQDialogOpen(true);
  }

  async function handleSaveQuestion() {
    if (!selectedExercise || !question) return;
    setSavingQ(true);
    try {
      await supabase.from('exercise_questions').insert({
        exercise_id: selectedExercise.id,
        exercise_type: selectedExercise.exercise_type,
        question_data: question,
        points: (question as any).points ?? 1,
      });
      setQDialogOpen(false);
      await fetchData();
    } catch (err) {
      console.error(err);
    } finally {
      setSavingQ(false);
    }
  }

  function updateQ(patch: Partial<AnyQuestion>) {
    setQuestion((prev) => (prev ? { ...prev, ...patch } : prev));
  }

  function renderQuestionForm() {
    if (!selectedExercise || !question) return null;
    const type = selectedExercise.exercise_type;

    if (type === 'qcm') {
      const q = question as QCMQuestion;
      return (
        <div className="space-y-3">
          <div className="space-y-1">
            <Label>Question Text</Label>
            <Textarea
              rows={2}
              value={q.question_text}
              onChange={(e) => updateQ({ question_text: e.target.value } as any)}
              placeholder="Enter the question..."
            />
          </div>
          {(['A', 'B', 'C', 'D'] as const).map((opt) => (
            <div key={opt} className="space-y-1">
              <Label>Option {opt}</Label>
              <Input
                value={(q as any)[`option_${opt.toLowerCase()}`]}
                onChange={(e) => updateQ({ [`option_${opt.toLowerCase()}`]: e.target.value } as any)}
                placeholder={`Option ${opt}`}
              />
            </div>
          ))}
          <div className="space-y-1">
            <Label>Correct Answer</Label>
            <RadioGroup
              value={q.correct_answer}
              onValueChange={(v) => updateQ({ correct_answer: v as any })}
              className="flex gap-4"
            >
              {(['A', 'B', 'C', 'D'] as const).map((opt) => (
                <div key={opt} className="flex items-center gap-1.5">
                  <RadioGroupItem value={opt} id={`opt-${opt}`} />
                  <Label htmlFor={`opt-${opt}`}>{opt}</Label>
                </div>
              ))}
            </RadioGroup>
          </div>
          <div className="space-y-1">
            <Label>Points</Label>
            <Input
              type="number"
              min={1}
              value={q.points}
              onChange={(e) => updateQ({ points: parseInt(e.target.value) || 1 } as any)}
              className="w-24"
            />
          </div>
        </div>
      );
    }

    if (type === 'fill_blank') {
      const q = question as FillBlankQuestion;
      return (
        <div className="space-y-3">
          <div className="space-y-1">
            <Label>Question Text (use [BLANK] to mark the blank)</Label>
            <Textarea
              rows={2}
              value={q.question_text}
              onChange={(e) => updateQ({ question_text: e.target.value } as any)}
              placeholder="e.g. The cat [BLANK] on the mat."
            />
          </div>
          <div className="space-y-1">
            <Label>Correct Answer</Label>
            <Input
              value={q.correct_answer}
              onChange={(e) => updateQ({ correct_answer: e.target.value } as any)}
              placeholder="e.g. sat"
            />
          </div>
          <div className="space-y-1">
            <Label>Points</Label>
            <Input
              type="number"
              min={1}
              value={q.points}
              onChange={(e) => updateQ({ points: parseInt(e.target.value) || 1 } as any)}
              className="w-24"
            />
          </div>
        </div>
      );
    }

    if (type === 'short_answer') {
      const q = question as ShortAnswerQuestion;
      return (
        <div className="space-y-3">
          <div className="space-y-1">
            <Label>Question Text</Label>
            <Textarea
              rows={2}
              value={q.question_text}
              onChange={(e) => updateQ({ question_text: e.target.value } as any)}
              placeholder="Enter the question..."
            />
          </div>
          <div className="space-y-1">
            <Label>Sample Answer</Label>
            <Textarea
              rows={2}
              value={q.sample_answer}
              onChange={(e) => updateQ({ sample_answer: e.target.value } as any)}
              placeholder="Model answer for grading reference..."
            />
          </div>
          <div className="space-y-1">
            <Label>Points</Label>
            <Input
              type="number"
              min={1}
              value={q.points}
              onChange={(e) => updateQ({ points: parseInt(e.target.value) || 1 } as any)}
              className="w-24"
            />
          </div>
        </div>
      );
    }

    if (type === 'matching') {
      const q = question as MatchingQuestion;
      return (
        <div className="space-y-3">
          <div className="grid grid-cols-2 gap-3">
            <div className="space-y-2">
              <Label>Left Items</Label>
              {q.left_items.map((item, i) => (
                <Input
                  key={i}
                  value={item}
                  onChange={(e) => {
                    const updated = [...q.left_items];
                    updated[i] = e.target.value;
                    updateQ({ left_items: updated } as any);
                  }}
                  placeholder={`Left ${i + 1}`}
                />
              ))}
              <Button
                variant="outline"
                size="sm"
                onClick={() => updateQ({ left_items: [...q.left_items, ''] } as any)}
              >
                + Add Left
              </Button>
            </div>
            <div className="space-y-2">
              <Label>Right Items (matching order)</Label>
              {q.right_items.map((item, i) => (
                <Input
                  key={i}
                  value={item}
                  onChange={(e) => {
                    const updated = [...q.right_items];
                    updated[i] = e.target.value;
                    updateQ({ right_items: updated } as any);
                  }}
                  placeholder={`Right ${i + 1}`}
                />
              ))}
              <Button
                variant="outline"
                size="sm"
                onClick={() => updateQ({ right_items: [...q.right_items, ''] } as any)}
              >
                + Add Right
              </Button>
            </div>
          </div>
          <div className="space-y-1">
            <Label>Total Points</Label>
            <Input
              type="number"
              min={1}
              value={q.points}
              onChange={(e) => updateQ({ points: parseInt(e.target.value) || 1 } as any)}
              className="w-24"
            />
          </div>
        </div>
      );
    }

    return null;
  }

  return (
    <div className="p-6 space-y-6 max-w-5xl mx-auto">
      {/* Header */}
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-2xl font-bold text-gray-900">My Exercises</h1>
          <p className="text-gray-500 text-sm mt-1">{exercises.length} exercise{exercises.length !== 1 ? 's' : ''}</p>
        </div>
        <Button
          className="bg-flehub-green hover:bg-flehub-green/90 text-white"
          onClick={openCreateExercise}
        >
          <Plus className="w-4 h-4 mr-2" />
          Create Exercise
        </Button>
      </div>

      {/* Exercise List */}
      {loading ? (
        <div className="space-y-3">
          {Array.from({ length: 5 }).map((_, i) => (
            <Skeleton key={i} className="h-20 rounded-xl" />
          ))}
        </div>
      ) : exercises.length === 0 ? (
        <div className="flex flex-col items-center justify-center py-20 text-gray-400">
          <ListChecks className="w-12 h-12 mb-3 opacity-40" />
          <p className="text-lg font-medium">No exercises yet</p>
          <p className="text-sm">Create your first exercise to get started</p>
        </div>
      ) : (
        <div className="space-y-3">
          {exercises.map((ex) => (
            <Card key={ex.id} className="card-hover">
              <CardContent className="py-4 flex items-center justify-between gap-4 flex-wrap">
                <div className="flex items-center gap-3 min-w-0">
                  <div className="p-2 rounded-lg bg-flehub-green-light shrink-0">
                    <PenSquare className="w-4 h-4 text-flehub-green" />
                  </div>
                  <div className="min-w-0">
                    <p className="font-semibold text-gray-900 truncate">{ex.title}</p>
                    <p className="text-xs text-gray-500 mt-0.5 truncate max-w-sm">{ex.description}</p>
                    <div className="flex flex-wrap gap-1.5 mt-1.5">
                      <Badge className={`text-xs ${exerciseTypeColors[ex.exercise_type]}`} variant="secondary">
                        {exerciseTypeLabels[ex.exercise_type]}
                      </Badge>
                      <Badge variant="secondary" className="text-xs bg-gray-100 text-gray-600">
                        {ex.cefr_level}
                      </Badge>
                      <Badge variant="secondary" className="text-xs bg-gray-100 text-gray-600">
                        {ex.time_limit_minutes} min
                      </Badge>
                      <Badge variant="secondary" className="text-xs bg-gray-100 text-gray-600">
                        {ex.question_count} question{ex.question_count !== 1 ? 's' : ''}
                      </Badge>
                      <Badge
                        variant="outline"
                        className={`text-xs ${
                          ex.is_published
                            ? 'border-flehub-green text-flehub-green'
                            : 'border-gray-300 text-gray-400'
                        }`}
                      >
                        {ex.is_published ? 'Published' : 'Draft'}
                      </Badge>
                    </div>
                  </div>
                </div>
                <div className="flex items-center gap-2 shrink-0">
                  <Button
                    variant="outline"
                    size="sm"
                    className="text-flehub-green border-flehub-green hover:bg-flehub-green-light"
                    onClick={() => openAddQuestion(ex)}
                  >
                    <Plus className="w-3.5 h-3.5 mr-1" />
                    Add Question
                  </Button>
                  <Button
                    variant="ghost"
                    size="sm"
                    className="text-gray-600 hover:bg-gray-100"
                    onClick={() => {
                      setEditingEx(ex);
                      setExForm({
                        title: ex.title,
                        description: ex.description,
                        exercise_type: ex.exercise_type,
                        cefr_level: ex.cefr_level,
                        time_limit_minutes: ex.time_limit_minutes,
                        is_published: ex.is_published,
                      });
                      setExDialogOpen(true);
                    }}
                  >
                    <PenSquare className="w-3.5 h-3.5" />
                  </Button>
                  <Button
                    variant="ghost"
                    size="sm"
                    className="text-red-500 hover:bg-red-50"
                    onClick={() => handleDeleteExercise(ex.id)}
                  >
                    <Trash2 className="w-3.5 h-3.5" />
                  </Button>
                </div>
              </CardContent>
            </Card>
          ))}
        </div>
      )}

      {/* Create / Edit Exercise Dialog */}
      <Dialog open={exDialogOpen} onOpenChange={setExDialogOpen}>
        <DialogContent className="max-w-md">
          <DialogHeader>
            <DialogTitle>{editingEx ? 'Edit Exercise' : 'Create Exercise'}</DialogTitle>
          </DialogHeader>
          <div className="space-y-4 py-2">
            <div className="space-y-1">
              <Label>Title <span className="text-red-500">*</span></Label>
              <Input
                placeholder="e.g. Present Tense Practice"
                value={exForm.title}
                onChange={(e) => setExForm({ ...exForm, title: e.target.value })}
              />
            </div>
            <div className="space-y-1">
              <Label>Description</Label>
              <Textarea
                rows={2}
                placeholder="Brief description..."
                value={exForm.description}
                onChange={(e) => setExForm({ ...exForm, description: e.target.value })}
              />
            </div>
            <div className="grid grid-cols-2 gap-3">
              <div className="space-y-1">
                <Label>Type <span className="text-red-500">*</span></Label>
                <Select
                  value={exForm.exercise_type}
                  onValueChange={(v) => setExForm({ ...exForm, exercise_type: v as ExerciseType })}
                >
                  <SelectTrigger>
                    <SelectValue placeholder="Select type" />
                  </SelectTrigger>
                  <SelectContent>
                    {(Object.entries(exerciseTypeLabels) as [ExerciseType, string][]).map(([k, v]) => (
                      <SelectItem key={k} value={k}>
                        {v}
                      </SelectItem>
                    ))}
                  </SelectContent>
                </Select>
              </div>
              <div className="space-y-1">
                <Label>CEFR Level <span className="text-red-500">*</span></Label>
                <Select
                  value={exForm.cefr_level}
                  onValueChange={(v) => setExForm({ ...exForm, cefr_level: v as CEFR })}
                >
                  <SelectTrigger>
                    <SelectValue placeholder="Select level" />
                  </SelectTrigger>
                  <SelectContent>
                    {cefrLevels.map((l) => (
                      <SelectItem key={l} value={l}>
                        {l}
                      </SelectItem>
                    ))}
                  </SelectContent>
                </Select>
              </div>
            </div>
            <div className="space-y-1">
              <Label>Time Limit (minutes)</Label>
              <Input
                type="number"
                min={1}
                value={exForm.time_limit_minutes}
                onChange={(e) =>
                  setExForm({ ...exForm, time_limit_minutes: parseInt(e.target.value) || 30 })
                }
                className="w-32"
              />
            </div>
            <div className="flex items-center gap-3">
              <Switch
                checked={exForm.is_published}
                onCheckedChange={(v) => setExForm({ ...exForm, is_published: v })}
                id="ex-published"
              />
              <Label htmlFor="ex-published" className="cursor-pointer">
                {exForm.is_published ? 'Published' : 'Draft'}
              </Label>
            </div>
          </div>
          <DialogFooter>
            <Button variant="outline" onClick={() => setExDialogOpen(false)}>
              Cancel
            </Button>
            <Button
              className="bg-flehub-green hover:bg-flehub-green/90 text-white"
              onClick={handleSaveExercise}
              disabled={saving || !exForm.title || !exForm.exercise_type || !exForm.cefr_level}
            >
              {saving ? 'Saving...' : editingEx ? 'Save Changes' : 'Create Exercise'}
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>

      {/* Add Question Dialog */}
      <Dialog open={qDialogOpen} onOpenChange={setQDialogOpen}>
        <DialogContent className="max-w-lg max-h-[90vh] overflow-y-auto">
          <DialogHeader>
            <DialogTitle>
              Add Question
              {selectedExercise && (
                <span className="ml-2 text-sm font-normal text-gray-500">
                  — {exerciseTypeLabels[selectedExercise.exercise_type]}
                </span>
              )}
            </DialogTitle>
          </DialogHeader>
          <div className="py-2">{renderQuestionForm()}</div>
          <DialogFooter>
            <Button variant="outline" onClick={() => setQDialogOpen(false)}>
              Cancel
            </Button>
            <Button
              className="bg-flehub-green hover:bg-flehub-green/90 text-white"
              onClick={handleSaveQuestion}
              disabled={savingQ}
            >
              {savingQ ? 'Saving...' : 'Add Question'}
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>
    </div>
  );
}
