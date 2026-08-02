import { redirect } from 'next/navigation'

/**
 * Entry point for the e-learning application ("MFK App").
 * Keeps /dashboard URLs stable (bookmarks, shared links) while offering /app as the branded gateway.
 */
export default function MfkAppEntryPage() {
  redirect('/dashboard')
}
