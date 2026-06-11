'use client'

import { ChangeEvent, DragEvent, FormEvent, useEffect, useRef, useState } from 'react'
import { createClient } from '@/lib/supabase'

type ResourceType = 'pdf' | 'audio' | 'image' | 'video'
type UploadMode = 'file' | 'video'
type CEFRLevel = 'A1' | 'A2' | 'B1' | 'B2' | 'C1' | 'C2'

interface ToastState {
  type: 'success' | 'error'
  message: string
}

const MAX_FILE_SIZE = 50 * 1024 * 1024
const BUCKET_NAME = 'flehub-resources'

const FILE_MIME_TYPES = [
  'application/pdf',
  'audio/mpeg',
  'audio/wav',
  'audio/ogg',
  'image/jpeg',
  'image/png',
  'image/webp',
]

const LEVELS: CEFRLevel[] = ['A1', 'A2', 'B1', 'B2', 'C1', 'C2']

function getResourceTypeFromFile(file: File): Exclude<ResourceType, 'video'> | null {
  if (file.type === 'application/pdf') return 'pdf'
  if (file.type.startsWith('audio/')) return 'audio'
  if (file.type.startsWith('image/')) return 'image'
  return null
}

function encodeStoragePath(path: string): string {
  return path.split('/').map(encodeURIComponent).join('/')
}

function getResourceStoragePath(teacherId: string, fileName: string): string {
  return `${teacherId}/${crypto.randomUUID()}-${fileName}`
}

function getVideoEmbedUrl(value: string): string | null {
  if (!value.trim()) return null

  try {
    const url = new URL(value.trim())
    const hostname = url.hostname.toLowerCase().replace(/^www\./, '')

    if (hostname === 'youtu.be') {
      const videoId = url.pathname.split('/').filter(Boolean)[0]
      return videoId ? `https://www.youtube.com/embed/${videoId}` : null
    }

    if (hostname === 'youtube.com' || hostname.endsWith('.youtube.com')) {
      const watchId = url.searchParams.get('v')
      const pathParts = url.pathname.split('/').filter(Boolean)
      const embedId =
        watchId ??
        (['embed', 'shorts'].includes(pathParts[0]) ? pathParts[1] : null)

      return embedId ? `https://www.youtube.com/embed/${embedId}` : null
    }

    if (hostname === 'vimeo.com' || hostname.endsWith('.vimeo.com')) {
      const pathParts = url.pathname.split('/').filter(Boolean)
      const videoId = pathParts[0] === 'video' ? pathParts[1] : pathParts[0]
      return videoId ? `https://player.vimeo.com/video/${videoId}` : null
    }
  } catch {
    return null
  }

  return null
}

async function uploadFileWithProgress({
  file,
  filePath,
  accessToken,
  onProgress,
}: {
  file: File
  filePath: string
  accessToken: string
  onProgress: (progress: number) => void
}) {
  const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL
  const anonKey = process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY

  if (!supabaseUrl || !anonKey) {
    throw new Error('Missing Supabase configuration')
  }

  const uploadUrl = `${supabaseUrl}/storage/v1/object/${BUCKET_NAME}/${encodeStoragePath(filePath)}`

  await new Promise<void>((resolve, reject) => {
    const xhr = new XMLHttpRequest()

    xhr.upload.onprogress = (event) => {
      if (!event.lengthComputable) return
      onProgress(Math.round((event.loaded / event.total) * 100))
    }

    xhr.onload = () => {
      if (xhr.status >= 200 && xhr.status < 300) {
        onProgress(100)
        resolve()
        return
      }

      try {
        const body = JSON.parse(xhr.responseText) as { message?: string; error?: string }
        reject(new Error(body.message ?? body.error ?? 'Storage upload failed'))
      } catch {
        reject(new Error(xhr.responseText || 'Storage upload failed'))
      }
    }

    xhr.onerror = () => reject(new Error('Storage upload failed'))
    xhr.open('POST', uploadUrl)
    xhr.setRequestHeader('Authorization', `Bearer ${accessToken}`)
    xhr.setRequestHeader('apikey', anonKey)
    xhr.setRequestHeader('Content-Type', file.type)
    xhr.setRequestHeader('x-upsert', 'false')
    xhr.send(file)
  })
}

