'use client'

import { useEffect, useState } from 'react'
import { useRouter } from 'next/navigation'
import { createClient } from '@/lib/supabase/client'
import { getJournalistIdForProfile, type ArticleCategory } from '@/lib/articles'
import {
  ensureUniqueVideoSlug,
  parseYoutubeLink,
  type VideoStatus,
} from '@/lib/videos'
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
import { AlertTriangle, Loader2, X } from 'lucide-react'

export type VideoEditorInitial = {
  id: string
  title: string
  slug: string
  description: string | null
  youtube_url: string
  youtube_video_id: string
  thumbnail_url: string
  category_id: string | null
  status: VideoStatus
  published_at: string | null
}

type Props = {
  initial?: VideoEditorInitial | null
  categories: ArticleCategory[]
}

export function VideoEditor({ initial = null, categories }: Props) {
  const router = useRouter()
  const supabase = createClient()

  const [title, setTitle] = useState(initial?.title ?? '')
  const [categoryId, setCategoryId] = useState(initial?.category_id ?? '')
  const [description, setDescription] = useState(initial?.description ?? '')
  const [youtubeUrl, setYoutubeUrl] = useState(initial?.youtube_url ?? '')
  const [videoId, setVideoId] = useState(initial?.youtube_video_id ?? '')
  const [thumbnailUrl, setThumbnailUrl] = useState(initial?.thumbnail_url ?? '')
  const [status, setStatus] = useState<VideoStatus>(initial?.status ?? 'draft')

  const [saving, setSaving] = useState<'draft' | 'publish' | 'unpublish' | null>(
    null
  )
  const [error, setError] = useState<string | null>(null)

  useEffect(() => {
    if (!initial) return
    setTitle(initial.title)
    setCategoryId(initial.category_id ?? '')
    setDescription(initial.description ?? '')
    setYoutubeUrl(initial.youtube_url)
    setVideoId(initial.youtube_video_id)
    setThumbnailUrl(initial.thumbnail_url)
    setStatus(initial.status)
  }, [initial])

  const onYoutubeUrlChange = (value: string) => {
    setYoutubeUrl(value)
    const parsed = parseYoutubeLink(value)
    if (parsed) {
      setVideoId(parsed.videoId)
      setThumbnailUrl(parsed.thumbnailUrl)
    } else {
      setVideoId('')
      setThumbnailUrl('')
    }
  }

  const save = async (nextStatus: VideoStatus) => {
    const trimmedTitle = title.trim()
    if (!trimmedTitle) {
      setError('Le titre est obligatoire.')
      return
    }

    const parsed = parseYoutubeLink(youtubeUrl)
    if (!parsed) {
      setError(
        'Lien YouTube invalide. Collez une URL YouTube (watch, youtu.be, shorts…) ou un ID de 11 caractères.'
      )
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

      const slug = await ensureUniqueVideoSlug(supabase, trimmedTitle, initial?.id)
      const now = new Date().toISOString()
      const payload = {
        journalist_id: journalistId,
        category_id: categoryId || null,
        title: trimmedTitle,
        slug,
        description: description.trim() || null,
        youtube_url: youtubeUrl.trim(),
        youtube_video_id: parsed.videoId,
        thumbnail_url: parsed.thumbnailUrl,
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
          .from('videos')
          .update(payload)
          .eq('id', initial.id)
        if (updErr) throw updErr
      } else {
        const { error: insErr } = await supabase.from('videos').insert(payload)
        if (insErr) throw insErr
      }

      setStatus(nextStatus)
      setVideoId(parsed.videoId)
      setThumbnailUrl(parsed.thumbnailUrl)
      router.push('/dashboard/journalist/videos')
      router.refresh()
    } catch (err) {
      setError((err as Error).message)
    } finally {
      setSaving(null)
    }
  }

  const busy = saving !== null

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
          placeholder="Titre de la vidéo"
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
          placeholder="Description de la vidéo"
          rows={5}
          disabled={busy}
        />
      </div>

      <div className="space-y-2">
        <Label htmlFor="youtube">Lien YouTube</Label>
        <Input
          id="youtube"
          value={youtubeUrl}
          onChange={(e) => onYoutubeUrlChange(e.target.value)}
          placeholder="https://www.youtube.com/watch?v=…"
          disabled={busy}
        />
        {videoId ? (
          <p className="text-xs text-gray-500">
            ID détecté : <span className="font-mono text-gray-700">{videoId}</span>
          </p>
        ) : youtubeUrl.trim() ? (
          <p className="text-xs text-amber-600">
            Impossible d’extraire un ID YouTube de ce lien.
          </p>
        ) : null}
      </div>

      <div className="space-y-2">
        <Label>Miniature (générée automatiquement)</Label>
        <div className="flex flex-col sm:flex-row gap-4 items-start">
          {thumbnailUrl ? (
            // eslint-disable-next-line @next/next/no-img-element
            <img
              src={thumbnailUrl}
              alt="Miniature YouTube"
              className="w-full sm:w-56 h-36 object-cover rounded-lg border border-gray-200"
            />
          ) : (
            <div className="w-full sm:w-56 h-36 rounded-lg border border-dashed border-gray-200 bg-gray-50 flex items-center justify-center text-xs text-gray-400">
              Collez un lien YouTube
            </div>
          )}
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
          Publier
        </Button>
        <Button
          type="button"
          variant="ghost"
          disabled={busy}
          onClick={() => router.push('/dashboard/journalist/videos')}
        >
          Annuler
        </Button>
      </div>
    </div>
  )
}
