'use client';

import { useEffect, useState } from 'react';
import { createClient } from '@/lib/supabase/client';
import { Button } from '@/components/ui/button';
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
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { ChevronLeft, ChevronRight, Plus, Loader2, CalendarDays } from 'lucide-react';

interface CalendarEvent {
  id: string;
  title: string;
  description?: string;
  event_type: 'exam' | 'session' | 'deadline' | 'holiday';
  start_date: string;
  end_date?: string;
  cefr_level?: string;
  is_public: boolean;
}

interface NewEvent {
  title: string;
  description: string;
  event_type: 'exam' | 'session' | 'deadline' | 'holiday';
  start_date: string;
  end_date: string;
  cefr_level: string;
  is_public: boolean;
}

const EVENT_COLORS: Record<string, { bg: string; text: string; dot: string }> = {
  exam: { bg: 'bg-green-100', text: 'text-green-800', dot: 'bg-green-500' },
  session: { bg: 'bg-blue-100', text: 'text-blue-800', dot: 'bg-blue-500' },
  deadline: { bg: 'bg-red-100', text: 'text-red-800', dot: 'bg-red-500' },
  holiday: { bg: 'bg-gray-100', text: 'text-gray-700', dot: 'bg-gray-400' },
};

const DAYS_OF_WEEK = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
const MONTHS_LONG = [
  'January', 'February', 'March', 'April', 'May', 'June',
  'July', 'August', 'September', 'October', 'November', 'December',
];
const CEFR_LEVELS = ['', 'A1', 'A2', 'B1', 'B2', 'C1', 'C2'];

function getDaysInMonth(year: number, month: number) {
  return new Date(year, month + 1, 0).getDate();
}

function getFirstDayOfMonth(year: number, month: number) {
  return new Date(year, month, 1).getDay();
}

function toDateStr(date: Date) {
  return date.toISOString().split('T')[0];
}

