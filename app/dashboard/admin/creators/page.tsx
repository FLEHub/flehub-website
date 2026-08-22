'use client'

import { useCallback, useEffect, useRef, useState } from 'react'
import { createClient } from '@/lib/supabase/client'
import { CREATOR_ASSETS_BUCKET } from '@/lib/series'
import {
  Clapperboard,
  Plus,
  RefreshCw,
  PauseCircle,
  CheckCircle2,
  Upload,
  Pencil,
  AlertTriangle,
  X,
} from 'lucide-react'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { Label } from '@/components/ui/label'
import { Textarea } from '@/components/ui/textarea'
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
import {
  Dialog,
  DialogContent,
  DialogFooter,
  DialogHeader,
  DialogTitle,
} from '@/components/ui/dialog'

type UserStatus = 'pending' | 'approved' | 'rejected' | 'suspended'

interface CreatorRow {
  id: string
  profile_id: string
  bio: string | null
  avatar_url: string | null
  created_at: string
  full_name: string
  email: string
  status: UserStatus
}

const STATUS_CLASS: Record<UserStatus, string> = {
  pending: 'bg-yellow-50 text-yellow-700 border-yellow-200',
  approved: 'bg-[#E8F1FA] text-[#1E5FA8] border-green-200',
  rejected: 'bg-red-50 text-red-700 border-red-200',
  suspended: 'bg-orange-50 text-orange-700 border-orange-200',
}

