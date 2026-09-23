/** Public site origin used in auth redirects and transactional emails. */
export function publicSiteUrl(): string {
  const configured = process.env.NEXT_PUBLIC_SITE_URL?.trim()
  const url = configured && configured.length > 0 ? configured : 'https://mfkigali.com'
  return url.replace(/\/$/, '')
}

export function authConfirmedUrl(): string {
  return `${publicSiteUrl()}/auth/confirmed`
}
