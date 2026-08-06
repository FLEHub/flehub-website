'use client'

import { useEffect, useMemo, useRef, useState } from 'react'
import { useRouter } from 'next/navigation'
import { createClient } from '@/lib/supabase/client'
import { getJournalistIdForProfile, type ArticleCategory } from '@/lib/articles'
import {
  GALLERY_PHOTO_ACCEPT,
  GALLERY_PHOTOS_BUCKET,
  ensureUniqueGallerySlug,
  galleryPhotoStoragePath,
  type GalleryPhoto,
  type GalleryStatus,
} from '@/lib/galleries'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { Label } from '@/components/ui/label'
import { Textarea } from '@/components/ui/textarea'
import { Progress } from '@/components/ui/progress'
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from '@/components/ui/select'
import {
  AlertTriangle,
  ImagePlus,
  Loader2,
  Star,
  Trash2,
  Upload,
  X,
} from 'lucide-react'

/** Nombre d’uploads simultanés vers le bucket (évite de saturer le navigateur). */
const UPLOAD_CONCURRENCY = 4

/**
 * Exécute `fn` sur chaque élément avec une concurrence limitée.
 * Les résultats restent indexés dans l’ordre d’entrée (ordre de sélection).
 */
async function mapWithConcurrency<T, R>(
  items: T[],
  concurrency: number,
  fn: (item: T, index: number) => Promise<R>,
  onProgress?: (done: number) => void
): Promise<R[]> {
  const results = new Array<R>(items.length)
  let nextIndex = 0
  let done = 0

  const worker = async () => {
    while (true) {
      const i = nextIndex
      nextIndex += 1
      if (i >= items.length) return
      results[i] = await fn(items[i], i)
      done += 1
      onProgress?.(done)
    }
  }

  const poolSize = Math.max(1, Math.min(concurrency, items.length))
  await Promise.all(Array.from({ length: poolSize }, () => worker()))
  return results
}

type LocalPhoto = {
  /** DB id when already persisted; otherwise a client temp id */
  key: string
  dbId: string | null
  photo_url: string
  caption: string
  sort_order: number
  storagePath: string | null
}

export type GalleryEditorInitial = {
  id: string
  title: string
  slug: string
  description: string | null
  cover_image_url: string | null
  category_id: string | null
  status: GalleryStatus
  published_at: string | null
  photos: GalleryPhoto[]
}

type Props = {
  initial?: GalleryEditorInitial | null
  categories: ArticleCategory[]
}

function toLocalPhotos(
  photos: GalleryPhoto[],
  coverUrl: string | null
): { locals: LocalPhoto[]; coverKey: string | null } {
  const sorted = [...photos].sort((a, b) => a.sort_order - b.sort_order)
  const locals: LocalPhoto[] = sorted.map((p, i) => ({
    key: p.id,
    dbId: p.id,
    photo_url: p.photo_url,
    caption: p.caption ?? '',
    sort_order: i,
    storagePath: galleryPhotoStoragePath(p.photo_url),
  }))
  const cover =
    locals.find((p) => p.photo_url === coverUrl)?.key ??
    locals[0]?.key ??
    null
  return { locals, coverKey: cover }
}