export default function AdminCalendarPage() {
  const supabase = createClient();

  const today = new Date();
  const [viewYear, setViewYear] = useState(today.getFullYear());
  const [viewMonth, setViewMonth] = useState(today.getMonth());
  const [events, setEvents] = useState<CalendarEvent[]>([]);
  const [loading, setLoading] = useState(true);
  const [addOpen, setAddOpen] = useState(false);
  const [selectedDay, setSelectedDay] = useState<string | null>(null);
  const [saving, setSaving] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [newEvent, setNewEvent] = useState<NewEvent>({
    title: '',
    description: '',
    event_type: 'exam',
    start_date: '',
    end_date: '',
    cefr_level: '',
    is_public: true,
  });

  const fetchEvents = async () => {
    const { data, error: fetchErr } = await supabase
      .from('calendar_events')
      .select('*')
      .order('start_date', { ascending: true });
    if (!fetchErr) setEvents((data as CalendarEvent[]) || []);
    setLoading(false);
  };

  useEffect(() => { fetchEvents(); }, []);

  const prevMonth = () => {
    if (viewMonth === 0) { setViewYear((y) => y - 1); setViewMonth(11); }
    else setViewMonth((m) => m - 1);
  };

  const nextMonth = () => {
    if (viewMonth === 11) { setViewYear((y) => y + 1); setViewMonth(0); }
    else setViewMonth((m) => m + 1);
  };

  const eventsForDay = (dateStr: string) =>
    events.filter((e) => {
      if (!e.end_date) return e.start_date === dateStr;
      return e.start_date <= dateStr && dateStr <= e.end_date;
    });

  const upcomingEvents = events
    .filter((e) => e.start_date >= toDateStr(today))
    .slice(0, 10);

  const openAddForDay = (dateStr: string) => {
    setNewEvent((prev) => ({ ...prev, start_date: dateStr, end_date: dateStr }));
    setSelectedDay(dateStr);
    setAddOpen(true);
  };

  const saveEvent = async () => {
    if (!newEvent.title || !newEvent.start_date) return;
    setSaving(true);
    setError(null);
    const payload = {
      title: newEvent.title,
      description: newEvent.description || null,
      event_type: newEvent.event_type,
      start_date: newEvent.start_date,
      end_date: newEvent.end_date || newEvent.start_date,
      cefr_level: newEvent.cefr_level || null,
      is_public: newEvent.is_public,
    };
    const { error: saveErr } = await supabase.from('calendar_events').insert(payload);
    if (saveErr) {
      setError('Failed to save event.');
    } else {
      setAddOpen(false);
      setNewEvent({
        title: '', description: '', event_type: 'exam',
        start_date: '', end_date: '', cefr_level: '', is_public: true,
      });
      await fetchEvents();
    }
    setSaving(false);
  };

  const daysInMonth = getDaysInMonth(viewYear, viewMonth);
  const firstDay = getFirstDayOfMonth(viewYear, viewMonth);
  const totalCells = Math.ceil((firstDay + daysInMonth) / 7) * 7;

  return (
    <div className="p-6 max-w-7xl mx-auto space-y-6">
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-2xl font-bold">Academic Calendar</h1>
          <p className="text-sm text-muted-foreground mt-1">
            Manage exam dates, sessions, deadlines, and holidays
          </p>
        </div>
        <Button
          onClick={() => {
            const d = toDateStr(today);
            setNewEvent((p) => ({ ...p, start_date: d, end_date: d }));
            setAddOpen(true);
          }}
          className="text-white"
          style={{ backgroundColor: '#00A550' }}
        >
          <Plus className="h-4 w-4 mr-2" />
          Add Event
        </Button>
      </div>

      {error && (
        <div className="bg-destructive/10 text-destructive px-4 py-2 rounded-lg text-sm">
          {error}
        </div>
      )}

      <div className="grid grid-cols-1 xl:grid-cols-4 gap-6">
        {/* Calendar */}
        <Card className="xl:col-span-3">
          <CardHeader className="pb-2">
            <div className="flex items-center justify-between">
              <CardTitle className="text-lg">
                {MONTHS_LONG[viewMonth]} {viewYear}
              </CardTitle>
              <div className="flex gap-1">
                <Button variant="outline" size="icon" className="h-8 w-8" onClick={prevMonth}>
                  <ChevronLeft className="h-4 w-4" />
                </Button>
                <Button variant="outline" size="icon" className="h-8 w-8" onClick={nextMonth}>
                  <ChevronRight className="h-4 w-4" />
                </Button>
              </div>
            </div>
          </CardHeader>
          <CardContent>
            {loading ? (
              <div className="flex items-center justify-center h-64">
                <Loader2 className="h-6 w-6 animate-spin" style={{ color: '#00A550' }} />
              </div>
            ) : (
              <>
                {/* Day headers */}
                <div className="grid grid-cols-7 mb-1">
                  {DAYS_OF_WEEK.map((d) => (
                    <div key={d} className="text-center text-xs font-medium text-muted-foreground py-2">
                      {d}
                    </div>
                  ))}
                </div>
                {/* Calendar grid */}
                <div className="grid grid-cols-7 border-l border-t">
                  {Array.from({ length: totalCells }).map((_, idx) => {
                    const dayNum = idx - firstDay + 1;
                    const isCurrentMonth = dayNum >= 1 && dayNum <= daysInMonth;
                    const dateStr = isCurrentMonth
                      ? `${viewYear}-${String(viewMonth + 1).padStart(2, '0')}-${String(dayNum).padStart(2, '0')}`
                      : '';
                    const isToday = dateStr === toDateStr(today);
                    const dayEvents = dateStr ? eventsForDay(dateStr) : [];

                    return (
                      <div
                        key={idx}
                        className={`min-h-[90px] border-r border-b p-1 transition-colors ${
                          isCurrentMonth ? 'bg-background hover:bg-muted/30 cursor-pointer' : 'bg-muted/10'
                        }`}
                        onClick={() => isCurrentMonth && openAddForDay(dateStr)}
                      >
                        {isCurrentMonth && (
                          <>
                            <div
                              className={`text-xs font-medium w-6 h-6 flex items-center justify-center rounded-full mb-1 ${
                                isToday
                                  ? 'text-white'
                                  : 'text-foreground'
                              }`}
                              style={isToday ? { backgroundColor: '#00A550' } : {}}
                            >
                              {dayNum}
                            </div>
                            <div className="space-y-0.5">
                              {dayEvents.slice(0, 2).map((ev) => {
                                const style = EVENT_COLORS[ev.event_type];
                                return (
                                  <div
                                    key={ev.id}
                                    className={`text-[10px] px-1 rounded truncate font-medium ${style.bg} ${style.text}`}
                                    title={ev.title}
                                    onClick={(e) => e.stopPropagation()}
                                  >
                                    {ev.title}
                                  </div>
                                );
                              })}
                              {dayEvents.length > 2 && (
                                <div className="text-[10px] text-muted-foreground px-1">
                                  +{dayEvents.length - 2} more
                                </div>
                              )}
                            </div>
                          </>
                        )}
                      </div>
                    );
                  })}
                </div>
              </>
            )}

            {/* Legend */}
            <div className="flex flex-wrap gap-3 mt-4 pt-4 border-t">
              {Object.entries(EVENT_COLORS).map(([type, style]) => (
                <div key={type} className="flex items-center gap-1.5 text-xs text-muted-foreground capitalize">
                  <span className={`h-2.5 w-2.5 rounded-full ${style.dot}`} />
                  {type}
                </div>
              ))}
            </div>
          </CardContent>
        </Card>

        {/* Upcoming Events Sidebar */}
        <Card>
          <CardHeader className="pb-2">
            <CardTitle className="text-sm font-semibold flex items-center gap-2">
              <CalendarDays className="h-4 w-4" style={{ color: '#00A550' }} />
              Upcoming Events
            </CardTitle>
          </CardHeader>
          <CardContent className="p-0">
            {upcomingEvents.length === 0 ? (
              <p className="text-sm text-muted-foreground text-center py-8 px-4">
                No upcoming events
              </p>
            ) : (
              <div className="divide-y">
                {upcomingEvents.map((ev) => {
                  const style = EVENT_COLORS[ev.event_type];
                  return (
                    <div key={ev.id} className="px-4 py-3 flex gap-3 items-start">
                      <span className={`mt-0.5 h-2.5 w-2.5 rounded-full shrink-0 ${style.dot}`} />
                      <div className="min-w-0">
                        <p className="text-sm font-medium truncate">{ev.title}</p>
                        <p className="text-xs text-muted-foreground mt-0.5">
                          {new Date(ev.start_date + 'T00:00:00').toLocaleDateString('en-US', {
                            month: 'short',
                            day: 'numeric',
                            year: 'numeric',
                          })}
                          {ev.cefr_level && (
                            <span className="ml-1.5 font-medium" style={{ color: '#00A550' }}>
                              {ev.cefr_level}
                            </span>
                          )}
                        </p>
                      </div>
                    </div>
                  );
                })}
              </div>
            )}
          </CardContent>
        </Card>
      </div>

      {/* Add Event Dialog */}
      <Dialog open={addOpen} onOpenChange={setAddOpen}>
        <DialogContent className="sm:max-w-lg">
          <DialogHeader>
            <DialogTitle>Add Calendar Event</DialogTitle>
          </DialogHeader>
          <div className="space-y-4 py-2">
            <div className="space-y-1.5">
              <Label>Title *</Label>
              <Input
                placeholder="Event title"
                value={newEvent.title}
                onChange={(e) => setNewEvent((p) => ({ ...p, title: e.target.value }))}
              />
            </div>
            <div className="space-y-1.5">
              <Label>Description</Label>
              <Textarea
                placeholder="Optional description"
                rows={3}
                value={newEvent.description}
                onChange={(e) => setNewEvent((p) => ({ ...p, description: e.target.value }))}
              />
            </div>
            <div className="grid grid-cols-2 gap-4">
              <div className="space-y-1.5">
                <Label>Event Type *</Label>
                <Select
                  value={newEvent.event_type}
                  onValueChange={(v) =>
                    setNewEvent((p) => ({ ...p, event_type: v as NewEvent['event_type'] }))
                  }
                >
                  <SelectTrigger>
                    <SelectValue />
                  </SelectTrigger>
                  <SelectContent>
                    <SelectItem value="exam">Exam</SelectItem>
                    <SelectItem value="session">Session</SelectItem>
                    <SelectItem value="deadline">Deadline</SelectItem>
                    <SelectItem value="holiday">Holiday</SelectItem>
                  </SelectContent>
                </Select>
              </div>
              <div className="space-y-1.5">
                <Label>CEFR Level</Label>
                <Select
                  value={newEvent.cefr_level}
                  onValueChange={(v) => setNewEvent((p) => ({ ...p, cefr_level: v }))}
                >
                  <SelectTrigger>
                    <SelectValue placeholder="All levels" />
                  </SelectTrigger>
                  <SelectContent>
                    <SelectItem value="">All levels</SelectItem>
                    {CEFR_LEVELS.filter(Boolean).map((l) => (
                      <SelectItem key={l} value={l}>{l}</SelectItem>
                    ))}
                  </SelectContent>
                </Select>
              </div>
            </div>
            <div className="grid grid-cols-2 gap-4">
              <div className="space-y-1.5">
                <Label>Start Date *</Label>
                <Input
                  type="date"
                  value={newEvent.start_date}
                  onChange={(e) => setNewEvent((p) => ({ ...p, start_date: e.target.value }))}
                />
              </div>
              <div className="space-y-1.5">
                <Label>End Date</Label>
                <Input
                  type="date"
                  value={newEvent.end_date}
                  onChange={(e) => setNewEvent((p) => ({ ...p, end_date: e.target.value }))}
                />
              </div>
            </div>
            <div className="flex items-center gap-2">
              <input
                type="checkbox"
                id="is_public"
                checked={newEvent.is_public}
                onChange={(e) => setNewEvent((p) => ({ ...p, is_public: e.target.checked }))}
                className="rounded"
                style={{ accentColor: '#00A550' }}
              />
              <Label htmlFor="is_public" className="cursor-pointer">
                Visible to all users
              </Label>
            </div>
          </div>
          <DialogFooter>
            <Button variant="outline" onClick={() => setAddOpen(false)}>
              Cancel
            </Button>
            <Button
              onClick={saveEvent}
              disabled={saving || !newEvent.title || !newEvent.start_date}
              className="text-white"
              style={{ backgroundColor: '#00A550' }}
            >
              {saving && <Loader2 className="h-4 w-4 animate-spin mr-2" />}
              Save Event
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>
    </div>
  );
}
