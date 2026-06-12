'use client';

import { useState, useRef, useCallback } from 'react';
import { createClient } from '@/lib/supabase/client';

// ─── Types ────────────────────────────────────────────────────────────────────

type ResourceType = 'pdf' | 'audio' | 'image' | 'video';
type CEFRLevel = 'A1' | 'A2' | 'B1' | 'B2' | 'C1' | 'C2';

interface FormData {
  title: string;
  description: string;
  subject: string;
  level: CEFRLevel | '';
  is_public: boolean;
}

interface UploadState {
  status: 'idle' | 'uploading' | 'success' | 'error';
  progress: number;
  message: string;
}

// ─── Constants ────────────────────────────────────────────────────────────────

const ACCEPTED_MIME: Record<string, ResourceType> = {
  'application/pdf': 'pdf',
  'audio/mpeg': 'audio',
  'audio/mp3': 'audio',
  'audio/wav': 'audio',
  'audio/ogg': 'audio',
  'image/jpeg': 'image',
  'image/png': 'image',
  'image/webp': 'image',
};

const MAX_FILE_SIZE = 50 * 1024 * 1024; // 50 MB
const STORAGE_BUCKET = 'flehub-resources';

const TYPE_LABELS: Record<ResourceType, string> = {
  pdf: 'PDF',
  audio: 'Audio',
  image: 'Image',
  video: 'Vidéo',
};

const TYPE_ICONS: Record<ResourceType, string> = {
  pdf: '📄',
  audio: '🎵',
  image: '🖼️',
  video: '🎬',
};

const SUBJECTS = [
  'Grammaire',
  'Vocabulaire',
  'Expression orale',
  'Expression écrite',
  'Compréhension orale',
  'Compréhension écrite',
  'Phonétique',
  'Civilisation',
  'Préparation DELF/DALF',
  'Autre',
];

const LEVELS: CEFRLevel[] = ['A1', 'A2', 'B1', 'B2', 'C1', 'C2'];

const LEVEL_COLORS: Record<CEFRLevel, string> = {
  A1: 'bg-green-100 text-green-800',
  A2: 'bg-emerald-100 text-emerald-800',
  B1: 'bg-blue-100 text-blue-800',
  B2: 'bg-indigo-100 text-indigo-800',
  C1: 'bg-purple-100 text-purple-800',
  C2: 'bg-rose-100 text-rose-800',
};

// ─── Helpers ─────────────────────────────────────────────────────────────────

function isValidVideoUrl(url: string): boolean {
  return /^(https?:\/\/)?(www\.)?(youtube\.com\/watch\?v=|youtu\.be\/|vimeo\.com\/)/.test(url);
}

function getYouTubeEmbedUrl(url: string): string | null {
  const yt = url.match(/(?:youtube\.com\/watch\?v=|youtu\.be\/)([A-Za-z0-9_-]{11})/);
  if (yt) return `https://www.youtube.com/embed/${yt[1]}`;
  const vimeo = url.match(/vimeo\.com\/(\d+)/);
  if (vimeo) return `https://player.vimeo.com/video/${vimeo[1]}`;
  return null;
}

function formatFileSize(bytes: number): string {
  if (bytes < 1024 * 1024) return `${(bytes / 1024).toFixed(0)} KB`;
  return `${(bytes / (1024 * 1024)).toFixed(1)} MB`;
}

function encodeStoragePath(path: string): string {
  return path.split('/').map(encodeURIComponent).join('/');
}

function getSafeStorageFileName(fileName: string): string {
  return fileName
    .normalize('NFKD')
    .replace(/[\u0300-\u036f]/g, '')
    .replace(/[^a-zA-Z0-9._-]+/g, '_')
    .replace(/^_+|_+$/g, '') || 'resource';
}

// ─── Sub-components ───────────────────────────────────────────────────────────

