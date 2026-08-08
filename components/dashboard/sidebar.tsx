'use client'

import { useState, useEffect } from 'react'
import Link from 'next/link'
import { usePathname, useRouter } from 'next/navigation'
import { createClient } from '@/lib/supabase/client'
import {
  GraduationCap,
  LayoutDashboard,
  Users,
  FileText,
  Calendar,
  DollarSign,
  Settings,
  BookOpen,
  Video,
  UserCheck,
  MessageSquare,
  Award,
  Shield,
  LogOut,
  ChevronLeft,
  ChevronRight,
  Menu,
  ClipboardList,
  BookOpenCheck,
  PenSquare,
  Newspaper,
  Mic,
  Images,
  Clapperboard,
  Handshake,
  Headphones,
} from 'lucide-react'
import { cn } from '@/lib/utils'
import { Button } from '@/components/ui/button'
import { Avatar, AvatarFallback } from '@/components/ui/avatar'
import { BrandMark } from '@/components/brand-mark'
import { DEFAULT_ORG_SHORT_NAME, DEFAULT_ORG_TAGLINE } from '@/lib/org-branding'

type Role = 'admin' | 'school' | 'teacher' | 'learner' | 'journalist' | 'creator'

interface Profile {
  full_name: string
  email: string
  role: Role
}

interface NavItem {
  label: string
  href: string
  icon: React.ElementType
}

const navByRole: Record<Role, NavItem[]> = {
  admin: [
    { label: 'Dashboard', href: '/dashboard/admin', icon: LayoutDashboard },
    { label: 'Users', href: '/dashboard/admin/users', icon: Shield },
    { label: 'Journalists', href: '/dashboard/admin/journalists', icon: Newspaper },
    { label: 'Creators', href: '/dashboard/admin/creators', icon: Clapperboard },
    { label: 'Partners', href: '/dashboard/admin/partners', icon: Handshake },
    { label: 'Exams', href: '/dashboard/admin/exams', icon: FileText },
    { label: 'School Exam Access', href: '/dashboard/admin/school-exam-access', icon: BookOpenCheck },
    { label: 'Calendar', href: '/dashboard/admin/calendar', icon: Calendar },
    { label: 'Finances', href: '/dashboard/admin/finances', icon: DollarSign },
    { label: 'Settings', href: '/dashboard/admin/settings', icon: Settings },
  ],
  school: [
    { label: 'Dashboard', href: '/dashboard/school', icon: LayoutDashboard },
    { label: 'Students', href: '/dashboard/school/students', icon: Users },
    { label: 'Exam Papers', href: '/dashboard/school/exams', icon: BookOpenCheck },
    { label: 'Exam Results', href: '/dashboard/school/results', icon: ClipboardList },
    { label: 'Certificates', href: '/dashboard/school/certificates', icon: Award },
    { label: 'Settings', href: '/dashboard/school/settings', icon: Settings },
  ],
  teacher: [
    { label: 'Dashboard', href: '/dashboard/teacher', icon: LayoutDashboard },
    { label: 'Modules', href: '/dashboard/teacher/elearning', icon: BookOpen },
    { label: 'Préparation', href: '/dashboard/teacher/preparation', icon: Headphones },
    { label: 'Sessions', href: '/dashboard/teacher/sessions', icon: Video },
    { label: 'Corrections', href: '/dashboard/teacher/corrections', icon: PenSquare },
    { label: 'Learners', href: '/dashboard/teacher/learners', icon: UserCheck },
    { label: 'Messages', href: '/dashboard/teacher/messages', icon: MessageSquare },
    { label: 'Settings', href: '/dashboard/teacher/settings', icon: Settings },
  ],
  learner: [
    { label: 'Dashboard', href: '/dashboard/learner', icon: LayoutDashboard },
    { label: 'eLearning', href: '/dashboard/learner/elearning', icon: BookOpen },
    { label: 'Préparation', href: '/dashboard/learner/preparation', icon: Headphones },
    { label: 'Enseignants', href: '/dashboard/learner/elearning/teachers', icon: GraduationCap },
    { label: 'Sessions', href: '/dashboard/learner/elearning/sessions', icon: Video },
    { label: 'Corrections', href: '/dashboard/learner/corrections', icon: PenSquare },
    { label: 'Certificats', href: '/dashboard/learner/certificates', icon: Award },
  ],
  journalist: [
    { label: 'Dashboard', href: '/dashboard/journalist', icon: LayoutDashboard },
    { label: 'Articles', href: '/dashboard/journalist/articles', icon: Newspaper },
    { label: 'Vidéos', href: '/dashboard/journalist/videos', icon: Video },
    { label: 'Reportages', href: '/dashboard/journalist/reportages', icon: Mic },
    { label: 'Galeries', href: '/dashboard/journalist/galleries', icon: Images },
  ],
  creator: [
    { label: 'Dashboard', href: '/dashboard/creator', icon: LayoutDashboard },
    { label: 'Séries', href: '/dashboard/creator/series', icon: Clapperboard },
  ],
}

