export const ACCOUNT_STATUS = {
  PENDING_EMAIL: 'pending_email_confirmation',
  PENDING_ADMIN: 'pending_admin_validation',
  ACTIVE: 'active',
  REJECTED: 'rejected',
  SUSPENDED: 'suspended',
} as const

export type AccountStatus = (typeof ACCOUNT_STATUS)[keyof typeof ACCOUNT_STATUS]

export type LoginBlockTone = 'warning' | 'error'

export type LoginBlock = {
  tone: LoginBlockTone
  message: string
}

const EMAIL_NOT_CONFIRMED =
  'Merci de confirmer votre adresse email (lien envoyé à l\'inscription) avant de continuer.'

const AWAITING_ADMIN =
  'Votre email est confirmé. Votre compte est en cours de validation par notre équipe, vous recevrez un email dès son activation.'

/**
 * Accounts that may use the platform. Legacy `approved` is treated as active.
 *
 * TEMPORAIRE : validation admin non bloquante le temps de stabiliser le flux email.
 * Revenir à un blocage strict une fois la confirmation d'email validée en production
 * (le lien arrive, et le compte passe de pending_email_confirmation à
 * pending_admin_validation) : retirer ACCOUNT_STATUS.PENDING_ADMIN ci-dessous.
 * Le trigger qui fait ce passage, et la page /admin/validations, restent en place.
 */
export function isActiveAccountStatus(status: string | null | undefined): boolean {
  return (
    status === ACCOUNT_STATUS.ACTIVE ||
    status === 'approved' ||
    status === ACCOUNT_STATUS.PENDING_ADMIN
  )
}

export function loginBlockForStatus(
  status: string | null | undefined,
  rejectionReason?: string | null
): LoginBlock | null {
  if (isActiveAccountStatus(status)) return null

  if (status === ACCOUNT_STATUS.PENDING_EMAIL || status === 'email_not_confirmed') {
    return { tone: 'warning', message: EMAIL_NOT_CONFIRMED }
  }

  // Inatteignable pour pending_admin_validation tant que isActiveAccountStatus
  // le laisse entrer. Conservé pour le retour au blocage strict, et pour
  // l'ancien statut `pending`.
  if (status === ACCOUNT_STATUS.PENDING_ADMIN || status === 'pending') {
    return { tone: 'warning', message: AWAITING_ADMIN }
  }

  if (status === ACCOUNT_STATUS.REJECTED) {
    const reason = rejectionReason?.trim()
    return {
      tone: 'error',
      message: reason
        ? `Votre inscription a été refusée. Motif : ${reason}`
        : "Votre inscription a été refusée. Veuillez contacter l'administrateur.",
    }
  }

  if (status === ACCOUNT_STATUS.SUSPENDED) {
    return {
      tone: 'error',
      message: "Votre compte est inactif. Veuillez contacter l'administrateur.",
    }
  }

  return {
    tone: 'error',
    message: "Votre compte n'est pas actif. Veuillez contacter l'administrateur.",
  }
}