export function ResourceUploadForm() {
  const supabase = createClient()
  const fileInputRef = useRef<HTMLInputElement>(null)
  const toastTimeoutRef = useRef<ReturnType<typeof setTimeout> | null>(null)

  const [mode, setMode] = useState<UploadMode>('file')
  const [title, setTitle] = useState('')
  const [description, setDescription] = useState('')
  const [subject, setSubject] = useState('')
  const [level, setLevel] = useState<CEFRLevel | ''>('')
  const [isPublic, setIsPublic] = useState(false)
  const [file, setFile] = useState<File | null>(null)
  const [videoUrl, setVideoUrl] = useState('')
  const [uploadProgress, setUploadProgress] = useState(0)
  const [isDragging, setIsDragging] = useState(false)
  const [isSubmitting, setIsSubmitting] = useState(false)
  const [formError, setFormError] = useState<string | null>(null)
  const [toast, setToast] = useState<ToastState | null>(null)

  const fileType = file ? getResourceTypeFromFile(file) : null
  const videoEmbedUrl = mode === 'video' ? getVideoEmbedUrl(videoUrl) : null
  const resourceType: ResourceType | null = mode === 'video' ? 'video' : fileType

  useEffect(() => {
    return () => {
      if (toastTimeoutRef.current) {
        clearTimeout(toastTimeoutRef.current)
      }
    }
  }, [])

  function showToast(nextToast: ToastState) {
    setToast(nextToast)

    if (toastTimeoutRef.current) {
      clearTimeout(toastTimeoutRef.current)
    }

    toastTimeoutRef.current = setTimeout(() => setToast(null), 4500)
  }

  function resetForm() {
    setMode('file')
    setTitle('')
    setDescription('')
    setSubject('')
    setLevel('')
    setIsPublic(false)
    setFile(null)
    setVideoUrl('')
    setUploadProgress(0)
    setFormError(null)

    if (fileInputRef.current) {
      fileInputRef.current.value = ''
    }
  }

  function setSelectedFile(nextFile: File | null) {
    setFormError(null)

    if (!nextFile) {
      setFile(null)
      return
    }

    if (!FILE_MIME_TYPES.includes(nextFile.type)) {
      setFile(null)
      setFormError('Type de fichier non pris en charge.')
      return
    }

    if (nextFile.size > MAX_FILE_SIZE) {
      setFile(null)
      setFormError('Le fichier dépasse la limite de 50MB.')
      return
    }

    setFile(nextFile)
  }

  function handleFileInput(event: ChangeEvent<HTMLInputElement>) {
    setSelectedFile(event.target.files?.[0] ?? null)
  }

  function handleDrop(event: DragEvent<HTMLDivElement>) {
    event.preventDefault()
    setIsDragging(false)
    setSelectedFile(event.dataTransfer.files?.[0] ?? null)
  }

  async function handleSubmit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault()
    setFormError(null)

    if (!title.trim()) {
      setFormError('Le titre est requis.')
      return
    }

    if (!resourceType) {
      setFormError('Veuillez ajouter un fichier valide ou une URL vidéo valide.')
      return
    }

    if (mode === 'video' && !videoEmbedUrl) {
      setFormError('Veuillez saisir une URL YouTube ou Vimeo valide.')
      return
    }

    setIsSubmitting(true)
    setUploadProgress(0)

    try {
      const {
        data: { user },
        error: userError,
      } = await supabase.auth.getUser()

      if (userError || !user) {
        throw new Error('Vous devez être connecté pour ajouter une ressource.')
      }

      let filePath = videoUrl.trim()
      let fileSize: number | null = null
      let fileName: string | null = null

      if (mode === 'file') {
        if (!file) {
          throw new Error('Veuillez sélectionner un fichier.')
        }

        const {
          data: { session },
          error: sessionError,
        } = await supabase.auth.getSession()

        if (sessionError || !session?.access_token) {
          throw new Error('Session invalide. Veuillez vous reconnecter.')
        }

        filePath = getResourceStoragePath(user.id, file.name)
        fileSize = file.size
        fileName = file.name

        await uploadFileWithProgress({
          file,
          filePath,
          accessToken: session.access_token,
          onProgress: setUploadProgress,
        })
      }

      const { error: insertError } = await supabase.from('resources').insert({
        teacher_id: user.id,
        title: title.trim(),
        description: description.trim() || null,
        type: resourceType,
        subject: subject.trim() || null,
        level: level || null,
        file_path: filePath,
        file_size: fileSize,
        file_name: fileName,
        is_public: isPublic,
      })

      if (insertError) {
        throw insertError
      }

      showToast({ type: 'success', message: 'Ressource ajoutée avec succès.' })
      resetForm()
    } catch (error) {
      const message = error instanceof Error ? error.message : 'Une erreur est survenue.'
      showToast({ type: 'error', message })
    } finally {
      setIsSubmitting(false)
    }
  }

  return (
    <div className="relative">
      {toast && (
        <div
          className={`fixed right-4 top-4 z-50 max-w-sm rounded-xl border px-4 py-3 text-sm shadow-lg ${
            toast.type === 'success'
              ? 'border-green-200 bg-green-50 text-green-800'
              : 'border-red-200 bg-red-50 text-red-700'
          }`}
          role="status"
        >
          {toast.message}
        </div>
      )}

      <form
        onSubmit={handleSubmit}
        className="space-y-6 rounded-2xl border border-gray-100 bg-white p-6 shadow-sm"
      >
        <div>
          <h2 className="text-xl font-bold text-gray-900">Ajouter une ressource</h2>
          <p className="mt-1 text-sm text-gray-500">
            Téléversez un PDF, audio, image, ou partagez une vidéo YouTube/Vimeo.
          </p>
        </div>

        <div className="grid grid-cols-2 gap-2 rounded-xl bg-gray-50 p-1">
          <button
            type="button"
            onClick={() => {
              setMode('file')
              setVideoUrl('')
              setFormError(null)
            }}
            className={`rounded-lg px-4 py-2 text-sm font-semibold transition-colors ${
              mode === 'file'
                ? 'bg-white text-flehub-green shadow-sm'
                : 'text-gray-500 hover:text-gray-700'
            }`}
          >
            Fichier
          </button>
          <button
            type="button"
            onClick={() => {
              setMode('video')
              setFile(null)
              setUploadProgress(0)
              setFormError(null)
              if (fileInputRef.current) fileInputRef.current.value = ''
            }}
            className={`rounded-lg px-4 py-2 text-sm font-semibold transition-colors ${
              mode === 'video'
                ? 'bg-white text-flehub-green shadow-sm'
                : 'text-gray-500 hover:text-gray-700'
            }`}
          >
            Vidéo URL
          </button>
        </div>

        {mode === 'file' ? (
          <div
            onDrop={handleDrop}
            onDragOver={(event) => {
              event.preventDefault()
              setIsDragging(true)
            }}
            onDragLeave={() => setIsDragging(false)}
            className={`rounded-2xl border-2 border-dashed p-6 text-center transition-colors ${
              isDragging
                ? 'border-flehub-green bg-flehub-green-light'
                : 'border-gray-200 bg-gray-50 hover:border-flehub-green/60'
            }`}
          >
            <input
              ref={fileInputRef}
              type="file"
              accept={FILE_MIME_TYPES.join(',')}
              onChange={handleFileInput}
              className="hidden"
            />
            <div className="mx-auto mb-3 flex h-12 w-12 items-center justify-center rounded-full bg-flehub-green-light text-flehub-green">
              ↑
            </div>
            <p className="text-sm font-semibold text-gray-800">
              Glissez-déposez un fichier ici
            </p>
            <p className="mt-1 text-xs text-gray-500">
              PDF, audio ou image. Taille maximale: 50MB.
            </p>
            <button
              type="button"
              onClick={() => fileInputRef.current?.click()}
              className="mt-4 rounded-xl border border-flehub-green px-4 py-2 text-sm font-semibold text-flehub-green hover:bg-flehub-green-light"
            >
              Choisir un fichier
            </button>

            {file && (
              <div className="mt-4 rounded-xl border border-gray-100 bg-white p-3 text-left">
                <p className="truncate text-sm font-medium text-gray-900">{file.name}</p>
                <p className="text-xs text-gray-500">
                  {(file.size / (1024 * 1024)).toFixed(2)} MB
                  {fileType ? ` · ${fileType}` : ''}
                </p>
              </div>
            )}

            {isSubmitting && uploadProgress > 0 && (
              <div className="mt-4">
                <div className="mb-1 flex items-center justify-between text-xs text-gray-500">
                  <span>Upload en cours</span>
                  <span>{uploadProgress}%</span>
                </div>
                <div className="h-2 overflow-hidden rounded-full bg-gray-200">
                  <div
                    className="h-full rounded-full bg-flehub-green transition-all"
                    style={{ width: `${uploadProgress}%` }}
                  />
                </div>
              </div>
            )}
          </div>
        ) : (
          <div className="space-y-3">
            <label htmlFor="videoUrl" className="text-sm font-medium text-gray-700">
              URL YouTube ou Vimeo
            </label>
            <input
              id="videoUrl"
              type="url"
              value={videoUrl}
              onChange={(event) => setVideoUrl(event.target.value)}
              placeholder="https://www.youtube.com/watch?v=..."
              className="w-full rounded-xl border border-gray-300 px-3 py-2 text-sm focus:border-flehub-green focus:outline-none focus:ring-2 focus:ring-flehub-green/20"
            />
            {videoUrl && !videoEmbedUrl && (
              <p className="text-xs text-red-500">
                Seules les URLs youtube.com, youtu.be ou vimeo.com sont acceptées.
              </p>
            )}
            {videoEmbedUrl && (
              <div className="overflow-hidden rounded-2xl border border-gray-100 bg-black">
                <iframe
                  src={videoEmbedUrl}
                  title="Aperçu vidéo"
                  className="aspect-video w-full"
                  allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture"
                  allowFullScreen
                />
              </div>
            )}
          </div>
        )}

        <div className="grid grid-cols-1 gap-4 sm:grid-cols-2">
          <div className="sm:col-span-2">
            <label htmlFor="title" className="text-sm font-medium text-gray-700">
              Titre <span className="text-red-500">*</span>
            </label>
            <input
              id="title"
              type="text"
              value={title}
              onChange={(event) => setTitle(event.target.value)}
              className="mt-1 w-full rounded-xl border border-gray-300 px-3 py-2 text-sm focus:border-flehub-green focus:outline-none focus:ring-2 focus:ring-flehub-green/20"
              required
            />
          </div>

          <div className="sm:col-span-2">
            <label htmlFor="description" className="text-sm font-medium text-gray-700">
              Description
            </label>
            <textarea
              id="description"
              value={description}
              onChange={(event) => setDescription(event.target.value)}
              rows={3}
              className="mt-1 w-full rounded-xl border border-gray-300 px-3 py-2 text-sm focus:border-flehub-green focus:outline-none focus:ring-2 focus:ring-flehub-green/20"
            />
          </div>

          <div>
            <label htmlFor="subject" className="text-sm font-medium text-gray-700">
              Sujet
            </label>
            <input
              id="subject"
              type="text"
              value={subject}
              onChange={(event) => setSubject(event.target.value)}
              placeholder="Grammaire, DELF B1..."
              className="mt-1 w-full rounded-xl border border-gray-300 px-3 py-2 text-sm focus:border-flehub-green focus:outline-none focus:ring-2 focus:ring-flehub-green/20"
            />
          </div>

          <div>
            <label htmlFor="level" className="text-sm font-medium text-gray-700">
              Niveau
            </label>
            <select
              id="level"
              value={level}
              onChange={(event) => setLevel(event.target.value as CEFRLevel | '')}
              className="mt-1 w-full rounded-xl border border-gray-300 bg-white px-3 py-2 text-sm focus:border-flehub-green focus:outline-none focus:ring-2 focus:ring-flehub-green/20"
            >
              <option value="">Sélectionner</option>
              {LEVELS.map((item) => (
                <option key={item} value={item}>
                  {item}
                </option>
              ))}
            </select>
          </div>
        </div>

        <div className="flex items-center justify-between rounded-xl border border-gray-100 bg-gray-50 px-4 py-3">
          <div>
            <p className="text-sm font-medium text-gray-800">Ressource publique</p>
            <p className="text-xs text-gray-500">
              Les apprenants peuvent voir cette ressource si elle est publique.
            </p>
          </div>
          <button
            type="button"
            onClick={() => setIsPublic((value) => !value)}
            className={`relative h-6 w-11 rounded-full transition-colors ${
              isPublic ? 'bg-flehub-green' : 'bg-gray-300'
            }`}
            aria-pressed={isPublic}
          >
            <span
              className={`absolute top-1 h-4 w-4 rounded-full bg-white transition-transform ${
                isPublic ? 'translate-x-5' : 'translate-x-1'
              }`}
            />
          </button>
        </div>

        <div className="rounded-xl bg-flehub-green-light px-4 py-3 text-sm text-flehub-green">
          Type détecté: <span className="font-semibold">{resourceType ?? 'en attente'}</span>
        </div>

        {formError && (
          <div className="rounded-xl border border-red-200 bg-red-50 px-4 py-3 text-sm text-red-700">
            {formError}
          </div>
        )}

        <button
          type="submit"
          disabled={isSubmitting}
          className="w-full rounded-xl bg-flehub-green px-4 py-3 text-sm font-semibold text-white shadow-sm transition-colors hover:bg-flehub-green-dark disabled:cursor-not-allowed disabled:opacity-60"
        >
          {isSubmitting ? 'Enregistrement...' : 'Ajouter la ressource'}
        </button>
      </form>
    </div>
  )
}

export default ResourceUploadForm
