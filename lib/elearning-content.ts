export type LessonContentType = 'youtube' | 'image' | 'text';

export const MEDIA_BUCKET = 'elearning-media';

/** Extract a YouTube video id from common URL formats. */
export function getYoutubeVideoId(url: string): string | null {
  const trimmed = url.trim();
  if (!trimmed) return null;

  try {
    const u = new URL(trimmed);
    const host = u.hostname.replace(/^www\./, '');

    if (host === 'youtu.be') {
      const id = u.pathname.split('/').filter(Boolean)[0];
      return id || null;
    }

    if (host === 'youtube.com' || host === 'm.youtube.com' || host === 'music.youtube.com') {
      if (u.pathname === '/watch') {
        return u.searchParams.get('v');
      }
      const parts = u.pathname.split('/').filter(Boolean);
      if (parts[0] === 'embed' || parts[0] === 'shorts' || parts[0] === 'live') {
        return parts[1] || null;
      }
    }
  } catch {
    // bare id
  }

  if (/^[a-zA-Z0-9_-]{11}$/.test(trimmed)) return trimmed;
  return null;
}

export function getYoutubeEmbedUrl(urlOrId: string): string | null {
  const id = getYoutubeVideoId(urlOrId);
  if (!id) return null;
  return `https://www.youtube.com/embed/${id}`;
}
