import { redirect } from 'next/navigation'
import { revalidatePath } from 'next/cache'
import { createClient } from '@/lib/supabase/server'
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card'
import { Badge } from '@/components/ui/badge'
import { Button } from '@/components/ui/button'
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from '@/components/ui/table'
import {
  Users,
  Clock,
  School,
  UserCheck,
  CheckCircle2,
  XCircle,
  FileText,
  DollarSign,
  TrendingUp,
  CalendarDays,
  ArrowRight,
  ShieldAlert,
} from 'lucide-react'
import Link from 'next/link'

// ─── Server Actions ────────────────────────────────────────────────────────────

async function approveUser(formData: FormData) {
  'use server'
  const userId = formData.get('userId') as string
  if (!userId) return

  const supabase = await createClient()
  await supabase
    .from('profiles')
    .update({ status: 'approved' })
    .eq('id', userId)

  revalidatePath('/dashboard/admin')
}

async function rejectUser(formData: FormData) {
  'use server'
  const userId = formData.get('userId') as string
  if (!userId) return

  const supabase = await createClient()
  await supabase
    .from('profiles')
    .update({ status: 'rejected' })
    .eq('id', userId)

  revalidatePath('/dashboard/admin')
}

// ─── Helpers ───────────────────────────────────────────────────────────────────

function StatCard({
  title,
  value,
  icon: Icon,
  iconColor,
  iconBg,
  trend,
}: {
  title: string
  value: number | string
  icon: React.ElementType
  iconColor: string
  iconBg: string
  trend?: string
}) {
  return (
    <Card className="border-0 shadow-sm hover:shadow-md transition-shadow">
      <CardContent className="p-5">
        <div className="flex items-center justify-between">
          <div>
            <p className="text-sm text-gray-500 font-medium">{title}</p>
            <p className="text-2xl font-bold text-gray-900 mt-1">{value}</p>
            {trend && (
              <p className="text-xs text-gray-400 mt-1 flex items-center gap-1">
                <TrendingUp className="w-3 h-3 text-[#00A550]" />
                {trend}
              </p>
            )}
          </div>
          <div className={`flex items-center justify-center w-11 h-11 rounded-xl ${iconBg}`}>
            <Icon className={`w-5 h-5 ${iconColor}`} />
          </div>
        </div>
      </CardContent>
    </Card>
  )
}

function statusBadge(status: string) {
  const map: Record<string, string> = {
    pending: 'bg-yellow-50 text-yellow-700 border-yellow-200',
    approved: 'bg-green-50 text-green-700 border-green-200',
    rejected: 'bg-red-50 text-red-700 border-red-200',
    suspended: 'bg-orange-50 text-orange-700 border-orange-200',
    upcoming: 'bg-blue-50 text-blue-700 border-blue-200',
    ongoing: 'bg-[#E6F5EE] text-[#00A550] border-green-200',
    completed: 'bg-gray-100 text-gray-600 border-gray-200',
    cancelled: 'bg-red-50 text-red-600 border-red-200',
  }
  return map[status] ?? 'bg-gray-100 text-gray-600 border-gray-200'
}

function roleBadgeColor(role: string) {
  const map: Record<string, string> = {
    admin: 'bg-purple-50 text-purple-700',
    school: 'bg-blue-50 text-blue-700',
    teacher: 'bg-teal-50 text-teal-700',
    learner: 'bg-gray-50 text-gray-600',
  }
  return map[role] ?? 'bg-gray-50 text-gray-600'
}

// ─── Page ──────────────────────────────────────────────────────────────────────

