'use client'

import { useCallback, useEffect, useRef, useState } from 'react'
import { createClient } from '@/lib/supabase/client'
import {
  PARTNER_LOGO_ACCEPT,
  PARTNER_LOGOS_BUCKET,
  normalizeWebsiteUrl,
  type Partner,
} from '@/lib/partners'
import {
  AlertTriangle,
  ArrowDown,
  ArrowUp,
  Building2,
  CheckCircle2,
  Plus,
  RefreshCw,
  Trash2,
  Upload,
  X,
} from 'lucide-react'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { Label } from '@/components/ui/label'
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

function partnerLogoStoragePath(publicUrl: string): string | null {
  const marker = `/storage/v1/object/public/${PARTNER_LOGOS_BUCKET}/`
  const idx = publicUrl.indexOf(marker)
  if (idx === -1) return null
  const path = publicUrl.slice(idx + marker.length).split('?')[0]
  return path || null
}

export default function AdminPartnersPage() {
  const supabase = createClient()
  const logoRef = useRef<HTMLInputElement>(null)

  const [rows, setRows] = useState<Partner[]>([])
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)
  const [success, setSuccess] = useState<string | null>(null)
  const [actionId, setActionId] = useState<string | null>(null)

  const [addOpen, setAddOpen] = useState(false)
  const [name, setName] = useState('')
  const [websiteUrl, setWebsiteUrl] = useState('')
  const [logoUrl, setLogoUrl] = useState('')
  const [uploading, setUploading] = useState(false)
  const [saving, setSaving] = useState(false)

  const fetchPartners = useCallback(async () => {
    setLoading(true)
    setError(null)
    try {
      const { data, error: qErr } = await supabase
        .from('partners')
        .select('id, name, logo_url, website_url, sort_order, created_at, updated_at')
        .order('sort_order', { ascending: true })
        .order('created_at', { ascending: true })
      if (qErr) throw qErr
      setRows((data ?? []) as Partner[])
    } catch (err) {
      setError((err as Error).message || 'Failed to load partners.')
    } finally {
      setLoading(false)
    }
  }, [supabase])

  useEffect(() => {
    void fetchPartners()
  }, [fetchPartners])

  const resetAddForm = () => {
    setName('')
    setWebsiteUrl('')
    setLogoUrl('')
    setError(null)
  }

  const uploadLogo = async (file: File) => {
    setUploading(true)
    setError(null)
    try {
      const ext = file.name.split('.').pop()?.toLowerCase() || 'png'
      const path = `${crypto.randomUUID()}.${ext}`
      const { error: upErr } = await supabase.storage
        .from(PARTNER_LOGOS_BUCKET)
        .upload(path, file, { upsert: true })
      if (upErr) throw upErr

      const { data: urlData } = supabase.storage
        .from(PARTNER_LOGOS_BUCKET)
        .getPublicUrl(path)
      setLogoUrl(`${urlData.publicUrl}?t=${Date.now()}`)
    } catch (err) {
      setError((err as Error).message)
    } finally {
      setUploading(false)
    }
  }

  const handleCreate = async (e: React.FormEvent) => {
    e.preventDefault()
    const trimmedName = name.trim()
    if (!trimmedName) {
      setError('Name is required.')
      return
    }
    if (!logoUrl) {
      setError('Please upload a logo.')
      return
    }

    setSaving(true)
    setError(null)
    setSuccess(null)
    try {
      const nextOrder =
        rows.length === 0
          ? 0
          : Math.max(...rows.map((r) => r.sort_order)) + 1

      const { error: insErr } = await supabase.from('partners').insert({
        name: trimmedName,
        logo_url: logoUrl,
        website_url: normalizeWebsiteUrl(websiteUrl),
        sort_order: nextOrder,
        updated_at: new Date().toISOString(),
      })
      if (insErr) throw insErr

      setAddOpen(false)
      resetAddForm()
      setSuccess('Partner added successfully.')
      await fetchPartners()
    } catch (err) {
      setError((err as Error).message)
    } finally {
      setSaving(false)
    }
  }

  const movePartner = async (id: string, direction: 'up' | 'down') => {
    const index = rows.findIndex((r) => r.id === id)
    if (index < 0) return
    const swapIndex = direction === 'up' ? index - 1 : index + 1
    if (swapIndex < 0 || swapIndex >= rows.length) return

    const a = rows[index]
    const b = rows[swapIndex]
    setActionId(id)
    setError(null)
    try {
      const now = new Date().toISOString()
      const { error: errA } = await supabase
        .from('partners')
        .update({ sort_order: b.sort_order, updated_at: now })
        .eq('id', a.id)
      if (errA) throw errA
      const { error: errB } = await supabase
        .from('partners')
        .update({ sort_order: a.sort_order, updated_at: now })
        .eq('id', b.id)
      if (errB) throw errB
      await fetchPartners()
    } catch (err) {
      setError((err as Error).message)
    } finally {
      setActionId(null)
    }
  }

  const deletePartner = async (row: Partner) => {
    if (!confirm(`Delete partner “${row.name}”?`)) return
    setActionId(row.id)
    setError(null)
    setSuccess(null)
    try {
      const { error: delErr } = await supabase
        .from('partners')
        .delete()
        .eq('id', row.id)
      if (delErr) throw delErr

      const path = partnerLogoStoragePath(row.logo_url)
      if (path) {
        await supabase.storage.from(PARTNER_LOGOS_BUCKET).remove([path])
      }

      setSuccess('Partner deleted.')
      await fetchPartners()
    } catch (err) {
      setError((err as Error).message)
    } finally {
      setActionId(null)
    }
  }

  return (
    <div className="p-6 space-y-6 max-w-5xl mx-auto">
      <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-3">
        <div>
          <h1 className="text-2xl font-bold text-gray-900">Partners</h1>
          <p className="text-sm text-gray-500 mt-1">
            Manage partner logos displayed at the bottom of the MFK homepage.
          </p>
        </div>
        <div className="flex gap-2">
          <Button
            type="button"
            variant="outline"
            size="sm"
            onClick={() => void fetchPartners()}
            disabled={loading}
          >
            <RefreshCw className={`w-4 h-4 mr-2 ${loading ? 'animate-spin' : ''}`} />
            Refresh
          </Button>
          <Button
            type="button"
            size="sm"
            className="bg-[#1E5FA8] hover:bg-[#164A82]"
            onClick={() => {
              resetAddForm()
              setAddOpen(true)
            }}
          >
            <Plus className="w-4 h-4 mr-2" />
            Add partner
          </Button>
        </div>
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
            <div className="w-8 h-8 rounded-lg bg-blue-50 flex items-center justify-center">
              <Building2 className="w-4 h-4 text-blue-600" />
            </div>
            <CardTitle className="text-base">Existing partners</CardTitle>
          </div>
        </CardHeader>
        <CardContent>
          {loading ? (
            <div className="h-24 bg-gray-100 rounded animate-pulse" />
          ) : rows.length === 0 ? (
            <p className="text-sm text-gray-500 py-8 text-center">
              No partners yet.
            </p>
          ) : (
            <div className="table-frame">
              <Table>
                <TableHeader>
                  <TableRow>
                    <TableHead className="w-16">Order</TableHead>
                    <TableHead>Logo</TableHead>
                    <TableHead>Name</TableHead>
                    <TableHead>Website</TableHead>
                    <TableHead className="text-right">Actions</TableHead>
                  </TableRow>
                </TableHeader>
                <TableBody>
                  {rows.map((row, index) => (
                    <TableRow key={row.id}>
                      <TableCell>
                        <div className="flex flex-col gap-1">
                          <Button
                            type="button"
                            size="sm"
                            variant="ghost"
                            className="h-7 w-7 p-0"
                            disabled={index === 0 || actionId === row.id}
                            onClick={() => void movePartner(row.id, 'up')}
                            aria-label="Move up"
                          >
                            <ArrowUp className="w-3.5 h-3.5" />
                          </Button>
                          <Button
                            type="button"
                            size="sm"
                            variant="ghost"
                            className="h-7 w-7 p-0"
                            disabled={
                              index === rows.length - 1 || actionId === row.id
                            }
                            onClick={() => void movePartner(row.id, 'down')}
                            aria-label="Move down"
                          >
                            <ArrowDown className="w-3.5 h-3.5" />
                          </Button>
                        </div>
                      </TableCell>
                      <TableCell>
                        {/* eslint-disable-next-line @next/next/no-img-element */}
                        <img
                          src={row.logo_url}
                          alt={row.name}
                          className="h-12 w-24 object-contain bg-gray-50 rounded border border-gray-100 p-1"
                        />
                      </TableCell>
                      <TableCell className="font-medium text-gray-900">
                        {row.name}
                      </TableCell>
                      <TableCell className="text-sm text-gray-600 max-w-[220px] truncate">
                        {row.website_url ? (
                          <a
                            href={row.website_url}
                            target="_blank"
                            rel="noopener noreferrer"
                            className="text-[#1E5FA8] hover:underline"
                          >
                            {row.website_url}
                          </a>
                        ) : (
                          '—'
                        )}
                      </TableCell>
                      <TableCell className="text-right">
                        <Button
                          type="button"
                          size="sm"
                          variant="outline"
                          className="border-red-200 text-red-700 hover:bg-red-50"
                          disabled={actionId === row.id}
                          onClick={() => void deletePartner(row)}
                        >
                          {actionId === row.id ? (
                            <RefreshCw className="w-3.5 h-3.5 animate-spin" />
                          ) : (
                            <>
                              <Trash2 className="w-3.5 h-3.5 mr-1" />
                              Delete
                            </>
                          )}
                        </Button>
                      </TableCell>
                    </TableRow>
                  ))}
                </TableBody>
              </Table>
            </div>
          )}
        </CardContent>
      </Card>

      <Dialog
        open={addOpen}
        onOpenChange={(open) => {
          setAddOpen(open)
          if (!open) resetAddForm()
        }}
      >
        <DialogContent className="sm:max-w-md">
          <DialogHeader>
            <DialogTitle>Add partner</DialogTitle>
          </DialogHeader>
          <form onSubmit={handleCreate} className="space-y-4 py-2">
            <div className="space-y-1.5">
              <Label htmlFor="partner-name">Name</Label>
              <Input
                id="partner-name"
                value={name}
                onChange={(e) => setName(e.target.value)}
                required
                placeholder="Partner name"
                disabled={saving || uploading}
              />
            </div>

            <div className="space-y-1.5">
              <Label>Logo</Label>
              <div className="flex flex-col gap-3">
                {logoUrl ? (
                  // eslint-disable-next-line @next/next/no-img-element
                  <img
                    src={logoUrl}
                    alt=""
                    className="h-20 w-40 object-contain bg-gray-50 rounded border border-gray-100 p-2"
                  />
                ) : (
                  <div className="h-20 w-40 rounded border border-dashed border-gray-200 bg-gray-50 flex items-center justify-center text-xs text-gray-400">
                    No logo
                  </div>
                )}
                <div>
                  <input
                    ref={logoRef}
                    type="file"
                    accept={PARTNER_LOGO_ACCEPT}
                    className="hidden"
                    onChange={(e) => {
                      const f = e.target.files?.[0]
                      if (f) void uploadLogo(f)
                      e.target.value = ''
                    }}
                  />
                  <Button
                    type="button"
                    variant="outline"
                    size="sm"
                    disabled={saving || uploading}
                    onClick={() => logoRef.current?.click()}
                  >
                    {uploading ? (
                      <RefreshCw className="w-3.5 h-3.5 animate-spin mr-1.5" />
                    ) : (
                      <Upload className="w-3.5 h-3.5 mr-1.5" />
                    )}
                    {logoUrl ? 'Change logo' : 'Upload logo'}
                  </Button>
                </div>
              </div>
            </div>

            <div className="space-y-1.5">
              <Label htmlFor="partner-url">Website (optional)</Label>
              <Input
                id="partner-url"
                type="text"
                value={websiteUrl}
                onChange={(e) => setWebsiteUrl(e.target.value)}
                placeholder="https://example.com"
                disabled={saving || uploading}
              />
            </div>

            <DialogFooter>
              <Button
                type="button"
                variant="outline"
                onClick={() => setAddOpen(false)}
                disabled={saving}
              >
                Cancel
              </Button>
              <Button
                type="submit"
                disabled={saving || uploading}
                className="bg-[#1E5FA8] hover:bg-[#164A82] text-white"
              >
                {saving ? 'Saving…' : 'Add partner'}
              </Button>
            </DialogFooter>
          </form>
        </DialogContent>
      </Dialog>
    </div>
  )
}