interface SidebarProps {
  role: Role
  profile: Profile
  orgShortName?: string
  orgTagline?: string
}

export function Sidebar({
  role,
  profile,
  orgShortName = DEFAULT_ORG_SHORT_NAME,
  orgTagline = DEFAULT_ORG_TAGLINE,
}: SidebarProps) {
  const pathname = usePathname()
  const router = useRouter()
  const supabase = createClient()

  const [collapsed, setCollapsed] = useState(false)
  const [mobileOpen, setMobileOpen] = useState(false)
  const [signingOut, setSigningOut] = useState(false)

  const navItems = navByRole[role] ?? navByRole.learner

  // On desktop, always expanded; on mobile, collapsed by default
  useEffect(() => {
    const handleResize = () => {
      if (window.innerWidth >= 1024) {
        setCollapsed(false)
        setMobileOpen(false)
      } else {
        setCollapsed(true)
      }
    }
    handleResize()
    window.addEventListener('resize', handleResize)
    return () => window.removeEventListener('resize', handleResize)
  }, [])

  const handleSignOut = async () => {
    setSigningOut(true)
    try {
      await supabase.auth.signOut()
      router.push('/login')
    } catch {
      setSigningOut(false)
    }
  }

  const initials = profile.full_name
    ? profile.full_name
        .split(' ')
        .slice(0, 2)
        .map((n) => n[0])
        .join('')
        .toUpperCase()
    : profile.email?.[0]?.toUpperCase() ?? 'U'

  const sidebarWidth = collapsed ? 'w-16' : 'w-60'

  const SidebarContent = () => (
    <div className="flex h-full flex-col bg-white border-r border-gray-200 shadow-sm">
      {/* Logo */}
      <div className="flex min-h-16 items-center justify-between gap-1 px-3 py-2.5 border-b border-gray-100">
        <Link href={`/dashboard/${role}`} className="flex items-center gap-2 min-w-0 flex-1">
          <div className="flex-shrink-0 flex items-center justify-center w-8 h-8 rounded-lg bg-[#00A550]">
            <GraduationCap className="w-5 h-5 text-white" />
          </div>
          {!collapsed && (
            <BrandMark
              shortName={orgShortName}
              tagline={orgTagline}
              size="sm"
              className="min-w-0"
            />
          )}
        </Link>
        {/* Desktop collapse toggle */}
        <button
          onClick={() => setCollapsed((v) => !v)}
          className="hidden lg:flex items-center justify-center w-6 h-6 rounded text-gray-400 hover:text-gray-600 hover:bg-gray-100 transition-colors"
          aria-label={collapsed ? 'Expand sidebar' : 'Collapse sidebar'}
        >
          {collapsed ? (
            <ChevronRight className="w-4 h-4" />
          ) : (
            <ChevronLeft className="w-4 h-4" />
          )}
        </button>
      </div>

      {/* Navigation */}
      <nav className="flex-1 overflow-y-auto py-4 px-2 space-y-1">
        {navItems.map((item) => {
          const Icon = item.icon
          const isActive =
            item.href === `/dashboard/${role}`
              ? pathname === item.href
              : pathname.startsWith(item.href)

          return (
            <Link
              key={item.href}
              href={item.href}
              onClick={() => setMobileOpen(false)}
              className={cn(
                'sidebar-link flex items-center gap-3 rounded-lg px-3 py-2.5 text-sm font-medium transition-all duration-150',
                isActive
                  ? 'sidebar-link active bg-[#E6F5EE] text-[#00A550]'
                  : 'text-gray-600 hover:bg-gray-50 hover:text-gray-900',
                collapsed && 'justify-center px-2'
              )}
              title={collapsed ? item.label : undefined}
            >
              <Icon
                className={cn(
                  'flex-shrink-0',
                  collapsed ? 'w-5 h-5' : 'w-4 h-4',
                  isActive ? 'text-[#00A550]' : 'text-gray-500'
                )}
              />
              {!collapsed && <span className="truncate">{item.label}</span>}
            </Link>
          )
        })}
      </nav>

      {/* User section */}
      <div className="border-t border-gray-100 p-3 space-y-2">
        <div
          className={cn(
            'flex items-center gap-3 rounded-lg p-2',
            collapsed && 'justify-center'
          )}
        >
          <Avatar className="flex-shrink-0 w-8 h-8">
            <AvatarFallback className="bg-[#00A550] text-white text-xs font-semibold">
              {initials}
            </AvatarFallback>
          </Avatar>
          {!collapsed && (
            <div className="min-w-0 flex-1">
              <p className="text-sm font-medium text-gray-900 truncate">
                {profile.full_name || 'User'}
              </p>
              <p className="text-xs text-gray-500 truncate">{profile.email}</p>
            </div>
          )}
        </div>

        <Button
          variant="ghost"
          size="sm"
          onClick={handleSignOut}
          disabled={signingOut}
          className={cn(
            'w-full text-gray-600 hover:text-red-600 hover:bg-red-50 transition-colors',
            collapsed ? 'justify-center px-2' : 'justify-start gap-2'
          )}
          title={collapsed ? 'Sign Out' : undefined}
        >
          <LogOut className="w-4 h-4 flex-shrink-0" />
          {!collapsed && <span>{signingOut ? 'Signing out…' : 'Sign Out'}</span>}
        </Button>
      </div>
    </div>
  )

  return (
    <>
      {/* Mobile hamburger */}
      <button
        onClick={() => setMobileOpen((v) => !v)}
        className="lg:hidden fixed top-4 left-4 z-50 flex items-center justify-center w-9 h-9 rounded-lg bg-white border border-gray-200 shadow-sm text-gray-600 hover:text-gray-900"
        aria-label="Toggle navigation"
      >
        <Menu className="w-5 h-5" />
      </button>

      {/* Mobile overlay */}
      {mobileOpen && (
        <div
          className="lg:hidden fixed inset-0 z-40 bg-black/40"
          onClick={() => setMobileOpen(false)}
          aria-hidden
        />
      )}

      {/* Mobile drawer */}
      <aside
        className={cn(
          'lg:hidden fixed top-0 left-0 z-40 h-full w-60 transition-transform duration-200',
          mobileOpen ? 'translate-x-0' : '-translate-x-full'
        )}
      >
        <SidebarContent />
      </aside>

      {/* Desktop sidebar */}
      <aside
        className={cn(
          'hidden lg:flex fixed top-0 left-0 z-30 h-full flex-col transition-all duration-200',
          sidebarWidth
        )}
      >
        <SidebarContent />
      </aside>
    </>
  )
}
