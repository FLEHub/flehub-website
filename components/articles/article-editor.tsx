'use client'

import { useEffect, useRef, useState } from 'react'
import { useRouter } from 'next/navigation'
import { createClient } from '@/lib/supabase/client'
import {
  ensureUniqueSlug,
  getJournalistIdForProfile,
  type ArticleCategory,
  type ArticleStatus,
} from '@/lib/articles'
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

export type ArticleEditorInitial = {
  id: string
  title: string
  slug: string
  excerpt: string | null
  content: string
  cover_image_url: string | null
  category_id: string | null
  status: ArticleStatus
  published_at: string | null
}

type Props = {
  initial?: ArticleEditorInitial | null
  categories: ArticleCategory[]
}

export function ArticleEditor({ initial = null, categories }: Props) {
  const router = useRouter()
  const supabase = createClient()
  const fileRef = useRef<HTMLInputElement>(null)

  const [title, setTitle] = useState(initial?.title ?? '')
  const [categoryId, setCategoryId] = useState(initial?.category_id ?? '')
  const [excerpt, setExcerpt] = useState(initial?.excerpt ?? '')
  const [content, setContent] = useState(initial?.content ?? '')
  const [coverUrl, setCoverUrl] = useState(initial?.cover_image_url ?? '')
  const [status, setStatus] = useState<ArticleStatus>(initial?.status ?? 'draft')

  const [saving, setSaving] = useState<'draft' | 'publish' | 'unpublish' | null>(null)
  const [uploading, setUploading] = useState(false)
  const [error, setError] = useState<string | null>(null)

  useEffect(() => {
    if (!initial) return
    setTitle(initial.title)
    setCategoryId(initial.category_id ?? '')
    setExcerpt(initial.excerpt ?? '')
    setContent(initial.content ?? '')
    setCoverUrl(initial.cover_image_url ?? '')
    setStatus(initial.status)
  }, [initial])

  const uploadCover = async (file: File) => {
    setUploading(true)
    setError(null)
    try {
      const {
        data: { user },
      } = await supabase.auth.getUser()
      if (!user) throw new Error('Session expirée. Reconnectez-vous.')

      const ext = file.name.split('.').pop()?.toLowerCase() || 'jpg'
      const path = `${user.id}/covers/${crypto.randomUUID()}.${ext}`
      const { error: upErr } = await supabase.storage
        .from('journalist-assets')
        .upload(path, file, { upsert: true })
      if (upErr) throw upErr

      const { data: urlData } = supabase.storage
        .from('journalist-assets')
        .getPublicUrl(path)
      setCoverUrl(`${urlData.publicUrl}?t=${Date.now()}`)
    } catch (err) {
      setError((err as Error).message)
    } finally {
      setUploading(false)
    }
  }

  const save = async (nextStatus: ArticleStatus) => {
    const trimmedTitle = title.trim()
    if (!trimmedTitle) {
      setError('Le titre est obligatoire.')
      return
    }

    setSaving(nextStatus === 'published' ? 'publish' : nextStatus === 'draft' && status === 'published' ? 'unpublish' : 'draft')
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

      const slug = await ensureUniqueSlug(supabase, trimmedTitle, initial?.id)
      const now = new Date().toISOString()
      const payload = {
        journalist_id: journalistId,
        category_id: categoryId || null,
        title: trimmedTitle,
        slug,
        excerpt: excerpt.trim() || null,
        content: content.trim(),
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
          .from('articles')
          .update(payload)
          .eq('id', initial.id)
        if (updErr) throw updErr
      } else {
        const { error: insErr } = await supabase.from('articles').insert(payload)
        if (insErr) throw insErr
      }

      setStatus(nextStatus)
      router.push('/dashboard/journalist/articles')
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
          placeholder="Titre de l'article"
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
        <Label htmlFor="excerpt">Extrait</Label>
        <Textarea
          id="excerpt"
          value={excerpt}
          onChange={(e) => setExcerpt(e.target.value)}
          placeholder="Court résumé affiché dans les listes"
          rows={3}
          disabled={busy}
        />
      </div>

      <div className="space-y-2">
        <Label htmlFor="content">Contenu</Label>
        <Textarea
          id="content"
          value={content}
          onChange={(e) => setContent(e.target.value)}
          placeholder="Corps de l'article"
          rows={14}
          disabled={busy}
          className="font-mono text-sm"
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
              ref={fileRef}
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
              onClick={() => fileRef.current?.click()}
            >
              {uploading ? (
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
          {status === 'published' ? 'Dépublier (brouillon)' : 'Enregistrer en brouillon'}
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
          onClick={() => router.push('/dashboard/journalist/articles')}
        >
          Annuler
        </Button>
      </div>
    </div>
  )
}
