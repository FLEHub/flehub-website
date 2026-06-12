'use client';

import { useEffect, useMemo, useState } from 'react';
import { createClient } from '@/lib/supabase/client';
import { Badge } from '@/components/ui/badge';
import { Button } from '@/components/ui/button';
import { Card, CardContent } from '@/components/ui/card';
import { Input } from '@/components/ui/input';
import { Skeleton } from '@/components/ui/skeleton';
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from '@/components/ui/select';
import { ExternalLink, Search } from 'lucide-react';

type ResourceType = 'pdf' | 'audio' | 'image' | 'video';
type CEFRLevel = 'A1' | 'A2' | 'B1' | 'B2' | 'C1' | 'C2';
type TypeFilter = ResourceType | 'all';
type LevelFilter = CEFRLevel | 'all';

interface TeacherProfile {
  full_name: string | null;
}

interface Resource {
  id: string;
  teacher_id: string;
  title: string;
  description: string | null;
  type: ResourceType;
  subject: string | null;
  level: CEFRLevel | null;
  file_path: string;
  is_public: boolean;
  created_at: string;
  teacher: TeacherProfile | TeacherProfile[] | null;
}

const resourceTypes: Array<{ value: TypeFilter; label: string }> = [
  { value: 'all', label: 'Tous' },
  { value: 'pdf', label: 'PDF' },
  { value: 'audio', label: 'Audio' },
  { value: 'image', label: 'Image' },
  { value: 'video', label: 'Vidéo' },
];

const levels: LevelFilter[] = ['all', 'A1', 'A2', 'B1', 'B2', 'C1', 'C2'];

const typeMeta: Record<ResourceType, { icon: string; label: string }> = {
  pdf: { icon: '📄', label: 'PDF' },
  audio: { icon: '🎵', label: 'Audio' },
  image: { icon: '🖼️', label: 'Image' },
  video: { icon: '🎬', label: 'Vidéo' },
};

const levelColors: Record<CEFRLevel, string> = {
  A1: 'bg-green-100 text-green-800',
  A2: 'bg-emerald-100 text-emerald-800',
  B1: 'bg-blue-100 text-blue-800',
  B2: 'bg-indigo-100 text-indigo-800',
  C1: 'bg-purple-100 text-purple-800',
  C2: 'bg-rose-100 text-rose-800',
};

function formatDate(value: string) {
  return new Intl.DateTimeFormat('fr-FR', {
    day: '2-digit',
    month: 'short',
    year: 'numeric',
  }).format(new Date(value));
}

function getTeacherName(teacher: Resource['teacher']) {
  const profile = Array.isArray(teacher) ? teacher[0] : teacher;
  return profile?.full_name || 'Enseignant FLEHub';
}

