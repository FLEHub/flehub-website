'use client';

import { useState } from 'react';
import Link from 'next/link';
import {
  GraduationCap,
  BookOpen,
  Users,
  Shield,
  Smartphone,
  Video,
  Award,
  ChevronRight,
  Menu,
  X,
  Star,
  CheckCircle,
  Globe,
  BarChart3,
  Clock,
  Zap,
} from 'lucide-react';

const cefrLevels = [
  {
    level: 'A1',
    name: 'Découverte',
    color: 'bg-emerald-50 border-emerald-200',
    badge: 'bg-emerald-100 text-emerald-700',
    description: 'Compétences de base pour communiquer en français dans des situations simples du quotidien.',
    skills: ['Salutations', 'Présentations', 'Chiffres & couleurs'],
  },
  {
    level: 'A2',
    name: 'Survie',
    color: 'bg-teal-50 border-teal-200',
    badge: 'bg-teal-100 text-teal-700',
    description: 'Échanges simples sur des sujets familiers comme la famille, les achats et le travail.',
    skills: ['Vie quotidienne', 'Achats', 'Transports'],
  },
  {
    level: 'B1',
    name: 'Seuil',
    color: 'bg-green-50 border-green-200',
    badge: 'bg-green-100 text-green-700',
    description: 'Compréhension des points essentiels sur des sujets concrets ou abstraits.',
    skills: ['Voyage', 'Travail', 'Opinions'],
  },
  {
    level: 'B2',
    name: 'Avancé',
    color: 'bg-lime-50 border-lime-200',
    badge: 'bg-lime-100 text-lime-700',
    description: 'Interaction avec des locuteurs natifs avec aisance et spontanéité.',
    skills: ['Débats', 'Rédaction', 'Littérature'],
  },
  {
    level: 'C1',
    name: 'Autonome',
    color: 'bg-yellow-50 border-yellow-200',
    badge: 'bg-yellow-100 text-yellow-700',
    description: 'Expression fluide et spontanée sans chercher ses mots de manière apparente.',
    skills: ['Académique', 'Professionnel', 'Nuances'],
  },
  {
    level: 'C2',
    name: 'Maîtrise',
    color: 'bg-orange-50 border-orange-200',
    badge: 'bg-orange-100 text-orange-700',
    description: 'Compréhension aisée de pratiquement tout ce qui est lu ou entendu.',
    skills: ['Précision', 'Éloquence', 'Culture'],
  },
];

const features = [
  {
    icon: BookOpen,
    title: 'Cours Interactifs',
    description:
      'Contenus multimédias riches, exercices adaptatifs et retours instantanés pour un apprentissage engageant à chaque niveau CECRL.',
  },
  {
    icon: Award,
    title: 'Certifications Officielles',
    description:
      'Examens structurés selon les normes CECRL avec résultats vérifiables et certificats reconnus par les institutions rwandaises.',
  },
  {
    icon: Video,
    title: 'Sessions Live',
    description:
      'Classes virtuelles en direct avec les enseignants, enregistrements disponibles et système de questions-réponses intégré.',
  },
  {
    icon: Users,
    title: 'Multi-Rôles',
    description:
      'Plateforme unifiée pour les apprenants, enseignants, écoles et administrateurs avec des tableaux de bord dédiés.',
  },
  {
    icon: Smartphone,
    title: 'Mobile Money',
    description:
      "Paiement des frais d'examen directement via MTN Mobile Money et Airtel Money — simple, rapide, sécurisé.",
  },
  {
    icon: Shield,
    title: 'Sécurité Renforcée',
    description:
      "Architecture sécurisée avec Row Level Security, authentification robuste et protection des données conformes aux normes.",
  },
];

