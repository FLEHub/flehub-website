'use client'

import { useState, useEffect, useCallback } from 'react'
import { createClient } from '@/lib/supabase/client'
import {
  Search,
  CheckCircle2,
  XCircle,
  PauseCircle,
  RefreshCw,
  Users,
  ChevronDown,
} from 'lucide-react'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { Badge } from '@/components/ui/badge'
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card'
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from '@/components/ui/table'
import { Tabs, TabsContent, TabsList, TabsTrigger } from '@/components/ui/tabs'
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuTrigger,
} from '@/components/ui/dropdown-menu'

type UserStatus = 'pending' | 'approved' | 'rejected' | 'suspended'
type UserRole = 'admin' | 'school' | 'teacher' | 'learner'

interface Profile {
  id: string
  full_name: string | null
  email: string | null
  role: UserRole
  status: UserStatus
  created_at: string
}

const STATUS_CONFIG: Record<
  UserStatus,
  { label: string; className: string }
> = {
  pending: {
    label: 'Pending',
    className: 'bg-yellow-50 text-yellow-700 border border-yellow-200',
  },
  approved: {
    label: 'Approved',
    className: 'bg-[#E6F5EE] text-[#00A550] border border-green-200',
  },
  rejected: {
    label: 'Rejected',
    className: 'bg-red-50 text-red-700 border border-red-200',
  },
  suspended: {
    label: 'Suspended',
    className: 'bg-orange-50 text-orange-700 border border-orange-200',
  },
}

const ROLE_CONFIG: Record<UserRole, { label: string; className: string }> = {
  admin: { label: 'Admin', className: 'bg-purple-50 text-purple-700' },
  school: { label: 'School', className: 'bg-blue-50 text-blue-700' },
  teacher: { label: 'Teacher', className: 'bg-teal-50 text-teal-700' },
  learner: { label: 'Learner', className: 'bg-gray-100 text-gray-600' },
}

const TABS: { value: string; label: string; role?: UserRole }[] = [
  { value: 'all', label: 'All' },
  { value: 'learner', label: 'Learners', role: 'learner' },
  { value: 'teacher', label: 'Teachers', role: 'teacher' },
  { value: 'school', label: 'Schools', role: 'school' },
  { value: 'admin', label: 'Admins', role: 'admin' },
]

