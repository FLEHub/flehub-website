'use client'

import { usePathname } from 'next/navigation'
import { Header } from '@/components/dashboard/header'

type Role = 'admin' | 'school' | 'teacher' | 'learner'

interface Profile {
  full_name: string
  email: string
  role: Role
}

interface DashboardHeaderProps {
  profile: Profile
}

const TITLE_MAP: Record<string, string> = {
  '/dashboard/admin': 'Admin Dashboard',
  '/dashboard/admin/users': 'User Management',
  '/dashboard/admin/exams': 'Exam Sessions',
  '/dashboard/admin/exam-papers': 'Sujets PDF',
  '/dashboard/admin/results': 'Validation résultats',
  '/dashboard/admin/calendar': 'Calendar',
  '/dashboard/admin/finances': 'Finances',
  '/dashboard/school': 'Accueil école',
  '/dashboard/school/students': 'Mes élèves',
  '/dashboard/school/exams': 'Examens',
  '/dashboard/school/results': 'Résultats',
  '/dashboard/school/certificates': 'Certificats',
  '/dashboard/school/settings': 'Paramètres école',
  '/dashboard/school/profile': 'Profil école',
  '/dashboard/teacher': 'Teacher Dashboard',
  '/dashboard/learner': 'Learner Dashboard',
  '/dashboard/messages': 'Messages',
}

function titleFromPath(pathname: string): string {
  if (TITLE_MAP[pathname]) return TITLE_MAP[pathname]

  const segments = pathname.split('/').filter(Boolean)
  if (segments.length >= 2) {
    const section = segments[segments.length - 1]
    return section
      .split('-')
      .map((word) => word.charAt(0).toUpperCase() + word.slice(1))
      .join(' ')
  }

  return 'Dashboard'
}

export function DashboardHeader({ profile }: DashboardHeaderProps) {
  const pathname = usePathname()
  const title = titleFromPath(pathname)

  return <Header title={title} profile={profile} />
}