function Toast({ state, onClose }: { state: UploadState; onClose: () => void }) {
  if (state.status === 'idle' || state.status === 'uploading') return null;
  const isSuccess = state.status === 'success';
  return (
    <div
      className={`fixed bottom-6 right-6 z-50 flex items-center gap-3 rounded-xl px-5 py-4 shadow-lg text-white text-sm font-medium transition-all ${
        isSuccess ? 'bg-green-600' : 'bg-red-600'
      }`}
    >
      <span>{isSuccess ? '✅' : '❌'}</span>
      <span>{state.message}</span>
      <button onClick={onClose} className="ml-2 opacity-70 hover:opacity-100 text-lg leading-none">
        ×
      </button>
    </div>
  );
}

function ProgressBar({ progress }: { progress: number }) {
  return (
    <div className="w-full bg-gray-200 rounded-full h-2.5 overflow-hidden">
      <div
        className="bg-blue-600 h-2.5 rounded-full transition-all duration-300"
        style={{ width: `${progress}%` }}
      />
    </div>
  );
}

// ─── Main Component ───────────────────────────────────────────────────────────

interface ResourceUploadFormProps {
  onSuccess?: () => void;
}

export default function ResourceUploadForm({ onSuccess }: ResourceUploadFormProps) {
  const supabase = createClient();

  // Mode
  const [mode, setMode] = useState<'file' | 'video'>('file');

  // File state
  const [dragOver, setDragOver] = useState(false);
  const [selectedFile, setSelectedFile] = useState<File | null>(null);
  const [detectedType, setDetectedType] = useState<ResourceType | null>(null);
  const [fileError, setFileError] = useState<string>('');
  const fileInputRef = useRef<HTMLInputElement>(null);

  // Video URL state
  const [videoUrl, setVideoUrl] = useState('');
  const [videoEmbedUrl, setVideoEmbedUrl] = useState<string | null>(null);
  const [videoUrlError, setVideoUrlError] = useState('');

  // Form fields
  const [form, setForm] = useState<FormData>({
    title: '',
    description: '',
    subject: '',
    level: '',
    is_public: false,
  });

  // Upload state
  const [uploadState, setUploadState] = useState<UploadState>({
    status: 'idle',
    progress: 0,
    message: '',
  });

  // ── File handling ─────────────────────────────────────────────────────────

  const processFile = useCallback((file: File) => {
    setFileError('');
    const type = ACCEPTED_MIME[file.type];
    if (!type) {
      setSelectedFile(null);
      setDetectedType(null);
      setFileError('Type de fichier non accepté. Utilisez PDF, audio (MP3/WAV) ou image (JPG/PNG/WebP).');
      return;
    }
    if (file.size > MAX_FILE_SIZE) {
      setSelectedFile(null);
      setDetectedType(null);
      setFileError(`Fichier trop volumineux (${formatFileSize(file.size)}). Maximum : 50 MB.`);
      return;
    }
    setSelectedFile(file);
    setDetectedType(type);
  }, []);

  const handleDrop = useCallback(
    (e: React.DragEvent) => {
      e.preventDefault();
      setDragOver(false);
      const file = e.dataTransfer.files[0];
      if (file) processFile(file);
    },
    [processFile]
  );

  const handleFileChange = useCallback(
    (e: React.ChangeEvent<HTMLInputElement>) => {
      const file = e.target.files?.[0];
      if (file) processFile(file);
    },
    [processFile]
  );

  // ── Video URL handling ────────────────────────────────────────────────────

  const handleVideoUrlChange = (url: string) => {
    setVideoUrl(url);
    setVideoUrlError('');
    setVideoEmbedUrl(null);
    if (!url) return;
    if (!isValidVideoUrl(url)) {
      setVideoUrlError('Entrez une URL YouTube (youtube.com ou youtu.be) ou Vimeo.');
      return;
    }
    const embed = getYouTubeEmbedUrl(url);
    setVideoEmbedUrl(embed);
  };

  // ── Form handling ─────────────────────────────────────────────────────────

  const updateForm = (field: keyof FormData, value: string | boolean) => {
    setForm((prev) => ({ ...prev, [field]: value }));
  };

  const resetForm = () => {
    setForm({ title: '', description: '', subject: '', level: '', is_public: false });
    setSelectedFile(null);
    setDetectedType(null);
    setFileError('');
    setVideoUrl('');
    setVideoEmbedUrl(null);
    setVideoUrlError('');
    if (fileInputRef.current) fileInputRef.current.value = '';
  };

  // ── Submit ────────────────────────────────────────────────────────────────

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();

    if (!form.title.trim()) return;
    if (mode === 'file' && !selectedFile) return;
    if (mode === 'video' && !isValidVideoUrl(videoUrl)) return;

    setUploadState({ status: 'uploading', progress: 0, message: '' });

    try {
      const { data: { user } } = await supabase.auth.getUser();
      if (!user) throw new Error('Non authentifié. Veuillez vous reconnecter.');

      let filePath = '';
      let storagePath: string | null = null;
      let fileSize: number | null = null;
      let fileName: string | null = null;
      let resourceType: ResourceType;

      if (mode === 'file' && selectedFile && detectedType) {
        // XHR upload with progress tracking
        resourceType = detectedType;
        const uniqueName = `${user.id}/${crypto.randomUUID()}-${getSafeStorageFileName(selectedFile.name)}`;
        storagePath = uniqueName;
        filePath = uniqueName;
        fileSize = selectedFile.size;
        fileName = selectedFile.name;

        const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL;
        const anonKey = process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY;
        if (!supabaseUrl || !anonKey) {
          throw new Error('Configuration Supabase manquante.');
        }

        const {
          data: { session },
        } = await supabase.auth.getSession();
        if (!session?.access_token) {
          throw new Error('Session invalide. Veuillez vous reconnecter.');
        }

        await new Promise<void>((resolve, reject) => {
          const xhr = new XMLHttpRequest();
          xhr.open('POST', `${supabaseUrl}/storage/v1/object/${STORAGE_BUCKET}/${encodeStoragePath(uniqueName)}`);
          xhr.setRequestHeader('Authorization', `Bearer ${session.access_token}`);
          xhr.setRequestHeader('apikey', anonKey);
          xhr.setRequestHeader('x-upsert', 'false');
          xhr.setRequestHeader('Content-Type', selectedFile.type);

          xhr.upload.addEventListener('progress', (event) => {
            if (event.lengthComputable) {
              const pct = Math.round((event.loaded / event.total) * 100);
              setUploadState({ status: 'uploading', progress: pct, message: '' });
            }
          });

          xhr.addEventListener('load', () => {
            if (xhr.status >= 200 && xhr.status < 300) {
              setUploadState({ status: 'uploading', progress: 100, message: '' });
              resolve();
            } else {
              try {
                const err = JSON.parse(xhr.responseText);
                reject(new Error(err.message || 'Erreur de stockage.'));
              } catch {
                reject(new Error('Erreur lors de l\'upload du fichier.'));
              }
            }
          });

          xhr.addEventListener('error', () => reject(new Error('Erreur réseau lors de l\'upload.')));
          xhr.send(selectedFile);
        });

      } else {
        // Video URL mode
        resourceType = 'video';
        filePath = videoUrl.trim();
      }

      // Insert into DB
      const { error: dbError } = await supabase.from('resources').insert({
        teacher_id: user.id,
        title: form.title.trim(),
        description: form.description.trim() || null,
        type: resourceType,
        subject: form.subject || null,
        level: form.level || null,
        file_path: filePath,
        file_size: fileSize,
        file_name: fileName,
        is_public: form.is_public,
      });

      if (dbError) {
        if (storagePath) {
          await supabase.storage.from(STORAGE_BUCKET).remove([storagePath]);
        }
        throw new Error(dbError.message);
      }

      setUploadState({
        status: 'success',
        progress: 100,
        message: 'Ressource publiée avec succès !',
      });
      resetForm();
      onSuccess?.();

    } catch (err) {
      setUploadState({
        status: 'error',
        progress: 0,
        message: err instanceof Error ? err.message : 'Une erreur est survenue.',
      });
    }
  };

  const isSubmitting = uploadState.status === 'uploading';
  const canSubmit =
    form.title.trim() &&
    (mode === 'file' ? !!selectedFile : isValidVideoUrl(videoUrl)) &&
    !isSubmitting;

  // ── Render ────────────────────────────────────────────────────────────────

  return (
    <>
      <form onSubmit={handleSubmit} className="space-y-6 max-w-2xl mx-auto">

        {/* Mode tabs */}
        <div className="flex rounded-xl border border-gray-200 overflow-hidden">
          <button
            type="button"
            onClick={() => setMode('file')}
            className={`flex-1 py-3 text-sm font-medium transition-colors ${
              mode === 'file'
                ? 'bg-blue-600 text-white'
                : 'bg-white text-gray-600 hover:bg-gray-50'
            }`}
          >
            📁 Fichier (PDF / Audio / Image)
          </button>
          <button
            type="button"
            onClick={() => setMode('video')}
            className={`flex-1 py-3 text-sm font-medium transition-colors ${
              mode === 'video'
                ? 'bg-blue-600 text-white'
                : 'bg-white text-gray-600 hover:bg-gray-50'
            }`}
          >
            🎬 Vidéo YouTube / Vimeo
          </button>
        </div>

        {/* FILE MODE */}
        {mode === 'file' && (
          <div>
            <div
              onDragOver={(e) => { e.preventDefault(); setDragOver(true); }}
              onDragLeave={() => setDragOver(false)}
              onDrop={handleDrop}
              onClick={() => fileInputRef.current?.click()}
              className={`relative cursor-pointer rounded-xl border-2 border-dashed p-8 text-center transition-all ${
                dragOver
                  ? 'border-blue-500 bg-blue-50'
                  : selectedFile
                  ? 'border-green-400 bg-green-50'
                  : 'border-gray-300 bg-gray-50 hover:border-blue-400 hover:bg-blue-50'
              }`}
            >
              <input
                ref={fileInputRef}
                type="file"
                accept=".pdf,audio/*,image/jpeg,image/png,image/webp"
                className="hidden"
                onChange={handleFileChange}
              />
              {selectedFile && detectedType ? (
                <div className="space-y-1">
                  <div className="text-3xl">{TYPE_ICONS[detectedType]}</div>
                  <p className="font-semibold text-gray-800">{selectedFile.name}</p>
                  <p className="text-sm text-gray-500">
                    {TYPE_LABELS[detectedType]} · {formatFileSize(selectedFile.size)}
                  </p>
                  <button
                    type="button"
                    onClick={(e) => { e.stopPropagation(); setSelectedFile(null); setDetectedType(null); }}
                    className="mt-2 text-xs text-red-500 hover:text-red-700"
                  >
                    Supprimer
                  </button>
                </div>
              ) : (
                <div className="space-y-2">
                  <div className="text-4xl">📂</div>
                  <p className="text-sm font-medium text-gray-700">
                    Glissez un fichier ici ou cliquez pour choisir
                  </p>
                  <p className="text-xs text-gray-400">
                    PDF · MP3 / WAV · JPG / PNG / WebP — max 50 MB
                  </p>
                </div>
              )}
            </div>
            {fileError && (
              <p className="mt-2 text-sm text-red-600">{fileError}</p>
            )}
          </div>
        )}

        {/* VIDEO MODE */}
        {mode === 'video' && (
          <div className="space-y-3">
            <input
              type="url"
              value={videoUrl}
              onChange={(e) => handleVideoUrlChange(e.target.value)}
              placeholder="https://www.youtube.com/watch?v=... ou https://vimeo.com/..."
              className="w-full rounded-xl border border-gray-300 px-4 py-3 text-sm focus:border-blue-500 focus:outline-none focus:ring-2 focus:ring-blue-500/20"
            />
            {videoUrlError && (
              <p className="text-sm text-red-600">{videoUrlError}</p>
            )}
            {videoEmbedUrl && (
              <div className="overflow-hidden rounded-xl aspect-video">
                <iframe
                  src={videoEmbedUrl}
                  className="w-full h-full"
                  allowFullScreen
                  title="Prévisualisation vidéo"
                />
              </div>
            )}
          </div>
        )}

        {/* Upload progress */}
        {isSubmitting && (
          <div className="space-y-2">
            <div className="flex justify-between text-xs text-gray-500">
              <span>{mode === 'file' ? 'Upload en cours…' : 'Enregistrement…'}</span>
              <span>{uploadState.progress}%</span>
            </div>
            <ProgressBar progress={uploadState.progress} />
          </div>
        )}

        {/* ── Common fields ── */}
        <div className="space-y-4">

          {/* Title */}
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">
              Titre <span className="text-red-500">*</span>
            </label>
            <input
              type="text"
              value={form.title}
              onChange={(e) => updateForm('title', e.target.value)}
              maxLength={100}
              placeholder="ex. Exercice de prononciation — voyelles nasales"
              required
              className="w-full rounded-xl border border-gray-300 px-4 py-2.5 text-sm focus:border-blue-500 focus:outline-none focus:ring-2 focus:ring-blue-500/20"
            />
          </div>

          {/* Description */}
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">
              Description
            </label>
            <textarea
              value={form.description}
              onChange={(e) => updateForm('description', e.target.value)}
              maxLength={500}
              rows={3}
              placeholder="Décrivez brièvement cette ressource…"
              className="w-full rounded-xl border border-gray-300 px-4 py-2.5 text-sm focus:border-blue-500 focus:outline-none focus:ring-2 focus:ring-blue-500/20 resize-none"
            />
          </div>

          {/* Subject + Level */}
          <div className="grid grid-cols-2 gap-4">
            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">
                Compétence / Domaine
              </label>
              <select
                value={form.subject}
                onChange={(e) => updateForm('subject', e.target.value)}
                className="w-full rounded-xl border border-gray-300 px-4 py-2.5 text-sm focus:border-blue-500 focus:outline-none focus:ring-2 focus:ring-blue-500/20 bg-white"
              >
                <option value="">— Choisir —</option>
                {SUBJECTS.map((s) => (
                  <option key={s} value={s}>{s}</option>
                ))}
              </select>
            </div>

            <div>
              <label className="block text-sm font-medium text-gray-700 mb-1">
                Niveau CECRL
              </label>
              <div className="flex flex-wrap gap-1.5">
                {LEVELS.map((lvl) => (
                  <button
                    key={lvl}
                    type="button"
                    onClick={() => updateForm('level', form.level === lvl ? '' : lvl)}
                    className={`px-3 py-1.5 rounded-lg text-xs font-semibold border transition-all ${
                      form.level === lvl
                        ? LEVEL_COLORS[lvl] + ' border-transparent ring-2 ring-offset-1 ring-current'
                        : 'border-gray-200 text-gray-500 hover:border-gray-400'
                    }`}
                  >
                    {lvl}
                  </button>
                ))}
              </div>
            </div>
          </div>

          {/* is_public toggle */}
          <div className="flex items-center justify-between rounded-xl border border-gray-200 px-4 py-3">
            <div>
              <p className="text-sm font-medium text-gray-700">Visible par tous les enseignants</p>
              <p className="text-xs text-gray-400 mt-0.5">
                Si désactivé, la ressource reste privée (visible uniquement par vous)
              </p>
            </div>
            <button
              type="button"
              onClick={() => updateForm('is_public', !form.is_public)}
              className={`relative inline-flex h-6 w-11 items-center rounded-full transition-colors ${
                form.is_public ? 'bg-blue-600' : 'bg-gray-300'
              }`}
            >
              <span
                className={`inline-block h-4 w-4 transform rounded-full bg-white shadow transition-transform ${
                  form.is_public ? 'translate-x-6' : 'translate-x-1'
                }`}
              />
            </button>
          </div>
        </div>

        {/* Submit */}
        <button
          type="submit"
          disabled={!canSubmit}
          className={`w-full rounded-xl py-3 text-sm font-semibold transition-all ${
            canSubmit
              ? 'bg-blue-600 text-white hover:bg-blue-700 active:scale-[0.99]'
              : 'bg-gray-100 text-gray-400 cursor-not-allowed'
          }`}
        >
          {isSubmitting
            ? mode === 'file'
              ? `Upload… ${uploadState.progress}%`
              : 'Enregistrement…'
            : mode === 'file'
            ? '⬆️  Publier la ressource'
            : '🔗  Enregistrer la vidéo'}
        </button>
      </form>

      {/* Toast */}
      <Toast
        state={uploadState}
        onClose={() => setUploadState((s) => ({ ...s, status: 'idle' }))}
      />
    </>
  );
}