export default function AdminUsersPage() {
  const supabase = createClient()

  const [profiles, setProfiles] = useState<Profile[]>([])
  const [loading, setLoading] = useState(true)
  const [actionLoading, setActionLoading] = useState<string | null>(null)
  const [searchQuery, setSearchQuery] = useState('')
  const [activeTab, setActiveTab] = useState('all')
  const [error, setError] = useState<string | null>(null)

  const fetchProfiles = useCallback(async () => {
    setLoading(true)
    setError(null)
    try {
      const { data, error: fetchError } = await supabase
        .from('profiles')
        .select('id, full_name, email, role, status, created_at')
        .order('created_at', { ascending: false })

      if (fetchError) throw fetchError
      setProfiles(data ?? [])
    } catch (err) {
      setError('Failed to load users. Please try again.')
    } finally {
      setLoading(false)
    }
  }, [supabase])

  useEffect(() => {
    fetchProfiles()
  }, [fetchProfiles])

  const updateStatus = async (userId: string, newStatus: UserStatus) => {
    setActionLoading(userId + newStatus)
    setError(null)
    try {
      const { error: updateError } = await supabase
        .from('profiles')
        .update({ status: newStatus })
        .eq('id', userId)

      if (updateError) throw updateError

      setProfiles((prev) =>
        prev.map((p) => (p.id === userId ? { ...p, status: newStatus } : p))
      )
    } catch {
      setError('Failed to update user status. Please try again.')
    } finally {
      setActionLoading(null)
    }
  }

  // Filter profiles based on active tab and search query
  const filteredProfiles = profiles.filter((p) => {
    const matchesTab =
      activeTab === 'all' || p.role === (activeTab as UserRole)

    const query = searchQuery.toLowerCase().trim()
    const matchesSearch =
      !query ||
      p.full_name?.toLowerCase().includes(query) ||
      p.email?.toLowerCase().includes(query)

    return matchesTab && matchesSearch
  })

  const countByRole = (role?: UserRole) =>
    role
      ? profiles.filter((p) => p.role === role).length
      : profiles.length

  return (
    <div className="p-6 space-y-6">
      {/* Page header */}
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
        <div>
          <h1 className="text-2xl font-bold text-gray-900">User Management</h1>
          <p className="text-sm text-gray-500 mt-1">
            Manage and approve FLEHub platform users.
          </p>
        </div>
        <Button
          variant="outline"
          size="sm"
          onClick={fetchProfiles}
          disabled={loading}
          className="self-start sm:self-auto flex items-center gap-2"
        >
          <RefreshCw className={`w-4 h-4 ${loading ? 'animate-spin' : ''}`} />
          Refresh
        </Button>
      </div>

      {/* Error banner */}
      {error && (
        <div className="rounded-lg bg-red-50 border border-red-200 px-4 py-3 text-sm text-red-700">
          {error}
        </div>
      )}

      <Card className="border-0 shadow-sm">
        <CardHeader className="pb-4">
          {/* Search */}
          <div className="flex items-center gap-3">
            <div className="relative flex-1 max-w-sm">
              <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-gray-400" />
              <Input
                placeholder="Search by name or email…"
                value={searchQuery}
                onChange={(e) => setSearchQuery(e.target.value)}
                className="pl-9 border-gray-200 focus:border-[#00A550] focus:ring-[#00A550]/20"
              />
            </div>
            <div className="text-sm text-gray-500">
              <span className="font-semibold text-gray-900">{filteredProfiles.length}</span>{' '}
              {filteredProfiles.length === 1 ? 'user' : 'users'}
            </div>
          </div>
        </CardHeader>

        <CardContent className="p-0">
          <Tabs value={activeTab} onValueChange={setActiveTab}>
            <div className="px-6 border-b border-gray-100">
              <TabsList className="h-auto bg-transparent p-0 gap-0">
                {TABS.map((tab) => (
                  <TabsTrigger
                    key={tab.value}
                    value={tab.value}
                    className="rounded-none border-b-2 border-transparent data-[state=active]:border-[#00A550] data-[state=active]:text-[#00A550] data-[state=active]:bg-transparent text-gray-600 hover:text-gray-900 pb-3 pt-2 px-4 text-sm font-medium transition-colors"
                  >
                    {tab.label}
                    <span className="ml-1.5 text-xs text-gray-400">
                      ({countByRole(tab.role)})
                    </span>
                  </TabsTrigger>
                ))}
              </TabsList>
            </div>

            {TABS.map((tab) => (
              <TabsContent key={tab.value} value={tab.value} className="mt-0">
                <Table>
                  <TableHeader>
                    <TableRow className="border-gray-100">
                      <TableHead className="text-xs text-gray-500 font-medium pl-6">
                        Name
                      </TableHead>
                      <TableHead className="text-xs text-gray-500 font-medium">
                        Email
                      </TableHead>
                      <TableHead className="text-xs text-gray-500 font-medium">
                        Role
                      </TableHead>
                      <TableHead className="text-xs text-gray-500 font-medium">
                        Status
                      </TableHead>
                      <TableHead className="text-xs text-gray-500 font-medium">
                        Joined
                      </TableHead>
                      <TableHead className="text-xs text-gray-500 font-medium pr-6 text-right">
                        Actions
                      </TableHead>
                    </TableRow>
                  </TableHeader>
                  <TableBody>
                    {loading ? (
                      Array.from({ length: 5 }).map((_, i) => (
                        <TableRow key={i} className="border-gray-50">
                          {Array.from({ length: 6 }).map((_, j) => (
                            <TableCell key={j} className="py-3">
                              <div className="h-4 rounded bg-gray-100 animate-pulse w-3/4" />
                            </TableCell>
                          ))}
                        </TableRow>
                      ))
                    ) : filteredProfiles.length === 0 ? (
                      <TableRow>
                        <TableCell
                          colSpan={6}
                          className="text-center py-16 text-gray-500"
                        >
                          <div className="flex flex-col items-center gap-2">
                            <Users className="w-8 h-8 text-gray-300" />
                            <p className="text-sm">No users found</p>
                            {searchQuery && (
                              <button
                                onClick={() => setSearchQuery('')}
                                className="text-xs text-[#00A550] hover:underline"
                              >
                                Clear search
                              </button>
                            )}
                          </div>
                        </TableCell>
                      </TableRow>
                    ) : (
                      filteredProfiles.map((profile) => {
                        const statusCfg = STATUS_CONFIG[profile.status] ?? STATUS_CONFIG.pending
                        const roleCfg = ROLE_CONFIG[profile.role] ?? ROLE_CONFIG.learner
                        const isActing = actionLoading?.startsWith(profile.id)

                        return (
                          <TableRow
                            key={profile.id}
                            className="border-gray-50 hover:bg-gray-50/70 transition-colors"
                          >
                            {/* Name */}
                            <TableCell className="pl-6 py-3">
                              <div className="flex items-center gap-2.5">
                                <div className="w-8 h-8 rounded-full bg-[#E6F5EE] flex items-center justify-center flex-shrink-0">
                                  <span className="text-xs font-semibold text-[#00A550]">
                                    {(
                                      profile.full_name ??
                                      profile.email ??
                                      'U'
                                    )[0].toUpperCase()}
                                  </span>
                                </div>
                                <span className="text-sm font-medium text-gray-900 truncate max-w-[140px]">
                                  {profile.full_name ?? '—'}
                                </span>
                              </div>
                            </TableCell>

                            {/* Email */}
                            <TableCell className="text-sm text-gray-600 py-3 max-w-[180px] truncate">
                              {profile.email ?? '—'}
                            </TableCell>

                            {/* Role */}
                            <TableCell className="py-3">
                              <span
                                className={`text-xs px-2 py-0.5 rounded-full font-medium capitalize ${roleCfg.className}`}
                              >
                                {roleCfg.label}
                              </span>
                            </TableCell>

                            {/* Status */}
                            <TableCell className="py-3">
                              <span
                                className={`text-xs px-2 py-0.5 rounded-full font-medium ${statusCfg.className}`}
                              >
                                {statusCfg.label}
                              </span>
                            </TableCell>

                            {/* Joined */}
                            <TableCell className="text-xs text-gray-500 py-3">
                              {new Date(profile.created_at).toLocaleDateString(
                                'en-RW',
                                {
                                  day: 'numeric',
                                  month: 'short',
                                  year: 'numeric',
                                }
                              )}
                            </TableCell>

                            {/* Actions */}
                            <TableCell className="py-3 pr-6 text-right">
                              <div className="flex items-center justify-end gap-1.5">
                                {profile.status === 'pending' && (
                                  <>
                                    <Button
                                      size="sm"
                                      disabled={!!isActing}
                                      onClick={() =>
                                        updateStatus(profile.id, 'approved')
                                      }
                                      className="h-7 px-2.5 text-xs bg-[#00A550] hover:bg-[#008040] text-white"
                                    >
                                      <CheckCircle2 className="w-3.5 h-3.5 mr-1" />
                                      Approve
                                    </Button>
                                    <Button
                                      size="sm"
                                      variant="outline"
                                      disabled={!!isActing}
                                      onClick={() =>
                                        updateStatus(profile.id, 'rejected')
                                      }
                                      className="h-7 px-2.5 text-xs text-red-600 border-red-200 hover:bg-red-50"
                                    >
                                      <XCircle className="w-3.5 h-3.5 mr-1" />
                                      Reject
                                    </Button>
                                  </>
                                )}

                                {profile.status === 'approved' && (
                                  <DropdownMenu>
                                    <DropdownMenuTrigger asChild>
                                      <Button
                                        size="sm"
                                        variant="outline"
                                        disabled={!!isActing}
                                        className="h-7 px-2.5 text-xs border-gray-200"
                                      >
                                        Actions
                                        <ChevronDown className="w-3 h-3 ml-1" />
                                      </Button>
                                    </DropdownMenuTrigger>
                                    <DropdownMenuContent align="end" className="w-36">
                                      <DropdownMenuItem
                                        onClick={() =>
                                          updateStatus(profile.id, 'suspended')
                                        }
                                        className="text-orange-600 focus:text-orange-600 focus:bg-orange-50 text-xs"
                                      >
                                        <PauseCircle className="w-3.5 h-3.5 mr-2" />
                                        Suspend
                                      </DropdownMenuItem>
                                      <DropdownMenuItem
                                        onClick={() =>
                                          updateStatus(profile.id, 'rejected')
                                        }
                                        className="text-red-600 focus:text-red-600 focus:bg-red-50 text-xs"
                                      >
                                        <XCircle className="w-3.5 h-3.5 mr-2" />
                                        Reject
                                      </DropdownMenuItem>
                                    </DropdownMenuContent>
                                  </DropdownMenu>
                                )}

                                {(profile.status === 'rejected' ||
                                  profile.status === 'suspended') && (
                                  <Button
                                    size="sm"
                                    variant="outline"
                                    disabled={!!isActing}
                                    onClick={() =>
                                      updateStatus(profile.id, 'approved')
                                    }
                                    className="h-7 px-2.5 text-xs text-[#00A550] border-green-200 hover:bg-[#E6F5EE]"
                                  >
                                    <CheckCircle2 className="w-3.5 h-3.5 mr-1" />
                                    Reactivate
                                  </Button>
                                )}
                              </div>
                            </TableCell>
                          </TableRow>
                        )
                      })
                    )}
                  </TableBody>
                </Table>
              </TabsContent>
            ))}
          </Tabs>
        </CardContent>
      </Card>
    </div>
  )
}
