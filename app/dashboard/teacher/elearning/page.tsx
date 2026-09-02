'use client';

import { useEffect, useState } from 'react';
import Link from 'next/link';
import { createClient } from '@/lib/supabase/client';
import { Card, CardContent, CardHeader } from '@/components/ui/card';
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
import { Plus, Pencil, Trash2, BookOpen, Layers, FolderOpen } from 'lucide-react';

type CEFR = 'A1' | 'A2' | 'B1' | 'B2' | 'C1' | 'C2';

interface ElearningModule {
  id: string;
  title: string;
  description: string | null;
  cefr_level: CEFR | null;
  published: boolean;
  created_at: string;
}

const cefrLevels: CEFR[] = ['A1', 'A2', 'B1', 'B2', 'C1', 'C2'];

const cefrColors: Record<CEFR, string> = {
  A1: 'bg-green-100 text-green-700',
  A2: 'bg-lime-100 text-lime-700',
  B1: 'bg-yellow-100 text-yellow-700',
  B2: 'bg-orange-100 text-orange-700',
  C1: 'bg-red-100 text-red-700',
  C2: 'bg-rose-100 text-rose-700',
};

const emptyForm = {
  title: '',
  description: '',
  cefr_level: '' as CEFR | '',
  published: false,
};

export default function TeacherElearningPage() {
  const supabase = createClient();

  const [modules, setModules] = useState<ElearningModule[]>([]);
  const [teacherId, setTeacherId] = useState<string | null>(null);
  const [loading, setLoading] = useState(true);
  const [saving, setSaving] = useState(false);

  const [dialogOpen, setDialogOpen] = useState(false);
  const [editing, setEditing] = useState<ElearningModule | null>(null);
  const [form, setForm] = useState({ ...emptyForm });
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
      setTeacherId(teacher.id);

      const { data } = await supabase
        .from('elearning_modules')
        .select('id, title, description, cefr_level, published, created_at')
        .eq('teacher_id', teacher.id)
        .order('created_at', { ascending: false });

      setModules((data as ElearningModule[]) ?? []);
    } catch (err) {
      console.error(err);
    } finally {
      setLoading(false);
    }
  }

  function openCreate() {
    setEditing(null);
    setForm({ ...emptyForm });
    setDialogOpen(true);
  }

  function openEdit(mod: ElearningModule) {
    setEditing(mod);
    setForm({
      title: mod.title,
      description: mod.description ?? '',
      cefr_level: mod.cefr_level ?? '',
      published: mod.published,
    });
    setDialogOpen(true);
  }

  async function handleSave() {
    if (!teacherId || !form.title) return;
    setSaving(true);
    try {
      const payload = {
        title: form.title.trim(),
        description: form.description.trim() || null,
        cefr_level: form.cefr_level || null,
        published: form.published,
        updated_at: new Date().toISOString(),
      };

      if (editing) {
        const { error } = await supabase
          .from('elearning_modules')
          .update(payload)
          .eq('id', editing.id);
        if (error) throw error;
      } else {
        const { error } = await supabase.from('elearning_modules').insert({
          ...payload,
          teacher_id: teacherId,
        });
        if (error) throw error;
      }

      setDialogOpen(false);
      await fetchData();
    } catch (err) {
      console.error(err);
    } finally {
      setSaving(false);
    }
  }

  async function handleDelete(id: string) {
    try {
      const { error } = await supabase.from('elearning_modules').delete().eq('id', id);
      if (error) throw error;
      setDeleteConfirmId(null);
      setModules((prev) => prev.filter((m) => m.id !== id));
    } catch (err) {
      console.error(err);
    }
  }

  return (
    <div className="p-4 sm:p-6 space-y-6 max-w-7xl mx-auto">
      <div className="flex flex-col gap-3 sm:flex-row sm:items-center sm:justify-between">
        <div>
          <h1 className="text-2xl font-bold text-gray-900">Modules eLearning</h1>
          <p className="text-gray-500 text-sm mt-1">
            Créez et publiez vos modules pour vos apprenants
          </p>
        </div>
        <Button
          className="bg-flehub-green hover:bg-flehub-green/90 text-white"
          onClick={openCreate}
        >
          <Plus className="w-4 h-4 mr-1" />
          Créer un module
        </Button>
      </div>

      {loading ? (
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-4">
          {Array.from({ length: 8 }).map((_, i) => (
            <Skeleton key={i} className="h-52 rounded-xl" />
          ))}
        </div>
      ) : modules.length === 0 ? (
        <div className="flex flex-col items-center justify-center py-20 text-gray-400">
          <BookOpen className="w-12 h-12 mb-3 opacity-40" />
          <p className="text-lg font-medium">Aucun module</p>
          <p className="text-sm">Créez votre premier module eLearning pour commencer</p>
        </div>
      ) : (
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-4">
          {modules.map((mod) => (
            <Card key={mod.id} className="card-hover flex flex-col">
              <CardHeader className="pb-2">
                <div className="flex items-start justify-between gap-2">
                  <div className="p-2 rounded-lg bg-flehub-green-light">
                    <Layers className="w-5 h-5 text-flehub-green" />
                  </div>
                  <Badge
                    variant="outline"
                    className={`text-xs font-semibold ${
                      mod.published
                        ? 'border-flehub-green text-flehub-green bg-flehub-green-light'
                        : 'border-gray-300 text-gray-400'
                    }`}
                  >
                    {mod.published ? 'Publié' : 'Brouillon'}
                  </Badge>
                </div>
                <Link
                  href={`/dashboard/teacher/elearning/${mod.id}`}
                  className="font-semibold text-gray-900 text-sm mt-2 leading-snug line-clamp-2 hover:text-flehub-green transition-colors block"
                >
                  {mod.title}
                </Link>
              </CardHeader>
              <CardContent className="flex flex-col flex-1 justify-between gap-3">
                <p className="text-xs text-gray-500 line-clamp-2">
                  {mod.description || 'Aucune description'}
                </p>
                <div className="flex flex-wrap gap-1">
                  {mod.cefr_level && (
                    <Badge
                      className={`text-xs ${cefrColors[mod.cefr_level]}`}
                      variant="secondary"
                    >
                      {mod.cefr_level}
                    </Badge>
                  )}
                </div>
                <Button
                  asChild
                  size="sm"
                  className="bg-flehub-green hover:bg-flehub-green/90 text-white"
                >
                  <Link href={`/dashboard/teacher/elearning/${mod.id}`}>
                    <FolderOpen className="w-3.5 h-3.5 mr-1" />
                    Gérer le contenu
                  </Link>
                </Button>
                <div className="flex gap-2 pt-1 border-t border-gray-100">
                  <Button
                    variant="ghost"
                    size="sm"
                    className="flex-1 text-flehub-green hover:bg-flehub-green-light"
                    onClick={() => openEdit(mod)}
                  >
                    <Pencil className="w-3.5 h-3.5 mr-1" />
                    Modifier
                  </Button>
                  <Button
                    variant="ghost"
                    size="sm"
                    className="text-red-500 hover:bg-red-50"
                    onClick={() => setDeleteConfirmId(mod.id)}
                  >
                    <Trash2 className="w-3.5 h-3.5" />
                  </Button>
                </div>
              </CardContent>
            </Card>
          ))}
        </div>
      )}

      <Dialog open={dialogOpen} onOpenChange={setDialogOpen}>
        <DialogContent className="max-w-lg max-h-[90vh] overflow-y-auto">
          <DialogHeader>
            <DialogTitle>{editing ? 'Modifier le module' : 'Créer un module'}</DialogTitle>
          </DialogHeader>
          <div className="space-y-4 py-2">
            <div className="space-y-2">
              <Label htmlFor="title">Titre</Label>
              <Input
                id="title"
                value={form.title}
                onChange={(e) => setForm({ ...form, title: e.target.value })}
                placeholder="Ex. Expression écrite B1"
              />
            </div>
            <div className="space-y-2">
              <Label htmlFor="description">Description</Label>
              <Textarea
                id="description"
                value={form.description}
                onChange={(e) => setForm({ ...form, description: e.target.value })}
                rows={3}
              />
            </div>
            <div className="space-y-2">
              <Label>Niveau CECR</Label>
              <Select
                value={form.cefr_level}
                onValueChange={(v) => setForm({ ...form, cefr_level: v as CEFR })}
              >
                <SelectTrigger>
                  <SelectValue placeholder="Choisir un niveau" />
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
            <div className="flex items-center justify-between rounded-lg border border-gray-100 px-3 py-2">
              <div>
                <Label htmlFor="published">Publier</Label>
                <p className="text-xs text-gray-400">Visible pour les apprenants inscrits</p>
              </div>
              <Switch
                id="published"
                checked={form.published}
                onCheckedChange={(v) => setForm({ ...form, published: v })}
              />
            </div>
          </div>
          <DialogFooter>
            <Button variant="outline" onClick={() => setDialogOpen(false)}>
              Annuler
            </Button>
            <Button
              className="bg-flehub-green hover:bg-flehub-green/90 text-white"
              disabled={saving || !form.title}
              onClick={handleSave}
            >
              {saving ? 'Enregistrement…' : 'Enregistrer'}
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>

      <Dialog open={!!deleteConfirmId} onOpenChange={() => setDeleteConfirmId(null)}>
        <DialogContent className="max-w-sm">
          <DialogHeader>
            <DialogTitle>Supprimer ce module ?</DialogTitle>
          </DialogHeader>
          <p className="text-sm text-gray-500">
            Cette action est irréversible. Les séquences, leçons et soumissions liées seront
            également supprimées.
          </p>
          <DialogFooter>
            <Button variant="outline" onClick={() => setDeleteConfirmId(null)}>
              Annuler
            </Button>
            <Button
              variant="destructive"
              onClick={() => deleteConfirmId && handleDelete(deleteConfirmId)}
            >
              Supprimer
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>
    </div>
  );
}