const roles = [
  {
    icon: GraduationCap,
    title: 'Apprenant',
    description:
      'Accédez à vos cours, suivez votre progression et inscrivez-vous aux examens selon votre niveau.',
    features: ['Tableau de bord personnel', 'Suivi de progression', 'Accès aux examens', 'Certificats en ligne'],
    cta: 'Commencer gratuitement',
    href: '/register',
  },
  {
    icon: BookOpen,
    title: 'Enseignant',
    description:
      'Gérez vos classes, créez du contenu pédagogique et suivez les performances de vos étudiants.',
    features: ['Gestion de classes', 'Création de contenus', 'Suivi des étudiants', 'Sessions live'],
    cta: 'Rejoindre comme enseignant',
    href: '/register',
  },
  {
    icon: Users,
    title: 'École',
    description:
      "Inscrivez vos élèves en masse, gérez les paiements et obtenez des rapports détaillés sur l'établissement.",
    features: ["Inscription en masse", 'Gestion des paiements', 'Rapports détaillés', 'Tableau de bord école'],
    cta: 'Inscrire mon école',
    href: '/register',
  },
  {
    icon: BarChart3,
    title: 'Administrateur',
    description:
      "Supervisez l'ensemble de la plateforme, approuvez les utilisateurs et gérez les paramètres système.",
    features: ["Vue d'ensemble totale", 'Approbation des comptes', 'Statistiques avancées', 'Gestion des niveaux'],
    cta: 'Accès administrateur',
    href: '/login',
  },
];

const pricing = [
  { level: 'A1', name: 'Découverte', price: '25 000', popular: false },
  { level: 'A2', name: 'Survie', price: '30 000', popular: false },
  { level: 'B1', name: 'Seuil', price: '40 000', popular: true },
  { level: 'B2', name: 'Avancé', price: '50 000', popular: false },
  { level: 'C1', name: 'Autonome', price: '65 000', popular: false },
  { level: 'C2', name: 'Maîtrise', price: '80 000', popular: false },
];

const testimonials = [
  {
    name: 'Uwimana Clarisse',
    role: 'Apprenante B2',
    school: 'Kigali',
    text: "FLEHub a complètement transformé mon apprentissage du français. Les cours interactifs et les sessions live avec des enseignants qualifiés m'ont permis d'obtenir mon certificat B2 en moins d'un an.",
    rating: 5,
    initials: 'UC',
  },
  {
    name: 'Prof. Niyonzima Jean',
    role: 'Enseignant certifié',
    school: "Lycée de l'Excellence, Butare",
    text: 'La plateforme simplifie considérablement la gestion de mes classes. Je peux suivre la progression de chaque étudiant en temps réel et adapter mon enseignement en conséquence.',
    rating: 5,
    initials: 'NJ',
  },
  {
    name: 'École Bilingue Horizon',
    role: 'Établissement partenaire',
    school: 'Musanze',
    text: "Depuis que nous avons rejoint FLEHub, l'organisation des examens est devenue beaucoup plus fluide. Les rapports détaillés nous aident à améliorer continuellement nos programmes.",
    rating: 5,
    initials: 'EH',
  },
];

const navLinks = [
  { label: 'Fonctionnalités', href: '#features' },
  { label: 'Niveaux CECRL', href: '#cefr' },
  { label: 'Témoignages', href: '#testimonials' },
  { label: 'Tarifs', href: '#pricing' },
];

