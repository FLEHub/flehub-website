const PRODUCTION_SITE_URL = 'https://mfkigali.com'

function isLoopbackSiteUrl(url: string): boolean {
  return url.includes('localhost') || url.includes('127.0.0.1')
}

/** Public site origin used in auth redirects and transactional emails. */
export function publicSiteUrl(): string {
  const configured = process.env.NEXT_PUBLIC_SITE_URL?.trim() ?? ''
  const ignoreLoopback =
    process.env.NODE_ENV === 'production' && isLoopbackSiteUrl(configured)

  if (ignoreLoopback) {
    console.error(
      '[site-url] NEXT_PUBLIC_SITE_URL points at localhost in production; using https://mfkigali.com'
    )
  }

  const url =
    configured.length > 0 && !ignoreLoopback ? configured : PRODUCTION_SITE_URL
  return url.replace(/\/$/, '')
}

/** Page shown after the address is confirmed. The account still waits for an admin. */
export function authConfirmedUrl(): string {
  return `${publicSiteUrl()}/auth/confirmed`
}

/**
 * Absolute URL on the public site. In production the request host is ignored,
 * so a proxy that reports localhost cannot send the visitor there.
 */
export function appUrl(path: string, requestOrigin: string): URL {
  const base = process.env.NODE_ENV === 'production' ? publicSiteUrl() : requestOrigin
  return new URL(path, base)
}
