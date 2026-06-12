'use client';

import { useEffect, useRef, useState } from 'react';
import type { ChangeEvent, DragEvent, ElementType, FormEvent } from 'react';
import {
  CheckCircle2,
  FileAudio,
  FileText,
  Image as ImageIcon,
  Link2,
  Loader2,
  Trash2,
  UploadCloud,
  XCircle,
} from 'lucide-react';
import { createClient } from '@/lib/supabase/client';

type ResourceType = 'pdf' | 'audio' | 'image' | 'video';
type FileResourceType = Exclude<ResourceType, 'video'>;
type CECRLLevel = 'A1' | 'A2' | 'B1' | 'B2' | 'C1' | 'C2';

type LessonForm = {
  title: string;
  description: string;
  level: CECRLLevel | '';
  subject: string;
  is_public: boolean;
};

type SelectedResourceFile = {
  id: string;
  file: File;
  type: FileResourceType;
  previewUrl?: string;
};

type FileUploadProgress = {
  progress: number;
  status: 'pending' | 'uploading' | 'complete' | 'error';
  message?: string;
};

type UploadStatus =
  | { type: 'idle' }
  | { type: 'uploading'; message: string }
  | { type: 'success'; message: string }
  | { type: 'error'; message: string };

type ResourceInsertRow = {
  teacher_id: string;
  title: string;
  description: string | null;
  type: ResourceType;
  subject: string | null;
  level: CECRLLevel | null;
  file_path: string;
  file_size: number | null;
  file_name: string | null;
  is_public: boolean;
};

interface ResourceUploadFormProps {
  teacherId?: string | null;
  onSuccess?: () => void;
}

const BUCKET_NAME = 'flehub-resources';
const MAX_FILE_SIZE = 50 * 1024 * 1024;

const LEVELS: CECRLLevel[] = ['A1', 'A2', 'B1', 'B2', 'C1', 'C2'];
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
];

const FILE_TABS: Array<{
  type: ResourceType;
  label: string;
  description: string;
  accept?: string;
  icon: ElementType;
}> = [
  {
    type: 'pdf',
    label: 'PDF',
    description: 'Lesson sheets, exercises, grammar notes',
    accept: '.pdf,application/pdf',
    icon: FileText,
  },
  {
    type: 'audio',
    label: 'Audio',
    description: 'MP3, WAV, OGG listening and pronunciation files',
    accept: '.mp3,.wav,.ogg,audio/mpeg,audio/mp3,audio/wav,audio/x-wav,audio/ogg',
    icon: FileAudio,
  },
  {
    type: 'image',
    label: 'Image',
    description: 'JPG, PNG, WebP visual aids and flashcards',
    accept: '.jpg,.jpeg,.png,.webp,image/jpeg,image/png,image/webp',
    icon: ImageIcon,
  },
  {
    type: 'video',
    label: 'Vidéo',
    description: 'YouTube or Vimeo link only',
    icon: Link2,
  },
];

const emptyForm: LessonForm = {
  title: '',
  description: '',
  level: '',
  subject: '',
  is_public: false,
};

function formatFileSize(bytes: number) {
  if (bytes < 1024 * 1024) {
    return `${Math.max(1, Math.round(bytes / 1024))} KB`;
  }

  return `${(bytes / (1024 * 1024)).toFixed(1)} MB`;
}

function getFileExtension(fileName: string) {
  return fileName.split('.').pop()?.toLowerCase() ?? '';
}

function isAcceptedFile(file: File, type: FileResourceType) {
  const extension = getFileExtension(file.name);

  if (type === 'pdf') {
    return file.type === 'application/pdf' || extension === 'pdf';
  }

  if (type === 'audio') {
    return (
      ['audio/mpeg', 'audio/mp3', 'audio/wav', 'audio/x-wav', 'audio/ogg'].includes(file.type) ||
      ['mp3', 'wav', 'ogg'].includes(extension)
    );
  }

  return (
    ['image/jpeg', 'image/png', 'image/webp'].includes(file.type) ||
    ['jpg', 'jpeg', 'png', 'webp'].includes(extension)
  );
}

