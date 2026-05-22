'use client';

import { useEffect, useState } from 'react';
import { createClient } from '@/lib/supabase/client';
import { Button } from '@/components/ui/button';
import { Badge } from '@/components/ui/badge';
import { Card, CardContent } from '@/components/ui/card';
import {
  Dialog,
  DialogContent,
  DialogHeader,
  DialogTitle,
} from '@/components/ui/dialog';
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from '@/components/ui/select';
import {
  BookOpen,
  Video,
  FileText,
  Headphones,
  Mic,
  Link as LinkIcon,
  Loader2,
  ExternalLink,
  Clock,
} from 'lucide-react';

interface Course {
  id: string;
  title: string;
  description?: string;
  cefr_level: string;
  competency: string;
  content_type: 'video' | 'pdf' | 'audio' | 'text' | 'link';
  content_url?: string;
  duration_minutes?: number;
  thumbnail_url?: string;
  is_published: boolean;
  teacher_id: string;
  teacher?: { full_name: string };
}

interface LearnerProgress {
  course_id: string;
  status: 'not_started' | 'in_progress' | 'completed';
}

const COMPETENCY_LABELS: Record<string, string> = {
  EO: 'Expression Orale',
  EE: 'Expression Écrite',
  CO: 'Compréhension Orale',
  CE: 'Compréhension Écrite',
  EL: 'Éléments Linguistiques',
};

const CONTENT_TYPE_ICONS: Record<string, React.ElementType> = {
  video: Video,
  pdf: FileText,
  audio: Headphones,
  text: BookOpen,
  link: LinkIcon,
};

const PROGRESS_STYLES: Record<string, { label: string; class: string }> = {
  not_started: { label: 'Not Started', class: 'bg-gray-100 text-gray-600' },
  in_progress: { label: 'In Progress', class: 'bg-amber-100 text-amber-700' },
  completed: { label: 'Completed', class: 'bg-green-100 text-green-700' },
};

const PEXELS_THUMBS = [
  'https://images.pexels.com/photos/256395/pexels-photo-256395.jpeg?auto=compress&cs=tinysrgb&w=400',
  'https://images.pexels.com/photos/159711/books-bookstore-book-reading-159711.jpeg?auto=compress&cs=tinysrgb&w=400',
  'https://images.pexels.com/photos/301926/pexels-photo-301926.jpeg?auto=compress&cs=tinysrgb&w=400',
  'https://images.pexels.com/photos/207691/pexels-photo-207691.jpeg?auto=compress&cs=tinysrgb&w=400',
  'https://images.pexels.com/photos/289737/pexels-photo-289737.jpeg?auto=compress&cs=tinysrgb&w=400',
];

const BG_COLORS = [
  'bg-green-200', 'bg-blue-200', 'bg-purple-200', 'bg-amber-200', 'bg-rose-200',
];