export default async function AdminDashboardPage() {
  const supabase = await createClient()

  // Auth guard
  const {
    data: { user },
  } = await supabase.auth.getUser()
  if (!user) redirect('/login')

  const { data: adminProfile } = await supabase
    .from('profiles')
    .select('role')
    .eq('id', user.id)
    .maybeSingle()
  if (adminProfile?.role !== 'admin') redirect('/dashboard')

  // ── Fetch stats ────────────────────────────────────────────────────────────

  const [
    { count: totalUsers },
    { count: pendingCount },
    { count: activeSchools },
    { count: activeTeachers },
  ] = await Promise.all([
    supabase.from('profiles').select('*', { count: 'exact', head: true }),
    supabase
      .from('profiles')
      .select('*', { count: 'exact', head: true })
      .eq('status', 'pending'),
    supabase
      .from('profiles')
      .select('*', { count: 'exact', head: true })
      .eq('role', 'school')
      .eq('status', 'approved'),
    supabase
      .from('profiles')
      .select('*', { count: 'exact', head: true })
      .eq('role', 'teacher')
      .eq('status', 'approved'),
  ])

  // ── Pending approvals ──────────────────────────────────────────────────────

  const { data: pendingUsers } = await supabase
    .from('profiles')
    .select('id, full_name, email, role, created_at')
    .eq('status', 'pending')
    .order('created_at', { ascending: false })
    .limit(10)

  // ── Recent exam sessions ───────────────────────────────────────────────────

  const { data: examSessions } = await supabase
    .from('exam_sessions')
    .select('id, title, cefr_level, exam_date, venue, status')
    .order('exam_date', { ascending: false })
    .limit(5)

  // ── Recent payments ────────────────────────────────────────────────────────

  const { data: payments } = await supabase
    .from('payments')
    .select('id, amount_rwf, status, created_at, learners(profiles(full_name, email))')
    .order('created_at', { ascending: false })
    .limit(5)

  // ── Total revenue (completed payments) ────────────────────────────────────

  const { data: revenueData } = await supabase
    .from('payments')
    .select('amount_rwf')
    .eq('status', 'completed')

  const totalRevenue = (revenueData ?? []).reduce(
    (sum, p) => sum + (p.amount_rwf ?? 0),
    0
  )

  return (
    <div className="p-6 space-y-8">
      {/* Page title */}
      <div>
        <h1 className="text-2xl font-bold text-gray-900">Admin Dashboard</h1>
        <p className="text-sm text-gray-500 mt-1">
          Welcome back — here&apos;s what&apos;s happening on FLEHub today.
        </p>
      </div>

      {/* Stat cards */}
      <div className="grid grid-cols-1 sm:grid-cols-2 xl:grid-cols-4 gap-4">
        <StatCard
          title="Total Users"
          value={totalUsers ?? 0}
          icon={Users}
          iconColor="text-[#00A550]"
          iconBg="bg-[#E6F5EE]"
        />
        <StatCard
          title="Pending Approvals"
          value={pendingCount ?? 0}
          icon={ShieldAlert}
          iconColor="text-yellow-600"
          iconBg="bg-yellow-50"
        />
        <StatCard
          title="Active Schools"
          value={activeSchools ?? 0}
          icon={School}
          iconColor="text-blue-600"
          iconBg="bg-blue-50"
        />
        <StatCard
          title="Active Teachers"
          value={activeTeachers ?? 0}
          icon={UserCheck}
          iconColor="text-teal-600"
          iconBg="bg-teal-50"
        />
      </div>

      {/* Pending approvals */}
      {(pendingUsers?.length ?? 0) > 0 && (
        <Card className="border-0 shadow-sm">
          <CardHeader className="pb-3 flex flex-row items-center justify-between">
            <div className="flex items-center gap-2">
              <div className="w-8 h-8 rounded-lg bg-yellow-50 flex items-center justify-center">
                <Clock className="w-4 h-4 text-yellow-600" />
              </div>
              <CardTitle className="text-base font-semibold">
                Approbations en attente
              </CardTitle>
              <Badge className="bg-yellow-100 text-yellow-700 border-0 text-xs">
                {pendingCount}
              </Badge>
            </div>
            <Link
              href="/dashboard/admin/users?status=pending"
              className="text-sm text-[#00A550] hover:underline flex items-center gap-1"
            >
              View all <ArrowRight className="w-3.5 h-3.5" />
            </Link>
          </CardHeader>
          <CardContent>
            <div className="space-y-2">
              {pendingUsers?.map((u) => (
                <div
                  key={u.id}
                  className="flex items-center justify-between py-2.5 px-3 rounded-lg bg-gray-50 hover:bg-gray-100 transition-colors"
                >
                  <div className="flex items-center gap-3 min-w-0">
                    <div className="w-8 h-8 rounded-full bg-[#E6F5EE] flex items-center justify-center flex-shrink-0">
                      <span className="text-sm font-semibold text-[#00A550]">
                        {(u.full_name ?? u.email ?? 'U')[0].toUpperCase()}
                      </span>
                    </div>
                    <div className="min-w-0">
                      <p className="text-sm font-medium text-gray-900 truncate">
                        {u.full_name ?? 'No name'}
                      </p>
                      <p className="text-xs text-gray-500 truncate">{u.email}</p>
                    </div>
                    <span
                      className={`hidden sm:inline-flex text-xs px-2 py-0.5 rounded-full font-medium capitalize ${roleBadgeColor(u.role ?? '')}`}
                    >
                      {u.role}
                    </span>
                  </div>

                  <div className="flex items-center gap-2 flex-shrink-0 ml-3">
                    <form action={approveUser}>
                      <input type="hidden" name="userId" value={u.id} />
                      <button
                        type="submit"
                        className="flex items-center gap-1 text-xs bg-[#00A550] hover:bg-[#008040] text-white px-3 py-1.5 rounded-lg font-medium transition-colors"
                      >
                        <CheckCircle2 className="w-3.5 h-3.5" />
                        Approve
                      </button>
                    </form>
                    <form action={rejectUser}>
                      <input type="hidden" name="userId" value={u.id} />
                      <button
                        type="submit"
                        className="flex items-center gap-1 text-xs bg-white hover:bg-red-50 text-red-600 border border-red-200 px-3 py-1.5 rounded-lg font-medium transition-colors"
                      >
                        <XCircle className="w-3.5 h-3.5" />
                        Reject
                      </button>
                    </form>
                  </div>
                </div>
              ))}
            </div>
          </CardContent>
        </Card>
      )}

      {/* Two-column section: Exam sessions + Payments */}
      <div className="grid grid-cols-1 xl:grid-cols-2 gap-6">
        {/* Recent Exam Sessions */}
        <Card className="border-0 shadow-sm">
          <CardHeader className="pb-3 flex flex-row items-center justify-between">
            <div className="flex items-center gap-2">
              <div className="w-8 h-8 rounded-lg bg-[#E6F5EE] flex items-center justify-center">
                <FileText className="w-4 h-4 text-[#00A550]" />
              </div>
              <CardTitle className="text-base font-semibold">Recent Exam Sessions</CardTitle>
            </div>
            <Link
              href="/dashboard/admin/exams"
              className="text-sm text-[#00A550] hover:underline flex items-center gap-1"
            >
              View all <ArrowRight className="w-3.5 h-3.5" />
            </Link>
          </CardHeader>
          <CardContent className="p-0">
            <Table>
              <TableHeader>
                <TableRow className="border-gray-100">
                  <TableHead className="text-xs text-gray-500 font-medium pl-4">Title</TableHead>
                  <TableHead className="text-xs text-gray-500 font-medium">Level</TableHead>
                  <TableHead className="text-xs text-gray-500 font-medium">Date</TableHead>
                  <TableHead className="text-xs text-gray-500 font-medium pr-4">Status</TableHead>
                </TableRow>
              </TableHeader>
              <TableBody>
                {(examSessions ?? []).length === 0 ? (
                  <TableRow>
                    <TableCell colSpan={4} className="text-center text-sm text-gray-500 py-8">
                      No exam sessions yet
                    </TableCell>
                  </TableRow>
                ) : (
                  examSessions?.map((s) => (
                    <TableRow key={s.id} className="border-gray-50 hover:bg-gray-50/60">
                      <TableCell className="text-sm font-medium text-gray-900 pl-4 py-3 max-w-[140px] truncate">
                        {s.title}
                      </TableCell>
                      <TableCell className="py-3">
                        <span className="text-xs font-semibold bg-[#E6F5EE] text-[#00A550] px-2 py-0.5 rounded">
                          {s.cefr_level}
                        </span>
                      </TableCell>
                      <TableCell className="text-xs text-gray-500 py-3">
                        {s.exam_date
                          ? new Date(s.exam_date).toLocaleDateString('en-RW', {
                              day: 'numeric',
                              month: 'short',
                              year: 'numeric',
                            })
                          : '—'}
                      </TableCell>
                      <TableCell className="py-3 pr-4">
                        <span
                          className={`text-xs px-2 py-0.5 rounded-full font-medium capitalize border ${statusBadge(s.status ?? '')}`}
                        >
                          {s.status ?? 'Unknown'}
                        </span>
                      </TableCell>
                    </TableRow>
                  ))
                )}
              </TableBody>
            </Table>
          </CardContent>
        </Card>

        {/* Recent Payments */}
        <Card className="border-0 shadow-sm">
          <CardHeader className="pb-3 flex flex-row items-center justify-between">
            <div className="flex items-center gap-2">
              <div className="w-8 h-8 rounded-lg bg-green-50 flex items-center justify-center">
                <DollarSign className="w-4 h-4 text-green-600" />
              </div>
              <CardTitle className="text-base font-semibold">Recent Payments</CardTitle>
            </div>
            <div className="text-right">
              <p className="text-xs text-gray-500">Total Revenue</p>
              <p className="text-sm font-bold text-[#00A550]">
                {totalRevenue.toLocaleString('en-RW')} RWF
              </p>
            </div>
          </CardHeader>
          <CardContent className="p-0">
            <Table>
              <TableHeader>
                <TableRow className="border-gray-100">
                  <TableHead className="text-xs text-gray-500 font-medium pl-4">User</TableHead>
                  <TableHead className="text-xs text-gray-500 font-medium">Amount</TableHead>
                  <TableHead className="text-xs text-gray-500 font-medium">Date</TableHead>
                  <TableHead className="text-xs text-gray-500 font-medium pr-4">Status</TableHead>
                </TableRow>
              </TableHeader>
              <TableBody>
                {(payments ?? []).length === 0 ? (
                  <TableRow>
                    <TableCell colSpan={4} className="text-center text-sm text-gray-500 py-8">
                      No payments yet
                    </TableCell>
                  </TableRow>
                ) : (
                  payments?.map((p) => {
                    const learner = p.learners as { profiles?: { full_name?: string; email?: string } } | null
                    const profile = learner?.profiles
                    return (
                      <TableRow key={p.id} className="border-gray-50 hover:bg-gray-50/60">
                        <TableCell className="text-sm text-gray-900 pl-4 py-3 max-w-[130px] truncate">
                          {profile?.full_name ?? profile?.email ?? 'Unknown'}
                        </TableCell>
                        <TableCell className="text-sm font-semibold text-gray-900 py-3">
                          {(p.amount_rwf ?? 0).toLocaleString('en-RW')}
                          <span className="text-xs font-normal text-gray-400 ml-1">RWF</span>
                        </TableCell>
                        <TableCell className="text-xs text-gray-500 py-3">
                          {new Date(p.created_at).toLocaleDateString('en-RW', {
                            day: 'numeric',
                            month: 'short',
                          })}
                        </TableCell>
                        <TableCell className="py-3 pr-4">
                          <span
                            className={`text-xs px-2 py-0.5 rounded-full font-medium capitalize border ${statusBadge(p.status ?? '')}`}
                          >
                            {p.status}
                          </span>
                        </TableCell>
                      </TableRow>
                    )
                  })
                )}
              </TableBody>
            </Table>
          </CardContent>
        </Card>
      </div>

      {/* Quick actions */}
      <Card className="border-0 shadow-sm">
        <CardHeader className="pb-3">
          <CardTitle className="text-base font-semibold">Quick Actions</CardTitle>
        </CardHeader>
        <CardContent>
          <div className="grid grid-cols-2 sm:grid-cols-4 gap-3">
            {[
              {
                label: 'Create Exam Session',
                href: '/dashboard/admin/exams?action=new',
                icon: FileText,
                color: 'text-[#00A550]',
                bg: 'bg-[#E6F5EE]',
              },
              {
                label: 'Manage Users',
                href: '/dashboard/admin/users',
                icon: Users,
                color: 'text-blue-600',
                bg: 'bg-blue-50',
              },
              {
                label: 'View Calendar',
                href: '/dashboard/admin/calendar',
                icon: CalendarDays,
                color: 'text-orange-600',
                bg: 'bg-orange-50',
              },
              {
                label: 'View Finances',
                href: '/dashboard/admin/finances',
                icon: DollarSign,
                color: 'text-green-600',
                bg: 'bg-green-50',
              },
            ].map((action) => {
              const Icon = action.icon
              return (
                <Link
                  key={action.href}
                  href={action.href}
                  className="flex flex-col items-center gap-2 p-4 rounded-xl border border-gray-100 hover:border-gray-200 hover:shadow-sm transition-all text-center group"
                >
                  <div
                    className={`w-10 h-10 rounded-xl flex items-center justify-center ${action.bg} group-hover:scale-110 transition-transform`}
                  >
                    <Icon className={`w-5 h-5 ${action.color}`} />
                  </div>
                  <span className="text-xs font-medium text-gray-700 leading-snug">
                    {action.label}
                  </span>
                </Link>
              )
            })}
          </div>
        </CardContent>
      </Card>
    </div>
  )
}