function sanitizeFileName(fileName: string) {
  const cleaned = fileName
    .normalize('NFD')
    .replace(/[\u0300-\u036f]/g, '')
    .replace(/[^a-zA-Z0-9._-]+/g, '-')
    .replace(/-+/g, '-')
    .replace(/^-|-$/g, '');

  return cleaned || 'resource';
}

function encodeStoragePath(path: string) {
  return path.split('/').map(encodeURIComponent).join('/');
}

function getVideoEmbedUrl(rawUrl: string) {
  try {
    const parsed = new URL(rawUrl);
    if (!['http:', 'https:'].includes(parsed.protocol)) {
      return null;
    }

    const host = parsed.hostname.toLowerCase().replace(/^www\./, '');

    if (host === 'youtu.be') {
      const videoId = parsed.pathname.split('/').filter(Boolean)[0];
      return videoId ? `https://www.youtube.com/embed/${videoId}` : null;
    }

    if (host === 'youtube.com' || host === 'm.youtube.com') {
      const watchId = parsed.searchParams.get('v');
      if (watchId) {
        return `https://www.youtube.com/embed/${watchId}`;
      }

      const [prefix, videoId] = parsed.pathname.split('/').filter(Boolean);
      if ((prefix === 'embed' || prefix === 'shorts') && videoId) {
        return `https://www.youtube.com/embed/${videoId}`;
      }
    }

    if (host === 'vimeo.com') {
      const videoId = parsed.pathname.split('/').filter(Boolean).find((segment) => /^\d+$/.test(segment));
      return videoId ? `https://player.vimeo.com/video/${videoId}` : null;
    }

    if (host === 'player.vimeo.com') {
      const [, videoId] = parsed.pathname.split('/').filter(Boolean);
      return videoId && /^\d+$/.test(videoId) ? `https://player.vimeo.com/video/${videoId}` : null;
    }
  } catch {
    return null;
  }

  return null;
}

function uploadFileWithProgress({
  file,
  path,
  accessToken,
  onProgress,
}: {
  file: File;
  path: string;
  accessToken: string;
  onProgress: (progress: number) => void;
}) {
  const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL;
  const anonKey = process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY;

  if (!supabaseUrl || !anonKey) {
    return Promise.reject(new Error('Supabase environment variables are missing.'));
  }

  return new Promise<void>((resolve, reject) => {
    const xhr = new XMLHttpRequest();
    const objectUrl = `${supabaseUrl}/storage/v1/object/${BUCKET_NAME}/${encodeStoragePath(path)}`;

    xhr.open('POST', objectUrl);
    xhr.setRequestHeader('Authorization', `Bearer ${accessToken}`);
    xhr.setRequestHeader('apikey', anonKey);
    xhr.setRequestHeader('x-upsert', 'false');
    xhr.setRequestHeader('Content-Type', file.type || 'application/octet-stream');

    xhr.upload.addEventListener('progress', (event) => {
      if (!event.lengthComputable) {
        return;
      }

      onProgress(Math.round((event.loaded / event.total) * 100));
    });

    xhr.addEventListener('load', () => {
      if (xhr.status >= 200 && xhr.status < 300) {
        onProgress(100);
        resolve();
        return;
      }

      try {
        const parsed = JSON.parse(xhr.responseText);
        reject(new Error(parsed.message || 'Storage upload failed.'));
      } catch {
        reject(new Error('Storage upload failed.'));
      }
    });

    xhr.addEventListener('error', () => reject(new Error('Network error during upload.')));
    xhr.send(file);
  });
}

