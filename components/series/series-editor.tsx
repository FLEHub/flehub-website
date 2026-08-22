'use client'

import { useEffect, useRef, useState } from 'react'
import { useRouter } from 'next/navigation'
import { createClient } from '@/lib/supabase/client'
import type { ArticleCategory } from '@/lib/articles'
import {
  CREATOR_ASSETS_BUCKET,
  ensureUniqueSeriesSlug,
  getCreatorIdForProfile,
  seriesTypeLabel,
  type SeriesStatus,
  type SeriesType,
} from '@/lib/series'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { Label } from '@/components/ui/label'
import { Textarea } from '@/components/ui/textarea'
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from '@/components/ui/select'
import { AlertTriangle, Loader2, Upload, X } from 'lucide-react'

export type SeriesEditorInitial = {
  id: string
  type: SeriesType
  title: string
  slug: string
  description: string | null
  cover_image_url: string | null
  category_id: string | null
  status: SeriesStatus
  published_at: string | null
}

type Props = {
  initial?: SeriesEditorInitial | null
  categories: ArticleCategory[]
  /** When true, type cannot be changed (edit mode). */
  lockType?: boolean
}

export function SeriesEditor({
  initial = null,
  categories,
  lockType = false,
}: Props) {
  const router = useRouter()
  const supabase = createClient()
  const coverRef = useRef<HTMLInputElement>(null)

  const [type, setType] = useState<SeriesType>(initial?.type ?? 'webseries')
  const [title, setTitle] = useState(initial?.title ?? '')
  const [categoryId, setCategoryId] = useState(initial?.category_id ?? '')
  const [description, setDescription] = useState(initial?.description ?? '')
  const [coverUrl, setCoverUrl] = useState(initial?.cover_image_url ?? '')
  const [status, setStatus] = useState<SeriesStatus>(initial?.status ?? 'draft')

  const [saving, setSaving] = useState<'draft' | 'publish' | 'unpublish' | null>(
    null
  )
  const [uploadingCover, setUploadingCover] = useState(false)
  const [error, setError] = useState<string | null>(null)

  useEffect(() => {
    if (!initial) return
    setType(initial.type)
    setTitle(initial.title)
    setCategoryId(initial.category_id ?? '')
    setDescription(initial.description ?? '')
    setCoverUrl(initial.cover_image_url ?? '')
    setStatus(initial.status)
  }, [initial])

  const uploadCover = async (file: File) => {
    setUploadingCover(true)
    setError(null)
    try {
      const {
        data: { user },
      } = await supabase.auth.getUser()
      if (!user) throw new Error('Session expirée. Reconnectez-vous.')

      const ext = file.name.split('.').pop()?.toLowerCase() || 'jpg'
      const path = `${user.id}/covers/${crypto.randomUUID()}.${ext}`
      const { error: upErr } = await supabase.storage
        .from(CREATOR_ASSETS_BUCKET)
        .upload(path, file, { upsert: true })
      if (upErr) throw upErr

      const { data: urlData } = supabase.storage
        .from(CREATOR_ASSETS_BUCKET)
        .getPublicUrl(path)
      setCoverUrl(`${urlData.publicUrl}?t=${Date.now()}`)
    } catch (err) {
      setError((err as Error).message)
    } finally {
      setUploadingCover(false)
    }
  }

  const save = async (nextStatus: SeriesStatus) => {
    const trimmedTitle = title.trim()
    if (!trimmedTitle) {
      setError('Le titre est obligatoire.')
      return
    }

    setSaving(
      nextStatus === 'published'
        ? 'publish'
        : nextStatus === 'draft' && status === 'published'
          ? 'unpublish'
          : 'draft'
    )
    setError(null)

    try {
      const {
        data: { user },
      } = await supabase.auth.getUser()
      if (!user) throw new Error('Session expirée. Reconnectez-vous.')

      const creatorId = await getCreatorIdForProfile(supabase, user.id)
      if (!creatorId) {
        throw new Error(
          'Aucun profil créateur associé. Contactez un administrateur.'
        )
      }

      const slug = await ensureUniqueSeriesSlug(
        supabase,
        trimmedTitle,
        initial?.id
      )
      const now = new Date().toISOString()
      const payload = {
        creator_id: creatorId,
        category_id: categoryId || null,
        type,
        title: trimmedTitle,
        slug,
        description: description.trim() || null,
        cover_image_url: coverUrl || null,
        status: nextStatus,
        published_at:
          nextStatus === 'published'
            ? initial?.published_at && status === 'published'
              ? initial.published_at
              : now
            : null,
        updated_at: now,
      }

      if (initial?.id) {
        const { error: updErr } = await supabase
          .from('series')
          .update({
            category_id: payload.category_id,
            title: payload.title,
            slug: payload.slug,
            description: payload.description,
            cover_image_url: payload.cover_image_url,
            status: payload.status,
            published_at: payload.published_at,
            updated_at: payload.updated_at,
            // type locked on edit
          })
          .eq('id', initial.id)
        if (updErr) throw updErr
        setStatus(nextStatus)
        router.push(`/dashboard/creator/series/${initial.id}`)
      } else {
        const { data: created, error: insErr } = await supabase
          .from('series')
          .insert(payload)
          .select('id')
          .single()
        if (insErr) throw insErr
        setStatus(nextStatus)
        router.push(`/dashboard/creator/series/${created.id}`)
      }
      router.refresh()
    } catch (err) {
      setError((err as Error).message)
    } finally {
      setSaving(null)
    }
  }

  const busy = saving !== null || uploadingCover

  return (
    <div className="space-y-6 max-w-3xl">
      {error && (
        <div className="flex items-center gap-2 rounded-lg bg-red-50 border border-red-200 px-4 py-3 text-sm text-red-700">
          <AlertTriangle className="w-4 h-4 flex-shrink-0" />
          <span className="flex-1">{error}</span>
          <button type="button" onClick={() => setError(null)}>
            <X className="w-4 h-4" />
          </button>
        </div>
      )}

      <div className="space-y-2">
        <Label>Type</Label>
        <Select
          value={type}
          onValueChange={(v) => setType(v as SeriesType)}
          disabled={busy || lockType}
        >
          <SelectTrigger className="bg-white">
            <SelectValue placeholder="Type de série" />
          </SelectTrigger>
          <SelectContent>
            <SelectItem value="webseries">
              {seriesTypeLabel('webseries')}
            </SelectItem>
            <SelectItem value="podcast">
              {seriesTypeLabel('podcast')}
            </SelectItem>
          </SelectContent>
        </Select>
        {lockType && (
          <p className="text-xs text-gray-500">
            Le type ne peut plus être modifié après création.
          </p>
        )}
      </div>

      <div className="space-y-2">
        <Label htmlFor="title">Titre</Label>
        <Input
          id="title"
          value={title}
          onChange={(e) => setTitle(e.target.value)}
          placeholder="Titre de la série"
          disabled={busy}
        />
      </div>

      <div className="space-y-2">
        <Label>Catégorie</Label>
        <Select
          value={categoryId || undefined}
          onValueChange={setCategoryId}
          disabled={busy || categories.length === 0}
        >
          <SelectTrigger className="bg-white">
            <SelectValue placeholder="Choisir une catégorie" />
          </SelectTrigger>
          <SelectContent>
            {categories.map((c) => (
              <SelectItem key={c.id} value={c.id}>
                {c.name}
              </SelectItem>
            ))}
          </SelectContent>
        </Select>
      </div>

      <div className="space-y-2">
        <Label htmlFor="description">Description</Label>
        <Textarea
          id="description"
          value={description}
          onChange={(e) => setDescription(e.target.value)}
          placeholder="Description de la série"
          rows={5}
          disabled={busy}
        />
      </div>

      <div className="space-y-2">
        <Label>Image de couverture</Label>
        <div className="flex flex-col sm:flex-row gap-4 items-start">
          {coverUrl ? (
            // eslint-disable-next-line @next/next/no-img-element
            <img
              src={coverUrl}
              alt="Couverture"
              className="w-full sm:w-56 h-36 object-cover rounded-lg border border-gray-200"
            />
          ) : (
            <div className="w-full sm:w-56 h-36 rounded-lg border border-dashed border-gray-200 bg-gray-50 flex items-center justify-center text-xs text-gray-400">
              Aucune image
            </div>
          )}
          <div className="flex flex-col gap-2">
            <input
              ref={coverRef}
              type="file"
              accept="image/png,image/jpeg,image/jpg,image/webp"
              className="hidden"
              onChange={(e) => {
                const f = e.target.files?.[0]
                if (f) void uploadCover(f)
                e.target.value = ''
              }}
            />
            <Button
              type="button"
              variant="outline"
              disabled={busy}
              onClick={() => coverRef.current?.click()}
            >
              {uploadingCover ? (
                <Loader2 className="w-4 h-4 mr-2 animate-spin" />
              ) : (
                <Upload className="w-4 h-4 mr-2" />
              )}
              {coverUrl ? 'Changer l’image' : 'Téléverser une image'}
            </Button>
            {coverUrl && (
              <Button
                type="button"
                variant="ghost"
                disabled={busy}
                onClick={() => setCoverUrl('')}
                className="justify-start text-gray-500"
              >
                Retirer l’image
              </Button>
            )}
          </div>
        </div>
      </div>

      <div className="flex flex-wrap gap-3 pt-2 border-t border-gray-100">
        <Button
          type="button"
          variant="outline"
          disabled={busy}
          onClick={() => void save('draft')}
        >
          {saving === 'draft' || saving === 'unpublish' ? (
            <Loader2 className="w-4 h-4 mr-2 animate-spin" />
          ) : null}
          {status === 'published'
            ? 'Dépublier (brouillon)'
            : 'Enregistrer en brouillon'}
        </Button>
        <Button
          type="button"
          disabled={busy}
          className="bg-[#1E5FA8] hover:bg-[#164A82]"
          onClick={() => void save('published')}
        >
          {saving === 'publish' ? (
            <Loader2 className="w-4 h-4 mr-2 animate-spin" />
          ) : null}
          Publier la série
        </Button>
        <Button
          type="button"
          variant="ghost"
          disabled={busy}
          onClick={() =>
            router.push(
              initial?.id
                ? `/dashboard/creator/series/${initial.id}`
                : '/dashboard/creator'
            )
          }
        >
          Annuler
        </Button>
      </div>
    </div>
  )
}
