export const DEFAULT_ORG_SHORT_NAME = 'MFK'
export const DEFAULT_ORG_TAGLINE = 'Maison de la Francophonie Kigali'
export const DEFAULT_ORG_NAME = 'MFK'

export interface OrgBranding {
  orgName: string
  orgShortName: string
  orgTagline: string
}

export function normalizeOrgBranding(row?: {
  org_name?: string | null
  org_short_name?: string | null
  org_tagline?: string | null
} | null): OrgBranding {
  const orgShortName =
    row?.org_short_name?.trim() || DEFAULT_ORG_SHORT_NAME
  const orgTagline = row?.org_tagline?.trim() || DEFAULT_ORG_TAGLINE
  const orgName = row?.org_name?.trim() || orgShortName || DEFAULT_ORG_NAME
  return { orgName, orgShortName, orgTagline }
}

export function adminOrgLabel(shortName: string): string {
  return `Administration ${shortName.trim() || DEFAULT_ORG_SHORT_NAME}`
}