export default function ResourceUploadForm({ teacherId: providedTeacherId, onSuccess }: ResourceUploadFormProps) {
  const supabase = createClient();
  const fileInputRefs = useRef<Record<FileResourceType, HTMLInputElement | null>>({
    pdf: null,
    audio: null,
    image: null,
  });
  const filesRef = useRef<SelectedResourceFile[]>([]);

  const [form, setForm] = useState<LessonForm>({ ...emptyForm });
  const [activeTab, setActiveTab] = useState<ResourceType>('pdf');
  const [files, setFiles] = useState<SelectedResourceFile[]>([]);
  const [dragOverTab, setDragOverTab] = useState<FileResourceType | null>(null);
  const [fileError, setFileError] = useState<string | null>(null);
  const [videoUrl, setVideoUrl] = useState('');
  const [uploadStatus, setUploadStatus] = useState<UploadStatus>({ type: 'idle' });
  const [progressByFileId, setProgressByFileId] = useState<Record<string, FileUploadProgress>>({});

  useEffect(() => {
    filesRef.current = files;
  }, [files]);

  useEffect(() => {
    return () => {
      filesRef.current.forEach((resourceFile) => {
        if (resourceFile.previewUrl) {
          URL.revokeObjectURL(resourceFile.previewUrl);
        }
      });
    };
  }, []);

  const isUploading = uploadStatus.type === 'uploading';
  const videoEmbedUrl = videoUrl.trim() ? getVideoEmbedUrl(videoUrl.trim()) : null;
  const videoError = videoUrl.trim() && !videoEmbedUrl ? 'Enter a valid YouTube or Vimeo URL.' : null;
  const selectedFilesByType = files.reduce<Record<FileResourceType, SelectedResourceFile[]>>(
    (acc, resourceFile) => {
      acc[resourceFile.type].push(resourceFile);
      return acc;
    },
    { pdf: [], audio: [], image: [] }
  );
  const hasResources = files.length > 0 || Boolean(videoEmbedUrl);
  const canSubmit = Boolean(form.title.trim()) && hasResources && !videoError && !isUploading;

  function updateForm<K extends keyof LessonForm>(field: K, value: LessonForm[K]) {
    setForm((current) => ({ ...current, [field]: value }));
  }

  function addFiles(fileList: FileList | File[], type: FileResourceType) {
    setFileError(null);

    const incomingFiles = Array.from(fileList);
    const accepted: SelectedResourceFile[] = [];
    const rejected: string[] = [];

    incomingFiles.forEach((file) => {
      if (!isAcceptedFile(file, type)) {
        rejected.push(`${file.name} has an unsupported format.`);
        return;
      }

      if (file.size > MAX_FILE_SIZE) {
        rejected.push(`${file.name} is larger than 50 MB.`);
        return;
      }

      accepted.push({
        id: crypto.randomUUID(),
        file,
        type,
        previewUrl: type === 'image' ? URL.createObjectURL(file) : undefined,
      });
    });

    if (accepted.length > 0) {
      setFiles((current) => [...current, ...accepted]);
    }

    if (rejected.length > 0) {
      setFileError(rejected.join(' '));
    }
  }

  function handleFileInputChange(event: ChangeEvent<HTMLInputElement>, type: FileResourceType) {
    if (event.target.files) {
      addFiles(event.target.files, type);
    }

    event.target.value = '';
  }

  function handleDrop(event: DragEvent<HTMLDivElement>, type: FileResourceType) {
    event.preventDefault();
    setDragOverTab(null);

    if (event.dataTransfer.files.length > 0) {
      addFiles(event.dataTransfer.files, type);
    }
  }

  function removeFile(fileId: string) {
    setFiles((current) => {
      const removed = current.find((resourceFile) => resourceFile.id === fileId);
      if (removed?.previewUrl) {
        URL.revokeObjectURL(removed.previewUrl);
      }

      return current.filter((resourceFile) => resourceFile.id !== fileId);
    });

    setProgressByFileId((current) => {
      const next = { ...current };
      delete next[fileId];
      return next;
    });
  }

  function resetForm() {
    files.forEach((resourceFile) => {
      if (resourceFile.previewUrl) {
        URL.revokeObjectURL(resourceFile.previewUrl);
      }
    });

    setForm({ ...emptyForm });
    setFiles([]);
    setProgressByFileId({});
    setVideoUrl('');
    setActiveTab('pdf');
    setFileError(null);
  }

  async function resolveTeacherId() {
    if (providedTeacherId) {
      return providedTeacherId;
    }

    const {
      data: { user },
      error: userError,
    } = await supabase.auth.getUser();

    if (userError || !user) {
      throw new Error('You must be signed in to upload resources.');
    }

    const { data: teacher, error: teacherError } = await supabase
      .from('teachers')
      .select('id')
      .eq('profile_id', user.id)
      .maybeSingle();

    if (teacherError) {
      throw new Error(teacherError.message);
    }

    if (!teacher?.id) {
      throw new Error('Teacher profile not found.');
    }

    return teacher.id as string;
  }

  async function handleSubmit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();

    if (!canSubmit) {
      return;
    }

    setUploadStatus({ type: 'uploading', message: 'Preparing lesson resources...' });
    setProgressByFileId(
      files.reduce<Record<string, FileUploadProgress>>((acc, resourceFile) => {
        acc[resourceFile.id] = { progress: 0, status: 'pending' };
        return acc;
      }, {})
    );

    try {
      const teacherId = await resolveTeacherId();
      const {
        data: { session },
      } = await supabase.auth.getSession();
      const accessToken = session?.access_token ?? process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY;

      if (!accessToken) {
        throw new Error('Supabase session is unavailable.');
      }

      const resourceRows: ResourceInsertRow[] = [];

      for (const resourceFile of files) {
        const safeName = sanitizeFileName(resourceFile.file.name);
        const filePath = `${teacherId}/${crypto.randomUUID()}-${safeName}`;

        setUploadStatus({ type: 'uploading', message: `Uploading ${resourceFile.file.name}...` });
        setProgressByFileId((current) => ({
          ...current,
          [resourceFile.id]: { progress: 0, status: 'uploading' },
        }));

        await uploadFileWithProgress({
          file: resourceFile.file,
          path: filePath,
          accessToken,
          onProgress: (progress) => {
            setProgressByFileId((current) => ({
              ...current,
              [resourceFile.id]: { progress, status: 'uploading' },
            }));
          },
        });

        setProgressByFileId((current) => ({
          ...current,
          [resourceFile.id]: { progress: 100, status: 'complete' },
        }));

        resourceRows.push({
          teacher_id: teacherId,
          title: form.title.trim(),
          description: form.description.trim() || null,
          type: resourceFile.type,
          subject: form.subject || null,
          level: form.level || null,
          file_path: filePath,
          file_size: resourceFile.file.size,
          file_name: resourceFile.file.name,
          is_public: form.is_public,
        });
      }

      if (videoEmbedUrl) {
        resourceRows.push({
          teacher_id: teacherId,
          title: form.title.trim(),
          description: form.description.trim() || null,
          type: 'video',
          subject: form.subject || null,
          level: form.level || null,
          file_path: videoUrl.trim(),
          file_size: null,
          file_name: null,
          is_public: form.is_public,
        });
      }

      setUploadStatus({ type: 'uploading', message: 'Saving lesson resources...' });

      const { error: insertError } = await supabase.from('resources').insert(resourceRows);
      if (insertError) {
        throw new Error(insertError.message);
      }

      setUploadStatus({
        type: 'success',
        message: `${resourceRows.length} resource${resourceRows.length === 1 ? '' : 's'} uploaded successfully.`,
      });
      resetForm();
      onSuccess?.();
    } catch (error) {
      const message = error instanceof Error ? error.message : 'Unable to upload lesson resources.';

      setUploadStatus({ type: 'error', message });
      setProgressByFileId((current) => {
        const next = { ...current };
        Object.keys(next).forEach((fileId) => {
          if (next[fileId].status === 'uploading' || next[fileId].status === 'pending') {
            next[fileId] = { ...next[fileId], status: 'error', message };
          }
        });
        return next;
      });
    }
  }

  function renderDropZone(type: FileResourceType) {
    const selectedFiles = selectedFilesByType[type];
    const tab = FILE_TABS.find((item) => item.type === type);
    const Icon = tab?.icon ?? UploadCloud;
    const isDragOver = dragOverTab === type;

    return (
      <div className="space-y-4">
        <div
          onDragOver={(event) => {
            event.preventDefault();
            setDragOverTab(type);
          }}
          onDragLeave={() => setDragOverTab(null)}
          onDrop={(event) => handleDrop(event, type)}
          onClick={() => fileInputRefs.current[type]?.click()}
          className={`cursor-pointer rounded-2xl border-2 border-dashed p-8 text-center transition ${
            isDragOver ? 'border-flehub-green bg-flehub-green-light' : 'border-gray-300 bg-gray-50 hover:border-flehub-green'
          }`}
        >
          <input
            ref={(element) => {
              fileInputRefs.current[type] = element;
            }}
            type="file"
            multiple
            accept={tab?.accept}
            className="hidden"
            onChange={(event) => handleFileInputChange(event, type)}
          />
          <div className="mx-auto mb-3 flex h-12 w-12 items-center justify-center rounded-full bg-white text-flehub-green shadow-sm">
            <Icon className="h-6 w-6" />
          </div>
          <p className="text-sm font-semibold text-gray-800">Drag and drop {tab?.label} files here</p>
          <p className="mt-1 text-xs text-gray-500">or click to browse. Max 50 MB per file.</p>
        </div>

        {selectedFiles.length > 0 && (
          <div className="space-y-3">
            {selectedFiles.map((resourceFile) => (
              <SelectedFileRow
                key={resourceFile.id}
                resourceFile={resourceFile}
                progress={progressByFileId[resourceFile.id]}
                onRemove={() => removeFile(resourceFile.id)}
                disabled={isUploading}
              />
            ))}
          </div>
        )}
      </div>
    );
  }

  return (
    <form onSubmit={handleSubmit} className="space-y-6">
      <div className="rounded-2xl border border-gray-200 bg-white p-5 shadow-sm">
        <div className="mb-5">
          <h2 className="text-lg font-semibold text-gray-900">Upload lesson package</h2>
          <p className="text-sm text-gray-500">
            Add the lesson details once, then attach every PDF, audio file, image, and video link for the package.
          </p>
        </div>

        <div className="space-y-5">
          <div className="space-y-1.5">
            <label htmlFor="lesson-title" className="text-sm font-medium text-gray-700">
              Lesson title <span className="text-red-500">*</span>
            </label>
            <input
              id="lesson-title"
              type="text"
              required
              value={form.title}
              onChange={(event) => updateForm('title', event.target.value)}
              placeholder="Example: Les temps du passe - B1"
              className="w-full rounded-xl border border-gray-300 px-4 py-2.5 text-sm outline-none transition focus:border-flehub-green focus:ring-2 focus:ring-flehub-green/20"
            />
          </div>

          <div className="space-y-1.5">
            <label htmlFor="lesson-description" className="text-sm font-medium text-gray-700">
              Description
            </label>
            <textarea
              id="lesson-description"
              value={form.description}
              onChange={(event) => updateForm('description', event.target.value)}
              rows={3}
              placeholder="Describe the lesson objectives, target learners, or teacher notes."
              className="w-full resize-none rounded-xl border border-gray-300 px-4 py-2.5 text-sm outline-none transition focus:border-flehub-green focus:ring-2 focus:ring-flehub-green/20"
            />
          </div>

          <div className="grid gap-5 md:grid-cols-2">
            <div className="space-y-2">
              <p className="text-sm font-medium text-gray-700">CECRL Level</p>
              <div className="flex flex-wrap gap-2">
                {LEVELS.map((level) => (
                  <button
                    key={level}
                    type="button"
                    onClick={() => updateForm('level', form.level === level ? '' : level)}
                    className={`rounded-full border px-4 py-2 text-sm font-semibold transition ${
                      form.level === level
                        ? 'border-flehub-green bg-flehub-green text-white shadow-sm'
                        : 'border-gray-200 bg-white text-gray-600 hover:border-flehub-green hover:text-flehub-green'
                    }`}
                  >
                    {level}
                  </button>
                ))}
              </div>
            </div>

            <div className="space-y-1.5">
              <label htmlFor="lesson-subject" className="text-sm font-medium text-gray-700">
                Subject/Competence
              </label>
              <select
                id="lesson-subject"
                value={form.subject}
                onChange={(event) => updateForm('subject', event.target.value)}
                className="w-full rounded-xl border border-gray-300 bg-white px-4 py-2.5 text-sm outline-none transition focus:border-flehub-green focus:ring-2 focus:ring-flehub-green/20"
              >
                <option value="">Select a subject</option>
                {SUBJECTS.map((subject) => (
                  <option key={subject} value={subject}>
                    {subject}
                  </option>
                ))}
              </select>
            </div>
          </div>

          <div className="flex flex-col gap-3 rounded-xl border border-gray-200 bg-gray-50 p-4 sm:flex-row sm:items-center sm:justify-between">
            <div>
              <p className="text-sm font-medium text-gray-800">Visible to all teachers</p>
              <p className="text-xs text-gray-500">Private resources remain available only to you.</p>
            </div>
            <button
              type="button"
              role="switch"
              aria-checked={form.is_public}
              onClick={() => updateForm('is_public', !form.is_public)}
              className={`relative inline-flex h-7 w-12 shrink-0 items-center rounded-full transition ${
                form.is_public ? 'bg-flehub-green' : 'bg-gray-300'
              }`}
            >
              <span
                className={`inline-block h-5 w-5 rounded-full bg-white shadow transition ${
                  form.is_public ? 'translate-x-6' : 'translate-x-1'
                }`}
              />
            </button>
          </div>
        </div>
      </div>

      <div className="rounded-2xl border border-gray-200 bg-white p-5 shadow-sm">
        <div className="mb-4 grid grid-cols-2 gap-2 md:grid-cols-4">
          {FILE_TABS.map((tab) => {
            const Icon = tab.icon;
            const selectedCount =
              tab.type === 'video' ? (videoEmbedUrl ? 1 : 0) : selectedFilesByType[tab.type as FileResourceType].length;

            return (
              <button
                key={tab.type}
                type="button"
                onClick={() => setActiveTab(tab.type)}
                className={`rounded-xl border p-3 text-left transition ${
                  activeTab === tab.type
                    ? 'border-flehub-green bg-flehub-green-light text-flehub-green'
                    : 'border-gray-200 bg-white text-gray-600 hover:border-flehub-green/60'
                }`}
              >
                <div className="flex items-center gap-2">
                  <Icon className="h-4 w-4" />
                  <span className="text-sm font-semibold">{tab.label}</span>
                  {selectedCount > 0 && (
                    <span className="ml-auto rounded-full bg-flehub-green px-2 py-0.5 text-xs font-semibold text-white">
                      {selectedCount}
                    </span>
                  )}
                </div>
                <p className="mt-1 line-clamp-2 text-xs opacity-75">{tab.description}</p>
              </button>
            );
          })}
        </div>

        {activeTab === 'pdf' && renderDropZone('pdf')}
        {activeTab === 'audio' && renderDropZone('audio')}
        {activeTab === 'image' && renderDropZone('image')}
        {activeTab === 'video' && (
          <div className="space-y-4">
            <div className="space-y-1.5">
              <label htmlFor="video-url" className="text-sm font-medium text-gray-700">
                YouTube or Vimeo URL
              </label>
              <input
                id="video-url"
                type="url"
                value={videoUrl}
                onChange={(event) => setVideoUrl(event.target.value)}
                placeholder="https://www.youtube.com/watch?v=... or https://vimeo.com/..."
                className="w-full rounded-xl border border-gray-300 px-4 py-2.5 text-sm outline-none transition focus:border-flehub-green focus:ring-2 focus:ring-flehub-green/20"
              />
              {videoError && <p className="text-sm text-red-600">{videoError}</p>}
            </div>

            {videoEmbedUrl && (
              <div className="overflow-hidden rounded-xl border border-gray-200 bg-black">
                <iframe
                  src={videoEmbedUrl}
                  className="aspect-video w-full"
                  title="Video preview"
                  allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share"
                  allowFullScreen
                />
              </div>
            )}
          </div>
        )}

        {fileError && (
          <div className="mt-4 rounded-xl border border-red-200 bg-red-50 px-4 py-3 text-sm text-red-700">
            {fileError}
          </div>
        )}
      </div>

      {uploadStatus.type !== 'idle' && (
        <div
          className={`rounded-xl border px-4 py-3 text-sm ${
            uploadStatus.type === 'success'
              ? 'border-green-200 bg-green-50 text-green-700'
              : uploadStatus.type === 'error'
                ? 'border-red-200 bg-red-50 text-red-700'
                : 'border-blue-200 bg-blue-50 text-blue-700'
          }`}
        >
          <div className="flex items-center gap-2">
            {uploadStatus.type === 'uploading' && <Loader2 className="h-4 w-4 animate-spin" />}
            {uploadStatus.type === 'success' && <CheckCircle2 className="h-4 w-4" />}
            {uploadStatus.type === 'error' && <XCircle className="h-4 w-4" />}
            <span>{uploadStatus.message}</span>
          </div>
        </div>
      )}

      <button
        type="submit"
        disabled={!canSubmit}
        className={`flex w-full items-center justify-center gap-2 rounded-xl px-4 py-3 text-sm font-semibold transition ${
          canSubmit
            ? 'bg-flehub-green text-white hover:bg-flehub-green/90'
            : 'cursor-not-allowed bg-gray-100 text-gray-400'
        }`}
      >
        {isUploading ? <Loader2 className="h-4 w-4 animate-spin" /> : <UploadCloud className="h-4 w-4" />}
        {isUploading ? 'Uploading lesson package...' : 'Upload lesson package'}
      </button>
    </form>
  );
}

