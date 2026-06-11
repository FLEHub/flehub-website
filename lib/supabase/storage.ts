import { createServiceClient } from '@/lib/supabase/service'

export const BUCKET_NAME = 'flehub-resources'

const RESOURCE_BUCKET_OPTIONS = {
  public: false,
  fileSizeLimit: 524288000,
  allowedMimeTypes: [
    'video/mp4',
    'video/webm',
    'application/pdf',
    'audio/mpeg',
    'audio/mp3',
    'audio/wav',
    'audio/ogg',
    'image/jpeg',
    'image/png',
    'image/webp',
  ],
}

export async function ensureResourcesBucket(): Promise<void> {
  const supabase = createServiceClient()
  const { data: buckets, error: listError } = await supabase.storage.listBuckets()

  if (listError) {
    throw listError
  }

  if (buckets?.some((bucket) => bucket.name === BUCKET_NAME)) {
    return
  }

  const { error: createError } = await supabase.storage.createBucket(
    BUCKET_NAME,
    RESOURCE_BUCKET_OPTIONS
  )

  if (createError) {
    throw createError
  }
}

export function getResourceStoragePath(teacherId: string, fileName: string): string {
  return `${teacherId}/${crypto.randomUUID()}-${fileName}`
}

export async function getSignedUrl(filePath: string, expiresIn = 60): Promise<string> {
  const supabase = createServiceClient()
  const { data, error } = await supabase.storage
    .from(BUCKET_NAME)
    .createSignedUrl(filePath, expiresIn)

  if (error) {
    throw error
  }

  if (!data?.signedUrl) {
    throw new Error('Failed to create signed URL for resource')
  }

  return data.signedUrl
}
