/** Découpe le texte d'une leçon MFK (Objectif / Consigne / Support / Fiche). */

export interface LessonSections {
  objectif: string;
  consigne: string;
  supportTitle: string;
  supportBody: string;
  ficheTitle: string;
  ficheBody: string;
}

const HEADER = /^(Objectif|Consigne|Support\b.*|Fiche\b.*)$/i;

export function parseLessonSections(content: string | null | undefined): LessonSections {
  const empty: LessonSections = {
    objectif: '',
    consigne: '',
    supportTitle: '',
    supportBody: '',
    ficheTitle: '',
    ficheBody: '',
  };
  if (!content?.trim()) return empty;

  const lines = content.replace(/\r\n/g, '\n').split('\n');
  let current: 'objectif' | 'consigne' | 'support' | 'fiche' | null = null;
  const buckets: Record<'objectif' | 'consigne' | 'support' | 'fiche', string[]> = {
    objectif: [],
    consigne: [],
    support: [],
    fiche: [],
  };
  let supportTitle = '';
  let ficheTitle = '';

  for (const raw of lines) {
    const line = raw.trimEnd();
    const trimmed = line.trim();
    if (HEADER.test(trimmed)) {
      if (/^Objectif$/i.test(trimmed)) {
        current = 'objectif';
        continue;
      }
      if (/^Consigne$/i.test(trimmed)) {
        current = 'consigne';
        continue;
      }
      if (/^Support\b/i.test(trimmed)) {
        current = 'support';
        supportTitle = trimmed.replace(/^Support\s*[—–-]\s*/i, '').trim() || trimmed;
        continue;
      }
      if (/^Fiche\b/i.test(trimmed)) {
        current = 'fiche';
        ficheTitle = trimmed.replace(/^Fiche\s*[—–-]\s*/i, '').trim() || trimmed;
        continue;
      }
    }
    if (current) buckets[current].push(line);
  }

  const join = (parts: string[]) => parts.join('\n').trim();
  return {
    objectif: join(buckets.objectif),
    consigne: join(buckets.consigne),
    supportTitle,
    supportBody: join(buckets.support),
    ficheTitle,
    ficheBody: join(buckets.fiche),
  };
}

export function firstSentences(text: string, max = 2): string {
  const compact = text.replace(/\s+/g, ' ').trim();
  if (!compact) return '';
  const parts = compact.split(/(?<=[.!?])\s+/).filter(Boolean);
  return parts.slice(0, max).join(' ').trim();
}

export function firstQuestions(text: string, max = 2): string[] {
  const compact = text.replace(/\s+/g, ' ').trim();
  if (!compact) return [];
  return compact
    .split(/(?<=\?)\s+/)
    .map((s) => s.trim())
    .filter((s) => s.endsWith('?'))
    .slice(0, max);
}

export function firstNonEmptyLines(text: string, max = 4, maxChars = 160): string[] {
  return text
    .split('\n')
    .map((l) => l.trim())
    .filter(Boolean)
    .slice(0, max)
    .map((l) => (l.length > maxChars ? `${l.slice(0, maxChars - 1)}…` : l));
}

/** Titres de sous-parties de fiche (1. … / tirets) pour le champ lexical. */
export function ficheHeadings(ficheBody: string, max = 6): string[] {
  const headings: string[] = [];
  for (const raw of ficheBody.split('\n')) {
    const line = raw.trim();
    const numbered = line.match(/^\d+[.)]\s+(.+)/);
    if (numbered?.[1]) {
      headings.push(numbered[1].replace(/\s+/g, ' ').trim());
    }
  }
  if (headings.length > 0) return headings.slice(0, max);
  return firstNonEmptyLines(ficheBody, max, 80);
}

export function extractGrammarPoint(elObjectif: string, elTitle: string): string {
  const src = elObjectif.replace(/\s+/g, ' ').trim();
  const patterns = [
    /point de langue\s*:\s*(.+)$/i,
    /Point\s*:\s*(.+)$/i,
    /^Fixer\s*:\s*(.+)$/i,
    /^Retenir\s+(.+)$/i,
    /^Maîtriser\s+(.+?)(?:\s+au registre|\.|$)/i,
  ];
  for (const re of patterns) {
    const m = src.match(re);
    if (m?.[1]) return m[1].replace(/\s+/g, ' ').trim();
  }
  if (src) return firstSentences(src, 1);
  const fromTitle = elTitle.replace(/^EL\s*[—–-]\s*/i, '').trim();
  return fromTitle || '—';
}

export function extractLexicalField(el: LessonSections, elTitle: string): string {
  const headings = ficheHeadings(el.ficheBody, 5);
  if (headings.length > 0) return headings.join(' · ');
  for (const raw of el.ficheBody.split('\n')) {
    const line = raw.trim();
    const col = line.match(/^Collocation\s*:\s*(.+)/i);
    if (col?.[1]) return col[1].replace(/\s+/g, ' ').trim();
  }
  const ficheLine = el.ficheBody
    .split('\n')
    .map((l) => l.trim())
    .find((l) => /^Fiche\b/i.test(l) && /[—–-]/.test(l));
  if (ficheLine) {
    return ficheLine.replace(/^Fiche(?:\s+C[12])?\s*[—–-]\s*/i, '').trim();
  }
  if (el.ficheTitle && !/^Fiche$/i.test(el.ficheTitle)) {
    return el.ficheTitle.replace(/^Fiche(?:\s+C[12])?\s*[—–-]\s*/i, '').trim();
  }
  const fromTitle = elTitle.replace(/^EL\s*[—–-]\s*/i, '').trim();
  return fromTitle || '—';
}