export function GalleryEditor({ initial = null, categories }: Props) {
  const router = useRouter()
  const supabase = createClient()
  const fileRef = useRef<HTMLInputElement>(null)

  const [galleryId] = useState(() => initial?.id ?? crypto.randomUUID())
  const [title, setTitle] = useState(initial?.title ?? '')
  const [categoryId, setCategoryId] = useState(initial?.category_id ?? '')
  const [description, setDescription] = useState(initial?.description ?? '')
  const [status, setStatus] = useState<GalleryStatus>(initial?.status ?? 'draft')

  const initialMapped = useMemo(
    () =>
      initial
        ? toLocalPhotos(initial.photos, initial.cover_image_url)
        : { locals: [] as LocalPhoto[], coverKey: null as string | null },
    // eslint-disable-next-line react-hooks/exhaustive-deps
    []
  )

  const [photos, setPhotos] = useState<LocalPhoto[]>(initialMapped.locals)
  const [coverKey, setCoverKey] = useState<string | null>(initialMapped.coverKey)
  const [removedDbIds, setRemovedDbIds] = useState<string[]>([])
  const [removedStoragePaths, setRemovedStoragePaths] = useState<string[]>([])

  const [saving, setSaving] = useState<'draft' | 'publish' | 'unpublish' | null>(
    null
  )
  const [uploading, setUploading] = useState(false)
  const [uploadProgress, setUploadProgress] = useState<{
    done: number
    total: number
  } | null>(null)
  const [error, setError] = useState<string | null>(null)
  const photosRef = useRef(photos)
  photosRef.current = photos

  useEffect(() => {
    if (!initial) return
    setTitle(initial.title)
    setCategoryId(initial.category_id ?? '')
    setDescription(initial.description ?? '')
    setStatus(initial.status)
    const mapped = toLocalPhotos(initial.photos, initial.cover_image_url)
    setPhotos(mapped.locals)
    setCoverKey(mapped.coverKey)
    setRemovedDbIds([])
    setRemovedStoragePaths([])
  }, [initial])

  const coverUrl =
    photos.find((p) => p.key === coverKey)?.photo_url ??
    photos[0]?.photo_url ??
    null

  const uploadPhotos = async (files: FileList | File[]) => {
    const list = Array.from(files).filter((f) => f.type.startsWith('image/'))
    if (list.length === 0) {
      setError('Sélectionnez au moins une image (jpg, png, webp, gif).')
      return
    }

    setUploading(true)
    setUploadProgress({ done: 0, total: list.length })
    setError(null)

    try {
      const {
        data: { user },
      } = await supabase.auth.getUser()
      if (!user) throw new Error('Session expirée. Reconnectez-vous.')

      const journalistId = await getJournalistIdForProfile(supabase, user.id)
      if (!journalistId) {
        throw new Error(
          'Aucun profil journaliste associé. Contactez un administrateur.'
        )
      }

      const baseOrder = photosRef.current.length
      const failures: string[] = []

      const results = await mapWithConcurrency(
        list,
        UPLOAD_CONCURRENCY,
        async (file, index) => {
          try {
            const ext = file.name.split('.').pop()?.toLowerCase() || 'jpg'
            const path = `${journalistId}/${galleryId}/${crypto.randomUUID()}.${ext}`
            const { error: upErr } = await supabase.storage
              .from(GALLERY_PHOTOS_BUCKET)
              .upload(path, file, { upsert: true })
            if (upErr) throw upErr

            const { data: urlData } = supabase.storage
              .from(GALLERY_PHOTOS_BUCKET)
              .getPublicUrl(path)

            const photo: LocalPhoto = {
              key: crypto.randomUUID(),
              dbId: null,
              photo_url: `${urlData.publicUrl}?t=${Date.now()}`,
              caption: '',
              sort_order: baseOrder + index,
              storagePath: path,
            }
            return photo
          } catch (err) {
            failures.push(
              `${file.name}: ${(err as Error).message || 'échec d’envoi'}`
            )
            return null
          }
        },
        (done) => setUploadProgress({ done, total: list.length })
      )

      // Conserve l’ordre de sélection (index d’origine), ignore les échecs.
      const uploaded = results.filter((p): p is LocalPhoto => p !== null)

      if (uploaded.length > 0) {
        setPhotos((prev) => {
          const next = [...prev, ...uploaded]
          return next.map((p, i) => ({ ...p, sort_order: i }))
        })
        setCoverKey((prev) => prev ?? uploaded[0]?.key ?? null)
      }

      if (failures.length > 0) {
        const summary =
          uploaded.length === 0
            ? `Aucune photo n’a pu être envoyée (${failures.length} échec${failures.length > 1 ? 's' : ''}).`
            : `${uploaded.length}/${list.length} photos envoyées. Échecs : ${failures.slice(0, 3).join(' · ')}${failures.length > 3 ? '…' : ''}`
        setError(summary)
      }
    } catch (err) {
      setError((err as Error).message)
    } finally {
      setUploading(false)
      setUploadProgress(null)
    }
  }

  const removePhoto = (key: string) => {
    const target = photos.find((p) => p.key === key)
    if (!target) return

    if (target.dbId) {
      setRemovedDbIds((prev) => [...prev, target.dbId!])
    }
    if (target.storagePath) {
      setRemovedStoragePaths((prev) => [...prev, target.storagePath!])
    }

    setPhotos((prev) => {
      const next = prev
        .filter((p) => p.key !== key)
        .map((p, i) => ({ ...p, sort_order: i }))
      return next
    })
    setCoverKey((prev) => {
      if (prev !== key) return prev
      const remaining = photos.filter((p) => p.key !== key)
      return remaining[0]?.key ?? null
    })
  }

  const updateCaption = (key: string, caption: string) => {
    setPhotos((prev) =>
      prev.map((p) => (p.key === key ? { ...p, caption } : p))
    )
  }

  const save = async (nextStatus: GalleryStatus) => {
    const trimmedTitle = title.trim()
    if (!trimmedTitle) {
      setError('Le titre est obligatoire.')
      return
    }
    if (photos.length === 0) {
      setError('Ajoutez au moins une photo à la galerie.')
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

      const journalistId = await getJournalistIdForProfile(supabase, user.id)
      if (!journalistId) {
        throw new Error(
          'Aucun profil journaliste associé. Contactez un administrateur.'
        )
      }

      const slug = await ensureUniqueGallerySlug(
        supabase,
        trimmedTitle,
        initial?.id ?? galleryId
      )
      const now = new Date().toISOString()
      const resolvedCover =
        photos.find((p) => p.key === coverKey)?.photo_url ??
        photos[0]?.photo_url ??
        null

      const payload = {
        id: galleryId,
        journalist_id: journalistId,
        category_id: categoryId || null,
        title: trimmedTitle,
        slug,
        description: description.trim() || null,
        cover_image_url: resolvedCover,
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
          .from('galleries')
          .update({
            category_id: payload.category_id,
            title: payload.title,
            slug: payload.slug,
            description: payload.description,
            cover_image_url: payload.cover_image_url,
            status: payload.status,
            published_at: payload.published_at,
            updated_at: payload.updated_at,
          })
          .eq('id', galleryId)
        if (updErr) throw updErr
      } else {
        const { error: insErr } = await supabase
          .from('galleries')
          .insert(payload)
        if (insErr) throw insErr
      }

      if (removedDbIds.length > 0) {
        const { error: delErr } = await supabase
          .from('gallery_photos')
          .delete()
          .in('id', removedDbIds)
        if (delErr) throw delErr
      }

      const toInsert = photos.filter((p) => !p.dbId)
      if (toInsert.length > 0) {
        const { error: photoInsErr } = await supabase
          .from('gallery_photos')
          .insert(
            toInsert.map((p) => ({
              gallery_id: galleryId,
              photo_url: p.photo_url,
              caption: p.caption.trim() || null,
              sort_order: p.sort_order,
            }))
          )
        if (photoInsErr) throw photoInsErr
      }

      const toUpdate = photos.filter((p) => p.dbId)
      for (const p of toUpdate) {
        const { error: photoUpdErr } = await supabase
          .from('gallery_photos')
          .update({
            caption: p.caption.trim() || null,
            sort_order: p.sort_order,
            photo_url: p.photo_url,
          })
          .eq('id', p.dbId!)
        if (photoUpdErr) throw photoUpdErr
      }

      if (removedStoragePaths.length > 0) {
        await supabase.storage
          .from(GALLERY_PHOTOS_BUCKET)
          .remove(removedStoragePaths)
      }

      setStatus(nextStatus)
      router.push('/dashboard/journalist/galleries')
      router.refresh()
    } catch (err) {
      setError((err as Error).message)
    } finally {
      setSaving(null)
    }
  }

  const busy = saving !== null || uploading

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
        <Label htmlFor="title">Titre</Label>
        <Input
          id="title"
          value={title}
          onChange={(e) => setTitle(e.target.value)}
          placeholder="Titre de la galerie"
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
          placeholder="Description de la galerie"
          rows={4}
          disabled={busy}
        />
      </div>

      <div className="space-y-3">
        <div className="flex flex-wrap items-center justify-between gap-2">
          <div>
            <Label>Photos</Label>
            <p className="text-xs text-gray-500 mt-0.5">
              Sélectionnez plusieurs fichiers en une seule fois (Ctrl/Cmd ou
              Shift).
            </p>
          </div>
          <div>
            <input
              ref={fileRef}
              type="file"
              accept={GALLERY_PHOTO_ACCEPT}
              multiple
              className="hidden"
              onChange={(e) => {
                const files = e.target.files
                if (files?.length) void uploadPhotos(files)
                e.target.value = ''
              }}
            />
            <Button
              type="button"
              variant="outline"
              size="sm"
              disabled={busy}
              onClick={() => fileRef.current?.click()}
            >
              {uploading ? (
                <Loader2 className="w-4 h-4 mr-2 animate-spin" />
              ) : (
                <Upload className="w-4 h-4 mr-2" />
              )}
              {uploading && uploadProgress
                ? `${uploadProgress.done}/${uploadProgress.total} photos`
                : 'Ajouter des photos'}
            </Button>
          </div>
        </div>

        {uploadProgress && (
          <div className="rounded-lg border border-[#00A550]/20 bg-[#E6F5EE]/60 px-4 py-3 space-y-2">
            <div className="flex items-center justify-between gap-3 text-sm text-gray-700">
              <span className="inline-flex items-center gap-2">
                <Loader2 className="w-4 h-4 animate-spin text-[#00A550]" />
                Envoi en cours…
              </span>
              <span className="font-medium tabular-nums text-[#00A550]">
                {uploadProgress.done}/{uploadProgress.total} photos envoyées
              </span>
            </div>
            <Progress
              value={
                uploadProgress.total > 0
                  ? Math.round(
                      (uploadProgress.done / uploadProgress.total) * 100
                    )
                  : 0
              }
              className="h-2 bg-white/80 [&>div]:bg-[#00A550]"
            />
          </div>
        )}

        {photos.length === 0 && !uploading ? (
          <button
            type="button"
            disabled={busy}
            onClick={() => fileRef.current?.click()}
            className="w-full rounded-lg border border-dashed border-gray-200 bg-gray-50 px-4 py-10 text-center text-sm text-gray-500 hover:border-[#00A550] hover:text-[#00A550] transition-colors disabled:opacity-50"
          >
            <ImagePlus className="w-6 h-6 mx-auto mb-2 opacity-60" />
            Choisir plusieurs photos (jpg, png, webp)
          </button>
        ) : photos.length === 0 && uploading ? (
          <div className="w-full rounded-lg border border-dashed border-gray-200 bg-gray-50 px-4 py-10 text-center text-sm text-gray-500">
            <Loader2 className="w-6 h-6 mx-auto mb-2 animate-spin text-[#00A550]" />
            Préparation de l’envoi…
          </div>
        ) : (
          <ul className="space-y-3">
            {photos.map((photo) => {
              const isCover = photo.key === coverKey
              return (
                <li
                  key={photo.key}
                  className="flex flex-col sm:flex-row gap-3 rounded-lg border border-gray-100 bg-white p-3"
                >
                  <div className="relative flex-shrink-0">
                    {/* eslint-disable-next-line @next/next/no-img-element */}
                    <img
                      src={photo.photo_url}
                      alt=""
                      className="w-full sm:w-28 h-28 object-cover rounded-md border border-gray-100"
                    />
                    {isCover && (
                      <span className="absolute top-1.5 left-1.5 inline-flex items-center gap-1 rounded bg-[#00A550] text-white text-[10px] font-medium px-1.5 py-0.5">
                        <Star className="w-3 h-3" />
                        Couverture
                      </span>
                    )}
                  </div>
                  <div className="flex-1 min-w-0 space-y-2">
                    <Input
                      value={photo.caption}
                      onChange={(e) => updateCaption(photo.key, e.target.value)}
                      placeholder="Légende (optionnel)"
                      disabled={busy}
                    />
                    <div className="flex flex-wrap gap-2">
                      {!isCover && (
                        <Button
                          type="button"
                          variant="outline"
                          size="sm"
                          disabled={busy}
                          onClick={() => setCoverKey(photo.key)}
                        >
                          <Star className="w-3.5 h-3.5 mr-1.5" />
                          Définir comme couverture
                        </Button>
                      )}
                      <Button
                        type="button"
                        variant="ghost"
                        size="sm"
                        disabled={busy}
                        className="text-red-600 hover:text-red-700 hover:bg-red-50"
                        onClick={() => removePhoto(photo.key)}
                      >
                        <Trash2 className="w-3.5 h-3.5 mr-1.5" />
                        Retirer
                      </Button>
                    </div>
                  </div>
                </li>
              )
            })}
          </ul>
        )}

        {coverUrl && !uploading && (
          <p className="text-xs text-gray-500">
            Image de couverture : première photo ou celle marquée « Couverture ».
          </p>
        )}
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
          className="bg-[#00A550] hover:bg-[#008040]"
          onClick={() => void save('published')}
        >
          {saving === 'publish' ? (
            <Loader2 className="w-4 h-4 mr-2 animate-spin" />
          ) : null}
          Publier
        </Button>
        <Button
          type="button"
          variant="ghost"
          disabled={busy}
          onClick={() => router.push('/dashboard/journalist/galleries')}
        >
          Annuler
        </Button>
      </div>
    </div>
  )
}