function SelectedFileRow({
  resourceFile,
  progress,
  onRemove,
  disabled,
}: {
  resourceFile: SelectedResourceFile;
  progress?: FileUploadProgress;
  onRemove: () => void;
  disabled: boolean;
}) {
  const progressValue = progress?.progress ?? 0;

  return (
    <div className="rounded-xl border border-gray-200 bg-white p-3">
      <div className="flex items-center gap-3">
        {resourceFile.previewUrl ? (
          <img
            src={resourceFile.previewUrl}
            alt=""
            className="h-14 w-14 rounded-lg border border-gray-200 object-cover"
          />
        ) : (
          <div className="flex h-12 w-12 items-center justify-center rounded-lg bg-gray-100 text-gray-500">
            {resourceFile.type === 'pdf' ? <FileText className="h-5 w-5" /> : <FileAudio className="h-5 w-5" />}
          </div>
        )}

        <div className="min-w-0 flex-1">
          <p className="truncate text-sm font-medium text-gray-900">{resourceFile.file.name}</p>
          <p className="text-xs text-gray-500">{formatFileSize(resourceFile.file.size)}</p>
        </div>

        <button
          type="button"
          onClick={onRemove}
          disabled={disabled}
          className="rounded-lg p-2 text-gray-400 transition hover:bg-red-50 hover:text-red-600 disabled:cursor-not-allowed disabled:opacity-50"
          aria-label={`Remove ${resourceFile.file.name}`}
        >
          <Trash2 className="h-4 w-4" />
        </button>
      </div>

      {progress && (
        <div className="mt-3 space-y-1">
          <div className="flex items-center justify-between text-xs text-gray-500">
            <span className="capitalize">{progress.status}</span>
            <span>{progressValue}%</span>
          </div>
          <div className="h-2 overflow-hidden rounded-full bg-gray-100">
            <div
              className={`h-full rounded-full transition-all ${
                progress.status === 'error' ? 'bg-red-500' : 'bg-flehub-green'
              }`}
              style={{ width: `${progressValue}%` }}
            />
          </div>
          {progress.message && <p className="text-xs text-red-600">{progress.message}</p>}
        </div>
      )}
    </div>
  );
}