export default function LearnerResourcesPage() {
  const [resources, setResources] = useState<Resource[]>([]);
  const [loading, setLoading] = useState(true);
  const [searchTerm, setSearchTerm] = useState('');
  const [typeFilter, setTypeFilter] = useState<TypeFilter>('all');
  const [levelFilter, setLevelFilter] = useState<LevelFilter>('all');
  const [subjectFilter, setSubjectFilter] = useState('all');

  useEffect(() => {
    async function fetchResources() {
      const supabase = createClient();

      try {
        const { data, error } = await supabase
          .from('resources')
          .select(`
            id,
            teacher_id,
            title,
            description,
            type,
            subject,
            level,
            file_path,
            is_public,
            created_at,
            teacher:profiles!resources_teacher_id_fkey(full_name)
          `)
          .eq('is_public', true)
          .order('created_at', { ascending: false });

        if (error) throw error;

        setResources((data ?? []) as Resource[]);
      } catch (err) {
        console.error(err);
        setResources([]);
      } finally {
        setLoading(false);
      }
    }

    fetchResources();
  }, []);

  const subjects = useMemo(() => {
    return Array.from(
      new Set(
        resources
          .map((resource) => resource.subject)
          .filter((subject): subject is string => Boolean(subject))
      )
    ).sort((a, b) => a.localeCompare(b));
  }, [resources]);

  const filteredResources = useMemo(() => {
    const query = searchTerm.trim().toLowerCase();

    return resources.filter((resource) => {
      const matchesSearch =
        !query ||
        resource.title.toLowerCase().includes(query) ||
        (resource.description ?? '').toLowerCase().includes(query);

      const matchesType = typeFilter === 'all' || resource.type === typeFilter;
      const matchesLevel = levelFilter === 'all' || resource.level === levelFilter;
      const matchesSubject = subjectFilter === 'all' || resource.subject === subjectFilter;

      return matchesSearch && matchesType && matchesLevel && matchesSubject;
    });
  }, [levelFilter, resources, searchTerm, subjectFilter, typeFilter]);

  return (
    <div className="p-6 space-y-6 max-w-7xl mx-auto">
      <div>
        <h1 className="text-2xl font-bold text-gray-900">Bibliothèque de ressources</h1>
        <p className="text-gray-500 text-sm mt-1">
          Explorez les ressources pédagogiques de vos enseignants
        </p>
      </div>

      <Card>
        <CardContent className="p-4 space-y-4">
          <div className="relative">
            <Search className="absolute left-3 top-1/2 h-4 w-4 -translate-y-1/2 text-gray-400" />
            <Input
              value={searchTerm}
              onChange={(event) => setSearchTerm(event.target.value)}
              placeholder="Rechercher par titre ou description..."
              className="pl-9"
            />
          </div>

          <div className="space-y-3">
            <div className="flex flex-wrap items-center gap-2">
              <span className="text-sm font-medium text-gray-600">Type:</span>
              {resourceTypes.map((type) => (
                <Button
                  key={type.value}
                  type="button"
                  variant={typeFilter === type.value ? 'default' : 'outline'}
                  size="sm"
                  className={typeFilter === type.value ? 'bg-flehub-green text-white' : ''}
                  onClick={() => setTypeFilter(type.value)}
                >
                  {type.label}
                </Button>
              ))}
            </div>

            <div className="flex flex-wrap items-center gap-2">
              <span className="text-sm font-medium text-gray-600">Niveau:</span>
              {levels.map((level) => (
                <Button
                  key={level}
                  type="button"
                  variant={levelFilter === level ? 'default' : 'outline'}
                  size="sm"
                  className={levelFilter === level ? 'bg-flehub-green text-white' : ''}
                  onClick={() => setLevelFilter(level)}
                >
                  {level === 'all' ? 'Tous' : level}
                </Button>
              ))}
            </div>

            <div className="max-w-xs">
              <Select value={subjectFilter} onValueChange={setSubjectFilter}>
                <SelectTrigger>
                  <SelectValue placeholder="Filtrer par sujet" />
                </SelectTrigger>
                <SelectContent>
                  <SelectItem value="all">Tous les sujets</SelectItem>
                  {subjects.map((subject) => (
                    <SelectItem key={subject} value={subject}>
                      {subject}
                    </SelectItem>
                  ))}
                </SelectContent>
              </Select>
            </div>
          </div>
        </CardContent>
      </Card>

      {loading ? (
        <div className="grid grid-cols-1 lg:grid-cols-3 gap-4">
          {Array.from({ length: 6 }).map((_, index) => (
            <Skeleton key={index} className="h-64 rounded-xl" />
          ))}
        </div>
      ) : filteredResources.length === 0 ? (
        <div className="flex flex-col items-center justify-center py-20 text-gray-400">
          <span className="mb-3 text-5xl" aria-hidden>
            📚
          </span>
          <p className="text-lg font-medium">Aucune ressource disponible pour le moment</p>
        </div>
      ) : (
        <div className="grid grid-cols-1 lg:grid-cols-3 gap-4">
          {filteredResources.map((resource) => {
            const meta = typeMeta[resource.type];
            const teacherName = getTeacherName(resource.teacher);

            return (
              <Card key={resource.id} className="card-hover flex flex-col">
                <CardContent className="p-5 flex flex-col flex-1 gap-4">
                  <div className="flex items-start justify-between gap-3">
                    <div className="flex items-center gap-3 min-w-0">
                      <div className="flex h-11 w-11 flex-shrink-0 items-center justify-center rounded-xl bg-flehub-green-light text-2xl">
                        {meta.icon}
                      </div>
                      <div className="min-w-0">
                        <p className="text-xs font-medium uppercase tracking-wide text-gray-400">
                          {meta.label}
                        </p>
                        <h2 className="font-semibold text-gray-900 line-clamp-2">
                          {resource.title}
                        </h2>
                      </div>
                    </div>

                    {resource.level && (
                      <Badge className={`flex-shrink-0 ${levelColors[resource.level]}`} variant="secondary">
                        {resource.level}
                      </Badge>
                    )}
                  </div>

                  <p className="text-sm text-gray-500 line-clamp-2 min-h-[2.5rem]">
                    {resource.description || 'Aucune description fournie.'}
                  </p>

                  <div className="flex flex-wrap gap-2">
                    {resource.subject && (
                      <Badge variant="outline" className="bg-gray-50 text-gray-600">
                        {resource.subject}
                      </Badge>
                    )}
                  </div>

                  <div className="mt-auto flex items-center justify-between gap-3 border-t border-gray-100 pt-4">
                    <div className="min-w-0 text-xs text-gray-500">
                      <p className="truncate font-medium text-gray-700">{teacherName}</p>
                      <p>{formatDate(resource.created_at)}</p>
                    </div>

                    <Button asChild size="sm" className="bg-flehub-green hover:bg-flehub-green/90 text-white">
                      <a href={resource.file_path} target="_blank" rel="noopener noreferrer">
                        Ouvrir
                        <ExternalLink className="ml-1.5 h-3.5 w-3.5" />
                      </a>
                    </Button>
                  </div>
                </CardContent>
              </Card>
            );
          })}
        </div>
      )}
    </div>
  );
}
