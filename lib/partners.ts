export const PARTNER_LOGOS_BUCKET = 'partner-logos'

export const PARTNER_LOGO_ACCEPT =
  'image/png,image/jpeg,image/jpg,image/webp,image/svg+xml,image/gif,.png,.jpg,.jpeg,.webp,.svg,.gif'

export type Partner = {
  id: string
  name: string
  logo_url: string
  website_url: string | null
  sort_order: number
  created_at: string
  updated_at?: string
}

/** Normalize optional website URL (adds https:// if missing a scheme). */
export function normalizeWebsiteUrl(raw: string | null | undefined): string | null {
  const value = (raw ?? '').trim()
  if (!value) return null
  if (/^https?:\/\//i.test(value)) return value
  return `https://${value}`
}
