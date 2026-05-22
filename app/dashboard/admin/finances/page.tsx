'use client';

import { useEffect, useState } from 'react';
import { createClient } from '@/lib/supabase/client';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import { Badge } from '@/components/ui/badge';
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from '@/components/ui/select';
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from '@/components/ui/table';
import {
  ChartContainer,
  ChartTooltip,
  ChartTooltipContent,
} from '@/components/ui/chart';
import {
  BarChart,
  Bar,
  XAxis,
  YAxis,
  CartesianGrid,
  ResponsiveContainer,
} from 'recharts';
import {
  DollarSign,
  TrendingUp,
  Clock,
  RefreshCw,
  Loader2,
  Save,
} from 'lucide-react';

interface Payment {
  id: string;
  learner_id: string;
  amount_rwf: number;
  payment_method: 'mtn_momo' | 'airtel_money' | 'bank_transfer' | 'cash';
  status: 'pending' | 'completed' | 'failed' | 'refunded';
  payment_type: string;
  created_at: string;
  profiles?: { full_name: string };
}

interface RetakeSetting {
  level: string;
  days: number;
}

const MONTHS = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

const CEFR_LEVELS = ['A1', 'A2', 'B1', 'B2', 'C1', 'C2'];

const METHOD_LABELS: Record<string, string> = {
  mtn_momo: 'MTN MoMo',
  airtel_money: 'Airtel Money',
  bank_transfer: 'Bank Transfer',
  cash: 'Cash',
};

const STATUS_COLORS: Record<string, string> = {
  pending: 'bg-amber-100 text-amber-700',
  completed: 'bg-green-100 text-green-700',
  failed: 'bg-red-100 text-red-700',
  refunded: 'bg-blue-100 text-blue-700',
};

function buildMonthlyData(payments: Payment[]) {
  const now = new Date();
  const months: { month: string; revenue: number }[] = [];
  for (let i = 5; i >= 0; i--) {
    const d = new Date(now.getFullYear(), now.getMonth() - i, 1);
    months.push({ month: MONTHS[d.getMonth()], revenue: 0 });
  }
  for (const p of payments) {
    if (p.status !== 'completed') continue;
    const d = new Date(p.created_at);
    const monthLabel = MONTHS[d.getMonth()];
    const entry = months.find((m) => m.month === monthLabel);
    if (entry) entry.revenue += p.amount_rwf;
  }
  return months;
}

function buildMethodBreakdown(payments: Payment[]) {
  const map: Record<string, number> = { mtn_momo: 0, airtel_money: 0, bank_transfer: 0, cash: 0 };
  let total = 0;
  for (const p of payments) {
    if (p.status === 'completed') {
      map[p.payment_method] = (map[p.payment_method] || 0) + p.amount_rwf;
      total += p.amount_rwf;
    }
  }
  return Object.entries(map).map(([k, v]) => ({
    method: METHOD_LABELS[k] || k,
    amount: v,
    pct: total > 0 ? Math.round((v / total) * 100) : 0,
  }));
}

const chartConfig = {
  revenue: { label: 'Revenue (RWF)', color: '#00A550' },
};

