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
import {
  Video,
  Plus,
  Calendar,
  Clock,
  Users,
  Play,
  ExternalLink,
  VideoOff,
  Link as LinkIcon,
} from 'lucide-react';

type CEFR = 'A1' | 'A2' | 'B1' | 'B2' | 'C1' | 'C2';
type SessionStatus = 'scheduled' | 'live' | 'completed' | 'cancelled';

interface LiveSession {
  id: string;
  title: string;
  description: string;
  scheduled_at: string;
  duration_minutes: number;
  cefr_level: CEFR;
  max_participants: number;
  status: SessionStatus;
  meeting_url: string | null;
  created_at: string;
}

const cefrLevels: CEFR[] = ['A1', 'A2', 'B1', 'B2', 'C1', 'C2'];

const statusConfig: Record<SessionStatus, { label: string; badgeClass: string }> = {
  scheduled: { label: 'Planifiée', badgeClass: 'bg-blue-100 text-blue-700 border-blue-200' },
  live:      { label: 'En direct', badgeClass: 'bg-flehub-green-light text-flehub-green border-flehub-green' },
  completed: { label: 'Terminée',  badgeClass: 'bg-gray-100 text-gray-600 border-gray-300' },
  cancelled: { label: 'Annulée',   badgeClass: 'bg-red-100 text-red-600 border-red-200' },
};

const emptyForm = {
  title: '',
  description: '',
  scheduled_at: '',
  duration_minutes: 60,
  cefr_level: '' as CEFR | '',
  max_participants: 20,
  meeting_url: '',
};