export default function LandingPage() {
  const [mobileMenuOpen, setMobileMenuOpen] = useState(false);

  return (
    <div className="min-h-screen bg-white font-sans">
      {/* Sticky Navigation */}
      <nav className="sticky top-0 z-50 bg-white/95 backdrop-blur-sm border-b border-gray-100 shadow-sm">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="flex items-center justify-between h-16">
            {/* Logo */}
            <Link href="/" className="flex items-center gap-2.5 group">
              <div className="w-9 h-9 bg-flehub-green rounded-lg flex items-center justify-center shadow-sm group-hover:shadow-md transition-shadow">
                <GraduationCap className="w-5 h-5 text-white" />
              </div>
              <span className="text-xl font-bold text-gray-900">
                FLE<span className="text-flehub-green">Hub</span>
              </span>
            </Link>

            {/* Desktop Nav */}
            <div className="hidden md:flex items-center gap-1">
              {navLinks.map((link) => (
                <a key={link.href} href={link.href} className="nav-link">
                  {link.label}
                </a>
              ))}
            </div>

            {/* Desktop Auth Buttons */}
            <div className="hidden md:flex items-center gap-3">
              <Link
                href="/login"
                className="px-4 py-2 text-sm font-medium text-gray-700 hover:text-flehub-green transition-colors rounded-lg hover:bg-gray-50"
              >
                Se connecter
              </Link>
              <Link
                href="/register"
                className="px-4 py-2 text-sm font-medium text-white bg-flehub-green rounded-lg hover:bg-flehub-green-dark transition-colors shadow-sm"
              >
                S&apos;inscrire
              </Link>
            </div>

            {/* Mobile Menu Toggle */}
            <button
              onClick={() => setMobileMenuOpen(!mobileMenuOpen)}
              className="md:hidden p-2 rounded-lg text-gray-600 hover:bg-gray-100 transition-colors"
              aria-label="Toggle menu"
            >
              {mobileMenuOpen ? <X className="w-5 h-5" /> : <Menu className="w-5 h-5" />}
            </button>
          </div>
        </div>

        {/* Mobile Menu */}
        {mobileMenuOpen && (
          <div className="md:hidden bg-white border-t border-gray-100 px-4 py-4 space-y-1 shadow-lg">
            {navLinks.map((link) => (
              <a
                key={link.href}
                href={link.href}
                onClick={() => setMobileMenuOpen(false)}
                className="block px-3 py-2.5 text-sm font-medium text-gray-700 hover:text-flehub-green hover:bg-gray-50 rounded-lg transition-colors"
              >
                {link.label}
              </a>
            ))}
            <div className="pt-3 border-t border-gray-100 flex flex-col gap-2">
              <Link
                href="/login"
                className="block px-3 py-2.5 text-sm font-medium text-center text-gray-700 border border-gray-200 rounded-lg hover:bg-gray-50 transition-colors"
              >
                Se connecter
              </Link>
              <Link
                href="/register"
                className="block px-3 py-2.5 text-sm font-medium text-center text-white bg-flehub-green rounded-lg hover:bg-flehub-green-dark transition-colors"
              >
                S&apos;inscrire
              </Link>
            </div>
          </div>
        )}
      </nav>

      {/* Hero Section */}
      <section className="gradient-hero text-white overflow-hidden">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-20 lg:py-28">
          <div className="max-w-4xl mx-auto text-center">
            <div className="inline-flex items-center gap-2 bg-white/15 backdrop-blur-sm border border-white/25 rounded-full px-4 py-1.5 text-sm font-medium mb-8">
              <Zap className="w-3.5 h-3.5" />
              Plateforme officielle d&apos;examens FLE au Rwanda
            </div>

            <h1 className="text-4xl sm:text-5xl lg:text-6xl font-extrabold leading-tight tracking-tight mb-6">
              Maîtrisez le Français,{' '}
              <span className="block text-white/90 mt-1">Certifiez Votre Niveau</span>
            </h1>

            <p className="text-lg sm:text-xl text-white/80 max-w-2xl mx-auto mb-10 leading-relaxed">
              FLEHub est la plateforme de gestion des examens et de l&apos;apprentissage du français langue
              étrangère au Rwanda. De A1 à C2, progressez à votre rythme avec des enseignants certifiés.
            </p>

            <div className="flex flex-col sm:flex-row items-center justify-center gap-4 mb-16">
              <Link
                href="/register"
                className="w-full sm:w-auto inline-flex items-center justify-center gap-2 px-8 py-3.5 bg-white text-flehub-green font-semibold rounded-xl hover:bg-gray-50 transition-all shadow-lg hover:shadow-xl text-base"
              >
                Commencer gratuitement
                <ChevronRight className="w-4 h-4" />
              </Link>
              <a
                href="#cefr"
                className="w-full sm:w-auto inline-flex items-center justify-center gap-2 px-8 py-3.5 bg-white/15 border border-white/30 text-white font-semibold rounded-xl hover:bg-white/25 transition-all text-base"
              >
                Découvrir les niveaux
              </a>
            </div>

            {/* Stats */}
            <div className="grid grid-cols-3 gap-6 max-w-2xl mx-auto">
              {[
                { value: '2 400+', label: 'Apprenants actifs' },
                { value: '85+', label: 'Établissements' },
                { value: '6', label: 'Niveaux CECRL' },
              ].map((stat) => (
                <div key={stat.label} className="text-center">
                  <div className="text-3xl sm:text-4xl font-extrabold text-white mb-1">{stat.value}</div>
                  <div className="text-sm text-white/70 font-medium">{stat.label}</div>
                </div>
              ))}
            </div>
          </div>
        </div>

        {/* Wave bottom */}
        <div className="relative h-16 overflow-hidden -mb-1">
          <svg
            className="absolute bottom-0 w-full"
            viewBox="0 0 1440 64"
            fill="none"
            xmlns="http://www.w3.org/2000/svg"
            preserveAspectRatio="none"
          >
            <path d="M0 64L1440 64L1440 0C1200 40 960 64 720 64C480 64 240 40 0 0L0 64Z" fill="white" />
          </svg>
        </div>
      </section>

      {/* CEFR Levels Section */}
      <section id="cefr" className="py-20 bg-white">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="text-center mb-14">
            <span className="inline-block text-sm font-semibold text-flehub-green uppercase tracking-wider mb-3">
              Cadre Européen Commun de Référence
            </span>
            <h2 className="text-3xl sm:text-4xl font-bold text-gray-900 mb-4">
              Six Niveaux, Un Parcours Clair
            </h2>
            <p className="text-lg text-gray-500 max-w-2xl mx-auto">
              Chaque niveau CECRL est structuré avec des objectifs précis, des contenus adaptés et un examen de
              certification officiel.
            </p>
          </div>

          <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-6">
            {cefrLevels.map((item) => (
              <div
                key={item.level}
                className={`rounded-2xl border-2 p-6 card-hover transition-all ${item.color}`}
              >
                <div className="flex items-start justify-between mb-4">
                  <div>
                    <span className={`inline-flex items-center px-3 py-1 rounded-full text-sm font-bold ${item.badge}`}>
                      {item.level}
                    </span>
                    <h3 className="text-lg font-bold text-gray-900 mt-2">{item.name}</h3>
                  </div>
                  <Globe className="w-6 h-6 text-gray-400 mt-1 flex-shrink-0" />
                </div>
                <p className="text-sm text-gray-600 mb-4 leading-relaxed">{item.description}</p>
                <div className="flex flex-wrap gap-2">
                  {item.skills.map((skill) => (
                    <span
                      key={skill}
                      className="text-xs px-2.5 py-1 bg-white/70 text-gray-700 rounded-full border border-gray-200 font-medium"
                    >
                      {skill}
                    </span>
                  ))}
                </div>
              </div>
            ))}
          </div>
        </div>
      </section>

      {/* Features Section */}
      <section id="features" className="py-20 bg-gray-50">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="text-center mb-14">
            <span className="inline-block text-sm font-semibold text-flehub-green uppercase tracking-wider mb-3">
              Fonctionnalités
            </span>
            <h2 className="text-3xl sm:text-4xl font-bold text-gray-900 mb-4">
              Tout ce qu&apos;il vous faut pour réussir
            </h2>
            <p className="text-lg text-gray-500 max-w-2xl mx-auto">
              Une plateforme complète conçue pour répondre aux besoins spécifiques du marché rwandais.
            </p>
          </div>

          <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-8">
            {features.map((feature) => (
              <div
                key={feature.title}
                className="bg-white rounded-2xl p-7 card-hover border border-gray-100 shadow-sm"
              >
                <div className="w-12 h-12 bg-flehub-green-light rounded-xl flex items-center justify-center mb-5">
                  <feature.icon className="w-6 h-6 text-flehub-green" />
                </div>
                <h3 className="text-lg font-bold text-gray-900 mb-2">{feature.title}</h3>
                <p className="text-sm text-gray-500 leading-relaxed">{feature.description}</p>
              </div>
            ))}
          </div>
        </div>
      </section>

      {/* Role Cards Section */}
      <section className="py-20 bg-white">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="text-center mb-14">
            <span className="inline-block text-sm font-semibold text-flehub-green uppercase tracking-wider mb-3">
              Une plateforme pour tous
            </span>
            <h2 className="text-3xl sm:text-4xl font-bold text-gray-900 mb-4">Votre rôle, votre espace</h2>
            <p className="text-lg text-gray-500 max-w-2xl mx-auto">
              Chaque type d&apos;utilisateur dispose d&apos;une interface dédiée adaptée à ses besoins.
            </p>
          </div>

          <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-6">
            {roles.map((role) => (
              <div
                key={role.title}
                className="flex flex-col bg-white rounded-2xl border border-gray-200 overflow-hidden card-hover shadow-sm"
              >
                <div className="p-6 flex-1">
                  <div className="w-12 h-12 bg-flehub-green-light rounded-xl flex items-center justify-center mb-4">
                    <role.icon className="w-6 h-6 text-flehub-green" />
                  </div>
                  <h3 className="text-lg font-bold text-gray-900 mb-2">{role.title}</h3>
                  <p className="text-sm text-gray-500 mb-4 leading-relaxed">{role.description}</p>
                  <ul className="space-y-2">
                    {role.features.map((feat) => (
                      <li key={feat} className="flex items-center gap-2 text-sm text-gray-600">
                        <CheckCircle className="w-4 h-4 text-flehub-green flex-shrink-0" />
                        {feat}
                      </li>
                    ))}
                  </ul>
                </div>
                <div className="p-6 pt-0">
                  <Link
                    href={role.href}
                    className="block w-full text-center px-4 py-2.5 text-sm font-semibold text-flehub-green border-2 border-flehub-green rounded-xl hover:bg-flehub-green hover:text-white transition-all"
                  >
                    {role.cta}
                  </Link>
                </div>
              </div>
            ))}
          </div>
        </div>
      </section>

      {/* Testimonials Section */}
      <section id="testimonials" className="py-20 bg-gray-50">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="text-center mb-14">
            <span className="inline-block text-sm font-semibold text-flehub-green uppercase tracking-wider mb-3">
              Témoignages
            </span>
            <h2 className="text-3xl sm:text-4xl font-bold text-gray-900 mb-4">Ils nous font confiance</h2>
            <p className="text-lg text-gray-500 max-w-2xl mx-auto">
              Découvrez ce que disent nos apprenants, enseignants et établissements partenaires.
            </p>
          </div>

          <div className="grid grid-cols-1 md:grid-cols-3 gap-8">
            {testimonials.map((t) => (
              <div key={t.name} className="bg-white rounded-2xl p-7 border border-gray-100 shadow-sm card-hover">
                <div className="flex items-center gap-1 mb-5">
                  {Array.from({ length: t.rating }).map((_, i) => (
                    <Star key={i} className="w-4 h-4 text-amber-400 fill-amber-400" />
                  ))}
                </div>
                <p className="text-gray-600 text-sm leading-relaxed mb-6 italic">&ldquo;{t.text}&rdquo;</p>
                <div className="flex items-center gap-3">
                  <div className="w-10 h-10 bg-flehub-green rounded-full flex items-center justify-center text-white text-sm font-bold flex-shrink-0">
                    {t.initials}
                  </div>
                  <div>
                    <div className="text-sm font-bold text-gray-900">{t.name}</div>
                    <div className="text-xs text-gray-500">{t.role}</div>
                    <div className="text-xs text-flehub-green font-medium">{t.school}</div>
                  </div>
                </div>
              </div>
            ))}
          </div>
        </div>
      </section>

      {/* Pricing Section */}
      <section id="pricing" className="py-20 bg-white">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="text-center mb-14">
            <span className="inline-block text-sm font-semibold text-flehub-green uppercase tracking-wider mb-3">
              Tarifs
            </span>
            <h2 className="text-3xl sm:text-4xl font-bold text-gray-900 mb-4">
              Frais d&apos;examen transparents
            </h2>
            <p className="text-lg text-gray-500 max-w-2xl mx-auto">
              Des frais d&apos;examen clairs et accessibles, payables via Mobile Money ou virement bancaire.
            </p>
          </div>

          <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-6 max-w-5xl mx-auto">
            {pricing.map((item) => (
              <div
                key={item.level}
                className={`relative rounded-2xl border-2 p-6 text-center card-hover ${
                  item.popular
                    ? 'border-flehub-green shadow-lg shadow-green-100'
                    : 'border-gray-200'
                }`}
              >
                {item.popular && (
                  <div className="absolute -top-3.5 left-1/2 -translate-x-1/2">
                    <span className="bg-flehub-green text-white text-xs font-bold px-4 py-1.5 rounded-full whitespace-nowrap">
                      Le plus populaire
                    </span>
                  </div>
                )}
                <div
                  className={`inline-flex items-center justify-center w-14 h-14 rounded-2xl mb-4 text-2xl font-black ${
                    item.popular ? 'bg-flehub-green text-white' : 'bg-gray-100 text-gray-700'
                  }`}
                >
                  {item.level}
                </div>
                <h3 className="text-lg font-bold text-gray-900 mb-1">{item.name}</h3>
                <div className="text-3xl font-extrabold text-gray-900 mt-3 mb-1">
                  {item.price}
                  <span className="text-base font-medium text-gray-500 ml-1">RWF</span>
                </div>
                <p className="text-xs text-gray-500 mb-5">Par session d&apos;examen</p>
                <div className="space-y-2.5 text-left mb-6">
                  {["Accès à l'examen officiel", 'Résultats détaillés', 'Certificat numérique'].map((feat) => (
                    <div key={feat} className="flex items-center gap-2 text-sm text-gray-600">
                      <CheckCircle className="w-4 h-4 text-flehub-green flex-shrink-0" />
                      {feat}
                    </div>
                  ))}
                </div>
                <Link
                  href="/register"
                  className={`block w-full py-2.5 text-sm font-semibold rounded-xl transition-all ${
                    item.popular
                      ? 'bg-flehub-green text-white hover:bg-flehub-green-dark'
                      : 'border-2 border-flehub-green text-flehub-green hover:bg-flehub-green hover:text-white'
                  }`}
                >
                  S&apos;inscrire au niveau {item.level}
                </Link>
              </div>
            ))}
          </div>

          <p className="text-center text-sm text-gray-500 mt-8 flex items-center justify-center gap-1.5">
            <Clock className="w-4 h-4 text-gray-400" />
            Paiement accepté via MTN Mobile Money, Airtel Money et virement bancaire.
          </p>
        </div>
      </section>

      {/* CTA Banner */}
      <section className="gradient-hero py-16">
        <div className="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 text-center text-white">
          <h2 className="text-3xl sm:text-4xl font-extrabold mb-4">
            Prêt à commencer votre parcours ?
          </h2>
          <p className="text-lg text-white/80 mb-8 max-w-xl mx-auto">
            Rejoignez des milliers d&apos;apprenants au Rwanda qui progressent en français avec FLEHub.
          </p>
          <div className="flex flex-col sm:flex-row items-center justify-center gap-4">
            <Link
              href="/register"
              className="w-full sm:w-auto inline-flex items-center justify-center gap-2 px-8 py-3.5 bg-white text-flehub-green font-bold rounded-xl hover:bg-gray-50 transition-all shadow-lg text-base"
            >
              Créer un compte gratuit
              <ChevronRight className="w-4 h-4" />
            </Link>
            <Link
              href="/login"
              className="w-full sm:w-auto inline-flex items-center justify-center gap-2 px-8 py-3.5 bg-white/15 border border-white/30 text-white font-semibold rounded-xl hover:bg-white/25 transition-all text-base"
            >
              Se connecter
            </Link>
          </div>
        </div>
      </section>

      {/* Footer */}
      <footer className="bg-gray-900 text-gray-400 py-14">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="grid grid-cols-1 md:grid-cols-4 gap-10 mb-10">
            {/* Brand */}
            <div>
              <Link href="/" className="flex items-center gap-2.5 mb-4">
                <div className="w-9 h-9 bg-flehub-green rounded-lg flex items-center justify-center">
                  <GraduationCap className="w-5 h-5 text-white" />
                </div>
                <span className="text-xl font-bold text-white">
                  FLE<span className="text-flehub-green">Hub</span>
                </span>
              </Link>
              <p className="text-sm leading-relaxed">
                La plateforme officielle d&apos;examens et d&apos;apprentissage du français langue étrangère au Rwanda.
              </p>
            </div>

            {/* Platform links */}
            <div>
              <h4 className="text-white font-semibold mb-4 text-sm uppercase tracking-wider">Plateforme</h4>
              <ul className="space-y-2.5 text-sm">
                {['Fonctionnalités', 'Niveaux CECRL', 'Tarifs', 'Témoignages'].map((item) => (
                  <li key={item}>
                    <a href="#" className="hover:text-flehub-green transition-colors">
                      {item}
                    </a>
                  </li>
                ))}
              </ul>
            </div>

            {/* Account links */}
            <div>
              <h4 className="text-white font-semibold mb-4 text-sm uppercase tracking-wider">Compte</h4>
              <ul className="space-y-2.5 text-sm">
                {[
                  { label: 'Se connecter', href: '/login' },
                  { label: "S'inscrire", href: '/register' },
                  { label: 'Espace apprenant', href: '/dashboard/learner' },
                  { label: 'Espace enseignant', href: '/dashboard/teacher' },
                ].map((item) => (
                  <li key={item.label}>
                    <Link href={item.href} className="hover:text-flehub-green transition-colors">
                      {item.label}
                    </Link>
                  </li>
                ))}
              </ul>
            </div>

            {/* Contact */}
            <div>
              <h4 className="text-white font-semibold mb-4 text-sm uppercase tracking-wider">Contact</h4>
              <ul className="space-y-2.5 text-sm">
                <li>Kigali, Rwanda</li>
                <li>
                  <a href="mailto:info@flehub.rw" className="hover:text-flehub-green transition-colors">
                    info@flehub.rw
                  </a>
                </li>
                <li>
                  <a href="tel:+250780000000" className="hover:text-flehub-green transition-colors">
                    +250 780 000 000
                  </a>
                </li>
              </ul>
            </div>
          </div>

          <div className="border-t border-gray-800 pt-8 flex flex-col sm:flex-row items-center justify-between gap-4 text-sm">
            <p>&copy; {new Date().getFullYear()} FLEHub. Tous droits réservés.</p>
            <div className="flex items-center gap-6">
              <a href="#" className="hover:text-flehub-green transition-colors">
                Politique de confidentialité
              </a>
              <a href="#" className="hover:text-flehub-green transition-colors">
                Conditions d&apos;utilisation
              </a>
            </div>
          </div>
        </div>
      </footer>
    </div>
  );
}
