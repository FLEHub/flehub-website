/** Maps Supabase Auth / PostgREST errors to a user-facing French message. */

export const EMAIL_ALREADY_USED =
  'Cette adresse e-mail est déjà utilisée. Veuillez vous connecter ou réinitialiser votre mot de passe.'

export const ORPHAN_LOOKUP_FAILED =
  "Un compte existe déjà pour cette adresse, mais le profil n'a pas pu être créé automatiquement. Réessayez, ou contactez l'administrateur."

export function isAuthEmailTakenError(message: string): boolean {
  const msg = (message || '').toLowerCase()
  return (
    msg.includes('already registered') ||
    msg.includes('already been registered') ||
    msg.includes('user already exists') ||
    msg.includes('email_exists') ||
    msg.includes('identity already exists') ||
    msg.includes('user already registered')
  )
}

export function mapRegisterAuthError(message: string, status?: number | null): string {
  const msg = (message || '').toLowerCase()

  if (isAuthEmailTakenError(message)) {
    return EMAIL_ALREADY_USED
  }

  if (msg.includes('database error saving new user')) {
    return "L'enregistrement du profil a échoué. Veuillez réessayer."
  }

  if (
    status === 429 ||
    msg.includes('rate limit') ||
    msg.includes('over_email_send_rate_limit') ||
    msg.includes('too many requests')
  ) {
    return 'Trop de tentatives. Veuillez patienter quelques minutes avant de réessayer.'
  }

  if (msg.includes('password should be') || msg.includes('weak password')) {
    return 'Le mot de passe est trop faible. Utilisez au moins 8 caractères, avec des lettres et des chiffres.'
  }

  if (msg.includes('leaked') || msg.includes('pwned') || msg.includes('compromised')) {
    return 'Ce mot de passe a été exposé dans une fuite de données. Choisissez-en un autre.'
  }

  if (
    msg.includes('invalid email') ||
    msg.includes('unable to validate email') ||
    (msg.includes('email address') && msg.includes('invalid'))
  ) {
    return 'Veuillez saisir une adresse e-mail valide.'
  }

  if (msg.includes('signup is disabled') || msg.includes('signups not allowed')) {
    return "L'inscription est temporairement indisponible. Veuillez réessayer plus tard."
  }

  if (msg.includes('error sending') || msg.includes('confirmation email')) {
    return "Le compte a été créé mais l'e-mail de confirmation n'a pas pu être envoyé. Réessayez dans quelques minutes."
  }

  if (
    msg.includes('fetch failed') ||
    msg.includes('failed to fetch') ||
    msg.includes('network') ||
    msg.includes('authretryablefetch')
  ) {
    return 'Une erreur réseau est survenue. Veuillez vérifier votre connexion ou réessayer dans quelques instants.'
  }

  return message?.trim() || "L'inscription a échoué. Veuillez réessayer."
}

export function mapRegisterDbError(message: string, code?: string | null): string {
  const msg = (message || '').toLowerCase()
  const c = code ?? ''

  if (c === '23505' || msg.includes('duplicate key') || msg.includes('unique constraint')) {
    return EMAIL_ALREADY_USED
  }
  if (c === '23503' || msg.includes('foreign key')) {
    return "Impossible de créer le profil (référence invalide). Veuillez réessayer."
  }
  if (c === '23514' || msg.includes('check constraint')) {
    return 'Une valeur du formulaire est invalide. Vérifiez le rôle, le niveau CECRL et les champs obligatoires.'
  }
  if (msg.includes('row-level security') || msg.includes('rls') || c === '42501') {
    return "L'insertion du profil a été bloquée. Veuillez réessayer ou contacter l'administrateur."
  }

  return "L'enregistrement du profil a échoué. Veuillez réessayer."
}