export default function TeacherSessionsPage() {
  const supabase = createClient();

  const [sessions, setSessions] = useState<LiveSession[]>([]);
  const [teacherId, setTeacherId] = useState<string | null>(null);
  const [loading, setLoading] = useState(true);
  const [saving, setSaving] = useState(false);
  const [dialogOpen, setDialogOpen] = useState(false);
  const [form, setForm] = useState({ ...emptyForm });

  useEffect(() => { fetchData(); }, []);

  async function fetchData() {
    try {
      const { data: { user } } = await supabase.auth.getUser();
      if (!user) return;

      const { data: teacher } = await supabase
        .from('teachers')
        .select('id')
        .eq('profile_id', user.id)
        .maybeSingle();

      if (!teacher) return;
      setTeacherId(teacher.id);

      const { data } = await supabase
        .from('live_sessions')
        .select('*')
        .eq('teacher_id', teacher.id)
        .order('scheduled_at', { ascending: false });

      setSessions(data ?? []);
    } catch (err) {
      console.error(err);
    } finally {
      setLoading(false);
    }
  }

  async function handleSave() {
    if (!teacherId || !form.title || !form.scheduled_at || !form.cefr_level) return;
    setSaving(true);
    try {
      await supabase.from('live_sessions').insert({
        title: form.title,
        description: form.description || null,
        scheduled_at: new Date(form.scheduled_at).toISOString(),
        duration_minutes: Number(form.duration_minutes),
        cefr_level: form.cefr_level,
        max_participants: Number(form.max_participants),
        teacher_id: teacherId,
        status: 'scheduled',
        meeting_url: form.meeting_url.trim() || null,
      });
      setDialogOpen(false);
      setForm({ ...emptyForm });
      await fetchData();
    } catch (err) {
      console.error(err);
    } finally {
      setSaving(false);
    }
  }

  async function updateStatus(id: string, status: SessionStatus) {
    await supabase.from('live_sessions').update({ status }).eq('id', id);
    await fetchData();
  }

  const formatDateTime = (iso: string) =>
    new Date(iso).toLocaleString('fr-FR', {
      weekday: 'short',
      year: 'numeric',
      month: 'short',
      day: 'numeric',
      hour: '2-digit',
      minute: '2-digit',
    });

  const upcoming = sessions.filter((s) => s.status === 'scheduled' || s.status === 'live');
  const past = sessions.filter((s) => s.status === 'completed' || s.status === 'cancelled');

  function SessionCard({ session }: { session: LiveSession }) {
    const cfg = statusConfig[session.status];
    const isLive = session.status === 'live';
    const isScheduled = session.status === 'scheduled';

    return (
      <Card className={`transition-all ${isLive ? 'border-flehub-green ring-1 ring-flehub-green' : 'hover:border-gray-300'}`}>
        <CardContent className="py-4">
          <div className="flex flex-col sm:flex-row sm:items-start gap-3">
            <div className={`p-2.5 rounded-lg shrink-0 ${isLive ? 'bg-flehub-green-light' : 'bg-gray-100'}`}>
              <Video className={`w-5 h-5 ${isLive ? 'text-flehub-green animate-pulse' : 'text-gray-500'}`} />
            </div>

            <div className="flex-1 min-w-0">
              <div className="flex flex-wrap items-center gap-2 mb-1">
                <span className="font-semibold text-gray-900">{session.title}</span>
                <Badge variant="outline" className={`text-xs ${cfg.badgeClass}`}>
                  {isLive && <span className="mr-1 inline-block w-1.5 h-1.5 rounded-full bg-flehub-green animate-pulse" />}
                  {cfg.label}
                </Badge>
                <Badge variant="secondary" className="text-xs bg-gray-100 text-gray-600">
                  {session.cefr_level}
                </Badge>
              </div>

              {session.description && (
                <p className="text-xs text-gray-500 mb-2 line-clamp-1">{session.description}</p>
              )}

              <div className="flex flex-wrap gap-3 text-xs text-gray-500">
                <span className="flex items-center gap-1">
                  <Calendar className="w-3.5 h-3.5" />
                  {formatDateTime(session.scheduled_at)}
                </span>
                <span className="flex items-center gap-1">
                  <Clock className="w-3.5 h-3.5" />
                  {session.duration_minutes} min
                </span>
                <span className="flex items-center gap-1">
                  <Users className="w-3.5 h-3.5" />
                  Max {session.max_participants}
                </span>
              </div>

              {session.meeting_url && (
                <div className="mt-2 flex items-center gap-1.5 text-xs text-gray-500">
                  <LinkIcon className="w-3.5 h-3.5 shrink-0" />
                  <span className="truncate max-w-xs">{session.meeting_url}</span>
                </div>
              )}
            </div>

            <div className="flex flex-col gap-2 shrink-0">
              {isScheduled && (
                <>
                  <Button
                    size="sm"
                    className="bg-flehub-green hover:bg-flehub-green/90 text-white"
                    onClick={() => updateStatus(session.id, 'live')}
                  >
                    <Play className="w-3.5 h-3.5 mr-1" />
                    Démarrer
                  </Button>
                  {session.meeting_url && (
                    <Button
                      size="sm"
                      variant="outline"
                      onClick={() => window.open(session.meeting_url!, '_blank')}
                    >
                      <ExternalLink className="w-3.5 h-3.5 mr-1" />
                      Ouvrir le lien
                    </Button>
                  )}
                  <Button
                    size="sm"
                    variant="ghost"
                    className="text-red-500 hover:bg-red-50"
                    onClick={() => updateStatus(session.id, 'cancelled')}
                  >
                    Annuler
                  </Button>
                </>
              )}
              {isLive && (
                <>
                  {session.meeting_url ? (
                    <Button
                      size="sm"
                      className="bg-flehub-green hover:bg-flehub-green/90 text-white"
                      onClick={() => window.open(session.meeting_url!, '_blank')}
                    >
                      <ExternalLink className="w-3.5 h-3.5 mr-1" />
                      Rejoindre
                    </Button>
                  ) : null}
                  <Button
                    size="sm"
                    variant="outline"
                    className="text-gray-600"
                    onClick={() => updateStatus(session.id, 'completed')}
                  >
                    Terminer
                  </Button>
                </>
              )}
            </div>
          </div>
        </CardContent>
      </Card>
    );
  }

  return (
    <div className="p-6 space-y-6 max-w-4xl mx-auto">
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-2xl font-bold text-gray-900">Sessions en direct</h1>
          <p className="text-gray-500 text-sm mt-1">
            {upcoming.length} à venir · {past.length} passées
          </p>
        </div>
        <Button
          className="bg-flehub-green hover:bg-flehub-green/90 text-white"
          onClick={() => { setForm({ ...emptyForm }); setDialogOpen(true); }}
        >
          <Plus className="w-4 h-4 mr-2" />
          Planifier une session
        </Button>
      </div>

      {loading ? (
        <div className="space-y-3">
          {Array.from({ length: 3 }).map((_, i) => (
            <Skeleton key={i} className="h-28 rounded-xl" />
          ))}
        </div>
      ) : (
        <>
          {upcoming.length > 0 && (
            <div className="space-y-3">
              <h2 className="text-xs font-semibold text-gray-500 uppercase tracking-wider">
                À venir &amp; En direct
              </h2>
              {upcoming.map((s) => <SessionCard key={s.id} session={s} />)}
            </div>
          )}

          {past.length > 0 && (
            <div className="space-y-3">
              <h2 className="text-xs font-semibold text-gray-400 uppercase tracking-wider">
                Passées
              </h2>
              {past.map((s) => <SessionCard key={s.id} session={s} />)}
            </div>
          )}

          {sessions.length === 0 && (
            <div className="flex flex-col items-center justify-center py-20 text-gray-400">
              <VideoOff className="w-12 h-12 mb-3 opacity-40" />
              <p className="text-lg font-medium">Aucune session</p>
              <p className="text-sm">Planifiez votre première session en direct</p>
            </div>
          )}
        </>
      )}

      <Dialog open={dialogOpen} onOpenChange={setDialogOpen}>
        <DialogContent className="max-w-md">
          <DialogHeader>
            <DialogTitle>Planifier une session en direct</DialogTitle>
          </DialogHeader>
          <div className="space-y-4 py-2">
            <div className="space-y-1">
              <Label>Titre <span className="text-red-500">*</span></Label>
              <Input
                placeholder="ex. : Pratique orale B1"
                value={form.title}
                onChange={(e) => setForm({ ...form, title: e.target.value })}
              />
            </div>
            <div className="space-y-1">
              <Label>Description</Label>
              <Textarea
                rows={2}
                placeholder="Contenu abordé..."
                value={form.description}
                onChange={(e) => setForm({ ...form, description: e.target.value })}
              />
            </div>
            <div className="space-y-1">
              <Label>Date &amp; heure <span className="text-red-500">*</span></Label>
              <Input
                type="datetime-local"
                value={form.scheduled_at}
                onChange={(e) => setForm({ ...form, scheduled_at: e.target.value })}
              />
            </div>
            <div className="grid grid-cols-2 gap-3">
              <div className="space-y-1">
                <Label>Durée (minutes)</Label>
                <Input
                  type="number"
                  min={15}
                  value={form.duration_minutes}
                  onChange={(e) => setForm({ ...form, duration_minutes: parseInt(e.target.value) || 60 })}
                />
              </div>
              <div className="space-y-1">
                <Label>Participants max</Label>
                <Input
                  type="number"
                  min={1}
                  value={form.max_participants}
                  onChange={(e) => setForm({ ...form, max_participants: parseInt(e.target.value) || 20 })}
                />
              </div>
            </div>
            <div className="space-y-1">
              <Label>Niveau CECRL <span className="text-red-500">*</span></Label>
              <Select
                value={form.cefr_level}
                onValueChange={(v) => setForm({ ...form, cefr_level: v as CEFR })}
              >
                <SelectTrigger>
                  <SelectValue placeholder="Sélectionner un niveau" />
                </SelectTrigger>
                <SelectContent>
                  {cefrLevels.map((l) => (
                    <SelectItem key={l} value={l}>{l}</SelectItem>
                  ))}
                </SelectContent>
              </Select>
            </div>
            <div className="space-y-1">
              <Label className="flex items-center gap-1.5">
                <LinkIcon className="w-3.5 h-3.5 text-gray-400" />
                Lien de la réunion
              </Label>
              <Input
                type="url"
                placeholder="https://meet.google.com/... ou zoom.us/j/..."
                value={form.meeting_url}
                onChange={(e) => setForm({ ...form, meeting_url: e.target.value })}
              />
              <p className="text-xs text-gray-400">Google Meet, Zoom, Teams — collez le lien ici</p>
            </div>
          </div>
          <DialogFooter>
            <Button variant="outline" onClick={() => setDialogOpen(false)}>
              Annuler
            </Button>
            <Button
              className="bg-flehub-green hover:bg-flehub-green/90 text-white"
              onClick={handleSave}
              disabled={saving || !form.title || !form.scheduled_at || !form.cefr_level}
            >
              {saving ? 'Enregistrement...' : 'Planifier'}
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>
    </div>
  );
}