export default function LearnerCoursesPage() {
  const supabase = createClient();

  const [currentUser, setCurrentUser] = useState<{ id: string; cefr_level?: string } | null>(null);
  const [courses, setCourses] = useState<Course[]>([]);
  const [progress, setProgress] = useState<LearnerProgress[]>([]);
  const [loading, setLoading] = useState(true);
  const [competencyFilter, setCompetencyFilter] = useState('all');
  const [typeFilter, setTypeFilter] = useState('all');
  const [activeCourse, setActiveCourse] = useState<Course | null>(null);
  const [viewerOpen, setViewerOpen] = useState(false);
  const [starting, setStarting] = useState(false);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    const init = async () => {
      setLoading(true);
      const { data: { user } } = await supabase.auth.getUser();
      if (!user) { setLoading(false); return; }

      const { data: profile } = await supabase
        .from('profiles')
        .select('id,cefr_level')
        .eq('id', user.id)
        .maybeSingle();
      setCurrentUser(profile as typeof currentUser);

      const level = (profile as { cefr_level?: string })?.cefr_level;

      // Fetch courses
      let query = supabase
        .from('courses')
        .select('*, teacher:profiles!courses_teacher_id_fkey(full_name)')
        .eq('is_published', true);
      if (level) query = query.eq('cefr_level', level);

      const { data: courseData, error: courseErr } = await query.order('created_at', { ascending: false });
      if (courseErr) setError('Failed to load courses.');
      else setCourses((courseData as Course[]) || []);

      // Fetch learner progress
      const { data: progressData } = await supabase
        .from('learner_progress')
        .select('course_id,status')
        .eq('learner_id', user.id);
      setProgress((progressData as LearnerProgress[]) || []);

      setLoading(false);
    };
    init();
  }, [supabase]);

  const getProgress = (courseId: string): LearnerProgress['status'] => {
    const p = progress.find((p) => p.course_id === courseId);
    return p?.status || 'not_started';
  };

  const startCourse = async (course: Course) => {
    if (!currentUser) return;
    setStarting(true);
    const existing = progress.find((p) => p.course_id === course.id);
    if (!existing) {
      const { error: insertErr } = await supabase.from('learner_progress').insert({
        learner_id: currentUser.id,
        course_id: course.id,
        status: 'in_progress',
        started_at: new Date().toISOString(),
      });
      if (!insertErr) {
        setProgress((prev) => [...prev, { course_id: course.id, status: 'in_progress' }]);
      }
    } else if (existing.status === 'not_started') {
      await supabase
        .from('learner_progress')
        .update({ status: 'in_progress', started_at: new Date().toISOString() })
        .eq('learner_id', currentUser.id)
        .eq('course_id', course.id);
      setProgress((prev) =>
        prev.map((p) => p.course_id === course.id ? { ...p, status: 'in_progress' } : p)
      );
    }
    setActiveCourse(course);
    setViewerOpen(true);
    setStarting(false);
  };

  const filteredCourses = courses.filter((c) => {
    if (competencyFilter !== 'all' && c.competency !== competencyFilter) return false;
    if (typeFilter !== 'all' && c.content_type !== typeFilter) return false;
    return true;
  });

  if (loading) {
    return (
      <div className="flex items-center justify-center min-h-[60vh]">
        <Loader2 className="h-8 w-8 animate-spin" style={{ color: '#00A550' }} />
      </div>
    );
  }

  return (
    <div className="p-6 max-w-7xl mx-auto space-y-6">
      <div>
        <h1 className="text-2xl font-bold">My Courses</h1>
        <p className="text-sm text-muted-foreground mt-1">
          Browse and study available courses for your level
        </p>
      </div>

      {error && (
        <div className="bg-destructive/10 text-destructive px-4 py-2 rounded-lg text-sm">
          {error}
        </div>
      )}

      {/* Filters */}
      <div className="flex flex-wrap gap-3 items-center">
        <Select value={competencyFilter} onValueChange={setCompetencyFilter}>
          <SelectTrigger className="w-52 h-9">
            <SelectValue placeholder="All competencies" />
          </SelectTrigger>
          <SelectContent>
            <SelectItem value="all">All competencies</SelectItem>
            {Object.entries(COMPETENCY_LABELS).map(([k, v]) => (
              <SelectItem key={k} value={k}>{k} — {v}</SelectItem>
            ))}
          </SelectContent>
        </Select>
        <Select value={typeFilter} onValueChange={setTypeFilter}>
          <SelectTrigger className="w-44 h-9">
            <SelectValue placeholder="All types" />
          </SelectTrigger>
          <SelectContent>
            <SelectItem value="all">All types</SelectItem>
            <SelectItem value="video">Video</SelectItem>
            <SelectItem value="pdf">PDF</SelectItem>
            <SelectItem value="audio">Audio</SelectItem>
            <SelectItem value="text">Text</SelectItem>
            <SelectItem value="link">Link</SelectItem>
          </SelectContent>
        </Select>
        {(competencyFilter !== 'all' || typeFilter !== 'all') && (
          <Button
            variant="ghost"
            size="sm"
            onClick={() => { setCompetencyFilter('all'); setTypeFilter('all'); }}
          >
            Clear filters
          </Button>
        )}
        <span className="text-sm text-muted-foreground ml-auto">
          {filteredCourses.length} course{filteredCourses.length !== 1 ? 's' : ''}
        </span>
      </div>

      {/* Course Grid */}
      {filteredCourses.length === 0 ? (
        <div className="text-center py-16 text-muted-foreground">
          <BookOpen className="h-12 w-12 mx-auto mb-3 opacity-20" />
          <p className="font-medium">No courses found</p>
          <p className="text-sm mt-1">Try adjusting your filters</p>
        </div>
      ) : (
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-5">
          {filteredCourses.map((course, idx) => {
            const progressStatus = getProgress(course.id);
            const progressStyle = PROGRESS_STYLES[progressStatus];
            const ContentIcon = CONTENT_TYPE_ICONS[course.content_type] || BookOpen;
            const thumbUrl = course.thumbnail_url || PEXELS_THUMBS[idx % PEXELS_THUMBS.length];

            return (
              <Card key={course.id} className="overflow-hidden flex flex-col group hover:shadow-md transition-shadow">
                {/* Thumbnail */}
                <div className="relative h-40 overflow-hidden bg-muted">
                  <img
                    src={thumbUrl}
                    alt={course.title}
                    className="w-full h-full object-cover group-hover:scale-105 transition-transform duration-300"
                    onError={(e) => {
                      const target = e.currentTarget;
                      target.style.display = 'none';
                      const fallback = target.nextElementSibling as HTMLElement;
                      if (fallback) fallback.style.display = 'flex';
                    }}
                  />
                  <div
                    className={`absolute inset-0 hidden items-center justify-center ${BG_COLORS[idx % BG_COLORS.length]}`}
                  >
                    <ContentIcon className="h-12 w-12 text-white/60" />
                  </div>
                  {/* Content type badge */}
                  <div className="absolute top-2 right-2">
                    <span className="bg-black/60 text-white text-[10px] font-medium px-2 py-0.5 rounded-full flex items-center gap-1">
                      <ContentIcon className="h-3 w-3" />
                      {course.content_type.toUpperCase()}
                    </span>
                  </div>
                  {/* Progress badge */}
                  <div className="absolute top-2 left-2">
                    <span className={`text-[10px] font-medium px-2 py-0.5 rounded-full ${progressStyle.class}`}>
                      {progressStyle.label}
                    </span>
                  </div>
                </div>

                <CardContent className="p-4 flex flex-col flex-1 gap-3">
                  <div className="flex-1">
                    <div className="flex items-center gap-1.5 mb-1.5">
                      <Badge variant="outline" className="text-[10px] px-1.5 py-0" style={{ color: '#00A550', borderColor: '#00A550' }}>
                        {course.cefr_level}
                      </Badge>
                      <Badge variant="outline" className="text-[10px] px-1.5 py-0">
                        {course.competency}
                      </Badge>
                    </div>
                    <h3 className="font-semibold text-sm leading-tight line-clamp-2">
                      {course.title}
                    </h3>
                    {course.teacher?.full_name && (
                      <p className="text-xs text-muted-foreground mt-1">
                        by {course.teacher.full_name}
                      </p>
                    )}
                    {course.duration_minutes && (
                      <p className="text-xs text-muted-foreground mt-1 flex items-center gap-1">
                        <Clock className="h-3 w-3" />
                        {course.duration_minutes} min
                      </p>
                    )}
                  </div>
                  <Button
                    size="sm"
                    className="w-full text-white text-xs"
                    style={{ backgroundColor: '#00A550' }}
                    onClick={() => startCourse(course)}
                    disabled={starting}
                  >
                    {progressStatus === 'completed'
                      ? 'Review Course'
                      : progressStatus === 'in_progress'
                      ? 'Continue'
                      : 'Start Course'}
                  </Button>
                </CardContent>
              </Card>
            );
          })}
        </div>
      )}

      {/* Course Viewer Dialog */}
      <Dialog open={viewerOpen} onOpenChange={setViewerOpen}>
        <DialogContent className="sm:max-w-3xl max-h-[85vh] overflow-y-auto">
          <DialogHeader>
            <DialogTitle className="pr-4">{activeCourse?.title}</DialogTitle>
          </DialogHeader>
          {activeCourse && (
            <div className="space-y-4">
              <div className="flex flex-wrap gap-2">
                <Badge variant="outline" style={{ color: '#00A550', borderColor: '#00A550' }}>
                  {activeCourse.cefr_level}
                </Badge>
                <Badge variant="outline">
                  {COMPETENCY_LABELS[activeCourse.competency] || activeCourse.competency}
                </Badge>
                <Badge variant="secondary" className="capitalize">
                  {activeCourse.content_type}
                </Badge>
              </div>

              {activeCourse.description && (
                <p className="text-sm text-muted-foreground">{activeCourse.description}</p>
              )}

              {/* Content viewer */}
              {activeCourse.content_url ? (
                <div className="space-y-3">
                  {activeCourse.content_type === 'video' && (
                    <div className="aspect-video bg-black rounded-lg overflow-hidden">
                      <iframe
                        src={activeCourse.content_url}
                        className="w-full h-full"
                        allowFullScreen
                        title={activeCourse.title}
                      />
                    </div>
                  )}
                  {activeCourse.content_type === 'pdf' && (
                    <div className="border rounded-lg overflow-hidden h-96">
                      <iframe
                        src={activeCourse.content_url}
                        className="w-full h-full"
                        title={activeCourse.title}
                      />
                    </div>
                  )}
                  {activeCourse.content_type === 'audio' && (
                    <div className="bg-muted rounded-lg p-6 flex flex-col items-center gap-4">
                      <Headphones className="h-12 w-12" style={{ color: '#00A550' }} />
                      <audio controls className="w-full max-w-sm">
                        <source src={activeCourse.content_url} />
                        Your browser does not support the audio element.
                      </audio>
                    </div>
                  )}
                  {(activeCourse.content_type === 'link' || activeCourse.content_type === 'text') && (
                    <div className="bg-muted/50 border rounded-lg p-6 text-center space-y-3">
                      <LinkIcon className="h-10 w-10 mx-auto" style={{ color: '#00A550' }} />
                      <p className="text-sm text-muted-foreground">
                        This course content is available at an external link.
                      </p>
                      <Button
                        asChild
                        className="text-white"
                        style={{ backgroundColor: '#00A550' }}
                      >
                        <a href={activeCourse.content_url} target="_blank" rel="noopener noreferrer">
                          <ExternalLink className="h-4 w-4 mr-2" />
                          Open Content
                        </a>
                      </Button>
                    </div>
                  )}
                </div>
              ) : (
                <div className="bg-muted rounded-lg p-8 text-center text-muted-foreground">
                  <BookOpen className="h-10 w-10 mx-auto mb-2 opacity-30" />
                  <p className="text-sm">Content not yet available</p>
                </div>
              )}

              {/* Mark as completed */}
              {getProgress(activeCourse.id) !== 'completed' && (
                <div className="flex justify-end pt-2 border-t">
                  <Button
                    variant="outline"
                    size="sm"
                    style={{ borderColor: '#00A550', color: '#00A550' }}
                    onClick={async () => {
                      if (!currentUser) return;
                      await supabase
                        .from('learner_progress')
                        .upsert({
                          learner_id: currentUser.id,
                          course_id: activeCourse.id,
                          status: 'completed',
                          completed_at: new Date().toISOString(),
                        });
                      setProgress((prev) =>
                        prev.some((p) => p.course_id === activeCourse.id)
                          ? prev.map((p) =>
                              p.course_id === activeCourse.id
                                ? { ...p, status: 'completed' }
                                : p
                            )
                          : [...prev, { course_id: activeCourse.id, status: 'completed' }]
                      );
                      setViewerOpen(false);
                    }}
                  >
                    Mark as Completed
                  </Button>
                </div>
              )}
            </div>
          )}
        </DialogContent>
      </Dialog>
    </div>
  );
}