export default function AdminFinancesPage() {
  const supabase = createClient();

  const [payments, setPayments] = useState<Payment[]>([]);
  const [loading, setLoading] = useState(true);
  const [statusFilter, setStatusFilter] = useState('all');
  const [retakeSettings, setRetakeSettings] = useState<RetakeSetting[]>(
    CEFR_LEVELS.map((l) => ({ level: l, days: 30 }))
  );
  const [savingRetake, setSavingRetake] = useState(false);
  const [retakeSaved, setRetakeSaved] = useState(false);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    const load = async () => {
      setLoading(true);
      const { data, error: fetchErr } = await supabase
        .from('payments')
        .select('*, profiles(full_name)')
        .order('created_at', { ascending: false });
      if (fetchErr) {
        // Try without join
        const { data: d2 } = await supabase
          .from('payments')
          .select('*')
          .order('created_at', { ascending: false });
        setPayments((d2 as Payment[]) || []);
      } else {
        setPayments((data as Payment[]) || []);
      }

      // Load retake settings
      const { data: examSettings } = await supabase
        .from('exam_sessions')
        .select('cefr_level,retake_waiting_days')
        .not('retake_waiting_days', 'is', null);
      if (examSettings && examSettings.length > 0) {
        const settingsMap = new Map(
          (examSettings as { cefr_level: string; retake_waiting_days: number }[]).map((s) => [
            s.cefr_level,
            s.retake_waiting_days,
          ])
        );
        setRetakeSettings(
          CEFR_LEVELS.map((l) => ({ level: l, days: settingsMap.get(l) ?? 30 }))
        );
      }
      setLoading(false);
    };
    load();
  }, [supabase]);

  const totalRevenue = payments
    .filter((p) => p.status === 'completed')
    .reduce((s, p) => s + p.amount_rwf, 0);

  const now = new Date();
  const thisMonthRevenue = payments
    .filter((p) => {
      const d = new Date(p.created_at);
      return (
        p.status === 'completed' &&
        d.getMonth() === now.getMonth() &&
        d.getFullYear() === now.getFullYear()
      );
    })
    .reduce((s, p) => s + p.amount_rwf, 0);

  const pendingTotal = payments
    .filter((p) => p.status === 'pending')
    .reduce((s, p) => s + p.amount_rwf, 0);

  const refundTotal = payments
    .filter((p) => p.status === 'refunded')
    .reduce((s, p) => s + p.amount_rwf, 0);

  const monthlyData = buildMonthlyData(payments);
  const methodBreakdown = buildMethodBreakdown(payments);

  const filteredPayments =
    statusFilter === 'all' ? payments : payments.filter((p) => p.status === statusFilter);

  const saveRetakeSettings = async () => {
    setSavingRetake(true);
    setError(null);
    try {
      for (const setting of retakeSettings) {
        await supabase
          .from('exam_sessions')
          .update({ retake_waiting_days: setting.days })
          .eq('cefr_level', setting.level);
      }
      setRetakeSaved(true);
      setTimeout(() => setRetakeSaved(false), 2000);
    } catch {
      setError('Failed to save retake settings.');
    }
    setSavingRetake(false);
  };

  const fmtRwf = (n: number) =>
    new Intl.NumberFormat('en-RW', { style: 'decimal', maximumFractionDigits: 0 }).format(n);

  if (loading) {
    return (
      <div className="flex items-center justify-center min-h-[60vh]">
        <Loader2 className="h-8 w-8 animate-spin" style={{ color: '#00A550' }} />
      </div>
    );
  }

  return (
    <div className="p-6 space-y-6 max-w-7xl mx-auto">
      <div>
        <h1 className="text-2xl font-bold">Financial Reports</h1>
        <p className="text-muted-foreground text-sm mt-1">
          Overview of payments, revenue, and exam retake settings
        </p>
      </div>

      {error && (
        <div className="bg-destructive/10 text-destructive px-4 py-2 rounded-lg text-sm">
          {error}
        </div>
      )}

      {/* Summary Cards */}
      <div className="grid grid-cols-1 sm:grid-cols-2 xl:grid-cols-4 gap-4">
        {[
          {
            title: 'Total Revenue',
            value: `RWF ${fmtRwf(totalRevenue)}`,
            icon: DollarSign,
            color: '#00A550',
          },
          {
            title: 'This Month',
            value: `RWF ${fmtRwf(thisMonthRevenue)}`,
            icon: TrendingUp,
            color: '#00A550',
          },
          {
            title: 'Pending Payments',
            value: `RWF ${fmtRwf(pendingTotal)}`,
            icon: Clock,
            color: '#F59E0B',
          },
          {
            title: 'Refunds',
            value: `RWF ${fmtRwf(refundTotal)}`,
            icon: RefreshCw,
            color: '#3B82F6',
          },
        ].map((card) => (
          <Card key={card.title}>
            <CardContent className="p-5 flex items-center gap-4">
              <div
                className="h-11 w-11 rounded-full flex items-center justify-center shrink-0"
                style={{ backgroundColor: `${card.color}18` }}
              >
                <card.icon className="h-5 w-5" style={{ color: card.color }} />
              </div>
              <div>
                <p className="text-sm text-muted-foreground">{card.title}</p>
                <p className="text-xl font-bold mt-0.5">{card.value}</p>
              </div>
            </CardContent>
          </Card>
        ))}
      </div>

      {/* Charts Row */}
      <div className="grid grid-cols-1 xl:grid-cols-3 gap-6">
        {/* Revenue Bar Chart */}
        <Card className="xl:col-span-2">
          <CardHeader>
            <CardTitle className="text-base">Monthly Revenue (Last 6 Months)</CardTitle>
          </CardHeader>
          <CardContent>
            <ChartContainer config={chartConfig} className="h-56 w-full">
              <ResponsiveContainer width="100%" height="100%">
                <BarChart data={monthlyData} margin={{ top: 4, right: 4, left: 0, bottom: 0 }}>
                  <CartesianGrid strokeDasharray="3 3" className="stroke-muted" />
                  <XAxis
                    dataKey="month"
                    tick={{ fontSize: 12 }}
                    axisLine={false}
                    tickLine={false}
                  />
                  <YAxis
                    tick={{ fontSize: 11 }}
                    axisLine={false}
                    tickLine={false}
                    tickFormatter={(v) => `${(v / 1000).toFixed(0)}k`}
                  />
                  <ChartTooltip
                    content={<ChartTooltipContent />}
                    formatter={(value: number) => [`RWF ${fmtRwf(value)}`, 'Revenue']}
                  />
                  <Bar dataKey="revenue" fill="#00A550" radius={[4, 4, 0, 0]} />
                </BarChart>
              </ResponsiveContainer>
            </ChartContainer>
          </CardContent>
        </Card>

        {/* Method Breakdown */}
        <Card>
          <CardHeader>
            <CardTitle className="text-base">Payment Methods</CardTitle>
          </CardHeader>
          <CardContent className="space-y-4">
            {methodBreakdown.map((m) => (
              <div key={m.method}>
                <div className="flex justify-between text-sm mb-1">
                  <span className="font-medium">{m.method}</span>
                  <span className="text-muted-foreground">{m.pct}%</span>
                </div>
                <div className="h-2 rounded-full bg-muted overflow-hidden">
                  <div
                    className="h-full rounded-full transition-all"
                    style={{ width: `${m.pct}%`, backgroundColor: '#00A550' }}
                  />
                </div>
                <p className="text-xs text-muted-foreground mt-1">RWF {fmtRwf(m.amount)}</p>
              </div>
            ))}
            {methodBreakdown.every((m) => m.amount === 0) && (
              <p className="text-sm text-muted-foreground text-center py-4">
                No completed payments yet
              </p>
            )}
          </CardContent>
        </Card>
      </div>

      {/* Payments Table */}
      <Card>
        <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-4">
          <CardTitle className="text-base">Payments</CardTitle>
          <Select value={statusFilter} onValueChange={setStatusFilter}>
            <SelectTrigger className="w-40 h-8 text-sm">
              <SelectValue placeholder="Filter status" />
            </SelectTrigger>
            <SelectContent>
              <SelectItem value="all">All</SelectItem>
              <SelectItem value="pending">Pending</SelectItem>
              <SelectItem value="completed">Completed</SelectItem>
              <SelectItem value="failed">Failed</SelectItem>
              <SelectItem value="refunded">Refunded</SelectItem>
            </SelectContent>
          </Select>
        </CardHeader>
        <CardContent className="p-0">
          <div className="overflow-x-auto">
            <Table>
              <TableHeader>
                <TableRow>
                  <TableHead>Learner</TableHead>
                  <TableHead>Type</TableHead>
                  <TableHead>Amount</TableHead>
                  <TableHead>Method</TableHead>
                  <TableHead>Status</TableHead>
                  <TableHead>Date</TableHead>
                </TableRow>
              </TableHeader>
              <TableBody>
                {filteredPayments.length === 0 ? (
                  <TableRow>
                    <TableCell colSpan={6} className="text-center text-muted-foreground py-8">
                      No payments found
                    </TableCell>
                  </TableRow>
                ) : (
                  filteredPayments.map((p) => (
                    <TableRow key={p.id}>
                      <TableCell className="font-medium">
                        {p.profiles?.full_name || 'Unknown'}
                      </TableCell>
                      <TableCell className="capitalize text-sm">{p.payment_type || '-'}</TableCell>
                      <TableCell className="font-mono text-sm">
                        RWF {fmtRwf(p.amount_rwf)}
                      </TableCell>
                      <TableCell className="text-sm">
                        {METHOD_LABELS[p.payment_method] || p.payment_method}
                      </TableCell>
                      <TableCell>
                        <span
                          className={`text-xs font-medium px-2 py-0.5 rounded-full capitalize ${
                            STATUS_COLORS[p.status] || 'bg-muted text-muted-foreground'
                          }`}
                        >
                          {p.status}
                        </span>
                      </TableCell>
                      <TableCell className="text-sm text-muted-foreground">
                        {new Date(p.created_at).toLocaleDateString()}
                      </TableCell>
                    </TableRow>
                  ))
                )}
              </TableBody>
            </Table>
          </div>
        </CardContent>
      </Card>

      {/* Retake Settings */}
      <Card>
        <CardHeader>
          <CardTitle className="text-base">Retake Waiting Period Settings</CardTitle>
          <p className="text-sm text-muted-foreground">
            Set the minimum number of days between exam retakes per CEFR level
          </p>
        </CardHeader>
        <CardContent>
          <div className="grid grid-cols-2 sm:grid-cols-3 lg:grid-cols-6 gap-4 mb-4">
            {retakeSettings.map((s, i) => (
              <div key={s.level} className="space-y-1.5">
                <Label className="text-xs font-semibold" htmlFor={`retake-${s.level}`}>
                  {s.level}
                </Label>
                <div className="flex items-center gap-1">
                  <Input
                    id={`retake-${s.level}`}
                    type="number"
                    min={1}
                    max={365}
                    value={s.days}
                    onChange={(e) => {
                      const updated = [...retakeSettings];
                      updated[i] = { ...s, days: Number(e.target.value) };
                      setRetakeSettings(updated);
                    }}
                    className="h-9 text-sm"
                  />
                  <span className="text-xs text-muted-foreground shrink-0">d</span>
                </div>
              </div>
            ))}
          </div>
          <Button
            onClick={saveRetakeSettings}
            disabled={savingRetake}
            className="text-white"
            style={{ backgroundColor: '#00A550' }}
          >
            {savingRetake ? (
              <Loader2 className="h-4 w-4 animate-spin mr-2" />
            ) : (
              <Save className="h-4 w-4 mr-2" />
            )}
            {retakeSaved ? 'Saved!' : 'Save Settings'}
          </Button>
        </CardContent>
      </Card>
    </div>
  );
}
