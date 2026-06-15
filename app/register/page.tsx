'use client';

import { useRef, useState } from 'react';
import Link from 'next/link';
import { GraduationCap, BookOpen, Users, ArrowLeft, ArrowRight, CheckCircle, AlertCircle, Eye, EyeOff } from 'lucide-react';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import {
  MIN_BIO_LENGTH,
  MIN_QUALIFICATIONS_LENGTH,
} from '@/lib/register/validation';
import {
  getProvinces,
  getDistrictsByProvince,
  getSectorsByDistrict,
  getCellsBySector,
  getVillagesByCell,
} from 'rwanda-geo-structure';

type Role = 'learner' | 'teacher' | 'school';
type LearnerSubtype = 'independent' | 'pupil';
type CEFRLevel = 'A1' | 'A2' | 'B1' | 'B2' | 'C1' | 'C2';

interface FormData {
  // Common
  full_name: string;
  email: string;
  password: string;
  confirm_password: string;
  phone: string;
  // Learner
  subtype: LearnerSubtype;
  cefr_level: CEFRLevel | '';
  // Teacher
  bio: string;
  qualifications: string;
  // School
  school_name: string;
  school_type: 'primary' | 'secondary' | 'both' | '';
  director_name: string;
  address: string;
  province: string;
  district: string;
  sector: string;
  cell: string;
  village: string;
}

const cefrLevels: { value: CEFRLevel; label: string }[] = [
  { value: 'A1', label: 'A1 — Découverte' },
  { value: 'A2', label: 'A2 — Survie' },
  { value: 'B1', label: 'B1 — Seuil' },
  { value: 'B2', label: 'B2 — Avancé' },
  { value: 'C1', label: 'C1 — Autonome' },
  { value: 'C2', label: 'C2 — Maîtrise' },
];

const roleOptions = [
  {
    value: 'learner' as Role,
    icon: GraduationCap,
    title: 'Apprenant',
    description: 'Je souhaite apprendre le français et passer des examens de certification.',
  },
  {
    value: 'teacher' as Role,
    icon: BookOpen,
    title: 'Enseignant',
    description: 'Je souhaite créer des cours et encadrer des apprenants.',
  },
  {
    value: 'school' as Role,
    icon: Users,
    title: 'École',
    description: 'Je représente un établissement scolaire souhaitant inscrire ses élèves.',
  },
];

const initialFormData: FormData = {
  full_name: '',
  email: '',
  password: '',
  confirm_password: '',
  phone: '',
  subtype: 'independent',
  cefr_level: '',
  bio: '',
  qualifications: '',
  school_name: '',
  school_type: '',
  director_name: '',
  address: '',
  province: '',
  district: '',
  sector: '',
  cell: '',
  village: '',
};

