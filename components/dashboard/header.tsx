'use client'

import { useState, useEffect, useRef } from 'react'
import Link from 'next/link'
import { useRouter } from 'next/navigation'
import { createClient } from '@/lib/supabase/client'
import {
  Bell,
  ChevronDown,
  User,
  Settings,
  LogOut,
} from 'lucide-react'
import { cn } from '@/lib/utils'
import { Button } from '@/components/ui/button'
import { Avatar, AvatarFallback } from '@/components/ui/avatar'
import { Badge } from '@/components/ui/badge'

interface Profile {
  full_name: string
  email: string
  role: string
}

interface HeaderProps {
  title: string
  profile: Profile
}

interface Notification {
  id: string
  title: string
  body: string
  is_read: boolean
  created_at: string
}

export function Header({ title, profile }: HeaderProps) {
  const router = useRouter()
  const supabase = createClient()

  const [unreadCount, setUnreadCount] = useState(0)
  const [notifications, setNotifications] = useState<Notification[]>([])
  const [notifOpen, setNotifOpen] = useState(false)
  const [userMenuOpen, setUserMenuOpen] = useState(false)
  const [signingOut, setSigningOut] = useState(false)

  const notifRef = useRef<HTMLDivElement>(null)
  const userMenuRef = useRef<HTMLDivElement>(null)

  const initials = profile.full_name
    ? profile.full_name
        .split(' ')
        .slice(0, 2)
        .map((n) => n[0])
        .join('')
        .toUpperCase()
    : profile.email?.[0]?.toUpperCase() ?? 'U'

  // Fetch unread notifications
  useEffect(() => {
    const fetchNotifications = async () => {
      try {
        const { data, error } = await supabase
          .from('notifications')
          .select('id, title, body, is_read, created_at')
          .eq('is_read', false)
          .order('created_at', { ascending: false })
          .limit(10)

        if (!error && data) {
          setNotifications(data)
          setUnreadCount(data.length)
        }
      } catch {
        // Silently fail — notifications are non-critical
      }
    }

    fetchNotifications()

    // Subscribe to real-time changes
    const channel = supabase
      .channel('notifications-changes')
      .on(
        'postgres_changes',
        { event: '*', schema: 'public', table: 'notifications' },
        () => {
          fetchNotifications()
        }
      )
      .subscribe()

    return () => {
      supabase.removeChannel(channel)
    }
  }, [supabase])

  // Close dropdowns on outside click
  useEffect(() => {
    const handleClick = (e: MouseEvent) => {
      if (notifRef.current && !notifRef.current.contains(e.target as Node)) {
        setNotifOpen(false)
      }
      if (userMenuRef.current && !userMenuRef.current.contains(e.target as Node)) {
        setUserMenuOpen(false)
      }
    }
    document.addEventListener('mousedown', handleClick)
    return () => document.removeEventListener('mousedown', handleClick)
  }, [])

  const markAllRead = async () => {
    try {
      await supabase
        .from('notifications')
        .update({ is_read: true })
        .eq('is_read', false)
      setNotifications([])
      setUnreadCount(0)
    } catch {
      // Silently fail
    }
  }

  const handleSignOut = async () => {
    setSigningOut(true)
    setUserMenuOpen(false)
    try {
      await supabase.auth.signOut()
      router.push('/login')
    } catch {
      setSigningOut(false)
    }
  }

  const roleDashboardPath = {
    admin: '/dashboard/admin',
    school: '/dashboard/school',
    teacher: '/dashboard/teacher',
    learner: '/dashboard/learner',
  }[profile.role] ?? '/dashboard'

  return (
    <header className="fixed top-0 left-0 right-0 z-20 h-16 bg-white border-b border-gray-200 shadow-sm lg:left-60">
      <div className="flex h-full items-center justify-between px-4 sm:px-6">
        {/* Page title */}
        <div className="flex items-center gap-3 pl-10 lg:pl-0">
          <h1 className="text-lg font-semibold text-gray-900 truncate">{title}</h1>
        </div>

        {/* Right side actions */}
        <div className="flex items-center gap-2">
          {/* Notification bell */}
          <div className="relative" ref={notifRef}>
            <button
              onClick={() => {
                setNotifOpen((v) => !v)
                setUserMenuOpen(false)
              }}
              className="relative flex items-center justify-center w-9 h-9 rounded-lg text-gray-500 hover:text-gray-900 hover:bg-gray-100 transition-colors"
              aria-label="Notifications"
            >
              <Bell className="w-5 h-5" />
              {unreadCount > 0 && (
                <span className="absolute -top-0.5 -right-0.5 flex items-center justify-center w-4 h-4 rounded-full bg-[#00A550] text-white text-[10px] font-bold leading-none">
                  {unreadCount > 9 ? '9+' : unreadCount}
                </span>
              )}
            </button>

            {notifOpen && (
              <div className="absolute right-0 top-11 w-80 bg-white rounded-xl border border-gray-200 shadow-lg overflow-hidden z-50">
                <div className="flex items-center justify-between px-4 py-3 border-b border-gray-100">
                  <span className="font-semibold text-sm text-gray-900">Notifications</span>
                  {unreadCount > 0 && (
                    <button
                      onClick={markAllRead}
                      className="text-xs text-[#00A550] hover:underline font-medium"
                    >
                      Mark all read
                    </button>
                  )}
                </div>

                <div className="max-h-72 overflow-y-auto divide-y divide-gray-50">
                  {notifications.length === 0 ? (
                    <div className="px-4 py-8 text-center text-sm text-gray-500">
                      No new notifications
                    </div>
                  ) : (
                    notifications.map((n) => (
                      <div
                        key={n.id}
                        className="px-4 py-3 hover:bg-gray-50 transition-colors cursor-pointer"
                      >
                        <p className="text-sm font-medium text-gray-900 line-clamp-1">
                          {n.title}
                        </p>
                        {n.body && (
                          <p className="text-xs text-gray-500 mt-0.5 line-clamp-2">
                            {n.body}
                          </p>
                        )}
                        <p className="text-xs text-gray-400 mt-1">
                          {new Date(n.created_at).toLocaleDateString('en-RW', {
                            month: 'short',
                            day: 'numeric',
                            hour: '2-digit',
                            minute: '2-digit',
                          })}
                        </p>
                      </div>
                    ))
                  )}
                </div>

                <div className="border-t border-gray-100 px-4 py-2">
                  <Link
                    href={`${roleDashboardPath}/notifications`}
                    className="block text-center text-xs text-[#00A550] hover:underline py-1"
                    onClick={() => setNotifOpen(false)}
                  >
                    View all notifications
                  </Link>
                </div>
              </div>
            )}
          </div>

          {/* User menu */}
          <div className="relative" ref={userMenuRef}>
            <button
              onClick={() => {
                setUserMenuOpen((v) => !v)
                setNotifOpen(false)
              }}
              className="flex items-center gap-2 rounded-lg px-2 py-1.5 hover:bg-gray-100 transition-colors"
              aria-label="User menu"
            >
              <Avatar className="w-7 h-7">
                <AvatarFallback className="bg-[#00A550] text-white text-xs font-semibold">
                  {initials}
                </AvatarFallback>
              </Avatar>
              <span className="hidden sm:block text-sm font-medium text-gray-700 max-w-[120px] truncate">
                {profile.full_name || profile.email}
              </span>
              <ChevronDown
                className={cn(
                  'hidden sm:block w-4 h-4 text-gray-400 transition-transform duration-150',
                  userMenuOpen && 'rotate-180'
                )}
              />
            </button>

            {userMenuOpen && (
              <div className="absolute right-0 top-11 w-52 bg-white rounded-xl border border-gray-200 shadow-lg overflow-hidden z-50">
                <div className="px-4 py-3 border-b border-gray-100">
                  <p className="text-sm font-semibold text-gray-900 truncate">
                    {profile.full_name || 'User'}
                  </p>
                  <p className="text-xs text-gray-500 truncate">{profile.email}</p>
                  <Badge
                    variant="secondary"
                    className="mt-1 text-[10px] capitalize bg-[#E6F5EE] text-[#00A550] border-0"
                  >
                    {profile.role}
                  </Badge>
                </div>

                <div className="py-1">
                  <Link
                    href={`${roleDashboardPath}/profile`}
                    className="flex items-center gap-2.5 px-4 py-2 text-sm text-gray-700 hover:bg-gray-50 hover:text-gray-900 transition-colors"
                    onClick={() => setUserMenuOpen(false)}
                  >
                    <User className="w-4 h-4 text-gray-400" />
                    Profile
                  </Link>
                  <Link
                    href={`${roleDashboardPath}/settings`}
                    className="flex items-center gap-2.5 px-4 py-2 text-sm text-gray-700 hover:bg-gray-50 hover:text-gray-900 transition-colors"
                    onClick={() => setUserMenuOpen(false)}
                  >
                    <Settings className="w-4 h-4 text-gray-400" />
                    Settings
                  </Link>
                </div>

                <div className="border-t border-gray-100 py-1">
                  <button
                    onClick={handleSignOut}
                    disabled={signingOut}
                    className="flex w-full items-center gap-2.5 px-4 py-2 text-sm text-red-600 hover:bg-red-50 transition-colors disabled:opacity-50"
                  >
                    <LogOut className="w-4 h-4" />
                    {signingOut ? 'Signing out…' : 'Sign Out'}
                  </button>
                </div>
              </div>
            )}
          </div>
        </div>
      </div>
    </header>
  )
}
