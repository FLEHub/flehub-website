'use client'

import { useEffect, useMemo, useRef, useState } from 'react'
import { createClient } from '@/lib/supabase/client'
import {
  EPISODE_AUDIO_ACCEPT,
  EPISODE_AUDIO_BUCKET,
  getCreatorIdForProfile,
  parseYoutubeLink,
  type EpisodeStatus,
  type SeriesEpisode,
  type SeriesType,
} from '@/lib/series'
import { Badge } from '@/components/ui/badge'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { Label } from '@/components/ui/label'
import { Textarea } from '@/components/ui/textarea'
import {
  AlertTriangle,
  Loader2,
  Pencil,
  Plus,
  Upload,
  X,
} from 'lucide-react'

type Props = {
  seriesId: string
  seriesType: SeriesType
  initialEpisodes: SeriesEpisode[]
}

const STATUS_CLASS: Record<EpisodeStatus, string> = {
  draft: 'bg-yellow-50 text-yellow-700 border-yellow-200',
  published: 'bg-[#E8F1FA] text-[#1E5FA8] border-[#1E5FA8]/30',
}

export function EpisodeManager({
  seriesId,
  seriesType,
  initialEpisodes,
}: Props) {
  const supabase = createClient()
  const audioRef = useRef<HTMLInputElement>(null)

  const [episodes, setEpisodes] = useState<SeriesEpisode[]>(initialEpisodes)
  const [error, setError] = useState<string | null>(null)
  const [formOpen, setFormOpen] = useState(false)
  const [editingId, setEditingId] = useState<string | null>(null)
  const [saving, setSaving] = useState(false)
  const [uploadingAudio, setUploadingAudio] = useState(false)
  const [actionId, setActionId] = useState<string | null>(null)

  const [episodeNumber, setEpisodeNumber] = useState(1)
  const [title, setTitle] = useState('')
  const [description, setDescription] = useState('')
  const [youtubeUrl, setYoutubeUrl] = useState('')
  const [videoId, setVideoId] = useState('')
  const [thumbnailUrl, setThumbnailUrl] = useState('')
  const [audioUrl, setAudioUrl] = useState('')

  useEffect(() => {
    setEpisodes(initialEpisodes)
  }, [initialEpisodes])

  const nextNumber = useMemo(() => {
    if (episodes.length === 0) return 1
    return Math.max(...episodes.map((e) => e.episode_number)) + 1
  }, [episodes])

  const resetForm = (forNew = true) => {
    setEditingId(null)
    setTitle('')
    setDescription('')
    setYoutubeUrl('')
    setVideoId('')
    setThumbnailUrl('')
    setAudioUrl('')
    setEpisodeNumber(forNew ? nextNumber : 1)
    setError(null)
  }

  const openNew = () => {
    resetForm(true)
    setEpisodeNumber(nextNumber)
    setFormOpen(true)
  }

  const openEdit = (ep: SeriesEpisode) => {
    setEditingId(ep.id)
    setEpisodeNumber(ep.episode_number)
    setTitle(ep.title)
    setDescription(ep.description ?? '')
    setYoutubeUrl(ep.youtube_url ?? '')
    setVideoId(ep.youtube_video_id ?? '')
    setThumbnailUrl(ep.thumbnail_url ?? '')
    setAudioUrl(ep.audio_url ?? '')
    setFormOpen(true)
    setError(null)
  }

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

  const uploadAudio = async (file: File) => {
    setUploadingAudio(true)
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

      const ext = file.name.split('.').pop()?.toLowerCase() || 'mp3'
      const path = `${creatorId}/${seriesId}/${crypto.randomUUID()}.${ext}`
      const { error: upErr } = await supabase.storage
        .from(EPISODE_AUDIO_BUCKET)
        .upload(path, file, { upsert: true })
      if (upErr) throw upErr

      const { data: urlData } = supabase.storage
        .from(EPISODE_AUDIO_BUCKET)
        .getPublicUrl(path)
      setAudioUrl(`${urlData.publicUrl}?t=${Date.now()}`)
    } catch (err) {
      setError((err as Error).message)
    } finally {
      setUploadingAudio(false)
    }
  }

  const refreshEpisodes = async () => {
    const { data, error: qErr } = await supabase
      .from('series_episodes')
      .select(
        'id, series_id, episode_number, title, description, youtube_url, youtube_video_id, thumbnail_url, audio_url, status, published_at, created_at, updated_at'
      )
      .eq('series_id', seriesId)
      .order('episode_number', { ascending: true })
    if (qErr) throw qErr
    setEpisodes((data ?? []) as SeriesEpisode[])
  }

  const saveEpisode = async (nextStatus: EpisodeStatus) => {
    const trimmedTitle = title.trim()
    if (!trimmedTitle) {
      setError('Le titre de l’épisode est obligatoire.')
      return
    }
    if (!Number.isFinite(episodeNumber) || episodeNumber < 1) {
      setError('Le numéro d’épisode doit être un entier ≥ 1.')
      return
    }

    if (seriesType === 'webseries') {
      const parsed = parseYoutubeLink(youtubeUrl)
      if (!parsed) {
        setError(
          'Lien YouTube invalide. Collez une URL YouTube ou un ID de 11 caractères.'
        )
        return
      }
    } else if (!audioUrl) {
      setError('Le fichier audio est obligatoire pour un podcast.')
      return
    }

    setSaving(true)
    setError(null)

    try {
      const now = new Date().toISOString()
      const existing = editingId
        ? episodes.find((e) => e.id === editingId)
        : null

      const youtubeParsed =
        seriesType === 'webseries' ? parseYoutubeLink(youtubeUrl) : null

      const payload = {
        series_id: seriesId,
        episode_number: episodeNumber,
        title: trimmedTitle,
        description: description.trim() || null,
        youtube_url:
          seriesType === 'webseries' ? youtubeUrl.trim() : null,
        youtube_video_id: youtubeParsed?.videoId ?? null,
        thumbnail_url: youtubeParsed?.thumbnailUrl ?? null,
        audio_url: seriesType === 'podcast' ? audioUrl : null,
        status: nextStatus,
        published_at:
          nextStatus === 'published'
            ? existing?.published_at && existing.status === 'published'
              ? existing.published_at
              : now
            : null,
        updated_at: now,
      }

      if (editingId) {
        const { error: updErr } = await supabase
          .from('series_episodes')
          .update(payload)
          .eq('id', editingId)
        if (updErr) throw updErr
      } else {
        const { error: insErr } = await supabase
          .from('series_episodes')
          .insert(payload)
        if (insErr) throw insErr
      }

      await refreshEpisodes()
      setFormOpen(false)
      resetForm()
    } catch (err) {
      setError((err as Error).message)
    } finally {
      setSaving(false)
    }
  }

  const togglePublish = async (ep: SeriesEpisode) => {
    setActionId(ep.id)
    setError(null)
    try {
      const next: EpisodeStatus =
        ep.status === 'published' ? 'draft' : 'published'
      const now = new Date().toISOString()
      const { error: updErr } = await supabase
        .from('series_episodes')
        .update({
          status: next,
          published_at: next === 'published' ? now : null,
          updated_at: now,
        })
        .eq('id', ep.id)
      if (updErr) throw updErr
      await refreshEpisodes()
    } catch (err) {
      setError((err as Error).message)
    } finally {
      setActionId(null)
    }
  }

  const busy = saving || uploadingAudio

  return (
    <div className="space-y-4">
      <div className="flex flex-wrap items-center justify-between gap-2">
        <div>
          <h2 className="text-lg font-semibold text-gray-900">Épisodes</h2>
          <p className="text-sm text-gray-500">
            {seriesType === 'webseries'
              ? 'Chaque épisode contient un lien YouTube.'
              : 'Chaque épisode contient un fichier audio.'}
          </p>
        </div>
        {!formOpen && (
          <Button
            type="button"
            size="sm"
            className="bg-[#1E5FA8] hover:bg-[#164A82]"
            onClick={openNew}
          >
            <Plus className="w-4 h-4 mr-1.5" />
            Ajouter un épisode
          </Button>
        )}
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

      {formOpen && (
        <div className="rounded-xl border border-gray-100 bg-white p-4 sm:p-5 space-y-4">
          <h3 className="font-medium text-gray-900">
            {editingId ? 'Modifier l’épisode' : 'Nouvel épisode'}
          </h3>

          <div className="grid grid-cols-1 sm:grid-cols-3 gap-4">
            <div className="space-y-2">
              <Label htmlFor="ep-num">N° d’épisode</Label>
              <Input
                id="ep-num"
                type="number"
                min={1}
                value={episodeNumber}
                onChange={(e) => setEpisodeNumber(Number(e.target.value) || 1)}
                disabled={busy}
              />
            </div>
            <div className="space-y-2 sm:col-span-2">
              <Label htmlFor="ep-title">Titre</Label>
              <Input
                id="ep-title"
                value={title}
                onChange={(e) => setTitle(e.target.value)}
                placeholder="Titre de l’épisode"
                disabled={busy}
              />
            </div>
          </div>

          <div className="space-y-2">
            <Label htmlFor="ep-desc">Description</Label>
            <Textarea
              id="ep-desc"
              value={description}
              onChange={(e) => setDescription(e.target.value)}
              rows={3}
              disabled={busy}
            />
          </div>

          {seriesType === 'webseries' ? (
            <div className="space-y-2">
              <Label htmlFor="ep-yt">Lien YouTube</Label>
              <Input
                id="ep-yt"
                value={youtubeUrl}
                onChange={(e) => onYoutubeUrlChange(e.target.value)}
                placeholder="https://www.youtube.com/watch?v=…"
                disabled={busy}
              />
              {thumbnailUrl && (
                // eslint-disable-next-line @next/next/no-img-element
                <img
                  src={thumbnailUrl}
                  alt=""
                  className="w-full sm:w-56 h-32 object-cover rounded-lg border border-gray-100"
                />
              )}
              {videoId && (
                <p className="text-xs text-gray-500">ID vidéo : {videoId}</p>
              )}
            </div>
          ) : (
            <div className="space-y-2">
              <Label>Fichier audio (mp3 / wav / m4a)</Label>
              {audioUrl ? (
                <audio controls src={audioUrl} className="w-full max-w-md" />
              ) : (
                <div className="rounded-lg border border-dashed border-gray-200 bg-gray-50 px-4 py-6 text-center text-xs text-gray-400">
                  Aucun fichier audio
                </div>
              )}
              <div>
                <input
                  ref={audioRef}
                  type="file"
                  accept={EPISODE_AUDIO_ACCEPT}
                  className="hidden"
                  onChange={(e) => {
                    const f = e.target.files?.[0]
                    if (f) void uploadAudio(f)
                    e.target.value = ''
                  }}
                />
                <Button
                  type="button"
                  variant="outline"
                  disabled={busy}
                  onClick={() => audioRef.current?.click()}
                >
                  {uploadingAudio ? (
                    <Loader2 className="w-4 h-4 mr-2 animate-spin" />
                  ) : (
                    <Upload className="w-4 h-4 mr-2" />
                  )}
                  {audioUrl ? 'Changer l’audio' : 'Téléverser un audio'}
                </Button>
              </div>
            </div>
          )}

          <div className="flex flex-wrap gap-2 pt-2 border-t border-gray-100">
            <Button
              type="button"
              variant="outline"
              disabled={busy}
              onClick={() => void saveEpisode('draft')}
            >
              {saving ? <Loader2 className="w-4 h-4 mr-2 animate-spin" /> : null}
              Enregistrer en brouillon
            </Button>
            <Button
              type="button"
              disabled={busy}
              className="bg-[#1E5FA8] hover:bg-[#164A82]"
              onClick={() => void saveEpisode('published')}
            >
              {saving ? <Loader2 className="w-4 h-4 mr-2 animate-spin" /> : null}
              Publier l’épisode
            </Button>
            <Button
              type="button"
              variant="ghost"
              disabled={busy}
              onClick={() => {
                setFormOpen(false)
                resetForm()
              }}
            >
              Annuler
            </Button>
          </div>
        </div>
      )}

      {episodes.length === 0 ? (
        <p className="text-sm text-gray-500 py-6 text-center rounded-xl border border-dashed border-gray-200 bg-gray-50">
          Aucun épisode pour le moment.
        </p>
      ) : (
        <ul className="space-y-3">
          {episodes.map((ep) => (
            <li
              key={ep.id}
              className="flex flex-col sm:flex-row gap-3 rounded-xl border border-gray-100 bg-white p-4"
            >
              <div className="flex-shrink-0 w-12 h-12 rounded-lg bg-[#E8F1FA] flex items-center justify-center text-sm font-bold text-[#1E5FA8]">
                {ep.episode_number}
              </div>
              <div className="min-w-0 flex-1 space-y-1">
                <div className="flex flex-wrap items-center gap-2">
                  <h3 className="font-medium text-gray-900">{ep.title}</h3>
                  <Badge
                    variant="outline"
                    className={STATUS_CLASS[ep.status as EpisodeStatus]}
                  >
                    {ep.status === 'published' ? 'Publié' : 'Brouillon'}
                  </Badge>
                </div>
                {ep.description && (
                  <p className="text-sm text-gray-500 line-clamp-2">
                    {ep.description}
                  </p>
                )}
              </div>
              <div className="flex flex-wrap gap-2 sm:justify-end">
                <Button
                  type="button"
                  size="sm"
                  variant="outline"
                  onClick={() => openEdit(ep)}
                >
                  <Pencil className="w-3.5 h-3.5 mr-1.5" />
                  Modifier
                </Button>
                <Button
                  type="button"
                  size="sm"
                  variant="ghost"
                  disabled={actionId === ep.id}
                  onClick={() => void togglePublish(ep)}
                >
                  {actionId === ep.id ? (
                    <Loader2 className="w-3.5 h-3.5 animate-spin" />
                  ) : ep.status === 'published' ? (
                    'Dépublier'
                  ) : (
                    'Publier'
                  )}
                </Button>
              </div>
            </li>
          ))}
        </ul>
      )}
    </div>
  )
}