export default function AdminCreatorsPage() {
  const supabase = createClient()

  const [rows, setRows] = useState<CreatorRow[]>([])
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)
  const [success, setSuccess] = useState<string | null>(null)
  const [creating, setCreating] = useState(false)
  const [actionId, setActionId] = useState<string | null>(null)

  const [fullName, setFullName] = useState('')
  const [email, setEmail] = useState('')
  const [password, setPassword] = useState('')
  const [bio, setBio] = useState('')

  const [editOpen, setEditOpen] = useState(false)
  const [editing, setEditing] = useState<CreatorRow | null>(null)
  const [editBio, setEditBio] = useState('')
  const [editSaving, setEditSaving] = useState(false)
  const [avatarUploading, setAvatarUploading] = useState(false)
  const avatarInputRef = useRef<HTMLInputElement>(null)

  const fetchCreators = useCallback(async () => {
    setLoading(true)
    setError(null)
    try {
      const { data: creators, error: cErr } = await supabase
        .from('creators')
        .select('id, profile_id, bio, avatar_url, created_at')
        .order('created_at', { ascending: false })
      if (cErr) throw cErr

      const profileIds = (creators ?? []).map((c) => c.profile_id)
      let profilesById: Record<
        string,
        { full_name: string | null; email: string | null; status: UserStatus }
      > = {}

      if (profileIds.length > 0) {
        const { data: profiles, error: pErr } = await supabase
          .from('profiles')
          .select('id, full_name, email, status')
          .in('id', profileIds)
        if (pErr) throw pErr
        profilesById = Object.fromEntries(
          (profiles ?? []).map((p) => [p.id, p as (typeof profiles)[number]])
        )
      }

      setRows(
        (creators ?? []).map((c) => {
          const p = profilesById[c.profile_id]
          return {
            id: c.id,
            profile_id: c.profile_id,
            bio: c.bio,
            avatar_url: c.avatar_url,
            created_at: c.created_at,
            full_name: p?.full_name ?? '—',
            email: p?.email ?? '—',
            status: (p?.status as UserStatus) ?? 'approved',
          }
        })
      )
    } catch (err) {
      setError((err as Error).message || 'Failed to load creators.')
    } finally {
      setLoading(false)
    }
  }, [supabase])

  useEffect(() => {
    fetchCreators()
  }, [fetchCreators])

  const handleCreate = async (e: React.FormEvent) => {
    e.preventDefault()
    setCreating(true)
    setError(null)
    setSuccess(null)
    try {
      const res = await fetch('/api/admin/creators', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          full_name: fullName,
          email,
          password,
          bio,
        }),
      })
      const data = await res.json()
      if (!res.ok) throw new Error(data.error || 'Create failed')
      setFullName('')
      setEmail('')
      setPassword('')
      setBio('')
      setSuccess('Creator account created successfully.')
      await fetchCreators()
    } catch (err) {
      setError((err as Error).message)
    } finally {
      setCreating(false)
    }
  }

  const updateStatus = async (profileId: string, status: UserStatus) => {
    setActionId(profileId + status)
    setError(null)
    try {
      const { error: err } = await supabase
        .from('profiles')
        .update({ status, updated_at: new Date().toISOString() })
        .eq('id', profileId)
      if (err) throw err
      await fetchCreators()
    } catch (err) {
      setError((err as Error).message)
    } finally {
      setActionId(null)
    }
  }

  const openEdit = (row: CreatorRow) => {
    setEditing(row)
    setEditBio(row.bio ?? '')
    setEditOpen(true)
  }

  const saveEdit = async () => {
    if (!editing) return
    setEditSaving(true)
    setError(null)
    try {
      const { error: err } = await supabase
        .from('creators')
        .update({ bio: editBio.trim() || null, updated_at: new Date().toISOString() })
        .eq('id', editing.id)
      if (err) throw err
      setEditOpen(false)
      setEditing(null)
      await fetchCreators()
    } catch (err) {
      setError((err as Error).message)
    } finally {
      setEditSaving(false)
    }
  }

  const uploadAvatar = async (file: File) => {
    if (!editing) return
    setAvatarUploading(true)
    setError(null)
    try {
      const ext = file.name.split('.').pop()?.toLowerCase() || 'png'
      const path = `${editing.profile_id}/avatar.${ext}`
      const { error: upErr } = await supabase.storage
        .from(CREATOR_ASSETS_BUCKET)
        .upload(path, file, { upsert: true })
      if (upErr) throw upErr

      const { data: urlData } = supabase.storage
        .from(CREATOR_ASSETS_BUCKET)
        .getPublicUrl(path)
      const publicUrl = `${urlData.publicUrl}?t=${Date.now()}`

      const { error: dbErr } = await supabase
        .from('creators')
        .update({ avatar_url: publicUrl, updated_at: new Date().toISOString() })
        .eq('id', editing.id)
      if (dbErr) throw dbErr

      setEditing((prev) => (prev ? { ...prev, avatar_url: publicUrl } : prev))
      await fetchCreators()
    } catch (err) {
      setError((err as Error).message)
    } finally {
      setAvatarUploading(false)
    }
  }

  return (
    <div className="p-6 space-y-6 max-w-5xl mx-auto">
      <div>
        <h1 className="text-2xl font-bold text-gray-900">Creators</h1>
        <p className="text-sm text-gray-500 mt-1">
          Create and manage creator accounts for web-séries and podcasts.
        </p>
      </div>

      {error && (
        <div className="flex items-center gap-2 rounded-lg bg-red-50 border border-red-200 px-4 py-3 text-sm text-red-700">
          <AlertTriangle className="w-4 h-4 flex-shrink-0" />
          <span className="flex-1">{error}</span>
          <button type="button" onClick={() => setError(null)}>
            <X className="w-4 h-4" />
          </button>
        </div>
      )}
      {success && (
        <div className="flex items-center gap-2 rounded-lg bg-[#E8F1FA] border border-green-200 px-4 py-3 text-sm text-[#1E5FA8]">
          <CheckCircle2 className="w-4 h-4 flex-shrink-0" />
          {success}
        </div>
      )}

      <Card className="border-0 shadow-sm">
        <CardHeader className="pb-3">
          <div className="flex items-center gap-2">
            <div className="w-8 h-8 rounded-lg bg-[#E8F1FA] flex items-center justify-center">
              <Plus className="w-4 h-4 text-[#1E5FA8]" />
            </div>
            <CardTitle className="text-base">Create creator</CardTitle>
          </div>
        </CardHeader>
        <CardContent>
          <form onSubmit={handleCreate} className="grid grid-cols-1 sm:grid-cols-2 gap-4">
            <div className="space-y-1.5">
              <Label htmlFor="c-name">Full name</Label>
              <Input
                id="c-name"
                value={fullName}
                onChange={(e) => setFullName(e.target.value)}
                required
                placeholder="Jane Doe"
              />
            </div>
            <div className="space-y-1.5">
              <Label htmlFor="c-email">Email</Label>
              <Input
                id="c-email"
                type="email"
                value={email}
                onChange={(e) => setEmail(e.target.value)}
                required
                placeholder="creator@mfk.rw"
              />
            </div>
            <div className="space-y-1.5">
              <Label htmlFor="c-password">Password</Label>
              <Input
                id="c-password"
                type="password"
                value={password}
                onChange={(e) => setPassword(e.target.value)}
                required
                minLength={8}
                placeholder="Min. 8 characters"
              />
            </div>
            <div className="space-y-1.5 sm:col-span-2">
              <Label htmlFor="c-bio">Bio (optional)</Label>
              <Textarea
                id="c-bio"
                value={bio}
                onChange={(e) => setBio(e.target.value)}
                rows={3}
                placeholder="Short biography…"
              />
            </div>
            <div className="sm:col-span-2 flex justify-end">
              <Button
                type="submit"
                disabled={creating}
                className="bg-[#1E5FA8] hover:bg-[#164A82] text-white"
              >
                {creating ? (
                  <RefreshCw className="w-4 h-4 animate-spin mr-1.5" />
                ) : (
                  <Plus className="w-4 h-4 mr-1.5" />
                )}
                {creating ? 'Creating…' : 'Create account'}
              </Button>
            </div>
          </form>
        </CardContent>
      </Card>

      <Card className="border-0 shadow-sm">
        <CardHeader className="pb-3">
          <div className="flex items-center justify-between gap-2">
            <div className="flex items-center gap-2">
              <div className="w-8 h-8 rounded-lg bg-blue-50 flex items-center justify-center">
                <Clapperboard className="w-4 h-4 text-blue-600" />
              </div>
              <CardTitle className="text-base">Existing creators</CardTitle>
            </div>
            <Button variant="outline" size="sm" onClick={fetchCreators} disabled={loading}>
              <RefreshCw className={`w-3.5 h-3.5 mr-1.5 ${loading ? 'animate-spin' : ''}`} />
              Refresh
            </Button>
          </div>
        </CardHeader>
        <CardContent>
          {loading ? (
            <div className="h-24 bg-gray-100 rounded animate-pulse" />
          ) : rows.length === 0 ? (
            <p className="text-sm text-gray-500 py-8 text-center">No creators yet.</p>
          ) : (
            <div className="overflow-x-auto">
              <Table>
                <TableHeader>
                  <TableRow>
                    <TableHead>Creator</TableHead>
                    <TableHead>Email</TableHead>
                    <TableHead>Status</TableHead>
                    <TableHead>Bio</TableHead>
                    <TableHead className="text-right">Actions</TableHead>
                  </TableRow>
                </TableHeader>
                <TableBody>
                  {rows.map((row) => (
                    <TableRow key={row.id}>
                      <TableCell>
                        <div className="flex items-center gap-3">
                          {row.avatar_url ? (
                            // eslint-disable-next-line @next/next/no-img-element
                            <img
                              src={row.avatar_url}
                              alt=""
                              className="w-9 h-9 rounded-full object-cover border border-gray-200"
                            />
                          ) : (
                            <div className="w-9 h-9 rounded-full bg-gray-100 flex items-center justify-center text-xs font-semibold text-gray-500">
                              {row.full_name.slice(0, 2).toUpperCase()}
                            </div>
                          )}
                          <span className="font-medium text-gray-900">{row.full_name}</span>
                        </div>
                      </TableCell>
                      <TableCell className="text-sm text-gray-600">{row.email}</TableCell>
                      <TableCell>
                        <Badge
                          variant="secondary"
                          className={`border ${STATUS_CLASS[row.status]}`}
                        >
                          {row.status}
                        </Badge>
                      </TableCell>
                      <TableCell className="max-w-[220px] truncate text-sm text-gray-500">
                        {row.bio || '—'}
                      </TableCell>
                      <TableCell className="text-right space-x-1">
                        <Button
                          variant="outline"
                          size="sm"
                          onClick={() => openEdit(row)}
                          className="border-gray-200"
                        >
                          <Pencil className="w-3.5 h-3.5 mr-1" />
                          Edit
                        </Button>
                        {row.status === 'suspended' ? (
                          <Button
                            variant="outline"
                            size="sm"
                            disabled={actionId === row.profile_id + 'approved'}
                            onClick={() => updateStatus(row.profile_id, 'approved')}
                            className="border-green-200 text-[#1E5FA8]"
                          >
                            <CheckCircle2 className="w-3.5 h-3.5 mr-1" />
                            Reactivate
                          </Button>
                        ) : (
                          <Button
                            variant="outline"
                            size="sm"
                            disabled={actionId === row.profile_id + 'suspended'}
                            onClick={() => updateStatus(row.profile_id, 'suspended')}
                            className="border-orange-200 text-orange-700"
                          >
                            <PauseCircle className="w-3.5 h-3.5 mr-1" />
                            Suspend
                          </Button>
                        )}
                      </TableCell>
                    </TableRow>
                  ))}
                </TableBody>
              </Table>
            </div>
          )}
        </CardContent>
      </Card>

      <Dialog open={editOpen} onOpenChange={setEditOpen}>
        <DialogContent className="sm:max-w-md">
          <DialogHeader>
            <DialogTitle>Edit creator</DialogTitle>
          </DialogHeader>
          {editing && (
            <div className="space-y-4 py-2">
              <div className="flex items-center gap-4">
                {editing.avatar_url ? (
                  // eslint-disable-next-line @next/next/no-img-element
                  <img
                    src={editing.avatar_url}
                    alt=""
                    className="w-16 h-16 rounded-full object-cover border border-gray-200"
                  />
                ) : (
                  <div className="w-16 h-16 rounded-full bg-gray-100 flex items-center justify-center text-sm font-semibold text-gray-500">
                    {editing.full_name.slice(0, 2).toUpperCase()}
                  </div>
                )}
                <div>
                  <p className="font-medium text-gray-900">{editing.full_name}</p>
                  <p className="text-xs text-gray-500">{editing.email}</p>
                  <input
                    ref={avatarInputRef}
                    type="file"
                    accept="image/png,image/jpeg,image/jpg,image/webp"
                    className="hidden"
                    onChange={(e) => {
                      const f = e.target.files?.[0]
                      if (f) uploadAvatar(f)
                      e.target.value = ''
                    }}
                  />
                  <Button
                    type="button"
                    variant="outline"
                    size="sm"
                    className="mt-2"
                    disabled={avatarUploading}
                    onClick={() => avatarInputRef.current?.click()}
                  >
                    {avatarUploading ? (
                      <RefreshCw className="w-3.5 h-3.5 animate-spin mr-1" />
                    ) : (
                      <Upload className="w-3.5 h-3.5 mr-1" />
                    )}
                    {avatarUploading ? 'Uploading…' : 'Upload avatar'}
                  </Button>
                </div>
              </div>
              <div className="space-y-1.5">
                <Label htmlFor="edit-bio">Bio</Label>
                <Textarea
                  id="edit-bio"
                  value={editBio}
                  onChange={(e) => setEditBio(e.target.value)}
                  rows={4}
                />
              </div>
            </div>
          )}
          <DialogFooter>
            <Button variant="outline" onClick={() => setEditOpen(false)}>
              Cancel
            </Button>
            <Button
              onClick={saveEdit}
              disabled={editSaving}
              className="bg-[#1E5FA8] hover:bg-[#164A82] text-white"
            >
              {editSaving ? 'Saving…' : 'Save'}
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>
    </div>
  )
}
