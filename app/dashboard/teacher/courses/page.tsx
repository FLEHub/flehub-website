'use client';

import { useEffect, useState } from 'react';
import { createClient } from '@/lib/supabase/client';
import ResourceUploadForm from '@/components/teacher/ResourceUploadForm';
import { Card, CardContent, CardHeader } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Badge } from '@/components/ui/badge';
import { Skeleton } from '@/components/ui/skeleton';
import {
  Dialog,
  DialogContent,
  DialogHeader,
  DialogTitle,
  DialogFooter,
} from '@/components/ui/dialog';
import {
  Pencil,
  Trash2,
  BookOpen,
  Video,
  Volume2,
  FileText,
  AlignLeft,
  Filter,
  Upload,
} from 'lucide-react';

type CEFR = 'A1' | 'A2' | 'B1' | 'B2' | 'C1' | 'C2';
type Competency = 'EO' | 'EE' | 'CO' | 'CE' | 'EL';
type ContentType = 'video' | 'audio' | 'pdf' | 'text';

interface Course {
  id: string;
  title: string;
  description: string;
  cefr_level: CEFR;
  competency: Competency;
  content_type: ContentType;
  content_url: string;
  duration_minutes: number;
  is_published: boolean;
  created_at: string;
}

const cefrLevels: CEFR[] = ['A1', 'A2', 'B1', 'B2', 'C1', 'C2'];
const competencies: Competency[] = ['EO', 'EE', 'CO', 'CE', 'EL'];

const competencyLabels: Record<Competency, string> = {
  EO: 'Expression Orale',
  EE: 'Expression Ecrite',
  CO: 'Compréhension Orale',
  CE: 'Compréhension Ecrite',
  EL: 'Eléments Linguistiques',
};

const competencyColors: Record<Competency, string> = {
  EO: 'bg-blue-100 text-blue-700',
  EE: 'bg-orange-100 text-orange-700',
  CO: 'bg-teal-100 text-teal-700',
  CE: 'bg-rose-100 text-rose-700',
  EL: 'bg-amber-100 text-amber-700',
};

const contentTypeIcon: Record<ContentType, React.ElementType> = {
  video: Video,
  audio: Volume2,
  pdf: FileText,
  text: AlignLeft,
};

const cefrColors: Record<CEFR, string> = {
  A1: 'bg-green-100 text-green-700',
  A2: 'bg-lime-100 text-lime-700',
  B1: 'bg-yellow-100 text-yellow-700',
  B2: 'bg-orange-100 text-orange-700',
  C1: 'bg-red-100 text-red-700',
  C2: 'bg-rose-100 text-rose-700',
};

