export type RegisterRole = 'learner' | 'teacher' | 'school';

export type RegisterPayload = {
  role: RegisterRole;
  full_name: string;
  email: string;
  password: string;
  phone: string;
  subtype?: 'independent' | 'pupil';
  cefr_level?: string;
  bio?: string;
  qualifications?: string;
  school_name?: string;
  province?: string;
  district?: string;
  sector?: string;
  cell?: string;
  village?: string;
};

const MIN_BIO_LENGTH = 20;
const MIN_QUALIFICATIONS_LENGTH = 3;

export function validateRegisterPayload(payload: RegisterPayload): string | null {
  if (!payload.full_name?.trim()) {
    return 'Le nom complet est requis.';
  }

  if (!payload.email?.trim() || !/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(payload.email)) {
    return 'Veuillez saisir une adresse e-mail valide.';
  }

  if (!payload.password || payload.password.length < 8) {
    return 'Le mot de passe doit contenir au moins 8 caractères.';
  }

  if (!payload.phone?.trim()) {
    return 'Le numéro de téléphone est requis.';
  }

  if (!payload.role || !['learner', 'teacher', 'school'].includes(payload.role)) {
    return 'Veuillez sélectionner un rôle valide.';
  }

  if (payload.role === 'learner') {
    if (!payload.cefr_level) {
      return 'Veuillez sélectionner votre niveau CECRL.';
    }
  }

  if (payload.role === 'teacher') {
    if (!payload.bio?.trim()) {
      return 'La biographie est requise.';
    }
    if (payload.bio.trim().length < MIN_BIO_LENGTH) {
      return `La biographie doit contenir au moins ${MIN_BIO_LENGTH} caractères.`;
    }
    if (!payload.qualifications?.trim()) {
      return 'Les qualifications sont requises.';
    }
    if (payload.qualifications.trim().length < MIN_QUALIFICATIONS_LENGTH) {
      return 'Veuillez préciser vos qualifications (diplômes, certifications, etc.).';
    }
  }

  if (payload.role === 'school') {
    if (!payload.school_name?.trim()) {
      return "Le nom de l'établissement est requis.";
    }
    if (!payload.province) return 'Veuillez sélectionner une province.';
    if (!payload.district) return 'Veuillez sélectionner un district.';
    if (!payload.sector) return 'Veuillez sélectionner un secteur.';
    if (!payload.cell) return 'Veuillez sélectionner une cellule.';
    if (!payload.village) return 'Veuillez sélectionner un village.';
  }

  return null;
}

export function mapRegisterError(message: string): string {
  const normalized = message.toLowerCase();

  if (
    normalized.includes('rate limit') ||
    normalized.includes('email rate limit exceeded') ||
    normalized.includes('too many requests')
  ) {
    return 'Trop de tentatives d\'inscription. Veuillez patienter 15 minutes avant de réessayer, ou contactez le support si le problème persiste.';
  }

  if (
    normalized.includes('already registered') ||
    normalized.includes('already been registered') ||
    normalized.includes('user already registered') ||
    normalized.includes('duplicate key') ||
    normalized.includes('already exists')
  ) {
    return 'Cette adresse e-mail est déjà utilisée. Veuillez vous connecter.';
  }

  if (normalized.includes('service role') || normalized.includes('supabase service')) {
    return "Configuration serveur incomplète. Veuillez contacter l'administrateur.";
  }

  if (
    normalized.includes('fetch failed') ||
    normalized.includes('network') ||
    normalized.includes('unable to verify')
  ) {
    return 'Impossible de contacter le serveur d\'authentification. Vérifiez votre connexion et réessayez.';
  }

  if (normalized.includes('password')) {
    return 'Le mot de passe ne respecte pas les critères de sécurité. Utilisez au moins 8 caractères.';
  }

  if (normalized.includes('invalid email')) {
    return 'Veuillez saisir une adresse e-mail valide.';
  }

  return 'Une erreur est survenue lors de l\'inscription. Veuillez réessayer dans quelques instants.';
}

export { MIN_BIO_LENGTH, MIN_QUALIFICATIONS_LENGTH };