export default function RegisterPage() {
  const [step, setStep] = useState<1 | 2>(1);
  const [selectedRole, setSelectedRole] = useState<Role | null>(null);
  const [formData, setFormData] = useState<FormData>(initialFormData);
  const [showPassword, setShowPassword] = useState(false);
  const [showConfirm, setShowConfirm] = useState(false);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [fieldErrors, setFieldErrors] = useState<Partial<Record<keyof FormData, string>>>({});
  const [success, setSuccess] = useState(false);
  const submittingRef = useRef(false);

  // Rwanda geo cascading state
  const [provinces] = useState<string[]>(getProvinces());
  const [districts, setDistricts] = useState<string[]>([]);
  const [sectors, setSectors] = useState<string[]>([]);
  const [cells, setCells] = useState<string[]>([]);
  const [villages, setVillages] = useState<string[]>([]);

  const update = (field: keyof FormData, value: string) => {
    setFormData((prev) => ({ ...prev, [field]: value }));
    setError(null);
    setFieldErrors((prev) => {
      if (!prev[field]) return prev;
      const next = { ...prev };
      delete next[field];
      return next;
    });
  };

  const handleProvince = (value: string) => {
    update('province', value);
    setDistricts(getDistrictsByProvince(value));
    update('district', '');
    setSectors([]);
    update('sector', '');
    setCells([]);
    update('cell', '');
    setVillages([]);
    update('village', '');
  };

  const handleDistrict = (value: string) => {
    update('district', value);
    setSectors(getSectorsByDistrict(formData.province, value));
    update('sector', '');
    setCells([]);
    update('cell', '');
    setVillages([]);
    update('village', '');
  };

  const handleSector = (value: string) => {
    update('sector', value);
    setCells(getCellsBySector(formData.province, formData.district, value));
    update('cell', '');
    setVillages([]);
    update('village', '');
  };

  const handleCell = (value: string) => {
    update('cell', value);
    setVillages(getVillagesByCell(formData.province, formData.district, formData.sector, value));
    update('village', '');
  };

  const handleRoleSelect = (role: Role) => {
    setSelectedRole(role);
    setError(null);
  };

  const validateStep1 = () => {
    if (!selectedRole) {
      setError('Veuillez sélectionner un rôle pour continuer.');
      return false;
    }
    return true;
  };

  const validateStep2 = (): string | null => {
    const nextFieldErrors: Partial<Record<keyof FormData, string>> = {};

    if (!formData.full_name.trim()) {
      nextFieldErrors.full_name = 'Le nom complet est requis.';
    }
    if (!formData.email.trim() || !/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(formData.email)) {
      nextFieldErrors.email = 'Veuillez saisir une adresse e-mail valide.';
    }
    if (formData.password.length < 8) {
      nextFieldErrors.password = 'Le mot de passe doit contenir au moins 8 caractères.';
    }
    if (formData.password !== formData.confirm_password) {
      nextFieldErrors.confirm_password = 'Les mots de passe ne correspondent pas.';
    }
    if (!formData.phone.trim()) {
      nextFieldErrors.phone = 'Le numéro de téléphone est requis.';
    }

    if (selectedRole === 'learner' && !formData.cefr_level) {
      nextFieldErrors.cefr_level = 'Veuillez sélectionner votre niveau CECRL.';
    }

    if (selectedRole === 'teacher') {
      if (!formData.bio.trim()) {
        nextFieldErrors.bio = 'La biographie est requise.';
      } else if (formData.bio.trim().length < MIN_BIO_LENGTH) {
        nextFieldErrors.bio = `La biographie doit contenir au moins ${MIN_BIO_LENGTH} caractères.`;
      }

      if (!formData.qualifications.trim()) {
        nextFieldErrors.qualifications = 'Les qualifications sont requises.';
      } else if (formData.qualifications.trim().length < MIN_QUALIFICATIONS_LENGTH) {
        nextFieldErrors.qualifications =
          'Veuillez préciser vos qualifications (diplômes, certifications, etc.).';
      }
    }

    if (selectedRole === 'school') {
      if (!formData.school_name.trim()) {
        nextFieldErrors.school_name = "Le nom de l'établissement est requis.";
      }
      if (!formData.school_type) nextFieldErrors.school_type = "Veuillez sélectionner le type d'établissement.";
      if (!formData.director_name.trim()) nextFieldErrors.director_name = 'Le nom du directeur est requis.';
      if (!formData.address.trim()) nextFieldErrors.address = "L'adresse de l'établissement est requise.";
      if (!formData.province) nextFieldErrors.province = 'Veuillez sélectionner une province.';
      if (!formData.district) nextFieldErrors.district = 'Veuillez sélectionner un district.';
      if (!formData.sector) nextFieldErrors.sector = 'Veuillez sélectionner un secteur.';
      if (!formData.cell) nextFieldErrors.cell = 'Veuillez sélectionner une cellule.';
      if (!formData.village) nextFieldErrors.village = 'Veuillez sélectionner un village.';
    }

    setFieldErrors(nextFieldErrors);

    const firstError = Object.values(nextFieldErrors)[0];
    return firstError ?? null;
  };

  const handleNext = () => {
    if (!validateStep1()) return;
    setStep(2);
  };

  const handleBack = () => {
    setStep(1);
    setError(null);
    setFieldErrors({});
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();

    if (loading || submittingRef.current) return;

    if (!selectedRole) {
      setError('Veuillez sélectionner un rôle pour continuer.');
      setStep(1);
      return;
    }

    const validationError = validateStep2();
    if (validationError) {
      setError(validationError);
      return;
    }

    submittingRef.current = true;
    setLoading(true);
    setError(null);

    try {
      const res = await fetch('/api/register', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          role: selectedRole,
          full_name: formData.full_name.trim(),
          email: formData.email.trim().toLowerCase(),
          password: formData.password,
          phone: formData.phone.trim(),
          subtype: formData.subtype,
          cefr_level: formData.cefr_level || undefined,
          bio: selectedRole === 'teacher' ? formData.bio.trim() : undefined,
          qualifications:
            selectedRole === 'teacher' ? formData.qualifications.trim() : undefined,
          school_name: formData.school_name.trim() || undefined,
          school_type: formData.school_type || undefined,
          director_name: formData.director_name.trim() || undefined,
          address: formData.address.trim() || undefined,
          province: formData.province || undefined,
          district: formData.district || undefined,
          sector: formData.sector || undefined,
          cell: formData.cell || undefined,
          village: formData.village || undefined,
        }),
      });

      let result: { error?: string; success?: boolean } = {};
      try {
        result = await res.json();
      } catch {
        setError("Réponse serveur invalide. Vérifiez que l'application est bien déployée.");
        return;
      }

      if (!res.ok) {
        setError(result.error ?? 'Une erreur est survenue.');
        return;
      }

      setSuccess(true);
    } catch {
      setError('Une erreur réseau est survenue. Veuillez vérifier votre connexion.');
    } finally {
      submittingRef.current = false;
      setLoading(false);
    }
  };

  // Success screen
  if (success) {
    const isPending = selectedRole === 'school' || selectedRole === 'teacher';
    return (
      <div className="min-h-screen flex items-center justify-center bg-gray-50 px-4">
        <div className="max-w-md w-full bg-white rounded-2xl shadow-sm border border-gray-100 p-8 text-center">
          <div className="w-16 h-16 bg-green-100 rounded-full flex items-center justify-center mx-auto mb-5">
            <CheckCircle className="w-9 h-9 text-flehub-green" />
          </div>
          <h2 className="text-2xl font-bold text-gray-900 mb-3">
            {isPending ? 'Inscription envoyée !' : 'Compte créé avec succès !'}
          </h2>
          <p className="text-gray-500 text-sm leading-relaxed mb-6">
            {isPending
              ? "Votre demande d'inscription a été reçue. Un administrateur examinera votre dossier et vous notifiera par e-mail dès que votre compte sera approuvé."
              : 'Votre compte apprenant a été créé et activé. Vous pouvez maintenant vous connecter et commencer votre apprentissage du français.'}
          </p>
          {!isPending && (
            <p className="text-xs text-gray-400 mb-6">
              Un e-mail de confirmation a été envoyé à{' '}
              <span className="font-medium text-gray-600">{formData.email}</span>. Veuillez
              vérifier votre boîte de réception.
            </p>
          )}
          <Link
            href="/login"
            className="block w-full py-3 bg-flehub-green text-white font-semibold rounded-xl hover:bg-flehub-green-dark transition-colors text-sm"
          >
            Aller à la page de connexion
          </Link>
          <Link
            href="/"
            className="block mt-3 text-sm text-gray-500 hover:text-flehub-green transition-colors"
          >
            Retour à l&apos;accueil
          </Link>
        </div>
      </div>
    );
  }

  return (
    <div className="min-h-screen flex">
      {/* Left Panel — Branding */}
      <div className="hidden lg:flex lg:w-[42%] gradient-hero flex-col items-center justify-center p-12 text-white relative overflow-hidden">
        {/* Background pattern */}
        <div className="absolute inset-0 opacity-10">
          <div
            className="absolute inset-0"
            style={{
              backgroundImage: 'radial-gradient(circle at 1px 1px, white 1px, transparent 0)',
              backgroundSize: '32px 32px',
            }}
          />
        </div>
        <div className="absolute top-0 right-0 w-72 h-72 rounded-full bg-white/5 -translate-y-16 translate-x-16" />
        <div className="absolute bottom-0 left-0 w-56 h-56 rounded-full bg-white/5 translate-y-12 -translate-x-12" />

        <div className="relative z-10 max-w-sm text-center">
          {/* Logo */}
          <div className="flex items-center justify-center gap-3 mb-10">
            <div className="w-14 h-14 bg-white/20 rounded-2xl flex items-center justify-center backdrop-blur-sm">
              <GraduationCap className="w-8 h-8 text-white" />
            </div>
            <span className="text-3xl font-extrabold">FLEHub</span>
          </div>

          <h2 className="text-3xl font-bold mb-4 leading-snug">
            Rejoignez la communauté FLEHub
          </h2>
          <p className="text-white/75 text-base leading-relaxed mb-10">
            Créez votre compte en quelques minutes et commencez votre parcours vers la maîtrise du français.
          </p>

          {/* Steps indicator */}
          <div className="space-y-3 text-left">
            {[
              { step: '1', title: 'Choisissez votre rôle', desc: 'Apprenant, enseignant ou école' },
              { step: '2', title: 'Renseignez vos informations', desc: 'Nom, e-mail, mot de passe' },
              { step: '3', title: "Commencez l'aventure", desc: 'Accédez à la plateforme' },
            ].map((item) => (
              <div key={item.step} className="flex items-start gap-3 bg-white/10 rounded-xl px-4 py-3 backdrop-blur-sm">
                <div className="w-7 h-7 bg-white/20 rounded-full flex items-center justify-center text-sm font-bold flex-shrink-0">
                  {item.step}
                </div>
                <div>
                  <div className="text-sm font-semibold">{item.title}</div>
                  <div className="text-xs text-white/65">{item.desc}</div>
                </div>
              </div>
            ))}
          </div>
        </div>
      </div>

      {/* Right Panel — Form */}
      <div className="flex-1 flex flex-col items-center justify-center px-6 py-10 bg-white overflow-y-auto">
        {/* Mobile logo */}
        <div className="lg:hidden flex items-center gap-2.5 mb-6">
          <div className="w-9 h-9 bg-flehub-green rounded-lg flex items-center justify-center">
            <GraduationCap className="w-5 h-5 text-white" />
          </div>
          <span className="text-xl font-bold text-gray-900">
            FLE<span className="text-flehub-green">Hub</span>
          </span>
        </div>

        <div className="w-full max-w-lg">
          {/* Header */}
          <div className="mb-6">
            <h1 className="text-2xl font-bold text-gray-900 mb-1">Créer un compte</h1>
            <p className="text-gray-500 text-sm">
              Déjà inscrit ?{' '}
              <Link href="/login" className="text-flehub-green font-semibold hover:underline">
                Se connecter
              </Link>
            </p>
          </div>

          {/* Step indicator */}
          <div className="flex items-center gap-3 mb-8">
            {[1, 2].map((s) => (
              <div key={s} className="flex items-center gap-3">
                <div
                  className={`flex items-center justify-center w-8 h-8 rounded-full text-sm font-bold transition-all ${
                    step === s
                      ? 'bg-flehub-green text-white shadow-sm shadow-green-200'
                      : s < step
                      ? 'bg-green-100 text-flehub-green'
                      : 'bg-gray-100 text-gray-400'
                  }`}
                >
                  {s < step ? <CheckCircle className="w-4 h-4" /> : s}
                </div>
                <span
                  className={`text-xs font-medium ${
                    step === s ? 'text-flehub-green' : s < step ? 'text-gray-500' : 'text-gray-400'
                  }`}
                >
                  {s === 1 ? 'Votre rôle' : 'Vos informations'}
                </span>
                {s < 2 && <div className={`h-px w-8 ${step > 1 ? 'bg-flehub-green' : 'bg-gray-200'}`} />}
              </div>
            ))}
          </div>

          {/* Error */}
          {error && (
            <div className="mb-5 bg-red-50 border border-red-200 rounded-xl p-4 flex gap-3">
              <AlertCircle className="w-5 h-5 text-red-500 flex-shrink-0 mt-0.5" />
              <p className="text-sm text-red-700">{error}</p>
            </div>
          )}

          {/* STEP 1 — Role Selection */}
          {step === 1 && (
            <div className="space-y-4">
              <p className="text-sm text-gray-600 font-medium mb-2">
                Quel est votre rôle sur la plateforme ?
              </p>
              {roleOptions.map((opt) => (
                <button
                  key={opt.value}
                  type="button"
                  onClick={() => handleRoleSelect(opt.value)}
                  className={`w-full flex items-start gap-4 p-4 rounded-2xl border-2 text-left transition-all ${
                    selectedRole === opt.value
                      ? 'border-flehub-green bg-flehub-green-light shadow-sm'
                      : 'border-gray-200 hover:border-gray-300 hover:bg-gray-50'
                  }`}
                >
                  <div
                    className={`w-11 h-11 rounded-xl flex items-center justify-center flex-shrink-0 ${
                      selectedRole === opt.value ? 'bg-flehub-green' : 'bg-gray-100'
                    }`}
                  >
                    <opt.icon
                      className={`w-5 h-5 ${
                        selectedRole === opt.value ? 'text-white' : 'text-gray-500'
                      }`}
                    />
                  </div>
                  <div className="flex-1 min-w-0">
                    <div className="flex items-center justify-between">
                      <span
                        className={`text-sm font-bold ${
                          selectedRole === opt.value ? 'text-flehub-green' : 'text-gray-900'
                        }`}
                      >
                        {opt.title}
                      </span>
                      {selectedRole === opt.value && (
                        <CheckCircle className="w-4 h-4 text-flehub-green flex-shrink-0" />
                      )}
                    </div>
                    <p className="text-xs text-gray-500 mt-0.5 leading-relaxed">{opt.description}</p>
                  </div>
                </button>
              ))}

              <button
                type="button"
                onClick={handleNext}
                disabled={!selectedRole}
                className="w-full mt-2 h-11 flex items-center justify-center gap-2 bg-flehub-green text-white font-semibold rounded-xl hover:bg-flehub-green-dark transition-colors disabled:opacity-50 disabled:cursor-not-allowed shadow-sm"
              >
                Continuer
                <ArrowRight className="w-4 h-4" />
              </button>
            </div>
          )}

          {/* STEP 2 — Details Form */}
          {step === 2 && (
            <form onSubmit={handleSubmit} className="space-y-5" noValidate>
              {/* Back button */}
              <button
                type="button"
                onClick={handleBack}
                className="flex items-center gap-1.5 text-sm text-gray-500 hover:text-flehub-green transition-colors mb-1"
              >
                <ArrowLeft className="w-4 h-4" />
                Modifier mon rôle
              </button>

              {/* Common fields */}
              <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
                <div className="sm:col-span-2 space-y-1.5">
                  <Label htmlFor="full_name" className="text-sm font-medium text-gray-700">
                    Nom complet <span className="text-red-500">*</span>
                  </Label>
                  <Input
                    id="full_name"
                    type="text"
                    autoComplete="name"
                    placeholder="Jean Dupont"
                    value={formData.full_name}
                    onChange={(e) => update('full_name', e.target.value)}
                    disabled={loading}
                    className="h-10 border-gray-300 focus:border-flehub-green rounded-xl"
                  />
                </div>

                <div className="sm:col-span-2 space-y-1.5">
                  <Label htmlFor="email" className="text-sm font-medium text-gray-700">
                    Adresse e-mail <span className="text-red-500">*</span>
                  </Label>
                  <Input
                    id="email"
                    type="email"
                    autoComplete="email"
                    placeholder="vous@exemple.com"
                    value={formData.email}
                    onChange={(e) => update('email', e.target.value)}
                    disabled={loading}
                    className="h-10 border-gray-300 focus:border-flehub-green rounded-xl"
                  />
                </div>

                <div className="space-y-1.5">
                  <Label htmlFor="password" className="text-sm font-medium text-gray-700">
                    Mot de passe <span className="text-red-500">*</span>
                  </Label>
                  <div className="relative">
                    <Input
                      id="password"
                      type={showPassword ? 'text' : 'password'}
                      autoComplete="new-password"
                      placeholder="Min. 8 caractères"
                      value={formData.password}
                      onChange={(e) => update('password', e.target.value)}
                      disabled={loading}
                      className="h-10 pr-10 border-gray-300 focus:border-flehub-green rounded-xl"
                    />
                    <button
                      type="button"
                      onClick={() => setShowPassword(!showPassword)}
                      className="absolute right-3 top-1/2 -translate-y-1/2 text-gray-400 hover:text-gray-600"
                      tabIndex={-1}
                    >
                      {showPassword ? <EyeOff className="w-4 h-4" /> : <Eye className="w-4 h-4" />}
                    </button>
                  </div>
                </div>

                <div className="space-y-1.5">
                  <Label htmlFor="confirm_password" className="text-sm font-medium text-gray-700">
                    Confirmer <span className="text-red-500">*</span>
                  </Label>
                  <div className="relative">
                    <Input
                      id="confirm_password"
                      type={showConfirm ? 'text' : 'password'}
                      autoComplete="new-password"
                      placeholder="Répéter le mot de passe"
                      value={formData.confirm_password}
                      onChange={(e) => update('confirm_password', e.target.value)}
                      disabled={loading}
                      className="h-10 pr-10 border-gray-300 focus:border-flehub-green rounded-xl"
                    />
                    <button
                      type="button"
                      onClick={() => setShowConfirm(!showConfirm)}
                      className="absolute right-3 top-1/2 -translate-y-1/2 text-gray-400 hover:text-gray-600"
                      tabIndex={-1}
                    >
                      {showConfirm ? <EyeOff className="w-4 h-4" /> : <Eye className="w-4 h-4" />}
                    </button>
                  </div>
                </div>

                <div className="sm:col-span-2 space-y-1.5">
                  <Label htmlFor="phone" className="text-sm font-medium text-gray-700">
                    Téléphone <span className="text-red-500">*</span>
                  </Label>
                  <Input
                    id="phone"
                    type="tel"
                    autoComplete="tel"
                    placeholder="+250 780 000 000"
                    value={formData.phone}
                    onChange={(e) => update('phone', e.target.value)}
                    disabled={loading}
                    className="h-10 border-gray-300 focus:border-flehub-green rounded-xl"
                  />
                </div>
              </div>

              {/* ---- Learner-specific fields ---- */}
              {selectedRole === 'learner' && (
                <div className="border-t border-gray-100 pt-5 space-y-4">
                  <p className="text-xs font-semibold text-gray-500 uppercase tracking-wider">
                    Informations apprenant
                  </p>

                  <div className="space-y-1.5">
                    <Label className="text-sm font-medium text-gray-700">
                      Type d&apos;apprenant <span className="text-red-500">*</span>
                    </Label>
                    <div className="grid grid-cols-2 gap-3">
                      {[
                        { value: 'independent' as LearnerSubtype, label: 'Indépendant', desc: 'Apprentissage personnel' },
                        { value: 'pupil' as LearnerSubtype, label: 'Élève', desc: 'Inscrit dans un établissement' },
                      ].map((opt) => (
                        <button
                          key={opt.value}
                          type="button"
                          onClick={() => update('subtype', opt.value)}
                          className={`p-3 rounded-xl border-2 text-left transition-all ${
                            formData.subtype === opt.value
                              ? 'border-flehub-green bg-flehub-green-light'
                              : 'border-gray-200 hover:border-gray-300'
                          }`}
                        >
                          <div
                            className={`text-sm font-semibold ${
                              formData.subtype === opt.value ? 'text-flehub-green' : 'text-gray-700'
                            }`}
                          >
                            {opt.label}
                          </div>
                          <div className="text-xs text-gray-500 mt-0.5">{opt.desc}</div>
                        </button>
                      ))}
                    </div>
                  </div>

                  <div className="space-y-1.5">
                    <Label htmlFor="cefr_level" className="text-sm font-medium text-gray-700">
                      Niveau CECRL souhaité <span className="text-red-500">*</span>
                    </Label>
                    <select
                      id="cefr_level"
                      value={formData.cefr_level}
                      onChange={(e) => update('cefr_level', e.target.value)}
                      disabled={loading}
                      className="w-full h-10 px-3 rounded-xl border border-gray-300 text-sm text-gray-900 bg-white focus:outline-none focus:border-flehub-green focus:ring-2 focus:ring-flehub-green/20"
                    >
                      <option value="">Sélectionner un niveau</option>
                      {cefrLevels.map((lvl) => (
                        <option key={lvl.value} value={lvl.value}>
                          {lvl.label}
                        </option>
                      ))}
                    </select>
                  </div>
                </div>
              )}

              {/* ---- Teacher-specific fields ---- */}
              {selectedRole === 'teacher' && (
                <div className="border-t border-gray-100 pt-5 space-y-4">
                  <p className="text-xs font-semibold text-gray-500 uppercase tracking-wider">
                    Informations enseignant
                  </p>

                  <div className="space-y-1.5">
                    <Label htmlFor="bio" className="text-sm font-medium text-gray-700">
                      Biographie <span className="text-red-500">*</span>
                    </Label>
                    <textarea
                      id="bio"
                      rows={3}
                      required
                      minLength={MIN_BIO_LENGTH}
                      placeholder="Décrivez brièvement votre expérience en enseignement du français…"
                      value={formData.bio}
                      onChange={(e) => update('bio', e.target.value)}
                      disabled={loading}
                      aria-invalid={Boolean(fieldErrors.bio)}
                      className={`w-full px-3 py-2.5 rounded-xl border text-sm text-gray-900 bg-white focus:outline-none focus:ring-2 focus:ring-flehub-green/20 resize-none ${
                        fieldErrors.bio
                          ? 'border-red-400 focus:border-red-400'
                          : 'border-gray-300 focus:border-flehub-green'
                      }`}
                    />
                    <p className="text-xs text-gray-400">
                      Minimum {MIN_BIO_LENGTH} caractères ({formData.bio.trim().length}/{MIN_BIO_LENGTH})
                    </p>
                    {fieldErrors.bio && (
                      <p className="text-xs text-red-600">{fieldErrors.bio}</p>
                    )}
                  </div>

                  <div className="space-y-1.5">
                    <Label htmlFor="qualifications" className="text-sm font-medium text-gray-700">
                      Qualifications <span className="text-red-500">*</span>
                    </Label>
                    <Input
                      id="qualifications"
                      type="text"
                      required
                      minLength={MIN_QUALIFICATIONS_LENGTH}
                      placeholder="Ex: DALF C2, Master FLE, CAPES…"
                      value={formData.qualifications}
                      onChange={(e) => update('qualifications', e.target.value)}
                      disabled={loading}
                      aria-invalid={Boolean(fieldErrors.qualifications)}
                      className={`h-10 rounded-xl ${
                        fieldErrors.qualifications
                          ? 'border-red-400 focus:border-red-400'
                          : 'border-gray-300 focus:border-flehub-green'
                      }`}
                    />
                    {fieldErrors.qualifications && (
                      <p className="text-xs text-red-600">{fieldErrors.qualifications}</p>
                    )}
                    <p className="text-xs text-gray-400">
                      Votre compte sera examiné par un administrateur avant activation.
                    </p>
                  </div>
                </div>
              )}

              {/* ---- School-specific fields ---- */}
              {selectedRole === 'school' && (
                <div className="border-t border-gray-100 pt-5 space-y-4">
                  <p className="text-xs font-semibold text-gray-500 uppercase tracking-wider">
                    Informations établissement
                  </p>

                  <div className="space-y-1.5">
                    <Label htmlFor="school_name" className="text-sm font-medium text-gray-700">
                      Nom de l&apos;établissement <span className="text-red-500">*</span>
                    </Label>
                    <Input
                      id="school_name"
                      type="text"
                      placeholder="Ex: Lycée de l'Excellence de Butare"
                      value={formData.school_name}
                      onChange={(e) => update('school_name', e.target.value)}
                      disabled={loading}
                      className="h-10 border-gray-300 focus:border-flehub-green rounded-xl"
                    />
                  </div>

                  <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
                    <div className="space-y-1.5">
                      <Label htmlFor="school_type" className="text-sm font-medium text-gray-700">
                        Type <span className="text-red-500">*</span>
                      </Label>
                      <select
                        id="school_type"
                        value={formData.school_type}
                        onChange={(e) => update('school_type', e.target.value)}
                        disabled={loading}
                        className="w-full h-10 px-3 rounded-xl border border-gray-300 text-sm text-gray-900 bg-white focus:outline-none focus:border-flehub-green focus:ring-2 focus:ring-flehub-green/20"
                      >
                        <option value="">Sélectionner</option>
                        <option value="primary">Primaire</option>
                        <option value="secondary">Secondaire</option>
                        <option value="both">Primaire et secondaire</option>
                      </select>
                      {fieldErrors.school_type && (
                        <p className="text-xs text-red-600">{fieldErrors.school_type}</p>
                      )}
                    </div>

                    <div className="space-y-1.5">
                      <Label htmlFor="director_name" className="text-sm font-medium text-gray-700">
                        Directeur <span className="text-red-500">*</span>
                      </Label>
                      <Input
                        id="director_name"
                        type="text"
                        placeholder="Nom complet du directeur"
                        value={formData.director_name}
                        onChange={(e) => update('director_name', e.target.value)}
                        disabled={loading}
                        className="h-10 border-gray-300 focus:border-flehub-green rounded-xl"
                      />
                      {fieldErrors.director_name && (
                        <p className="text-xs text-red-600">{fieldErrors.director_name}</p>
                      )}
                    </div>
                  </div>

                  <div className="space-y-1.5">
                    <Label htmlFor="address" className="text-sm font-medium text-gray-700">
                      Adresse officielle <span className="text-red-500">*</span>
                    </Label>
                    <Input
                      id="address"
                      type="text"
                      placeholder="Adresse physique de l'établissement"
                      value={formData.address}
                      onChange={(e) => update('address', e.target.value)}
                      disabled={loading}
                      className="h-10 border-gray-300 focus:border-flehub-green rounded-xl"
                    />
                    {fieldErrors.address && (
                      <p className="text-xs text-red-600">{fieldErrors.address}</p>
                    )}
                  </div>

                  {/* Province */}
                  <div className="space-y-1.5">
                    <Label htmlFor="province" className="text-sm font-medium text-gray-700">
                      Province <span className="text-red-500">*</span>
                    </Label>
                    <select
                      id="province"
                      value={formData.province}
                      onChange={(e) => handleProvince(e.target.value)}
                      disabled={loading}
                      className="w-full h-10 px-3 rounded-xl border border-gray-300 text-sm text-gray-900 bg-white focus:outline-none focus:border-flehub-green focus:ring-2 focus:ring-flehub-green/20"
                    >
                      <option value="">Sélectionner une province</option>
                      {provinces.map((p) => (
                        <option key={p} value={p}>{p}</option>
                      ))}
                    </select>
                  </div>

                  {/* District */}
                  <div className="space-y-1.5">
                    <Label htmlFor="district" className="text-sm font-medium text-gray-700">
                      District <span className="text-red-500">*</span>
                    </Label>
                    <select
                      id="district"
                      value={formData.district}
                      onChange={(e) => handleDistrict(e.target.value)}
                      disabled={loading || !formData.province}
                      className="w-full h-10 px-3 rounded-xl border border-gray-300 text-sm text-gray-900 bg-white focus:outline-none focus:border-flehub-green focus:ring-2 focus:ring-flehub-green/20 disabled:bg-gray-50 disabled:text-gray-400"
                    >
                      <option value="">Sélectionner un district</option>
                      {districts.map((d) => (
                        <option key={d} value={d}>{d}</option>
                      ))}
                    </select>
                  </div>

                  {/* Secteur / Umurenge */}
                  <div className="space-y-1.5">
                    <Label htmlFor="sector" className="text-sm font-medium text-gray-700">
                      Secteur (Umurenge) <span className="text-red-500">*</span>
                    </Label>
                    <select
                      id="sector"
                      value={formData.sector}
                      onChange={(e) => handleSector(e.target.value)}
                      disabled={loading || !formData.district}
                      className="w-full h-10 px-3 rounded-xl border border-gray-300 text-sm text-gray-900 bg-white focus:outline-none focus:border-flehub-green focus:ring-2 focus:ring-flehub-green/20 disabled:bg-gray-50 disabled:text-gray-400"
                    >
                      <option value="">Sélectionner un secteur</option>
                      {sectors.map((s) => (
                        <option key={s} value={s}>{s}</option>
                      ))}
                    </select>
                  </div>

                  {/* Cellule / Akagari */}
                  <div className="space-y-1.5">
                    <Label htmlFor="cell" className="text-sm font-medium text-gray-700">
                      Cellule (Akagari) <span className="text-red-500">*</span>
                    </Label>
                    <select
                      id="cell"
                      value={formData.cell}
                      onChange={(e) => handleCell(e.target.value)}
                      disabled={loading || !formData.sector}
                      className="w-full h-10 px-3 rounded-xl border border-gray-300 text-sm text-gray-900 bg-white focus:outline-none focus:border-flehub-green focus:ring-2 focus:ring-flehub-green/20 disabled:bg-gray-50 disabled:text-gray-400"
                    >
                      <option value="">Sélectionner une cellule</option>
                      {cells.map((c) => (
                        <option key={c} value={c}>{c}</option>
                      ))}
                    </select>
                  </div>

                  {/* Village / Umudugudu */}
                  <div className="space-y-1.5">
                    <Label htmlFor="village" className="text-sm font-medium text-gray-700">
                      Village (Umudugudu) <span className="text-red-500">*</span>
                    </Label>
                    <select
                      id="village"
                      value={formData.village}
                      onChange={(e) => update('village', e.target.value)}
                      disabled={loading || !formData.cell}
                      className="w-full h-10 px-3 rounded-xl border border-gray-300 text-sm text-gray-900 bg-white focus:outline-none focus:border-flehub-green focus:ring-2 focus:ring-flehub-green/20 disabled:bg-gray-50 disabled:text-gray-400"
                    >
                      <option value="">Sélectionner un village</option>
                      {villages.map((v) => (
                        <option key={v} value={v}>{v}</option>
                      ))}
                    </select>
                  </div>

                  <p className="text-xs text-gray-400">
                    Votre compte école sera examiné par un administrateur avant activation.
                  </p>
                </div>
              )}

              {/* Submit */}
              <button
                type="submit"
                disabled={loading}
                aria-busy={loading}
                className="w-full h-11 flex items-center justify-center gap-2 bg-flehub-green text-white font-semibold rounded-xl hover:bg-flehub-green-dark transition-colors disabled:opacity-60 disabled:cursor-not-allowed shadow-sm mt-2"
              >
                {loading ? (
                  <>
                    <svg
                      className="animate-spin w-4 h-4 text-white"
                      xmlns="http://www.w3.org/2000/svg"
                      fill="none"
                      viewBox="0 0 24 24"
                    >
                      <circle className="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" strokeWidth="4" />
                      <path
                        className="opacity-75"
                        fill="currentColor"
                        d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4z"
                      />
                    </svg>
                    Création du compte…
                  </>
                ) : (
                  <>
                    Créer mon compte
                    <ArrowRight className="w-4 h-4" />
                  </>
                )}
              </button>

              <p className="text-center text-xs text-gray-400 mt-2">
                En vous inscrivant, vous acceptez nos{' '}
                <a href="#" className="text-flehub-green hover:underline">
                  Conditions d&apos;utilisation
                </a>{' '}
                et notre{' '}
                <a href="#" className="text-flehub-green hover:underline">
                  Politique de confidentialité
                </a>
                .
              </p>
            </form>
          )}
        </div>
      </div>
    </div>
  );
}