export default function TeacherCoursesPage() {
  const supabase = createClient();

  const [courses, setCourses] = useState<Course[]>([]);
  const [loading, setLoading] = useState(true);

  const [dialogOpen, setDialogOpen] = useState(false);

  const [filterCefr, setFilterCefr] = useState<CEFR | 'all'>('all');
  const [filterCompetency, setFilterCompetency] = useState<Competency | 'all'>('all');
  const [deleteConfirmId, setDeleteConfirmId] = useState<string | null>(null);

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

      const { data } = await supabase
        .from('courses')
        .select('*')
        .eq('teacher_id', teacher.id)
        .order('created_at', { ascending: false });

      setCourses(data ?? []);
    } catch (err) {
      console.error(err);
    } finally {
      setLoading(false);
    }
  }

  function openCreate() {
    setDialogOpen(true);
  }

  function closeModal() {
    setDialogOpen(false);
  }

  async function handleDelete(id: string) {
    await supabase.from('courses').delete().eq('id', id);
    setDeleteConfirmId(null);
    await fetchData();
  }

  const filtered = courses.filter((c) => {
    if (filterCefr !== 'all' && c.cefr_level !== filterCefr) return false;
    if (filterCompetency !== 'all' && c.competency !== filterCompetency) return false;
    return true;
  });

  return (
    <div className="p-6 space-y-6 max-w-7xl mx-auto">
      {/* Header */}
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-2xl font-bold text-gray-900">My Courses</h1>
          <p className="text-gray-500 text-sm mt-1">{courses.length} course{courses.length !== 1 ? 's' : ''} total</p>
        </div>
        <Button
          className="bg-flehub-green hover:bg-flehub-green/90 text-white"
          onClick={openCreate}
        >
          <Upload className="w-4 h-4 mr-2" />
          Upload New Course
        </Button>
      </div>

      {/* Filters */}
      <div className="flex flex-wrap items-center gap-2">
        <Filter className="w-4 h-4 text-gray-400" />
        <span className="text-sm text-gray-500">Filter:</span>
        <div className="flex flex-wrap gap-2">
          <Button
            variant={filterCefr === 'all' ? 'default' : 'outline'}
            size="sm"
            className={filterCefr === 'all' ? 'bg-flehub-green text-white' : ''}
            onClick={() => setFilterCefr('all')}
          >
            All Levels
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
        <div className="w-px h-5 bg-gray-200 mx-1" />
        <div className="flex flex-wrap gap-2">
          <Button
            variant={filterCompetency === 'all' ? 'default' : 'outline'}
            size="sm"
            className={filterCompetency === 'all' ? 'bg-flehub-green text-white' : ''}
            onClick={() => setFilterCompetency('all')}
          >
            All Skills
          </Button>
          {competencies.map((c) => (
            <Button
              key={c}
              variant={filterCompetency === c ? 'default' : 'outline'}
              size="sm"
              className={filterCompetency === c ? 'bg-flehub-green text-white' : ''}
              onClick={() => setFilterCompetency(c)}
            >
              {c}
            </Button>
          ))}
        </div>
      </div>

      {/* Course Grid */}
      {loading ? (
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-4">
          {Array.from({ length: 8 }).map((_, i) => (
            <Skeleton key={i} className="h-52 rounded-xl" />
          ))}
        </div>
      ) : filtered.length === 0 ? (
        <div className="flex flex-col items-center justify-center py-20 text-gray-400">
          <BookOpen className="w-12 h-12 mb-3 opacity-40" />
          <p className="text-lg font-medium">No courses found</p>
          <p className="text-sm">Upload your first course to get started</p>
        </div>
      ) : (
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-4">
          {filtered.map((course) => {
            const Icon = contentTypeIcon[course.content_type] ?? BookOpen;
            return (
              <Card key={course.id} className="card-hover flex flex-col">
                <CardHeader className="pb-2">
                  <div className="flex items-start justify-between gap-2">
                    <div className="p-2 rounded-lg bg-flehub-green-light">
                      <Icon className="w-5 h-5 text-flehub-green" />
                    </div>
                    <Badge
                      variant="outline"
                      className={`text-xs font-semibold ${
                        course.is_published
                          ? 'border-flehub-green text-flehub-green bg-flehub-green-light'
                          : 'border-gray-300 text-gray-400'
                      }`}
                    >
                      {course.is_published ? 'Published' : 'Draft'}
                    </Badge>
                  </div>
                  <h3 className="font-semibold text-gray-900 text-sm mt-2 leading-snug line-clamp-2">
                    {course.title}
                  </h3>
                </CardHeader>
                <CardContent className="flex flex-col flex-1 justify-between gap-3">
                  <p className="text-xs text-gray-500 line-clamp-2">{course.description}</p>
                  <div className="flex flex-wrap gap-1">
                    <Badge className={`text-xs ${cefrColors[course.cefr_level]}`} variant="secondary">
                      {course.cefr_level}
                    </Badge>
                    <Badge
                      className={`text-xs ${competencyColors[course.competency]}`}
                      variant="secondary"
                      title={competencyLabels[course.competency]}
                    >
                      {course.competency}
                    </Badge>
                    {course.duration_minutes > 0 && (
                      <Badge variant="secondary" className="text-xs bg-gray-100 text-gray-600">
                        {course.duration_minutes} min
                      </Badge>
                    )}
                  </div>
                  <div className="flex gap-2 pt-1 border-t border-gray-100">
                    <Button
                      variant="ghost"
                      size="sm"
                      className="flex-1 text-flehub-green hover:bg-flehub-green-light"
                      onClick={() => setDialogOpen(true)}
                    >
                      <Pencil className="w-3.5 h-3.5 mr-1" />
                      Edit
                    </Button>
                    <Button
                      variant="ghost"
                      size="sm"
                      className="flex-1 text-red-500 hover:bg-red-50"
                      onClick={() => setDeleteConfirmId(course.id)}
                    >
                      <Trash2 className="w-3.5 h-3.5 mr-1" />
                      Delete
                    </Button>
                  </div>
                </CardContent>
              </Card>
            );
          })}
        </div>
      )}

      {/* Create / Edit Dialog */}
      <Dialog open={dialogOpen} onOpenChange={setDialogOpen}>
        <DialogContent className="max-w-lg max-h-[90vh] overflow-y-auto">
          <ResourceUploadForm onSuccess={() => closeModal()} />
        </DialogContent>
      </Dialog>

      {/* Delete Confirmation Dialog */}
      <Dialog open={!!deleteConfirmId} onOpenChange={() => setDeleteConfirmId(null)}>
        <DialogContent className="max-w-sm">
          <DialogHeader>
            <DialogTitle>Delete Course?</DialogTitle>
          </DialogHeader>
          <p className="text-sm text-gray-500">
            This action cannot be undone. All learner progress for this course will also be removed.
          </p>
          <DialogFooter>
            <Button variant="outline" onClick={() => setDeleteConfirmId(null)}>
              Cancel
            </Button>
            <Button
              variant="destructive"
              onClick={() => deleteConfirmId && handleDelete(deleteConfirmId)}
            >
              Delete
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>
    </div>
  );
}
